local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- TEMİZLİK
local old = player.PlayerGui:FindFirstChild("rzgr1ks_V14")
if old then old:Destroy() end

local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "rzgr1ks_V14"
sg.ResetOnSpawn = false

-- AYARLAR
_G.Aimbot = false
_G.SpeedBoost = false
_G.InfJump = false
_G.ESP = false

-- [SARI TOP / OPEN BUTTON]
local OpenBtn = Instance.new("TextButton", sg)
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(0, 5, 0.4, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- Saf Sarı
OpenBtn.Text = "AÇ"
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

-- [ANA PANEL]
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 300, 0, 350)
Main.Position = UDim2.new(0.5, -150, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(255, 255, 0)

-- BAŞLIK
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "rzgr1ks Hub V14"
Title.TextColor3 = Color3.new(1, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20

-- KAPATMA BUTONU
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 40, 0, 40)
Close.Position = UDim2.new(1, -40, 0, 0)
Close.Text = "X"
Close.BackgroundColor3 = Color3.new(1, 0, 0)
Close.TextColor3 = Color3.white

-- BUTON OLUŞTURUCU (En Basit Hal)
local function createBtn(name, pos, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0, 280, 0, 50)
    b.Position = UDim2.new(0, 10, 0, pos)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.Text = name .. " : KAPALI"
    b.TextColor3 = Color3.white
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    
    local active = false
    b.MouseButton1Click:Connect(function() -- Dokunmatik için en garantisi
        active = not active
        b.Text = active and (name .. " : AÇIK") or (name .. " : KAPALI")
        b.BackgroundColor3 = active and Color3.fromRGB(255, 150, 0) or Color3.fromRGB(40, 40, 40)
        callback(active)
    end)
end

-- ÖZELLİKLER (Sırayla Alt Alta)
createBtn("AIMBOT", 60, function(v) _G.Aimbot = v end)
createBtn("SPEED BYPASS", 120, function(v) _G.SpeedBoost = v end)
createBtn("PLAYER ESP", 180, function(v) _G.ESP = v end)
createBtn("INF JUMP", 240, function(v) _G.InfJump = v v end)

-- AÇ/KAPAT MANTIĞI
Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    Main.Visible = true
    OpenBtn.Visible = false
end)

-- ANA DÖNGÜ (Hız ve Aimbot)
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local root = char.HumanoidRootPart
        local hum = char.Humanoid

        -- SPEED BYPASS (CFrame)
        if _G.SpeedBoost and hum.MoveDirection.Magnitude > 0 then
            local s = char:FindFirstChildOfClass("Tool") and 30 or 65
            root.CFrame = root.CFrame + (hum.MoveDirection * (s/60))
        end
        
        -- JUMP FIX
        hum.JumpPower = 15
        hum.UseJumpPower = true
    end

    -- AIMBOT (Auto Lock)
    if _G.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local target = nil
        local dist = 250
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
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
    if _G.InfJump and player.Character then
        player.Character.Humanoid:ChangeState(3)
    end
end)
