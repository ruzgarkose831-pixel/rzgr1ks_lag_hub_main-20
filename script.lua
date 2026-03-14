--[[
    rzgr1ks duels - v8 full private
    yt: rzgr1ks | dc: rzgr1ks
]]--

if not game:IsLoaded() then task.wait() end

local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local lp = plrs.LocalPlayer
local cam = workspace.CurrentCamera

local cfg = {
    reach = false, reach_dist = 15, classic_hb = false,
    aim = false, aim_part = "Head", team_chk = true, wall_chk = false,
    spd = 16, jmp = 50, inf_jmp = false, spin = false, spin_spd = 50,
    esp = false, xray = false
}

local gui = Instance.new("ScreenGui", (gethui and gethui()) or lp.PlayerGui)
gui.Name = "rz_v8_priv"

local bg = Instance.new("Frame", gui)
bg.Size = UDim2.new(0, 350, 0, 480); bg.Position = UDim2.new(0.5, -175, 0.2, 0)
bg.BackgroundColor3 = Color3.fromRGB(15, 15, 15); bg.Active = true; bg.Draggable = true
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)

local top = Instance.new("TextLabel", bg)
top.Size = UDim2.new(1, 0, 0, 30); top.Text = "rzgr1ks duels v8 | FULL"; top.TextColor3 = Color3.new(1,0,0); top.Font = "Code"; top.BackgroundTransparency = 1; top.TextSize = 16

local scroll = Instance.new("ScrollingFrame", bg)
scroll.Size = UDim2.new(1, -10, 1, -40); scroll.Position = UDim2.new(0, 5, 0, 35)
scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 2; scroll.AutomaticCanvasSize = "Y"
local list = Instance.new("UIListLayout", scroll); list.Padding = UDim.new(0, 4)

-- // UI Builder (Kısa ve organik)
local function btn(txt, state_key, callback)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, -5, 0, 30); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.TextColor3 = Color3.new(1,1,1); b.Font = "Code"; Instance.new("UICorner", b)
    local function upd() b.Text = txt .. ": " .. tostring(cfg[state_key]) end
    b.MouseButton1Click:Connect(function() cfg[state_key] = not cfg[state_key]; upd(); if callback then callback(cfg[state_key]) end end)
    upd(); return b
end

local function slider(txt, min, max, state_key)
    local f = Instance.new("Frame", scroll); f.Size = UDim2.new(1, -5, 0, 40); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt..": "..cfg[state_key]; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Font = "Code"
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(1, 0, 0, 15); b.Position = UDim2.new(0,0,0,20); b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.Text = ""; Instance.new("UICorner", b)
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((cfg[state_key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.new(1,0,0); Instance.new("UICorner", fill)
    local drag = false
    b.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end end)
    uis.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    rs.RenderStepped:Connect(function() 
        if drag then 
            local p = math.clamp((uis:GetMouseLocation().X - b.AbsolutePosition.X)/b.AbsoluteSize.X, 0, 1)
            cfg[state_key] = math.floor(min + (p * (max-min))); fill.Size = UDim2.new(p,0,1,0); l.Text = txt..": "..cfg[state_key]
        end 
    end)
end

local function lbl(txt)
    local l = Instance.new("TextLabel", scroll); l.Size = UDim2.new(1, 0, 0, 20); l.Text = " > " .. txt; l.TextColor3 = Color3.new(1,0,0); l.BackgroundTransparency = 1; l.Font = "Code"; l.TextXAlignment = "Left"
end

-- // Menüyü Diz
lbl("COMBAT & REACH")
btn("Stealth Reach (Bypass)", "reach")
btn("Classic Hitbox (Size)", "classic_hb", function(v) if not v then for _,p in pairs(plrs:GetPlayers()) do if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.Size = Vector3.new(2,2,1); p.Character.HumanoidRootPart.Transparency = 1 end end end end)
slider("Hitbox/Reach Size", 5, 50, "reach_dist")
btn("Spinbot", "spin")

lbl("AIMBOT (Hold E)")
btn("Aimbot Master", "aim")
btn("Team Check", "team_chk")
btn("Wall Check", "wall_chk")
local pt_btn = Instance.new("TextButton", scroll); pt_btn.Size = UDim2.new(1, -5, 0, 30); pt_btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); pt_btn.TextColor3 = Color3.new(1,1,1); pt_btn.Font = "Code"; Instance.new("UICorner", pt_btn); pt_btn.Text = "Aim Part: " .. cfg.aim_part
pt_btn.MouseButton1Click:Connect(function() cfg.aim_part = (cfg.aim_part == "Head") and "Torso" or "Head"; pt_btn.Text = "Aim Part: " .. cfg.aim_part end)

lbl("MOVEMENT")
slider("Walk Speed", 16, 250, "spd")
slider("Jump Power", 50, 300, "jmp")
btn("Infinite Jump", "inf_jmp")

lbl("VISUALS & MISC")
btn("Player ESP", "esp", function(v) if not v then for _,p in pairs(plrs:GetPlayers()) do if p.Character and p.Character:FindFirstChild("rz_esp") then p.Character.rz_esp:Destroy() end end end end)
local xray_cache = {}
btn("X-Ray", "xray", function(v)
    if v then for _,o in pairs(workspace:GetDescendants()) do if o:IsA("BasePart") and not o:IsDescendantOf(lp.Character) and not o.Parent:FindFirstChild("Humanoid") then xray_cache[o] = o.Transparency; o.Transparency = 0.6 end end
    else for o, t in pairs(xray_cache) do if o then o.Transparency = t end end; table.clear(xray_cache) end
end)
local s_btn = Instance.new("TextButton", scroll); s_btn.Size = UDim2.new(1, -5, 0, 30); s_btn.BackgroundColor3 = Color3.fromRGB(40, 10, 10); s_btn.TextColor3 = Color3.new(1,1,1); s_btn.Font = "Code"; Instance.new("UICorner", s_btn); s_btn.Text = "Copy rzgr1ks YT/DC"
s_btn.MouseButton1Click:Connect(function() setclipboard("YouTube: rzgr1ks | Discord: rzgr1ks") end)

-- // Aimbot Core
local is_aiming = false
uis.InputBegan:Connect(function(k, gp) if not gp and k.KeyCode == Enum.KeyCode.E then is_aiming = true end end)
uis.InputEnded:Connect(function(k, gp) if not gp and k.KeyCode == Enum.KeyCode.E then is_aiming = false end end)

local function get_aim()
    local t, d = nil, math.huge
    local m = uis:GetMouseLocation()
    for _, p in pairs(plrs:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild(cfg.aim_part) and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if cfg.team_chk and p.Team == lp.Team then continue end
            local pos, vis = cam:WorldToViewportPoint(p.Character[cfg.aim_part].Position)
            if vis then
                if cfg.wall_chk then
                    local ray = RaycastParams.new(); ray.FilterDescendantsInstances = {lp.Character, p.Character}; ray.FilterType = Enum.RaycastFilterType.Exclude
                    if workspace:Raycast(cam.CFrame.Position, (p.Character[cfg.aim_part].Position - cam.CFrame.Position).Unit * 1000, ray) then continue end
                end
                local dist = (Vector2.new(pos.X, pos.Y) - m).Magnitude
                if dist < d then t = p.Character[cfg.aim_part]; d = dist end
            end
        end
    end
    return t
end

-- // Main Loop
rs.RenderStepped:Connect(function()
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if hum then hum.WalkSpeed = cfg.spd; hum.JumpPower = cfg.jmp end
    
    if cfg.aim and is_aiming then
        local targ = get_aim()
        if targ then cam.CFrame = CFrame.new(cam.CFrame.Position, targ.Position) end
    end
    
    for _, p in pairs(plrs:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local e_hrp = p.Character.HumanoidRootPart
            
            if cfg.classic_hb then
                e_hrp.Size = Vector3.new(cfg.reach_dist, cfg.reach_dist, cfg.reach_dist)
                e_hrp.Transparency = 0.7; e_hrp.CanCollide = false
            end
            
            if cfg.reach then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") and hrp and (hrp.Position - e_hrp.Position).Magnitude <= cfg.reach_dist then
                    firetouchinterest(e_hrp, tool.Handle, 0); firetouchinterest(e_hrp, tool.Handle, 1)
                end
            end
            
            if cfg.esp and not p.Character:FindFirstChild("rz_esp") then
                local hl = Instance.new("Highlight", p.Character); hl.Name = "rz_esp"; hl.FillColor = Color3.new(1,0,0)
            end
        end
    end
    
    if cfg.spin and hrp then hrp.AssemblyAngularVelocity = Vector3.new(0, cfg.spin_spd, 0) end
end)

-- Mobile Auto Proximity (E)
rs.Heartbeat:Connect(function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and lp.Character and lp.Character.PrimaryPart and (lp.Character.PrimaryPart.Position - obj.Parent.Position).Magnitude < obj.MaxActivationDistance then
            fireproximityprompt(obj)
        end
    end
end)

uis.JumpRequest:Connect(function() if cfg.inf_jmp and lp.Character then lp.Character:FindFirstChild("Humanoid"):ChangeState(3) end end)
