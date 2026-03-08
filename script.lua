local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Cleanup
local old = player:WaitForChild("PlayerGui"):FindFirstChild("LemonStyleHub")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "LemonStyleHub"
ScreenGui.ResetOnSpawn = false

-- States
_G.SpeedBoost = false
_G.ESP = false
_G.InfJump = false
_G.JumpPower = 15
_G.SpeedValue = 60

-- Main Frame
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 400, 0, 450)
Main.Position = UDim2.new(0.5, -200, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Header
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "LEMON HUB DUELS PREMIUM - rzgr1ks Edit"
Title.TextColor3 = Color3.fromRGB(255, 150, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1

-- Scrolling Content
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 1.5, 0)
Scroll.ScrollBarThickness = 2
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 150, 0)

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 10)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- Helper: Create Toggle
local function addToggle(name, callback)
    local Frame = Instance.new("Frame", Scroll)
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0, 45, 0, 22)
    Btn.Position = UDim2.new(1, -50, 0.5, -11)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Text = ""
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame", Btn)
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = UDim2.new(0, 2, 0.5, -9)
    Circle.BackgroundColor3 = Color3.white
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

    local active = false
    Btn.Activated:Connect(function()
        active = not active
        Btn.BackgroundColor3 = active and Color3.fromRGB(255, 100, 0) or Color3.fromRGB(40, 40, 40)
        Circle:TweenPosition(active and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9), "Out", "Quad", 0.1, true)
        callback(active)
    end)
end

-- Helper: Create Slider
local function addSlider(name, min, max, default, callback)
    local Frame = Instance.new("Frame", Scroll)
    Frame.Size = UDim2.new(1, 0, 0, 50)
    Frame.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Text = name .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(255, 150, 0)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Bar = Instance.new("Frame", Frame)
    Bar.Size = UDim2.new(1, -10, 0, 4)
    Bar.Position = UDim2.new(0, 0, 0.7, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 150, 0)

    local Knob = Instance.new("TextButton", Bar)
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.Position = UDim2.new((default-min)/(max-min), -6, 0.5, -6)
    Knob.Text = ""
    Knob.BackgroundColor3 = Color3.white
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update()
        local input = UIS:GetMouseLocation()
        local pos = math.clamp((input.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        Knob.Position = UDim2.new(pos, -6, 0.5, -6)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (max-min)*pos)
        Label.Text = name .. ": " .. val
        callback(val)
    end

    Knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update() end end)
end

-- BUTTONS (English like Lemon Hub)
addToggle("Speed Boost", function(v) _G.SpeedBoost = v end)
addSlider("Boost Speed", 16, 200, 60, function(v) _G.SpeedValue = v end)
addToggle("Player ESP", function(v) _G.ESP = v end)
addToggle("Infinite Jump", function(v) _G.InfJump = v end)
addSlider("Jump Height", 0, 200, 15, function(v) _G.JumpPower = v end)
addToggle("Anti Ragdoll", function(v) end)
addToggle("Auto Attack", function(v) end)

-- Main Engine
task.spawn(function()
    while task.wait(0.1) do
        local char = player.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            hum.UseJumpPower = true
            if _G.SpeedBoost then
                local hasTool = char:FindFirstChildOfClass("Tool")
                hum.WalkSpeed = hasTool and 30 or _G.SpeedValue
                hum.JumpPower = _G.JumpPower
            end
        end
        if _G.ESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local h = p.Character:FindFirstChild("LemonHighlight") or Instance.new("Highlight", p.Character)
                    h.Name = "LemonHighlight"
                    h.FillColor = Color3.fromRGB(255, 150, 0)
                end
            end
        end
    end
end)

-- Inf Jump Logic
UIS.JumpRequest:Connect(function()
    if _G.InfJump then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Minimize Button
local Close = Instance.new("TextButton", Header)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 2)
Close.Text = "X"
Close.TextColor3 = Color3.white
Close.BackgroundTransparency = 1
Close.Activated:Connect(function() ScreenGui:Destroy() end)
