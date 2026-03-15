--[[ 
    rzgr1ks duels v16 - TABBED UI & NEW CAMLOCK
    - Old Aimbot/Silent Aim Deleted.
    - Added Universal Mobile Camlock (from web sources).
    - Features separated into Tabs (Combat, Movement, Visuals, Config).
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
    aim = false, reach = false, reach_dist = 15, hb_expander = false,
    spd = 16, jmp = 50, grav = 196.2, inf_jmp = false, spin = false, spin_spd = 100,
    esp = false, xray = false, menu_open = true
}

local locked_target = nil -- Yeni Aimbot için kilitlenen hedef
local file_name = "rzgr1ks_config.json"
local updaters = {}

-- // UI SETUP
local gui = Instance.new("ScreenGui", (gethui and gethui()) or lp.PlayerGui)
gui.Name = "rz_v16_tabs"

-- // NEW MOBILE CAMLOCK BUTTON (Toggle Mode)
local lockBtn = Instance.new("TextButton", gui)
lockBtn.Size = UDim2.new(0, 65, 0, 65); lockBtn.Position = UDim2.new(0.7, 0, 0.4, 0)
lockBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0); lockBtn.BackgroundTransparency = 0.4
lockBtn.Text = "LOCK"; lockBtn.TextColor3 = Color3.new(1,1,1); lockBtn.Font = "Code"; lockBtn.TextSize = 16
Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(1, 0)
lockBtn.Active = true; lockBtn.Draggable = true; lockBtn.Visible = false

-- // MAIN MENU CONTAINER
local bg = Instance.new("Frame", gui)
bg.Size = UDim2.new(0, 320, 0, 420); bg.Position = UDim2.new(0.1, 0, 0.2, 0)
bg.BackgroundColor3 = Color3.fromRGB(15, 15, 15); bg.Active = true; bg.Draggable = true; bg.ClipsDescendants = true
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)

local top = Instance.new("TextLabel", bg)
top.Size = UDim2.new(1, -40, 0, 35); top.Text = " rzgr1ks v16 | TABS"; top.TextColor3 = Color3.new(1,0,0); top.Font = "Code"; top.TextXAlignment = Enum.TextXAlignment.Left; top.BackgroundTransparency = 1

local minBtn = Instance.new("TextButton", bg)
minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(1, -35, 0, 2)
minBtn.Text = "-"; minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); minBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", minBtn)

minBtn.MouseButton1Click:Connect(function()
    cfg.menu_open = not cfg.menu_open
    ts:Create(bg, TweenInfo.new(0.3), {Size = cfg.menu_open and UDim2.new(0, 320, 0, 420) or UDim2.new(0, 320, 0, 35)}):Play()
    minBtn.Text = cfg.menu_open and "-" or "+"
end)

-- // TAB SYSTEM
local tabContainer = Instance.new("Frame", bg)
tabContainer.Size = UDim2.new(1, -10, 0, 35); tabContainer.Position = UDim2.new(0, 5, 0, 35)
tabContainer.BackgroundTransparency = 1
local tabLayout = Instance.new("UIListLayout", tabContainer)
tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.Padding = UDim.new(0, 5)

local pages = {}
local tabBtns = {}

local function createTab(name, isFirst)
    local btn = Instance.new("TextButton", tabContainer)
    btn.Size = UDim2.new(0, 70, 1, 0); btn.BackgroundColor3 = isFirst and Color3.new(0.6,0,0) or Color3.fromRGB(30,30,30)
    btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); btn.Font = "Code"; btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local page = Instance.new("ScrollingFrame", bg)
    page.Size = UDim2.new(1, -10, 1, -80); page.Position = UDim2.new(0, 5, 0, 75)
    page.BackgroundTransparency = 1; page.ScrollBarThickness = 2; page.AutomaticCanvasSize = "Y"
    page.Visible = isFirst
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 5)
    
    pages[name] = page
    tabBtns[name] = btn
    
    btn.MouseButton1Click:Connect(function()
        for k, v in pairs(pages) do v.Visible = (k == name) end
        for k, v in pairs(tabBtns) do v.BackgroundColor3 = (k == name) and Color3.new(0.6,0,0) or Color3.fromRGB(30,30,30) end
    end)
    return page
end

local tabCombat = createTab("Combat", true)
local tabMove = createTab("Move", false)
local tabVisual = createTab("Visual", false)
local tabCfg = createTab("Config", false)

-- // UI BUILDERS
local function createToggle(parent, txt, state_key, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -5, 0, 35); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.TextColor3 = Color3.new(1,1,1); b.Font = "Code"; b.TextSize = 14
    Instance.new("UICorner", b)
    local function upd() 
        b.Text = txt .. ": " .. (cfg[state_key] and "ON" or "OFF")
        if state_key == "aim" then lockBtn.Visible = cfg.aim; if not cfg.aim then locked_target = nil; lockBtn.Text = "LOCK"; lockBtn.BackgroundColor3 = Color3.fromRGB(200,0,0) end end
    end
    table.insert(updaters, upd)
    b.MouseButton1Click:Connect(function() cfg[state_key] = not cfg[state_key]; upd(); if callback then callback(cfg[state_key]) end end)
    upd()
end

local function createSlider(parent, txt, min, max, state_key)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, -5, 0, 45); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.Text = txt..": "..cfg[state_key]; l.TextColor3 = Color3.new(1,1,1); l.Font = "Code"; l.BackgroundTransparency = 1
    local b = Instance.new("Frame", f); b.Size = UDim2.new(1, 0, 0, 10); b.Position = UDim2.new(0,0,0,25); b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((cfg[state_key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.new(1,0,0)
    
    local function upd() l.Text = txt..": "..cfg[state_key]; fill.Size = UDim2.new((cfg[state_key]-min)/(max-min), 0, 1, 0) end
    table.insert(updaters, upd)
    
    local dragging = false
    b.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    uis.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    rs.RenderStepped:Connect(function()
        if dragging then
            local rel = math.clamp((uis:GetMouseLocation().X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
            cfg[state_key] = math.floor(min + (rel * (max - min))); upd()
        end
    end)
    upd()
end

-- // POPULATE TABS
-- Combat Tab
createToggle(tabCombat, "Camlock Aimbot", "aim")
createToggle(tabCombat, "Hitbox Expander", "hb_expander")
createToggle(tabCombat, "Stealth Reach", "reach")
createSlider(tabCombat, "Hitbox/Reach Size", 5, 100, "reach_dist")

-- Movement Tab
createSlider(tabMove, "Walk Speed", 16, 300, "spd")
createSlider(tabMove, "Jump Power", 50, 400, "jmp")
createSlider(tabMove, "Gravity", 0, 500, "grav")
createToggle(tabMove, "Infinite Jump", "inf_jmp")
createToggle(tabMove, "Spinbot", "spin")
createSlider(tabMove, "Spin Speed", 0, 500, "spin_spd")

-- Visuals Tab
createToggle(tabVisual, "Player ESP", "esp", function(v) if not v then for _,p in pairs(plrs:GetPlayers()) do if p.Character and p.Character:FindFirstChild("rz_esp") then p.Character.rz_esp:Destroy() end end end end)
local xray_cache = {}
createToggle(tabVisual, "X-Ray", "xray", function(v)
    if v then
        for _,o in pairs(workspace:GetDescendants()) do
            if o:IsA("BasePart") and not o:IsA("Terrain") and not o:IsDescendantOf(lp.Character) and not o.Parent:FindFirstChild("Humanoid") then
                if not xray_cache[o] then xray_cache[o] = o.Transparency end
                o.Transparency = 0.5
            end
        end
    else
        for o, trans in pairs(xray_cache) do if o then o.Transparency = trans end end; table.clear(xray_cache)
    end
end)

-- Config Tab
local saveBtn = Instance.new("TextButton", tabCfg); saveBtn.Size = UDim2.new(1, -5, 0, 35); saveBtn.BackgroundColor3 = Color3.new(0, 0.6, 0); saveBtn.TextColor3 = Color3.new(1,1,1); saveBtn.Text = "Save Config"; saveBtn.Font = "Code"; Instance.new("UICorner", saveBtn)
local loadBtn = Instance.new("TextButton", tabCfg); loadBtn.Size = UDim2.new(1, -5, 0, 35); loadBtn.BackgroundColor3 = Color3.new(0.6, 0.4, 0); loadBtn.TextColor3 = Color3.new(1,1,1); loadBtn.Text = "Load Config"; loadBtn.Font = "Code"; Instance.new("UICorner", loadBtn)

saveBtn.MouseButton1Click:Connect(function() if writefile then pcall(function() writefile(file_name, http:JSONEncode(cfg)) end); saveBtn.Text = "SAVED!"; task.wait(1); saveBtn.Text = "Save Config" end end)
loadBtn.MouseButton1Click:Connect(function() 
    if isfile and isfile(file_name) and readfile then 
        local s, d = pcall(function() return http:JSONDecode(readfile(file_name)) end)
        if s and type(d) == "table" then for k,v in pairs(d) do if cfg[k] ~= nil then cfg[k] = v end end; for _,f in ipairs(updaters) do f() end; loadBtn.Text = "LOADED!"; task.wait(1); loadBtn.Text = "Load Config" end
    end 
end)

-- // NEW AIMBOT LOGIC (CAMLOCK)
local function get_closest_to_center()
    local t, d = nil, math.huge
    for _, p in pairs(plrs:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local pos, vis = cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if vis then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                if dist < d then t = p.Character.HumanoidRootPart; d = dist end
            end
        end
    end
    return t
end

-- Aimbot Butonuna Tıklayınca Kilitle / Çöz
lockBtn.MouseButton1Click:Connect(function()
    if locked_target then
        locked_target = nil -- Kilidi aç
        lockBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        lockBtn.Text = "LOCK"
    else
        locked_target = get_closest_to_center() -- Ekranın ortasına en yakın olanı bul ve kilitle
        if locked_target then
            lockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            lockBtn.Text = "UNLK"
        end
    end
end)

-- // CORE ENGINE
rs.RenderStepped:Connect(function()
    local char = lp.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        local hrp = char.HumanoidRootPart
        
        hum.UseJumpPower = true
        hum.WalkSpeed = cfg.spd
        hum.JumpPower = cfg.jmp
        workspace.Gravity = cfg.grav
        
        -- CAMLOCK EXECUTION
        if cfg.aim and locked_target then
            if locked_target.Parent and locked_target.Parent:FindFirstChild("Humanoid") and locked_target.Parent.Humanoid.Health > 0 then
                -- Kamerayı pürüzsüz bir şekilde hedefe kilitler
                cam.CFrame = CFrame.lookAt(cam.CFrame.Position, locked_target.Position)
            else
                -- Adam ölürse veya oyundan çıkarsa kilidi otomatik bırak
                locked_target = nil
                lockBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                lockBtn.Text = "LOCK"
            end
        end
        
        -- Hitbox, Reach & ESP Loop
        for _, p in pairs(plrs:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local e_hrp = p.Character.HumanoidRootPart
                
                -- Hitbox Expander
                if cfg.hb_expander then
                    e_hrp.Size = Vector3.new(cfg.reach_dist, cfg.reach_dist, cfg.reach_dist)
                    e_hrp.Transparency = 0.7; e_hrp.CanCollide = false
                else
                    if e_hrp.Size.X > 5 then e_hrp.Size = Vector3.new(2, 2, 1); e_hrp.Transparency = 1; e_hrp.CanCollide = true end
                end
                
                -- Reach
                if cfg.reach then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") and (hrp.Position - e_hrp.Position).Magnitude <= cfg.reach_dist then
                        firetouchinterest(e_hrp, tool.Handle, 0); firetouchinterest(e_hrp, tool.Handle, 1)
                    end
                end
                
                -- ESP
                if cfg.esp and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    if not p.Character:FindFirstChild("rz_esp") then Instance.new("Highlight", p.Character).Name = "rz_esp" end
                end
            end
        end
        
        if cfg.spin then hrp.AssemblyAngularVelocity = Vector3.new(0, cfg.spin_spd, 0) end
    end
end)

uis.JumpRequest:Connect(function() if cfg.inf_jmp and lp.Character then lp.Character.Humanoid:ChangeState(3) end end)
