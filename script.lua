local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Ana GUI Ayarları
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "rzgr1ks_Hub_V2"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false 

-- Ana Menü Çerçevesi
local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0,350,0,520)
Main.Position = UDim2.new(0.35,0,0.2,0)
Main.BackgroundColor3 = Color3.fromRGB(25,25,35)
Main.Active = true
Main.Draggable = true 

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0,15)

-- Başlık
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundTransparency = 1
Title.Text = "rzgr1ks Hub PRO"
Title.TextColor3 = Color3.fromRGB(0,255,170)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold

-- Durum Değişkenleri
_G.ESPEnabled = false

-- Yardımcı Fonksiyon: Humanoid Getir
local function getHumanoid()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.UseJumpPower = true end
	return hum
end

-- ESP Uygulama Fonksiyonu
local function applyESP(targetChar)
	if _G.ESPEnabled and targetChar then
		local highlight = targetChar:FindFirstChild("ESPHighlight")
		if not highlight then
			highlight = Instance.new("Highlight")
			highlight.Name = "ESPHighlight"
			highlight.Parent = targetChar
			highlight.FillColor = Color3.fromRGB(255, 0, 50)
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.FillTransparency = 0.5
		end
	end
end

-- Toggle Oluşturucu
local function createToggle(name, posY, callback)
	local Btn = Instance.new("TextButton")
	Btn.Parent = Main
	Btn.Size = UDim2.new(0,300,0,40)
	Btn.Position = UDim2.new(0.05, 0, posY, 0)
	Btn.Text = name.." : OFF"
	Btn.BackgroundColor3 = Color3.fromRGB(60,60,80)
	Btn.TextColor3 = Color3.fromRGB(255,255,255)
	Btn.Font = Enum.Font.SourceSansBold
	Instance.new("UICorner", Btn)

	local enabled = false
	Btn.MouseButton1Click:Connect(function()
		enabled = not enabled
		Btn.Text = enabled and (name.." : ON") or (name.." : OFF")
		Btn.BackgroundColor3 = enabled and Color3.fromRGB(0,170,120) or Color3.fromRGB(60,60,80)
		if callback then callback(enabled) end
	end)
end

-- --- ÖZELLİKLER ---

-- 1. Speed Mode
createToggle("Speed Mode", 0.15, function(enabled)
	local hum = getHumanoid()
	if hum then hum.WalkSpeed = enabled and 60 or 16 end
end)

-- 2. Jump Boost
createToggle("Jump Boost", 0.25, function(enabled)
	local hum = getHumanoid()
	if hum then hum.JumpPower = enabled and 120 or 50 end
end)

-- 3. Player ESP
createToggle("Player ESP", 0.35, function(enabled)
	_G.ESPEnabled = enabled
	if not enabled then
		for _, p in pairs(Players:GetPlayers()) do
			if p.Character and p.Character:FindFirstChild("ESPHighlight") then
				p.Character.ESPHighlight:Destroy()
			end
		end
	else
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player and p.Character then applyESP(p.Character) end
		end
	end
end)

-- Slider (Dinamik JumpPower)
local SliderFrame = Instance.new("Frame", Main)
SliderFrame.Size = UDim2.new(0,300,0,40)
SliderFrame.Position = UDim2.new(0.05,0,0.50,0)
SliderFrame.BackgroundColor3 = Color3.fromRGB(60,60,80)
Instance.new("UICorner", SliderFrame)

local SliderBar = Instance.new("Frame", SliderFrame)
SliderBar.Size = UDim2.new(0.9,0,0,6)
SliderBar.Position = UDim2.new(0.05,0,0.5,-3)
SliderBar.BackgroundColor3 = Color3.fromRGB(100,100,130)

local SliderKnob = Instance.new("Frame", SliderBar)
SliderKnob.Size = UDim2.new(0,20,0,20)
SliderKnob.Position = UDim2.new(0,0,0.5,-10)
SliderKnob.BackgroundColor3 = Color3.fromRGB(0,255,170)
Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1,0)

local ValueLabel = Instance.new("TextLabel", SliderFrame)
ValueLabel.Size = UDim2.new(1,0,0,20)
ValueLabel.Position = UDim2.new(0,0,-0.6,0)
ValueLabel.BackgroundTransparency = 1
ValueLabel.Text = "Custom Jump: 50"
ValueLabel.TextColor3 = Color3.fromRGB(255,255,255)
ValueLabel.Font = Enum.Font.SourceSans

local dragging = false
SliderKnob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
		SliderKnob.Position = UDim2.new(pos, -10, 0.5, -10)
		local val = math.floor(50 + (200 * pos))
		ValueLabel.Text = "Custom Jump: "..val
		local hum = getHumanoid()
		if hum then hum.JumpPower = val end
	end
end)

-- Kapatma / Açma Sistemi
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0,30,0,30)
Close.Position = UDim2.new(1,-35,0,5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(200,60,60)
Close.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", Close)

local OpenCircle = Instance.new("TextButton", ScreenGui)
OpenCircle.Size = UDim2.new(0,60,0,60)
OpenCircle.Position = UDim2.new(0.02,0,0.8,0)
OpenCircle.BackgroundColor3 = Color3.fromRGB(0,255,170)
OpenCircle.Text = "OPEN"
OpenCircle.Visible = false
Instance.new("UICorner", OpenCircle).CornerRadius = UDim.new(1,0)

Close.MouseButton1Click:Connect(function() Main.Visible = false OpenCircle.Visible = true end)
OpenCircle.MouseButton1Click:Connect(function() Main.Visible = true OpenCircle.Visible = false end)

-- Arka Plan Döngüsü (Yeni oyuncular için ESP)
task.spawn(function()
	while task.wait(3) do
		if _G.ESPEnabled then
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= player and p.Character then applyESP(p.Character) end
			end
		end
	end
end)
