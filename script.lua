--[[
    @project: RZGR1KS DUEL V48 - THE TRUE ORIGINAL
    @fix: 100% Original V23 GUI + Bulletproof Mobile Sliders
]]--

if _G.RZGR_TRUE_ORIGINAL then return end
_G.RZGR_TRUE_ORIGINAL = true

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

-- // X-RAY TOGGLE
local function ToggleXray(state)
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(Local.Player.Character) then
            v.LocalTransparencyModifier = state and 0.6 or 0
        end
    end
end

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

local OldNC; OldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    if not checkcaller() and Registry.States.Combat.Silent and (Method == "Raycast" or Method:find("PartOnRay")) then
        local T = GetTarget()
        if T then
            if Method == "Raycast" then Args[2] = (T.Position - Args[1]).Unit * 1000 end
            return OldNC(self, unpack(Args))
        end
    end
    return OldNC(self, ...)
end)

Services.RunService.Heartbeat:Connect(function()
    local Char = Local.Player.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    
    -- SPINBOT
    if Registry.States.Combat.Spin and Root then
        Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(Registry.States.Combat.SpinSpeed), 0)
    end

    -- MOVEMENT
    if Root and Hum then
        if Registry.States.Movement.Speed and Hum.MoveDirection.Magnitude > 0 then
            Root.AssemblyLinearVelocity = Vector3.new(Hum.MoveDirection.X * Registry.States.Movement.Vel, Root.AssemblyLinearVelocity.Y, Hum.MoveDirection.Z * Registry.States.Movement.Vel)
        end
        Hum.JumpPower = Registry.States.Movement.Jump
        workspace.Gravity = Registry.States.Movement.Grav
    end
    
    -- XRAY CONTINUOUS FIX
    if Registry.States.Visuals.Xray then ToggleXray(true) end
    
    -- HITBOX
    if Registry.States.Combat.Hitbox then
        for _, p in ipairs(Services.Players:GetPlayers()) do
            if p ~= Local.Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(Registry.States.Combat.HSize, Registry.States.Combat.HSize, Registry.States.Combat.HSize)
                p.Character.HumanoidRootPart.Transparency = 0.7; p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
end)

-- // UI RESTORATION (ORİJİNAL TASARIM - 350 GENİŞLİK)
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 350, 0, 45)
Main.Position = UDim2.new(0.5, -175, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

-- // MOBİL SÜRÜKLEME FİKSİ (ESKİSİ GİBİ SORUNSUZ)
local d, s, p
Main.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        d = true; s = i.Position; p = Main.Position
    end
end)
Services.UIS.InputChanged:Connect(function(i)
    if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - s
        Main.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y)
    end
end)
Services.UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end
end)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(0, 250, 0, 45); Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "RZGR1KS DUEL V23"; Title.TextColor3 = Color3.fromRGB(255, 40, 40)
Title.Font = "GothamBold"; Title.TextSize = 14; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 45, 0, 45); MinBtn.Position = UDim2.new(1, -50, 0, 0)
MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.Font = "GothamBold"; MinBtn.TextSize = 25; MinBtn.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 0, 320); Scroll.Position = UDim2.new(0, 10, 0, 50)
Scroll.Visible = false; Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2
Scroll.BorderSizePixel = 0; Scroll.CanvasSize = UDim2.new(0, 0, 0, 750)
local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 10); Layout.HorizontalAlignment = "Center"

-- // COMPONENT BUILDERS
local function AddToggle(txt, sub, key)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, 310, 0, 40); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = txt..": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 12; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        b.Text = txt..(Registry.States[sub][key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Registry.States[sub][key] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(30, 30, 30)
        if key == "Xray" and not Registry.States[sub][key] then ToggleXray(false) end
    end)
end

-- // KUSURSUZ MOBİL SLIDER FİKSİ (YAĞ GİBİ KAYAR)
local function AddSlider(txt, min, max, sub, key)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(0, 310, 0, 50); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt..": "..Registry.States[sub][key]; l.TextColor3 = Color3.new(0.8,0.8,0.8); l.BackgroundTransparency = 1; l.Font = "Gotham"; l.TextSize = 10
    local bar = Instance.new("TextButton", f); bar.Size = UDim2.new(1, 0, 0, 6); bar.Position = UDim2.new(0, 0, 0, 30); bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50); bar.Text = ""
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((Registry.States[sub][key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 40, 40); fill.BorderSizePixel = 0
    
    local draggingSlider = false
    local function Update(posX)
        local percent = math.clamp((posX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        local val = math.floor(min + (percent * (max - min)))
        l.Text = txt..": "..val; Registry.States[sub][key] = val
    end
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            Update(input.Position.X)
        end
    end)
    
    Services.UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)
    
    Services.UIS.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input.Position.X)
        end
    end)
end

-- // MINIMIZE / EXPAND
local isExpanded = false
MinBtn.MouseButton1Click:Connect(function()
    isExpanded = not isExpanded
    MinBtn.Text = isExpanded and "X" or "-"
    Scroll.Visible = isExpanded
    Main:TweenSize(isExpanded and UDim2.new(0, 350, 0, 380) or UDim2.new(0, 350, 0, 45), "Out", "Quart", 0.3, true)
end)

-- // LOAD LIST (TÜM ÖZELLİKLER)
AddToggle("Silent Aim", "Combat", "Silent")
AddToggle("Spinbot", "Combat", "Spin")
AddSlider("Spin Speed", 10, 200, "Combat", "SpinSpeed")
AddToggle("Hitbox Expander", "Combat", "Hitbox")
AddSlider("Hitbox Radius", 2, 200, "Combat", "HSize")
AddToggle("Speed Bypass", "Movement", "Speed")
AddSlider("Speed Value", 16, 500, "Movement", "Vel")
AddSlider("Jump Power", 50, 500, "Movement", "Jump")
AddSlider("Gravity Control", 0, 196, "Movement", "Grav")
AddToggle("ESP Highlight", "Visuals", "Esp")
AddToggle("Material X-RAY", "Visuals", "Xray")
AddToggle("Anti Ragdoll", "Misc", "AntiRagdoll")

-- // SOCIALS (SENİN LİNKLERİN)
local ytBtn = Instance.new("TextButton", Scroll); ytBtn.Size = UDim2.new(0, 310, 0, 40); ytBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0); ytBtn.Text = "SUBSCRIBE YT: rzgr1ks"; ytBtn.TextColor3 = Color3.new(1,1,1); ytBtn.Font = "GothamBold"; Instance.new("UICorner", ytBtn)
ytBtn.MouseButton1Click:Connect(function() setclipboard("https://youtube.com/@rzgr1ks") end)

local dcBtn = Instance.new("TextButton", Scroll); dcBtn.Size = UDim2.new(0, 310, 0, 40); dcBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242); dcBtn.Text = "JOIN DISCORD SERVER"; dcBtn.TextColor3 = Color3.new(1,1,1); dcBtn.Font = "GothamBold"; Instance.new("UICorner", dcBtn)
dcBtn.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/XpbcvVdU") end)
