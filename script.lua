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
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" then return nil end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- [[ AYARLAR ]] --
_G.Settings = {
    ESP = false,
    StealthSpeed = false, SpeedVal = 0.6,
    BatHitbox = false, BatSize = 40,
    LocalLag = false, -- SADECE SENİ LAGLANDIRIR
    LagAmount = 0.5,  -- LAG SÜRESİ (Saniye)
    GalaxyMode = false,
    GravityVal = 100,
    InfJump = true,
    AntiRagdoll = true
}

-- [[ ULTRA SLIM GUI ]] --
if Player.PlayerGui:FindFirstChild("LemonV50") then Player.PlayerGui.LemonV49:Destroy() end
local gui = Instance.new("ScreenGui", Player.PlayerGui); gui.Name = "LemonV50"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 350, 0, 260)
main.Position = UDim2.new(0.5, -175, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(5, 5, 5); main.Active = true; main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 4)
local stroke = Instance.new("UIStroke", main); stroke.Thickness = 1.5
RunService.RenderStepped:Connect(function() stroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)

-- KÜÇÜLTME
local mini = Instance.new("TextButton", main)
mini.Size = UDim2.new(0, 20, 0, 20); mini.Position = UDim2.new(1, -25, 0, 5)
mini.Text = "-"; mini.TextColor3 = Color3.new(1,1,1); mini.BackgroundTransparency = 1
local icon = Instance.new("TextButton", gui)
icon.Size = UDim2.new(0, 40, 0, 40); icon.Position = UDim2.new(1, -50, 0.5, 0); icon.Text = "🍋"; icon.Visible = false
mini.MouseButton1Click:Connect(function() main.Visible = false; icon.Visible = true end)
icon.MouseButton1Click:Connect(function() main.Visible = true; icon.Visible = false end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -40); scroll.Position = UDim2.new(0, 5, 0, 35)
scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0,0,0,450); scroll.ScrollBarThickness = 0
local left = Instance.new("Frame", scroll); left.Size = UDim2.new(0.48,0,1,0); left.BackgroundTransparency = 1
Instance.new("UIListLayout", left).Padding = UDim.new(0, 5)
local right = Instance.new("Frame", scroll); right.Size = UDim2.new(0.48,0,1,0); right.Position = UDim2.new(0.52,0,0,0); right.BackgroundTransparency = 1
Instance.new("UIListLayout", right).Padding = UDim.new(0, 5)

-- UI FONKSIYONLARI
local function AddToggle(p, l, t, k)
    local b = Instance.new("TextButton", p)
    b.Size = UDim2.new(1, 0, 0, 22); b.BackgroundColor3 = Color3.fromRGB(20,20,20)
    b.Text = "["..l.."] "..t; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 8; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        _G.Settings[k] = not _G.Settings[k]
        b.BackgroundColor3 = _G.Settings[k] and Color3.fromRGB(255,100,0) or Color3.fromRGB(20,20,20)
    end)
end

local function AddSlider(p, t, min, max, k)
    local f = Instance.new("Frame", p); f.Size = UDim2.new(1,0,0,30); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1,0,0,10); l.Text = t..": ".._G.Settings[k]
    l.TextColor3 = Color3.new(0.8,0.8,0.8); l.Font = "Gotham"; l.TextSize = 7; l.BackgroundTransparency = 1
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1,0,0,8); b.Position = UDim2.new(0,0,1,-10)
    b.BackgroundColor3 = Color3.new(0.1,0.1,0.1); b.Text = ""; Instance.new("UICorner", b)
    local fi = Instance.new("Frame", b); fi.Size = UDim2.new((_G.Settings[k]-min)/(max-min),0,1,0); fi.BackgroundColor3 = Color3.new(1,0.5,0); Instance.new("UICorner", fi)
    b.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local c; c = RunService.RenderStepped:Connect(function()
                local p_val = math.clamp((UIS:GetMouseLocation().X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                _G.Settings[k] = math.round((min + (max - min) * p_val) * 10) / 10
                l.Text = t..": ".._G.Settings[k]; fi.Size = UDim2.new(p_val,0,1,0)
            end)
            UIS.InputEnded:Once(function() c:Disconnect() end)
        end
    end)
end

-- BUTONLAR
AddToggle(left, "L", "BENI LAGLANDIR", "LocalLag")
AddSlider(left, "Lag Suresi", 0, 3, "LagAmount")
AddToggle(left, "N", "Stealth Speed", "StealthSpeed")
AddToggle(left, "A", "Galaxy Mode", "GalaxyMode")

AddToggle(right, "C", "God Hitbox", "BatHitbox")
AddSlider(right, "Gravity %", 0, 100, "GravityVal")
AddToggle(right, "S", "Anti-Ragdoll", "AntiRagdoll")
AddToggle(right, "J", "Inf Jump", "InfJump")

-- [[ PHANTOM LAG ENGINE ]] --
task.spawn(function()
    while true do
        task.wait()
        if _G.Settings.LocalLag then
            -- Bu ayar FPS düşürmeden paketleri geciktirir (Gelişmiş executor desteği gerekir)
            pcall(function()
                settings().Network.IncomingReplicationLag = _G.Settings.LagAmount
            end)
        else
            pcall(function()
                settings().Network.IncomingReplicationLag = 0
            end)
        end
    end
end)

-- ANA MOTORLAR
RunService.Stepped:Connect(function()
    local char = Player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        if _G.Settings.StealthSpeed and hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * _G.Settings.SpeedVal)
        end
        if _G.Settings.BatHitbox then
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

print("LEMON V50 - PHANTOM LAG AKTIF!")
