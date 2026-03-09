--[[ 
    rzgr1ks DUEL SCRIPT - V117 (ULTRA MICRO EDITION)
    - UPDATE: Drastically reduced UI size for maximum screen visibility.
    - UPDATE: Semi-transparent background.
    - MAINTAINED: All features (Config, ESP, Hitbox, AutoWalk, CounterTP, etc.)
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
    Speed = 30, Jump = 55, HB_Size = 25,
    HB_Enabled = false, ESP_Enabled = false,
    Sword_HB_Enabled = false, Sword_HB_Size = 15,
    KillAura = false, KA_Range = 30,
    CounterTP = false, CustomTP_Pos = nil,
    AutoWalk = false, Walking = false, SelectedSlot = 1, Points = {},
    AntiVoid = false, AutoClick = false, RagdollWalk = false
}

-- 2. CONFIGURATION SYSTEM
local function SaveConfig()
    local config = {
        Speed = _G.Data.Speed, Jump = _G.Data.Jump, 
        HB_Size = _G.Data.HB_Size, Sword_HB_Size = _G.Data.Sword_HB_Size,
        Points = {}
    }
    for i, p in pairs(_G.Data.Points) do
        config.Points[tostring(i)] = {x = p.X, y = p.Y, z = p.Z}
    end
    pcall(function() writefile("rzgr1ks_v117.json", HttpService:JSONEncode(config)) end)
end

local function LoadConfig()
    pcall(function()
        if isfile("rzgr1ks_v117.json") then
            local data = HttpService:JSONDecode(readfile("rzgr1ks_v117.json"))
            _G.Data.Speed = data.Speed or 30; _G.Data.Jump = data.Jump or 55
            _G.Data.HB_Size = data.HB_Size or 25; _G.Data.Sword_HB_Size = data.Sword_HB_Size or 15
            if data.Points then
                for i, p in pairs(data.Points) do
                    _G.Data.Points[tonumber(i)] = Vector3.new(p.x, p.y, p.z)
                end
            end
        end
    end)
end
LoadConfig()

-- 3. UI DESIGN (ULTRA MICRO)
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "rzgr1ks_V117"; gui.ResetOnSpawn = false

-- KÜÇÜCÜK MENÜ BUTONU
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 45, 0, 25); toggleBtn.Position = UDim2.new(0, 5, 0.15, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20); toggleBtn.Text = "MENU"; toggleBtn.TextColor3 = Color3.fromRGB(255,140,0); toggleBtn.TextSize = 10; toggleBtn.Font = "GothamBold"
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,5)
Instance.new("UIStroke", toggleBtn).Color = Color3.fromRGB(255, 140, 0)

-- MİKRO ANA KASA
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 160, 0, 230) -- ÇOK DAHA KÜÇÜK
main.Position = UDim2.new(0.5, -80, 0.5, -115)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
main.BackgroundTransparency = 0.15 -- EKRAN GÖRÜNSÜN DİYE SAYDAM
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", main); Stroke.Thickness = 1.5; Stroke.Color = Color3.fromRGB(255, 140, 0)

toggleBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

-- SÜRÜKLEME
local dragging, dragStart, startPos
main.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = main.Position end end)
UIS.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UIS.InputEnded:Connect(function() dragging = false end)

local container = Instance.new("ScrollingFrame", main); container.Size = UDim2.new(1,-6,1,-6); container.Position = UDim2.new(0,3,0,3); container.BackgroundTransparency = 1; container.ScrollBarThickness = 0; container.CanvasSize = UDim2.new(0,0,0,800)
local layout = Instance.new("UIListLayout", container); layout.Padding = UDim.new(0,3); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- UI HELPERS (MINI)
local function CreateToggle(text, dataKey)
    local b = Instance.new("TextButton", container); b.Size = UDim2.new(1,0,0,22); b.BackgroundColor3 = Color3.fromRGB(25,25,30); b.Text = text .. ": OFF"; b.TextColor3 = Color3.new(1,1,1); b.TextSize = 10; b.Font = "Gotham"; Instance.new("UICorner",b).CornerRadius = UDim.new(0,4)
    b.MouseButton1Click:Connect(function() _G.Data[dataKey] = not _G.Data[dataKey]; b.Text = text .. ": " .. (_G.Data[dataKey] and "ON" or "OFF"); b.TextColor3 = _G.Data[dataKey] and Color3.fromRGB(255,140,0) or Color3.new(1,1,1) end)
end

local function CreateSlider(text, min, max, dataKey)
    local f = Instance.new("Frame", container); f.Size = UDim2.new(1,0,0,28); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = text .. ": " .. _G.Data[dataKey]; l.Size = UDim2.new(1,0,0,12); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 9; l.Font = "Gotham"
    local bar = Instance.new("Frame", f); bar.Size = UDim2.new(1,-4,0,4); bar.Position = UDim2.new(0,2,1,-6); bar.BackgroundColor3 = Color3.fromRGB(40,40,45); Instance.new("UICorner",bar)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((_G.Data[dataKey]-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(255,140,0); Instance.new("UICorner",fill)
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then local conn; conn = UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1); fill.Size = UDim2.new(p, 0, 1, 0); local v = math.floor(min + (max - min) * p); l.Text = text .. ": " .. v; _G.Data[dataKey] = v end end); UIS.InputEnded:Once(function() conn:Disconnect() end) end end)
end

local function CreateBtn(text, color, callback)
    local b = Instance.new("TextButton", container); b.Size = UDim2.new(1,0,0,22); b.BackgroundColor3 = color; b.Text = text; b.TextColor3 = Color3.new(1,1,1); b.TextSize = 10; b.Font = "GothamBold"; Instance.new("UICorner", b).CornerRadius = UDim.new(0,4); b.MouseButton1Click:Connect(callback); return b
end

-- 4. BUTTONS
CreateBtn("SAVE CONFIG", Color3.fromRGB(70, 70, 70), function() SaveConfig() end)
CreateToggle("ESP (See Players)", "ESP_Enabled")
CreateToggle("Hitbox Expander", "HB_Enabled")
CreateSlider("Hitbox Size", 2, 100, "HB_Size")
CreateToggle("God Reach", "Sword_HB_Enabled")
CreateSlider("Reach Size", 2, 1000, "Sword_HB_Size")
CreateToggle("Kill Aura", "KillAura")

local slotBtn = CreateBtn("WALK SLOT: 1", Color3.fromRGB(50, 30, 0), function()
    _G.Data.SelectedSlot = (_G.Data.SelectedSlot % 4) + 1
    slotBtn.Text = "WALK SLOT: " .. _G.Data.SelectedSlot
end)

CreateBtn("SAVE WALK POINT", Color3.fromRGB(0, 70, 130), function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then _G.Data.Points[_G.Data.SelectedSlot] = hrp.Position end
end)

CreateToggle("START AUTO WALK", "AutoWalk")
CreateToggle("Counter-TP", "CounterTP")
CreateBtn("SET REVENGE POS", Color3.fromRGB(130, 0, 0), function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then _G.Data.CustomTP_Pos = hrp.CFrame end
end)

CreateSlider("Walk Speed", 16, 300, "Speed")
CreateSlider("Jump Power", 50, 500, "Jump")
CreateToggle("Ragdoll Walk", "RagdollWalk")

-- 5. AUTO WALK LOGIC
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

-- 6. PHYSICS & COMBAT
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

    -- MOVEMENT
    if not _G.Data.AutoWalk then
        local moveVector = Controls:GetMoveVector()
        if _G.Data.RagdollWalk and moveVector.Magnitude > 0 then
            local cam = workspace.CurrentCamera
            local moveDir = (cam.CFrame.RightVector * moveVector.X) + (cam.CFrame.LookVector * -moveVector.Z)
            hrp.Velocity = Vector3.new(moveDir.X * _G.Data.Speed, hrp.Velocity.Y, moveDir.Z * _G.Data.Speed)
        elseif hum.MoveDirection.Magnitude > 0 then
            hrp.Velocity = Vector3.new(hum.MoveDirection.X * _G.Data.Speed, hrp.Velocity.Y, hum.MoveDirection.Z * _G.Data.Speed)
        end
    end
end)

UIS.JumpRequest:Connect(function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and not _G.Data.AutoWalk then hrp.Velocity = Vector3.new(hrp.Velocity.X, _G.Data.Jump, hrp.Velocity.Z) end
end)

-- 7. PLAYER ESP & HITBOX
RunService.Stepped:Connect(function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local root = v.Character.HumanoidRootPart
            root.Size = _G.Data.HB_Enabled and Vector3.new(_G.Data.HB_Size, _G.Data.HB_Size, _G.Data.HB_Size) or Vector3.new(2,2,1)
            root.Transparency = _G.Data.HB_Enabled and 0.7 or 1; root.CanCollide = false
            
            local esp = v.Character:FindFirstChild("R_ESP")
            if _G.Data.ESP_Enabled and not esp then 
                Instance.new("Highlight", v.Character).Name = "R_ESP"
            elseif not _G.Data.ESP_Enabled and esp then 
                esp:Destroy() 
            end
        end
    end
end)
