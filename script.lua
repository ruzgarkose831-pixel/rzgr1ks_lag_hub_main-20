--[[ 
    rzgr1ks DUEL SCRIPT - V122 (CLASSIC SPEED UPDATE)
    - UPDATED: Walk Speed returned to its original Velocity method.
    - MAINTAINED: Physics Spin Bot, God Reach, ESP, and Config System.
    - FIXED: Better compatibility for ground-based movement.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local PlayerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local Controls = PlayerModule:GetControls()

-- 1. GLOBAL DATA
_G.Data = {
    Speed = 40, Jump = 60, Gravity = 196.2,
    HB_Size = 25, HB_Enabled = false, HB_Invisible = false,
    ESP_Enabled = false, Sword_HB_Enabled = false, Sword_HB_Size = 25,
    KillAura = false, SpinBot = false, SpinSpeed = 30,
    CounterTP = false, CustomTP_Pos = nil,
    AutoWalk = false, Points = {}, SelectedSlot = 1,
    FloatEnabled = false, RagdollWalk = false,
    AntiVoid = false, AutoClick = false
}

-- 2. CONFIG SYSTEM
local function SaveSettings()
    local config = {
        Speed = _G.Data.Speed, Jump = _G.Data.Jump, Gravity = _G.Data.Gravity,
        HB_Size = _G.Data.HB_Size, Sword_HB_Size = _G.Data.Sword_HB_Size,
        SpinSpeed = _G.Data.SpinSpeed, Points = {}
    }
    for i, p in pairs(_G.Data.Points) do config.Points[tostring(i)] = {x = p.X, y = p.Y, z = p.Z} end
    pcall(function() writefile("rzgr1ks_config.json", HttpService:JSONEncode(config)) end)
end

local function LoadSettings()
    pcall(function()
        if isfile("rzgr1ks_config.json") then
            local data = HttpService:JSONDecode(readfile("rzgr1ks_config.json"))
            _G.Data.Speed = data.Speed or 40; _G.Data.Jump = data.Jump or 60; _G.Data.Gravity = data.Gravity or 196.2
            _G.Data.HB_Size = data.HB_Size or 25; _G.Data.Sword_HB_Size = data.Sword_HB_Size or 25
            _G.Data.SpinSpeed = data.SpinSpeed or 30
            if data.Points then for i, p in pairs(data.Points) do _G.Data.Points[tonumber(i)] = Vector3.new(p.x, p.y, p.z) end end
            workspace.Gravity = _G.Data.Gravity
        end
    end)
end

-- 3. UI CONSTRUCTION
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui")); gui.Name = "rzgr1ks_V122"; gui.ResetOnSpawn = false
local toggleBtn = Instance.new("TextButton", gui); toggleBtn.Size = UDim2.new(0, 50, 0, 30); toggleBtn.Position = UDim2.new(0, 5, 0.1, 0); toggleBtn.Text = "V122"; toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 0, 0); toggleBtn.TextColor3 = Color3.new(1,0,0); Instance.new("UICorner", toggleBtn)
local main = Instance.new("Frame", gui); main.Visible = false; main.Size = UDim2.new(0, 180, 0, 300); main.Position = UDim2.new(0.5, -90, 0.5, -150); main.BackgroundColor3 = Color3.fromRGB(10, 0, 0); main.BackgroundTransparency = 0.2; Instance.new("UICorner", main); Instance.new("UIStroke", main).Color = Color3.new(1, 0, 0)
toggleBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

local container = Instance.new("ScrollingFrame", main); container.Size = UDim2.new(1,-6,1,-10); container.Position = UDim2.new(0,3,0,5); container.BackgroundTransparency = 1; container.ScrollBarThickness = 2; container.CanvasSize = UDim2.new(0,0,0,1400)
Instance.new("UIListLayout", container).Padding = UDim.new(0,3)

local function CreateToggle(text, dataKey)
    local b = Instance.new("TextButton", container); b.Size = UDim2.new(1,0,0,24); b.BackgroundColor3 = Color3.fromRGB(30,0,0); b.Text = text .. ": OFF"; b.TextColor3 = Color3.new(1,1,1); b.TextSize = 10; Instance.new("UICorner",b)
    b.MouseButton1Click:Connect(function() _G.Data[dataKey] = not _G.Data[dataKey]; b.Text = text .. ": " .. (_G.Data[dataKey] and "ON" or "OFF"); b.TextColor3 = _G.Data[dataKey] and Color3.new(1,0,0) or Color3.new(1,1,1) end)
end

local function CreateSlider(text, min, max, dataKey, callback)
    local f = Instance.new("Frame", container); f.Size = UDim2.new(1,0,0,32); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = text .. ": " .. _G.Data[dataKey]; l.Size = UDim2.new(1,0,0,12); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 9
    local bar = Instance.new("Frame", f); bar.Size = UDim2.new(1,-6,0,4); bar.Position = UDim2.new(0,3,1,-8); bar.BackgroundColor3 = Color3.fromRGB(50,0,0)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((_G.Data[dataKey]-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.new(1,0,0)
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then local conn; conn = UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1); fill.Size = UDim2.new(p, 0, 1, 0); local v = math.floor(min + (max - min) * p); l.Text = text .. ": " .. v; _G.Data[dataKey] = v; if callback then callback(v) end end end); UIS.InputEnded:Once(function() conn:Disconnect() end) end end)
end

-- 4. BUTTONS
CreateToggle("KILL AURA", "KillAura")
CreateToggle("GOD REACH", "Sword_HB_Enabled")
CreateSlider("Reach Size", 2, 200, "Sword_HB_Size")
CreateToggle("SPIN BOT", "SpinBot")
CreateSlider("Spin Speed", 5, 200, "SpinSpeed")
CreateToggle("PLAYER HITBOX", "HB_Enabled")
CreateSlider("HB Size", 2, 100, "HB_Size")
CreateToggle("RAGDOLL WALK", "RagdollWalk")
CreateSlider("WALK SPEED", 16, 400, "Speed")
CreateSlider("JUMP POWER", 50, 600, "Jump")
CreateToggle("FLOAT PLATFORM", "FloatEnabled")
CreateToggle("ANTI-VOID", "AntiVoid")

local saveBtn = Instance.new("TextButton", container); saveBtn.Size = UDim2.new(1,0,0,30); saveBtn.Text = "SAVE CONFIG"; saveBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0); saveBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", saveBtn)
saveBtn.MouseButton1Click:Connect(SaveSettings)

-- 5. THE CORE ENGINE
local floatPart = Instance.new("Part", workspace); floatPart.Size = Vector3.new(6, 1, 6); floatPart.Transparency = 1; floatPart.Anchored = true

RunService.Heartbeat:Connect(function()
    local char = player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid")
    if not (hrp and hum) then return end

    -- Physics Spin
    local spin = hrp:FindFirstChild("rzgr1ks_Spin") or Instance.new("BodyAngularVelocity", hrp)
    spin.Name = "rzgr1ks_Spin"; spin.MaxTorque = Vector3.new(0, math.huge, 0)
    spin.AngularVelocity = _G.Data.SpinBot and Vector3.new(0, _G.Data.SpinSpeed, 0) or Vector3.new(0, 0, 0)

    -- Float & Anti-Void
    if _G.Data.FloatEnabled then floatPart.CFrame = hrp.CFrame * CFrame.new(0, -3.5, 0); floatPart.CanCollide = true else floatPart.CanCollide = false end
    if _G.Data.AntiVoid and hrp.Position.Y < -80 then hrp.CFrame = _G.Data.CustomTP_Pos or CFrame.new(0, 100, 0); hrp.Velocity = Vector3.new(0,0,0) end

    -- Sword HB
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and _G.Data.Sword_HB_Enabled then
        if _G.Data.KillAura then tool:Activate() end
        for _, p in pairs(tool:GetDescendants()) do
            if p:IsA("BasePart") then p.Size = Vector3.new(_G.Data.Sword_HB_Size, _G.Data.Sword_HB_Size, _G.Data.Sword_HB_Size); p.Transparency = 0.8; p.CanCollide = false end
        end
    end

    -- CLASSIC VELOCITY SPEED (İlk yaptığımız yöntem)
    if _G.Data.RagdollWalk then
        local moveDir = Controls:GetMoveVector()
        if moveDir.Magnitude > 0 then
            local camera = workspace.CurrentCamera
            local look = (camera.CFrame.RightVector * moveDir.X) + (camera.CFrame.LookVector * -moveDir.Z)
            hrp.CFrame = hrp.CFrame + Vector3.new(look.X, 0, look.Z) * (_G.Data.Speed / 50)
        end
    elseif not _G.Data.AutoWalk and hum.MoveDirection.Magnitude > 0 then
        -- İşte o klasik hız yöntemi:
        hrp.Velocity = Vector3.new(hum.MoveDirection.X * _G.Data.Speed, hrp.Velocity.Y, hum.MoveDirection.Z * _G.Data.Speed)
    end
end)

-- 6. JUMP POWER FIX
UIS.JumpRequest:Connect(function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and not _G.Data.AutoWalk then
        hrp.Velocity = Vector3.new(hrp.Velocity.X, _G.Data.Jump, hrp.Velocity.Z)
    end
end)

-- 7. PLAYER MODS (Hitbox)
RunService.Stepped:Connect(function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local root = v.Character.HumanoidRootPart
            root.Size = _G.Data.HB_Enabled and Vector3.new(_G.Data.HB_Size, _G.Data.HB_Size, _G.Data.HB_Size) or Vector3.new(2,2,1)
            root.Transparency = _G.Data.HB_Enabled and 0.7 or 1; root.CanCollide = false
        end
    end
end)
