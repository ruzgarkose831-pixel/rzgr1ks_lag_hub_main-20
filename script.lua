-- [[ 22S x LEMON: AÇILIR KAPANIR MİNİ MENÜ ]] --
local LP = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local Toggles = { Speed = false, Hitbox = false, AutoE = false }
local Vars = { SpeedVal = 35, HBSize = 12 }
local IsMinimized = false

-- [[ MOTORLAR ]] --
game:GetService("RunService").Stepped:Connect(function()
    pcall(function()
        if Toggles.Speed and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character:TranslateBy(LP.Character.Humanoid.MoveDirection * (Vars.SpeedVal/60))
        end
        if Toggles.Hitbox then
            for _, p in pairs(game:GetService("Players"):GetPlayers()) do
                if p ~= LP and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = Vector3.new(Vars.HBSize, Vars.HBSize, Vars.HBSize)
                    p.Character.HumanoidRootPart.Transparency = 0.7
                end
            end
        end
        if Toggles.AutoE then
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
        end
    end)
end)

-- [[ UI TASARIMI ]] --
local sg = Instance.new("ScreenGui", LP.PlayerGui); sg.Name = "MiniHybrid"
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 180, 0, 240)
main.Position = UDim2.new(1, -200, 0.4, 0) -- Sağ tarafa sabitledim
main.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
main.BorderSizePixel = 0
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(0, 120, 255); stroke.Thickness = 2

-- Başlık Çubuğu
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 30); header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Text = " 22S x LEMON"
title.Size = UDim2.new(0.7, 0, 1, 0); title.TextColor3 = Color3.new(1,1,1); title.TextXAlignment = "Left"; title.BackgroundTransparency = 1; title.Font = "SourceSansBold"

-- KÜÇÜLTME BUTONU (Minimize)
local minBtn = Instance.new("TextButton", header)
minBtn.Text = "-"; minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(1, -30, 0, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50); minBtn.TextColor3 = Color3.new(1,1,1); minBtn.BorderSizePixel = 0
Instance.new("UICorner", minBtn)

-- İçerik Kutusu
local content = Instance.new("Frame", main)
content.Position = UDim2.new(0, 0, 0, 35); content.Size = UDim2.new(1, 0, 1, -35); content.BackgroundTransparency = 1
local list = Instance.new("UIListLayout", content); list.Padding = UDim.new(0, 5); list.HorizontalAlignment = "Center"

-- Minimize Fonksiyonu
minBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        main:TweenSize(UDim2.new(0, 180, 0, 30), "Out", "Quart", 0.3, true)
        minBtn.Text = "+"
        content.Visible = false
    else
        main:TweenSize(UDim2.new(0, 180, 0, 240), "Out", "Quart", 0.3, true)
        minBtn.Text = "-"
        task.wait(0.2)
        content.Visible = true
    end
end)

-- Özellik Butonları
local function AddToggle(name, var)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.new(0.9, 0, 0, 28); b.BackgroundColor3 = Color3.fromRGB(25, 25, 40); b.TextColor3 = Color3.new(0.8,0.8,0.8); b.Text = name; b.Font = "SourceSans"
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Toggles[var] = not Toggles[var]
        b.BackgroundColor3 = Toggles[var] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(25, 25, 40)
        b.TextColor3 = Toggles[var] and Color3.new(1,1,1) or Color3.new(0.8,0.8,0.8)
    end)
end

AddToggle("Speed Hack", "Speed")
AddToggle("Hitbox Expander", "Hitbox")
AddToggle("Auto Click E", "AutoE")

-- Input Kutuları (Hız ve Hitbox Değerleri)
local function AddInput(placeholder, var)
    local i = Instance.new("TextBox", content)
    i.Size = UDim2.new(0.9, 0, 0, 25); i.PlaceholderText = placeholder; i.Text = ""; i.BackgroundColor3 = Color3.fromRGB(10, 10, 20); i.TextColor3 = Color3.white
    i.FocusLost:Connect(function() Vars[var] = tonumber(i.Text) or Vars[var] end)
    Instance.new("UICorner", i)
end

AddInput("Hız Değeri (35)", "SpeedVal")
AddInput("Hitbox Boyutu (12)", "HBSize")

print("✅ Menü Küçültme Tuşu Eklendi!")
