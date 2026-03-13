-- rzgr1ks semi TP | Red Edition

-- Rebranded with working 0.73 logic + Auto Velocity + Discords

local Players = game:GetService("Players")

local TweenService = game:GetService("TweenService")

local RunService = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService")

local ProximityPromptService = game:GetService("ProximityPromptService")

local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Coordinates

local pos1 = Vector3.new(-352.98, -7, 74.30)

local pos2 = Vector3.new(-352.98, -6.49, 45.76)

local standing1 = Vector3.new(-336.36, -4.59, 99.51)

local standing2 = Vector3.new(-334.81, -4.59, 18.90)

local spot1_sequence = {

    CFrame.new(-370.810913, -7.00000334, 41.2687263, 0.99984771, 1.22364419e-09, 0.0174523517, -6.54859778e-10, 1, -3.2596418e-08, -0.0174523517, 3.25800258e-08, 0.99984771),

    CFrame.new(-336.355286, -5.10107088, 17.2327671, -0.999883354, -2.76150569e-08, 0.0152716246, -2.88224964e-08, 1, -7.88441525e-08, -0.0152716246, -7.9275118e-08, -0.999883354)

}

local spot2_sequence = {

    CFrame.new(-354.782867, -7.00000334, 92.8209305, -0.999997616, -1.11891862e-09, -0.00218066527, -1.11958298e-09, 1, 3.03415071e-10, 0.00218066527, 3.05855785e-10, -0.999997616),

    CFrame.new(-336.942902, -5.10106993, 99.3276443, 0.999914348, -3.63984611e-08, 0.0130875716, 3.67094941e-08, 1, -2.35254749e-08, -0.0130875716, 2.40038975e-08, 0.999914348)

}

-- Cleanup existing

if CoreGui:FindFirstChild("VandersGui") then CoreGui["VandersGui"]:Destroy() end

local screenGui = Instance.new("ScreenGui")

screenGui.Name = "rzgr1ks gui"

screenGui.Parent = CoreGui

-- Themes

local MAIN_RED = Color3.fromRGB(255, 0, 0)

local DARK_BG = Color3.fromRGB(15, 15, 15)

-- ESP Markers

local function createESPBox(position, labelText)

    local espPart = Instance.new("Part", workspace)

    espPart.Size = Vector3.new(5, 0.5, 5)

    espPart.Position = position

    espPart.Anchored = true

    espPart.CanCollide = false

    espPart.Transparency = 0.5

    espPart.Material = Enum.Material.Neon

    espPart.Color = MAIN_RED

    local bill = Instance.new("BillboardGui", espPart)

    bill.Size = UDim2.new(0, 100, 0, 40)

    bill.StudsOffset = Vector3.new(0, 2, 0)

    bill.AlwaysOnTop = true

    local txt = Instance.new("TextLabel", bill)

    txt.Size = UDim2.new(1, 0, 1, 0)

    txt.BackgroundTransparency = 1

    txt.Text = labelText

    txt.TextColor3 = Color3.fromRGB(255, 255, 255)

    txt.Font = Enum.Font.GothamBold

    txt.TextSize = 14

end

createESPBox(pos1, "Teleport Here")

createESPBox(pos2, "Teleport Here")

createESPBox(standing1, "Standing 1")

createESPBox(standing2, "Standing 2")

-- Variables for Logic

local velocityEnabled = true -- Auto-enabled as requested

local IsStealing = false

local StealProgress = 0

-- Desync Logic (ResetToWork)

local function ResetToWork()

    pcall(function()

        if setfflag then

            setfflag("S2PhysicsSenderRate", "15000")

            setfflag("ServerMaxBandwith", "52")

        end

    end)

    local char = player.Character

    if char then

        char:ClearAllChildren()

        local f = Instance.new("Model", workspace)

        player.Character = f task.wait()

        player.Character = char f:Destroy()

    end

end

task.spawn(function() task.wait(1) ResetToWork() end)

-- Main Frame

local mainFrame = Instance.new("Frame", screenGui)

mainFrame.Size = UDim2.new(0, 190, 0, 420)

mainFrame.Position = UDim2.new(1, -210, 0.5, -210)

mainFrame.BackgroundColor3 = DARK_BG

Instance.new("UICorner", mainFrame)

local stroke = Instance.new("UIStroke", mainFrame)

stroke.Color = MAIN_RED

stroke.Thickness = 2

local title = Instance.new("TextLabel", mainFrame)

title.Size = UDim2.new(1, 0, 0, 40)

title.Text = "RZGR1KS SEMI TP"

title.TextColor3 = Color3.fromRGB(255, 255, 255)

title.Font = Enum.Font.GothamBlack

title.BackgroundTransparency = 1

-- [[ VELOCITY LABEL ]]

local velocityStatus = Instance.new("TextLabel", mainFrame)

velocityStatus.Size = UDim2.new(1, 0, 0, 20)

velocityStatus.Position = UDim2.new(0, 0, 0, 230)

velocityStatus.BackgroundTransparency = 1

velocityStatus.Text = "VELOCITY: IDLE (29.5)"

velocityStatus.TextColor3 = Color3.fromRGB(200, 200, 200)

velocityStatus.Font = Enum.Font.GothamBold

velocityStatus.TextSize = 10

-- Velocity Loop Logic

RunService.Heartbeat:Connect(function()

    if velocityEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then

        local hrp = player.Character.HumanoidRootPart

        local hum = player.Character:FindFirstChildOfClass("Humanoid")

        if hum.MoveDirection.Magnitude > 0 then

            hrp.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X * 29.5, hrp.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * 29.5)

            velocityStatus.Text = "VELOCITY: ACTIVE (29.5)"

            velocityStatus.TextColor3 = Color3.fromRGB(0, 255, 100)

        else

            velocityStatus.Text = "VELOCITY: IDLE (29.5)"

            velocityStatus.TextColor3 = Color3.fromRGB(200, 200, 200)

        end

    end

end)

-- Scanner Logic

local function getNearestAnimal()

    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

    if not hrp then return nil end

    local nearest, dist = nil, 200

    for _, plot in ipairs(workspace.Plots:GetChildren()) do

        local podiums = plot:FindFirstChild("AnimalPodiums")

        if podiums then

            for _, p in ipairs(podiums:GetChildren()) do

                local d = (hrp.Position - p:GetPivot().Position).Magnitude

                if d < dist then dist = d nearest = p end

            end

        end

    end

    return nearest

end

-- Working 0.73 Teleport Logic

local function executeInternalSteal(sequence)

    if IsStealing then return end

    local target = getNearestAnimal()

    if not target then return end

    local prompt = target.Base.Spawn.PromptAttachment:FindFirstChildOfClass("ProximityPrompt")

    if not prompt then return end

    IsStealing = true

    task.spawn(function()

        for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do c:Fire() end

        local startTime = tick()

        local tpDone = false

        while tick() - startTime < 1.3 do

            StealProgress = (tick() - startTime) / 1.3

            if StealProgress >= 0.73 and not tpDone then

                tpDone = true

                local hrp = player.Character.HumanoidRootPart

                local hum = player.Character:FindFirstChildOfClass("Humanoid")

                local carpet = player.Backpack:FindFirstChild("Flying Carpet")

                if carpet then hum:EquipTool(carpet) task.wait(0.05) end

                hrp.CFrame = sequence[1]

                task.wait(0.1)

                hrp.CFrame = sequence[2]

                task.wait(0.2)

                local d1 = (hrp.Position - pos1).Magnitude

                local d2 = (hrp.Position - pos2).Magnitude

                hrp.CFrame = CFrame.new(d1 < d2 and pos1 or pos2)

            end

            task.wait()

        end

        for _, c in ipairs(getconnections(prompt.Triggered)) do c:Fire() end

        IsStealing = false

        StealProgress = 0

    end)

end

-- Buttons

local function createStyledButton(text, pos, callback, textColor)

    local btn = Instance.new("TextButton", mainFrame)

    btn.Size = UDim2.new(0.9, 0, 0, 30)

    btn.Position = pos

    btn.BackgroundColor3 = Color3.fromRGB(30, 0, 0)

    btn.Text = text

    btn.Font = Enum.Font.GothamBold

    btn.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)

    btn.TextSize = 10

    Instance.new("UICorner", btn)

    local s = Instance.new("UIStroke", btn)

    s.Color = MAIN_RED

    btn.MouseButton1Click:Connect(callback)

    return btn

end

createStyledButton("Auto TP Left", UDim2.new(0.05, 0, 0, 50), function() executeInternalSteal(spot1_sequence) end)

createStyledButton("Auto TP Right", UDim2.new(0.05, 0, 0, 90), function() executeInternalSteal(spot2_sequence) end)

createStyledButton("Force Reset", UDim2.new(0.05, 0, 0, 130), ResetToWork)

-- Progress Bar

local bar = Instance.new("Frame", mainFrame)

bar.Size = UDim2.new(0.9, 0, 0, 10)

bar.Position = UDim2.new(0.05, 0, 0, 180)

bar.BackgroundColor3 = Color3.fromRGB(40, 0, 0)

local fill = Instance.new("Frame", bar)

fill.Size = UDim2.new(0, 0, 1, 0)

fill.BackgroundColor3 = MAIN_RED

RunService.RenderStepped:Connect(function() fill.Size = UDim2.new(math.clamp(StealProgress, 0, 1), 0, 1, 0) end)

-- Discords

createStyledButton("Vanders Discord", UDim2.new(0.05, 0, 0, 340), function() setclipboard("https://discord.gg/VMPaUDS3r") end)

createStyledButton("Solsras Discord", UDim2.new(0.05, 0, 0, 380), function() setclipboard("https://discord.gg/cRbTymkPa") end, Color3.fromRGB(80, 150, 255))

-- Draggable Logic

local dragging, dStart, sPos

mainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dStart = i.Position sPos = mainFrame.Position end end)

UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then

    local delta = i.Position - dStart

    mainFrame.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)

end end)

UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
