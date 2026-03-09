--[[ 
    rzgr1ks DUEL SCRIPT - V125 (LEMON EMOJI UPDATE)
    - NEW: Lemon Emoji Toggle (Menüyü kapatmak yerine 🍋 emojisine küçültür)
    - STYLE: Classic Lemon (Yellow & Dark Grey)
    - FIXED: Huge Sliders for Mobile
    - FIXED: Stats persistence after death
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local PlayerModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local Controls = PlayerModule:GetControls()

-- 1. GLOBAL DATA
_G.Data = {
    Speed = 45, Jump = 65, Gravity = 196.2,
    HB_Size = 25, HB_Enabled = false,
    Sword_HB_Enabled = false, Sword_HB_Size = 25,
    KillAura = false, SpinBot = false, SpinSpeed = 35,
    CounterTP = false, CustomTP_Pos = nil,
    AutoWalk = false, Points = {}, SelectedSlot = 1,
    FloatEnabled = false, FloatOffset = -3.5,
    RagdollWalk = false, AntiVoid = false
}

-- 2. LEMON UI COLORS
local LEMON_YELLOW = Color3.fromRGB(255, 230, 0)
local DARK_BG = Color3.fromRGB(20, 20, 20)
local LIGHT_BG = Color3.fromRGB(35, 35, 35)

-- 3. UI CONSTRUCTION
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui")); gui.Name = "LemonV125"; gui.ResetOnSpawn = false

-- LEMON EMOJI TOGGLE (Ikon)
local lemonBtn = Instance.new("TextButton", gui)
lemonBtn.Size = UDim2.new(0, 50, 0, 50); lemonBtn.Position = UDim2.new(0, 10, 0.5, -25)
lemonBtn.BackgroundColor3 = DARK_BG; lemonBtn.Text = "🍋"; lemonBtn.TextSize = 30
lemonBtn.BorderSizePixel = 0; Instance.new("UICorner", lemonBtn).CornerRadius = UDim.new(0, 25)
local lemonStroke = Instance.new("UIStroke", lemonBtn); lemonStroke.Color = LEMON_YELLOW; lemonStroke.Thickness = 2

-- MAIN FRAME
local main = Instance.new("Frame", gui); main.Size = UDim2.new(0, 190, 0, 320); main.Position = UDim2.new(0.5, -95, 0.5, -160); main.BackgroundColor3 = DARK_BG; main.Visible = false; main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", main).Color = LEMON_YELLOW

-- Toggle Script
lemonBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
    lemonBtn.Visible = not main.Visible
end)

-- Header (İçeriden Kapatma Butonu Yerine Limona Dönüş)
local header = Instance.new("TextButton", main); header.Size = UDim2.new(1, 0, 0, 30); header.BackgroundColor3 = LIGHT_BG; header.Text = "CLOSE (BACK TO 🍋)"; header.TextColor3 = LEMON_YELLOW; header.Font = "GothamBold"; header.TextSize = 12
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)
header.MouseButton1Click:Connect(function() main.Visible = false; lemonBtn.Visible = true end)

local container = Instance.new("ScrollingFrame", main); container.Size = UDim2.new(1, -10, 1, -40); container.Position = UDim2.new(0, 5, 0, 35); container.BackgroundTransparency = 1; container.ScrollBarThickness = 2; container.CanvasSize = UDim2.new(0, 0, 0, 1500)
Instance.new("UIListLayout", container).Padding = UDim.new(0, 5)

-- UI HELPERS
local function CreateToggle(text, dataKey)
    local b = Instance.new("TextButton", container); b.Size = UDim2.new(1, 0, 0, 32); b.BackgroundColor3 = LIGHT_BG; b.Text = text .. ": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 11; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() 
        _G.Data[dataKey] = not _G.Data[dataKey]
        b.Text = text .. ": " .. (_G.Data[dataKey] and "ON" or "OFF")
        b.TextColor3 = _G.Data[dataKey] and LEMON_YELLOW or Color3.new(1,1,1)
    end)
end

local function CreateSlider(text, min, max, dataKey, callback)
    local f = Instance.new("Frame", container); f.Size = UDim2.new(1, 0, 0, 50); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = text .. ": " .. _G.Data[dataKey]; l.Size = UDim2.new(1, 0, 0, 20); l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Font = "GothamBold"; l.TextSize = 11
    local bar = Instance.new("Frame", f); bar.Size = UDim2.new(1, -10, 0, 12); bar.Position = UDim2.new(0, 5, 1, -18); bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Instance.new("UICorner", bar)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((_G.Data[dataKey]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = LEMON_YELLOW; Instance.new("UICorner", fill)
    
    bar.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            local conn; conn = UIS.InputChanged:Connect(function(i) 
                if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then 
                    local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(p, 0, 1, 0)
                    local v = math.floor(min + (max - min) * p)
                    l.Text = text .. ": " .. v; _G.Data[dataKey] = v
                    if callback then callback(v) end 
                end 
            end)
            UIS.InputEnded:Once(function() conn:Disconnect() end) 
        end 
    end)
end

-- 4. BUTTONS
CreateToggle("KILL AURA", "KillAura")
CreateToggle("GOD REACH", "Sword_HB_Enabled")
CreateSlider("Reach Size", 2, 300, "Sword_HB_Size")
CreateToggle("HITBOX", "HB_Enabled")
CreateSlider("HB Size", 2, 120, "HB_Size")
CreateToggle("FLOAT PLATFORM", "FloatEnabled")
CreateSlider("Float Offset", -15, 20, "FloatOffset")
CreateSlider("SPEED", 16, 500, "Speed")
CreateSlider("JUMP", 50, 800, "Jump")
CreateToggle("SPIN BOT", "SpinBot")
CreateToggle("AUTO WALK", "AutoWalk")
CreateToggle("ANTI-VOID", "AntiVoid")

-- 5. CORE ENGINE
local floatPart = Instance.new("Part", workspace); floatPart.Size = Vector3.new(10, 1, 10); floatPart.Transparency = 1; floatPart.Anchored = true
player.CharacterAdded:Connect(function() task.wait(0.5); workspace.Gravity = _G.Data.Gravity end)

RunService.Heartbeat:Connect(function()
    local char = player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid")
    if not (hrp and hum) then return end

    if _G.Data.FloatEnabled then floatPart.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + _G.Data.FloatOffset, hrp.Position.Z); floatPart.CanCollide = true else floatPart.CanCollide = false end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and _G.Data.Sword_HB_Enabled then
        if _G.Data.KillAura then tool:Activate() end
        for _, p in pairs(tool:GetDescendants()) do if p:IsA("BasePart") then p.Size = Vector3.new(_G.Data.Sword_HB_Size, _G.Data.Sword_HB_Size, _G.Data.Sword_HB_Size); p.Transparency = 0.8; p.CanCollide = false end end
    end

    if not _G.Data.AutoWalk and hum.MoveDirection.Magnitude > 0 then
        hrp.Velocity = Vector3.new(hum.MoveDirection.X * _G.Data.Speed, hrp.Velocity.Y, hum.MoveDirection.Z * _G.Data.Speed)
    end
end)

UIS.JumpRequest:Connect(function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and not _G.Data.AutoWalk then hrp.Velocity = Vector3.new(hrp.Velocity.X, _G.Data.Jump, hrp.Velocity.Z) end
end)

RunService.Stepped:Connect(function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local root = v.Character.HumanoidRootPart
            root.Size = _G.Data.HB_Enabled and Vector3.new(_G.Data.HB_Size, _G.Data.HB_Size, _G.Data.HB_Size) or Vector3.new(2,2,1)
            root.Transparency = _G.Data.HB_Enabled and 0.7 or 1; root.CanCollide = false
        end
    end
end)

-- SAVE/CLEAR FOR AUTO WALK
local setBtn = Instance.new("TextButton", container); setBtn.Size = UDim2.new(1, 0, 0, 32); setBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0); setBtn.Text = "SET WALK POINT"; setBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", setBtn)
setBtn.MouseButton1Click:Connect(function() table.insert(_G.Data.Points, player.Character.HumanoidRootPart.Position) end)

local clearBtn = Instance.new("TextButton", container); clearBtn.Size = UDim2.new(1, 0, 0, 32); clearBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0); clearBtn.Text = "CLEAR POINTS"; clearBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", clearBtn)
clearBtn.MouseButton1Click:Connect(function() _G.Data.Points = {} end)
