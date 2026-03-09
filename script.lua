--[[ 
    rzgr1ks DUEL SCRIPT - V115 (GHOST PATH & AUTO-WALK)
    - NEW: Multi-Point Auto Walk (4 Slotlu Rota Sistemi)
    - NEW: Loop Walk (Sürekli devriye atma)
    - ALL-IN-ONE: Speed, Jump, Reach, Kill Aura, Revenge TP dahil!
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local PlayerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local Controls = PlayerModule:GetControls()

-- 1. GLOBAL DATA
_G.Data = {
    Speed = 30, Jump = 55, Gravity = 196.2,
    HB_Size = 25, HB_Enabled = false, 
    Sword_HB_Enabled = false, Sword_HB_Size = 15,
    KillAura = false, KA_Range = 30,
    CounterTP = false, CustomTP_Pos = nil,
    AutoWalk = false, SelectedSlot = 1, Points = {}, -- AUTO WALK VERİLERİ
    AntiVoid = false, AutoClick = false, ESP_Enabled = false, RagdollWalk = false
}

-- 2. MAIN UI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "rzgr1ks_V115"; gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 260, 0, 520)
main.Position = UDim2.new(0.5, -130, 0.5, -260)
main.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)
Instance.new("UIStroke", main).Color = Color3.fromRGB(255, 140, 0)

local container = Instance.new("ScrollingFrame", main); container.Size = UDim2.new(1,-10,1,-50); container.Position = UDim2.new(0,5,0,45); container.BackgroundTransparency = 1; container.ScrollBarThickness = 0; container.CanvasSize = UDim2.new(0,0,0,1600)
Instance.new("UIListLayout", container).Padding = UDim.new(0,6)

-- UI HELPERS
local function CreateToggle(text, dataKey)
    local b = Instance.new("TextButton", container); b.Size = UDim2.new(1,0,0,32); b.BackgroundColor3 = Color3.fromRGB(20,20,30); b.Text = text .. ": OFF"; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner",b)
    b.MouseButton1Click:Connect(function() _G.Data[dataKey] = not _G.Data[dataKey]; b.Text = text .. ": " .. (_G.Data[dataKey] and "ON" or "OFF"); b.TextColor3 = _G.Data[dataKey] and Color3.fromRGB(255,140,0) or Color3.new(1,1,1) end)
end

local function CreateSlider(text, min, max, dataKey)
    local f = Instance.new("Frame", container); f.Size = UDim2.new(1,0,0,40); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = text .. ": " .. _G.Data[dataKey]; l.Size = UDim2.new(1,0,0,16); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1
    local bar = Instance.new("Frame", f); bar.Size = UDim2.new(1,-10,0,6); bar.Position = UDim2.new(0,5,1,-10); bar.BackgroundColor3 = Color3.fromRGB(40,40,50)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((_G.Data[dataKey]-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255,140,0)
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then local conn; conn = UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1); fill.Size = UDim2.new(p, 0, 1, 0); local v = math.floor(min + (max - min) * p); l.Text = text .. ": " .. v; _G.Data[dataKey] = v end end); UIS.InputEnded:Once(function() conn:Disconnect() end) end end)
end

local function CreateBtn(text, color, callback)
    local b = Instance.new("TextButton", container); b.Size = UDim2.new(1,0,0,32); b.BackgroundColor3 = color; b.Text = text; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b); b.MouseButton1Click:Connect(callback); return b
end

-- 3. INTERFACE (AUTO WALK SECTION)
local slotBtn = CreateBtn("SELECT SLOT: 1", Color3.fromRGB(60, 40, 0), function()
    _G.Data.SelectedSlot = (_G.Data.SelectedSlot % 4) + 1
    slotBtn.Text = "SELECT SLOT: " .. _G.Data.SelectedSlot
end)

CreateBtn("SAVE POINT (Current Pos)", Color3.fromRGB(0, 80, 150), function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then 
        _G.Data.Points[_G.Data.SelectedSlot] = hrp.Position
        print("Point " .. _G.Data.SelectedSlot .. " Saved!")
    end
end)

CreateToggle("AUTO WALK (Loop Mode)", "AutoWalk")

-- OTHER FEATURES
CreateToggle("KILL AURA", "KillAura")
CreateToggle("GOD REACH (Sword)", "Sword_HB_Enabled")
CreateSlider("Sword Size", 2, 1000, "Sword_HB_Size")
CreateToggle("COUNTER-TP (Revenge)", "CounterTP")
CreateBtn("SET REVENGE POS", Color3.fromRGB(150, 0, 0), function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then _G.Data.CustomTP_Pos = hrp.CFrame end
end)
CreateSlider("WALK SPEED", 16, 300, "Speed")
CreateToggle("PLAYER ESP", "ESP_Enabled")

-- 4. AUTO WALK ENGINE
task.spawn(function()
    while task.wait(0.1) do
        if _G.Data.AutoWalk and player.Character then
            for i = 1, 4 do
                local targetPos = _G.Data.Points[i]
                if not _G.Data.AutoWalk then break end
                if targetPos then
                    local hum = player.Character:FindFirstChild("Humanoid")
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hrp then
                        while _G.Data.AutoWalk and (hrp.Position - targetPos).Magnitude > 4 do
                            hum:MoveTo(targetPos)
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
    end
end)

-- 5. CORE LOOP (REVENGE, SWORD, PHYSICS)
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not (hrp and hum) then return end

    -- REVENGE TP
    if _G.Data.CounterTP and _G.Data.CustomTP_Pos and (hum.PlatformStand or hum.Sit) then
        hrp.CFrame = _G.Data.CustomTP_Pos
        task.delay(0.1, function() hum.PlatformStand = false; hum.Sit = false; hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    end

    -- SWORD & AURA
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        if _G.Data.KillAura then tool:Activate() end
        if _G.Data.Sword_HB_Enabled then
            local h = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart")
            if h then h.Size = Vector3.new(_G.Data.Sword_HB_Size, _G.Data.Sword_HB_Size, _G.Data.Sword_HB_Size); h.Transparency = 0.8; h.CanCollide = false end
        end
    end

    -- SPEED
    if not _G.Data.AutoWalk and hum.MoveDirection.Magnitude > 0 then
        hrp.Velocity = Vector3.new(hum.MoveDirection.X * _G.Data.Speed, hrp.Velocity.Y, hum.MoveDirection.Z * _G.Data.Speed)
    end
end)
