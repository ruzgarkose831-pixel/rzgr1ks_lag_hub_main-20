--[[
    @title: RZGR1KS DUEL - PROFESSIONAL FRAMEWORK
    @version: 21.0.0 (INTERNAL / STABLE)
    @developer: rzgr1ks
    @youtube: rzgr1ks
    @discord: https://discord.gg/XpbcvVdU
    
    [TECHNICAL SPECIFICATIONS]
    - Environment: Universal (Mobile/PC)
    - Combat: Silent Aim Redirection V3 & Auto-Hitbox
    - Physics: Linear Velocity & Angular Momentum Bypass
    - Interface: Compact Modular GUI (Draggable & Minimizable)
]]--

-- // Framework Bootstrapper
if _G.RZGR_FRAMEWORK_ACTIVE then
    warn("[RZGR1KS] Framework already active.")
    return
end
_G.RZGR_FRAMEWORK_ACTIVE = true

-- // Core API Virtualization
local Core = setmetatable({}, {
    __index = function(self, key)
        return game:GetService(key)
    end
})

local Services = {
    Players = Core.Players,
    Run = Core.RunService,
    UIS = Core.UserInputService,
    Http = Core.HttpService,
    CoreGui = Core.CoreGui,
    Workspace = Core.Workspace,
    Stats = Core.Stats,
    Lighting = Core.Lighting
}

local Local = {
    Player = Services.Players.LocalPlayer,
    Camera = Services.Workspace.CurrentCamera,
    Mouse = Services.Players.LocalPlayer:GetMouse()
}

-- // Internal Registry System
local Registry = {
    Data = {
        Youtube = "https://youtube.com/@rzgr1ks",
        Discord = "https://discord.gg/XpbcvVdU",
        Version = "21.0.0"
    },
    States = {
        Combat = { SilentAim = false, Hitbox = false, HSize = 2, Ghost = true, WallCheck = false },
        Movement = { Speed = false, Velocity = 16, Spin = false, S_Speed = 100, InfJump = false },
        Visuals = { Esp = false, Xray = false, Fullbright = false },
        Misc = { AntiRagdoll = false, AutoSave = true }
    },
    Connections = {}
}

-- // Utility Engine
local Utils = {}
do
    function Utils:GetTarget()
        local Nearest = nil
        local MinDist = math.huge
        for _, p in ipairs(Services.Players:GetPlayers()) do
            if p ~= Local.Player and p.Character and p.Character:FindFirstChild("Head") then
                if p.Team ~= Local.Player.Team then
                    local Pos, OnScreen = Local.Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if OnScreen then
                        local MouseDist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Local.Mouse.X, Local.Mouse.Y)).Magnitude
                        if MouseDist < MinDist then
                            MinDist = MouseDist
                            Nearest = p.Character.Head
                        end
                    end
                end
            end
        end
        return Nearest
    end

    function Utils:ApplyXray(State)
        for _, obj in ipairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(Local.Player.Character) then
                obj.LocalTransparencyModifier = State and 0.6 or 0
            end
        end
    end
end

-- // Core Combat Hooking (Metatable Redirection)
local OldNC; OldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    if not checkcaller() and Registry.States.Combat.SilentAim and (Method == "FindPartOnRayWithIgnoreList" or Method == "Raycast") then
        local Target = Utils:GetTarget()
        if Target then
            return Target, Target.Position, Target.CFrame.p, Target.Material
        end
    end
    return OldNC(self, ...)
end)

-- // Main Heartbeat Thread
Registry.Connections.MainLoop = Services.Run.Heartbeat:Connect(function()
    local Char = Local.Player.Character
    if not Char then return end
    
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    
    -- // Movement Management
    if Root and Hum then
        if Registry.States.Movement.Speed and Hum.MoveDirection.Magnitude > 0 then
            local Vel = Hum.MoveDirection * Registry.States.Movement.Velocity
            Root.AssemblyLinearVelocity = Vector3.new(Vel.X, Root.AssemblyLinearVelocity.Y, Vel.Y)
        end
        
        local Spinner = Root:FindFirstChild("RZGR_SPIN")
        if Registry.States.Movement.Spin then
            if not Spinner then
                Spinner = Instance.new("AngularVelocity", Root)
                Spinner.Name = "RZGR_SPIN"
                Spinner.MaxTorque = math.huge
                Spinner.Attachment0 = Root:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", Root)
            end
            Spinner.AngularVelocity = Vector3.new(0, Registry.States.Movement.S_Speed, 0)
        elseif Spinner then Spinner:Destroy() end
    end
    
    -- // Combat & Visual Processing
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= Local.Player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if Registry.States.Combat.Hitbox then
                    hrp.Size = Vector3.new(Registry.States.Combat.HSize, Registry.States.Combat.HSize, Registry.States.Combat.HSize)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = not Registry.States.Combat.Ghost
                else
                    hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1; hrp.CanCollide = true
                end
            end
            
            -- // High-Performance Highlight
            local esp = p.Character:FindFirstChild("RZGR_ESP")
            if Registry.States.Visuals.Esp then
                if not esp then
                    esp = Instance.new("Highlight", p.Character)
                    esp.Name = "RZGR_ESP"
                    esp.FillColor = Color3.fromRGB(255, 45, 45)
                end
            elseif esp then esp:Destroy() end
        end
    end
end)

-- // Compact Interface Engine
local Interface = {}
do
    local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
    Screen.Name = "RZGR_UI_V21"

    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.new(0, 240, 0, 380) -- Reduced size
    Main.Position = UDim2.new(0.5, -120, 0.5, -190)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
    
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 6)
    
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = "RZGR1KS DUEL V21"
    Title.TextColor3 = Color3.fromRGB(255, 50, 50)
    Title.Font = "GothamBold"
    Title.TextSize = 12
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = "Left"
    
    local MinBtn = Instance.new("TextButton", Header)
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -35, 0, 2.5)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1,1,1)
    MinBtn.BackgroundTransparency = 1
    
    local Container = Instance.new("ScrollingFrame", Main)
    Container.Size = UDim2.new(1, -10, 1, -45)
    Container.Position = UDim2.new(0, 5, 0, 40)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 0
    local Layout = Instance.new("UIListLayout", Container); Layout.Padding = UDim.new(0, 5); Layout.HorizontalAlignment = "Center"

    -- // UI COMPONENT BUILDERS
    local function NewToggle(txt, sub, key, callback)
        local b = Instance.new("TextButton", Container)
        b.Size = UDim2.new(1, 0, 0, 35)
        b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        b.Text = " " .. txt .. ": OFF"
        b.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        b.Font = "GothamSemibold"
        b.TextSize = 11
        Instance.new("UICorner", b)
        
        b.MouseButton1Click:Connect(function()
            Registry.States[sub][key] = not Registry.States[sub][key]
            local state = Registry.States[sub][key]
            b.Text = " " .. txt .. (state and ": ON" or ": OFF")
            b.BackgroundColor3 = state and Color3.fromRGB(100, 20, 20) or Color3.fromRGB(25, 25, 25)
            if callback then callback(state) end
        end)
    end

    local function NewSlider(txt, min, max, def, sub, key)
        local f = Instance.new("Frame", Container); f.Size = UDim2.new(1, 0, 0, 45); f.BackgroundTransparency = 1
        local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 15); l.Text = " " .. txt .. ": " .. def; l.TextColor3 = Color3.new(0.6, 0.6, 0.6); l.Font = "Gotham"; l.TextSize = 10; l.BackgroundTransparency = 1; l.TextXAlignment = "Left"
        local r = Instance.new("Frame", f); r.Size = UDim2.new(1, -10, 0, 3); r.Position = UDim2.new(0, 5, 0, 25); r.BackgroundColor3 = Color3.fromRGB(40, 40, 40); r.BorderSizePixel = 0
        local fill = Instance.new("Frame", r); fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50); fill.BorderSizePixel = 0
        
        local function Update(input)
            local p = math.clamp((input.Position.X - r.AbsolutePosition.X) / r.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(p, 0, 1, 0)
            local val = math.floor(min + (p * (max - min)))
            l.Text = " " .. txt .. ": " .. val
            Registry.States[sub][key] = val
        end
        r.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Update(i) end end)
    end

    local function NewSocial(txt, link, color)
        local b = Instance.new("TextButton", Container)
        b.Size = UDim2.new(1, 0, 0, 35); b.BackgroundColor3 = color; b.Text = txt; b.TextColor3 = Color3.new(1, 1, 1); b.Font = "GothamBold"; b.TextSize = 11; Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(link)
                local old = b.Text
                b.Text = "COPIED TO CLIPBOARD!"
                task.wait(1)
                b.Text = old
            end
        end)
    end

    -- // LOAD CONTENT
    NewToggle("Silent Aim", "Combat", "SilentAim")
    NewToggle("Ghost Hitbox", "Combat", "Hitbox")
    NewSlider("Hitbox Size", 2, 100, 2, "Combat", "HSize")
    NewToggle("Velocity Speed", "Movement", "Speed")
    NewSlider("Speed Power", 16, 500, 16, "Movement", "Velocity")
    NewToggle("Spinbot", "Movement", "Spin")
    NewToggle("Entity ESP", "Visuals", "Esp")
    NewToggle("Modern X-Ray", "Visuals", "Xray", function(s) Utils:ApplyXray(s) end)
    
    NewSocial("SUBSCRIBE YT: rzgr1ks", Registry.Data.Youtube, Color3.fromRGB(200, 0, 0))
    NewSocial("JOIN DISCORD", Registry.Data.Discord, Color3.fromRGB(88, 101, 242))

    -- // MINIMIZE LOGIC
    local IsMin = false
    MinBtn.MouseButton1Click:Connect(function()
        IsMin = not IsMin
        Container.Visible = not IsMin
        Main:TweenSize(IsMin and UDim2.new(0, 240, 0, 35) or UDim2.new(0, 240, 0, 380), "Out", "Quart", 0.3, true)
        MinBtn.Text = IsMin and "+" or "-"
    end)

    -- // DRAGGING ENGINE
    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    Services.UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    Services.UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end

-- // FINAL DEPLOYMENT LOG
print("================================")
print("RZGR1KS DUEL V21 DEPLOYED")
print("Socials: YouTube & Discord")
print("================================")
if setclipboard then setclipboard(Registry.Data.Discord) end
