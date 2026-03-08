local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. ESKİ SCRİPTİ TEMİZLE
if game:GetService("CoreGui"):FindFirstChild("rzgr1ks_V57") then game:GetService("CoreGui").rzgr1ks_V57:Destroy() end

-- 2. ANA PANEL (STABİL VE GÖRÜNÜR)
local sg = Instance.new("ScreenGui", game:GetService("CoreGui")); sg.Name = "rzgr1ks_V57"
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 310, 0, 260); Main.Position = UDim2.new(0.5, -155, 0.5, -130)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); Main.Active = true; Main.Draggable = true
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 2; Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30); Title.Text = "rzgr1ks V57 - ELEVATION 0 FIX"; Title.BackgroundTransparency = 1
Title.Font = "GothamBold"; Title.TextSize = 10; Title.TextColor3 = Color3.new(1,1,1)

-- RGB KENARLIK
spawn(function()
    while task.wait() do Stroke.Color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1) end
end)

-- KÜÇÜLTME SİSTEMİ
local MiniBtn = Instance.new("TextButton", Main)
MiniBtn.Size = UDim2.new(0, 25, 0, 25); MiniBtn.Position = UDim2.new(1, -30, 0, 3); MiniBtn.Text = "-"; MiniBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); MiniBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", MiniBtn)
local OpenBtn = Instance.new("TextButton", sg); OpenBtn.Size = UDim2.new(0, 45, 0, 45); OpenBtn.Position = UDim2.new(0, 10, 0.5, -22); OpenBtn.Visible = false; OpenBtn.Text = "R"; OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); OpenBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", OpenBtn); Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(255, 140, 0)
MiniBtn.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

-- 3. AYARLAR (ELEVATION 0 OLARAK BAŞLATILDI)
_G.Set = {Speed = 70, Hitbox = false, HitboxSize = 25, ESP = false, Plat = false, Elev = 0, AntiRag = true}

-- BUTON OLUŞTURUCU
local function QuickToggle(name, key, pos)
    local t = Instance.new("TextButton", Main)
    t.Size = UDim2.new(0, 140, 0, 30); t.Position = pos; t.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    t.Text = name..": OFF"; t.TextColor3 = Color3.new(1,1,1); t.Font = "Gotham"; t.TextSize = 8; Instance.new("UICorner", t)
    t.MouseButton1Click:Connect(function()
        _G.Set[key] = not _G.Set[key]
        t.Text = _G.Set[key] and name..": ON" or name..": OFF"
        t.TextColor3 = _G.Set[key] and Color3.fromRGB(255, 140, 0) or Color3.new(1, 1, 1)
    end)
end

QuickToggle("Block Platform", "Plat", UDim2.new(0, 10, 0, 40))
QuickToggle("Anti Ragdoll", "AntiRag", UDim2.new(0, 160, 0, 40))
QuickToggle("ESP Wallhack", "ESP", UDim2.new(0, 10, 0, 75))
QuickToggle("Hitbox Expand", "Hitbox", UDim2.new(0, 160, 0, 75))

-- 4. SLIDER OLUŞTURUCU (YÜKSEKLİK 0-500 ARASI)
local function QuickSlider(txt, min, max, def, key, y)
    local f = Instance.new("Frame", Main); f.Size = UDim2.new(0, 290, 0, 35); f.Position = UDim2.new(0, 10, 0, y); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = txt..": "..def; l.Size = UDim2.new(1,0,0,15); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 8
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 0, 4); b.Position = UDim2.new(0,0,0,20); b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.Text = ""
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((def-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    b.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local p = math.clamp((inp.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0); local val = math.floor(min + (max - min) * p)
                l.Text = txt..": "..val; _G.Set[key] = val
            end
        end)
        UIS.InputEnded:Connect(function(u) if u.UserInputType == Enum.UserInputType.MouseButton1 or u.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

QuickSlider("Walk Speed", 16, 500, 70, "Speed", 115)
QuickSlider("Hitbox Size", 5, 100, 25, "HitboxSize", 155)
QuickSlider("Elevation Height (Fly)", 0, 500, 0, "Elev", 195) -- 0'dan başlar

-- 5. ÇALIŞTIRICI MOTOR
local AirBlock = Instance.new("Part", workspace); AirBlock.Name = "R_Platform"; AirBlock.Size = Vector3.new(20, 1, 20); AirBlock.Transparency = 0.7; AirBlock.Anchored = true; AirBlock.Color = Color3.fromRGB(255, 140, 0)

RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    
    hum.WalkSpeed = _G.Set.Speed

    -- ANTI RAGDOLL
    if _G.Set.AntiRag then
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum.PlatformStand = false
        hum.Sit = false
    end

    -- PLATFORM MOTORU (YÜKSEKLİK 0 FIX)
    if _G.Set.Plat then
        AirBlock.CanCollide = true
        AirBlock.CFrame = CFrame.new(root.Position.X, _G.Set.Elev, root.Position.Z)
        if hum:GetState() == Enum.HumanoidStateType.Freefall then hum:ChangeState(Enum.HumanoidStateType.Running) end
    else
        AirBlock.CanCollide = false
        AirBlock.Position = Vector3.new(0, -1000, 0)
    end
    
    -- ESP & HITBOX
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = v.Character.HumanoidRootPart
            if _G.Set.Hitbox then 
                hrp.Size = Vector3.new(_G.Set.HitboxSize, _G.Set.HitboxSize, _G.Set.HitboxSize)
                hrp.Transparency = 0.7; hrp.CanCollide = false
            else 
                hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 0; hrp.CanCollide = true 
            end
            local hl = v.Character:FindFirstChild("ESPHL") or Instance.new("Highlight", v.Character); hl.Name = "ESPHL"; hl.Enabled = _G.Set.ESP; hl.FillColor = Color3.fromRGB(255, 140, 0)
        end
    end
end)
