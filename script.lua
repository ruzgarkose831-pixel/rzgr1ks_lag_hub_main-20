--[[ 
    rzgr1ks DUEL - V134 (STABLE & DRAGGABLE)
    - FIXED: Buttons now respond instantly.
    - NEW: Draggable GUI (Touch & Mouse).
    - STYLE: Compact Lemon Premium (Smaller size).
    - FIXED: All core features (Auto Walk, Hitbox, Float).
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- 1. DATA (Simplified & Direct)
_G.Data = {
    BatAimbot = false, AimbotRadius = 50,
    SpamBat = false, AutoAttack = false,
    SpeedBoost = false, BoostSpeed = 44,
    SpinBot = false, SpinSpeed = 50,
    GalaxyMode = false, GalaxyBrightVal = 50,
    JumpMod = false, JumpPowerVal = 50,
    AutoWalk = false, Points = {}, 
    FloatEnabled = false, FloatOffset = -3.5,
    HitboxBooster = false, HB_Size = 25
}

-- 2. DRAGGABLE FUNCTION
local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- 3. UI CONSTRUCTION (Compact & Small)
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui")); gui.Name = "rzgr1ks_V134"; gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui); main.Size = UDim2.new(0, 320, 0, 380); main.Position = UDim2.new(0.5, -160, 0.5, -190); main.BackgroundColor3 = Color3.fromRGB(15, 15, 20); main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10); Instance.new("UIStroke", main).Color = Color3.fromRGB(255, 140, 0)
MakeDraggable(main)

-- ICON
local icon = Instance.new("TextButton", gui); icon.Size = UDim2.new(0, 45, 0, 45); icon.Position = UDim2.new(0, 10, 0.5, -22); icon.Text = "🍋"; icon.TextSize = 25; icon.BackgroundColor3 = main.BackgroundColor3; icon.BorderSizePixel = 0; Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 22)
icon.MouseButton1Click:Connect(function() main.Visible = not main.Visible; icon.Visible = not main.Visible end)

local header = Instance.new("TextButton", main); header.Size = UDim2.new(1, 0, 0, 35); header.Text = "rzgr1ks DUEL - CLOSE"; header.TextColor3 = Color3.new(1,1,1); header.BackgroundColor3 = Color3.fromRGB(25, 25, 30); header.Font = "GothamBold"; header.TextSize = 12
header.MouseButton1Click:Connect(function() main.Visible = false; icon.Visible = true end)

local scroll = Instance.new("ScrollingFrame", main); scroll.Size = UDim2.new(1, -10, 1, -45); scroll.Position = UDim2.new(0, 5, 0, 40); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 1200)
local list = Instance.new("UIListLayout", scroll); list.Padding = UDim.new(0, 3)

-- 4. IMPROVED BUTTONS & SLIDERS
local function AddToggle(txt, key)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(1, 0, 0, 28); b.BackgroundColor3 = Color3.fromRGB(30, 30, 35); b.Text = txt .. ": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 10; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        _G.Data[key] = not _G.Data[key]
        b.Text = txt .. ": " .. (_G.Data[key] and "ON" or "OFF")
        b.TextColor3 = _G.Data[key] and Color3.fromRGB(255, 140, 0) or Color3.new(1,1,1)
    end)
end

local function AddSlider(txt, min, max, key, cb)
    local f = Instance.new("Frame", scroll); f.Size = UDim2.new(1, 0, 0, 40); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = txt .. ": " .. _G.Data[key]; l.Size = UDim2.new(1, 0, 0, 15); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 9
    local bar = Instance.new("Frame", f); bar.Size = UDim2.new(1, -20, 0, 8); bar.Position = UDim2.new(0, 10, 1, -15); bar.BackgroundColor3 = Color3.fromRGB(50,50,55); Instance.new("UICorner", bar)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((_G.Data[key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 140, 0); Instance.new("UICorner", fill)
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local function Update()
                local p = math.clamp((UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0)
                local v = math.floor(min + (max - min) * p)
                l.Text = txt .. ": " .. v; _G.Data[key] = v; if cb then cb(v) end
            end
            local conn; conn = UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then Update() end end)
            UIS.InputEnded:Once(function() conn:Disconnect() end); Update()
        end
    end)
end

-- 5. BUTTON LIST
AddToggle("AUTO ATTACK", "AutoAttack")
AddToggle("SPAM BAT", "SpamBat")
AddToggle("SPEED BOOST", "SpeedBoost")
AddSlider("WALK SPEED", 16, 500, "BoostSpeed")
AddToggle("JUMP MOD", "JumpMod")
AddSlider("JUMP POWER", 20, 500, "JumpPowerVal")
AddToggle("GALAXY MODE", "GalaxyMode")
AddToggle("HITBOX BOOSTER", "HitboxBooster")
AddSlider("HITBOX SIZE", 2, 100, "HB_Size")
AddToggle("FLOAT PLATFORM", "FloatEnabled")
AddSlider("FLOAT LEVEL", -15, 10, "FloatOffset")
AddToggle("SPIN BOT", "SpinBot")
AddToggle("AUTO WALK", "AutoWalk")
local pBtn = Instance.new("TextButton", scroll); pBtn.Size = UDim2.new(1, 0, 0, 28); pBtn.Text = "SAVE WALK POINT"; pBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200); pBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", pBtn)
pBtn.MouseButton1Click:Connect(function() table.insert(_G.Data.Points, player.Character.HumanoidRootPart.Position) end)

-- 6. ENGINE (FIXED)
local platform = Instance.new("Part", workspace); platform.Size = Vector3.new(15, 1, 15); platform.Transparency = 1; platform.Anchored = true; platform.CanCollide = false

RunService.Heartbeat:Connect(function()
    local char = player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid")
    if not (hrp and hum) then return end

    -- Float
    if _G.Data.FloatEnabled then platform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + _G.Data.FloatOffset, hrp.Position.Z); platform.CanCollide = true else platform.CanCollide = false end

    -- Speed
    if _G.Data.SpeedBoost then hum.WalkSpeed = _G.Data.BoostSpeed end
    
    -- Hitbox
    if _G.Data.HitboxBooster then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(_G.Data.HB_Size, _G.Data.HB_Size, _G.Data.HB_Size)
                v.Character.HumanoidRootPart.Transparency = 0.7; v.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end

    -- Combat
    if _G.Data.AutoAttack or _G.Data.SpamBat then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end
end)

-- Auto Walk Logic
task.spawn(function()
    while task.wait(0.5) do
        if _G.Data.AutoWalk and #_G.Data.Points > 0 and player.Character then
            for _, pos in pairs(_G.Data.Points) do
                if not _G.Data.AutoWalk then break end
                local hum = player.Character:FindFirstChild("Humanoid")
                if hum then hum:MoveTo(pos) repeat task.wait(0.1) until (player.Character.HumanoidRootPart.Position - pos).Magnitude < 5 or not _G.Data.AutoWalk end
            end
        end
    end
end)
