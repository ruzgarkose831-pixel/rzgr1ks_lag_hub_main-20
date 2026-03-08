local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. TEMİZLİK VE ÖN HAZIRLIK
local function cleanup()
    if game:GetService("CoreGui"):FindFirstChild("rzgr1ks_V38") then game:GetService("CoreGui").rzgr1ks_V38:Destroy() end
    if workspace:FindFirstChild("WalkBlock_" .. player.Name) then workspace["WalkBlock_" .. player.Name]:Destroy() end
end
cleanup()

-- 2. UI TASARIMI (Lemon Style)
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "rzgr1ks_V38"

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 250, 0, 420)
Main.Position = UDim2.new(0.5, -125, 0.5, -210)
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
Scroll.Size = UDim2.new(1, -10, 1, -50); Scroll.Position = UDim2.new(0, 45, 0, 45)
Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 5, 0); Scroll.ScrollBarThickness = 0
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 8)

-- AYARLAR
_G.HighWalk = false
_G.FlyHeight = 8
_G.SpeedVal = 70
_G.JumpVal = 50
_G.SpinSpeed = 10
_G.Spinbot = false

-- GÖRÜNMEZ BLOK OLUŞTURMA (Ayak Altı Bloğu)
local WalkBlock = Instance.new("Part")
WalkBlock.Name = "WalkBlock_" .. player.Name
WalkBlock.Size = Vector3.new(12, 1, 12)
WalkBlock.Transparency = 0.8 -- Biraz görünür yaptım ki yerini anla (İstersen 1 yap)
WalkBlock.Color = Color3.fromRGB(255, 130, 0) -- Turuncu Premium Blok
WalkBlock.Anchored = true
WalkBlock.CanCollide = false
WalkBlock.Parent = workspace

-- [SLIDER VE TOGGLE YAPICILAR]
local function createSlider(name, min, max, default, callback)
    local sFrame = Instance.new("Frame", Scroll)
    sFrame.Size = UDim2.new(0, 220, 0, 45); sFrame.BackgroundTransparency = 1
    local lab = Instance.new("TextLabel", sFrame)
    lab.Text = name .. ": " .. default; lab.Size = UDim2.new(1, 0, 0, 15); lab.TextColor3 = Color3.new(1,1,1); lab.BackgroundTransparency = 1
    local bar = Instance.new("TextButton", sFrame)
    bar.Size = UDim2.new(0, 200, 0, 5); bar.Position = UDim2.new(0, 10, 0, 25); bar.BackgroundColor3 = Color3.fromRGB(40,40,40); bar.Text = ""
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
        UIS.InputEnded:Connect(function(endInp) if endInp.UserInputType == Enum.UserInputType.MouseButton1 or endInp.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

local function createToggle(name, callback)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, 220, 0, 35); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.Text = " " .. name .. ": OFF"; b.TextColor3 = Color3.new(1, 1, 1); b.Font = "Gotham"; b.TextSize = 11; Instance.new("UICorner", b)
    local act = false
    b.MouseButton1Click:Connect(function()
        act = not act; b.Text = act and (" " .. name .. ": ON") or (" " .. name .. ": OFF"); b.TextColor3 = act and Color3.fromRGB(255, 130, 0) or Color3.new(1, 1, 1); callback(act)
    end)
end

-- ÖZELLİKLERİ EKLE
createToggle("Block Walk (Havada Blok)", function(v) _G.HighWalk = v end)
createSlider("Walk Height (Blok Yüksekliği)", 3, 50, 8, function(v) _G.FlyHeight = v end)
createSlider("Speed", 16, 500, 70, function(v) _G.SpeedVal = v end)
createSlider("Jump", 50, 500, 50, function(v) _G.JumpVal = v end)
createToggle("Mevlana (Yavaş Spin)", function(v) _G.Spinbot = v end)
createSlider("Mevlana Hızı", 1, 100, 10, function(v) _G.SpinSpeed = v end)
createToggle("Hitbox", function(v) _G.Hitbox = v end)

-- ANA MOTOR (PLATFORM TAKİBİ)
RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    hum.WalkSpeed = _G.SpeedVal
    hum.JumpPower = _G.JumpVal

    -- Blok Takip Sistemi
    if _G.HighWalk then
        WalkBlock.CanCollide = true
        -- Bloğu karakterin altına, belirlediğin yüksekliğe sabitle
        WalkBlock.CFrame = CFrame.new(root.Position.X, _G.FlyHeight, root.Position.Z)
    else
        WalkBlock.CanCollide = false
        WalkBlock.Position = Vector3.new(0, -1000, 0)
    end

    if _G.Spinbot then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(_G.SpinSpeed), 0)
    end

    if _G.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(15, 15, 15)
                p.Character.HumanoidRootPart.Transparency = 0.8
            end
        end
    end
end)

-- KAPATMA/AÇMA
local Cls = Instance.new("TextButton", Main)
Cls.Size = UDim2.new(0, 25, 0, 25); Cls.Position = UDim2.new(1, -30, 0, 5); Cls.Text = "X"; Cls.BackgroundColor3 = Color3.new(0.6, 0, 0)
Cls.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)
