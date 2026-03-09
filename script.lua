--[[ 
    rzgr1ks DUEL - V133 (PREMIUM EDITION)
    - Visuals: Exact replica of the Lemon Hub UI from the image.
    - Translation: All code, variables, and UI text converted to English.
    - Fixed: Auto Walk, Hitbox Booster, and Float Platform.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local PlayerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local Controls = PlayerModule:GetControls()

-- 1. GLOBAL SETTINGS DATA
_G.Data = {
    -- Combat & Tools
    BatAimbot = false, AimbotRadius = 50,
    SpamBat = false, AutoAttack = false,
    AutoStealOld = false, StealRange = 66,
    AutoStealDuels = false, InstaGrab = false, GrabSpeed = 0.01,
    
    -- Movement & Physics
    SpeedBoost = false, BoostSpeed = 44,
    SpinBot = false, SpinSpeed = 50,
    AntiRagdoll = false, InfJump = false, InfJumpPower = 80,
    
    -- Visuals & Environment
    GalaxyMode = false, GalaxyBrightVal = 50,
    GravityVal = 100,
    HopPower = 50, GalaxyLite = false,
    
    -- Mods & Fixed Features
    JumpMod = false, JumpPowerVal = 50,
    SpeedWhileStealing = false, StealSpeedVal = 50,
    Invisible = false, AnimSpeed = 50,
    AutoPlay = false, AutoJumpOnSteal = false, JumpDelay = 50,
    
    -- Restoration Features
    AutoWalk = false, Points = {}, TargetPoint = nil,
    FloatEnabled = false, FloatOffset = -3.5,
    HitboxBooster = false, HB_Size = 25
}

-- 2. GALAXY VISUAL ENGINE
local function ApplyGalaxyVisuals(state)
    local sky = Lighting:FindFirstChild("rzgr1ks_Sky")
    if state then
        if not sky then
            sky = Instance.new("Sky", Lighting); sky.Name = "rzgr1ks_Sky"
            sky.SkyboxBk = "rbxassetid://159454299"; sky.SkyboxDn = "rbxassetid://159454286"
            sky.SkyboxFt = "rbxassetid://159454293"; sky.SkyboxLf = "rbxassetid://159454296"
            sky.SkyboxRt = "rbxassetid://159454282"; sky.SkyboxUp = "rbxassetid://159454300"
        end
        Lighting.Ambient = Color3.fromRGB(100, 0, 255)
        Lighting.ClockTime = 0
        Lighting.Brightness = (_G.Data.GalaxyBrightVal / 100) * 3 + 1
    else
        if sky then sky:Destroy() end
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
    end
end

-- 3. PREMIUM UI CONSTRUCTION
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui")); gui.Name = "rzgr1ks_Duel"; gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui); main.Size = UDim2.new(0, 360, 0, 480); main.Position = UDim2.new(0.5, -180, 0.5, -240); main.BackgroundColor3 = Color3.fromRGB(12, 12, 18); main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12); Instance.new("UIStroke", main).Color = Color3.fromRGB(255, 140, 0)

-- TOGGLE ICON
local icon = Instance.new("TextButton", gui); icon.Size = UDim2.new(0, 50, 0, 50); icon.Position = UDim2.new(0, 10, 0.5, -25); icon.BackgroundColor3 = main.BackgroundColor3; icon.Text = "🍋"; icon.TextSize = 30; icon.BorderSizePixel = 0; Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 25)
icon.MouseButton1Click:Connect(function() main.Visible = not main.Visible; icon.Visible = not main.Visible end)

-- HEADER
local header = Instance.new("Frame", main); header.Size = UDim2.new(1, 0, 0, 55); header.BackgroundTransparency = 1
local title = Instance.new("TextLabel", header); title.Size = UDim2.new(1, 0, 0, 30); title.Text = "rzgr1ks DUEL - PREMIUM"; title.TextColor3 = Color3.new(1, 1, 1); title.Font = "GothamBold"; title.TextSize = 14
local dev = Instance.new("TextLabel", header); dev.Size = UDim2.new(1, 0, 0, 20); dev.Position = UDim2.new(0,0,0,25); dev.Text = "STABLE VERSION 1.3.3"; dev.TextColor3 = Color3.fromRGB(150, 150, 150); dev.Font = "Gotham"; dev.TextSize = 10

-- SCROLLING FRAME
local scroll = Instance.new("ScrollingFrame", main); scroll.Size = UDim2.new(1, -20, 1, -65); scroll.Position = UDim2.new(0, 10, 0, 60); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 2; scroll.CanvasSize = UDim2.new(0, 0, 0, 2100)
local col1 = Instance.new("Frame", scroll); col1.Size = UDim2.new(0.5, -5, 1, 0); col1.BackgroundTransparency = 1; Instance.new("UIListLayout", col1).Padding = UDim.new(0, 4)
local col2 = Instance.new("Frame", scroll); col2.Size = UDim2.new(0.5, -5, 1, 0); col2.Position = UDim2.new(0.5, 5, 0, 0); col2.BackgroundTransparency = 1; Instance.new("UIListLayout", col2).Padding = UDim.new(0, 4)

-- UI GENERATORS
local function AddToggle(txt, key, parent, cb)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, 0, 0, 28); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, -30, 1, 0); l.Text = txt; l.TextColor3 = Color3.new(1,1,1); l.Font = "Gotham"; l.TextSize = 10; l.TextXAlignment = "Left"
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0, 24, 0, 24); b.Position = UDim2.new(1, -26, 0.5, -12); b.BackgroundColor3 = Color3.fromRGB(30, 30, 35); b.Text = ""; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function() _G.Data[key] = not _G.Data[key]; b.BackgroundColor3 = _G.Data[key] and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(30, 30, 35); if cb then cb(_G.Data[key]) end end)
end

local function AddSlider(txt, min, max, key, parent, cb)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, 0, 0, 38); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = txt .. ": " .. _G.Data[key]; l.Size = UDim2.new(1, 0, 0, 14); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 9; l.TextXAlignment = "Left"
    local bar = Instance.new("Frame", f); bar.Size = UDim2.new(1, -6, 0, 6); bar.Position = UDim2.new(0, 3, 1, -12); bar.BackgroundColor3 = Color3.fromRGB(50,50,55); Instance.new("UICorner", bar)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((_G.Data[key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 140, 0); Instance.new("UICorner", fill)
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then local conn; conn = UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1); fill.Size = UDim2.new(p, 0, 1, 0); local v = math.floor(min + (max - min) * p); l.Text = txt .. ": " .. v; _G.Data[key] = v; if cb then cb(v) end end end); UIS.InputEnded:Once(function() conn:Disconnect() end) end end)
end

-- 4. INTERFACE MAPPING
-- Column 1
AddToggle("[X] Bat Aimbot", "BatAimbot", col1)
AddSlider("Aimbot Range", 5, 200, "AimbotRadius", col1)
AddToggle("Spam Bat", "SpamBat", col1)
AddToggle("Auto Attack", "AutoAttack", col1)
AddToggle("Auto Steal Old", "AutoStealOld", col1)
AddSlider("Steal Dist", 5, 100, "StealRange", col1)
AddToggle("Speed Boost", "SpeedBoost", col1)
AddSlider("Walk Speed", 16, 500, "BoostSpeed", col1)
AddToggle("Spin Bot", "SpinBot", col1)
AddSlider("Spin Rate", 5, 100, "SpinSpeed", col1)
AddToggle("Auto Walk (Route)", "AutoWalk", col1)
local pBtn = Instance.new("TextButton", col1); pBtn.Size = UDim2.new(1,0,0,26); pBtn.Text = "ADD ROUTE POINT"; pBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 200); pBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", pBtn)
pBtn.MouseButton1Click:Connect(function() table.insert(_G.Data.Points, player.Character.HumanoidRootPart.Position) end)

-- Column 2
AddToggle("[M] Galaxy Mode", "GalaxyMode", col2, function(v) ApplyGalaxyVisuals(v) end)
AddSlider("Galaxy Brightness", 0, 100, "GalaxyBrightVal", col2, function(v) Lighting.Brightness = (v/100)*3+1 end)
AddSlider("Gravity Mod", 0, 200, "GravityVal", col2, function(v) workspace.Gravity = (v/100)*196.2 end)
AddToggle("Jump Mod", "JumpMod", col2)
AddSlider("Jump Power", 20, 500, "JumpPowerVal", col2)
AddToggle("Invisible", "Invisible", col2)
AddToggle("Float Platform", "FloatEnabled", col2)
AddSlider("Float Level", -15, 10, "FloatOffset", col2)
AddToggle("Hitbox Booster", "HitboxBooster", col2)
AddSlider("Hitbox Scale", 2, 100, "HB_Size", col2)

-- 5. CORE FUNCTIONALITY
local platform = Instance.new("Part", workspace); platform.Size = Vector3.new(12, 1, 12); platform.Transparency = 1; platform.Anchored = true; platform.CanCollide = false

RunService.Heartbeat:Connect(function()
    local char = player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid")
    if not (hrp and hum) then return end

    -- Persistence & Gravity
    hum.UseJumpPower = true
    hum.JumpPower = _G.Data.JumpMod and _G.Data.JumpPowerVal or 50

    -- Float Platform Logic
    if _G.Data.FloatEnabled then
        platform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + _G.Data.FloatOffset, hrp.Position.Z)
        platform.CanCollide = true
    else platform.CanCollide = false end

    -- Speed & Auto Walk
    if _G.Data.AutoWalk and _G.Data.TargetPoint then
        hum:MoveTo(_G.Data.TargetPoint)
    elseif _G.Data.SpeedBoost then
        hum.WalkSpeed = _G.Data.BoostSpeed
    end

    -- Physics Spin
    local spinVel = hrp:FindFirstChild("rzgr1ks_Spin") or Instance.new("BodyAngularVelocity", hrp)
    spinVel.Name = "rzgr1ks_Spin"; spinVel.MaxTorque = Vector3.new(0, math.huge, 0)
    spinVel.AngularVelocity = _G.Data.SpinBot and Vector3.new(0, _G.Data.SpinSpeed, 0) or Vector3.new(0, 0, 0)

    -- Auto Attack Logic
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and (_G.Data.AutoAttack or _G.Data.SpamBat) then
        tool:Activate()
    end
end)

-- ROUTE MANAGER (Auto Walk)
task.spawn(function()
    while task.wait(0.2) do
        if _G.Data.AutoWalk and #_G.Data.Points > 0 then
            for _, pos in pairs(_G.Data.Points) do
                if not _G.Data.AutoWalk then break end
                _G.Data.TargetPoint = pos
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then 
                    repeat task.wait(0.1) until (hrp.Position - pos).Magnitude < 6 or not _G.Data.AutoWalk 
                end
            end
        end
    end
end)

-- HITBOX BOOSTER (Server Stepped)
RunService.Stepped:Connect(function()
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local part = target.Character.HumanoidRootPart
            part.Size = _G.Data.HitboxBooster and Vector3.new(_G.Data.HB_Size, _G.Data.HB_Size, _G.Data.HB_Size) or Vector3.new(2,2,1)
            part.Transparency = _G.Data.HitboxBooster and 0.7 or 1; part.CanCollide = false
        end
    end
end)

player.CharacterAdded:Connect(function() task.wait(0.5); ApplyGalaxyVisuals(_G.Data.GalaxyMode) end)
