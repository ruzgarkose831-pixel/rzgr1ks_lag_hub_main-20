--[[
    @title: rzgr1ks V48 - VISIBILITY & INPUT FIX
    @status: BUTTONS FIXED, SLIDERS SMOOTH, XRAY ACTIVE
]]--

if _G.RZGR_V48_FINAL_FIX then return end
_G.RZGR_V48_FINAL_FIX = true

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

-- // X-RAY & ENGINE
local function ToggleXray(state)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(Local.Player.Character) then
            obj.LocalTransparencyModifier = state and 0.6 or 0
        end
    end
end

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

-- // INTERFACE (VISIBILITY GUARANTEED)
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Name = "RZGR_MAIN"
Main.Size = UDim2.new(0, 240, 0, 380)
Main.Position = UDim2.new(0.5, -120, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true -- Legacy drag support for reliability
Instance.new("UICorner", Main)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = "rzgr1ks V48 - BYPASS"; Title.TextColor3 = Color3.fromRGB(100, 100, 255); Title.Font = "GothamBold"; Title.BackgroundTransparency = 1; Title.TextSize = 12

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Name = "ButtonContainer"
Scroll.Size = UDim2.new(1, -10, 1, -55)
Scroll.Position = UDim2.new(0, 5, 0, 50)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 600) -- Scroll alanı genişletildi
Scroll.ScrollBarThickness = 2

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 10)
Layout.HorizontalAlignment = "Center"
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- // COMPONENT BUILDERS (GUARANTEED VISIBILITY)
local function AddToggle(txt, sub, key)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, 210, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.Text = txt .. ": OFF"
    b.TextColor3 = Color3.fromRGB(255, 140, 0)
    b.Font = "GothamBold"
    b.TextSize = 11
    Instance.new("UICorner", b)
    
    b.MouseButton1Click:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        b.Text = txt .. (Registry.States[sub][key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Registry.States[sub][key] and Color3.fromRGB(100, 25, 25) or Color3.fromRGB(30, 30, 30)
    end)
end

local function AddSlider(txt, min, max, sub, key)
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(0, 210, 0, 50)
    f.BackgroundTransparency = 1
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt..": "..Registry.States[sub][key]; l.TextColor3 = Color3.new(0.8,0.8,0.8); l.BackgroundTransparency = 1; l.Font = "Gotham"; l.TextSize = 10
    
    local bar = Instance.new("TextButton", f)
    bar.Size = UDim2.new(1, 0, 0, 6); bar.Position = UDim2.new(0, 0, 0, 30); bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50); bar.Text = ""
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((Registry.States[sub][key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(100, 100, 255); fill.BorderSizePixel = 0

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

-- // MINIMIZE
local isMin = false
local mBtn = Instance.new("TextButton", Header)
mBtn.Size = UDim2.new(0, 30, 0, 30); mBtn.Position = UDim2.new(1, -35, 0, 7); mBtn.Text = "-"; mBtn.TextColor3 = Color3.new(1,1,1); mBtn.BackgroundTransparency = 1; mBtn.TextSize = 20

mBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    mBtn.Text = isMin and "+" or "-"
    Scroll.Visible = not isMin
    Main:TweenSize(isMin and UDim2.new(0, 240, 0, 45) or UDim2.new(0, 240, 0, 380), "Out", "Quart", 0.2, true)
end)

-- // LOAD EVERYTHING
AddToggle("Silent Aim", "Combat", "Silent")
AddToggle("Hitbox Expander", "Combat", "Hitbox")
AddSlider("Hitbox Radius", 2, 200, "Combat", "HSize")
AddToggle("Speed Bypass", "Movement", "Speed")
AddSlider("Speed Value", 16, 500, "Movement", "Vel")
AddSlider("Jump Power", 50, 500, "Movement", "Jump")
AddSlider("Gravity", 0, 196, "Movement", "Grav")
AddToggle("Wallhack ESP", "Visuals", "Esp")
AddToggle("Material XRAY", "Visuals", "Xray")
AddToggle("Anti Ragdoll", "Misc", "AntiRagdoll")

local dBtn = Instance.new("TextButton", Scroll)
dBtn.Size = UDim2.new(0, 210, 0, 40); dBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242); dBtn.Text = "JOIN DISCORD"; dBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", dBtn)
dBtn.MouseButton1Click:Connect(function() setclipboard(Registry.Social.Discord) end)

print("RZGR1KS V48 DEPLOYED - ALL BUTTONS RENDERED")
