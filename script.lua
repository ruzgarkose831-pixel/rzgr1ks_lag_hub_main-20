local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- GUI Ayarları
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "rzgr1ks_V3"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false 

-- Ana Menü
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 250, 0, 200)
Main.Position = UDim2.new(0.5, -125, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Main.Active = true
Main.Draggable = true 
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "rzgr1ks Hub"
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.BackgroundTransparency = 1
Title.TextScaled = true

-- Durum Değişkeni
_G.BoostActive = false

-- SÜREKLİ GÜNCELLEME DÖNGÜSÜ (Anti-Reset)
-- Bu kısım hızı ve zıplamayı oyunun sıfırlamasına izin vermeden her 0.1 saniyede bir zorlar.
task.spawn(function()
    while true do
        if _G.BoostActive then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.UseJumpPower = true
                    hum.WalkSpeed = 60 -- İstediğin hız değeri
                    hum.JumpPower = 15 -- İstediğin zıplama gücü (15)
                end
            end
        end
        task.wait(0.1) -- Çok hızlı kontrol ederek hilenin kapanmasını engeller
    end
end)

-- Ana Combo Butonu
local ComboBtn = Instance.new("TextButton", Main)
ComboBtn.Size = UDim2.new(0, 200, 0, 60)
ComboBtn.Position = UDim2.new(0.5, -100, 0.4, 0)
ComboBtn.Text = "BOOST : KAPALI"
ComboBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
ComboBtn.TextColor3 = Color3.white
ComboBtn.Font = Enum.Font.SourceSansBold
ComboBtn.TextSize = 18
Instance.new("UICorner", ComboBtn)

ComboBtn.MouseButton1Click:Connect(function()
    _G.BoostActive = not _G.BoostActive
    if _G.BoostActive then
        ComboBtn.Text = "BOOST : AÇIK\n(Hız: 60 | Zıplama: 15)"
        ComboBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 120)
    else
        ComboBtn.Text = "BOOST : KAPALI"
        ComboBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        
        -- Kapatıldığında normale döndür
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
    end
end)

-- Kapatma / Açma Sistemi
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Instance.new("UICorner", Close)

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0.02, 0, 0.7, 0)
OpenBtn.Text = "MENU"
OpenBtn.Visible = false
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

Close.MouseButton1Click:Connect(function() Main.Visible = false OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true OpenBtn.Visible = false end)
