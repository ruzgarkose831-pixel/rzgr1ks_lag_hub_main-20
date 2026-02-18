-- Oyun tamamen yüklensin
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- GUI oluştur
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Button = Instance.new("TextButton")

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)

Button.Parent = Frame
Button.Size = UDim2.new(0, 200, 0, 50)
Button.Position = UDim2.new(0.5, -100, 0.5, -25)
Button.Text = "Butona Bas"
Button.BackgroundColor3 = Color3.fromRGB(0,170,0)
Button.TextColor3 = Color3.new(1,1,1)

Button.MouseButton1Click:Connect(function()
    print("Butona basıldı!")
end)
