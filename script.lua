local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local Toggles = {Speed = false, Hitbox = false, AutoE = false, AutoZ = false, AutoC = false}
local Vars = {SpeedVal = 40, HBSize = 15}

-- [[ 1. GÜVENLİ GUI OLUŞTURMA (CoreGui Bypass) ]] --
local guiParent
pcall(function()
    guiParent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not guiParent then
    guiParent = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")
end

-- Eski menü varsa sil (Üst üste binmemesi için)
if guiParent:FindFirstChild("Lemon22S_Ultimate") then
    guiParent.Lemon22S_Ultimate:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name = "Lemon22S_Ultimate"
sg.ResetOnSpawn = false
sg.Parent = guiParent

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 190, 0, 260)
main.Position = UDim2.new(0.85, -100, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = sg

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 120, 255)
stroke.Thickness = 2
stroke.Parent = main

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 30)
header.Text = "  22S x LEMON"
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
header.TextXAlignment = Enum.TextXAlignment.Left
header.Font = Enum.Font.SourceSansBold
header.TextSize = 16
header.Parent = main

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -27, 0, 3)
minBtn.Text = "-"
minBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 220)
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.SourceSansBold
minBtn.TextSize = 16
minBtn.Parent = main

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 5)
minCorner.Parent = minBtn

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 2
content.CanvasSize = UDim2.new(0, 0, 0, 250)
content.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 5)
padding.Parent = content

-- [[ 2. BUTONLARI GARANTİLİ OLUŞTURMA ]] --
local function CreateToggle(name, var)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Text = name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = content

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        Toggles[var] = not Toggles[var]
        btn.BackgroundColor3 = Toggles[var] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(25, 25, 35)
        btn.TextColor3 = Toggles[var] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
    end)
end

CreateToggle("⚡ Speed Hack", "Speed")
CreateToggle("🎯 Hitbox Expander", "Hitbox")
CreateToggle("⌨️ Auto Click E", "AutoE")
CreateToggle("⬅️ Auto Left (Z)", "AutoZ")
CreateToggle("➡️ Auto Right (C)", "AutoC")

local speedInp = Instance.new("TextBox")
speedInp.Size = UDim2.new(0.9, 0, 0, 25)
speedInp.PlaceholderText = "Hız (40)"
speedInp.Text = ""
speedInp.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
speedInp.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInp.Font = Enum.Font.SourceSans
speedInp.TextSize = 14
speedInp.Parent = content

local inpCorner = Instance.new("UICorner")
inpCorner.CornerRadius = UDim.new(0, 5)
inpCorner.Parent = speedInp

speedInp.FocusLost:Connect(function()
    Vars.SpeedVal = tonumber(speedInp.Text) or 40
end)

-- [[ 3. KÜÇÜLTME MANTIĞI ]] --
local open = true
minBtn.MouseButton1Click:Connect(function()
    open = not open
    if not open then
        main.Size = UDim2.new(0, 190, 0, 30)
        minBtn.Text = "+"
        content.Visible = false
    else
        main.Size = UDim2.new(0, 190, 0, 260)
        minBtn.Text = "-"
        content.Visible = true
    end
end)

-- [[ 4. KISAYOLLAR ]] --
UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.RightShift then main.Visible = not main.Visible end
    if i.KeyCode == Enum.KeyCode.Z then Toggles.AutoZ = not Toggles.AutoZ end
    if i.KeyCode == Enum.KeyCode.C then Toggles.AutoC = not Toggles.AutoC end
end)

-- [[ 5. MOTORLAR (Sona alındı ki UI yüklenmesini engellemesin) ]] --
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

        if Toggles.AutoZ and LP.Character then
             LP.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(-38.5, 3.5, 4.5))
        end
        if Toggles.AutoC and LP.Character then
             LP.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(38.5, 3.5, 4.5))
        end
    end)
end)

print("✅ GUI Kökten Çözüldü: CoreGui aktif, butonlar yüklendi!")
