--[[
    @title: rzgr1ks V48 - RE-FIXED BYPASS
    @updates: X-Ray Restored, Full Mobile Input Support, Draggable Fixed
]]--

if _G.RZGR_V48_FIXED then return end
_G.RZGR_V48_FIXED = true

local Services = setmetatable({}, {__index = function(_, k) return game:GetService(k) end})
local Local = {
    Player = Services.Players.LocalPlayer,
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

-- // X-RAY ENGINE
local function ToggleXray(state)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(Local.Player.Character) then
            obj.LocalTransparencyModifier = state and 0.6 or 0
        end
    end
end

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
    
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= Local.Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            if Registry.States.Combat.Hitbox then
                hrp.Size = Vector3.new(Registry.States.Combat.HSize, Registry.States.Combat.HSize, Registry.States.Combat.HSize)
                hrp.Transparency = 0.7; hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2,2,1); hrp.Transparency = 1; hrp.CanCollide = true
            end
        end
    end
    if Registry.States.Visuals.Xray then ToggleXray(true) end
end)

-- // INTERFACE ENGINE
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 240, 0, 360)
Main.Position = UDim2.new(0.5, -120, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Header.Active = true

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = "rzgr1ks V48 - BYPASS"; Title.TextColor3 = Color3.fromRGB(80, 80, 255); Title.Font = "GothamBold"; Title.TextSize = 11; Title.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -50); Scroll.Position = UDim2.new(0, 5, 0, 45); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 0
local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 8); Layout.HorizontalAlignment = "Center"

-- // DRAGGING FIX (MOBILE STABLE)
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Services.UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- // COMPONENTS
local function AddToggle(txt, sub, key, callback)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1, -10, 0, 35); b.BackgroundColor3 = Color3.fromRGB(22, 22, 22); b.Text = txt .. ": OFF"; b.TextColor3 = Color3.fromRGB(200, 100, 0); b.Font = "GothamBold"; b.TextSize = 10; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        b.Text = txt .. (Registry.States[sub][key] and ": ON" or ": OFF")
        b.TextColor3 = Registry.States[sub][key] and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(200, 100, 0)
        if callback then callback(Registry.States[sub][key]) end
    end)
end

local function AddSlider(txt, min, max, sub, key)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(1, -10, 0, 40); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 15); l.Text = txt..": "..Registry.States[sub][key]; l.TextColor3 = Color3.new(0.6,0.6,0.6); l.Font = "Gotham"; l.BackgroundTransparency = 1; l.TextSize = 9
    local bar = Instance.new("Frame", f); bar.Size = UDim2.new(1, 0, 0, 6); bar.Position = UDim2.new(0,0,0,25); bar.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((Registry.States[sub][key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(80, 80, 255)
    
    local function Update(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (pos * (max - min)))
        l.Text = txt..": "..val; Registry.States[sub][key] = val
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = Services.RunService.RenderStepped:Connect(function()
                if Services.UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or Services.UIS:IsMouseButtonPressed(Enum.UserInputType.Touch) then
                    Update({Position = Services.UIS:GetMouseLocation()})
                else
                    connection:Disconnect()
                end
            end)
        end
    end)
end

-- LOAD
AddToggle("Silent Aim", "Combat", "Silent")
AddToggle("Hitbox Expander", "Combat", "Hitbox")
AddSlider("Hitbox Radius", 2, 150, "Combat", "HSize")
AddToggle("Velocity Speed", "Movement", "Speed")
AddSlider("Speed Value", 16, 800, "Movement", "Vel")
AddSlider("Jump Power", 50, 500, "Movement", "Jump")
AddSlider("Gravity", 0, 196, "Movement", "Grav")
AddToggle("ESP Wallhack", "Visuals", "Esp")
AddToggle("X-Ray Material", "Visuals", "Xray", function(s) if not s then ToggleXray(false) end end)
AddToggle("Anti Ragdoll", "Misc", "AntiRagdoll")

-- Discord
local dc = Instance.new("TextButton", Scroll); dc.Size = UDim2.new(1,-10,0,35); dc.BackgroundColor3 = Color3.fromRGB(88, 101, 242); dc.Text = "JOIN DISCORD"; dc.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", dc)
dc.MouseButton1Click:Connect(function() setclipboard(Registry.Social.Discord) end)

-- Minimize System (FIXED)
local isMin = false
local mBtn = Instance.new("TextButton", Header)
mBtn.Size = UDim2.new(0,30,0,30); mBtn.Position = UDim2.new(1,-35,0,5); mBtn.Text = "-"; mBtn.TextColor3 = Color3.new(1,1,1); mBtn.BackgroundTransparency = 1; mBtn.Font = "Gotham"

mBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    mBtn.Text = isMin and "+" or "-"
    Main:TweenSize(isMin and UDim2.new(0, 240, 0, 40) or UDim2.new(0, 240, 0, 360), "Out", "Quart", 0.3, true)
    task.wait(0.1)
    Scroll.Visible = not isMin
end)
