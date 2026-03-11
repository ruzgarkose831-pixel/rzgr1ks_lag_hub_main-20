local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ MASTER SETTINGS ]] --
_G.Settings = {
    Aimbot = false, SemiTP = false, AutoSteal = false, AutoClickE = false,
    AutoWalk = false, Points = {nil, nil, nil, nil}, CurrentPoint = 1,
    AntiRagdoll = false, WalkSpeed = 16, JumpPower = 50, Gravity = 196.2,
    HBExpander = false, HBSize = 2, GalaxyMode = false, EscapeSpeed = 30
}

-- [[ CORE ENGINES ]] --

-- 1. Hitbox Expander & Physics
task.spawn(function()
    while task.wait(0.5) do
        if _G.Settings.HBExpander then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(_G.Settings.HBSize, _G.Settings.HBSize, _G.Settings.HBSize)
                    hrp.Transparency = 0.7; hrp.Color = Color3.new(1,0,0); hrp.CanCollide = false
                end
            end
        end
        workspace.Gravity = _G.Settings.Gravity
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = _G.Settings.WalkSpeed
            Player.Character.Humanoid.JumpPower = _G.Settings.JumpPower
        end
    end
end)

-- 2. Galaxy Mode
local function SetGalaxy(state)
    if state then
        local s = Instance.new("Sky", game.Lighting); s.Name = "LemonSky"
        s.SkyboxBk = "rbxassetid://159454299"; s.SkyboxDn = "rbxassetid://159454299"
        s.SkyboxFt = "rbxassetid://159454299"; s.SkyboxLf = "rbxassetid://159454299"
        s.SkyboxRt = "rbxassetid://159454299"; s.SkyboxUp = "rbxassetid://159454299"
        game.Lighting.ClockTime = 0
    else
        if game.Lighting:FindFirstChild("LemonSky") then game.Lighting.LemonSky:Destroy() end
        game.Lighting.ClockTime = 12
    end
end

-- [[ UI DESIGN: COMPACT & ANIMATED ]] --
if Player.PlayerGui:FindFirstChild("LemonV84") then Player.PlayerGui.LemonV84:Destroy() end
local gui = Instance.new("ScreenGui", Player.PlayerGui); gui.Name = "LemonV84"; gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 220, 0, 350); main.Position = UDim2.new(0.5, -110, 0.5, -175); main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); main.Active = true; main.Draggable = true
Instance.new("UICorner", main); local stroke = Instance.new("UIStroke", main); stroke.Thickness = 2; stroke.Color = Color3.fromRGB(255, 255, 0)

local ball = Instance.new("TextButton", gui)
ball.Size = UDim2.new(0, 50, 0, 50); ball.Position = UDim2.new(0.05, 0, 0.4, 0); ball.BackgroundColor3 = Color3.fromRGB(255, 255, 0); ball.Text = "🍋"; ball.Visible = false; Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)

local function Toggle(v)
    if v then main.Visible = false; ball.Visible = true else ball.Visible = false; main.Visible = true end
end
local min = Instance.new("TextButton", main); min.Size = UDim2.new(0, 25, 0, 25); min.Position = UDim2.new(1, -30, 0, 5); min.Text = "-"; min.BackgroundColor3 = Color3.new(1,1,0); Instance.new("UICorner", min)
min.MouseButton1Click:Connect(function() Toggle(true) end); ball.MouseButton1Click:Connect(function() Toggle(false) end)

local scroll = Instance.new("ScrollingFrame", main); scroll.Size = UDim2.new(1, -10, 1, -45); scroll.Position = UDim2.new(0, 5, 0, 40); scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 5, 0); scroll.ScrollBarThickness = 0
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

local function AddBtn(txt, callback)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(0.95, 0, 0, 30); b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    local active = false
    b.MouseButton1Click:Connect(function() active = not active; callback(active); b.BackgroundColor3 = active and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(30, 30, 30); b.TextColor3 = active and Color3.new(0,0,0) or Color3.new(1,1,1) end)
end

-- [[ BUTONLAR: HER ŞEY BURADA ]] --
AddBtn("AIMBOT", function(v) _G.Settings.Aimbot = v end)
AddBtn("HITBOX EXPANDER", function(v) _G.Settings.HBExpander = v end)
AddBtn("AUTO CLICK E", function(v) _G.Settings.AutoClickE = v end)
AddBtn("GALAXY MODE", function(v) SetGalaxy(v) end)
AddBtn("ANTI RAGDOLL", function(v) _G.Settings.AntiRagdoll = v end)
AddBtn("AUTO WALK (LOOP)", function(v) _G.Settings.AutoWalk = v end)
AddBtn("SEMI-TP ESCAPE", function(v) _G.Settings.SemiTP = v end)

-- Ayar Butonları (Hız, Jump, Gravity)
local function SetVal(txt, field, val1, val2)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(0.95, 0, 0, 30); b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(50, 50, 50); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        _G.Settings[field] = (_G.Settings[field] == val1) and val2 or val1
        b.Text = txt .. ": " .. _G.Settings[field]
    end)
end

SetVal("Speed", "WalkSpeed", 16, 100)
SetVal("Jump", "JumpPower", 50, 150)
SetVal("Gravity", "Gravity", 196.2, 40)

for i = 1, 4 do
    local pb = Instance.new("TextButton", scroll); pb.Size = UDim2.new(0.95, 0, 0, 25); pb.Text = "Set Point " .. i; pb.BackgroundColor3 = Color3.fromRGB(80, 0, 0); pb.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", pb)
    pb.MouseButton1Click:Connect(function() _G.Settings.Points[i] = Player.Character.HumanoidRootPart.Position; pb.Text = "P"..i.." OK" end)
end

print("🍋 OMEGA LEMON V84 LOADED!")
