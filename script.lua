local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService") -- Config için gerekli
local player = Players.LocalPlayer

-- 1. ESKİLERİ SİL
if game:GetService("CoreGui"):FindFirstChild("rzgr1ks_V59") then game:GetService("CoreGui").rzgr1ks_V59:Destroy() end

-- 2. ANA PANEL (YAPILANDIRMA İÇİN BİRAZ DAHA UZATILDI)
local sg = Instance.new("ScreenGui", game:GetService("CoreGui")); sg.Name = "rzgr1ks_V59"
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 310, 0, 380) -- Config butonları için yer açıldı
Main.Position = UDim2.new(0.5, -155, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); Main.Active = true; Main.Draggable = true
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 2; Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35); Title.Text = "rzgr1ks V59 - CONFIG SYSTEM"; Title.BackgroundTransparency = 1
Title.Font = "GothamBold"; Title.TextSize = 11; Title.TextColor3 = Color3.new(1,1,1)

spawn(function()
    while task.wait() do Stroke.Color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1) end
end)

-- 3. AYARLAR VE NESNE REFERANSLARI
_G.Set = {Speed = 70, Hitbox = false, HitboxSize = 25, ESP = false, Plat = false, Elev = 0, AntiRag = true}
local UI_Elements = {} -- UI'yı güncellemek için butonları burada tutacağız

-- 4. CONFIG FONKSİYONLARI (SAVE / LOAD)
local fileName = "rzgr1ks_config.json"

local function SaveConfig()
    local data = HttpService:JSONEncode(_G.Set)
    writefile(fileName, data)
    print("Ayarlar Kaydedildi!")
end

local function LoadConfig()
    if isfile(fileName) then
        local data = readfile(fileName)
        _G.Set = HttpService:JSONDecode(data)
        print("Ayarlar Yüklendi!")
        -- UI'yı yeni değerlere göre güncellemek için sayfayı yenilemek en sağlıklısı
    end
end

-- 5. BUTONLAR (TOGGLES)
local function QuickToggle(name, key, pos)
    local t = Instance.new("TextButton", Main)
    t.Size = UDim2.new(0, 140, 0, 32); t.Position = pos; t.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    t.Text = name..": OFF"; t.TextColor3 = Color3.new(1,1,1); t.Font = "Gotham"; t.TextSize = 8; Instance.new("UICorner", t)
    
    t.MouseButton1Click:Connect(function()
        _G.Set[key] = not _G.Set[key]
        t.Text = _G.Set[key] and name .. ": ON" or name .. ": OFF"
        t.TextColor3 = _G.Set[key] and Color3.fromRGB(255, 140, 0) or Color3.new(1, 1, 1)
    end)
end

QuickToggle("Block Platform", "Plat", UDim2.new(0, 10, 0, 45))
QuickToggle("Anti Ragdoll", "AntiRag", UDim2.new(0, 160, 0, 45))
QuickToggle("ESP Wallhack", "ESP", UDim2.new(0, 10, 0, 85))
QuickToggle("Hitbox Expand", "Hitbox", UDim2.new(0, 160, 0, 85))

-- 6. BÜYÜK SLIDERLAR
local function BigSlider(txt, min, max, def, key, y)
    local f = Instance.new("Frame", Main); f.Size = UDim2.new(0, 290, 0, 50); f.Position = UDim2.new(0, 10, 0, y); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = txt..": "..def; l.Size = UDim2.new(1,0,0,20); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 9; l.Font = "GothamBold"
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 0, 12); b.Position = UDim2.new(0,0,0,25); b.BackgroundColor3 = Color3.fromRGB(45,45,45); b.Text = ""; Instance.new("UICorner", b)
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((def-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255, 140, 0); Instance.new("UICorner", fill)
    
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

BigSlider("Walk Speed", 16, 500, 70, "Speed", 125)
BigSlider("Hitbox Size", 5, 100, 25, "HitboxSize", 185)
BigSlider("Elevation (Platform)", 0, 500, 0, "Elev", 245)

--- 7. CONFIG BUTONLARI (SAVE & LOAD) ---
local SaveBtn = Instance.new("TextButton", Main)
SaveBtn.Size = UDim2.new(0, 140, 0, 40); SaveBtn.Position = UDim2.new(0, 10, 0, 310)
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0); SaveBtn.Text = "SAVE CONFIG"; SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.Font = "GothamBold"; Instance.new("UICorner", SaveBtn)

local LoadBtn = Instance.new("TextButton", Main)
LoadBtn.Size = UDim2.new(0, 140, 0, 40); LoadBtn.Position = UDim2.new(0, 160, 0, 310)
LoadBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 200); LoadBtn.Text = "LOAD CONFIG"; LoadBtn.TextColor3 = Color3.new(1,1,1)
LoadBtn.Font = "GothamBold"; Instance.new("UICorner", LoadBtn)

SaveBtn.MouseButton1Click:Connect(SaveConfig)
LoadBtn.MouseButton1Click:Connect(function()
    LoadConfig()
    -- Ayarlar yüklendikten sonra scripti yeniden başlatmak en garantisidir 
    -- ama biz burada sadece değerleri motorun kullanması için güncelliyoruz.
end)

-- 8. MOTOR (ENGINE)
local AirBlock = Instance.new("Part", workspace); AirBlock.Name = "R_Platform"; AirBlock.Size = Vector3.new(25, 1, 25); AirBlock.Transparency = 0.7; AirBlock.Anchored = true; AirBlock.Color = Color3.fromRGB(255, 140, 0)

RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    
    hum.WalkSpeed = _G.Set.Speed
    if _G.Set.AntiRag then hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false); hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false); hum.PlatformStand = false end

    if _G.Set.Plat then
        AirBlock.CanCollide = true; AirBlock.CFrame = CFrame.new(root.Position.X, _G.Set.Elev, root.Position.Z)
        if hum:GetState() == Enum.HumanoidStateType.Freefall then hum:ChangeState(Enum.HumanoidStateType.Running) end
    else
        AirBlock.CanCollide = false; AirBlock.Position = Vector3.new(0, -1000, 0)
    end
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = v.Character.HumanoidRootPart
            if _G.Set.Hitbox then hrp.Size = Vector3.new(_G.Set.HitboxSize, _G.Set.HitboxSize, _G.Set.HitboxSize); hrp.Transparency = 0.7; hrp.CanCollide = false
            else hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 0; hrp.CanCollide = true end
            local hl = v.Character:FindFirstChild("ESPHL") or Instance.new("Highlight", v.Character); hl.Name = "ESPHL"; hl.Enabled = _G.Set.ESP; hl.FillColor = Color3.fromRGB(255, 140, 0)
        end
    end
end)
