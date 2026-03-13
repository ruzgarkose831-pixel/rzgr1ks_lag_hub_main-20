-- GUI CREATE
local gui = Instance.new("ScreenGui")
gui.Name = "RZGR_HUB"
gui.ResetOnSpawn = false
gui.Parent = par

local main = Instance.new("Frame")
main.Size = UDim2.new(0,420,0,320)
main.Position = UDim2.new(0.5,-210,0.5,-160)
main.BackgroundColor3 = pm
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner",main)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "RZGR HUB"
title.TextColor3 = wh
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = main

-- BUTTON FUNCTION
local function makeBtn(text,x,y,callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0,180,0,40)
	b.Position = UDim2.new(0,x,0,y)
	b.BackgroundColor3 = pl
	b.TextColor3 = wh
	b.Text = text.." : OFF"
	b.Font = Enum.Font.Gotham
	b.TextScaled = true
	b.Parent = main
	
	Instance.new("UICorner",b)
	
	local state = false
	
	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = text.." : "..(state and "ON" or "OFF")
		callback(state)
	end)
end

-- BUTTONS

makeBtn("Speed55",20,60,function(v)
	speed55 = v
end)

makeBtn("Spinbot",220,60,function(v)
	toggleSpin(v)
end)

makeBtn("Auto Grab",20,120,function(v)
	autograb = v
end)

makeBtn("Xray",220,120,function(v)
	xrayon = v
end)

makeBtn("Anti Ragdoll",20,180,function(v)
	antirag = v
	if v then
		anti.Enable("v1")
	else
		anti.Disable()
	end
end)

makeBtn("Float",220,180,function(v)
	floaton = v
end)

makeBtn("Infinite Jump",120,240,function(v)
	infjump = v
end)

-- DRAG SYSTEM
local dragging
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

uis.InputChanged:Connect(function(input)
	if dragging then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)
