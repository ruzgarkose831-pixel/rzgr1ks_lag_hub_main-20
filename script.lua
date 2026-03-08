local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- 1. CLEANUP
local function cleanup()
    if game:GetService("CoreGui"):FindFirstChild("rzgr1ks_V44") then game:GetService("CoreGui").rzgr1ks_V44:Destroy() end
    if workspace:FindFirstChild("HeliBlock_" .. player.Name) then workspace["HeliBlock_" .. player.Name]:Destroy() end
end
cleanup()

-- 2. RGB GUI DESIGN
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "rzgr1ks_V44"

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 200, 0, 350) 
Main.Position = UDim2.new(0.5, -100, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35); Title.Text = "rzgr1ks V44 - RGB"; Title.BackgroundTransparency = 1
Title.Font = "GothamBold"; Title.TextSize = 11

-- RGB ANIMATION LOOP
spawn(function()
    while task.wait() do
        local hue = tick() % 5 / 5
        local color = Color3.fromHSV(hue, 1, 1)
        Stroke.Color = color
        Title.TextColor3 = color
    end
end)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -45); Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 5, 0); Scroll.ScrollBarThickness = 0
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 6)

-- SETTINGS
_G.Speed = 70; _G.Jump = 50; _G.Spin = false; _G.SpinSpd = 35; _G.Platform = false; _G.Elev = 15

-- 3. PHYSICAL BLOCK
local HeliBlock = Instance.new("Part")
HeliBlock.Name = "HeliBlock_" .. player.Name; HeliBlock.Size = Vector3.new(12, 1, 12)
HeliBlock.Transparency = 0.8; HeliBlock.Anchored = true; HeliBlock.CanCollide = false; HeliBlock.Parent = workspace

-- 4. COMPONENTS
local function createSlider(name, min, max, default, callback)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(0, 185, 0, 40); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = name..": "..default; l.Size = UDim2.new(1,0,0,15); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 9
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0, 170, 0, 4); b.Position = UDim2.new(0,8,0,25); b.BackgroundColor3 = Color3.fromRGB(35,35,35); b.Text = ""
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255,140,0)
    b.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local p = math.clamp((inp.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0); local val = math.floor(min + (max - min) * p)
                l.Text = name..": "..val; callback(val)
            end
        end)
        UIS.InputEnded:Connect(function(u) if u.UserInputType == Enum.UserInputType.MouseButton1 or u.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

local function createToggle(name, callback)
    local t = Instance.new("TextButton", Scroll); t.Size = UDim2.new(0, 185, 0, 28); t.BackgroundColor3 = Color3.fromRGB(25, 25, 25); t.Text = name..": OFF"; t.TextColor3 = Color3.new(1,1,1); t.Font = "Gotham"; t.TextSize = 9; Instance.new("UICorner", t)
    local on = false
    t.MouseButton1Click:Connect(function()
        on = not on; t.Text = on and name..": ON" or name..": OFF"; t.TextColor3 = on and Color3.fromRGB(255,140,0) or Color3.new(1,1,1); callback(on)
    end)
end

-- ADDING FEATURES
createToggle("Block Platform (Fly)", function(v) _G.Platform = v end)
createSlider("Elevation Height", 5, 120, 15, function(v) _G.Elev = v end)
createSlider("Walk Speed", 16, 500, 70, function(v) _G.Speed = v end)
createSlider("Jump Power", 50, 600, 50, function(v) _G.Jump = v end)
createToggle("Spinbot Bypass", function(v) _G.Spin = v end)
createSlider("Spin Velocity", 10, 250, 35, function(v) _G.SpinSpd = v end)
createToggle("Hitbox Expander", function(v) _G.Hitbox = v end)

-- 5. ENGINE
RunService.Heartbeat:Connect(function()
    local char = player.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hum or not root then return end

    hum.WalkSpeed = _G.Speed; hum.JumpPower = _G.Jump

    if _G.Spin then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(_G.SpinSpd), 0) end

    if _G.Platform then
        HeliBlock.CanCollide = true
        HeliBlock.CFrame = CFrame.new(root.Position.X, _G.Elev, root.Position.Z)
        if hum:GetState() == Enum.HumanoidStateType.Freefall then hum:ChangeState(Enum.HumanoidStateType.Running) end
    else
        HeliBlock.CanCollide = false; HeliBlock.Position = Vector3.new(0, -1000, 0)
    end
end)

-- MINIMIZE BUTTON
local Open = Instance.new("TextButton", sg); Open.Size = UDim2.new(0, 40, 0, 40); Open.Position = UDim2.new(0, 15, 0.5, -20); Open.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Open.Text = "L"; Open.TextColor3 = Color3.new(1,1,1); Open.Visible = false; Instance.new("UICorner", Open).CornerRadius = UDim.new(1,0); Instance.new("UIStroke", Open).Color = Color3.fromRGB(255,140,0)
local Cls = Instance.new("TextButton", Main); Cls.Size = UDim2.new(0, 20, 0, 20); Cls.Position = UDim2.new(1, -25, 0, 8); Cls.Text = "X"; Cls.BackgroundColor3 = Color3.new(0.6,0,0); Cls.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", Cls)
Cls.MouseButton1Click:Connect(function() Main.Visible = false; Open.Visible = true end)
Open.MouseButton1Click:Connect(function() Main.Visible = true; Open.Visible = false end)
