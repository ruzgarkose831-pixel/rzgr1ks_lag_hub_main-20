local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- SETTINGS
_G.Settings = {
    PlayerHB = false,
    PlayerHBSize = 25,

    BatHitbox = true,
    BatSize = 45,

    PlayerESP = false,
    ESPDistance = 500,

    UnderArms = false,
    HiddenHead = false,

    Speed = true,
    SpeedVal = 75,

    JumpPower = 80,

    Spin = false,
    SpinSpeed = 200,

    AutoAttack = false,

    Aimbot = false,
    TargetLock = false,

    BoxESP = false,
    NameESP = false,
    Tracers = false,

    SmartHitbox = false,

    FOV = 150,
    FOVVisible = true
}

-- CLEAN GUI
if PlayerGui:FindFirstChild("LemonHubPremiumGui") then
    PlayerGui.LemonHubPremiumGui:Destroy()
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "LemonHubPremiumGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = PlayerGui

-- MAIN PANEL
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,320,0,450)
main.Position = UDim2.new(0.5,-160,0.5,-225)
main.BackgroundColor3 = Color3.fromRGB(10,10,10)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2

RunService.RenderStepped:Connect(function()
    stroke.Color = Color3.fromHSV(tick()%5/5,1,1)
end)

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.Text = "  LEMON HUB PREMIUM"
title.TextColor3 = Color3.fromRGB(255,170,0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

-- MINIMIZE
local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0,30,0,30)
minBtn.Position = UDim2.new(1,-40,0,5)
minBtn.Text = "_"
minBtn.BackgroundTransparency = 1
minBtn.TextColor3 = Color3.new(1,1,1)

local sideIcon = Instance.new("TextButton", gui)
sideIcon.Size = UDim2.new(0,60,0,60)
sideIcon.Position = UDim2.new(0.9,0,0.5,0)
sideIcon.Text = "🍋"
sideIcon.TextSize = 30
sideIcon.Visible = false
sideIcon.BackgroundColor3 = Color3.fromRGB(20,20,20)
Instance.new("UICorner", sideIcon)

minBtn.MouseButton1Click:Connect(function()
    main.Visible=false
    sideIcon.Visible=true
end)

sideIcon.MouseButton1Click:Connect(function()
    main.Visible=true
    sideIcon.Visible=false
end)

-- SCROLL
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1,-10,1,-50)
scroll.Position = UDim2.new(0,5,0,45)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.CanvasSize = UDim2.new(0,0,0,1100)

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- TOGGLE
local function AddToggle(text,key)

    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-10,0,35)
    btn.BackgroundColor3 = Color3.fromRGB(25,25,25)
    btn.Text = " "..text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left

    Instance.new("UICorner", btn)

    local status = Instance.new("Frame", btn)
    status.Size = UDim2.new(0,10,0,10)
    status.Position = UDim2.new(1,-25,0.5,-5)
    Instance.new("UICorner", status)

    btn.MouseButton1Click:Connect(function()
        _G.Settings[key] = not _G.Settings[key]
    end)

    RunService.RenderStepped:Connect(function()
        status.BackgroundColor3 =
            _G.Settings[key] and Color3.new(0,1,0) or Color3.new(1,0,0)
    end)

end

-- SLIDER
local function AddSlider(text,min,max,key)

    local frame = Instance.new("Frame",scroll)
    frame.Size = UDim2.new(1,-10,0,50)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel",frame)
    label.Size = UDim2.new(1,0,0,20)
    label.BackgroundTransparency = 1
    label.Text = text..": ".._G.Settings[key]
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left

    local bar = Instance.new("TextButton",frame)
    bar.Size = UDim2.new(1,0,0,15)
    bar.Position = UDim2.new(0,0,1,-20)
    bar.BackgroundColor3 = Color3.fromRGB(40,40,40)
    bar.Text=""

    Instance.new("UICorner",bar)

    local fill = Instance.new("Frame",bar)
    fill.Size = UDim2.new((_G.Settings[key]-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(255,145,0)
    Instance.new("UICorner",fill)

    bar.MouseButton1Down:Connect(function()

        local move
        move = UIS.InputChanged:Connect(function(input)

            if input.UserInputType==Enum.UserInputType.MouseMovement
            or input.UserInputType==Enum.UserInputType.Touch then

                local p = math.clamp(
                    (input.Position.X-bar.AbsolutePosition.X)
                    /bar.AbsoluteSize.X,
                    0,1
                )

                _G.Settings[key]=math.floor(min+(max-min)*p)

                label.Text = text..": ".._G.Settings[key]

                fill.Size = UDim2.new(p,0,1,0)

            end

        end)

        UIS.InputEnded:Connect(function(input)

            if input.UserInputType==Enum.UserInputType.MouseButton1
            or input.UserInputType==Enum.UserInputType.Touch then
                if move then
                    move:Disconnect()
                end
            end

        end)

    end)

end

-- MENU
AddToggle("BAT HITBOX","BatHitbox")
AddSlider("BAT SIZE",5,500,"BatSize")

AddToggle("PLAYER HITBOX","PlayerHB")
AddSlider("HITBOX SIZE",2,120,"PlayerHBSize")

AddToggle("BOX ESP","BoxESP")
AddToggle("NAME ESP","NameESP")

AddToggle("AIMBOT","Aimbot")
AddToggle("TARGET LOCK","TargetLock")

AddToggle("TRACERS","Tracers")
AddToggle("SMART HITBOX","SmartHitbox")

AddToggle("SPEED","Speed")
AddSlider("SPEED POWER",16,500,"SpeedVal")

AddToggle("SPIN BOT","Spin")
AddToggle("AUTO ATTACK","AutoAttack")

-- FOV CIRCLE
local circle = Drawing.new("Circle")
circle.Thickness = 2
circle.NumSides = 60
circle.Filled = false
circle.Color = Color3.fromRGB(255,170,0)

-- MAIN LOOP
RunService.RenderStepped:Connect(function()

    local char = Player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if hum and root then

        if _G.Settings.Speed then
            hum.WalkSpeed = _G.Settings.SpeedVal
        end

        if _G.Settings.Spin then
            root.CFrame =
                root.CFrame *
                CFrame.Angles(0,math.rad(_G.Settings.SpinSpeed/10),0)
        end

        if _G.Settings.AutoAttack then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
        end

    end

    circle.Radius = _G.Settings.FOV
    circle.Visible = _G.Settings.FOVVisible

    local mouse = UIS:GetMouseLocation()
    circle.Position = mouse

    local closest
    local dist = _G.Settings.FOV

    for _,v in pairs(Players:GetPlayers()) do

        if v~=Player
        and v.Character
        and v.Character:FindFirstChild("Head") then

            local head=v.Character.Head

            local pos,onscreen =
                Camera:WorldToViewportPoint(head.Position)

            if onscreen then

                local mag =
                    (Vector2.new(pos.X,pos.Y)-mouse).Magnitude

                if mag<dist then
                    dist=mag
                    closest=head
                end

                if _G.Settings.BoxESP then

                    if not v.Character:FindFirstChild("BoxESP") then

                        local box=Instance.new("BoxHandleAdornment")
                        box.Name="BoxESP"
                        box.Adornee=v.Character.HumanoidRootPart
                        box.Size=Vector3.new(4,6,2)
                        box.Color3=Color3.fromRGB(255,170,0)
                        box.AlwaysOnTop=true
                        box.Parent=v.Character

                    end

                end

                if _G.Settings.NameESP then

                    if not v.Character:FindFirstChild("NameESP") then

                        local bill=Instance.new("BillboardGui")
                        bill.Name="NameESP"
                        bill.Size=UDim2.new(0,100,0,40)
                        bill.AlwaysOnTop=true
                        bill.Adornee=head
                        bill.Parent=v.Character

                        local txt=Instance.new("TextLabel",bill)
                        txt.Size=UDim2.new(1,0,1,0)
                        txt.BackgroundTransparency=1
                        txt.Text=v.Name
                        txt.TextColor3=Color3.new(1,1,1)
                        txt.TextStrokeTransparency=0
                        txt.Font=Enum.Font.GothamBold
                        txt.TextScaled=true

                    end

                end

            end

        end

    end

    if _G.Settings.Aimbot and closest then
        Camera.CFrame =
            CFrame.new(Camera.CFrame.Position,closest.Position)
    end

end)

print("LEMON HUB PREMIUM LOADED 🍋")
