--[[
    HYDRA HUB DUELS 🐬 (SILENT HUB INTEGRATION – FIXED SPEED CONFLICT)
    - Auto Duel: Silent Hub pathfinding + grab detection
    - Instant Grab: Silent Hub stealing logic
    - Speed overrides automatically disabled during Auto Duel
    - Other features unchanged
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Platform Detection
local IS_MOBILE = UserInputService.TouchEnabled

-- Configuration
local CONFIG = {
    AUTO_STEAL_NEAREST = false,
    AUTO_DUEL = false,
    AUTO_HIT = false,
    ANTI_RAGDOLL = false,
    SLOW_MO = false,
    TALL_JUMP = false,
    ANTI_TRAP = true,
    ANTI_SENTRY = true,
    SPIN_BOT = false,
    INFINITE_JUMP = false,
    FOLLOW_PLAYER = false
}

-- Speed Variables
local SpeedState = {
    Active = false,
    Mode = "None",
    Value = 16
}
local stealSpeedBtn, sprintSpeedBtn  -- references for toggling

-- ==============================================================================
-- 1. HYDRAHUB GUI LIBRARY (ADAPTIVE) – unchanged
-- ==============================================================================
local HydraGuiLib = {}
HydraGuiLib.__index = HydraGuiLib

local BASE_WIDTH = 320 
local BASE_HEIGHT = 420          -- compact bottom
local THEME_COLOR = Color3.fromRGB(147, 51, 234)
local BG_COLOR = Color3.fromRGB(0, 0, 0)
local BG_TRANSPARENCY = 0.15
local BUTTON_TRANSPARENCY = 0.25
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)

local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

function HydraGuiLib:CreateGui(titleText)
    local self = setmetatable({}, HydraGuiLib)
    if CoreGui:FindFirstChild("HydraHub") then CoreGui["HydraHub"]:Destroy() end
    if PlayerGui:FindFirstChild("HydraHub") then PlayerGui["HydraHub"]:Destroy() end
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "HydraHub"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() self.ScreenGui.Parent = CoreGui end)
    if self.ScreenGui.Parent ~= CoreGui then self.ScreenGui.Parent = PlayerGui end

    self.UIScale = Instance.new("UIScale", self.ScreenGui)
    local function updateScale()
        if IS_MOBILE then
            local viewport = Camera.ViewportSize
            local ratio = viewport.Y / 450 
            self.UIScale.Scale = math.clamp(ratio, 1.0, 1.3)
        else self.UIScale.Scale = 1.0 end
    end
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
    updateScale()

    self.Frame = Instance.new("Frame", self.ScreenGui)
    self.Frame.Size = UDim2.new(0, BASE_WIDTH, 0, BASE_HEIGHT)
    self.Frame.Position = UDim2.new(0.5, -BASE_WIDTH/2, 0.5, -BASE_HEIGHT/2)
    self.Frame.BackgroundColor3 = BG_COLOR
    self.Frame.BackgroundTransparency = BG_TRANSPARENCY
    self.Frame.BorderSizePixel = 0
    self.Frame.Active = true
    self.Frame.ClipsDescendants = true 
    Instance.new("UICorner", self.Frame).CornerRadius = UDim.new(0, 18)
    local Stroke = Instance.new("UIStroke", self.Frame)
    Stroke.Color = THEME_COLOR
    Stroke.Thickness = 1.6
    MakeDraggable(self.Frame)

    -- Animated Dots
    local dots = {}
    for i=1, 45 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(math.random(2,4), math.random(2,4))
        dot.Position = UDim2.new(math.random(), 0, math.random(), 0)
        dot.BackgroundColor3 = THEME_COLOR
        dot.BackgroundTransparency = 0.6
        dot.BorderSizePixel = 0
        dot.ZIndex = 1 
        dot.Parent = self.Frame
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
        table.insert(dots, {ui = dot, speed = Vector2.new((math.random()-0.5)*0.0006, (math.random()-0.5)*0.0006)})
    end
    RunService.RenderStepped:Connect(function()
        if not self.Frame.Visible then return end
        for _,d in pairs(dots) do
            local pos = d.ui.Position
            local newX = pos.X.Scale + d.speed.X
            local newY = pos.Y.Scale + d.speed.Y
            if newX > 1 then newX = 0 end
            if newX < 0 then newX = 1 end
            if newY > 1 then newY = 0 end
            if newY < 0 then newY = 1 end
            d.ui.Position = UDim2.new(newX, 0, newY, 0)
        end
    end)

    self.Title = Instance.new("TextLabel", self.Frame)
    self.Title.Size = UDim2.new(1, 0, 0, 45)
    self.Title.Position = UDim2.new(0, 0, 0, 0)
    self.Title.BackgroundTransparency = 1
    self.Title.Text = titleText
    self.Title.TextColor3 = TEXT_COLOR
    self.Title.Font = Enum.Font.GothamBold
    self.Title.TextSize = 20
    self.Title.TextXAlignment = Enum.TextXAlignment.Center
    self.Title.ZIndex = 5
    
    self.MinBtn = Instance.new("TextButton", self.Frame)
    self.MinBtn.Size = UDim2.new(0, 25, 0, 25)
    self.MinBtn.Position = UDim2.new(1, -35, 0, 10)
    self.MinBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    self.MinBtn.Text = "-"
    self.MinBtn.TextColor3 = Color3.new(1,1,1)
    self.MinBtn.Font = Enum.Font.GothamBlack
    self.MinBtn.TextSize = 18
    self.MinBtn.ZIndex = 10
    Instance.new("UICorner", self.MinBtn).CornerRadius = UDim.new(0, 6)
    
    self.OpenBtn = Instance.new("TextButton", self.ScreenGui)
    self.OpenBtn.Size = UDim2.new(0, 50, 0, 50)
    self.OpenBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
    self.OpenBtn.BackgroundColor3 = THEME_COLOR
    self.OpenBtn.Text = "🐬"
    self.OpenBtn.TextSize = 30
    self.OpenBtn.Visible = false
    self.OpenBtn.AutoButtonColor = true
    MakeDraggable(self.OpenBtn)
    Instance.new("UICorner", self.OpenBtn).CornerRadius = UDim.new(1, 0)
    local CircleStroke = Instance.new("UIStroke", self.OpenBtn)
    CircleStroke.Color = Color3.new(1,1,1)
    CircleStroke.Thickness = 2
    CircleStroke.Transparency = 0.5

    self.MinBtn.MouseButton1Click:Connect(function()
        self.Frame.Visible = false
        self.OpenBtn.Visible = true
    end)
    self.OpenBtn.MouseButton1Click:Connect(function()
        self.Frame.Visible = true
        self.OpenBtn.Visible = false
    end)
    
    return self
end

function HydraGuiLib:AddGridButton(text, callback, row, col)
    local btn = Instance.new("TextButton", self.Frame)
    local width = 0.44
    local xPos = (col == 0) and 0.04 or 0.52 
    local yPos = 55 + (row * 42)
    btn.Size = UDim2.new(width, 0, 0, 35)
    btn.Position = UDim2.new(xPos, 0, 0, yPos)
    btn.BackgroundColor3 = BG_COLOR
    btn.BackgroundTransparency = BUTTON_TRANSPARENCY
    btn.Text = text
    btn.TextColor3 = TEXT_COLOR
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11 
    btn.ZIndex = 2
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", btn)
    Stroke.Color = THEME_COLOR
    Stroke.Thickness = 1
    btn.MouseButton1Click:Connect(function()
        callback(btn)
        local originalColor = btn.BackgroundColor3
        btn.BackgroundColor3 = THEME_COLOR
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = BG_COLOR}):Play()
    end)
    return btn
end

-- Function for a centered button with custom width (default 0.33)
function HydraGuiLib:AddCenteredButton(text, callback, row, width)
    width = width or 0.33
    local btn = Instance.new("TextButton", self.Frame)
    btn.Size = UDim2.new(width, 0, 0, 35)
    btn.Position = UDim2.new(0.5 - width/2, 0, 0, 55 + row * 42)
    btn.BackgroundColor3 = BG_COLOR
    btn.BackgroundTransparency = BUTTON_TRANSPARENCY
    btn.Text = text
    btn.TextColor3 = TEXT_COLOR
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11 
    btn.ZIndex = 2
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", btn)
    Stroke.Color = THEME_COLOR
    Stroke.Thickness = 1
    btn.MouseButton1Click:Connect(function()
        callback(btn)
        local originalColor = btn.BackgroundColor3
        btn.BackgroundColor3 = THEME_COLOR
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = BG_COLOR}):Play()
    end)
    return btn
end

function HydraGuiLib:AddLabel(text, yPos)
    local lbl = Instance.new("TextLabel", self.Frame)
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.Position = UDim2.new(0, 0, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.ZIndex = 2
    return lbl
end

function HydraGuiLib:AddTextBox(defaultText, yPos, callback)
    local box = Instance.new("TextBox", self.Frame)
    box.Size = UDim2.new(0.5, 0, 0, 30)
    box.Position = UDim2.new(0.25, 0, 0, yPos)
    box.BackgroundColor3 = BG_COLOR
    box.BackgroundTransparency = BUTTON_TRANSPARENCY
    box.Text = defaultText
    box.TextColor3 = TEXT_COLOR
    box.Font = Enum.Font.GothamBold
    box.TextSize = 12
    box.ZIndex = 2
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", box)
    Stroke.Color = THEME_COLOR
    Stroke.Thickness = 1
    box.FocusLost:Connect(function(enter) callback(box) end)
    return box
end

function HydraGuiLib:AddProgressBar(yPos)
    local bg = Instance.new("Frame", self.Frame)
    bg.Size = UDim2.new(0.9, 0, 0, 8)
    bg.Position = UDim2.new(0.05, 0, 0, yPos)
    bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    bg.ZIndex = 2
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", bg)
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = THEME_COLOR
    fill.ZIndex = 3
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    return bg, fill
end

-- ==============================================================================
-- 2. INSTANT GRAB (SILENT HUB LOGIC)
-- ==============================================================================
local AnimalsData = nil
pcall(function() AnimalsData = require(ReplicatedStorage:WaitForChild("Datas"):WaitForChild("Animals")) end)
if not AnimalsData then AnimalsData = {} end

local allAnimalsCache = {}
local PromptMemoryCache = {}
local InternalStealCache = {}
local LastTargetUID = nil
local LastPlayerPosition = nil
local PlayerVelocity = Vector3.zero

local AUTO_STEAL_PROX_RADIUS = 20
local IsStealing = false
local StealProgress = 0
local CurrentStealTarget = nil
local StealStartTime = 0

local CIRCLE_RADIUS = AUTO_STEAL_PROX_RADIUS
local PART_THICKNESS = 0.3
local PART_HEIGHT = 0.2
local PART_COLOR = THEME_COLOR
local PartsCount = 65
local circleParts = {}
local circleEnabled = true

local stealConnection = nil
local velocityConnection = nil

local function getHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
end

local function isMyBase(plotName)
    local plot = workspace.Plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yourBase = sign:FindFirstChild("YourBase")
        if yourBase and yourBase:IsA("BillboardGui") then
            return yourBase.Enabled == true
        end
    end
    return false
end

local function scanSinglePlot(plot)
    if not plot or not plot:IsA("Model") then return end
    if isMyBase(plot.Name) then return end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return end
    for _, podium in ipairs(podiums:GetChildren()) do
        if podium:IsA("Model") and podium:FindFirstChild("Base") then
            local animalName = "Unknown"
            local spawn = podium.Base:FindFirstChild("Spawn")
            if spawn then
                for _, child in ipairs(spawn:GetChildren()) do
                    if child:IsA("Model") and child.Name ~= "PromptAttachment" then
                        animalName = child.Name
                        local animalInfo = AnimalsData[animalName]
                        if animalInfo and animalInfo.DisplayName then
                            animalName = animalInfo.DisplayName
                        end
                        break
                    end
                end
            end
            table.insert(allAnimalsCache, {
                name = animalName,
                plot = plot.Name,
                slot = podium.Name,
                worldPosition = podium:GetPivot().Position,
                uid = plot.Name .. "_" .. podium.Name,
            })
        end
    end
end

local function initializeScanner()
    task.wait(2)
    local plots = workspace:WaitForChild("Plots", 5)
    if not plots then return end
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") then scanSinglePlot(plot) end
    end
    plots.ChildAdded:Connect(function(plot)
        if plot:IsA("Model") then task.wait(0.5) scanSinglePlot(plot) end
    end)
    task.spawn(function()
        while task.wait(5) do
            allAnimalsCache = {}
            for _, plot in ipairs(plots:GetChildren()) do
                if plot:IsA("Model") then scanSinglePlot(plot) end
            end
        end
    end)
end

local function findProximityPromptForAnimal(animalData)
    if not animalData then return nil end
    local cachedPrompt = PromptMemoryCache[animalData.uid]
    if cachedPrompt and cachedPrompt.Parent then return cachedPrompt end
    local plot = workspace.Plots:FindFirstChild(animalData.plot)
    if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return nil end
    local podium = podiums:FindFirstChild(animalData.slot)
    if not podium then return nil end
    local base = podium:FindFirstChild("Base")
    if not base then return nil end
    local spawn = base:FindFirstChild("Spawn")
    if not spawn then return nil end
    local attach = spawn:FindFirstChild("PromptAttachment")
    if not attach then return nil end
    for _, p in ipairs(attach:GetChildren()) do
        if p:IsA("ProximityPrompt") then
            PromptMemoryCache[animalData.uid] = p
            return p
        end
    end
    return nil
end

local function updatePlayerVelocity()
    local hrp = getHRP()
    if not hrp then return end
    local currentPos = hrp.Position
    if LastPlayerPosition then
        PlayerVelocity = (currentPos - LastPlayerPosition) / task.wait()
    end
    LastPlayerPosition = currentPos
end

local function shouldSteal(animalData)
    if not animalData or not animalData.worldPosition then return false end
    local hrp = getHRP()
    if not hrp then return false end
    return (hrp.Position - animalData.worldPosition).Magnitude <= AUTO_STEAL_PROX_RADIUS
end

local function buildStealCallbacks(prompt)
    if InternalStealCache[prompt] then return end
    local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
    local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(conns1) == "table" then
        for _, conn in ipairs(conns1) do
            if type(conn.Function) == "function" then
                table.insert(data.holdCallbacks, conn.Function)
            end
        end
    end
    local ok2, conns2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(conns2) == "table" then
        for _, conn in ipairs(conns2) do
            if type(conn.Function) == "function" then
                table.insert(data.triggerCallbacks, conn.Function)
            end
        end
    end
    if (#data.holdCallbacks > 0) or (#data.triggerCallbacks > 0) then
        InternalStealCache[prompt] = data
    end
end

local function executeInternalStealAsync(prompt, animalData)
    local data = InternalStealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    IsStealing = true
    StealProgress = 0
    CurrentStealTarget = animalData
    StealStartTime = tick()
    task.spawn(function()
        if #data.holdCallbacks > 0 then
            for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
        end
        local startTime = tick()
        while tick() - startTime < 1.3 do
            StealProgress = (tick() - startTime) / 1.3
            task.wait(0.05)
        end
        StealProgress = 1
        if #data.triggerCallbacks > 0 then
            for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
        end
        task.wait(0.1)
        data.ready = true
        task.wait(0.3)
        IsStealing = false
        StealProgress = 0
        CurrentStealTarget = nil
    end)
    return true
end

local function attemptSteal(prompt, animalData)
    if not prompt or not prompt.Parent then return false end
    buildStealCallbacks(prompt)
    if not InternalStealCache[prompt] then 
        if prompt.Parent then fireproximityprompt(prompt) end
        return true 
    end
    return executeInternalStealAsync(prompt, animalData)
end

local function getNearestAnimal()
    local hrp = getHRP()
    if not hrp then return nil end
    local nearest = nil
    local minDist = math.huge
    for _, animalData in ipairs(allAnimalsCache) do
        if isMyBase(animalData.plot) then continue end
        if animalData.worldPosition then
            local dist = (hrp.Position - animalData.worldPosition).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = animalData
            end
        end
    end
    return nearest
end

local function autoStealLoop()
    if stealConnection then stealConnection:Disconnect() end
    if velocityConnection then velocityConnection:Disconnect() end
    velocityConnection = RunService.Heartbeat:Connect(updatePlayerVelocity)
    stealConnection = RunService.Heartbeat:Connect(function()
        if not CONFIG.AUTO_STEAL_NEAREST then return end
        if IsStealing then return end
        local targetAnimal = getNearestAnimal()
        if not targetAnimal then return end
        if not shouldSteal(targetAnimal) then return end
        if LastTargetUID ~= targetAnimal.uid then LastTargetUID = targetAnimal.uid end
        local prompt = PromptMemoryCache[targetAnimal.uid]
        if not prompt or not prompt.Parent then
            prompt = findProximityPromptForAnimal(targetAnimal)
        end
        if prompt then attemptSteal(prompt, targetAnimal) end
    end)
end

local function createCircle(character)
    for _, part in ipairs(circleParts) do if part then part:Destroy() end end
    circleParts = {}
    if not CONFIG.AUTO_STEAL_NEAREST then return end
    CIRCLE_RADIUS = AUTO_STEAL_PROX_RADIUS
    local points = {}
    for i = 0, PartsCount - 1 do
        local angle = math.rad(i * 360 / PartsCount)
        table.insert(points, Vector3.new(math.cos(angle), 0, math.sin(angle)) * CIRCLE_RADIUS)
    end
    for i = 1, #points do
        local nextIndex = i % #points + 1
        local p1 = points[i]; local p2 = points[nextIndex]
        local part = Instance.new("Part")
        part.Name = "HydraCircle"
        part.Anchored = true; part.CanCollide = false
        part.Size = Vector3.new((p2 - p1).Magnitude, PART_HEIGHT, PART_THICKNESS)
        part.Color = PART_COLOR; part.Material = Enum.Material.Neon; part.Transparency = 0.3
        part.Parent = Workspace
        table.insert(circleParts, part)
    end
end

local function updateCircle(character)
    if not CONFIG.AUTO_STEAL_NEAREST then 
        for _, part in ipairs(circleParts) do part.Transparency = 1 end
        return 
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local points = {}
    for i = 0, PartsCount - 1 do
        local angle = math.rad(i * 360 / PartsCount)
        table.insert(points, Vector3.new(math.cos(angle), 0, math.sin(angle)) * CIRCLE_RADIUS)
    end
    for i, part in ipairs(circleParts) do
        part.Transparency = 0.3
        local nextIndex = i % #points + 1
        local p1 = points[i]; local p2 = points[nextIndex]
        local center = (p1 + p2) / 2 + root.Position
        part.CFrame = CFrame.new(center, center + Vector3.new(p2.X - p1.X, 0, p2.Z - p1.Z)) * CFrame.Angles(0, math.pi/2, 0)
    end
end

local function onCharacterAdded(character)
    if circleEnabled then
        createCircle(character)
        RunService:BindToRenderStep("CircleFollow", Enum.RenderPriority.Camera.Value + 1, function() updateCircle(character) end)
    end
end

local function updateCircleRadius()
    CIRCLE_RADIUS = AUTO_STEAL_PROX_RADIUS
    local character = LocalPlayer.Character
    if character and circleEnabled then createCircle(character) end
end

-- ==============================================================================
-- 3. SPEED LOGIC (with ability to disable)
-- ==============================================================================
local SpeedConnection = nil

local function enableSpeedBypass()
    if SpeedConnection then SpeedConnection:Disconnect() end
    SpeedConnection = RunService.Stepped:Connect(function()
        if not SpeedState.Active then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum and root and hum:GetState() == Enum.HumanoidStateType.Running then
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                root.AssemblyLinearVelocity = Vector3.new(moveDir.X * SpeedState.Value, root.AssemblyLinearVelocity.Y, moveDir.Z * SpeedState.Value)
            end
        end
    end)
end

local function disableSpeedBypass()
    if SpeedConnection then
        SpeedConnection:Disconnect()
        SpeedConnection = nil
    end
end

local function updateSpeedState(mode)
    -- If Auto Duel is active, prevent toggling speed modes
    if CONFIG.AUTO_DUEL then return end
    
    if SpeedState.Mode == mode and SpeedState.Active then
        SpeedState.Active = false
        SpeedState.Mode = "None"
        disableSpeedBypass()
    else
        SpeedState.Active = true
        SpeedState.Mode = mode
        if mode == "Steal" then SpeedState.Value = 30
        elseif mode == "Sprint" then SpeedState.Value = 59 end
        enableSpeedBypass()
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if SpeedState.Active and not CONFIG.AUTO_DUEL then enableSpeedBypass() end
end)

-- ==============================================================================
-- 4. FIXED PHYSICS (Tall Jump = 76, Slow Mo)
-- ==============================================================================
local SlowFallForce = nil
local SlowFallAttachment = nil

local function applySlowFall(enabled)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if enabled and root then
        if not SlowFallAttachment then SlowFallAttachment = Instance.new("Attachment", root); SlowFallAttachment.Name = "SlowFallAtt" end
        if not SlowFallForce then
            SlowFallForce = Instance.new("VectorForce", root)
            SlowFallForce.Name = "SlowFallForce"
            SlowFallForce.Attachment0 = SlowFallAttachment
            SlowFallForce.RelativeTo = Enum.ActuatorRelativeTo.World
            SlowFallForce.Enabled = true
        end
        task.spawn(function()
            while CONFIG.SLOW_MO and SlowFallForce and SlowFallForce.Parent do
                if root.AssemblyLinearVelocity.Y < -5 then
                    local totalMass = 0
                    for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then totalMass = totalMass + p:GetMass() end end
                    SlowFallForce.Force = Vector3.new(0, totalMass * Workspace.Gravity * 0.92, 0)
                else SlowFallForce.Force = Vector3.zero end
                task.wait(0.1)
            end
            if SlowFallForce then SlowFallForce:Destroy(); SlowFallForce = nil end
            if SlowFallAttachment then SlowFallAttachment:Destroy(); SlowFallAttachment = nil end
        end)
    else
        if SlowFallForce then SlowFallForce:Destroy(); SlowFallForce = nil end
        if SlowFallAttachment then SlowFallAttachment:Destroy(); SlowFallAttachment = nil end
    end
end

local lastJump = 0
UserInputService.JumpRequest:Connect(function()
    if CONFIG.TALL_JUMP == true and LocalPlayer.Character and (tick() - lastJump > 0.5) then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 76, root.AssemblyLinearVelocity.Z)
            lastJump = tick()
        end
    end
end)

-- ==============================================================================
-- 5. OTHER FEATURES (Anti‑Trap, Anti‑Sentry, Auto Hit) – unchanged
-- ==============================================================================
task.spawn(function()
    local processedTraps = {}
    while task.wait(5) do
        if CONFIG.ANTI_TRAP then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name == "Trap" or obj.Name:lower():find("trap")) then
                    if not processedTraps[obj] then
                        processedTraps[obj] = true
                        pcall(function()
                            for _, p in pairs(obj:GetDescendants()) do
                                if p:IsA("BasePart") then p.CanCollide = false; p.CanTouch = false end
                                if p:IsA("Script") then p:Destroy() end
                            end
                        end)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if CONFIG.ANTI_SENTRY and LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, obj in pairs(Workspace:GetChildren()) do
                    if obj.Name:find("Sentry") and (obj:GetPivot().Position - root.Position).Magnitude < 60 then
                        if obj:IsA("Model") and obj.PrimaryPart then obj.PrimaryPart.CFrame = CFrame.new(0, -500, 0)
                        elseif obj:IsA("BasePart") then obj.CFrame = CFrame.new(0, -500, 0) end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        if CONFIG.AUTO_HIT and LocalPlayer.Character then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
        task.wait(0.1)
    end
end)

-- ==============================================================================
-- 6. SPIN BOT (7200°/s) – unchanged
-- ==============================================================================
local spinConnection = nil
local spinSpeed = math.rad(7200)

local function enableSpinBot()
    if spinConnection then spinConnection:Disconnect() end
    spinConnection = RunService.RenderStepped:Connect(function(deltaTime)
        if not CONFIG.SPIN_BOT then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local currentVel = hrp.AssemblyLinearVelocity
        hrp.AssemblyAngularVelocity = Vector3.new(0, spinSpeed, 0)
        hrp.AssemblyLinearVelocity = Vector3.new(currentVel.X, currentVel.Y, currentVel.Z)
    end)
end

local function disableSpinBot()
    if spinConnection then spinConnection:Disconnect(); spinConnection = nil end
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.AssemblyAngularVelocity = Vector3.zero end
    end
end

RunService.Heartbeat:Connect(function()
    if CONFIG.SPIN_BOT then enableSpinBot() else disableSpinBot() end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if CONFIG.SPIN_BOT then enableSpinBot() end
end)

-- ==============================================================================
-- 7. INFINITE JUMP (from 222 Hub)
-- ==============================================================================
local jumpForce = 55
local clampFallSpeed = 35

RunService.Heartbeat:Connect(function()
    if not CONFIG.INFINITE_JUMP then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local vel = hrp.AssemblyLinearVelocity
    if vel.Y < -clampFallSpeed then
        hrp.AssemblyLinearVelocity = Vector3.new(vel.X, -clampFallSpeed, vel.Z)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if not CONFIG.INFINITE_JUMP then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local vel = hrp.AssemblyLinearVelocity
    hrp.AssemblyLinearVelocity = Vector3.new(vel.X, jumpForce, vel.Z)
end)

-- ==============================================================================
-- 8. FOLLOW PLAYER (full movement)
-- ==============================================================================
local FOLLOW_SPEED = 30
local FOLLOW_STOP_DIST = 5

local function getNearestEnemy(hrp)
    local nearest, dist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            local ehrp = char and char:FindFirstChild("HumanoidRootPart")
            local ehum = char and char:FindFirstChildOfClass("Humanoid")
            if ehrp and ehum and ehum.Health > 0 then
                local d = (hrp.Position - ehrp.Position).Magnitude
                if d < dist then
                    nearest = plr
                    dist = d
                end
            end
        end
    end
    return nearest, dist
end

RunService.Heartbeat:Connect(function()
    if not CONFIG.FOLLOW_PLAYER then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local target, dist = getNearestEnemy(hrp)
    if not target then return end

    local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end

    if dist <= FOLLOW_STOP_DIST then
        hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
        return
    end

    local direction = (targetHRP.Position - hrp.Position).Unit
    hrp.AssemblyLinearVelocity = Vector3.new(direction.X * FOLLOW_SPEED, hrp.AssemblyLinearVelocity.Y, direction.Z * FOLLOW_SPEED)
end)

-- ==============================================================================
-- 9. ANTI RAGDOLL (Hydra version) – unchanged
-- ==============================================================================
local Frozen = false
local DisabledRemotes = {}
local RemoteWatcher = nil
local BlockedStates = {
    [Enum.HumanoidStateType.Ragdoll] = true,
    [Enum.HumanoidStateType.FallingDown] = true,
    [Enum.HumanoidStateType.Physics] = true,
    [Enum.HumanoidStateType.Dead] = true
}
local RemoteKeywords = { "useitem", "combatservice", "ragdoll" }

local function ForceNormal(character)
    local hum = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    hum.Health = hum.MaxHealth
    hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    if not Frozen then
        Frozen = true
        hrp.Anchored = true
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame += Vector3.new(0, 1.5, 0)
    end
end

local function Release(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp and Frozen then
        hrp.Anchored = false
        Frozen = false
    end
end

local function RestoreMotors(character)
    for _, v in ipairs(character:GetDescendants()) do
        if v:IsA("Motor6D") then v.Enabled = true elseif v:IsA("Constraint") then v.Enabled = false end
    end
end

local function KillRemote(remote)
    if not getconnections or not remote:IsA("RemoteEvent") then return end
    if DisabledRemotes[remote] then return end
    local name = remote.Name:lower()
    for _, key in ipairs(RemoteKeywords) do
        if name:find(key) then
            DisabledRemotes[remote] = {}
            for _, c in ipairs(getconnections(remote.OnClientEvent)) do
                if c.Disable then c:Disable() table.insert(DisabledRemotes[remote], c) end
            end
            break
        end
    end
end

local function InitAntiRagdoll(character)
    local hum = character:WaitForChild("Humanoid", 10)
    if not hum then return end
    for state in pairs(BlockedStates) do hum:SetStateEnabled(state, false) end
    hum.StateChanged:Connect(function(_, new)
        if CONFIG.ANTI_RAGDOLL and BlockedStates[new] then ForceNormal(character) RestoreMotors(character) end
    end)
    RunService.Stepped:Connect(function()
        if not CONFIG.ANTI_RAGDOLL then Release(character) return end
        if BlockedStates[hum:GetState()] then ForceNormal(character) else Release(character) end
        hum.Health = hum.MaxHealth
    end)
end

local function InitAntiItem()
    task.spawn(function()
        local PlayerModule = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 10)
        if PlayerModule then
            local s, pm = pcall(require, PlayerModule)
            if s and pm and pm.GetControls then
                pm:GetControls():Enable()
            end
        end
    end)
    
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do KillRemote(obj) end
    if RemoteWatcher then RemoteWatcher:Disconnect() end
    RemoteWatcher = ReplicatedStorage.DescendantAdded:Connect(KillRemote)
end

local function StartAntiRagdoll() 
    if LocalPlayer.Character then 
        InitAntiRagdoll(LocalPlayer.Character) 
    end 
    InitAntiItem() 
end

local function StopAntiRagdoll()
    for remote, connections in pairs(DisabledRemotes) do 
        for _, conn in ipairs(connections) do 
            if conn.Enable then conn:Enable() end 
        end 
    end
    DisabledRemotes = {}
    if RemoteWatcher then RemoteWatcher:Disconnect() RemoteWatcher = nil end
    if LocalPlayer.Character and Frozen then Release(LocalPlayer.Character) end
end

local antiRagdollActive = false
RunService.Heartbeat:Connect(function()
    if CONFIG.ANTI_RAGDOLL and not antiRagdollActive then
        StartAntiRagdoll()
        antiRagdollActive = true
    elseif not CONFIG.ANTI_RAGDOLL and antiRagdollActive then
        StopAntiRagdoll()
        antiRagdollActive = false
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    if CONFIG.ANTI_RAGDOLL then
        task.wait(0.5)
        InitAntiRagdoll(char)
    end
end)

-- ==============================================================================
-- 10. AUTO DUEL (SILENT HUB LOGIC)
-- ==============================================================================
local duelPath = {}
local duelPathIndex = 1
local duelIsMoving = false
local duelMoveConn = nil
local duelWaitingGrab = false
local duelGrabDone = false
local duelSpeedConn = nil

-- Speed monitor for grab detection (Silent Hub style)
duelSpeedConn = RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        if hum.WalkSpeed < 23 and duelWaitingGrab and not duelGrabDone then
            task.wait(0.3)
            duelWaitingGrab = false
            duelGrabDone = true
        end
    end
end)

local function stopDuel()
    if duelMoveConn then duelMoveConn:Disconnect() end
    duelIsMoving = false
    duelWaitingGrab = false
    duelGrabDone = false
end

local function moveDuel()
    if duelMoveConn then duelMoveConn:Disconnect() end
    duelMoveConn = RunService.Stepped:Connect(function()
        if not CONFIG.AUTO_DUEL or not duelIsMoving or duelWaitingGrab then return end
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local wp = duelPath[duelPathIndex]
        if not wp then 
            stopDuel()
            return 
        end
        local d = (root.Position - wp.position).Magnitude
        if d < 5 then
            if (duelPathIndex == 4 or duelPathIndex == 6) and not duelGrabDone then
                duelWaitingGrab = true
                root.Velocity = Vector3.zero
                return
            end
            if duelPathIndex == #duelPath then
                stopDuel()
                return
            end
            duelPathIndex = duelPathIndex + 1
        else
            local dir = (wp.position - root.Position).Unit
            root.Velocity = Vector3.new(dir.X * wp.speed, root.Velocity.Y, dir.Z * wp.speed)
        end
    end)
end

local function startDuel()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    duelIsMoving = true
    duelGrabDone = false

    -- Choose path based on current position (Silent Hub logic)
    if (root.Position - Vector3.new(-475,-7,96)).Magnitude >
       (root.Position - Vector3.new(-474,-7,23)).Magnitude then
        duelPath = {
            {position=Vector3.new(-475,-7,96),speed=59},
            {position=Vector3.new(-483,-5,95),speed=59},
            {position=Vector3.new(-487,-5,95),speed=55},
            {position=Vector3.new(-492,-5,95),speed=55},
            {position=Vector3.new(-473,-7,95),speed=29},
            {position=Vector3.new(-473,-7,11),speed=29}
        }
    else
        duelPath = {
            {position=Vector3.new(-474,-7,23),speed=55},
            {position=Vector3.new(-484,-5,24),speed=55},
            {position=Vector3.new(-488,-5,24),speed=55},
            {position=Vector3.new(-493,-5,25),speed=55},
            {position=Vector3.new(-473,-7,25),speed=29},
            {position=Vector3.new(-474,-7,112),speed=29}
        }
    end

    duelPathIndex = 1
    moveDuel()
end

-- ==============================================================================
-- 11. GUI CONSTRUCTION
-- ==============================================================================

local myGui = HydraGuiLib:CreateGui("HYDRA HUB DUELS 🐬")
local spinBotBtn, infJumpBtn, followPlayerBtn

-- ROW 0
myGui:AddGridButton("AUTO GRAB: OFF", function(btn)
    CONFIG.AUTO_STEAL_NEAREST = not CONFIG.AUTO_STEAL_NEAREST
    btn.Text = "AUTO GRAB: " .. (CONFIG.AUTO_STEAL_NEAREST and "ON" or "OFF")
    updateCircleRadius()
end, 0, 0)

myGui:AddGridButton("AUTO DUEL: OFF", function(btn)
    CONFIG.AUTO_DUEL = not CONFIG.AUTO_DUEL
    btn.Text = "AUTO DUEL: " .. (CONFIG.AUTO_DUEL and "ON" or "OFF")
    
    if CONFIG.AUTO_DUEL then 
        -- Disable speed overrides to prevent conflicts
        if SpeedState.Active then
            SpeedState.Active = false
            SpeedState.Mode = "None"
            disableSpeedBypass()
            -- Update button texts
            if stealSpeedBtn then stealSpeedBtn.Text = "STEAL SPEED: OFF" end
            if sprintSpeedBtn then sprintSpeedBtn.Text = "SPRINT SPEED: OFF" end
        end
        startDuel() 
    else 
        stopDuel() 
    end
end, 0, 1)

-- ROW 1
stealSpeedBtn = myGui:AddGridButton("STEAL SPEED: OFF", function(btn)
    updateSpeedState("Steal")
    btn.Text = (SpeedState.Mode == "Steal") and "STEAL SPEED: ON" or "STEAL SPEED: OFF"
    if sprintSpeedBtn then sprintSpeedBtn.Text = "SPRINT SPEED: OFF" end
end, 1, 0)

sprintSpeedBtn = myGui:AddGridButton("SPRINT SPEED: OFF", function(btn)
    updateSpeedState("Sprint")
    btn.Text = (SpeedState.Mode == "Sprint") and "SPRINT SPEED: ON" or "SPRINT SPEED: OFF"
    if stealSpeedBtn then stealSpeedBtn.Text = "STEAL SPEED: OFF" end
end, 1, 1)

-- ROW 2
myGui:AddGridButton("AUTO HIT: OFF", function(btn)
    CONFIG.AUTO_HIT = not CONFIG.AUTO_HIT
    btn.Text = "AUTO HIT: " .. (CONFIG.AUTO_HIT and "ON" or "OFF")
end, 2, 0)

myGui:AddGridButton("ANTI RAGDOLL: OFF", function(btn)
    CONFIG.ANTI_RAGDOLL = not CONFIG.ANTI_RAGDOLL
    btn.Text = "ANTI RAGDOLL: " .. (CONFIG.ANTI_RAGDOLL and "ON" or "OFF")
end, 2, 1)

-- ROW 3
myGui:AddGridButton("SLOW MO: OFF", function(btn)
    CONFIG.SLOW_MO = not CONFIG.SLOW_MO
    btn.Text = "SLOW MO: " .. (CONFIG.SLOW_MO and "ON" or "OFF")
    applySlowFall(CONFIG.SLOW_MO)
end, 3, 0)

myGui:AddGridButton("TALL JUMP: OFF", function(btn)
    CONFIG.TALL_JUMP = not CONFIG.TALL_JUMP
    btn.Text = "TALL JUMP: " .. (CONFIG.TALL_JUMP and "ON" or "OFF")
end, 3, 1)

-- ROW 4
spinBotBtn = myGui:AddGridButton("SPIN BOT: OFF", function(btn)
    CONFIG.SPIN_BOT = not CONFIG.SPIN_BOT
    btn.Text = "SPIN BOT: " .. (CONFIG.SPIN_BOT and "ON" or "OFF")
end, 4, 0)

infJumpBtn = myGui:AddGridButton("INF JUMP: OFF", function(btn)
    CONFIG.INFINITE_JUMP = not CONFIG.INFINITE_JUMP
    btn.Text = "INF JUMP: " .. (CONFIG.INFINITE_JUMP and "ON" or "OFF")
end, 4, 1)

-- ROW 5 (single button, centered, one‑third width)
followPlayerBtn = myGui:AddCenteredButton("FOLLOW PLAYER: OFF", function(btn)
    CONFIG.FOLLOW_PLAYER = not CONFIG.FOLLOW_PLAYER
    btn.Text = "FOLLOW PLAYER: " .. (CONFIG.FOLLOW_PLAYER and "ON" or "OFF")
end, 5, 0.33)

-- ==============================================================================
-- Bottom UI elements (Grab Radius, Progress) – with reduced overhang
-- ==============================================================================
local baseY = 55 + (6 * 42) + 5   -- after row 5

myGui:AddLabel("Grab Radius (5-200):", baseY)
local grabRadiusBox = myGui:AddTextBox(tostring(AUTO_STEAL_PROX_RADIUS), baseY + 20, function(box)
    local n = tonumber(box.Text)
    if n and n >= 5 and n <= 200 then
        AUTO_STEAL_PROX_RADIUS = math.floor(n)
        updateCircleRadius()
    else
        box.Text = tostring(AUTO_STEAL_PROX_RADIUS)
    end
end)

myGui:AddLabel("Steal Progress:", baseY + 60)
local _, progressFill = myGui:AddProgressBar(baseY + 80)

task.spawn(function()
    while task.wait(0.03) do
        if IsStealing then
            TweenService:Create(progressFill, TweenInfo.new(0.1), {Size = UDim2.new(StealProgress, 0, 1, 0)}):Play()
        else
            TweenService:Create(progressFill, TweenInfo.new(0.1), {Size = UDim2.new(0, 0, 1, 0)}):Play()
        end
    end
end)

-- ==============================================================================
-- Initialize systems
-- ==============================================================================
initializeScanner()
autoStealLoop()
if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

print("HYDRA HUB DUELS Loaded (Silent Hub Auto Duel & Instant Grab – speed conflict fixed)")
