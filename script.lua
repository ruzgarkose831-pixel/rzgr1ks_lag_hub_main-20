local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. CLEANUP
local function cleanup()
    if game:GetService("CoreGui"):FindFirstChild("rzgr1ks_V49") then game:GetService("CoreGui").rzgr1ks_V49:Destroy() end
    if workspace:FindFirstChild("AirBlock_" .. player.Name) then workspace["AirBlock_" .. player.Name]:Destroy() end
end
cleanup()

-- 2. ULTRA COMPACT GRID UI
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "rzgr1ks_V49"

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 320, 0, 260) -- Genişlik artırıldı, yükseklik azaltıldı
Main.Position = UDim2.new(0.5, -160, 0.5, -130)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30); Title.Text = "rzgr1ks V49 - GRID MODE"; Title.BackgroundTransparency = 1
Title.Font = "GothamBold"; Title.TextSize = 10

-- RGB ANIMATION
spawn(function()
    while task.wait() do
        local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        Stroke.Color = color; Title.TextColor3 = color
    end
end)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -10, 1, -40); Container.Position = UDim2.new(0, 5, 0, 35)
Container.BackgroundTransparency = 1; Container.CanvasSize = UDim2.new(0, 0, 2, 0); Container.ScrollBarThickness = 0
local Layout = Instance.new("UIGridLayout", Container)
Layout.CellSize = UDim2.new(0, 150, 0, 35) -- Yan yana iki buton sığacak şekilde ayarlandı
Layout.Padding = UDim2.new(0, 5, 0, 5)

-- SETTINGS
_G.Cfg = {Speed = 70, Jump = 50, Spin = false, Platform = false, Elev = 15, AntiRag = true, Hitbox = false, ESP = false}

-- 3. UPDATED COMPONENTS
local function createToggle(name, key, callback)
    local t = Instance.new("TextButton", Container)
    t.Size = UDim2.new(0, 145, 0, 30); t.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    t.Text = name .. ": OFF"; t.TextColor3 = Color3.new(1,1,1); t.Font = "Gotham"; t.TextSize = 8
    Instance.new("UICorner", t)
    t.MouseButton1Click:Connect(function()
        _G.Cfg[key] = not _G.Cfg[key]
        t.Text = _G.Cfg[key] and name .. ": ON" or name .. ": OFF"
        t.TextColor3 = _G.Cfg[key] and Color3.fromRGB(255, 140, 0) or Color3.new(1,1,1)
        if callback then callback(_G.Cfg[key]) end
    end)
end

-- 4. FEATURES (ALL FIXED)
createToggle("Block Plat", "Platform")
createToggle("ESP Wall", "ESP")
createToggle("Hitbox Exp", "Hitbox")
createToggle("Anti Ragdoll", "AntiRag")
createToggle("Torque Spin", "Spin")

-- SLIDERS (Alt alta devam eder)
local function createSlider(name, min, max, default, key)
    local f = Instance.new("Frame", Container); f.Size = UDim2.new(0, 145, 0, 35); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = name..": "..default; l.Size = UDim2.new(1,0,0,12); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 7
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0, 130, 0, 3); b.Position = UDim2.new(0,8,0,20); b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.Text = ""
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255,140,0)
    b.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local p = math.clamp((inp.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0); local val = math.floor(min + (max - min) * p)
                l.Text = name..": "..val; _G.Cfg[key] = val
            end
        end)
        UIS.InputEnded:Connect(function(u) if u.UserInputType == Enum.UserInputType.MouseButton1 or u.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

createSlider("Speed", 16, 500, 70, "Speed")
createSlider("Height", 5, 200, 15, "Elev")

-- 5. ENGINE FIXES
local AirBlock = Instance.new("Part")
AirBlock.Name = "AirBlock_" .. player.Name; AirBlock.Size = Vector3.new(15, 1, 15); AirBlock.Transparency = 0.8; AirBlock.Anchored = true; AirBlock.Parent = workspace

RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    hum.WalkSpeed = _G.Cfg.Speed
    
    -- MEVLANA BYPASS FIX (Physical Torque)
    if _G.Cfg.Spin then
        root.RotVelocity = Vector3.new(0, 50, 0) -- Ölmeni engelleyen fiziksel dönme
    end

    -- HITBOX FIX
    if _G.Cfg.Hitbox then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(15, 15, 15)
                v.Character.HumanoidRootPart.Transparency = 0.7
                v.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end

    -- PLATFORM FIX
    if _G.Cfg.Platform then
        AirBlock.CanCollide = true
        AirBlock.CFrame = CFrame.new(root.Position.X, _G.Cfg.Elev, root.Position.Z)
    else
        AirBlock.CanCollide = false; AirBlock.Position = Vector3.new(0, -1000, 0)
    end
end)
