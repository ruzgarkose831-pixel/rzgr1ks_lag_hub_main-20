--[[
    rzgr1ks DUEL HUB - V77 (FULL CONFIG & JSON SAVE)
    - Ayarlarını dosyaya kaydeder (writefile/readfile).
    - Ölüm koruması ve mobil buton aktiftir.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- 1. CONFIG SİSTEMİ (DOSYA İŞLEMLERİ)
local FileName = "rzgr1ks_config.json"
_G.Set = {Speed = 16, Jump = 50, Gravity = 196.2, HitboxSize = 25}

local function SaveConfig()
    local json = HttpService:JSONEncode(_G.Set)
    writefile(FileName, json)
    print("Ayarlar Kaydedildi!")
end

local function LoadConfig()
    if isfile(FileName) then
        local data = readfile(FileName)
        _G.Set = HttpService:JSONDecode(data)
        print("Ayarlar Yüklendi!")
    end
end

-- 2. ANA PANEL
if game:GetService("CoreGui"):FindFirstChild("rzg_hub_v77") then game:GetService("CoreGui").rzg_hub_v77:Destroy() end
local sg = Instance.new("ScreenGui", game:GetService("CoreGui")); sg.Name = "rzg_hub_v77"
local Main = Instance.new("Frame", sg); Main.Size = UDim2.new(0, 310, 0, 550); Main.Position = UDim2.new(0.5, -155, 0.5, -275); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Main.Draggable = true
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 3; Stroke.Color = Color3.new(1,1,1); Instance.new("UICorner", Main)
local Title = Instance.new("TextLabel", Main); Title.Size = UDim2.new(1, 0, 0, 35); Title.Position = UDim2.new(0, 15, 0, 0); Title.Text = "rzgr1ks CONFIG HUB V77"; Title.BackgroundTransparency = 1; Title.Font = "GothamBold"; Title.TextSize = 13; Title.TextColor3 = Color3.new(1,1,1); Title.TextXAlignment = "Left"

-- MOBİL BUTON
local OpenBtn = Instance.new("TextButton", sg); OpenBtn.Size = UDim2.new(0, 50, 0, 50); OpenBtn.Position = UDim2.new(1, -60, 0, 10); OpenBtn.Text = "MENU"; OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); OpenBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", OpenBtn); OpenBtn.BackgroundTransparency = 0.5
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- 3. UI ELEMENTLERİ
local function CreateSlider(txt, min, max, key, y)
    local f = Instance.new("Frame", Main); f.Size = UDim2.new(0, 280, 0, 45); f.Position = UDim2.new(0, 15, 0, y); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = txt..": ".._G.Set[key]; l.Size = UDim2.new(1,0,0,15); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Font = "GothamBold"; l.TextSize = 9
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 0, 14); b.Position = UDim2.new(0,0,0,20); b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.Text = ""; Instance.new("UICorner", b)
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((_G.Set[key]-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", fill)
    
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

CreateSlider("Walk Speed", 16, 150, "Speed", 50)
CreateSlider("Jump Power", 50, 300, "Jump", 105)
CreateSlider("Gravity", 0, 196, "Gravity", 160)

-- CONFIG BUTONLARI
local function SpecialBtn(name, pos, color, func)
    local b = Instance.new("TextButton", Main); b.Size = UDim2.new(0, 135, 0, 35); b.Position = pos; b.BackgroundColor3 = color; b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 10; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(func)
end

SpecialBtn("SAVE CONFIG", UDim2.new(0, 10, 0, 220), Color3.fromRGB(0, 120, 0), SaveConfig)
SpecialBtn("LOAD CONFIG", UDim2.new(0, 160, 0, 220), Color3.fromRGB(0, 80, 150), LoadConfig)

-- 4. MOTOR VE ANTI-DIE
RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        if hum.Health <= 0 then hum.Health = 100 end
        hum.WalkSpeed = _G.Set.Speed
        hum.JumpPower = _G.Set.Jump
        workspace.Gravity = _G.Set.Gravity
    end
end)

-- Başlangıçta varsa ayarları yükle
LoadConfig()
