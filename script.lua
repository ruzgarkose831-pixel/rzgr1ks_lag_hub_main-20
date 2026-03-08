-- GUI oluşturma
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui

-- Ana pencere
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Position = UDim2.new(0.4,0,0.3,0)
Frame.Size = UDim2.new(0,250,0,150)
Frame.Active = true
Frame.Draggable = true

-- Buton
TextButton.Parent = Frame
TextButton.Size = UDim2.new(0,200,0,50)
TextButton.Position = UDim2.new(0.1,0,0.3,0)
TextButton.Text = "Test Button"
TextButton.BackgroundColor3 = Color3.fromRGB(0,170,255)

-- Buton çalışınca
TextButton.MouseButton1Click:Connect(function()
    print("Butona basıldı!")
end)
