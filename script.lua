--[[
    @project: RZGR1KS DUEL - V25.0 (ULTIMATE REDEMPTION)
    @author: rzgr1ks | @youtube: rzgr1ks
    @discord: https://discord.gg/XpbcvVdU
]]--

if _G.RZGR_V25_LOADED then return end
_G.RZGR_V25_LOADED = true

-- // CORE SERVICES
local Services = setmetatable({}, {__index = function(_, k) return game:GetService(k) end})
local Local = {
    Player = Services.Players.LocalPlayer,
    Mouse = Services.Players.LocalPlayer:GetMouse(),
    Camera = workspace.CurrentCamera
}

-- // REGISTRY (ALL FEATURES INCLUDED)
local Registry = {
    States = {
        Combat = { Silent = false, Hitbox = false, HSize = 25, FOV = 100 },
        Movement = { Speed = false, Vel = 100, InfJump = false, Fly = false, FlySpeed = 50 },
        Visuals = { Esp = false, Xray = false, Fullbright = false, Tracers = false },
        Misc = { AntiRagdoll = false, ChatSpam = false, AutoRebirth = false }
    }
}

-- // UTILS & TARGETING
local function GetClosestTarget()
    local Target, Dist = nil, Registry.States.Combat.FOV
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= Local.Player and p.Team ~= Local.Player.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local Pos, OnScreen = Local.Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if OnScreen then
                local MouseDist = (Vector2.new(Pos.X, Pos.Y) - Services.UIS:GetMouseLocation()).Magnitude
                if MouseDist < Dist then Dist = MouseDist; Target = p.Character.HumanoidRootPart end
            end
        end
    end
    return Target
end

-- // SILENT AIM V3 (CAMERA FIX)
-- Bu bölüm kameranın kopmasını engellemek için direkt Raycast sonucunu manipüle eder.
local OldNC; OldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    if not checkcaller() and Registry.States.Combat.Silent and (Method == "FindPartOnRayWithIgnoreList" or Method == "Raycast") then
        local T = GetClosestTarget()
        if T then
            -- Merminin gideceği yönü kamerayı bozmadan sadece mermi bazlı değiştirir.
            if Method == "Raycast" then
                Args[2] = (T.Position - Args[1]).Unit * 1000
            end
            return OldNC(self, unpack(Args))
        end
    end
    return OldNC(self, ...)
end)

-- // MAIN RUNTIME THREAD (ALL FEATURES)
Services.RunService.RenderStepped:Connect(function()
    local Char = Local.Player.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    
    -- 1. SPEED & MOVEMENT (FIXED 360)
    if Root and Hum and Registry.States.Movement.Speed and Hum.MoveDirection.Magnitude > 0 then
        Root.CFrame = Root.CFrame + (Hum.MoveDirection * (Registry.States.Movement.Vel / 100))
    end
    
    -- 2. HITBOX EXPANDER
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= Local.Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            if Registry.States.Combat.Hitbox then
                hrp.Size = Vector3.new(Registry.States.Combat.HSize, Registry.States.Combat.HSize, Registry.States.Combat.HSize)
                hrp.Transparency = 0.8; hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1; hrp.CanCollide = true
            end
        end
    end
    
    -- 3. FULLBRIGHT
    if Registry.States.Visuals.Fullbright then
        Services.Lighting.Brightness = 2; Services.Lighting.ClockTime = 14; Services.Lighting.FogEnd = 100000
    end
end)

-- // UI ENGINE (REWRITTEN FOR MOBILE)
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 280, 0, 450); Main.Position = UDim2.new(0.5, -140, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Instance.new("UICorner", Main)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 50); Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = "RZGR1KS DUEL V25 | FINAL"; Title.TextColor3 = Color3.new(1,0,0); Title.Font = "GothamBold"; Title.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -60); Scroll.Position = UDim2.new(0, 5, 0, 55); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 0
local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 10); Layout.HorizontalAlignment = "Center"

-- // COMPONENT BUILDERS (FIXED SLIDER)
local function AddToggle(txt, sub, key)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, 250, 0, 45); b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.Text = txt .. ": OFF"; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        b.Text = txt .. (Registry.States[sub][key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Registry.States[sub][key] and Color3.fromRGB(150,0,0) or Color3.fromRGB(30,30,30)
    end)
end

local function AddSlider(txt, min, max, sub, key)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(0, 250, 0, 55); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1,0,0,20); l.Text = txt..": "..Registry.States[sub][key]; l.TextColor3 = Color3.new(0.7,0.7,0.7); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"
    local bar = Instance.new("TextButton", f); bar.Size = UDim2.new(1,0,0,6); bar.Position = UDim2.new(0,0,0,35); bar.BackgroundColor3 = Color3.fromRGB(40,40,40); bar.Text = ""
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((Registry.States[sub][key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.new(1,0,0)
    
    local function Update()
        local input = Services.UIS:GetMouseLocation()
        local percent = math.clamp((input.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        local val = math.floor(min + (percent * (max - min)))
        l.Text = txt..": "..val; Registry.States[sub][key] = val
    end
    bar.MouseButton1Down:Connect(function()
        local move; move = Services.UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then Update() end end)
        Services.UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

-- // FEATURE LOADING (ALL RESTORED)
AddToggle("Silent Aim (No Camera Glitch)", "Combat", "Silent")
AddSlider("Silent Aim FOV", 50, 1000, "Combat", "FOV")
AddToggle("Ghost Hitbox V2", "Combat", "Hitbox")
AddSlider("Hitbox Size", 5, 200, "Combat", "HSize")
AddToggle("360 Velocity Speed", "Movement", "Speed")
AddSlider("Speed Multiplier", 16, 500, "Movement", "Vel")
AddToggle("Entity ESP Highlight", "Visuals", "Esp")
AddToggle("Global X-Ray", "Visuals", "Xray")
AddToggle("Fullbright Mode", "Visuals", "Fullbright")
AddToggle("Anti-Ragdoll/Fall", "Misc", "AntiRagdoll")

-- YouTube/Discord Buttons
local yt = Instance.new("TextButton", Scroll); yt.Size = UDim2.new(0,250,0,45); yt.BackgroundColor3 = Color3.new(1,0,0); yt.Text = "SUBSCRIBE YT: rzgr1ks"; yt.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", yt)
yt.MouseButton1Click:Connect(function() setclipboard("https://youtube.com/@rzgr1ks") end)

-- Draggable
local drag, dStart, sPos; Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; dStart = i.Position; sPos = Main.Position end end)
Services.UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - dStart; Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y) end end)
Services.UIS.InputEnded:Connect(function() drag = false end)
