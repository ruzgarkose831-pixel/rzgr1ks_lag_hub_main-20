local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Cleanup
local old = player.PlayerGui:FindFirstChild("rzgr1ks_V23")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "rzgr1ks_V23"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 99999

-- States
_G.Aimbot = false
_G.SpeedBoost = false
_G.FakeLag = false
_G.ServerLag = false -- Yeni özellik
_G.SpeedValue = 65

-- [MENU BUTTON]
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 60, 0, 60); OpenBtn.Position = UDim2.new(0, 10, 0.4, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 220, 0); OpenBtn.Text = "MENU"; OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

-- [MAIN PANEL]
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 400); Main.Position = UDim2.new(0.5, -150, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Main.Draggable = true
Main.BorderColor3 = Color3.fromRGB(255, 220, 0); Main.BorderSizePixel = 2
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -50); Scroll.Position = UDim2.new(0, 10, 0, 45); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 1.5, 0)
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 10)

-- BUTTON CREATOR
local function makeBtn(text, callback)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1, 0, 0, 45); b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.Text = text .. ": OFF"; b.TextColor3 = Color3.white; b.Font = "GothamBold"; b.TextSize = 14
    Instance.new("UICorner", b)
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.Text = active and (text .. ": ON") or (text .. ": OFF")
        b.BackgroundColor3 = active and Color3.fromRGB(255, 180, 0) or Color3.fromRGB(40, 40, 40)
        callback(active)
    end)
end

-- FEATURES
makeBtn("Aimbot Lock", function(v) _G.Aimbot = v end)
makeBtn("Speed Hack", function(v) _G.SpeedBoost = v end)
makeBtn("Fake Lag (Client)", function(v) _G.FakeLag = v end)
makeBtn("Server Lag (Dangerous)", function(v) _G.ServerLag = v end)

-- CLOSE/OPEN
local Close = Instance.new("TextButton", Main); Close.Size = UDim2.new(0, 30, 0, 30); Close.Position = UDim2.new(1, -35, 0, 5); Close.Text = "X"; Close.BackgroundColor3 = Color3.new(1, 0, 0)
Close.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.Activated:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

-- ENGINE
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    -- SERVER LAG SPAM (USE WITH CAUTION)
    if _G.ServerLag then
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then
            -- Sunucuya saniyede onlarca vuruş/kullanım sinyali gönderir
            for i = 1, 20 do
                tool:Activate()
            end
        end
    end

    -- FAKE LAG
    if _G.FakeLag and root then
        root.Anchored = true
        task.wait(0.03)
        root.Anchored = false
    end

    -- SPEED & AIMBOT (V22 logic)
    if _G.SpeedBoost and char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = _G.SpeedValue
    end

    if _G.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        -- (Targeting logic continues here as in previous versions)
    end
end)
