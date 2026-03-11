local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer

-- [[ GUI TASARIM (KOMPAKT MASTER) ]] --
if Player.PlayerGui:FindFirstChild("rzgr1ks") then Player.PlayerGui.LemonV51:Destroy() end
local gui = Instance.new("ScreenGui", Player.PlayerGui); gui.Name = "LemonV51"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 420, 0, 350)
main.Position = UDim2.new(0.5, -210, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(8, 8, 8); main.Active = true; main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", main); stroke.Thickness = 2
RunService.RenderStepped:Connect(function() stroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)

-- Kapat/Aç
local mini = Instance.new("TextButton", main)
mini.Size = UDim2.new(0, 25, 0, 25); mini.Position = UDim2.new(1, -30, 0, 5)
mini.Text = "-"; mini.TextColor3 = Color3.new(1,1,1); mini.BackgroundTransparency = 1; mini.TextSize = 25
local icon = Instance.new("TextButton", gui)
icon.Size = UDim2.new(0, 50, 0, 50); icon.Position = UDim2.new(1, -60, 0.5, 0); icon.Text = "🍋"; icon.Visible = false
Instance.new("UICorner", icon).CornerRadius = UDim.new(1,0)
mini.MouseButton1Click:Connect(function() main.Visible = false; icon.Visible = true end)
icon.MouseButton1Click:Connect(function() main.Visible = true; icon.Visible = false end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -45); scroll.Position = UDim2.new(0, 5, 0, 40)
scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0,0,0,800); scroll.ScrollBarThickness = 2
local left = Instance.new("Frame", scroll); left.Size = UDim2.new(0.48,0,1,0); left.BackgroundTransparency = 1
Instance.new("UIListLayout", left).Padding = UDim.new(0, 6)
local right = Instance.new("Frame", scroll); right.Size = UDim2.new(0.48,0,1,0); right.Position = UDim2.new(0.52,0,0,0); right.BackgroundTransparency = 1
Instance.new("UIListLayout", right).Padding = UDim.new(0, 6)

-- FONKSIYONLAR
local function AddToggle(p, t, k)
    local b = Instance.new("TextButton", p)
    b.Size = UDim2.new(1, 0, 0, 28); b.BackgroundColor3 = Color3.fromRGB(25,25,25)
    b.Text = t; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 9; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        _G.Settings[k] = not _G.Settings[k]
        b.BackgroundColor3 = _G.Settings[k] and Color3.fromRGB(255,140,0) or Color3.fromRGB(25,25,25)
    end)
end

local function AddSlider(p, t, min, max, k, dec)
    local f = Instance.new("Frame", p); f.Size = UDim2.new(1,0,0,35); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1,0,0,12); l.Text = t..": ".._G.Settings[k]
    l.TextColor3 = Color3.new(0.8,0.8,0.8); l.Font = "Gotham"; l.TextSize = 8; l.BackgroundTransparency = 1
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1,0,0,10); b.Position = UDim2.new(0,0,1,-12)
    b.BackgroundColor3 = Color3.new(0.1,0.1,0.1); b.Text = ""; Instance.new("UICorner", b)
    local fi = Instance.new("Frame", b); fi.Size = UDim2.new((_G.Settings[k]-min)/(max-min),0,1,0); fi.BackgroundColor3 = Color3.new(1,0.5,0); Instance.new("UICorner", fi)
    b.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local c; c = RunService.RenderStepped:Connect(function()
                local pv = math.clamp((UIS:GetMouseLocation().X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                local val = min + (max - min) * pv
                _G.Settings[k] = dec and math.round(val*10)/10 or math.floor(val)
                l.Text = t..": ".._G.Settings[k]; fi.Size = UDim2.new(pv,0,1,0)
            end)
            UIS.InputEnded:Once(function() c:Disconnect() end)
        end
    end)
end

-- [[ BUTONLARI DIZ ]] --
-- SOL SÜTUN
AddToggle(left, "Player ESP", "ESP")
AddSlider(left, "ESP Mesafe", 0, 5000, "ESPDist")
AddToggle(left, "Hiz Boost", "SpeedBoost")
AddSlider(left, "Hiz Degeri", 16, 300, "SpeedVal")
AddToggle(left, "Stealth Speed", "StealthSpeed")
AddSlider(left, "S-Hiz Gucu", 0, 2, "S_SpeedVal", true)
AddToggle(left, "Ziplama Mod", "JumpMod")
AddSlider(left, "Ziplama Gucu", 50, 400, "JumpPower")
AddToggle(left, "Infinite Jump", "InfJump")

-- SAĞ SÜTUN
AddToggle(right, "SERVER NUKE (LAG)", "ServerNuke")
AddToggle(right, "PART SPAM (PHYSICS)", "PartSpam")
AddToggle(right, "FAKE LAG (LOCAL)", "LocalLag")
AddSlider(right, "Lag Suresi", 0, 3, "LagAmount", true)
AddToggle(right, "God Hitbox", "BatHitbox")
AddSlider(right, "Reach Boyutu", 5, 200, "BatSize")
AddToggle(right, "Spin Bot", "SpinBot")
AddSlider(right, "Gravity %", 0, 100, "GravityVal")
AddToggle(right, "Galaxy Mode", "GalaxyMode")
AddToggle(right, "Anti-Ragdoll", "AntiRagdoll")

-- [[ ANA MOTORLAR (V51 CORE) ]] --

-- 1. SERVER OVERLOAD & LAG
task.spawn(function()
    while task.wait(0.05) do
        if _G.Settings.ServerNuke then
            for i=1, 30 do
                local r = game:FindFirstChildOfClass("RemoteEvent", true)
                if r then pcall(function() r:FireServer({[string.rep("L",100)]=string.rep("G",100)}, tick()) end) end
            end
        end
        if _G.Settings.LocalLag then
            pcall(function() settings().Network.IncomingReplicationLag = _G.Settings.LagAmount end)
        else
            pcall(function() settings().Network.IncomingReplicationLag = 0 end)
        end
    end
end)

-- 2. PHYSICS & PART SPAM
task.spawn(function()
    while task.wait(0.2) do
        if _G.Settings.PartSpam and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local p = Instance.new("Part", workspace)
            p.Size = Vector3.new(20,20,20); p.CFrame = Player.Character.HumanoidRootPart.CFrame; p.Transparency = 1; p.CanCollide = false
            for _, v in pairs(Players:GetPlayers()) do
                if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    firetouchinterest(p, v.Character.HumanoidRootPart, 0)
                    firetouchinterest(p, v.Character.HumanoidRootPart, 1)
                end
            end
            task.wait(0.1); p:Destroy()
        end
    end
end)

-- 3. KARAKTER MOTORU (SPEED, JUMP, HITBOX, SPIN)
RunService.Stepped:Connect(function()
    local char = Player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        -- Normal Mods
        hum.WalkSpeed = _G.Settings.SpeedBoost and _G.Settings.SpeedVal or 16
        hum.JumpPower = _G.Settings.JumpMod and _G.Settings.JumpPower or 50
        if _G.Settings.AntiRagdoll then hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end
        
        -- Stealth Speed
        if _G.Settings.StealthSpeed and hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * _G.Settings.S_SpeedVal)
        end
        
        -- Spin Bot
        local s = hrp:FindFirstChild("LSpin") or Instance.new("BodyAngularVelocity", hrp)
        s.Name = "LSpin"; s.MaxTorque = Vector3.new(0, math.huge, 0)
        s.AngularVelocity = _G.Settings.SpinBot and Vector3.new(0, _G.Settings.SpinSpeed, 0) or Vector3.new(0,0,0)
        
        -- Hitbox
        if _G.Settings.BatHitbox and char:FindFirstChildOfClass("Tool") then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    if (hrp.Position - v.Character.HumanoidRootPart.Position).Magnitude <= _G.Settings.BatSize then
                        firetouchinterest(hrp, v.Character.HumanoidRootPart, 0)
                        firetouchinterest(hrp, v.Character.HumanoidRootPart, 1)
                    end
                end
            end
        end
    end
    workspace.Gravity = 196.2 * (_G.Settings.GravityVal / 100)
end)

-- 4. GALAXY & WORLD
RunService.RenderStepped:Connect(function()
    if _G.Settings.GalaxyMode then
        if not Lighting:FindFirstChild("LemonSky") then
            local sk = Instance.new("Sky", Lighting); sk.Name = "LemonSky"
            sk.SkyboxBk = "rbxassetid://159454299"; sk.SkyboxDn = "rbxassetid://159454296"
            sk.SkyboxFt = "rbxassetid://159454293"; sk.SkyboxLf = "rbxassetid://159454286"
            sk.SkyboxRt = "rbxassetid://159454288"; sk.SkyboxUp = "rbxassetid://159454290"
        end
        Lighting.ClockTime = 0
    else
        if Lighting:FindFirstChild("LemonSky") then Lighting.LemonSky:Destroy() end
        Lighting.ClockTime = 14
    end
end)

UIS.JumpRequest:Connect(function()
    if _G.Settings.InfJump and Player.Character then
        Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

print("V51 ULTIMATE GALAXY MASTER LOADED - ALL FEATURES RESTORED!")
