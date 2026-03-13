--[[
    @project: RZGR1KS DUEL V48 - ULTIMATE REPAIR
    @features: 100% Full List + Fixed Silent Aim + Non-Glitch GUI
]]--

if _G.RZGR_FINAL_FIX then return end
_G.RZGR_FINAL_FIX = true

local Services = setmetatable({}, {__index = function(_, k) return game:GetService(k) end})
local Local = {
    Player = Services.Players.LocalPlayer,
    Mouse = Services.Players.LocalPlayer:GetMouse(),
    Camera = workspace.CurrentCamera
}

local Registry = {
    States = {
        Combat = { Silent = false, Hitbox = false, HSize = 25, Spin = false, SpinSpeed = 80 },
        Movement = { Speed = false, Vel = 100, Jump = 50, Grav = 196.2 },
        Visuals = { Xray = false },
        Misc = { AntiRagdoll = false }
    }
}

-- // GELİŞMİŞ SILENT AIM (Internet Standart Raycast Hook)
local function GetClosestPlayer()
    local target, shortestDistance = nil, math.huge
    for _, v in pairs(Services.Players:GetPlayers()) do
        if v ~= Local.Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = Local.Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - Services.UIS:GetMouseLocation()).Magnitude
                if magnitude < shortestDistance then
                    target = v.Character.HumanoidRootPart
                    shortestDistance = magnitude
                end
            end
        end
    end
    return target
end

local OldNC; OldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if not checkcaller() and Registry.States.Combat.Silent and (method == "Raycast" or method == "FindPartOnRayWithIgnoreList") then
        local T = GetClosestPlayer()
        if T then
            if method == "Raycast" then args[2] = (T.Position - args[1]).Unit * 1000
            else args[1] = Ray.new(args[1].Origin, (T.Position - args[1].Origin).Unit * 1000) end
            return OldNC(self, unpack(args))
        end
    end
    return OldNC(self, ...)
end)

-- // MAIN LOOP (Tüm Özelliklerin Çalışma Merkezi)
Services.RunService.Heartbeat:Connect(function()
    local char = Local.Player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if root and hum then
        -- Spinbot
        if Registry.States.Combat.Spin then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Registry.States.Combat.SpinSpeed), 0)
        end
        -- Speed (Velocity)
        if Registry.States.Movement.Speed and hum.MoveDirection.Magnitude > 0 then
            root.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X * Registry.States.Movement.Vel, root.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * Registry.States.Movement.Vel)
        end
        -- Jump & Gravity
        hum.JumpPower = Registry.States.Movement.Jump
        workspace.Gravity = Registry.States.Movement.Grav
        -- Anti Ragdoll
        if Registry.States.Misc.AntiRagdoll then hum.PlatformStand = false end
    end
    
    -- Hitbox
    if Registry.States.Combat.Hitbox then
        for _, p in pairs(Services.Players:GetPlayers()) do
            if p ~= Local.Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(Registry.States.Combat.HSize, Registry.States.Combat.HSize, Registry.States.Combat.HSize)
                p.Character.HumanoidRootPart.Transparency = 0.7; p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
    
    -- X-Ray
    if Registry.States.Visuals.Xray then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(char) then v.LocalTransparencyModifier = 0.6 end
        end
    end
end)

-- // UI (AÇILMAMA SORUNU GİDERİLDİ)
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 320, 0, 40)
Main.Position = UDim2.new(0.5, -160, 0.1, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -50, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "RZGR1KS DUEL V23"; Title.TextColor3 = Color3.new(1,0,0); Title.Font = "GothamBold"; Title.TextSize = 14; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0, 40, 0, 40); ToggleBtn.Position = UDim2.new(1, -40, 0, 0)
ToggleBtn.Text = "-"; ToggleBtn.TextColor3 = Color3.new(1,1,1); ToggleBtn.Font = "GothamBold"; ToggleBtn.TextSize = 25; ToggleBtn.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, 0, 0, 350)
Scroll.Position = UDim2.new(0, 0, 0, 40)
Scroll.Visible = false
Scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 2
Scroll.CanvasSize = UDim2.new(0, 0, 0, 650) -- Tüm butonlar için geniş alan

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 5); Layout.HorizontalAlignment = "Center"

-- // GUI AÇMA/KAPAMA (KESİN ÇALIŞAN SİSTEM)
local open = false
ToggleBtn.Activated:Connect(function()
    open = not open
    Scroll.Visible = open
    ToggleBtn.Text = open and "X" or "-"
    Main.Size = open and UDim2.new(0, 320, 0, 390) or UDim2.new(0, 320, 0, 40)
end)

-- // COMPONENT BUILDER
local function CreateToggle(txt, sub, key)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1, -10, 0, 35); b.BackgroundColor3 = Color3.fromRGB(35, 35, 35); b.Text = txt..": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"
    Instance.new("UICorner", b)
    b.Activated:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        b.Text = txt..(Registry.States[sub][key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Registry.States[sub][key] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(35, 35, 35)
    end)
end

local function CreateSlider(txt, min, max, sub, key)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(1, -10, 0, 45); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt..": "..Registry.States[sub][key]; l.TextColor3 = Color3.new(0.8,0.8,0.8); l.Font = "Gotham"; l.TextSize = 10; l.BackgroundTransparency = 1
    local bar = Instance.new("TextButton", f); bar.Size = UDim2.new(1, 0, 0, 4); bar.Position = UDim2.new(0, 0, 0, 25); bar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2); bar.Text = ""
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((Registry.States[sub][key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.new(1, 0, 0); fill.BorderSizePixel = 0
    
    local move = false
    local function Upd()
        local p = math.clamp((Services.UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(p, 0, 1, 0); local val = math.floor(min + (p * (max - min)))
        l.Text = txt..": "..val; Registry.States[sub][key] = val
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move = true Upd() end end)
    Services.UIS.InputChanged:Connect(function(i) if move and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Upd() end end)
    Services.UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move = false end end)
end

-- // TÜM ÖZELLİKLERİ SIRAYLA EKLEME
CreateToggle("Silent Aim", "Combat", "Silent")
CreateToggle("Hitbox Expander", "Combat", "Hitbox")
CreateSlider("Hitbox Radius", 2, 200, "Combat", "HSize")
CreateToggle("Spinbot", "Combat", "Spin")
CreateSlider("Spin Speed", 0, 300, "Combat", "SpinSpeed")
CreateToggle("Speed Bypass", "Movement", "Speed")
CreateSlider("Walk Speed", 16, 500, "Movement", "Vel")
CreateSlider("Jump Power", 50, 500, "Movement", "Jump")
CreateSlider("Gravity", 0, 196, "Movement", "Grav")
CreateToggle("X-Ray Vision", "Visuals", "Xray")
CreateToggle("Anti Ragdoll", "Misc", "AntiRagdoll")

-- SOSYAL
local yt = Instance.new("TextButton", Scroll); yt.Size = UDim2.new(1, -10, 0, 35); yt.BackgroundColor3 = Color3.fromRGB(200, 0, 0); yt.Text = "YT: @rzgr1ks"; yt.TextColor3 = Color3.new(1,1,1); yt.Font = "GothamBold"
yt.Activated:Connect(function() setclipboard("https://youtube.com/@rzgr1ks") end)
