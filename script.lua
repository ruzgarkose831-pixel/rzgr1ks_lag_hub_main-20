--[[
    @project: RZGR1KS DUEL V48 - NO CLASH FIX
    @owner: rzgr1ks
    @fix: UI Padding & Canvas Auto-Adjustment
]]--

if _G.RZGR_NO_CLASH_LOADED then return end
_G.RZGR_NO_CLASH_LOADED = true

local Services = setmetatable({}, {__index = function(_, k) return game:GetService(k) end})
local Local = { Player = Services.Players.LocalPlayer }

local Registry = {
    States = {
        Combat = { Silent = false, Hitbox = false, HSize = 25, Spin = false, SpinSpeed = 50 },
        Movement = { Speed = false, Vel = 100, Jump = 50, Grav = 196.2 },
        Visuals = { Esp = false, Xray = false },
        Misc = { AntiRagdoll = false }
    }
}

-- // CORE LOGIC (SILENT, SPEED, JUMP, SPIN)
Services.RunService.Heartbeat:Connect(function()
    local Char = Local.Player.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    
    if Root and Hum then
        if Registry.States.Combat.Spin then Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(Registry.States.Combat.SpinSpeed), 0) end
        if Registry.States.Movement.Speed and Hum.MoveDirection.Magnitude > 0 then
            Root.AssemblyLinearVelocity = Vector3.new(Hum.MoveDirection.X * Registry.States.Movement.Vel, Root.AssemblyLinearVelocity.Y, Hum.MoveDirection.Z * Registry.States.Movement.Vel)
        end
        Hum.JumpPower = Registry.States.Movement.Jump
        workspace.Gravity = Registry.States.Movement.Grav
    end
    
    if Registry.States.Visuals.Xray then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(Char) then v.LocalTransparencyModifier = 0.6 end
        end
    end
end)

-- // UI CONSTRUCTION (ORİJİNAL SİYAH BAR - ÇAKIŞMA ÖNLEYİCİ)
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Name = "RZGR_Main"
Main.Size = UDim2.new(0, 330, 0, 45) -- Başlangıç boyutu (İnce bar)
Main.Position = UDim2.new(0.5, -165, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true -- Mobil taşıma aktif
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -50, 0, 45); Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "RZGR1KS DUEL V23"; Title.TextColor3 = Color3.fromRGB(255, 40, 40); Title.Font = "GothamBold"; Title.TextSize = 14; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 45, 0, 45); MinBtn.Position = UDim2.new(1, -45, 0, 0)
MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.Font = "GothamBold"; MinBtn.TextSize = 25; MinBtn.BackgroundTransparency = 1

-- // ÇAKIŞMAYI ÖNLEYEN SCROLL ALANI
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Name = "ButtonContainer"
Scroll.Size = UDim2.new(1, -20, 0, 320) -- Yükseklik sabitlendi
Scroll.Position = UDim2.new(0, 10, 0, 50)
Scroll.Visible = false
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
Scroll.BorderSizePixel = 0
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y -- İçerik arttıkça sayfa uzar
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ClipsDescendants = true -- Dışarı taşmayı engeller

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 12) -- Butonlar arası boşluk
Layout.HorizontalAlignment = "Center"
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- // SLIDER & TOGGLE BUILDER (TOUCH COMPATIBLE)
local function AddToggle(txt, sub, key)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, 290, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.Text = txt..": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"
    Instance.new("UICorner", b)
    
    b.MouseButton1Click:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        b.Text = txt..(Registry.States[sub][key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Registry.States[sub][key] and Color3.fromRGB(160, 0, 0) or Color3.fromRGB(30, 30, 30)
    end)
end

local function AddSlider(txt, min, max, sub, key)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(0, 290, 0, 55); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt..": "..Registry.States[sub][key]; l.TextColor3 = Color3.new(0.8,0.8,0.8); l.BackgroundTransparency = 1; l.Font = "Gotham"; l.TextSize = 11
    
    local bar = Instance.new("TextButton", f); bar.Size = UDim2.new(1, 0, 0, 8); bar.Position = UDim2.new(0, 0, 0, 30); bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50); bar.Text = ""
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((Registry.States[sub][key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 40, 40); fill.BorderSizePixel = 0
    
    local isMoving = false
    local function Update()
        local input = Services.UIS:GetMouseLocation()
        local relX = math.clamp((input.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        local val = math.floor(min + (relX * (max - min)))
        l.Text = txt..": "..val; Registry.States[sub][key] = val
    end

    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isMoving = true Update() end end)
    Services.UIS.InputChanged:Connect(function(i) if isMoving and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update() end end)
    Services.UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isMoving = false end end)
end

-- // MINIMIZE LOGIC
local expanded = false
MinBtn.MouseButton1Click:Connect(function()
    expanded = not expanded
    MinBtn.Text = expanded and "X" or "-"
    Scroll.Visible = expanded
    Main:TweenSize(expanded and UDim2.new(0, 330, 0, 400) or UDim2.new(0, 330, 0, 45), "Out", "Quart", 0.3, true)
end)

-- // LOAD ALL FEATURES (CLASH-FREE)
AddToggle("Silent Aim", "Combat", "Silent")
AddToggle("Hitbox Expander", "Combat", "Hitbox")
AddSlider("Hitbox Size", 2, 200, "Combat", "HSize")
AddToggle("Spinbot", "Combat", "Spin")
AddSlider("Spin Speed", 10, 200, "Combat", "SpinSpeed")
AddToggle("Speed Mode", "Movement", "Speed")
AddSlider("Walk Speed", 16, 800, "Movement", "Vel")
AddSlider("Jump Power", 50, 500, "Movement", "Jump")
AddSlider("Gravity", 0, 196, "Movement", "Grav")
AddToggle("X-Ray Vision", "Visuals", "Xray")
AddToggle("Anti Ragdoll", "Misc", "AntiRagdoll")

-- // SOCIALS
local yt = Instance.new("TextButton", Scroll); yt.Size = UDim2.new(0, 290, 0, 40); yt.BackgroundColor3 = Color3.fromRGB(200, 0, 0); yt.Text = "YT: @rzgr1ks"; yt.TextColor3 = Color3.new(1,1,1); yt.Font = "GothamBold"; Instance.new("UICorner", yt)
yt.MouseButton1Click:Connect(function() setclipboard("https://youtube.com/@rzgr1ks") end)

local dc = Instance.new("TextButton", Scroll); dc.Size = UDim2.new(0, 290, 0, 40); dc.BackgroundColor3 = Color3.fromRGB(88, 101, 242); dc.Text = "JOIN DISCORD"; dc.TextColor3 = Color3.new(1,1,1); dc.Font = "GothamBold"; Instance.new("UICorner", dc)
dc.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/XpbcvVdU") end)
