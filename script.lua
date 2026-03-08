--[[ 
    LEMÖN PROJECT HUB - V94 (SLIM & COMPACT)
    - Menü boyutları küçültüldü (Daha az yer kaplar).
    - Auto-Walk & Bypass özellikleri optimize edildi.
    - Mobil uyumlu ve hızlı şablon.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Pathfinding = game:GetService("PathfindingService")
local player = Players.LocalPlayer

-- 1. AYARLAR & STATE
_G.Data = {
    Speed = 30,
    Jump = 60,
    HB_Size = 25,
    HB_Enabled = false,
    ESP_Enabled = false,
    Walking = false,
    SelectedPoint = 1,
    Points = {nil, nil, nil, nil}
}

local PointColors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,0.6,0)}
local VisualParts = {nil, nil, nil, nil}

-- 2. ANA PANEL (KÜÇÜLTÜLMÜŞ BOYUTLAR)
local gui = Instance.new("ScreenGui")
gui.Name = "LemonSlimGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 380) -- Boyut küçültüldü (Önceki 360x450 idi)
main.Position = UDim2.new(0.5, -150, 0.5, -190) -- Ortalaması ayarlandı
main.BackgroundColor3 = Color3.fromRGB(15,15,20)
main.Parent = gui
Instance.new("UICorner",main).CornerRadius = UDim.new(0,10)
local Stroke = Instance.new("UIStroke", main); Stroke.Thickness = 2; Stroke.Color = Color3.fromRGB(255,140,0)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "LEMON SLIM V94"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255,140,0)
title.Parent = main

-- KAYDIRILABİLİR KONTEYNER (KÜÇÜK PANEL İÇİN ÖNEMLİ)
local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1,-16,1,-55)
container.Position = UDim2.new(0,8,0,45)
container.BackgroundTransparency = 1
container.ScrollBarThickness = 2
container.CanvasSize = UDim2.new(0,0,0,600)
container.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,6)
layout.Parent = container

-- SÜRÜKLEME SİSTEMİ
local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = main.Position
    end
end)
title.InputEnded:Connect(function() dragging = false end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- 3. UI ELEMENTLERİ
local function CreateToggle(text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,36); frame.BackgroundColor3 = Color3.fromRGB(30,30,35); frame.Parent = container
    Instance.new("UICorner",frame)

    local label = Instance.new("TextLabel", frame)
    label.Text = text; label.Size = UDim2.new(1,-45,1,0); label.Position = UDim2.new(0,10,0,0)
    label.BackgroundTransparency = 1; label.TextColor3 = Color3.new(1,1,1); label.Font = "Gotham"; label.TextSize = 13; label.TextXAlignment = "Left"

    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(0,30,0,18); button.Position = UDim2.new(1,-40,0.5,-9); button.BackgroundColor3 = Color3.fromRGB(80,80,80); button.Text = ""
    Instance.new("UICorner",button).CornerRadius = UDim.new(1,0)

    local state = false
    button.MouseButton1Click:Connect(function()
        state = not state
        button.BackgroundColor3 = state and Color3.fromRGB(255,140,0) or Color3.fromRGB(80,80,80)
        callback(state)
    end)
end

local function CreateSlider(text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,50); frame.BackgroundTransparency = 1; frame.Parent = container

    local label = Instance.new("TextLabel", frame)
    label.Text = text .. " : " .. default; label.Size = UDim2.new(1,0,0,20); label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1); label.Font = "Gotham"; label.TextSize = 12; label.TextXAlignment = "Left"

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1,0,0,5); bar.Position = UDim2.new(0,0,1,-10); bar.BackgroundColor3 = Color3.fromRGB(50,50,55)
    Instance.new("UICorner",bar)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255,140,0)
    Instance.new("UICorner",fill)

    local function update(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (max - min) * pos)
        label.Text = text .. " : " .. val
        callback(val)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = UIS.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then update(i) end
            end)
            UIS.InputEnded:Once(function() connection:Disconnect() end)
        end
    end)
end

local function CreateButton(text, color, callback)
    local b = Instance.new("TextButton", container)
    b.Size = UDim2.new(1,0,0,32); b.BackgroundColor3 = color; b.Text = text; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 13
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
    return b
end

-- 4. ÖZELLİKLER
CreateToggle("Hitbox Expander", function(s) _G.Data.HB_Enabled = s end)
CreateSlider("Hitbox Size", 2, 100, 25, function(v) _G.Data.HB_Size = v end)
CreateToggle("Player ESP", function(s) _G.Data.ESP_Enabled = s end)
CreateSlider("Bypass Speed", 16, 100, 30, function(v) _G.Data.Speed = v end)
CreateSlider("Bypass Jump", 50, 150, 60, function(v) _G.Data.Jump = v end)

local slotBtn = CreateButton("SLOT: POINT 1", Color3.fromRGB(60, 45, 0), function()
    _G.Data.SelectedPoint = (_G.Data.SelectedPoint % 4) + 1
    slotBtn.Text = "SLOT: POINT " .. _G.Data.SelectedPoint
end)

CreateButton("SAVE POSITION", Color3.fromRGB(0, 80, 150), function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        _G.Data.Points[_G.Data.SelectedPoint] = hrp.Position
        if VisualParts[_G.Data.SelectedPoint] then VisualParts[_G.Data.SelectedPoint]:Destroy() end
        local p = Instance.new("Part", workspace); p.Size = Vector3.new(2,2,2); p.Position = hrp.Position; p.Anchored = true; p.CanCollide = false
        p.Shape = "Ball"; p.Material = "Neon"; p.Color = PointColors[_G.Data.SelectedPoint]; p.Transparency = 0.5; VisualParts[_G.Data.SelectedPoint] = p
    end
end)

CreateButton("AUTO WALK START", Color3.fromRGB(0, 100, 0), function()
    local target = _G.Data.Points[_G.Data.SelectedPoint]
    if not target or _G.Data.Walking then return end
    _G.Data.Walking = true
    spawn(function()
        while _G.Data.Walking and target and player.Character do
            local hum = player.Character:FindFirstChild("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                hum:MoveTo(target)
                if hrp.Velocity.Magnitude < 1 then hum.Jump = true end
                if (hrp.Position - target).Magnitude < 4 then break end
            end
            task.wait(0.1)
        end
        _G.Data.Walking = false
    end)
end)

CreateButton("STOP WALK", Color3.fromRGB(120, 0, 0), function() _G.Data.Walking = false end)

-- 5. LOOPS
RunService.RenderStepped:Connect(function(dt)
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and hrp and not _G.Data.Walking and hum.MoveDirection.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (_G.Data.Speed - 16) * dt)
    end
end)

UIS.JumpRequest:Connect(function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and not _G.Data.Walking then hrp.Velocity = Vector3.new(hrp.Velocity.X, _G.Data.Jump, hrp.Velocity.Z) end
end)

RunService.Heartbeat:Connect(function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local root = v.Character.HumanoidRootPart
            if _G.Data.HB_Enabled then
                root.Size = Vector3.new(_G.Data.HB_Size, _G.Data.HB_Size, _G.Data.HB_Size)
                root.Transparency = 0.7; root.CanCollide = false
            else
                root.Size = Vector3.new(2, 2, 1); root.Transparency = 1
            end
            if _G.Data.ESP_Enabled then
                if not v.Character:FindFirstChild("LemonESP") then
                    local h = Instance.new("Highlight", v.Character); h.Name = "LemonESP"
                    h.FillColor = Color3.new(1, 0.5, 0)
                end
            else
                if v.Character:FindFirstChild("LemonESP") then v.Character.LemonESP:Destroy() end
            end
        end
    end
end)
