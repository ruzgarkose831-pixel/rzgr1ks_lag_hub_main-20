local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- Temizlik
if Player.PlayerGui:FindFirstChild("LemonGalaxySupreme") then
    Player.PlayerGui.LemonGalaxySupreme:Destroy()
end

_G.Settings = {
    -- Karakter & Hareket
    ESP = false, ESPDist = 1500, GalaxyMode = false, GravityVal = 100,
    UnderArms = false, HiddenHead = false, SpeedBoost = false, SpeedVal = 75,
    JumpMod = false, JumpPower = 100, AntiRagdoll = false, SpinBot = false, SpinSpeed = 150,
    -- Combat & Server
    BatHitbox = false, BatSize = 45, SpamBat = false, ServerLag = false,
    InfJump = false, AutoWalk = false, Waypoints = {}
}

local gui = Instance.new("ScreenGui", Player.PlayerGui)
gui.Name = "LemonGalaxySupreme"
gui.ResetOnSpawn = false

-- ANA PANEL
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 540, 0, 420)
main.Position = UDim2.new(0.5, -270, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- UZAY ARKA PLANI
local bg = Instance.new("ImageLabel", main)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Image = "rbxassetid://13264663806"
bg.ScaleType = Enum.ScaleType.Crop
bg.Transparency = 0.5; bg.ZIndex = 0

-- RGB KENARLIK
local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2.5
RunService.RenderStepped:Connect(function() stroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)

-- BAŞLIKLAR
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5)
title.Text = "LEMÖN HUB DUELS PREMİÜM"
title.TextColor3 = Color3.fromRGB(255, 170, 0)
title.Font = "GothamBold"; title.TextSize = 15; title.BackgroundTransparency = 1; title.ZIndex = 2

local sub = Instance.new("TextLabel", main)
sub.Size = UDim2.new(1, 0, 0, 20)
sub.Position = UDim2.new(0, 0, 0, 22)
sub.Text = "discord.gg/lemonhub"; sub.TextColor3 = Color3.fromRGB(150, 150, 150)
sub.Font = "Gotham"; sub.TextSize = 10; sub.BackgroundTransparency = 1; sub.ZIndex = 2

-- İKİ SÜTUNLU SCROLL ALANI
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -60)
scroll.Position = UDim2.new(0, 5, 0, 55)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
scroll.CanvasSize = UDim2.new(0, 0, 0, 850)
scroll.ZIndex = 2

local leftCol = Instance.new("Frame", scroll)
leftCol.Size = UDim2.new(0.48, 0, 1, 0)
leftCol.BackgroundTransparency = 1
local lList = Instance.new("UIListLayout", leftCol); lList.Padding = UDim.new(0, 10)

local rightCol = Instance.new("Frame", scroll)
rightCol.Size = UDim2.new(0.48, 0, 1, 0)
rightCol.Position = UDim2.new(0.52, 0, 0, 0)
rightCol.BackgroundTransparency = 1
local rList = Instance.new("UIListLayout", rightCol); rList.Padding = UDim.new(0, 10)

-- MODERNIZE TOGGLE & SLIDER FONKSIYONLARI
local function AddToggle(parent, letter, text, key)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 35)
    f.BackgroundTransparency = 1
    
    local lBox = Instance.new("TextLabel", f)
    lBox.Size = UDim2.new(0, 18, 0, 18)
    lBox.Position = UDim2.new(0, 5, 0.5, -9)
    lBox.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
    lBox.Text = letter; lBox.TextColor3 = Color3.new(0,0,0)
    lBox.Font = "GothamBold"; lBox.TextSize = 11; Instance.new("UICorner", lBox)
    
    local txt = Instance.new("TextLabel", f)
    txt.Size = UDim2.new(1, -70, 1, 0)
    txt.Position = UDim2.new(0, 30, 0, 0)
    txt.Text = text; txt.TextColor3 = Color3.new(1,1,1)
    txt.Font = "GothamBold"; txt.TextSize = 11; txt.TextXAlignment = "Left"; txt.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 38, 0, 20)
    btn.Position = UDim2.new(1, -40, 0.5, -10)
    btn.Text = ""
    btn.BackgroundColor3 = _G.Settings[key] and Color3.fromRGB(255, 100, 0) or Color3.fromRGB(40,40,40)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame", btn)
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = _G.Settings[key] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    circle.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    btn.MouseButton1Click:Connect(function()
        _G.Settings[key] = not _G.Settings[key]
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = _G.Settings[key] and Color3.fromRGB(255, 100, 0) or Color3.fromRGB(40,40,40)}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = _G.Settings[key] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
    end)
end

local function AddSlider(parent, text, min, max, key)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 45)
    f.BackgroundTransparency = 1
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 0, 15); l.Text = text .. ": " .. _G.Settings[key]
    l.TextColor3 = Color3.fromRGB(180, 180, 180); l.BackgroundTransparency = 1; l.Font = "Gotham"; l.TextSize = 10; l.TextXAlignment = "Left"
    
    local bar = Instance.new("TextButton", f)
    bar.Size = UDim2.new(1, -10, 0, 14); bar.Position = UDim2.new(0, 5, 1, -20)
    bar.BackgroundColor3 = Color3.fromRGB(30, 30, 30); bar.Text = ""; Instance.new("UICorner", bar)
    
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((_G.Settings[key]-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 150, 0); Instance.new("UICorner", fill)
    
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

-- SOL SÜTUN İÇERİĞİ
AddToggle(leftCol, "G", "Player ESP", "ESP")
AddSlider(leftCol, "ESP Distance", 0, 2500, "ESPDist")
AddToggle(leftCol, "A", "Galaxy Mode", "GalaxyMode")
AddSlider(leftCol, "Gravity %", 0, 100, "GravityVal")
AddToggle(leftCol, "H", "Underground Arms", "UnderArms")
AddToggle(leftCol, "K", "Hidden Head", "HiddenHead")
AddToggle(leftCol, "N", "Hız Hilesi", "SpeedBoost")
AddSlider(leftCol, "Speed Value", 16, 500, "SpeedVal")
AddToggle(leftCol, "L", "Zıplama Gücü", "JumpMod")
AddSlider(leftCol, "Jump Value", 50, 300, "JumpPower")

-- SAĞ SÜTUN İÇERİĞİ
AddToggle(rightCol, "C", "God Bat Hitbox", "BatHitbox")
AddSlider(rightCol, "Reach Range", 5, 200, "BatSize")
AddToggle(rightCol, "", "Spam Bat (Auto Atk)", "SpamBat")
AddToggle(rightCol, "S", "SERVER LAG SPAM", "ServerLag")
AddToggle(rightCol, "R", "Anti-Ragdoll", "AntiRagdoll")
AddToggle(rightCol, "P", "Spin Bot (Mevlana)", "SpinBot")
AddSlider(rightCol, "Spin Speed", 50, 800, "SpinSpeed")
AddToggle(rightCol, "J", "Inf Jump", "InfJump")
AddToggle(rightCol, "U", "Auto Walk", "AutoWalk")

-- [[ GALAXY OMEGA ENGINE ]] --

-- Hız & Zıplama & Anti-Ragdoll (Heartbeat: Gecikmesiz)
RunService.Heartbeat:Connect(function()
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = _G.Settings.SpeedBoost and _G.Settings.SpeedVal or 16
        hum.JumpPower = _G.Settings.JumpMod and _G.Settings.JumpPower or 50
        if _G.Settings.AntiRagdoll then
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end
    end
end)

-- Mevlana (Physical Body Velocity)
RunService.RenderStepped:Connect(function()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local vel = root:FindFirstChild("LemonSpin") or Instance.new("BodyAngularVelocity", root)
        vel.Name = "LemonSpin"; vel.MaxTorque = Vector3.new(0, math.huge, 0)
        vel.AngularVelocity = _G.Settings.SpinBot and Vector3.new(0, _G.Settings.SpinSpeed, 0) or Vector3.new(0, 0, 0)
    end
end)

-- Inf Jump
UIS.JumpRequest:Connect(function()
    if _G.Settings.InfJump and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- God Hitbox & Galaxy Gravity
RunService.RenderStepped:Connect(function()
    workspace.Gravity = _G.Settings.GalaxyMode and (196.2 * (_G.Settings.GravityVal / 100)) or 196.2
    
    if _G.Settings.BatHitbox and Player.Character and Player.Character:FindFirstChildOfClass("Tool") then
        local r = Player.Character:FindFirstChild("GodReach") or Instance.new("Part", Player.Character)
        r.Name = "GodReach"; r.Transparency = 1; r.CanCollide = false
        r.Size = Vector3.new(_G.Settings.BatSize, _G.Settings.BatSize, _G.Settings.BatSize)
        r.CFrame = Player.Character.HumanoidRootPart.CFrame
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                firetouchinterest(r, v.Character.HumanoidRootPart, 0)
                firetouchinterest(r, v.Character.HumanoidRootPart, 1)
            end
        end
    end
end)

-- Lag Spammer
task.spawn(function()
    while task.wait(0.1) do
        if _G.Settings.ServerLag then
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("RemoteEvent") then pcall(function() v:FireServer(string.rep("LAG", 500)) end) end
            end
        end
    end
end)

-- Animasyonlu Açılış
main.Size = UDim2.new(0,0,0,0)
TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 540, 0, 420)}):Play()

print("LEMON HUB V44 SUPREME - GÖRÜNÜR VE AKTİF!")
