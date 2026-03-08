local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. TEMİZLİK
local function cleanup()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "rzgr1ks_V31" then v:Destroy() end
    end
end
cleanup()

-- 2. LEMON HUB PREMIUM UI
local sg = Instance.new("ScreenGui")
sg.Name = "rzgr1ks_V31"
sg.Parent = game:GetService("CoreGui") or player.PlayerGui
sg.IgnoreGuiInset = true

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 330, 0, 480)
Main.Position = UDim2.new(0.5, -165, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(255, 120, 0) -- Neon Turuncu
Stroke.Thickness = 2

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -50)
Scroll.Position = UDim2.new(0, 5, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2.5, 0)
Scroll.ScrollBarThickness = 2

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 10)
UIList.HorizontalAlignment = "Center"

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "LEMON HUB V31 - PREMIUM"
Title.TextColor3 = Color3.fromRGB(255, 120, 0)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- AYARLAR
_G.Aimbot = false
_G.Hitbox = false
_G.AntiRagdoll = false
_G.Spinbot = false
_G.HighWalk = false
_G.SpeedVal = 70
_G.JumpVal = 50
_G.FlyHeight = 7 -- Havada durma yüksekliği

-- UI BİLEŞENLERİ
local function createToggle(name, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(0, 290, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = "  " .. name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextXAlignment = "Left"
    btn.Font = "Gotham"
    Instance.new("UICorner", btn)
    
    local act = false
    btn.MouseButton1Click:Connect(function()
        act = not act
        btn.Text = act and ("  " .. name .. ": ON") or ("  " .. name .. ": OFF")
        btn.TextColor3 = act and Color3.fromRGB(255, 120, 0) or Color3.new(1, 1, 1)
        callback(act)
    end)
end

local function createSlider(name, min, max, default, callback)
    local sFrame = Instance.new("Frame", Scroll)
    sFrame.Size = UDim2.new(0, 290, 0, 55)
    sFrame.BackgroundTransparency = 1
    
    local lab = Instance.new("TextLabel", sFrame)
    lab.Text = name .. ": " .. default
    lab.Size = UDim2.new(1, 0, 0, 20)
    lab.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    lab.BackgroundTransparency = 1
    
    local bar = Instance.new("TextButton", sFrame)
    bar.Size = UDim2.new(0, 270, 0, 6)
    bar.Position = UDim2.new(0.5, -135, 0, 35)
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    bar.Text = ""
    Instance.new("UICorner", bar)
    
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
    Instance.new("UICorner", fill)
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = UIS.InputChanged:Connect(function(move)
                if move.UserInputType == Enum.UserInputType.MouseButton1 or move.UserInputType == Enum.UserInputType.Touch then
                    local p = math.clamp((move.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(p, 0, 1, 0)
                    local val = math.floor(min + (max - min) * p)
                    lab.Text = name .. ": " .. val
                    callback(val)
                end
            end)
            UIS.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    connection:Disconnect()
                end
            end)
        end
    end)
end

-- ÖZELLİKLERİ EKLE
createToggle("Aimbot Lock", function(v) _G.Aimbot = v end)
createToggle("Hitbox Expander", function(v) _G.Hitbox = v end)
createSlider("Movement Speed", 16, 500, 70, function(v) _G.SpeedVal = v end)
createSlider("Jump Power", 50, 500, 50, function(v) _G.JumpVal = v end)
createToggle("Anti-Ragdoll (God Mode)", function(v) _G.AntiRagdoll = v end)
createToggle("High Walk (Yüksek Yürüme)", function(v) _G.HighWalk = v v31_FixHighWalk(v) end)
createSlider("High Walk Height", 0, 50, 7, function(v) _G.FlyHeight = v end)
createToggle("Spin Bot", function(v) _G.Spinbot = v end)
createToggle("Infinite Jump", function(v) _G.InfJump = v end)

-- 3. MOTOR VE HATA DÜZELTMELERİ
function v31_FixHighWalk(active)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not active and root then
        if root:FindFirstChild("AirWalker") then root.AirWalker:Destroy() end
    end
end

RunService.RenderStepped:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if hum and root then
        hum.WalkSpeed = _G.SpeedVal
        hum.JumpPower = _G.JumpVal
        
        -- HIGH WALK (STUCK FIX)
        if _G.HighWalk then
            local bv = root:FindFirstChild("AirWalker") or Instance.new("BodyVelocity", root)
            bv.Name = "AirWalker"
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Velocity = Vector3.new(0, 0, 0)
            
            -- Işınlanma yerine yumuşak yükselme
            local targetHeight = _G.FlyHeight
            local ray = Ray.new(root.Position, Vector3.new(0, -100, 0))
            local _, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, {char})
            local currentGroundDist = (root.Position.Y - hitPos.Y)
            
            if currentGroundDist < targetHeight then
                root.CFrame = root.CFrame * CFrame.new(0, 0.3, 0)
            elseif currentGroundDist > targetHeight + 1 then
                root.CFrame = root.CFrame * CFrame.new(0, -0.3, 0)
            end
        end
        
        -- ANTI-RAGDOLL
        if _G.AntiRagdoll then
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            if hum.PlatformStand then hum.PlatformStand = false end
            if root.Velocity.Magnitude > 100 then root.Velocity = Vector3.new(0,0,0) end -- Fırlatılmayı engeller
        end
    end

    if _G.Spinbot and root then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(60), 0)
    end
    
    if _G.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(20, 20, 20)
                p.Character.HumanoidRootPart.Transparency = 0.8
                p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
end)

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if _G.InfJump and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(3)
    end
end)

-- KAPATMA
local Cls = Instance.new("TextButton", Main)
Cls.Size = UDim2.new(0, 30, 0, 30); Cls.Position = UDim2.new(1, -35, 0, 5)
Cls.Text = "X"; Cls.BackgroundColor3 = Color3.new(0.6, 0, 0); Cls.TextColor3 = Color3.new(1, 1, 1)
Cls.MouseButton1Click:Connect(function() sg:Destroy() end)
