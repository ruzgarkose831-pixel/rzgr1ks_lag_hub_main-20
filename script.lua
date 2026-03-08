local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. CLEANUP & INITIALIZATION
local function cleanup()
    if game:GetService("CoreGui"):FindFirstChild("rzgr1ks_V48") then game:GetService("CoreGui").rzgr1ks_V48:Destroy() end
    if workspace:FindFirstChild("AirBlock_" .. player.Name) then workspace["AirBlock_" .. player.Name]:Destroy() end
end
cleanup()

_G.Config = {
    Speed = 70, Jump = 50, Spin = false, SpinSpd = 50, 
    Platform = false, Elev = 15, AntiRag = false, 
    Gravity = 196.2, Hitbox = false, HitboxSize = 15, ESP = false
}

-- 2. NEW SPIN METHOD: TORQUE BYPASS
local function applyTorqueSpin(char, state)
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local attachment = root:FindFirstChild("SpinAttachment") or Instance.new("Attachment", root)
    attachment.Name = "SpinAttachment"
    
    local torque = root:FindFirstChild("SpinTorque") or Instance.new("Torque", root)
    torque.Name = "SpinTorque"
    torque.Attachment0 = attachment
    
    if state then
        torque.Enabled = true
        -- Karakteri fiziksel olarak saniyede kendi ekseni etrafında döndürür
        torque.Torque = Vector3.new(0, _G.Config.SpinSpd * 5000, 0)
    else
        torque.Enabled = false
    end
end

-- 3. RGB SLIM GUI
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "rzgr1ks_V48"
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 210, 0, 440); Main.Position = UDim2.new(0.5, -105, 0.5, -220)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main); local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 2
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35); Title.Text = "rzgr1ks V48 - BYPASS"; Title.BackgroundTransparency = 1; Title.Font = "GothamBold"; Title.TextSize = 11

spawn(function()
    while task.wait() do
        local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        Stroke.Color = color; Title.TextColor3 = color
    end
end)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -85); Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 7, 0); Scroll.ScrollBarThickness = 0
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 6)

-- 4. COMPONENTS
local function createToggle(name, key, callback)
    local t = Instance.new("TextButton", Scroll); t.Size = UDim2.new(0, 195, 0, 28); t.BackgroundColor3 = Color3.fromRGB(25, 25, 25); t.Text = name..": OFF"; t.TextColor3 = Color3.new(1,1,1); t.Font = "Gotham"; t.TextSize = 9; Instance.new("UICorner", t)
    t.MouseButton1Click:Connect(function()
        _G.Config[key] = not _G.Config[key]
        t.Text = _G.Config[key] and name..": ON" or name..": OFF"
        t.TextColor3 = _G.Config[key] and Color3.fromRGB(255,140,0) or Color3.new(1,1,1)
        if callback then callback(_G.Config[key]) end
    end)
end

local function createSlider(name, min, max, default, key)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(0, 195, 0, 40); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = name..": "..default; l.Size = UDim2.new(1,0,0,15); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 9
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0, 180, 0, 4); b.Position = UDim2.new(0,8,0,25); b.BackgroundColor3 = Color3.fromRGB(35,35,35); b.Text = ""
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255,140,0)
    b.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local p = math.clamp((inp.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0); local val = math.floor(min + (max - min) * p)
                l.Text = name..": "..val; _G.Config[key] = val
            end
        end)
        UIS.InputEnded:Connect(function(u) if u.UserInputType == Enum.UserInputType.MouseButton1 or u.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

-- 5. FEATURES
createToggle("Torque Spin (Bypass)", "Spin", function(v) 
    if player.Character then applyTorqueSpin(player.Character, v) end 
end)
createSlider("Spin Power", 10, 300, 50, "SpinSpd")
createToggle("Block Platform", "Platform")
createSlider("Walk Speed", 16, 500, 70, "Speed")
createToggle("ESP Wallhack", "ESP")
createToggle("Hitbox Expander", "Hitbox")
createSlider("Hitbox Size", 5, 50, 15, "HitboxSize")
createToggle("Anti Ragdoll", "AntiRag")

-- 6. ENGINE
RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    hum.WalkSpeed = _G.Config.Speed
    
    -- Fiziksel Spin Güncelleme
    if _G.Config.Spin and root:FindFirstChild("SpinTorque") then
        root.SpinTorque.Torque = Vector3.new(0, _G.Config.SpinSpd * 5000, 0)
    end

    if _G.Config.Hitbox then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(_G.Config.Config.HitboxSize, _G.Config.Config.HitboxSize, _G.Config.Config.HitboxSize)
            end
        end
    end
end)
