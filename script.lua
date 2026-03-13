--[[ 
    RZGR1KS DUEL PROJECT - ULTIMATE FRAMEWORK
    BRANDED FOR YT: rzgr1ks & DC: discord.gg/XpbcvVdU
]]--

-- // Framework Sentinel & Services
if _G.RZGR_LOADED then return end
_G.RZGR_LOADED = true

local Libs = {
    Players = game:GetService("Players"),
    Run = game:GetService("RunService"),
    UIS = game:GetService("UserInputService"),
    Http = game:GetService("HttpService"),
    CoreGui = game:GetService("CoreGui")
}

local Local = {
    Player = Libs.Players.LocalPlayer,
    Mouse = Libs.Players.LocalPlayer:GetMouse(),
    Camera = workspace.CurrentCamera
}

local Registry = {
    Social = {
        YouTube = "https://youtube.com/@rzgr1ks",
        Discord = "https://discord.gg/XpbcvVdU"
    },
    States = {
        Combat = { Silent = false, Hitbox = false, HSize = 2 },
        Movement = { Speed = false, Vel = 16 },
        Visuals = { Esp = false }
    }
}

-- // CORE LOGIC (Silent Aim & Hitbox)
local function GetTarget()
    local Target = nil
    local Dist = math.huge
    for _, p in ipairs(Libs.Players:GetPlayers()) do
        if p ~= Local.Player and p.Character and p.Character:FindFirstChild("Head") then
            if p.Team ~= Local.Player.Team then
                local Pos, OnScreen = Local.Camera:WorldToViewportPoint(p.Character.Head.Position)
                if OnScreen then
                    local Mag = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Local.Mouse.X, Local.Mouse.Y)).Magnitude
                    if Mag < Dist then Dist = Mag; Target = p.Character.Head end
                end
            end
        end
    end
    return Target
end

local OldNC; OldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    if not checkcaller() and Registry.States.Combat.Silent and (Method == "FindPartOnRayWithIgnoreList" or Method == "Raycast") then
        local T = GetTarget()
        if T then return T, T.Position, T.CFrame.p, T.Material end
    end
    return OldNC(self, ...)
end)

Libs.Run.Heartbeat:Connect(function()
    local Char = Local.Player.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    
    if Root and Hum and Registry.States.Movement.Speed and Hum.MoveDirection.Magnitude > 0 then
        Root.AssemblyLinearVelocity = Vector3.new(Hum.MoveDirection.X * Registry.States.Movement.Vel, Root.AssemblyLinearVelocity.Y, Hum.MoveDirection.Z * Registry.States.Movement.Vel)
    end
    
    for _, p in ipairs(Libs.Players:GetPlayers()) do
        if p ~= Local.Player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if Registry.States.Combat.Hitbox then
                    hrp.Size = Vector3.new(Registry.States.Combat.HSize, Registry.States.Combat.HSize, Registry.States.Combat.HSize)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                else
                    hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1; hrp.CanCollide = true
                end
            end
        end
    end
end)

-- // INTERFACE ENGINE
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Libs.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 300, 0, 480)
Main.Position = UDim2.new(0.5, -150, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", Main)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -60)
Scroll.Position = UDim2.new(0, 5, 0, 50)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 0
local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 5); Layout.HorizontalAlignment = "Center"

-- Title & Header
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40); Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Header)
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0); Title.Text = "RZGR1KS DUEL | YT: rzgr1ks"; Title.TextColor3 = Color3.fromRGB(255, 40, 40); Title.Font = "GothamBold"; Title.BackgroundTransparency = 1

-- // BUTTON BUILDERS
local function AddToggle(txt, sub, key)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, 280, 0, 40); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = txt .. ": OFF"; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        b.Text = txt .. (Registry.States[sub][key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Registry.States[sub][key] and Color3.fromRGB(100, 20, 20) or Color3.fromRGB(30, 30, 30)
    end)
end

-- // SOCIAL BUTTONS (WITH AUTO-COPY)
local function AddSocial(txt, link, color)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, 280, 0, 45); b.BackgroundColor3 = color; b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; Instance.new("UICorner", b)
    
    b.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(link)
            local oldTxt = b.Text
            b.Text = "LINK KOPYALANDI!"
            b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            b.TextColor3 = Color3.new(0, 0, 0)
            task.wait(1.5)
            b.Text = oldTxt
            b.BackgroundColor3 = color
            b.TextColor3 = Color3.new(1, 1, 1)
        end
    end)
end

-- Load Items
AddToggle("Silent Aim", "Combat", "Silent")
AddToggle("Ghost Hitbox", "Combat", "Hitbox")
AddToggle("Velocity Speed", "Movement", "Speed")

-- Socials
AddSocial("SUBSCRIBE YOUTUBE", Registry.Social.YouTube, Color3.fromRGB(200, 0, 0))
AddSocial("JOIN DISCORD", Registry.Social.Discord, Color3.fromRGB(88, 101, 242))

-- Dragging
local drag, dStart, sPos; Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; dStart = i.Position; sPos = Main.Position end end)
Libs.UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - dStart; Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y) end end)
Libs.UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)

print("RZGR1KS DUEL V20 Loaded. Discord link copied!")
if setclipboard then setclipboard(Registry.Social.Discord) end
