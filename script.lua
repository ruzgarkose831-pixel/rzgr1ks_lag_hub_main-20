local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. CLEANUP OLD
local function cleanup()
    if game:GetService("CoreGui"):FindFirstChild("rzgr1ks_V51") then game:GetService("CoreGui").rzgr1ks_V51:Destroy() end
    if workspace:FindFirstChild("AirBlock_" .. player.Name) then workspace["AirBlock_" .. player.Name]:Destroy() end
end
cleanup()

-- 2. GRID UI DESIGN
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "rzgr1ks_V51"

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 310, 0, 240)
Main.Position = UDim2.new(0.5, -155, 0.5, -120)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -30, 0, 30); Title.Text = "  rzgr1ks V51 - FULL GRID"
Title.BackgroundTransparency = 1; Title.Font = "GothamBold"; Title.TextSize = 10; Title.TextXAlignment = "Left"

-- RGB ANIMATION
spawn(function()
    while task.wait() do
        local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        Stroke.Color = color; Title.TextColor3 = color
    end
end)

-- MINIMIZE SYSTEM
local MiniBtn = Instance.new("TextButton", Main)
MiniBtn.Size = UDim2.new(0, 25, 0, 25); MiniBtn.Position = UDim2.new(1, -28, 0, 3)
MiniBtn.Text = "-"; MiniBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); MiniBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", MiniBtn)

local OpenBtn = Instance.new("TextButton", sg)
OpenBtn.Size = UDim2.new(0, 40, 0, 40); OpenBtn.Position = UDim2.new(0, 15, 0.5, -20)
OpenBtn.Visible = false; OpenBtn.Text = "R"; OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", OpenBtn); Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(255, 140, 0)

MiniBtn.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -40); Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 2.5, 0); Scroll.ScrollBarThickness = 0
local Grid = Instance.new("UIGridLayout", Scroll)
Grid.CellSize = UDim2.new(0, 145, 0, 30); Grid.Padding = UDim2.new(0, 5, 0, 5)

-- 3. UPDATED COMPONENTS
_G.Set = {Speed = 70, Elev = 15, Spin = false, Hitbox = false, ESP = false, AntiRag = true}

local function createToggle(name, key)
    local t = Instance.new("TextButton", Scroll)
    t.BackgroundColor3 = Color3.fromRGB(25, 25, 25); t.Text = name .. ": OFF"
    t.TextColor3 = Color3.new(1, 1, 1); t.Font = "Gotham"; t.TextSize = 8; Instance.new("UICorner", t)
    t.MouseButton1Click:Connect(function()
        _G.Set[key] = not _G.Set[key]
        t.Text = _G.Set[key] and name .. ": ON" or name .. ": OFF"
        t.TextColor3 = _G.Set[key] and Color3.fromRGB(255, 140, 0) or Color3.new(1, 1, 1)
    end)
end

local function createSlider(name, min, max, default, key)
    local f = Instance.new("Frame", Scroll); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = name..": "..default; l.Size = UDim2.new(1,0,0,12); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 7
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0, 130, 0, 3); b.Position = UDim2.new(0,8,0,20); b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.Text = ""
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255,140,0)
    b.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local p = math.clamp((inp.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0); local val = math.floor(min + (max - min) * p)
                l.Text = name..": "..val; _G.Set[key] = val
            end
        end)
        UIS.InputEnded:Connect(function(u) if u.UserInputType == Enum.UserInputType.MouseButton1 or u.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

-- 4. BUTTONS & SLIDERS (YAN YANA)
createToggle("Block Platform", "Platform")
createToggle("ESP Wallhack", "ESP")
createToggle("Hitbox Expand", "Hitbox")
createToggle("Anti Ragdoll", "AntiRag")
createToggle("Torque Spin", "Spin")
createSlider("Walk Speed", 16, 500, 70, "Speed")
createSlider("Elev Height", 5, 200, 15, "Elev")

-- 5. ENGINE
local AirBlock = Instance.new("Part")
AirBlock.Name = "AirBlock_" .. player.Name; AirBlock.Size = Vector3.new(16, 1, 16); AirBlock.Transparency = 0.8; AirBlock.Anchored = true; AirBlock.Parent = workspace

RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    hum.WalkSpeed = _G.Set.Speed
    if _G.Set.Spin then root.RotVelocity = Vector3.new(0, 50, 0) end
    
    if _G.Set.Hitbox then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(15, 15, 15)
                v.Character.HumanoidRootPart.Transparency = 0.7
            end
        end
    end

    if _G.Set.Platform then
        AirBlock.CanCollide = true; AirBlock.CFrame = CFrame.new(root.Position.X, _G.Set.Elev, root.Position.Z)
        if hum:GetState() == Enum.HumanoidStateType.Freefall then hum:ChangeState(Enum.HumanoidStateType.Running) end
    else
        AirBlock.CanCollide = false; AirBlock.Position = Vector3.new(0, -1000, 0)
    end
end)
