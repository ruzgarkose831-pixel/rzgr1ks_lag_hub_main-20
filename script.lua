--[[ 
    rzgr1ks DUEL SCRIPT - V102 (AUTO-PATH MASTER)
    - Fix: Sequential Auto-Walk (Goes to 1, then 2, then 3...)
    - Add: Visual Line between points
    - Add: Configuration System
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- 1. SETTINGS & CONFIG
_G.Data = {
    Speed = 30, Jump = 55, HB_Size = 25,
    HB_Enabled = false, ESP_Enabled = false,
    Walking = false, SelectedSlot = 1,
    Points = {} -- Stores recorded positions
}

local function SaveConfig()
    local config = {Speed = _G.Data.Speed, Jump = _G.Data.Jump, HB_Size = _G.Data.HB_Size}
    writefile("rzgr1ks_v102.json", HttpService:JSONEncode(config))
end

local PointColors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,1,0)}
local Visuals = {}

-- 2. MAIN UI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "rzgr1ks_V102"; gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 240, 0, 330)
main.Position = UDim2.new(0.5, -120, 0.5, -165)
main.BackgroundColor3 = Color3.fromRGB(15,15,20)
main.BorderSizePixel = 0
Instance.new("UICorner",main).CornerRadius = UDim.new(0,12)
Instance.new("UIStroke", main).Color = Color3.fromRGB(255,140,0)

-- MINI LOGO
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 70, 0, 30); toggleBtn.Position = UDim2.new(0, 10, 0.2, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25); toggleBtn.Text = "rzgr1ks"
toggleBtn.TextColor3 = Color3.fromRGB(255,140,0); toggleBtn.Font = "GothamBold"
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,8)
toggleBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

-- DRAG
local dragging, dragStart, startPos
main.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = main.Position end end)
UIS.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UIS.InputEnded:Connect(function() dragging = false end)

local container = Instance.new("ScrollingFrame", main); container.Size = UDim2.new(1,-10,1,-45); container.Position = UDim2.new(0,5,0,40); container.BackgroundTransparency = 1; container.ScrollBarThickness = 0; container.CanvasSize = UDim2.new(0,0,0,520)
Instance.new("UIListLayout", container).Padding = UDim.new(0,5)

-- 3. UI HELPERS
local function CreateSlider(text, min, max, default, callback)
    local f = Instance.new("Frame", container); f.Size = UDim2.new(1,0,0,35); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = text .. ": " .. default; l.Size = UDim2.new(1,0,0,12); l.TextColor3 = Color3.new(1,1,1); l.Font = "Gotham"; l.TextSize = 10; l.BackgroundTransparency = 1
    local bar = Instance.new("Frame", f); bar.Size = UDim2.new(1,-10,0,4); bar.Position = UDim2.new(0,5,1,-8); bar.BackgroundColor3 = Color3.fromRGB(50,50,55); Instance.new("UICorner",bar)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((default-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255,140,0); Instance.new("UICorner",fill)
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then local conn; conn = UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1); fill.Size = UDim2.new(p, 0, 1, 0); local v = math.floor(min + (max - min) * p); l.Text = text .. ": " .. v; callback(v) end end); UIS.InputEnded:Once(function() conn:Disconnect() end) end end)
end

local function CreateBtn(text, color, callback)
    local b = Instance.new("TextButton", container); b.Size = UDim2.new(1,0,0,26); b.BackgroundColor3 = color; b.Text = text; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 10; Instance.new("UICorner", b); b.MouseButton1Click:Connect(callback); return b
end

-- 4. FEATURES
CreateSlider("Speed Boost", 16, 150, _G.Data.Speed, function(v) _G.Data.Speed = v end)
CreateSlider("Jump Power", 50, 200, _G.Data.Jump, function(v) _G.Data.Jump = v end)

local slotBtn = CreateBtn("RECORDING SLOT: 1", Color3.fromRGB(60, 45, 0), function()
    _G.Data.SelectedSlot = (_G.Data.SelectedSlot % 4) + 1
    slotBtn.Text = "RECORDING SLOT: " .. _G.Data.SelectedSlot
end)

CreateBtn("SAVE POSITION", Color3.fromRGB(0, 80, 150), function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local slot = _G.Data.SelectedSlot
        _G.Data.Points[slot] = hrp.Position
        if Visuals[slot] then Visuals[slot]:Destroy() end
        local p = Instance.new("Part", workspace); p.Size = Vector3.new(1.5,1.5,1.5); p.Position = hrp.Position; p.Anchored = true; p.CanCollide = false; p.Shape = "Ball"; p.Material = "Neon"; p.Color = PointColors[slot]; p.Transparency = 0.5; Visuals[slot] = p
    end
end)

CreateBtn("START SEQUENTIAL WALK", Color3.fromRGB(0, 100, 0), function()
    if _G.Data.Walking then return end
    _G.Data.Walking = true
    task.spawn(function()
        -- 1'den başlayıp kaydedilen son noktaya kadar sırayla gider
        for i = 1, 4 do
            local target = _G.Data.Points[i]
            if not _G.Data.Walking then break end
            if target then
                print("Moving to Point: " .. i)
                while _G.Data.Walking and player.Character do
                    local hum = player.Character:FindFirstChild("Humanoid")
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hrp then
                        hum:MoveTo(target)
                        if (hrp.Position - target).Magnitude < 5 then break end -- Varınca döngüden çık, sonrakine geç
                    end
                    task.wait(0.1)
                end
            end
        end
        _G.Data.Walking = false
        print("Path Finished!")
    end)
end)

CreateBtn("STOP WALK", Color3.fromRGB(120, 0, 0), function() _G.Data.Walking = false end)
CreateBtn("SAVE CONFIG", Color3.fromRGB(80, 80, 80), function() SaveConfig() end)
CreateBtn("CLEAR ALL POINTS", Color3.fromRGB(40, 40, 40), function() _G.Data.Points = {}; for _,v in pairs(Visuals) do v:Destroy() end end)

-- 5. ENGINE
RunService.PostSimulation:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and hrp and not _G.Data.Walking and hum.MoveDirection.Magnitude > 0 then
        hrp.Velocity = Vector3.new(hum.MoveDirection.X * _G.Data.Speed, hrp.Velocity.Y, hum.MoveDirection.Z * _G.Data.Speed)
    end
end)

UIS.JumpRequest:Connect(function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and not _G.Data.Walking then hrp.Velocity = Vector3.new(hrp.Velocity.X, _G.Data.Jump, hrp.Velocity.Z) end
end)
