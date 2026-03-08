local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- 1. KÖKTEN TEMİZLİK
local targetGui = game:GetService("CoreGui") or player:WaitForChild("PlayerGui")
for _, v in pairs(targetGui:GetChildren()) do
    if v.Name == "rzgr1ks_V26" then v:Destroy() end
end
for _, v in pairs(player.PlayerGui:GetChildren()) do
    if string.find(v.Name, "rzgr1ks") then v:Destroy() end
end

-- 2. ANA YAPI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "rzgr1ks_V26"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999999

-- Güvenli Parent (Delta/CoreGui desteklemiyorsa PlayerGui'ye atar)
local success = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not success then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

-- STATES
_G.Aimbot = false
_G.SpeedBoost = false
_G.FakeLag = false
_G.ServerLag = false
_G.InfJump = false
_G.Hitbox = false
_G.Spinbot = false
_G.SpeedValue = 70
_G.HitboxSize = 25

-- [AÇMA BUTONU]
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(0, 10, 0.45, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
OpenBtn.Text = "MENU"
OpenBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 14
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

-- [ANA PANEL]
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 390)
Main.Position = UDim2.new(0.5, -130, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(255, 200, 0)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

-- Başlık
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "rzgr1ks Hub V26"
Title.TextColor3 = Color3.fromRGB(255, 200, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Instance.new("UICorner", Title)

-- Kapatma
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Close.Font = Enum.Font.GothamBold
Instance.new("UICorner", Close)

-- [BUTONLARIN KONULACAĞI ÇERÇEVE]
local ButtonContainer = Instance.new("Frame", Main)
ButtonContainer.Size = UDim2.new(1, -20, 1, -50)
ButtonContainer.Position = UDim2.new(0, 10, 0, 45)
ButtonContainer.BackgroundTransparency = 1

-- OTOMATİK DİZİLİM (Bu sayede butonlar kaybolmaz)
local UIList = Instance.new("UIListLayout", ButtonContainer)
UIList.Padding = UDim.new(0, 8)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- 3. BUTON OLUŞTURUCU (Hata Çözüldü)
local layoutOrder = 1
local function createButton(text, callback)
    local b = Instance.new("TextButton", ButtonContainer)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    b.Text = text .. ": OFF"
    b.TextColor3 = Color3.fromRGB(255, 255, 255) -- HATA BURADAYDI, DÜZELTİLDİ
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.LayoutOrder = layoutOrder
    layoutOrder = layoutOrder + 1
    Instance.new("UICorner", b)

    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = active and (text .. ": ON") or (text .. ": OFF")
        b.BackgroundColor3 = active and Color3.fromRGB(255, 180, 0) or Color3.fromRGB(45, 45, 45)
        callback(active)
    end)
end

-- ÖZELLİKLER (Sırasıyla Otomatik Dizilir)
createButton("Aimbot Lock", function(v) _G.Aimbot = v end)
createButton("Hitbox Expander", function(v) _G.Hitbox = v end)
createButton("Speed Hack", function(v) _G.SpeedBoost = v end)
createButton("Spinbot (Anti-Aim)", function(v) _G.Spinbot = v end)
createButton("Fake Lag (Blink)", function(v) _G.FakeLag = v end)
createButton("Server Lag (Stress)", function(v) _G.ServerLag = v end)
createButton("Infinite Jump", function(v) _G.InfJump = v end)

-- AÇ/KAPAT BAĞLANTILARI
Close.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

-- 4. ANA MOTOR (Engine)
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    if _G.SpeedBoost and hum then hum.WalkSpeed = _G.SpeedValue end
    if _G.Spinbot and root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(50), 0) end
    if _G.FakeLag and root then root.Anchored = true; task.wait(0.03); root.Anchored = false end
    
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

    if _G.ServerLag and char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then for i=1, 15 do tool:Activate() end end
    end

    if _G.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local target = nil; local dist = 300
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                local pos, vis = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if vis then
                    local m = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if m < dist then target = p; dist = m end
                end
            end
        end
        if target then camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.HumanoidRootPart.Position) end
    end
end)

UIS.JumpRequest:Connect(function()
    if _G.InfJump and player.Character then player.Character.Humanoid:ChangeState(3) end
end)
