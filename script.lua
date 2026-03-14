--[[
    ====================================================================================================
    @project: RZGR1KS DUELS - ENTERPRISE PRIVATE EXECUTIVE
    @version: 5.0.6 (X-Ray & Multi-Language Update)
    @status: Ultra-Stable
    
    [CHANGELOG V5.0.6]
    - LANGUAGE SYSTEM: Added TR/EN toggle with persistent saving.
    - X-RAY MODULE: Restored high-performance structure transparency.
    - REFINED CONFIG: Optimized JSON structure for language localization.
    ====================================================================================================
]]--

if not game:IsLoaded() then repeat task.wait() until game:IsLoaded() end

-- // SERVISLER
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- // DEGISKENLER
local LocalPlayer = Players.LocalPlayer
local ConfigFileName = "RZGR1KS_V5_FINAL.json"

-- // DIL TABLOSU (LANGUAGES)
local Langs = {
    ["TR"] = {
        Open = "AÇ", Close = "KAPAT",
        ConfigSec = "Konfigürasyon ve Dil",
        LangToggle = "Dil / Language",
        Save = "Ayarları Kaydet",
        Reset = "Sıfırla",
        CombatSec = "Savaş Operasyonları",
        HB = "Hitbox Genişletme",
        HBSize = "Hitbox Boyutu",
        Spin = "Fiziksel Spinbot",
        SpinSpd = "Dönüş Hızı",
        MoveSec = "Fizyoloji / Hareket",
        Speed = "Yürüme Hızı",
        Jump = "Zıplama Gücü",
        Grav = "Yerçekimi",
        InfJump = "Sınırsız Zıplama",
        VisualSec = "Görsel Zeka",
        ESP = "Oyuncu ESP (Highlight)",
        XRay = "Yapı X-Ray (Duvar Arkası)",
        SocialSec = "Sosyal",
        Copied = "KOPYALANDI!"
    },
    ["EN"] = {
        Open = "OPEN", Close = "CLOSE",
        ConfigSec = "Config & Language",
        LangToggle = "Language / Dil",
        Save = "Save Settings",
        Reset = "Reset Config",
        CombatSec = "Combat Operations",
        HB = "Hitbox Expander",
        HBSize = "Hitbox Size",
        Spin = "Physical Spinbot",
        SpinSpd = "Spin Velocity",
        MoveSec = "Physiology / Movement",
        Speed = "Walk Speed",
        Jump = "Jump Power",
        Grav = "Gravity Control",
        InfJump = "Infinite Jump",
        VisualSec = "Visual Intelligence",
        ESP = "Player ESP (Highlight)",
        XRay = "Structure X-Ray",
        SocialSec = "Socials",
        Copied = "COPIED!"
    }
}

-- // VARSAYILAN AYARLAR
local Config = {
    Language = "TR", -- Varsayılan Türkçe
    Combat = { HitboxEnabled = false, HitboxSize = 25, SpinbotActive = false, SpinRPM = 50 },
    Movement = { Speed = 16, Jump = 50, Gravity = 196.2, InfiniteJump = false },
    Visuals = { HighlightESP = false, XRayActive = false, XRayTrans = 0.6 },
    Misc = { AntiAFK = true }
}

-- // 💾 CONFIG MOTORU
local function SaveConfig()
    pcall(function() if writefile then writefile(ConfigFileName, HttpService:JSONEncode(Config)) end end)
end

local function LoadConfig()
    pcall(function()
        if isfile and isfile(ConfigFileName) then
            local data = HttpService:JSONDecode(readfile(ConfigFileName))
            for cat, sub in pairs(data) do
                if type(sub) == "table" then
                    for k, v in pairs(sub) do Config[cat][k] = v end
                else
                    Config[cat] = sub
                end
            end
        end
    end)
end
LoadConfig()

-- // 🛠️ X-RAY MODÜLÜ
local XRayCache = {}
local function ToggleXRay(state)
    if state then
        task.spawn(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
                    if not obj.Parent:FindFirstChildOfClass("Humanoid") and obj.Transparency < 1 then
                        XRayCache[obj] = obj.Transparency
                        obj.Transparency = Config.Visuals.XRayTrans
                    end
                end
            end
        end)
    else
        for part, trans in pairs(XRayCache) do if part and part.Parent then part.Transparency = trans end end
        table.clear(XRayCache)
    end
end

-- // GUI BASLANGIC
local TargetParent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
if TargetParent:FindFirstChild("RZGR1KS_V6") then TargetParent:FindFirstChild("RZGR1KS_V6"):Destroy() end

local ScreenUI = Instance.new("ScreenGui", TargetParent)
ScreenUI.Name = "RZGR1KS_V6"; ScreenUI.ResetOnSpawn = false; ScreenUI.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame", ScreenUI)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12); MainFrame.Size = UDim2.new(0, 380, 0, 52); MainFrame.Position = UDim2.new(0.5, -190, 0.2, 0); MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 52); Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "RZGR1KS DUELS : ENTERPRISE"; Title.Font = "GothamBold"; Title.TextColor3 = Color3.fromRGB(220, 40, 40); Title.TextSize = 14; Title.Size = UDim2.new(1, -120, 1, 0); Title.Position = UDim2.new(0, 20, 0, 0); Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

local ToggleBtn = Instance.new("TextButton", Header)
ToggleBtn.Text = Langs[Config.Language].Open; ToggleBtn.Size = UDim2.new(0, 80, 0, 32); ToggleBtn.Position = UDim2.new(1, -95, 0, 10); ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); ToggleBtn.TextColor3 = Color3.new(1, 1, 1); ToggleBtn.Font = "GothamBold"; ToggleBtn.TextSize = 11
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Position = UDim2.new(0, 10, 0, 65); Content.Size = UDim2.new(1, -20, 0, 435); Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 1; Content.Visible = false; Content.AutomaticCanvasSize = "Y"
Instance.new("UIListLayout", Content).Padding = UDim.new(0, 8)

-- // UI FABRIKASI
local Components = {}
local RefreshUI = function() end -- Global yenileme

function Components:Section(langKey)
    local l = Instance.new("TextLabel", Content)
    l.Size = UDim2.new(1, 0, 0, 25); l.BackgroundTransparency = 1; l.Font = "GothamBold"; l.TextColor3 = Color3.fromRGB(220, 40, 40); l.TextSize = 10
    local update = function() l.Text = ">>> " .. Langs[Config.Language][langKey]:upper() .. " <<<" end
    update(); return update
end

function Components:Toggle(langKey, dataset, key, callback)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(1, -10, 0, 40); b.Font = "GothamBold"; b.TextColor3 = Color3.new(1, 1, 1); b.TextSize = 11; Instance.new("UICorner", b)
    local update = function()
        b.Text = Langs[Config.Language][langKey] .. " : " .. (dataset[key] and "ON" or "OFF")
        b.BackgroundColor3 = dataset[key] and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(20, 20, 20)
    end
    b.MouseButton1Click:Connect(function()
        dataset[key] = not dataset[key]
        update(); if callback then callback(dataset[key]) end; SaveConfig()
    end)
    update(); return update
end

function Components:Slider(langKey, min, max, dataset, key, callback)
    local f = Instance.new("Frame", Content); f.Size = UDim2.new(1, -10, 0, 60); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.BackgroundTransparency = 1; l.Font = "Gotham"; l.TextColor3 = Color3.new(0.8, 0.8, 0.8); l.TextSize = 11; l.TextXAlignment = "Left"
    local t = Instance.new("TextButton", f); t.Size = UDim2.new(1, 0, 0, 10); t.Position = UDim2.new(0, 0, 0, 25); t.BackgroundColor3 = Color3.fromRGB(30, 30, 30); t.Text = ""
    local fill = Instance.new("Frame", t); fill.Size = UDim2.new(math.clamp((dataset[key]-min)/(max-min), 0, 1), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
    Instance.new("UICorner", t); Instance.new("UICorner", fill)
    
    local isSliding = false
    local updateText = function() l.Text = Langs[Config.Language][langKey] .. " : " .. dataset[key] end
    local function UpdateVal()
        local scale = math.clamp((UIS:GetMouseLocation().X - t.AbsolutePosition.X) / t.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (scale * (max - min)))
        dataset[key] = val; updateText(); fill.Size = UDim2.new(scale, 0, 1, 0)
        if callback then callback() end
    end
    t.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isSliding = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then if isSliding then isSliding = false; SaveConfig() end end end)
    RunService.RenderStepped:Connect(function() if isSliding then UpdateVal() end end)
    updateText(); return updateText
end

function Components:Button(langKey, callback)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(1, -10, 0, 35); b.BackgroundColor3 = Color3.fromRGB(35, 35, 35); b.Font = "GothamBold"; b.TextColor3 = Color3.new(1, 1, 1); b.TextSize = 11; Instance.new("UICorner", b)
    local update = function() b.Text = Langs[Config.Language][langKey] or langKey end
    b.MouseButton1Click:Connect(callback); update(); return update
end

-- // 🟢 UI OLUŞTURMA VE GÜNCELLEME LİSTESİ
local UIElements = {}

table.insert(UIElements, Components:Section("ConfigSec"))
table.insert(UIElements, Components:Button("LangToggle", function()
    Config.Language = (Config.Language == "TR") and "EN" or "TR"
    for _, updateFunc in pairs(UIElements) do updateFunc() end
    ToggleBtn.Text = Content.Visible and Langs[Config.Language].Close or Langs[Config.Language].Open
    SaveConfig()
end))
table.insert(UIElements, Components:Button("Save", SaveConfig))

table.insert(UIElements, Components:Section("CombatSec"))
table.insert(UIElements, Components:Toggle("HB", Config.Combat, "HitboxEnabled"))
table.insert(UIElements, Components:Slider("HBSize", 2, 250, Config.Combat, "HitboxSize"))
table.insert(UIElements, Components:Toggle("Spin", Config.Combat, "SpinbotActive"))

table.insert(UIElements, Components:Section("MoveSec"))
table.insert(UIElements, Components:Slider("Speed", 16, 500, Config.Movement, "Speed"))
table.insert(UIElements, Components:Slider("Jump", 50, 1000, Config.Movement, "Jump"))
table.insert(UIElements, Components:Slider("Grav", 0, 1000, Config.Movement, "Gravity"))
table.insert(UIElements, Components:Toggle("InfJump", Config.Movement, "InfiniteJump"))

table.insert(UIElements, Components:Section("VisualSec"))
table.insert(UIElements, Components:Toggle("ESP", Config.Visuals, "HighlightESP", function(v)
    if not v then for _,p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("RZ_HL") then p.Character.RZ_HL:Destroy() end end end
end))
table.insert(UIElements, Components:Toggle("XRay", Config.Visuals, "XRayActive", ToggleXRay))

-- // DİNAMİK DÖNGÜLER
RunService.Heartbeat:Connect(function()
    if Config.Combat.HitboxEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(Config.Combat.HitboxSize, Config.Combat.HitboxSize, Config.Combat.HitboxSize)
                p.Character.HumanoidRootPart.Transparency = 0.7; p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Config.Movement.Speed; hum.JumpPower = Config.Movement.Jump; workspace.Gravity = Config.Movement.Gravity
    end
    if Config.Combat.SpinbotActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, Config.Combat.SpinRPM, 0)
    end
end)

-- ESP Karakter Takibi
local function ApplyESP(p)
    p.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if Config.Visuals.HighlightESP then
            local hl = Instance.new("Highlight", char); hl.Name = "RZ_HL"; hl.FillTransparency = 0.7
        end
    end)
end
Players.PlayerAdded:Connect(ApplyESP); for _,p in pairs(Players:GetPlayers()) do ApplyESP(p) end

-- Menu Aç/Kapat
ToggleBtn.MouseButton1Click:Connect(function()
    Content.Visible = not Content.Visible
    ToggleBtn.Text = Content.Visible and Langs[Config.Language].Close or Langs[Config.Language].Open
    TweenService:Create(MainFrame, TweenInfo.new(0.4), {Size = Content.Visible and UDim2.new(0, 380, 0, 510) or UDim2.new(0, 380, 0, 52)}):Play()
end)

UIS.JumpRequest:Connect(function() if Config.Movement.InfiniteJump then LocalPlayer.Character.Humanoid:ChangeState(3) end end)

print("RZGR1KS DUELS ENTERPRISE V5.0.6 LOADED")
