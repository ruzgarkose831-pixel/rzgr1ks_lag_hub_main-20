local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local LP = Players.LocalPlayer

local Toggles = {Speed = false, Jump = false, Grav = false, Spin = false, ESP = false, HB = false, Bat = false, AutoE = false}
local Vars = {SpeedVal = 40, JumpVal = 70, GravVal = 50, HBSize = 12}

-- [[ 1. GARANTİLİ GUI OLUŞTURMA (BÜYÜTÜLMÜŞ BOYUT) ]] --
local guiName = "rzgr1ks_duels_gui_big"
local guiParent = (gethui and gethui()) or game:GetService("CoreGui") or LP:FindFirstChild("PlayerGui")

if guiParent:FindFirstChild(guiName) then guiParent[guiName]:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name = guiName
sg.Parent = guiParent

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 470) -- GENİŞLİK 210'dan 280'e, YÜKSEKLİK 360'tan 470'e ÇIKARILDI
main.Position = UDim2.new(0.5, -140, 0.5, -235) -- Tam ortaya ayarlandı
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = sg

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(0, 120, 255); stroke.Thickness = 2

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 45) -- Başlık daha kalın oldu
title.Text = "rzgr1ks duels"
title.TextColor3 = Color3.white
title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
title.Font = "SourceSansBold"
title.TextSize = 22 -- Yazı boyutu büyütüldü
title.Parent = main

-- [[ 2. BUTONLARI ELLE YERLEŞTİRME (DAHA BÜYÜK VE ARALIKLI) ]] --
local function CreateBtn(name, var, yPos)
    local btn = Instance.new("TextButton", main)
    btn.Name = name
    btn.Size = UDim2.new(0, 250, 0, 40) -- Butonlar daha geniş (250) ve daha kalın (40)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.Text = name
    btn.TextColor3 = Color3.white
    btn.Font = "SourceSansBold"
    btn.TextSize = 18 -- Buton yazıları büyüdü
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        Toggles[var] = not Toggles[var]
        btn.BackgroundColor3 = Toggles[var] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(35, 35, 45)
    end)
end

local function CreateInp(hint, var, def, yPos)
    local inp = Instance.new("TextBox", main)
    inp.Size = UDim2.new(0, 250, 0, 35) -- Kutucuklar daha büyük
    inp.Position = UDim2.new(0, 15, 0, yPos)
    inp.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    inp.PlaceholderText = hint
    inp.Text = ""
    inp.TextColor3 = Color3.white
    inp.Font = "SourceSans"
    inp.TextSize = 16 -- Kutu yazıları büyüdü
    Instance.new("UICorner", inp)
    inp.FocusLost:Connect(function() Vars[var] = tonumber(inp.Text) or def end)
end

-- Koordinatları büyüyen butonlara göre ayarladık
CreateBtn("⚡ Speed Hack", "Speed", 55)
CreateBtn("⬆️ Jump Power", "Jump", 100)
CreateBtn("🌌 Gravity Mode", "Grav", 145)
CreateBtn("🔄 Spinbot", "Spin", 190)
CreateBtn("👁️ ESP (Kırmızı)", "ESP", 235)
CreateBtn("🎯 Karakter Hitbox", "HB", 280)
CreateBtn("🏏 Sopa Hitbox", "Bat", 325)
CreateBtn("🖐️ Auto E (Mobile)", "AutoE", 370)

CreateInp("Hız (Örn: 50)", "SpeedVal", 40, 415)

-- [[ 3. ÖZELLİK MOTORLARI ]] --
RS.RenderStepped:Connect(function()
    pcall(function()
        local char = LP.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        -- Speed & Jump
        if hum then
            hum.WalkSpeed = Toggles.Speed and Vars.SpeedVal or 16
            if Toggles.Jump then hum.UseJumpPower = true; hum.JumpPower = Vars.JumpVal else hum.JumpPower = 50 end
        end

        workspace.Gravity = Toggles.Grav and Vars.GravVal or 196.2

        if Toggles.Spin and hrp then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(15), 0)
        end

        if Toggles.HB then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = Vector3.new(Vars.HBSize, Vars.HBSize, Vars.HBSize)
                    p.Character.HumanoidRootPart.Transparency = 0.7
                    p.Character.HumanoidRootPart.CanCollide = false
                end
            end
        end

        if Toggles.Bat and char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                tool.Handle.Size = Vector3.new(Vars.HBSize, Vars.HBSize, Vars.HBSize)
                tool.Handle.Transparency = 0.5
            end
        end
    end)
end)

-- Auto E (Mobil Uyumlu)
task.spawn(function()
    while task.wait(0.2) do
        if Toggles.AutoE then
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and v.Enabled then
                        local d = (v.Parent.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                        if d <= 15 then 
                            if fireproximityprompt then fireproximityprompt(v) else
                                v.HoldDuration = 0; v:InputHoldBegin(); task.wait(); v:InputHoldEnd()
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
    if Toggles.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and not p.Character:FindFirstChild("ESP_HL") then
                local hl = Instance.new("Highlight", p.Character)
                hl.Name = "ESP_HL"; hl.FillColor = Color3.new(1,0,0)
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("ESP_HL") then p.Character.ESP_HL:Destroy() end
        end
    end
end)

print("✅ rzgr1ks duels (BÜYÜK ARAYÜZ) Yüklendi! İyi oyunlar.")
