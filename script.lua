local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. ESKİLERİ TEMİZLE
if game:GetService("CoreGui"):FindFirstChild("rzgr1ks_V65") then game:GetService("CoreGui").rzgr1ks_V65:Destroy() end

-- 2. ANA PANEL VE YENİ BAŞLIK (rzgr1ks Duel Hub)
local sg = Instance.new("ScreenGui", game:GetService("CoreGui")); sg.Name = "rzgr1ks_V65"
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 310, 0, 480); Main.Position = UDim2.new(0.5, -155, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Main.Active = true; Main.Draggable = true
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 3; Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -40, 0, 35); Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "rzgr1ks DUEL HUB"; Title.BackgroundTransparency = 1
Title.Font = "GothamBold"; Title.TextSize = 14; Title.TextXAlignment = "Left"

-- FULL RGB ANIMASYON MOTORU
local RGB_Objects = {}
spawn(function()
    while task.wait() do
        local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        Stroke.Color = color
        Title.TextColor3 = color
        for _, obj in pairs(RGB_Objects) do
            if obj:IsA("TextButton") and obj.Name == "Toggle_ON" then 
                obj.TextColor3 = color 
                obj:FindFirstChildOfClass("UIStroke").Color = color
            elseif obj:IsA("Frame") and obj.Name == "SliderFill" then 
                obj.BackgroundColor3 = color
            elseif obj:IsA("TextButton") and obj.Name == "MinimizedIcon" then 
                obj.BackgroundColor3 = color 
                obj:FindFirstChildOfClass("UIStroke").Color = color 
            end
        end
    end
end)

-- 3. RGB KÜÇÜLTÜLMÜŞ KARE (Duel Hub Icon)
local MiniSquare = Instance.new("TextButton", sg); MiniSquare.Name = "MinimizedIcon"; MiniSquare.Size = UDim2.new(0, 75, 0, 75); MiniSquare.Position = UDim2.new(0, 30, 0.5, -37); MiniSquare.Text = "DUEL"; MiniSquare.TextColor3 = Color3.new(1, 1, 1); MiniSquare.Font = "GothamBold"; MiniSquare.Visible = false; MiniSquare.Active = true; MiniSquare.Draggable = true; Instance.new("UICorner", MiniSquare); Instance.new("UIStroke", MiniSquare).Thickness = 3; table.insert(RGB_Objects, MiniSquare)

local CloseBtn = Instance.new("TextButton", Main); CloseBtn.Size = UDim2.new(0, 25, 0, 25); CloseBtn.Position = UDim2.new(1, -30, 0, 5); CloseBtn.Text = "X"; CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0); CloseBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", CloseBtn)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false; MiniSquare.Visible = true end)
MiniSquare.MouseButton1Click:Connect(function() Main.Visible = true; MiniSquare.Visible = false end)

-- 4. AYARLAR
_G.Set = {Speed = 16, Jump = 50, Gravity = 196.2, HitboxSize = 25, Elev = 0, Hitbox = false, ESP = false, Plat = false, AntiRag = true, BypassSpeed = true}

-- UI YARDIMCILARI (TOGGLE & SLIDER)
local function QuickToggle(name, key, pos)
    local t = Instance.new("TextButton", Main); t.Size = UDim2.new(0, 140, 0, 32); t.Position = pos; t.BackgroundColor3 = Color3.fromRGB(20, 20, 20); t.Text = name..": OFF"; t.TextColor3 = Color3.new(1,1,1); t.Font = "Gotham"; t.TextSize = 8; Instance.new("UICorner", t); local ts = Instance.new("UIStroke", t); ts.Thickness = 2; ts.Color = Color3.fromRGB(50,50,50)
    t.MouseButton1Click:Connect(function()
        _G.Set[key] = not _G.Set[key]
        if _G.Set[key] then t.Text = name..": ON"; t.Name = "Toggle_ON"; table.insert(RGB_Objects, t) else t.Text = name..": OFF"; t.Name = "Toggle_OFF"; t.TextColor3 = Color3.new(1,1,1); ts.Color = Color3.fromRGB(50,50,50) for i,o in pairs(RGB_Objects) do if o==t then table.remove(RGB_Objects, i) end end end
    end)
end

local function BigSlider(txt, min, max, def, key, y)
    local f = Instance.new("Frame", Main); f.Size = UDim2.new(0, 280, 0, 45); f.Position = UDim2.new(0, 15, 0, y); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = txt..": "..def; l.Size = UDim2.new(1,0,0,15); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 9; l.Font = "GothamBold"
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 0, 14); b.Position = UDim2.new(0,0,0,20); b.BackgroundColor3 = Color3.fromRGB(35,35,35); b.Text = ""; Instance.new("UICorner", b)
    local fill = Instance.new("Frame", b); fill.Name = "SliderFill"; fill.Size = UDim2.new((def-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(0, 100, 255); Instance.new("UICorner", fill); table.insert(RGB_Objects, fill)
    b.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local p = math.clamp((inp.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0); local val = math.floor(min + (max - min) * p); l.Text = txt..": "..val; _G.Set[key] = val
            end
        end)
        UIS.InputEnded:Connect(function(u) if u.UserInputType == Enum.UserInputType.MouseButton1 or u.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

-- ÖZELLİKLER SIRALAMASI
QuickToggle("Stealth Speed", "BypassSpeed", UDim2.new(0, 10, 0, 45))
QuickToggle("Force Anti-Ragdoll", "AntiRag", UDim2.new(0, 160, 0, 45))
QuickToggle("Duel ESP", "ESP", UDim2.new(0, 10, 0, 85))
QuickToggle("Hitbox Expander", "Hitbox", UDim2.new(0, 160, 0, 85))
QuickToggle("Duel Platform", "Plat", UDim2.new(0, 10, 0, 385))

BigSlider("Walk Speed", 16, 400, 16, "Speed", 125)
BigSlider("Jump Power", 50, 400, 50, "Jump", 175)
BigSlider("Gravity Fix", 0, 196, 196, "Gravity", 225)
BigSlider("Duel Hitbox", 5, 100, 25, "HitboxSize", 275)
BigSlider("Platform Elevation", -150, 500, 0, "Elev", 325)

-- 5. DUEL HUB MOTOR (STABİLİZASYON)
local AirBlock = Instance.new("Part", workspace); AirBlock.Name = "Duel_Platform"; AirBlock.Size = Vector3.new(30, 1, 30); AirBlock.Transparency = 1; AirBlock.Anchored = true

RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid"); local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    -- ADVANCED ANTI-RAGDOLL (FORCE UPRIGHT)
    if _G.Set.AntiRag then
        local currentCF = root.CFrame
        if math.abs(root.Orientation.X) > 15 or math.abs(root.Orientation.Z) > 15 then
            root.CFrame = CFrame.new(currentCF.Position) * CFrame.Angles(0, math.rad(currentCF.Rotation.Y), 0)
            root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        end
        hum.PlatformStand = false
        if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end

    -- STEALTH SPEED (CFrame Bypass)
    if _G.Set.BypassSpeed and hum.MoveDirection.Magnitude > 0 then
        root.CFrame = root.CFrame + (hum.MoveDirection * (_G.Set.Speed / 45))
    elseif not _G.Set.BypassSpeed then
        hum.WalkSpeed = _G.Set.Speed
    end

    -- PLATFORM ENGINE
    if _G.Set.Plat then
        AirBlock.CanCollide = true
        AirBlock.CFrame = CFrame.new(root.Position.X, _G.Set.Elev, root.Position.Z)
    else
        AirBlock.CanCollide = false; AirBlock.Position = Vector3.new(0, -5000, 0)
    end
    
    workspace.Gravity = _G.Set.Gravity
end)
