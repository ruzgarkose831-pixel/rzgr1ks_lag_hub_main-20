--[[
    @project: RZGR1KS DUEL V48 - FULL INTEGRATION
    @ui: Animated Modern GUI (User Provided)
    @logic: Fully Functional (Silent Aim, ESP, Movement, Combat)
]]--

if _G.RZGR1KS_V48_HYBRID then return end
_G.RZGR1KS_V48_HYBRID = true

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LOCAL_PLAYER = Players.LocalPlayer
local MOUSE = LOCAL_PLAYER:GetMouse()
local CAMERA = workspace.CurrentCamera

-- State store (Hem görsel hem fonksiyonel)
local VisualState = {
    ["Silent Aim"] = false,
    ["Hitbox Expander"] = false,
    ["Hitbox Radius"] = 25,
    ["Spinbot"] = false,
    ["Spin Speed"] = 100,
    ["Speed Bypass"] = false,
    ["Walk Speed"] = 100,
    ["Jump Power"] = 50,
    ["Gravity Control"] = 196,
    ["Material X-RAY"] = false,
    ["Name ESP"] = false,
    ["Box ESP"] = false,
    ["Tracer ESP"] = false,
    ["Anti Ragdoll"] = false
}

-- // 1. COMBAT LOGIC (SILENT AIM & HITBOX)
local function GetClosestPlayer()
    local target, dist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LOCAL_PLAYER and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, vis = CAMERA:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if mag < dist then
                    target = v.Character.HumanoidRootPart
                    dist = mag
                end
            end
        end
    end
    return target
end

-- Silent Aim Hook (Internet Standard)
local OldNC; OldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if not checkcaller() and VisualState["Silent Aim"] and (method == "Raycast" or method == "FindPartOnRayWithIgnoreList") then
        local T = GetClosestPlayer()
        if T then
            if method == "Raycast" then args[2] = (T.Position - args[1]).Unit * 1000
            else args[1] = Ray.new(args[1].Origin, (T.Position - args[1].Origin).Unit * 1000) end
            return OldNC(self, unpack(args))
        end
    end
    return OldNC(self, ...)
end)

-- // 2. VISUALS LOGIC (ESP)
local function CreateESP(p)
    local box = Drawing.new("Square")
    box.Thickness = 1; box.Filled = false; box.Color = Color3.new(1,0,0)
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1; tracer.Color = Color3.new(1,1,1)
    local name = Drawing.new("Text")
    name.Size = 14; name.Center = true; name.Outline = true; name.Color = Color3.new(1,1,1)

    local connection; connection = RunService.RenderStepped:Connect(function()
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local hrp = p.Character.HumanoidRootPart
            local pos, vis = CAMERA:WorldToViewportPoint(hrp.Position)
            
            box.Visible = VisualState["Box ESP"] and vis
            tracer.Visible = VisualState["Tracer ESP"] and vis
            name.Visible = VisualState["Name ESP"] and vis

            if vis then
                box.Size = Vector2.new(2000/pos.Z, 2500/pos.Z)
                box.Position = Vector2.new(pos.X - box.Size.X/2, pos.Y - box.Size.Y/2)
                tracer.From = Vector2.new(CAMERA.ViewportSize.X/2, CAMERA.ViewportSize.Y)
                tracer.To = Vector2.new(pos.X, pos.Y)
                name.Position = Vector2.new(pos.X, pos.Y - box.Size.Y/2 - 15)
                name.Text = p.Name
            end
        else
            box.Visible = false; tracer.Visible = false; name.Visible = false
            if not p.Parent then box:Remove(); tracer:Remove(); name:Remove(); connection:Disconnect() end
        end
    end)
end
for _, p in pairs(Players:GetPlayers()) do if p ~= LOCAL_PLAYER then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

-- // 3. CORE LOOP (SPEED, SPIN, HITBOX, XRAY)
RunService.Heartbeat:Connect(function()
    local char = LOCAL_PLAYER.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    -- Movement Features
    if root and hum then
        if VisualState["Spinbot"] then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(VisualState["Spin Speed"]), 0)
        end
        if VisualState["Speed Bypass"] and hum.MoveDirection.Magnitude > 0 then
            root.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X * VisualState["Walk Speed"], root.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * VisualState["Walk Speed"])
        end
        hum.JumpPower = VisualState["Jump Power"]
        workspace.Gravity = VisualState["Gravity Control"]
        if VisualState["Anti Ragdoll"] then hum.PlatformStand = false end
    end

    -- Hitbox & Xray
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LOCAL_PLAYER and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = p.Character.HumanoidRootPart
            if VisualState["Hitbox Expander"] then
                targetPart.Size = Vector3.new(VisualState["Hitbox Radius"], VisualState["Hitbox Radius"], VisualState["Hitbox Radius"])
                targetPart.Transparency = 0.7; targetPart.CanCollide = false
            else
                targetPart.Size = Vector3.new(2,2,1); targetPart.Transparency = 1
            end
        end
    end
    
    if VisualState["Material X-RAY"] then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(char) then v.LocalTransparencyModifier = 0.6 end
        end
    else
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
        end
    end
end)

-- // 4. GUI CONSTRUCTION (TASARIMIN ÜZERİNE FONKSİYON EKLEME)
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or game.CoreGui)
Screen.Name = "RZGR1KS_DUEL_PRO"
Screen.ResetOnSpawn = false

local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 360, 0, 52)
Main.Position = UDim2.new(0.5, -180, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -80, 1, 0); Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1; Title.Text = "RZGR1KS DUEL PRO"; Title.Font = "GothamBold"; Title.TextSize = 16; Title.TextColor3 = Color3.fromRGB(255, 80, 80); Title.TextXAlignment = "Left"

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0, 64, 0, 36); ToggleBtn.Position = UDim2.new(1, -70, 0, 8)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); ToggleBtn.Text = "+"; ToggleBtn.Font = "GothamBold"; ToggleBtn.TextSize = 20; ToggleBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -12, 0, 360); Scroll.Position = UDim2.new(0, 6, 0, 60)
Scroll.BackgroundTransparency = 1; Scroll.BorderSizePixel = 0; Scroll.Visible = false; Scroll.ScrollBarThickness = 3; Scroll.AutomaticCanvasSize = "Y"
local listLayout = Instance.new("UIListLayout", Scroll)
listLayout.Padding = UDim.new(0, 10); listLayout.HorizontalAlignment = "Center"

-- UI YARDIMCILARI (GELİŞMİŞ)
local function CreateSectionTitle(parent, text)
    local t = Instance.new("TextLabel", parent)
    t.Size = UDim2.new(1, -16, 0, 25); t.BackgroundTransparency = 1; t.Font = "GothamBold"; t.TextSize = 12; t.TextColor3 = Color3.fromRGB(255, 80, 80); t.Text = text
end

local function CreateToggle(parent, text)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -16, 0, 44); btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28); btn.Text = text .. " : OFF"; btn.Font = "GothamBold"; btn.TextSize = 13; btn.TextColor3 = Color3.new(0.9,0.9,0.9)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        VisualState[text] = not VisualState[text]
        btn.Text = text .. " : " .. (VisualState[text] and "ON" or "OFF")
        local color = VisualState[text] and Color3.fromRGB(200, 30, 30) or Color3.fromRGB(28,28,28)
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    end)
end

local function CreateSlider(parent, labelText, min, max, start)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -16, 0, 65); container.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, 0, 0, 20); label.BackgroundTransparency = 1; label.Font = "Gotham"; label.TextSize = 11; label.TextColor3 = Color3.new(0.8,0.8,0.8); label.Text = labelText..": "..start
    
    local bar = Instance.new("TextButton", container)
    bar.Size = UDim2.new(1, 0, 0, 14); bar.Position = UDim2.new(0, 0, 0, 25); bar.BackgroundColor3 = Color3.fromRGB(40,40,40); bar.Text = ""
    Instance.new("UICorner", bar)
    
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((start-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255,80,80); fill.BorderSizePixel = 0
    Instance.new("UICorner", fill)

    local function update(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (pos * (max - min)))
        VisualState[labelText] = val
        label.Text = labelText..": "..val
    end

    local dragging = false
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end end)
end

-- // GUI İÇERİĞİ OLUŞTURMA
CreateSectionTitle(Scroll, "COMBAT")
CreateToggle(Scroll, "Silent Aim")
CreateToggle(Scroll, "Hitbox Expander")
CreateSlider(Scroll, "Hitbox Radius", 2, 200, 25)
CreateToggle(Scroll, "Spinbot")
CreateSlider(Scroll, "Spin Speed", 0, 300, 100)

CreateSectionTitle(Scroll, "MOVEMENT")
CreateToggle(Scroll, "Speed Bypass")
CreateSlider(Scroll, "Walk Speed", 16, 800, 100)
CreateSlider(Scroll, "Jump Power", 50, 500, 50)
CreateSlider(Scroll, "Gravity Control", 0, 196, 196)

CreateSectionTitle(Scroll, "VISUALS")
CreateToggle(Scroll, "Material X-RAY")
CreateToggle(Scroll, "Name ESP")
CreateToggle(Scroll, "Box ESP")
CreateToggle(Scroll, "Tracer ESP")

CreateSectionTitle(Scroll, "MISC")
CreateToggle(Scroll, "Anti Ragdoll")

-- SOSYAL BUTONLAR
local discordBtn = Instance.new("TextButton", Scroll)
discordBtn.Size = UDim2.new(1, -16, 0, 44); discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242); discordBtn.Text = "Discord: rzgr1ks (Kopyala)"; discordBtn.TextColor3 = Color3.new(1,1,1); discordBtn.Font = "GothamBold"; Instance.new("UICorner", discordBtn)
discordBtn.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/XpbcvVdU"); discordBtn.Text = "Kopyalandı! ✅"; delay(1.5, function() discordBtn.Text = "Discord: rzgr1ks (Kopyala)" end) end)

-- AÇ/KAPAT ANİMASYONU
local opened = false
ToggleBtn.MouseButton1Click:Connect(function()
    opened = not opened
    Scroll.Visible = opened
    ToggleBtn.Text = opened and "x" or "+"
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = opened and UDim2.new(0, 360, 0, 450) or UDim2.new(0, 360, 0, 52)}):Play()
end)

print("RZGR1KS DUEL V48 LOADED SUCCESSFULLY")
