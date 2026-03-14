--[[ 
    rzgr1ks duels v11 - MOBILE EDITION
    - Mobile Aimbot Button Added (Floating)
    - Touch Slider Optimization
    - Gravity & Spin Speed Fixed
]]--

if not game:IsLoaded() then task.wait() end

local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local lp = plrs.LocalPlayer
local cam = workspace.CurrentCamera

-- // CONFIGURATION
local cfg = {
    reach = false, reach_dist = 15, classic_hb = false,
    aim = false, aim_part = "Head", team_chk = true, wall_chk = false,
    spd = 16, jmp = 50, grav = 196.2, inf_jmp = false, 
    spin = false, spin_spd = 50,
    esp = false, xray = false, menu_open = true
}

local is_aiming = false -- Aimbot kontrolü

-- // UI SETUP
local gui = Instance.new("ScreenGui", (gethui and gethui()) or lp.PlayerGui)
gui.Name = "rz_v11_mobile"

-- // MOBILE AIMBOT BUTTON (E Tuşu yerine geçer)
local aimBtn = Instance.new("TextButton", gui)
aimBtn.Size = UDim2.new(0, 70, 0, 70)
aimBtn.Position = UDim2.new(0.7, 0, 0.5, 0)
aimBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
aimBtn.BackgroundTransparency = 0.5
aimBtn.Text = "AIM"
aimBtn.TextColor3 = Color3.new(1,1,1)
aimBtn.Font = "Code"
aimBtn.Visible = false -- Aimbot ayarı kapalıyken gizli kalır
Instance.new("UICorner", aimBtn).CornerRadius = UDim.new(1, 0)
aimBtn.Active = true
aimBtn.Draggable = true -- İstediğin yere çekebilirsin

aimBtn.MouseButton1Down:Connect(function() is_aiming = true; aimBtn.BackgroundTransparency = 0.1 end)
aimBtn.MouseButton1Up:Connect(function() is_aiming = false; aimBtn.BackgroundTransparency = 0.5 end)

-- // MAIN MENU
local bg = Instance.new("Frame", gui)
bg.Size = UDim2.new(0, 300, 0, 450); bg.Position = UDim2.new(0.1, 0, 0.2, 0)
bg.BackgroundColor3 = Color3.fromRGB(12, 12, 12); bg.Active = true; bg.Draggable = true; bg.ClipsDescendants = true
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)

local minBtn = Instance.new("TextButton", bg)
minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(1, -35, 0, 5)
minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); minBtn.Text = "-"; minBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", minBtn)

local top = Instance.new("TextLabel", bg)
top.Size = UDim2.new(1, 0, 0, 40); top.Text = "rzgr1ks v11 | MOBILE"; top.TextColor3 = Color3.new(1,0,0); top.Font = "Code"; top.BackgroundTransparency = 1

local scroll = Instance.new("ScrollingFrame", bg)
scroll.Size = UDim2.new(1, -10, 1, -50); scroll.Position = UDim2.new(0, 5, 0, 45)
scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 0; scroll.AutomaticCanvasSize = "Y"
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 4)

minBtn.MouseButton1Click:Connect(function()
    cfg.menu_open = not cfg.menu_open
    ts:Create(bg, TweenInfo.new(0.3), {Size = cfg.menu_open and UDim2.new(0, 300, 0, 450) or UDim2.new(0, 300, 0, 40)}):Play()
    minBtn.Text = cfg.menu_open and "-" or "+"
end)

-- // UI BUILDERS
local function btn(txt, state_key, callback)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, -5, 0, 30); b.BackgroundColor3 = Color3.fromRGB(22, 22, 22); b.TextColor3 = Color3.new(1,1,1); b.Font = "Code"; Instance.new("UICorner", b)
    local function upd() 
        b.Text = txt .. ": " .. (cfg[state_key] and "AÇIK" or "KAPALI")
        if state_key == "aim" then aimBtn.Visible = cfg.aim end
    end
    b.MouseButton1Click:Connect(function() cfg[state_key] = not cfg[state_key]; upd(); if callback then callback(cfg[state_key]) end end)
    upd()
end

local function slider(txt, min, max, state_key)
    local f = Instance.new("Frame", scroll); f.Size = UDim2.new(1, -5, 0, 45); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt..": "..cfg[state_key]; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Font = "Code"
    local b = Instance.new("Frame", f); b.Size = UDim2.new(1, -10, 0, 10); b.Position = UDim2.new(0,5,0,25); b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((cfg[state_key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.new(1,0,0)
    
    local function update(input)
        local pos = input.Position.X - b.AbsolutePosition.X
        local rel = math.clamp(pos / b.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (rel * (max - min)))
        cfg[state_key] = val
        l.Text = txt..": "..val
        fill.Size = UDim2.new(rel, 0, 1, 0)
    end
    
    b.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local con; con = rs.RenderStepped:Connect(function()
                if uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or uis:GetMouseLocation() then
                    update(input)
                else
                    con:Disconnect()
                end
            end)
        end
    end)
end

local function lbl(txt)
    local l = Instance.new("TextLabel", scroll); l.Size = UDim2.new(1, 0, 0, 25); l.Text = "--- " .. txt .. " ---"; l.TextColor3 = Color3.new(1,0,0); l.BackgroundTransparency = 1; l.Font = "Code"
end

-- // MENU SECTIONS
lbl("COMBAT")
btn("Stealth Reach", "reach")
btn("Classic Hitbox", "classic_hb")
slider("Menzil", 5, 100, "reach_dist")
btn("Spinbot", "spin")
slider("Spin Speed", 0, 500, "spin_spd")

lbl("AIMBOT (MOBILE FIX)")
btn("Aimbot Master", "aim")
btn("Team Check", "team_chk")
btn("Wall Check", "wall_chk")

lbl("MOVEMENT")
slider("Speed", 16, 250, "spd")
slider("Jump", 50, 300, "jmp")
slider("Gravity", 0, 500, "grav")
btn("Infinite Jump", "inf_jmp")

lbl("VISUALS")
btn("ESP", "esp")
btn("X-Ray", "xray", function(v)
    for _,o in pairs(workspace:GetDescendants()) do if o:IsA("BasePart") and not o:IsDescendantOf(lp.Character) and not o.Parent:FindFirstChild("Humanoid") then o.Transparency = v and 0.6 or 0 end end
end)

lbl("SOCIALS")
local ytBtn = Instance.new("TextButton", scroll)
ytBtn.Size = UDim2.new(1, -5, 0, 30); ytBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0); ytBtn.TextColor3 = Color3.new(1,1,1); ytBtn.Text = "YouTube: rzgr1ks"; ytBtn.Font = "Code"; Instance.new("UICorner", ytBtn)
ytBtn.MouseButton1Click:Connect(function() setclipboard("https://youtube.com/@rzgr1ks") end)

local dcBtn = Instance.new("TextButton", scroll)
dcBtn.Size = UDim2.new(1, -5, 0, 30); dcBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255); dcBtn.TextColor3 = Color3.new(1,1,1); dcBtn.Text = "Discord Server"; dcBtn.Font = "Code"; Instance.new("UICorner", dcBtn)
dcBtn.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/rzgr1ks") end)

-- // AIMBOT ENGINE
local function get_aim()
    local t, d = nil, math.huge
    for _, p in pairs(plrs:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if cfg.team_chk and p.Team == lp.Team then continue end
            local pos, vis = cam:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local dist = (Vector2.new(pos.X, pos.Y) - uis:GetMouseLocation()).Magnitude
                if dist < d then t = p.Character.Head; d = dist end
            end
        end
    end
    return t
end

-- // CORE LOOP
rs.RenderStepped:Connect(function()
    local char = lp.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = cfg.spd
        char.Humanoid.JumpPower = cfg.jmp
        workspace.Gravity = cfg.grav
        
        -- Mobile Aimbot Logic
        if cfg.aim and is_aiming then
            local target = get_aim()
            if target then cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position) end
        end
        
        -- Reach & Hitbox
        for _, p in pairs(plrs:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                local e_hrp = p.Character.HumanoidRootPart
                if cfg.classic_hb then
                    e_hrp.Size = Vector3.new(cfg.reach_dist, cfg.reach_dist, cfg.reach_dist)
                    e_hrp.Transparency = 0.7; e_hrp.CanCollide = false
                else
                    e_hrp.Size = Vector3.new(2, 2, 1); e_hrp.Transparency = 1; e_hrp.CanCollide = true
                end
                if cfg.reach then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        if (char.HumanoidRootPart.Position - e_hrp.Position).Magnitude <= cfg.reach_dist then
                            firetouchinterest(e_hrp, tool.Handle, 0); firetouchinterest(e_hrp, tool.Handle, 1)
                        end
                    end
                end
                if cfg.esp then
                    if not p.Character:FindFirstChild("rz_esp") then Instance.new("Highlight", p.Character).Name = "rz_esp" end
                else
                    if p.Character:FindFirstChild("rz_esp") then p.Character.rz_esp:Destroy() end
                end
            end
        end
        if cfg.spin and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, cfg.spin_spd, 0)
        end
    end
end)

uis.JumpRequest:Connect(function() if cfg.inf_jmp and lp.Character then lp.Character.Humanoid:ChangeState(3) end end)
