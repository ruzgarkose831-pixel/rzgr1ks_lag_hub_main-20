local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- [[ CONFIGURATION ]] --
_G.Settings = {
    AutoFarm = false,
    DeliveryPos = Vector3.new(-164, 45, 120),
    TPSpeed = 15,          
    CarpetName = "Flying Carpet",
    WaitTime = 0.01
}

-- [[ CORE GLIDE ENGINE ]] --
local function Glide(target)
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not char:FindFirstChild(_G.Settings.CarpetName) then return end

    local distance = (target - hrp.Position).Magnitude
    local direction = (target - hrp.Position).Unit
    
    for i = 0, distance, _G.Settings.TPSpeed do
        if not _G.Settings.AutoFarm then break end
        if not char:FindFirstChild(_G.Settings.CarpetName) then break end
        
        hrp.CFrame = CFrame.new(hrp.Position + (direction * math.min(_G.Settings.TPSpeed, (target - hrp.Position).Magnitude)))
        RunService.Heartbeat:Wait()
    end
    hrp.CFrame = CFrame.new(target)
end

-- [[ CARPET ACTIVATOR ]] --
local function UseCarpet()
    local char = Player.Character
    local carpet = char:FindFirstChild(_G.Settings.CarpetName) or Player.Backpack:FindFirstChild(_G.Settings.CarpetName)
    
    if carpet then
        carpet.Parent = char
        task.wait(0.1)
        carpet:Activate() -- Simulates click to start flying
    end
end

-- [[ TARGET SCANNER ]] --
local function FindTargetItem()
    local target = nil
    local dist = math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") or v:IsA("TouchTransmitter") then
            local part = v.Parent
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                local d = (Player.Character.HumanoidRootPart.Position - part.Position).Magnitude
                if d < dist and d > 5 then
                    dist = d
                    target = part
                end
            end
        end
    end
    return target
end

-- [[ MAIN LOOP ]] --
task.spawn(function()
    while task.wait(0.5) do
        if _G.Settings.AutoFarm then
            local char = Player.Character
            UseCarpet()
            task.wait(0.2)
            
            local targetItem = FindTargetItem()
            if targetItem and char:FindFirstChild(_G.Settings.CarpetName) then
                Glide(targetItem.Position)
                task.wait(0.3)
                
                local prompt = targetItem:FindFirstChildOfClass("ProximityPrompt")
                if prompt then fireproximityprompt(prompt) end
                
                Glide(_G.Settings.DeliveryPos)
                task.wait(0.5)
            end
        end
    end
end)

-- [[ NEON ENGLISH GUI ]] --
if Player.PlayerGui:FindFirstChild("SigmaV63") then Player.PlayerGui.SigmaV63:Destroy() end

local gui = Instance.new("ScreenGui", Player.PlayerGui)
gui.Name = "SigmaV63"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 250, 0, 180)
main.Position = UDim2.new(0.02, 0, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- Neon Border
local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(255, 0, 100)
task.spawn(function()
    while task.wait() do
        for i = 0, 1, 0.01 do
            stroke.Color = Color3.fromHSV(i, 1, 1)
            task.wait(0.05)
        end
    end
end)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "BRAINROT STEALER V63"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = "GothamBold"
title.TextSize = 14
title.BackgroundTransparency = 1

local farmBtn = Instance.new("TextButton", main)
farmBtn.Size = UDim2.new(0.9, 0, 0, 45)
farmBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
farmBtn.Text = "AUTO STEAL: DISABLED"
farmBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
farmBtn.TextColor3 = Color3.new(1, 1, 1)
farmBtn.Font = "Gotham"
farmBtn.TextSize = 12
Instance.new("UICorner", farmBtn)

farmBtn.MouseButton1Click:Connect(function()
    _G.Settings.AutoFarm = not _G.Settings.AutoFarm
    farmBtn.Text = "AUTO STEAL: " .. (_G.Settings.AutoFarm and "ENABLED" or "DISABLED")
    farmBtn.BackgroundColor3 = _G.Settings.AutoFarm and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(30, 30, 30)
end)

local setPosBtn = Instance.new("TextButton", main)
setPosBtn.Size = UDim2.new(0.9, 0, 0, 45)
setPosBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
setPosBtn.Text = "SET DELIVERY POINT"
setPosBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 100)
setPosBtn.TextColor3 = Color3.new(1, 1, 1)
setPosBtn.Font = "Gotham"
setPosBtn.TextSize = 12
Instance.new("UICorner", setPosBtn)

setPosBtn.MouseButton1Click:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        _G.Settings.DeliveryPos = Player.Character.HumanoidRootPart.Position
        setPosBtn.Text = "POINT SAVED!"
        task.wait(1)
        setPosBtn.Text = "SET DELIVERY POINT"
    end
end)

local footer = Instance.new("TextLabel", main)
footer.Size = UDim2.new(1, 0, 0, 20)
footer.Position = UDim2.new(0, 0, 1, -20)
footer.Text = "Status: Ready to mog the server"
footer.TextColor3 = Color3.fromRGB(150, 150, 150)
footer.Font = "Gotham"
footer.TextSize = 10
footer.BackgroundTransparency = 1

print("V63 HYPER NEON LOADED. STATUS: SIGMA")
