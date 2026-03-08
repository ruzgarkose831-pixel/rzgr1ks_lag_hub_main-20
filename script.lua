local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. TEMİZLİK
local function cleanup()
    if game:GetService("CoreGui"):FindFirstChild("rzgr1ks_V33") then
        game:GetService("CoreGui").rzgr1ks_V33:Destroy()
    end
    if workspace:FindFirstChild("FakeFloor_" .. player.Name) then
        workspace["FakeFloor_" .. player.Name]:Destroy()
    end
end
cleanup()

-- 2. UI ANA YAPI (Boyutlar Küçültüldü)
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "rzgr1ks_V33"
sg.IgnoreGuiInset = true

-- ANA PANEL (240x360 - Daha Küçük)
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 240, 0, 360)
Main.Position = UDim2.new(0.5, -120, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(255, 130, 0)
Stroke.Thickness = 1.5

-- SARI TOP (Açma Butonu)
local OpenBtn = Instance.new("TextButton", sg)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 15, 0.5, -25)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
OpenBtn.Text = "HUB"
OpenBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenBtn).Thickness = 2

-- KAYDIRILABİLİR LİSTE
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -50)
Scroll.Position = UDim2.new(0, 5, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2.5, 0)
Scroll.ScrollBarThickness = 0

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 6)
UIList.HorizontalAlignment = "Center"

-- BAŞLIK
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "rzgr1ks V33"
Title.TextColor3 = Color3.fromRGB(255, 130, 0)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13

-- KAPATMA (Sarı Topa Dönüştürür)
local Cls = Instance.new("TextButton", Main)
Cls.Size = UDim2.new(0, 25, 0, 25); Cls.Position = UDim2.new(1, -30, 0, 5)
Cls.Text = "X"; Cls.BackgroundColor3 = Color3.new(0.6, 0, 0); Cls.TextColor3 = Color3.new(1, 1, 1)

Cls.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

-- AYARLAR VE BYPASS
_G.HighWalk = false
_G.FlyHeight = 8
_G.SpeedVal = 70
_G.AntiRagdoll = false

local FakeFloor = Instance.new("Part", workspace)
FakeFloor.Name = "FakeFloor_" .. player.Name
FakeFloor.Size = Vector3.new(10, 1, 10)
FakeFloor.Transparency = 1
FakeFloor.Anchored = true
FakeFloor.CanCollide = false

-- UI OLUŞTURUCULAR
local function createToggle(name, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(0, 210, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = " " .. name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextXAlignment = "Left"
    btn.Font = "Gotham"
    btn.TextSize = 11
    Instance.new("UICorner", btn)
    
    local act = false
    btn.MouseButton1Click:Connect(function()
        act = not act
        btn.Text = act and (" " .. name .. ": ON") or (" " .. name .. ": OFF")
        btn.TextColor3 = act and Color3.fromRGB(255, 130, 0) or Color3.new(1, 1, 1)
        callback(act)
    end)
end

-- ÖZELLİKLERİ EKLE
createToggle("High Walk (Bypass)", function(v) _G.HighWalk = v end)
createToggle("Anti-Ragdoll", function(v) _G.AntiRagdoll = v end)
createToggle("Infinite Jump", function(v) _G.InfJump = v end)

-- MOTOR
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    if hum and root then
        hum.WalkSpeed = _G.SpeedVal
        
        -- High Walk Bypass (Sahte Zemin)
        if _G.HighWalk then
            hum:ChangeState(Enum.HumanoidStateType.Running)
            FakeFloor.CFrame = root.CFrame * CFrame.new(0, -(_G.FlyHeight / 2), 0)
            FakeFloor.CanCollide = true
            root.Velocity = Vector3.new(root.Velocity.X, 0.05, root.Velocity.Z)
        else
            FakeFloor.CanCollide = false
            FakeFloor.Position = Vector3.new(0, -1000, 0)
        end

        -- Anti-Ragdoll
        if _G.AntiRagdoll then
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            if hum.PlatformStand then hum.PlatformStand = false end
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if _G.InfJump and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(3)
    end
end)
