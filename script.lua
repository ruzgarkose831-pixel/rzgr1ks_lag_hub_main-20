--[[
    @project: RZGR1KS DUEL V48 - ABSOLUTE FIX
    @features: All restored (Speed, Spin, Xray, etc.), New Silent Aim
]]--

if _G.RZGR1KS_LOADED then return end
_G.RZGR1KS_LOADED = true

local Services = setmetatable({}, {__index = function(_, k) return game:GetService(k) end})
local Local = {
    Player = Services.Players.LocalPlayer,
    Mouse = Services.Players.LocalPlayer:GetMouse(),
    Camera = workspace.CurrentCamera
}

local Registry = {
    States = {
        Combat = { Silent = false, Hitbox = false, HSize = 25, Spin = false, SpinSpeed = 100 },
        Movement = { Speed = false, Vel = 100, Jump = 50, Grav = 196.2 },
        Visuals = { Xray = false },
        Misc = { AntiRagdoll = false }
    }
}

-- // GELİŞMİŞ SILENT AIM (GÜNCEL STANDARTLAR)
local function GetTarget()
    local target, dist = nil, math.huge
    for _, v in pairs(Services.Players:GetPlayers()) do
        if v ~= Local.Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, vis = Local.Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Local.Mouse.X, Local.Mouse.Y)).Magnitude
                if mag < dist then
                    target = v.Character.HumanoidRootPart
                    dist = mag
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
        local target = GetTarget()
        if target then
            if method == "Raycast" then
                args[2] = (target.Position - args[1]).Unit * 1000
            else
                args[1] = Ray.new(args[1].Origin, (target.Position - args[1].Origin).Unit * 1000)
            end
            return OldNC(self, unpack(args))
        end
    end
    return OldNC(self, ...)
end)

-- // MAIN RUNNER
Services.RunService.Heartbeat:Connect(function()
    local char = Local.Player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if root and hum then
        if Registry.States.Combat.Spin then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Registry.States.Combat.SpinSpeed), 0)
        end
        if Registry.States.Movement.Speed and hum.MoveDirection.Magnitude > 0 then
            root.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X * Registry.States.Movement.Vel, root.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * Registry.States.Movement.Vel)
        end
        hum.JumpPower = Registry.States.Movement.Jump
        workspace.Gravity = Registry.States.Movement.Grav
        if Registry.States.Misc.AntiRagdoll then hum.PlatformStand = false end
    end
    
    if Registry.States.Combat.Hitbox then
        for _, p in pairs(Services.Players:GetPlayers()) do
            if p ~= Local.Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(Registry.States.Combat.HSize, Registry.States.Combat.HSize, Registry.States.Combat.HSize)
                p.Character.HumanoidRootPart.Transparency = 0.7; p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
    
    if Registry.States.Visuals.Xray then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(char) then v.LocalTransparencyModifier = 0.6 end
        end
    end
end)

-- // UI (TAMAMEN GÖRÜNÜR VE ÇALIŞIR HALE GETİRİLDİ)
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 320, 0, 45)
Main.Position = UDim2.new(0.5, -160, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true 
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -50, 0, 45); Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "RZGR1KS DUEL V23"; Title.TextColor3 = Color3.fromRGB(255, 40, 40); Title.Font = "GothamBold"; Title.TextSize = 14; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45); ToggleBtn.Position = UDim2.new(1, -45, 0, 0)
ToggleBtn.Text = "-"; ToggleBtn.TextColor3 = Color3.new(1,1,1); ToggleBtn.Font = "GothamBold"; ToggleBtn.TextSize = 25; ToggleBtn.BackgroundTransparency = 1

-- SCROLL ALANI
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 0, 350)
Scroll.Position = UDim2.new(0, 5, 0, 50)
Scroll.Visible = false
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
Scroll.BorderSizePixel = 0
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 8); Layout.HorizontalAlignment = "Center"; Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- // COMPONENT FONKSİYONLARI
local function AddToggle(txt, sub, key)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1, -10, 0, 38); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.Text = txt..": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 12
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        b.Text = txt..(Registry.States[sub][key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Registry.States[sub][key] and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(25, 25, 25)
    end)
end

local function AddSlider(txt, min, max, sub, key)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(1, -10, 0, 50); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 18); l.Text = txt..": "..Registry.States[sub][key]; l.TextColor3 = Color3.new(0.8,0.8,0.8); l.Font = "Gotham"; l.TextSize = 10; l.BackgroundTransparency = 1
    local bar = Instance.new("TextButton", f); bar.Size = UDim2.new(1, 0, 0, 6); bar.Position = UDim2.new(0, 0, 0, 28); bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45); bar.Text = ""
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((Registry.States[sub][key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 40, 40); fill.BorderSizePixel = 0
    
    local isDragging = false
    local function Update()
        local percent = math.clamp((Services.UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        local val = math.floor(min + (percent * (max - min)))
        l.Text = txt..": "..val; Registry.States[sub][key] = val
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isDragging = true Update() end end)
    Services.UIS.InputChanged:Connect(function(i) if isDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update() end end)
    Services.UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isDragging = false end end)
end

-- // TÜM ÖZELLİKLER (SIRAYLA)
AddToggle("Silent Aim", "Combat", "Silent")
AddToggle("Hitbox Expander", "Combat", "Hitbox")
AddSlider("Hitbox Radius", 2, 150, "Combat", "HSize")
AddToggle("Spinbot", "Combat", "Spin")
AddSlider("Spin Speed", 0, 300, "Combat", "SpinSpeed")
AddToggle("Speed Bypass", "Movement", "Speed")
AddSlider("Walk Speed", 16, 500, "Movement", "Vel")
AddSlider("Jump Power", 50, 500, "Movement", "Jump")
AddSlider("Gravity Control", 0, 196, "Movement", "Grav")
AddToggle("Material X-RAY", "Visuals", "Xray")
AddToggle("Anti Ragdoll", "Misc", "AntiRagdoll")

-- SOSYAL BUTONLAR
local yt = Instance.new("TextButton", Scroll); yt.Size = UDim2.new(1, -10, 0, 35); yt.BackgroundColor3 = Color3.fromRGB(200, 0, 0); yt.Text = "YT: @rzgr1ks"; yt.TextColor3 = Color3.new(1,1,1); yt.Font = "GothamBold"; Instance.new("UICorner", yt)
yt.MouseButton1Click:Connect(function() setclipboard("https://youtube.com/@rzgr1ks") end)

-- TOGGLE LOGIC
local isExp = false
ToggleBtn.MouseButton1Click:Connect(function()
    isExp = not isExp
    ToggleBtn.Text = isExp and "X" or "-"
    Scroll.Visible = isExp
    Main:TweenSize(isExp and UDim2.new(0, 320, 0, 420) or UDim2.new(0, 320, 0, 45), "Out", "Quart", 0.3, true)
end)
