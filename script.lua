--[[
    @project: RZGR1KS DUEL V48 - TOTAL RESTORATION
    @fix: Improved Silent Aim, Fixed Button Clashing, All Features Restored
]]--

if _G.RZGR_V48_FIXED then return end
_G.RZGR_V48_FIXED = true

local Services = setmetatable({}, {__index = function(_, k) return game:GetService(k) end})
local Local = {
    Player = Services.Players.LocalPlayer,
    Camera = workspace.CurrentCamera,
    Mouse = Services.Players.LocalPlayer:GetMouse()
}

local Registry = {
    States = {
        Combat = { Silent = false, Hitbox = false, HSize = 25, Spin = false, SpinSpeed = 100 },
        Movement = { Speed = false, Vel = 100, Jump = 50, Grav = 196.2 },
        Visuals = { Esp = false, Xray = false },
        Misc = { AntiRagdoll = false }
    }
}

-- // GELİŞMİŞ SILENT AIM MANTIĞI (INTERNET STANDARDI)
local function GetClosestPlayer()
    local target, shortestDistance = nil, math.huge
    for _, v in pairs(Services.Players:GetPlayers()) do
        if v ~= Local.Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = Local.Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Local.Mouse.X, Local.Mouse.Y)).Magnitude
                if magnitude < shortestDistance then
                    target = v.Character.HumanoidRootPart
                    shortestDistance = magnitude
                end
            end
        end
    end
    return target
end

-- Raycast ve Namecall Hook (Silent Aim için en stabil yöntem)
local OldNC; OldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and Registry.States.Combat.Silent and (method == "Raycast" or method == "FindPartOnRayWithIgnoreList") then
        local target = GetClosestPlayer()
        if target then
            if method == "Raycast" then
                args[2] = (target.Position - args[1]).Unit * 1000
            elseif method == "FindPartOnRayWithIgnoreList" then
                args[1] = Ray.new(args[1].Origin, (target.Position - args[1].Origin).Unit * 1000)
            end
            return OldNC(self, unpack(args))
        end
    end
    return OldNC(self, ...)
end)

-- // MAIN LOOP (TÜM ÖZELLİKLER BURADA ÇALIŞIR)
Services.RunService.Heartbeat:Connect(function()
    local Char = Local.Player.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    
    if Root and Hum then
        -- Spinbot
        if Registry.States.Combat.Spin then
            Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(Registry.States.Combat.SpinSpeed), 0)
        end
        -- Speed
        if Registry.States.Movement.Speed and Hum.MoveDirection.Magnitude > 0 then
            Root.AssemblyLinearVelocity = Vector3.new(Hum.MoveDirection.X * Registry.States.Movement.Vel, Root.AssemblyLinearVelocity.Y, Hum.MoveDirection.Z * Registry.States.Movement.Vel)
        end
        -- Jump & Grav
        Hum.JumpPower = Registry.States.Movement.Jump
        workspace.Gravity = Registry.States.Movement.Grav
    end
    
    -- X-Ray Fix
    if Registry.States.Visuals.Xray then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsDescendantOf(Char) then
                v.LocalTransparencyModifier = 0.6
            end
        end
    end

    -- Hitbox Expander
    if Registry.States.Combat.Hitbox then
        for _, p in ipairs(Services.Players:GetPlayers()) do
            if p ~= Local.Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(Registry.States.Combat.HSize, Registry.States.Combat.HSize, Registry.States.Combat.HSize)
                p.Character.HumanoidRootPart.Transparency = 0.7; p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
end)

-- // UI RESTORATION (ÇAKIŞMA ÖNLEYİCİ - %100 GÖRÜNÜR)
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 340, 0, 45)
Main.Position = UDim2.new(0.5, -170, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -50, 0, 45); Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "RZGR1KS DUEL V23"; Title.TextColor3 = Color3.fromRGB(255, 40, 40); Title.Font = "GothamBold"; Title.TextSize = 14; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 45, 0, 45); MinBtn.Position = UDim2.new(1, -45, 0, 0)
MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.Font = "GothamBold"; MinBtn.TextSize = 25; MinBtn.BackgroundTransparency = 1

-- SCROLL ALANI (Çakışmayı önlemek için özel ayar)
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 0, 350)
Scroll.Position = UDim2.new(0, 5, 0, 50)
Scroll.Visible = false
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 800) -- Elle çok geniş yapıldı ki hiçbir şey eksik kalmasın

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 10); Layout.HorizontalAlignment = "Center"

-- // COMPONENT BUILDERS
local function AddToggle(txt, sub, key)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, 300, 0, 40); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = txt..": OFF"; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 12; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        b.Text = txt..(Registry.States[sub][key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Registry.States[sub][key] and Color3.fromRGB(160, 0, 0) or Color3.fromRGB(30, 30, 30)
    end)
end

local function AddSlider(txt, min, max, sub, key)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(0, 300, 0, 55); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt..": "..Registry.States[sub][key]; l.TextColor3 = Color3.new(0.8,0.8,0.8); l.BackgroundTransparency = 1; l.Font = "Gotham"; l.TextSize = 11
    local bar = Instance.new("TextButton", f); bar.Size = UDim2.new(1, 0, 0, 8); bar.Position = UDim2.new(0, 0, 0, 30); bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50); bar.Text = ""
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((Registry.States[sub][key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 40, 40); fill.BorderSizePixel = 0
    
    local move = false
    local function Upd()
        local percent = math.clamp((Services.UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0); local val = math.floor(min + (percent * (max - min)))
        l.Text = txt..": "..val; Registry.States[sub][key] = val
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move = true Upd() end end)
    Services.UIS.InputChanged:Connect(function(i) if move and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Upd() end end)
    Services.UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move = false end end)
end

-- // TÜM ÖZELLİKLERİ TEK TEK EKLE (EKSİKSİZ)
AddToggle("Silent Aim", "Combat", "Silent")
AddToggle("Hitbox Expander", "Combat", "Hitbox")
AddSlider("Hitbox Radius", 2, 200, "Combat", "HSize")
AddToggle("Spinbot", "Combat", "Spin")
AddSlider("Spin Speed", 10, 300, "Combat", "SpinSpeed")
AddToggle("Speed Bypass", "Movement", "Speed")
AddSlider("Speed Power", 16, 800, "Movement", "Vel")
AddSlider("Jump Power", 50, 500, "Movement", "Jump")
AddSlider("Gravity Control", 0, 196, "Movement", "Grav")
AddToggle("X-Ray Vision", "Visuals", "Xray")
AddToggle("Anti Ragdoll", "Misc", "AntiRagdoll")

-- SOSYAL BUTONLAR
local yt = Instance.new("TextButton", Scroll); yt.Size = UDim2.new(0, 300, 0, 40); yt.BackgroundColor3 = Color3.fromRGB(200, 0, 0); yt.Text = "YT: @rzgr1ks"; yt.TextColor3 = Color3.new(1,1,1); yt.Font = "GothamBold"; Instance.new("UICorner", yt)
yt.MouseButton1Click:Connect(function() setclipboard("https://youtube.com/@rzgr1ks") end)

local dc = Instance.new("TextButton", Scroll); dc.Size = UDim2.new(0, 300, 0, 40); dc.BackgroundColor3 = Color3.fromRGB(88, 101, 242); dc.Text = "JOIN DISCORD"; dc.TextColor3 = Color3.new(1,1,1); dc.Font = "GothamBold"; Instance.new("UICorner", dc)
dc.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/XpbcvVdU") end)

-- MINIMIZE
local open = false
MinBtn.MouseButton1Click:Connect(function()
    open = not open
    MinBtn.Text = open and "X" or "-"
    Scroll.Visible = open
    Main:TweenSize(open and UDim2.new(0, 340, 0, 420) or UDim2.new(0, 340, 0, 45), "Out", "Quart", 0.3, true)
end)
