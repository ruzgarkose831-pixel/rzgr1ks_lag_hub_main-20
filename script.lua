--[[
    @project: RZGR1KS DUEL V48
    @feature: SPINBOT ADDED (STABLE)
    @fix: Visible Buttons & Drag Fix
]]--

if _G.RZGR_V48_SPIN_LOADED then return end
_G.RZGR_V48_SPIN_LOADED = true

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

-- // CORE ENGINES
Services.RunService.Heartbeat:Connect(function()
    local Char = Local.Player.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    
    -- 1. Spinbot (Optimal Speed)
    if Registry.States.Combat.Spin and Root then
        Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(Registry.States.Combat.SpinSpeed), 0)
    end

    -- 2. Movement Features
    if Root and Hum then
        if Registry.States.Movement.Speed and Hum.MoveDirection.Magnitude > 0 then
            Root.AssemblyLinearVelocity = Vector3.new(Hum.MoveDirection.X * Registry.States.Movement.Vel, Root.AssemblyLinearVelocity.Y, Hum.MoveDirection.Z * Registry.States.Movement.Vel)
        end
        Hum.JumpPower = Registry.States.Movement.Jump
        workspace.Gravity = Registry.States.Movement.Grav
    end
    
    -- 3. Hitbox Expander
    if Registry.States.Combat.Hitbox then
        for _, p in ipairs(Services.Players:GetPlayers()) do
            if p ~= Local.Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(Registry.States.Combat.HSize, Registry.States.Combat.HSize, Registry.States.Combat.HSize)
                p.Character.HumanoidRootPart.Transparency = 0.7; p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
end)

-- // UI CONSTRUCTION (V23 BLACK BAR STYLE)
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 350, 0, 45)
Main.Position = UDim2.new(0.5, -175, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true -- LEGACY DRAG FOR MOBILE

local Corner = Instance.new("UICorner", Main); Corner.CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(0, 250, 0, 45); Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "RZGR1KS DUEL V23 + SPIN"; Title.TextColor3 = Color3.fromRGB(255, 40, 40)
Title.Font = "GothamBold"; Title.TextSize = 14; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 45, 0, 45); MinBtn.Position = UDim2.new(1, -50, 0, 0)
MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.Font = "GothamBold"; MinBtn.TextSize = 25; MinBtn.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 0, 320); Scroll.Position = UDim2.new(0, 10, 0, 50)
Scroll.Visible = false; Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 3
Scroll.BorderSizePixel = 0; Scroll.CanvasSize = UDim2.new(0, 0, 0, 750)

local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 10); Layout.HorizontalAlignment = "Center"

-- // COMPONENTS
local function AddToggle(txt, sub, key)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, 310, 0, 40); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = txt..": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 12; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        b.Text = txt..(Registry.States[sub][key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Registry.States[sub][key] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(30, 30, 30)
    end)
end

local function AddSlider(txt, min, max, sub, key)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(0, 310, 0, 50); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt..": "..Registry.States[sub][key]; l.TextColor3 = Color3.new(0.8,0.8,0.8); l.BackgroundTransparency = 1; l.Font = "Gotham"; l.TextSize = 10
    local bar = Instance.new("TextButton", f); bar.Size = UDim2.new(1, 0, 0, 6); bar.Position = UDim2.new(0, 0, 0, 30); bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50); bar.Text = ""
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((Registry.States[sub][key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 40, 40); fill.BorderSizePixel = 0
    
    local function Update()
        local input = Services.UIS:GetMouseLocation()
        local percent = math.clamp((input.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0); local val = math.floor(min + (percent * (max - min)))
        l.Text = txt..": "..val; Registry.States[sub][key] = val
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then local move; move = Services.UIS.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then Update() end end) Services.UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end) end end)
end

-- // MINIMIZE LOGIC
local isExpanded = false
MinBtn.MouseButton1Click:Connect(function()
    isExpanded = not isExpanded
    MinBtn.Text = isExpanded and "X" or "-"
    Scroll.Visible = isExpanded
    Main:TweenSize(isExpanded and UDim2.new(0, 350, 0, 420) or UDim2.new(0, 350, 0, 45), "Out", "Quart", 0.3, true)
end)

-- // LOAD LIST
AddToggle("Silent Aim", "Combat", "Silent")
AddToggle("Spinbot", "Combat", "Spin")
AddSlider("Spin Speed", 10, 200, "Combat", "SpinSpeed")
AddToggle("Hitbox Expander", "Combat", "Hitbox")
AddSlider("Hitbox Radius", 2, 200, "Combat", "HSize")
AddToggle("Speed Bypass", "Movement", "Speed")
AddSlider("Speed Value", 16, 800, "Movement", "Vel")
AddSlider("Jump Power", 50, 500, "Movement", "Jump")
AddSlider("Gravity Control", 0, 196, "Movement", "Grav")
AddToggle("ESP Highlight", "Visuals", "Esp")
AddToggle("Material X-RAY", "Visuals", "Xray")
AddToggle("Anti Ragdoll", "Misc", "AntiRagdoll")

-- // SOCIALS
local yt = Instance.new("TextButton", Scroll); yt.Size = UDim2.new(0, 310, 0, 40); yt.BackgroundColor3 = Color3.fromRGB(200, 0, 0); yt.Text = "YT: @rzgr1ks"; yt.TextColor3 = Color3.new(1,1,1); yt.Font = "GothamBold"; Instance.new("UICorner", yt)
yt.MouseButton1Click:Connect(function() setclipboard("https://youtube.com/@rzgr1ks") end)

local dc = Instance.new("TextButton", Scroll); dc.Size = UDim2.new(0, 310, 0, 40); dc.BackgroundColor3 = Color3.fromRGB(88, 101, 242); dc.Text = "DISCORD SERVER"; dc.TextColor3 = Color3.new(1,1,1); dc.Font = "GothamBold"; Instance.new("UICorner", dc)
dc.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/XpbcvVdU") end)
