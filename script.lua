local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. TEMİZLİK
local function cleanup()
    if game:GetService("CoreGui"):FindFirstChild("rzgr1ks_V35") then game:GetService("CoreGui").rzgr1ks_V35:Destroy() end
    if workspace:FindFirstChild("FakeFloor_" .. player.Name) then workspace["FakeFloor_" .. player.Name]:Destroy() end
end
cleanup()

-- 2. UI TASARIMI (Lemon Premium Style)
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "rzgr1ks_V35"

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 240, 0, 400)
Main.Position = UDim2.new(0.5, -120, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(255, 130, 0)

-- SARI TOP (Açma Butonu)
local OpenBtn = Instance.new("TextButton", sg)
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -22)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
OpenBtn.Text = "HUB"
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -50)
Scroll.Position = UDim2.new(0, 5, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 3, 0)
Scroll.ScrollBarThickness = 2

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = "Center"

-- BAŞLIK
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "rzgr1ks V35 - PREMIUM"
Title.TextColor3 = Color3.fromRGB(255, 130, 0)
Title.BackgroundTransparency = 1
Title.Font = "GothamBold"
Title.TextSize = 14

-- AYARLAR
_G.Aimbot = false
_G.Hitbox = false
_G.HighWalk = false
_G.AntiRagdoll = false
_G.Spinbot = false
_G.InfJump = false
_G.ServerLag = false
_G.SpeedVal = 70

-- BUTON YAPICI
local function createToggle(name, callback)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, 210, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.Text = " " .. name .. ": OFF"
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = "Gotham"
    b.TextSize = 11
    Instance.new("UICorner", b)
    
    local act = false
    b.MouseButton1Click:Connect(function()
        act = not act
        b.Text = act and (" " .. name .. ": ON") or (" " .. name .. ": OFF")
        b.TextColor3 = act and Color3.fromRGB(255, 130, 0) or Color3.new(1, 1, 1)
        callback(act)
    end)
end

-- TÜM ÖZELLİKLER GERİ GELDİ
createToggle("Aimbot (V-Locker)", function(v) _G.Aimbot = v end)
createToggle("Hitbox Expander", function(v) _G.Hitbox = v end)
createToggle("High Walk (Bypass)", function(v) _G.HighWalk = v end)
createToggle("Anti-Ragdoll", function(v) _G.AntiRagdoll = v end)
createToggle("Spin Bot (Mevlana)", function(v) _G.Spinbot = v end)
createToggle("Infinite Jump", function(v) _G.InfJump = v end)
createToggle("Server Lag Stress", function(v) _G.ServerLag = v end)

-- KAPATMA/AÇMA MANTIĞI
local Cls = Instance.new("TextButton", Main)
Cls.Size = UDim2.new(0, 25, 0, 25); Cls.Position = UDim2.new(1, -30, 0, 5)
Cls.Text = "X"; Cls.BackgroundColor3 = Color3.new(0.6, 0, 0)
Cls.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

-- FAKE FLOOR (Yükseklik Sabitleme Parçası)
local FakeFloor = Instance.new("Part", workspace)
FakeFloor.Name = "FakeFloor_" .. player.Name
FakeFloor.Size = Vector3.new(15, 1, 15)
FakeFloor.Transparency = 1
FakeFloor.Anchored = true
FakeFloor.CanCollide = false

-- ANA MOTOR
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    -- Speed Hack
    hum.WalkSpeed = _G.SpeedVal

    -- High Walk Fix (Yere Yapışma ve Sonsuz Uçma Çözümü)
    if _G.HighWalk then
        hum:ChangeState(Enum.HumanoidStateType.Running)
        FakeFloor.CFrame = root.CFrame * CFrame.new(0, -3.5, 0)
        FakeFloor.CanCollide = true
        -- Y eksenindeki hızı sıfırla (Sonsuz yükselmeyi durdurur)
        if root.Velocity.Y > 0 then
            root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        end
    else
        FakeFloor.CanCollide = false
        FakeFloor.Position = Vector3.new(0, -1000, 0)
    end

    -- Hitbox Expander (Geri Geldi)
    if _G.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                hrp.Size = Vector3.new(15, 15, 15)
                hrp.Transparency = 0.7
                hrp.CanCollide = false
            end
        end
    end

    -- Aimbot / V-Locker (Geri Geldi)
    if _G.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local cam = workspace.CurrentCamera
        local target = nil
        local shortestDist = 500
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                local pos, vis = cam:WorldToViewportPoint(p.Character.Head.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if mag < shortestDist then
                        target = p
                        shortestDist = mag
                    end
                end
            end
        end
        if target then
            cam.CFrame = CFrame.new(cam.CFrame.Position, target.Character.Head.Position)
        end
    end

    -- Diğer Özellikler
    if _G.AntiRagdoll then
        hum.PlatformStand = false
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end

    if _G.Spinbot then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(60), 0)
    end

    if _G.ServerLag and char:FindFirstChildOfClass("Tool") then
        for i=1, 10 do char:FindFirstChildOfClass("Tool"):Activate() end
    end
end)

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if _G.InfJump and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(3)
    end
end)
