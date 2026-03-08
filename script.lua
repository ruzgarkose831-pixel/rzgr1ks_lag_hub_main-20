local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Cleanup
local old = player:WaitForChild("PlayerGui"):FindFirstChild("LemonStyleHub")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "LemonStyleHub"
ScreenGui.ResetOnSpawn = false

-- States
_G.Aimbot = false
_G.AimbotFOV = 150
_G.SpeedBoost = false
_G.SpeedValue = 60
_G.JumpPower = 15
_G.InfJump = false
_G.ESP = false

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 460
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 255, 0)

-- [SARI TOP / OPEN BUTTON]
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(0, 10, 0.4, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
OpenBtn.Text = "OPEN"
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

-- [MAIN GUI]
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 400, 0, 450)
Main.Position = UDim2.new(0.5, -200, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -50); Scroll.Position = UDim2.new(0, 10, 0, 45); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
local UIList = Instance.new("UIListLayout", Scroll); UIList.Padding = UDim.new(0, 10)

-- Helper: Add Toggle & Slider
local function addToggle(name, callback)
    local Btn = Instance.new("TextButton", Scroll)
    Btn.Size = UDim2.new(1, 0, 0, 40); Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Btn.Text = name .. " : OFF"; Btn.TextColor3 = Color3.white; Instance.new("UICorner", Btn)
    local active = false
    Btn.Activated:Connect(function()
        active = not active
        Btn.Text = active and (name .. " : ON") or (name .. " : OFF")
        Btn.BackgroundColor3 = active and Color3.fromRGB(255, 180, 0) or Color3.fromRGB(25, 25, 25)
        callback(active)
    end)
end

local function addSlider(name, min, max, default, callback)
    local Frame = Instance.new("Frame", Scroll); Frame.Size = UDim2.new(1, 0, 0, 50); Frame.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel", Frame); Label.Size = UDim2.new(1,0,0,20); Label.Text = name .. ": " .. default; Label.TextColor3 = Color3.new(1,1,0); Label.BackgroundTransparency = 1
    local Btn = Instance.new("TextButton", Frame); Btn.Size = UDim2.new(1, 0, 0, 10); Btn.Position = UDim2.new(0,0,0.6,0); Btn.Text = ""
    Btn.Activated:Connect(function()
        local pos = math.clamp((UIS:GetMouseLocation().X - Btn.AbsolutePosition.X) / Btn.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max-min)*pos); Label.Text = name .. ": " .. val; callback(val)
    end)
end

-- BUTTONS
addToggle("Aimbot (Safe Lock)", function(v) _G.Aimbot = v end)
addSlider("Aimbot FOV", 50, 600, 150, function(v) _G.AimbotFOV = v end)
addToggle("BYPASS SPEED", function(v) _G.SpeedBoost = v end)
addSlider("Speed Value", 16, 250, 60, function(v) _G.SpeedValue = v end)
addToggle("Player ESP", function(v) _G.ESP = v end)
addToggle("Infinite Jump", function(v) _G.InfJump = v end)
addSlider("Jump Power", 0, 100, 15, function(v) _G.JumpPower = v end)

-- [TARGET LOGIC]
local function getClosest()
    local target, dist = nil, _G.AimbotFOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, vis = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if mag < dist then target = p; dist = mag end
            end
        end
    end
    return target
end

-- [MAIN ENGINE - RENDERSTEPPED]
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.Aimbot
    FOVCircle.Radius = _G.AimbotFOV
    FOVCircle.Position = UIS:GetMouseLocation()

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    -- BYPASS SPEED (CFrame Teleport System)
    if _G.SpeedBoost and root and hum and hum.MoveDirection.Magnitude > 0 then
        local currentSpeed = char:FindFirstChildOfClass("Tool") and 30 or _G.SpeedValue
        -- WalkSpeed'i ellemeyip koordinatı iteliyoruz (Anticheat Bypass)
        root.CFrame = root.CFrame + (hum.MoveDirection * (currentSpeed / 50))
    end

    -- AIMBOT (Hard Lock)
    if _G.Aimbot then
        local target = getClosest()
        if target and target.Character:FindFirstChild("HumanoidRootPart") then
            if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UIS:IsKeyDown(Enum.KeyCode.ButtonR2) then
                camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            end
        end
    end

    -- JUMP & ESP
    if hum then hum.JumpPower = _G.JumpPower end
    if _G.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and not p.Character:FindFirstChild("Highlight") then
                local h = Instance.new("Highlight", p.Character)
                h.FillColor = Color3.new(1, 1, 0)
            end
        end
    end
end)

-- INF JUMP
UIS.JumpRequest:Connect(function() if _G.InfJump then player.Character.Humanoid:ChangeState("Jumping") end end)

-- GUI CONTROL
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0,30,0,30); Close.Position = UDim2.new(1,-35,0,5); Close.Text = "X"; Close.BackgroundColor3 = Color3.new(1,0,0)
Close.Activated:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.Activated:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)
