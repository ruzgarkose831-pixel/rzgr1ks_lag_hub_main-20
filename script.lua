--[[
    @project: RZGR1KS DUEL - FINAL FLAWLESS GUI
    @fix: AutomaticCanvasSize (Butonlar asla kaybolmaz), Mobile Touch Sliders, No Camera Glitch
]]--

if _G.RZGR_ABSOLUTE_FINAL then return end
_G.RZGR_ABSOLUTE_FINAL = true

local Services = setmetatable({}, {__index = function(_, k) return game:GetService(k) end})
local Local = {
    Player = Services.Players.LocalPlayer,
    Camera = workspace.CurrentCamera
}

local Registry = {
    States = {
        Combat = { Silent = false, Hitbox = false, HSize = 25, Spin = false, SpinSpeed = 50 },
        Movement = { Speed = false, Vel = 100, Jump = 50, Grav = 196.2 },
        Visuals = { Esp = false, Xray = false },
        Misc = { AntiRagdoll = false }
    }
}

-- // CORE LOGIC
local function GetTarget()
    local T, D = nil, math.huge
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= Local.Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local Pos, OnScreen = Local.Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if OnScreen then
                local Mag = (Vector2.new(Pos.X, Pos.Y) - Services.UIS:GetMouseLocation()).Magnitude
                if Mag < D then D = Mag; T = p.Character.HumanoidRootPart end
            end
        end
    end
    return T
end

-- Kamerayı bozmayan, sadece mermiyi yönlendiren Raycast hook
local OldNC; OldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    if not checkcaller() and Registry.States.Combat.Silent then
        if Method == "Raycast" then
            local T = GetTarget()
            if T then Args[2] = (T.Position - Args[1]).Unit * 1000 return OldNC(self, unpack(Args)) end
        elseif Method == "FindPartOnRayWithIgnoreList" or Method == "FindPartOnRay" then
            local T = GetTarget()
            if T then Args[1] = Ray.new(Args[1].Origin, (T.Position - Args[1].Origin).Unit * 1000) return OldNC(self, unpack(Args)) end
        end
    end
    return OldNC(self, ...)
end)

Services.RunService.Heartbeat:Connect(function()
    local Char = Local.Player.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    
    if Root and Hum then
        -- Spinbot
        if Registry.States.Combat.Spin then
            Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(Registry.States.Combat.SpinSpeed), 0)
        end
        
        -- Speed & Jump
        if Registry.States.Movement.Speed and Hum.MoveDirection.Magnitude > 0 then
            Root.AssemblyLinearVelocity = Vector3.new(Hum.MoveDirection.X * Registry.States.Movement.Vel, Root.AssemblyLinearVelocity.Y, Hum.MoveDirection.Z * Registry.States.Movement.Vel)
        end
        Hum.JumpPower = Registry.States.Movement.Jump
        workspace.Gravity = Registry.States.Movement.Grav
        
        -- Anti Ragdoll
        if Registry.States.Misc.AntiRagdoll then Hum.PlatformStand = false end
    end
    
    -- X-Ray
    if Registry.States.Visuals.Xray then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(Char) then v.LocalTransparencyModifier = 0.6 end
        end
    end
    
    -- Hitbox & ESP
    if Registry.States.Combat.Hitbox then
        for _, p in ipairs(Services.Players:GetPlayers()) do
            if p ~= Local.Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(Registry.States.Combat.HSize, Registry.States.Combat.HSize, Registry.States.Combat.HSize)
                p.Character.HumanoidRootPart.Transparency = 0.7; p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
end)

-- // UI KUSURSUZ TASARIM & OTOMATİK BOYUTLANDIRMA
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 320, 0, 400) -- Görünür boyut
Main.Position = UDim2.new(0.5, -160, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true -- Mobil Sürükleme Kesin Çalışır
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "RZGR1KS DUEL V48"; Title.TextColor3 = Color3.fromRGB(255, 40, 40)
Title.Font = "GothamBold"; Title.TextSize = 15; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 45, 0, 45); MinBtn.Position = UDim2.new(1, -45, 0, 0)
MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.Font = "GothamBold"; MinBtn.TextSize = 25; MinBtn.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -55)
Scroll.Position = UDim2.new(0, 10, 0, 50)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.BorderSizePixel = 0
-- Butonların kaybolmasını %100 engelleyen ayar:
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = "Center"

-- // MOBİL KUSURSUZ BUTON & SLIDER FONKSİYONLARI
local function AddToggle(txt, sub, key)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = txt..": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 12; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        b.Text = txt..(Registry.States[sub][key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Registry.States[sub][key] and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 30, 30)
        if key == "Xray" and not Registry.States[sub][key] then ToggleXray(false) end
    end)
end

local function AddSlider(txt, min, max, sub, key)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(1, 0, 0, 50); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt..": "..Registry.States[sub][key]; l.TextColor3 = Color3.new(0.8,0.8,0.8); l.BackgroundTransparency = 1; l.Font = "Gotham"; l.TextSize = 11
    local bar = Instance.new("TextButton", f); bar.Size = UDim2.new(1, 0, 0, 6); bar.Position = UDim2.new(0, 0, 0, 30); bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50); bar.Text = ""
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((Registry.States[sub][key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 40, 40); fill.BorderSizePixel = 0
    
    local dragging = false
    local function Update(inputPos)
        local percent = math.clamp((inputPos - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        local val = math.floor(min + (percent * (max - min)))
        l.Text = txt..": "..val; Registry.States[sub][key] = val
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; Update(input.Position.X)
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    Services.UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input.Position.X)
        end
    end)
end

-- // KÜÇÜLTME
local isExp = true
MinBtn.MouseButton1Click:Connect(function()
    isExp = not isExp
    MinBtn.Text = isExp and "-" or "+"
    Scroll.Visible = isExp
    Main:TweenSize(isExp and UDim2.new(0, 320, 0, 400) or UDim2.new(0, 320, 0, 45), "Out", "Quart", 0.3, true)
end)

-- // LİSTE (TÜM ÖZELLİKLER BURADA)
AddToggle("Silent Aim", "Combat", "Silent")
AddToggle("Hitbox Expander", "Combat", "Hitbox")
AddSlider("Hitbox Radius", 2, 200, "Combat", "HSize")
AddToggle("Spinbot", "Combat", "Spin")
AddSlider("Spin Speed", 10, 150, "Combat", "SpinSpeed")
AddToggle("Speed Bypass", "Movement", "Speed")
AddSlider("Speed Value", 16, 500, "Movement", "Vel")
AddSlider("Jump Power", 50, 500, "Movement", "Jump")
AddSlider("Gravity Control", 0, 196, "Movement", "Grav")
AddToggle("Material X-RAY", "Visuals", "Xray")
AddToggle("Anti Ragdoll", "Misc", "AntiRagdoll")

-- // SOSYAL LİNKLER
local ytBtn = Instance.new("TextButton", Scroll); ytBtn.Size = UDim2.new(1, 0, 0, 40); ytBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0); ytBtn.Text = "SUBSCRIBE YT: rzgr1ks"; ytBtn.TextColor3 = Color3.new(1,1,1); ytBtn.Font = "GothamBold"; Instance.new("UICorner", ytBtn)
ytBtn.MouseButton1Click:Connect(function() setclipboard("https://youtube.com/@rzgr1ks") end)

local dcBtn = Instance.new("TextButton", Scroll); dcBtn.Size = UDim2.new(1, 0, 0, 40); dcBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242); dcBtn.Text = "JOIN DISCORD SERVER"; dcBtn.TextColor3 = Color3.new(1,1,1); dcBtn.Font = "GothamBold"; Instance.new("UICorner", dcBtn)
dcBtn.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/XpbcvVdU") end)
