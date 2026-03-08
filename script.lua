--[[
    rzgr1ks DUEL HUB - V74 (MOBILE STABLE & ANTI-DIE)
    - Mobil Destek: Sağ üstteki butona basarak menüyü kapat/aç.
    - Ölüm Koruması: Karakter State'leri ve Health manipülasyonu güncellendi.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. MOBİL ÖLÜM KORUMASI (GOD-MODE)
local mt = getrawmetatable(game); setreadonly(mt, false); local oldIndex = mt.__index
mt.__index = newcclosure(function(t, k)
    if not checkcaller() then
        if k == "WalkSpeed" and t:IsA("Humanoid") then return 16 end
        if k == "JumpPower" and t:IsA("Humanoid") then return 50 end
        if k == "Health" and t:IsA("Humanoid") then return 100 end
    end
    return oldIndex(t, k)
end); setreadonly(mt, true)

-- 2. ANA PANEL VE MOBİL BUTON
if game:GetService("CoreGui"):FindFirstChild("rzg_hub_v74") then game:GetService("CoreGui").rzg_hub_v74:Destroy() end
local sg = Instance.new("ScreenGui", game:GetService("CoreGui")); sg.Name = "rzg_hub_v74"

local Main = Instance.new("Frame", sg); Main.Size = UDim2.new(0, 310, 0, 520); Main.Position = UDim2.new(0.5, -155, 0.5, -240); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Main.Draggable = true
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 3; Instance.new("UICorner", Main)
local Title = Instance.new("TextLabel", Main); Title.Size = UDim2.new(1, 0, 0, 35); Title.Position = UDim2.new(0, 15, 0, 0); Title.Text = "rzgr1ks DUEL HUB V74"; Title.BackgroundTransparency = 1; Title.Font = "GothamBold"; Title.TextSize = 14; Title.TextColor3 = Color3.new(1,1,1); Title.TextXAlignment = "Left"

-- MOBİL KAPAT/AÇ BUTONU (EKRANIN SAĞINDA DURUR)
local OpenBtn = Instance.new("TextButton", sg)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(1, -60, 0, 10) -- Sağ üst köşe
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.Text = "MENU"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Font = "GothamBold"
OpenBtn.TextSize = 10
OpenBtn.BackgroundTransparency = 0.5
Instance.new("UICorner", OpenBtn)
local OS = Instance.new("UIStroke", OpenBtn); OS.Thickness = 2; OS.Color = Color3.new(1,1,1)

OpenBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- 3. RGB SİSTEMİ
local RGB_Objects = {Stroke, OS}
spawn(function()
    while task.wait() do
        local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        for _, obj in pairs(RGB_Objects) do
            if obj:IsA("Frame") then obj.BackgroundColor3 = color
            elseif obj:IsA("UIStroke") then obj.Color = color end
        end
    end
end)

-- 4. CONFIG & MOTOR
_G.Set = _G.Set or {Speed = 45, Jump = 50, Gravity = 196.2, HitboxSize = 25, ESP = false, Hitbox = false, AntiRag = true, BypassSpeed = true}

local function CreateToggle(name, key, pos)
    local t = Instance.new("TextButton", Main); t.Size = UDim2.new(0, 140, 0, 32); t.Position = pos; t.BackgroundColor3 = Color3.fromRGB(30, 30, 30); t.Text = name..": "..(_G.Set[key] and "ON" or "OFF"); t.TextColor3 = Color3.new(1,1,1); t.Font = "Gotham"; t.TextSize = 8; Instance.new("UICorner", t)
    local ts = Instance.new("UIStroke", t); ts.Thickness = 2; ts.Color = _G.Set[key] and Color3.new(1,1,1) or Color3.fromRGB(60,60,60)
    if _G.Set[key] then table.insert(RGB_Objects, ts) end

    t.MouseButton1Click:Connect(function()
        _G.Set[key] = not _G.Set[key]
        t.Text = name..": "..(_G.Set[key] and "ON" or "OFF")
        if _G.Set[key] then ts.Color = Color3.new(1,1,1); table.insert(RGB_Objects, ts) else ts.Color = Color3.fromRGB(60,60,60) end
    end)
end

local function CreateSlider(txt, min, max, def, key, y)
    local f = Instance.new("Frame", Main); f.Size = UDim2.new(0, 280, 0, 45); f.Position = UDim2.new(0, 15, 0, y); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = txt..": ".._G.Set[key]; l.Size = UDim2.new(1,0,0,15); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Font = "GothamBold"; l.TextSize = 9
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 0, 14); b.Position = UDim2.new(0,0,0,20); b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.Text = ""; Instance.new("UICorner", b)
    local fill = Instance.new("Frame", b); fill.Name = "SliderFill"; fill.Size = UDim2.new((_G.Set[key]-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", fill)
    
    b.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local p = math.clamp((inp.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0); local val = math.floor(min + (max - min) * p); l.Text = txt..": "..val; _G.Set[key] = val
            end
        end)
        UIS.InputEnded:Connect(function(u) if u.UserInputType == Enum.UserInputType.MouseButton1 or u.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

-- ÖZELLİKLER
CreateToggle("Stealth Speed", "BypassSpeed", UDim2.new(0, 10, 0, 45))
CreateToggle("Anti-Ragdoll", "AntiRag", UDim2.new(0, 160, 0, 45))
CreateToggle("Player ESP", "ESP", UDim2.new(0, 10, 0, 85))
CreateToggle("Hitbox Expand", "Hitbox", UDim2.new(0, 160, 0, 85))
CreateSlider("Walk Speed", 16, 300, 45, "Speed", 130)
CreateSlider("Jump Power", 50, 300, 50, "Jump", 185)
CreateSlider("Gravity", 0, 196, 196, "Gravity", 240)
CreateSlider("Hitbox Size", 2, 100, 25, "HitboxSize", 295)

-- MOTOR (MOBİL OPTİMİZE)
RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    if not hum then return end
    
    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    if hum.Health <= 0 then hum.Health = 100 end 
    
    if _G.Set.BypassSpeed then hum.WalkSpeed = _G.Set.Speed end
    hum.JumpPower = _G.Set.Jump
    workspace.Gravity = _G.Set.Gravity
end)
