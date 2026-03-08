-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

-- Ana Menü
local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0,320,0,420)
Main.Position = UDim2.new(0.35,0,0.25,0)
Main.BackgroundColor3 = Color3.fromRGB(25,25,35)
Main.Active = true
Main.Draggable = true

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0,10)

-- Başlık
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundTransparency = 1
Title.Text = "rzgr1ks Hub"
Title.TextColor3 = Color3.fromRGB(0,255,170)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold

-- Toggle Buton
local Toggle = Instance.new("TextButton")
Toggle.Parent = Main
Toggle.Size = UDim2.new(0,260,0,40)
Toggle.Position = UDim2.new(0.1,0,0.2,0)
Toggle.Text = "Feature 1 : OFF"
Toggle.BackgroundColor3 = Color3.fromRGB(60,60,80)
Toggle.TextColor3 = Color3.fromRGB(255,255,255)

local corner1 = Instance.new("UICorner", Toggle)

local enabled = false
Toggle.MouseButton1Click:Connect(function()
	if enabled == false then
		enabled = true
		Toggle.Text = "Feature 1 : ON"
		Toggle.BackgroundColor3 = Color3.fromRGB(0,170,120)
	else
		enabled = false
		Toggle.Text = "Feature 1 : OFF"
		Toggle.BackgroundColor3 = Color3.fromRGB(60,60,80)
	end
end)

-- İkinci Buton
local Button2 = Instance.new("TextButton")
Button2.Parent = Main
Button2.Size = UDim2.new(0,260,0,40)
Button2.Position = UDim2.new(0.1,0,0.35,0)
Button2.Text = "Feature 2"
Button2.BackgroundColor3 = Color3.fromRGB(80,60,120)
Button2.TextColor3 = Color3.fromRGB(255,255,255)

local corner2 = Instance.new("UICorner", Button2)

-- Menü Kapat Butonu
local Close = Instance.new("TextButton")
Close.Parent = Main
Close.Size = UDim2.new(0,30,0,30)
Close.Position = UDim2.new(1,-35,0,5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(200,60,60)

Close.MouseButton1Click:Connect(function()
	Main.Visible = false
end)
