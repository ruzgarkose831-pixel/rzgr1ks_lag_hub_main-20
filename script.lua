--[[
    ====================================================================================================
    @project: RZGR1KS DUELS - ENTERPRISE PRIVATE EXECUTIVE
    @version: 5.0.5 (JSON Configuration System Update)
    @status: High-Performance Execution
    
    [SYSTEM NOTES]
    - PERSISTENCE: All settings are now stored in "RZGR1KS_CONFIG.json".
    - AUTO-LOAD: Script restores your last used settings upon execution.
    - REFRESH RATE: 60Hz polling for Hitbox and ESP dynamics.
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
local ConfigFileName = "RZGR1KS_CONFIG.json"

-- // VARSAYILAN AYARLAR
local Config = {
    Combat = { HitboxEnabled = false, HitboxSize = 25, HitboxTransparency = 0.7, SpinbotActive = false, SpinRPM = 50 },
    Movement = { Speed = 16, Jump = 50, Gravity = 196.2, InfiniteJump = false, AntiRagdoll = false },
    Visuals = { HighlightESP = false, ESP_Color = {220, 40, 40}, XRayActive = false },
    Misc = { AutoInteract = false, AntiAFK = true }
}

-- // 💾 CONFIG FONKSIYONLARI
local function SaveConfig()
    local success, err = pcall(function()
        if writefile then
            writefile(ConfigFileName, HttpService:JSONEncode(Config))
        end
    end)
    return success
end

local function LoadConfig()
    local success, err = pcall(function()
        if isfile and isfile(ConfigFileName) then
            local data = HttpService:JSONDecode(readfile(ConfigFileName))
            for cat, sub in pairs(data) do
                for k, v in pairs(sub) do
                    Config[cat][k] = v
                end
            end
        end
    end)
    return success
end

local function ResetConfig()
    if isfile and isfile(ConfigFileName) then
        delfile(ConfigFileName)
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "RZGR1KS", Text = "Ayarlar sıfırlandı! Scripti yeniden açın."})
    end
end

-- İlk çalıştırmada ayarları yükle
LoadConfig()

-- // GUI BASLANGIC
local TargetParent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
if TargetParent:FindFirstChild("RZGR1KS_V5") then TargetParent:FindFirstChild("RZGR1KS_V5"):Destroy() end

local ScreenUI = Instance.new("ScreenGui", TargetParent)
ScreenUI.Name = "RZGR1KS_V5"; ScreenUI.ResetOnSpawn = false; ScreenUI.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame", ScreenUI)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12); MainFrame.Size = UDim2.new(0, 380, 0, 52); MainFrame.Position = UDim2.new(0.5, -190, 0.2, 0); MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 52); Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Text = "RZGR1KS DUELS : V5.0.5"; Title.Font = "GothamBold"; Title.TextColor3 = Color3.fromRGB(220, 40, 40); Title.TextSize = 14; Title.Size = UDim2.new(1, -120, 1, 0); Title.Position = UDim2.new(0, 20, 0, 0); Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

local ToggleBtn = Instance.new("TextButton", Header)
ToggleBtn.Text = "OPEN"; ToggleBtn.Size = UDim2.new(0, 80, 0, 32); ToggleBtn.Position = UDim2.new(1, -95, 0, 10); ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); ToggleBtn.TextColor3 = Color3.new(1, 1, 1); ToggleBtn.Font = "GothamBold"; ToggleBtn.TextSize = 11
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Position = UDim2.new(0, 10, 0, 65); Content.Size = UDim2.new(1, -20, 0, 435); Content.BackgroundTransparency = 1; Content.ScrollBarThickness = 1; Content.Visible = false; Content.AutomaticCanvasSize = "Y"
Instance.new("UIListLayout", Content).Padding = UDim.new(0, 8)

-- // MODÜL MOTORLARI (ESP & HITBOX)
local function ApplyESP(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if Config.Visuals.HighlightESP then
            local hl = Instance.new("Highlight", char)
            hl.Name = "RZ_HL"; hl.FillColor = Color3.fromRGB(unpack(Config.Visuals.ESP_Color)); hl.FillTransparency = 0.7
        end
    end)
end
Players.PlayerAdded:Connect(ApplyESP)
for _, p in pairs(Players:GetPlayers()) do ApplyESP(p) end

RunService.Heartbeat:Connect(function()
    -- Hitbox Logic
    if Config.Combat.HitboxEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(Config.Combat.HitboxSize, Config.Combat.HitboxSize, Config.Combat.HitboxSize)
                p.Character.HumanoidRootPart.Transparency = Config.Combat.HitboxTransparency
                p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
    -- Movement Logic
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Config.Movement.Speed
        hum.JumpPower = Config.Movement.Jump
        workspace.Gravity = Config.Movement.Gravity
    end
end)

-- // UI FABRIKASI
local Components = {}

function Components:Section(txt)
    local l = Instance.new("TextLabel", Content)
    l.Size = UDim2.new(1, 0, 0, 25); l.BackgroundTransparency = 1; l.Font = "GothamBold"; l.Text = ">>> " .. txt:upper() .. " <<<"; l.TextColor3 = Color3.fromRGB(220, 40, 40); l.TextSize = 10
end

function Components:Toggle(name, dataset, key, callback)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(1, -10, 0, 40); b.BackgroundColor3 = dataset[key] and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(20, 20, 20)
    b.Text = name .. " : " .. (dataset[key] and "AKTİF" or "PASİF"); b.Font = "GothamBold"; b.TextColor3 = Color3.new(1, 1, 1); b.TextSize = 11; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        dataset[key] = not dataset[key]
        b.Text = name .. " : " .. (dataset[key] and "AKTİF" or "PASİF")
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = dataset[key] and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(20, 20, 20)}):Play()
        if callback then callback(dataset[key]) end
        SaveConfig() -- Her değişimde kaydet
    end)
end

function Components:Slider(name, min, max, dataset, key)
    local f = Instance.new("Frame", Content); f.Size = UDim2.new(1, -10, 0, 60); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.BackgroundTransparency = 1; l.Text = name .. " : " .. dataset[key]; l.Font = "Gotham"; l.TextColor3 = Color3.new(0.8, 0.8, 0.8); l.TextSize = 11; l.TextXAlignment = "Left"
    local t = Instance.new("TextButton", f); t.Size = UDim2.new(1, 0, 0, 10); t.Position = UDim2.new(0, 0, 0, 25); t.BackgroundColor3 = Color3.fromRGB(30, 30, 30); t.Text = ""
    local fill = Instance.new("Frame", t); fill.Size = UDim2.new(math.clamp((dataset[key]-min)/(max-min), 0, 1), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
    Instance.new("UICorner", t); Instance.new("UICorner", fill)
    
    local isSliding = false
    local function Update()
        local scale = math.clamp((UIS:GetMouseLocation().X - t.AbsolutePosition.X) / t.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (scale * (max - min)))
        dataset[key] = val; l.Text = name .. " : " .. val; fill.Size = UDim2.new(scale, 0, 1, 0)
    end
    t.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isSliding = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then if isSliding then isSliding = false; SaveConfig() end end end)
    RunService.RenderStepped:Connect(function() if isSliding then Update() end end)
end

function Components:Button(name, callback)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(1, -10, 0, 35); b.BackgroundColor3 = Color3.fromRGB(35, 35, 35); b.Text = name; b.Font = "GothamBold"; b.TextColor3 = Color3.new(1, 1, 1); b.TextSize = 11; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
end

-- // INTERFACE KURULUMU
Components:Section("Konfigürasyon Yönetimi")
Components:Button("Ayarları Şimdi Kaydet", function() 
    if SaveConfig() then 
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "RZGR1KS", Text = "Ayarlar başarıyla kaydedildi!"}) 
    end 
end)
Components:Button("Varsayılan Ayarlara Dön", ResetConfig)

Components:Section("Savaş Ayarları")
Components:Toggle("Hitbox Expander", Config.Combat, "HitboxEnabled")
Components:Slider("Hitbox Boyutu", 2, 250, Config.Combat, "HitboxSize")

Components:Section("Hareket Ayarları")
Components:Slider("Yürüme Hızı", 16, 500, Config.Movement, "Speed")
Components:Slider("Zıplama Gücü", 50, 1000, Config.Movement, "Jump")
Components:Slider("Yerçekimi", 0, 1000, Config.Movement, "Gravity")
Components:Toggle("Sınırsız Zıplama", Config.Movement, "InfiniteJump")

Components:Section("Görsel Ayarlar")
Components:Toggle("Oyuncu ESP (Highlight)", Config.Visuals, "HighlightESP", function(v)
    if not v then
        for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("RZ_HL") then p.Character.RZ_HL:Destroy() end end
    end
end)

Components:Section("Destek")
Components:Button("Discord Sunucumuz (Kopyala)", function() setclipboard("https://discord.gg/XpbcvVdU") end)

-- // MENU AC/KAPAT
local State = false
ToggleBtn.MouseButton1Click:Connect(function()
    State = not State
    Content.Visible = State
    ToggleBtn.Text = State and "CLOSE" or "OPEN"
    TweenService:Create(MainFrame, TweenInfo.new(0.4), {Size = State and UDim2.new(0, 380, 0, 510) or UDim2.new(0, 380, 0, 52)}):Play()
end)

-- Sınırsız Zıplama Event
UIS.JumpRequest:Connect(function() if Config.Movement.InfiniteJump then LocalPlayer.Character.Humanoid:ChangeState(3) end end)

print("RZGR1KS DUELS V5.0.5 LOADED WITH CONFIG SYSTEM")
