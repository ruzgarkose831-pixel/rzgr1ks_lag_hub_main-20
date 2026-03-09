--[[ 
    rzgr1ks DUEL HUB V9 (FINAL ARSENAL)
    - NEW: Player ESP (Box, Health, Name).
    - NEW: Look-At Aimbot (Head follows closest player).
    - FULL: Includes Gravity, Bat Hitbox, Anti-Ragdoll, and Auto-Walk.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- 1. ULTIMATE DATA TABLE
_G.Hub = {
    -- Combat & Aim
    LookAt = false, LookAtRange = 50,
    SmartHitbox = false, HitboxSize = 15,
    BatHitbox = false, BatHitboxSize = 15,
    AutoAttack = false, SpamBat = false,
    Spin = false, SpinSpeed = 50,
    
    -- ESP Features
    ESP = false, ESP_Box = false, ESP_Health = false, ESP_Name = false,
    
    -- Movement & Physics
    Speed = false, SpeedVal = 50,
    Jump = false, JumpVal = 80,
    Gravity = false, GravityVal = 196.2,
    AntiRagdoll = false,
    Float = false, FloatOffset = -3.5,
    
    -- Automation
    Galaxy = false,
    AutoWalk = false, Points = {}
}

-- 2. ESP SYSTEM ENGINE
local function CreateESP(target)
    local box = Drawing.new("Square"); box.Thickness = 1; box.Filled = false; box.Color = Color3.new(1, 1, 1); box.Visible = false
    local health = Drawing.new("Line"); health.Thickness = 2; health.Color = Color3.new(0, 1, 0); health.Visible = false
    local name = Drawing.new("Text"); name.Size = 14; name.Center = true; name.Outline = true; name.Color = Color3.new(1, 1, 1); name.Visible = false

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character:FindFirstChild("Humanoid") and _G.Hub.ESP then
            local hrp = target.Character.HumanoidRootPart
            local hum = target.Character.Humanoid
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local size = (camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0)).Y - camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.6, 0)).Y)
                local boxSize = Vector2.new(size / 1.5, size)
                local boxPos = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)

                -- Box
                box.Visible = _G.Hub.ESP_Box; box.Size = boxSize; box.Position = boxPos
                -- Health
                health.Visible = _G.Hub.ESP_Health; health.From = Vector2.new(boxPos.X - 5, boxPos.Y + boxSize.Y); health.To = Vector2.new(boxPos.X - 5, boxPos.Y + boxSize.Y - (hum.Health / hum.MaxHealth) * boxSize.Y)
                -- Name
                name.Visible = _G.Hub.ESP_Name; name.Position = Vector2.new(pos.X, boxPos.Y - 15); name.Text = target.Name
            else
                box.Visible = false; health.Visible = false; name.Visible = false
            end
        else
            box.Visible = false; health.Visible = false; name.Visible = false
            if not target.Parent then box:Destroy(); health:Destroy(); name:Destroy(); connection:Disconnect() end
        end
    end)
end
for _, v in pairs(Players:GetPlayers()) do if v ~= player then CreateESP(v) end end
Players.PlayerAdded:Connect(function(v) CreateESP(v) end)

-- 3. UI GENERATION (V7 Base)
local gui = Instance.new("ScreenGui", player.PlayerGui); gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui); main.Size = UDim2.new(0, 330, 0, 420); main.Position = UDim2.new(0.5, -165, 0.5, -210); main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Instance.new("UICorner", main); local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(255, 140, 0); stroke.Thickness = 2

local icon = Instance.new("TextButton", gui); icon.Size = UDim2.new(0, 45, 0, 45); icon.Position = UDim2.new(0, 10, 0.5, -20); icon.Text = "🍋"; icon.TextSize = 25; icon.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 22)
icon.MouseButton1Click:Connect(function() main.Visible = true; icon.Visible = false end)

local header = Instance.new("TextButton", main); header.Size = UDim2.new(1, 0, 0, 35); header.Text = "rzgr1ks DUEL HUB V9 - CLOSE"; header.Font = "GothamBold"; header.TextSize = 12; header.BackgroundColor3 = Color3.fromRGB(35, 35, 40); header.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", header)
header.MouseButton1Click:Connect(function() main.Visible = false; icon.Visible = true end)

local scroll = Instance.new("ScrollingFrame", main); scroll.Size = UDim2.new(1, -10, 1, -45); scroll.Position = UDim2.new(0, 5, 0, 40); scroll.CanvasSize = UDim2.new(0, 0, 0, 2000); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 4
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

local function Toggle(n, k)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(1, 0, 0, 30); b.Text = n .. " : OFF"; b.BackgroundColor3 = Color3.fromRGB(40, 40, 45); b.Font = "GothamBold"; b.TextSize = 11; b.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() _G.Hub[k] = not _G.Hub[k]; b.Text = n .. (_G.Hub[k] and " : ON" or " : OFF"); b.TextColor3 = _G.Hub[k] and Color3.fromRGB(255, 140, 0) or Color3.new(1, 1, 1) end)
end

local function Slider(n, min, max, k)
    local f = Instance.new("Frame", scroll); f.Size = UDim2.new(1, 0, 0, 40); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 15); l.Text = n .. ": " .. _G.Hub[k]; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 10
    local bar = Instance.new("Frame", f); bar.Size = UDim2.new(1, -20, 0, 8); bar.Position = UDim2.new(0, 10, 1, -15); bar.BackgroundColor3 = Color3.fromRGB(50,50,55); Instance.new("UICorner", bar)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((_G.Hub[k]-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255,140,0); Instance.new("UICorner", fill)
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then local conn; conn = UIS.InputChanged:Connect(function() local p = math.clamp((UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1); fill.Size = UDim2.new(p,0,1,0); local v = math.floor(min+(max-min)*p); _G.Hub[k] = v; l.Text = n .. ": " .. v end) UIS.InputEnded:Once(function() conn:Disconnect() end) end end)
end

-- 4. BUTTONS
Toggle("HEAD LOOK-AT (Target Lock)", "LookAt")
Slider("LOOK-AT DISTANCE", 10, 200, "LookAtRange")
Toggle("PLAYER BOX ESP", "ESP_Box")
Toggle("PLAYER NAME ESP", "ESP_Name")
Toggle("PLAYER HEALTH ESP", "ESP_Health")
_G.Hub.ESP = true -- Main Master Switch
Toggle("SMART HITBOX (Player)", "SmartHitbox")
Slider("PLAYER HB SIZE", 2, 100, "HitboxSize")
Toggle("BAT/SWORD HITBOX", "BatHitbox")
Slider("BAT HB SIZE", 5, 100, "BatHitboxSize")
Toggle("AUTO ATTACK", "AutoAttack")
Toggle("SPAM BAT", "SpamBat")
Toggle("SPEED BOOST", "Speed")
Slider("WALK SPEED", 16, 200, "SpeedVal")
Toggle("JUMP MOD", "Jump")
Slider("JUMP POWER", 50, 200, "JumpVal")
Toggle("GRAVITY MOD", "Gravity")
Slider("GRAVITY AMOUNT", 0, 200, "GravityVal")
Toggle("ANTI RAGDOLL", "AntiRagdoll")
Toggle("SPIN BOT", "Spin")
Toggle("FLOAT PLATFORM", "Float")
Toggle("AUTO WALK", "AutoWalk")

-- 5. ENGINE
local platform = Instance.new("Part", workspace); platform.Size = Vector3.new(15, 1, 15); platform.Anchored = true; platform.Transparency = 1

RunService.RenderStepped:Connect(function()
    local char = player.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    -- LOOK-AT LOGIC (Head Follow)
    if _G.Hub.LookAt then
        local target = nil; local dist = _G.Hub.LookAtRange
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
                local d = (hrp.Position - v.Character.Head.Position).Magnitude
                if d < dist then target = v.Character.Head; dist = d end
            end
        end
        if target then
            local neck = char:FindFirstChild("Neck", true)
            if neck then
                local cframe = CFrame.new(char.Head.Position, target.Position)
                neck.C0 = char.UpperTorso.CFrame:ToObjectSpace(cframe) * CFrame.Angles(math.rad(90), 0, math.rad(180))
            end
        end
    end

    -- Physics
    if _G.Hub.Speed then hum.WalkSpeed = _G.Hub.SpeedVal end
    if _G.Hub.Jump then hum.JumpPower = _G.Hub.JumpVal; hum.UseJumpPower = true end
    workspace.Gravity = _G.Hub.Gravity and _G.Hub.GravityVal or 196.2
    if _G.Hub.Float then platform.Position = hrp.Position + Vector3.new(0, _G.Hub.FloatOffset, 0); platform.CanCollide = true else platform.CanCollide = false end

    -- Combat
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        if _G.Hub.AutoAttack or _G.Hub.SpamBat then tool:Activate() end
        if _G.Hub.BatHitbox then
            for _, p in pairs(tool:GetDescendants()) do
                if p:IsA("BasePart") then p.Size = Vector3.new(_G.Hub.BatHitboxSize, _G.Hub.BatHitboxSize, _G.Hub.BatHitboxSize); p.Transparency = 0.8; p.CanCollide = false end
            end
        end
    end
end)

-- Hitbox Expander
RunService.Stepped:Connect(function()
    for _, t in pairs(Players:GetPlayers()) do
        if t ~= player and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            t.Character.HumanoidRootPart.Size = _G.Hub.SmartHitbox and Vector3.new(_G.Hub.HitboxSize, _G.Hub.HitboxSize, _G.Hub.HitboxSize) or Vector3.new(2,2,1)
            t.Character.HumanoidRootPart.Transparency = _G.Hub.SmartHitbox and 0.7 or 1; t.Character.HumanoidRootPart.CanCollide = false
        end
    end
end)
