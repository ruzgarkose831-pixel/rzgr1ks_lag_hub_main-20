--[[ 
    rzgr1ks duels v13 - THE COMPLETE BUILD
    - NO FEATURES REMOVED
    - FIXED AIMBOT & SILENT AIM
    - AUTO-ATTACK & REACH
    - MOBILE UI OPTIMIZED
]]--

if not game:IsLoaded() then task.wait() end

local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local lp = plrs.LocalPlayer
local cam = workspace.CurrentCamera

-- // FULL CONFIGURATION
local cfg = {
    -- Combat
    aim = false, silent_aim = true, auto_click = false,
    reach = false, reach_dist = 15, classic_hb = false,
    team_chk = true, wall_chk = false, aim_part = "HumanoidRootPart",
    -- Movement
    spd = 16, jmp = 50, grav = 196.2, inf_jmp = false,
    spin = false, spin_spd = 100,
    -- Visuals & Misc
    esp = false, xray = false, menu_open = true
}

local is_aiming = false

-- // UI SETUP
local gui = Instance.new("ScreenGui", (gethui and gethui()) or lp.PlayerGui)
gui.Name = "rz_v13_final"

-- // MOBILE LOCK BUTTON (Draggable)
local lockBtn = Instance.new("TextButton", gui)
lockBtn.Size = UDim2.new(0, 75, 0, 75); lockBtn.Position = UDim2.new(0.7, 0, 0.4, 0)
lockBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0); lockBtn.BackgroundTransparency = 0.4
lockBtn.Text = "LOCK"; lockBtn.TextColor3 = Color3.new(1,1,1); lockBtn.Font = "Code"; lockBtn.TextSize = 18
Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(1, 0)
lockBtn.Active = true; lockBtn.Draggable = true; lockBtn.Visible = false

lockBtn.MouseButton1Down:Connect(function() is_aiming = true; lockBtn.BackgroundColor3 = Color3.new(0, 1, 0) end)
lockBtn.MouseButton1Up:Connect(function() is_aiming = false; lockBtn.BackgroundColor3 = Color3.new(0.8, 0, 0) end)

-- // MAIN MENU
local bg = Instance.new("Frame", gui)
bg.Size = UDim2.new(0, 320, 0, 480); bg.Position = UDim2.new(0.1, 0, 0.2, 0)
bg.BackgroundColor3 = Color3.fromRGB(15, 15, 15); bg.Active = true; bg.Draggable = true; bg.ClipsDescendants = true
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)

local minBtn = Instance.new("TextButton", bg)
minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(1, -35, 0, 5)
minBtn.Text = "-"; minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); minBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", minBtn)

local top = Instance.new("TextLabel", bg)
top.Size = UDim2.new(1, 0, 0, 40); top.Text = "rzgr1ks v13 | ALL FEATURES"; top.TextColor3 = Color3.new(1,0,0); top.Font = "Code"; top.TextSize = 16; top.BackgroundTransparency = 1

local scroll = Instance.new("ScrollingFrame", bg)
scroll.Size = UDim2.new(1, -10, 1, -50); scroll.Position = UDim2.new(0, 5, 0, 45); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 2; scroll.AutomaticCanvasSize = "Y"
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

minBtn.MouseButton1Click:Connect(function()
    cfg.menu_open = not cfg.menu_open
    ts:Create(bg, TweenInfo.new(0.3), {Size = cfg.menu_open and UDim2.new(0, 320, 0, 480) or UDim2.new(0, 320, 0, 40)}):Play()
    minBtn.Text = cfg.menu_open and "-" or "+"
end)

-- // UI ELEMENTS BUILDER
local function btn(txt, state_key, callback)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, -10, 0, 35); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.TextColor3 = Color3.new(1,1,1); b.Font = "Code"; b.TextSize = 14
    Instance.new("UICorner", b)
    local function upd() 
        b.Text = txt .. ": " .. (cfg[state_key] and "ON" or "OFF")
        if state_key == "aim" then lockBtn.Visible = cfg.aim end
    end
    b.MouseButton1Click:Connect(function() cfg[state_key] = not cfg[state_key]; upd(); if callback then callback(cfg[state_key]) end end)
    upd()
end

local function slider(txt, min, max, state_key)
    local f = Instance.new("Frame", scroll); f.Size = UDim2.new(1, -10, 0, 45); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt..": "..cfg[state_key]; l.TextColor3 = Color3.new(1,1,1); l.Font = "Code"; l.BackgroundTransparency = 1
    local b = Instance.new("Frame", f); b.Size = UDim2.new(1, 0, 0, 10); b.Position = UDim2.new(0,0,0,25); b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((cfg[state_key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.new(1,0,0)
    
    local function update_slider()
        local rel = math.clamp((uis:GetMouseLocation().X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (rel * (max - min)))
        cfg[state_key] = val; l.Text = txt..": "..val; fill.Size = UDim2.new(rel, 0, 1, 0)
    end
    local dragging = false
    b.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    uis.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    rs.RenderStepped:Connect(function() if dragging then update_slider() end end)
end

local function lbl(txt)
    local l = Instance.new("TextLabel", scroll); l.Size = UDim2.new(1, 0, 0, 25); l.Text = "-- " .. txt .. " --"; l.TextColor3 = Color3.new(0.6, 0.6, 0.6); l.Font = "Code"; l.BackgroundTransparency = 1
end

-- // LIST FEATURES
lbl("COMBAT")
btn("Aimbot Master", "aim")
btn("Silent Mode", "silent_aim")
btn("Auto Attack", "auto_click")
btn("Reach (Stealth)", "reach")
btn("Classic Hitbox", "classic_hb")
slider("Reach/Hitbox Size", 5, 100, "reach_dist")

lbl("MOVEMENT")
slider("Speed", 16, 300, "spd")
slider("Jump Power", 50, 400, "jmp")
slider("Gravity", 0, 500, "grav")
btn("Inf Jump", "inf_jmp")
btn("Spinbot", "spin")
slider("Spin Speed", 0, 500, "spin_spd")

lbl("VISUALS")
btn("ESP", "esp")
btn("X-Ray", "xray", function(v)
    for _,o in pairs(workspace:GetDescendants()) do if o:IsA("BasePart") and not o:IsDescendantOf(lp.Character) and not o.Parent:FindFirstChild("Humanoid") then o.Transparency = v and 0.6 or 0 end end
end)

lbl("SOCIALS")
local yt = Instance.new("TextButton", scroll); yt.Size = UDim2.new(1, -10, 0, 35); yt.BackgroundColor3 = Color3.new(0.8, 0, 0); yt.Text = "YouTube: rzgr1ks"; yt.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", yt)
yt.MouseButton1Click:Connect(function() setclipboard("https://youtube.com/@rzgr1ks") end)

local dc = Instance.new("TextButton", scroll); dc.Size = UDim2.new(1, -10, 0, 35); dc.BackgroundColor3 = Color3.new(0, 0.4, 1); dc.Text = "Discord Server"; dc.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", dc)
dc.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/rzgr1ks") end)

-- // AIMBOT & ENGINE LOGIC (FIXED)
local function get_target()
    local t, d = nil, math.huge
    for _, p in pairs(plrs:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
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

rs.RenderStepped:Connect(function()
    local char = lp.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        local hrp = char.HumanoidRootPart
        
        hum.WalkSpeed = cfg.spd
        hum.JumpPower = cfg.jmp
        workspace.Gravity = cfg.grav
        
        if is_aiming and cfg.aim then
            local target = get_target()
            if target then
                if cfg.silent_aim then
                    local lookPos = Vector3.new(target.Position.X, hrp.Position.Y, target.Position.Z)
                    hrp.CFrame = CFrame.lookAt(hrp.Position, lookPos)
                else
                    cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position)
                end
                
                if cfg.auto_click then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
        end
        
        -- Reach, Hitbox, ESP Loop
        for _, p in pairs(plrs:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local e_hrp = p.Character.HumanoidRootPart
                -- Reach
                if cfg.reach then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") and (hrp.Position - e_hrp.Position).Magnitude <= cfg.reach_dist then
                        firetouchinterest(e_hrp, tool.Handle, 0); firetouchinterest(e_hrp, tool.Handle, 1)
                    end
                end
                -- Hitbox
                if cfg.classic_hb then
                    e_hrp.Size = Vector3.new(cfg.reach_dist, cfg.reach_dist, cfg.reach_dist)
                    e_hrp.Transparency = 0.7; e_hrp.CanCollide = false
                else
                    e_hrp.Size = Vector3.new(2, 2, 1); e_hrp.Transparency = 1; e_hrp.CanCollide = true
                end
                -- ESP
                if cfg.esp then
                    if not p.Character:FindFirstChild("rz_esp") then Instance.new("Highlight", p.Character).Name = "rz_esp" end
                else
                    if p.Character:FindFirstChild("rz_esp") then p.Character.rz_esp:Destroy() end
                end
            end
        end
        
        if cfg.spin then hrp.AssemblyAngularVelocity = Vector3.new(0, cfg.spin_spd, 0) end
    end
end)

uis.JumpRequest:Connect(function() if cfg.inf_jmp and lp.Character then lp.Character.Humanoid:ChangeState(3) end end)
