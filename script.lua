--[[
    rzgr1ks DUEL HUB - V90 (THE MASTERPIECE)
    - Scrollable UI: Tüm özellikler eklendi, aşağı kaydırılabilir modern menü.
    - Limitli Değerler: Speed(30-50), Jump(60-80), Gravity(100-70).
    - Full Özellikler: Hitbox, ESP, Server Lag, Anti-Ragdoll, Anti-Die.
    - 4-Point Auto Walk: Görsel destekli 4 farklı checkpoint sistemi.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- 1. TÜM AYARLAR VE LİMİTLER
_G.Set = {
    Speed = 30, 
    Jump = 60, 
    Gravity = 100,
    HB_Toggle = false, 
    HB_Size = 25,
    ESP = false,
    Lag = false,
    AntiRag = true,
    AntiDie = true
}

local Points = {nil, nil, nil, nil}
local Visuals = {nil, nil, nil, nil}
local SelectedSlot = 1
local IsWalking = false
local PointColors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,1,0)}

-- Görsel İşaretçi (Checkpoint Küreleri)
local function UpdatePointVisual(pos, index)
    if Visuals[index] then Visuals[index]:Destroy() end
    local p = Instance.new("Part", workspace)
    p.Size = Vector3.new(3, 3, 3); p.Position = pos; p.Anchored = true; p.CanCollide = false
    p.Shape = Enum.PartType.Ball; p.Material = Enum.Material.Neon; p.Color = PointColors[index]; p.Transparency = 0.4
    local bg = Instance.new("BillboardGui", p); bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 80, 0, 40)
    local tl = Instance.new("TextLabel", bg); tl.Text = "POINT "..index; tl.TextColor3 = PointColors[index]; tl.BackgroundTransparency = 1; tl.Size = UDim2.new(1,0,1,0); tl.Font = "GothamBold"
    Visuals[index] = p
end

-- 2. RGB NEON UI & SCROLLING FRAME
if CoreGui:FindFirstChild("rzg_v90") then CoreGui.rzg_v90:Destroy() end
local sg = Instance.new("ScreenGui", CoreGui); sg.Name = "rzg_v90"

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 320, 0, 450) -- Ekranı kaplamasın diye boyutu sabitledim
Main.Position = UDim2.new(0.5, -160, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local RGBStroke = Instance.new("UIStroke", Main); RGBStroke.Thickness = 3

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "rzgr1ks MASTERPIECE V90"
Title.TextColor3 = Color3.new(1, 1, 1); Title.Font = "GothamBold"; Title.TextSize = 15; Title.BackgroundTransparency = 1

-- KAYDIRILABİLİR ALAN (SCROLLING FRAME)
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -50); Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 750) -- İçerik uzadıkça kaydırma alanı

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 8); Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- MOBİL MENÜ BUTONU
local MenuBtn = Instance.new("TextButton", sg)
MenuBtn.Size = UDim2.new(0, 55, 0, 55); MenuBtn.Position = UDim2.new(1, -70, 0.5, -27)
MenuBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MenuBtn.Text = "HUB"; MenuBtn.TextColor3 = Color3.new(1,1,1); MenuBtn.Font = "GothamBold"
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1,0); local MStroke = Instance.new("UIStroke", MenuBtn); MStroke.Thickness = 2
MenuBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- 3. BUTON OLUŞTURUCULAR
local function AddBtn(txt, color, func)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 40); b.BackgroundColor3 = color; b.Text = txt; b.TextColor3 = Color3.new(1,1,1)
    b.Font = "GothamBold"; b.TextSize = 13; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.Parent = Scroll
    b.MouseButton1Click:Connect(func)
    return b
end

local function AddToggle(name, key)
    local t = Instance.new("TextButton")
    t.Size = UDim2.new(1, -10, 0, 35); t.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    t.Text = name .. ": " .. (_G.Set[key] and "ON" or "OFF"); t.TextColor3 = Color3.new(1,1,1)
    t.Font = "GothamSemibold"; t.TextSize = 13; Instance.new("UICorner", t).CornerRadius = UDim.new(0, 8)
    t.Parent = Scroll
    t.MouseButton1Click:Connect(function()
        _G.Set[key] = not _G.Set[key]
        t.Text = name .. ": " .. (_G.Set[key] and "ON" or "OFF")
    end)
    return t
end

-- UI ELEMENTLERİNİ EKLEME
-- Sınırlandırılmış Fizik Ayarları
local speedBtn = AddBtn("SPEED: 30", Color3.fromRGB(40, 40, 40), function()
    _G.Set.Speed = (_G.Set.Speed >= 50) and 30 or _G.Set.Speed + 5
end)

local jumpBtn = AddBtn("JUMP: 60", Color3.fromRGB(40, 40, 40), function()
    _G.Set.Jump = (_G.Set.Jump >= 80) and 60 or _G.Set.Jump + 5
end)

local gravBtn = AddBtn("GRAVITY: 100", Color3.fromRGB(40, 40, 40), function()
    _G.Set.Gravity = (_G.Set.Gravity <= 70) and 100 or _G.Set.Gravity - 10
end)

-- Özellik Toggles (Hepsi Burada)
AddToggle("Hitbox Expander", "HB_Toggle")
AddToggle("Player ESP", "ESP")
AddToggle("Server Lag", "Lag")
AddToggle("Anti-Ragdoll", "AntiRag")
AddToggle("Anti-Die", "AntiDie")

-- 4'lü Checkpoint Sistemi
local slotBtn = AddBtn("SELECT POINT: 1", Color3.fromRGB(60, 50, 0), function()
    SelectedSlot = (SelectedSlot % 4) + 1
    slotBtn.Text = "SELECT POINT: " .. SelectedSlot
end)

AddBtn("SAVE THIS POSITION", Color3.fromRGB(0, 70, 120), function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local pos = player.Character.HumanoidRootPart.Position
        Points[SelectedSlot] = pos
        UpdatePointVisual(pos, SelectedSlot)
    end
end)

AddBtn("AUTO WALK TO SELECTED", Color3.fromRGB(0, 100, 0), function()
    local target = Points[SelectedSlot]
    if not target or IsWalking then return end
    IsWalking = true
    spawn(function()
        while IsWalking and target and player.Character do
            player.Character.Humanoid:MoveTo(target)
            if (player.Character.HumanoidRootPart.Position - target).Magnitude < 4 then break end
            task.wait(0.1)
        end
        IsWalking = false
    end)
end)

AddBtn("STOP WALKING", Color3.fromRGB(120, 0, 0), function() IsWalking = false end)

-- 4. RGB & ANA DÖNGÜ (FİZİK, ESP, HITBOX)
spawn(function()
    while task.wait() do
        local c = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        RGBStroke.Color = c; MStroke.Color = c
    end
end)

RunService.Heartbeat:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    
    if hum then
        speedBtn.Text = "SPEED: ".._G.Set.Speed
        jumpBtn.Text = "JUMP: ".._G.Set.Jump
        gravBtn.Text = "GRAVITY: ".._G.Set.Gravity
        
        -- Fizik Uygulamaları
        if not IsWalking then hum.WalkSpeed = _G.Set.Speed end
        hum.JumpPower = _G.Set.Jump
        workspace.Gravity = _G.Set.Gravity
        
        if _G.Set.AntiDie then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            if hum.Health <= 0 then hum.Health = 100 end
        end
        if _G.Set.AntiRag then hum.PlatformStand = false end
    end

    -- Server Lag
    if _G.Set.Lag and char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0.0001, 0)
    end

    -- Hitbox & ESP Logic
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = v.Character.HumanoidRootPart
            
            -- Hitbox
            if _G.Set.HB_Toggle then
                hrp.Size = Vector3.new(_G.Set.HB_Size, _G.Set.HB_Size, _G.Set.HB_Size)
                hrp.Transparency = 0.7; hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1
            end
            
            -- ESP (Highlight)
            if _G.Set.ESP then
                if not v.Character:FindFirstChild("ESP_High") then
                    local h = Instance.new("Highlight", v.Character)
                    h.Name = "ESP_High"; h.FillColor = Color3.new(1,0,0); h.OutlineColor = Color3.new(1,1,1)
                end
            else
                if v.Character:FindFirstChild("ESP_High") then v.Character.ESP_High:Destroy() end
            end
        end
    end
end)
