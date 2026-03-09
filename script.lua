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

-- UI Setup (English & Compact)
local gui = Instance.new("ScreenGui", Player.PlayerGui); gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 190, 0, 380)
main.Position = UDim2.new(1, -200, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", main)
local stroke = Instance.new("UIStroke", main); stroke.Thickness = 1.5
RunService.RenderStepped:Connect(function() stroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -45); scroll.Position = UDim2.new(0, 5, 0, 35)
scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 0; scroll.CanvasSize = UDim2.new(0, 0, 0, 1100)
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 6)

-- Open/Close
local close = Instance.new("TextButton", main); close.Size = UDim2.new(0, 25, 0, 25); close.Position = UDim2.new(1, -30, 0, 5); close.Text = "X"; close.TextColor3 = Color3.new(1,0,0); close.BackgroundTransparency = 1
close.MouseButton1Click:Connect(function() main.Visible = false; _G.Icon.Visible = true end)

_G.Icon = Instance.new("TextButton", gui); _G.Icon.Size = UDim2.new(0, 45, 0, 45); _G.Icon.Position = UDim2.new(0.9, 0, 0.2, 0); _G.Icon.Text = "🍋"; _G.Icon.Visible = false; _G.Icon.BackgroundColor3 = Color3.fromRGB(20,20,20); Instance.new("UICorner", _G.Icon)
_G.Icon.MouseButton1Click:Connect(function() main.Visible = true; _G.Icon.Visible = false end)

local function AddToggle(text, key)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(1, 0, 0, 28); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.Text = text; b.TextColor3 = Color3.new(1, 1, 1); b.Font = 3; b.TextSize = 11; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() _G.Settings[key] = not _G.Settings[key] end)
    RunService.RenderStepped:Connect(function() b.TextColor3 = _G.Settings[key] and Color3.new(0, 1, 0) or Color3.new(1, 1, 1) end)
end

local function AddSlider(text, min, max, key)
    local f = Instance.new("Frame", scroll); f.Size = UDim2.new(1, 0, 0, 42); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 15); l.Text = text .. ": " .. _G.Settings[key]; l.TextColor3 = Color3.new(1, 1, 1); l.BackgroundTransparency = 1; l.TextSize = 10; l.Font = 3
    local bar = Instance.new("TextButton", f); bar.Size = UDim2.new(1, -10, 0, 12); bar.Position = UDim2.new(0, 5, 1, -12); bar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2); bar.Text = ""; Instance.new("UICorner", bar)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((_G.Settings[key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.new(0, 1, 0); Instance.new("UICorner", fill)
    local function update()
        local p = math.clamp((UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        _G.Settings[key] = math.floor(min + (max - min) * p); l.Text = text .. ": " .. _G.Settings[key]; fill.Size = UDim2.new(p, 0, 1, 0)
    end
    bar.MouseButton1Down:Connect(function() local move; move = UIS.InputChanged:Connect(function(i) if i.UserInputType.Value == 0 or i.UserInputType.Value == 8 then update() end end) update() UIS.InputEnded:Once(function() move:Disconnect() end) end)
end

-- Menu Items
AddToggle("Underground Body", "UndergroundBody")
AddToggle("Underground Arms", "UnderArms")
AddToggle("Hidden Head", "HiddenHead")
AddToggle("Bat Hitbox (Fixed)", "BatHitbox")
AddSlider("Bat Size", 5, 150, "BatSize")
AddToggle("Player Hitbox", "PlayerHB")
AddSlider("Player Size", 2, 60, "PlayerHBSize")
AddToggle("Speed Hack", "Speed")
AddSlider("Speed Val", 16, 250, "SpeedVal")
AddToggle("Spin Bot", "Spin")
AddSlider("Spin Val", 10, 500, "SpinSpeed")
AddToggle("Auto Attack", "AutoAttack")

-- Hitbox Engines
RunService.RenderStepped:Connect(function()
    local char = Player.Character; if not char then return end
    
    -- ABSOLUTE BAT HITBOX
    if _G.Settings.BatHitbox then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, p in pairs(tool:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Size = Vector3.new(_G.Settings.BatSize, _G.Settings.BatSize, _G.Settings.BatSize)
                    p.Transparency = 0.8
                    p.CanCollide = false
                    p.Massless = true
                    -- Visual Guide
                    if not p:FindFirstChild("HB_Box") then
                        local b = Instance.new("SelectionBox", p); b.Name = "HB_Box"; b.Adornee = p; b.LineThickness = 0.05; b.Color3 = Color3.new(1,0,0)
                    end
                end
            end
        end
    end

    -- PLAYER HITBOX (CLASSIC)
    if _G.Settings.PlayerHB then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(_G.Settings.PlayerHBSize, _G.Settings.PlayerHBSize, _G.Settings.PlayerHBSize)
                v.Character.HumanoidRootPart.Transparency = 0.7
                v.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end

    -- BODY MODS
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if hum and root then
        hum.HipHeight = _G.Settings.UndergroundBody and -3.0 or 2.0
        if _G.Settings.UnderArms then
            local rs = char:FindFirstChild("RightShoulder", true); local ls = char:FindFirstChild("LeftShoulder", true)
            if rs then rs.C0 = CFrame.new(1, -5, 0) * CFrame.Angles(math.pi, 0, 0) end
            if ls then ls.C0 = CFrame.new(-1, -5, 0) * CFrame.Angles(math.pi, 0, 0) end
        end
        if _G.Settings.HiddenHead then
            local n = char:FindFirstChild("Neck", true); if n then n.C0 = CFrame.new(0, -1.2, 0) end
        end
        
        -- MOVEMENT
        hum.AutoRotate = not _G.Settings.Spin
        local sv = root:FindFirstChild("SpinV") or Instance.new("BodyAngularVelocity", root); sv.Name = "SpinV"
        sv.MaxTorque = Vector3.new(0, math.huge, 0); sv.AngularVelocity = _G.Settings.Spin and Vector3.new(0, _G.Settings.SpinSpeed, 0) or Vector3.new(0,0,0)
        if _G.Settings.Speed then hum.WalkSpeed = _G.Settings.SpeedVal end
        if _G.Settings.AutoAttack then local t = char:FindFirstChildOfClass("Tool"); if t then t:Activate() end end
    end
end)
