--[[
    @title: RZGR1KS V48 - BYPASS
    @updates: New Spinbot Method, Fixed X-Ray, Mobile Touch Sliders
]]--

if _G.RZGR_FINAL_V48 then return end
_G.RZGR_FINAL_V48 = true

local Services = setmetatable({}, {__index = function(_, k) return game:GetService(k) end})
local Local = {
    Player = Services.Players.LocalPlayer,
    Camera = workspace.CurrentCamera
}

local Registry = {
    States = {
        Combat = { Silent = false, Hitbox = false, HSize = 25, Spin = false, SpinSpeed = 100 },
        Movement = { Speed = false, Vel = 100, Jump = 50, Grav = 196.2 },
        Visuals = { Esp = false, Xray = false },
        Misc = { AntiRagdoll = false }
    },
    Social = { Discord = "https://discord.gg/XpbcvVdU", YT = "https://youtube.com/@rzgr1ks" }
}

-- // X-RAY ENGINE (STABLE VERSION)
local function ToggleXray(state)
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(Local.Player.Character) then
            v.LocalTransparencyModifier = state and 0.6 or 0
        end
    end
end

-- // MAIN ENGINE
Services.RunService.Heartbeat:Connect(function()
    local Char = Local.Player.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    
    -- NEW SPINBOT METHOD (Angular Velocity Style)
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
                p.Character.HumanoidRootPart.Transparency = 0.7
            end
        end
    end
end)

-- // UI ENGINE (SMALLER & COMPACT)
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 260, 0, 40) -- Daha küçük ve şık başlar
Main.Position = UDim2.new(0.5, -130, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- MOBILE DRAG FIX
local dragging, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Main.Position
    end
end)
Services.UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
Services.UIS.InputEnded:Connect(function() dragging = false end)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -50, 0, 40); Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "RZGR1KS V23"; Title.TextColor3 = Color3.fromRGB(255, 50, 50); Title.Font = "GothamBold"; Title.TextSize = 13; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 40, 0, 40); MinBtn.Position = UDim2.new(1, -40, 0, 0)
MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.Font = "GothamBold"; MinBtn.TextSize = 20; MinBtn.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 0, 300); Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.Visible = false; Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2; Scroll.CanvasSize = UDim2.new(0,0,0,650)
local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 8); Layout.HorizontalAlignment = "Center"

-- // MOBILE COMPONENT FIX (TOUCH SLIDERS)
local function AddToggle(txt, sub, key)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1, 0, 0, 38); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.Text = txt..": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        b.Text = txt..(Registry.States[sub][key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Registry.States[sub][key] and Color3.fromRGB(160, 0, 0) or Color3.fromRGB(25, 25, 25)
        if key == "Xray" and not Registry.States[sub][key] then ToggleXray(false) end
    end)
end

local function AddSlider(txt, min, max, sub, key)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(1, 0, 0, 45); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 15); l.Text = txt..": "..Registry.States[sub][key]; l.TextColor3 = Color3.new(0.7,0.7,0.7); l.BackgroundTransparency = 1; l.Font = "Gotham"; l.TextSize = 10
    local bar = Instance.new("Frame", f); bar.Size = UDim2.new(1, 0, 0, 4); bar.Position = UDim2.new(0, 0, 0, 25); bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((Registry.States[sub][key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50); fill.BorderSizePixel = 0
    
    local function Update(input)
        local sizeX = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(sizeX, 0, 1, 0)
        local val = math.floor(min + (sizeX * (max - min)))
        l.Text = txt..": "..val; Registry.States[sub][key] = val
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local move; move = Services.UIS.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then Update(i) end
            end)
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then move:Disconnect() end end)
        end
    end)
end

-- // MINIMIZE
local isExp = false
MinBtn.MouseButton1Click:Connect(function()
    isExp = not isExp
    MinBtn.Text = isExp and "X" or "-"
    Scroll.Visible = isExp
    Main:TweenSize(isExp and UDim2.new(0, 260, 0, 360) or UDim2.new(0, 260, 0, 40), "Out", "Quart", 0.3, true)
end)

-- // LOAD LIST
AddToggle("Silent Aim", "Combat", "Silent")
AddToggle("Spinbot Mode", "Combat", "Spin")
AddSlider("Spin Power", 10, 300, "Combat", "SpinSpeed")
AddToggle("Hitbox Expander", "Combat", "Hitbox")
AddSlider("Hitbox Radius", 2, 200, "Combat", "HSize")
AddToggle("Speed Bypass", "Movement", "Speed")
AddSlider("Speed Value", 16, 500, "Movement", "Vel")
AddSlider("Jump Power", 50, 500, "Movement", "Jump")
AddSlider("Gravity Control", 0, 196, "Movement", "Grav")
AddToggle("Wallhack ESP", "Visuals", "Esp")
AddToggle("Material X-RAY", "Visuals", "Xray")
AddToggle("Anti Ragdoll", "Misc", "AntiRagdoll")

-- SOCIALS
local dBtn = Instance.new("TextButton", Scroll); dBtn.Size = UDim2.new(1,0,0,35); dBtn.BackgroundColor3 = Color3.fromRGB(88,101,242); dBtn.Text = "JOIN DISCORD"; dBtn.TextColor3 = Color3.new(1,1,1); dBtn.Font = "GothamBold"; Instance.new("UICorner", dBtn)
dBtn.MouseButton1Click:Connect(function() setclipboard(Registry.Social.Discord) end)

local yBtn = Instance.new("TextButton", Scroll); yBtn.Size = UDim2.new(1,0,0,35); yBtn.BackgroundColor3 = Color3.fromRGB(200,0,0); yBtn.Text = "YT: @rzgr1ks"; yBtn.TextColor3 = Color3.new(1,1,1); yBtn.Font = "GothamBold"; Instance.new("UICorner", yBtn)
yBtn.MouseButton1Click:Connect(function() setclipboard(Registry.Social.YT) end)
