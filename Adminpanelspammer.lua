local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local SelectedPlayer = nil
local Cooldowns = {}
local Buttons = {}

-- Tween Ayarları
local function playTween(obj, prop, goal, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Sine), goal):Play()
end

-- Ana Ekran
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "rzgr1ks_Neon_Admin"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Ana Panel (Neon Mavi Çerçeveli)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 230, 0, 400)
MainFrame.Position = UDim2.new(0.5, -115, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 170, 255) -- NEON MAVİ KENAR
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Başlık (Neon Gölge Efektli)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "rzgr1ks admin panel"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Kapatma (X)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -30, 0, 2)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "×"
MinBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
MinBtn.TextSize = 24
MinBtn.Parent = MainFrame

-- Küçültülmüş Mod (Genişlik 230)
local MinimizedFrame = Instance.new("Frame")
MinimizedFrame.Size = UDim2.new(0, 230, 0, 35)
MinimizedFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MinimizedFrame.BorderSizePixel = 2
MinimizedFrame.BorderColor3 = Color3.fromRGB(0, 170, 255)
MinimizedFrame.Visible = false
MinimizedFrame.Draggable = true
MinimizedFrame.Parent = ScreenGui
Instance.new("UICorner", MinimizedFrame)

local MinLabel = Instance.new("TextLabel")
MinLabel.Size = UDim2.new(1, -40, 1, 0)
MinLabel.Position = UDim2.new(0, 10, 0, 0)
MinLabel.BackgroundTransparency = 1
MinLabel.Text = "rzgr1ks admin panel"
MinLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
MinLabel.Font = Enum.Font.GothamBold
MinLabel.TextSize = 11
MinLabel.TextXAlignment = Enum.TextXAlignment.Left
MinLabel.Parent = MinimizedFrame

local MaxBtn = Instance.new("TextButton")
MaxBtn.Size = UDim2.new(0, 30, 0, 30)
MaxBtn.Position = UDim2.new(1, -30, 0, 2)
MaxBtn.BackgroundTransparency = 1
MaxBtn.Text = "+"
MaxBtn.TextColor3 = Color3.fromRGB(0, 255, 127)
MaxBtn.TextSize = 22
MaxBtn.Parent = MinimizedFrame

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false MinimizedFrame.Position = MainFrame.Position MinimizedFrame.Visible = true end)
MaxBtn.MouseButton1Click:Connect(function() MainFrame.Position = MinimizedFrame.Position MainFrame.Visible = true MinimizedFrame.Visible = false end)

-- OYUNCU LİSTESİ
local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, -16, 0, 90)
PlayerScroll.Position = UDim2.new(0, 8, 0, 40)
PlayerScroll.BackgroundTransparency = 1
PlayerScroll.ScrollBarThickness = 2
PlayerScroll.Parent = MainFrame

local PlayerGrid = Instance.new("UIGridLayout")
PlayerGrid.Parent = PlayerScroll
PlayerGrid.CellPadding = UDim2.new(0, 5, 0, 5)
PlayerGrid.CellSize = UDim2.new(0.47, 0, 0, 28)

-- KOMUTLAR (3'lü Sıra - KIRMIZI BUTONLAR)
local CommandScroll = Instance.new("ScrollingFrame")
CommandScroll.Size = UDim2.new(1, -16, 0, 160)
CommandScroll.Position = UDim2.new(0, 8, 0, 140)
CommandScroll.BackgroundTransparency = 1
CommandScroll.ScrollBarThickness = 2
CommandScroll.Parent = MainFrame

local CommandGrid = Instance.new("UIGridLayout")
CommandGrid.Parent = CommandScroll
CommandGrid.CellPadding = UDim2.new(0, 4, 0, 4)
CommandGrid.CellSize = UDim2.new(0.31, 0, 0, 38)

local CommandData = {
    {name = "rocket", cd = 120}, {name = "ragdoll", cd = 30}, {name = "balloon", cd = 30},
    {name = "inverse", cd = 60}, {name = "nightvision", cd = 60}, {name = "jail", cd = 60},
    {name = "control", cd = 60}, {name = "tiny", cd = 60}, {name = "jumpscare", cd = 60},
    {name = "morph", cd = 60}
}

-- Komut Buton Oluşturucu (Animasyonlu)
for _, data in pairs(CommandData) do
    local CmdBtn = Instance.new("TextButton")
    CmdBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0) -- KIRMIZI BUTON
    CmdBtn.Text = data.name
    CmdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CmdBtn.Font = Enum.Font.GothamSemibold
    CmdBtn.TextSize = 8
    CmdBtn.Parent = CommandScroll
    Instance.new("UICorner", CmdBtn).CornerRadius = UDim.new(0, 5)
    
    Buttons[data.name] = {btn = CmdBtn, data = data}

    -- Hover Efekti
    CmdBtn.MouseEnter:Connect(function() playTween(CmdBtn, "BackgroundColor3", {BackgroundColor3 = Color3.fromRGB(120, 0, 0)}) end)
    CmdBtn.MouseLeave:Connect(function() if not Cooldowns[data.name] then playTween(CmdBtn, "BackgroundColor3", {BackgroundColor3 = Color3.fromRGB(80, 0, 0)}) end end)

    CmdBtn.MouseButton1Click:Connect(function()
        if SelectedPlayer and not Cooldowns[data.name] then
            local cmdStr = ";" .. data.name .. " " .. SelectedPlayer.Name
            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                TextChatService.TextChannels.RBXGeneral:SendAsync(cmdStr)
            else
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(cmdStr, "All")
            end
            
            Cooldowns[data.name] = true
            playTween(CmdBtn, "BackgroundColor3", {BackgroundColor3 = Color3.fromRGB(20, 20, 20)})
            CmdBtn.TextColor3 = Color3.fromRGB(255, 255, 0) -- PARLAK SARI COOLDOWN
            
            task.spawn(function()
                local remaining = data.cd
                while remaining > 0 do
                    CmdBtn.Text = remaining .. "s"
                    task.wait(1)
                    remaining = remaining - 1
                end
                CmdBtn.Text = data.name
                CmdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                playTween(CmdBtn, "BackgroundColor3", {BackgroundColor3 = Color3.fromRGB(80, 0, 0)})
                Cooldowns[data.name] = nil
            end)
        end
    end)
end

-- SPAM ALL BUTONU (Neon Kırmızı)
local SpamBtn = Instance.new("TextButton")
SpamBtn.Size = UDim2.new(1, -16, 0, 40)
SpamBtn.Position = UDim2.new(0, 8, 0, 310)
SpamBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
SpamBtn.Text = "🔥 SPAM ALL 🔥"
SpamBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpamBtn.Font = Enum.Font.GothamBold
SpamBtn.TextSize = 13
SpamBtn.Parent = MainFrame
Instance.new("UICorner", SpamBtn)

SpamBtn.MouseButton1Click:Connect(function()
    if SelectedPlayer then
        -- Tıklandığında hafif küçülme efekti
        playTween(SpamBtn, "Size", {Size = UDim2.new(1, -25, 0, 35)})
        task.wait(0.1)
        playTween(SpamBtn, "Size", {Size = UDim2.new(1, -16, 0, 40)})

        for _, cmdInfo in pairs(Buttons) do
            if not Cooldowns[cmdInfo.data.name] then
                local cmdStr = ";" .. cmdInfo.data.name .. " " .. SelectedPlayer.Name
                if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                    TextChatService.TextChannels.RBXGeneral:SendAsync(cmdStr)
                else
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(cmdStr, "All")
                end
                -- Cooldown görselini tetikle (Aynı mantık)
                task.spawn(function()
                    Cooldowns[cmdInfo.data.name] = true
                    cmdInfo.btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    cmdInfo.btn.TextColor3 = Color3.fromRGB(255, 255, 0)
                    local r = cmdInfo.data.cd
                    while r > 0 do cmdInfo.btn.Text = r .. "s" task.wait(1) r = r - 1 end
                    cmdInfo.btn.Text = cmdInfo.data.name
                    cmdInfo.btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    cmdInfo.btn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
                    Cooldowns[cmdInfo.data.name] = nil
                end)
                task.wait(0.1)
            end
        end
    end
end)

-- Oyuncu Listesi (Yumuşak Geçişli)
local function updatePlayers()
    for _, c in pairs(PlayerScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local B = Instance.new("TextButton")
            B.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            B.Text = p.DisplayName
            B.TextColor3 = Color3.fromRGB(255, 255, 255)
            B.TextSize = 9
            B.Font = Enum.Font.Gotham
            B.Parent = PlayerScroll
            Instance.new("UICorner", B)
            
            B.MouseButton1Click:Connect(function()
                for _, btn in pairs(PlayerScroll:GetChildren()) do
                    if btn:IsA("TextButton") then btn.TextColor3 = Color3.fromRGB(255, 255, 255) end
                end
                B.TextColor3 = Color3.fromRGB(0, 170, 255) -- Mavi Seçim
                SelectedPlayer = p
            end)
        end
    end
end

updatePlayers()
Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(updatePlayers)
