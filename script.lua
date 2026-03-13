--[[
    @project: RZGR1KS DUEL V48 - ADJUSTABLE HITBOX
    @update: Hitbox Expander Slider Integration + Social Fix
]]--

if _G.RZGR1KS_FINAL_LOADED then return end
_G.RZGR1KS_FINAL_LOADED = true

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LOCAL_PLAYER = Players.LocalPlayer
local CAMERA = workspace.CurrentCamera

-- State store
local VisualState = {
    ["Silent Aim"] = false,
    ["Hitbox Expander"] = false,
    ["Hitbox Size"] = 2, -- Dinamik hitbox boyutu
    ["Spinbot"] = false,
    ["Spin Speed"] = 100,
    ["Speed Bypass"] = false,
    ["Walk Speed"] = 100,
    ["Jump Power"] = 50,
    ["Gravity Control"] = 196,
    ["Multi Jump"] = false,
    ["Material X-RAY"] = false,
    ["Anti Ragdoll"] = false
}

-- // JUMP & MOVEMENT LOGIC
UIS.JumpRequest:Connect(function()
    if VisualState["Multi Jump"] then
        local hum = LOCAL_PLAYER.Character and LOCAL_PLAYER.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Core Heartbeat (Fixes & Features)
RunService.Heartbeat:Connect(function()
    local char = LOCAL_PLAYER.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if hum and root then
        hum.UseJumpPower = true 
        hum.JumpPower = VisualState["Jump Power"]
        workspace.Gravity = VisualState["Gravity Control"]
        
        if VisualState["Speed Bypass"] and hum.MoveDirection.Magnitude > 0 then
            root.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X * VisualState["Walk Speed"], root.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * VisualState["Walk Speed"])
        end

        if VisualState["Spinbot"] then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(VisualState["Spin Speed"]), 0)
        end
    end
    
    -- AYARLANABİLİR HITBOX MANTIĞI
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LOCAL_PLAYER and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = p.Character.HumanoidRootPart
            if VisualState["Hitbox Expander"] then
                targetPart.Size = Vector3.new(VisualState["Hitbox Size"], VisualState["Hitbox Size"], VisualState["Hitbox Size"])
                targetPart.Transparency = 0.7
                targetPart.CanCollide = false
            else
                -- Özellik kapalıysa hitboxları normale döndür
                targetPart.Size = Vector3.new(2, 2, 1)
                targetPart.Transparency = 1
                targetPart.CanCollide = true
            end
        end
    end
end)

-- // UI CONSTRUCTION
local Screen = Instance.new("ScreenGui", (gethui and gethui()) or game.CoreGui)
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 360, 0, 52)
Main.Position = UDim2.new(0.5, -180, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -80, 1, 0); Title.Position = UDim2.new(0, 16, 0, 0); Title.BackgroundTransparency = 1; Title.Text = "RZGR1KS DUEL V48"; Title.Font = "GothamBold"; Title.TextSize = 16; Title.TextColor3 = Color3.fromRGB(255, 60, 60); Title.TextXAlignment = "Left"

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0, 60, 0, 36); ToggleBtn.Position = UDim2.new(1, -68, 0, 8); ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); ToggleBtn.Text = "+"; ToggleBtn.Font = "GothamBold"; ToggleBtn.TextSize = 20; ToggleBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", ToggleBtn)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -12, 0, 360); Scroll.Position = UDim2.new(0, 6, 0, 60); Scroll.BackgroundTransparency = 1; Scroll.Visible = false; Scroll.ScrollBarThickness = 2; Scroll.AutomaticCanvasSize = "Y"
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 8)

-- Helper Functions
local function NewToggle(txt)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, -16, 0, 42); btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28); btn.Text = txt.." : OFF"; btn.Font = "GothamBold"; btn.TextColor3 = Color3.new(0.9,0.9,0.9); Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        VisualState[txt] = not VisualState[txt]
        btn.Text = txt.." : "..(VisualState[txt] and "ON" or "OFF")
        btn.BackgroundColor3 = VisualState[txt] and Color3.fromRGB(200, 30, 30) or Color3.fromRGB(28,28,28)
    end)
end

local function NewSlider(txt, min, max, start)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(1, -16, 0, 60); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt..": "..start; l.TextColor3 = Color3.new(0.8,0.8,0.8); l.Font = "Gotham"; l.BackgroundTransparency = 1
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 0, 12); b.Position = UDim2.new(0,0,0,25); b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.Text = ""; Instance.new("UICorner", b)
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((start-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255,60,60); Instance.new("UICorner", fill)
    
    local move = false
    local function upd()
        local p = math.clamp((UIS:GetMouseLocation().X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(p, 0, 1, 0); local val = math.floor(min + (p * (max - min)))
        VisualState[txt] = val; l.Text = txt..": "..val
    end
    b.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move = false end end)
    UIS.InputChanged:Connect(function(i) if move and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd() end end)
end

-- // ADDING CONTENT (Sıralı)
NewToggle("Silent Aim")
NewToggle("Hitbox Expander")
NewSlider("Hitbox Size", 2, 100, 2) -- AYARLANABİLİR HİTBOX SLIDERI
NewToggle("Spinbot")
NewSlider("Spin Speed", 0, 500, 100)
NewToggle("Speed Bypass")
NewSlider("Walk Speed", 16, 800, 100)
NewSlider("Jump Power", 50, 600, 50)
NewSlider("Gravity Control", 0, 196, 196)
NewToggle("Multi Jump")
NewToggle("Material X-RAY")
NewToggle("Anti Ragdoll")

-- SOCIAL SECTION
local dc = Instance.new("TextButton", Scroll); dc.Size = UDim2.new(1,-16,0,42); dc.BackgroundColor3 = Color3.fromRGB(88, 101, 242); dc.Text = "Discord: rzgr1ks (Copy)"; dc.TextColor3 = Color3.new(1,1,1); dc.Font = "GothamBold"; Instance.new("UICorner", dc)
dc.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/XpbcvVdU"); dc.Text = "Kopyalandı! ✅"; task.wait(1); dc.Text = "Discord: rzgr1ks (Copy)" end)

local yt = Instance.new("TextButton", Scroll); yt.Size = UDim2.new(1,-16,0,42); yt.BackgroundColor3 = Color3.fromRGB(255, 0, 0); yt.Text = "YouTube: rzgr1ks (Copy)"; yt.TextColor3 = Color3.new(1,1,1); yt.Font = "GothamBold"; Instance.new("UICorner", yt)
yt.MouseButton1Click:Connect(function() setclipboard("https://youtube.com/@rzgr1ks"); yt.Text = "Kopyalandı! ✅"; task.wait(1); yt.Text = "YouTube: rzgr1ks (Copy)" end)

-- TOGGLE MENU
local op = false
ToggleBtn.MouseButton1Click:Connect(function()
    op = not op
    Scroll.Visible = op
    ToggleBtn.Text = op and "x" or "+"
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = op and UDim2.new(0, 360, 0, 480) or UDim2.new(0, 360, 0, 52)}):Play()
end)
