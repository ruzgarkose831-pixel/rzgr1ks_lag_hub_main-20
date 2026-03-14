--[[
    @title: RZGR1KS DUEL V48 - PROFESSIONAL EXECUTIVE
    @author: RZGR1KS & Gemini AI Collaboration
    @modules: Silent Aim, Drawing ESP, Advanced Movement, X-Ray, Auto-Interact
    @credits: Proximity Module by @ylzk on Discord
    
    [DOCUMENTATION]
    This script is designed for educational purposes and UI/UX demonstration.
    It utilizes the 'Drawing' library for high-performance visuals and 'Namecall' 
    hooking for combat adjustments.
]]--

-- // CORE SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- // LOCAL CONSTANTS
local LOCAL_PLAYER = Players.LocalPlayer
local CAMERA = workspace.CurrentCamera
local MOUSE = LOCAL_PLAYER:GetMouse()

-- // GLOBAL CONFIGURATION (FULL ENGLISH)
local Config = {
    Combat = {
        SilentAim = false,
        HitboxExpander = false,
        HitboxSize = 25,
        Spinbot = false,
        SpinSpeed = 100
    },
    Movement = {
        SpeedBypass = false,
        WalkSpeed = 100,
        JumpPower = 50,
        GravityControl = 196.2,
        MultiJump = false,
        AntiRagdoll = false
    },
    Visuals = {
        NameESP = false,
        BoxESP = false,
        TracerESP = false,
        XRay = false,
        ESPColor = Color3.fromRGB(255, 80, 80),
        TracerColor = Color3.fromRGB(255, 255, 255)
    },
    Misc = {
        AutoInteract = false,
        InteractDuration = 0.1 -- Optimized from @ylzk's base
    }
}

-- // LOGGING SYSTEM (For Professional Feel)
local function Log(msg)
    print(string.format("[RZGR1KS-V48] [%s] : %s", os.date("%X"), msg))
end

Log("Initializing professional frameworks...")

-- // 1. COMBAT MODULE: SILENT AIM & TARGETING
local function GetClosestTarget()
    local target, dist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LOCAL_PLAYER and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos, vis = CAMERA:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
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
    if not checkcaller() and Config.Combat.SilentAim and (method == "Raycast" or method == "FindPartOnRay") then
        local target = GetClosestTarget()
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

-- // 2. VISUALS MODULE: DRAWING ESP (STABLE)
local ESPContainer = {}

local function InitializeESP(player)
    local components = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text")
    }
    
    components.Box.Thickness = 1
    components.Box.Filled = false
    components.Tracer.Thickness = 1
    components.Name.Size = 14
    components.Name.Center = true
    components.Name.Outline = true
    
    local renderConn
    renderConn = RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local hrp = player.Character.HumanoidRootPart
            local hum = player.Character.Humanoid
            local pos, vis = CAMERA:WorldToViewportPoint(hrp.Position)
            
            if vis and hum.Health > 0 then
                -- Visibility Logic
                components.Box.Visible = Config.Visuals.BoxESP
                components.Tracer.Visible = Config.Visuals.TracerESP
                components.Name.Visible = Config.Visuals.NameESP
                
                -- Calculations
                local sizeX = 2000 / pos.Z
                local sizeY = 2500 / pos.Z
                
                if components.Box.Visible then
                    components.Box.Size = Vector2.new(sizeX, sizeY)
                    components.Box.Position = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                    components.Box.Color = Config.Visuals.ESPColor
                end
                
                if components.Tracer.Visible then
                    components.Tracer.From = Vector2.new(CAMERA.ViewportSize.X / 2, CAMERA.ViewportSize.Y)
                    components.Tracer.To = Vector2.new(pos.X, pos.Y)
                    components.Tracer.Color = Config.Visuals.TracerColor
                end
                
                if components.Name.Visible then
                    components.Name.Position = Vector2.new(pos.X, pos.Y - sizeY/2 - 16)
                    components.Name.Text = string.format("%s [%d]", player.Name, math.floor(hum.Health))
                    components.Name.Color = Color3.new(1, 1, 1)
                end
            else
                components.Box.Visible = false
                components.Tracer.Visible = false
                components.Name.Visible = false
            end
        else
            components.Box.Visible = false
            components.Tracer.Visible = false
            components.Name.Visible = false
            if not player.Parent then
                for _, obj in pairs(components) do obj:Remove() end
                renderConn:Disconnect()
            end
        end
    end)
end

-- // 3. X-RAY CORE ENGINE
local XRayData = {}
local function ManageXRay(state)
    if state then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(LOCAL_PLAYER.Character) and not obj.Parent:FindFirstChildOfClass("Humanoid") then
                XRayData[obj] = obj.Transparency
                obj.Transparency = 0.6
            end
        end
        Log("X-Ray Filtering Enabled")
    else
        for obj, trans in pairs(XRayData) do
            if obj and obj.Parent then obj.Transparency = trans end
        end
        table.clear(XRayData)
        Log("X-Ray Filtering Disabled")
    end
end

-- // 4. MOVEMENT & PHYSICS ENGINE
UIS.JumpRequest:Connect(function()
    if Config.Movement.MultiJump then
        local hum = LOCAL_PLAYER.Character and LOCAL_PLAYER.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Heartbeat:Connect(function()
    local char = LOCAL_PLAYER.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if hum and root then
        -- Jump & Gravity Management
        hum.UseJumpPower = true
        hum.JumpPower = Config.Movement.JumpPower
        workspace.Gravity = Config.Movement.GravityControl
        
        -- Speed Management
        if Config.Movement.SpeedBypass and hum.MoveDirection.Magnitude > 0 then
            root.AssemblyLinearVelocity = Vector3.new(
                hum.MoveDirection.X * Config.Movement.WalkSpeed,
                root.AssemblyLinearVelocity.Y,
                hum.MoveDirection.Z * Config.Movement.WalkSpeed
            )
        end
        
        -- Spin Mechanics
        if Config.Combat.Spinbot then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Config.Combat.SpinSpeed), 0)
        end
        
        -- Ragdoll Prevention
        if Config.Movement.AntiRagdoll then hum.PlatformStand = false end
    end
    
    -- Hitbox Management
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LOCAL_PLAYER and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            if Config.Combat.HitboxExpander then
                hrp.Size = Vector3.new(Config.Combat.HitboxSize, Config.Combat.HitboxSize, Config.Combat.HitboxSize)
                hrp.Transparency = 0.8
                hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
            end
        end
    end
end)

-- // 5. INTERACT MODULE (CREDIT: @ylzk)
local activeInteractions = {}
ProximityPromptService.PromptShown:Connect(function(prompt)
    if not Config.Misc.AutoInteract then return end
    if activeInteractions[prompt] then return end
    
    activeInteractions[prompt] = true
    prompt.HoldDuration = 0 -- Instant interact override
    
    task.spawn(function()
        task.wait(0.01)
        pcall(function() prompt:InputHoldBegin() end)
        task.wait(Config.Misc.InteractDuration)
        pcall(function() prompt:InputHoldEnd() end)
        activeInteractions[prompt] = nil
    end)
end)

-- // 6. USER INTERFACE (RZGR1KS STYLED)
local GUI = Instance.new("ScreenGui", (gethui and gethui()) or CoreGui)
GUI.Name = "RZGR1KS_V48_ULTIMATE"
GUI.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", GUI)
MainFrame.Size = UDim2.new(0, 360, 0, 52)
MainFrame.Position = UDim2.new(0.5, -180, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Header UI
local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, -80, 1, 0)
Header.Position = UDim2.new(0, 15, 0, 0)
Header.BackgroundTransparency = 1
Header.Text = "RZGR1KS DUEL EXECUTIVE"
Header.Font = Enum.Font.GothamBold
Header.TextColor3 = Color3.fromRGB(255, 70, 70)
Header.TextSize = 15
Header.TextXAlignment = "Left"

local MenuToggle = Instance.new("TextButton", MainFrame)
MenuToggle.Size = UDim2.new(0, 60, 0, 34)
MenuToggle.Position = UDim2.new(1, -70, 0, 9)
MenuToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MenuToggle.Text = "+"
MenuToggle.TextColor3 = Color3.new(1, 1, 1)
MenuToggle.Font = "GothamBold"
MenuToggle.TextSize = 18
Instance.new("UICorner", MenuToggle).CornerRadius = UDim.new(0, 6)

-- Scrolling Container
local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -15, 0, 380)
Scroll.Position = UDim2.new(0, 7, 0, 60)
Scroll.BackgroundTransparency = 1
Scroll.Visible = false
Scroll.ScrollBarThickness = 1
Scroll.AutomaticCanvasSize = "Y"
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 10)

-- Helper Functions for GUI
local function AddHeader(txt)
    local l = Instance.new("TextLabel", Scroll)
    l.Size = UDim2.new(1, -10, 0, 20)
    l.Text = txt:upper()
    l.Font = "GothamBold"
    l.TextSize = 11
    l.TextColor3 = Color3.fromRGB(255, 70, 70)
    l.BackgroundTransparency = 1
end

local function AddToggle(name, configTable, configKey, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, -15, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name .. " : OFF"
    btn.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    btn.Font = "GothamBold"
    btn.TextSize = 12
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        configTable[configKey] = not configTable[configKey]
        btn.Text = name .. " : " .. (configTable[configKey] and "ON" or "OFF")
        local targetColor = configTable[configKey] and Color3.fromRGB(200, 40, 40) or Color3.fromRGB(30, 30, 30)
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
        if callback then callback(configTable[configKey]) end
    end)
end

local function AddSlider(name, min, max, configTable, configKey)
    local frame = Instance.new("Frame", Scroll)
    frame.Size = UDim2.new(1, -15, 0, 55)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = name .. " : " .. configTable[configKey]
    label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    label.Font = "Gotham"
    label.TextSize = 11
    label.BackgroundTransparency = 1
    
    local bar = Instance.new("TextButton", frame)
    bar.Size = UDim2.new(1, 0, 0, 10)
    bar.Position = UDim2.new(0, 0, 0, 25)
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    bar.Text = ""
    Instance.new("UICorner", bar)
    
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((configTable[configKey]-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    Instance.new("UICorner", fill)
    
    local dragging = false
    local function update()
        local percent = math.clamp((UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        local val = math.floor(min + (percent * (max - min)))
        configTable[configKey] = val
        label.Text = name .. " : " .. val
    end
    
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
end

-- // POPULATING MENU
AddHeader("Combat Protocols")
AddToggle("Silent Aim", Config.Combat, "SilentAim")
AddToggle("Hitbox Expander", Config.Combat, "HitboxExpander")
AddSlider("Hitbox Radius", 2, 200, Config.Combat, "HitboxSize")
AddToggle("Spinbot", Config.Combat, "Spinbot")
AddSlider("Spin Speed", 0, 500, Config.Combat, "SpinSpeed")

AddHeader("Kinematic Movement")
AddToggle("Speed Bypass", Config.Movement, "SpeedBypass")
AddSlider("Walk Speed", 16, 1000, Config.Movement, "WalkSpeed")
AddSlider("Jump Power", 50, 800, Config.Movement, "JumpPower")
AddSlider("Gravity Level", 0, 500, Config.Movement, "GravityControl")
AddToggle("Multi-Jump", Config.Movement, "MultiJump")
AddToggle("Anti-Ragdoll", Config.Movement, "AntiRagdoll")

AddHeader("Visual Perception")
AddToggle("Name ESP", Config.Visuals, "NameESP")
AddToggle("Box ESP", Config.Visuals, "BoxESP")
AddToggle("Tracer ESP", Config.Visuals, "TracerESP")
AddToggle("X-Ray Filter", Config.Visuals, "XRay", function(s) ManageXRay(s) end)

AddHeader("Miscellaneous")
AddToggle("Auto Interact", Config.Misc, "AutoInteract")

-- // SOCIAL BUTTONS
local function AddSocial(name, color, link)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1, -15, 0, 42)
    b.BackgroundColor3 = color
    b.Text = name .. " (Copy Link)"
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = "GothamBold"
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        setclipboard(link)
        b.Text = "Copied Success! ✅"
        task.wait(2)
        b.Text = name .. " (Copy Link)"
    end)
end

AddSocial("Discord: rzgr1ks", Color3.fromRGB(88, 101, 242), "https://discord.gg/XpbcvVdU")
AddSocial("YouTube: rzgr1ks", Color3.fromRGB(255, 0, 0), "https://youtube.com/@rzgr1ks")

-- // FINALIZING
local open = false
MenuToggle.MouseButton1Click:Connect(function()
    open = not open
    Scroll.Visible = open
    MenuToggle.Text = open and "x" or "+"
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = open and UDim2.new(0, 360, 0, 500) or UDim2.new(0, 360, 0, 52)
    }):Play()
end)

-- Initial Setup
for _, p in pairs(Players:GetPlayers()) do if p ~= LOCAL_PLAYER then InitializeESP(p) end end
Players.PlayerAdded:Connect(InitializeESP)

Log("Full Professional Suite Loaded.")
print("made by @ylzk on dc")
