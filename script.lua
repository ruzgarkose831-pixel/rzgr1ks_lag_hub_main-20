local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local Toggles = {Speed = false, Jump = false, Grav = false, ESP = false, HB = false}
local Vars = {SpeedVal = 40, HBSize = 12}

-- [[ 1. GUI OLUŞTURMA ]] --
local guiName = "rzgr1ks_V10_Force"
local guiParent = (gethui and gethui()) or game:GetService("CoreGui") or LP:WaitForChild("PlayerGui")

if guiParent:FindFirstChild(guiName) then
    guiParent[guiName]:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name = guiName
sg.ResetOnSpawn = false
sg.DisplayOrder = 100
sg.Parent = guiParent

local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.new(0, 260, 0, 400)
main.Position = UDim2.new(0.5, -130, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 0
main.Active = true
main.ZIndex = 5
main.Parent = sg

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 150, 255)
stroke.Thickness = 2
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.Text = "rzgr1ks duels V10"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.ZIndex = 6
title.Parent = main
Instance.new("UICorner", title)

-- [[ 2. DRAG SYSTEM (SÜRÜKLEME) ]] --
local dragging = false
local dragInput
local dragStart
local startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- [[ 3. BUTON OLUŞTURUCU ]] --
local function CreateBtn(name, var, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 230, 0, 40)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.ZIndex = 7
    btn.Parent = main
    
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        Toggles[var] = not Toggles[var]
        btn.BackgroundColor3 = Toggles[var] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 50)
    end)
end

CreateBtn("👁️ ESP (Parıltı)", "ESP", 60)
CreateBtn("🎯 Adamlar İçin HB Expander", "HB", 110)
CreateBtn("⚡ Speed Hack", "Speed", 160)
CreateBtn("⬆️ Jump Power", "Jump", 210)
CreateBtn("🌌 Gravity Mode", "Grav", 260)

local inp = Instance.new("TextBox")
inp.Size = UDim2.new(0, 230, 0, 35)
inp.Position = UDim2.new(0, 15, 0, 310)
inp.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
inp.PlaceholderText = "Hız Değeri (40)"
inp.Text = ""
inp.TextColor3 = Color3.new(1, 1, 1)
inp.ZIndex = 7
inp.Parent = main

inp.FocusLost:Connect(function()
    Vars.SpeedVal = tonumber(inp.Text) or 40
end)

-- [[ 4. FONKSİYONEL MOTORLAR ]] --
RS.RenderStepped:Connect(function()
    pcall(function()
        local char = LP.Character
        local hum = char and char:FindFirstChild("Humanoid")
        
        -- Speed & Jump Logic
        if hum then
            hum.WalkSpeed = Toggles.Speed and Vars.SpeedVal or 16
            if Toggles.Jump then 
                hum.UseJumpPower = true 
                hum.JumpPower = 75 
            else 
                hum.JumpPower = 50 
            end
        end

        -- Gravity Logic
        workspace.Gravity = Toggles.Grav and 50 or 196.2

        -- Hitbox Expander (Adamlar İçin)
        if Toggles.HB then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(Vars.HBSize, Vars.HBSize, Vars.HBSize)
                    hrp.Transparency = 0.6
                    hrp.CanCollide = false
                end
            end
        end
    end)
end)

-- ESP Sistemi (Highlight)
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local hl = p.Character:FindFirstChild("rzgr_ESP")
                    if Toggles.ESP then
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "rzgr_ESP"
                            hl.FillColor = Color3.new(1, 0, 0)
                            hl.OutlineColor = Color3.new(1, 1, 1)
                            hl.Parent = p.Character
                        end
                    else
                        if hl then hl:Destroy() end
                    end
                end
            end
        end)
    end
end)

print("✅ rzgr1ks Duels V10: GUI ve Script Başarıyla Birleştirildi!")
