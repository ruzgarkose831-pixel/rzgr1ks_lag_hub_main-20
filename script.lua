-- [[ 22S x LEMON: FULLY WORKING HYBRID ]] --
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local Toggles = {Speed = false, Hitbox = false, AutoE = false, AutoZ = false, AutoC = false}
local Vars = {SpeedVal = 40, HBSize = 15}

-- [[ 1. ÇALIŞAN MOTORLAR (FIXED & ENHANCED) ]] --
RS.RenderStepped:Connect(function()
    pcall(function()
        if Toggles.Speed and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local hum = LP.Character:FindFirstChild("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0 then
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

        -- Auto Z / C Koordinat Motoru
        if Toggles.AutoZ and LP.Character then
             LP.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(-38.5, 3.5, 4.5)) -- Örnek Z Pozisyonu
        end
        if Toggles.AutoC and LP.Character then
             LP.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(38.5, 3.5, 4.5)) -- Örnek C Pozisyonu
        end
    end)
end)

-- [[ 2. UI TASARIMI ]] --
local sg = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
sg.Name = "22S_Lemon_Hybrid"
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 190, 0, 260)
main.Position = UDim2.new(0.85, -100, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(2, 2, 12)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true
main.Draggable = true -- Menüyü mouse ile ekranda gezdirebilirsin

local corner = Instance.new("UICorner", main)
local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(0, 100, 255); stroke.Thickness = 2

-- Başlık Barı
local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1, 0, 0, 30); header.Text = "  22S x LEMON"; header.TextColor3 = Color3.new(1,1,1); header.BackgroundColor3 = Color3.fromRGB(5, 5, 25); header.TextXAlignment = "Left"; header.Font = "SourceSansBold"; header.TextSize = 16

-- KÜÇÜLTME TUŞU
local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 24, 0, 24); minBtn.Position = UDim2.new(1, -27, 0, 3); minBtn.Text = "-"; minBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 220); minBtn.TextColor3 = Color3.white; minBtn.Font = "SourceSansBold"
Instance.new("UICorner", minBtn)

local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, 0, 1, -35); content.Position = UDim2.new(0, 0, 0, 35); content.BackgroundTransparency = 1; content.ScrollBarThickness = 3; content.CanvasSize = UDim2.new(0,0,0,300)
local layout = Instance.new("UIListLayout", content); layout.Padding = UDim.new(0, 6); layout.HorizontalAlignment = "Center"

-- [[ 3. ÖZELLİK FONKSİYONU ]] --
local function CreateToggle(name, var)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(0.9, 0, 0, 30); btn.BackgroundColor3 = Color3.fromRGB(20, 20, 45); btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.Text = name; btn.Font = "SourceSans"
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        Toggles[var] = not Toggles[var]
        btn.BackgroundColor3 = Toggles[var] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(20, 20, 45)
        btn.TextColor3 = Toggles[var] and Color3.new(1,1,1) or Color3.fromRGB(200, 200, 200)
    end)
end

CreateToggle("⚡ Speed Hack", "Speed")
CreateToggle("🎯 Hitbox Expander", "Hitbox")
CreateToggle("⌨️ Auto Click E", "AutoE")
CreateToggle("⬅️ Auto Left (Z)", "AutoZ")
CreateToggle("➡️ Auto Right (C)", "AutoC")

-- Hız Ayar Kutusu
local speedInp = Instance.new("TextBox", content)
speedInp.Size = UDim2.new(0.9, 0, 0, 25); speedInp.PlaceholderText = "Hız (40)"; speedInp.BackgroundColor3 = Color3.fromRGB(10, 10, 25); speedInp.TextColor3 = Color3.white; speedInp.Text = ""
Instance.new("UICorner", speedInp)
speedInp.FocusLost:Connect(function() Vars.SpeedVal = tonumber(speedInp.Text) or 40 end)

-- [[ 4. KÜÇÜLTME MANTIĞI ]] --
local open = true
minBtn.MouseButton1Click:Connect(function()
    open = not open
    if not open then
        main:TweenSize(UDim2.new(0, 190, 0, 30), "Out", "Quart", 0.3, true)
        minBtn.Text = "+"
        content.Visible = false
    else
        main:TweenSize(UDim2.new(0, 190, 0, 260), "Out", "Quart", 0.3, true)
        minBtn.Text = "-"
        task.wait(0.25)
        content.Visible = true
    end
end)

-- [[ 5. KISAYOLLAR ]] --
UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.RightShift then main.Visible = not main.Visible end
    if i.KeyCode == Enum.KeyCode.Z then Toggles.AutoZ = not Toggles.AutoZ end
    if i.KeyCode == Enum.KeyCode.C then Toggles.AutoC = not Toggles.AutoC end
end)

print("✅ HİBRİT SCRİPT AKTİF: Menü Sağdadır, '-' ile küçülür.")
