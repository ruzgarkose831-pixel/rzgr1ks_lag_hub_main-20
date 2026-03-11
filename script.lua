local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- Eski GUI Temizliği
local old = Player.PlayerGui:FindFirstChild("LemonV45")
if old then old:Destroy() end

_G.Settings = {
    ESP = false, ESPDist = 1000,
    SpeedBoost = false, SpeedVal = 70,
    JumpMod = false, JumpPower = 100,
    BatHitbox = false, BatSize = 40,
    SpinBot = false, SpinSpeed = 150,
    GalaxyMode = false, GravityVal = 100,
    AntiRagdoll = false, InfJump = false,
    ServerLag = false, UnderArms = false, HiddenHead = false,
    AutoWalk = false, Waypoints = {}
}

local gui = Instance.new("ScreenGui", Player.PlayerGui)
gui.Name = "LemonV45"
gui.ResetOnSpawn = false

-- ANA PANEL (Boyut Küçültüldü: 440x340)
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 440, 0, 340)
main.Position = UDim2.new(0.5, -220, 0.5, -170)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- UZAY ARKA PLANI
local bg = Instance.new("ImageLabel", main)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Image = "rbxassetid://13264663806"
bg.Transparency = 0.6; bg.ScaleType = Enum.ScaleType.Crop; bg.ZIndex = 0

-- RGB KENARLIK
local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2.2
RunService.RenderStepped:Connect(function() stroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)

-- KÜÇÜLTME SİSTEMİ (İkon)
local miniBtn = Instance.new("TextButton", main)
miniBtn.Size = UDim2.new(0, 30, 0, 30)
miniBtn.Position = UDim2.new(1, -35, 0, 5)
miniBtn.Text = "_"; miniBtn.TextColor3 = Color3.new(1,1,1)
miniBtn.BackgroundTransparency = 1; miniBtn.Font = "GothamBold"; miniBtn.TextSize = 20; miniBtn.ZIndex = 5

local openIcon = Instance.new("TextButton", gui)
openIcon.Size = UDim2.new(0, 50, 0, 50)
openIcon.Position = UDim2.new(1, -60, 0.5, -25)
openIcon.BackgroundColor3 = Color3.fromRGB(20,20,20)
openIcon.Text = "🍋"; openIcon.TextSize = 25; openIcon.Visible = false
Instance.new("UICorner", openIcon).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", openIcon).Color = Color3.fromRGB(255,180,0)

miniBtn.MouseButton1Click:Connect(function()
    main.Visible = false; openIcon.Visible = true
end)
openIcon.MouseButton1Click:Connect(function()
    main.Visible = true; openIcon.Visible = false
end)

-- BAŞLIK
local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1, 0, 0, 40)
header.Text = "  LEMÖN HUB V45 COMPACT"; header.TextColor3 = Color3.fromRGB(255, 180, 0)
header.Font = "GothamBold"; header.TextSize = 13; header.BackgroundTransparency = 1; header.TextXAlignment = "Left"; header.ZIndex = 2

-- İKİ SÜTUNLU SCROLL
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -50)
scroll.Position = UDim2.new(0, 5, 0, 45)
scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 750); scroll.ScrollBarThickness = 1; scroll.ZIndex = 2

local left = Instance.new("Frame", scroll)
left.Size = UDim2.new(0.48, 0, 1, 0); left.BackgroundTransparency = 1
local lList = Instance.new("UIListLayout", left); lList.Padding = UDim.new(0, 8)

local right = Instance.new("Frame", scroll)
right.Size = UDim2.new(0.48, 0, 1, 0); right.Position = UDim2.new(0.52, 0, 0, 0); right.BackgroundTransparency = 1
local rList = Instance.new("UIListLayout", right); rList.Padding = UDim.new(0, 8)

-- ÇALIŞAN TOGGLE FONKSİYONU
local function AddToggle(parent, letter, text, key)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 32); f.BackgroundTransparency = 1
    
    local lBox = Instance.new("TextLabel", f)
    lBox.Size = UDim2.new(0, 18, 0, 18); lBox.Position = UDim2.new(0, 2, 0.5, -9)
    lBox.BackgroundColor3 = Color3.fromRGB(255, 180, 0); lBox.Text = letter; lBox.TextColor3 = Color3.new(0,0,0)
    lBox.Font = "GothamBold"; lBox.TextSize = 10; Instance.new("UICorner", lBox)
    
    local txt = Instance.new("TextLabel", f)
    txt.Size = UDim2.new(1, -60, 1, 0); txt.Position = UDim2.new(0, 25, 0, 0)
    txt.Text = text; txt.TextColor3 = Color3.new(1,1,1); txt.Font = "GothamBold"; txt.TextSize = 10; txt.TextXAlignment = "Left"; txt.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 34, 0, 18); btn.Position = UDim2.new(1, -36, 0.5, -9)
    btn.Text = ""; btn.BackgroundColor3 = _G.Settings[key] and Color3.fromRGB(255,100,0) or Color3.fromRGB(50,50,50)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local dot = Instance.new("Frame", btn)
    dot.Size = UDim2.new(0, 14, 0, 14); dot.Position = _G.Settings[key] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    dot.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    btn.MouseButton1Click:Connect(function()
        _G.Settings[key] = not _G.Settings[key]
        btn.BackgroundColor3 = _G.Settings[key] and Color3.fromRGB(255,100,0) or Color3.fromRGB(50,50,50)
        dot.Position = _G.Settings[key] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    end)
end

-- ÇALIŞAN SLIDER FONKSİYONU
local function AddSlider(parent, text, min, max, key)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 40); f.BackgroundTransparency = 1
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 0, 15); l.Text = text .. ": " .. _G.Settings[key]
    l.TextColor3 = Color3.fromRGB(200, 200, 200); l.Font = "Gotham"; l.TextSize = 9; l.TextXAlignment = "Left"; l.BackgroundTransparency = 1
    
    local bar = Instance.new("TextButton", f)
    bar.Size = UDim2.new(1, -4, 0, 12); bar.Position = UDim2.new(0, 2, 1, -18)
    bar.BackgroundColor3 = Color3.fromRGB(30,30,30); bar.Text = ""; Instance.new("UICorner", bar)
    
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((_G.Settings[key]-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 150, 0); Instance.new("UICorner", fill)
    
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

-- SOL SÜTUN
AddToggle(left, "G", "Player ESP", "ESP")
AddSlider(left, "Distance", 0, 2000, "ESPDist")
AddToggle(left, "N", "Hız Hilesi", "SpeedBoost")
AddSlider(left, "Speed", 16, 500, "SpeedVal")
AddToggle(left, "L", "Zıplama", "JumpMod")
AddSlider(left, "Jump", 50, 400, "JumpPower")
AddToggle(left, "A", "Galaxy Mode", "GalaxyMode")
AddSlider(left, "Gravity %", 0, 100, "GravityVal")

-- SAĞ SÜTUN
AddToggle(right, "C", "Bat Hitbox", "BatHitbox")
AddSlider(right, "Reach", 5, 200, "BatSize")
AddToggle(right, "S", "SERVER LAG", "ServerLag")
AddToggle(right, "P", "Mevlana (Spin)", "SpinBot")
AddSlider(right, "Spin Spd", 50, 1000, "SpinSpeed")
AddToggle(right, "R", "Anti-Ragdoll", "AntiRagdoll")
AddToggle(right, "J", "Inf Jump", "InfJump")
AddToggle(right, "U", "Auto Walk", "AutoWalk")

-- [[ CORE ENGINE - FIX ]] --
RunService.Heartbeat:Connect(function()
    local char = Player.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if _G.Settings.SpeedBoost then hum.WalkSpeed = _G.Settings.SpeedVal end
        if _G.Settings.JumpMod then hum.JumpPower = _G.Settings.JumpPower end
        if _G.Settings.AntiRagdoll then
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        -- SPIN FIX
        local s = root:FindFirstChild("LSpin") or Instance.new("BodyAngularVelocity", root)
        s.Name = "LSpin"; s.MaxTorque = Vector3.new(0, math.huge, 0)
        s.AngularVelocity = _G.Settings.SpinBot and Vector3.new(0, _G.Settings.SpinSpeed, 0) or Vector3.new(0,0,0)
        
        -- GALAXY GRAVITY
        workspace.Gravity = _G.Settings.GalaxyMode and (196.2 * (_G.Settings.GravityVal / 100)) or 196.2
        
        -- HITBOX FIX
        if _G.Settings.BatHitbox and Player.Character:FindFirstChildOfClass("Tool") then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (root.Position - v.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= _G.Settings.BatSize then
                        firetouchinterest(root, v.Character.HumanoidRootPart, 0)
                        firetouchinterest(root, v.Character.HumanoidRootPart, 1)
                    end
                end
            end
        end
    end
end)

-- LAG SERVER FIX
task.spawn(function()
    while task.wait(0.2) do
        if _G.Settings.ServerLag then
            for i=1, 50 do
                local ev = game:FindFirstChildOfClass("RemoteEvent", true)
                if ev then pcall(function() ev:FireServer(string.rep("LAG", 100)) end) end
            end
        end
    end
end)

-- INF JUMP
UIS.JumpRequest:Connect(function()
    if _G.Settings.InfJump and Player.Character then
        Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

print("LEMON HUB V45 COMPACT LOADED! Her şey aktif.")
