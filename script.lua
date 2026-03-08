local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Cleanup old GUI
local old = player:WaitForChild("PlayerGui"):FindFirstChild("LemonStyleHub")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "LemonStyleHub"
ScreenGui.ResetOnSpawn = false

-- Global States
_G.Aimbot = false
_G.AimbotFOV = 150
_G.SpeedBoost = false
_G.ESP = false
_G.InfJump = false
_G.JumpPower = 50 
_G.SpeedValue = 60

-- FOV Circle Visual
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 460
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 255, 0) -- Yellow

-- [FLOATING BUTTON / YELLOW BALL]
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 220, 0)
OpenBtn.Text = "OPEN"
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 12
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local Stroke = Instance.new("UIStroke", OpenBtn)
Stroke.Thickness = 2
Stroke.Color = Color3.new(1,1,1)

-- [MAIN PANEL]
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 420)
Main.Position = UDim2.new(0.5, -175, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
Main.Active = true
Main.Draggable = true

-- Header
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40); Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = "LEMON HUB - rzgr1ks V17"; Title.TextColor3 = Color3.fromRGB(255, 220, 0); Title.Font = "GothamBold"; Title.TextSize = 16; Title.BackgroundTransparency = 1

-- Scrolling Content
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -55); Scroll.Position = UDim2.new(0, 10, 0, 45); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 1.8, 0); Scroll.ScrollBarThickness = 2
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 10)

-- UI Component Helpers
local function addToggle(name, callback)
    local Frame = Instance.new("Frame", Scroll); Frame.Size = UDim2.new(1, 0, 0, 40); Frame.BackgroundTransparency = 1
    local Btn = Instance.new("TextButton", Frame); Btn.Size = UDim2.new(0, 45, 0, 22); Btn.Position = UDim2.new(1, -50, 0.5, -11); Btn.BackgroundColor3 = Color3.fromRGB(40,40,40); Btn.Text = ""; Instance.new("UICorner", Btn).CornerRadius = UDim.new(1,0)
    local Circle = Instance.new("Frame", Btn); Circle.Size = UDim2.new(0, 18, 0, 18); Circle.Position = UDim2.new(0, 2, 0.5, -9); Circle.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", Circle).CornerRadius = UDim.new(1,0)
    local Lbl = Instance.new("TextLabel", Frame); Lbl.Size = UDim2.new(0.7,0,1,0); Lbl.Text = name; Lbl.TextColor3 = Color3.new(0.9,0.9,0.9); Lbl.Font = "Gotham"; Lbl.TextSize = 14; Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = "Left"
    local active = false
    Btn.Activated:Connect(function()
        active = not active
        Btn.BackgroundColor3 = active and Color3.fromRGB(255, 220, 0) or Color3.fromRGB(40, 40, 40)
        Circle:TweenPosition(active and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9), "Out", "Quad", 0.1, true)
        callback(active)
    end)
end

local function addSlider(name, min, max, default, callback)
    local Frame = Instance.new("Frame", Scroll); Frame.Size = UDim2.new(1, 0, 0, 50); Frame.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel", Frame); Label.Size = UDim2.new(1, 0, 0, 20); Label.Text = name .. ": " .. default; Label.TextColor3 = Color3.fromRGB(255, 220, 0); Label.Font = "Gotham"; Label.TextSize = 12; Label.TextXAlignment = "Left"; Label.BackgroundTransparency = 1
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

-- BUTTONS & SLIDERS
addToggle("Aimbot Lock", function(v) _G.Aimbot = v end)
addSlider("Aimbot FOV", 50, 500, 150, function(v) _G.AimbotFOV = v end)
addToggle("Speed Boost", function(v) _G.SpeedBoost = v end)
addSlider("WalkSpeed", 16, 200, 60, function(v) _G.SpeedValue = v end)
addToggle("Player ESP", function(v) _G.ESP = v end)
addToggle("Infinite Jump", function(v) _G.InfJump = v end)
addSlider("Jump Power", 0, 250, 50, function(v) _G.JumpPower = v end)

-- CLOSE / OPEN SYSTEM
local Close = Instance.new("TextButton", Header)
Close.Size = UDim2.new(0,30,0,30); Close.Position = UDim2.new(1,-35,0,5); Close.Text = "X"; Close.TextColor3 = Color3.new(1,1,1); Close.BackgroundTransparency = 1
Close.Activated:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.Activated:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

-- TARGETING LOGIC
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

-- MAIN ENGINE LOOP
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.Aimbot
    FOVCircle.Radius = _G.AimbotFOV
    FOVCircle.Position = UIS:GetMouseLocation()

    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if _G.SpeedBoost then
            -- Auto-speed adjustment: 30 when holding item, SpeedValue when empty
            hum.WalkSpeed = char:FindFirstChildOfClass("Tool") and 30 or _G.SpeedValue
        end
        hum.JumpPower = _G.JumpPower
        hum.UseJumpPower = true
    end

    -- AIMBOT LOCK (Camera Snap)
    if _G.Aimbot then
        local target = getClosest()
        if target and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
        end
    end

    -- ESP SYSTEM
    if _G.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and not p.Character:FindFirstChild("LemonHighlight") then
                local h = Instance.new("Highlight", p.Character)
                h.Name = "LemonHighlight"
                h.FillColor = Color3.fromRGB(255, 220, 0)
            end
        end
    end
end)

-- JUMP HANDLER
UIS.JumpRequest:Connect(function()
    if _G.InfJump and player.Character then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
