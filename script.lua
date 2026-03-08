local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- 1. ESKİ GUI'Yİ SİLME (Bunu en başa koydum ki hata vermesin)
local old = player:WaitForChild("PlayerGui"):FindFirstChild("rzgr1ks_FinalFix")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "rzgr1ks_FinalFix"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 2. AYARLAR (States)
_G.Aimbot = false
_G.AimbotFOV = 150
_G.SpeedBoost = false
_G.SpeedValue = 60
_G.JumpHeight = 15 -- Zıplama yüksekliği (JumpPower yerine Height daha stabil)
_G.InfJump = false
_G.ESP = false

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 460
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 200, 0) -- Sarı

-- 3. [SARI TOP / OPEN BUTTON] (GUI KAPANINCA ÇIKAR)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(0, 10, 0.45, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0) -- Sarı
OpenBtn.Text = "OPEN"
OpenBtn.TextColor3 = Color3.white
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.Visible = false -- Başlangıçta kapalı
OpenBtn.ZIndex = 100 -- En üstte olması için
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

-- 4. [ANA MENÜ FRAME]
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 280, 0, 360) -- Biraz daha dar, dikey bir menü
Main.Position = UDim2.new(0.5, -140, 0.25, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.Active = true
Main.Draggable = true -- Taşınabilir
Main.Visible = true -- Başlangıçta açık
Main.ZIndex = 50
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Başlık
local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.Text = "rzgr1ks Hub V13"
Header.TextColor3 = Color3.fromRGB(0, 255, 170) -- Yeşilimsi başlık
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 16
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.white
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Kırmızı kapat
Instance.new("UICorner", CloseBtn)

-- Özellikler Listesi
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2, 0) -- Aşağı kaydırılabilir
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 170)
Scroll.ZIndex = 60

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 10)
UIList.ZIndex = 61

-- 5. [ÖZELLİK EKLEME FONKSİYONLARI]
local function addToggle(name, callback)
    local Frame = Instance.new("Frame", Scroll)
    Frame.Size = UDim2.new(1, -5, 0, 40); Frame.BackgroundTransparency = 1; Frame.ZIndex = 70
    
    local Lbl = Instance.new("TextLabel", Frame)
    Lbl.Size = UDim2.new(0.7, 0, 1, 0); Lbl.Text = name; Lbl.TextColor3 = Color3.white; Lbl.Font = "GothamSemibold"; Lbl.TextSize = 14; Lbl.TextXAlignment = "Left"; Lbl.BackgroundTransparency = 1; Lbl.ZIndex = 71
    
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0, 50, 0, 24); Btn.Position = UDim2.new(1, -55, 0.5, -12); Btn.BackgroundColor3 = Color3.fromRGB(40,40,40); Btn.Text = "OFF"; Btn.TextColor3 = Color3.white; Btn.ZIndex = 72; Instance.new("UICorner", Btn).CornerRadius = UDim.new(1,0)
    
    local active = false
    Btn.Activated:Connect(function()
        active = not active
        Btn.Text = active and "ON" or "OFF"
        Btn.BackgroundColor3 = active and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(40, 40, 40)
        callback(active)
    end)
end

-- 6. [ÖZELLİKLERİ EKLE]
addToggle("Aimbot (Smart Lock)", function(v) _G.Aimbot = v end)
addToggle("Speed Bypass (Move)", function(v) _G.SpeedBoost = v end)
addToggle("Player ESP", function(v) _G.ESP = v end)
addToggle("Infinite Jump", function(v) _G.InfJump = v end)

-- 7. [AÇMA/KAPATMA LOGIC] (Sarı Top)
CloseBtn.Activated:Connect(function()
    Main.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.Activated:Connect(function()
    Main.Visible = true
    OpenBtn.Visible = false
end)

-- 8. [HEDEF BULMA MANTIĞI]
local function getClosest()
    local target, dist = nil, _G.AimbotFOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid").Health > 0 then
            local pos, vis = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if mag < dist then target = p; dist = mag end
            end
        end
    end
    return target
end

-- 9. [ANA MOTOR (Loop) - HIZ VE AIMBOT]
RunService.RenderStepped:Connect(function()
    -- FOV
    FOVCircle.Visible = _G.Aimbot
    FOVCircle.Radius = _G.AimbotFOV
    FOVCircle.Position = UIS:GetMouseLocation()

    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        local root = char.HumanoidRootPart
        
        -- Zıplama Gücünü Sabitle (15)
        hum.UseJumpPower = false -- JumpHeight kullanması için
        hum.JumpHeight = _G.JumpHeight
        
        -- SPEED BYPASS (CFrame Teleport)
        if _G.SpeedBoost and hum.MoveDirection.Magnitude > 0 then
            -- Elinde bir eşya var mı kontrol et
            local currentSpeed = char:FindFirstChildOfClass("Tool") and 30 or _G.SpeedValue
            root.CFrame = root.CFrame + (hum.MoveDirection * (currentSpeed / 60))
        end
    end

    -- AIMBOT (Hard Lock)
    if _G.Aimbot then
        local target = getClosest()
        if target and target.Character:FindFirstChild("HumanoidRootPart") and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            -- Kamerayı hedefe kilitle
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
        end
    end

    -- ESP
    if _G.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                if not p.Character:FindFirstChild("ESPHighlight") then
                    local h = Instance.new("Highlight", p.Character)
                    h.Name = "ESPHighlight"; h.FillColor = Color3.fromRGB(0, 255, 170)
                end
            end
        end
    else
        -- Clean ESP when off
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("ESPHighlight") then
                p.Character.ESPHighlight:Destroy()
            end
        end
    end
end)

-- INFINITE JUMP FIXED
UIS.JumpRequest:Connect(function()
    if _G.InfJump and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
