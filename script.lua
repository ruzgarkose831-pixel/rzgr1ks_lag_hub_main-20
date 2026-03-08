-- rzgr1ks Hub V27 - Delta/Mobile Fix
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. HER ŞEYİ SİL VE TEMİZLE
local function cleanup()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "LemonFix" then v:Destroy() end
    end
    for _, v in pairs(player.PlayerGui:GetChildren()) do
        if v.Name == "LemonFix" then v:Destroy() end
    end
end
cleanup()

-- 2. GUI OLUŞTUR (En Basit ve Sağlam Yapı)
local sg = Instance.new("ScreenGui")
sg.Name = "LemonFix"
sg.DisplayOrder = 999999
sg.IgnoreGuiInset = true -- Ekranın en tepesine kadar çıkar
sg.Parent = game:GetService("CoreGui") or player.PlayerGui

-- ANA PANEL (Ekranın Tam Ortasında)
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 250, 0, 350)
Main.Position = UDim2.new(0.5, -125, 0.5, -175)
Main.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Main.BorderSizePixel = 3
Main.BorderColor3 = Color3.new(1, 0.8, 0) -- Sarı Kenarlık
Main.ZIndex = 10

-- BAŞLIK
local Ttl = Instance.new("TextLabel", Main)
Ttl.Size = UDim2.new(1, 0, 0, 40)
Ttl.Text = "rzgr1ks V27 - FIXED"
Ttl.TextColor3 = Color3.new(1, 1, 1)
Ttl.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
Ttl.ZIndex = 11

-- KAPATMA (X)
local Cls = Instance.new("TextButton", Main)
Cls.Size = UDim2.new(0, 30, 0, 30)
Cls.Position = UDim2.new(1, -30, 0, 0)
Cls.Text = "X"
Cls.BackgroundColor3 = Color3.new(0.8, 0, 0)
Cls.TextColor3 = Color3.new(1, 1, 1)
Cls.ZIndex = 12

-- BUTON LİSTESİ
local List = Instance.new("UIListLayout", Main)
List.Padding = UDim.new(0, 5)
List.HorizontalAlignment = "Center"
List.VerticalAlignment = "Center"

-- STATES
_G.Aimbot = false
_G.Hitbox = false
_G.Speed = false
_G.ServerLag = false

-- BUTON FONKSİYONU (En Basit Hal)
local function add(txt, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0, 220, 0, 45)
    b.Text = txt .. ": OFF"
    b.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.ZIndex = 15
    
    local act = false
    b.MouseButton1Click:Connect(function()
        act = not act
        b.Text = act and (txt .. ": ON") or (txt .. ": OFF")
        b.BackgroundColor3 = act and Color3.new(1, 0.7, 0) or Color3.new(0.3, 0.3, 0.3)
        callback(act)
    end)
end

-- ÖZELLİKLER
add("Aimbot", function(v) _G.Aimbot = v end)
add("Hitbox Expander", function(v) _G.Hitbox = v end)
add("Speed Hack", function(v) _G.Speed = v end)
add("Server Lag", function(v) _G.ServerLag = v end)

-- MOTOR
RunService.RenderStepped:Connect(function()
    if _G.Speed and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 75
    end
    
    if _G.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(20, 20, 20)
                p.Character.HumanoidRootPart.Transparency = 0.7
                p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end

    if _G.ServerLag and player.Character then
        local t = player.Character:FindFirstChildOfClass("Tool")
        if t then for i=1,10 do t:Activate() end end
    end
    
    if _G.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        -- Aimbot Logic (Sadeleştirilmiş)
        local cam = workspace.CurrentCamera
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local _, vis = cam:WorldToViewportPoint(p.Character.Head.Position)
                if vis then
                    cam.CFrame = CFrame.new(cam.CFrame.Position, p.Character.Head.Position)
                    break
                end
            end
        end
    end
end)

Cls.MouseButton1Click:Connect(function() sg:Destroy() end)
