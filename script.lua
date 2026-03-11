local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- [[ MASTER SETTINGS ]] --
_G.Settings = {
    WalkSpeed = 16,
    JumpPower = 50,
    Gravity = 196.2,
    HBSize = 2,            -- Hitbox büyüklüğü (Kutudan ayarlanır)
    EscapeSpeed = 30,      -- Semi-TP hızı (Kutudan ayarlanır)
    Aimbot = false,
    HBExpander = false,
    AntiRagdoll = false,
    GalaxyMode = false,
    AutoClickE = false,
    AutoSteal = false,
    SemiTP = false,
    Points = {nil, nil, nil, nil},
    CurrentPoint = 1,
    AutoWalk = false,
    DeliveryPos = nil
}

-- [[ FORCE MOTOR - HER ŞEYİ KİLİTLER ]] --
RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = tonumber(_G.Settings.WalkSpeed) or 16
            hum.JumpPower = tonumber(_G.Settings.JumpPower) or 50
            hum.UseJumpPower = true
        end
        workspace.Gravity = tonumber(_G.Settings.Gravity) or 196.2
        
        -- Hitbox Expander Force
        if _G.Settings.HBExpander then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    local s = tonumber(_G.Settings.HBSize) or 2
                    hrp.Size = Vector3.new(s, s, s)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                end
            end
        end
    end)
end)

-- [[ UI DESIGN - PREMIUM COMPACT ]] --
if Player.PlayerGui:FindFirstChild("LemonV87") then Player.PlayerGui.LemonV87:Destroy() end
local gui = Instance.new("ScreenGui", Player.PlayerGui); gui.Name = "LemonV87"; gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui); main.Size = UDim2.new(0, 230, 0, 400); main.Position = UDim2.new(0.5, -115, 0.5, -200); main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); main.Active = true; main.Draggable = true
Instance.new("UICorner", main); local stroke = Instance.new("UIStroke", main); stroke.Thickness = 2; stroke.Color = Color3.fromRGB(255, 255, 0)

-- Sarı Top (Minimize)
local ball = Instance.new("TextButton", gui); ball.Size = UDim2.new(0, 50, 0, 50); ball.Position = UDim2.new(0.05, 0, 0.4, 0); ball.BackgroundColor3 = Color3.fromRGB(255, 255, 0); ball.Text = "🍋"; ball.Visible = false; Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)
local function Toggle(v) main.Visible = not v; ball.Visible = v end
local min = Instance.new("TextButton", main); min.Size = UDim2.new(0, 25, 0, 25); min.Position = UDim2.new(1, -30, 0, 5); min.Text = "-"; min.BackgroundColor3 = Color3.new(1,1,0); Instance.new("UICorner", min)
min.MouseButton1Click:Connect(function() Toggle(true) end); ball.MouseButton1Click:Connect(function() Toggle(false) end)

local scroll = Instance.new("ScrollingFrame", main); scroll.Size = UDim2.new(1, -10, 1, -50); scroll.Position = UDim2.new(0, 5, 0, 45); scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 6, 0); scroll.ScrollBarThickness = 2
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 6)

-- [[ CUSTOM INPUT BOX FONKSİYONU ]] --
local function AddInput(label, settingField)
    local frame = Instance.new("Frame", scroll); frame.Size = UDim2.new(0.95, 0, 0, 35); frame.BackgroundTransparency = 1
    local txt = Instance.new("TextLabel", frame); txt.Size = UDim2.new(0.5, 0, 1, 0); txt.Text = label; txt.TextColor3 = Color3.new(1,1,1); txt.BackgroundTransparency = 1; txt.Font = "GothamBold"; txt.TextSize = 10; txt.TextXAlignment = "Left"
    local box = Instance.new("TextBox", frame); box.Size = UDim2.new(0.4, 0, 0.8, 0); box.Position = UDim2.new(0.55, 0, 0.1, 0); box.BackgroundColor3 = Color3.fromRGB(30,30,30); box.TextColor3 = Color3.fromRGB(255, 255, 0); box.Text = tostring(_G.Settings[settingField]); Instance.new("UICorner", box)
    box.FocusLost:Connect(function() _G.Settings[settingField] = tonumber(box.Text) or _G.Settings[settingField] end)
end

-- [[ GİRİŞ KUTULARI (INPUTS) ]] --
AddInput("WALK SPEED:", "WalkSpeed")
AddInput("JUMP POWER:", "JumpPower")
AddInput("GRAVITY:", "Gravity")
AddInput("HITBOX SIZE:", "HBSize")
AddInput("SEMI-TP SPEED:", "EscapeSpeed")

-- [[ AÇ/KAPAT BUTONLARI (TOGGLES) ]] --
local function AddToggle(txt, callback)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(0.95, 0, 0, 32); b.Text = txt .. ": OFF"; b.BackgroundColor3 = Color3.fromRGB(35, 35, 35); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    local act = false; b.MouseButton1Click:Connect(function() act = not act; callback(act); b.Text = txt .. ": " .. (act and "ON" or "OFF"); b.BackgroundColor3 = act and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(35, 35, 35); b.TextColor3 = act and Color3.new(0,0,0) or Color3.new(1,1,1) end)
end

AddToggle("HB EXPANDER", function(v) _G.Settings.HBExpander = v end)
AddToggle("SEMI-TP ESCAPE", function(v) _G.Settings.SemiTP = v end)
AddToggle("AUTO CLICK E", function(v) _G.Settings.AutoClickE = v end)
AddToggle("AIMBOT", function(v) _G.Settings.Aimbot = v end)
AddToggle("ANTI RAGDOLL", function(v) _G.Settings.AntiRagdoll = v end)
AddToggle("GALAXY MODE", function(v) -- Galaxy code
end)

-- [[ DİĞER BUTONLAR ]] --
for i = 1, 4 do
    local pb = Instance.new("TextButton", scroll); pb.Size = UDim2.new(0.95, 0, 0, 25); pb.Text = "Set Auto-Walk P" .. i; pb.BackgroundColor3 = Color3.fromRGB(80, 0, 0); pb.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", pb)
    pb.MouseButton1Click:Connect(function() _G.Settings.Points[i] = Player.Character.HumanoidRootPart.Position; pb.Text = "P"..i.." SAVED!" end)
end

local setTarget = Instance.new("TextButton", scroll); setTarget.Size = UDim2.new(0.95, 0, 0, 30); setTarget.Text = "SET SEMI-TP TARGET"; setTarget.BackgroundColor3 = Color3.fromRGB(0, 80, 150); setTarget.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", setTarget)
setTarget.MouseButton1Click:Connect(function() _G.Settings.DeliveryPos = Player.Character.HumanoidRootPart.Position; setTarget.Text = "TARGET OK!" end)

print("🍋 LEMON V87: FULL CUSTOM CONTROL LOADED!")
