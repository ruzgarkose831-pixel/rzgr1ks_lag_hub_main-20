local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "rzgr1ks Hub V15 | Steal a Brainrot",
   LoadingTitle = "Yükleniyor...",
   LoadingSubtitle = "by rzgr1ks",
   ConfigurationSaving = {
      Enabled = false
   },
   KeySystem = false
})

local MainTab = Window:CreateTab("Ana Menü", 4483362458) -- Ana özellikler

-- HIZ AYARI (Bypasslı)
MainTab:CreateToggle({
   Name = "Speed Bypass (65 Speed)",
   CurrentValue = false,
   Flag = "SpeedToggle",
   Callback = function(Value)
      _G.SpeedBoost = Value
   end,
})

-- AIMBOT
MainTab:CreateToggle({
   Name = "Aimbot Lock",
   CurrentValue = false,
   Flag = "AimToggle",
   Callback = function(Value)
      _G.Aimbot = Value
   end,
})

-- INF JUMP
MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "JumpToggle",
   Callback = function(Value)
      _G.InfJump = Value
   end,
})

-- ESP
MainTab:CreateButton({
   Name = "Player ESP (Highlight)",
   Callback = function()
      for _, p in pairs(game.Players:GetPlayers()) do
         if p ~= game.Players.LocalPlayer and p.Character then
            local h = Instance.new("Highlight", p.Character)
            h.FillColor = Color3.fromRGB(255, 255, 0)
         end
      end
   end,
})

-- ARKA PLAN MOTORU (Hız ve Aimbot Logic)
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

RunService.RenderStepped:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        -- Hız Bypass
        if _G.SpeedBoost and char.Humanoid.MoveDirection.Magnitude > 0 then
            local s = char:FindFirstChildOfClass("Tool") and 30 or 65
            char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (char.Humanoid.MoveDirection * (s/60))
        end
        
        -- Aimbot Logic
        if _G.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local target = nil
            local dist = 300
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local pos, vis = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                    if vis then
                        local m = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                        if m < dist then target = p; dist = m end
                    end
                end
            end
            if target then
                camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            end
        end
    end
end)

-- INF JUMP LOOP
UIS.JumpRequest:Connect(function()
    if _G.InfJump and player.Character then
        player.Character.Humanoid:ChangeState(3)
    end
end)

Rayfield:Notify({
   Title = "Başarılı!",
   Content = "rzgr1ks Hub V15 Yüklendi. Menüyü sol üstteki butondan kontrol edebilirsin.",
   Duration = 5,
   Image = 4483362458,
})
