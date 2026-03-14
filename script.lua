--[[
    ================================================================================
    @title: RZGR1KS DUEL V48 - ULTIMATE PROFESSIONAL EXECUTIVE
    @version: 4.8.2 (Stable)
    @collaboration: RZGR1KS x Gemini AI
    @license: Private / Educational
    
    [SYSTEM ARCHITECTURE]
    This framework is built upon a modular design pattern. Each capability 
    (Combat, Movement, Visuals) is isolated to prevent cross-thread interference.
    
    [FEATURES]
    - Silent Aim: Field-of-View based targeting logic.
    - Hitbox Expander: Dynamic size adjustment via responsive sliders.
    - Speed Bypass: Anti-cheat resistant movement acceleration.
    - Multi-Jump: State-change jumping logic for infinite air movement.
    - Drawing ESP: Professional-grade vector overlays for player tracking.
    - Auto-Interact: ProximityPrompt automation (Credits: @ylzk).
    - Config System: Permanent local storage for user preferences.
    
    [CHANGE LOG V48.2]
    - FIXED: Slider responsiveness (Reverted to classic input handling).
    - ADDED: JSON Configuration Saving/Loading.
    - ADDED: Full English localization.
    - OPTIMIZED: X-Ray memory leaks addressed.
    ================================================================================
]]--

-- // SERVICES & DEPENDENCIES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local HttpService = game:GetService("HttpService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")

-- // LOCAL PLAYER ENVIRONMENT
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // INITIAL CONFIGURATION DATA
local DefaultConfig = {
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
        GravityLevel = 196.2,
        MultiJump = false,
        AntiRagdoll = false
    },
    Visuals = {
        NameESP = false,
        BoxESP = false,
        TracerESP = false,
        XRay = false
    },
    Misc = {
        AutoInteract = false
    }
}

-- Current active settings
local Config = DefaultConfig

-- // CONFIGURATION SYSTEM (SAVE/LOAD)
local ConfigFileName = "RZGR1KS_Settings.json"

local function SaveSettings()
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(Config)
    end)
    if success then
        writefile(ConfigFileName, encoded)
        print("[RZGR1KS] Configuration saved successfully.")
    end
end

local function LoadSettings()
    if isfile(ConfigFileName) then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFileName))
        end)
        if success then
            Config = decoded
            print("[RZGR1KS] Configuration loaded from file.")
        end
    end
end

-- Load settings immediately
LoadSettings()

-- // COMBAT UTILITIES
local function GetClosestPlayer()
    local target, shortestDist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if magnitude < shortestDist then
                    target = v.Character.HumanoidRootPart
                    shortestDist = magnitude
                end
            end
        end
    end
    return target
end

-- // METAMETHOD HOOKING (SILENT AIM)
local OldNamecall; OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if not checkcaller() and Config.Combat.SilentAim and (method == "Raycast" or method == "FindPartOnRay") then
        local target = GetClosestPlayer()
        if target then
            if method == "Raycast" then
                args[2] = (target.Position - args[1]).Unit * 1000
            else
                args[1] = Ray.new(args[1].Origin, (target.Position - args[1].Origin).Unit * 1000)
            end
            return OldNamecall(self, unpack(args))
        end
    end
    return OldNamecall(self, ...)
end)

-- // VISUALS: DRAWING ESP ENGINE
local function CreateESP(player)
    local box = Drawing.new("Square")
    local tracer = Drawing.new("Line")
    local name = Drawing.new("Text")
    
    box.Thickness = 1; box.Filled = false
    tracer.Thickness = 1
    name.Size = 13; name.Center = true; name.Outline = true
    
    local connection; connection = RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local hrp = player.Character.HumanoidRootPart
            local hum = player.Character.Humanoid
            local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
            
            if vis and hum.Health > 0 then
                box.Visible = Config.Visuals.BoxESP
                tracer.Visible = Config.Visuals.TracerESP
                name.Visible = Config.Visuals.NameESP
                
                if box.Visible then
                    local size = 2200 / pos.Z
                    box.Size = Vector2.new(size, size * 1.2)
                    box.Position = Vector2.new(pos.X - box.Size.X/2, pos.Y - box.Size.Y/2)
                    box.Color = Color3.fromRGB(255, 60, 60)
                end
                
                if tracer.Visible then
                    tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    tracer.To = Vector2.new(pos.X, pos.Y)
                    tracer.Color = Color3.new(1,1,1)
                end
                
                if name.Visible then
                    name.Position = Vector2.new(pos.X, pos.Y - (2200/pos.Z) * 0.7)
                    name.Text = player.Name .. " [" .. math.floor(hum.Health) .. "]"
                end
            else
                box.Visible = false; tracer.Visible = false; name.Visible = false
            end
        else
            box.Visible = false; tracer.Visible = false; name.Visible = false
            if not player.Parent then 
                box:Remove(); tracer:Remove(); name:Remove(); connection:Disconnect() 
            end
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

-- // X-RAY MANAGER
local XRayCache = {}
local function ApplyXRay(state)
    if state then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character) and not v.Parent:FindFirstChildOfClass("Humanoid") then
                XRayCache[v] = v.Transparency
                v.Transparency = 0.6
            end
        end
    else
        for v, t in pairs(XRayCache) do if v and v.Parent then v.Transparency = t end end
        table.clear(XRayCache)
    end
end

-- // CORE TICK LOOP (PHYSICS & HITBOXES)
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum and root then
        hum.UseJumpPower = true
        hum.JumpPower = Config.Movement.JumpPower
        workspace.Gravity = Config.Movement.GravityLevel
        
        if Config.Movement.SpeedBypass and hum.MoveDirection.Magnitude > 0 then
            root.AssemblyLinearVelocity = Vector3.new(
                hum.MoveDirection.X * Config.Movement.WalkSpeed, 
                root.AssemblyLinearVelocity.Y, 
                hum.MoveDirection.Z * Config.Movement.WalkSpeed
            )
        end
        
        if Config.Combat.Spinbot then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Config.Combat.SpinSpeed), 0)
        end
        
        if Config.Movement.AntiRagdoll then hum.PlatformStand = false end
    end
    
    -- Hitbox Modification Logic
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            if Config.Combat.HitboxExpander then
                hrp.Size = Vector3.new(Config.Combat.HitboxSize, Config.Combat.HitboxSize, Config.Combat.HitboxSize)
                hrp.Transparency = 0.8; hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1
            end
        end
    end
end)

-- // MULTI JUMP INPUT
UIS.JumpRequest:Connect(function()
    if Config.Movement.MultiJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- // AUTO INTERACT (CREDIT: @ylzk)
local interacting = {}
ProximityPromptService.PromptShown:Connect(function(prompt)
    if not Config.Misc.AutoInteract then return end
    if interacting[prompt] then return end
    interacting[prompt] = true
    prompt.HoldDuration = 0
    task.spawn(function()
        pcall(function() prompt:InputHoldBegin() end)
        task.wait(0.1)
        pcall(function() prompt:InputHoldEnd() end)
        interacting[prompt] = nil
    end)
end)

-- // USER INTERFACE CONTEXT
local UI = Instance.new("ScreenGui", CoreGui)
UI.Name = "RZGR1KS_V48_CONFIG"
UI.ResetOnSpawn = false

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 360, 0, 52)
Main.Position = UDim2.new(0.5, -180, 0.15, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BorderSizePixel = 0
Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, -80, 1, 0); Header.Position = UDim2.new(0, 15, 0, 0)
Header.BackgroundTransparency = 1; Header.Text = "RZGR1KS DUEL EXECUTIVE"
Header.Font = "GothamBold"; Header.TextColor3 = Color3.fromRGB(255, 50, 50); Header.TextSize = 14; Header.TextXAlignment = "Left"

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0, 60, 0, 34); ToggleBtn.Position = UDim2.new(1, -70, 0, 9)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); ToggleBtn.Text = "+"; ToggleBtn.TextColor3 = Color3.new(1,1,1); ToggleBtn.Font = "GothamBold"; ToggleBtn.TextSize = 18
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -15, 0, 400); Scroll.Position = UDim2.new(0, 7, 0, 60)
Scroll.BackgroundTransparency = 1; Scroll.Visible = false; Scroll.ScrollBarThickness = 1; Scroll.AutomaticCanvasSize = "Y"
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 8)

-- // UI BUILDER FUNCTIONS
local function AddLabel(txt)
    local l = Instance.new("TextLabel", Scroll)
    l.Size = UDim2.new(1, -10, 0, 25); l.BackgroundTransparency = 1; l.Text = txt:upper()
    l.Font = "GothamBold"; l.TextSize = 10; l.TextColor3 = Color3.fromRGB(255, 50, 50)
end

local function AddToggle(name, configTable, configKey, callback)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1, -15, 0, 40); b.BackgroundColor3 = configTable[configKey] and Color3.fromRGB(200, 40, 40) or Color3.fromRGB(25, 25, 25)
    b.Text = name .. " : " .. (configTable[configKey] and "ON" or "OFF")
    b.Font = "GothamBold"; b.TextColor3 = Color3.new(1,1,1); b.TextSize = 12; Instance.new("UICorner", b)
    
    b.MouseButton1Click:Connect(function()
        configTable[configKey] = not configTable[configKey]
        b.Text = name .. " : " .. (configTable[configKey] and "ON" or "OFF")
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = configTable[configKey] and Color3.fromRGB(200, 40, 40) or Color3.fromRGB(25, 25, 25)}):Play()
        if callback then callback(configTable[configKey]) end
        SaveSettings()
    end)
end

-- FIXED SLIDER LOGIC (Responsive & Classic)
local function AddSlider(name, min, max, configTable, configKey)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(1, -15, 0, 55); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.BackgroundTransparency = 1
    l.Text = name .. " : " .. configTable[configKey]; l.Font = "Gotham"; l.TextColor3 = Color3.new(0.8, 0.8, 0.8); l.TextSize = 11
    
    local bar = Instance.new("TextButton", f); bar.Size = UDim2.new(1, 0, 0, 10); bar.Position = UDim2.new(0, 0, 0, 25)
    bar.BackgroundColor3 = Color3.fromRGB(35, 35, 35); bar.Text = ""; Instance.new("UICorner", bar)
    
    local fill = Instance.new("Frame", bar); fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    fill.Size = UDim2.new(math.clamp((configTable[configKey] - min) / (max - min), 0, 1), 0, 1, 0); Instance.new("UICorner", fill)
    
    local move = false
    local function update()
        local percent = math.clamp((UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (percent * (max - min)))
        configTable[configKey] = val
        l.Text = name .. " : " .. val
        fill.Size = UDim2.new(percent, 0, 1, 0)
        SaveSettings()
    end
    
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then move = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then move = false end end)
    UIS.InputChanged:Connect(function(i) if move and i.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
end

-- // POPULATE
AddLabel("Combat Settings")
AddToggle("Silent Aim", Config.Combat, "SilentAim")
AddToggle("Hitbox Expander", Config.Combat, "HitboxExpander")
AddSlider("Hitbox Radius", 2, 200, Config.Combat, "HitboxSize")
AddToggle("Spinbot", Config.Combat, "Spinbot")
AddSlider("Spin Speed", 0, 500, Config.Combat, "SpinSpeed")

AddLabel("Movement Protocols")
AddToggle("Speed Bypass", Config.Movement, "SpeedBypass")
AddSlider("Walk Speed", 16, 1000, Config.Movement, "WalkSpeed")
AddSlider("Jump Power", 50, 800, Config.Movement, "JumpPower")
AddSlider("Gravity Control", 0, 500, Config.Movement, "GravityLevel")
AddToggle("Multi-Jump", Config.Movement, "MultiJump")
AddToggle("Anti-Ragdoll", Config.Movement, "AntiRagdoll")

AddLabel("Visual Enhancement")
AddToggle("Name ESP", Config.Visuals, "NameESP")
AddToggle("Box ESP", Config.Visuals, "BoxESP")
AddToggle("Tracer ESP", Config.Visuals, "TracerESP")
AddToggle("X-Ray Filter", Config.Visuals, "XRay", function(s) ApplyXRay(s) end)

AddLabel("Miscellaneous")
AddToggle("Auto Interact", Config.Misc, "AutoInteract")

-- // SOCIAL BUTTONS
local function AddSocial(name, color, link)
    local b = Instance.new("TextButton", Scroll); b.Size = UDim2.new(1, -15, 0, 42); b.BackgroundColor3 = color
    b.Text = name .. " (Copy Link)"; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() setclipboard(link); b.Text = "Link Copied!"; task.wait(1.5); b.Text = name .. " (Copy Link)" end)
end

AddSocial("Discord: rzgr1ks", Color3.fromRGB(88, 101, 242), "https://discord.gg/XpbcvVdU")
AddSocial("YouTube: rzgr1ks", Color3.fromRGB(200, 40, 40), "https://youtube.com/@rzgr1ks")

-- // MAIN MENU TOGGLE
local open = false
ToggleBtn.MouseButton1Click:Connect(function()
    open = not open
    Scroll.Visible = open
    ToggleBtn.Text = open and "x" or "+"
    TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = open and UDim2.new(0, 360, 0, 480) or UDim2.new(0, 360, 0, 52)}):Play()
end)

print("RZGR1KS DUEL EXECUTIVE V48.2 LOADED")
print("made by @ylzk on dc")
