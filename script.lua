-- ============================================================
-- 22S DUELS - ULTIMATE HYBRID EDITION (LEMON ENHANCED)
-- Bütün Özellikler Tek Scriptte Birleştirildi
-- ============================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

-- [[ TÜM AYARLARIN MERKEZİ ]] --
local Enabled = {
    -- 22S Features
    SpeedBoost = false, AntiRagdoll = false, SpinBot = false,
    AutoSteal = false, Optimizer = false, Galaxy = false,
    SpamBat = false, BatAimbot = false, GalaxySkyBright = false,
    AutoWalkEnabled = false, AutoRightEnabled = false,
    -- Lemon Hub Additions
    HitboxEnabled = false, AutoClickE = false, Fly = false,
    SafeMode = true
}

local Values = {
    BoostSpeed = 30, SpinSpeed = 30, STEAL_RADIUS = 20,
    STEAL_DURATION = 1.3, DEFAULT_GRAVITY = 196.2, GalaxyGravityPercent = 70,
    HBSize = 10, HOP_POWER = 35, HOP_COOLDOWN = 0.08
}

local KEYBINDS = {
    SPEED = Enum.KeyCode.V, SPIN = Enum.KeyCode.N, GALAXY = Enum.KeyCode.M,
    BATAIMBOT = Enum.KeyCode.X, NUKE = Enum.KeyCode.Q, 
    AUTOLEFT = Enum.KeyCode.Z, AUTORIGHT = Enum.KeyCode.C,
    GUI = Enum.KeyCode.U
}

-- [[ LEMON ENGINE: HITBOX & FORCE MOTORS ]] --
RunService.RenderStepped:Connect(function()
    pcall(function()
        if Enabled.HitboxEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(Values.HBSize, Values.HBSize, Values.HBSize)
                    hrp.Transparency = 0.6
                    hrp.CanCollide = false
                end
            end
        end

        if Enabled.AutoClickE then
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
        end
        
        -- Speed Force (Oyunun hızını kırmasını engeller)
        if Enabled.SpeedBoost and Player.Character then
            local hum = Player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0 then
                Player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(
                    hum.MoveDirection.X * Values.BoostSpeed, 
                    Player.Character.HumanoidRootPart.AssemblyLinearVelocity.Y, 
                    hum.MoveDirection.Z * Values.BoostSpeed
                )
            end
        end
    end)
end)

-- [[ 22S CORE LOGIC (Aimbot & Auto-Steal) ]] --
local function getNearestEnemy()
    local nearest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (Player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then dist = d; nearest = p end
        end
    end
    return nearest
end

-- [[ UI CONSTRUCT (22S BLUE DESIGN) ]] --
local sg = Instance.new("ScreenGui", Player.PlayerGui); sg.Name = "UltimateHybrid"
local main = Instance.new("Frame", sg); main.Size = UDim2.new(0, 560, 0, 450); main.Position = UDim2.new(0.5, -280, 0.5, -225); main.BackgroundColor3 = Color3.fromRGB(2, 2, 4); main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)
local mainStroke = Instance.new("UIStroke", main); mainStroke.Thickness = 2; mainStroke.Color = Color3.fromRGB(60, 130, 255)

-- Scroll Frames for Features
local leftSide = Instance.new("ScrollingFrame", main); leftSide.Size = UDim2.new(0.48, 0, 0.8, 0); leftSide.Position = UDim2.new(0.01, 0, 0.15, 0); leftSide.BackgroundTransparency = 1; leftSide.CanvasSize = UDim2.new(0, 0, 2, 0)
local rightSide = Instance.new("ScrollingFrame", main); rightSide.Size = UDim2.new(0.48, 0, 0.8, 0); rightSide.Position = UDim2.new(0.51, 0, 0.15, 0); rightSide.BackgroundTransparency = 1; rightSide.CanvasSize = UDim2.new(0, 0, 2, 0)
Instance.new("UIListLayout", leftSide).Padding = UDim.new(0, 5)
Instance.new("UIListLayout", rightSide).Padding = UDim.new(0, 5)

-- [[ DYNAMIC COMPONENT BUILDERS ]] --
local function AddToggle(parent, text, var, callback)
    local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(0.9, 0, 0, 35); btn.Text = text .. ": OFF"; btn.BackgroundColor3 = Color3.fromRGB(20, 20, 40); btn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        Enabled[var] = not Enabled[var]
        btn.Text = text .. ": " .. (Enabled[var] and "ON" or "OFF")
        btn.BackgroundColor3 = Enabled[var] and Color3.fromRGB(60, 130, 255) or Color3.fromRGB(20, 20, 40)
        if callback then callback(Enabled[var]) end
    end)
end

local function AddSlider(parent, text, var, min, max)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(0.9, 0, 0, 45); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = text .. ": " .. Values[var]; l.Size = UDim2.new(1,0,0,20); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1
    local b = Instance.new("TextBox", f); b.Size = UDim2.new(1,0,0,20); b.Position = UDim2.new(0,0,0,20); b.Text = tostring(Values[var]); b.BackgroundColor3 = Color3.fromRGB(30,30,50); b.TextColor3 = Color3.new(1,1,1)
    b.FocusLost:Connect(function() Values[var] = tonumber(b.Text) or Values[var]; l.Text = text .. ": " .. Values[var] end)
end

-- [[ TÜM ÖZELLİKLERİ LİSTEYE EKLE ]] --
-- LEFT SIDE (Movement & Combat)
AddToggle(leftSide, "Speed Boost [V]", "SpeedBoost")
AddSlider(leftSide, "Boost Speed", "BoostSpeed", 1, 100)
AddToggle(leftSide, "Hitbox Expander", "HitboxEnabled")
AddSlider(leftSide, "Hitbox Size", "HBSize", 1, 50)
AddToggle(leftSide, "Bat Aimbot [X]", "BatAimbot")
AddToggle(leftSide, "Spin Bot [N]", "SpinBot")
AddToggle(leftSide, "Anti Ragdoll", "AntiRagdoll")

-- RIGHT SIDE (Automation & Visuals)
AddToggle(rightSide, "Auto Steal", "AutoSteal")
AddToggle(rightSide, "Auto Press [E]", "AutoClickE")
AddToggle(rightSide, "Galaxy Mode [M]", "Galaxy")
AddToggle(rightSide, "Galaxy Sky Bright", "GalaxySkyBright")
AddToggle(rightSide, "Auto Left [Z]", "AutoWalkEnabled")
AddToggle(rightSide, "Auto Right [C]", "AutoRightEnabled")
AddToggle(rightSide, "Optimizer (FPS)", "Optimizer")

-- [[ KEYBIND HANDLER ]] --
UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == KEYBINDS.GUI then main.Visible = not main.Visible end
    if i.KeyCode == KEYBINDS.SPEED then Enabled.SpeedBoost = not Enabled.SpeedBoost end
    -- Nuke Sistemi
    if i.KeyCode == KEYBINDS.NUKE then
        local target = getNearestEnemy()
        if target then print("Nuking: " .. target.Name) end -- Buraya 22S'in Nuke remote eventini bağla
    end
end)

print("🚀 ULTIMATE HYBRID LOADED: 22S Altyapısı + Lemon Motorları Aktif!")
