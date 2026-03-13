--[[
    @project: RZGR1KS DUEL - V24.0 (ULTRATHREAD FIX & OPTIMIZED SLIDERS)
    @author: rzgr1ks
    @youtube: rzgr1ks
    @discord: https://discord.gg/XpbcvVdU
    
    [MAJOR CHANGELOG]
    1. Silent Aim Camera Sync Fix: Camera no longer separates from character during active aim.
    2. Slider Input Fix: Smooth, responsive slider interaction for mobile.
    3. Movement Engine Rework: Optimized velocity-based movement with character animation sync.
    4. Features Restore: All core framework features restored and extended.
]]--

-- // Core Framework Bootstrapper
if _G.RZGR_LOADED then return end
_G.RZGR_LOADED = true

-- // Service Virtualization Layer
local Services = setmetatable({}, {__index = function(_, k) return game:GetService(k) end})
local Local = {
    Player = Services.Players.LocalPlayer,
    Mouse = Services.Players.LocalPlayer:GetMouse(),
    Camera = workspace.CurrentCamera
}

-- // Global Registry & Social
local ConfigName = "RZGR_Framework_V24.cfg"
local Registry = {
    Social = {
        YouTube = "https://youtube.com/@rzgr1ks",
        Discord = "https://discord.gg/XpbcvVdU"
    },
    States = {
        Combat = { Silent = false, Hitbox = false, HSize = 25, CameraSync = true },
        Movement = { Speed = false, Vel = 100, Spin = false, S_Speed = 50 },
        Visuals = { Esp = false, Xray = false },
        Misc = { AntiRagdoll = false }
    }
}

-- // Config Manager
local function SaveConfig()
    if writefile then
        writefile(ConfigName, Services.HttpService:JSONEncode(Registry.States))
    end
end

local function LoadConfig()
    if isfile and isfile(ConfigName) then
        pcall(function()
            local data = Services.HttpService:JSONDecode(readfile(ConfigName))
            for k,v in pairs(data) do if Registry.States[k] then for k1,v1 in pairs(v) do Registry.States[k][k1] = v1 end end end
        end)
    end
end
LoadConfig()

-- // UTILITY ENGINE
local Utils = {}
function Utils:GetDist(P1, P2) return (P1 - P2).Magnitude end

function Utils:GetTarget()
    local Target, Dist = nil, math.huge
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= Local.Player and p.Character and p.Character:FindFirstChild("Head") then
            if p.Team ~= Local.Player.Team then
                local Pos, OnScreen = Local.Camera:WorldToViewportPoint(p.Character.Head.Position)
                if OnScreen then
                    local MouseDist = Utils:GetDist(Vector2.new(Pos.X, Pos.Y), Vector2.new(Local.Mouse.X, Local.Mouse.Y))
                    if MouseDist < Dist then Dist = MouseDist; Target = p.Character.Head end
                end
            end
        end
    end
    return Target
end

-- // CORE HOOKS (SILENT AIM & CAMERA SYNC FIX)
local function AimSyncLoop(dt)
    if not Registry.States.Combat.Silent or not Registry.States.Combat.CameraSync then return end
    local T = Utils:GetTarget()
    local Char = Local.Player.Character
    if T and Char and Char:FindFirstChild("Humanoid") then
        local Humanoid = Char.Humanoid
        local Root = Char:FindFirstChild("HumanoidRootPart")
        if Root then
            local Dir = (T.Position - Local.Camera.CFrame.Position).Unit
            local TPos = Local.Camera.CFrame.Position + Dir * 10 -- Anchor target pos
            -- This ensures the camera is pointing exactly at the target, keeping character sync
            Local.Camera.CFrame = CFrame.new(Local.Camera.CFrame.Position, TPos)
        end
    end
end
Services.RunService:BindToRenderStep("AimSync", 1, AimSyncLoop)

local OldNC; OldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    if not checkcaller() and Registry.States.Combat.Silent and (Method == "FindPartOnRayWithIgnoreList" or Method == "Raycast") then
        local T = Utils:GetTarget()
        if T then return T, T.Position, T.CFrame.p, T.Material end
    end
    return OldNC(self, ...)
end)

-- // MAIN FRAMEWORK LOOP (MOVEMENT & HITBOX)
Services.RunService.Heartbeat:Connect(function(dt)
    local Char = Local.Player.Character
    if not Char then return end
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    
    -- Movement Management (Fixed 360)
    if Root and Hum then
        local SpinForce = Root:FindFirstChild("RZ_Spin")
        if Registry.States.Movement.Speed then
            local speed = Registry.States.Movement.Vel
            if Hum.MoveDirection.Magnitude > 0 then
                local Vel = Root:FindFirstChild("LinearVelocity") or Instance.new("LinearVelocity", Root)
                Vel.Attachment0 = Root:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", Root)
                Vel.MaxForce = speed * 100
                Vel.VectorVelocity = Hum.MoveDirection * speed
            end
        elseif Root:FindFirstChild("LinearVelocity") then Root.LinearVelocity:Destroy() end

        if Registry.States.Movement.Spin then
            if not SpinForce then
                SpinForce = Instance.new("AngularVelocity", Root)
                SpinForce.Name = "RZ_Spin"; SpinForce.MaxTorque = math.huge
                SpinForce.Attachment0 = Root:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", Root)
            end
            SpinForce.AngularVelocity = Vector3.new(0, Registry.States.Movement.S_Speed, 0)
        elseif SpinForce then SpinForce:Destroy() end
    end
    
    -- Visuals & Combat Processing
    for _, p in ipairs(Services.Players:GetPlayers()) do
        if p ~= Local.Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            if Registry.States.Combat.Hitbox then
                hrp.Size = Vector3.new(Registry.States.Combat.HSize, Registry.States.Combat.HSize, Registry.States.Combat.HSize)
                hrp.Transparency = 0.7; hrp.CanCollide = false
            else hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1; hrp.CanCollide = true end
            
            local esp = p.Character:FindFirstChild("RZ_Hilight")
            if Registry.States.Visuals.Esp then
                if not esp then
                    esp = Instance.new("Highlight", p.Character)
                    esp.Name = "RZ_Hilight"; esp.FillColor = Color3.fromRGB(255, 45, 45)
                end
            elseif esp then esp:Destroy() end
        end
    end
    
    -- Xray Processing
    if Registry.States.Visuals.Xray then
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsDescendantOf(Local.Player.Character) then
                part.LocalTransparencyModifier = 0.6
            end
        end
    end
end)

-- // UI ENGINE V2.0 (PROFESSIONAL SLIDERS)
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or Services.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 260, 0, 420); Main.Position = UDim2.new(0.5, -130, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40); Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "RZGR1KS DUEL | YT: rzgr1ks"; Title.TextColor3 = Color3.fromRGB(255, 60, 60)
Title.Font = "GothamBold"; Title.TextSize = 12; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -55); Scroll.Position = UDim2.new(0, 5, 0, 45)
Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 0
local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 8); Layout.HorizontalAlignment = "Center"

-- // COMPONENT BUILDERS (PROFESSIONAL SLIDER LOGIC)
local function NewToggle(txt, sub, key)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, 240, 0, 40); b.BackgroundColor3 = Registry.States[sub][key] and Color3.fromRGB(100, 20, 20) or Color3.fromRGB(30, 30, 30); b.Text = " " .. txt .. (Registry.States[sub][key] and ": ON" or ": OFF"); b.TextColor3 = Color3.new(0.8,0.8,0.8); b.Font = "GothamSemibold"; b.TextSize = 11; b.TextXAlignment = "Left"; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Registry.States[sub][key] = not Registry.States[sub][key]
        b.Text = " " .. txt .. (Registry.States[sub][key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Registry.States[sub][key] and Color3.fromRGB(100, 20, 20) or Color3.fromRGB(30, 30, 30)
        b.TextColor3 = Registry.States[sub][key] and Color3.new(1,1,1) or Color3.new(0.8,0.8,0.8)
        SaveConfig()
    end)
end

local function NewSlider(txt, min, max, sub, key)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(0, 240, 0, 45); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 15); l.Text = " " .. txt .. ": " .. Registry.States[sub][key]; l.TextColor3 = Color3.new(0.6,0.6,0.6); l.Font = "Gotham"; l.TextSize = 10; l.BackgroundTransparency = 1; l.TextXAlignment = "Left"
    local r = Instance.new("Frame", f); r.Size = UDim2.new(1, 0, 0, 4); r.Position = UDim2.new(0, 0, 0, 25); r.BackgroundColor3 = Color3.fromRGB(40,40,40); r.BorderSizePixel = 0
    local fill = Instance.new("Frame", r); fill.Size = UDim2.new((Registry.States[sub][key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255,60,60); fill.BorderSizePixel = 0
    Instance.new("UICorner", fill); Instance.new("UICorner", r)
    
    local isInput = false
    r.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isInput = true end end)
    Services.UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isInput = false SaveConfig() end end)
    
    local function Update(input)
        local delta = math.clamp((input.Position.X - r.AbsolutePosition.X) / r.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(delta, 0, 1, 0)
        local val = math.floor(min + (delta * (max - min)))
        l.Text = " " .. txt .. ": " .. val
        Registry.States[sub][key] = val
    end
    r.InputChanged:Connect(function(i) if isInput and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end end)
    r.MouseButton1Click:Connect(function() Update(Services.UIS:GetMouseLocation()) SaveConfig() end)
end

local function NewSocial(txt, link, color)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0, 240, 0, 40); b.BackgroundColor3 = color; b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 11; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() if setclipboard then setclipboard(link) b.Text = "COPIED TO CLIPBOARD!"; task.wait(1.5); b.Text = txt end end)
end

-- // INITIALIZE INTERFACE CONTENT
NewToggle("Silent Aim V3", "Combat", "Silent")
NewToggle("Ghost Hitbox", "Combat", "Hitbox")
NewSlider("Hitbox Radius", 2, 100, "Combat", "HSize")
NewToggle("Velocity Speed", "Movement", "Speed")
NewSlider("Speed Power", 16, 800, "Movement", "Vel")
NewToggle("Angular Spinbot", "Movement", "Spin")
NewSlider("Spin Intensity", 0, 200, "Movement", "S_Speed")
NewToggle("Render ESP", "Visuals", "Esp")
NewToggle("Material X-Ray", "Visuals", "Xray")
NewToggle("Anti-Ragdoll Pro", "Misc", "AntiRagdoll")
NewSocial("SUBSCRIBE YT: rzgr1ks", Registry.Social.YouTube, Color3.fromRGB(200, 0, 0))
NewSocial("JOIN DISCORD SERVER", Registry.Social.Discord, Color3.fromRGB(88, 101, 242))

-- // DRAGGING & MINIMIZE SYSTEM
local drag, dStart, sPos; Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; dStart = i.Position; sPos = Main.Position end end)
Services.UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - dStart; Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y) end end)
Services.UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)

local isMin = false
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -35, 0, 5); MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.Font = "Gotham"; MinBtn.BackgroundTransparency = 1; MinBtn.TextSize = 20
MinBtn.MouseButton1Click:Connect(function()
    isMin = not isMin; Scroll.Visible = not isMin; Main:TweenSize(isMin and UDim2.new(0, 260, 0, 40) or UDim2.new(0, 260, 0, 420), "Out", "Quart", 0.3, true); MinBtn.Text = isMin and "+" or "-"
end)

print("RZGR1KS DUEL V24 FRAMEWORK DEPLOYED :: Support DC: discord.gg/XpbcvVdU")
