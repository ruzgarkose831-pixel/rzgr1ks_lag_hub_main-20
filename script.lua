local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- [[ CONFIGURATION ]] --
_G.Settings = {
    AutoFarm = false,
    DeliveryPos = nil, 
    TPSpeed = 18,          
    CarpetName = "Flying Carpet",
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

-- [[ FORCED EQUIP & ACTIVATE ]] --
local function ForceEquipCarpet()
    local char = Player.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local carpet = Player.Backpack:FindFirstChild(_G.Settings.CarpetName)
    
    if carpet and hum then
        hum:EquipTool(carpet)
        task.wait(0.2)
        carpet:Activate()
    end
end

-- [[ BRAINROT TARGET FINDER ]] --
local function FindTarget()
    local targetObj = nil
    local dist = math.huge
    
    -- Yerleri tara (ProximityPrompt olan her şey bir hedeftir)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local part = v.Parent
            if part:IsA("BasePart") then
                local d = (Player.Character.HumanoidRootPart.Position - part.Position).Magnitude
                if d < dist and d > 4 then
                    dist = d
                    targetObj = part
                end
            end
        end
    end
    return targetObj
end

-- [[ MAIN STEALER LOOP ]] --
task.spawn(function()
    while task.wait(0.5) do
        if _G.Settings.AutoFarm and _G.Settings.DeliveryPos then
            local char = Player.Character
            
            -- 1. Halıyı hazırla
            if not char:FindFirstChild(_G.Settings.CarpetName) then
                ForceEquipCarpet()
            end
            
            -- 2. Hedef bul
            local target = FindTarget()
            if target and char:FindFirstChild(_G.Settings.CarpetName) then
                -- 3. HEDEFE GİT
                print("Target Found: " .. target.Name .. " | Flying to target...")
                Glide(target.Position)
                task.wait(0.2)
                
                -- 4. OTOMATİK ÇAL (Prompt'u tetikle)
                local prompt = target:FindFirstChildOfClass("ProximityPrompt")
                if prompt then fireproximityprompt(prompt) end
                task.wait(0.1)
                
                -- 5. TESLİM NOKTASINA DÖN
                print("Item Stolen! Returning to Delivery Point...")
                Glide(_G.Settings.DeliveryPos)
                task.wait(0.5)
            end
        end
    end
end)

-- [[ NEON ENGLISH GUI V66 ]] --
if Player.PlayerGui:FindFirstChild("SigmaV66") then Player.PlayerGui.SigmaV66:Destroy() end
local gui = Instance.new("ScreenGui", Player.PlayerGui); gui.Name = "SigmaV66"; gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui); main.Size = UDim2.new(0, 250, 0, 180); main.Position = UDim2.new(0.02, 0, 0.4, 0); main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.Active = true; main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", main); stroke.Thickness = 2; stroke.Color = Color3.fromRGB(0, 255, 150)

local title = Instance.new("TextLabel", main); title.Size = UDim2.new(1, 0, 0, 40); title.Text = "AUTO STEAL & TP V66"; title.TextColor3 = Color3.new(1, 1, 1); title.Font = "GothamBold"; title.BackgroundTransparency = 1

local farmBtn = Instance.new("TextButton", main); farmBtn.Size = UDim2.new(0.9, 0, 0, 45); farmBtn.Position = UDim2.new(0.05, 0, 0.25, 0); farmBtn.Text = "STATUS: NO POSITION"; farmBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); farmBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", farmBtn)

farmBtn.MouseButton1Click:Connect(function()
    if not _G.Settings.DeliveryPos then farmBtn.Text = "SET DELIVERY FIRST!"; task.wait(1); farmBtn.Text = "STATUS: NO POSITION"; return end
    _G.Settings.AutoFarm = not _G.Settings.AutoFarm
    farmBtn.Text = _G.Settings.AutoFarm and "FARMING: ENABLED" or "FARMING: DISABLED"
    farmBtn.BackgroundColor3 = _G.Settings.AutoFarm and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(35, 35, 35)
end)

local setBtn = Instance.new("TextButton", main); setBtn.Size = UDim2.new(0.9, 0, 0, 45); setBtn.Position = UDim2.new(0.05, 0, 0.55, 0); setBtn.Text = "SET DELIVERY POINT"; setBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 255); setBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", setBtn)

setBtn.MouseButton1Click:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        _G.Settings.DeliveryPos = Player.Character.HumanoidRootPart.Position
        setBtn.Text = "SAVED!"
        farmBtn.Text = "FARMING: READY"
        task.wait(1)
        setBtn.Text = "SET DELIVERY POINT"
    end
end)
