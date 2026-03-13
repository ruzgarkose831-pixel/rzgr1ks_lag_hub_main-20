local plr = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local mouse = plr:GetMouse()
local cg = game:GetService("CoreGui")
local players = game:GetService("Players")

local par = (gethui and gethui()) or cg
local guiName = "LemonHybrid_V6"

if par:FindFirstChild(guiName) then par[guiName]:Destroy() end

-- AYARLAR
local states = {
    speedOn = false, speedVal = 16,
    jumpPower = 50, gravity = 196.2,
    espOn = false, hitboxOn = false, hitboxVal = 2,
    infjump = false
}

-----------------------------------
-- CORE LOGIC (Hız, Hitbox, Fizik)
-----------------------------------

-- ESP & Hitbox & Speed Loop
rs.RenderStepped:Connect(function()
    -- Speed
    if states.speedOn and plr.Character then
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * ((states.speedVal - 16) / 45))
        end
    end
    
    -- Hitbox
    if states.hitboxOn then
        for _, p in pairs(players:GetPlayers()) do
            if p ~= plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                hrp.Size = Vector3.new(states.hitboxVal, states.hitboxVal, states.hitboxVal)
                hrp.Transparency = 0.7
                hrp.CanCollide = false
            end
        end
    end

    -- ESP
    if states.espOn then
        for _, p in pairs(players:GetPlayers()) do
            if p ~= plr and p.Character then
                local hl = p.Character:FindFirstChild("LemonESP")
                if not hl then
                    hl = Instance.new("Highlight", p.Character)
                    hl.Name = "LemonESP"
                    hl.FillColor = Color3.fromRGB(255, 230, 0)
                end
            end
        end
    else
        for _, p in pairs(players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("LemonESP") then
                p.Character.LemonESP:Destroy()
            end
        end
    end
end)

-- Fizik Güncelleyici (Gravity & Jump)
task.spawn(function()
    while task.wait(0.1) do
        workspace.Gravity = states.gravity
        if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
            plr.Character:FindFirstChildOfClass("Humanoid").JumpPower = states.jumpPower
        end
    end
end)

-----------------------------------
-- GUI TASARIMI
-----------------------------------
local ScreenGui = Instance.new("ScreenGui", par)
ScreenGui.Name = guiName

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 400)
Main.Position = UDim2.new(0.05, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "22S x LEMON V6"
Title.TextColor3 = Color3.fromRGB(255, 230, 0)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0, 2)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.BackgroundTransparency = 1

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -10, 1, -45)
Content.Position = UDim2.new(0, 5, 0, 40)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 2
local UIList = Instance.new("UIListLayout", Content)
UIList.Padding = UDim.new(0, 8)

-----------------------------------
-- MODÜLER GUI ELEMANLARI
-----------------------------------

-- SLIDER (Gelişmiş & Bug-Free)
local function createSlider(parent, name, min, max, default, stateKey)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -5, 0, 40)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 15)
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    label.BackgroundTransparency = 1
    label.TextSize = 12

    local sliderBack = Instance.new("Frame", frame)
    sliderBack.Size = UDim2.new(1, -10, 0, 4)
    sliderBack.Position = UDim2.new(0, 5, 0, 25)
    sliderBack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local sliderFill = Instance.new("Frame", sliderBack)
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 230, 0)
    
    local knob = Instance.new("TextButton", sliderFill)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(1, -6, 0.5, -6)
    knob.Text = ""
    knob.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging = false

    local function update()
        local inputPos = math.clamp((mouse.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(inputPos, 0, 1, 0)
        local val = min + (inputPos * (max - min))
        states[stateKey] = val
        label.Text = name .. ": " .. math.floor(val)
    end

    knob.MouseButton1Down:Connect(function() dragging = true end)
    
    -- GLOBAL RELEASE FIX
    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    mouse.Move:Connect(function()
        if dragging then update() end
    end)
end

-- TOGGLE
local function createToggle(name, stateKey)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, -5, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        states[stateKey] = not states[stateKey]
        btn.Text = name .. (states[stateKey] and ": ON" or ": OFF")
        btn.BackgroundColor3 = states[stateKey] and Color3.fromRGB(255, 230, 0) or Color3.fromRGB(30, 30, 30)
        btn.TextColor3 = states[stateKey] and Color3.new(0,0,0) or Color3.new(1,1,1)
    end)
end

-----------------------------------
-- SIRALAMA (Özellik + Slider)
-----------------------------------

createToggle("ESP Master", "espOn")

createToggle("Hitbox Expander", "hitboxOn")
createSlider(Content, "Hitbox Size", 2, 50, 2, "hitboxVal")

createToggle("Speed Hack", "speedOn")
createSlider(Content, "Speed Value", 16, 300, 16, "speedVal")

createToggle("Infinite Jump", "infjump")
createSlider(Content, "Jump Power", 50, 500, 50, "jumpPower")

createSlider(Content, "Gravity (World)", 0, 196, 196, "gravity")

-- Küçültme Mantığı
local isMin = false
MinBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    Content.Visible = not isMin
    Main:TweenSize(isMin and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 400), "Out", "Quart", 0.3, true)
    MinBtn.Text = isMin and "+" or "-"
end)

-- Inf Jump Trigger
uis.JumpRequest:Connect(function()
    if states.infjump and plr.Character then
        local h = plr.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
