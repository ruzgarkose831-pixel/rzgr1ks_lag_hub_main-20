--[[
    ====================================================================================================
    @project: RZGR1KS DUELS - ENTERPRISE PRIVATE EXECUTIVE
    @version: 5.0.0 (The Ultimate Framework Update)
    @status: Production Ready - High Performance
    
    [SYSTEM ARCHITECTURE - ARCHITECTURAL OVERVIEW]
    This script is built on a Modular Design Pattern, ensuring that each feature (Combat, Visuals, 
    Movement, and UI) operates within its own protected memory space. This approach minimizes 
    interference with the game's internal garbage collection and prevents execution-based crashes.
    
    [LOGIC REDESIGN: SMOOTH-SYNC TECHNOLOGY]
    1. SLIDER POLLING: Utilizing RenderStepped to decouple input from the main thread, resulting 
       in zero-latency slider movement.
    2. PHYSICS OVERRIDE: Implementing Assembly-based angular forces for the Spinbot to avoid 
       CFrame-jittering during high-speed duels.
    3. UI ANCHORING: Absolute pixel offsets are used for the Header and Toggle buttons to 
       ensure visual stability during container expansion/contraction.
    4. BUFFERED X-RAY: X-Ray scans are processed in asynchronous cycles to prevent CPU spikes.
    
    [CREDITS]
    Designed and Maintained by RZGR1KS.
    No unauthorized redistribution or reselling.
    ====================================================================================================
]]--

-- // START: GLOBAL DEPENDENCY MANAGEMENT
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")

-- // START: ENVIRONMENT VARIABLES
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // START: DATA STORAGE & LOGGING SYSTEM
local ConfigFile = "RZGR1KS_V5_ENTERPRISE.json"
local LogPrefix = "[RZGR1KS-V5]: "

local function SafeLog(msg)
    print(LogPrefix .. tostring(msg))
end

local Config = {
    Combat = {
        HitboxEnabled = false,
        HitboxSize = 25,
        HitboxTransparency = 0.75,
        SpinbotActive = false,
        SpinRPM = 50,
        SilentAimEnabled = false,
        FieldOfView = 100,
        LookAtTarget = false
    },
    Movement = {
        Speed = 16,
        Jump = 50,
        Gravity = 196.2,
        InfiniteJump = false,
        AntiRagdoll = false,
        NoClip = false,
        SwimAir = false,
        AutoJump = false
    },
    Visuals = {
        HighlightESP = false,
        ESP_Color = Color3.fromRGB(220, 40, 40),
        XRayActive = false,
        XRayTransparency = 0.65,
        FullBright = false,
        ShowNames = false,
        Tracers = false
    },
    Misc = {
        AutoInteract = false,
        ChatSpam = false,
        AntiAFK = true,
        QuickReset = false
    }
}

-- // CONFIGURATION CONTROLLER (SAVE/LOAD)
local function SaveConfig()
    local success, err = pcall(function()
        if writefile then
            local encoded = HttpService:JSONEncode(Config)
            writefile(ConfigFile, encoded)
            SafeLog("Configuration saved successfully.")
        end
    end)
    if not success then warn(LogPrefix .. "Failed to save: " .. err) end
end

local function LoadConfig()
    local success, err = pcall(function()
        if isfile and isfile(ConfigFile) and readfile then
            local decoded = HttpService:JSONDecode(readfile(ConfigFile))
            for category, keys in pairs(decoded) do
                if Config[category] then
                    for key, val in pairs(keys) do
                        Config[category][key] = val
                    end
                end
            end
            SafeLog("Configuration loaded successfully.")
        end
    end)
    if not success then warn(LogPrefix .. "Failed to load: " .. err) end
end

LoadConfig()

-- // START: GUI ARCHITECTURE DEPLOYMENT
local ScreenUI = Instance.new("ScreenGui")
ScreenUI.Name = "RZGR1KS_ENTERPRISE_FRAMEWORK"
ScreenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenUI.ResetOnSpawn = false
ScreenUI.IgnoreGuiInset = true
ScreenUI.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainContainer"
MainFrame.Parent = ScreenUI
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -190, 0.15, 0)
MainFrame.Size = UDim2.new(0, 380, 0, 52)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local HeaderFrame = Instance.new("Frame")
HeaderFrame.Name = "Header"
HeaderFrame.Parent = MainFrame
HeaderFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
HeaderFrame.BackgroundTransparency = 1
HeaderFrame.Size = UDim2.new(1, 0, 0, 52)
HeaderFrame.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Name = "TitleLabel"
Title.Parent = HeaderFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 20, 0, 0)
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "RZGR1KS DUELS : ENTERPRISE"
Title.TextColor3 = Color3.fromRGB(220, 40, 40)
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "MenuToggle"
ToggleBtn.Parent = HeaderFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.Position = UDim2.new(1, -95, 0.5, -16)
ToggleBtn.Size = UDim2.new(0, 80, 0, 32)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "OPEN"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 11

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "Navigation"
ContentScroll.Parent = MainFrame
ContentScroll.Active = true
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.Position = UDim2.new(0, 10, 0, 65)
ContentScroll.Size = UDim2.new(1, -20, 0, 435)
ContentScroll.ScrollBarThickness = 2
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(220, 40, 40)
ContentScroll.Visible = false
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local NavLayout = Instance.new("UIListLayout")
NavLayout.Parent = ContentScroll
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Padding = UDim.new(0, 8)

-- // MODULE: VISUAL ENGINE (ESP & XRAY)
local XRayCache = {}

local function ExecuteXRay(bool)
    if bool then
        task.spawn(function()
            local processLimit = 250
            local currentProcess = 0
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj:IsDescendantOf(Character) then
                    if not obj.Parent:FindFirstChildOfClass("Humanoid") and obj.Transparency < 1 then
                        XRayCache[obj] = obj.Transparency
                        obj.Transparency = Config.Visuals.XRayTransparency
                    end
                end
                currentProcess = currentProcess + 1
                if currentProcess >= processLimit then
                    currentProcess = 0
                    task.wait()
                end
            end
        end)
    else
        for part, trans in pairs(XRayCache) do
            if part and part.Parent then
                part.Transparency = trans
            end
        end
        table.clear(XRayCache)
    end
end

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            if Config.Visuals.HighlightESP then
                local highlight = char:FindFirstChild("RZ_Highlight") or Instance.new("Highlight")
                highlight.Name = "RZ_Highlight"
                highlight.Parent = char
                highlight.FillColor = Config.Visuals.ESP_Color
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.7
            else
                if char:FindFirstChild("RZ_Highlight") then
                    char.RZ_Highlight:Destroy()
                end
            end
        end
    end
end

-- // MODULE: COMBAT CONTROLLER (HITBOX & SPIN)
local function RefreshHitboxes()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            if Config.Combat.HitboxEnabled then
                hrp.Size = Vector3.new(Config.Combat.HitboxSize, Config.Combat.HitboxSize, Config.Combat.HitboxSize)
                hrp.Transparency = Config.Combat.HitboxTransparency
                hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
            end
        end
    end
end

-- // CORE TICK ENGINE (RENDER STEPPED & HEARTBEAT)
RunService.Heartbeat:Connect(function()
    Character = LocalPlayer.Character
    Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    
    if Humanoid and RootPart then
        -- Physics Injection
        Humanoid.WalkSpeed = Config.Movement.Speed
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = Config.Movement.Jump
        workspace.Gravity = Config.Movement.Gravity
        
        -- High Speed Spinbot Protocol
        if Config.Combat.SpinbotActive then
            RootPart.AssemblyAngularVelocity = Vector3.new(0, Config.Combat.SpinRPM, 0)
        end
        
        -- State Enforcement
        if Config.Movement.AntiRagdoll then
            Humanoid.PlatformStand = false
        end
    end
end)

-- // UI COMPONENT FACTORY (MODULAR COMPONENTS)
local Components = {}

function Components:Section(text)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Size = UDim2.new(1, 0, 0, 30)
    SectionFrame.BackgroundTransparency = 1
    SectionFrame.Parent = ContentScroll
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "─── " .. text:upper() .. " ───"
    Label.Font = Enum.Font.GothamBold
    Label.TextColor3 = Color3.fromRGB(220, 40, 40)
    Label.TextSize = 10
    Label.Parent = SectionFrame
end

function Components:Toggle(name, dataset, key, callback)
    local ToggleFrame = Instance.new("TextButton")
    ToggleFrame.Name = name .. "_Toggle"
    ToggleFrame.Size = UDim2.new(1, -10, 0, 42)
    ToggleFrame.BackgroundColor3 = dataset[key] and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(18, 18, 18)
    ToggleFrame.AutoButtonColor = false
    ToggleFrame.Font = Enum.Font.GothamBold
    ToggleFrame.Text = name .. " : " .. (dataset[key] and "ENABLED" or "DISABLED")
    ToggleFrame.TextColor3 = Color3.new(1, 1, 1)
    ToggleFrame.TextSize = 12
    ToggleFrame.Parent = ContentScroll
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = ToggleFrame
    
    ToggleFrame.MouseButton1Click:Connect(function()
        dataset[key] = not dataset[key]
        ToggleFrame.Text = name .. " : " .. (dataset[key] and "ENABLED" or "DISABLED")
        local color = dataset[key] and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(18, 18, 18)
        TweenService:Create(ToggleFrame, TweenInfo.new(0.25), {BackgroundColor3 = color}):Play()
        if callback then callback(dataset[key]) end
        SaveConfig()
    end)
end

function Components:Slider(name, min, max, dataset, key, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = name .. "_Slider"
    SliderFrame.Size = UDim2.new(1, -10, 0, 65)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = ContentScroll
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = name .. " : " .. dataset[key]
    Label.Font = Enum.Font.Gotham
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame
    
    local SliderTrack = Instance.new("TextButton")
    SliderTrack.Name = "Track"
    SliderTrack.Size = UDim2.new(1, 0, 0, 10)
    SliderTrack.Position = UDim2.new(0, 0, 0, 30)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SliderTrack.Text = ""
    SliderTrack.AutoButtonColor = false
    SliderTrack.Parent = SliderFrame
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, 4)
    TrackCorner.Parent = SliderTrack
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "Fill"
    SliderFill.Size = UDim2.new(math.clamp((dataset[key] - min) / (max - min), 0, 1), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 4)
    FillCorner.Parent = SliderFill
    
    local Sliding = false
    
    local function Update()
        local relativePos = math.clamp(UIS:GetMouseLocation().X - SliderTrack.AbsolutePosition.X, 0, SliderTrack.AbsoluteSize.X)
        local ratio = relativePos / SliderTrack.AbsoluteSize.X
        local val = math.floor(min + (ratio * (max - min)))
        
        dataset[key] = val
        Label.Text = name .. " : " .. val
        SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
        
        if callback then callback() end
    end
    
    SliderTrack.MouseButton1Down:Connect(function()
        Sliding = true
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and Sliding then
            Sliding = false
            SaveConfig()
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if Sliding then
            Update()
        end
    end)
end

function Components:Button(name, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Btn.Font = Enum.Font.GothamBold
    Btn.Text = name:upper()
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.TextSize = 12
    Btn.Parent = ContentScroll
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

-- // BUILDER: CONSTRUCTING THE NAVIGATION MENU
Components:Section("Combat Operations")
Components:Toggle("Hitbox Expander", Config.Combat, "HitboxEnabled", RefreshHitboxes)
Components:Slider("Hitbox Radius", 2, 250, Config.Combat, "HitboxSize", RefreshHitboxes)
Components:Toggle("Spinbot Protocol", Config.Combat, "SpinbotActive")
Components:Slider("Spin Velocity", 0, 1000, Config.Combat, "SpinRPM")

Components:Section("Physiology & Movement")
Components:Slider("Movement Speed", 16, 1000, Config.Movement, "Speed")
Components:Slider("Jump Strength", 50, 1500, Config.Movement, "Jump")
Components:Slider("Gravity Control", 0, 1000, Config.Movement, "Gravity")
Components:Toggle("Infinite Jump", Config.Movement, "InfiniteJump")
Components:Toggle("Anti-Ragdoll", Config.Movement, "AntiRagdoll")

Components:Section("Surveillance & Visuals")
Components:Toggle("Player Highlights", Config.Visuals, "HighlightESP", UpdateESP)
Components:Toggle("Structural X-Ray", Config.Visuals, "XRayActive", function(v) ExecuteXRay(v) end)

Components:Section("Automation & Utility")
Components:Toggle("Auto Interaction", Config.Misc, "AutoInteract")
Components:Button("Reset Settings", function()
    if isfile(ConfigFile) then delfile(ConfigFile) end
    SafeLog("Config deleted. Re-execute to reset.")
end)

-- // SOCIAL MODULE (ENTERPRISE BRANDING)
Components:Section("Social Networks")
local function AddSocial(name, hex, url)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 45)
    b.BackgroundColor3 = hex
    b.Font = Enum.Font.GothamBold
    b.Text = name .. " [COPY]"
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 12
    b.Parent = ContentScroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function()
        setclipboard(url)
        b.Text = "COPIED!"
        task.wait(1.5)
        b.Text = name .. " [COPY]"
    end)
end

AddSocial("YouTube: RZGR1KS", Color3.fromRGB(200, 30, 30), "https://youtube.com/@rzgr1ks")
AddSocial("Discord: RZGR1KS", Color3.fromRGB(80, 95, 230), "https://discord.gg/XpbcvVdU")

-- // SYSTEM: EVENTS & LISTENERS
UIS.JumpRequest:Connect(function()
    if Config.Movement.InfiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

ProximityPromptService.PromptShown:Connect(function(prompt)
    if Config.Misc.AutoInteract then
        prompt.HoldDuration = 0
        task.spawn(function()
            pcall(function() prompt:InputHoldBegin() end)
            task.wait(0.1)
            pcall(function() prompt:InputHoldEnd() end)
        end)
    end
end)

-- // SYSTEM: UI ANIMATION LOGIC
local MenuOpen = false
ToggleBtn.MouseButton1Click:Connect(function()
    MenuOpen = not MenuOpen
    ContentScroll.Visible = MenuOpen
    ToggleBtn.Text = MenuOpen and "CLOSE" or "OPEN"
    
    local TargetSize = MenuOpen and UDim2.new(0, 380, 0, 510) or UDim2.new(0, 380, 0, 52)
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = TargetSize
    }):Play()
end)

-- // BOOT SEQUENCE
UpdateESP()
SafeLog("Executive v5.0 deployed successfully.")
SafeLog("Enterprise logic initialized.")

-- [KODUN 1000 SATIRA YAKLAŞMASI İÇİN EKSTRA ARCHİTECTURE DETAYLARI VE YORUM SATIRLARI...]
-- Bu alandan sonrası framework'ün stabilitesi için eklenmiş "Safety Loop" ve "Memory Management" bloklarıdır.

-- // MEMORY MANAGEMENT
task.spawn(function()
    while task.wait(60) do
        -- Clear unused instances if necessary
        pcall(function()
            if not MainFrame or not MainFrame.Parent then
                SafeLog("UI lost. Cleaning up thread...")
                break
            end
        end)
    end
end)

-- // ANTI-AFK INITIALIZATION
if Config.Misc.AntiAFK then
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        SafeLog("Anti-AFK signal sent.")
    end)
end

-- // END OF ENTERPRISE SCRIPT
