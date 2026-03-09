local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer

_G.Settings = {
    UndergroundBody = false, UnderArms = false, HiddenHead = false,
    BatHitbox = true, BatSize = 45, 
    PlayerHB = false, PlayerHBSize = 25,
    Speed = true, SpeedVal = 75,
    Spin = false, SpinSpeed = 200,
    AutoAttack = false
}

-- UI Setup (Extreme Large Sliders & Minimize)
local gui = Instance.new("ScreenGui", Player.PlayerGui); gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 220, 0, 460); main.Position = UDim2.new(1, -230, 0.5, -230); main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Instance.new("UICorner", main); local st = Instance.new("UIStroke", main); st.Thickness = 2.5
RunService.RenderStepped:Connect(function() st.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)

-- Minimize & Close Buttons
local min = Instance.new("TextButton", main); min.Size = UDim2.new(0, 30, 0, 30); min.Position = UDim2.new(1, -65, 0, 5); min.Text = "_"; min.TextColor3 = Color3.new(1,1,1); min.BackgroundTransparency = 1; min.TextSize = 25
local cl = Instance.new("TextButton", main); cl.Size = UDim2.new(0, 30, 0, 30); cl.Position = UDim2.new(1, -35, 0, 5); cl.Text = "X"; cl.TextColor3 = Color3.new(1,0,0); cl.BackgroundTransparency = 1; cl.TextSize = 18

local icon = Instance.new("TextButton", gui); icon.Size = UDim2.new(0, 60, 0, 60); icon.Position = UDim2.new(0.9, 0, 0.2, 0); icon.Text = "🍋"; icon.Visible = false; icon.BackgroundColor3 = Color3.fromRGB(10,10,10); Instance.new("UICorner", icon)

min.MouseButton1Click:Connect(function() main.Visible = false; icon.Visible = true end)
icon.MouseButton1Click:Connect(function() main.Visible = true; icon.Visible = false end)
cl.MouseButton1Click:Connect(function() gui:Destroy() end)

local sc = Instance.new("ScrollingFrame", main)
sc.Size = UDim2.new(1, -10, 1, -60); sc.Position = UDim2.new(0, 5, 0, 50); sc.BackgroundTransparency = 1; sc.ScrollBarThickness = 0; sc.CanvasSize = UDim2.new(0, 0, 0, 1250)
Instance.new("UIListLayout", sc).Padding = UDim.new(0, 12)

-- Functions
local function AddToggle(t, k)
    local b = Instance.new("TextButton", sc); b.Size = UDim2.new(1, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(20, 20, 20); b.Text = t; b.TextColor3 = Color3.new(1, 1, 1); b.Font = 3; b.TextSize = 14; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() _G.Settings[k] = not _G.Settings[k] end)
    RunService.RenderStepped:Connect(function() b.TextColor3 = _G.Settings[k] and Color3.new(0, 1, 0) or Color3.new(1, 1, 1) end)
end

local function AddSlider(t, min, max, k)
    local f = Instance.new("Frame", sc); f.Size = UDim2.new(1, 0, 0, 65); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 22); l.Text = t .. ": " .. _G.Settings[k]; l.TextColor3 = Color3.new(1, 1, 1); l.BackgroundTransparency = 1; l.TextSize = 12; l.Font = 3
    local bar = Instance.new("TextButton", f); bar.Size = UDim2.new(1, -10, 0, 20); bar.Position = UDim2.new(0, 5, 1, -25); bar.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1); bar.Text = ""; Instance.new("UICorner", bar)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((_G.Settings[k]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.new(0, 1, 0); Instance.new("UICorner", fill)
    local function up()
        local p = math.clamp((UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        _G.Settings[k] = math.floor(min + (max - min) * p); l.Text = t .. ": " .. _G.Settings[k]; fill.Size = UDim2.new(p, 0, 1, 0)
    end
    bar.MouseButton1Down:Connect(function() local m; m = UIS.InputChanged:Connect(function(i) if i.UserInputType.Value == 0 or i.UserInputType.Value == 8 then up() end end) up() UIS.InputEnded:Once(function() m:Disconnect() end) end)
end

-- Menu Items
AddToggle("Underground Body (Bypass)", "UndergroundBody")
AddToggle("Underground Arms", "UnderArms")
AddToggle("Hidden Head", "HiddenHead")
AddToggle("OMEGA BAT REACH", "BatHitbox")
AddSlider("Hitbox Radius", 5, 500, "BatSize")
AddToggle("Classic Player HB", "PlayerHB")
AddSlider("Player HB Size", 2, 150, "PlayerHBSize")
AddToggle("Speed Hack", "Speed")
AddSlider("Speed Value", 16, 600, "SpeedVal")
AddToggle("Spin Bot", "Spin")
AddToggle("Auto Clicker", "AutoAttack")

-- CORE OVERRIDE ENGINE
RunService.RenderStepped:Connect(function()
    local char = Player.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    -- 1. ABSOLUTE UNDERGROUND (Bypass Ground Collision)
    if _G.Settings.UndergroundBody and hum and root then
        hum.HipHeight = -4.5 -- Forced Height
        root.Velocity = Vector3.new(root.Velocity.X, -10, root.Velocity.Z) -- Constant Downward Pull
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false -- Stop ground from pushing you up
            end
        end
    elseif hum then
        hum.HipHeight = 2.0 -- Reset
    end

    -- 2. BAT HITBOX ENGINE
    if _G.Settings.BatHitbox then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, p in pairs(tool:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Size = Vector3.new(_G.Settings.BatSize, _G.Settings.BatSize, _G.Settings.BatSize)
                    p.Transparency = 0.8; p.CanCollide = false; p.Massless = true
                    for _, enemy in pairs(Players:GetPlayers()) do
                        if enemy ~= Player and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
                            firetouchinterest(p, enemy.Character.HumanoidRootPart, 0)
                            firetouchinterest(p, enemy.Character.HumanoidRootPart, 1)
                        end
                    end
                end
            end
        end
    end

    -- 3. PLAYER HITBOX & MOVEMENT
    if _G.Settings.PlayerHB then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(_G.Settings.PlayerHBSize, _G.Settings.PlayerHBSize, _G.Settings.PlayerHBSize)
                v.Character.HumanoidRootPart.Transparency = 0.8; v.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end

    if hum and root then
        if _G.Settings.UnderArms then
            local rs = char:FindFirstChild("RightShoulder",true); local ls = char:FindFirstChild("LeftShoulder",true)
            if rs then rs.C0 = CFrame.new(1,-7,0)*CFrame.Angles(math.pi,0,0) end
            if ls then ls.C0 = CFrame.new(-1,-7,0)*CFrame.Angles(math.pi,0,0) end
        end
        if _G.Settings.HiddenHead then
            local n = char:FindFirstChild("Neck",true); if n then n.C0 = CFrame.new(0,-1.8,0) end
        end
        hum.AutoRotate = not _G.Settings.Spin
        local sv = root:FindFirstChild("SpinV") or Instance.new("BodyAngularVelocity", root)
        sv.Name = "SpinV"; sv.MaxTorque = Vector3.new(0, math.huge, 0)
        sv.AngularVelocity = _G.Settings.Spin and Vector3.new(0, _G.Settings.SpinSpeed, 0) or Vector3.new(0,0,0)
        if _G.Settings.Speed then hum.WalkSpeed = _G.Settings.SpeedVal end
        if _G.Settings.AutoAttack then local t = char:FindFirstChildOfClass("Tool"); if t then t:Activate() end end
    end
end)
