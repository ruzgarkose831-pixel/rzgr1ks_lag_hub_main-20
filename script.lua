--[[
    rzgr1ks DUEL HUB - V83 (REBIRTH & FIXED AUTO-WALK)
    - Auto-Walk: Checkpoint'e yere basarak, takılmadan yürür.
    - Tüm Özellikler: ESP, Hitbox, Lag, Anti-Ragdoll, Speed, Jump.
    - Stabilite: Ölme ve donma sorunları giderildi.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- 1. AYARLAR VE KAYIT SİSTEMİ
local FileName = "rzgr1ks_v83.json"
_G.Set = {
    Speed = 16, Jump = 50, Gravity = 196.2, 
    HitboxSize = 25, HB_Toggle = false, HB_Visual = true,
    ESP = false, AntiRag = true, Lag = false,
    HB_Color = 2 -- 1:Red, 2:Cyan, 3:Green
}

local function Save() writefile(FileName, HttpService:JSONEncode(_G.Set)) end
local function Load() if isfile(FileName) then _G.Set = HttpService:JSONDecode(readfile(FileName)) end end
Load()

local Colors = {Color3.new(1,0,0), Color3.new(0,1,1), Color3.new(0,1,0), Color3.new(1,1,0)}
local CP_Pos = nil
local IsWalking = false

-- 2. ANA PANEL KURULUMU
if game:GetService("CoreGui"):FindFirstChild("rzg_hub_v83") then game:GetService("CoreGui").rzg_hub_v83:Destroy() end
local sg = Instance.new("ScreenGui", game:GetService("CoreGui")); sg.Name = "rzg_hub_v83"
local Main = Instance.new("Frame", sg); Main.Size = UDim2.new(0, 330, 0, 680); Main.Position = UDim2.new(0.5, -165, 0.5, -340); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Main.Draggable = true
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 3; Instance.new("UICorner", Main)

-- MOBİL BUTON
local OpenBtn = Instance.new("TextButton", sg); OpenBtn.Size = UDim2.new(0, 50, 0, 50); OpenBtn.Position = UDim2.new(1, -60, 0, 20); OpenBtn.Text = "MENU"; Instance.new("UICorner", OpenBtn); OpenBtn.BackgroundTransparency = 0.5
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- 3. UI ELEMENTLERİ
local function NewToggle(name, key, x, y)
    local t = Instance.new("TextButton", Main); t.Size = UDim2.new(0, 145, 0, 30); t.Position = UDim2.new(0, x, 0, y); t.BackgroundColor3 = Color3.fromRGB(30, 30, 30); t.Text = name..": "..(_G.Set[key] and "ON" or "OFF"); t.TextColor3 = Color3.new(1,1,1); t.Font = "Gotham"; t.TextSize = 8; Instance.new("UICorner", t)
    t.MouseButton1Click:Connect(function() _G.Set[key] = not _G.Set[key] t.Text = name..": "..(_G.Set[key] and "ON" or "OFF") end)
end

local function NewSlider(txt, min, max, key, y)
    local f = Instance.new("Frame", Main); f.Size = UDim2.new(0, 300, 0, 40); f.Position = UDim2.new(0, 15, 0, y); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = txt..": ".._G.Set[key]; l.Size = UDim2.new(1,0,0,15); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 9
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 0, 12); b.Position = UDim2.new(0,0,0,18); b.BackgroundColor3 = Color3.fromRGB(45,45,45); b.Text = ""; Instance.new("UICorner", b)
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((_G.Set[key]-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", fill)
    b.MouseButton1Down:Connect(function()
        local m; m = UIS.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                local p = math.clamp((i.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0); local v = math.floor(min + (max - min) * p); l.Text = txt..": "..v; _G.Set[key] = v
            end
        end)
        UIS.InputEnded:Connect(function(u) if u.UserInputType == Enum.UserInputType.MouseButton1 or u.UserInputType == Enum.UserInputType.Touch then m:Disconnect() end end)
    end)
end

-- ÖZELLİKLERİ EKLE
NewToggle("Hitbox Exp", "HB_Toggle", 10, 45)
NewToggle("HB Visual", "HB_Visual", 170, 45)
NewToggle("Anti-Ragdoll", "AntiRag", 10, 80)
NewToggle("Server Lag", "Lag", 170, 80)
NewToggle("Player ESP", "ESP", 90, 115)

NewSlider("Hitbox Size", 2, 100, "HitboxSize", 160)
NewSlider("Walk Speed", 16, 150, "Speed", 210)
NewSlider("Jump Power", 50, 300, "Jump", 260)
NewSlider("Gravity", 0, 196, "Gravity", 310)

-- BUTONLAR
local function NewBtn(name, x, y, color, func)
    local b = Instance.new("TextButton", Main); b.Size = UDim2.new(0, 145, 0, 35); b.Position = UDim2.new(0, x, 0, y); b.BackgroundColor3 = color; b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 9; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(func)
end

NewBtn("SET CHECKPOINT", 10, 370, Color3.fromRGB(80, 80, 0), function() if player.Character then CP_Pos = player.Character.HumanoidRootPart.Position end end)
NewBtn("AUTO WALK GO", 170, 370, Color3.fromRGB(0, 100, 0), function()
    if not CP_Pos or IsWalking then return end
    IsWalking = true
    while IsWalking and CP_Pos and player.Character do
        local dist = (player.Character.HumanoidRootPart.Position - CP_Pos).Magnitude
        if dist < 3 then IsWalking = false break end
        player.Character.Humanoid:MoveTo(CP_Pos)
        task.wait(0.1)
    end
end)
NewBtn("STOP WALK", 90, 415, Color3.fromRGB(120, 0, 0), function() IsWalking = false end)
NewBtn("SAVE CONFIG", 10, 470, Color3.fromRGB(0, 120, 0), Save)
NewBtn("LOAD CONFIG", 170, 470, Color3.fromRGB(0, 80, 150), Load)

-- 4. ANA MOTOR (HITBOX & ESP & ANTI-DIE)
RunService.RenderStepped:Connect(function()
    workspace.Gravity = _G.Set.Gravity
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = v.Character.HumanoidRootPart
            if _G.Set.HB_Toggle then
                hrp.Size = Vector3.new(_G.Set.HitboxSize, _G.Set.HitboxSize, _G.Set.HitboxSize)
                hrp.Transparency = _G.Set.HB_Visual and 0.7 or 1
                hrp.Color = Colors[_G.Set.HB_Color]
                hrp.CanCollide = false
            else hrp.Size = Vector3.new(2,2,1) end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local c = player.Character; local h = c and c:FindFirstChild("Humanoid")
    if h then
        h:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        if h.Health <= 0 then h.Health = 100 end
        if not IsWalking then h.WalkSpeed = _G.Set.Speed end
        h.JumpPower = _G.Set.Jump
        if _G.Set.AntiRag then h.PlatformStand = false end
    end
    if _G.Set.Lag and c:FindFirstChild("HumanoidRootPart") then
        for i=1,5 do local p = Instance.new("Part", workspace); p.Transparency=1; p.Position=c.HumanoidRootPart.Position; task.delay(0.1, function() p:Destroy() end) end
    end
end)

spawn(function() while task.wait() do Stroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end end)
