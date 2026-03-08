--[[
    rzgr1ks DUEL HUB - V80 (VISUAL & TOGGLE HITBOX)
    - Hitbox Toggle: Tek tıkla aç/kapat.
    - Hitbox Visuals: Renk ve görünürlük ayarları eklendi.
    - Full Config & Anti-Die desteği.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- 1. CONFIG SİSTEMİ
local FileName = "rzgr1ks_v80_visual.json"
_G.Set = {
    Speed = 16, Jump = 50, 
    HitboxSize = 25, HitboxExp = false, 
    HitboxVisual = true, -- Görsel efekt açık mı?
    ESP = false, AntiDie = true,
    HB_Color = Color3.fromRGB(0, 255, 255), -- Turkuaz Neon
    HB_Transparency = 0.7
}

local function SaveConfig()
    local data = {}
    for i,v in pairs(_G.Set) do
        if typeof(v) == "Color3" then data[i] = {v.R, v.G, v.B} else data[i] = v end
    end
    writefile(FileName, HttpService:JSONEncode(data))
end

local function LoadConfig()
    if isfile(FileName) then
        local data = HttpService:JSONDecode(readfile(FileName))
        for i, v in pairs(data) do 
            if type(v) == "table" then _G.Set[i] = Color3.new(v[1], v[2], v[3]) else _G.Set[i] = v end
        end
    end
end
LoadConfig()

-- 2. ANA PANEL
if game:GetService("CoreGui"):FindFirstChild("rzg_hub_v80") then game:GetService("CoreGui").rzg_hub_v80:Destroy() end
local sg = Instance.new("ScreenGui", game:GetService("CoreGui")); sg.Name = "rzg_hub_v80"
local Main = Instance.new("Frame", sg); Main.Size = UDim2.new(0, 320, 0, 600); Main.Position = UDim2.new(0.5, -160, 0.5, -300); Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); Main.Active = true; Main.Draggable = true
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 3; Instance.new("UICorner", Main)
local Title = Instance.new("TextLabel", Main); Title.Size = UDim2.new(1, 0, 0, 35); Title.Text = "rzgr1ks VISUAL HUB V80"; Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1; Title.Font = "GothamBold"

-- MOBİL BUTON
local OpenBtn = Instance.new("TextButton", sg); OpenBtn.Size = UDim2.new(0, 55, 0, 55); OpenBtn.Position = UDim2.new(1, -65, 0, 15); OpenBtn.Text = "MENU"; OpenBtn.BackgroundColor3 = Color3.fromRGB(20,20,20); OpenBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", OpenBtn); OpenBtn.BackgroundTransparency = 0.4
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- 3. UI YARDIMCILARI
local function CreateToggle(name, key, pos)
    local t = Instance.new("TextButton", Main); t.Size = UDim2.new(0, 145, 0, 30); t.Position = pos; t.BackgroundColor3 = Color3.fromRGB(25, 25, 25); t.Text = name..": "..(_G.Set[key] and "ON" or "OFF"); t.TextColor3 = Color3.new(1,1,1); t.Font = "Gotham"; t.TextSize = 8; Instance.new("UICorner", t)
    t.MouseButton1Click:Connect(function()
        _G.Set[key] = not _G.Set[key]
        t.Text = name..": "..(_G.Set[key] and "ON" or "OFF")
    end)
end

local function CreateSlider(txt, min, max, key, y)
    local f = Instance.new("Frame", Main); f.Size = UDim2.new(0, 290, 0, 40); f.Position = UDim2.new(0, 15, 0, y); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = txt..": ".._G.Set[key]; l.Size = UDim2.new(1,0,0,15); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 9
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 0, 12); b.Position = UDim2.new(0,0,0,18); b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.Text = ""; Instance.new("UICorner", b)
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((_G.Set[key]-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", fill)
    b.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local p = math.clamp((inp.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0); local val = (key == "HB_Transparency") and (math.floor(p * 10) / 10) or math.floor(min + (max - min) * p)
                l.Text = txt..": "..val; _G.Set[key] = val
            end
        end)
        UIS.InputEnded:Connect(function(u) if u.UserInputType == Enum.UserInputType.MouseButton1 or u.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

-- ÖZELLİKLER LİSTESİ
CreateToggle("HITBOX SYSTEM", "HitboxExp", UDim2.new(0, 10, 0, 45))
CreateToggle("SHOW VISUALS", "HitboxVisual", UDim2.new(0, 165, 0, 45))
CreateToggle("PLAYER ESP", "ESP", UDim2.new(0, 85, 0, 80))

CreateSlider("Hitbox Size", 2, 100, "HitboxSize", 125)
CreateSlider("HB Transparency", 0, 1, "HB_Transparency", 175)
CreateSlider("Walk Speed", 16, 150, "Speed", 225)

-- SAVE/LOAD
local function ActionBtn(name, pos, color, func)
    local b = Instance.new("TextButton", Main); b.Size = UDim2.new(0, 145, 0, 35); b.Position = pos; b.BackgroundColor3 = color; b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 10; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(func)
end

ActionBtn("SAVE CONFIG", UDim2.new(0, 10, 0, 300), Color3.fromRGB(0, 120, 0), SaveConfig)
ActionBtn("LOAD CONFIG", UDim2.new(0, 165, 0, 300), Color3.fromRGB(0, 80, 150), LoadConfig)

-- 4. VISUAL HITBOX MOTORU
RunService.RenderStepped:Connect(function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = v.Character.HumanoidRootPart
            if _G.Set.HitboxExp then
                hrp.Size = Vector3.new(_G.Set.HitboxSize, _G.Set.HitboxSize, _G.Set.HitboxSize)
                hrp.CanCollide = false
                
                if _G.Set.HitboxVisual then
                    hrp.Transparency = _G.Set.HB_Transparency
                    hrp.Color = _G.Set.HB_Color
                    hrp.Material = Enum.Material.Neon
                else
                    hrp.Transparency = 1
                end
            else
                -- Kapalıyken orijinal boyuta dön
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
            end
        end
    end
end)

-- 5. ANTI-DIE
RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        if hum.Health <= 0 then hum.Health = 100 end
        hum.WalkSpeed = _G.Set.Speed
    end
end)

spawn(function() while task.wait() do Stroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end end)
