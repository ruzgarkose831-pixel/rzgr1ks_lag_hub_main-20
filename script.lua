local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Temizlik
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
_G.JumpPower = 50 -- Varsayılan Roblox zıplama gücü
_G.SpeedValue = 60

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 460
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 255, 0)

-- [SARI TOP / OPEN BUTTON]
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
OpenBtn.Text = ""
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenBtn).Thickness = 2

-- [ANA PANEL]
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 400)
Main.Position = UDim2.new(0.5, -175, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
Main.Active = true
Main.Draggable = true

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 35); Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = "rzgr1ks Hub V16 - Stabil"; Title.TextColor3 = Color3.fromRGB(255, 200, 0); Title.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -50); Scroll.Position = UDim2.new(0, 10, 0, 45); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 1.5, 0)
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 10)

-- Helpers
local function addToggle(name, callback)
    local Frame = Instance.new("Frame", Scroll); Frame.Size = UDim2.new(1, 0, 0, 40); Frame.BackgroundTransparency = 1
    local Btn = Instance.new("TextButton", Frame); Btn.Size = UDim2.new(0, 45, 0, 22); Btn.Position = UDim2.new(1, -50, 0.5, -11); Btn.BackgroundColor3 = Color3.fromRGB(40,40,40); Btn.Text = ""; Instance.new("UICorner", Btn).CornerRadius = UDim.new(1,0)
    local Lbl = Instance.new("TextLabel", Frame); Lbl.Size = UDim2.new(0.7,0,1,0); Lbl.Text = name; Lbl.TextColor3 = Color3.new(0.9,0.9,0.9); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = "Left"
    local active = false
    Btn.Activated:Connect(function()
        active = not active
        Btn.BackgroundColor3 = active and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(40, 40, 40)
        callback(active)
    end)
end

local function addSlider(name, min, max, default, callback)
    local Frame = Instance.new("Frame", Scroll); Frame.Size = UDim2.new(1, 0, 0, 45); Frame.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel", Frame); Label.Size = UDim2.new(1, 0, 0, 20); Label.Text = name .. ": " .. default; Label.TextColor3 = Color3.fromRGB(255, 200, 0); Label.BackgroundTransparency = 1; Label.TextXAlignment = "Left"
    local Bar = Instance.new("Frame", Frame); Bar.Size = UDim2.new(1, -10, 0, 4); Bar.Position = UDim2.new(0, 0, 0.7, 0); Bar.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local Knob = Instance.new("TextButton", Bar); Knob.Size = UDim2.new(0, 12, 0, 12); Knob.Position = UDim2.new((default-min)/(max-min), -6, 0.5, -6); Knob.Text = ""
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
addToggle("Aimbot Kilit", function(v) _G.Aimbot = v end)
addSlider("Aimbot Menzil", 50, 500, 150, function(v) _G.AimbotFOV = v end)
addToggle("Hız Hilesi", function(v) _G.SpeedBoost = v end)
addSlider("Yürüme Hızı", 16, 200, 60, function(v) _G.SpeedValue = v end)
addToggle("ESP (Oyuncuları Gör)", function(v) _G.ESP = v end)
addToggle("Sınırsız Zıplama", function(v) _G.InfJump = v end)
addSlider("Zıplama Gücü", 0, 250, 50, function(v) _G.JumpPower = v end)

-- Kapat/Aç
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

-- MAIN ENGINE
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.Aimbot
    FOVCircle.Radius = _G.AimbotFOV
    FOVCircle.Position = UIS:GetMouseLocation()

    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        -- ESKİ HIZ SİSTEMİ (Ama sürekli yenileyen bypass ile)
        if _G.SpeedBoost then
            hum.WalkSpeed = char:FindFirstChildOfClass("Tool") and 30 or _G.SpeedValue
        end
        hum.JumpPower = _G.JumpPower
    end

    -- AIMBOT (Sadece Kilitlenme)
    if _G.Aimbot then
        local target = getClosest()
        if target and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            -- Kamerayı doğrudan hedefin merkezine odaklar
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
        end
    end

    -- ESP
    if _G.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and not p.Character:FindFirstChild("LemonHighlight") then
                Instance.new("Highlight", p.Character).Name = "LemonHighlight"
            end
        end
    end
end)

-- Inf Jump
UIS.JumpRequest:Connect(function()
    if _G.InfJump then player.Character.Humanoid:ChangeState(3) end
end)
