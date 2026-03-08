local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Cleanup
local old = player:WaitForChild("PlayerGui"):FindFirstChild("LemonStyleHub")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "LemonStyleHub"
ScreenGui.ResetOnSpawn = false

-- States
_G.Aimbot = false
_G.AutoShoot = false
_G.FakeLag = false
_G.Orbit = false
_G.SpeedBoost = false
_G.ESP = false
_G.InfJump = false
_G.SpeedValue = 60

-- [SARI TOP / OPEN BUTTON]
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50); OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 220, 0); OpenBtn.Text = "OPEN"; OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

-- [MAIN PANEL]
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 450); Main.Position = UDim2.new(0.5, -175, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -50); Scroll.Position = UDim2.new(0, 10, 0, 45); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 10)

-- UI Helpers
local function addToggle(name, callback)
    local Frame = Instance.new("Frame", Scroll); Frame.Size = UDim2.new(1, 0, 0, 40); Frame.BackgroundTransparency = 1
    local Btn = Instance.new("TextButton", Frame); Btn.Size = UDim2.new(0, 45, 0, 22); Btn.Position = UDim2.new(1, -50, 0.5, -11); Btn.BackgroundColor3 = Color3.fromRGB(40,40,40); Btn.Text = ""
    local Lbl = Instance.new("TextLabel", Frame); Lbl.Size = UDim2.new(0.7,0,1,0); Lbl.Text = name; Lbl.TextColor3 = Color3.new(0.9,0.9,0.9); Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = "Left"; Lbl.Font = "Gotham"
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1,0)
    local active = false
    Btn.Activated:Connect(function() active = not active; Btn.BackgroundColor3 = active and Color3.fromRGB(255, 220, 0) or Color3.fromRGB(40, 40, 40); callback(active) end)
end

-- Features
addToggle("Aimbot Lock", function(v) _G.Aimbot = v end)
addToggle("Auto Shoot", function(v) _G.AutoShoot = v end)
addToggle("Fake Lag (Enemy Misses)", function(v) _G.FakeLag = v end)
addToggle("Orbit Enemy (Annoying)", function(v) _G.Orbit = v end)
addToggle("Speed Hack", function(v) _G.SpeedBoost = v end)
addToggle("Infinite Jump", function(v) _G.InfJump = v end)
addToggle("Player ESP", function(v) _G.ESP = v end)

-- Kapatma
local Close = Instance.new("TextButton", Main); Close.Size = UDim2.new(0,30,0,30); Close.Position = UDim2.new(1,-35,0,5); Close.Text = "X"; Close.BackgroundColor3 = Color3.new(1,0,0)
Close.Activated:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.Activated:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

-- [GET TARGET]
local function getTarget()
    local nearest = nil
    local dist = 300
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local mDist = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if mDist < dist then nearest = v; dist = mDist end
            end
        end
    end
    return nearest
end

-- [MAIN LOOP]
local tickCount = 0
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    -- FAKE LAG (Rakip senin nerede olduğunu anlayamaz)
    if _G.FakeLag and root then
        tickCount = tickCount + 1
        if tickCount % 5 == 0 then -- Her 5 karede bir pozisyonu dondurur
            root.Anchored = true
            task.wait(0.05)
            root.Anchored = false
        end
    end

    -- AIMBOT & ORBIT
    if _G.Aimbot then
        local target = getTarget()
        if target and target.Character then
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            
            -- Lock Camera
            camera.CFrame = CFrame.new(camera.CFrame.Position, tRoot.Position)

            -- ORBIT (Rakibin etrafında ışınlanarak döner, sana vuramaz)
            if _G.Orbit and root then
                local angle = tick() * 10
                root.CFrame = tRoot.CFrame * CFrame.new(math.cos(angle) * 10, 2, math.sin(angle) * 10)
            end

            -- Auto Shoot
            if _G.AutoShoot then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end
    end

    -- General Speed
    if _G.SpeedBoost and hum then hum.WalkSpeed = _G.SpeedValue end
end)

-- Inf Jump
UIS.JumpRequest:Connect(function() if _G.InfJump then player.Character.Humanoid:ChangeState(3) end end)
