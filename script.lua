local plr = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local cg = game:GetService("CoreGui")

-- Executor destekliyorsa gethui, yoksa CoreGui kullan
local par = (gethui and gethui()) or cg
local guiName = "LemonHub_V2"

-- ESKİ GUI'Yİ SİLME İŞLEMİ (Üst üste binmeyi önler)
if par:FindFirstChild(guiName) then
    par[guiName]:Destroy()
end
if cg:FindFirstChild(guiName) then
    cg[guiName]:Destroy()
end

-- Renk Paleti (Senin orijinal renklerin)
local pm = Color3.fromRGB(15, 15, 15)
local pl = Color3.fromRGB(30, 30, 30)
local pa = Color3.fromRGB(50, 50, 50)
local wh = Color3.fromRGB(255, 255, 255)
local accent = Color3.fromRGB(200, 200, 0) -- Limon Sarısı

-----------------------------------
-- HİLE FONKSİYONLARI BAŞLANGICI --
-----------------------------------
local spinbot = false
local antiMode = nil
local conns = {}
local ragConns = {}

-- Spinbot Logic
local function spinOn(c)
    local hrp = c:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end
    for _, v in pairs(hrp:GetChildren()) do
        if v:IsA("BodyAngularVelocity") then v:Destroy() end
    end
    local bv = Instance.new("BodyAngularVelocity")
    bv.MaxTorque = Vector3.new(0, math.huge, 0)
    bv.AngularVelocity = Vector3.new(0, 40, 0)
    bv.Parent = hrp
end

local function spinOff(c)
    if c then
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v:IsA("BodyAngularVelocity") then v:Destroy() end
            end
        end
    end
end

-- Anti Ragdoll Logic (Basitleştirilmiş v1)
local function antiLoop()
    while antiMode == "v1" do
        task.wait()
        local c = plr.Character
        if c then
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum and (hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown) then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end
end

-----------------------------------
-- YENİ GUI OLUŞTURMA BAŞLANGICI --
-----------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = par

-- Ana Pencere
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
MainFrame.BackgroundColor3 = pm
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true -- Pencereyi fareyle sürükleyebilmeni sağlar

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 8)
UICornerMain.Parent = MainFrame

-- Üst Başlık Çubuğu
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = pl
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local UICornerTop = Instance.new("UICorner")
UICornerTop.CornerRadius = UDim.new(0, 8)
UICornerTop.Parent = TopBar

-- Alt köşeleri düzeltmek için yama
local TopBarPatch = Instance.new("Frame")
TopBarPatch.Size = UDim2.new(1, 0, 0, 10)
TopBarPatch.Position = UDim2.new(0, 0, 1, -10)
TopBarPatch.BackgroundColor3 = pl
TopBarPatch.BorderSizePixel = 0
TopBarPatch.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = accent
Title.Text = "🍋 22S x LEMON"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- İçerik Kutusu (Butonların duracağı yer)
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 4
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Container

-- Buton Oluşturma Fonksiyonu
local function createButton(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = pa
    btn.TextColor3 = wh
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.AutoButtonColor = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.Parent = Container
    return btn
end

-- Butonları Ekleme
local SpinBtn = createButton("Spinbot: KAPALI")
local AntiBtn = createButton("Anti-Ragdoll: KAPALI")
local CloseBtn = createButton("Menüyü Kapat (Sil)")
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)

-- Buton İşlevleri (Tıklama Olayları)
SpinBtn.MouseButton1Click:Connect(function()
    spinbot = not spinbot
    if spinbot then
        SpinBtn.Text = "Spinbot: AÇIK"
        SpinBtn.TextColor3 = accent
        if plr.Character then spinOn(plr.Character) end
        table.insert(conns, plr.CharacterAdded:Connect(function(c) spinOn(c) end))
    else
        SpinBtn.Text = "Spinbot: KAPALI"
        SpinBtn.TextColor3 = wh
        if plr.Character then spinOff(plr.Character) end
        for _, c in pairs(conns) do c:Disconnect() end
        conns = {}
    end
end)

AntiBtn.MouseButton1Click:Connect(function()
    if antiMode == "v1" then
        antiMode = nil
        AntiBtn.Text = "Anti-Ragdoll: KAPALI"
        AntiBtn.TextColor3 = wh
    else
        antiMode = "v1"
        AntiBtn.Text = "Anti-Ragdoll: AÇIK"
        AntiBtn.TextColor3 = accent
        task.spawn(antiLoop)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    -- Özellikleri kapat
    spinbot = false
    antiMode = nil
    if plr.Character then spinOff(plr.Character) end
    -- GUI'yi tamamen yok et
    ScreenGui:Destroy()
end)
