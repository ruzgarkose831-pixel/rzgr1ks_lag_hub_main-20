local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. TEMİZLİK
local function clear()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if string.find(v.Name, "rzgr1ks") or string.find(v.Name, "Lemon") then v:Destroy() end
    end
    for _, v in pairs(player.PlayerGui:GetChildren()) do
        if string.find(v.Name, "rzgr1ks") or string.find(v.Name, "Lemon") then v:Destroy() end
    end
end
clear()

-- 2. ANA YAPI
local sg = Instance.new("ScreenGui")
sg.Name = "rzgr1ks_V29"
sg.DisplayOrder = 1000000
sg.Parent = game:GetService("CoreGui") or player.PlayerGui

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 280, 0, 560) -- Daha uzun panel
Main.Position = UDim2.new(0.5, -140, 0.5, -280)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(255, 200, 0)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "rzgr1ks Hub V29 - PRO"
Title.TextColor3 = Color3.fromRGB(255, 200, 0)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.TextSize = 16

-- STATES & SETTINGS
_G.Aimbot = false
_G.Hitbox = false
_G.SpeedEnabled = false
_G.JumpEnabled = false
_G.MultiJump = false
_G.AntiRagdoll = false
_G.Spinbot = false
_G.HighWalk = false
_G.ServerLag = false

_G.SpeedVal = 70
_G.JumpVal = 50

-- BUTON YAPICI (Standart Toggle)
local function createToggle(text, yPos, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0, 240, 0, 35)
    b.Position = UDim2.new(0.5, -120, 0, yPos)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.Text = text .. ": OFF"
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 13
    Instance.new("UICorner", b)
    
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = active and (text .. ": ON") or (text .. ": OFF")
        b.BackgroundColor3 = active and Color3.fromRGB(255, 160, 0) or Color3.fromRGB(40, 40, 40)
        callback(active)
    end)
    return b
end

-- AYARLAYICI YAPICI (+/- Butonları)
local function createAdjuster(text, yPos, valRef, step)
    local label = Instance.new("TextLabel", Main)
    label.Size = UDim2.new(0, 120, 0, 35)
    label.Position = UDim2.new(0, 20, 0, yPos)
    label.Text = text .. ": " .. _G[valRef]
    label.BackgroundColor3 = Color3.fromRGB(30,30,30)
    label.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", label)

    local btnPlus = Instance.new("TextButton", Main)
    btnPlus.Size = UDim2.new(0, 50, 0, 35)
    btnPlus.Position = UDim2.new(0, 145, 0, yPos)
    btnPlus.Text = "+"
    btnPlus.BackgroundColor3 = Color3.fromRGB(50,150,50)
    Instance.new("UICorner", btnPlus)

    local btnMinus = Instance.new("TextButton", Main)
    btnMinus.Size = UDim2.new(0, 50, 0, 35)
    btnMinus.Position = UDim2.new(0, 200, 0, yPos)
    btnMinus.Text = "-"
    btnMinus.BackgroundColor3 = Color3.fromRGB(150,50,50)
    Instance.new("UICorner", btnMinus)

    btnPlus.MouseButton1Click:Connect(function()
        _G[valRef] = _G[valRef] + step
        label.Text = text .. ": " .. _G[valRef]
    end)
    btnMinus.MouseButton1Click:Connect(function()
        _G[valRef] = math.max(0, _G[valRef] - step)
        label.Text = text .. ": " .. _G[valRef]
    end)
end

-- ÖZELLİKLERİ YERLEŞTİR
createToggle("Aimbot Lock", 45, function(v) _G.Aimbot = v end)
createToggle("Hitbox Expander", 85, function(v) _G.Hitbox = v end)

createToggle("Speed Hack", 125, function(v) _G.SpeedEnabled = v end)
createAdjuster("Speed", 165, "SpeedVal", 10)

createToggle("Jump Hack", 205, function(v) _G.JumpEnabled = v end)
createAdjuster("Jump", 245, "JumpVal", 10)

createToggle("Multi Jump", 285, function(v) _G.MultiJump = v end)
createToggle("Anti Ragdoll", 325, function(v) _G.AntiRagdoll = v end)
createToggle("Spinbot (Mevlana)", 365, function(v) _G.Spinbot = v end)
createToggle("High Walk (Uçma)", 405, function(v) _G.HighWalk = v end)
createToggle("Server Lag Stress", 445, function(v) _G.ServerLag = v end)

-- KAPATMA / AÇMA
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 30, 0, 30); Close.Position = UDim2.new(1, -35, 0, 2)
Close.Text = "X"; Close.BackgroundColor3 = Color3.fromRGB(180,0,0)

local OpenBtn = Instance.new("TextButton", sg)
OpenBtn.Size = UDim2.new(0, 50, 0, 50); OpenBtn.Position = UDim2.new(0, 10, 0.5, -25)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0); OpenBtn.Text = "AÇ"; OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

Close.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

-- MOTOR (Engine)
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if hum then
        -- Hız ve Zıplama
        if _G.SpeedEnabled then hum.WalkSpeed = _G.SpeedVal end
        if _G.JumpEnabled then hum.JumpPower = _G.JumpVal; hum.UseJumpPower = true end
        
        -- High Walk (HipHeight ile havada durma)
        if _G.HighWalk then hum.HipHeight = 5 else hum.HipHeight = 0 end
        
        -- Anti Ragdoll
        if _G.AntiRagdoll then
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end
    end

    -- Spinbot
    if _G.Spinbot and root then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(60), 0)
    end

    -- Hitbox
    if _G.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(20, 20, 20)
                p.Character.HumanoidRootPart.Transparency = 0.8
                p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end

    -- Server Lag
    if _G.ServerLag and char then
        local t = char:FindFirstChildOfClass("Tool")
        if t then for i=1,15 do t:Activate() end end
    end
    
    -- Aimbot
    if _G.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local cam = workspace.CurrentCamera
        local target = nil; local dist = 400
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                local pos, vis = cam:WorldToViewportPoint(p.Character.Head.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if mag < dist then target = p; dist = mag end
                end
            end
        end
        if target then cam.CFrame = CFrame.new(cam.CFrame.Position, target.Character.Head.Position) end
    end
end)

-- Multi Jump
UIS.JumpRequest:Connect(function()
    if _G.MultiJump and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
