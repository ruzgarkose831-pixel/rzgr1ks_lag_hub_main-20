local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- [[ SETTINGS ]] --
_G.Settings = {
    AutoFarm = false,
    DeliveryPos = nil, -- Manual setup required now for 100% accuracy
    TPSpeed = 16,          
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
        hum:EquipTool(carpet) -- Direct Engine Call to hold the tool
        task.wait(0.2)
        carpet:Activate() -- Start flying
    end
end

-- [[ TARGET SCANNER ]] --
local function FindTargetItem()
    local target = nil
    local dist = math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") or v:IsA("TouchTransmitter") then
            local part = v.Parent
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and not part:IsDescendantOf(Player.Character) then
                local d = (Player.Character.HumanoidRootPart.Position - part.Position).Magnitude
                if d < dist and d > 3 then
                    dist = d
                    target = part
                end
            end
        end
    end
    return target
end

-- [[ MAIN AUTO LOOP ]] --
task.spawn(function()
    while task.wait(0.5) do
        if _G.Settings.AutoFarm and _G.Settings.DeliveryPos then
            local char = Player.Character
            
            -- Ensure carpet is equipped
            if not char:FindFirstChild(_G.Settings.CarpetName) then
                ForceEquipCarpet()
            end
            
            local targetItem = FindTargetItem()
            if targetItem and char:FindFirstChild(_G.Settings.CarpetName) then
                -- Step 1: Fly to Item
                Glide(targetItem.Position)
                task.wait(0.2)
                
                -- Step 2: Grab Item
                local prompt = targetItem:FindFirstChildOfClass("ProximityPrompt")
                if prompt then fireproximityprompt(prompt) end
                
                -- Step 3: Fly back to SAVED Position
                Glide(_G.Settings.DeliveryPos)
                task.wait(0.4)
            end
        end
    end
end)

-- [[ NEON UI V64 ]] --
if Player.PlayerGui:FindFirstChild("SigmaV64") then Player.PlayerGui.SigmaV64:Destroy() end
local gui = Instance.new("ScreenGui", Player.PlayerGui); gui.Name = "SigmaV64"; gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui); main.Size = UDim2.new(0, 240, 0, 180); main.Position = UDim2.new(0.02, 0, 0.4, 0); main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); main.Active = true; main.Draggable = true
Instance.new("UICorner", main)
local stroke = Instance.new("UIStroke", main); stroke.Thickness = 2; stroke.Color = Color3.fromRGB(0, 255, 200)

local title = Instance.new("TextLabel", main); title.Size = UDim2.new(1, 0, 0, 40); title.Text = "CARPET STEALER V64"; title.TextColor3 = Color3.new(1, 1, 1); title.Font = "GothamBold"; title.BackgroundTransparency = 1

local farmBtn = Instance.new("TextButton", main); farmBtn.Size = UDim2.new(0.9, 0, 0, 45); farmBtn.Position = UDim2.new(0.05, 0, 0.25, 0); farmBtn.Text = "STATUS: WAITING FOR POS"; farmBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); farmBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", farmBtn)

farmBtn.MouseButton1Click:Connect(function()
    if not _G.Settings.DeliveryPos then farmBtn.Text = "SET POSITION FIRST!"; task.wait(1); farmBtn.Text = "STATUS: WAITING FOR POS"; return end
    _G.Settings.AutoFarm = not _G.Settings.AutoFarm
    farmBtn.Text = _G.Settings.AutoFarm and "FARMING: ON" or "FARMING: OFF"
    farmBtn.BackgroundColor3 = _G.Settings.AutoFarm and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(30, 30, 30)
end)

local setBtn = Instance.new("TextButton", main); setBtn.Size = UDim2.new(0.9, 0, 0, 45); setBtn.Position = UDim2.new(0.05, 0, 0.55, 0); setBtn.Text = "SET DELIVERY POINT"; setBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 255); setBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", setBtn)

setBtn.MouseButton1Click:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        _G.Settings.DeliveryPos = Player.Character.HumanoidRootPart.Position
        setBtn.Text = "POINT CAPTURED!"
        farmBtn.Text = "FARMING: READY"
        task.wait(1)
        setBtn.Text = "SET DELIVERY POINT"
    end
end)
