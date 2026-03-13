local plr = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local cg = game:GetService("CoreGui")
local players = game:GetService("Players")

local par = (gethui and gethui()) or cg
local guiName = "LemonHybrid_V9_Mobile"

if par:FindFirstChild(guiName) then par[guiName]:Destroy() end

-- AYARLAR
local states = {
    speedOn = false, speedVal = 16,
    jumpPower = 50, gravity = 196.2,
    espOn = false, hitboxOn = false, hitboxVal = 2,
    infjump = false, antirag = false,
    spinbot = false, xrayon = false
}

local xrayCache = {}

-----------------------------------
-- CORE LOGIC
-----------------------------------

rs.RenderStepped:Connect(function()
    if not plr.Character then return end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    local root = plr.Character:FindFirstChild("HumanoidRootPart")

    if states.speedOn and hum and root and hum.MoveDirection.Magnitude > 0 then
        root.CFrame = root.CFrame + (hum.MoveDirection * ((states.speedVal - 16) / 45))
    end
    
    if states.antirag and hum then
        if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end

    for _, p in pairs(players:GetPlayers()) do
        if p ~= plr and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if states.hitboxOn then
                    hrp.Size = Vector3.new(states.hitboxVal, states.hitboxVal, states.hitboxVal)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                else
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                end
            end
            local hl = p.Character:FindFirstChild("LemonESP")
            if states.espOn then
                if not hl then
                    hl = Instance.new("Highlight", p.Character)
                    hl.Name = "LemonESP"
                    hl.FillColor = Color3.fromRGB(255, 230, 0)
                end
            elseif hl then hl:Destroy() end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        workspace.Gravity = states.gravity
        if plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum then hum.JumpPower = states.jumpPower end
            if root then
                local s = root:FindFirstChild("LemonSpin")
                if states.spinbot then
                    if not s then
                        s = Instance.new("BodyAngularVelocity", root)
                        s.Name = "LemonSpin"
                        s.MaxTorque = Vector3.new(0, math.huge, 0)
                        s.AngularVelocity = Vector3.new(0, 50, 0)
                    end
                elseif s then s:Destroy() end
            end
        end
    end
end)

-----------------------------------
-- MOBİL DESTEKLİ GUI
-----------------------------------
local ScreenGui = Instance.new("ScreenGui", par)
ScreenGui.Name = guiName

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 280, 0, 350)
Main.Position = UDim2.new(0.5, -140, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true -- Mobilde de çalışır
Instance.new("UICorner", Main)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "🍋 LEMON MOBILE V9"
Title.TextColor3 = Color3.fromRGB(255, 230, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(1, -40, 0, 2)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.TextSize = 20
MinBtn.BackgroundTransparency = 1

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -10, 1, -50)
Content.Position = UDim2.new(0, 5, 0, 45)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 4
local UIList = Instance.new("UIListLayout", Content)
UIList.Padding = UDim.new(0, 10)

-----------------------------------
-- MOBİL SLIDER FİX (Touch Support)
-----------------------------------

local function createSlider(name, min, max, default, stateKey)
    local frame = Instance.new("Frame", Content)
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14

    local sliderBack = Instance.new("Frame", frame)
    sliderBack.Size = UDim2.new(1, -30, 0, 8)
    sliderBack.Position = UDim2.new(0, 15, 0, 30)
    sliderBack.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Instance.new("UICorner", sliderBack)

    local sliderFill = Instance.new("Frame", sliderBack)
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 230, 0)
    Instance.new("UICorner", sliderFill)
    
    local knob = Instance.new("Frame", sliderFill)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(1, -9, 0.5, -9)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging = false

    local function update(input)
        local inputPos = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(inputPos, 0, 1, 0)
        local val = math.floor(min + (inputPos * (max - min)))
        states[stateKey] = val
        label.Text = name .. ": " .. val
    end

    -- Mobil ve PC için giriş takibi
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)

    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    uis.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

local function createToggle(name, stateKey)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        states[stateKey] = not states[stateKey]
        btn.Text = name .. (states[stateKey] and ": ON" or ": OFF")
        btn.BackgroundColor3 = states[stateKey] and Color3.fromRGB(255, 230, 0) or Color3.fromRGB(35, 35, 35)
        btn.TextColor3 = states[stateKey] and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
    end)
end

-----------------------------------
-- MOBİL DİZİLİM
-----------------------------------
createToggle("ESP Master", "espOn")
createToggle("X-Ray View", "xrayon")
createToggle("Hitbox Expander", "hitboxOn")
createSlider("Hitbox Size", 2, 60, 2, "hitboxVal")
createToggle("Speed Hack", "speedOn")
createSlider("Speed Value", 16, 300, 16, "speedVal")
createToggle("Spinbot", "spinbot")
createToggle("Anti-Ragdoll", "antirag")
createToggle("Infinite Jump", "infjump")
createSlider("Jump Power", 50, 500, 50, "jumpPower")
createSlider("Gravity", 0, 196, 196, "gravity")

local isMin = false
MinBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    Content.Visible = not isMin
    Main:TweenSize(isMin and UDim2.new(0, 280, 0, 40) or UDim2.new(0, 280, 0, 350), "Out", "Quart", 0.3, true)
    MinBtn.Text = isMin and "+" or "-"
end)

uis.JumpRequest:Connect(function()
    if states.infjump and plr.Character then
        local h = plr.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
