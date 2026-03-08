local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- 1. TEMİZLİK
if game:GetService("CoreGui"):FindFirstChild("rzgr1ks_V60") then game:GetService("CoreGui").rzgr1ks_V60:Destroy() end

-- 2. ANA PANEL (YENİ ÖZELLİKLER İÇİN UZATILDI)
local sg = Instance.new("ScreenGui", game:GetService("CoreGui")); sg.Name = "rzgr1ks_V60"
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 310, 0, 480) -- Panel boyutu artırıldı
Main.Position = UDim2.new(0.5, -155, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Main.Active = true; Main.Draggable = true
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 2; Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35); Title.Text = "rzgr1ks V60 - MEGA UPDATE"; Title.BackgroundTransparency = 1
Title.Font = "GothamBold"; Title.TextSize = 12; Title.TextColor3 = Color3.new(1,1,1)

spawn(function()
    while task.wait() do Stroke.Color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1) end
end)

-- 3. AYARLAR (YENİLER EKLENDİ)
_G.Set = {
    Speed = 70, 
    Jump = 50, 
    Gravity = 196.2, 
    HitboxSize = 25, 
    Elev = 0, 
    Hitbox = false, 
    ESP = false, 
    Plat = false, 
    AntiRag = true
}

-- 4. TOGGLE BUTONLARI
local function QuickToggle(name, key, pos)
    local t = Instance.new("TextButton", Main)
    t.Size = UDim2.new(0, 140, 0, 32); t.Position = pos; t.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    t.Text = name..": OFF"; t.TextColor3 = Color3.new(1,1,1); t.Font = "Gotham"; t.TextSize = 8; Instance.new("UICorner", t)
    t.MouseButton1Click:Connect(function()
        _G.Set[key] = not _G.Set[key]
        t.Text = _G.Set[key] and name .. ": ON" or name .. ": OFF"
        t.TextColor3 = _G.Set[key] and Color3.fromRGB(255, 140, 0) or Color3.new(1, 1, 1)
    end)
end

QuickToggle("Block Platform", "Plat", UDim2.new(0, 10, 0, 45))
QuickToggle("Anti Ragdoll", "AntiRag", UDim2.new(0, 160, 0, 45))
QuickToggle("ESP Wallhack", "ESP", UDim2.new(0, 10, 0, 85))
QuickToggle("Hitbox Expand", "Hitbox", UDim2.new(0, 160, 0, 85))

-- 5. BÜYÜK MOBİL SLIDERLAR
local function BigSlider(txt, min, max, def, key, y)
    local f = Instance.new("Frame", Main); f.Size = UDim2.new(0, 280, 0, 45); f.Position = UDim2.new(0, 15, 0, y); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = txt..": "..def; l.Size = UDim2.new(1,0,0,15); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 9; l.Font = "GothamBold"
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 0, 12); b.Position = UDim2.new(0,0,0,20); b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.Text = ""; Instance.new("UICorner", b)
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((def-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255, 140, 0); Instance.new("UICorner", fill)
    
    b.MouseButton1Down:Connect(function()
        local move; move = UIS.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local p = math.clamp((inp.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0); local val = math.floor(min + (max - min) * p)
                l.Text = txt..": "..val; _G.Set[key] = val
                if key == "Gravity" then workspace.Gravity = val end
            end
        end)
        UIS.InputEnded:Connect(function(u) if u.UserInputType == Enum.UserInputType.MouseButton1 or u.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end end)
    end)
end

BigSlider("Walk Speed", 16, 500, 70, "Speed", 125)
BigSlider("Jump Power", 50, 500, 50, "Jump", 175)
BigSlider("Gravity", 0, 196, 196, "Gravity", 225)
BigSlider("Hitbox Size", 5, 100, 25, "HitboxSize", 275)
BigSlider("Elevation (MINUS FIX)", -200, 500, 0, "Elev", 325) -- Eksi değerler eklendi

-- 6. CONFIG SAVE/LOAD
local function Save() writefile("rzgr_v60.json", HttpService:JSONEncode(_G.Set)) end
local function Load() if isfile("rzgr_v60.json") then _G.Set = HttpService:JSONDecode(readfile("rzgr_v60.json")) end end

local SBtn = Instance.new("TextButton", Main); SBtn.Size = UDim2.new(0, 130, 0, 35); SBtn.Position = UDim2.new(0, 15, 0, 385); SBtn.Text = "SAVE"; SBtn.BackgroundColor3 = Color3.fromRGB(0,100,0); SBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", SBtn)
local LBtn = Instance.new("TextButton", Main); LBtn.Size = UDim2.new(0, 130, 0, 35); LBtn.Position = UDim2.new(0, 160, 0, 385); LBtn.Text = "LOAD"; LBtn.BackgroundColor3 = Color3.fromRGB(0,50,150); LBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", LBtn)
SBtn.MouseButton1Click:Connect(Save)
LBtn.MouseButton1Click:Connect(Load)

-- 7. MOTOR (FIXED ENGINE)
local AirBlock = Instance.new("Part", workspace); AirBlock.Name = "R_Platform"; AirBlock.Size = Vector3.new(30, 1, 30); AirBlock.Transparency = 0.7; AirBlock.Anchored = true; AirBlock.Color = Color3.fromRGB(255, 140, 0)

RunService.Heartbeat:Connect(function()
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    
    -- Hız ve Zıplama
    hum.WalkSpeed = _G.Set.Speed
    hum.JumpPower = _G.Set.Jump
    hum.UseJumpPower = true

    -- Gelişmiş Anti Ragdoll (Force State)
    if _G.Set.AntiRag then
        if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        hum.PlatformStand = false
    end

    -- Platform Fix (Eksi değer desteğiyle)
    if _G.Set.Plat then
        AirBlock.CanCollide = true
        AirBlock.CFrame = CFrame.new(root.Position.X, _G.Set.Elev, root.Position.Z)
    else
        AirBlock.CanCollide = false; AirBlock.Position = Vector3.new(0, -2000, 0)
    end
    
    -- ESP & Hitbox
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = v.Character.HumanoidRootPart
            if _G.Set.Hitbox then 
                hrp.Size = Vector3.new(_G.Set.HitboxSize, _G.Set.HitboxSize, _G.Set.HitboxSize)
                hrp.Transparency = 0.7; hrp.CanCollide = false
            else 
                hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 0; hrp.CanCollide = true 
            end
            local hl = v.Character:FindFirstChild("ESPHL") or Instance.new("Highlight", v.Character); hl.Name = "ESPHL"; hl.Enabled = _G.Set.ESP; hl.FillColor = Color3.fromRGB(255, 140, 0)
        end
    end
end)
