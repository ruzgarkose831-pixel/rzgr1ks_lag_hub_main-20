--[[
    LEMÖN HUB DUELS PREMİÜM - V40 FINAL FIX
    Tüm özellikler eklendi, GUI görünürlüğü garanti altına alındı.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- ÖNCEKİ SCRIPTİ TEMİZLE
local oldGui = Player.PlayerGui:FindFirstChild("LemonHubFinal")
if oldGui then oldGui:Destroy() end

_G.Settings = {
    PlayerHB = false, PlayerHBSize = 25,
    BatHitbox = true, BatSize = 45, 
    PlayerESP = false, ESPDistance = 800,
    UnderArms = false, HiddenHead = false,
    Speed = true, SpeedVal = 70,
    JumpPower = 50,
    Spin = false, SpinSpeed = 200,
    AutoAttack = false,
    Waypoints = {}
}

-- GUI OLUŞTURMA
local gui = Instance.new("ScreenGui", Player.PlayerGui)
gui.Name = "LemonHubFinal"
gui.ResetOnSpawn = false

-- ANA PANEL
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 320, 0, 480)
main.Position = UDim2.new(0.5, -160, 0.5, -240)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true -- Menüyü başlığından tut sürükle
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- RGB KENARLIK
local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2.5
RunService.RenderStepped:Connect(function() 
    stroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) 
end)

-- BAŞLIK
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "LEMÖN HUB PREMIUM"
title.TextColor3 = Color3.fromRGB(255, 160, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = "Left"
title.BackgroundTransparency = 1

-- KÜÇÜLTME TUŞU
local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0, 35, 0, 35)
minBtn.Position = UDim2.new(1, -40, 0, 0)
minBtn.Text = "_"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.BackgroundTransparency = 1
minBtn.TextSize = 25

-- LİMON İKONU (KÜÇÜLÜNCE)
local sideIcon = Instance.new("TextButton", gui)
sideIcon.Size = UDim2.new(0, 60, 0, 60)
sideIcon.Position = UDim2.new(0.9, 0, 0.2, 0)
sideIcon.Text = "🍋"
sideIcon.Visible = false
sideIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", sideIcon).CornerRadius = UDim.new(1, 0)
local sStroke = Instance.new("UIStroke", sideIcon); sStroke.Thickness = 2
RunService.RenderStepped:Connect(function() sStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)

minBtn.MouseButton1Click:Connect(function() main.Visible = false; sideIcon.Visible = true end)
sideIcon.MouseButton1Click:Connect(function() main.Visible = true; sideIcon.Visible = false end)

-- KAYDIRMA ALANI
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -50)
scroll.Position = UDim2.new(0, 5, 0, 45)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 1200)
scroll.ScrollBarThickness = 3
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 10)

-- YARDIMCI FONKSİYONLAR
local function AddToggle(text, key)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = "GothamSemibold"; btn.TextSize = 12; btn.TextXAlignment = "Left"
    Instance.new("UICorner", btn)
    
    local dot = Instance.new("Frame", btn)
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(1, -25, 0.5, -6)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    
    btn.MouseButton1Click:Connect(function() _G.Settings[key] = not _G.Settings[key] end)
    RunService.RenderStepped:Connect(function()
        dot.BackgroundColor3 = _G.Settings[key] and Color3.new(0,1,0) or Color3.new(1,0,0)
    end)
end

local function AddSlider(text, min, max, key)
    local f = Instance.new("Frame", scroll)
    f.Size = UDim2.new(1, -10, 0, 55)
    f.BackgroundTransparency = 1
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 0, 20); l.Text = text .. ": " .. _G.Settings[key]
    l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Font = "GothamBold"; l.TextSize = 11; l.TextXAlignment = "Left"
    
    local bar = Instance.new("TextButton", f)
    bar.Size = UDim2.new(1, 0, 0, 20) -- 20PX KALIN SLIDER
    bar.Position = UDim2.new(0, 0, 1, -25)
    bar.BackgroundColor3 = Color3.fromRGB(40,40,40); bar.Text = ""; Instance.new("UICorner", bar)
    
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((_G.Settings[key]-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 140, 0); Instance.new("UICorner", fill)
    
    bar.MouseButton1Down:Connect(function()
        local m; m = UIS.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                _G.Settings[key] = math.floor(min + (max - min) * p)
                l.Text = text .. ": " .. _G.Settings[key]
                fill.Size = UDim2.new(p, 0, 1, 0)
            end
        end)
        UIS.InputEnded:Once(function() m:Disconnect() end)
    end)
end

-- ÖZELLİKLERİ EKLE
AddToggle("GELİŞMİŞ BAT HİTBOX (GOD)", "BatHitbox")
AddSlider("Sopa Menzili", 5, 500, "BatSize")
AddToggle("Düşman Hitbox Büyüt", "PlayerHB")
AddSlider("Hitbox Boyutu", 2, 120, "PlayerHBSize")
AddToggle("Player ESP", "PlayerESP")
AddSlider("ESP Mesafesi", 100, 3000, "ESPDistance")
AddToggle("Hız Hilesi", "Speed")
AddSlider("Hız Ayarı", 16, 600, "SpeedVal")
AddSlider("Zıplama Gücü", 50, 300, "JumpPower")
AddToggle("Mevlana (SpinBot)", "Spin")
AddSlider("Dönme Hızı", 50, 1000, "SpinSpeed")
AddToggle("Yeraltı Kolları", "UnderArms")
AddToggle("Kafayı Gizle", "HiddenHead")
AddToggle("Auto Clicker", "AutoAttack")

--[[ OMEGA LOGIC ENGINE ]]--
RunService.RenderStepped:Connect(function()
    local char = Player.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    -- 1. BAT HITBOX: HER YÖNTEMİ DENE
    if _G.Settings.BatHitbox and root then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            -- Force Reach Part
            local reach = char:FindFirstChild("LemonReach") or Instance.new("Part", char)
            reach.Name = "LemonReach"; reach.Transparency = 1; reach.CanCollide = false; reach.Massless = true
            if not reach:FindFirstChild("Weld") then
                local w = Instance.new("Weld", reach); w.Part0 = root; w.Part1 = reach
            end
            reach.Size = Vector3.new(_G.Settings.BatSize, _G.Settings.BatSize, _G.Settings.BatSize)
            
            -- Sopa Parçalarını Büyüt
            for _, p in pairs(tool:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Size = Vector3.new(_G.Settings.BatSize, _G.Settings.BatSize, _G.Settings.BatSize)
                    p.Transparency = 0.8; p.CanCollide = false
                end
            end
            
            -- Force Vuruş (Touch Interest)
            for _, enemy in pairs(Players:GetPlayers()) do
                if enemy ~= Player and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
                    firetouchinterest(reach, enemy.Character.HumanoidRootPart, 0)
                    firetouchinterest(reach, enemy.Character.HumanoidRootPart, 1)
                end
            end
        end
    end

    -- 2. DÜŞMAN HITBOX
    if _G.Settings.PlayerHB then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(_G.Settings.PlayerHBSize, _G.Settings.PlayerHBSize, _G.Settings.PlayerHBSize)
                v.Character.HumanoidRootPart.Transparency = 0.7; v.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end

    -- 3. HAREKET VE BODY MODS
    if hum and root then
        if _G.Settings.Speed then hum.WalkSpeed = _G.Settings.SpeedVal end
        hum.JumpPower = _G.Settings.JumpPower
        
        if _G.Settings.UnderArms then
            local rs = char:FindFirstChild("RightShoulder",true); local ls = char:FindFirstChild("LeftShoulder",true)
            if rs then rs.C0 = CFrame.new(1,-6,0)*CFrame.Angles(math.pi,0,0) end
            if ls then ls.C0 = CFrame.new(-1,-6,0)*CFrame.Angles(math.pi,0,0) end
        end
        if _G.Settings.HiddenHead then
            local n = char:FindFirstChild("Neck",true); if n then n.C0 = CFrame.new(0,-1.5,0) end
        end
        
        if _G.Settings.Spin then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(_G.Settings.SpinSpeed/10), 0)
        end
        if _G.Settings.AutoAttack then
            local t = char:FindFirstChildOfClass("Tool")
            if t then t:Activate() end
        end
    end
end)

-- SIMPLE ESP
local function addESP(P)
    RunService.RenderStepped:Connect(function()
        if P.Character and P.Character:FindFirstChild("HumanoidRootPart") then
            local h = P.Character.HumanoidRootPart
            local esp = h:FindFirstChild("LemonESP") or Instance.new("BillboardGui", h)
            esp.Name = "LemonESP"; esp.Size = UDim2.new(0,100,0,50); esp.AlwaysOnTop = true; esp.StudsOffset = Vector3.new(0,3,0)
            local t = esp:FindFirstChild("Text") or Instance.new("TextLabel", esp)
            t.Name = "Text"; t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1; t.TextColor3 = Color3.new(1,1,1); t.Font = "GothamBold"; t.TextSize = 10
            local dist = math.floor((Player.Character.HumanoidRootPart.Position - h.Position).Magnitude)
            t.Text = P.Name .. "\n[" .. dist .. "m]"; t.Visible = _G.Settings.PlayerESP and dist <= _G.Settings.ESPDistance
        end
    end)
end
Players.PlayerAdded:Connect(addESP)
for _, v in pairs(Players:GetPlayers()) do if v ~= Player then addESP(v) end end

print("LEMÖN HUB V40 Yüklendi! Menü görünmüyorsa tekrar çalıştırın.")
