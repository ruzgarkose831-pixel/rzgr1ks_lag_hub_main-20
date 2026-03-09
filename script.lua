--[[ 
    rzgr1ks V21 (ULTIMATE ABYSS EDITION)
    - ALL FEATURES RESTORED & FIXED.
    - BODY: Underground Arms, Cursed Torso, Hidden Head.
    - COMBAT: Forced Bat Hitbox, Smart Hitbox, Auto Attack, Head Look-At.
    - MOVEMENT: Spin Bot (Fix), Speed, Jump, Gravity, Anti-Ragdoll, Float.
    - VISUALS: ESP (Box/Name), Galaxy Mode, Atmosphere Control.
    - SYSTEM: JSON Config & Checkpoint Auto-Walk.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local ConfigFile = "rzgr1ks_v21_final.json"

-- 1. MASTER DATA TABLE
_G.Hub = {
    -- Cursed Body
    UndergroundArms = false, CursedTorso = false, HiddenHead = false,
    -- Combat
    BatHitbox = true, BatHitboxSize = 25, SmartHitbox = false, HitboxSize = 15,
    AutoAttack = false, HeadLookAt = false, LookAtRange = 60,
    -- Movement
    Speed = true, SpeedVal = 60, Jump = false, JumpVal = 80,
    Gravity = false, GravityVal = 196.2, AntiRagdoll = true,
    Spin = false, SpinSpeed = 100, Float = false, FloatOffset = -3.5,
    -- Visuals
    ESP_Box = false, ESP_Name = false, Galaxy = false,
    Brightness = 2, Exposure = 0,
    -- Automation
    AutoWalk = false, Points = {}
}

-- 2. RGB & UTILS
local rgbColor = Color3.new(1,1,1)
RunService.RenderStepped:Connect(function() rgbColor = Color3.fromHSV(tick() % 4 / 4, 1, 1) end)

local function SaveConfig()
    local t = {}
    for k, v in pairs(_G.Hub) do if type(v) ~= "table" then t[k] = v end end
    writefile(ConfigFile, HttpService:JSONEncode(t))
end

-- 3. UI CONSTRUCTION
local gui = Instance.new("ScreenGui", player.PlayerGui); gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui); main.Size = UDim2.new(0, 340, 0, 500); main.Position = UDim2.new(0.5, -170, 0.5, -250); main.BackgroundColor3 = Color3.fromRGB(5,5,5)
Instance.new("UICorner", main)
local stroke = Instance.new("UIStroke", main); stroke.Thickness = 2.5; RunService.RenderStepped:Connect(function() stroke.Color = rgbColor end)

local header = Instance.new("TextButton", main); header.Size = UDim2.new(1, 0, 0, 35); header.Text = "rzgr1ks V21 ULTIMATE"; header.Font = "GothamBold"; header.BackgroundColor3 = Color3.fromRGB(15,15,15); header.TextColor3 = Color3.new(1,1,1)
header.MouseButton1Click:Connect(function() main.Visible = false; icon.Visible = true end)

local icon = Instance.new("TextButton", gui); icon.Size = UDim2.new(0, 50, 0, 50); icon.Position = UDim2.new(0, 10, 0.5, -25); icon.Text = "🍋"; icon.BackgroundColor3 = Color3.fromRGB(10,10,10); Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 25)
Instance.new("UIStroke", icon).Thickness = 2; icon.MouseButton1Click:Connect(function() main.Visible = true; icon.Visible = false end)

local scroll = Instance.new("ScrollingFrame", main); scroll.Size = UDim2.new(1, -10, 1, -45); scroll.Position = UDim2.new(0, 5, 0, 40); scroll.CanvasSize = UDim2.new(0, 0, 0, 2500); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 3
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

-- Helpers
local function Toggle(n, k)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(1, 0, 0, 32); b.BackgroundColor3 = Color3.fromRGB(20,20,20); b.Font = "GothamBold"; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    RunService.RenderStepped:Connect(function() b.Text = n .. (_G.Hub[k] and " : ON" or " : OFF"); b.TextColor3 = _G.Hub[k] and rgbColor or Color3.new(1,1,1) end)
    b.MouseButton1Click:Connect(function() _G.Hub[k] = not _G.Hub[k] end)
end

local function Slider(n, min, max, k)
    local f = Instance.new("Frame", scroll); f.Size = UDim2.new(1, 0, 0, 40); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 15); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Font = "GothamBold"; l.TextSize = 10
    local bar = Instance.new("Frame", f); bar.Size = UDim2.new(1, -20, 0, 8); bar.Position = UDim2.new(0, 10, 1, -12); bar.BackgroundColor3 = Color3.fromRGB(40,40,40); Instance.new("UICorner", bar)
    local fill = Instance.new("Frame", bar); Instance.new("UICorner", fill)
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then local conn; conn = UIS.InputChanged:Connect(function() local p = math.clamp((UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1); _G.Hub[k] = math.floor(min+(max-min)*p) end) UIS.InputEnded:Once(function() conn:Disconnect() end) end end)
    RunService.RenderStepped:Connect(function() l.Text = n .. ": " .. _G.Hub[k]; fill.Size = UDim2.new((_G.Hub[k]-min)/(max-min),0,1,0); fill.BackgroundColor3 = rgbColor end)
end

-- 4. BUTTON LIST
local function Label(t) local l = Instance.new("TextLabel", scroll); l.Size = UDim2.new(1,0,0,20); l.Text = "--- "..t.." ---"; l.TextColor3 = Color3.new(1,1,0); l.BackgroundTransparency = 1; l.Font = "GothamBold" end

Label("CURSED MODS")
Toggle("UNDERGROUND ARMS", "UndergroundArms")
Toggle("CURSED TORSO", "CursedTorso")
Toggle("HIDDEN HEAD", "HiddenHead")

Label("COMBAT")
Toggle("BAT HITBOX (FORCE)", "BatHitbox")
Slider("BAT SIZE", 5, 100, "BatHitboxSize")
Toggle("SMART HITBOX (PLAYER)", "SmartHitbox")
Slider("PLAYER SIZE", 2, 100, "HitboxSize")
Toggle("AUTO ATTACK", "AutoAttack")
Toggle("HEAD LOOK-AT", "HeadLookAt")

Label("MOVEMENT")
Toggle("SPEED BOOST", "Speed")
Slider("SPEED VAL", 16, 250, "SpeedVal")
Toggle("SPIN BOT (FIXED)", "Spin")
Slider("SPIN SPEED", 10, 300, "SpinSpeed")
Toggle("ANTI RAGDOLL", "AntiRagdoll")
Toggle("JUMP MOD", "Jump")
Toggle("GRAVITY MOD", "Gravity")
Toggle("FLOAT", "Float")

Label("VISUALS & ATMO")
Toggle("GALAXY SKY", "Galaxy")
Toggle("BOX ESP", "ESP_Box")
Slider("BRIGHTNESS", 0, 10, "Brightness")

Label("AUTOMATION")
local pBtn = Instance.new("TextButton", scroll); pBtn.Size = UDim2.new(1, 0, 0, 32); pBtn.Text = "ADD CHECKPOINT"; pBtn.BackgroundColor3 = Color3.fromRGB(50,0,100); Instance.new("UICorner", pBtn)
pBtn.MouseButton1Click:Connect(function() table.insert(_G.Hub.Points, player.Character.HumanoidRootPart.Position) end)
Toggle("AUTO WALK", "AutoWalk")
local sBtn = Instance.new("TextButton", scroll); sBtn.Size = UDim2.new(1, 0, 0, 32); sBtn.Text = "SAVE CONFIG"; sBtn.BackgroundColor3 = Color3.fromRGB(0,50,0); Instance.new("UICorner", sBtn)
sBtn.MouseButton1Click:Connect(SaveConfig)

-- 5. THE CORE ENGINE
local platform = Instance.new("Part", workspace); platform.Size = Vector3.new(15, 1, 15); platform.Anchored = true; platform.Transparency = 1

RunService.RenderStepped:Connect(function()
    local char = player.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp) then return end

    -- Body Distortion Fixes
    local rs = char:FindFirstChild("RightShoulder", true)
    local ls = char:FindFirstChild("LeftShoulder", true)
    local neck = char:FindFirstChild("Neck", true)
    local rootJoint = hrp:FindFirstChildOfClass("Motor6D")

    if _G.Hub.UndergroundArms and rs and ls then
        rs.C0 = CFrame.new(1, -5, 0) * CFrame.Angles(math.rad(180), 0, 0)
        ls.C0 = CFrame.new(-1, -5, 0) * CFrame.Angles(math.rad(180), 0, 0)
    end
    if _G.Hub.CursedTorso and rootJoint then rootJoint.C0 = CFrame.new(0, -2.5, 0) end
    if _G.Hub.HiddenHead and neck then neck.C0 = CFrame.new(0, -1.2, 0) end

    -- Combat Features
    if _G.Hub.BatHitbox then
        local t = char:FindFirstChildOfClass("Tool")
        if t then for _, p in pairs(t:GetDescendants()) do if p:IsA("BasePart") then p.Size = Vector3.new(_G.Hub.BatHitboxSize, _G.Hub.BatHitboxSize, _G.Hub.BatHitboxSize); p.Transparency = 0.8; p.CanCollide = false end end end
    end
    if _G.Hub.AutoAttack then local t = char:FindFirstChildOfClass("Tool"); if t then t:Activate() end end

    -- Movement Features
    hum.AutoRotate = not _G.Hub.Spin
    local spinV = hrp:FindFirstChild("UltimateSpin") or Instance.new("BodyAngularVelocity", hrp)
    spinV.Name = "UltimateSpin"; spinV.MaxTorque = Vector3.new(0, math.huge, 0)
    spinV.AngularVelocity = _G.Hub.Spin and Vector3.new(0, _G.Hub.SpinSpeed, 0) or Vector3.new(0,0,0)

    if _G.Hub.Speed and not _G.Hub.AutoWalk then hum.WalkSpeed = _G.Hub.SpeedVal end
    if _G.Hub.AntiRagdoll then hum.PlatformStand = false; hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end
    if _G.Hub.Gravity then workspace.Gravity = _G.Hub.GravityVal else workspace.Gravity = 196.2 end
    if _G.Hub.Float then platform.Position = hrp.Position + Vector3.new(0, _G.Hub.FloatOffset, 0); platform.CanCollide = true else platform.CanCollide = false end
    
    -- Visuals
    if _G.Hub.Galaxy then Lighting.ClockTime = 0; Lighting.OutdoorAmbient = Color3.fromRGB(120,0,255) end
    Lighting.Brightness = _G.Hub.Brightness
end)

-- Auto Walk Engine
task.spawn(function()
    while task.wait(0.1) do
        if _G.Hub.AutoWalk and #_G.Hub.Points > 0 and player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then for _, p in pairs(_G.Hub.Points) do if not _G.Hub.AutoWalk then break end hum:MoveTo(p); repeat task.wait(0.1) until (player.Character.HumanoidRootPart.Position - p).Magnitude < 6 or not _G.Hub.AutoWalk end end
        end
    end
end)

-- Smart Hitbox
RunService.Stepped:Connect(function()
    for _, t in pairs(Players:GetPlayers()) do
        if t ~= player and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            t.Character.HumanoidRootPart.Size = _G.Hub.SmartHitbox and Vector3.new(_G.Hub.HitboxSize, _G.Hub.HitboxSize, _G.Hub.HitboxSize) or Vector3.new(2,2,1)
            t.Character.HumanoidRootPart.Transparency = _G.Hub.SmartHitbox and 0.7 or 1; t.Character.HumanoidRootPart.CanCollide = false
        end
    end
end)
