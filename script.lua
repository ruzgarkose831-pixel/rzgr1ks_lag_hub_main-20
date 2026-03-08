local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. TEMİZLİK
local function cleanup()
    if game:GetService("CoreGui"):FindFirstChild("rzgr1ks_V37") then game:GetService("CoreGui").rzgr1ks_V37:Destroy() end
end
cleanup()

-- 2. UI TASARIMI
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "rzgr1ks_V37"

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 260, 0, 450)
Main.Position = UDim2.new(0.5, -130, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(255, 130, 0)

-- SARI TOP (Açma Butonu)
local OpenBtn = Instance.new("TextButton", sg)
OpenBtn.Size = UDim2.new(0, 45, 0, 45); OpenBtn.Position = UDim2.new(0, 10, 0.5, -22)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0); OpenBtn.Text = "HUB"; OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -50); Scroll.Position = UDim2.new(0, 5, 0, 45)
Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 5, 0); Scroll.ScrollBarThickness = 0
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 8)

-- VARSAYILAN AYARLAR
_G.SpeedVal = 70; _G.JumpVal = 50; _G.GravityVal = 196.2
_G.SpinSpeed = 15; _G.HighWalk = false; _G.Spinbot = false

-- [SLIDER SİSTEMİ]
local function createSlider(name, min, max, default, callback)
    local sFrame = Instance.new("Frame", Scroll)
    sFrame.Size = UDim2.new(0, 230, 0, 50); sFrame.BackgroundTransparency = 1
    local lab = Instance.new("TextLabel", sFrame)
    lab.Text = name .. ": " .. default; lab.Size = UDim2.new(1, 0, 0, 20); lab.TextColor3 = Color3.new(1,1,1); lab.BackgroundTransparency = 1
    local bar = Instance.new("TextButton", sFrame)
    bar.Size = UDim2.new(0, 210, 0, 6); bar.Position = UDim2.new(0, 10, 0, 30); bar.BackgroundColor3 = Color3.fromRGB(40,40,40); bar.Text = ""
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 130, 0)
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local con; con = UIS.InputChanged:Connect(function(move)
                if move.UserInputType == Enum.UserInputType.MouseButton1 or move.UserInputType == Enum.UserInputType.Touch or move.UserInputType == Enum.UserInputType.MouseMovement then
                    local p = math.clamp((move.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(p, 0, 1, 0)
                    local val = math.floor(min + (max - min) * p)
                    lab.Text = name .. ": " .. val; callback(val)
                end
            end)
            UIS.InputEnded:Connect(function(up) if up.UserInputType == Enum.UserInputType.MouseButton1 or up.UserInputType == Enum.UserInputType.Touch then con:Disconnect() end end)
        end
    end)
end

local function createToggle(name, callback)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, 230, 0, 35); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.Text = " " .. name .. ": OFF"; b.TextColor3 = Color3.new(1, 1, 1); b.Font = "Gotham"; b.TextSize = 11; Instance.new("UICorner", b)
    local act = false
    b.MouseButton1Click:Connect(function()
        act = not act; b.Text = act and (" " .. name .. ": ON") or (" " .. name .. ": OFF"); b.TextColor3 = act and Color3.fromRGB(255, 130, 0) or Color3.new(1, 1, 1); callback(act)
    end)
end

-- ÖZELLİKLERİ EKLE
createToggle("High Walk (Sabit Uçuş)", function(v) _G.HighWalk = v end)
createSlider("Movement Speed", 16, 500, 70, function(v) _G.SpeedVal = v end)
createSlider("Jump Power", 50, 500, 50, function(v) _G.JumpVal = v end)
createSlider("World Gravity", 0, 300, 196, function(v) _G.GravityVal = v end)
createToggle("Mevlana (Yavaş Spin)", function(v) _G.Spinbot = v end)
createSlider("Spin Speed", 1, 100, 15, function(v) _G.SpinSpeed = v end)
createToggle("Aimbot V-Locker", function(v) _G.Aimbot = v end)
createToggle("Hitbox Expander", function(v) _G.Hitbox = v end)

-- KAPATMA/AÇMA
local Cls = Instance.new("TextButton", Main)
Cls.Size = UDim2.new(0, 25, 0, 25); Cls.Position = UDim2.new(1, -30, 0, 5); Cls.Text = "X"; Cls.BackgroundColor3 = Color3.new(0.6, 0, 0)
Cls.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

-- ANA MOTOR
RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    hum.WalkSpeed = _G.SpeedVal
    hum.JumpPower = _G.JumpVal
    workspace.Gravity = _G.GravityVal

    -- High Walk (Dikey Hız Sabitleyici - Uçmayı Engeller)
    if _G.HighWalk then
        hum:ChangeState(Enum.HumanoidStateType.NoPhysics)
        root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z) -- Y ekseni (Yukarı/Aşağı) sıfırlandı
    else
        if hum:GetState() == Enum.HumanoidStateType.NoPhysics then hum:ChangeState(Enum.HumanoidStateType.Running) end
    end

    -- Yavaşlatılmış Mevlana
    if _G.Spinbot then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(_G.SpinSpeed), 0)
    end

    -- Hitbox & Aimbot aynı stabilitede devam ediyor
    if _G.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(15, 15, 15)
                p.Character.HumanoidRootPart.Transparency = 0.8
            end
        end
    end
end)
