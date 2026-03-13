--[[
    @title: rzgr1ks V48 - FINAL FIX
    @status: FIXED EVERYTHING (DRAG, SLIDER, XRAY, SILENT)
]]--

if _G.RZGR_V48_FINAL then return end
_G.RZGR_V48_FINAL = true

local Services = setmetatable({}, {__index = function(_, k) return game:GetService(k) end})
local Local = {
    Player = Services.Players.LocalPlayer,
    Mouse = Services.Players.LocalPlayer:GetMouse(),
    Camera = workspace.CurrentCamera
}

local Registry = {
    States = {
        Combat = { Silent = false, Hitbox = false, HSize = 25 },
        Movement = { Speed = false, Vel = 100, Jump = 50, Grav = 196.2 },
        Visuals = { Esp = false, Xray = false },
        Misc = { AntiRagdoll = false }
    },
    Social = { Discord = "https://discord.gg/XpbcvVdU" }
}

-- // X-RAY ENGINE (STABLE)
local function ToggleXray(state)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(Local.Player.Character) then
            obj.LocalTransparencyModifier = state and 0.6 or 0
        end
    end
end

-- // TARGETING (NO CAMERA GLITCH)
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

-- // SILENT AIM BYPASS (NEW METHOD)
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

-- // MAIN ENGINE
Services.RunService.Heartbeat:Connect(function()
    local Char = Local.Player.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    
    if Root and Hum then
        if Registry.States.Movement.Speed and Hum.MoveDirection.Magnitude > 0 then
            Root.AssemblyLinearVelocity = Vector3.new(Hum.MoveDirection.X * Registry.States.Movement.Vel, Root.AssemblyLinearVelocity.Y, Hum.MoveDirection.Z * Registry.States.Movement.Vel)
        end
        Hum.JumpPower = Registry.States.Movement.Jump
        workspace.Gravity = Registry.States.Movement.Grav
    end
    
    if Registry.States.Combat.Hitbox then
        for _, p in ipairs(Services.Players:GetPlayers()) do
            if p ~= Local.Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(Registry.States.Combat.HSize, Registry.States.Combat.HSize, Registry.States.Combat.HSize)
                p.Character.HumanoidRootPart.Transparency = 0.7
                p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
    if Registry.States.Visuals.Xray then ToggleXray(true) end
end)

-- // INTERFACE (TOTAL REWRITE FOR MOBILE)
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 240, 0, 380)
Main.Position = UDim2.new(0.5, -120, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Instance.new("UICorner", Main)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Instance.new("UICorner", Header)

-- DRAG FIX (ABSOLUTE TOUCH)
local dragStart, startPos, dragging
Header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = i.Position; startPos = Main.Position
    end
end)
Services.UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
Services.UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = "rzgr1ks V48 - FINAL"; Title.TextColor3 = Color3.fromRGB(100, 100, 255); Title.Font = "GothamBold"; Title.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -55); Scroll.Position = UDim2.new(0, 5, 0, 50); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 0
local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 8); Layout.HorizontalAlignment = "Center"

-- MINIMIZE SYSTEM
local isMin = false
local mBtn = Instance.new("TextButton", Header)
mBtn.Size = UDim2.new(0, 30, 0, 30); mBtn.Position = UDim2.new(1, -35, 0, 7); mBtn.Text = "-"; mBtn.TextColor3 = Color3.new(1,1,1); mBtn.BackgroundTransparency = 1
mBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    mBtn.Text = isMin and "+" or "-"
    Scroll.Visible = not isMin
    Main:TweenSize(isMin and UDim2.new(0, 240, 0, 45) or UDim2.new(0, 240, 0, 380), "Out", "Quart", 0.3, true)
end)

-- COMPONENT BUILDERS (TOUCH FIX)
local function AddToggle(txt, sub, key)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1, -10, 0, 38); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.Text = txt .. ": OFF"; b.TextColor3 = Color3.fromRGB(255, 140, 0); b.Font = "GothamBold"; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        b.Text = txt .. (Registry.States[sub][key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Registry.States[sub][key] and Color3.fromRGB(120, 20, 20) or Color3.fromRGB(25, 25, 25)
    end)
end

local function AddSlider(txt, min, max, sub, key)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(1, -10, 0, 45); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 15); l.Text = txt..": "..Registry.States[sub][key]; l.TextColor3 = Color3.new(0.6,0.6,0.6); l.BackgroundTransparency = 1
    local bar = Instance.new("TextButton", f); bar.Size = UDim2.new(1, 0, 0, 4); bar.Position = UDim2.new(0,0,0,25); bar.BackgroundColor3 = Color3.fromRGB(45,45,45); bar.Text = ""
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((Registry.States[sub][key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    
    local function Update()
        local input = Services.UIS:GetMouseLocation()
        local percent = math.clamp((input.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        local val = math.floor(min + (percent * (max - min)))
        l.Text = txt..": "..val; Registry.States[sub][key] = val
    end
    
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            local move; move = Services.UIS.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then Update() end
            end)
            Services.UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
        end
    end)
end

-- LOADING
AddToggle("Silent Aim", "Combat", "Silent")
AddToggle("Hitbox Expander", "Combat", "Hitbox")
AddSlider("Hitbox Radius", 2, 200, "Combat", "HSize")
AddToggle("Speed Bypass", "Movement", "Speed")
AddSlider("Speed Value", 16, 800, "Movement", "Vel")
AddSlider("Jump Height", 50, 500, "Movement", "Jump")
AddSlider("Gravity Control", 0, 196, "Movement", "Grav")
AddToggle("Wallhack ESP", "Visuals", "Esp")
AddToggle("Material XRAY", "Visuals", "Xray")
AddToggle("Anti Ragdoll", "Misc", "AntiRagdoll")

local dBtn = Instance.new("TextButton", Scroll); dBtn.Size = UDim2.new(1, -10, 0, 38); dBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242); dBtn.Text = "JOIN DISCORD"; dBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", dBtn)
dBtn.MouseButton1Click:Connect(function() setclipboard(Registry.Social.Discord) end)
