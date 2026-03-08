--[[
    rzgr1ks DUEL HUB - V82 (AUTO-MOVE & PATHFINDING)
    - Auto-Move: Koyduğun checkpoint'e karakter yürüyerek gider.
    - Pathfinding: Engellerin etrafından dolanır, gerçekçi yürür.
    - Tüm Legacy Özellikler: Hitbox, ESP, Lag, Config vb. aktiftir.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local PathfindingService = game:GetService("PathfindingService")
local player = Players.LocalPlayer

-- 1. CONFIG & GLOBALS
local FileName = "rzgr1ks_v82_final.json"
local CheckpointPos = nil
local Moving = false
local Colors = {Color3.new(1,0,0), Color3.new(0,1,1), Color3.new(0,1,0), Color3.new(1,1,0), Color3.new(1,0,1), Color3.new(1,1,1)}
local ColorIndex = 2

_G.Set = {
    Speed = 16, Jump = 50, HitboxSize = 25, 
    HitboxExp = false, HitboxVisual = true, 
    ESP = false, AntiRag = true, LagServer = false,
    HB_ColorIdx = 2, HB_Trans = 0.7
}

local function SaveConfig() writefile(FileName, HttpService:JSONEncode(_G.Set)) end
local function LoadConfig() if isfile(FileName) then _G.Set = HttpService:JSONDecode(readfile(FileName)) ColorIndex = _G.Set.HB_ColorIdx or 2 end end
LoadConfig()

-- 2. AUTO-MOVE FONKSİYONU (PATHFINDING)
local function GoToCheckpoint()
    if not CheckpointPos or Moving then return end
    local char = player.Character
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if char and hum and hrp then
        Moving = true
        local path = PathfindingService:CreatePath({AgentCanJump = true, WaypointSpacing = 2})
        path:ComputeAsync(hrp.Position, CheckpointPos)
        
        local waypoints = path:GetWaypoints()
        for _, waypoint in pairs(waypoints) do
            if not Moving then break end
            if waypoint.Action == Enum.PathfindingWaypointAction.Jump then
                hum.Jump = true
            end
            hum:MoveTo(waypoint.Position)
            hum.MoveToFinished:Wait()
        end
        Moving = false
    end
end

-- 3. ANA PANEL (V82)
if game:GetService("CoreGui"):FindFirstChild("rzg_hub_v82") then game:GetService("CoreGui").rzg_hub_v82:Destroy() end
local sg = Instance.new("ScreenGui", game:GetService("CoreGui")); sg.Name = "rzg_hub_v82"
local Main = Instance.new("Frame", sg); Main.Size = UDim2.new(0, 330, 0, 680); Main.Position = UDim2.new(0.5, -165, 0.5, -340); Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Main.Draggable = true; Main.Active = true
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 3; Instance.new("UICorner", Main)

-- MOBİL BUTON
local OpenBtn = Instance.new("TextButton", sg); OpenBtn.Size = UDim2.new(0, 50, 0, 50); OpenBtn.Position = UDim2.new(1, -60, 0, 20); OpenBtn.Text = "MENU"; Instance.new("UICorner", OpenBtn); OpenBtn.BackgroundTransparency = 0.5
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- UI ELEMENTLERİ (Özet)
local function CreateToggle(name, key, pos)
    local t = Instance.new("TextButton", Main); t.Size = UDim2.new(0, 150, 0, 30); t.Position = pos; t.BackgroundColor3 = Color3.fromRGB(25, 25, 25); t.Text = name..": "..(_G.Set[key] and "ON" or "OFF"); t.TextColor3 = Color3.new(1,1,1); t.Font = "Gotham"; t.TextSize = 8; Instance.new("UICorner", t)
    t.MouseButton1Click:Connect(function() _G.Set[key] = not _G.Set[key] t.Text = name..": "..(_G.Set[key] and "ON" or "OFF") end)
end

local function ActionBtn(name, pos, color, func)
    local b = Instance.new("TextButton", Main); b.Size = UDim2.new(0, 145, 0, 35); b.Position = pos; b.BackgroundColor3 = color; b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 9; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(func)
end

-- ÖZELLİKLER
CreateToggle("Hitbox System", "HitboxExp", UDim2.new(0, 10, 0, 45))
CreateToggle("Visual Hitbox", "HitboxVisual", UDim2.new(0, 170, 0, 45))
CreateToggle("Server Lag", "LagServer", UDim2.new(0, 90, 0, 80))

-- AUTO MOVE BUTONLARI
ActionBtn("SET CHECKPOINT", UDim2.new(0, 10, 0, 125), Color3.fromRGB(100, 100, 0), function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        CheckpointPos = player.Character.HumanoidRootPart.Position
        print("Checkpoint Ayarlandı!")
    end
end)

ActionBtn("AUTO MOVE GO", UDim2.new(0, 170, 0, 125), Color3.fromRGB(0, 150, 0), function()
    spawn(GoToCheckpoint)
end)

ActionBtn("STOP MOVE", UDim2.new(0, 90, 0, 165), Color3.fromRGB(150, 0, 0), function()
    Moving = false
end)

-- LİDER (Diğer Sliderlar ve Kayıtlar)
ActionBtn("SAVE CONFIG", UDim2.new(0, 10, 0, 420), Color3.fromRGB(0, 100, 0), SaveConfig)
ActionBtn("LOAD CONFIG", UDim2.new(0, 170, 0, 420), Color3.fromRGB(0, 70, 130), LoadConfig)

-- 4. ANA MOTOR
RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        if hum.Health <= 0 then hum.Health = 100 end
        if not Moving then hum.WalkSpeed = _G.Set.Speed end -- Yürürken hızı bozmasın
    end
end)

-- Hitbox Logic
RunService.RenderStepped:Connect(function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = v.Character.HumanoidRootPart
            if _G.Set.HitboxExp then
                hrp.Size = Vector3.new(_G.Set.HitboxSize, _G.Set.HitboxSize, _G.Set.HitboxSize)
                hrp.Transparency = _G.Set.HitboxVisual and _G.Set.HB_Trans or 1
                hrp.Color = Colors[ColorIndex]
                hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2,2,1)
            end
        end
    end
end)

spawn(function() while task.wait() do Stroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end end)
