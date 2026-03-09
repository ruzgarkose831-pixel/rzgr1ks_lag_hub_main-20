local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer

_G.Settings = {
    UndergroundBody = false,
    UnderArms = false,
    HiddenHead = false,
    BatHitbox = true, 
    BatSize = 25, 
    PlayerHB = false, 
    PlayerHBSize = 15,
    Speed = true, 
    SpeedVal = 60, 
    Spin = false, 
    SpinSpeed = 100,
    AntiRagdoll = true,
    AutoAttack = false,
    Galaxy = false
}

-- UI Setup
local gui = Instance.new("ScreenGui", Player.PlayerGui); gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 190, 0, 360)
main.Position = UDim2.new(1, -200, 0.5, -180)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Instance.new("UICorner", main)

local stroke = Instance.new("UIStroke", main); stroke.Thickness = 1.5
RunService.RenderStepped:Connect(function() stroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -45); scroll.Position = UDim2.new(0, 5, 0, 35)
scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 0; scroll.CanvasSize = UDim2.new(0, 0, 0, 1100)
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 6)

-- Close/Open
local close = Instance.new("TextButton", main); close.Size = UDim2.new(0, 25, 0, 25); close.Position = UDim2.new(1, -30, 0, 5); close.Text = "X"; close.TextColor3 = Color3.new(1,0,0); close.BackgroundTransparency = 1
close.MouseButton1Click:Connect(function() main.Visible = false; _G.Icon.Visible = true end)

_G.Icon = Instance.new("TextButton", gui); _G.Icon.Size = UDim2.new(0, 45, 0, 45); _G.Icon.Position = UDim2.new(0.9, 0, 0.2, 0); _G.Icon.Text = "rzgr1ks"; _G.Icon.Visible = false; _G.Icon.BackgroundColor3 = Color3.fromRGB(20,20,20); Instance.new("UICorner", _G.Icon)
_G.Icon.MouseButton1Click:Connect(function() main.Visible = true; _G.Icon.Visible = false end)

-- Improved Toggle
local function AddToggle(text, key)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(1, 0, 0, 28); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.Text = text; b.TextColor3 = Color3.new(1, 1, 1); b.Font = 3; b.TextSize = 11; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() _G.Settings[key] = not _G.Settings[key] end)
    RunService.RenderStepped:Connect(function() b.TextColor3 = _G.Settings[key] and Color3.new(0, 1, 0) or Color3.new(1, 1, 1) end)
end

-- BIGGER SLIDERS
local function AddSlider(text, min, max, key)
    local f = Instance.new("Frame", scroll); f.Size = UDim2.new(1, 0, 0, 40); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 15); l.Text = text .. ": " .. _G.Settings[key]; l.TextColor3 = Color3.new(1, 1, 1); l.BackgroundTransparency = 1; l.TextSize = 10; l.Font = 3
    
    local bar = Instance.new("TextButton", f); bar.Size = UDim2.new(1, -10, 0, 8); bar.Position = UDim2.new(0, 5, 1, -12); bar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2); bar.Text = ""; Instance.new("UICorner", bar)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((_G.Settings[key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.new(0, 1, 0); Instance.new("UICorner", fill)
    
    local function update()
        local p = math.clamp((UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        _G.Settings[key] = math.floor(min + (max - min) * p); l.Text = text .. ": " .. _G.Settings[key]; fill.Size = UDim2.new(p, 0, 1, 0)
    end
    
    bar.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then update() end
        end)
        update()
        UIS.InputEnded:Once(function() move:Disconnect() end)
    end)
end

-- Features List
AddToggle("Underground Body", "UndergroundBody")
AddToggle("Underground Arms", "UnderArms")
AddToggle("Hidden Head", "HiddenHead")
AddToggle("Bat Hitbox", "BatHitbox")
AddSlider("Bat Area", 5, 150, "BatSize")
AddToggle("Player Hitbox", "PlayerHB")
AddSlider("Player Area", 2, 60, "PlayerHBSize")
AddToggle("Speed Hack", "Speed")
AddSlider("Speed Setting", 16, 300, "SpeedVal")
AddToggle("Spin Bot", "Spin")
AddSlider("Spin Power", 10, 600, "SpinSpeed")
AddToggle("Anti Ragdoll", "AntiRagdoll")
AddToggle("Auto Attack", "AutoAttack")
AddToggle("Galaxy Mode", "Galaxy")

-- Core Loop
RunService.RenderStepped:Connect(function()
    local char = Player.Character; if not (char and char:FindFirstChild("Humanoid")) then return end
    local hum = char.Humanoid; local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- 1. Underground Body (Fixed)
    hum.HipHeight = _G.Settings.UndergroundBody and -3.0 or 2.0

    -- 2. Underground Arms (Fixed rotation)
    if _G.Settings.UnderArms then
        local rs = char:FindFirstChild("RightShoulder", true); local ls = char:FindFirstChild("LeftShoulder", true)
        if rs then rs.C0 = CFrame.new(1, -5, 0) * CFrame.Angles(math.pi, 0, 0) end
        if ls then ls.C0 = CFrame.new(-1, -5, 0) * CFrame.Angles(math.pi, 0, 0) end
    end

    -- 3. Hidden Head
    if _G.Settings.HiddenHead then
        local n = char:FindFirstChild("Neck", true); if n then n.C0 = CFrame.new(0, -1.2, 0) end
    end

    -- 4. Bat Hitbox (Bigger/Wider)
    if _G.Settings.BatHitbox then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, p in pairs(tool:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Size = Vector3.new(_G.Settings.BatSize, _G.Settings.BatSize, _G.Settings.BatSize)
                    p.Transparency = 0.7; p.CanCollide = false; p.Massless = true
                end
            end
        end
    end

    -- 5. Movement
    hum.AutoRotate = not _G.Settings.Spin
    local sv = root:FindFirstChild("SpinV") or Instance.new("BodyAngularVelocity", root); sv.Name = "SpinV"
    sv.MaxTorque = Vector3.new(0, math.huge, 0); sv.AngularVelocity = _G.Settings.Spin and Vector3.new(0, _G.Settings.SpinSpeed, 0) or Vector3.new(0,0,0)
    
    if _G.Settings.Speed then hum.WalkSpeed = _G.Settings.SpeedVal end
    if _G.Settings.AntiRagdoll then hum.PlatformStand = false end
    if _G.Settings.AutoAttack then local t = char:FindFirstChildOfClass("Tool"); if t then t:Activate() end end
    
    if _G.Settings.Galaxy then Lighting.ClockTime = 0; Lighting.OutdoorAmbient = Color3.fromRGB(120,0,255) end
end)
