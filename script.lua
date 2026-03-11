local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer

-- Önceki GUI Temizliği
local old = Player.PlayerGui:FindFirstChild("LemonV46")
if old then old:Destroy() end

_G.Settings = {
    ESP = false, ESPDist = 1000,
    SpeedBoost = false, SpeedVal = 70,
    JumpMod = false, JumpPower = 100,
    BatHitbox = false, BatSize = 40,
    SpinBot = false, SpinSpeed = 150,
    GalaxyMode = false, -- Sadece Görsel Efekt
    GravityVal = 100, -- Yerçekimi Bağımsız
    AntiRagdoll = false, InfJump = false,
    ServerLag = false, UnderArms = false, HiddenHead = false,
}

local gui = Instance.new("ScreenGui", Player.PlayerGui)
gui.Name = "LemonV46"
gui.ResetOnSpawn = false

-- ANA PANEL (Küçültülmüş Boyut: 400x320)
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 400, 0, 320)
main.Position = UDim2.new(0.5, -200, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

-- RGB KENARLIK
local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2
RunService.RenderStepped:Connect(function() stroke.Color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1) end)

-- KÜÇÜLTME BUTONU
local miniBtn = Instance.new("TextButton", main)
miniBtn.Size = UDim2.new(0, 25, 0, 25); miniBtn.Position = UDim2.new(1, -30, 0, 5)
miniBtn.Text = "-"; miniBtn.TextColor3 = Color3.new(1,1,1); miniBtn.BackgroundTransparency = 1; miniBtn.TextSize = 25

local openIcon = Instance.new("TextButton", gui)
openIcon.Size = UDim2.new(0, 45, 0, 45); openIcon.Position = UDim2.new(1, -55, 0.8, 0)
openIcon.BackgroundColor3 = Color3.fromRGB(15,15,15); openIcon.Text = "🍋"; openIcon.Visible = false
Instance.new("UICorner", openIcon).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", openIcon).Color = Color3.fromRGB(255, 180, 0)

miniBtn.MouseButton1Click:Connect(function() main.Visible = false; openIcon.Visible = true end)
openIcon.MouseButton1Click:Connect(function() main.Visible = true; openIcon.Visible = false end)

-- BAŞLIK
local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1, 0, 0, 35); header.Text = "  LEMÖN HUB V46 MINIMA"
header.TextColor3 = Color3.fromRGB(255, 180, 0); header.Font = "GothamBold"; header.TextSize = 12
header.BackgroundTransparency = 1; header.TextXAlignment = "Left"

-- İKİ SÜTUNLU SCROLL
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -45); scroll.Position = UDim2.new(0, 5, 0, 40)
scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 650); scroll.ScrollBarThickness = 0

local left = Instance.new("Frame", scroll)
left.Size = UDim2.new(0.48, 0, 1, 0); left.BackgroundTransparency = 1
local lList = Instance.new("UIListLayout", left); lList.Padding = UDim.new(0, 6)

local right = Instance.new("Frame", scroll)
right.Size = UDim2.new(0.48, 0, 1, 0); right.Position = UDim2.new(0.52, 0, 0, 0); right.BackgroundTransparency = 1
local rList = Instance.new("UIListLayout", right); rList.Padding = UDim.new(0, 6)

-- GALAXY MODE EFEKTİ (GRAFİK DEĞİŞTİRİCİ)
local function ToggleGalaxyEffect(state)
    local cc = Lighting:FindFirstChild("LemonCC") or Instance.new("ColorCorrectionEffect", Lighting)
    cc.Name = "LemonCC"
    if state then
        cc.Brightness = -0.1; cc.Contrast = 0.2; cc.Saturation = 0.5
        cc.TintColor = Color3.fromRGB(200, 180, 255)
        Lighting.Atmosphere.Density = 0.4
    else
        cc.Brightness = 0; cc.Contrast = 0; cc.Saturation = 0; cc.TintColor = Color3.new(1,1,1)
        Lighting.Atmosphere.Density = 0
    end
end

-- TOGGLE VE SLIDER MOTORLARI (AKTİF ÇALIŞAN VERSİYON)
local function AddToggle(parent, letter, text, key)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 30); f.BackgroundTransparency = 1
    
    local lBox = Instance.new("TextLabel", f)
    lBox.Size = UDim2.new(0, 16, 0, 16); lBox.Position = UDim2.new(0, 2, 0.5, -8)
    lBox.BackgroundColor3 = Color3.fromRGB(255, 180, 0); lBox.Text = letter; lBox.TextColor3 = Color3.new(0,0,0)
    lBox.Font = "GothamBold"; lBox.TextSize = 9; Instance.new("UICorner", lBox)
    
    local txt = Instance.new("TextLabel", f)
    txt.Size = UDim2.new(1, -55, 1, 0); txt.Position = UDim2.new(0, 22, 0, 0)
    txt.Text = text; txt.TextColor3 = Color3.new(1,1,1); txt.Font = "GothamBold"; txt.TextSize = 9; txt.TextXAlignment = "Left"; txt.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 30, 0, 16); btn.Position = UDim2.new(1, -32, 0.5, -8)
    btn.Text = ""; btn.BackgroundColor3 = _G.Settings[key] and Color3.new(1, 0.5, 0) or Color3.fromRGB(40,40,40)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _G.Settings[key] = not _G.Settings[key]
            btn.BackgroundColor3 = _G.Settings[key] and Color3.new(1, 0.5, 0) or Color3.fromRGB(40,40,40)
            if key == "GalaxyMode" then ToggleGalaxyEffect(_G.Settings[key]) end
        end
    end)
end

local function AddSlider(parent, text, min, max, key)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 35); f.BackgroundTransparency = 1
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 0, 12); l.Text = text .. ": " .. _G.Settings[key]
    l.TextColor3 = Color3.new(0.7,0.7,0.7); l.Font = "Gotham"; l.TextSize = 8; l.TextXAlignment = "Left"; l.BackgroundTransparency = 1
    
    local bar = Instance.new("TextButton", f)
    bar.Size = UDim2.new(1, -4, 0, 10); bar.Position = UDim2.new(0, 2, 1, -15)
    bar.BackgroundColor3 = Color3.fromRGB(30,30,30); bar.Text = ""; Instance.new("UICorner", bar)
    
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((_G.Settings[key]-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.new(1, 0.6, 0); Instance.new("UICorner", fill)
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local con; con = RunService.RenderStepped:Connect(function()
                local p = math.clamp((UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                _G.Settings[key] = math.floor(min + (max - min) * p)
                l.Text = text .. ": " .. _G.Settings[key]
                fill.Size = UDim2.new(p, 0, 1, 0)
            end)
            UIS.InputEnded:Once(function() con:Disconnect() end)
        end
    end)
end

-- ÖZELLİKLERİ DİZ
AddToggle(left, "G", "Player ESP", "ESP")
AddSlider(left, "Distance", 0, 2000, "ESPDist")
AddToggle(left, "A", "Galaxy Mode (Grafik)", "GalaxyMode")
AddToggle(left, "N", "Hız Hilesi", "SpeedBoost")
AddSlider(left, "Hız", 16, 500, "SpeedVal")
AddToggle(left, "L", "Zıplama", "JumpMod")
AddSlider(left, "Güç", 50, 400, "JumpPower")

AddToggle(right, "C", "God Hitbox", "BatHitbox")
AddSlider(right, "Range", 5, 200, "BatSize")
AddSlider(right, "Gravity %", 0, 100, "GravityVal") -- Yerçekimi bağımsız slider
AddToggle(right, "P", "Spin Bot", "SpinBot")
AddSlider(right, "Spin", 50, 1000, "SpinSpeed")
AddToggle(right, "S", "Server Lag", "ServerLag")
AddToggle(right, "R", "Anti-Ragdoll", "AntiRagdoll")
AddToggle(right, "J", "Inf Jump", "InfJump")

-- [[ CORE MOTORS ]] --
RunService.Heartbeat:Connect(function()
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = _G.Settings.SpeedBoost and _G.Settings.SpeedVal or 16
        hum.JumpPower = _G.Settings.JumpMod and _G.Settings.JumpPower or 50
        if _G.Settings.AntiRagdoll then
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end
    end
    workspace.Gravity = 196.2 * (_G.Settings.GravityVal / 100)
end)

RunService.RenderStepped:Connect(function()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local s = root:FindFirstChild("LSpin") or Instance.new("BodyAngularVelocity", root)
        s.Name = "LSpin"; s.MaxTorque = Vector3.new(0, math.huge, 0)
        s.AngularVelocity = _G.Settings.SpinBot and Vector3.new(0, _G.Settings.SpinSpeed, 0) or Vector3.new(0,0,0)
        
        if _G.Settings.BatHitbox and Player.Character:FindFirstChildOfClass("Tool") then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    if (root.Position - v.Character.HumanoidRootPart.Position).Magnitude <= _G.Settings.BatSize then
                        firetouchinterest(root, v.Character.HumanoidRootPart, 0)
                        firetouchinterest(root, v.Character.HumanoidRootPart, 1)
                    end
                end
            end
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if _G.Settings.InfJump and Player.Character then
        Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if _G.Settings.ServerLag then
            for i=1, 20 do
                local ev = game:FindFirstChildOfClass("RemoteEvent", true)
                if ev then pcall(function() ev:FireServer(string.rep("LAG", 100)) end) end
            end
        end
    end
end)

print("LEMON HUB V46 MINIMA - READY")
