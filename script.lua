local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- 1. ESKİLERİ TEMİZLE
for _, v in pairs(player.PlayerGui:GetChildren()) do
    if v.Name == "rzgr1ks_V25" then v:Destroy() end
end

-- 2. ANA YAPI (En Üst Katman)
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "rzgr1ks_V25"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999

-- STATES
_G.Aimbot = false
_G.SpeedBoost = false
_G.FakeLag = false
_G.ServerLag = false
_G.InfJump = false
_G.Hitbox = false
_G.Spinbot = false
_G.SpeedValue = 70
_G.HitboxSize = 25 -- Hitbox büyüklüğü

-- [FLOATING OPEN BUTTON]
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(0, 5, 0.45, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 220, 0)
OpenBtn.Text = "MENU"
OpenBtn.Font = "GothamBold"
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

-- [MAIN PANEL - Boyu uzatıldı]
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 280, 0, 490)
Main.Position = UDim2.new(0.5, -140, 0.15, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(255, 220, 0)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

-- Header
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "rzgr1ks Hub V25"
Title.TextColor3 = Color3.new(1, 1, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = "GothamBold"

-- 3. BUTON OLUŞTURUCU
local function createButton(text, yPos, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0, 240, 0, 45)
    b.Position = UDim2.new(0, 20, 0, yPos)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    b.Text = text .. ": OFF"
    b.TextColor3 = Color3.white
    b.Font = "GothamBold"
    b.TextSize = 14
    Instance.new("UICorner", b)

    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = active and (text .. ": ON") or (text .. ": OFF")
        b.BackgroundColor3 = active and Color3.fromRGB(255, 180, 0) or Color3.fromRGB(45, 45, 45)
        callback(active)
    end)
end

-- ÖZELLİKLERİ EKLE (Alt alta)
createButton("Aimbot Lock", 60, function(v) _G.Aimbot = v end)
createButton("Hitbox Expander", 115, function(v) _G.Hitbox = v end)
createButton("Speed Hack", 170, function(v) _G.SpeedBoost = v end)
createButton("Spinbot (Anti-Aim)", 225, function(v) _G.Spinbot = v end)
createButton("Fake Lag (Blink)", 280, function(v) _G.FakeLag = v end)
createButton("Server Lag (Stress)", 335, function(v) _G.ServerLag = v end)
createButton("Infinite Jump", 390, function(v) _G.InfJump = v end)

-- CLOSE/OPEN
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.new(0.8, 0, 0)
Close.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

-- 4. ANA MOTOR
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    -- SPEED
    if _G.SpeedBoost and hum then
        hum.WalkSpeed = _G.SpeedValue
    end

    -- SPINBOT
    if _G.Spinbot and root then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(50), 0)
    end

    -- FAKE LAG
    if _G.FakeLag and root then
        root.Anchored = true
        task.wait(0.03)
        root.Anchored = false
    end

    -- HITBOX EXPANDER
    if _G.Hitbox then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local eRoot = v.Character.HumanoidRootPart
                eRoot.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                eRoot.Transparency = 0.6
                eRoot.BrickColor = BrickColor.new("Bright yellow")
                eRoot.Material = "Neon"
                eRoot.CanCollide = false
            end
        end
    end

    -- SERVER LAG SPAM
    if _G.ServerLag and char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for i = 1, 15 do
                tool:Activate()
            end
        end
    end

    -- AIMBOT LOCK
    if _G.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local target = nil
        local dist = 300
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                local pos, vis = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if vis then
                    local m = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if m < dist then target = p; dist = m end
                end
            end
        end
        if target then
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
        end
    end
end)

-- INF JUMP
UIS.JumpRequest:Connect(function()
    if _G.InfJump and player.Character then player.Character.Humanoid:ChangeState(3) end
end)
