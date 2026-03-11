local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- Önceki GUI'yi temizle
if Player.PlayerGui:FindFirstChild("LemonHubReborn") then
    Player.PlayerGui.LemonHubReborn:Destroy()
end

_G.Settings = {
    BatHitbox = false, BatSize = 45, SpamBat = false,
    PlayerHB = false, PlayerHBSize = 25,
    ESP = false, ESPDist = 1000,
    SpeedBoost = false, SpeedVal = 75,
    JumpMod = false, JumpPower = 100,
    InfJump = false, AntiRagdoll = false,
    SpinBot = false, SpinSpeed = 200,
    GalaxyMode = false, GravityVal = 100,
    ServerLag = false, UnderArms = false, HiddenHead = false,
    AutoWalk = false, Waypoints = {}
}

local gui = Instance.new("ScreenGui", Player.PlayerGui)
gui.Name = "LemonHubReborn"
gui.ResetOnSpawn = false

-- ANA PANEL (Görünürlüğü Garantili Klasik Stil)
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 520, 0, 480)
main.Position = UDim2.new(0.5, -260, 0.5, -240)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

-- RGB KENARLIK
local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2
RunService.RenderStepped:Connect(function() stroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)

-- BAŞLIK
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "  LEMÖN HUB DUELS PREMİÜM"
title.TextColor3 = Color3.fromRGB(255, 160, 0)
title.Font = Enum.Font.GothamBold; title.TextSize = 16
title.BackgroundTransparency = 1; title.TextXAlignment = "Left"

-- KAYDIRMA ALANI (Tüm butonların toplandığı yer)
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 1100) -- Uzunluk garantisi
scroll.ScrollBarThickness = 3
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 10)

-- YARDIMCI FONKSİYONLAR (Fotoğraftaki Stil)
local function AddToggle(text, letter, key)
    local f = Instance.new("Frame", scroll)
    f.Size = UDim2.new(1, -10, 0, 40)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", f)
    
    if letter ~= "" then
        local lBox = Instance.new("TextLabel", f)
        lBox.Size = UDim2.new(0, 20, 0, 20)
        lBox.Position = UDim2.new(0, 10, 0.5, -10)
        lBox.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
        lBox.Text = letter; lBox.TextColor3 = Color3.new(0,0,0)
        lBox.Font = "GothamBold"; lBox.TextSize = 12
        Instance.new("UICorner", lBox)
    end
    
    local txt = Instance.new("TextLabel", f)
    txt.Size = UDim2.new(1, -100, 1, 0)
    txt.Position = UDim2.new(0, 40, 0, 0)
    txt.Text = text; txt.TextColor3 = Color3.new(1,1,1)
    txt.Font = "GothamBold"; txt.TextSize = 13; txt.TextXAlignment = "Left"; txt.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 45, 0, 22)
    btn.Position = UDim2.new(1, -55, 0.5, -11)
    btn.BackgroundColor3 = _G.Settings[key] and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    btn.MouseButton1Click:Connect(function()
        _G.Settings[key] = not _G.Settings[key]
        btn.BackgroundColor3 = _G.Settings[key] and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    end)
end

local function AddSlider(text, min, max, key)
    local f = Instance.new("Frame", scroll)
    f.Size = UDim2.new(1, -10, 0, 50)
    f.BackgroundTransparency = 1
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 0, 20); l.Text = text .. ": " .. _G.Settings[key]
    l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Font = "GothamBold"; l.TextSize = 11; l.TextXAlignment = "Left"
    
    local bar = Instance.new("TextButton", f)
    bar.Size = UDim2.new(1, 0, 0, 15); bar.Position = UDim2.new(0, 0, 1, -20)
    bar.BackgroundColor3 = Color3.fromRGB(40,40,40); bar.Text = ""; Instance.new("UICorner", bar)
    
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

-- ÖZELLİKLERİ SIRAYLA EKLE (Artık kaybolmazlar)
AddToggle("Player ESP", "G", "ESP")
AddSlider("ESP Mesafesi", 0, 3000, "ESPDist")
AddToggle("Bat Hitbox (God)", "C", "BatHitbox")
AddSlider("Hitbox Menzili", 5, 200, "BatSize")
AddToggle("Auto Clicker", "", "SpamBat")
AddToggle("Hız Hilesi", "N", "SpeedBoost")
AddSlider("Hız Değeri", 16, 500, "SpeedVal")
AddToggle("Zıplama Hilesi", "L", "JumpMod")
AddSlider("Zıplama Gücü", 50, 400, "JumpPower")
AddToggle("Spin Bot (Mevlana)", "P", "SpinBot")
AddSlider("Dönme Hızı", 50, 1000, "SpinSpeed")
AddToggle("Anti Ragdoll", "R", "AntiRagdoll")
AddToggle("Sınırsız Zıplama", "J", "InfJump")
AddToggle("Galaxy Mode (Yer Çekimi)", "A", "GalaxyMode")
AddSlider("Yer Çekimi %", 0, 100, "GravityVal")
AddToggle("Server Lag Spammer", "S", "ServerLag")
AddToggle("Kolları Gizle", "H", "UnderArms")
AddToggle("Kafayı Gizle", "K", "HiddenHead")
AddToggle("Auto Walk", "U", "AutoWalk")

-- [[ LOGIC MOTORLARI ]] --
RunService.Heartbeat:Connect(function()
    local char = Player.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if _G.Settings.SpeedBoost then hum.WalkSpeed = _G.Settings.SpeedVal end
        if _G.Settings.JumpMod then hum.JumpPower = _G.Settings.JumpPower end
        if _G.Settings.AntiRagdoll then
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local char = Player.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    
    -- SPIN
    if root then
        local s = root:FindFirstChild("OmegaSpin") or Instance.new("BodyAngularVelocity", root)
        s.Name = "OmegaSpin"; s.MaxTorque = Vector3.new(0, math.huge, 0)
        s.AngularVelocity = _G.Settings.SpinBot and Vector3.new(0, _G.Settings.SpinSpeed, 0) or Vector3.new(0, 0, 0)
    end
    
    -- GALAXY (GRAVITY)
    workspace.Gravity = _G.Settings.GalaxyMode and (196.2 * (_G.Settings.GravityVal / 100)) or 196.2

    -- BAT HITBOX
    if _G.Settings.BatHitbox and char:FindFirstChildOfClass("Tool") then
        local r = char:FindFirstChild("ReachPart") or Instance.new("Part", char)
        r.Name = "ReachPart"; r.Transparency = 1; r.CanCollide = false; r.Size = Vector3.new(_G.Settings.BatSize, _G.Settings.BatSize, _G.Settings.BatSize)
        if not r:FindFirstChild("Weld") then
            local w = Instance.new("Weld", r); w.Part0 = root; w.Part1 = r
        end
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                firetouchinterest(r, v.Character.HumanoidRootPart, 0)
                firetouchinterest(r, v.Character.HumanoidRootPart, 1)
            end
        end
    end
end)

-- LAG SPAMMER
task.spawn(function()
    while task.wait(0.1) do
        if _G.Settings.ServerLag then
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("RemoteEvent") then pcall(function() v:FireServer(string.rep("LAG", 500)) end) end
            end
        end
    end
end)

print("LEMON HUB V43 REBORN LOADED! Butonlar artık sabit ve görünür.")
