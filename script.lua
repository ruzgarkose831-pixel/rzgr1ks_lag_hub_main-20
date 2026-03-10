local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- Ayarlar (Hiçbir özellik silinmedi)
_G.Settings = {
    PlayerHB = false, PlayerHBSize = 25,
    BatHitbox = true, BatSize = 45, 
    PlayerESP = false, ESPDistance = 500,
    UnderArms = false, HiddenHead = false,
    ServerLag = false,
    Speed = true, SpeedVal = 75,
    JumpPower = 80,
    AutoWalkGo = false, AutoWalkStop = false,
    Spin = false, SpinSpeed = 200,
    AutoAttack = false,
    Waypoints = {}
}

-- Önceki GUI'yi temizle
if Player.PlayerGui:FindFirstChild("LemonHubPremiumGui") then
    Player.PlayerGui.LemonHubPremiumGui:Destroy()
end

local gui = Instance.new("ScreenGui", Player.PlayerGui)
gui.Name = "LemonHubPremiumGui"
gui.ResetOnSpawn = false

-- Ana Panel (Görünürlük garantili ayarlar)
local main = Instance.new("Frame", gui)
main.Name = "MainFrame"
main.Size = UDim2.new(0, 320, 0, 450)
main.Position = UDim2.new(0.5, -160, 0.5, -225)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true -- Menüyü sürükleyebilirsin
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- Kenarlık Efekti (RGB)
local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2
RunService.RenderStepped:Connect(function() 
    stroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) 
end)

-- Başlık
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "  LEMÖN HUB PREMİÜM"
title.TextColor3 = Color3.fromRGB(255, 170, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1

-- Küçültme Tuşu (_)
local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -40, 0, 5)
minBtn.Text = "_"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.BackgroundTransparency = 1
minBtn.TextSize = 20

-- Küçülmüş Haldeki Limon İkonu
local sideIcon = Instance.new("TextButton", gui)
sideIcon.Size = UDim2.new(0, 60, 0, 60)
sideIcon.Position = UDim2.new(0.9, 0, 0.5, 0)
sideIcon.Text = "🍋"
sideIcon.TextSize = 30
sideIcon.Visible = false
sideIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", sideIcon).CornerRadius = UDim.new(1, 0)
local sStroke = Instance.new("UIStroke", sideIcon); sStroke.Thickness = 2
RunService.RenderStepped:Connect(function() sStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)

-- Küçültme Fonksiyonu
minBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    sideIcon.Visible = true
end)
sideIcon.MouseButton1Click:Connect(function()
    main.Visible = true
    sideIcon.Visible = false
end)

-- Kaydırma Alanı
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -50)
scroll.Position = UDim2.new(0, 5, 0, 45)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.CanvasSize = UDim2.new(0, 0, 0, 1100)
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = "Center"

-- Fonksiyonlar (Toggle & Slider)
local function AddToggle(text, key)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.TextXAlignment = "Left"
    Instance.new("UICorner", btn)
    
    local status = Instance.new("Frame", btn)
    status.Size = UDim2.new(0, 10, 0, 10)
    status.Position = UDim2.new(1, -25, 0.5, -5)
    Instance.new("UICorner", status).CornerRadius = UDim.new(1,0)
    
    btn.MouseButton1Click:Connect(function()
        _G.Settings[key] = not _G.Settings[key]
    end)
    
    RunService.RenderStepped:Connect(function()
        status.BackgroundColor3 = _G.Settings[key] and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    end)
end

local function AddSlider(text, min, max, key)
    local frame = Instance.new("Frame", scroll)
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. _G.Settings[key]
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold; label.TextSize = 11; label.TextXAlignment = "Left"
    
    local bar = Instance.new("TextButton", frame)
    bar.Size = UDim2.new(1, 0, 0, 15) -- KALIN SLIDER
    bar.Position = UDim2.new(0, 0, 1, -20)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    bar.Text = ""
    Instance.new("UICorner", bar)
    
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((_G.Settings[key]-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 145, 0)
    Instance.new("UICorner", fill)
    
    bar.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local p = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                _G.Settings[key] = math.floor(min + (max - min) * p)
                label.Text = text .. ": " .. _G.Settings[key]
                fill.Size = UDim2.new(p, 0, 1, 0)
            end
        end)
        UIS.InputEnded:Once(function() move:Disconnect() end)
    end)
end

-- Menü İçeriği
AddToggle("GELİŞMİŞ BAT HİTBOX", "BatHitbox")
AddSlider("Sopa Menzili", 5, 500, "BatSize")
AddToggle("Karakter Hitbox", "PlayerHB")
AddSlider("Hitbox Boyutu", 2, 120, "PlayerHBSize")
AddToggle("Player ESP", "PlayerESP")
AddToggle("Kolları Gizle", "UnderArms")
AddToggle("Kafayı Gizle", "HiddenHead")
AddToggle("Hız Hilesi", "Speed")
AddSlider("Hız Ayarı", 16, 500, "SpeedVal")
AddToggle("Spin Bot", "Spin")
AddToggle("Auto Attack", "AutoAttack")

--[[ LOGIC MOTORU (Aynı güçte devam) ]]--
RunService.RenderStepped:Connect(function()
    local char = Player.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if _G.Settings.BatHitbox and root then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local rp = char:FindFirstChild("AdvReach") or Instance.new("Part", char)
            rp.Name = "AdvReach"; rp.Anchored = false; rp.Massless = true; rp.Transparency = 1; rp.CanCollide = false
            if not rp:FindFirstChild("Weld") then
                local w = Instance.new("Weld", rp); w.Part0 = root; w.Part1 = rp
            end
            for _, p in pairs(tool:GetDescendants()) do
                if p:IsA("BasePart") then p.Size = Vector3.new(_G.Settings.BatSize, _G.Settings.BatSize, _G.Settings.BatSize); p.Transparency = 0.8; p.CanCollide = false end
            end
            for _, enemy in pairs(Players:GetPlayers()) do
                if enemy ~= Player and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
                    firetouchinterest(rp, enemy.Character.HumanoidRootPart, 0)
                    firetouchinterest(rp, enemy.Character.HumanoidRootPart, 1)
                end
            end
        end
    end

    if hum and root then
        if _G.Settings.Speed then hum.WalkSpeed = _G.Settings.SpeedVal end
        if _G.Settings.UnderArms then
            local rs = char:FindFirstChild("RightShoulder",true); if rs then rs.C0 = CFrame.new(1,-6,0)*CFrame.Angles(math.pi,0,0) end
        end
        if _G.Settings.Spin then
            root.Velocity = Vector3.new(0,0,0)
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(_G.Settings.SpinSpeed/10), 0)
        end
        if _G.Settings.AutoAttack then local t = char:FindFirstChildOfClass("Tool"); if t then t:Activate() end end
    end
end)

print("Lemon Hub Fixed Loaded!")
