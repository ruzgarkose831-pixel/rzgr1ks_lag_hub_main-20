--[[
    ====================================================================================================
    @project: RZGR1KS DUELS - ENTERPRISE PRIVATE EXECUTIVE
    @version: 5.0.2 (Feature Restoration & Input Fix)
    @status: Optimized for High-Performance Execution
    
    [FIXED IN 5.0.2]
    - STICKY SLIDERS: Implemented global InputService listener to force release on mouse-up.
    - MISSING FEATURES: Restored X-Ray, Hitbox Expander, Multi-Jump, and Spinbot logic.
    - UI PERSISTENCE: Multi-layer parent check (gethui/CoreGui/PlayerGui) for visibility.
    ====================================================================================================
]]--

if not game:IsLoaded() then repeat task.wait() until game:IsLoaded() end

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
local Mouse = LocalPlayer:GetMouse()
local ConfigFile = "RZGR1KS_V5_ULTIMATE.json"

-- // TARGET UI PARENT
local TargetParent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
if TargetParent:FindFirstChild("RZGR1KS_ENTERPRISE_FRAMEWORK") then
    TargetParent:FindFirstChild("RZGR1KS_ENTERPRISE_FRAMEWORK"):Destroy()
end

-- // CONFIGURATION DATA
local Config = {
    Combat = {
        HitboxEnabled = false, HitboxSize = 25, HitboxTransparency = 0.75,
        SpinbotActive = false, SpinRPM = 50
    },
    Movement = {
        Speed = 16, Jump = 50, Gravity = 196.2, 
        InfiniteJump = false, AntiRagdoll = false
    },
    Visuals = {
        HighlightESP = false, ESP_Color = Color3.fromRGB(220, 40, 40),
        XRayActive = false, XRayTransparency = 0.65
    },
    Misc = {
        AutoInteract = false, AntiAFK = true
    }
}

local function SaveConfig()
    pcall(function() if writefile then writefile(ConfigFile, HttpService:JSONEncode(Config)) end end)
end

pcall(function()
    if isfile and isfile(ConfigFile) and readfile then
        local decoded = HttpService:JSONDecode(readfile(ConfigFile))
        for cat, keys in pairs(decoded) do
            if Config[cat] then for k, v in pairs(keys) do Config[cat][k] = v end end
        end
    end
end)

-- // UI ARCHITECTURE
local ScreenUI = Instance.new("ScreenGui", TargetParent)
ScreenUI.Name = "RZGR1KS_ENTERPRISE_FRAMEWORK"
ScreenUI.ResetOnSpawn = false
ScreenUI.IgnoreGuiInset = true
ScreenUI.DisplayOrder = 999999

local MainFrame = Instance.new("Frame", ScreenUI)
MainFrame.Name = "Main"
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Size = UDim2.new(0, 380, 0, 52)
MainFrame.Position = UDim2.new(0.5, -190, 0.15, 0)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 52); Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Position = UDim2.new(0, 20, 0, 0); Title.Size = UDim2.new(1, -120, 1, 0); Title.BackgroundTransparency = 1
Title.Font = "GothamBold"; Title.Text = "RZGR1KS DUELS : EXECUTIVE"; Title.TextColor3 = Color3.fromRGB(220, 40, 40); Title.TextSize = 14; Title.TextXAlignment = "Left"

local ToggleBtn = Instance.new("TextButton", Header)
ToggleBtn.Position = UDim2.new(1, -95, 0, 10); ToggleBtn.Size = UDim2.new(0, 80, 0, 32); ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); ToggleBtn.Text = "OPEN"; ToggleBtn.Font = "GothamBold"; ToggleBtn.TextColor3 = Color3.new(1, 1, 1); ToggleBtn.TextSize = 11
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Position = UDim2.new(0, 10, 0, 65); Content.Size = UDim2.new(1, -20, 0, 435); Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 1; Content.Visible = false; Content.AutomaticCanvasSize = "Y"
Instance.new("UIListLayout", Content).Padding = UDim.new(0, 8)

-- // RESTORED MODULES: VISUALS (X-RAY & ESP)
local XRayCache = {}
local function ManageXRay(state)
    if state then
        task.spawn(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
                    if not obj.Parent:FindFirstChildOfClass("Humanoid") and obj.Transparency < 1 then
                        XRayCache[obj] = obj.Transparency
                        obj.Transparency = Config.Visuals.XRayTransparency
                    end
                end
            end
        end)
    else
        for part, trans in pairs(XRayCache) do if part and part.Parent then part.Transparency = trans end end
        table.clear(XRayCache)
    end
end

local function ManageESP()
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

-- // RESTORED MODULES: COMBAT & PHYSICS
local function SyncHitbox()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            hrp.Size = Config.Combat.HitboxEnabled and Vector3.new(Config.Combat.HitboxSize, Config.Combat.HitboxSize, Config.Combat.HitboxSize) or Vector3.new(2, 2, 1)
            hrp.Transparency = Config.Combat.HitboxEnabled and 0.8 or 1; hrp.CanCollide = false
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

-- // UI COMPONENT FACTORY
local Components = {}
local ActiveSliders = {} -- Track sliders for global release

function Components:Section(txt)
    local l = Instance.new("TextLabel", Content)
    l.Size = UDim2.new(1, 0, 0, 25); l.BackgroundTransparency = 1; l.Font = "GothamBold"; l.Text = ">>> " .. txt:upper() .. " <<<"; l.TextColor3 = Color3.fromRGB(220, 40, 40); l.TextSize = 10
end

function Components:Toggle(name, dataset, key, callback)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(1, -10, 0, 40); b.BackgroundColor3 = dataset[key] and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(20, 20, 20)
    b.Font = "GothamBold"; b.Text = name .. " : " .. (dataset[key] and "ENABLED" or "DISABLED"); b.TextColor3 = Color3.new(1, 1, 1); b.TextSize = 11; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        dataset[key] = not dataset[key]
        b.Text = name .. " : " .. (dataset[key] and "ENABLED" or "DISABLED")
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = dataset[key] and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(20, 20, 20)}):Play()
        if callback then callback(dataset[key]) end; SaveConfig()
    end)
end

function Components:Slider(name, min, max, dataset, key, callback)
    local f = Instance.new("Frame", Content); f.Size = UDim2.new(1, -10, 0, 60); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.BackgroundTransparency = 1; l.Text = name .. " : " .. dataset[key]; l.Font = "Gotham"; l.TextColor3 = Color3.new(0.8, 0.8, 0.8); l.TextSize = 11; l.TextXAlignment = "Left"
    local t = Instance.new("TextButton", f); t.Size = UDim2.new(1, 0, 0, 10); t.Position = UDim2.new(0, 0, 0, 25); t.BackgroundColor3 = Color3.fromRGB(30, 30, 30); t.Text = ""
    local fill = Instance.new("Frame", t); fill.Size = UDim2.new(math.clamp((dataset[key]-min)/(max-min), 0, 1), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
    Instance.new("UICorner", t); Instance.new("UICorner", fill)
    
    local isSliding = false
    local function Update()
        local scale = math.clamp((UIS:GetMouseLocation().X - t.AbsolutePosition.X) / t.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (scale * (max - min)))
        dataset[key] = val; l.Text = name .. " : " .. val; fill.Size = UDim2.new(scale, 0, 1, 0)
        if callback then callback() end
    end
    
    t.MouseButton1Down:Connect(function() isSliding = true end)
    
    -- GLOBAL RELEASE FIX
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isSliding then
            isSliding = false
            SaveConfig()
        end
    end)
    
    RunService.RenderStepped:Connect(function() if isSliding then Update() end end)
end

-- // BUILD INTERFACE
Components:Section("Combat & Offense")
Components:Toggle("Hitbox Expansion", Config.Combat, "HitboxEnabled", SyncHitbox)
Components:Slider("Hitbox Scale", 2, 250, Config.Combat, "HitboxSize", SyncHitbox)
Components:Toggle("Physics Spinbot", Config.Combat, "SpinbotActive")
Components:Slider("Spin Velocity", 0, 1000, Config.Combat, "SpinRPM")

Components:Section("Kinematics")
Components:Slider("Walk Speed", 16, 1000, Config.Movement, "Speed")
Components:Slider("Jump Power", 50, 1500, Config.Movement, "Jump")
Components:Slider("Gravity Force", 0, 1000, Config.Movement, "Gravity")
Components:Toggle("Infinite Jump (Multi)", Config.Movement, "InfiniteJump")
Components:Toggle("Anti-Ragdoll State", Config.Movement, "AntiRagdoll")

Components:Section("Surveillance")
Components:Toggle("High-Visibility ESP", Config.Visuals, "HighlightESP", ManageESP)
Components:Toggle("Wall-Hacks (X-Ray)", Config.Visuals, "XRayActive", ManageXRay)

Components:Section("Utility")
Components:Toggle("Auto Interact (Prompt)", Config.Misc, "AutoInteract")

-- // SOCIALS
local function AddSocial(n, c, u)
    local b = Instance.new("TextButton", Content); b.Size = UDim2.new(1, -10, 0, 40); b.BackgroundColor3 = c; b.Font = "GothamBold"; b.Text = n .. " [COPY]"; b.TextColor3 = Color3.new(1, 1, 1); b.TextSize = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function() setclipboard(u); b.Text = "COPIED!"; task.wait(1); b.Text = n .. " [COPY]" end)
end
AddSocial("YouTube: RZGR1KS", Color3.fromRGB(200, 30, 30), "https://youtube.com/@rzgr1ks")
AddSocial("Discord: RZGR1KS", Color3.fromRGB(80, 95, 230), "https://discord.gg/XpbcvVdU")

-- // UI TOGGLE & ANIMATION
local State = false
ToggleBtn.MouseButton1Click:Connect(function()
    State = not State
    Content.Visible = State
    ToggleBtn.Text = State and "CLOSE" or "OPEN"
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = State and UDim2.new(0, 380, 0, 510) or UDim2.new(0, 380, 0, 52)}):Play()
end)

-- // GLOBAL EVENT LISTENERS
UIS.JumpRequest:Connect(function() if Config.Movement.InfiniteJump then LocalPlayer.Character.Humanoid:ChangeState(3) end end)
ProximityPromptService.PromptShown:Connect(function(p) if Config.Misc.AutoInteract then p.HoldDuration = 0; pcall(function() p:InputHoldBegin() task.wait() p:InputHoldEnd() end) end end)

-- Anti-AFK Logic
LocalPlayer.Idled:Connect(function() game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) task.wait(0.5) game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)

ManageESP()
print("RZGR1KS DUELS EXECUTIVE V5.0.2 FULLY DEPLOYED")
