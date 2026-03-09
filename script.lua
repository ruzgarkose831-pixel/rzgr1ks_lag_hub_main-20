-- rzgr1ks DUEL HUB V7

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

_G.Hub = {
Aimbot=false,
FOV=150,
Speed=false,
SpeedVal=50,
Jump=false,
JumpVal=80,
Spin=false,
SmartHitbox=false,
HitboxSize=15,
ESP=false,
Tracer=false,
HealthESP=false,
Float=false,
Galaxy=false
}

-- GUI
local gui=Instance.new("ScreenGui",player.PlayerGui)
gui.ResetOnSpawn=false

local main=Instance.new("Frame",gui)
main.Size=UDim2.new(0,330,0,420)
main.Position=UDim2.new(0.5,-165,0.5,-210)
main.BackgroundColor3=Color3.fromRGB(20,20,25)
Instance.new("UICorner",main)

-- ICON
local icon=Instance.new("TextButton",gui)
icon.Size=UDim2.new(0,45,0,45)
icon.Position=UDim2.new(0,10,0.5,-20)
icon.Text="🍋"
icon.TextSize=25
icon.BackgroundColor3=Color3.fromRGB(20,20,25)
Instance.new("UICorner",icon)

icon.MouseButton1Click:Connect(function()
main.Visible=true
icon.Visible=false
end)

-- INSERT KEY GUI
UIS.InputBegan:Connect(function(input,gp)
if gp then return end
if input.KeyCode==Enum.KeyCode.Insert then
main.Visible=not main.Visible
end
end)

-- HEADER
local header=Instance.new("TextButton",main)
header.Size=UDim2.new(1,0,0,35)
header.Text="rzgr1ks DUEL HUB V7"
header.Font=Enum.Font.GothamBold
header.TextSize=14
header.BackgroundColor3=Color3.fromRGB(35,35,40)
header.TextColor3=Color3.new(1,1,1)

header.MouseButton1Click:Connect(function()
main.Visible=false
icon.Visible=true
end)

-- DRAG
local drag=false
local start
local startpos

header.InputBegan:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
drag=true
start=i.Position
startpos=main.Position
end
end)

UIS.InputEnded:Connect(function()
drag=false
end)

UIS.InputChanged:Connect(function(i)
if drag then
local delta=i.Position-start
main.Position=UDim2.new(
startpos.X.Scale,
startpos.X.Offset+delta.X,
startpos.Y.Scale,
startpos.Y.Offset+delta.Y
)
end
end)

-- SCROLL
local scroll=Instance.new("ScrollingFrame",main)
scroll.Size=UDim2.new(1,-10,1,-45)
scroll.Position=UDim2.new(0,5,0,40)
scroll.CanvasSize=UDim2.new(0,0,0,900)
scroll.BackgroundTransparency=1
scroll.ScrollBarThickness=4

local layout=Instance.new("UIListLayout",scroll)
layout.Padding=UDim.new(0,5)

-- TOGGLE
local function Toggle(name,key)

local b=Instance.new("TextButton",scroll)
b.Size=UDim2.new(1,0,0,30)
b.Text=name.." : OFF"
b.BackgroundColor3=Color3.fromRGB(40,40,45)
b.Font=Enum.Font.GothamBold
b.TextSize=12
b.TextColor3=Color3.new(1,1,1)

Instance.new("UICorner",b)

b.MouseButton1Click:Connect(function()

_G.Hub[key]=not _G.Hub[key]

if _G.Hub[key] then
b.Text=name.." : ON"
b.TextColor3=Color3.fromRGB(255,140,0)
else
b.Text=name.." : OFF"
b.TextColor3=Color3.new(1,1,1)
end

end)

end

-- SLIDER
local function Slider(name,min,max,key)

local frame=Instance.new("Frame",scroll)
frame.Size=UDim2.new(1,0,0,40)
frame.BackgroundTransparency=1

local label=Instance.new("TextLabel",frame)
label.Size=UDim2.new(1,0,0,15)
label.Text=name..": ".._G.Hub[key]
label.TextColor3=Color3.new(1,1,1)
label.BackgroundTransparency=1
label.Font=Enum.Font.Gotham
label.TextSize=12

local bar=Instance.new("Frame",frame)
bar.Size=UDim2.new(1,-20,0,8)
bar.Position=UDim2.new(0,10,1,-15)
bar.BackgroundColor3=Color3.fromRGB(50,50,55)
Instance.new("UICorner",bar)

local fill=Instance.new("Frame",bar)
fill.Size=UDim2.new(.3,0,1,0)
fill.BackgroundColor3=Color3.fromRGB(255,140,0)
Instance.new("UICorner",fill)

bar.InputBegan:Connect(function(input)

if input.UserInputType==Enum.UserInputType.MouseButton1 then

local move
move=UIS.InputChanged:Connect(function()

local pos=(UIS:GetMouseLocation().X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X
pos=math.clamp(pos,0,1)

fill.Size=UDim2.new(pos,0,1,0)

local val=math.floor(min+(max-min)*pos)
_G.Hub[key]=val
label.Text=name..": "..val

end)

UIS.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 then
move:Disconnect()
end
end)

end

end)

end

-- BUTTONS
Toggle("FOV AIMBOT","Aimbot")
Slider("AIMBOT FOV",50,400,"FOV")

Toggle("SMART HITBOX","SmartHitbox")
Slider("HITBOX SIZE",5,40,"HitboxSize")

Toggle("PLAYER ESP","ESP")
Toggle("TRACER ESP","Tracer")
Toggle("HEALTH ESP","HealthESP")

Toggle("SPEED BOOST","Speed")
Slider("WALK SPEED",16,200,"SpeedVal")

Toggle("JUMP MOD","Jump")
Slider("JUMP POWER",50,200,"JumpVal")

Toggle("SPIN BOT","Spin")
Toggle("FLOAT PLATFORM","Float")
Toggle("GALAXY SKY","Galaxy")

-- FLOAT PLATFORM
local platform=Instance.new("Part")
platform.Size=Vector3.new(12,1,12)
platform.Anchored=true
platform.Transparency=1
platform.Parent=workspace

-- FOV CIRCLE
local circle=Drawing.new("Circle")
circle.Color=Color3.fromRGB(255,140,0)
circle.Thickness=2
circle.NumSides=100
circle.Radius=_G.Hub.FOV
circle.Visible=true
circle.Filled=false

-- ENGINE
RunService.RenderStepped:Connect(function()

circle.Position=Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
circle.Radius=_G.Hub.FOV

local char=player.Character
if not char then return end

local hum=char:FindFirstChildOfClass("Humanoid")
local hrp=char:FindFirstChild("HumanoidRootPart")

if not hum or not hrp then return end

if _G.Hub.Speed then
hum.WalkSpeed=_G.Hub.SpeedVal
end

if _G.Hub.Jump then
hum.JumpPower=_G.Hub.JumpVal
end

if _G.Hub.Spin then
hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(70),0)
end

if _G.Hub.Float then
platform.Position=hrp.Position-Vector3.new(0,3,0)
platform.CanCollide=true
else
platform.CanCollide=false
end

if _G.Hub.Galaxy then
Lighting.Brightness=5
Lighting.ClockTime=14
Lighting.FogEnd=100000
end

end)
