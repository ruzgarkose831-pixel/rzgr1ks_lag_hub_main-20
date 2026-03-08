local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "rzgr1ks_V4"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false 

-- Main Menu
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 320)
Main.Position = UDim2.new(0.5, -130, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Main.Active = true
Main.Draggable = true 
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "rzgr1ks Hub"
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.BackgroundTransparency = 1
Title.TextSize = 22
Title.Font = Enum.Font.SourceSansBold

-- States
_G.BoostActive = false
_G.ESPActive = false

-- Function: ESP
local function applyESP(char)
    if not char then return end
    local highlight = char:FindFirstChild("ESPHighlight")
    if _G.ESPActive then
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.Parent = char
            highlight.FillColor = Color3.fromRGB(255, 0, 50)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        end
    elseif highlight then
        highlight:Destroy()
    end
end

-- MAIN LOOP (Speed, Jump, Tool Check)
task.spawn(function()
    while task.wait(0.1) do
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                
                if _G.BoostActive then
                    -- Elinde bir eşya (Tool) var mı kontrol et
                    local hasTool = char:FindFirstChildOfClass("Tool")
                    
                    if hasTool then
                        hum.WalkSpeed = 30 -- Eşya varken hız 30
                    else
                        hum.WalkSpeed = 60 -- Eşya yokken hız 60
                    end
                    hum.JumpPower = 15 -- Zıplama gücü sabit 15
                end
            end
        end

        -- ESP Logic
        if _G.ESPActive then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    applyESP(p.Character)
                end
            end
        end
    end
end)

-- Button Creation
local function createButton(name, posY, callback)
    local Btn = Instance.new("TextButton", Main)
    Btn.Size = UDim2.new(0, 220, 0, 50)
    Btn.Position = UDim2.new(0.5, -110, 0, posY)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    Btn.Text = name .. " : OFF"
    Btn.TextColor3 = Color3.white
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 16
    Instance.new("UICorner", Btn)

    local active = false
    Btn.MouseButton1Click:Connect(function()
        active = not active
        Btn.Text = active and (name .. " : ON") or (name .. " : OFF")
        Btn.BackgroundColor3 = active and Color3.fromRGB(0, 170, 120) or Color3.fromRGB(45, 45, 60)
        callback(active)
    end)
end

createButton("BOOST MODE", 80, function(val) 
    _G.BoostActive = val 
    if not val then -- Reset when turned off
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

-- Open/Close
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Close.TextColor3 = Color3.white
Instance.new("UICorner", Close)

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
OpenBtn.Text = "HUB"
OpenBtn.Visible = false
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

Close.MouseButton1Click:Connect(function() Main.Visible = false OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true OpenBtn.Visible = false end)
