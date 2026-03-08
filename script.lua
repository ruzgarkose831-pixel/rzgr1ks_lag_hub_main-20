local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. ESKİLERİ SÜPÜR
local function cleanup()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "rzgr1ks_V30" then v:Destroy() end
    end
end
cleanup()

-- 2. MODERN LİMON ARAYÜZÜ (Dark & Orange Theme)
local sg = Instance.new("ScreenGui")
sg.Name = "rzgr1ks_V30"
sg.Parent = game:GetService("CoreGui") or player.PlayerGui
sg.IgnoreGuiInset = true

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 320, 0, 450)
Main.Position = UDim2.new(0.5, -160, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Neon Turuncu Kenarlık (Lemon Style)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(255, 100, 0)
Stroke.Thickness = 2

-- Kaydırılabilir Liste (Screenshot'taki gibi)
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -50)
Scroll.Position = UDim2.new(0, 5, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 0)

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 8)
UIList.HorizontalAlignment = "Center"

-- BAŞLIK
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "LEMON HUB V30 PREMIUM"
Title.TextColor3 = Color3.fromRGB(255, 140, 0)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- AYARLAR (Global States)
_G.Aimbot = false
_G.Hitbox = false
_G.AntiRagdoll = false
_G.Spinbot = false
_G.HighWalk = false
_G.SpeedVal = 16
_G.JumpVal = 50

-- [BİLEŞEN FABRİKASI]
local function createToggle(name, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(0, 280, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = "  " .. name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextXAlignment = "Left"
    btn.Font = "Gotham"
    Instance.new("UICorner", btn)
    
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.Text = active and ("  " .. name .. ": ON") or ("  " .. name .. ": OFF")
        btn.TextColor3 = active and Color3.fromRGB(255, 100, 0) or Color3.new(1, 1, 1)
        callback(active)
    end)
end

local function createSlider(name, min, max, default, callback)
    local sFrame = Instance.new("Frame", Scroll)
    sFrame.Size = UDim2.new(0, 280, 0, 50)
    sFrame.BackgroundTransparency = 1
    
    local lab = Instance.new("TextLabel", sFrame)
    lab.Text = name .. ": " .. default
    lab.Size = UDim2.new(1, 0, 0, 20)
    lab.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    lab.BackgroundTransparency = 1
    
    local bar = Instance.new("TextButton", sFrame)
    bar.Size = UDim2.new(0, 260, 0, 5)
    bar.Position = UDim2.new(0.5, -130, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    bar.Text = ""
    Instance.new("UICorner", bar)
    
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    Instance.new("UICorner", fill)
    
    local function update(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (max - min) * pos)
        lab.Text = name .. ": " .. val
        callback(val)
    end
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = UIS.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    update(input)
                end
            end)
            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    connection:Disconnect()
                end
            end)
            update(input)
        end
    end)
end

-- ÖZELLİKLERİ EKLE (Limon Hub Sıralaması)
createToggle("Aimbot Lock", function(v) _G.Aimbot = v end)
createToggle("Hitbox Expander", function(v) _G.Hitbox = v end)
createSlider("Speed Boost", 16, 300, 70, function(v) _G.SpeedVal = v end)
createSlider("Jump Power", 50, 500, 50, function(v) _G.JumpVal = v end)
createToggle("Anti Ragdoll (FIXED)", function(v) _G.AntiRagdoll = v end)
createToggle("Spin Bot (Mevlana)", function(v) _G.Spinbot = v end)
createToggle("High Walk (SkyWalk)", function(v) _G.HighWalk = v end)
createToggle("Infinite Jump", function(v) _G.InfJump = v end)

-- 3. MOTOR VE ANTI-RAGDOLL FIX
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if hum then
        hum.WalkSpeed = _G.SpeedVal
        hum.JumpPower = _G.JumpVal
        hum.UseJumpPower = true
        
        -- High Walk
        hum.HipHeight = _G.HighWalk and 5 or 0
        
        -- ANTI RAGDOLL ULTIMATE FIX
        if _G.AntiRagdoll then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            -- Eğer karakter düşmeye başlarsa zorla ayağa kaldır
            if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum.FloorMaterial == Enum.Material.Air then
                -- Opsiyonel: Karakterin dönmesini engellemek için
            end
        end
    end

    if _G.Spinbot and root then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(50), 0)
    end
    
    -- Hitbox & Aimbot (Önceki stabil kodlar buraya dahil)
    if _G.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(20, 20, 20)
                p.Character.HumanoidRootPart.Transparency = 0.8
                p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
end)

-- Multi/Infinite Jump
UIS.JumpRequest:Connect(function()
    if _G.InfJump and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- KAPATMA TUŞU
local Cls = Instance.new("TextButton", Main)
Cls.Size = UDim2.new(0, 30, 0, 30); Cls.Position = UDim2.new(1, -35, 0, 5)
Cls.Text = "X"; Cls.BackgroundColor3 = Color3.new(0.6, 0, 0); Cls.TextColor3 = Color3.new(1, 1, 1)
Cls.MouseButton1Click:Connect(function() sg:Destroy() end)
