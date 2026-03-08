--[[
    rzgr1ks DUEL HUB - V71 (NO-NOCLIP & SMART AUTO-WALK)
    Features: Smart Pathfinding, Manual Checkpoint, Anti-Cheat Spoofer
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService") -- Akıllı yol bulma
local player = Players.LocalPlayer

-- 1. ANTI-CHEAT SPOOFER (Metatable Protection)
local mt = getrawmetatable(game); local oldIndex = mt.__index; setreadonly(mt, false)
mt.__index = newcclosure(function(t, k)
    if not checkcaller() then
        if k == "WalkSpeed" and t:IsA("Humanoid") then return 16 end
        if k == "JumpPower" and t:IsA("Humanoid") then return 50 end
    end
    return oldIndex(t, k)
end); setreadonly(mt, true)

-- 2. ANA PANEL (V71)
if game:GetService("CoreGui"):FindFirstChild("rzg_hub_v71") then game:GetService("CoreGui").rzg_hub_v71:Destroy() end
local sg = Instance.new("ScreenGui", game:GetService("CoreGui")); sg.Name = "rzg_hub_v71"
local Main = Instance.new("Frame", sg); Main.Size = UDim2.new(0, 310, 0, 560); Main.Position = UDim2.new(0.5, -155, 0.5, -280); Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Main.Active = true; Main.Draggable = true
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 3; Instance.new("UICorner", Main)
local Title = Instance.new("TextLabel", Main); Title.Size = UDim2.new(1, -40, 0, 35); Title.Position = UDim2.new(0, 15, 0, 0); Title.Text = "rzgr1ks DUEL HUB V71"; Title.BackgroundTransparency = 1; Title.Font = "GothamBold"; Title.TextSize = 14; Title.TextXAlignment = "Left"

-- 3. RGB SİSTEMİ (Okunaklı Beyaz Yazı + Animasyonlu Çerçeve)
local RGB_Objects = {}
spawn(function()
    while task.wait() do
        local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        Stroke.Color = color; Title.TextColor3 = color
        for _, obj in pairs(RGB_Objects) do
            if obj:IsA("TextButton") and (obj.Name == "Toggle_ON" or obj.Name == "CP_Btn") then 
                obj.TextColor3 = Color3.new(1, 1, 1)
                if obj:FindFirstChildOfClass("UIStroke") then obj:FindFirstChildOfClass("UIStroke").Color = color end
            elseif obj:IsA("Frame") and obj.Name == "SliderFill" then obj.BackgroundColor3 = color
            elseif obj:IsA("TextButton") and obj.Name == "MinimizedIcon" then 
                obj.BackgroundColor3 = color; if obj:FindFirstChildOfClass("UIStroke") then obj:FindFirstChildOfClass("UIStroke").Color = color end
            end
        end
    end
end)

-- 4. KÜÇÜLTME & AYARLAR
_G.Set = {Speed = 45, Jump = 50, Gravity = 196.2, HitboxSize = 25, Elev = 0, Hitbox = false, ESP = false, Plat = false, AntiRag = true, BypassSpeed = true, LagServer = false}
local savedPos = nil

-- UI YARDIMCILARI (TOGGLE)
local function QuickToggle(name, key, pos)
    local t = Instance.new("TextButton", Main); t.Size = UDim2.new(0, 140, 0, 32); t.Position = pos; t.BackgroundColor3 = Color3.fromRGB(20, 20, 20); t.Text = name..": OFF"; t.TextColor3 = Color3.new(1,1,1); t.Font = "Gotham"; t.TextSize = 8; Instance.new("UICorner", t); local ts = Instance.new("UIStroke", t); ts.Thickness = 2; ts.Color = Color3.fromRGB(50,50,50)
    t.MouseButton1Click:Connect(function()
        _G.Set[key] = not _G.Set[key]
        if _G.Set[key] then t.Text = name..": ON"; t.Name = "Toggle_ON"; table.insert(RGB_Objects, t) else t.Text = name..": OFF"; t.Name = "Toggle_OFF"; t.TextColor3 = Color3.new(1,1,1); ts.Color = Color3.fromRGB(50,50,50) for i,o in pairs(RGB_Objects) do if o==t then table.remove(RGB_Objects, i) end end end
    end)
end

-- 5. AKILLI YOL BULMA VE CHECKPOINT BUTONLARI
local function SpecialBtn(name, pos, func)
    local b = Instance.new("TextButton", Main); b.Name = "CP_Btn"; b.Size = UDim2.new(0, 140, 0, 35); b.Position = pos; b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 9; Instance.new("UICorner", b); local bs = Instance.new("UIStroke", b); bs.Thickness = 2; table.insert(RGB_Objects, b)
    b.MouseButton1Click:Connect(func)
end

SpecialBtn("SET CHECKPOINT", UDim2.new(0, 10, 0, 345), function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        savedPos = player.Character.HumanoidRootPart.Position
        print("Checkpoint Kaydedildi!")
    end
end)

SpecialBtn("WALK TO CHECKPOINT", UDim2.new(0, 160, 0, 345), function()
    if savedPos and player.Character and player.Character:FindFirstChild("Humanoid") then
        local char = player.Character
        local hum = char.Humanoid
        local path = PathfindingService:CreatePath({AgentCanJump = true})
        path:ComputeAsync(char.HumanoidRootPart.Position, savedPos)
        
        if path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            for _, waypoint in pairs(waypoints) do
                if waypoint.Action == Enum.PathWaypointAction.Jump then
                    hum.Jump = true
                end
                hum:MoveTo(waypoint.Position)
                hum.MoveToFinished:Wait()
            end
        else
            -- Yol bulunamazsa direkt MoveTo dene
            hum:MoveTo(savedPos)
        end
    end
end)

-- ÖZELLİKLER SIRALAMASI
QuickToggle("Stealth Speed", "BypassSpeed", UDim2.new(0, 10, 0, 45))
QuickToggle("Force Anti-Ragdoll", "AntiRag", UDim2.new(0, 160, 0, 45))
QuickToggle("Player ESP", "ESP", UDim2.new(0, 10, 0, 85))
QuickToggle("Hitbox Expander", "Hitbox", UDim2.new(0, 160, 0, 85))

-- 6. DUEL HUB MOTOR (NOCLIPSIZ HIZ VE ANTI-RAGDOLL)
RunService.Heartbeat:Connect(function()
    local char = player.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid")
    if not (hum and root) then return end
    
    -- Hız Bypass (CFrame yerine Velocity veya WalkSpeed kullanarak duvar içinden geçmeyi engeller)
    if _G.Set.BypassSpeed then
        hum.WalkSpeed = _G.Set.Speed
    end
    
    -- Anti-Ragdoll
    if _G.Set.AntiRag then
        if math.abs(root.Orientation.X) > 15 or math.abs(root.Orientation.Z) > 15 then
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(root.Rotation.Y), 0)
            root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        end
    end
end)
