local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer

-- [[ GALAXY STEALTH BYPASS ]] --
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    -- Anti-Kick & Anti-Report Bypass
    if method == "Kick" or method == "kick" then return nil end
    if method == "FireServer" then
        local remoteName = tostring(self):lower()
        -- Eğer event adı ban/kick/cheat içeriyorsa engelle
        if remoteName:find("ban") or remoteName:find("kick") or remoteName:find("log") or remoteName:find("check") then
            warn("Anti-Cheat paketi engellendi: " .. remoteName)
            return nil
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- [[ AYARLAR ]] --
_G.Settings = {
    ESP = false, ESPDist = 1000,
    StealthSpeed = false, SpeedVal = 0.5, -- CFrame hızı (0.1 - 2.0 arası)
    StealthJump = false, JumpVal = 10,
    BatHitbox = false, BatSize = 40,
    SpinBot = false, SpinSpeed = 150,
    GalaxyMode = false,
    GravityVal = 100,
    AntiRagdoll = false,
    ServerLag = false
}

-- [[ ULTRA KOMPAKT GUI ]] --
if Player.PlayerGui:FindFirstChild("LemonV48") then Player.PlayerGui.LemonV48:Destroy() end
local gui = Instance.new("ScreenGui", Player.PlayerGui); gui.Name = "LemonV48"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 380, 0, 300)
main.Position = UDim2.new(0.5, -190, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
main.BorderSizePixel = 0; main.Active = true; main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6)
local stroke = Instance.new("UIStroke", main); stroke.Thickness = 2
RunService.RenderStepped:Connect(function() stroke.Color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1) end)

-- MINIMIZE
local mini = Instance.new("TextButton", main)
mini.Size = UDim2.new(0, 20, 0, 20); mini.Position = UDim2.new(1, -25, 0, 5)
mini.Text = "-"; mini.TextColor3 = Color3.new(1,1,1); mini.BackgroundTransparency = 1; mini.TextSize = 20

local icon = Instance.new("TextButton", gui)
icon.Size = UDim2.new(0, 40, 0, 40); icon.Position = UDim2.new(1, -50, 0.8, 0)
icon.BackgroundColor3 = Color3.fromRGB(10,10,10); icon.Text = "🍋"; icon.Visible = false; Instance.new("UICorner", icon).CornerRadius = UDim.new(1,0)

mini.MouseButton1Click:Connect(function() main.Visible = false; icon.Visible = true end)
icon.MouseButton1Click:Connect(function() main.Visible = true; icon.Visible = false end)

-- KAYDIRMA ALANI
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -40); scroll.Position = UDim2.new(0, 5, 0, 35)
scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0,0,0,550); scroll.ScrollBarThickness = 0
local left = Instance.new("Frame", scroll); left.Size = UDim2.new(0.48,0,1,0); left.BackgroundTransparency = 1
Instance.new("UIListLayout", left).Padding = UDim.new(0, 5)
local right = Instance.new("Frame", scroll); right.Size = UDim2.new(0.48,0,1,0); right.Position = UDim2.new(0.52,0,0,0); right.BackgroundTransparency = 1
Instance.new("UIListLayout", right).Padding = UDim.new(0, 5)

-- [[ GALAXY MODE (SKYBOX) ]] --
local function ApplyGalaxy(s)
    if s then
        local sk = Instance.new("Sky", Lighting); sk.Name = "LemonSky"
        sk.SkyboxBk = "rbxassetid://159454299"; sk.SkyboxDn = "rbxassetid://159454296"
        sk.SkyboxFt = "rbxassetid://159454293"; sk.SkyboxLf = "rbxassetid://159454286"
        sk.SkyboxRt = "rbxassetid://159454288"; sk.SkyboxUp = "rbxassetid://159454290"
        Lighting.ClockTime = 0
    elseif Lighting:FindFirstChild("LemonSky") then
        Lighting.LemonSky:Destroy(); Lighting.ClockTime = 14
    end
end

-- UI EKLEME FONKSIYONLARI
local function AddToggle(p, l, t, k)
    local b = Instance.new("TextButton", p)
    b.Size = UDim2.new(1, 0, 0, 26); b.BackgroundColor3 = Color3.fromRGB(20,20,20)
    b.Text = "["..l.."] "..t; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 8; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        _G.Settings[k] = not _G.Settings[k]
        b.BackgroundColor3 = _G.Settings[k] and Color3.fromRGB(255,140,0) or Color3.fromRGB(20,20,20)
        if k == "GalaxyMode" then ApplyGalaxy(_G.Settings[k]) end
    end)
end

local function AddSlider(p, t, min, max, k, step)
    local f = Instance.new("Frame", p); f.Size = UDim2.new(1,0,0,32); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1,0,0,10); l.Text = t..": ".._G.Settings[k]
    l.TextColor3 = Color3.new(0.8,0.8,0.8); l.Font = "Gotham"; l.TextSize = 7; l.BackgroundTransparency = 1
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1,0,0,8); b.Position = UDim2.new(0,0,1,-10)
    b.BackgroundColor3 = Color3.new(0.1,0.1,0.1); b.Text = ""; Instance.new("UICorner", b)
    local fi = Instance.new("Frame", b); fi.Size = UDim2.new((_G.Settings[k]-min)/(max-min),0,1,0); fi.BackgroundColor3 = Color3.new(1,0.5,0); Instance.new("UICorner", fi)
    b.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local c; c = RunService.RenderStepped:Connect(function()
                local p = math.clamp((UIS:GetMouseLocation().X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                local val = min + (max - min) * p
                _G.Settings[k] = step and math.floor(val/step)*step or math.floor(val)
                l.Text = t..": ".._G.Settings[k]; fi.Size = UDim2.new(p,0,1,0)
            end)
            UIS.InputEnded:Once(function() c:Disconnect() end)
        end
    end)
end

-- BUTONLARI DIZ
AddToggle(left, "G", "Player ESP", "ESP")
AddToggle(left, "A", "Galaxy Mode", "GalaxyMode")
AddToggle(left, "N", "Stealth Speed", "StealthSpeed")
AddSlider(left, "Hız Gücü", 0, 2, "SpeedVal", 0.1)
AddToggle(left, "L", "Stealth Jump", "StealthJump")
AddSlider(left, "Zıplama Gücü", 0, 50, "JumpVal")

AddToggle(right, "C", "God Hitbox", "BatHitbox")
AddSlider(right, "Reach", 5, 200, "BatSize")
AddSlider(right, "Gravity %", 0, 100, "GravityVal")
AddToggle(right, "S", "FIX LAG SERVER", "ServerLag")
AddToggle(right, "P", "Spin Bot", "SpinBot")
AddToggle(right, "R", "Anti-Ragdoll", "AntiRagdoll")

-- [[ STEALTH ENGINE ]] --
RunService.Stepped:Connect(function()
    local char = Player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hrp and hum then
        -- CFRAME SPEED (WalkSpeed Değişmeden Hızlı Gitme)
        if _G.Settings.StealthSpeed and hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * _G.Settings.SpeedVal)
        end
        
        -- STEALTH JUMP
        if _G.Settings.StealthJump and UIS:IsKeyDown(Enum.KeyCode.Space) then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, _G.Settings.JumpVal, hrp.Velocity.Z)
        end
        
        -- HITBOX
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

-- SERVER LAG (Daha Stabil Paketleme)
task.spawn(function()
    while task.wait(0.15) do
        if _G.Settings.ServerLag then
            for i=1, 15 do
                local r = game:FindFirstChildOfClass("RemoteEvent", true)
                if r then pcall(function() r:FireServer("\255\255\255", tick()) end) end
            end
        end
    end
end)

print("STEALTH GALAXY V48 - BYPASS AKTIF!")
