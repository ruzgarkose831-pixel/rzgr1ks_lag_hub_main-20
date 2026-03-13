local plr = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local mouse = plr:GetMouse()
local cg = game:GetService("CoreGui")
local players = game:GetService("Players")

local par = (gethui and gethui()) or cg
local guiName = "LemonHybrid_V5"

if par:FindFirstChild(guiName) then par[guiName]:Destroy() end

-- AYARLAR VE DURUMLAR
local states = {
    speedOn = false, speedVal = 16,
    jumpPower = 50, gravity = 196.2,
    spinbot = false, antirag = false,
    xrayon = false, infjump = false,
    espOn = false, hitboxOn = false, hitboxVal = 2
}

local connections = {}

-----------------------------------
-- ÖZELLİK MANTIĞI (LOGIC)
-----------------------------------

-- ESP Sistemi (Highlight Modeli)
local function updateESP()
    for _, p in pairs(players:GetPlayers()) do
        if p ~= plr and p.Character then
            local highlight = p.Character:FindFirstChild("LemonESP")
            if states.espOn then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "LemonESP"
                    highlight.FillColor = Color3.fromRGB(255, 230, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = p.Character
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end

-- Hitbox Expander
rs.RenderStepped:Connect(function()
    if states.hitboxOn then
        for _, p in pairs(players:GetPlayers()) do
            if p ~= plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                hrp.Size = Vector3.new(states.hitboxVal, states.hitboxVal, states.hitboxVal)
                hrp.Transparency = 0.7
                hrp.BrickColor = BrickColor.new("Bright yellow")
                hrp.CanCollide = false
            end
        end
    end
end)

-- Hız ve Diğer Fizik Döngüleri
rs.RenderStepped:Connect(function()
    if states.speedOn and plr.Character then
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * ((states.speedVal - 16) / 45))
        end
    end
    if states.espOn then updateESP() end
end)

task.spawn(function()
    while task.wait(0.1) do
        workspace.Gravity = states.gravity
        local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = states.jumpPower hum.UseJumpPower = true end
    end
end)

-----------------------------------
-- GUI TASARIMI
-----------------------------------
local ScreenGui = Instance.new("ScreenGui", par)
ScreenGui.Name = guiName

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 250, 0, 380)
Main.Position = UDim2.new(0.05, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "22S x LEMON V5"
Title.TextColor3 = Color3.fromRGB(255, 230, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0, 2)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.BackgroundTransparency = 1

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -10, 1, -45)
Content.Position = UDim2.new(0, 5, 0, 40)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 2
local UIList = Instance.new("UIListLayout", Content)
UIList.Padding = UDim.new(0, 5)

-- YARDIMCI FONKSİYONLAR (Slider & Toggle)
local function createSlider(name, min, max, default, stateKey)
    local frame = Instance.new("Frame", Content)
    frame.Size = UDim2.new(1, -5, 0, 45)
    frame.BackgroundTransparency = 1
    frame.Visible = false

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    label.BackgroundTransparency = 1

    local sliderBack = Instance.new("Frame", frame)
    sliderBack.Size = UDim2.new(1, -10, 0, 6)
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
        local pos = math.clamp((mouse.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        local val = min + (pos * (max - min))
        states[stateKey] = val
        label.Text = name .. ": " .. string.format("%.1f", val)
    end

    knob.MouseButton1Down:Connect(function() dragging = true end)
    uis.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    mouse.Move:Connect(function() if dragging then update() end end)
    return frame
end

local function createToggle(name, stateKey)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, -5, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        states[stateKey] = not states[stateKey]
        btn.Text = name .. (states[stateKey] and ": ON" or ": OFF")
        btn.BackgroundColor3 = states[stateKey] and Color3.fromRGB(255, 230, 0) or Color3.fromRGB(30, 30, 30)
        btn.TextColor3 = states[stateKey] and Color3.new(0,0,0) or Color3.new(1,1,1)
    end)
end

-- ÖZELLİKLERİ EKLE
createToggle("ESP Master", "espOn")
createToggle("Hitbox Expander", "hitboxOn")
createToggle("Speed Toggle", "speedOn")
createToggle("Infinite Jump", "infjump")

local configBtn = Instance.new("TextButton", Content)
configBtn.Size = UDim2.new(1, -5, 0, 30)
configBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
configBtn.Text = "⚙️ Configure (Ayarlar)"
configBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", configBtn)

local s1 = createSlider("Speed", 16, 300, 16, "speedVal")
local s2 = createSlider("Hitbox Size", 2, 30, 2, "hitboxVal")
local s3 = createSlider("Jump Power", 50, 500, 50, "jumpPower")
local s4 = createSlider("Gravity", 0, 196, 196, "gravity")

configBtn.MouseButton1Click:Connect(function()
    s1.Visible = not s1.Visible s2.Visible = not s2.Visible
    s3.Visible = not s3.Visible s4.Visible = not s4.Visible
end)

-- Küçültme Mantığı
local min = false
MinBtn.MouseButton1Click:Connect(function()
    min = not min
    Content.Visible = not min
    Main:TweenSize(min and UDim2.new(0, 250, 0, 35) or UDim2.new(0, 250, 0, 380), "Out", "Quart", 0.3, true)
    MinBtn.Text = min and "+" or "-"
end)

-- Inf Jump Logic
uis.JumpRequest:Connect(function()
    if states.infjump and plr.Character then
        local h = plr.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
