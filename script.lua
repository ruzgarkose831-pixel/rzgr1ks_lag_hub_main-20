--[[
    rzgr1ks duels - v9 (Slider & Aim Fixed)
    yt: rzgr1ks | dc: rzgr1ks
]]--

if not game:IsLoaded() then task.wait() end

local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local lp = plrs.LocalPlayer
local cam = workspace.CurrentCamera

local cfg = {
    reach = false, reach_dist = 15, classic_hb = false,
    aim = false, aim_part = "Head", team_chk = true, wall_chk = false,
    spd = 16, jmp = 50, inf_jmp = false, spin = false, spin_spd = 50,
    esp = false, xray = false, menu_open = true
}

local gui = Instance.new("ScreenGui", (gethui and gethui()) or lp.PlayerGui)
gui.Name = "rz_v9_final"

local bg = Instance.new("Frame", gui)
bg.Size = UDim2.new(0, 350, 0, 480); bg.Position = UDim2.new(0.5, -175, 0.2, 0)
bg.BackgroundColor3 = Color3.fromRGB(15, 15, 15); bg.Active = true; bg.Draggable = true; bg.ClipsDescendants = true
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)

-- // KÜÇÜLTME BUTONU (Minimize)
local minBtn = Instance.new("TextButton", bg)
minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(1, -35, 0, 5)
minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); minBtn.Text = "-"; minBtn.TextColor3 = Color3.new(1,1,1); minBtn.Font = "Code"
Instance.new("UICorner", minBtn)

local top = Instance.new("TextLabel", bg)
top.Size = UDim2.new(1, 0, 0, 40); top.Text = "rzgr1ks v9 | FIX"; top.TextColor3 = Color3.new(1,0,0); top.Font = "Code"; top.BackgroundTransparency = 1; top.TextSize = 16

local scroll = Instance.new("ScrollingFrame", bg)
scroll.Size = UDim2.new(1, -10, 1, -50); scroll.Position = UDim2.new(0, 5, 0, 45)
scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 2; scroll.AutomaticCanvasSize = "Y"
local list = Instance.new("UIListLayout", scroll); list.Padding = UDim.new(0, 4)

minBtn.MouseButton1Click:Connect(function()
    cfg.menu_open = not cfg.menu_open
    ts:Create(bg, TweenInfo.new(0.3), {Size = cfg.menu_open and UDim2.new(0, 350, 0, 480) or UDim2.new(0, 350, 0, 40)}):Play()
    minBtn.Text = cfg.menu_open and "-" or "+"
end)

-- // UI Builder (Fixed Sliders)
local function btn(txt, state_key, callback)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, -5, 0, 30); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.TextColor3 = Color3.new(1,1,1); b.Font = "Code"; Instance.new("UICorner", b)
    local function upd() b.Text = txt .. ": " .. (cfg[state_key] and "ON" or "OFF") end
    b.MouseButton1Click:Connect(function() cfg[state_key] = not cfg[state_key]; upd(); if callback then callback(cfg[state_key]) end end)
    upd()
end

local function slider(txt, min, max, state_key)
    local f = Instance.new("Frame", scroll); f.Size = UDim2.new(1, -5, 0, 45); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt..": "..cfg[state_key]; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Font = "Code"
    local b = Instance.new("Frame", f); b.Size = UDim2.new(1, -10, 0, 10); b.Position = UDim2.new(0,5,0,25); b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((cfg[state_key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.new(1,0,0)
    
    local function update_slider()
        local m = uis:GetMouseLocation()
        local rel = math.clamp((m.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (rel * (max - min)))
        cfg[state_key] = val
        l.Text = txt..": "..val
        fill.Size = UDim2.new(rel, 0, 1, 0)
    end

    local dragging = false
    b.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    uis.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    rs.RenderStepped:Connect(function() if dragging then update_slider() end end)
end

local function lbl(txt)
    local l = Instance.new("TextLabel", scroll); l.Size = UDim2.new(1, 0, 0, 20); l.Text = " > " .. txt; l.TextColor3 = Color3.new(1,0,0); l.BackgroundTransparency = 1; l.Font = "Code"; l.TextXAlignment = "Left"
end

-- // Menü Elemanları
lbl("COMBAT & REACH")
btn("Stealth Reach (Bypass)", "reach")
btn("Classic Hitbox (Size)", "classic_hb")
slider("Menzil Boyutu", 5, 100, "reach_dist")
btn("Spinbot", "spin")

lbl("AIMBOT (Hold E)")
btn("Aimbot Active", "aim")
btn("Team Check", "team_chk")
btn("Wall Check", "wall_chk")
local pt_btn = Instance.new("TextButton", scroll); pt_btn.Size = UDim2.new(1, -5, 0, 30); pt_btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); pt_btn.TextColor3 = Color3.new(1,1,1); pt_btn.Font = "Code"; Instance.new("UICorner", pt_btn); pt_btn.Text = "Part: " .. cfg.aim_part
pt_btn.MouseButton1Click:Connect(function() cfg.aim_part = (cfg.aim_part == "Head") and "HumanoidRootPart" or "Head"; pt_btn.Text = "Part: " .. cfg.aim_part end)

lbl("MOVEMENT")
slider("Speed", 16, 300, "spd")
slider("Jump", 50, 400, "jmp")
btn("Infinite Jump", "inf_jmp")

lbl("VISUALS")
btn("ESP", "esp")
btn("X-Ray", "xray", function(v)
    for _,o in pairs(workspace:GetDescendants()) do if o:IsA("BasePart") and not o:IsDescendantOf(lp.Character) and not o.Parent:FindFirstChild("Humanoid") then o.Transparency = v and 0.6 or 0 end end
end)

-- // AIMBOT ENGINE (FIXED)
local is_aiming = false
uis.InputBegan:Connect(function(k, gp) if not gp and k.KeyCode == Enum.KeyCode.E then is_aiming = true end end)
uis.InputEnded:Connect(function(k, gp) if not gp and k.KeyCode == Enum.KeyCode.E then is_aiming = false end end)

local function get_aim()
    local t, d = nil, math.huge
    for _, p in pairs(plrs:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild(cfg.aim_part) and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if cfg.team_chk and p.Team == lp.Team then continue end
            local pos, vis = cam:WorldToViewportPoint(p.Character[cfg.aim_part].Position)
            if vis then
                if cfg.wall_chk then
                    local r = Ray.new(cam.CFrame.Position, (p.Character[cfg.aim_part].Position - cam.CFrame.Position).Unit * 1000)
                    local hit = workspace:FindPartOnRayWithIgnoreList(r, {lp.Character, p.Character})
                    if hit then continue end
                end
                local dist = (Vector2.new(pos.X, pos.Y) - uis:GetMouseLocation()).Magnitude
                if dist < d then t = p.Character[cfg.aim_part]; d = dist end
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
        
        -- Aimbot Lock
        if cfg.aim and is_aiming then
            local target = get_aim()
            if target then cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position) end
        end
        
        -- Reach & Hitbox Logic
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
                
                -- ESP
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
btn("Copy Socials", "none", function() setclipboard("yt: rzgr1ks | dc: rzgr1ks") end)
