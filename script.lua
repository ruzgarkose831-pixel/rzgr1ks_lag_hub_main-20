--[[
    @project: RZGR1KS V48 - BYPASS
    @owner: rzgr1ks
    @yt: youtube.com/@rzgr1ks
    @dc: discord.gg/XpbcvVdU
]]--

if _G.RZGR_LOADED_V48 then return end
_G.RZGR_LOADED_V48 = true

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
    }
}

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
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    local Root = Char:FindFirstChild("HumanoidRootPart")
    
    if Root and Hum then
        if Registry.States.Movement.Speed and Hum.MoveDirection.Magnitude > 0 then
            Root.AssemblyLinearVelocity = Vector3.new(Hum.MoveDirection.X * Registry.States.Movement.Vel, Root.AssemblyLinearVelocity.Y, Hum.MoveDirection.Z * Registry.States.Movement.Vel)
        end
        Hum.JumpPower = Registry.States.Movement.Jump
        workspace.Gravity = Registry.States.Movement.Grav
    end
    
    if Registry.States.Visuals.Xray then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(Char) then v.LocalTransparencyModifier = 0.6 end
        end
    else
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(Char) then v.LocalTransparencyModifier = 0 end
        end
    end
    
    if Registry.States.Combat.Hitbox then
        for _, p in ipairs(Services.Players:GetPlayers()) do
            if p ~= Local.Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(Registry.States.Combat.HSize, Registry.States.Combat.HSize, Registry.States.Combat.HSize)
                p.Character.HumanoidRootPart.Transparency = 0.7; p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
end)

-- // UI (ORIGINAL V23 DESIGN)
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 350, 0, 45)
Main.Position = UDim2.new(0.5, -175, 0.1, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(0, 250, 0, 45); Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "RZGR1KS DUEL V23"; Title.TextColor3 = Color3.fromRGB(255, 40, 40)
Title.Font = "GothamBold"; Title.TextSize = 14; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 45, 0, 45); MinBtn.Position = UDim2.new(1, -50, 0, 0)
MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.Font = "GothamBold"; MinBtn.TextSize = 20; MinBtn.BackgroundTransparency = 1

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 0, 320); Container.Position = UDim2.new(0, 10, 0, 50)
Container.Visible = false; Container.BackgroundTransparency = 1; Container.ScrollBarThickness = 2; Container.CanvasSize = UDim2.new(0,0,0,550)
local Layout = Instance.new("UIListLayout", Container); Layout.Padding = UDim.new(0, 10); Layout.HorizontalAlignment = "Center"

-- // COMPONENT BUILDERS (FIXED SLIDERS)
local function AddToggle(txt, sub, key)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = txt..": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        b.Text = txt..(Registry.States[sub][key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Registry.States[sub][key] and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 30, 30)
    end)
end

local function AddSlider(txt, min, max, sub, key)
    local f = Instance.new("Frame", Container); f.Size = UDim2.new(1, 0, 0, 50); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt..": "..Registry.States[sub][key]; l.TextColor3 = Color3.new(0.8,0.8,0.8); l.BackgroundTransparency = 1; l.Font = "Gotham"
    local bar = Instance.new("TextButton", f); bar.Size = UDim2.new(1, 0, 0, 6); bar.Position = UDim2.new(0, 0, 0, 30); bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50); bar.Text = ""
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((Registry.States[sub][key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 40, 40); fill.BorderSizePixel = 0
    
    local function Update()
        local pos = math.clamp((Services.UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0); local val = math.floor(min + (pos * (max - min)))
        l.Text = txt..": "..val; Registry.States[sub][key] = val
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then local conn; conn = Services.RunService.RenderStepped:Connect(function() if Services.UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or Services.UIS:IsMouseButtonPressed(Enum.UserInputType.Touch) then Update() else conn:Disconnect() end end) end end)
end

-- // MINIMIZE & DRAG
local isExpanded = false
MinBtn.MouseButton1Click:Connect(function()
    isExpanded = not isExpanded
    MinBtn.Text = isExpanded and "X" or "-"
    Container.Visible = isExpanded
    Main:TweenSize(isExpanded and UDim2.new(0, 350, 0, 400) or UDim2.new(0, 350, 0, 45), "Out", "Quart", 0.3, true)
end)

local d, s, p; Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; s = i.Position; p = Main.Position end end)
Services.UIS.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - s; Main.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end)
Services.UIS.InputEnded:Connect(function() d = false end)

-- // LOAD LIST
AddToggle("Silent Aim", "Combat", "Silent")
AddToggle("Hitbox Expander", "Combat", "Hitbox")
AddSlider("Hitbox Radius", 2, 200, "Combat", "HSize")
AddToggle("Speed Mode", "Movement", "Speed")
AddSlider("Speed Power", 16, 500, "Movement", "Vel")
AddSlider("Jump Power", 50, 500, "Movement", "Jump")
AddSlider("Gravity", 0, 196, "Movement", "Grav")
AddToggle("ESP Highlight", "Visuals", "Esp")
AddToggle("Wallhack X-RAY", "Visuals", "Xray")
AddToggle("Anti Ragdoll", "Misc", "AntiRagdoll")

-- // SOCIALS (RESTORED)
local ytBtn = Instance.new("TextButton", Container); ytBtn.Size = UDim2.new(1,0,0,40); ytBtn.BackgroundColor3 = Color3.fromRGB(200,0,0); ytBtn.Text = "SUBSCRIBE YT: rzgr1ks"; ytBtn.TextColor3 = Color3.new(1,1,1); ytBtn.Font = "GothamBold"; Instance.new("UICorner", ytBtn)
ytBtn.MouseButton1Click:Connect(function() setclipboard("https://youtube.com/@rzgr1ks") end)

local dcBtn = Instance.new("TextButton", Container); dcBtn.Size = UDim2.new(1,0,0,40); dcBtn.BackgroundColor3 = Color3.fromRGB(88,101,242); dcBtn.Text = "JOIN DISCORD SERVER"; dcBtn.TextColor3 = Color3.new(1,1,1); dcBtn.Font = "GothamBold"; Instance.new("UICorner", dcBtn)
dcBtn.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/XpbcvVdU") end)
