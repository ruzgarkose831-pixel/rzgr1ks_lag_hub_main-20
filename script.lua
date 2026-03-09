--[[ 
    rzgr1ks DUEL SCRIPT - V120 (THE ETERNAL BRAINROT EDITION)
    - HİÇBİR ÖZELLİK SİLİNMEDİ.
    - TÜM ESKİ VE YENİ ÖZELLİKLER TEK BİR MİKRO MENÜDE.
    - AUTO-AFK, CONFIG, ESP, HITBOX, AUTO-WALK, COUNTER-TP, RAGDOLL WALK...
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local PlayerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local Controls = PlayerModule:GetControls()

-- 1. GLOBAL DATA (TÜM AYARLAR BURADA)
_G.Data = {
    Speed = 45, Jump = 60, Gravity = 196.2,
    HB_Size = 25, HB_Enabled = false, 
    Sword_HB_Enabled = false, Sword_HB_Size = 25,
    KillAura = false, KA_Range = 35,
    CounterTP = false, CustomTP_Pos = nil,
    SpinBot = false, SpinSpeed = 25,
    AntiVoid = false, ESP_Enabled = false,
    AutoWalk = false, SelectedSlot = 1, Points = {},
    RagdollWalk = false, AutoClick = true
}

-- 2. ANTI-AFK (Sistemden Atılmanı Önler)
pcall(function()
    player.Idled:Connect(function() 
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)
end)

-- 3. CONFIGURATION (AYARLARI KAYDET/YÜKLE)
local function SaveConfig()
    local config = {
        Speed = _G.Data.Speed, Jump = _G.Data.Jump, 
        HB_Size = _G.Data.HB_Size, Sword_HB_Size = _G.Data.Sword_HB_Size,
        Points = {}
    }
    for i, p in pairs(_G.Data.Points) do
        config.Points[tostring(i)] = {x = p.X, y = p.Y, z = p.Z}
    end
    pcall(function() writefile("rzgr1ks_v120.json", HttpService:JSONEncode(config)) end)
end

local function LoadConfig()
    pcall(function()
        if isfile("rzgr1ks_v120.json") then
            local data = HttpService:JSONDecode(readfile("rzgr1ks_v120.json"))
            _G.Data.Speed = data.Speed or 45; _G.Data.Jump = data.Jump or 60
            _G.Data.HB_Size = data.HB_Size or 25; _G.Data.Sword_HB_Size = data.Sword_HB_Size or 25
            if data.Points then
                for i, p in pairs(data.Points) do
                    _G.Data.Points[tonumber(i)] = Vector3.new(p.x, p.y, p.z)
                end
            end
        end
    end)
end
LoadConfig()

-- 4. UI (ULTRA MİKRO SİSTEM)
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "rzgr1ks_V120"; gui.ResetOnSpawn = false

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 50, 0, 25); toggleBtn.Position = UDim2.new(0, 5, 0.1, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15); toggleBtn.Text = "MENU"; toggleBtn.TextColor3 = Color3.new(1,0,0); toggleBtn.TextSize = 10; toggleBtn.Font = "GothamBold"
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,5); Instance.new("UIStroke", toggleBtn).Color = Color3.new(1,0,0)

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 165, 0, 280); main.Position = UDim2.new(0.5, -82, 0.5, -140); main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); main.BackgroundTransparency = 0.1
main.Visible = false; Instance.new("UICorner", main); Instance.new("UIStroke", main).Color = Color3.new(1,0,0)

toggleBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

local container = Instance.new("ScrollingFrame", main); container.Size = UDim2.new(1,-6,1,-6); container.Position = UDim2.new(0,3,0,3); container.BackgroundTransparency = 1; container.ScrollBarThickness = 0; container.CanvasSize = UDim2.new(0,0,0,1200)
local layout = Instance.new("UIListLayout", container); layout.Padding = UDim.new(0,3); layout.HorizontalAlignment = "Center"

-- UI YARDIMCILARI
local function CreateToggle(text, dataKey)
    local b = Instance.new("TextButton", container); b.Size = UDim2.new(1,0,0,24); b.BackgroundColor3 = Color3.fromRGB(20,20,20); b.Text = text .. ": OFF"; b.TextColor3 = Color3.new(1,1,1); b.TextSize = 10; Instance.new("UICorner",b)
    b.MouseButton1Click:Connect(function() _G.Data[dataKey] = not _G.Data[dataKey]; b.Text = text .. ": " .. (_G.Data[dataKey] and "ON" or "OFF"); b.TextColor3 = _G.Data[dataKey] and Color3.new(1,0,0) or Color3.new(1,1,1) end)
end

local function CreateSlider(text, min, max, dataKey)
    local f = Instance.new("Frame", container); f.Size = UDim2.new(1,0,0,30); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = text .. ": " .. _G.Data[dataKey]; l.Size = UDim2.new(1,0,0,12); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 9
    local bar = Instance.new("Frame", f); bar.Size = UDim2.new(1,-10,0,4); bar.Position = UDim2.new(0,5,1,-6); bar.BackgroundColor3 = Color3.fromRGB(40,40,40); Instance.new("UICorner",bar)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((_G.Data[dataKey]-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.new(1,0,0); Instance.new("UICorner",fill)
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then local conn; conn = UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1); fill.Size = UDim2.new(p, 0, 1, 0); local v = math.floor(min + (max - min) * p); l.Text = text .. ": " .. v; _G.Data[dataKey] = v end end); UIS.InputEnded:Once(function() conn:Disconnect() end) end end)
end

local function CreateBtn(text, color, callback)
    local b = Instance.new("TextButton", container); b.Size = UDim2.new(1,0,0,24); b.BackgroundColor3 = color; b.Text = text; b.TextColor3 = Color3.new(1,1,1); b.TextSize = 10; b.Font = "GothamBold"; Instance.new("UICorner", b); b.MouseButton1Click:Connect(callback)
end

-- 5. BUTTONS (TÜM ESKİLER)
CreateBtn("SAVE CONFIG", Color3.fromRGB(60, 60, 60), SaveConfig)
CreateToggle("KILL AURA", "KillAura")
CreateToggle("GOD REACH (Bat)", "Sword_HB_Enabled")
CreateSlider("Reach Size", 2, 1000, "Sword_HB_Size")
CreateToggle("COUNTER TP", "CounterTP")
CreateBtn("SET REVENGE POS", Color3.fromRGB(150, 0, 0), function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then _G.Data.CustomTP_Pos = player.Character.HumanoidRootPart.CFrame end end)
CreateToggle("ESP (See Players)", "ESP_Enabled")
CreateToggle("Hitbox Expander", "HB_Enabled")
CreateSlider("HB Size", 2, 100, "HB_Size")
CreateToggle("RAGDOLL WALK (Force)", "RagdollWalk")
CreateToggle("SPIN BOT", "SpinBot")
CreateToggle("ANTI-VOID", "AntiVoid")
local slotBtn = CreateBtn("WALK SLOT: 1", Color3.fromRGB(60, 40, 0), function() _G.Data.SelectedSlot = (_G.Data.SelectedSlot % 4) + 1; slotBtn.Text = "WALK SLOT: " .. _G.Data.SelectedSlot end)
CreateBtn("SAVE WALK POINT", Color3.fromRGB(0, 80, 150), function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then _G.Data.Points[_G.Data.SelectedSlot] = player.Character.HumanoidRootPart.Position end end)
CreateToggle("AUTO WALK", "AutoWalk")
CreateSlider("SPEED", 16, 400, "Speed")
CreateSlider("JUMP", 50, 500, "Jump")

-- 6. CORE ENGINE (SÜPER MOTOR)
RunService.Stepped:Connect(function()
    local char = player.Character if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not (hrp and hum) then return end

    -- SWORD/BAT REACH & AURA
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        if _G.Data.Sword_HB_Enabled then
            for _, v in pairs(tool:GetDescendants()) do
                if v:IsA("BasePart") then v.Size = Vector3.new(_G.Data.Sword_HB_Size, _G.Data.Sword_HB_Size, _G.Data.Sword_HB_Size); v.Transparency = 0.8; v.CanCollide = false; v.Massless = true end
            end
        end
        if _G.Data.KillAura then tool:Activate() end
    end

    -- COUNTER-TP & ANTI-VOID
    if _G.Data.CounterTP and _G.Data.CustomTP_Pos and (hum.PlatformStand or hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum.Sit) then
        hrp.CFrame = _G.Data.CustomTP_Pos; hrp.Velocity = Vector3.new(0,0,0); task.wait(0.1); hum:ChangeState(Enum.HumanoidStateType.GettingUp); hum.PlatformStand = false
    end
    if _G.Data.AntiVoid and hrp.Position.Y < -60 then hrp.CFrame = _G.Data.CustomTP_Pos or CFrame.new(0, 50, 0); hrp.Velocity = Vector3.new(0,0,0) end

    -- RAGDOLL WALK & SPIN BOT
    if _G.Data.RagdollWalk then
        local move = Controls:GetMoveVector()
        if move.Magnitude > 0 then
            local cam = workspace.CurrentCamera
            local moveDir = (cam.CFrame.RightVector * move.X) + (cam.CFrame.LookVector * -move.Z)
            hrp.CFrame = hrp.CFrame + Vector3.new(moveDir.X, 0, moveDir.Z) * (_G.Data.Speed / 50)
        end
    end
    if _G.Data.SpinBot then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(_G.Data.SpinSpeed), 0) end
end)

-- 7. AUTO WALK ENGINE
task.spawn(function()
    while task.wait(0.1) do
        if _G.Data.AutoWalk and player.Character then
            for i = 1, 4 do
                local target = _G.Data.Points[i]
                if not _G.Data.AutoWalk then break end
                if target then
                    local h = player.Character:FindFirstChild("Humanoid")
                    local hr = player.Character:FindFirstChild("HumanoidRootPart")
                    if h and hr then
                        while _G.Data.AutoWalk and (hr.Position - target).Magnitude > 5 do
                            h:MoveTo(target); task.wait(0.1)
                        end
                    end
                end
            end
        end
    end
end)

-- 8. ESP & HITBOX
RunService.Heartbeat:Connect(function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local root = v.Character.HumanoidRootPart
            root.Size = _G.Data.HB_Enabled and Vector3.new(_G.Data.HB_Size, _G.Data.HB_Size, _G.Data.HB_Size) or Vector3.new(2,2,1)
            root.Transparency = _G.Data.HB_Enabled and 0.7 or 1; root.CanCollide = false
            local esp = v.Character:FindFirstChild("R_ESP")
            if _G.Data.ESP_Enabled and not esp then Instance.new("Highlight", v.Character).Name = "R_ESP"
            elseif not _G.Data.ESP_Enabled and esp then esp:Destroy() end
        end
    end
end)
