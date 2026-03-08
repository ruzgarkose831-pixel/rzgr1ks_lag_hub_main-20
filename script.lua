--[[
    rzgr1ks DUEL HUB - V75 (TOTAL GOD-MODE & ANTI-DIE)
    - Tüm Anti-Ölüm yöntemleri eklendi.
    - Menü Butonu (Mobil) ve 'K' tuşu (PC) aktiftir.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. EN ÜST DÜZEY ANTI-DIE (METATABLE & STATE BYPASS)
local function ApplyGodMode(char)
    local hum = char:WaitForChild("Humanoid")
    
    -- Yöntem A: State Engelleme
    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    
    -- Yöntem B: Bağlantı Koparma (Scriptlerin senin öldüğünü anlamasını engeller)
    local diedConn = hum.Died:Connect(function() end)
    diedConn:Disconnect()

    -- Yöntem C: Fiziksel Koruma (Yerin dibine girmeyi engeller)
    spawn(function()
        while char and char.Parent do
            if char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position.Y < -500 then
                char.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0) -- Void'den kurtarma
            end
            task.wait(1)
        end
    end)
end

player.CharacterAdded:Connect(ApplyGodMode)
if player.Character then ApplyGodMode(player.Character) end

-- Metatable Spoofer (Canı 100 gösterir)
local mt = getrawmetatable(game); setreadonly(mt, false); local oldIndex = mt.__index
mt.__index = newcclosure(function(t, k)
    if not checkcaller() then
        if k == "Health" and t:IsA("Humanoid") then return 100 end
        if k == "WalkSpeed" and t:IsA("Humanoid") then return 16 end
    end
    return oldIndex(t, k)
end); setreadonly(mt, true)

-- 2. GUI KURULUMU
if game:GetService("CoreGui"):FindFirstChild("rzg_hub_v75") then game:GetService("CoreGui").rzg_hub_v75:Destroy() end
local sg = Instance.new("ScreenGui", game:GetService("CoreGui")); sg.Name = "rzg_hub_v75"
local Main = Instance.new("Frame", sg); Main.Size = UDim2.new(0, 310, 0, 520); Main.Position = UDim2.new(0.5, -155, 0.5, -240); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Main.Draggable = true
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 3; Instance.new("UICorner", Main)
local Title = Instance.new("TextLabel", Main); Title.Size = UDim2.new(1, 0, 0, 35); Title.Position = UDim2.new(0, 15, 0, 0); Title.Text = "rzgr1ks TOTAL GOD-MODE V75"; Title.BackgroundTransparency = 1; Title.Font = "GothamBold"; Title.TextSize = 12; Title.TextColor3 = Color3.new(1,1,1); Title.TextXAlignment = "Left"

-- KAPATMA BUTONU (Mobil)
local OpenBtn = Instance.new("TextButton", sg); OpenBtn.Size = UDim2.new(0, 50, 0, 50); OpenBtn.Position = UDim2.new(1, -60, 0, 10); OpenBtn.Text = "MENU"; OpenBtn.BackgroundColor3 = Color3.fromRGB(20,20,20); OpenBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", OpenBtn); OpenBtn.BackgroundTransparency = 0.5
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
UIS.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.K then Main.Visible = not Main.Visible end end)

-- RGB
local RGB_Objects = {Stroke}
spawn(function() while task.wait() do local c = Color3.fromHSV(tick() % 5 / 5, 1, 1) for _, o in pairs(RGB_Objects) do o.Color = c end end end)

-- 3. AYARLAR & MOTOR
_G.Set = _G.Set or {Speed = 45, Jump = 50, Gravity = 196.2, HitboxSize = 25, BypassSpeed = true}

local function CreateToggle(name, key, pos)
    local t = Instance.new("TextButton", Main); t.Size = UDim2.new(0, 140, 0, 32); t.Position = pos; t.BackgroundColor3 = Color3.fromRGB(30, 30, 30); t.Text = name..": OFF"; t.TextColor3 = Color3.new(1,1,1); t.Font = "Gotham"; t.TextSize = 8; Instance.new("UICorner", t)
    local ts = Instance.new("UIStroke", t); ts.Thickness = 2; ts.Color = Color3.fromRGB(60,60,60)
    t.MouseButton1Click:Connect(function()
        _G.Set[key] = not _G.Set[key]
        t.Text = name..": "..(_G.Set[key] and "ON" or "OFF")
        ts.Color = _G.Set[key] and Color3.new(1,1,1) or Color3.fromRGB(60,60,60)
    end)
end

local function CreateSlider(txt, min, max, def, key, y)
    local f = Instance.new("Frame", Main); f.Size = UDim2.new(0, 280, 0, 45); f.Position = UDim2.new(0, 15, 0, y); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = txt..": ".._G.Set[key]; l.Size = UDim2.new(1,0,0,15); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Font = "GothamBold"; l.TextSize = 9
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 0, 14); b.Position = UDim2.new(0,0,0,20); b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.Text = ""; Instance.new("UICorner", b)
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((_G.Set[key]-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", fill)
    b.MouseButton1Down:Connect(function()
        local m; m = UIS.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local p = math.clamp((inp.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0); local val = math.floor(min + (max - min) * p); l.Text = txt..": "..val; _G.Set[key] = val
            end
        end)
        UIS.InputEnded:Connect(function(u) if u.UserInputType == Enum.UserInputType.MouseButton1 or u.UserInputType == Enum.UserInputType.Touch then m:Disconnect() end end)
    end)
end

CreateToggle("Speed Bypass", "BypassSpeed", UDim2.new(0, 10, 0, 45))
CreateSlider("Walk Speed", 16, 300, 45, "Speed", 100)
CreateSlider("Jump Power", 50, 300, 50, "Jump", 155)

-- FINAL MOTOR
RunService.Heartbeat:Connect(function()
    local c = player.Character; local h = c and c:FindFirstChild("Humanoid")
    if not h then return end
    h.Health = 100
    if _G.Set.BypassSpeed then h.WalkSpeed = _G.Set.Speed end
end)
