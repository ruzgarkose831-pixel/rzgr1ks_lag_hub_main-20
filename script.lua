--[[
    @project: RZGR1KS DUEL - V23 (MAX CONFIG EDITION)
    @author: rzgr1ks
    @youtube: rzgr1ks
    @discord: https://discord.gg/XpbcvVdU
    
    [SYSTEM NOTES]
    - Full 360 Velocity Movement Fixed.
    - Self-Aiming Glitch Resolved.
    - Auto-Save/Load JSON Config System Added.
    - Large UI Components for Mobile Ergonomics.
]]--

-- // Framework Bootstrap
if _G.RZGR_V23_LOADED then return end
_G.RZGR_V23_LOADED = true

-- // Service Virtualization
local Services = setmetatable({}, {__index = function(_, k) return game:GetService(k) end})
local Local = {
    Player = Services.Players.LocalPlayer,
    Mouse = Services.Players.LocalPlayer:GetMouse(),
    Camera = workspace.CurrentCamera
}

-- // CONFIGURATION SYSTEM (NEW)
local ConfigName = "RZGR_V23_Config.json"
local Registry = {
    States = {
        Combat = { SilentAim = false, Hitbox = false, HSize = 25 },
        Movement = { Speed = false, Velocity = 100 },
        Visuals = { Esp = false }
    }
}

-- // Config Functions
local function SaveConfig()
    if writefile then
        local Encoded = Services.HttpService:JSONEncode(Registry.States)
        writefile(ConfigName, Encoded)
    end
end

local function LoadConfig()
    if isfile and isfile(ConfigName) then
        local Success, Decoded = pcall(function()
            return Services.HttpService:JSONDecode(readfile(ConfigName))
        end)
        if Success then
            Registry.States = Decoded
        end
    end
end

LoadConfig() -- Auto-load on startup

-- // TARGETING ENGINE (ANTI-SELF & TEAM CHECK)
local function GetValidTarget()
    local Target = nil
    local MinDist = math.huge
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= Local.Player and p.Character and p.Character:FindFirstChild("Head") then
            -- Check for Team and Transparency (optional check)
            if p.Team ~= Local.Player.Team then
                local Pos, OnScreen = Local.Camera:WorldToViewportPoint(p.Character.Head.Position)
                if OnScreen then
                    local MouseDist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Local.Mouse.X, Local.Mouse.Y)).Magnitude
                    if MouseDist < MinDist then
                        MinDist = MouseDist
                        Target = p.Character.Head
                    end
                end
            end
        end
    end
    return Target
end

-- // CORE HOOKS (SILENT AIM FIXED)
local OldNC; OldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    if not checkcaller() and Registry.States.Combat.SilentAim and (Method == "FindPartOnRayWithIgnoreList" or Method == "Raycast") then
        local T = GetValidTarget()
        if T then
            return T, T.Position, T.CFrame.p, T.Material
        end
    end
    return OldNC(self, ...)
end)

-- // MAIN RUNTIME (FIXED MOVEMENT & HITBOX)
Services.RunService.Heartbeat:Connect(function()
    local Char = Local.Player.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    
    -- FIXED 360 MOVEMENT
    if Root and Hum and Registry.States.Movement.Speed then
        if Hum.MoveDirection.Magnitude > 0 then
            local Dir = Hum.MoveDirection * Registry.States.Movement.Velocity
            Root.AssemblyLinearVelocity = Vector3.new(Dir.X, Root.AssemblyLinearVelocity.Y, Dir.Z)
        end
    end
    
    -- HITBOX ENGINE
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= Local.Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            if Registry.States.Combat.Hitbox then
                hrp.Size = Vector3.new(Registry.States.Combat.HSize, Registry.States.Combat.HSize, Registry.States.Combat.HSize)
                hrp.Transparency = 0.7
                hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1; hrp.CanCollide = true
            end
        end
    end
end)

-- // INTERFACE ENGINE (ENHANCED MOBILE UI)
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 280, 0, 450)
Main.Position = UDim2.new(0.5, -140, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "RZGR1KS DUEL V23"; Title.TextColor3 = Color3.fromRGB(255, 40, 40)
Title.Font = "GothamBold"; Title.TextSize = 14; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -65); Scroll.Position = UDim2.new(0, 5, 0, 55)
Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 0
local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 10); Layout.HorizontalAlignment = "Center"

-- // LARGE COMPONENT BUILDERS
local function AddToggle(txt, sub, key)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, 250, 0, 50) -- Big Buttons
    b.BackgroundColor3 = Registry.States[sub][key] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(30, 30, 30)
    b.Text = txt .. (Registry.States[sub][key] and ": ON" or ": OFF")
    b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 12
    Instance.new("UICorner", b)
    
    b.MouseButton1Click:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        local s = Registry.States[sub][key]
        b.Text = txt .. (s and ": ON" or ": OFF")
        b.BackgroundColor3 = s and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(30, 30, 30)
        SaveConfig() -- Auto-save on change
    end)
end

local function AddSlider(txt, min, max, sub, key)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(0, 250, 0, 60); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt .. ": " .. Registry.States[sub][key]
    l.TextColor3 = Color3.new(0.7,0.7,0.7); l.Font = "Gotham"; l.BackgroundTransparency = 1; l.TextXAlignment = "Left"
    
    local r = Instance.new("Frame", f); r.Size = UDim2.new(1, 0, 0, 6); r.Position = UDim2.new(0, 0, 0, 35); r.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local fill = Instance.new("Frame", r); fill.Size = UDim2.new((Registry.States[sub][key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255,40,40)
    
    r.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            local function Update()
                local p = math.clamp((Services.UserInputService:GetMouseLocation().X - r.AbsolutePosition.X) / r.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0)
                local val = math.floor(min + (p * (max - min)))
                l.Text = txt .. ": " .. val
                Registry.States[sub][key] = val
                SaveConfig()
            end
            Update()
        end
    end)
end

local function AddSocial(txt, link, color)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, 250, 0, 50); b.BackgroundColor3 = color; b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(link) b.Text = "COPIED!"; task.wait(1); b.Text = txt end
    end)
end

-- // INITIALIZE INTERFACE
AddToggle("Silent Aim V2", "Combat", "SilentAim")
AddToggle("Hitbox Expander", "Combat", "Hitbox")
AddSlider("Hitbox Radius", 2, 150, "Combat", "HSize")
AddToggle("360 Velocity Speed", "Movement", "Speed")
AddSlider("Speed Value", 16, 500, "Movement", "Velocity")
AddSocial("SUBSCRIBE YOUTUBE", "https://youtube.com/@rzgr1ks", Color3.fromRGB(200, 0, 0))
AddSocial("JOIN DISCORD SERVER", "https://discord.gg/XpbcvVdU", Color3.fromRGB(88, 101, 242))

-- // DRAGGING & MINIMIZE
local drag, dStart, sPos; Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; dStart = i.Position; sPos = Main.Position end end)
Services.UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - dStart; Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y) end end)
Services.UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)

local isMin = false
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 40, 0, 40); MinBtn.Position = UDim2.new(1, -45, 0, 5); MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.BackgroundTransparency = 1; MinBtn.TextSize = 20
MinBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    Scroll.Visible = not isMin
    Main:TweenSize(isMin and UDim2.new(0, 280, 0, 50) or UDim2.new(0, 280, 0, 450), "Out", "Quart", 0.3, true)
end)

print("RZGR1KS DUEL V23 LOADED - CONFIG SYSTEM ACTIVE")
