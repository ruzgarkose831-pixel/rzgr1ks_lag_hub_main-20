--[[ 
    LEMÖN HUB DUELS PREMİÜM (rzgr1ks V38 "ULTIMATE ANIMATED" Edition)
    Extreme GUI Overhaul: TweenService animations, iOS style toggles, smooth sliders.
    All previous features and God-Hitbox bypasses are retained.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

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

-- Tween Info Presets
local fastTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bounceTween = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
local backTween = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)

-- UI Construction
local gui = Instance.new("ScreenGui", Player.PlayerGui)
gui.Name = "LemonHubPremiumGui"
gui.ResetOnSpawn = false

-- Icon (Minimized State)
local sideIcon = Instance.new("TextButton", gui)
sideIcon.Size = UDim2.new(0, 0, 0, 0) -- Starts at 0, animates in later
sideIcon.Position = UDim2.new(0.95, -30, 0.3, -30)
sideIcon.Text = "🍋"
sideIcon.TextSize = 25
sideIcon.Visible = false
sideIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
sideIcon.AutoButtonColor = false
Instance.new("UICorner", sideIcon).CornerRadius = UDim.new(0, 15)
local sideStroke = Instance.new("UIStroke", sideIcon)
sideStroke.Thickness = 2.5
RunService.RenderStepped:Connect(function() sideStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)

-- Main Frame
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 340, 0, 500)
main.Position = UDim2.new(0.5, -170, 0.5, -250)
main.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local bg = Instance.new("ImageLabel", main)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Image = "rbxassetid://13264663806" 
bg.ScaleType = Enum.ScaleType.Crop
bg.Transparency = 0.5
bg.ZIndex = -1

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Thickness = 2
RunService.RenderStepped:Connect(function() mainStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)

-- Header Area
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "LEMÖN HUB DUELS PREMİÜM"
title.TextColor3 = Color3.fromRGB(255, 180, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left

-- Controls (Minimize / Close)
local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -70, 0.5, -15)
minBtn.Text = "—"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.BackgroundTransparency = 1
minBtn.Font = Enum.Font.GothamBold

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold

-- Animations for Minimize/Close
minBtn.MouseButton1Click:Connect(function()
    TweenService:Create(main, backTween, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.95, 0, 0.3, 0)}):Play()
    task.wait(0.4)
    main.Visible = false
    sideIcon.Visible = true
    TweenService:Create(sideIcon, bounceTween, {Size = UDim2.new(0, 60, 0, 60)}):Play()
end)

sideIcon.MouseButton1Click:Connect(function()
    TweenService:Create(sideIcon, fastTween, {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.2)
    sideIcon.Visible = false
    main.Visible = true
    TweenService:Create(main, bounceTween, {Size = UDim2.new(0, 340, 0, 500), Position = UDim2.new(0.5, -170, 0.5, -250)}):Play()
end)

closeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(main, backTween, {Size = UDim2.new(0,0,0,0)}):Play()
    task.wait(0.4); gui:Destroy()
end)

-- Scroll Frame
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -50)
scroll.Position = UDim2.new(0, 5, 0, 45)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 120, 0)
scroll.CanvasSize = UDim2.new(0, 0, 0, 1400)
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Helper: Animated Section
local function AddSection(txt)
    local l = Instance.new("TextLabel", scroll)
    l.Size = UDim2.new(1, -20, 0, 25)
    l.Text = "  " .. txt
    l.TextColor3 = Color3.new(1,1,1)
    l.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    l.BackgroundTransparency = 0.4
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", l).CornerRadius = UDim.new(0, 6)
    return l
end

-- Helper: Animated iOS Toggle
local function AddToggle(txt, key)
    local f = Instance.new("Frame", scroll)
    f.Size = UDim2.new(1, -20, 0, 35)
    f.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    f.BackgroundTransparency = 0.5
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -60, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.Text = txt
    l.TextColor3 = Color3.new(1,1,1)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamSemibold
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -50, 0.5, -10)
    btn.Text = ""
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame", btn)
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local function updateVisuals()
        local on = _G.Settings[key]
        TweenService:Create(btn, fastTween, {BackgroundColor3 = on and Color3.fromRGB(255, 120, 0) or Color3.fromRGB(40, 40, 40)}):Play()
        TweenService:Create(circle, fastTween, {Position = on and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
    end
    
    btn.MouseButton1Click:Connect(function()
        _G.Settings[key] = not _G.Settings[key]
        updateVisuals()
    end)
    updateVisuals()
end

-- Helper: Animated Thick Slider
local function AddSlider(txt, min, max, key)
    local f = Instance.new("Frame", scroll)
    f.Size = UDim2.new(1, -20, 0, 55)
    f.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    f.BackgroundTransparency = 0.5
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -10, 0, 20)
    l.Position = UDim2.new(0, 10, 0, 5)
    l.Text = txt .. ": " .. _G.Settings[key]
    l.TextColor3 = Color3.new(1,1,1)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamSemibold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    
    local bar = Instance.new("TextButton", f)
    bar.Size = UDim2.new(1, -20, 0, 16)
    bar.Position = UDim2.new(0, 10, 1, -22)
    bar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    bar.Text = ""
    bar.AutoButtonColor = false
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((_G.Settings[key]-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local grad = Instance.new("UIGradient", fill)
    grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 0))}
    
    local function update(input)
        local p = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        _G.Settings[key] = math.floor(min + (max - min) * p)
        l.Text = txt .. ": " .. _G.Settings[key]
        TweenService:Create(fill, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(p, 0, 1, 0)}):Play()
    end
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            update(input)
            local move; move = UIS.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then update(i) end
            end)
            UIS.InputEnded:Once(function() move:Disconnect() end)
        end
    end)
end

-- POPULATING MENU
AddSection("HİTBOX & COMBAT")
AddToggle("GELIŞMIŞ BAT HİTBOX (God Mode)", "BatHitbox")
AddSlider("Sopa Menzili (Radius)", 5, 500, "BatSize")
AddToggle("Player Hitbox Büyüt", "PlayerHB")
AddSlider("Player HB Boyutu", 2, 120, "PlayerHBSize")
AddToggle("Auto Attack", "AutoAttack")

AddSection("GÖRSELLİK & ESP")
AddToggle("Player ESP", "PlayerESP")
AddSlider("ESP Mesafesi", 0, 2000, "ESPDistance")
AddToggle("Server Lag (Görsel)", "ServerLag")

AddSection("KARAKTER & BODY MODS")
AddToggle("Kolları Gizle (UnderArms)", "UnderArms")
AddToggle("Kafayı Gizle", "HiddenHead")
AddToggle("Mevlana (Spin Bot)", "Spin")
AddSlider("Dönme Hızı", 10, 600, "SpinSpeed")

AddSection("HAREKET")
AddToggle("Hız Hilesi Aktif", "Speed")
AddSlider("Hız (Speed)", 16, 600, "SpeedVal")
AddSlider("Zıplama (Jump Power)", 50, 300, "JumpPower")

AddSection("OTOMATİK YÜRÜYÜŞ")
local awFrame = Instance.new("Frame", scroll)
awFrame.Size = UDim2.new(1, -20, 0, 40)
awFrame.BackgroundTransparency = 1
local addP = Instance.new("TextButton", awFrame); addP.Size = UDim2.new(0.3, 0, 1, 0); addP.Position = UDim2.new(0, 0, 0, 0); addP.Text = "Nokta Ekle"; addP.BackgroundColor3 = Color3.fromRGB(40,40,40); addP.TextColor3 = Color3.new(1,1,1); addP.Font = Enum.Font.GothamBold; addP.TextSize=10; Instance.new("UICorner", addP)
local startP = Instance.new("TextButton", awFrame); startP.Size = UDim2.new(0.3, 0, 1, 0); startP.Position = UDim2.new(0.35, 0, 0, 0); startP.Text = "Başla"; startP.BackgroundColor3 = Color3.fromRGB(0,150,0); startP.TextColor3 = Color3.new(1,1,1); startP.Font = Enum.Font.GothamBold; startP.TextSize=10; Instance.new("UICorner", startP)
local stopP = Instance.new("TextButton", awFrame); stopP.Size = UDim2.new(0.3, 0, 1, 0); stopP.Position = UDim2.new(0.7, 0, 0, 0); stopP.Text = "Durdur"; stopP.BackgroundColor3 = Color3.fromRGB(150,0,0); stopP.TextColor3 = Color3.new(1,1,1); stopP.Font = Enum.Font.GothamBold; stopP.TextSize=10; Instance.new("UICorner", stopP)

addP.MouseButton1Click:Connect(function() table.insert(_G.Settings.Waypoints, Player.Character.HumanoidRootPart.Position) end)
startP.MouseButton1Click:Connect(function() _G.Settings.AutoWalkGo = true end)
stopP.MouseButton1Click:Connect(function() _G.Settings.AutoWalkGo = false; _G.Settings.Waypoints = {} end)


-- ENGINES (Hitbox, ESP, Logic)
-- ESP Engine
local function drawESP(P)
    local B = P.Character; if not B then return end; local H = B:FindFirstChild("HumanoidRootPart"); if not H then return end
    local L = H:FindFirstChild("LemonESP") or Instance.new("BillboardGui", H); L.Name = "LemonESP"; L.Size = UDim2.new(0, 100, 0, 50); L.StudsOffset = Vector3.new(0, 3, 0); L.AlwaysOnTop = true
    local T = L:FindFirstChild("Text") or Instance.new("TextLabel", L); T.Name = "Text"; T.Size = UDim2.new(1, 0, 1, 0); T.TextColor3 = Color3.new(1, 1, 1); T.BackgroundTransparency = 1; T.Font = Enum.Font.GothamBold; T.TextSize = 10; T.TextXAlignment = 0; T.TextYAlignment = 0
    RunService.RenderStepped:Connect(function() 
        T.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1); 
        local D = math.floor((Player.Character.HumanoidRootPart.Position - H.Position).Magnitude)
        T.Text = P.Name .. "\n[" .. D .. "m]"
        T.Visible = _G.Settings.PlayerESP and D <= _G.Settings.ESPDistance
    end)
end
Players.PlayerAdded:Connect(drawESP); for _, P in pairs(Players:GetPlayers()) do if P ~= Player then drawESP(P) end end

-- AutoWalk Logic
task.spawn(function()
    while task.wait(0.2) do
        if _G.Settings.AutoWalkGo and #_G.Settings.Waypoints > 0 and Player.Character then
            local hum = Player.Character:FindFirstChild("Humanoid"); local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                for _, P in pairs(_G.Settings.Waypoints) do
                    if not _G.Settings.AutoWalkGo then break end
                    hum:MoveTo(P); task.wait(0.1)
                    local D; repeat D = (hrp.Position - P).Magnitude; task.wait(0.05) until D < 6 or not _G.Settings.AutoWalkGo or hum.Health <= 0
                end
            end
        end
    end
end)

-- Main Combat & Movement Loop
RunService.RenderStepped:Connect(function()
    local char = Player.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart")
    
    -- GOD BAT HITBOX (Bypass Methods Included)
    if _G.Settings.BatHitbox and hum and root then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local reachPart = char:FindFirstChild("AdvancedReachPart")
            if not reachPart then
                reachPart = Instance.new("Part", char); reachPart.Name = "AdvancedReachPart"; reachPart.Anchored = false; reachPart.Massless = true; reachPart.Transparency = 1; reachPart.CanCollide = false
                local reachWeld = Instance.new("Weld", reachPart); reachWeld.Part0 = root; reachWeld.Part1 = reachPart; reachWeld.C1 = CFrame.new(0, 0, 0)
            end
            
            for _, p in pairs(tool:GetDescendants()) do
                if p:IsA("BasePart") then p.Size = Vector3.new(_G.Settings.BatSize, _G.Settings.BatSize, _G.Settings.BatSize); p.Transparency = 0.8; p.CanCollide = false; p.Massless = true end
            end
            
            for _, enemy in pairs(Players:GetPlayers()) do
                if enemy ~= Player and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
                    local enemyRoot = enemy.Character.HumanoidRootPart
                    firetouchinterest(reachPart, enemyRoot, 0); firetouchinterest(reachPart, enemyRoot, 1)
                    reachPart.Velocity = (enemyRoot.Position - reachPart.Position).Unit * 100
                end
            end
        else
            local rp = char:FindFirstChild("AdvancedReachPart"); if rp then rp:Destroy() end
        end
    end

    -- CLASSIC PLAYER HITBOX
    if _G.Settings.PlayerHB then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local eRoot = v.Character.HumanoidRootPart
                eRoot.Size = Vector3.new(_G.Settings.PlayerHBSize, _G.Settings.PlayerHBSize, _G.Settings.PlayerHBSize); eRoot.Transparency = 0.7; eRoot.CanCollide = false
            end
        end
    end

    -- MOVEMENT & BODY MODS
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
        
        hum.AutoRotate = not _G.Settings.Spin
        local sv = root:FindFirstChild("SpinV") or Instance.new("BodyAngularVelocity", root)
        sv.Name = "SpinV"; sv.MaxTorque = Vector3.new(0, math.huge, 0)
        sv.AngularVelocity = _G.Settings.Spin and Vector3.new(0, _G.Settings.SpinSpeed, 0) or Vector3.new(0,0,0)
        
        if _G.Settings.AutoAttack then local t = char:FindFirstChildOfClass("Tool"); if t then t:Activate() end end
    end
end)
end)
