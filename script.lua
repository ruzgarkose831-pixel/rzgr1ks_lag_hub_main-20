--[[
    rzgr1ks DUEL HUB - V72 (STABILITY RE-FIX)
    - Ölme sorunu düzeltildi.
    - Tüm sliderlar ve butonlar geri getirildi.
    - Spoofer güçlendirildi.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. KESİN ÇÖZÜM: ANTI-KICK & ANTI-DIE SPOOFER
local mt = getrawmetatable(game); local oldIndex = mt.__index; setreadonly(mt, false)
mt.__index = newcclosure(function(t, k)
    if not checkcaller() then
        if k == "WalkSpeed" and t:IsA("Humanoid") then return 16 end
        if k == "JumpPower" and t:IsA("Humanoid") then return 50 end
        if k == "Health" and t:IsA("Humanoid") then return 100 end -- Ölme kontrolü bypass
    end
    return oldIndex(t, k)
end); setreadonly(mt, true)

-- 2. GUI TEMİZLİĞİ VE YENİDEN KURULUM
if game:GetService("CoreGui"):FindFirstChild("rzg_hub_v72") then game:GetService("CoreGui").rzg_hub_v72:Destroy() end
local sg = Instance.new("ScreenGui", game:GetService("CoreGui")); sg.Name = "rzg_hub_v72"
local Main = Instance.new("Frame", sg); Main.Size = UDim2.new(0, 310, 0, 520); Main.Position = UDim2.new(0.5, -155, 0.5, -260); Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); Main.Active = true; Main.Draggable = true
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 3; Instance.new("UICorner", Main)
local Title = Instance.new("TextLabel", Main); Title.Size = UDim2.new(1, -40, 0, 35); Title.Position = UDim2.new(0, 15, 0, 0); Title.Text = "rzgr1ks DUEL HUB V72"; Title.BackgroundTransparency = 1; Title.Font = "GothamBold"; Title.TextSize = 14; Title.TextColor3 = Color3.new(1,1,1); Title.TextXAlignment = "Left"

-- RGB SİSTEMİ (Stabilizasyon sağlandı)
local RGB_Objects = {}
spawn(function()
    while task.wait() do
        local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        Stroke.Color = color
        for _, obj in pairs(RGB_Objects) do
            if obj:IsA("Frame") and obj.Name == "SliderFill" then obj.BackgroundColor3 = color
            elseif obj:IsA("TextButton") and obj:FindFirstChild("UIStroke") then obj:FindFirstChild("UIStroke").Color = color end
        end
    end
end)

-- 3. AYARLAR (Hız 45 Varsayılan)
_G.Set = {Speed = 45, Jump = 50, Gravity = 196.2, HitboxSize = 25, ESP = false, Hitbox = false, AntiRag = true, BypassSpeed = true}
local savedPos = nil

-- 4. UI ELEMANLARI (BUTONLAR VE SLIDERLAR)
local function CreateToggle(name, key, pos)
    local t = Instance.new("TextButton", Main); t.Size = UDim2.new(0, 140, 0, 32); t.Position = pos; t.BackgroundColor3 = Color3.fromRGB(25, 25, 25); t.Text = name..": OFF"; t.TextColor3 = Color3.new(1,1,1); t.Font = "Gotham"; t.TextSize = 8; Instance.new("UICorner", t); local ts = Instance.new("UIStroke", t); ts.Thickness = 2; ts.Color = Color3.fromRGB(60,60,60)
    t.MouseButton1Click:Connect(function()
        _G.Set[key] = not _G.Set[key]
        if _G.Set[key] then t.Text = name..": ON"; ts.Color = Color3.new(1,1,1); table.insert(RGB_Objects, t) else t.Text = name..": OFF"; ts.Color = Color3.fromRGB(60,60,60) end
    end)
end

local function CreateSlider(txt, min, max, def, key, y)
    local f = Instance.new("Frame", Main); f.Size = UDim2.new(0, 280, 0, 45); f.Position = UDim2.new(0, 15, 0, y); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = txt..": "..def; l.Size = UDim2.new(1,0,0,15); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Font = "GothamBold"; l.TextSize = 9
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 0, 14); b.Position = UDim2.new(0,0,0,20); b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.Text = ""; Instance.new("UICorner", b)
    local fill = Instance.new("Frame", b); fill.Name = "SliderFill"; fill.Size = UDim2.new((def-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", fill); table.insert(RGB_Objects, fill)
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

-- ÖZELLİKLERİ YÜKLE
CreateToggle("Stealth Speed", "BypassSpeed", UDim2.new(0, 10, 0, 45))
CreateToggle("Anti-Ragdoll", "AntiRag", UDim2.new(0, 160, 0, 45))
CreateToggle("Player ESP", "ESP", UDim2.new(0, 10, 0, 85))
CreateToggle("Hitbox Expand", "Hitbox", UDim2.new(0, 160, 0, 85))

CreateSlider("Walk Speed", 16, 300, 45, "Speed", 130)
CreateSlider("Jump Power", 50, 300, 50, "Jump", 185)
CreateSlider("Gravity", 0, 196, 196, "Gravity", 240)
CreateSlider("Hitbox Size", 2, 100, 25, "HitboxSize", 295)

-- CHECKPOINT BUTONLARI (Alt Bölüm)
local function CPBtn(name, pos, func)
    local b = Instance.new("TextButton", Main); b.Size = UDim2.new(0, 135, 0, 35); b.Position = pos; b.BackgroundColor3 = Color3.fromRGB(35,35,35); b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 9; Instance.new("UICorner", b); b.MouseButton1Click:Connect(func)
end

CPBtn("SET CHECKPOINT", UDim2.new(0, 10, 0, 355), function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        savedPos = player.Character.HumanoidRootPart.Position
    end
end)

CPBtn("WALK TO CP", UDim2.new(0, 160, 0, 355), function()
    if savedPos and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:MoveTo(savedPos)
    end
end)

-- 5. STABİL MOTOR
RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid"); local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    
    if _G.Set.BypassSpeed then hum.WalkSpeed = _G.Set.Speed end
    hum.JumpPower = _G.Set.Jump
    workspace.Gravity = _G.Set.Gravity
    
    if _G.Set.AntiRag then
        hum.PlatformStand = false
        if hum:GetState() == Enum.HumanoidStateType.Ragdoll then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
end)
