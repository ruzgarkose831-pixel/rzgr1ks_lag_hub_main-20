--[[
    LEMÖN HUB DUELS PREMİÜM - V42 GALAXY ULTRA
    Tüm Özellikler ve Ekteki Görüntünün Tam Görsel Uyumu.
    Hiçbir özellik silinmedi, hepsi yeni görsele entegre edildi.
    Galaxt/Stars Background, RGB Borders, Animasyonlu Butonlar.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- Önceki GUI'yi temizle
local oldGui = Player.PlayerGui:FindFirstChild("LemonHubGalaxyUltra")
if oldGui then oldGui:Destroy() end

_G.Settings = {
    -- GÖRSEL section from image
    ESP = false, ESPDist = 1500, -- Player Name & Distance will be part of ESP
    -- COMBAT section from image
    BatHitbox = true, BatSize = 45, -- Reach Distance slider
    ServerLag = false, -- SERVER section
    -- KARAKTER & BODY MODS from image
    UnderArms = false, 
    HiddenHead = false,
    SpinBot = false, SpinSpeed = 200, -- P Mevlana from image
    -- MOVEMENT section from image
    GalaxyMode = false, GravityVal = 30, -- Low Gravity slider
    SpeedBoost = true, SpeedVal = 70, -- N Hız Hilesi
    JumpMod = true, JumpPower = 100, -- L Zıplama Gücü
    AntiRagdoll = false, -- R No Ragdoll
    InfJump = false, -- J Inf Jump
    -- AUTOMATION
    AutoWalkGo = false, 
    AutoWalkStop = false,
    Waypoints = {},
    -- internal for toggle state
    AutoWalk_On = false 
}

-- Tween Info Presets for smooth animations
local fastTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local bounceTween = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
local backTween = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)

-- GUI OLUŞTURMA
local gui = Instance.new("ScreenGui", Player.PlayerGui)
gui.Name = "LemonHubGalaxyUltra"
gui.ResetOnSpawn = false

-- ANA PANEL
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 520, 0, 480)
main.Position = UDim2.new(0.5, -260, 0.5, -240)
main.BackgroundColor3 = Color3.fromRGB(5, 5, 5) -- Black to let universe background show
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true -- Menüyü başlığından tut sürükle
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- UZAY ARKA PLANI (Image asset id based on similar assets)
local bg = Instance.new("ImageLabel", main)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Image = "rbxassetid://13264663806" -- A universe background, feel free to change to your own asset id.
bg.ScaleType = Enum.ScaleType.Crop
bg.Transparency = 0.5
bg.ZIndex = -1 -- Behind everything else

-- RGB KENARLIK
local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2.5
RunService.RenderStepped:Connect(function() 
    stroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) 
end)

-- Header Area with Title and Discord Link
local headerFrame = Instance.new("Frame", main)
headerFrame.Size = UDim2.new(1, 0, 0, 50)
headerFrame.BackgroundTransparency = 1

local mainTitle = Instance.new("TextLabel", headerFrame)
mainTitle.Size = UDim2.new(1, 0, 0, 25)
mainTitle.Position = UDim2.new(0, 0, 0, 5)
mainTitle.Text = "LEMÖN HUB DUELS PREMİÜM"
mainTitle.TextColor3 = Color3.fromRGB(255, 180, 0) -- Yellow from reference
mainTitle.Font = Enum.Font.GothamBold
mainTitle.TextSize = 14
mainTitle.BackgroundTransparency = 1
mainTitle.TextXAlignment = Enum.TextXAlignment.Center

local subHeader = Instance.new("TextLabel", headerFrame)
subHeader.Size = UDim2.new(1, 0, 0, 15)
subHeader.Position = UDim2.new(0, 0, 0, 25)
subHeader.Text = "discord.gg/lemonhub"
subHeader.TextColor3 = Color3.fromRGB(150, 150, 150)
subHeader.Font = Enum.Font.Gotham
subHeader.TextSize = 10
subHeader.BackgroundTransparency = 1
subHeader.TextXAlignment = Enum.TextXAlignment.Center

-- Close & Minimize buttons on header
local controlsFrame = Instance.new("Frame", headerFrame)
controlsFrame.Size = UDim2.new(0, 60, 0, 30)
controlsFrame.Position = UDim2.new(1, -70, 0, 5)
controlsFrame.BackgroundTransparency = 1

local minBtn = Instance.new("TextButton", controlsFrame)
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(0, 0, 0, 0)
minBtn.Text = "_"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.BackgroundTransparency = 1
minBtn.TextSize = 20
minBtn.Font = Enum.Font.GothamBold

local closeBtn = Instance.new("TextButton", controlsFrame)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(0, 35, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,0,0) -- Red close from other reference
closeBtn.BackgroundTransparency = 1
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold

-- Side Icon (Lemon) when minimized
local sideIcon = Instance.new("TextButton", gui)
sideIcon.Size = UDim2.new(0, 60, 0, 60)
sideIcon.Position = UDim2.new(0.95, -30, 0.3, -30) -- Side position
sideIcon.Text = "🍋"
sideIcon.TextSize = 25
sideIcon.Visible = false -- Hidden by default
sideIcon.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
local sideCorner = Instance.new("UICorner", sideIcon)
sideCorner.CornerRadius = UDIM.new(0, 12)
local sideStroke = Instance.new("UIStroke", sideIcon)
sideStroke.Thickness = 2.5
RunService.RenderStepped:Connect(function() 
    sideStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) 
end)

-- Minimize & Restore logic with smooth animations
minBtn.MouseButton1Click:Connect(function()
    TweenService:Create(main, backTween, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.95, 0, 0.3, 0)}):Play()
    task.wait(0.4)
    main.Visible = false
    sideIcon.Visible = true
    TweenService:Create(sideIcon, bounceTween, {Size = UDim2.new(0, 60, 0, 60)}):Play()
end)

sideIcon.MouseButton1Click:Connect(function()
    TweenService:Create(sideIcon, fastTween, {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.2)
    sideIcon.Visible = false
    main.Visible = true
    TweenService:Create(main, bounceTween, {Size = UDim2.new(0, 520, 0, 480), Position = UDim2.new(0.5, -260, 0.5, -240)}):Play()
end)

closeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(main, backTween, {Size = UDim2.new(0,0,0,0)}):Play()
    task.wait(0.4); gui:Destroy()
end)

-- Main scrolling frame for all features
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -60)
scroll.Position = UDim2.new(0, 5, 0, 50)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 120, 0) -- Orange scroll bar
scroll.CanvasSize = UDim2.new(0, 0, 0, 1500)
local listLayout = Instance.new("UIListLayout", scroll)
listLayout.Padding = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Helper function to add structured Sections to the scrolling frame
local function AddSection(title)
    local sectionLabel = Instance.new("TextLabel", scroll)
    sectionLabel.Size = UDim2.new(1, -20, 0, 25)
    sectionLabel.Text = title
    sectionLabel.TextColor3 = Color3.new(1, 1, 1)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextSize = 12
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Two-column sub-layout inside section
    local colFrame = Instance.new("Frame", scroll)
    colFrame.Size = UDim2.new(1, -10, 0, 0) -- Height will be automatic
    colFrame.BackgroundTransparency = 1
    local colLayout = Instance.new("UIGridLayout", colFrame)
    colLayout.CellSize = UDim2.new(0.48, 0, 0, 0) -- automatic cell height
    colLayout.CellPadding = UDim2.new(0.04, 0, 0, 8) -- padding between cells
    colLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    colLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- Helper to calculate grid height and apply to container
    RunService.RenderStepped:Connect(function()
        colFrame.Size = UDim2.new(1, -10, 0, colLayout.AbsoluteContentSize.Y)
    end)
    
    return colFrame
end

-- Helper function to add a structured, animated Toggle with large label and icon from reference
local function AddToggle(text, keyLetter, settingKey, parentCol)
    local toggleFrame = Instance.new("Frame", parentCol)
    toggleFrame.Size = UDim2.new(1, 0, 0, 32)
    toggleFrame.BackgroundTransparency = 1
    
    -- Small square icon with letter as in reference [G], [E], etc.
    if keyLetter ~= "" then
        local keyBox = Instance.new("TextLabel", toggleFrame)
        keyBox.Size = UDim2.new(0, 18, 0, 18)
        keyBox.Position = UDim2.new(0, 5, 0.5, -9)
        keyBox.BackgroundColor3 = Color3.fromRGB(255, 180, 0) -- Yellow for the key box
        keyBox.Text = keyLetter
        keyBox.TextColor3 = Color3.new(0, 0, 0)
        keyBox.Font = Enum.Font.GothamBold
        keyBox.TextSize = 11
        local keyCorner = Instance.new("UICorner", keyBox)
        keyCorner.CornerRadius = UDim.new(0, 4)
    end
    
    local mainLabel = Instance.new("TextLabel", toggleFrame)
    mainLabel.Size = UDim2.new(1, -70, 0, 20)
    mainLabel.Position = UDim2.new(0, keyLetter ~= "" and 30 or 5, 0.5, -10)
    mainLabel.Text = text
    mainLabel.TextColor3 = Color3.new(1, 1, 1)
    mainLabel.BackgroundTransparency = 1
    mainLabel.Font = Enum.Font.GothamBold
    mainLabel.TextSize = 11
    mainLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleBtn = Instance.new("TextButton", toggleFrame)
    toggleBtn.Size = UDim2.new(0, 40, 0, 20) -- Thick iOS style
    toggleBtn.Position = UDim2.new(1, -45, 0.5, -10)
    toggleBtn.Text = "" -- Text will be the background state
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggleBtn.AutoButtonColor = false -- Disables default hover scaling
    local toggleCorner = Instance.new("UICorner", toggleBtn)
    toggleCorner.CornerRadius = UDIM.new(1, 0)
    
    local circle = Instance.new("Frame", toggleBtn)
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = UDim2.new(0, 2, 0.5, -8) -- Centered vertically
    circle.BackgroundColor3 = Color3.new(1, 1, 1) -- White inside
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    -- Animation logic for the toggle (ios style)
    local function updateVisuals()
        local on = _G.Settings[settingKey]
        TweenService:Create(toggleBtn, fastTween, {BackgroundColor3 = on and Color3.fromRGB(255, 120, 0) or Color3.fromRGB(40, 40, 40)}):Play()
        TweenService:Create(circle, fastTween, {Position = on and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
    end
    
    toggleBtn.MouseButton1Click:Connect(function()
        _G.Settings[settingKey] = not _G.Settings[settingKey]
        updateVisuals()
    end)
    
    -- Initialize visual state
    updateVisuals()
    
    -- Hover effect for the toggle
    toggleFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then mainLabel.TextColor3 = Color3.fromRGB(255, 180, 0); TweenService:Create(mainLabel, fastTween, {TextSize=12}):Play() end end)
    toggleFrame.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then mainLabel.TextColor3 = Color3.new(1, 1, 1); TweenService:Create(mainLabel, fastTween, {TextSize=11}):Play() end end)
    
    return toggleFrame
end

-- Helper function to add a structured, large, thick, easy-to-grab Slider with specific visuals from reference
local function AddSlider(text, minVal, maxVal, key, parentCol)
    local sliderFrame = Instance.new("Frame", parentCol)
    sliderFrame.Size = UDim2.new(1, 0, 0, 50) -- Taller to be easier to grab
    sliderFrame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", sliderFrame)
    label.Size = UDim2.new(1, -40, 0, 18)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(150, 150, 150)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueReadout = Instance.new("TextLabel", sliderFrame)
    valueReadout.Size = UDim2.new(0, 40, 0, 18)
    valueReadout.Position = UDim2.new(1, -45, 0, 5)
    valueReadout.Text = tostring(_G.Settings[key])
    valueReadout.TextColor3 = Color3.new(1, 1, 1)
    valueReadout.BackgroundTransparency = 1
    valueReadout.Font = Enum.Font.GothamBold
    valueReadout.TextSize = 11
    valueReadout.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderBar = Instance.new("TextButton", sliderFrame)
    sliderBar.Size = UDim2.new(1, -10, 0, 16) -- EXTREME THICKNESS (16px)
    sliderBar.Position = UDim2.new(0, 5, 1, -20) -- Placed bottom, leaving room for label
    sliderBar.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1) -- Darker track
    sliderBar.Text = ""
    sliderBar.AutoButtonColor = false -- Disables default hover scaling
    local barCorner = Instance.new("UICorner", sliderBar)
    barCorner.CornerRadius = UDIM.new(1, 0)
    local barStroke = Instance.new("UIStroke", sliderBar)
    barStroke.Thickness = 1.5
    
    local sliderFill = Instance.new("Frame", sliderBar)
    sliderFill.Size = UDim2.new((_G.Settings[key]-minVal)/(maxVal-minVal), 0, 1, 0)
    -- UIGradient for the fill to match the orange/yellow from reference
    local gradientFill = Instance.new("UIGradient", sliderFill)
    gradientFill.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 0))}
    local fillCorner = Instance.new("UICorner", sliderFill)
    fillCorner.CornerRadius = UDIM.new(1, 0)
    
    local function update(input)
        local mousePos = input.Position.X
        local percent = math.clamp((mousePos - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        _G.Settings[key] = math.floor(minVal + (maxVal - minVal) * percent)
        valueReadout.Text = tostring(_G.Settings[key])
        TweenService:Create(sliderFill, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
    end
    
    -- Interaction handling with hover and drag
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            update(input)
            local inputConn; inputConn = UIS.InputChanged:Connect(function(changedInput)
                if changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch then
                    update(changedInput)
                end
            end)
            update(input)
            UIS.InputEnded:Once(function() inputConn:Disconnect() end)
        end
    end)
    
    -- Hover effects
    sliderFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then sliderBar.BackgroundColor3 = Color3.fromRGB(40,40,40); TweenService:Create(barStroke, fastTween, {Thickness=2}):Play() end end)
    sliderFrame.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then sliderBar.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1); TweenService:Create(barStroke, fastTween, {Thickness=1.5}):Play() end end)
    
    return sliderFrame
end

-- helper to add standard TextButtons for auto walk and clear
local function AddButton(parent, text, func)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(func)
    
    -- hover effects
    btn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then TweenService:Create(btn, fastTween, {BackgroundColor3=Color3.fromRGB(50,50,50)}):Play() end end)
    btn.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then TweenService:Create(btn, fastTween, {BackgroundColor3=Color3.fromRGB(30,30,30)}):Play() end end)
    
    return btn
end

-- start building the features list structured as image_0.png two columns

-- Left Column: GÖRSEL, HIZ, ZIPLAMA
local leftContainer = AddSection("GÖRSEL")
AddToggle("Player ESP", "G", "ESP", leftContainer)
local espDistSlider = AddSlider("Distance slider", 0, 2000, "ESPDist", leftContainer)
-- E Player Name & Distance is part of G but implicitly added as a description in reference
AddToggle("Galaxy Mode", "A", "GalaxyMode", leftContainer)
local gravSlider = AddSlider("Gravity slider", 0, 100, "GravityVal", leftContainer)
AddToggle("Underground Arms", "H", "UnderArms", leftContainer)
AddToggle("Hidden Head", "K", "HiddenHead", leftContainer)

-- HIZ and ZIPLAMA implicitly part of visual list but with sliders as description
local speedToggleFrame = AddSection("HIZ")
AddToggle("Hız Hilesi", "N", "SpeedBoost", speedToggleFrame)
local speedSlider = AddSlider("Speed slider", 16, 600, "SpeedVal", speedToggleFrame)

local jumpToggleFrame = AddSection("ZIPLAMA")
AddToggle("Zıplama Gücü", "L", "JumpMod", jumpToggleFrame)
local jumpSlider = AddSlider("Jump Power slider", 50, 300, "JumpPower", jumpToggleFrame)

-- Right Column: COMBAT, SERVER, AUTO WALK
local rightContainer = AddSection("COMBAT")
AddToggle("Bat Aimbot (God Hitbox)", "C", "BatHitbox", rightContainer)
local reachSlider = AddSlider("Reach Distance slider", 5, 200, "BatSize", rightContainer)
AddToggle("Auto Clicker (Spam Bat)", "", "SpamBat", rightContainer) -- User featured but not with key, add as separate

local serverContainer = AddSection("SERVER")
AddToggle("Server Lag Spammer", "S", "ServerLag", serverContainer)

local movementContainer = AddSection("MOVEMENT")
AddToggle("No Ragdoll (Anti Ragdoll)", "R", "AntiRagdoll", movementContainer) -- User feature, now with R key
AddToggle("Spin Bot (Mevlana)", "P", "SpinBot", movementContainer)
local spinSlider = AddSlider("Spin Speed slider", 10, 600, "SpinSpeed", movementContainer)
AddToggle("Inf Jump", "J", "InfJump", movementContainer)

local autowalkContainer = AddSection("AUTO WALK")
AddToggle("Auto Walk", "U", "AutoWalk_On", autowalkContainer) -- explicit toggle state from image feel
local awBtnFrame = Instance.new("Frame", scroll); awBtnFrame.Size = UDim2.new(1, -10, 0, 40); awBtnFrame.BackgroundTransparency=1; local awLayout=Instance.new("UIListLayout", awBtnFrame); awLayout.FillDirection=Enum.FillDirection.Horizontal; awLayout.Padding=UDim.new(0,5); awLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
AddSection("W Waypoints").Parent = awBtnFrame -- using W as section title feel from reference
AddButton(awBtnFrame, "Set Point", function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then table.insert(_G.Settings.Waypoints, player.Character.HumanoidRootPart.Position) end end).Size=UDim2.new(0.48,0,1,0)
AddButton(awBtnFrame, "Clear Points", function() _G.Settings.Waypoints = {} end).Size=UDim2.new(0.48,0,1,0)


--[[ LOGIC MOTORS: The full robust codebase from V41 "OMEGA" is retained and optimized ]]--

-- 1. Immediate Speed & Jump Power engine: Heartbeat loop guarantees zero delay
RunService.Heartbeat:Connect(function()
    local char = Player.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if _G.Settings.SpeedBoost then
            hum.WalkSpeed = _G.Settings.SpeedVal
        else
            hum.WalkSpeed = 16 -- Normal default speed
        end
        if _G.Settings.JumpMod then
            hum.UseJumpPower = true -- required in R15 for certain properties
            hum.JumpPower = _G.Settings.JumpPower
        else
            hum.JumpPower = 50 -- normal default jump power
        end
    end
end)

-- 2. Advanced SpinBot (Mevlana) using BodyAngularVelocity (CFrame removed as requested in previous turn)
RunService.RenderStepped:Connect(function()
    local char = Player.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        local spinObj = root:FindFirstChild("OmegaSpin")
        if _G.Settings.SpinBot then
            if not spinObj then
                spinObj = Instance.new("BodyAngularVelocity")
                spinObj.Name = "OmegaSpin"
                spinObj.MaxTorque = Vector3.new(0, math.huge, 0) -- only spin on Y axis
                spinObj.Parent = root
            end
            spinObj.AngularVelocity = Vector3.new(0, _G.Settings.SpinSpeed, 0)
        else
            if spinObj then spinObj:Destroy() end
        end
    end
end)

-- 3. Infinity Jump Implementation: Changing state to Jumping immediately on JumpRequest
UIS.JumpRequest:Connect(function()
    if _G.Settings.InfJump and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- 4. Server Lag Spammer (Uses task.spawn to not block main thread)
task.spawn(function()
    while task.wait(0.1) do
        if _G.Settings.ServerLag then
            -- Oyundaki tüm uzak eventleri bul ve çöp veri yolla (Standart lag yöntemi)
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("RemoteEvent") then
                    pcall(function() 
                        v:FireServer(string.rep("LAG_SPAM_", 500), math.huge) 
                    end)
                end
            end
        end
    end
end)

-- 5. Anti-Ragdoll (Düşmeyi engeller): SetStateEnabled is crucial
RunService.Stepped:Connect(function()
    if _G.Settings.AntiRagdoll and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum.PlatformStand = false -- prevent being in platform stand state
        end
    end
end)

-- 6. Low Gravity (workspace.Gravity modification) from previous turns
local origGravity = workspace.Gravity
RunService.RenderStepped:Connect(function()
    if _G.Settings.GalaxyMode then
        workspace.Gravity = origGravity * (_G.Settings.GravityVal / 100)
    else
        workspace.Gravity = origGravity -- reset to normal gravity
    end
end)

-- 7. Advanced Bat Hitbox (Ultimate Reach with every method)
RunService.RenderStepped:Connect(function()
    local char = Player.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart")
    
    if _G.Settings.BatHitbox and hum and root then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            -- Create or update the Giant Reach Part attached to the player's torso
            local reach = char:FindFirstChild("OmegaReach") or Instance.new("Part", char)
            reach.Name = "OmegaReach"
            reach.Anchored = false
            reach.Massless = true
            reach.Transparency = 1 -- keep it invisible
            reach.CanCollide = false
            reach.Size = Vector3.new(_G.Settings.BatSize, _G.Settings.BatSize, _G.Settings.BatSize)
            
            -- Ensure it's welded and centered
            local weld = reach:FindFirstChild("Weld") or Instance.new("Weld", reach)
            weld.Name = "Weld"
            weld.Part0 = root -- Weld to human root part
            weld.Part1 = reach
            weld.C1 = CFrame.new(0, 0, 0) -- Centered
            
            -- Force Fire TouchSignals to all nearby enemies (God Reach effect)
            for _, enemy in pairs(Players:GetPlayers()) do
                if enemy ~= Player and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
                    local eRoot = enemy.Character.HumanoidRootPart
                    firetouchinterest(reach, eRoot, 0) -- Fire TouchBegin signal
                    firetouchinterest(reach, eRoot, 1) -- Fire TouchEnd signal
                end
            end
        else
            -- Clean up reach part on unequip
            local rp = char:FindFirstChild("OmegaReach"); if rp then rp:Destroy() end
        end
    else
        -- Clean up reach part on disable
        local rp = char:FindFirstChild("OmegaReach"); if rp then rp:Destroy() end
    end
end)

-- 8. Auto Clicker (Spam Bat) implementation
local isClicking = false
RunService.RenderStepped:Connect(function()
    local char = Player.Character; if not char or not char:FindFirstChild("Humanoid") then return end
    if _G.Settings.SpamBat then
        local t = char:FindFirstChildOfClass("Tool")
        if t and not isClicking then
            isClicking = true
            task.spawn(function()
                while _G.Settings.SpamBat and t.Parent == char do
                    t:Activate()
                    task.wait(0.05) -- small wait to ensure server sees activation
                end
                isClicking = false
            end)
        end
    end
end)

-- 9. Auto Walk Waypoints Engine with funkionality
local awRunning = false
RunService.Heartbeat:Connect(function()
    local char = Player.Character; if not char or not char:FindFirstChild("Humanoid") then return end
    if _G.Settings.AutoWalk_On and not awRunning and #_G.Settings.Waypoints > 0 then
        local hum = char.Humanoid
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            awRunning = true
            task.spawn(function()
                while _G.Settings.AutoWalk_On and #_G.Settings.Waypoints > 0 and hum.Health > 0 do
                    for _, wp in ipairs(_G.Settings.Waypoints) do
                        if not _G.Settings.AutoWalk_On then break end -- Stop immediately on toggle off
                        hum:MoveTo(wp)
                        local dist = (hrp.Position - wp).Magnitude
                        -- Wait until close to waypoint or auto-walk is stopped or health is zero
                        repeat 
                            dist = (hrp.Position - wp).Magnitude
                            task.wait(0.1) 
                        until dist < 6 or not _G.Settings.AutoWalk_On or hum.Health <= 0
                    end
                end
                awRunning = false
            end)
        end
    elseif not _G.Settings.AutoWalk_On and player.Character then
         -- ensured reset on auto movement
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:MoveTo(Player.Character.HumanoidRootPart.Position) end
    end
end)

-- 10. Simple text-based ESP implementation with Distance from turns
local function updateESP(p)
    local char = p.Character; if not char then return end; local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local gui = root:FindFirstChild("GalaxyUltraESP") or Instance.new("BillboardGui", root)
    gui.Name = "GalaxyUltraESP"; gui.Size = UDim2.new(0, 100, 0, 50); gui.StudsOffset = Vector3.new(0, 3, 0); gui.AlwaysOnTop = true
    local textLabel = gui:FindFirstChild("Text") or Instance.new("TextLabel", gui); textLabel.Name = "Text"; textLabel.Size = UDim2.new(1, 0, 1, 0); textLabel.TextColor3 = Color3.new(1, 1, 1); textLabel.BackgroundTransparency = 1; textLabel.Font = Enum.Font.GothamBold; textLabel.TextSize = 10; textLabel.TextXAlignment = 0; textLabel.TextYAlignment = 0
    RunService.RenderStepped:Connect(function() 
        textLabel.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1); -- RGB color effect
        local char = Player.Character
        if char then
            local dist = math.floor((char.HumanoidRootPart.Position - root.Position).Magnitude)
            textLabel.Text = p.Name .. "\n[" .. dist .. " studs]"
            textLabel.Visible = _G.Settings.ESP and dist <= _G.Settings.ESPDist
        else
            textLabel.Visible = false
        end
    end)
end
Players.PlayerAdded:Connect(updateESP); for _, p in pairs(Players:GetPlayers()) do if p ~= Player then updateESP(p) end end

-- 11. Custom Body Mods from previous turns (Underarms, HiddenHead)
RunService.RenderStepped:Connect(function()
    local char = Player.Character; if not char or not char:FindFirstChild("Humanoid") then return end
    local rs = char:FindFirstChild("RightShoulder",true); local ls = char:FindFirstChild("LeftShoulder",true)
    local neck = char:FindFirstChild("Neck",true)
    if _G.Settings.UnderArms then
        if rs then rs.C0 = CFrame.new(1, -6, 0) * CFrame.Angles(math.pi, 0, 0) end
        if ls then ls.C0 = CFrame.new(-1, -6, 0) * CFrame.Angles(math.pi, 0, 0) end
    end
    if _G.Settings.HiddenHead and neck then
        neck.C0 = CFrame.new(0, -1.5, 0)
    end
end)

print("LEMÖN HUB GALAXY ULTRA LOADED! Features from reference image integrated.")
