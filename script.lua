local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- GUI Ayarları
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "rzgr1ks_Mobile_Hub"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false 

-- Ana Menü
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 400)
Main.Position = UDim2.new(0.5, -150, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Main.Active = true
Main.Draggable = true -- Mobilde parmağınla taşıyabilirsin
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "rzgr1ks Mobile Hub"
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.BackgroundTransparency = 1
Title.TextScaled = true

-- Değişkenler
_G.SpeedEnabled = false
_G.JumpPowerValue = 50
_G.ESPEnabled = false

-- Karakter Ayarlayıcı (Sürekli Kontrol)
task.spawn(function()
    while true do
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true -- Zıplama gücünü aktif et (Mobilde şart)
                if _G.SpeedEnabled then
                    hum.WalkSpeed = 60
                end
                hum.JumpPower = _G.JumpPowerValue
            end
        end
        task.wait(0.5)
    end
end)

-- Toggle Fonksiyonu
local function createToggle(name, posY, callback)
    local Btn = Instance.new("TextButton", Main)
    Btn.Size = UDim2.new(0, 260, 0, 40)
    Btn.Position = UDim2.new(0.5, -130, 0, posY)
    Btn.Text = name .. " : OFF"
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    Btn.TextColor3 = Color3.white
    Instance.new("UICorner", Btn)

    local enabled = false
    Btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        Btn.Text = enabled and (name .. " : ON") or (name .. " : OFF")
        Btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 120) or Color3.fromRGB(60, 60, 80)
        callback(enabled)
    end)
end

-- Özellikler
createToggle("Speed Boost", 60, function(val) _G.SpeedEnabled = val end)
createToggle("Player ESP", 110, function(val) _G.ESPEnabled = val end)

-- Mobil Uyumlu Slider (Jump Power)
local SliderFrame = Instance.new("Frame", Main)
SliderFrame.Size = UDim2.new(0, 260, 0, 40)
SliderFrame.Position = UDim2.new(0.5, -130, 0, 170)
SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
Instance.new("UICorner", SliderFrame)

local SliderBar = Instance.new("Frame", SliderFrame)
SliderBar.Size = UDim2.new(0.8, 0, 0, 5)
SliderBar.Position = UDim2.new(0.1, 0, 0.7, 0)
SliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 120)

local Knob = Instance.new("TextButton", SliderBar)
Knob.Size = UDim2.new(0, 20, 0, 20)
Knob.Position = UDim2.new(0, 0, 0.5, -10)
Knob.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
Knob.Text = ""
Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

local ValLabel = Instance.new("TextLabel", SliderFrame)
ValLabel.Size = UDim2.new(1, 0, 0, 20)
ValLabel.Position = UDim2.new(0, 0, 0.1, 0)
ValLabel.Text = "Jump Power: 50"
ValLabel.TextColor3 = Color3.white
ValLabel.BackgroundTransparency = 1

-- Slider Kaydırma Mantığı (Mobil + PC)
local function updateSlider(input)
    local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
    Knob.Position = UDim2.new(pos, -10, 0.5, -10)
    local value = math.floor(50 + (250 * pos))
    ValLabel.Text = "Jump Power: " .. value
    _G.JumpPowerValue = value
end

local dragging = false
Knob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

-- Kapat / Aç Butonları
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Instance.new("UICorner", Close)

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.Text = "MENU"
OpenBtn.Visible = false
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

Close.MouseButton1Click:Connect(function() Main.Visible = false OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true OpenBtn.Visible = false end)
