--[[
    ====================================================================================================
    @project: RZGR1KS DUELS - ENTERPRISE PRIVATE EXECUTIVE
    @version: 5.0.1 (UI Visibility & Injection Patch)
    @status: Optimized for All High-End Executors
    
    [FIXED IN 5.0.1]
    - UI INVISIBILITY: Added multi-layered parenting logic (gethui -> CoreGui -> PlayerGui).
    - LOADING HANG: Implemented game-load verification to prevent script execution on empty workspace.
    - DEPTH ORDER: Set DisplayOrder to 999,999 to ensure the menu is always on top.
    ====================================================================================================
]]--

-- // WAIT FOR GAME TO INITIALIZE
if not game:IsLoaded() then
    repeat task.wait() until game:IsLoaded()
end

-- // CORE SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- // LOCAL ENVIRONMENT
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()
local ConfigFile = "RZGR1KS_V5_STABLE.json"

-- // TARGET UI PARENT (ULTRA-STABLE INJECTION)
local TargetParent = nil
local success, err = pcall(function()
    TargetParent = (gethui and gethui()) or CoreGui or PlayerGui
end)
if not success or not TargetParent then TargetParent = PlayerGui end

-- // CLEANUP PREVIOUS SESSIONS
if TargetParent:FindFirstChild("RZGR1KS_ENTERPRISE_FRAMEWORK") then
    TargetParent:FindFirstChild("RZGR1KS_ENTERPRISE_FRAMEWORK"):Destroy()
end

-- // DATA STORAGE
local Config = {
    Combat = { HitboxEnabled = false, HitboxSize = 25, HitboxTransparency = 0.75, SpinbotActive = false, SpinRPM = 50 },
    Movement = { Speed = 16, Jump = 50, Gravity = 196.2, InfiniteJump = false, AntiRagdoll = false },
    Visuals = { HighlightESP = false, ESP_Color = Color3.fromRGB(220, 40, 40), XRayActive = false },
    Misc = { AutoInteract = false, AntiAFK = true }
}

local function SaveConfig()
    pcall(function() if writefile then writefile(ConfigFile, HttpService:JSONEncode(Config)) end end)
end

pcall(function()
    if isfile and isfile(ConfigFile) and readfile then
        local decoded = HttpService:JSONDecode(readfile(ConfigFile))
        for category, keys in pairs(decoded) do
            if Config[category] then for key, val in pairs(keys) do Config[category][key] = val end end
        end
    end
end)

-- // EXECUTIVE GUI INITIALIZATION
local ScreenUI = Instance.new("ScreenGui")
ScreenUI.Name = "RZGR1KS_ENTERPRISE_FRAMEWORK"
ScreenUI.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenUI.DisplayOrder = 999999
ScreenUI.ResetOnSpawn = false
ScreenUI.IgnoreGuiInset = true
ScreenUI.Parent = TargetParent

local MainFrame = Instance.new("Frame", ScreenUI)
MainFrame.Name = "MainContainer"
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -190, 0.15, 0)
MainFrame.Size = UDim2.new(0, 380, 0, 52)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("Frame", MainFrame)
Header.Name = "Header"
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Header.BackgroundTransparency = 1
Header.Size = UDim2.new(1, 0, 0, 52)

local Title = Instance.new("TextLabel", Header)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.Size = UDim2.new(1, -120, 1, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "RZGR1KS DUELS : ENTERPRISE"
Title.TextColor3 = Color3.fromRGB(220, 40, 40)
Title.TextSize = 15
Title.TextXAlignment = "Left"

local ToggleBtn = Instance.new("TextButton", Header)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.Position = UDim2.new(1, -95, 0, 10)
ToggleBtn.Size = UDim2.new(0, 80, 0, 32)
ToggleBtn.Font = "GothamBold"
ToggleBtn.Text = "OPEN"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextSize = 11
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local ContentScroll = Instance.new("ScrollingFrame", MainFrame)
ContentScroll.Position = UDim2.new(0, 10, 0, 65)
ContentScroll.Size = UDim2.new(1, -20, 0, 435)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 2
ContentScroll.Visible = false
ContentScroll.AutomaticCanvasSize = "Y"
Instance.new("UIListLayout", ContentScroll).Padding = UDim.new(0, 8)

-- // FUNCTIONAL MODULES
local function UpdateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if Config.Visuals.HighlightESP then
                local hl = p.Character:FindFirstChild("RZ_HL") or Instance.new("Highlight", p.Character)
                hl.Name = "RZ_HL"; hl.FillColor = Config.Visuals.ESP_Color; hl.FillTransparency = 0.7
            else
                if p.Character:FindFirstChild("RZ_HL") then p.Character.RZ_HL:Destroy() end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if hum and root then
        hum.WalkSpeed = Config.Movement.Speed
        hum.JumpPower = Config.Movement.Jump
        workspace.Gravity = Config.Movement.Gravity
        if Config.Combat.SpinbotActive then root.AssemblyAngularVelocity = Vector3.new(0, Config.Combat.SpinRPM, 0) end
        if Config.Movement.AntiRagdoll then hum.PlatformStand = false end
    end
end)

-- // UI COMPONENT BUILDER
local Components = {}

function Components:Section(txt)
    local l = Instance.new("TextLabel", ContentScroll)
    l.Size = UDim2.new(1, 0, 0, 30); l.BackgroundTransparency = 1; l.Font = "GothamBold"
    l.Text = "─── " .. txt:upper() .. " ───"; l.TextColor3 = Color3.fromRGB(220, 40, 40); l.TextSize = 10
end

function Components:Toggle(name, dataset, key, callback)
    local b = Instance.new("TextButton", ContentScroll)
    b.Size = UDim2.new(1, -10, 0, 42); b.BackgroundColor3 = dataset[key] and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(18, 18, 18)
    b.Font = "GothamBold"; b.Text = name .. " : " .. (dataset[key] and "ON" or "OFF"); b.TextColor3 = Color3.new(1, 1, 1); b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        dataset[key] = not dataset[key]
        b.Text = name .. " : " .. (dataset[key] and "ON" or "OFF")
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = dataset[key] and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(18, 18, 18)}):Play()
        if callback then callback(dataset[key]) end; SaveConfig()
    end)
end

function Components:Slider(name, min, max, dataset, key, callback)
    local f = Instance.new("Frame", ContentScroll); f.Size = UDim2.new(1, -10, 0, 65); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.BackgroundTransparency = 1; l.Text = name .. " : " .. dataset[key]; l.Font = "Gotham"; l.TextColor3 = Color3.new(0.8, 0.8, 0.8); l.TextSize = 11; l.TextXAlignment = "Left"
    local t = Instance.new("TextButton", f); t.Size = UDim2.new(1, 0, 0, 10); t.Position = UDim2.new(0, 0, 0, 30); t.BackgroundColor3 = Color3.fromRGB(30, 30, 30); t.Text = ""
    local fill = Instance.new("Frame", t); fill.Size = UDim2.new(math.clamp((dataset[key]-min)/(max-min), 0, 1), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
    Instance.new("UICorner", t); Instance.new("UICorner", fill)
    
    local sliding = false
    local function Update()
        local scale = math.clamp((UIS:GetMouseLocation().X - t.AbsolutePosition.X) / t.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (scale * (max - min)))
        dataset[key] = val; l.Text = name .. " : " .. val; fill.Size = UDim2.new(scale, 0, 1, 0)
        if callback then callback() end
    end
    t.MouseButton1Down:Connect(function() sliding = true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 and sliding then sliding = false; SaveConfig() end end)
    RunService.RenderStepped:Connect(function() if sliding then Update() end end)
end

-- // ASSEMBLE UI
Components:Section("Combat Operations")
Components:Toggle("Hitbox Mod", Config.Combat, "HitboxEnabled", function()
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = p.Character.HumanoidRootPart
        hrp.Size = Config.Combat.HitboxEnabled and Vector3.new(Config.Combat.HitboxSize, Config.Combat.HitboxSize, Config.Combat.HitboxSize) or Vector3.new(2, 2, 1)
        hrp.Transparency = Config.Combat.HitboxEnabled and 0.8 or 1
    end end
end)
Components:Slider("Hitbox Radius", 2, 250, Config.Combat, "HitboxSize")
Components:Toggle("Active Spinbot", Config.Combat, "SpinbotActive")
Components:Slider("Rotation RPM", 0, 1000, Config.Combat, "SpinRPM")

Components:Section("Physiology")
Components:Slider("Movement Velocity", 16, 1000, Config.Movement, "Speed")
Components:Slider("Jump Magnitude", 50, 1500, Config.Movement, "Jump")
Components:Toggle("Infinite Jump", Config.Movement, "InfiniteJump")

Components:Section("Visual Intelligence")
Components:Toggle("Lag-Free ESP", Config.Visuals, "HighlightESP", UpdateESP)

Components:Section("Enterprise Support")
local function Social(n, c, u)
    local b = Instance.new("TextButton", ContentScroll); b.Size = UDim2.new(1, -10, 0, 45); b.BackgroundColor3 = c; b.Font = "GothamBold"; b.Text = n .. " [COPY]"; b.TextColor3 = Color3.new(1, 1, 1); b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function() setclipboard(u); b.Text = "COPIED!"; task.wait(1.5); b.Text = n .. " [COPY]" end)
end
Social("YouTube: RZGR1KS", Color3.fromRGB(200, 30, 30), "https://youtube.com/@rzgr1ks")
Social("Discord: RZGR1KS", Color3.fromRGB(80, 95, 230), "https://discord.gg/XpbcvVdU")

-- // UI TOGGLE LOGIC
local Open = false
ToggleBtn.MouseButton1Click:Connect(function()
    Open = not Open
    ContentScroll.Visible = Open
    ToggleBtn.Text = Open and "CLOSE" or "OPEN"
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = Open and UDim2.new(0, 380, 0, 510) or UDim2.new(0, 380, 0, 52)}):Play()
end)

-- // ANTI-AFK
if Config.Misc.AntiAFK then
    LocalPlayer.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

print("----------------------------------------")
print("RZGR1KS DUELS EXECUTIVE V5.0.1 LOADED")
print("INJECTION SOURCE:", TargetParent.Name)
print("----------------------------------------")
UpdateESP()
