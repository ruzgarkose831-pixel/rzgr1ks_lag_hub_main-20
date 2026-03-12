local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local Toggles = {
    Speed = false, Jump = false, Gravity = false, Spin = false, 
    ESP = false, Hitbox = false, BatHitbox = false, AutoE = false
}
local Vars = {
    SpeedVal = 40, JumpVal = 70, GravVal = 50, SpinSpeed = 15, HBSize = 12
}

-- [[ 1. GÜVENLİ GUI OLUŞTURMA (CoreGui) ]] --
local guiParent
pcall(function() guiParent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not guiParent then guiParent = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui") end

if guiParent:FindFirstChild("Lemon22S_V5") then
    guiParent.Lemon22S_V5:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name = "Lemon22S_V5"
sg.ResetOnSpawn = false
sg.Parent = guiParent

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 200, 0, 300)
main.Position = UDim2.new(0.85, -100, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = sg

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(0, 120, 255); stroke.Thickness = 2

-- Başlık & Küçültme Tuşu
local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1, 0, 0, 30); header.Text = "  22S x LEMON V5"; header.TextColor3 = Color3.new(1,1,1); header.BackgroundColor3 = Color3.fromRGB(10, 10, 15); header.TextXAlignment = "Left"; header.Font = "SourceSansBold"; header.TextSize = 16

local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 24, 0, 24); minBtn.Position = UDim2.new(1, -27, 0, 3); minBtn.Text = "-"; minBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 220); minBtn.TextColor3 = Color3.white; minBtn.Font = "SourceSansBold"
Instance.new("UICorner", minBtn)

-- İçerik Alanı
local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, 0, 1, -30); content.Position = UDim2.new(0, 0, 0, 30); content.BackgroundTransparency = 1; content.ScrollBarThickness = 2; content.CanvasSize = UDim2.new(0, 0, 0, 450)
local layout = Instance.new("UIListLayout", content); layout.Padding = UDim.new(0, 5); layout.HorizontalAlignment = "Center"
Instance.new("UIPadding", content).PaddingTop = UDim.new(0, 5)

-- [[ 2. UI ELEMANLARI OLUŞTURUCU ]] --
local function CreateToggle(name, var)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(0.9, 0, 0, 30); btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35); btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.Text = name; btn.Font = "SourceSansBold"; btn.TextSize = 14
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        Toggles[var] = not Toggles[var]
        btn.BackgroundColor3 = Toggles[var] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(25, 25, 35)
        btn.TextColor3 = Toggles[var] and Color3.new(1,1,1) or Color3.fromRGB(200, 200, 200)
    end)
end

local function CreateInput(placeholder, var, default)
    local inp = Instance.new("TextBox", content)
    inp.Size = UDim2.new(0.9, 0, 0, 25); inp.PlaceholderText = placeholder; inp.Text = ""; inp.BackgroundColor3 = Color3.fromRGB(20, 20, 30); inp.TextColor3 = Color3.white; inp.Font = "SourceSans"
    Instance.new("UICorner", inp)
    inp.FocusLost:Connect(function() Vars[var] = tonumber(inp.Text) or default end)
end

-- Butonları Diziyoruz
CreateToggle("⚡ Speed Hack", "Speed")
CreateToggle("⬆️ Jump Power", "Jump")
CreateToggle("🌌 Gravity Mode", "Gravity")
CreateToggle("🔄 Spinbot", "Spin")
CreateToggle("👁️ Player ESP", "ESP")
CreateToggle("🎯 Player Hitbox", "Hitbox")
CreateToggle("🏏 Bat Hitbox", "BatHitbox")
CreateToggle("🖐️ Auto Interact (Mobil)", "AutoE")

CreateInput("Hız Değeri (40)", "SpeedVal", 40)
CreateInput("Zıplama Gücü (70)", "JumpVal", 70)
CreateInput("Yerçekimi (50)", "GravVal", 50)
CreateInput("Hitbox Boyutu (12)", "HBSize", 12)

-- [[ 3. KÜÇÜLTME & KISAYOL ]] --
local open = true
minBtn.MouseButton1Click:Connect(function()
    open = not open
    main.Size = open and UDim2.new(0, 200, 0, 300) or UDim2.new(0, 200, 0, 30)
    minBtn.Text = open and "-" or "+"
    content.Visible = open
end)

UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.RightShift then main.Visible = not main.Visible end
end)

-- [[ 4. MOBİL UYUMLU AUTO INTERACT (YENİ) ]] --
task.spawn(function()
    while task.wait(0.1) do
        if Toggles.AutoE then
            pcall(function()
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, obj in pairs(workspace:GetDescendants()) do
                        -- Eğer obje bir ProximityPrompt ise ve aktifse
                        if obj:IsA("ProximityPrompt") and obj.Enabled then
                            local dist = (obj.Parent.Position - hrp.Position).Magnitude
                            -- Karakterin etkileşim mesafesinde mi kontrol et
                            if dist <= (obj.MaxActivationDistance + 5) then
                                -- Basılı tutma simülasyonu (Mobil destekli)
                                local originalHold = obj.HoldDuration
                                obj.HoldDuration = 0 -- Bekleme süresini sıfırla
                                obj:InputHoldBegin() -- Basmaya başla
                                task.wait()
                                obj:InputHoldEnd()   -- Basmayı bırak (İşlemi tamamlar)
                                obj.HoldDuration = originalHold
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- [[ 5. DİĞER MOTORLAR VE ÖZELLİKLER ]] --
RS.RenderStepped:Connect(function()
    pcall(function()
        local char = LP.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if hum then
            if Toggles.Speed then hum.WalkSpeed = Vars.SpeedVal else hum.WalkSpeed = 16 end
            if Toggles.Jump then 
                hum.UseJumpPower = true 
                hum.JumpPower = Vars.JumpVal 
            else 
                hum.JumpPower = 50 
            end
        end

        if Toggles.Gravity then workspace.Gravity = Vars.GravVal else workspace.Gravity = 196.2 end

        if Toggles.Spin and hrp then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Vars.SpinSpeed), 0)
        end

        if Toggles.Hitbox then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local targHrp = p.Character.HumanoidRootPart
                    targHrp.Size = Vector3.new(Vars.HBSize, Vars.HBSize, Vars.HBSize)
                    targHrp.Transparency = 0.6
                    targHrp.CanCollide = false
                end
            end
        end

        if Toggles.BatHitbox and char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                tool.Handle.Size = Vector3.new(Vars.HBSize, Vars.HBSize, Vars.HBSize)
                tool.Handle.Transparency = 0.5
            end
        end
    end)
end)

-- [[ 6. ESP SİSTEMİ ]] --
local function UpdateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hl = p.Character:FindFirstChild("ESP_Highlight")
            if Toggles.ESP then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "ESP_Highlight"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                    hl.Parent = p.Character
                end
            else
                if hl then hl:Destroy() end
            end
        end
    end
end
RS.Heartbeat:Connect(function() pcall(UpdateESP) end)

print("✅ MOBİL UYUMLU V5 YÜKLENDİ: Auto-E artık ekrandaki kutuları kendisi basılı tutarak açar!")
