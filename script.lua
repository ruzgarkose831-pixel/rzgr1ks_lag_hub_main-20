local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local LP = Players.LocalPlayer

local Toggles = {
    Speed = false, Jump = false, Gravity = false, Spin = false, 
    ESP = false, Hitbox = false, BatHitbox = false, AutoE = false
}
local Vars = {
    SpeedVal = 40, JumpVal = 70, GravVal = 50, SpinSpeed = 15, HBSize = 12
}

-- [[ 1. AGRESİF TEMİZLİK VE GUI OLUŞTURMA ]] --
local guiName = "LemonV8_Fixed"
local guiParent = nil
pcall(function() guiParent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not guiParent then guiParent = LP:FindFirstChild("PlayerGui") end

if guiParent:FindFirstChild(guiName) then
    guiParent[guiName]:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name = guiName
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true -- Çentiği görmezden gel
sg.Parent = guiParent

-- Ana Panel (Ortada)
local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.new(0, 220, 0, 320)
main.Position = UDim2.new(0.5, -110, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = sg

local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(0, 150, 255); stroke.Thickness = 2
local corner = Instance.new("UICorner", main); corner.CornerRadius = UDim.new(0, 10)

-- Başlık
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
title.Text = "22S x LEMON V8 FIXED"
title.TextColor3 = Color3.white
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = main
Instance.new("UICorner", title)

-- Kapatma/Küçültme Butonu
local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 2)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
close.TextColor3 = Color3.white
close.Parent = main
Instance.new("UICorner", close)
close.MouseButton1Click:Connect(function() sg:Destroy() end)

-- Kaydırma Alanı (Zorunlu Boyutlandırma)
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -45)
scroll.Position = UDim2.new(0, 5, 0, 40)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 500) -- Elle büyük yaptık ki boş kalmasın
scroll.ScrollBarThickness = 4
scroll.Parent = main

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- [[ 2. ELEMENT OLUŞTURMA FONKSİYONLARI ]] --
local function NewButton(txt, var)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.95, 0, 0, 35) -- Boyutu net veriyoruz
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    b.Text = txt
    b.TextColor3 = Color3.white
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    b.Parent = scroll
    Instance.new("UICorner", b)
    
    b.MouseButton1Click:Connect(function()
        Toggles[var] = not Toggles[var]
        b.BackgroundColor3 = Toggles[var] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(40, 40, 50)
    end)
end

local function NewInput(hint, var, def)
    local i = Instance.new("TextBox")
    i.Size = UDim2.new(0.95, 0, 0, 30)
    i.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    i.PlaceholderText = hint
    i.Text = ""
    i.TextColor3 = Color3.white
    i.Font = Enum.Font.SourceSans
    i.TextSize = 14
    i.Parent = scroll
    Instance.new("UICorner", i)
    i.FocusLost:Connect(function() Vars[var] = tonumber(i.Text) or def end)
end

-- Butonlar ve Girdiler (Sırayla)
NewButton("⚡ Speed Hack (Eski Stil)", "Speed")
NewButton("⬆️ Jump Power", "Jump")
NewButton("🌌 Gravity Mode", "Gravity")
NewButton("🔄 Spinbot", "Spin")
NewButton("👁️ Player ESP", "ESP")
NewButton("🎯 Player Hitbox", "Hitbox")
NewButton("🏏 Bat Hitbox", "BatHitbox")
NewButton("🖐️ Auto E (Mobile)", "AutoE")

NewInput("Hız Değeri (40)", "SpeedVal", 40)
NewInput("Zıplama Gücü (70)", "JumpVal", 70)
NewInput("Yerçekimi (50)", "GravVal", 50)
NewInput("Hitbox Boyutu (12)", "HBSize", 12)

-- [[ 3. ÖZELLİK MOTORLARI ]] --
RS.RenderStepped:Connect(function()
    pcall(function()
        local char = LP.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        -- Speed & Jump
        if hum then
            if Toggles.Speed then hum.WalkSpeed = Vars.SpeedVal else hum.WalkSpeed = 16 end
            if Toggles.Jump then 
                hum.UseJumpPower = true 
                hum.JumpPower = Vars.JumpVal 
            else 
                hum.JumpPower = 50 
            end
        end

        -- Gravity
        workspace.Gravity = Toggles.Gravity and Vars.GravVal or 196.2

        -- Spinbot
        if Toggles.Spin and hrp then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Vars.SpinSpeed), 0)
        end

        -- Hitbox Expander
        if Toggles.Hitbox then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local h = p.Character.HumanoidRootPart
                    h.Size = Vector3.new(Vars.HBSize, Vars.HBSize, Vars.HBSize)
                    h.Transparency = 0.7; h.CanCollide = false
                end
            end
        end

        -- Bat Hitbox
        if Toggles.BatHitbox and char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                tool.Handle.Size = Vector3.new(Vars.HBSize, Vars.HBSize, Vars.HBSize)
                tool.Handle.Transparency = 0.5
            end
        end
    end)
end)

-- Auto E (Mobile Fix)
task.spawn(function()
    while task.wait(0.2) do
        if Toggles.AutoE then
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and obj.Enabled then
                        local dist = (obj.Parent.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= obj.MaxActivationDistance + 3 then
                            if fireproximityprompt then fireproximityprompt(obj) else
                                obj.HoldDuration = 0; obj:InputHoldBegin(); task.wait(); obj:InputHoldEnd()
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ESP
RS.Heartbeat:Connect(function()
    pcall(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local hl = p.Character:FindFirstChild("ESP_HL")
                if Toggles.ESP then
                    if not hl then
                        hl = Instance.new("Highlight", p.Character)
                        hl.Name = "ESP_HL"; hl.FillColor = Color3.new(1,0,0); hl.OutlineColor = Color3.new(1,1,1)
                    end
                elseif hl then hl:Destroy() end
            end
        end
    end)
end)

print("✅ V8 FIXED YÜKLENDİ - Menü Boş Kalma Sorunu Çözüldü!")
