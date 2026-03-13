local plr = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local ws = workspace
local cg = game:GetService("CoreGui")
local rep = game:GetService("ReplicatedStorage")

local par = (gethui and gethui()) or cg
local guiName = "LemonHybrid_V3"

-- Eski GUI'yi temizle
if par:FindFirstChild(guiName) then par[guiName]:Destroy() end

-- AYARLAR VE DURUMLAR
local states = {
    speedOn = false, speedVal = 55,
    jumpPower = 50, gravity = 196.2,
    spinbot = false, antirag = false,
    autograb = false, xrayon = false,
    floaton = false, infjump = false
}

local xrayCache = {}
local connections = {}

-----------------------------------
-- TEMEL FONKSİYONLAR
-----------------------------------

-- Gelişmiş Hız Mantığı (Ayarlanabilir)
rs.RenderStepped:Connect(function()
    if states.speedOn and plr.Character then
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * (states.speedVal / 50))
        end
    end
end)

-- Yerçekimi ve Zıplama Güncelleyici
task.spawn(function()
    while task.wait(0.5) do
        ws.Gravity = states.gravity
        if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
            plr.Character:FindFirstChildOfClass("Humanoid").JumpPower = states.jumpPower
            plr.Character:FindFirstChildOfClass("Humanoid").UseJumpPower = true
        end
    end
end)

-- Spinbot
local function toggleSpin(b)
    if b then
        local function apply(c)
            local hrp = c:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                local bv = Instance.new("BodyAngularVelocity")
                bv.Name = "LemonSpin"
                bv.MaxTorque = Vector3.new(0, math.huge, 0)
                bv.AngularVelocity = Vector3.new(0, 50, 0)
                bv.Parent = hrp
            end
        end
        if plr.Character then apply(plr.Character) end
        connections.spin = plr.CharacterAdded:Connect(apply)
    else
        if connections.spin then connections.spin:Disconnect() end
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local s = plr.Character.HumanoidRootPart:FindFirstChild("LemonSpin")
            if s then s:Destroy() end
        end
    end
end

-- Xray
local function toggleXray(b)
    if b then
        for _, v in pairs(ws:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(plr.Character) then
                xrayCache[v] = v.LocalTransparencyModifier
                v.LocalTransparencyModifier = 0.6
            end
        end
    else
        for part, trans in pairs(xrayCache) do
            if part and part.Parent then part.LocalTransparencyModifier = trans end
        end
        xrayCache = {}
    end
end

-----------------------------------
-- GUI TASARIMI (Küçülebilir)
-----------------------------------
local ScreenGui = Instance.new("ScreenGui", par)
ScreenGui.Name = guiName

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 320)
Main.Position = UDim2.new(0.05, 0, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local UICorner = Instance.new("UICorner", Main)

-- Küçültme Butonu
local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0, 5)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinBtn.TextColor3 = Color3.new(1, 1, 1)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 1.8, 0)
Container.ScrollBarThickness = 2

local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 5)

-- Arayüz Elemanları
local function createToggle(name, stateKey, callback)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        states[stateKey] = not states[stateKey]
        btn.Text = name .. (states[stateKey] and ": ON" or ": OFF")
        btn.BackgroundColor3 = states[stateKey] and Color3.fromRGB(200, 200, 0) or Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = states[stateKey] and Color3.new(0,0,0) or Color3.new(1,1,1)
        if callback then callback(states[stateKey]) end
    end)
end

local function createSlider(name, min, max, stateKey)
    local label = Instance.new("TextLabel", Container)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = name .. ": " .. states[stateKey]
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(0.8, 0.8, 0.8)

    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Text = "[ Değiştir ]"
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.new(1, 1, 1)
    
    btn.MouseButton1Click:Connect(function()
        local newVal = states[stateKey] + (max/10)
        if newVal > max then newVal = min end
        states[stateKey] = math.floor(newVal)
        label.Text = name .. ": " .. states[stateKey]
    end)
end

-- Menü İçeriği
createToggle("Speed Enable", "speedOn")
createSlider("Speed Multi", 16, 250, "speedVal")
createSlider("Jump Power", 50, 300, "jumpPower")
createSlider("Gravity", 0, 196, "gravity")
createToggle("Spinbot", "spinbot", toggleSpin)
createToggle("X-Ray", "xrayon", toggleXray)
createToggle("Anti-Ragdoll", "antirag")
createToggle("Infinite Jump", "infjump")

-- Küçültme Mantığı
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Container.Visible = not minimized
    Main:TweenSize(minimized and UDim2.new(0, 220, 0, 40) or UDim2.new(0, 220, 0, 320), "Out", "Quart", 0.3, true)
    MinBtn.Text = minimized and "+" or "-"
end)

-- Inf Jump
uis.JumpRequest:Connect(function()
    if states.infjump and plr.Character then
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
