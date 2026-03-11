local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- [[ GENEL YAPILANDIRMA ]] --
_G.Settings = {
    AutoFarm = false,        -- Tam otomatiği açar/kapatır
    DeliveryPos = Vector3.new(-164, 45, 120), -- Videodaki teslimat noktası
    TPSpeed = 12,            -- Akış hızı (Halı varken artırıldı)
    CarpetName = "Carpet",   -- Halının tam adı
    ItemPath = workspace:FindFirstChild("Items") -- Eşyaların olduğu klasör (Oyuna göre değişebilir)
}

-- [[ SEMI-TP MOTORU (Gidiş & Dönüş) ]] --
local function StealthMove(target)
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not char:FindFirstChild(_G.Settings.CarpetName) then return end

    local distance = (target - hrp.Position).Magnitude
    local direction = (target - hrp.Position).Unit
    
    for i = 0, distance, _G.Settings.TPSpeed do
        if not _G.Settings.AutoFarm then break end
        hrp.CFrame = CFrame.new(hrp.Position + (direction * math.min(_G.Settings.TPSpeed, (target - hrp.Position).Magnitude)))
        task.wait(0.01)
    end
    hrp.CFrame = CFrame.new(target)
end

-- [[ EN YAKIN EŞYAYI BUL ]] --
local function GetClosestItem()
    local closest = nil
    local dist = math.huge
    -- Oyunun eşya klasörünü tarar (Workspace içindeki 'Items' veya 'Drops' klasörü)
    local items = workspace:FindFirstChild("Items") or workspace:FindFirstChild("Brainrots") or workspace
    
    for _, v in pairs(items:GetDescendants()) do
        if v:IsA("TouchTransmitter") and v.Parent:IsA("Part") then -- Eşya alınabilir bir parçaysa
            local d = (Player.Character.HumanoidRootPart.Position - v.Parent.Position).Magnitude
            if d < dist then
                dist = d
                closest = v.Parent
            end
        end
    end
    return closest
end

-- [[ ANA OTOMATİK DÖNGÜ ]] --
task.spawn(function()
    while task.wait(0.5) do
        if _G.Settings.AutoFarm then
            local char = Player.Character
            local carpet = char:FindFirstChild(_G.Settings.CarpetName) or Player.Backpack:FindFirstChild(_G.Settings.CarpetName)
            
            if carpet then
                -- 1. Halıyı Eline Al
                if carpet.Parent ~= char then carpet.Parent = char end
                
                -- 2. En Yakın Eşyayı Bul ve Git
                local item = GetClosestItem()
                if item then
                    print("Hedef Belirlendi: " .. item.Name)
                    StealthMove(item.Position)
                    task.wait(0.2) -- Eşyayı alması için minik bekleme
                    
                    -- 3. Teslimat Noktasına Dön
                    print("Teslimata Gidiliyor...")
                    StealthMove(_G.Settings.DeliveryPos)
                end
            else
                warn("Hata: Envanterde Uçan Halı Bulunamadı!")
                _G.Settings.AutoFarm = false
            end
        end
    end
end)

-- [[ AUTO-STEAL GUI ]] --
if Player.PlayerGui:FindFirstChild("AutoSigmaV60") then Player.PlayerGui.AutoSigmaV60:Destroy() end
local gui = Instance.new("ScreenGui", Player.PlayerGui); gui.Name = "AutoSigmaV60"; gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 240, 0, 160); main.Position = UDim2.new(0.05, 0, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); main.Active = true; main.Draggable = true
Instance.new("UIStroke", main).Color = Color3.fromRGB(0, 255, 0)

local btn = Instance.new("TextButton", main)
btn.Size = UDim2.new(0.9, 0, 0, 50); btn.Position = UDim2.new(0.05, 0, 0.1, 0)
btn.Text = "AUTO STEAL & TP: KAPALI"; btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); btn.TextColor3 = Color3.new(1,1,1)
btn.MouseButton1Click:Connect(function()
    _G.Settings.AutoFarm = not _G.Settings.AutoFarm
    btn.Text = "AUTO STEAL: " .. (_G.Settings.AutoFarm and "AÇIK" or "KAPALI")
    btn.BackgroundColor3 = _G.Settings.AutoFarm and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(30, 30, 30)
end)

local setDel = Instance.new("TextButton", main)
setDel.Size = UDim2.new(0.9, 0, 0, 50); setDel.Position = UDim2.new(0.05, 0, 0.55, 0)
setDel.Text = "TESLİMAT NOKTASINI AYARLA"; setDel.BackgroundColor3 = Color3.fromRGB(40, 40, 40); setDel.TextColor3 = Color3.new(1,1,1)
setDel.MouseButton1Click:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        _G.Settings.DeliveryPos = Player.Character.HumanoidRootPart.Position
        setDel.Text = "NOKTA KAYDEDİLDİ!"; task.wait(1); setDel.Text = "TESLİMAT NOKTASINI AYARLA"
    end
end)

print("V60 ULTIMATE AUTO-FARM LOADED. WHAT THE SIGMA!")
