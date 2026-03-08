local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. CLEANUP
if game:GetService("CoreGui"):FindFirstChild("rzgr1ks_V55") then game:GetService("CoreGui").rzgr1ks_V55:Destroy() end

-- 2. STABLE MAIN PANEL
local sg = Instance.new("ScreenGui", game:GetService("CoreGui")); sg.Name = "rzgr1ks_V55"
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 310, 0, 240); Main.Position = UDim2.new(0.5, -155, 0.5, -120)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Main.Draggable = true
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 2; Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30); Title.Text = "rzgr1ks V55 - ABSOLUTE FIX"; Title.BackgroundTransparency = 1
Title.Font = "GothamBold"; Title.TextSize = 11; Title.TextColor3 = Color3.new(1,1,1)

-- RGB
spawn(function()
    while task.wait() do Stroke.Color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1) end
end)

-- 3. MINIMIZE SYSTEM
local MiniBtn = Instance.new("TextButton", Main)
MiniBtn.Size = UDim2.new(0, 25, 0, 25); MiniBtn.Position = UDim2.new(1, -30, 0, 3); MiniBtn.Text = "X"; MiniBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0); MiniBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", MiniBtn)
local OpenBtn = Instance.new("TextButton", sg); OpenBtn.Size = UDim2.new(0, 45, 0, 45); OpenBtn.Position = UDim2.new(0, 10, 0.5, -22); OpenBtn.Visible = false; OpenBtn.Text = "OPEN"; OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); OpenBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", OpenBtn)
MiniBtn.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

-- 4. FIXED POSITION BUTTONS (NO SCROLLING - NO BUG)
_G.Set = {Speed = 70, Hitbox = false, HitboxSize = 25, ESP = false, Spin = false, Plat = false}

local function QuickToggle(name, key, pos)
    local t = Instance.new("TextButton", Main)
    t.Size = UDim2.new(0, 140, 0, 30); t.Position = pos; t.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    t.Text = name..": OFF"; t.TextColor3 = Color3.new(1,1,1); t.Font = "Gotham"; t.TextSize = 8; Instance.new("UICorner", t)
    t.MouseButton1Click:Connect(function()
        _G.Set[key] = not _G.Set[key]
        t.Text = _G.Set[key] and name..": ON" or name..": OFF"
        t.TextColor3 = _G.Set[key] and Color3.fromRGB(255, 140, 0) or Color3.new(1, 1, 1)
    end)
end

-- Butonları Yan Yana Diz (Manuel Pozisyon)
QuickToggle("Block Platform", "Plat", UDim2.new(0, 10, 0, 40))
QuickToggle("ESP Wallhack", "ESP", UDim2.new(0, 160, 0, 40))
QuickToggle("Hitbox Expand", "Hitbox", UDim2.new(0, 10, 0, 80))
QuickToggle("Torque Spin", "Spin", UDim2.new(0, 160, 0, 80))

-- 5. SLIDERS (MANUAL POSITION)
local function QuickSlider(txt, min, max, def, key, y)
    local f = Instance.new("Frame", Main); f.Size = UDim2.new(0, 290, 0, 35); f.Position = UDim2.new(0, 10, 0, y); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = txt..": "..def; l.Size = UDim2.new(1,0,0,15); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 8
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 0, 4); b.Position = UDim2.new(0,0,0,20); b.BackgroundColor3 = Color3.fromRGB(50,50,50); b.Text = ""
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((def-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    b.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local p = math.clamp((inp.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0); local val = math.floor(min + (max - min) * p)
                l.Text = txt..": "..val; _G.Set[key] = val
            end
        end)
        UIS.InputEnded:Connect(function(u) if u.UserInputType == Enum.UserInputType.MouseButton1 or u.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

QuickSlider("Walk Speed", 16, 500, 70, "Speed", 125)
QuickSlider("Hitbox Size", 5, 100, 25, "HitboxSize", 165)
QuickSlider("Elevation Height", 5, 200, 15, "Elev", 205)

-- 6. FINAL ENGINE
local AirBlock = Instance.new("Part", workspace); AirBlock.Size = Vector3.new(16, 1, 16); AirBlock.Transparency = 0.8; AirBlock.Anchored = true

RunService.Heartbeat:Connect(function()
    local char = player.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    char.Humanoid.WalkSpeed = _G.Set.Speed
    if _G.Set.Spin then root.RotVelocity = Vector3.new(0, 50, 0) end
    if _G.Set.Plat then AirBlock.CanCollide = true; AirBlock.CFrame = CFrame.new(root.Position.X, _G.Set.Elev or 15, root.Position.Z) else AirBlock.CanCollide = false; AirBlock.Position = Vector3.new(0,-1000,0) end
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = v.Character.HumanoidRootPart
            if _G.Set.Hitbox then hrp.Size = Vector3.new(_G.Set.HitboxSize, _G.Set.HitboxSize, _G.Set.HitboxSize); hrp.Transparency = 0.7; hrp.CanCollide = false
            else hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 0; hrp.CanCollide = true end
            local hl = v.Character:FindFirstChild("ESPHL") or Instance.new("Highlight", v.Character); hl.Name = "ESPHL"; hl.Enabled = _G.Set.ESP; hl.FillColor = Color3.fromRGB(255, 140, 0)
        end
    end
end)
