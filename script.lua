local plr = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local ts = game:GetService("TweenService")
local cg = game:GetService("CoreGui")
local rep = game:GetService("ReplicatedStorage")

local par = (gethui and gethui()) or cg
local guiName = "LemonHub_Final"

-- ESKİSİNİ TEMİZLE
if par:FindFirstChild(guiName) then par[guiName]:Destroy() end

-- DEĞİŞKENLER VE AYARLAR
local speedOn = false
local spinbot = false
local antirag = false
local autograb = false
local infjump = false
local speedVal = 55

local conns = {}

-- RENKLER
local pm = Color3.fromRGB(15, 15, 15)
local pl = Color3.fromRGB(30, 30, 30)
local pa = Color3.fromRGB(50, 50, 50)
local wh = Color3.fromRGB(255, 255, 255)
local accent = Color3.fromRGB(255, 230, 0)

-----------------------------------
-- FONKSİYONLAR
-----------------------------------

-- Spinbot
local function toggleSpin(b)
    spinbot = b
    local function apply(c)
        local hrp = c:WaitForChild("HumanoidRootPart", 5)
        if not hrp then return end
        if b then
            local bv = Instance.new("BodyAngularVelocity")
            bv.Name = "LemonSpin"
            bv.MaxTorque = Vector3.new(0, math.huge, 0)
            bv.AngularVelocity = Vector3.new(0, 40, 0)
            bv.Parent = hrp
        else
            if hrp:FindFirstChild("LemonSpin") then hrp.LemonSpin:Destroy() end
        end
    end
    if plr.Character then apply(plr.Character) end
end

-- Anti-Ragdoll
rs.Heartbeat:Connect(function()
    if antirag and plr.Character then
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end
end)

-- Speed
rs.RenderStepped:Connect(function()
    if speedOn and plr.Character then
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            plr.Character:TranslateBy(hum.MoveDirection * (speedVal / 100))
        end
    end
end)

-- Infinite Jump
uis.JumpRequest:Connect(function()
    if infjump and plr.Character then
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-----------------------------------
-- ARAYÜZ (GUI) OLUŞTURMA
-----------------------------------
local ScreenGui = Instance.new("ScreenGui", par)
ScreenGui.Name = guiName

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 380)
Main.Position = UDim2.new(0.5, -130, 0.5, -190)
Main.BackgroundColor3 = pm
Main.Active = true
Main.Draggable = true

local UICorner = Instance.new("UICorner", Main)
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "🍋 LEMON HUB V3"
Title.TextColor3 = accent
Title.BackgroundColor3 = pl
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 1.2, 0)
Container.ScrollBarThickness = 2

local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 8)

-- BUTON YAPICI
local function createToggle(name, default, callback)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, -5, 0, 35)
    btn.BackgroundColor3 = pa
    btn.Text = name .. (default and ": ON" or ": OFF")
    btn.TextColor3 = wh
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. (state and ": ON" or ": OFF")
        btn.BackgroundColor3 = state and accent or pa
        btn.TextColor3 = state and pm or wh
        callback(state)
    end)
end

-- ÖZELLİKLERİ EKLE
createToggle("Speed (55)", false, function(v) speedOn = v end)
createToggle("Spinbot", false, function(v) toggleSpin(v) end)
createToggle("Anti-Ragdoll", false, function(v) antirag = v end)
createToggle("Infinite Jump", false, function(v) infjump = v end)
createToggle("Auto-Grab Animals", false, function(v) autograb = v end)

-- Kapatma Butonu
local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 20, 0, 20)
Close.Position = UDim2.new(1, -25, 0, 10)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Close.TextColor3 = wh
Instance.new("UICorner", Close)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

print("Lemon Hub başarıyla yüklendi!")
