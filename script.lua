-- RZGR1KS DUEL GUI (ALL FEATURES - VISUAL ONLY)

local UIS = game:GetService("UserInputService")

local Screen = Instance.new("ScreenGui")
Screen.Parent = (gethui and gethui()) or game.CoreGui
Screen.ResetOnSpawn = false
Screen.Name = "RZGR1KS_DUEL"

local Main = Instance.new("Frame")
Main.Parent = Screen
Main.Size = UDim2.new(0,320,0,45)
Main.Position = UDim2.new(0.5,-160,0.2,0)
Main.BackgroundColor3 = Color3.fromRGB(12,12,12)
Main.Active = true
Main.Draggable = true
Main.BorderSizePixel = 0

Instance.new("UICorner",Main).CornerRadius = UDim.new(0,6)

local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.Size = UDim2.new(1,-50,0,45)
Title.Position = UDim2.new(0,15,0,0)
Title.BackgroundTransparency = 1
Title.Text = "RZGR1KS DUEL"
Title.TextColor3 = Color3.fromRGB(255,40,40)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = Main
ToggleBtn.Size = UDim2.new(0,45,0,45)
ToggleBtn.Position = UDim2.new(1,-45,0,0)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Text = "-"
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.TextSize = 24

local Scroll = Instance.new("ScrollingFrame")
Scroll.Parent = Main
Scroll.Size = UDim2.new(1,-10,0,380)
Scroll.Position = UDim2.new(0,5,0,50)
Scroll.Visible = false
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.BorderSizePixel = 0

local Layout = Instance.new("UIListLayout")
Layout.Parent = Scroll
Layout.Padding = UDim.new(0,8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- TOGGLE OLUŞTURUCU
local function AddToggle(text)

    local Button = Instance.new("TextButton")
    Button.Parent = Scroll
    Button.Size = UDim2.new(1,-10,0,38)
    Button.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Button.Text = text.." : OFF"
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12

    Instance.new("UICorner",Button)

    local state = false

    Button.MouseButton1Click:Connect(function()

        state = not state

        if state then
            Button.Text = text.." : ON"
            Button.BackgroundColor3 = Color3.fromRGB(180,0,0)
        else
            Button.Text = text.." : OFF"
            Button.BackgroundColor3 = Color3.fromRGB(25,25,25)
        end

    end)

end

-- SLIDER OLUŞTURUCU
local function AddSlider(text,min,max,start)

    local Frame = Instance.new("Frame")
    Frame.Parent = Scroll
    Frame.Size = UDim2.new(1,-10,0,50)
    Frame.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Size = UDim2.new(1,0,0,18)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(200,200,200)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.Text = text..": "..start

    local Bar = Instance.new("Frame")
    Bar.Parent = Frame
    Bar.Size = UDim2.new(1,0,0,6)
    Bar.Position = UDim2.new(0,0,0,28)
    Bar.BackgroundColor3 = Color3.fromRGB(45,45,45)

    local Fill = Instance.new("Frame")
    Fill.Parent = Bar
    Fill.BorderSizePixel = 0
    Fill.BackgroundColor3 = Color3.fromRGB(255,40,40)
    Fill.Size = UDim2.new((start-min)/(max-min),0,1,0)

    local dragging = false
    local value = start

    local function Update(x)

        local percent = math.clamp((x - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,0,1)
        Fill.Size = UDim2.new(percent,0,1,0)

        value = math.floor(min + percent*(max-min))
        Label.Text = text..": "..value

    end

    Bar.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Update(input.Position.X)
        end

    end)

    UIS.InputChanged:Connect(function(input)

        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(input.Position.X)
        end

    end)

    UIS.InputEnded:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end

    end)

end

-- COMBAT
AddToggle("Silent Aim")
AddToggle("Hitbox Expander")
AddSlider("Hitbox Radius",2,150,25)
AddToggle("Spinbot")
AddSlider("Spin Speed",0,300,100)

-- MOVEMENT
AddToggle("Speed Bypass")
AddSlider("Walk Speed",16,500,100)
AddSlider("Jump Power",50,500,50)
AddSlider("Gravity Control",0,196,196)

-- VISUAL
AddToggle("Material X-Ray")

-- MISC
AddToggle("Anti Ragdoll")

-- YT BUTONU
local yt = Instance.new("TextButton")
yt.Parent = Scroll
yt.Size = UDim2.new(1,-10,0,35)
yt.BackgroundColor3 = Color3.fromRGB(200,0,0)
yt.Text = "YT: @rzgr1ks"
yt.TextColor3 = Color3.new(1,1,1)
yt.Font = Enum.Font.GothamBold
yt.TextSize = 12
Instance.new("UICorner",yt)

-- MENU AÇ KAPA
local Expanded = false

ToggleBtn.MouseButton1Click:Connect(function()

    Expanded = not Expanded
    Scroll.Visible = Expanded

    if Expanded then
        ToggleBtn.Text = "X"
        Main:TweenSize(UDim2.new(0,320,0,450),"Out","Quart",0.25,true)
    else
        ToggleBtn.Text = "-"
        Main:TweenSize(UDim2.new(0,320,0,45),"Out","Quart",0.25,true)
    end

end)
