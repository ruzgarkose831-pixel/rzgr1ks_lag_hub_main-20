--[[ 
    rzgr1ks duels v12 - SILENT AIM & AUTO-CLICK
    - Silent Aim: Karakter döner, kamera dönmez.
    - Auto Attack: Otomatik vuruş/ateş.
    - Mobile Optimized.
]]--

if not game:IsLoaded() then task.wait() end

local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local vim = game:GetService("VirtualInputManager") -- Otomatik tıklama için
local lp = plrs.LocalPlayer
local cam = workspace.CurrentCamera

-- // CONFIGURATION
local cfg = {
    reach = false, reach_dist = 15, classic_hb = false,
    aim = false, silent_aim = true, aim_part = "HumanoidRootPart", -- Karakterin dönmesi için RootPart daha iyi
    auto_click = false, team_chk = true, wall_chk = false,
    spd = 16, jmp = 50, grav = 196.2, inf_jmp = false, 
    spin = false, spin_spd = 50,
    esp = false, xray = false, menu_open = true
}

local is_aiming = false

-- // UI SETUP
local gui = Instance.new("ScreenGui", (gethui and gethui()) or lp.PlayerGui)
gui.Name = "rz_v12_silent"

-- // MOBILE AIM & ATTACK BUTTON
local aimBtn = Instance.new("TextButton", gui)
aimBtn.Size = UDim2.new(0, 80, 0, 80); aimBtn.Position = UDim2.new(0.7, 0, 0.4, 0)
aimBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0); aimBtn.BackgroundTransparency = 0.5
aimBtn.Text = "LOCK"; aimBtn.TextColor3 = Color3.new(1,1,1); aimBtn.Font = "Code"
Instance.new("UICorner", aimBtn).CornerRadius = UDim.new(1, 0)
aimBtn.Active = true; aimBtn.Draggable = true; aimBtn.Visible = false

aimBtn.MouseButton1Down:Connect(function() is_aiming = true; aimBtn.BackgroundColor3 = Color3.new(0,1,0) end)
aimBtn.MouseButton1Up:Connect(function() is_aiming = false; aimBtn.BackgroundColor3 = Color3.new(1,0,0) end)

-- // MAIN MENU
local bg = Instance.new("Frame", gui)
bg.Size = UDim2.new(0, 300, 0, 500); bg.Position = UDim2.new(0.1, 0, 0.2, 0)
bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10); bg.Active = true; bg.Draggable = true; bg.ClipsDescendants = true
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)

local minBtn = Instance.new("TextButton", bg)
minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(1, -35, 0, 5)
minBtn.Text = "-"; minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); minBtn.TextColor3 = Color3.new(1,1,1)

local scroll = Instance.new("ScrollingFrame", bg)
scroll.Size = UDim2.new(1, -10, 1, -50); scroll.Position = UDim2.new(0, 5, 0, 45)
scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 0; scroll.AutomaticCanvasSize = "Y"
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 4)

minBtn.MouseButton1Click:Connect(function()
    cfg.menu_open = not cfg.menu_open
    ts:Create(bg, TweenInfo.new(0.3), {Size = cfg.menu_open and UDim2.new(0, 300, 0, 500) or UDim2.new(0, 300, 0, 40)}):Play()
    minBtn.Text = cfg.menu_open and "-" or "+"
end)

-- // BUILDERS
local function btn(txt, state_key)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, -5, 0, 30); b.BackgroundColor3 = Color3.fromRGB(22, 22, 22); b.TextColor3 = Color3.new(1,1,1); b.Font = "Code"; Instance.new("UICorner", b)
    local function upd() 
        b.Text = txt .. ": " .. (cfg[state_key] and "AÇIK" or "KAPALI")
        if state_key == "aim" then aimBtn.Visible = cfg.aim end
    end
    b.MouseButton1Click:Connect(function() cfg[state_key] = not cfg[state_key]; upd() end)
    upd()
end

local function slider(txt, min, max, state_key)
    local f = Instance.new("Frame", scroll); f.Size = UDim2.new(1, -5, 0, 45); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt..": "..cfg[state_key]; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Font = "Code"
    local b = Instance.new("Frame", f); b.Size = UDim2.new(1, -10, 0, 8); b.Position = UDim2.new(0,5,0,25); b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((cfg[state_key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.new(1,0,0)
    
    b.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            local moving = rs.RenderStepped:Connect(function()
                local pos = uis:GetMouseLocation().X - b.AbsolutePosition.X
                local rel = math.clamp(pos / b.AbsoluteSize.X, 0, 1)
                cfg[state_key] = math.floor(min + (rel * (max - min)))
                l.Text = txt..": "..cfg[state_key]; fill.Size = UDim2.new(rel, 0, 1, 0)
            end)
            uis.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then moving:Disconnect() end end)
        end
    end)
end

-- // SECTIONS
btn("Aimbot Master (LOCK)", "aim")
btn("Silent Aim (Gövde Döner)", "silent_aim")
btn("Auto Click/Attack", "auto_click")
btn("Stealth Reach", "reach")
slider("Reach Menzili", 5, 100, "reach_dist")
slider("Hız", 16, 250, "spd")
slider("Yerçekimi", 0, 500, "grav")
btn("ESP", "esp")

-- // SOCIALS
local yt = Instance.new("TextButton", scroll); yt.Size = UDim2.new(1, -5, 0, 35); yt.BackgroundColor3 = Color3.new(0.8,0,0); yt.Text = "YouTube: rzgr1ks"; yt.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", yt)
yt.MouseButton1Click:Connect(function() setclipboard("https://youtube.com/@rzgr1ks") end)

local dc = Instance.new("TextButton", scroll); dc.Size = UDim2.new(1, -5, 0, 35); dc.BackgroundColor3 = Color3.new(0,0.4,1); dc.Text = "Discord Server"; dc.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", dc)
dc.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/rzgr1ks") end)

-- // HELPER: TARGET FINDER
local function get_target()
    local t, d = nil, math.huge
    for _, p in pairs(plrs:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            if cfg.team_chk and p.Team == lp.Team then continue end
            local pos, vis = cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if vis then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                if dist < d then t = p.Character.HumanoidRootPart; d = dist end
            end
        end
    end
    return t
end

-- // MAIN ENGINE
rs.RenderStepped:Connect(function()
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if hum then 
        hum.WalkSpeed = cfg.spd
        workspace.Gravity = cfg.grav
    end

    if is_aiming and cfg.aim then
        local target = get_target()
        if target then
            if cfg.silent_aim and hrp then
                -- Sadece karakteri döndür (Kamera serbest)
                local lookPos = Vector3.new(target.Position.X, hrp.Position.Y, target.Position.Z)
                hrp.CFrame = CFrame.lookAt(hrp.Position, lookPos)
            else
                -- Klasik kilitlenme (Kamera döner)
                cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position)
            end
            
            -- Auto Click (Ekran ortasına tıklar veya toolu tetikler)
            if cfg.auto_click then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then 
                    tool:Activate() -- Çoğu oyunda bu yeterlidir
                else
                    -- Eğer tool yoksa ekran ortasına sanal tıklama gönder
                    vim:SendMouseButtonEvent(cam.ViewportSize.X/2, cam.ViewportSize.Y/2, 0, true, game, 0)
                    vim:SendMouseButtonEvent(cam.ViewportSize.X/2, cam.ViewportSize.Y/2, 0, false, game, 0)
                end
            end
        end
    end
    
    -- Reach & ESP Logic
    for _, p in pairs(plrs:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local e_hrp = p.Character.HumanoidRootPart
            if cfg.reach and hrp then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") and (hrp.Position - e_hrp.Position).Magnitude <= cfg.reach_dist then
                    firetouchinterest(e_hrp, tool.Handle, 0); firetouchinterest(e_hrp, tool.Handle, 1)
                end
            end
            if cfg.esp then
                if not p.Character:FindFirstChild("rz_esp") then Instance.new("Highlight", p.Character).Name = "rz_esp" end
            else
                if p.Character:FindFirstChild("rz_esp") then p.Character.rz_esp:Destroy() end
            end
        end
    end
end)

uis.JumpRequest:Connect(function() if cfg.inf_jmp and lp.Character then lp.Character.Humanoid:ChangeState(3) end end)
