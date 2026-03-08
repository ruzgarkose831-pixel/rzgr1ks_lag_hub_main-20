local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "rzgr1ks_Fixed"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false 
ScreenGui.IgnoreGuiInset = true -- Ekranın en üstüne kadar kullanabilmeyi sağlar

-- Main Menu
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 280, 0, 350)
Main.Position = UDim2.new(0.5, -140, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true 
Main.Visible = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "rzgr1ks Hub PRO"
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.BackgroundTransparency = 1
Title.TextSize = 24
Title.Font = Enum.Font.SourceSansBold

-- States
_G.BoostActive = false
_G.ESPActive = false

-- Function: ESP Logic
local function updateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local highlight = p.Character:FindFirstChild("ESPHighlight")
            if _G.ESPActive then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESPHighlight"
                    highlight.Parent = p.Character
                    highlight.FillColor = Color3.fromRGB(255, 0, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end

-- Main Loop (Speed, Jump, Tool Check)
task.spawn(function()
    while task.wait(0.1) do
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                if _G.BoostActive then
                    local hasTool = char:FindFirstChildOfClass("Tool")
                    hum.WalkSpeed = hasTool and 30 or 60
                    hum.JumpPower = 15
                end
            end
        end
        if _G.ESPActive then updateESP() end
    end
end)

-- Ultra-Responsive Button Function (Mobile Friendly)
local function createButton(name, posY, callback)
    local Btn = Instance.new("TextButton", Main)
    Btn.Size = UDim2.new(0, 240, 0, 60)
    Btn.Position = UDim2.new(0.5, -120, 0, posY)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Btn.Text = name .. " : OFF"
    Btn.TextColor3 = Color3.white
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 18
    Btn.AutoButtonColor = true
    Instance.new("UICorner", Btn)

    local active = false
    
    -- Hem tıklama hem dokunma için en hızlı tepki veren event
    Btn.Activated:Connect(function()
        active = not active
        Btn.Text = active and (name .. " : ON") or (name .. " : OFF")
        Btn.BackgroundColor3 = active and Color3.fromRGB(0, 180, 130) or Color3.fromRGB(40, 40, 55)
        callback(active)
    end)
end

-- Create Two Separate Buttons
createButton("BOOST MODE", 70, function(val) 
    _G.BoostActive = val 
    if not val then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 hum.JumpPower = 50 end
    end
end)

createButton("PLAYER ESP", 150, function(val) 
    _G.ESPActive = val 
    if not val then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("ESPHighlight") then
                p.Character.ESPHighlight:Destroy()
            end
        end
    end
end)

-- Close Button
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 35, 0, 35)
Close.Position = UDim2.new(1, -40, 0, 5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
Close.TextColor3 = Color3.white
Instance.new("UICorner", Close)

-- Open Button (Mini Circle)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
OpenBtn.Text = "OPEN"
OpenBtn.Visible = false
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
OpenBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

Close.Activated:Connect(function() Main.Visible = false OpenBtn.Visible = true end)
OpenBtn.Activated:Connect(function() Main.Visible = true OpenBtn.Visible = false end)
