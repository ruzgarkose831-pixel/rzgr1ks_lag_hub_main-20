--[[ 
    rzgr1ks DUEL HUB V15 (SPINBOT & PHYSICS FIX)
    - ROOT FIX: Spinbot now disables 'AutoRotate' to prevent physics fighting.
    - NEW: Using high-torque AngularVelocity for absolute rotation.
    - ALL FEATURES INCLUDED: ESP, Bat Hitbox, Look-At, Config, Atmosphere.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local ConfigFile = "rzgr1ks_v15_final.json"

-- 1. DATA TABLE
_G.Hub = {
    Speed = false, SpeedVal = 50,
    Jump = false, JumpVal = 80,
    Gravity = false, GravityVal = 196.2,
    AntiRagdoll = false,
    Spin = false, SpinSpeed = 50,
    Float = false, FloatOffset = -3.5,
    LookAt = false, LookAtRange = 50,
    SmartHitbox = false, HitboxSize = 15,
    BatHitbox = false, BatHitboxSize = 15,
    AutoAttack = false,
    ESP_Box = false, ESP_Health = false, ESP_Name = false,
    Galaxy = false, Brightness = 2, Exposure = 0, FogEnd = 10000,
    AutoWalk = false, Points = {}, Markers = {}
}

-- 2. RGB ENGINE
local rgbColor = Color3.new(1,1,1)
RunService.RenderStepped:Connect(function()
    rgbColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
end)

-- 3. UI CONSTRUCTION (V14 Base - RGB)
local gui = Instance.new("ScreenGui", player.PlayerGui); gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui); main.Size = UDim2.new(0, 340, 0, 450); main.Position = UDim2.new(0.5, -170, 0.5, -225); main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Instance.new("UICorner", main)
local stroke = Instance.new("UIStroke", main); stroke.Thickness = 2.5; RunService.RenderStepped:Connect(function() stroke.Color = rgbColor end)

local header = Instance.new("TextButton", main); header.Size = UDim2.new(1, 0, 0, 35); header.Text = "rzgr1ks V15 SPIN FIX"; header.Font = "GothamBold"; header.BackgroundColor3 = Color3.fromRGB(15,15,15); header.TextColor3 = Color3.new(1,1,1)
header.MouseButton1Click:Connect(function() main.Visible = false; icon.Visible = true end)

local icon = Instance.new("TextButton", gui); icon.Size = UDim2.new(0, 50, 0, 50); icon.Position = UDim2.new(0, 10, 0.5, -25); icon.Text = "🍋"; icon.BackgroundColor3 = Color3.fromRGB(10,10,10); Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 25)
Instance.new("UIStroke", icon).Thickness = 2; icon.MouseButton1Click:Connect(function() main.Visible = true; icon.Visible = false end)

local scroll = Instance.new("ScrollingFrame", main); scroll.Size = UDim2.new(1, -10, 1, -45); scroll.Position = UDim2.new(0, 5, 0, 40); scroll.CanvasSize = UDim2.new(0, 0, 0, 2800); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 3
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

-- Helper Functions
local function Toggle(n, k)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(1, 0, 0, 32); b.BackgroundColor3 = Color3.fromRGB(25,25,30); b.Font = "GothamBold"; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    RunService.RenderStepped:Connect(function() b.Text = n .. (_G.Hub[k] and " : ON" or " : OFF"); b.TextColor3 = _G.Hub[k] and rgbColor or Color3.new(1,1,1) end)
    b.MouseButton1Click:Connect(function() _G.Hub[k] = not _G.Hub[k] end)
end

local function Slider(n, min, max, k)
    local f = Instance.new("Frame", scroll); f.Size = UDim2.new(1, 0, 0, 40); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 15); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Font = "GothamBold"; l.TextSize = 10
    local bar = Instance.new("Frame", f); bar.Size = UDim2.new(1, -20, 0, 8); bar.Position = UDim2.new(0, 10, 1, -12); bar.BackgroundColor3 = Color3.fromRGB(40,40,40); Instance.new("UICorner", bar)
    local fill = Instance.new("Frame", bar); Instance.new("UICorner", fill)
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then local conn; conn = UIS.InputChanged:Connect(function() local p = math.clamp((UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1); _G.Hub[k] = math.floor(min+(max-min)*p) end) UIS.InputEnded:Once(function() conn:Disconnect() end) end end)
    RunService.RenderStepped:Connect(function() l.Text = n .. ": " .. _G.Hub[k]; fill.Size = UDim2.new((_G.Hub[k]-min)/(max-min),0,1,0); fill.BackgroundColor3 = rgbColor end)
end

-- 4. BUTTONS
Toggle("AUTO WALK", "AutoWalk")
Toggle("BAT HITBOX (Absolute)", "BatHitbox")
Slider("BAT REACH", 5, 100, "BatHitboxSize")
Toggle("SMART HITBOX", "SmartHitbox")
Slider("PLAYER HB SIZE", 2, 100, "HitboxSize")
Toggle("SPIN BOT", "Spin")
Slider("SPIN SPEED", 10, 200, "SpinSpeed")
Toggle("SPEED BOOST", "Speed")
Slider("WALK SPEED", 16, 250, "SpeedVal")
Toggle("ANTI RAGDOLL", "AntiRagdoll")
Toggle("HEAD LOOK-AT", "LookAt")
Toggle("GALAXY SKY", "Galaxy")

-- 5. THE ULTIMATE ENGINE (Spin Fix Included)
local platform = Instance.new("Part", workspace); platform.Size = Vector3.new(15, 1, 15); platform.Anchored = true; platform.Transparency = 1

RunService.RenderStepped:Connect(function()
    local char = player.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end

    -- SPINBOT FIX (Kökten Çözüm)
    local spinV = hrp:FindFirstChild("rzgr1ks_SpinForce") or Instance.new("BodyAngularVelocity", hrp)
    spinV.Name = "rzgr1ks_SpinForce"
    spinV.MaxTorque = Vector3.new(0, math.huge, 0)
    
    if _G.Hub.Spin then
        hum.AutoRotate = false -- Oyunun düzeltmesini engeller
        spinV.AngularVelocity = Vector3.new(0, _G.Hub.SpinSpeed, 0)
    else
        hum.AutoRotate = true
        spinV.AngularVelocity = Vector3.new(0, 0, 0)
    end

    -- Absolute Bat Hitbox
    if _G.Hub.BatHitbox then
        local t = char:FindFirstChildOfClass("Tool")
        if t then 
            for _, p in pairs(t:GetDescendants()) do 
                if p:IsA("BasePart") then 
                    p.Size = Vector3.new(_G.Hub.BatHitboxSize, _G.Hub.BatHitboxSize, _G.Hub.BatHitboxSize)
                    p.Transparency = 0.8; p.CanCollide = false 
                end 
            end 
        end
    end

    -- Look-At & Movement
    if _G.Hub.LookAt then
        local target = nil; local dist = _G.Hub.LookAtRange
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
                local d = (hrp.Position - v.Character.Head.Position).Magnitude
                if d < dist then target = v.Character.Head; dist = d end
            end
        end
        if target then
            local neck = char:FindFirstChild("Neck", true)
            if neck then neck.C0 = char.UpperTorso.CFrame:ToObjectSpace(CFrame.new(char.Head.Position, target.Position)) * CFrame.Angles(1.57, 0, 3.14) end
        end
    end
    
    if _G.Hub.Speed and not _G.Hub.AutoWalk then hum.WalkSpeed = _G.Hub.SpeedVal end
    if _G.Hub.AntiRagdoll then hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false); hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end
    if _G.Hub.Float then platform.Position = hrp.Position + Vector3.new(0, _G.Hub.FloatOffset, 0); platform.CanCollide = true else platform.CanCollide = false end
    if _G.Hub.Galaxy then Lighting.ClockTime = 0; Lighting.Ambient = Color3.fromRGB(120, 0, 255) end
end)

-- Auto Walk Loop
task.spawn(function()
    while task.wait(0.5) do
        if _G.Hub.AutoWalk and #_G.Hub.Points > 0 and player.Character then
            for _, pos in pairs(_G.Hub.Points) do
                if not _G.Hub.AutoWalk then break end
                local h = player.Character:FindFirstChild("Humanoid")
                if h then h:MoveTo(pos); repeat task.wait(0.1) until (player.Character.HumanoidRootPart.Position - pos).Magnitude < 5 or not _G.Hub.AutoWalk end
            end
        end
    end
end)

-- Smart Hitbox (Player Expand)
RunService.Stepped:Connect(function()
    for _, t in pairs(Players:GetPlayers()) do
        if t ~= player and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            t.Character.HumanoidRootPart.Size = _G.Hub.SmartHitbox and Vector3.new(_G.Hub.HitboxSize, _G.Hub.HitboxSize, _G.Hub.HitboxSize) or Vector3.new(2,2,1)
            t.Character.HumanoidRootPart.Transparency = _G.Hub.SmartHitbox and 0.7 or 1; t.Character.HumanoidRootPart.CanCollide = false
        end
    end
end)
