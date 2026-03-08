local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Ana Menü
local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0,350,0,520)
Main.Position = UDim2.new(0.35,0,0.2,0)
Main.BackgroundColor3 = Color3.fromRGB(25,25,35)
Main.Active = true
Main.Draggable = true

local UICorner = Instance.new("UICorner",Main)
UICorner.CornerRadius = UDim.new(0,15)

-- Başlık
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundTransparency = 1
Title.Text = "rzgr1ks Hub"
Title.TextColor3 = Color3.fromRGB(0,255,170)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold

-- Toggle oluşturucu
local function createToggle(name,posY,callback)

	local Btn = Instance.new("TextButton")
	Btn.Parent = Main
	Btn.Size = UDim2.new(0,300,0,40)
	Btn.Position = UDim2.new(0.05,0,posY,0)
	Btn.Text = name.." : OFF"
	Btn.BackgroundColor3 = Color3.fromRGB(60,60,80)
	Btn.TextColor3 = Color3.fromRGB(255,255,255)

	local corner = Instance.new("UICorner",Btn)

	local enabled = false

	Btn.MouseButton1Click:Connect(function()

		enabled = not enabled

		if enabled then
			Btn.Text = name.." : ON"
			Btn.BackgroundColor3 = Color3.fromRGB(0,170,120)
		else
			Btn.Text = name.." : OFF"
			Btn.BackgroundColor3 = Color3.fromRGB(60,60,80)
		end

		if callback then
			callback(enabled)
		end

	end)

end

-- Togglelar
createToggle("Speed Mode",0.15,function(enabled)

	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		if enabled then
			humanoid.WalkSpeed = 50
			humanoid.JumpPower = 45
		else
			humanoid.WalkSpeed = 30
			humanoid.JumpPower = 50
		end
	end

end)

createToggle("Jump Boost",0.25)

createToggle("Extra Mode",0.35)

-- Slider frame
local SliderFrame = Instance.new("Frame")
SliderFrame.Parent = Main
SliderFrame.Size = UDim2.new(0,300,0,40)
SliderFrame.Position = UDim2.new(0.05,0,0.50,0)
SliderFrame.BackgroundColor3 = Color3.fromRGB(60,60,80)

local sliderCorner = Instance.new("UICorner",SliderFrame)

local SliderBar = Instance.new("Frame")
SliderBar.Parent = SliderFrame
SliderBar.Size = UDim2.new(1,0,0,6)
SliderBar.Position = UDim2.new(0,0,0.5,-3)
SliderBar.BackgroundColor3 = Color3.fromRGB(120,120,150)

local SliderKnob = Instance.new("Frame")
SliderKnob.Parent = SliderFrame
SliderKnob.Size = UDim2.new(0,20,0,20)
SliderKnob.Position = UDim2.new(0,0,0.5,-10)
SliderKnob.BackgroundColor3 = Color3.fromRGB(0,255,170)

local knobCorner = Instance.new("UICorner",SliderKnob)
knobCorner.CornerRadius = UDim.new(1,0)

local ValueLabel = Instance.new("TextLabel")
ValueLabel.Parent = SliderFrame
ValueLabel.Size = UDim2.new(1,0,0,20)
ValueLabel.Position = UDim2.new(0,0,-0.6,0)
ValueLabel.BackgroundTransparency = 1
ValueLabel.Text = "JumpPower: 50"
ValueLabel.TextColor3 = Color3.fromRGB(255,255,255)
ValueLabel.TextScaled = true

local dragging = false

SliderKnob.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
	end

end)

UIS.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end

end)

UIS.InputChanged:Connect(function(input)

	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

		local mouseX = UIS:GetMouseLocation().X
		local frameX = SliderFrame.AbsolutePosition.X
		local frameSize = SliderFrame.AbsoluteSize.X

		local pos = math.clamp((mouseX-frameX)/frameSize,0,1)

		SliderKnob.Position = UDim2.new(pos,-10,0.5,-10)

		local value = math.floor(30 + (70*pos))

		ValueLabel.Text = "JumpPower: "..value

		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.JumpPower = value
		end

	end

end)

-- Menü kapat
local Close = Instance.new("TextButton")
Close.Parent = Main
Close.Size = UDim2.new(0,30,0,30)
Close.Position = UDim2.new(1,-35,0,5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(200,60,60)

-- Siyah açma butonu
local OpenCircle = Instance.new("TextButton")
OpenCircle.Parent = ScreenGui
OpenCircle.Size = UDim2.new(0,60,0,60)
OpenCircle.Position = UDim2.new(0.05,0,0.5,0)
OpenCircle.BackgroundColor3 = Color3.fromRGB(0,0,0)
OpenCircle.Visible = false
OpenCircle.Text = ""

local circleCorner = Instance.new("UICorner",OpenCircle)
circleCorner.CornerRadius = UDim.new(1,0)

OpenCircle.Active = true
OpenCircle.Draggable = true

Close.MouseButton1Click:Connect(function()

	Main.Visible = false
	OpenCircle.Visible = true

end)

OpenCircle.MouseButton1Click:Connect(function()

	Main.Visible = true
	OpenCircle.Visible = false

end)
