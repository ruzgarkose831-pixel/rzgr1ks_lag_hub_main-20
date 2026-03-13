--[[
    @project: RZGR1KS DUEL V48 - FINAL REPAIR
    @status: GUI FIX & ADVANCED SILENT AIM
]]--

if _G.RZGR_FIXED_V48 then return end
_G.RZGR_FIXED_V48 = true

local Services = setmetatable({}, {__index = function(_, k) return game:GetService(k) end})
local Local = {
    Player = Services.Players.LocalPlayer,
    Camera = workspace.CurrentCamera,
    Mouse = Services.Players.LocalPlayer:GetMouse()
}

local Registry = {
    States = {
        Combat = { Silent = false, Hitbox = false, HSize = 25, Spin = false, SpinSpeed = 80 },
        Movement = { Speed = false, Vel = 100, Jump = 50, Grav = 196.2 },
        Visuals = { Xray = false },
        Misc = { AntiRagdoll = false }
    }
}

-- // GELİŞMİŞ SILENT AIM (INTERNET STANDARDI)
local function GetClosestToMouse()
    local target, dist = nil, math.huge
    for _, v in pairs(Services.Players:GetPlayers()) do
        if v ~= Local.Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos, visible = Local.Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if visible then
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

-- Namecall Hook: Mermiyi veya vuruşu hedefe kilitler
local OldNC; OldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if not checkcaller() and Registry.States.Combat.Silent and (method == "Raycast" or method == "FindPartOnRayWithIgnoreList") then
        local target = GetClosestToMouse()
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
        -- Spinbot (Yeni stabil yöntem)
        if Registry.States.Combat.Spin then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Registry.States.Combat.SpinSpeed), 0)
        end
        -- Movement
        if Registry.States.Movement.Speed and hum.MoveDirection.Magnitude > 0 then
            root.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X * Registry.States.Movement.Vel, root.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * Registry.States.Movement.Vel)
        end
        hum.JumpPower = Registry.States.Movement.Jump
        workspace.Gravity = Registry.States.Movement.Grav
    end
    
    -- Hitbox & Xray
    if Registry.States.Combat.Hitbox then
        for _, p in pairs(Services.Players:GetPlayers()) do
            if p ~= Local.Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(Registry.States.Combat.HSize, Registry.States.Combat.HSize, Registry.States.Combat.HSize)
                p.Character.HumanoidRootPart.Transparency = 0.7
            end
        end
    end
    
    if Registry.States.Visuals.Xray then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(char) then v.LocalTransparencyModifier = 0.6 end
        end
    end
end)

-- // UI (KESİN ÇALIŞAN GARANTİ SİSTEM)
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 300, 0, 40)
Main.Position = UDim2.new(0.5, -150, 0.1, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true -- Mobil taşıma
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -50, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "RZGR1KS DUEL V48"; Title.TextColor3 = Color3.new(1,0,0); Title.Font = "GothamBold"; Title.TextSize = 14; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0, 40, 0, 40); ToggleBtn.Position = UDim2.new(1, -40, 0, 0)
ToggleBtn.Text = "V"; ToggleBtn.TextColor3 = Color3.new(1,1,1); ToggleBtn.Font = "GothamBold"; ToggleBtn.BackgroundTransparency = 1

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, 0, 0, 350)
Content.Position = UDim2.new(0, 0, 0, 40)
Content.Visible = false
Content.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Content.CanvasSize = UDim2.new(0, 0, 0, 600)
Content.ScrollBarThickness = 2
Instance.new("UIListLayout", Content).Padding = UDim.new(0, 5)

-- // TOGGLE MEKANİZMASI (ACILMAMA SORUNU BURADA ÇÖZÜLDÜ)
local isOpen = false
ToggleBtn.Activated:Connect(function()
    isOpen = not isOpen
    Content.Visible = isOpen
    ToggleBtn.Text = isOpen and "^" or "V"
    Main.Size = isOpen and UDim2.new(0, 300, 0, 400) or UDim2.new(0, 300, 0, 40)
end)

-- // COMPONENT BUILDER
local function NewToggle(txt, sub, key)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(1, -10, 0, 35); b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.Text = txt..": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 12
    Instance.new("UICorner", b)
    b.Activated:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        b.Text = txt..(Registry.States[sub][key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Registry.States[sub][key] and Color3.fromRGB(150,0,0) or Color3.fromRGB(30,30,30)
    end)
end

local function NewSlider(txt, min, max, sub, key)
    local f = Instance.new("Frame", Content); f.Size = UDim2.new(1, -10, 0, 45); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt..": "..Registry.States[sub][key]; l.TextColor3 = Color3.new(0.8,0.8,0.8); l.Font = "Gotham"; l.TextSize = 10; l.BackgroundTransparency = 1
    local bar = Instance.new("TextButton", f); bar.Size = UDim2.new(1, 0, 0, 5); bar.Position = UDim2.new(0,0,0,25); bar.BackgroundColor3 = Color3.new(0.2,0.2,0.2); bar.Text = ""
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((Registry.States[sub][key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.new(1,0,0); fill.BorderSizePixel = 0
    
    local move = false
    local function Update()
        local p = math.clamp((Services.UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(p, 0, 1, 0); local val = math.floor(min + (p * (max - min)))
        l.Text = txt..": "..val; Registry.States[sub][key] = val
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move = true Update() end end)
    Services.UIS.InputChanged:Connect(function(i) if move and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update() end end)
    Services.UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move = false end end)
end

-- // LISTE (BÜTÜN ÖZELLİKLER)
NewToggle("Silent Aim", "Combat", "Silent")
NewToggle("Hitbox Expander", "Combat", "Hitbox")
NewSlider("Hitbox Radius", 2, 150, "Combat", "HSize")
NewToggle("Spinbot", "Combat", "Spin")
NewSlider("Spin Speed", 0, 300, "Combat", "SpinSpeed")
NewToggle("Speed Bypass", "Movement", "Speed")
NewSlider("WalkSpeed", 16, 500, "Movement", "Vel")
NewSlider("Jump Power", 50, 500, "Movement", "Jump")
NewSlider("Gravity", 0, 196, "Movement", "Grav")
NewToggle("X-Ray Vision", "Visuals", "Xray")
NewToggle("Anti Ragdoll", "Misc", "AntiRagdoll")

-- SOSYAL
local yt = Instance.new("TextButton", Content); yt.Size = UDim2.new(1,-10,0,35); yt.BackgroundColor3 = Color3.new(0.6,0,0); yt.Text = "YT: @rzgr1ks"; yt.TextColor3 = Color3.new(1,1,1); yt.Font = "GothamBold"
yt.Activated:Connect(function() setclipboard("https://youtube.com/@rzgr1ks") end)
