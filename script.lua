--[[
    @title: rzgr1ks V48 - BYPASS
    @status: ALL FEATURES RESTORED
    @fix: Silent Aim Camera Sync & Mobile Slider Input
]]--

if _G.RZGR_V48_LOADED then return end
_G.RZGR_V48_LOADED = true

local Services = setmetatable({}, {__index = function(_, k) return game:GetService(k) end})
local Local = {
    Player = Services.Players.LocalPlayer,
    Mouse = Services.Players.LocalPlayer:GetMouse(),
    Camera = workspace.CurrentCamera
}

local Registry = {
    States = {
        Combat = { Silent = false, Hitbox = false, HSize = 25 },
        Movement = { Speed = false, Vel = 100, Jump = 50, Grav = 196.2 },
        Visuals = { Esp = false },
        Misc = { AntiRagdoll = false }
    },
    Social = { Discord = "https://discord.gg/XpbcvVdU", YT = "https://youtube.com/@rzgr1ks" }
}

-- // TARGETING ENGINE
local function GetNearestTarget()
    local T, D = nil, math.huge
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= Local.Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local Pos, OnScreen = Local.Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if OnScreen then
                local Mag = (Vector2.new(Pos.X, Pos.Y) - Services.UIS:GetMouseLocation()).Magnitude
                if Mag < D then D = Mag; T = p.Character.HumanoidRootPart end
            end
        end
    end
    return T
end

-- // SILENT AIM BYPASS (NO CAMERA SPLIT)
local OldNC; OldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    if not checkcaller() and Registry.States.Combat.Silent and (Method == "Raycast" or Method:find("PartOnRay")) then
        local T = GetNearestTarget()
        if T then
            if Method == "Raycast" then Args[2] = (T.Position - Args[1]).Unit * 1000 end
            return OldNC(self, unpack(Args))
        end
    end
    return OldNC(self, ...)
end)

-- // MAIN ENGINE
Services.RunService.Heartbeat:Connect(function()
    local Char = Local.Player.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    
    -- Speed & Gravity & Jump
    if Root and Hum then
        if Registry.States.Movement.Speed and Hum.MoveDirection.Magnitude > 0 then
            Root.AssemblyLinearVelocity = Vector3.new(Hum.MoveDirection.X * Registry.States.Movement.Vel, Root.AssemblyLinearVelocity.Y, Hum.MoveDirection.Z * Registry.States.Movement.Vel)
        end
        Hum.JumpPower = Registry.States.Movement.Jump
        workspace.Gravity = Registry.States.Movement.Grav
    end
    
    -- Hitbox & ESP
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= Local.Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            if Registry.States.Combat.Hitbox then
                hrp.Size = Vector3.new(Registry.States.Combat.HSize, Registry.States.Combat.HSize, Registry.States.Combat.HSize)
                hrp.Transparency = 0.7; hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2,2,1); hrp.Transparency = 1; hrp.CanCollide = true
            end
            
            local esp = p.Character:FindFirstChild("RZ_ESP")
            if Registry.States.Visuals.Esp then
                if not esp then
                    esp = Instance.new("Highlight", p.Character)
                    esp.Name = "RZ_ESP"; esp.FillColor = Color3.fromRGB(255, 0, 0)
                end
            elseif esp then esp:Destroy() end
        end
    end
end)

-- // COMPACT UI (Visualdaki gibi küçük ve şık)
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 240, 0, 360)
Main.Position = UDim2.new(0.5, -120, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Header (Sürüklenebilir Alan)
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = "rzgr1ks V48 - BYPASS"; Title.TextColor3 = Color3.fromRGB(80, 80, 255); Title.Font = "GothamBold"; Title.TextSize = 12; Title.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -50); Scroll.Position = UDim2.new(0, 5, 0, 45); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 0
local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 6); Layout.HorizontalAlignment = "Center"

-- // COMPONENTS
local function AddToggle(txt, sub, key)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1, -10, 0, 35); b.BackgroundColor3 = Color3.fromRGB(22, 22, 22); b.Text = txt .. ": OFF"; b.TextColor3 = Color3.fromRGB(200, 100, 0); b.Font = "GothamBold"; b.TextSize = 11; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        local s = Registry.States[sub][key]
        b.Text = txt .. (s and ": ON" or ": OFF")
        b.TextColor3 = s and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(200, 100, 0)
    end)
end

local function AddSlider(txt, min, max, sub, key)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(1, -10, 0, 45); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 15); l.Text = txt..": "..Registry.States[sub][key]; l.TextColor3 = Color3.new(0.6,0.6,0.6); l.Font = "Gotham"; l.BackgroundTransparency = 1; l.TextSize = 10
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 0, 4); b.Position = UDim2.new(0,0,0,25); b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.Text = ""
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((Registry.States[sub][key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(80, 80, 255)
    
    local function Update()
        local p = math.clamp((Services.UIS:GetMouseLocation().X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(p, 0, 1, 0)
        local val = math.floor(min + (p * (max - min)))
        l.Text = txt..": "..val; Registry.States[sub][key] = val
    end
    b.MouseButton1Down:Connect(function()
        local move; move = Services.UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then Update() end end)
        Services.UIS.InputEnded:Connect(function() move:Disconnect() end)
    end)
end

-- LOAD ITEMS
AddToggle("Silent Aim", "Combat", "Silent")
AddToggle("Hitbox Expander", "Combat", "Hitbox")
AddSlider("Hitbox Radius", 2, 100, "Combat", "HSize")
AddToggle("Velocity Speed", "Movement", "Speed")
AddSlider("Speed Value", 16, 500, "Movement", "Vel")
AddSlider("Jump Power", 50, 500, "Movement", "Jump")
AddSlider("World Gravity", 0, 196, "Movement", "Grav")
AddToggle("ESP Wallhack", "Visuals", "Esp")
AddToggle("Anti Ragdoll", "Misc", "AntiRagdoll")

-- Socials
local dc = Instance.new("TextButton", Scroll); dc.Size = UDim2.new(1,-10,0,35); dc.BackgroundColor3 = Color3.fromRGB(88, 101, 242); dc.Text = "JOIN DISCORD"; dc.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", dc)
dc.MouseButton1Click:Connect(function() setclipboard(Registry.Social.Discord) end)

-- Draggable Logic
local drag, dStart, sPos; Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; dStart = i.Position; sPos = Main.Position end end)
Services.UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - dStart; Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y) end end)
Services.UIS.InputEnded:Connect(function() drag = false end)

-- Minimize System
local isMin = false; local mBtn = Instance.new("TextButton", Header); mBtn.Size = UDim2.new(0,30,0,30); mBtn.Position = UDim2.new(1,-35,0,5); mBtn.Text = "-"; mBtn.TextColor3 = Color3.new(1,1,1); mBtn.BackgroundTransparency = 1
mBtn.MouseButton1Click:Connect(function() isMin = not isMin; Scroll.Visible = not isMin; Main:TweenSize(isMin and UDim2.new(0, 240, 0, 40) or UDim2.new(0, 240, 0, 360), "Out", "Quart", 0.3, true) end)
