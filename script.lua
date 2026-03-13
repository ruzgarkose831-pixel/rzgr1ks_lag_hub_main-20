local plr = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local cg = game:GetService("CoreGui")
local players = game:GetService("Players")
local http = game:GetService("HttpService")

local par = (gethui and gethui()) or cg
local guiName = "LemonHybrid_V12"
local fileName = "LemonConfig.json"

if par:FindFirstChild(guiName) then par[guiName]:Destroy() end

-- VARSAYILAN AYARLAR
local states = {
    speedOn = false, speedVal = 16,
    jumpPower = 50, gravity = 196.2,
    espOn = false, hitboxOn = false, hitboxVal = 2,
    infjump = false, antirag = false,
    spinbot = false, xrayon = false
}

-----------------------------------
-- CONFIG SİSTEMİ (Kaydet/Yükle)
-----------------------------------
local function saveConfig()
    local data = http:JSONEncode(states)
    writefile(fileName, data)
    print("Ayarlar Kaydedildi!")
end

local function loadConfig()
    if isfile(fileName) then
        local data = http:JSONDecode(readfile(fileName))
        for i, v in pairs(data) do
            states[i] = v
        end
        print("Ayarlar Yüklendi!")
        -- Not: GUI elemanlarını güncellemek için menüyü yeniden başlatman gerekebilir 
        -- veya her eleman için update fonksiyonu çağrılmalıdır.
    end
end

-- Otomatik yükle
if isfile(fileName) then loadConfig() end

-----------------------------------
-- CORE LOGIC (Hiz, Hitbox, ESP...)
-----------------------------------
rs.Heartbeat:Connect(function()
    if states.speedOn and plr.Character then
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.MoveDirection.Magnitude > 0 then
            local targetVelocity = hum.MoveDirection * states.speedVal
            root.AssemblyLinearVelocity = Vector3.new(targetVelocity.X, root.AssemblyLinearVelocity.Y, targetVelocity.Z)
        end
    end
end)

rs.RenderStepped:Connect(function()
    for _, p in pairs(players:GetPlayers()) do
        if p ~= plr and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if states.hitboxOn then
                    hrp.Size = Vector3.new(states.hitboxVal, states.hitboxVal, states.hitboxVal)
                    hrp.Transparency = 0.7
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

            local xray = p.Character:FindFirstChild("LemonXray")
            if states.xrayon then
                if not xray then
                    xray = Instance.new("Highlight", p.Character)
                    xray.Name = "LemonXray"
                    xray.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    xray.FillColor = Color3.fromRGB(255, 0, 0)
                end
            elseif xray then xray:Destroy() end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        workspace.Gravity = states.gravity
        if plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = states.jumpPower hum.UseJumpPower = true end
            if states.spinbot then plr.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(25), 0) end
        end
    end
end)

-----------------------------------
-- GUI TASARIMI
-----------------------------------
local ScreenGui = Instance.new("ScreenGui", par)
ScreenGui.Name = guiName

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 280, 0, 420)
Main.Position = UDim2.new(0.5, -140, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.Draggable = true
Main.Active = true
Instance.new("UICorner", Main)

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -10, 1, -50)
Content.Position = UDim2.new(0, 5, 0, 45)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 2
local UIList = Instance.new("UIListLayout", Content)
UIList.Padding = UDim.new(0, 8)

-- Slider ve Toggle oluşturucuları (Mobil Uyumlu)
local function createSlider(name, min, max, default, stateKey)
    local frame = Instance.new("Frame", Content)
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 15)
    label.Text = name .. ": " .. states[stateKey] -- Kayıtlı değeri göster
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1

    local sliderBack = Instance.new("Frame", frame)
    sliderBack.Size = UDim2.new(1, -20, 0, 6)
    sliderBack.Position = UDim2.new(0, 10, 0, 25)
    sliderBack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local sliderFill = Instance.new("Frame", sliderBack)
    sliderFill.Size = UDim2.new((states[stateKey] - min) / (max - min), 0, 1, 0)
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true update(input) end
    end)
    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    uis.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
    end)
end

local function createToggle(name, stateKey)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = states[stateKey] and Color3.fromRGB(255, 230, 0) or Color3.fromRGB(30, 30, 30)
    btn.Text = name .. (states[stateKey] and ": ON" or ": OFF")
    btn.TextColor3 = states[stateKey] and Color3.new(0,0,0) or Color3.new(1,1,1)
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        states[stateKey] = not states[stateKey]
        btn.Text = name .. (states[stateKey] and ": ON" or ": OFF")
        btn.BackgroundColor3 = states[stateKey] and Color3.fromRGB(255, 230, 0) or Color3.fromRGB(30, 30, 30)
        btn.TextColor3 = states[stateKey] and Color3.new(0,0,0) or Color3.new(1,1,1)
    end)
end

-- BAŞLIK
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "22S x LEMON V12 (Config)"
Title.TextColor3 = Color3.new(1, 1, 0)
Title.BackgroundTransparency = 1

-- ÖZELLİKLER
createToggle("ESP Master", "espOn")
createToggle("Modern Xray", "xrayon")
createToggle("Hitbox Expander", "hitboxOn")
createSlider("Hitbox Size", 2, 60, 2, "hitboxVal")
createToggle("Velocity Speed", "speedOn")
createSlider("Speed Value", 16, 400, 16, "speedVal")
createToggle("Spinbot", "spinbot")
createToggle("Anti-Ragdoll", "antirag")
createToggle("Infinite Jump", "infjump")
createSlider("Jump Power", 50, 500, 50, "jumpPower")
createSlider("Gravity", 0, 196, 196, "gravity")

--- CONFIG BUTONLARI ---
local SaveBtn = Instance.new("TextButton", Content)
SaveBtn.Size = UDim2.new(1, -10, 0, 35)
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
SaveBtn.Text = "💾 SAVE CONFIG"
SaveBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", SaveBtn)
SaveBtn.MouseButton1Click:Connect(saveConfig)

local LoadBtn = Instance.new("TextButton", Content)
LoadBtn.Size = UDim2.new(1, -10, 0, 35)
LoadBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
LoadBtn.Text = "📂 LOAD CONFIG"
LoadBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", LoadBtn)
LoadBtn.MouseButton1Click:Connect(function()
    loadConfig()
    -- Basit bir reload mesajı
    LoadBtn.Text = "Yüklendi! (Menüyü Kapat/Aç)"
    task.wait(1)
    LoadBtn.Text = "📂 LOAD CONFIG"
end)

-- Menü Kapatma/Açma (GUI'yi silmeden gizler)
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(1, -40, 0, 2)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.BackgroundTransparency = 1

local isMin = false
MinBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    Content.Visible = not isMin
    Main:TweenSize(isMin and UDim2.new(0, 280, 0, 40) or UDim2.new(0, 280, 0, 420), "Out", "Quart", 0.3, true)
    MinBtn.Text = isMin and "+" or "-"
end)

uis.JumpRequest:Connect(function()
    if states.infjump and plr.Character then
        local h = plr.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
