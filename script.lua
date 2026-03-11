-- [[ 22S x LEMON: FULLY WORKING HYBRID ]] --
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local Toggles = {Speed = false, Hitbox = false, AutoE = false, AutoZ = false, AutoC = false}
local Vars = {SpeedVal = 40, HBSize = 15}

-- [[ 1. ÇALIŞAN MOTORLAR (FIXED) ]] --
RS.RenderStepped:Connect(function()
    if Toggles.Speed and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hum = LP.Character:FindFirstChild("Humanoid")
        if hum.MoveDirection.Magnitude > 0 then
            LP.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame + (hum.MoveDirection * (Vars.SpeedVal/45))
        end
    end
    
    if Toggles.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                hrp.Size = Vector3.new(Vars.HBSize, Vars.HBSize, Vars.HBSize)
                hrp.Transparency = 0.7
                hrp.CanCollide = false
            end
        end
    end
    
    if Toggles.AutoE then
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
        task.wait(0.05)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
    end
end)

-- [[ 2. UI TASARIMI (22S BLUE STYLE) ]] --
local sg = Instance.new("ScreenGui", LP.PlayerGui)
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 200, 0, 280)
main.Position = UDim2.new(0.85, -100, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(2, 2, 8)
main.BorderSizePixel = 0
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(0, 100, 255); stroke.Thickness = 2

-- Başlık ve Küçültme Tuşu
local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1, 0, 0, 30); header.Text = "  22S x LEMON"; header.TextColor3 = Color3.new(1,1,1); header.BackgroundColor3 = Color3.fromRGB(5, 5, 20); header.TextXAlignment = "Left"; header.Font = "SourceSansBold"

local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 25, 0, 25); minBtn.Position = UDim2.new(1, -28, 0, 2.5); minBtn.Text = "-"; minBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 200); minBtn.TextColor3 = Color3.white
Instance.new("UICorner", minBtn)

local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, 0, 1, -35); content.Position = UDim2.new(0, 0, 0, 35); content.BackgroundTransparency = 1; content.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", content); layout.Padding = UDim.new(0, 5); layout.HorizontalAlignment = "Center"

-- [[ 3. ÖZELLİK EKLEME ]] --
local function CreateToggle(name, var)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(0.9, 0, 0, 30); btn.BackgroundColor3 = Color3.fromRGB(20, 20, 40); btn.TextColor3 = Color3.fromRGB(180, 180, 180); btn.Text = name; btn.Font = "SourceSans"
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        Toggles[var] = not Toggles[var]
        btn.BackgroundColor3 = Toggles[var] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(20, 20, 40)
        btn.TextColor3 = Toggles[var] and Color3.new(1, 1, 1) or Color3.fromRGB(180, 180, 180)
    end)
end

CreateToggle("Speed Hack", "Speed")
CreateToggle("Hitbox Expander", "Hitbox")
CreateToggle("Auto Click E", "AutoE")
CreateToggle("Auto Left (Z)", "AutoZ")
CreateToggle("Auto Right (C)", "AutoC")

-- Hız Ayarı Input
local speedInp = Instance.new("TextBox", content)
speedInp.Size = UDim2.new(0.9, 0, 0, 25); speedInp.PlaceholderText = "Speed (40)"; speedInp.BackgroundColor3 = Color3.fromRGB(10, 10, 20); speedInp.TextColor3 = Color3.white
speedInp.FocusLost:Connect(function() Vars.SpeedVal = tonumber(speedInp.Text) or 40 end)

-- [[ 4. KÜÇÜLTME FONKSİYONU ]] --
local open = true
minBtn.MouseButton1Click:Connect(function()
    open = not open
    if not open then
        main:TweenSize(UDim2.new(0, 200, 0, 30), "Out", "Quart", 0.3, true)
        minBtn.Text = "+"
        content.Visible = false
    else
        main:TweenSize(UDim2.new(0, 200, 0, 280), "Out", "Quart", 0.3, true)
        minBtn.Text = "-"
        task.wait(0.25)
        content.Visible = true
    end
end)

-- [[ 5. KLAVYE KISAYOLLARI ]] --
UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.RightShift then main.Visible = not main.Visible end
    if i.KeyCode == Enum.KeyCode.Z then Toggles.AutoZ = not Toggles.AutoZ end -- Koordinat Z
    if i.KeyCode == Enum.KeyCode.C then Toggles.AutoC = not Toggles.AutoC end -- Koordinat C
end)

print("🚀 22S x LEMON V3 LOADED - Sağ Shift Menüyü Kapatır")
