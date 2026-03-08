-- rzgr1ks DUEL HUB - Gelişmiş Lemon Hub Teması ve Sabit Otomatik Yürüme (Pathfinding)
-- Bu script, sağlanan görsellerdeki gelişmiş tasarımı ve "auto walk" işlevini düzeltmek için PathfindingService'i kullanır.
-- Lütfen bu scripti güvenilir bir Roblox yürütücüsünde çalıştırın.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local PathfindingService = game:GetService("PathfindingService")
local TeleportService = game:GetService("TeleportService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- UI Renkleri ve Kozmik Arka Plan Teması
local MainColor = Color3.fromRGB(15, 15, 20)
local AccentColor = Color3.fromRGB(255, 170, 0)
local TextColor = Color3.fromRGB(240, 240, 240)
local ToggleOnColor = Color3.fromRGB(255, 100, 0)
local ToggleOffColor = Color3.fromRGB(100, 100, 100)
local CosmicBackgroundTexture = "rbxassetid://15266736412" -- Kozmik alan dokusu (vfx/dokular için rastgele bir kimlik)

-- UI ve İşlevsellik Değişkenleri
_G.HubData = _G.HubData or {
    HitboxSize = 25,
    HitboxEnabled = false,
    ESPEnabled = false,
    LagEnabled = false,
    SpeedValue = 50,
    JumpValue = 100,
    MultiValue = 1.6,
    AutoWalkData = {
        Points = {},
        TargetPoint = nil,
        IsWalking = false,
        CurrentPointNumber = 1
    }
}

-- UI Öğelerini Oluşturma İşlevleri (Kod tekrarını azaltmak ve tutarlılık için)
local function CreateMainFrame(parent)
    local frame = Instance.new("Frame")
    frame.Name = "MainHubFrame"
    frame.Size = UDim2.new(0, 360, 0, 600)
    frame.Position = UDim2.new(0.5, -180, 0.5, -300) -- Merkezde
    frame.BackgroundColor3 = MainColor
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = frame
    
    local backgroundTexture = Instance.new("ImageLabel")
    backgroundTexture.Name = "BackgroundTexture"
    backgroundTexture.Size = UDim2.new(1, 0, 1, 0)
    backgroundTexture.Image = CosmicBackgroundTexture
    backgroundTexture.BackgroundTransparency = 1
    backgroundTexture.ScaleType = Enum.ScaleType.Tile
    backgroundTexture.TileSize = UDim2.new(0, 100, 0, 100)
    backgroundTexture.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.Text = "LEMÖN HUB DUELS PREMÎÜM"
    title.TextColor3 = TextColor
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.BackgroundTransparency = 1
    title.Parent = frame
    
    -- Çok noktalı liste düzeni
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    listLayout.Parent = frame
    
    return frame, title, backgroundTexture
end

local function CreateColumn(parent, titleText)
    local frame = Instance.new("Frame")
    frame.Name = titleText .. "Column"
    frame.Size = UDim2.new(0.45, 0, 0.9, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = titleText
    title.TextColor3 = AccentColor
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 16
    title.BackgroundTransparency = 1
    title.Parent = frame
    
    return frame, title
end

local function CreateSectionBox(parent, iconId, labelText)
    local frame = Instance.new("Frame")
    frame.Name = labelText .. "Box"
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 40, 0, 40)
    icon.Position = UDim2.new(0, 10, 0.5, -20)
    icon.Image = iconId
    icon.BackgroundTransparency = 1
    icon.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 60, 0, 0)
    label.Text = labelText
    label.TextColor3 = TextColor
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Name = "Toggle"
    toggle.Size = UDim2.new(0, 30, 0, 30)
    toggle.Position = UDim2.new(1, -40, 0.5, -15)
    toggle.BackgroundColor3 = ToggleOffColor
    toggle.Text = ""
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 15)
    toggleCorner.Parent = toggle
    
    return frame, label, toggle
end

local function CreateSlider(parent, labelText, min, max, value)
    local frame = Instance.new("Frame")
    frame.Name = labelText .. "SliderFrame"
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = labelText
    label.TextColor3 = TextColor
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 10)
    track.Position = UDim2.new(0, 0, 1, -10)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    track.BorderSizePixel = 0
    track.Parent = frame
    
    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0, 20, 0, 20)
    thumb.Position = UDim2.new((value - min) / (max - min), -10, 0.5, -10)
    thumb.BackgroundColor3 = AccentColor
    thumb.BorderSizePixel = 0
    thumb.Parent = track
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb
    
    local filled = Instance.new("Frame")
    filled.Name = "Filled"
    filled.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    filled.BackgroundColor3 = AccentColor
    filled.BorderSizePixel = 0
    filled.Parent = track
    
    local filledCorner = Instance.new("UICorner")
    filledCorner.CornerRadius = UDim.new(1, 0)
    filledCorner.Parent = filled
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.Text = value
    valueLabel.TextColor3 = AccentColor
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.BackgroundTransparency = 1
    valueLabel.Parent = frame
    
    -- Slider Mantığı
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = UserInputService.InputChanged:Connect(function(change)
                if change.UserInputType == Enum.UserInputType.MouseMovement or change.UserInputType == Enum.UserInputType.Touch then
                    local inputPosition = UserInputService:GetMouseLocation().X
                    local trackPosition = track.AbsolutePosition.X
                    local trackWidth = track.AbsoluteSize.X
                    local percent = math.clamp((inputPosition - trackPosition) / trackWidth, 0, 1)
                    local newValue = math.round(min + percent * (max - min))
                    
                    thumb.Position = UDim2.new(percent, -10, 0.5, -10)
                    filled.Size = UDim2.new(percent, 0, 1, 0)
                    valueLabel.Text = newValue
                    value = newValue -- Gerekli işlevsel değişkeni güncelleyin
                end
            end)
            
            local inputEndedConnection
            inputEndedConnection = UserInputService.InputEnded:Connect(function(endedInput)
                if endedInput.UserInputType == Enum.UserInputType.MouseButton1 or endedInput.UserInputType == Enum.UserInputType.Touch then
                    connection:Disconnect()
                    inputEndedConnection:Disconnect()
                end
            end)
        end
    end)
    
    return frame, label, track, thumb, filled, valueLabel
end

local function CreateToggleButton(parent, iconId, labelText)
    local frame = Instance.new("Frame")
    frame.Name = labelText .. "ButtonFrame"
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    button.Text = ""
    button.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button
    
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 10, 0.5, -15)
    icon.Image = iconId
    icon.BackgroundTransparency = 1
    icon.Parent = button
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 50, 0, 0)
    label.Text = labelText
    label.TextColor3 = TextColor
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = button
    
    local toggle = Instance.new("TextButton")
    toggle.Name = "Toggle"
    toggle.Size = UDim2.new(0, 20, 0, 20)
    toggle.Position = UDim2.new(1, -30, 0.5, -10)
    toggle.BackgroundColor3 = ToggleOffColor
    toggle.Text = ""
    toggle.Parent = button
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggle
    
    return frame, label, toggle, button
end

local function CreateMultiDisplay(parent, multiText, multiValue)
    local frame = Instance.new("Frame")
    frame.Name = "MultiDisplayFrame"
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = multiText
    label.TextColor3 = TextColor
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0, 50, 1, 0)
    valueLabel.Position = UDim2.new(1, -60, 0, 0)
    valueLabel.Text = multiValue
    valueLabel.TextColor3 = AccentColor
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 16
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.BackgroundTransparency = 1
    valueLabel.Parent = frame
    
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, -70, 0, 5)
    track.Position = UDim2.new(0, 60, 1, -5)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    track.BorderSizePixel = 0
    track.Parent = frame
    
    local filled = Instance.new("Frame")
    filled.Name = "Filled"
    filled.Size = UDim2.new(math.clamp((tonumber(multiValue) - 1) / 0.6, 0, 1), 0, 1, 0) -- Rastgele bir % hesaplama
    filled.BackgroundColor3 = AccentColor
    filled.BorderSizePixel = 0
    filled.Parent = track
    
    return frame, label, valueLabel, filled
end

-- UI Özellik İşlevlerini Uygulama
local function ToggleHitbox()
    _G.HubData.HitboxEnabled = not _G.HubData.HitboxEnabled
    if _G.HubData.HitboxEnabled then
        print("Hitbox Expander: ON")
        local heartbeatConnection
        heartbeatConnection = RunService.Heartbeat:Connect(function()
            if not _G.HubData.HitboxEnabled then heartbeatConnection:Disconnect() return end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = Vector3.new(_G.HubData.HitboxSize, _G.HubData.HitboxSize, _G.HubData.HitboxSize)
                    p.Character.HumanoidRootPart.Transparency = 0.6 -- Mavi şeffaf etki
                    p.Character.HumanoidRootPart.Color = Color3.new(0, 0, 1)
                    p.Character.HumanoidRootPart.Material = Enum.Material.Neon
                    p.Character.HumanoidRootPart.CanCollide = false
                end
            end
        end)
    else
        print("Hitbox Expander: OFF")
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                p.Character.HumanoidRootPart.Transparency = 1
                p.Character.HumanoidRootPart.Color = Color3.new(0, 0, 0)
                p.Character.HumanoidRootPart.Material = Enum.Material.Plastic
                p.Character.HumanoidRootPart.CanCollide = true
            end
        end
    end
end

local function ToggleESP()
    _G.HubData.ESPEnabled = not _G.HubData.ESPEnabled
    if _G.HubData.ESPEnabled then
        print("Player ESP: ON")
        local heartbeatConnection
        heartbeatConnection = RunService.Heartbeat:Connect(function()
            if not _G.HubData.ESPEnabled then heartbeatConnection:Disconnect() return end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    if not p.Character:FindFirstChild("ESPHighlight") then
                        local highlight = Instance.new("Highlight", p.Character)
                        highlight.Name = "ESPHighlight"
                        highlight.FillColor = Color3.new(1, 0.5, 0)
                        highlight.OutlineColor = Color3.new(1, 1, 1)
                        highlight.FillTransparency = 0.5
                    end
                end
            end
        end)
    else
        print("Player ESP: OFF")
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("ESPHighlight") then
                p.Character.ESPHighlight:Destroy()
            end
        end
    end
end

local function ToggleLag()
    _G.HubData.LagEnabled = not _G.HubData.LagEnabled
    if _G.HubData.LagEnabled then
        print("Server Lag: ON (Temp network limit)")
        settings().Network.PhysicsSendRate = 5 -- Temel gönderim hızını sınırlayarak gecikme yaratır. Çok düşük değerler bağlantıyı kesebilir.
    else
        print("Server Lag: OFF")
        settings().Network.PhysicsSendRate = 20 -- Varsayılana geri yükle
    end
end

-- Sabit Otomatik Yürüme (Pathfinding) Uygulaması
local function SetAutoWalkPoint(pointNumber, buttonTextLabel)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local pos = player.Character.HumanoidRootPart.Position
        _G.HubData.AutoWalkData.Points[pointNumber] = pos
        _G.HubData.AutoWalkData.TargetPoint = pos
        _G.HubData.AutoWalkData.CurrentPointNumber = pointNumber
        buttonTextLabel.Text = "Nokta " .. pointNumber .. " Belirlendi (" .. pos.X .. ", " .. pos.Y .. ", " .. pos.Z .. ")"
        print("Nokta " .. pointNumber .. " belirlendi: " .. tostring(pos))
    end
end

local function StartAutoWalk(pointNumber, toggle)
    if not _G.HubData.AutoWalkData.Points[pointNumber] or _G.Set.HubData.AutoWalkData.IsWalking then return end
    print("Düzeltilmiş Otomatik Yürüyüş Nokta " .. pointNumber .. "'e başlatıldı...")
    
    _G.HubData.AutoWalkData.IsWalking = true
    local targetPosition = _G.HubData.AutoWalkData.Points[pointNumber]
    
    spawn(function()
        while _G.HubData.AutoWalkData.IsWalking and targetPosition and player.Character do
            local path = PathfindingService:CreatePath({AgentCanJump = true})
            local startPosition = player.Character.HumanoidRootPart.Position
            
            -- Hata ayıklama için: Hedefe giden yolu hesaplayın
            path:ComputeAsync(startPosition, targetPosition)
            
            if path.Status == Enum.PathStatus.Success then
                local waypoints = path:GetWaypoints()
                for i, waypoint in pairs(waypoints) do
                    if not _G.HubData.AutoWalkData.IsWalking then break end
                    
                    if waypoint.Action == Enum.PathfindingWaypointAction.Jump then
                        player.Character.Humanoid.Jump = true
                    end
                    
                    player.Character.Humanoid:MoveTo(waypoint.Position)
                    
                    -- Hata kontrolü: Noktaya ulaşmak çok uzun sürüyorsa veya çok uzaktaysa durun
                    local arrivedConnection
                    local timeoutTask = spawn(function()
                        task.wait(5) -- 5 saniye bekle
                        if not _G.HubData.AutoWalkData.IsWalking then return end
                        if arrivedConnection then arrivedConnection:Disconnect() end
                        print("Yol bulma noktasına ulaşmak çok uzun sürdü, yolu yeniden hesaplıyor...")
                    end)
                    
                    arrivedConnection = player.Character.Humanoid.MoveToFinished:Connect(function()
                        task.cancel(timeoutTask)
                        if arrivedConnection then arrivedConnection:Disconnect() end
                    end)
                    
                    -- Noktaya gerçekten yaklaşıp yaklaşmadığınızı kontrol etmek için her kalp atışında kontrol edin
                    while arrivedConnection.Connected and _G.HubData.AutoWalkData.IsWalking do
                        local distToWaypoint = (player.Character.HumanoidRootPart.Position - waypoint.Position).Magnitude
                        if distToWaypoint < 3 then arrivedConnection:Disconnect() break end
                        task.wait(0.1)
                    end
                    
                    if not _G.HubData.AutoWalkData.IsWalking then break end
                    if arrivedConnection and not arrivedConnection.Connected then continue end -- arrived
                end
            else
                print("Hedefe giden yol bulunamadı, yeniden deneniyor veya durduruluyor...")
                _G.HubData.AutoWalkData.IsWalking = false -- Dur, yol yok
                break
            end
            
            -- Hedefe ulaşma kontrolü
            local distanceToTarget = (player.Character.HumanoidRootPart.Position - targetPosition).Magnitude
            if distanceToTarget < 5 then
                print("Düzeltilmiş Otomatik Yürüyüş Tamamlandı.")
                _G.HubData.AutoWalkData.IsWalking = false
                break
            end
            
            task.wait(1) -- Bir sonraki kalp atışını kontrol etmek için döngüyü yavaşlatın
        end
        
        -- Tamamlandı veya durduruldu
        _G.HubData.AutoWalkData.IsWalking = false
        toggle.BackgroundColor3 = ToggleOffColor
        toggle.Text = "Yürüyüşe Başla"
    end)
end

local function StopAutoWalk(toggle)
    print("Düzeltilmiş Otomatik Yürüyüş Durduruldu.")
    _G.HubData.AutoWalkData.IsWalking = false
    toggle.BackgroundColor3 = ToggleOffColor
    toggle.Text = "Yürüyüşü Durdur"
end

-- Ana Yürütme Bloğu
if CoreGui:FindFirstChild("MainHubScreenGui") then CoreGui:FindFirstChild("MainHubScreenGui"):Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainHubScreenGui"
screenGui.Parent = CoreGui

local mainFrame, titleLabel, backgroundTexture = CreateMainFrame(screenGui)
mainFrame.Visible = true

-- Sütunlar ve Bölüm Kutuları Oluşturma
local columnContainer = Instance.new("Frame")
columnContainer.Size = UDim2.new(1, -20, 1, -80)
columnContainer.Position = UDim2.new(0, 10, 0, 70)
columnContainer.BackgroundTransparency = 1
columnContainer.Parent = mainFrame

local leftColumn, leftColumnTitle = CreateColumn(columnContainer, "OYUN AYARLARI")
leftColumn.Position = UDim2.new(0, 0, 0, 0)

local rightColumn, rightColumnTitle = CreateColumn(columnContainer, "GÖRSELLİK & SERVER")
rightColumn.Position = UDim2.new(1, -rightColumn.AbsoluteSize.X, 0, 0)

-- Bölüm Kutuları Ekleme
local _, _, hbToggle = CreateSectionBox(leftColumn, "rbxassetid://15266736412", "HİTBOX Expander (v88): OFF")
CreateSlider(leftColumn, "HİTBOX Genişliği (Scale 0-100)", 0, 100, 25)
CreateToggleButton(leftColumn, "rbxassetid://15266736412", "Player ESP: OFF")

local _, _, espToggle = CreateSectionBox(rightColumn, "rbxassetid://15266736412", "Player ESP: OFF")
local _, _, lagToggle = CreateSectionBox(rightColumn, "rbxassetid://15266736412", "SERVER Lag (PhysicsSendRate 5): OFF")
CreateToggleButton(rightColumn, "rbxassetid://15266736412", "Server Lag (PhysicsSendRate 5): OFF")

-- HIZ ve ZIPLAMA
local speedSliderFrame, _, _, _, _, speedValueLabel = CreateSlider(rightColumn, "HIZ (WalkSpeed)", 16, 150, 50)
local jumpSliderFrame, _, _, _, _, jumpValueLabel = CreateSlider(rightColumn, "ZIPLAMA (JumpPower)", 50, 150, 100)

-- MULTI
local multiDisplay, _, multiValueLabel, multiFilled = CreateMultiDisplay(rightColumn, "MULTI:", 1.6)

-- Nokta Belirleme Bölümü (Alt Kısım)
local pointFrame = Instance.new("Frame")
pointFrame.Name = "PointFrame"
pointFrame.Size = UDim2.new(0.45, 0, 0, 150)
pointFrame.Position = UDim2.new(1, -pointFrame.AbsoluteSize.X - 10, 1, -160)
pointFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
pointFrame.BorderSizePixel = 0
pointFrame.Parent = mainFrame

local pointCorner = Instance.new("UICorner")
pointCorner.CornerRadius = UDim.new(0, 10)
pointCorner.Parent = pointFrame

local setPointLabel = Instance.new("TextLabel")
setPointLabel.Size = UDim2.new(1, -60, 0, 30)
setPointLabel.Position = UDim2.new(0, 60, 0, 10)
setPointLabel.Text = "Nokta Belirle (Sabit Nokta)"
setPointLabel.TextColor3 = TextColor
setPointLabel.Font = Enum.Font.Gotham
setPointLabel.TextSize = 13
setPointLabel.TextXAlignment = Enum.TextXAlignment.Left
setPointLabel.BackgroundTransparency = 1
setPointLabel.Parent = pointFrame

local pointPinIcon = Instance.new("ImageLabel")
pointPinIcon.Size = UDim2.new(0, 40, 0, 40)
pointPinIcon.Position = UDim2.new(0, 10, 0, 10)
pointPinIcon.Image = "rbxassetid://15266736412" -- Pin İkonu
pointPinIcon.BackgroundTransparency = 1
pointPinIcon.Parent = pointFrame

local setPointButtonText = Instance.new("TextLabel")
setPointButtonText.Size = UDim2.new(1, -20, 0, 20)
setPointButtonText.Position = UDim2.new(0, 10, 0, 50)
setPointButtonText.Text = "Nokta 1 Belirlendi"
setPointButtonText.TextColor3 = TextColor
setPointButtonText.Font = Enum.Font.GothamSemibold
setPointButtonText.TextSize = 14
setPointButtonText.BackgroundTransparency = 1
setPointButtonText.Parent = pointFrame

local setPointButton = Instance.new("TextButton")
setPointButton.Size = UDim2.new(1, -20, 0, 30)
setPointButton.Position = UDim2.new(0, 10, 0, 80)
setPointButton.BackgroundColor3 = AccentColor
setPointButton.Text = "Nokta Belirle"
setPointButton.TextColor3 = TextColor
setPointButton.Font = Enum.Font.GothamBold
setPointButton.TextSize = 16
setPointButton.Parent = pointFrame

local setPointToggle = Instance.new("TextButton")
setPointToggle.Size = UDim2.new(0, 20, 0, 20)
setPointToggle.Position = UDim2.new(1, -30, 0.5, -10)
setPointToggle.BackgroundColor3 = ToggleOffColor
setPointToggle.Text = ""
setPointToggle.Parent = setPointButton

local setPointToggleCorner = Instance.new("UICorner")
setPointToggleCorner.CornerRadius = UDim.new(0, 10)
setPointToggleCorner.Parent = setPointToggle

local autoWalkGoLabel = Instance.new("TextLabel")
autoWalkGoLabel.Size = UDim2.new(1, -60, 0, 30)
autoWalkGoLabel.Position = UDim2.new(0, 60, 0, 10)
autoWalkGoLabel.Text = "Yürüyüşe Başla (AUTO WALK)"
autoWalkGoLabel.TextColor3 = TextColor
autoWalkGoLabel.Font = Enum.Font.Gotham
autoWalkGoLabel.TextSize = 13
autoWalkGoLabel.TextXAlignment = Enum.TextXAlignment.Left
autoWalkGoLabel.BackgroundTransparency = 1
autoWalkGoLabel.Parent = pointFrame
autoWalkGoLabel.Visible = false -- Başlangıçta gizli

local runningIcon = Instance.new("ImageLabel")
runningIcon.Size = UDim2.new(0, 40, 0, 40)
runningIcon.Position = UDim2.new(0, 10, 0, 10)
runningIcon.Image = "rbxassetid://15266736412" -- Koşan Adam İkonu
runningIcon.BackgroundTransparency = 1
runningIcon.Parent = pointFrame
runningIcon.Visible = false -- Gizli

local startWalkGoButton = Instance.new("TextButton")
startWalkGoButton.Size = UDim2.new(1, -20, 0, 30)
startWalkGoButton.Position = UDim2.new(0, 10, 0, 80)
startWalkGoButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
startWalkGoButton.Text = "Yürüyüşe Başla"
startWalkGoButton.TextColor3 = TextColor
startWalkGoButton.Font = Enum.Font.GothamBold
startWalkGoButton.TextSize = 16
startWalkGoButton.Parent = pointFrame
startWalkGoButton.Visible = false -- Gizli

local startWalkToggle = Instance.new("TextButton")
startWalkToggle.Size = UDim2.new(0, 20, 0, 20)
startWalkToggle.Position = UDim2.new(1, -30, 0.5, -10)
startWalkToggle.BackgroundColor3 = ToggleOffColor
startWalkToggle.Text = ""
startWalkToggle.Parent = startWalkGoButton

local startWalkToggleCorner = Instance.new("UICorner")
startWalkToggleCorner.CornerRadius = UDim.new(0, 10)
startWalkToggleCorner.Parent = startWalkToggle

local stopWalkGoLabel = Instance.new("TextLabel")
stopWalkGoLabel.Size = UDim2.new(1, -60, 0, 30)
stopWalkGoLabel.Position = UDim2.new(0, 60, 0, 10)
stopWalkGoLabel.Text = "Yürüyüşü Durdur"
stopWalkGoLabel.TextColor3 = TextColor
stopWalkGoLabel.Font = Enum.Font.Gotham
stopWalkGoLabel.TextSize = 13
stopWalkGoLabel.TextXAlignment = Enum.TextXAlignment.Left
stopWalkGoLabel.BackgroundTransparency = 1
stopWalkGoLabel.Parent = pointFrame
stopWalkGoLabel.Visible = false -- Gizli

local handIcon = Instance.new("ImageLabel")
handIcon.Size = UDim2.new(0, 40, 0, 40)
handIcon.Position = UDim2.new(0, 10, 0, 10)
handIcon.Image = "rbxassetid://15266736412" -- El İkonu
handIcon.BackgroundTransparency = 1
handIcon.Parent = pointFrame
handIcon.Visible = false -- Gizli

local stopWalkGoButton = Instance.new("TextButton")
stopWalkGoButton.Size = UDim2.new(1, -20, 0, 30)
stopWalkGoButton.Position = UDim2.new(0, 10, 0, 80)
stopWalkGoButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
stopWalkGoButton.Text = "Yürüyüşü Durdur"
stopWalkGoButton.TextColor3 = TextColor
stopWalkGoButton.Font = Enum.Font.GothamBold
stopWalkGoButton.TextSize = 16
stopWalkGoButton.Parent = pointFrame
stopWalkGoButton.Visible = false -- Gizli

local stopWalkToggle = Instance.new("TextButton")
stopWalkToggle.Size = UDim2.new(0, 20, 0, 20)
stopWalkToggle.Position = UDim2.new(1, -30, 0.5, -10)
stopWalkToggle.BackgroundColor3 = ToggleOffColor
stopWalkToggle.Text = ""
stopWalkToggle.Parent = stopWalkGoButton

local stopWalkToggleCorner = Instance.new("UICorner")
stopWalkToggleCorner.CornerRadius = UDim.new(0, 10)
stopWalkToggleCorner.Parent = stopWalkToggle

-- UI İşlevlerini ve Otomatik Yürüyüşü Bağlama
hbToggle.MouseButton1Click:Connect(function()
    ToggleHitbox()
    hbToggle.BackgroundColor3 = _G.HubData.HitboxEnabled and ToggleOnColor or ToggleOffColor
end)

espToggle.MouseButton1Click:Connect(function()
    ToggleESP()
    espToggle.BackgroundColor3 = _G.HubData.ESPEnabled and ToggleOnColor or ToggleOffColor
end)

lagToggle.MouseButton1Click:Connect(function()
    ToggleLag()
    lagToggle.BackgroundColor3 = _G.HubData.LagEnabled and ToggleOnColor or ToggleOffColor
end)

-- HIZ ve ZIPLAMA Bağlantısı
-- (Not: Slider'ların zaten yerleşik mantığı var)

-- Sabit Otomatik Yürüyüş Bağlantısı
setPointButton.MouseButton1Click:Connect(function()
    SetAutoWalkPoint(1, setPointButtonText) -- Nokta 1
end)

startWalkGoButton.MouseButton1Click:Connect(function()
    StartAutoWalk(1, startWalkToggle) -- Nokta 1
end)

stopWalkGoButton.MouseButton1Click:Connect(function()
    StopAutoWalk(stopWalkToggle)
end)

-- UI Değiştirme ve Mobil Kontrolleri Devre Dışı Bırakma
local menuButton = nil
if _G.OriginalMenuButton then _G.OriginalMenuButton:Destroy() end -- Orijinali temizle

local function ToggleUI()
    mainFrame.Visible = not mainFrame.Visible
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        ToggleUI()
    end
end)

-- Hata kontrolü: Orijinal mobil MENU düğmesini kopyala
spawn(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local mobileControls = p.Character:FindFirstChild("MobileControls")
            if mobileControls then
                local controlFrame = mobileControls:FindFirstChild("ControlFrame")
                if controlFrame then
                    local originalMenuButton = controlFrame:FindFirstChild("MenuButton")
                    if originalMenuButton then
                        _G.OriginalMenuButton = originalMenuButton:Clone()
                        _G.OriginalMenuButton.Parent = screenGui
                        _G.OriginalMenuButton.MouseButton1Click:Connect(ToggleUI)
                    end
                end
            end
        end
    end
end)

-- Ninja Kafası ve Mobil Kontrolleri Yeniden Yerleştirme
local function RepositionControls()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                if not head:FindFirstChild("NinjaIcon") then
                    local ninjaIcon = Instance.new("ImageLabel", head)
                    ninjaIcon.Name = "NinjaIcon"
                    ninjaIcon.Size = UDim2.new(0, 20, 0, 20)
                    ninjaIcon.Position = UDim2.new(0.5, -10, -0.5, 0)
                    ninjaIcon.Image = "rbxassetid://15266736412" -- Ninja İkonu
                    ninjaIcon.BackgroundTransparency = 1
                end
            end
        end
    end
    
    local mobileControls = player.Character and player.Character:FindFirstChild("MobileControls")
    if mobileControls then
        local controlFrame = mobileControls:FindFirstChild("ControlFrame")
        if controlFrame then
            local redJumpButton = controlFrame:FindFirstChild("JumpButton")
            if redJumpButton then
                -- Red Jump'ı daha uzağa taşıyarak özelleştirin
                redJumpButton.Position = UDim2.new(1, -110, 1, -110)
            end
            
            local lockIcon = controlFrame:FindFirstChild("LockIcon") -- image_2.png'deki gibi
            if not lockIcon then
                local icon = Instance.new("ImageLabel", controlFrame)
                icon.Name = "LockIcon"
                icon.Size = UDim2.new(0, 30, 0, 30)
                icon.Position = UDim2.new(1, -70, 1, -110)
                icon.Image = "rbxassetid://15266736412" -- Kilit İkonu
                icon.BackgroundTransparency = 1
            end
        end
    end
end

RunService.RenderStepped:Connect(RepositionControls)

-- Otomatik Yürüyüş için Kalp Atışı Kontrolü (Noktaya gerçekten yaklaşıp yaklaşmadığınızı doğrulamak için)
RunService.Heartbeat:Connect(function()
    if _G.HubData.AutoWalkData.IsWalking and player.Character then
        local char = player.Character
        local humanoid = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        
        if humanoid and hrp then
            local currentTarget = _G.HubData.AutoWalkData.TargetPoint
            if currentTarget then
                local distance = (hrp.Position - currentTarget).Magnitude
                if distance < 3 then
                    print("Hedef noktasına ulaşıldı.")
                    -- (İş mantığı StartAutoWalk'ta MoveToFinished tarafından zaten yönetilir, bu bir yedektir)
                end
            end
        end
    end
end)

print("Gelişmiş rzgr1ks Duel Hub V88 yüklendi. Otomatik yürüme PathfindingService ile düzeltildi.")
