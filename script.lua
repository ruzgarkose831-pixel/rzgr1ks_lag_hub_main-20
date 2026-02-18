-- LocalScript (StarterGui içindeki ScreenGui içine ekle)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- RemoteEvent oluştur (eğer yoksa)
local sendEvent = ReplicatedStorage:FindFirstChild("SendMessageEvent")
if not sendEvent then
    sendEvent = Instance.new("RemoteEvent")
    sendEvent.Name = "SendMessageEvent"
    sendEvent.Parent = ReplicatedStorage
end

-- GUI oluştur
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0.8,0,0.7,0)
frame.Position = UDim2.new(0.1,0,0.15,0)
frame.BackgroundColor3 = Color3.new(0,0,0)
frame.BorderColor3 = Color3.new(0,1,0)
frame.BorderSizePixel = 4

-- Terminal Output
local output = Instance.new("TextLabel", frame)
output.Name = "TerminalOutput"
output.Text = "> Welcome to rzgr1ks s lag hub enter your ps link to bypass"
output.TextColor3 = Color3.new(0,1,0)
output.BackgroundTransparency = 1
output.Size = UDim2.new(1, -20, 0.7, -20)
output.Position = UDim2.new(0,10,0,10)
output.TextScaled = true
output.TextWrapped = true
output.TextXAlignment = Enum.TextXAlignment.Left
output.TextYAlignment = Enum.TextYAlignment.Top

-- InputBox
local inputBox = Instance.new("TextBox", frame)
inputBox.Name = "InputBox"
inputBox.PlaceholderText = "Type your ps link..."
inputBox.TextColor3 = Color3.new(0,1,0)
inputBox.BackgroundColor3 = Color3.new(0,0,0)
inputBox.BorderColor3 = Color3.new(0,1,0)
inputBox.ClearTextOnFocus = false
inputBox.Size = UDim2.new(0.7,0,0.1,0)
inputBox.Position = UDim2.new(0.15,0,0.75,0)
inputBox.TextXAlignment = Enum.TextXAlignment.Left

-- SendButton
local sendButton = Instance.new("TextButton", frame)
sendButton.Name = "SendButton"
sendButton.Text = "SEND"
sendButton.TextColor3 = Color3.new(0,1,0)
sendButton.BackgroundColor3 = Color3.new(0,0,0)
sendButton.BorderColor3 = Color3.new(0,1,0)
sendButton.Size = UDim2.new(0.2,0,0.08,0)
sendButton.Position = UDim2.new(0.4,0,0.87,0)

-- Terminal yazı ekleme fonksiyonu
local function appendTerminal(text)
    output.Text = output.Text .. "\n> " .. text
end

-- Mesaj gönderme fonksiyonu
local function sendMessage()
    local message = inputBox.Text
    if message ~= "" then
        -- RemoteEvent ile sunucuya mesaj gönderebiliriz
        sendEvent:FireServer(message)
        -- Terminale ekle
        appendTerminal(message)
        inputBox.Text = ""
    else
        appendTerminal("Error: empty message")
    end
end

-- Buton tıklama
sendButton.MouseButton1Click:Connect(sendMessage)

-- Enter tuşu ile gönder
inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        sendMessage()
    end
end)

-- Sunucudan gelen mesajları terminale yazdırma (opsiyonel)
sendEvent.OnClientEvent:Connect(function(msg)
    appendTerminal(msg)
end)

-- Sunucu tarafı basit log (LocalScript içinde test için)
sendEvent.OnServerEvent:Connect(function(player, message)
    print(player.Name .. " sent: " .. message)
end)
