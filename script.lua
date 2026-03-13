local plr = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local cg = game:GetService("CoreGui")
local players = game:GetService("Players")

local par = (gethui and gethui()) or cg
local guiName = "LemonHybrid_V10"

if par:FindFirstChild(guiName) then par[guiName]:Destroy() end

-- AYARLAR
local states = {
    speedOn = false, speedVal = 16,
    jumpPower = 50, gravity = 196.2,
    espOn = false, hitboxOn = false, hitboxVal = 2,
    infjump = false, antirag = false,
    spinbot = false, xrayon = false
}

-----------------------------------
-- YENİ HIZ YÖNTEMİ (Velocity Based)
-----------------------------------
rs.Heartbeat:Connect(function()
    if states.speedOn and plr.Character then
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.MoveDirection.Magnitude > 0 then
            -- AssemblyLinearVelocity kullanarak pürüzsüz hızlanma
            local targetVelocity = hum.MoveDirection * states.speedVal
            root.AssemblyLinearVelocity = Vector3.new(targetVelocity.X, root.AssemblyLinearVelocity.Y, targetVelocity.Z)
        end
    end
end)

-----------------------------------
-- YENİ XRAY YÖNTEMİ (Aggressive)
-----------------------------------
local function toggleXray(val)
    states.xrayon = val
    task.spawn(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(plr.Character) then
                if states.xrayon then
                    if not v:FindFirstChild("OriginalTrans") then
                        local ov = Instance.new("NumberValue", v)
                        ov.Name = "OriginalTrans"
                        ov.Value = v.Transparency
                    end
                    v.Transparency = 0.6
                else
                    if v:FindFirstChild("OriginalTrans") then
                        v.Transparency = v.OriginalTrans.Value
                    end
                end
            end
        end
    end)
end

-----------------------------------
-- DİĞER DÖNGÜLER
-----------------------------------
rs.RenderStepped:Connect(function()
    for _, p in pairs(players:GetPlayers()) do
        if p ~= plr and p.Character then
            -- Hitbox
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
            -- ESP
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
            if hum then hum.JumpPower = states.jumpPower hum.UseJumpPower = true end
            if states.spinbot and root then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(20), 0)
            end
            if states.antirag and hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end
        end
    end
end)

-----------------------------------
-- MOBİL VE SLIDER SİSTEMİ (FIXED)
-----------------------------------
local ScreenGui = Instance.new("ScreenGui", par)
ScreenGui.Name = guiName

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 280, 0, 380)
Main.Position = UDim2.new(0.5, -140, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -10, 1, -50)
Content.Position = UDim2.new(0, 5, 0, 45)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 2
local UIList = Instance.new("UIListLayout", Content)
UIList.Padding = UDim.new(0, 8)

-- Slider Fonksiyonu (Mobil Fix)
local function createSlider(name, min, max, default, stateKey)
    local frame = Instance.new("Frame", Content)
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 15)
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1

    local sliderBack = Instance.new("Frame", frame)
    sliderBack.Size = UDim2.new(1, -20, 0, 6)
    sliderBack.Position = UDim2.new(0, 10, 0, 25)
    sliderBack.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

    local sliderFill = Instance.new("Frame", sliderBack)
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 230, 0)
    
    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (pos * (max - min)))
        states[stateKey] = val
        label.Text = name .. ": " .. val
    end

    sliderBack.InputBegan:Connect(function(input)
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

local function createToggle(name, stateKey, callback)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        states[stateKey] = not states[stateKey]
        btn.Text = name .. (states[stateKey] and ": ON" or ": OFF")
        btn.BackgroundColor3 = states[stateKey] and Color3.fromRGB(255, 230, 0) or Color3.fromRGB(35, 35, 35)
        btn.TextColor3 = states[stateKey] and Color3.new(0,0,0) or Color3.new(1,1,1)
        if callback then callback(states[stateKey]) end
    end)
end

-- Menü Başlığı ve Kapatma
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "22S x LEMON V10"
Title.TextColor3 = Color3.new(1,1,0)
Title.BackgroundTransparency = 1

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(1, -40, 0, 2)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.BackgroundTransparency = 1

-- ÖZELLİKLERİ EKLE
createToggle("ESP Master", "espOn")
createToggle("X-Ray View", "xrayon", toggleXray)
createToggle("Hitbox Master", "hitboxOn")
createSlider("Hitbox Size", 2, 60, 2, "hitboxVal")
createToggle("Velocity Speed", "speedOn")
createSlider("Speed Value", 16, 400, 16, "speedVal")
createToggle("Spinbot", "spinbot")
createToggle("Anti-Ragdoll", "antirag")
createToggle("Infinite Jump", "infjump")
createSlider("Jump Power", 50, 500, 50, "jumpPower")
createSlider("Gravity", 0, 196, 196, "gravity")

-- Küçültme
local isMin = false
MinBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    Content.Visible = not isMin
    Main:TweenSize(isMin and UDim2.new(0, 280, 0, 40) or UDim2.new(0, 280, 0, 380), "Out", "Quart", 0.3, true)
    MinBtn.Text = isMin and "+" or "-"
end)

uis.JumpRequest:Connect(function()
    if states.infjump and plr.Character then
        local h = plr.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
