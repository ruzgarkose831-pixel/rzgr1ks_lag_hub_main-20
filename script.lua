local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. TEMİZLİK VE BYPASS HAZIRLIĞI
local function cleanup()
    if game:GetService("CoreGui"):FindFirstChild("rzgr1ks_V41") then game:GetService("CoreGui").rzgr1ks_V41:Destroy() end
end
cleanup()

-- MEVLANA BYPASS (Hız ve Dönüşü Senkronize Eder)
local function applyBypass(char)
    if char:FindFirstChild("HumanoidRootPart") then
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("BodyAngularVelocity") or v:IsA("BodyVelocity") then v:Destroy() end
        end
    end
end

-- 2. UI TASARIMI (Premium Lemon Hub Style)
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "rzgr1ks_V41"

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 260, 0, 480) -- Daha fazla özellik için biraz uzatıldı
Main.Position = UDim2.new(0.5, -130, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(255, 130, 0)

-- SARI TOP (Açma Butonu)
local OpenBtn = Instance.new("TextButton", sg)
OpenBtn.Size = UDim2.new(0, 45, 0, 45); OpenBtn.Position = UDim2.new(0, 15, 0.5, -22)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0); OpenBtn.Text = "HUB"; OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -50); Scroll.Position = UDim2.new(0, 5, 0, 45)
Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 6, 0); Scroll.ScrollBarThickness = 0
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 8)

-- AYARLAR
_G.Aimbot = false; _G.Hitbox = false; _G.SpeedVal = 70; _G.JumpVal = 50
_G.Spinbot = false; _G.TrueFly = false; _G.ServerLag = false; _G.SpinSpd = 30

-- SLIDER YAPICI
local function createSlider(name, min, max, default, callback)
    local sFrame = Instance.new("Frame", Scroll)
    sFrame.Size = UDim2.new(0, 230, 0, 55); sFrame.BackgroundTransparency = 1
    local lab = Instance.new("TextLabel", sFrame)
    lab.Text = name .. ": " .. default; lab.Size = UDim2.new(1, 0, 0, 20); lab.TextColor3 = Color3.new(1,1,1); lab.BackgroundTransparency = 1
    local bar = Instance.new("TextButton", sFrame)
    bar.Size = UDim2.new(0, 210, 0, 6); bar.Position = UDim2.new(0, 10, 0, 30); bar.BackgroundColor3 = Color3.fromRGB(40,40,40); bar.Text = ""
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 130, 0)
    
    bar.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local p = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0)
                local val = math.floor(min + (max - min) * p)
                lab.Text = name .. ": " .. val; callback(val)
            end
        end)
        UIS.InputEnded:Connect(function(up) if up.UserInputType == Enum.UserInputType.MouseButton1 or up.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

local function createToggle(name, callback)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, 230, 0, 35); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.Text = name .. ": OFF"
    b.TextColor3 = Color3.new(1, 1, 1); b.Font = "Gotham"; b.TextSize = 11; Instance.new("UICorner", b)
    local act = false
    b.MouseButton1Click:Connect(function()
        act = not act; b.Text = act and (name .. ": ON") or (name .. ": OFF")
        b.TextColor3 = act and Color3.fromRGB(255, 130, 0) or Color3.new(1, 1, 1); callback(act)
    end)
end

-- TÜM ÖZELLİKLER GERİ GELDİ
createToggle("Aimbot (V-Locker)", function(v) _G.Aimbot = v end)
createToggle("Hitbox Expander", function(v) _G.Hitbox = v end)
createToggle("True Flight (Uçma)", function(v) _G.TrueFly = v end)
createToggle("Mevlana (Anti-Cheat Bypass)", function(v) _G.Spinbot = v end)
createSlider("Mevlana Speed", 5, 150, 30, function(v) _G.SpinSpd = v end)
createSlider("Movement Speed", 16, 500, 70, function(v) _G.SpeedVal = v end)
createSlider("Jump Power", 50, 500, 50, function(v) _G.JumpVal = v end)
createToggle("Server Lag Stress", function(v) _G.ServerLag = v end)

-- ANA MOTOR
RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    hum.WalkSpeed = _G.SpeedVal
    hum.JumpPower = _G.JumpVal

    -- BYPASS MEVLANA SİSTEMİ (Ölmeni ve Atılmanı Engeller)
    if _G.Spinbot then
        applyBypass(char)
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(_G.SpinSpd), 0)
    end

    if _G.TrueFly then
        hum:ChangeState(Enum.HumanoidStateType.NoPhysics)
        root.Velocity = Vector3.new(root.Velocity.X, UIS:IsKeyDown(Enum.KeyCode.Space) and 50 or 0, root.Velocity.Z)
    else
        if hum:GetState() == Enum.HumanoidStateType.NoPhysics then hum:ChangeState(Enum.HumanoidStateType.Running) end
    end

    if _G.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(18, 18, 18)
                p.Character.HumanoidRootPart.Transparency = 0.7
            end
        end
    end

    if _G.ServerLag and char:FindFirstChildOfClass("Tool") then
        for i=1, 5 do char:FindFirstChildOfClass("Tool"):Activate() end
    end
end)

-- KAPATMA/AÇMA
local Cls = Instance.new("TextButton", Main)
Cls.Size = UDim2.new(0, 25, 0, 25); Cls.Position = UDim2.new(1, -30, 0, 8); Cls.Text = "X"
Cls.BackgroundColor3 = Color3.new(0.6, 0, 0); Cls.TextColor3 = Color3.new(1, 1, 1)
Cls.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)
