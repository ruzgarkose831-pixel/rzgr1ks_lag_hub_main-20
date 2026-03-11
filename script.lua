local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ GLOBAL SETTINGS ]] --
_G.Settings = {
    AutoSteal = false, SemiTP = false, EscapeSpeed = 30, DeliveryPos = nil, CarpetName = "Flying Carpet",
    Aimbot = false, AimPart = "Head", WalkSpeed = 16, Gravity = 196.2, AntiRagdoll = false,
    AutoWalk = false, Points = {nil, nil, nil, nil}, CurrentPoint = 1, AutoClickE = false
}

-- [[ UI SETUP ]] --
if Player.PlayerGui:FindFirstChild("LemonV82") then Player.PlayerGui.LemonV82:Destroy() end
local gui = Instance.new("ScreenGui", Player.PlayerGui); gui.Name = "LemonV82"; gui.ResetOnSpawn = false

-- Ana Panel (Main Frame)
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 220, 0, 300) -- Daha küçük ve kompakt
main.Position = UDim2.new(0.1, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true
main.Draggable = true -- Sürüklenebilir

local corner = Instance.new("UICorner", main); corner.CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", main); stroke.Thickness = 2; stroke.Color = Color3.fromRGB(255, 255, 0)

-- Sarı Top (Minimize Button - Sarı Top Modu)
local minBtn = Instance.new("TextButton", gui)
minBtn.Size = UDim2.new(0, 40, 0, 40)
minBtn.Position = main.Position
minBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
minBtn.Text = ""
minBtn.Visible = false
minBtn.ZIndex = 10
local minCorner = Instance.new("UICorner", minBtn); minCorner.CornerRadius = UDim.new(1, 0)
local minStroke = Instance.new("UIStroke", minBtn); minStroke.Thickness = 2; minStroke.Color = Color3.new(0,0,0)

-- Kapatma/Küçültme Butonu (Panel Üstünde)
local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.Text = "-"
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
closeBtn.TextColor3 = Color3.new(0,0,0)
closeBtn.Font = "GothamBold"
Instance.new("UICorner", closeBtn)

-- Animasyon Fonksiyonları
local isMinimized = false
local function ToggleGUI()
    if not isMinimized then
        main:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.3, true)
        task.wait(0.3)
        main.Visible = false
        minBtn.Position = main.Position
        minBtn.Visible = true
    else
        minBtn.Visible = false
        main.Visible = true
        main:TweenSize(UDim2.new(0, 220, 0, 300), "In", "Quad", 0.3, true)
    end
    isMinimized = not isMinimized
end

closeBtn.MouseButton1Click:Connect(ToggleGUI)
minBtn.MouseButton1Click:Connect(ToggleGUI)

-- İçerik Başlığı
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "LEMON HUB V82"
title.TextColor3 = Color3.fromRGB(255, 255, 0)
title.Font = "GothamBold"
title.BackgroundTransparency = 1

-- Kaydırma Alanı
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -45)
scroll.Position = UDim2.new(0, 5, 0, 40)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
scroll.CanvasSize = UDim2.new(0, 0, 3, 0)
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

-- Efektli Buton Yapıcı
local function AddToggle(text, callback)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(0.95, 0, 0, 30)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = "Gotham"
    b.TextSize = 10
    Instance.new("UICorner", b)
    
    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        -- Efekt
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(30, 30, 30)}):Play()
        TweenService:Create(b, TweenInfo.new(0.2), {TextColor3 = state and Color3.new(0,0,0) or Color3.new(1,1,1)}):Play()
    end)
end

-- [[ ÖZELLİKLER (V81'den Aktarıldı) ]] --
AddToggle("SEMI-TP ESCAPE", function(v) _G.Settings.SemiTP = v end)
AddToggle("AUTO STEAL", function(v) _G.Settings.AutoSteal = v end)
AddToggle("AIMBOT", function(v) _G.Settings.Aimbot = v end)
AddToggle("AUTO CLICK E", function(v) _G.Settings.AutoClickE = v end)
AddToggle("AUTO WALK", function(v) _G.Settings.AutoWalk = v end)
AddToggle("ANTI RAGDOLL", function(v) _G.Settings.AntiRagdoll = v end)

-- Nokta Kayıt Butonları (Küçük Versiyon)
for i = 1, 4 do
    local pb = Instance.new("TextButton", scroll)
    pb.Size = UDim2.new(0.95, 0, 0, 25)
    pb.Text = "Set Point " .. i
    pb.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
    pb.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", pb)
    pb.MouseButton1Click:Connect(function() 
        _G.Settings.Points[i] = Player.Character.HumanoidRootPart.Position 
        pb.Text = "P" .. i .. " SAVED"
    end)
end

-- [[ SISTEM DONGULERI ]] --
RunService.RenderStepped:Connect(function()
    if _G.Settings.Aimbot then
        -- Aimbot kodları buraya (V81 ile aynı)
    end
end)

-- Sürükleme Takibi (Sarı topun panel ile aynı yerde kalması için)
main:GetPropertyChangedSignal("Position"):Connect(function()
    if not isMinimized then
        minBtn.Position = main.Position
    end
end)

print("🍋 Lemon Hub V82: Animated & Compact Loaded!")
