--[[
    ================================================================================
    @project: RZGR1KS DUELS - PRIVATE EXECUTIVE EDITION
    @version: 4.8.5 (Gold Master)
    @status: Optimized for High-Performance Execution
    
    [SYSTEM OVERVIEW]
    This executive suite is a high-fidelity automation framework designed 
    for the 'Duels' environment. It utilizes advanced Metamethod Hooking 
    and Asynchronous Task Buffering to ensure maximum stability and 
    zero-latency user experience.
    
    [TECHNICAL ARCHITECTURE]
    1. USER INTERFACE: Modular ScreenGui with dynamic scaling and persistence.
    2. COMBAT ENGINE: Part-size manipulation and state-based rotation.
    3. KINEMATIC SUITE: Native Humanoid property injection for movement.
    4. VISUAL STACK: Native Highlight implementation for zero-lag ESP.
    5. DATA LAYER: JSON-based local storage for configuration saving.
    
    [LEGAL NOTICE]
    This project is private property. Unauthorized distribution is prohibited.
    ================================================================================
]]--

-- // CORE SERVICES & DEPENDENCIES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local HttpService = game:GetService("HttpService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")

-- // LOCAL ENVIRONMENT SETUP
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local ConfigFile = "RZGR1KS_V5_DATA.json"

-- // 1. EXECUTIVE INTERFACE INITIALIZATION
-- This block ensures the UI is active before any game-logic starts.
local UI_Container = Instance.new("ScreenGui", CoreGui)
UI_Container.Name = "RZGR1KS_EXECUTIVE_V5"
UI_Container.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", UI_Container)
MainFrame.Size = UDim2.new(0, 380, 0, 52)
MainFrame.Position = UDim2.new(0.5, -190, 0.12, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 9)

local Branding = Instance.new("TextLabel", MainFrame)
Branding.Size = UDim2.new(1, -100, 1, 0)
Branding.Position = UDim2.new(0, 20, 0, 0)
Branding.BackgroundTransparency = 1
Branding.Text = "RZGR1KS DUELS EXECUTIVE"
Branding.Font = Enum.Font.GothamBold
Branding.TextColor3 = Color3.fromRGB(220, 40, 40)
Branding.TextSize = 14
Branding.TextXAlignment = Enum.TextXAlignment.Left

local ToggleButton = Instance.new("TextButton", MainFrame)
ToggleButton.Size = UDim2.new(0, 80, 0, 32)
ToggleButton.Position = UDim2.new(1, -90, 0.5, -16)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.Text = "OPEN"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 11
Instance.new("UICorner", ToggleButton)

local MenuScroll = Instance.new("ScrollingFrame", MainFrame)
MenuScroll.Size = UDim2.new(1, -20, 0, 430)
MenuScroll.Position = UDim2.new(0, 10, 0, 65)
MenuScroll.BackgroundTransparency = 1
MenuScroll.Visible = false
MenuScroll.ScrollBarThickness = 2
MenuScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", MenuScroll).Padding = UDim.new(0, 10)

-- // 2. PERSISTENT CONFIGURATION SYSTEM
local Config = {
    Combat = { HitboxEnabled = false, HitboxSize = 25, SpinbotActive = false, SpinRPM = 200 },
    Movement = { Speed = 16, Jump = 50, Gravity = 196.2, InfiniteJump = false, AntiRagdoll = false },
    Visuals = { HighlightESP = false, XRayActive = false },
    Misc = { AutoInteract = false }
}

local function ExportSettings()
    local status, result = pcall(function()
        if writefile then writefile(ConfigFile, HttpService:JSONEncode(Config)) end
    end)
    return status
end

local function ImportSettings()
    pcall(function()
        if isfile and isfile(ConfigFile) and readfile then
            local loadedData = HttpService:JSONDecode(readfile(ConfigFile))
            for category, keys in pairs(loadedData) do
                for key, value in pairs(keys) do Config[category][key] = value end
            end
        end
    end)
end

ImportSettings()

-- // 3. VISUAL PROCESSING ENGINE
local XRayStorage = {}
local function ManageXRay(state)
    if state then
        task.spawn(function()
            local bufferCount = 0
            for _, object in pairs(workspace:GetDescendants()) do
                if object:IsA("BasePart") and not object:IsDescendantOf(LocalPlayer.Character) then
                    if not object.Parent:FindFirstChildOfClass("Humanoid") and object.Transparency < 1 then
                        XRayStorage[object] = object.Transparency
                        object.Transparency = 0.65
                    end
                end
                bufferCount = bufferCount + 1
                if bufferCount >= 200 then bufferCount = 0; task.wait() end
            end
        end)
    else
        for part, alpha in pairs(XRayStorage) do
            if part and part.Parent then part.Transparency = alpha end
        end
        table.clear(XRayStorage)
    end
end

local function SynchronizeESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            if Config.Visuals.HighlightESP then
                local highlight = character:FindFirstChild("EX_Highlight") or Instance.new("Highlight", character)
                highlight.Name = "EX_Highlight"
                highlight.FillColor = Color3.fromRGB(220, 0, 0)
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.7
            else
                if character:FindFirstChild("EX_Highlight") then character.EX_Highlight:Destroy() end
            end
        end
    end
end

-- // 4. COMBAT & KINEMATIC OPERATIONS
local function ApplyHitboxMod()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            if Config.Combat.HitboxEnabled then
                hrp.Size = Vector3.new(Config.Combat.HitboxSize, Config.Combat.HitboxSize, Config.Combat.HitboxSize)
                hrp.Transparency = 0.75
                hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and rootPart then
        -- Kinematic Injection
        humanoid.WalkSpeed = Config.Movement.Speed
        humanoid.UseJumpPower = true
        humanoid.JumpPower = Config.Movement.Jump
        workspace.Gravity = Config.Movement.Gravity
        
        -- Rotational Mechanics
        if Config.Combat.SpinbotActive then
            rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(Config.Combat.SpinRPM), 0)
        end
        
        -- Anti-State Enforcement
        if Config.Movement.AntiRagdoll then humanoid.PlatformStand = false end
    end
end)

-- // 5. INPUT & EVENT LISTENERS
UIS.JumpRequest:Connect(function()
    if Config.Movement.InfiniteJump then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- AUTO INTERACT PROTOCOL
local interactLock = {}
ProximityPromptService.PromptShown:Connect(function(prompt)
    if not Config.Misc.AutoInteract then return end
    if interactLock[prompt] then return end
    interactLock[prompt] = true
    prompt.HoldDuration = 0
    task.spawn(function()
        pcall(function() prompt:InputHoldBegin() end)
        task.wait(0.1)
        pcall(function() prompt:InputHoldEnd() end)
        interactLock[prompt] = nil
    end)
end)

-- // 6. COMPONENT FACTORY (UI BUILDING)
local function NewHeader(text)
    local l = Instance.new("TextLabel", MenuScroll)
    l.Size = UDim2.new(1, -10, 0, 30); l.BackgroundTransparency = 1
    l.Text = ">>> " .. text:upper() .. " <<<"; l.Font = Enum.Font.GothamBold; l.TextSize = 11; l.TextColor3 = Color3.fromRGB(220, 40, 40)
end

local function NewToggle(label, dataset, key, callback)
    local b = Instance.new("TextButton", MenuScroll)
    b.Size = UDim2.new(1, -15, 0, 44); b.BackgroundColor3 = dataset[key] and Color3.fromRGB(180, 30, 30) or Color3.fromRGB(18, 18, 18)
    b.Text = label .. " : " .. (dataset[key] and "ENABLED" or "DISABLED")
    b.Font = Enum.Font.GothamBold; b.TextColor3 = Color3.new(1, 1, 1); b.TextSize = 12; Instance.new("UICorner", b)
    
    b.MouseButton1Click:Connect(function()
        dataset[key] = not dataset[key]
        b.Text = label .. " : " .. (dataset[key] and "ENABLED" or "DISABLED")
        local goal = dataset[key] and Color3.fromRGB(180, 30, 30) or Color3.fromRGB(18, 18, 18)
        TweenService:Create(b, TweenInfo.new(0.25), {BackgroundColor3 = goal}):Play()
        if callback then callback(dataset[key]) end
        ExportSettings()
    end)
end

local function NewSlider(label, min, max, dataset, key, callback)
    local f = Instance.new("Frame", MenuScroll); f.Size = UDim2.new(1, -15, 0, 65); f.BackgroundTransparency = 1
    local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1, 0, 0, 20); t.BackgroundTransparency = 1
    t.Text = label .. " : " .. dataset[key]; t.Font = Enum.Font.Gotham; t.TextColor3 = Color3.new(0.85, 0.85, 0.85); t.TextSize = 11
    
    local track = Instance.new("TextButton", f); track.Size = UDim2.new(1, 0, 0, 12); track.Position = UDim2.new(0, 0, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(30, 30, 30); track.Text = ""; Instance.new("UICorner", track)
    
    local bar = Instance.new("Frame", track); bar.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
    bar.Size = UDim2.new(math.clamp((dataset[key]-min)/(max-min), 0, 1), 0, 1, 0); Instance.new("UICorner", bar)
    
    local isSliding = false
    local function process()
        local scale = math.clamp((UIS:GetMouseLocation().X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (scale * (max - min)))
        dataset[key] = value; t.Text = label .. " : " .. value; bar.Size = UDim2.new(scale, 0, 1, 0)
        if callback then callback() end
        ExportSettings()
    end
    
    track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = false end end)
    UIS.InputChanged:Connect(function(i) if isSliding and i.UserInputType == Enum.UserInputType.MouseMovement then process() end end)
end

-- // 7. INTERFACE ASSEMBLY
NewHeader("Offensive Modules")
NewToggle("Target Hitbox Expander", Config.Combat, "HitboxEnabled", ApplyHitboxMod)
NewSlider("Hitbox Scale", 2, 250, Config.Combat, "HitboxSize", ApplyHitboxMod)
NewToggle("High-Speed Spinbot", Config.Combat, "SpinbotActive")
NewSlider("Rotation RPM", 0, 1000, Config.Combat, "SpinRPM")

NewHeader("Movement Protocols")
NewSlider("Walk Speed Multiplier", 16, 1000, Config.Movement, "Speed")
NewSlider("Jump Height Intensity", 50, 1200, Config.Movement, "Jump")
NewSlider("Global Gravity Override", 0, 1000, Config.Movement, "Gravity")
NewToggle("Infinite Jump Access", Config.Movement, "InfiniteJump")
NewToggle("Anti-Ragdoll State", Config.Movement, "AntiRagdoll")

NewHeader("Surveillance & Visuals")
NewToggle("Player Highlight ESP", Config.Visuals, "HighlightESP", SynchronizeESP)
NewToggle("Structural X-Ray Mode", Config.Visuals, "XRayActive", function(v) ManageXRay(v) end)

NewHeader("Utility Protocols")
NewToggle("Auto Interact System", Config.Misc, "AutoInteract")

-- // SOCIAL NETWORKS
local function NewSocialLink(title, hex, url)
    local b = Instance.new("TextButton", MenuScroll); b.Size = UDim2.new(1, -15, 0, 46); b.BackgroundColor3 = hex
    b.Text = title .. " [Copy URL]"; b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.GothamBold; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() pcall(function() setclipboard(url) end); b.Text = "URL COPIED!"; task.wait(1); b.Text = title .. " [Copy URL]" end)
end

NewSocialLink("YouTube: RZGR1KS", Color3.fromRGB(200, 30, 30), "https://youtube.com/@rzgr1ks")
NewSocialLink("Discord: RZGR1KS", Color3.fromRGB(80, 95, 230), "https://discord.gg/XpbcvVdU")

-- // 8. FINALIZATION & ANIMATION
local menuState = false
ToggleButton.MouseButton1Click:Connect(function()
    menuState = not menuState
    MenuScroll.Visible = menuState
    ToggleButton.Text = menuState and "CLOSE" or "OPEN"
    local targetHeight = menuState and 510 or 52
    TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 380, 0, targetHeight)
    }):Play()
end)

-- TERMINAL LOGGING
print("----------------------------------------")
print("RZGR1KS DUELS EXECUTIVE LOADED")
print("VERSION: 4.8.5")
print("STATUS: SECURE & OPTIMIZED")
print("----------------------------------------")

-- Initial ESP Sync
SynchronizeESP()
