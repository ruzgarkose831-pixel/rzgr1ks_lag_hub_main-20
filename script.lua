local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local Toggles = {Speed = false, Jump = false, Grav = false, ESP = false, HB = false}
local Vars = {SpeedVal = 40, HBSize = 12}

-- GUI
local guiName = "rzgr1ks_V10_Force"
local guiParent = LP:WaitForChild("PlayerGui")

if guiParent:FindFirstChild(guiName) then
	guiParent[guiName]:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name = guiName
sg.ResetOnSpawn = false
sg.Parent = guiParent

local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.new(0,260,0,400)
main.Position = UDim2.new(0.5,-130,0.5,-200)
main.BackgroundColor3 = Color3.fromRGB(20,20,25)
main.BorderSizePixel = 0
main.Active = true
main.Parent = sg

Instance.new("UICorner",main).CornerRadius = UDim.new(0,10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0,150,255)
stroke.Thickness = 2
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,45)
title.Text = "rzgr1ks duels V10"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(30,30,40)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = main

-- Drag System (yeni Roblox uyumlu)
local dragging = false
local dragInput
local dragStart
local startPos

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

title.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- Buton oluşturucu
local function CreateBtn(name,var,yPos)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,230,0,40)
	btn.Position = UDim2.new(0,15,0,yPos)
	btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
	btn.Text = name
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 16
	btn.Parent = main
	
	Instance.new("UICorner",btn)

	btn.MouseButton1Click:Connect(function()
		Toggles[var] = not Toggles[var]
		btn.BackgroundColor3 = Toggles[var] and Color3.fromRGB(0,150,255) or Color3.fromRGB(40,40,50)
	end)
end

CreateBtn("👁️ ESP (Parıltı)","ESP",60)
CreateBtn("🎯 Adamlar İçin HB Expander","HB",110)
CreateBtn("⚡ Speed Hack","Speed",160)
CreateBtn("⬆️ Jump Power","Jump",210)
CreateBtn("🌌 Gravity Mode","Grav",260)

local inp = Instance.new("TextBox")
inp.Size = UDim2.new(0,230,0,35)
inp.Position = UDim2.new(0,15,0,310)
inp.BackgroundColor3 = Color3.fromRGB(30,30,35)
inp.PlaceholderText = "Hız Değeri (40)"
inp.TextColor3 = Color3.new(1,1,1)
inp.Parent = main

inp.FocusLost:Connect(function()
	Vars.SpeedVal = tonumber(inp.Text) or 40
end)
