local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

-- Ana Menü
local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0,350,0,500)
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
Title.Position = UDim2.new(0,0,0,0)
Title.BackgroundTransparency = 1
Title.Text = "rzgr1ks Hub"
Title.TextColor3 = Color3.fromRGB(0,255,170)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold

-- Buton oluşturma fonksiyonu
local function createToggle(name, posY)
	local Btn = Instance.new("TextButton")
	Btn.Parent = Main
	Btn.Size = UDim2.new(0,300,0,40)
	Btn.Position = UDim2.new(0.05,0,posY,0)
	Btn.Text = name.." : OFF"
	Btn.BackgroundColor3 = Color3.fromRGB(60,60,80)
	Btn.TextColor3 = Color3.fromRGB(255,255,255)
	local corner = Instance.new("UICorner", Btn)
	
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
	end)
end

-- Çoklu toggle butonlar
createToggle("Auto Duel", 0.15)
createToggle("Auto Farm", 0.25)
createToggle("ESP", 0.35)
createToggle("Auto Heal", 0.45)
createToggle("Speed Boost", 0.55)
createToggle("Jump Boost", 0.65)

-- Normal butonlar
local function createButton(name, posY)
	local Btn = Instance.new("TextButton")
	Btn.Parent = Main
	Btn.Size = UDim2.new(0,300,0,40)
	Btn.Position = UDim2.new(0.05,0,posY,0)
	Btn.Text = name
	Btn.BackgroundColor3 = Color3.fromRGB(80,60,120)
	Btn.TextColor3 = Color3.fromRGB(255,255,255)
	local corner = Instance.new("UICorner", Btn)
	Btn.MouseButton1Click:Connect(function()
		print(name.." basıldı!")
	end)
end

createButton("Reset Stats", 0.75)
createButton("Teleport Home", 0.85)

-- Kapat butonu
local Close = Instance.new("TextButton")
Close.Parent = Main
Close.Size = UDim2.new(0,30,0,30)
Close.Position = UDim2.new(1,-35,0,5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(200,60,60)

-- Siyah top butonu
local OpenCircle = Instance.new("TextButton")
OpenCircle.Parent = ScreenGui
OpenCircle.Size = UDim2.new(0,60,0,60)
OpenCircle.Position = UDim2.new(0.05,0,0.5,0)
OpenCircle.BackgroundColor3 = Color3.fromRGB(0,0,0)
OpenCircle.Visible = false
OpenCircle.Text = ""

local circleCorner = Instance.new("UICorner", OpenCircle)
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
