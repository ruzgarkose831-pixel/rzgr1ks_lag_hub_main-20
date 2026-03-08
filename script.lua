local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. ZORUNLU TEMİZLİK
local function cleanup()
    if game:GetService("CoreGui"):FindFirstChild("rzgr1ks_V53") then game:GetService("CoreGui").rzgr1ks_V53:Destroy() end
    if workspace:FindFirstChild("AirBlock_" .. player.Name) then workspace["AirBlock_" .. player.Name]:Destroy() end
end
cleanup()

-- 2. ANA PANEL TASARIMI (BOŞ KALMAMASI İÇİN YENİLENDİ)
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "rzgr1ks_V53"

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 310, 0, 280)
Main.Position = UDim2.new(0.5, -155, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -30, 0, 35); Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "rzgr1ks V53 - GUI FIXED"; Title.BackgroundTransparency = 1
Title.Font = "GothamBold"; Title.TextSize = 11; Title.TextXAlignment = "Left"

-- RGB KENARLIK
spawn(function()
    while task.wait() do
        local color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
        Stroke.Color = color; Title.TextColor3 = color
    end
end)

-- KÜÇÜLTME BUTONU (MINIMIZE)
local MiniBtn = Instance.new("TextButton", Main)
MiniBtn.Size = UDim2.new(0, 25, 0, 25); MiniBtn.Position = UDim2.new(1, -30, 0, 5)
MiniBtn.Text = "-"; MiniBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Kırmızı kapatma butonu
MiniBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", MiniBtn)

local OpenBtn = Instance.new("TextButton", sg)
OpenBtn.Size = UDim2.new(0, 45, 0, 45); OpenBtn.Position = UDim2.new(0, 20, 0.5, -22)
OpenBtn.Visible = false; OpenBtn.Text = "MENU"; OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", OpenBtn); Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(255, 140, 0)

MiniBtn.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

-- İÇERİK ALANI (GRID LAYOUT)
local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -10, 1, -45); Content.Position = UDim2.new(0, 5, 0, 40)
Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 2
local Grid = Instance.new("UIGridLayout", Content)
Grid.CellSize = UDim2.new(0, 142, 0, 32); Grid.Padding = UDim2.new(0, 6, 0, 6)

-- 3. AYARLAR VE ESP SİSTEMİ
_G.V53 = {Speed = 70, Elev = 15, Spin = false, Hitbox = false, HitboxSize = 25, ESP = false, AntiRag = true}

local function createESP(plr)
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_" .. plr.Name; hl.FillColor = Color3.fromRGB(255, 140, 0); hl.FillTransparency = 0.5
    
    RunService.RenderStepped:Connect(function()
        if _G.V53.ESP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            hl.Parent = game:GetService("CoreGui"); hl.Adornee = plr.Character; hl.Enabled = true
        else
            hl.Enabled = false
        end
    end)
end

for _, v in pairs(Players:GetPlayers()) do if v ~= player then createESP(v) end end
Players.PlayerAdded:Connect(createESP)

-- 4. BUTON OLUŞTURUCU (BOŞ KALMAMASI İÇİN GARANTİ FONKSİYON)
local function AddToggle(txt, key)
    local t = Instance.new("TextButton", Content)
    t.BackgroundColor3 = Color3.fromRGB(30, 30, 30); t.Text = txt..": OFF"
    t.TextColor3 = Color3.new(1, 1, 1); t.Font = "Gotham"; t.TextSize = 8; Instance.new("UICorner", t)
    t.MouseButton1Click:Connect(function()
        _G.V53[key] = not _G.V53[key]
        t.Text = _G.V53[key] and txt..": ON" or txt..": OFF"
        t.TextColor3 = _G.V53[key] and Color3.fromRGB(255, 140, 0) or Color3.new(1, 1, 1)
    end)
end

local function AddSlider(txt, min, max, def, key)
    local f = Instance.new("Frame", Content); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = txt..": "..def; l.Size = UDim2.new(1,0,0,12); l.TextColor3 = Color3.new(1,1,1); l.TextSize = 7; l.BackgroundTransparency = 1
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0, 130, 0, 4); b.Position = UDim2.new(0,6,0,18); b.BackgroundColor3 = Color3.fromRGB(50,50,50); b.Text = ""
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((def-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    b.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local p = math.clamp((inp.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0); local val = math.floor(min + (max - min) * p)
                l.Text = txt..": "..val; _G.V53[key] = val
            end
        end)
        UIS.InputEnded:Connect(function(u) if u.UserInputType == Enum.UserInputType.MouseButton1 or u.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

-- ÖZELLİKLERİ EKLE (BOŞLUĞU DOLDURUR)
AddToggle("Block Platform", "Platform")
AddToggle("ESP Wallhack", "ESP")
AddToggle("Hitbox Expand", "Hitbox")
AddToggle("Torque Spin", "Spin")
AddToggle("Anti Ragdoll", "AntiRag")
AddSlider("Walk Speed", 16, 500, 70, "Speed")
AddSlider("Hitbox Size", 5, 100, 25, "HitboxSize")
AddSlider("Elev Height", 5, 200, 15, "Elev")

-- 5. ÇALIŞTIRICI MOTOR
local AirBlock = Instance.new("Part")
AirBlock.Name = "AirBlock_" .. player.Name; AirBlock.Size = Vector3.new(16, 1, 16); AirBlock.Transparency = 0.8; AirBlock.Anchored = true; AirBlock.Parent = workspace

RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    hum.WalkSpeed = _G.V53.Speed
    if _G.V53.Spin then root.RotVelocity = Vector3.new(0, 50, 0) end
    
    if _G.V53.Hitbox then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(_G.V53.HitboxSize, _G.V53.HitboxSize, _G.V53.HitboxSize)
                v.Character.HumanoidRootPart.Transparency = 0.7; v.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end

    if _G.V53.Platform then
        AirBlock.CanCollide = true; AirBlock.CFrame = CFrame.new(root.Position.X, _G.V53.Elev, root.Position.Z)
    else
        AirBlock.CanCollide = false; AirBlock.Position = Vector3.new(0, -1000, 0)
    end
end)
