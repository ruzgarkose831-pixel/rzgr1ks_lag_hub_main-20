--[[ 
    rzgr1ks duels v15 - THE CONFIG SAVER
    - Added Save/Load Config (writefile/readfile)
    - Auto-Updates UI on Load
    - All previous Mobile & Silent Aim Fixes included
]]--

if not game:IsLoaded() then task.wait() end

local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local http = game:GetService("HttpService")
local lp = plrs.LocalPlayer
local cam = workspace.CurrentCamera

-- // CONFIGURATION
local cfg = {
    lang = "TR",
    aim = false, silent_aim = true, auto_click = false,
    reach = false, reach_dist = 15, classic_hb = false,
    team_chk = true, wall_chk = false, aim_part = "HumanoidRootPart",
    spd = 16, jmp = 50, grav = 196.2, inf_jmp = false,
    spin = false, spin_spd = 100,
    esp = false, xray = false, menu_open = true
}

local file_name = "rzgr1ks_config.json"
local updaters = {} -- UI'ı güncellemek için
local is_aiming = false

-- // LANGUAGE SYSTEM
local msg = {
    TR = {
        title = "rzgr1ks v15 | FULL + CONFIG",
        lang = "Dili Değiştir (TR/EN)",
        c_aim = "Aimbot Kilit", c_silent = "Sessiz Kilit (Kamera Dönmez)", c_auto = "Oto Vuruş (Kesin İsabet)",
        c_reach = "Stealth Menzil", c_hb = "Klasik Hitbox", c_dist = "Menzil Boyutu",
        m_spd = "Hız", m_jmp = "Zıplama", m_grav = "Yerçekimi", m_inf = "Sınırsız Zıplama",
        m_spin = "Spinbot", m_spinspd = "Spin Hızı",
        v_esp = "Oyuncu ESP", v_xray = "Yapı X-Ray",
        cfg_save = "Ayarları Kaydet", cfg_load = "Ayarları Yükle",
        s_yt = "YouTube: rzgr1ks", s_dc = "Discord Sunucusu",
        on = "AÇIK", off = "KAPALI"
    },
    EN = {
        title = "rzgr1ks v15 | FULL + CONFIG",
        lang = "Change Language (TR/EN)",
        c_aim = "Aimbot Master", c_silent = "Silent Aim (No Cam Move)", c_auto = "Auto Attack (Sure Hit)",
        c_reach = "Stealth Reach", c_hb = "Classic Hitbox", c_dist = "Reach/Hitbox Size",
        m_spd = "Walk Speed", m_jmp = "Jump Power", m_grav = "Gravity", m_inf = "Infinite Jump",
        m_spin = "Spinbot", m_spinspd = "Spin Speed",
        v_esp = "Player ESP", v_xray = "Structure X-Ray",
        cfg_save = "Save Config", cfg_load = "Load Config",
        s_yt = "YouTube: rzgr1ks", s_dc = "Discord Server",
        on = "ON", off = "OFF"
    }
}

local function getMsg(key) return msg[cfg.lang][key] end

-- // CONFIG SAVE/LOAD FUNCTIONS
local function saveConfig()
    if writefile then
        local success, encoded = pcall(function() return http:JSONEncode(cfg) end)
        if success then writefile(file_name, encoded) end
    end
end

local function loadConfig()
    if isfile and isfile(file_name) and readfile then
        local success, decoded = pcall(function() return http:JSONDecode(readfile(file_name)) end)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                if cfg[k] ~= nil then cfg[k] = v end
            end
            -- UI'ı yeni ayarlara göre güncelle
            for _, f in ipairs(updaters) do f() end
        end
    end
end

-- // UI SETUP
local gui = Instance.new("ScreenGui", (gethui and gethui()) or lp.PlayerGui)
gui.Name = "rz_v15_final"

-- // MOBILE LOCK BUTTON (Press and Hold)
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
bg.Size = UDim2.new(0, 320, 0, 500); bg.Position = UDim2.new(0.1, 0, 0.2, 0)
bg.BackgroundColor3 = Color3.fromRGB(15, 15, 15); bg.Active = true; bg.Draggable = true; bg.ClipsDescendants = true
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)

local minBtn = Instance.new("TextButton", bg)
minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(1, -35, 0, 5)
minBtn.Text = "-"; minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); minBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", minBtn)

local top = Instance.new("TextLabel", bg)
top.Size = UDim2.new(1, 0, 0, 40); top.Text = getMsg("title"); top.TextColor3 = Color3.new(1,0,0); top.Font = "Code"; top.TextSize = 16; top.BackgroundTransparency = 1
table.insert(updaters, function() top.Text = getMsg("title") end)

local scroll = Instance.new("ScrollingFrame", bg)
scroll.Size = UDim2.new(1, -10, 1, -50); scroll.Position = UDim2.new(0, 5, 0, 45); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 2; scroll.AutomaticCanvasSize = "Y"
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

minBtn.MouseButton1Click:Connect(function()
    cfg.menu_open = not cfg.menu_open
    ts:Create(bg, TweenInfo.new(0.3), {Size = cfg.menu_open and UDim2.new(0, 320, 0, 500) or UDim2.new(0, 320, 0, 40)}):Play()
    minBtn.Text = cfg.menu_open and "-" or "+"
end)

-- // UI ELEMENTS BUILDER
local function btn(txtKey, state_key, callback)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, -10, 0, 35); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.TextColor3 = Color3.new(1,1,1); b.Font = "Code"; b.TextSize = 14
    Instance.new("UICorner", b)
    local function upd() 
        b.Text = getMsg(txtKey) .. ": " .. (cfg[state_key] and getMsg("on") or getMsg("off"))
        if state_key == "aim" then lockBtn.Visible = cfg.aim end
    end
    table.insert(updaters, upd)
    b.MouseButton1Click:Connect(function() cfg[state_key] = not cfg[state_key]; upd(); if callback then callback(cfg[state_key]) end end)
    upd()
end

local function slider(txtKey, min, max, state_key)
    local f = Instance.new("Frame", scroll); f.Size = UDim2.new(1, -10, 0, 45); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = getMsg(txtKey)..": "..cfg[state_key]; l.TextColor3 = Color3.new(1,1,1); l.Font = "Code"; l.BackgroundTransparency = 1
    local b = Instance.new("Frame", f); b.Size = UDim2.new(1, 0, 0, 10); b.Position = UDim2.new(0,0,0,25); b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((cfg[state_key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.new(1,0,0)
    
    local function upd() 
        l.Text = getMsg(txtKey)..": "..cfg[state_key] 
        fill.Size = UDim2.new((cfg[state_key]-min)/(max-min), 0, 1, 0)
    end
    table.insert(updaters, upd)
    
    local function update_slider()
        local rel = math.clamp((uis:GetMouseLocation().X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (rel * (max - min)))
        cfg[state_key] = val; upd()
    end
    local dragging = false
    b.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    uis.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    rs.RenderStepped:Connect(function() if dragging then update_slider() end end)
    upd()
end

local function lbl(txt)
    local l = Instance.new("TextLabel", scroll); l.Size = UDim2.new(1, 0, 0, 20); l.Text = "-- " .. txt .. " --"; l.TextColor3 = Color3.new(0.6, 0.6, 0.6); l.Font = "Code"; l.BackgroundTransparency = 1
end

-- // LANGUAGE TOGGLE
local langBtn = Instance.new("TextButton", scroll)
langBtn.Size = UDim2.new(1, -10, 0, 35); langBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); langBtn.TextColor3 = Color3.new(1,1,1); langBtn.Font = "Code"
Instance.new("UICorner", langBtn)
local function updateLangBtn() langBtn.Text = getMsg("lang") end
table.insert(updaters, updateLangBtn)
langBtn.MouseButton1Click:Connect(function()
    cfg.lang = (cfg.lang == "TR") and "EN" or "TR"
    for _, f in ipairs(updaters) do f() end
end)
updateLangBtn()

-- // FEATURES
lbl("COMBAT & AIM")
btn("c_aim", "aim")
btn("c_silent", "silent_aim")
btn("c_auto", "auto_click")
btn("c_reach", "reach")
btn("c_hb", "classic_hb")
slider("c_dist", 5, 100, "reach_dist")

lbl("MOVEMENT")
slider("m_spd", 16, 300, "spd")
slider("m_jmp", 50, 400, "jmp")
slider("m_grav", 0, 500, "grav")
btn("m_inf", "inf_jmp")
btn("m_spin", "spin")
slider("m_spinspd", 0, 500, "spin_spd")

lbl("VISUALS")
btn("v_esp", "esp", function(v) if not v then for _,p in pairs(plrs:GetPlayers()) do if p.Character and p.Character:FindFirstChild("rz_esp") then p.Character.rz_esp:Destroy() end end end end)

local xray_cache = {}
btn("v_xray", "xray", function(v)
    if v then
        for _,o in pairs(workspace:GetDescendants()) do
            if o:IsA("BasePart") and not o:IsA("Terrain") and not o:IsDescendantOf(lp.Character) and not o.Parent:FindFirstChild("Humanoid") then
                if not xray_cache[o] then xray_cache[o] = o.Transparency end
                o.Transparency = 0.5
            end
        end
    else
        for o, trans in pairs(xray_cache) do if o then o.Transparency = trans end end
        table.clear(xray_cache)
    end
end)

lbl("CONFIG")
local saveBtn = Instance.new("TextButton", scroll); saveBtn.Size = UDim2.new(1, -10, 0, 35); saveBtn.BackgroundColor3 = Color3.new(0, 0.6, 0); saveBtn.TextColor3 = Color3.new(1,1,1); saveBtn.Font = "Code"; Instance.new("UICorner", saveBtn)
local loadBtn = Instance.new("TextButton", scroll); loadBtn.Size = UDim2.new(1, -10, 0, 35); loadBtn.BackgroundColor3 = Color3.new(0.6, 0.4, 0); loadBtn.TextColor3 = Color3.new(1,1,1); loadBtn.Font = "Code"; Instance.new("UICorner", loadBtn)

local function updCfgBtns() saveBtn.Text = getMsg("cfg_save"); loadBtn.Text = getMsg("cfg_load") end
table.insert(updaters, updCfgBtns); updCfgBtns()

saveBtn.MouseButton1Click:Connect(function() saveConfig(); saveBtn.Text = "SAVED!"; task.wait(1); updCfgBtns() end)
loadBtn.MouseButton1Click:Connect(function() loadConfig(); loadBtn.Text = "LOADED!"; task.wait(1); updCfgBtns() end)

lbl("SOCIALS")
local yt = Instance.new("TextButton", scroll); yt.Size = UDim2.new(1, -10, 0, 35); yt.BackgroundColor3 = Color3.new(0.8, 0, 0); yt.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", yt)
local dc = Instance.new("TextButton", scroll); dc.Size = UDim2.new(1, -10, 0, 35); dc.BackgroundColor3 = Color3.new(0, 0.4, 1); dc.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", dc)
local function updSoc() yt.Text = getMsg("s_yt"); dc.Text = getMsg("s_dc") end
table.insert(updaters, updSoc); updSoc()
yt.MouseButton1Click:Connect(function() setclipboard("https://youtube.com/@rzgr1ks") end)
dc.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/rzgr1ks") end)

-- // AIMBOT ENGINE (FIXED FOR SILENT HIT REGISTRATION)
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
        
        hum.UseJumpPower = true
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
                    cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target.Position)
                end
                
                if cfg.auto_click then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then 
                        tool:Activate()
                        if tool:FindFirstChild("Handle") then
                            firetouchinterest(target, tool.Handle, 0)
                            firetouchinterest(target, tool.Handle, 1)
                        end
                    end
                end
            end
        end
        
        for _, p in pairs(plrs:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local e_hrp = p.Character.HumanoidRootPart
                
                if cfg.reach then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") and (hrp.Position - e_hrp.Position).Magnitude <= cfg.reach_dist then
                        firetouchinterest(e_hrp, tool.Handle, 0); firetouchinterest(e_hrp, tool.Handle, 1)
                    end
                end
                
                if cfg.classic_hb then
                    e_hrp.Size = Vector3.new(cfg.reach_dist, cfg.reach_dist, cfg.reach_dist)
                    e_hrp.Transparency = 0.7; e_hrp.CanCollide = false
                else
                    if e_hrp.Size.X > 5 then e_hrp.Size = Vector3.new(2, 2, 1); e_hrp.Transparency = 1; e_hrp.CanCollide = true end
                end
                
                if cfg.esp and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    if not p.Character:FindFirstChild("rz_esp") then Instance.new("Highlight", p.Character).Name = "rz_esp" end
                end
            end
        end
        
        if cfg.spin then hrp.AssemblyAngularVelocity = Vector3.new(0, cfg.spin_spd, 0) end
    end
end)

uis.JumpRequest:Connect(function() if cfg.inf_jmp and lp.Character then lp.Character.Humanoid:ChangeState(3) end end)
