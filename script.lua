--[[ 
    rzgr1ks DUEL SCRIPT - V98 (ENGLISH VERSION)
    - Fix: Anti-Die (Smooth Speed Bypass)
    - UI: English Translation
    - Customization: "rzgr1ks" brand
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. SETTINGS
_G.Data = {
    Speed = 25, 
    Jump = 55, 
    HB_Size = 25,
    HB_Enabled = false, 
    ESP_Enabled = false,
    Walking = false, 
    SelectedPoint = 1,
    Points = {nil, nil, nil, nil}
}

local PointColors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,0.6,0)}
local VisualParts = {nil, nil, nil, nil}

-- 2. MAIN PANEL
local gui = Instance.new("ScreenGui")
gui.Name = "rzgr1ks_GUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 240, 0, 300)
main.Position = UDim2.new(0.5, -120, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(15,15,20)
main.BorderSizePixel = 0
main.Parent = gui
main.Visible = true
Instance.new("UICorner",main).CornerRadius = UDim.new(0,12)
local Stroke = Instance.new("UIStroke", main); Stroke.Thickness = 2; Stroke.Color = Color3.fromRGB(255,140,0)

-- MINI TOGGLE BUTTON (rzgr1ks)
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 65, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0.2, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
toggleBtn.Text = "rzgr1ks"; toggleBtn.TextColor3 = Color3.fromRGB(255,140,0); toggleBtn.Font = "GothamBold"; toggleBtn.TextSize = 12
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", toggleBtn).Color = Color3.fromRGB(255,140,0)

toggleBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- DRAG SYSTEM (FULL FRAME)
local dragging, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,35); title.BackgroundTransparency = 1; title.Text = "rzgr1ks duel script"
title.Font = "GothamBold"; title.TextSize = 13; title.TextColor3 = Color3.fromRGB(255,140,0)

-- SCROLLING CONTAINER
local container = Instance.new("ScrollingFrame", main)
container.Size = UDim2.new(1,-10,1,-45); container.Position = UDim2.new(0,5,0,40)
container.BackgroundTransparency = 1; container.ScrollBarThickness = 0
container.CanvasSize = UDim2.new(0,0,0,500)
local layout = Instance.new("UIListLayout", container); layout.Padding = UDim.new(0,5)

-- 3. UI BUILDER FUNCTIONS
local function CreateToggle(text, callback)
    local b = Instance.new("TextButton", container)
    b.Size = UDim2.new(1,0,0,28); b.BackgroundColor3 = Color3.fromRGB(30,30,35); b.Text = text .. ": OFF"
    b.TextColor3 = Color3.new(1,1,1); b.Font = "Gotham"; b.TextSize = 11; Instance.new("UICorner",b)
    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s; b.Text = text .. ": " .. (s and "ON" or "OFF")
        b.TextColor3 = s and Color3.fromRGB(255,140,0) or Color3.new(1,1,1); callback(s)
    end)
end

local function CreateSlider(text, min, max, default, callback)
    local f = Instance.new("Frame", container); f.Size = UDim2.new(1,0,0,35); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = text .. ": " .. default; l.Size = UDim2.new(1,0,0,12); l.TextColor3 = Color3.new(1,1,1); l.Font = "Gotham"; l.TextSize = 10; l.BackgroundTransparency = 1
    local bar = Instance.new("Frame", f); bar.Size = UDim2.new(1,-10,0,4); bar.Position = UDim2.new(0,5,1,-8); bar.BackgroundColor3 = Color3.fromRGB(50,50,55)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255,140,0)
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local conn; conn = UIS.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                    local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(p, 0, 1, 0); local v = math.floor(min + (max - min) * p); l.Text = text .. ": " .. v; callback(v)
                end
            end)
            UIS.InputEnded:Once(function() conn:Disconnect() end)
        end
    end)
end

local function CreateBtn(text, color, callback)
    local b = Instance.new("TextButton", container)
    b.Size = UDim2.new(1,0,0,26); b.BackgroundColor3 = color; b.Text = text; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 10
    Instance.new("UICorner", b); b.MouseButton1Click:Connect(callback)
    return b
end

-- 4. ADD FEATURES (ENGLISH)
CreateToggle("Hitbox Expander", function(s) _G.Data.HB_Enabled = s end)
CreateSlider("HB Size", 2, 100, 25, function(v) _G.Data.HB_Size = v end)
CreateToggle("Player ESP", function(s) _G.Data.ESP_Enabled = s end)
CreateSlider("Speed Boost", 16, 60, 25, function(v) _G.Data.Speed = v end)
CreateSlider("Jump Power", 50, 150, 55, function(v) _G.Data.Jump = v end)

local slotBtn = CreateBtn("SELECTED: SLOT 1", Color3.fromRGB(60, 45, 0), function()
    _G.Data.SelectedPoint = (_G.Data.SelectedPoint % 4) + 1; slotBtn.Text = "SELECTED: SLOT " .. _G.Data.SelectedPoint
end)

CreateBtn("SAVE POSITION", Color3.fromRGB(0, 80, 150), function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        _G.Data.Points[_G.Data.SelectedPoint] = hrp.Position
        if VisualParts[_G.Data.SelectedPoint] then VisualParts[_G.Data.SelectedPoint]:Destroy() end
        local p = Instance.new("Part", workspace); p.Size = Vector3.new(1,1,1); p.Position = hrp.Position; p.Anchored = true; p.CanCollide = false
        p.Shape = "Ball"; p.Material = "Neon"; p.Color = PointColors[_G.Data.SelectedPoint]; p.Transparency = 0.5; VisualParts[_G.Data.SelectedPoint] = p
    end
end)

CreateBtn("START AUTO WALK", Color3.fromRGB(0, 100, 0), function()
    local target = _G.Data.Points[_G.Data.SelectedPoint]
    if not target or _G.Data.Walking then return end
    _G.Data.Walking = true
    task.spawn(function()
        while _G.Data.Walking and target and player.Character do
            local hum = player.Character:FindFirstChild("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp then hum:MoveTo(target); if (hrp.Position - target).Magnitude < 4 then break end end
            task.wait(0.1)
        end
        _G.Data.Walking = false
    end)
end)

CreateBtn("STOP AUTO WALK", Color3.fromRGB(120, 0, 0), function() _G.Data.Walking = false end)

-- 5. SMOOTH LOGIC LOOPS
RunService.Heartbeat:Connect(function(dt)
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum and hrp and not _G.Data.Walking and hum.MoveDirection.Magnitude > 0 then
        local extraSpeed = (_G.Data.Speed - 16)
        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * extraSpeed * dt)
    end
end)

UIS.JumpRequest:Connect(function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and not _G.Data.Walking then hrp.Velocity = Vector3.new(hrp.Velocity.X, _G.Data.Jump, hrp.Velocity.Z) end
end)

RunService.Stepped:Connect(function()
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
                if not v.Character:FindFirstChild("R_ESP") then
                    local h = Instance.new("Highlight", v.Character); h.Name = "R_ESP"
                    h.FillColor = Color3.new(1, 0.5, 0)
                end
            else
                if v.Character:FindFirstChild("R_ESP") then v.Character.R_ESP:Destroy() end
            end
        end
    end
end)
