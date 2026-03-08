local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- GUI Temizliği (Eskileri siler)
if player:WaitForChild("PlayerGui"):FindFirstChild("rzgr1ks_Final") then
    player.PlayerGui.rzgr1ks_Final:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "rzgr1ks_Final"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Ana Panel
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 240, 0, 200)
Main.Position = UDim2.new(0.5, -120, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true 

-- Başlık
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "rzgr1ks Hub V6"
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

-- Değişkenler
_G.Boost = false
_G.ESP = false

-- SÜREKLİ DÖNGÜ (Zorla Uygula)
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local char = player.Character
            if char and _G.Boost then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.UseJumpPower = true
                    hum.JumpPower = 15
                    -- Tool kontrolü
                    if char:FindFirstChildOfClass("Tool") then
                        hum.WalkSpeed = 30
                    else
                        hum.WalkSpeed = 60
                    end
                end
            end
            
            -- ESP Döngüsü
            if _G.ESP then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character then
                        local h = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
                        h.FillColor = Color3.fromRGB(255, 0, 0)
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                    end
                end
            end
        end)
    end
end)

-- BASİT BUTON OLUŞTURUCU
local function makeBtn(txt, pos, color, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0, 200, 0, 45)
    b.Position = UDim2.new(0, 20, 0, pos)
    b.Text = txt
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.white
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.ZIndex = 10 -- En üstte olması için
    
    -- Mobilde en iyi çalışan tıklama olayı
    b.MouseButton1Click:Connect(function()
        callback()
    end)
    
    return b
end

-- Butonları Tanımla
local boostBtn = makeBtn("BOOST: OFF", 60, Color3.fromRGB(50, 50, 60), function()
    _G.Boost = not _G.Boost
    -- Buraya buton metni güncelleme eklenebilir ama donmayı engellemek için sade bıraktım
end)

local espBtn = makeBtn("ESP: OFF", 115, Color3.fromRGB(50, 50, 60), function()
    _G.ESP = not _G.ESP
    if not _G.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Highlight") then
                p.Character.Highlight:Destroy()
            end
        end
    end
end)

-- Durum Güncelleme (Görsel geri bildirim)
task.spawn(function()
    while task.wait(0.3) do
        boostBtn.Text = _G.Boost and "BOOST: ON (Speed/Jump)" or "BOOST: OFF"
        boostBtn.BackgroundColor3 = _G.Boost and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(50, 50, 60)
        
        espBtn.Text = _G.ESP and "ESP: ON" or "ESP: OFF"
        espBtn.BackgroundColor3 = _G.ESP and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(50, 50, 60)
    end
end)
