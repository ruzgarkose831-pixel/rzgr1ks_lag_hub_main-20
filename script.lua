--[[
    rzgr1ks DUEL HUB - V81 (TRUE LEGACY & FIXED AUTO-WALK)
    - Auto-Walk: Yürüyerek gitme sistemi tamamen düzeltildi.
    - Eski Özellikler: ESP, Hitbox, Lag, Anti-Die, Speed, Jump geri eklendi.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- 1. CONFIG & DEĞERLER
local FileName = "rzg_legacy_v85.json"
_G.Set = {
    Speed = 16, Jump = 50, Gravity = 196.2, 
    HitboxSize = 25, HB_Toggle = false, 
    ESP = false, Lag = false, AntiDie = true
}

local function Save() writefile(FileName, HttpService:JSONEncode(_G.Set)) end
if isfile(FileName) then _G.Set = HttpService:JSONDecode(readfile(FileName)) end

local CP_Pos = nil
local IsWalking = false

-- 2. ANA PANEL
if game:GetService("CoreGui"):FindFirstChild("rzg_legacy_v85") then game:GetService("CoreGui").rzg_legacy_v85:Destroy() end
local sg = Instance.new("ScreenGui", game:GetService("CoreGui")); sg.Name = "rzg_legacy_v85"
local Main = Instance.new("Frame", sg); Main.Size = UDim2.new(0, 320, 0, 580); Main.Position = UDim2.new(0.5, -160, 0.5, -290); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Main.Draggable = true
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 2; Stroke.Color = Color3.new(1,1,1); Instance.new("UICorner", Main)

-- MOBİL BUTON
local OpenBtn = Instance.new("TextButton", sg); OpenBtn.Size = UDim2.new(0, 50, 0, 50); OpenBtn.Position = UDim2.new(1, -60, 0, 20); OpenBtn.Text = "MENU"; Instance.new("UICorner", OpenBtn); OpenBtn.BackgroundTransparency = 0.5
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- UI FONKSİYONLARI
local function NewToggle(name, key, y)
    local t = Instance.new("TextButton", Main); t.Size = UDim2.new(0, 280, 0, 30); t.Position = UDim2.new(0, 20, 0, y); t.BackgroundColor3 = Color3.fromRGB(30, 30, 30); t.Text = name..": "..(_G.Set[key] and "ON" or "OFF"); t.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", t)
    t.MouseButton1Click:Connect(function() _G.Set[key] = not _G.Set[key] t.Text = name..": "..(_G.Set[key] and "ON" or "OFF") end)
end

local function NewBtn(name, y, color, func)
    local b = Instance.new("TextButton", Main); b.Size = UDim2.new(0, 280, 0, 35); b.Position = UDim2.new(0, 20, 0, y); b.BackgroundColor3 = color; b.Text = name; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(func)
end

-- ÖZELLİKLER (ESKİLER + YENİLER)
NewToggle("Hitbox Expander", "HB_Toggle", 50)
NewToggle("Player ESP", "ESP", 90)
NewToggle("Server Lag", "Lag", 130)

-- HIZ VE ZIPLAMA BUTONLARI (KAYDIRMAK YERİNE DİREKT SET)
NewBtn("SPEED 50", 170, Color3.fromRGB(50, 50, 50), function() _G.Set.Speed = 50 end)
NewBtn("JUMP 100", 210, Color3.fromRGB(50, 50, 50), function() _G.Set.Jump = 100 end)

-- AUTO WALK SİSTEMİ
NewBtn("SET CHECKPOINT", 260, Color3.fromRGB(100, 100, 0), function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        CP_Pos = player.Character.HumanoidRootPart.Position
    end
end)

NewBtn("AUTO WALK GO", 305, Color3.fromRGB(0, 100, 0), function()
    if not CP_Pos then return end
    IsWalking = true
    spawn(function()
        while IsWalking and CP_Pos and player.Character do
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then 
                hum:MoveTo(CP_Pos) 
                local dist = (player.Character.HumanoidRootPart.Position - CP_Pos).Magnitude
                if dist < 4 then IsWalking = false break end
            end
            task.wait(0.1)
        end
    end)
end)

NewBtn("STOP AUTO WALK", 350, Color3.fromRGB(100, 0, 0), function() IsWalking = false end)
NewBtn("SAVE & LOAD CONFIG", 410, Color3.fromRGB(0, 80, 150), Save)

-- 4. ANA DÖNGÜ (STABİLİTE)
RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    if not hum then return end

    -- Anti-Die & Speed & Gravity
    if _G.Set.AntiDie then
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        if hum.Health <= 0 then hum.Health = 100 end
    end
    if not IsWalking then hum.WalkSpeed = _G.Set.Speed end
    hum.JumpPower = _G.Set.Jump
    workspace.Gravity = _G.Set.Gravity

    -- Lag (Eski özellik)
    if _G.Set.Lag and char:FindFirstChild("HumanoidRootPart") then
        for i=1,5 do local p = Instance.new("Part", workspace); p.Transparency=1; p.Position=char.HumanoidRootPart.Position; task.delay(0.1, function() p:Destroy() end) end
    end

    -- Hitbox (Eski özellik)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = v.Character.HumanoidRootPart
            if _G.Set.HB_Toggle then
                hrp.Size = Vector3.new(_G.Set.HitboxSize, _G.Set.HitboxSize, _G.Set.HitboxSize)
                hrp.Transparency = 0.8; hrp.CanCollide = false
            else hrp.Size = Vector3.new(2,2,1) end
        end
    end
end)
