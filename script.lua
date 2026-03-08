--[[
    rzgr1ks DUEL HUB - V87 (NEON & MODERN RGB UI)
    - Tasarım: Modern, şeffaf, RGB kenarlıklı ve yüksek okunurluklu.
    - 4 Nokta Sistemi: Görsel küreler ve kolay seçim.
    - Fixler: Hız, Zıplama ve Lag sistemleri en stabil hallerinde.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- 1. AYARLAR VE DEĞERLER
_G.Set = {Speed = 16, Jump = 50, HB = false, Lag = false, ESP = false}
local Points = {nil, nil, nil, nil}
local Visuals = {}
local CurrentPoint = 1
local IsWalking = false

-- 2. MODERN UI KURULUMU
if game:GetService("CoreGui"):FindFirstChild("rzg_neon_v87") then game:GetService("CoreGui").rzg_neon_v87:Destroy() end
local sg = Instance.new("ScreenGui", game:GetService("CoreGui")); sg.Name = "rzg_neon_v87"

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 320, 0, 620)
Main.Position = UDim2.new(0.5, -160, 0.5, -310)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BackgroundTransparency = 0.1
Main.Active = true
Main.Draggable = true

local Stroke = Instance.new("UIStroke", Main)
Stroke.Thickness = 2.5
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "rzgr1ks DUEL HUB V87"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1

-- MOBİL MENÜ BUTONU
local OpenBtn = Instance.new("TextButton", sg)
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(1, -70, 0.5, -27)
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenBtn.Text = "MENU"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local BStroke = Instance.new("UIStroke", OpenBtn); BStroke.Thickness = 2
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- 3. UI ELEMENTLERİ (ÖZELLİKLER)
local function CreateButton(txt, y, color, func)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0, 280, 0, 40)
    b.Position = UDim2.new(0, 20, 0, y)
    b.BackgroundColor3 = color
    b.Text = txt
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 13
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(func)
    return b
end

-- FONKSİYONLAR
local speedBtn = CreateButton("WALK SPEED: 16", 60, Color3.fromRGB(25, 25, 25), function()
    _G.Set.Speed = (_G.Set.Speed >= 160) and 16 or _G.Set.Speed + 24
end)

local jumpBtn = CreateButton("JUMP POWER: 50", 110, Color3.fromRGB(25, 25, 25), function()
    _G.Set.Jump = (_G.Set.Jump >= 300) and 50 or _G.Set.Jump + 50
end)

local lagBtn = CreateButton("SERVER LAG: OFF", 160, Color3.fromRGB(25, 25, 25), function()
    _G.Set.Lag = not _G.Set.Lag
end)

-- MULTI-POINT SİSTEMİ
local pointSelect = CreateButton("EDITING: POINT 1", 230, Color3.fromRGB(40, 30, 0), function(self)
    CurrentPoint = (CurrentPoint % 4) + 1
    self.Text = "EDITING: POINT " .. CurrentPoint
end)

CreateButton("SET THIS LOCATION", 280, Color3.fromRGB(0, 60, 100), function()
    if player.Character then
        local pos = player.Character.HumanoidRootPart.Position
        Points[CurrentPoint] = pos
        -- Görsel İşaretçi
        if Visuals[CurrentPoint] then Visuals[CurrentPoint]:Destroy() end
        local p = Instance.new("Part", workspace); p.Size = Vector3.new(3,3,3); p.Position = pos; p.Anchored = true; p.CanCollide = false
        p.Shape = Enum.PartType.Ball; p.Material = Enum.Material.Neon; p.Color = Color3.new(0, 0.5, 1); p.Transparency = 0.4
        Visuals[CurrentPoint] = p
    end
end)

CreateButton("AUTO WALK TO POINT", 330, Color3.fromRGB(0, 80, 0), function()
    local target = Points[CurrentPoint]
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

CreateButton("STOP ALL", 380, Color3.fromRGB(80, 0, 0), function() IsWalking = false end)

-- 4. RGB VE DÖNGÜLER
spawn(function()
    while task.wait() do
        local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        Stroke.Color = color
        BStroke.Color = color
    end
end)

RunService.Heartbeat:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        speedBtn.Text = "WALK SPEED: " .. _G.Set.Speed
        jumpBtn.Text = "JUMP POWER: " .. _G.Set.Jump
        lagBtn.Text = "SERVER LAG: " .. (_G.Set.Lag and "ON" or "OFF")
        if not IsWalking then hum.WalkSpeed = _G.Set.Speed end
        hum.JumpPower = _G.Set.Jump
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end
    -- Stabil Lag
    if _G.Set.Lag and char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0.0001, 0)
    end
end)
