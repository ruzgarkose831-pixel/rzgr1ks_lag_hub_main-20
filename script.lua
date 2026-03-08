-- GUI oluşturma
local ScreenGui = Instance.new("ScreenGui")
local OpenButton = Instance.new("TextButton")
local Frame = Instance.new("Frame")
local CloseButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui

-- Açma butonu
OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0,150,0,40)
OpenButton.Position = UDim2.new(0.02,0,0.4,0)
OpenButton.Text = "rzgr1ks's duel script"
OpenButton.BackgroundColor3 = Color3.fromRGB(0,170,255)

-- Menü frame (başta kapalı)
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0,100,0,100)
Frame.Position = UDim2.new(0.45,0,0.4,0)
Frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
Frame.Visible = false
Frame.Active = true
Frame.Draggable = true
Frame.ClipsDescendants = true

-- Frame'i daire yapma
Frame.BackgroundTransparency = 0
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(0.5,0.5)
Frame.AutomaticSize = Enum.AutomaticSize.None
Frame.Rotation = 0
Frame.Name = "MenuCircle"
Frame.Size = UDim2.new(0,100,0,100)
Frame.Position = UDim2.new(0.5,0,0.5,0)
Frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
Frame.BorderSizePixel = 0

-- UICorner ile top (daire) yap
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.5,0) -- %50 radius = circle
UICorner.Parent = Frame

-- Kapat butonu
CloseButton.Parent = Frame
CloseButton.Size = UDim2.new(0,50,0,30)
CloseButton.Position = UDim2.new(0.25,0,0.35,0)
CloseButton.Text = "X"
CloseButton.BackgroundColor3 = Color3.fromRGB(255,0,0)

-- Açma ve kapama fonksiyonları
OpenButton.MouseButton1Click:Connect(function()
    Frame.Visible = true
end)

CloseButton.MouseButton1Click:Connect(function()
    Frame.Visible = false
end)
