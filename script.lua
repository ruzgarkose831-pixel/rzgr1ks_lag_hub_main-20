local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Eski GUI temizliği
local old = player:WaitForChild("PlayerGui"):FindFirstChild("LemonStyleHub")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "LemonStyleHub"
ScreenGui.ResetOnSpawn = false

-- States
_G.Aimbot = false
_G.AimbotFOV = 150
_G.SpeedBoost = false
_G.ESP = false
_G.InfJump = false
_G.JumpPower = 15
_G.SpeedValue = 60

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 460
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 255, 0)

-- [SARI TOP BUTONU]
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
OpenBtn.Text = "AÇ"
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

-- [ANA PANEL] (Hiyerarşi ve Tasarım V11 ile Aynı)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 400, 0, 450)
Main.Position = UDim2.new(0.5, -200, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
Main.Active = true
Main.Draggable = true

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 35); Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = "LEMON HUB V11 - BYPASS EDITION"; Title.TextColor3 = Color3.fromRGB(255, 200, 0); Title.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -50); Scroll.Position = UDim2.new(0, 10, 0, 45); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
local UIList = Instance.new("UIListLayout", Scroll); UIList.Padding = UDim.new(0, 10)

-- Helper Functions (Toggle/Slider) aynı kaldı...
local function addToggle(name, callback)
    local Frame = Instance.new("Frame", Scroll); Frame.Size = UDim2.new(1, 0, 0, 40); Frame.BackgroundTransparency = 1
    local Btn = Instance.new("TextButton", Frame); Btn.Size = UDim2.new(0, 45, 0, 22); Btn.Position = UDim2.new(1, -50, 0.5, -11); Btn.BackgroundColor3 = Color3.fromRGB(40,40,40); Btn.Text = ""; Instance.new("UICorner", Btn).CornerRadius = UDim.new(1,0)
    local Circle = Instance.new("Frame", Btn); Circle.Size = UDim2.new(0, 18, 0, 18); Circle.Position = UDim2.new(0, 2, 0.5, -9); Circle.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", Circle).CornerRadius = UDim.new(1,0)
    local Lbl = Instance.new("TextLabel", Frame); Lbl.Size = UDim2.new(0.7,0,1,0); Lbl.Text = name; Lbl.TextColor3 = Color3.new(0.8,0.8,0.8); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = "Left"
    local active = false
    Btn.Activated:Connect(function()
        active = not active
        Btn.BackgroundColor3 = active and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(40, 40, 40)
        Circle:TweenPosition(active and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9), "Out", "Quad", 0.1, true)
        callback(active)
    end)
end

local function addSlider(name, min, max, default, callback)
    local Frame = Instance.new("Frame", Scroll); Frame.Size = UDim2.new(1, 0, 0, 50); Frame.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel", Frame); Label.Size = UDim2.new(1, 0, 0, 20); Label.Text = name .. ": " .. default; Label.TextColor3 = Color3.fromRGB(255, 200, 0); Label.BackgroundTransparency = 1; Label.TextXAlignment = "Left"
    local Bar = Instance.new("Frame", Frame); Bar.Size = UDim2.new(1, -10, 0, 4); Bar.Position = UDim2.new(0, 0, 0.7, 0); Bar.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local Knob = Instance.new("TextButton", Bar); Knob.Size = UDim2.new(0, 12, 0, 12); Knob.Position = UDim2.new((default-min)/(max-min), -6, 0.5, -6); Knob.Text = ""; Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)
    local dragging = false
    Knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((UIS:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Knob.Position = UDim2.new(pos, -6, 0.5, -6)
            local val = math.floor(min + (max-min)*pos); Label.Text = name .. ": " .. val; callback(val)
        end
    end)
end

-- ÖZELLİKLER
addToggle("Aimbot (Silent Lock)", function(v) _G.Aimbot = v end)
addSlider("Aimbot FOV", 50, 500, 150, function(v) _G.AimbotFOV = v end)
addToggle("Speed Bypass", function(v) _G.SpeedBoost = v end)
addSlider("Boost Speed", 16, 250, 60, function(v) _G.SpeedValue = v end)
addToggle("Player ESP", function(v) _G.ESP = v end)
addToggle("Infinite Jump", function(v) _G.InfJump = v end)
addSlider("Jump Power", 0, 100, 15, function(v) _G.JumpPower = v end)

-- Kapatma Logic
local Close = Instance.new("TextButton", Header)
Close.Size = UDim2.new(0,30,0,30); Close.Position = UDim2.new(1,-35,0,2); Close.Text = "X"; Close.TextColor3 = Color3.new(1,1,1); Close.BackgroundTransparency = 1
Close.Activated:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.Activated:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

-- TARGETING
local function getClosest()
    local target, minMag = nil, _G.AimbotFOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            local pos, vis = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if mag < minMag then target = p; minMag = mag end
            end
        end
    end
    return target
end

-- [ANA MOTOR - BYPASS & SILENT AIM]
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.Aimbot
    FOVCircle.Radius = _G.AimbotFOV
    FOVCircle.Position = UIS:GetMouseLocation()

    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local hum = char.Humanoid

        -- BYPASS SPEED (Anti-Cheat'e yakalanmayan hız)
        if _G.SpeedBoost and hum.MoveDirection.Magnitude > 0 then
            local s = char:FindFirstChildOfClass("Tool") and 30 or _G.SpeedValue
            -- Karakteri teleport ederek hızı bypass ediyoruz
            root.CFrame = root.CFrame + (hum.MoveDirection * (s/50))
        end

        hum.JumpPower = _G.JumpPower
    end

    -- AIMBOT (Hard Lock & Camera Redirect)
    if _G.Aimbot then
        local target = getClosest()
        if target and (UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UIS:IsKeyDown(Enum.KeyCode.ButtonR2)) then
            -- Kamerayı doğrudan rakibin kafasına/gövdesine kilitler
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
        end
    end

    if _G.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local h = p.Character:FindFirstChild("LemonHighlight") or Instance.new("Highlight", p.Character)
                h.Name = "LemonHighlight"; h.FillColor = Color3.fromRGB(255, 200, 0)
            end
        end
    end
end)

-- Inf Jump
UIS.JumpRequest:Connect(function()
    if _G.InfJump then player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
