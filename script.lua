--[[
    rzgr1ks DUEL HUB - V92 (LEMON HUB STYLE & AUTO-WALK FIX)
    - Tasarım: Lemon Hub Premium (Bölmeli, Kaydırılabilir, Modern)
    - Auto-Walk: 4-Point Pathfinding (Düzeltilmiş ve Takılmaz)
    - Anti-Cheat: Stealth Speed & Jump (CFrame/Velocity tabanlı)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- 1. AYARLAR
_G.Set = {
    Speed = 30, 
    Jump = 60, 
    Gravity = 100,
    HB_Toggle = false, 
    HB_Size = 25,
    ESP = false
}

local Points = {nil, nil, nil, nil}
local Visuals = {nil, nil, nil, nil}
local SelectedSlot = 1
local IsWalking = false
local PointColors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,1,0)}

-- 2. UI TASARIMI (LEMON HUB TEMASI)
if CoreGui:FindFirstChild("rzg_v92") then CoreGui.rzg_v92:Destroy() end
local sg = Instance.new("ScreenGui", CoreGui); sg.Name = "rzg_v92"

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 400, 0, 500)
Main.Position = UDim2.new(0.5, -200, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 2; Stroke.Color = Color3.fromRGB(255, 170, 0)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50); Title.Text = "LEMÖN HUB DUELS PREMÎÜM"
Title.TextColor3 = Color3.fromRGB(255, 170, 0); Title.Font = "GothamBold"; Title.TextSize = 18; Title.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -70); Scroll.Position = UDim2.new(0, 10, 0, 60)
Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2; Scroll.CanvasSize = UDim2.new(0, 0, 0, 750)
local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 10); Layout.HorizontalAlignment = "Center"

-- MENÜ BUTONU (MOBİL İÇİN)
local MenuBtn = Instance.new("TextButton", sg)
MenuBtn.Size = UDim2.new(0, 60, 0, 60); MenuBtn.Position = UDim2.new(1, -80, 0.5, -30)
MenuBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MenuBtn.Text = "MENU"; MenuBtn.TextColor3 = Color3.new(1,1,1); MenuBtn.Font = "GothamBold"
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1,0)
MenuBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- 3. BÖLÜM VE BUTON OLUŞTURUCU
local function CreateSection(name)
    local l = Instance.new("TextLabel", Scroll)
    l.Size = UDim2.new(0.9, 0, 0, 25); l.Text = "--- " .. name .. " ---"
    l.TextColor3 = Color3.fromRGB(255, 170, 0); l.Font = "GothamBold"; l.BackgroundTransparency = 1; l.TextSize = 12
end

local function AddBtn(txt, func, color)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0.9, 0, 0, 40); b.BackgroundColor3 = color or Color3.fromRGB(30, 30, 30)
    b.Text = txt; b.TextColor3 = Color3.new(1, 1, 1); b.Font = "GothamSemibold"; b.TextSize = 14
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(func)
    return b
end

-- ÖZELLİKLER
CreateSection("FİZİKSEL AYARLAR")
local speedBtn = AddBtn("BYPASS SPEED: 30", function()
    _G.Set.Speed = (_G.Set.Speed >= 50) and 30 or _G.Set.Speed + 5
end)

local jumpBtn = AddBtn("BYPASS JUMP: 60", function()
    _G.Set.Jump = (_G.Set.Jump >= 80) and 60 or _G.Set.Jump + 5
end)

CreateSection("SAVAŞ & GÖRSEL")
local hbBtn = AddBtn("HITBOX EXPANDER: OFF", function()
    _G.Set.HB_Toggle = not _G.Set.HB_Toggle
end)

local espBtn = AddBtn("PLAYER ESP: OFF", function()
    _G.Set.ESP = not _G.Set.ESP
end)

CreateSection("4-POINT CHECKPOINT")
local slotBtn = AddBtn("SEÇİLİ: POINT 1", function()
    SelectedSlot = (SelectedSlot % 4) + 1
    slotBtn.Text = "SEÇİLİ: POINT " .. SelectedSlot
end, Color3.fromRGB(60, 40, 0))

AddBtn("NOKTAYI KAYDET", function()
    if player.Character then
        local pos = player.Character.HumanoidRootPart.Position
        Points[SelectedSlot] = pos
        if Visuals[SelectedSlot] then Visuals[SelectedSlot]:Destroy() end
        local p = Instance.new("Part", workspace); p.Size = Vector3.new(4,4,4); p.Position = pos; p.Anchored = true; p.CanCollide = false
        p.Shape = "Ball"; p.Material = "Neon"; p.Color = PointColors[SelectedSlot]; p.Transparency = 0.5
        Visuals[SelectedSlot] = p
    end
end, Color3.fromRGB(0, 60, 100))

AddBtn("YÜRÜMEYE BAŞLA (FIXED)", function()
    local target = Points[SelectedSlot]
    if not target or IsWalking then return end
    IsWalking = true
    spawn(function()
        while IsWalking and target and player.Character do
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then
                hum:MoveTo(target) -- Temel hareket
                -- Takılma kontrolü: Eğer karakter duruyorsa zıplat
                if player.Character.HumanoidRootPart.Velocity.Magnitude < 1 then hum.Jump = true end
                if (player.Character.HumanoidRootPart.Position - target).Magnitude < 4 then break end
            end
            task.wait(0.1)
        end
        IsWalking = false
    end)
end, Color3.fromRGB(0, 100, 0))

AddBtn("YÜRÜMEYİ DURDUR", function() IsWalking = false end, Color3.fromRGB(100, 0, 0))

-- 4. ANA DÖNGÜ (BYPASS & UPDATE)
RunService.RenderStepped:Connect(function(dt)
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hum and hrp then
        -- Yazı Güncellemeleri
        speedBtn.Text = "BYPASS SPEED: " .. _G.Set.Speed
        jumpBtn.Text = "BYPASS JUMP: " .. _G.Set.Jump
        hbBtn.Text = "HITBOX EXPANDER: " .. (_G.Set.HB_Toggle and "ON" or "OFF")
        espBtn.Text = "PLAYER ESP: " .. (_G.Set.ESP and "ON" or "OFF")

        -- Hız Bypass (Yürürken CFrame itme)
        if not IsWalking and hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (_G.Set.Speed - 16) * dt)
        end
    end
end)

-- Zıplama Bypass (Velocity)
UserInputService.JumpRequest:Connect(function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and not IsWalking then
        hrp.Velocity = Vector3.new(hrp.Velocity.X, _G.Set.Jump, hrp.Velocity.Z)
    end
end)

-- Hitbox & ESP Döngüsü
RunService.Heartbeat:Connect(function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local targetHrp = v.Character.HumanoidRootPart
            -- Hitbox
            if _G.Set.HB_Toggle then
                targetHrp.Size = Vector3.new(_G.Set.HB_Size, _G.Set.HB_Size, _G.Set.HB_Size)
                targetHrp.Transparency = 0.7; targetHrp.CanCollide = false
            else
                targetHrp.Size = Vector3.new(2, 2, 1); targetHrp.Transparency = 1
            end
            -- ESP
            if _G.Set.ESP then
                if not v.Character:FindFirstChild("Highlight") then
                    Instance.new("Highlight", v.Character).FillColor = Color3.new(1, 0.5, 0)
                end
            else
                if v.Character:FindFirstChild("Highlight") then v.Character.Highlight:Destroy() end
            end
        end
    end
end)
