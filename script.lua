local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. CLEANUP OLD
local function cleanup()
    if game:GetService("CoreGui"):FindFirstChild("rzgr1ks_V52") then game:GetService("CoreGui").rzgr1ks_V52:Destroy() end
    if workspace:FindFirstChild("AirBlock_" .. player.Name) then workspace["AirBlock_" .. player.Name]:Destroy() end
end
cleanup()

-- 2. GRID UI DESIGN & MINIMIZE 
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "rzgr1ks_V52"

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 310, 0, 260) -- Hitbox slider için biraz uzatıldı
Main.Position = UDim2.new(0.5, -155, 0.5, -130)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -30, 0, 30); Title.Text = "  rzgr1ks V52 - ESP & HITBOX"
Title.BackgroundTransparency = 1; Title.Font = "GothamBold"; Title.TextSize = 10; Title.TextXAlignment = "Left"

-- RGB ANIMATION 
spawn(function()
    while task.wait() do
        local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        Stroke.Color = color; Title.TextColor3 = color
    end
end)

-- MINIMIZE SYSTEM 
local MiniBtn = Instance.new("TextButton", Main)
MiniBtn.Size = UDim2.new(0, 25, 0, 25); MiniBtn.Position = UDim2.new(1, -28, 0, 3)
MiniBtn.Text = "-"; MiniBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); MiniBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", MiniBtn)

local OpenBtn = Instance.new("TextButton", sg)
OpenBtn.Size = UDim2.new(0, 40, 0, 40); OpenBtn.Position = UDim2.new(0, 15, 0.5, -20)
OpenBtn.Visible = false; OpenBtn.Text = "R"; OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", OpenBtn); Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(255, 140, 0)

MiniBtn.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -40); Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 2.5, 0); Scroll.ScrollBarThickness = 0
local Grid = Instance.new("UIGridLayout", Scroll)
Grid.CellSize = UDim2.new(0, 145, 0, 30); Grid.Padding = UDim2.new(0, 5, 0, 5)

-- 3. COMPONENTS & SETTINGS
_G.Set = {Speed = 70, Elev = 15, Spin = false, Hitbox = false, HitboxSize = 25, ESP = false, AntiRag = true}

local function createToggle(name, key)
    local t = Instance.new("TextButton", Scroll)
    t.BackgroundColor3 = Color3.fromRGB(25, 25, 25); t.Text = name .. ": OFF"
    t.TextColor3 = Color3.new(1, 1, 1); t.Font = "Gotham"; t.TextSize = 8; Instance.new("UICorner", t)
    t.MouseButton1Click:Connect(function()
        _G.Set[key] = not _G.Set[key]
        t.Text = _G.Set[key] and name .. ": ON" or name .. ": OFF"
        t.TextColor3 = _G.Set[key] and Color3.fromRGB(255, 140, 0) or Color3.new(1, 1, 1)
    end)
end

local function createSlider(name, min, max, default, key)
    local f = Instance.new("Frame", Scroll); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = name..": "..default; l.Size = UDim2.new(1,0,0,12); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 7
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0, 130, 0, 3); b.Position = UDim2.new(0,8,0,20); b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.Text = ""
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255,140,0)
    b.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local p = math.clamp((inp.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0); local val = math.floor(min + (max - min) * p)
                l.Text = name..": "..val; _G.Set[key] = val
            end
        end)
        UIS.InputEnded:Connect(function(u) if u.UserInputType == Enum.UserInputType.MouseButton1 or u.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

-- 4. ESP SYSTEM (FIXED)
local function applyESP(plr)
    local bg = Instance.new("BillboardGui")
    bg.Name = "ESPGui_" .. plr.Name; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0, 200, 0, 50)
    local text = Instance.new("TextLabel", bg)
    text.Size = UDim2.new(1, 0, 1, 0); text.BackgroundTransparency = 1; text.Text = plr.Name
    text.TextColor3 = Color3.fromRGB(255, 140, 0); text.Font = "GothamBold"; text.TextSize = 10
    
    local hl = Instance.new("Highlight")
    hl.Name = "ESPHL_" .. plr.Name; hl.FillColor = Color3.fromRGB(255, 140, 0)
    hl.FillTransparency = 0.5; hl.OutlineColor = Color3.new(1, 1, 1)
    
    RunService.RenderStepped:Connect(function()
        if _G.Set.ESP and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("HumanoidRootPart") then
            if not bg.Parent then bg.Parent = game:GetService("CoreGui") end
            if not hl.Parent then hl.Parent = game:GetService("CoreGui") end
            
            bg.Adornee = plr.Character.Head; hl.Adornee = plr.Character
            bg.Enabled = true; hl.Enabled = true
            
            local dist = 0
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                dist = math.floor((player.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude)
            end
            text.Text = plr.Name .. " [" .. dist .. "m]"
        else
            bg.Enabled = false; hl.Enabled = false
        end
    end)
end

for _, v in pairs(Players:GetPlayers()) do if v ~= player then applyESP(v) end end
Players.PlayerAdded:Connect(function(v) applyESP(v) end)

-- 5. BUTTONS & SLIDERS (YAN YANA GRID)
createToggle("Block Platform", "Platform")
createToggle("ESP Wallhack", "ESP")
createToggle("Hitbox Expand", "Hitbox")
createToggle("Torque Spin", "Spin")
createToggle("Anti Ragdoll", "AntiRag")
createSlider("Walk Speed", 16, 500, 70, "Speed")
createSlider("Hitbox Size", 5, 100, 25, "HitboxSize") -- Hitbox boyutu geri geldi
createSlider("Elev Height", 5, 200, 15, "Elev")

-- 6. ENGINE (HITBOX FIX)
local AirBlock = Instance.new("Part")
AirBlock.Name = "AirBlock_" .. player.Name; AirBlock.Size = Vector3.new(16, 1, 16); AirBlock.Transparency = 0.8; AirBlock.Anchored = true; AirBlock.Parent = workspace

RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    hum.WalkSpeed = _G.Set.Speed
    if _G.Set.Spin then root.RotVelocity = Vector3.new(0, 50, 0) end
    
    -- HITBOX FIX: Artık devasa yapılabilir ve içinden geçilebilir (CanCollide = false)
    if _G.Set.Hitbox then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = v.Character.HumanoidRootPart
                hrp.Size = Vector3.new(_G.Set.HitboxSize, _G.Set.HitboxSize, _G.Set.HitboxSize)
                hrp.Transparency = 0.7
                hrp.CanCollide = false
            end
        end
    end

    if _G.Set.Platform then
        AirBlock.CanCollide = true; AirBlock.CFrame = CFrame.new(root.Position.X, _G.Set.Elev, root.Position.Z)
        if hum:GetState() == Enum.HumanoidStateType.Freefall then hum:ChangeState(Enum.HumanoidStateType.Running) end
    else
        AirBlock.CanCollide = false; AirBlock.Position = Vector3.new(0, -1000, 0)
    end
end)
