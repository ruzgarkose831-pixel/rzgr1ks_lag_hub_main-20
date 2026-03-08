local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. TEMİZLİK
local function cleanup()
    if game:GetService("CoreGui"):FindFirstChild("rzgr1ks_V39") then game:GetService("CoreGui").rzgr1ks_V39:Destroy() end
    if workspace:FindFirstChild("AirFloor_" .. player.Name) then workspace["AirFloor_" .. player.Name]:Destroy() end
end
cleanup()

-- 2. MODERN LEMON GUI
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "rzgr1ks_V39"

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 260, 0, 440)
Main.Position = UDim2.new(0.5, -130, 0.5, -220)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BorderSizePixel = 0
Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(255, 120, 0)

-- SARI TOP (MINIMIZE)
local OpenBtn = Instance.new("TextButton", sg)
OpenBtn.Size = UDim2.new(0, 45, 0, 45); OpenBtn.Position = UDim2.new(0, 15, 0.5, -22)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0); OpenBtn.Text = "L"; OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -55); Scroll.Position = UDim2.new(0, 5, 0, 45)
Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 5, 0); Scroll.ScrollBarThickness = 2
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 10)

-- BAŞLIK
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "rzgr1ks V39 - PREMIUM"; Title.TextColor3 = Color3.fromRGB(255, 120, 0)
Title.BackgroundTransparency = 1; Title.Font = "GothamBold"; Title.TextSize = 13

-- AYARLAR
_G.SpeedVal = 70; _G.JumpVal = 50; _G.Grav = 196.2; _G.SpinSpd = 10
_G.HighWalk = false; _G.FlyHeight = 15

-- 3. FİZİKSEL BLOK (UÇMA SİSTEMİ)
local AirFloor = Instance.new("Part")
AirFloor.Name = "AirFloor_" .. player.Name
AirFloor.Size = Vector3.new(20, 1, 20)
AirFloor.Transparency = 0.7 -- Yerini görmen için hafif turuncu
AirFloor.Color = Color3.fromRGB(255, 120, 0)
AirFloor.Anchored = true
AirFloor.CanCollide = false
AirFloor.Parent = workspace

-- 4. MODÜLER BİLEŞENLER
local function createSlider(name, min, max, default, callback)
    local sFrame = Instance.new("Frame", Scroll)
    sFrame.Size = UDim2.new(0, 230, 0, 55); sFrame.BackgroundTransparency = 1
    local lab = Instance.new("TextLabel", sFrame)
    lab.Text = name .. ": " .. default; lab.Size = UDim2.new(1, 0, 0, 20); lab.TextColor3 = Color3.new(1,1,1); lab.BackgroundTransparency = 1
    local bar = Instance.new("Frame", sFrame)
    bar.Size = UDim2.new(0, 210, 0, 6); bar.Position = UDim2.new(0, 10, 0, 30); bar.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
    
    local trigger = Instance.new("TextButton", bar)
    trigger.Size = UDim2.new(1, 0, 1, 0); trigger.BackgroundTransparency = 1; trigger.Text = ""
    
    trigger.InputBegan:Connect(function(input)
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
    b.Size = UDim2.new(0, 230, 0, 38); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.Text = name .. ": OFF"
    b.TextColor3 = Color3.new(1, 1, 1); b.Font = "Gotham"; b.TextSize = 11; Instance.new("UICorner", b)
    local act = false
    b.MouseButton1Click:Connect(function()
        act = not act; b.Text = act and (name .. ": ON") or (name .. ": OFF")
        b.TextColor3 = act and Color3.fromRGB(255, 120, 0) or Color3.new(1, 1, 1); callback(act)
    end)
end

-- ÖZELLİKLER
createToggle("High Block Walk", function(v) _G.HighWalk = v end)
createSlider("Flight Height", 5, 100, 15, function(v) _G.FlyHeight = v end)
createSlider("Speed Hack", 16, 500, 70, function(v) _G.SpeedVal = v end)
createSlider("Jump Power", 50, 500, 50, function(v) _G.JumpVal = v end)
createSlider("World Gravity", 0, 400, 196, function(v) _G.Grav = v end)
createToggle("Mevlana (Spin)", function(v) _G.Spinbot = v end)
createSlider("Spin Speed", 1, 100, 10, function(v) _G.SpinSpd = v end)
createToggle("Hitbox Expander", function(v) _G.Hitbox = v end)

-- 5. ANA MOTOR (PLATFORM & BYPASS)
RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    hum.WalkSpeed = _G.SpeedVal
    hum.JumpPower = _G.JumpVal
    workspace.Gravity = _G.Grav

    -- BLOK YÜRÜME SİSTEMİ (KESİN ÇÖZÜM)
    if _G.HighWalk then
        AirFloor.CanCollide = true
        -- Bloğu tam ayaklarının 3 birim altına sabitle
        AirFloor.CFrame = CFrame.new(root.Position.X, _G.FlyHeight, root.Position.Z)
        
        -- Düşme tespiti bypass: Karakterin yere basıyormuş gibi hissetmesini sağla
        if hum:GetState() == Enum.HumanoidStateType.Freefall then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    else
        AirFloor.CanCollide = false
        AirFloor.Position = Vector3.new(0, -1000, 0)
    end

    if _G.Spinbot then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(_G.SpinSpd), 0) end
    
    if _G.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(18, 18, 18)
                p.Character.HumanoidRootPart.Transparency = 0.7
            end
        end
    end
end)

-- KAPATMA/AÇMA
local Cls = Instance.new("TextButton", Main)
Cls.Size = UDim2.new(0, 25, 0, 25); Cls.Position = UDim2.new(1, -30, 0, 8); Cls.Text = "X"
Cls.BackgroundColor3 = Color3.new(0.6, 0, 0); Cls.TextColor3 = Color3.new(1, 1, 1)
Cls.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)
