--========================================================================
-- LIGHT HUB - COMBINED (Intro GUI + Speed/MultiJump + Walkfling Drop)
-- Sadece LocalPlayer'ı etkiler, diğer oyuncuları etkilemez.
-- Speed Boost: VectorForce yöntemi (koddaki stabil versiyon)
--========================================================================

-- Servisleri Al
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Hata yutma: bir özellik patlasa script devam eder
local function safeCall(fn, ...)
    if type(fn) ~= "function" then return false end
    local ok, err = pcall(fn, ...)
    if not ok then
        warn("[LightHub] skipped:", tostring(err))
    end
    return ok
end

-- Eski executor / ortam uyumu
if not math.clamp then
    function math.clamp(n, min, max)
        if n < min then return min end
        if n > max then return max end
        return n
    end
end
if typeof == nil then
    function typeof(v)
        local t = type(v)
        if t == "userdata" then
            local ok, cn = pcall(function() return v.ClassName end)
            if ok and cn then return cn end
        end
        return t
    end
end
if getgenv == nil then
    getgenv = function() return _G end
end

-- Dosya Adı (buton pozisyonları)
local SaveFileName = "LightHub_ButtonPositions_v17.json"

-- Konum Yükleme
local function LoadPositions()
    if writefile and readfile and pcall(function() readfile(SaveFileName) end) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(SaveFileName)) end)
        if success and data then return data end
    end
    return {}
end

local savedPositions = LoadPositions()
local function SavePosition(btnName, position)
    savedPositions[btnName] = {
        ScaleX = position.X.Scale, OffsetX = position.X.Offset,
        ScaleY = position.Y.Scale, OffsetY = position.Y.Offset
    }
    if writefile then pcall(function() writefile(SaveFileName, HttpService:JSONEncode(savedPositions)) end) end
end

--========================================================================
-- [ CONFIG & SAVE SYSTEM ]
--========================================================================
getgenv().LightHubConfig = getgenv().LightHubConfig or {
    SpeedBoostEnabled = true,
    NormalSpeed = 60,
    StealSpeed = 30,          -- Carry Speed değeri
    LaggerSpeed = 15.1,
    LaggerSteal = 10.1,       -- Lagger Carry değeri
    MultiJumpEnabled = false,
    SpeedMode = "normal",     -- "normal" | "carry" | "lagger" | "lagger_carry"
    BatAimbotEnabled = false,
    BatAimbotSpeed = 65,
    ConsoleMode = false,
    PCKeybindsEnabled = false,
    Keybinds = {
        ["Auto Left"] = "DPadLeft",
        ["Auto Right"] = "DPadRight",
        ["Tp down"] = "DPadDown",
        ["Bat Aimbot"] = "ButtonB",
        ["Carry Speed"] = "ButtonL3",
        ["Reset"] = "ButtonY",
        ["Lagger Speed"] = "ButtonR3",
        ["Drop Brainrot"] = "ButtonX",
    },
    PCKeybinds = {
        ["Auto Left"] = "L",
        ["Auto Right"] = "R",
        ["Drop Brainrot"] = "K",
        ["Reset"] = "T",
        ["Bat Aimbot"] = "B",
        ["Tp down"] = "Q",
        ["Carry Speed"] = "C",
        ["Lagger Speed"] = "J",
        ["Lagger Steal"] = "G",
    },
    IntroEnabled = true,
    IntroSongIndex = 1,
    UiBackgroundIndex = 1,
    UiColorIndex = 1, -- 1 Black, 2 Blue, 3 Green, 4 Pink, 5 White
}

local CONFIG_FILE = "LightHubConfig_v6.json"

local function SaveConfig()
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(getgenv().LightHubConfig))
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile and isfile(CONFIG_FILE) then
            local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
            for k, v in pairs(data) do
                if getgenv().LightHubConfig[k] ~= nil then
                    getgenv().LightHubConfig[k] = v
                end
            end
        else
            SaveConfig()
        end
    end)
    -- Nested tablolar her zaman dolu olsun
    getgenv().LightHubConfig.Keybinds = getgenv().LightHubConfig.Keybinds or {
        ["Auto Left"] = "DPadLeft", ["Auto Right"] = "DPadRight",
        ["Tp down"] = "DPadDown", ["Bat Aimbot"] = "ButtonB",
        ["Carry Speed"] = "ButtonL3", ["Reset"] = "ButtonY",
        ["Lagger Speed"] = "ButtonR3", ["Drop Brainrot"] = "ButtonX",
    }
    -- Drop Brainrot console key yoksa ekle
    if not getgenv().LightHubConfig.Keybinds["Drop Brainrot"] then
        getgenv().LightHubConfig.Keybinds["Drop Brainrot"] = "ButtonX"
    end
    getgenv().LightHubConfig.PCKeybinds = getgenv().LightHubConfig.PCKeybinds or {
        ["Auto Left"] = "L", ["Auto Right"] = "R", ["Drop Brainrot"] = "K",
        ["Reset"] = "T", ["Bat Aimbot"] = "B", ["Tp down"] = "Q",
        ["Carry Speed"] = "C", ["Lagger Speed"] = "J", ["Lagger Steal"] = "G",
    }
    -- Eski kayıtlarda D ise K yap
    if getgenv().LightHubConfig.PCKeybinds["Drop Brainrot"] == "D" then
        getgenv().LightHubConfig.PCKeybinds["Drop Brainrot"] = "K"
    end
    if getgenv().LightHubConfig.IntroEnabled == nil then
        getgenv().LightHubConfig.IntroEnabled = true
    end
    if not getgenv().LightHubConfig.IntroSongIndex then
        getgenv().LightHubConfig.IntroSongIndex = 1
    end
end
LoadConfig()

--========================================================================
-- [ SPEED BOOST (VectorForce) - STABİL YÖNTEM ]
-- Verdiğin koddaki VectorForce mantığı + SpeedMode desteği
-- Sadece LocalPlayer etkilenir.
--========================================================================
local currentBoostConnection = nil

local function getTargetSpeed()
    local cfg = getgenv().LightHubConfig
    local mode = cfg.SpeedMode or "normal"
    if mode == "carry" then
        return cfg.StealSpeed
    elseif mode == "lagger" then
        return cfg.LaggerSpeed
    elseif mode == "lagger_carry" then
        return cfg.LaggerSteal
    else
        return cfg.NormalSpeed
    end
end

local function setupBoost(character)
    if not character then return end
    local rootPart = character:WaitForChild("HumanoidRootPart", 5)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not rootPart or not humanoid then return end

    -- Eski force/attachment temizle
    if rootPart:FindFirstChild("LH_Attachment") then rootPart.LH_Attachment:Destroy() end
    if rootPart:FindFirstChild("LH_VectorForce") then rootPart.LH_VectorForce:Destroy() end
    if currentBoostConnection then
        currentBoostConnection:Disconnect()
        currentBoostConnection = nil
    end

    local attachment = Instance.new("Attachment")
    attachment.Name = "LH_Attachment"
    attachment.Parent = rootPart

    local vectorForce = Instance.new("VectorForce")
    vectorForce.Name = "LH_VectorForce"
    vectorForce.Attachment0 = attachment
    vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
    vectorForce.Force = Vector3.zero
    vectorForce.Parent = rootPart

    currentBoostConnection = RunService.RenderStepped:Connect(function()
        local ok, err = pcall(function()
            if not vectorForce or not vectorForce.Parent then return end
            -- Bat aimbot açıkken normal speed karışmasın
            if getgenv().LightHubConfig.BatAimbotEnabled then
                vectorForce.Force = Vector3.zero
                return
            end

            if not getgenv().LightHubConfig.SpeedBoostEnabled or not rootPart:IsDescendantOf(workspace) or not humanoid.Parent then
                vectorForce.Force = Vector3.zero
                return
            end

            local moveDir = humanoid.MoveDirection
            local targetSpeed = tonumber(getTargetSpeed()) or 16
            if targetSpeed < 0 then targetSpeed = 0 end

            -- WalkSpeed sadece okunur, asla değiştirilmez (oyun bazen değiştirir)
            local ws = humanoid.WalkSpeed
            if type(ws) ~= "number" or ws ~= ws or ws < 0 then
                ws = 16
            end

            if moveDir.Magnitude < 0.05 then
                vectorForce.Force = Vector3.zero
                return
            end

            local currentVel = rootPart.AssemblyLinearVelocity
            local currentHorizVel = Vector3.new(currentVel.X, 0, currentVel.Z)
            local speed = currentHorizVel.Magnitude

            -- Hedef mutlak hız = config değeri (WalkSpeed ile toplanmaz)
            if speed >= targetSpeed then
                vectorForce.Force = Vector3.zero
                return
            end

            -- VectorForce yöntemi aynı; kuvvet WalkSpeed'e göre ölçeklenir
            local gap = targetSpeed - speed
            local wsFactor = 1
            if targetSpeed > 0 then
                wsFactor = math.clamp(1 - (math.min(ws, targetSpeed) / targetSpeed) * 0.4, 0.45, 1)
            end
            local nearFactor = math.clamp(gap / math.max(targetSpeed * 0.2, 4), 0.25, 1)
            local forceMul = 1200 * wsFactor * nearFactor

            vectorForce.Force = Vector3.new(moveDir.X, 0, moveDir.Z) * forceMul
        end)
        if not ok then
            pcall(function() if vectorForce then vectorForce.Force = Vector3.zero end end)
        end
    end)
end

--========================================================================
-- [ BAT AIMBOT ] - En yakındaki oyuncuya VectorForce ile git
-- 2 blok yukarıda kal, yatay 3 blokta dur
--========================================================================
local batAimbotConn = nil
local batAimbotForce = nil
local batAimbotAtt = nil

local function getNearestPlayerRoot()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local d = (root.Position - myRoot.Position).Magnitude
                if d < nearestDist then
                    nearestDist = d
                    nearest = root
                end
            end
        end
    end
    return nearest
end

local function ensureBatForce(root)
    if batAimbotAtt and batAimbotAtt.Parent == root and batAimbotForce and batAimbotForce.Parent == root then
        return
    end
    if batAimbotAtt then pcall(function() batAimbotAtt:Destroy() end) end
    if batAimbotForce then pcall(function() batAimbotForce:Destroy() end) end
    batAimbotAtt = Instance.new("Attachment")
    batAimbotAtt.Name = "LH_BatAimbotAtt"
    batAimbotAtt.Parent = root
    batAimbotForce = Instance.new("VectorForce")
    batAimbotForce.Name = "LH_BatAimbotForce"
    batAimbotForce.Attachment0 = batAimbotAtt
    batAimbotForce.RelativeTo = Enum.ActuatorRelativeTo.World
    batAimbotForce.Force = Vector3.zero
    batAimbotForce.Parent = root
end

local batEquipConn = nil

local function useBatTool()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        -- Karakterde veya backpack'te "bat" ara (case-insensitive)
        local function findBat(container)
            if not container then return nil end
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") and string.lower(item.Name):find("bat", 1, true) then
                    return item
                end
            end
            return nil
        end
        local bat = findBat(char) or findBat(LocalPlayer:FindFirstChild("Backpack"))
        if not bat then return end
        if bat.Parent ~= char then
            hum:EquipTool(bat)
        end
        -- Kullan / aktif et
        pcall(function()
            bat:Activate()
        end)
    end)
end

local function stopBatAimbot()
    if batAimbotConn then
        batAimbotConn:Disconnect()
        batAimbotConn = nil
    end
    if batEquipConn then
        batEquipConn:Disconnect()
        batEquipConn = nil
    end
    if batAimbotForce then
        pcall(function() batAimbotForce.Force = Vector3.zero end)
    end
end

local function startBatAimbot()
    stopBatAimbot()
    -- Her saniye bat al ve kullan
    batEquipConn = RunService.Heartbeat:Connect(function()
        if not getgenv().LightHubConfig.BatAimbotEnabled then return end
    end)
    task.spawn(function()
        while getgenv().LightHubConfig.BatAimbotEnabled do
            useBatTool()
            task.wait(1)
        end
    end)

    batAimbotConn = RunService.RenderStepped:Connect(function()
        local ok = pcall(function()
        if not getgenv().LightHubConfig.BatAimbotEnabled then
            if batAimbotForce then batAimbotForce.Force = Vector3.zero end
            return
        end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not root then
            if batAimbotForce then batAimbotForce.Force = Vector3.zero end
            return
        end
        ensureBatForce(root)

        local speed = tonumber(getgenv().LightHubConfig.BatAimbotSpeed) or 65
        -- WalkSpeed degistirilmez; sadece velocity ile hareket

        local targetRoot = getNearestPlayerRoot()
        if not targetRoot then
            if batAimbotForce then batAimbotForce.Force = Vector3.zero end
            return
        end

        -- Her zaman rakibin 2 blok üstünden git, adamın içine girebilir
        local targetPos = targetRoot.Position + Vector3.new(0, 2, 0)
        local myPos = root.Position
        local offset = targetPos - myPos
        if offset.Magnitude < 0.5 then
            -- Çok yakındaysa sadece yüksekliği koru
            local vel = root.AssemblyLinearVelocity
            local yErr = targetPos.Y - myPos.Y
            batAimbotForce.Force = Vector3.new(-vel.X * 150, yErr * 600, -vel.Z * 150)
            return
        end

        local dir = offset.Unit
        local vel = root.AssemblyLinearVelocity
        local desiredVel = dir * speed
        local currentSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude

        if currentSpeed >= speed then
            batAimbotForce.Force = Vector3.new(0, (desiredVel.Y - vel.Y) * 400, 0)
            return
        end

        batAimbotForce.Force = Vector3.new(dir.X, dir.Y, dir.Z) * (speed * 20)
        end) -- pcall
        if not ok then
            pcall(function() if batAimbotForce then batAimbotForce.Force = Vector3.zero end end)
        end
    end)
end

--========================================================================
-- [ MULTI JUMP ] - VectorForce yöntemi (bug korumasına daha dayanıklı)
--========================================================================
local multiJumpForce = nil
local multiJumpAtt = nil
local lastMultiJump = 0

local function ensureMultiJumpForce(root)
    if multiJumpAtt and multiJumpAtt.Parent == root then return end
    if multiJumpAtt then pcall(function() multiJumpAtt:Destroy() end) end
    if multiJumpForce then pcall(function() multiJumpForce:Destroy() end) end
    multiJumpAtt = Instance.new("Attachment")
    multiJumpAtt.Name = "LH_MultiJumpAtt"
    multiJumpAtt.Parent = root
    multiJumpForce = Instance.new("VectorForce")
    multiJumpForce.Name = "LH_MultiJumpForce"
    multiJumpForce.Attachment0 = multiJumpAtt
    multiJumpForce.RelativeTo = Enum.ActuatorRelativeTo.World
    multiJumpForce.Force = Vector3.zero
    multiJumpForce.Parent = root
end

UserInputService.JumpRequest:Connect(function()
    safeCall(function()
        if not getgenv().LightHubConfig.MultiJumpEnabled then return end
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end

        local state = humanoid:GetState()
        if state ~= Enum.HumanoidStateType.Freefall and state ~= Enum.HumanoidStateType.Jumping then
            return
        end

        local now = tick()
        if now - lastMultiJump < 0.22 then return end
        lastMultiJump = now

        ensureMultiJumpForce(rootPart)

        -- Normal zıplama seviyesinde (fazla güçlü olmasın)
        local jumpPower = 35
        pcall(function()
            if humanoid.UseJumpPower ~= false and humanoid.JumpPower and humanoid.JumpPower > 0 then
                jumpPower = math.min(humanoid.JumpPower, 40)
            elseif humanoid.JumpHeight and humanoid.JumpHeight > 0 then
                jumpPower = math.min(math.sqrt(2 * workspace.Gravity * humanoid.JumpHeight), 40)
            end
        end)
        local vel = rootPart.AssemblyLinearVelocity
        pcall(function()
            rootPart.AssemblyLinearVelocity = Vector3.new(vel.X, jumpPower, vel.Z)
        end)
        if multiJumpForce then
            multiJumpForce.Force = Vector3.new(0, jumpPower * 2.5, 0)
            task.delay(0.025, function()
                pcall(function()
                    if multiJumpForce and multiJumpForce.Parent then
                        multiJumpForce.Force = Vector3.zero
                    end
                end)
            end)
        end
    end)
end)

-- High jump için tek seferlik güçlü zıplama (eski multi jump gücü)
local function doStrongJumpOnce()
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid then return end
    ensureMultiJumpForce(rootPart)
    local vel = rootPart.AssemblyLinearVelocity
    pcall(function()
        rootPart.AssemblyLinearVelocity = Vector3.new(vel.X, 50, vel.Z)
    end)
    multiJumpForce.Force = Vector3.new(0, 6500, 0)
    task.delay(0.08, function()
        if multiJumpForce and multiJumpForce.Parent then
            multiJumpForce.Force = Vector3.zero
        end
    end)
end

-- Spawn Y kaydı (high jump / Tp down / Auto Tp Down için)
local savedSpawnY = nil
local function captureSpawnY(char)
    task.spawn(function()
        local root = char:WaitForChild("HumanoidRootPart", 8)
        if not root then return end
        -- Karakter oturana kadar birkaç frame bekle, sonra en düşük Y'yi al
        task.wait(0.35)
        if not root.Parent then return end
        local y = root.Position.Y
        task.wait(0.15)
        if root.Parent then
            y = math.min(y, root.Position.Y)
        end
        savedSpawnY = y
    end)
end

-- Tp Down: mevcut XZ korunur, Y = spawn Y - 2 (2 blok aşağı)
local function doTpDown()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local baseY = savedSpawnY
    if baseY == nil then
        baseY = root.Position.Y
    end
    local y = baseY - 2
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = CFrame.new(root.Position.X, y, root.Position.Z)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)
end

if LocalPlayer.Character then captureSpawnY(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(char)
    captureSpawnY(char)
    multiJumpAtt = nil
    multiJumpForce = nil
    task.defer(function()
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if root then ensureMultiJumpForce(root) end
    end)
end)

--========================================================================
-- [ WALKFLING (Drop Brainrot - walkfling hali) ]
-- Sadece LocalPlayer'ı etkiler (client-side CanCollide + Velocity)
--========================================================================
local connections = connections or {}
connections.FreezePlayer = connections.FreezePlayer or {}
local featureStates = featureStates or {}
featureStates.FreezePlayer = featureStates.FreezePlayer or false

local function walkfling(enabled)
    local walkflinging = false
    if enabled then
        featureStates.FreezePlayer = true
        local function disablePlayerCollisions()
            local conn = RunService.Stepped:Connect(function()
                if not featureStates.FreezePlayer then
                    conn:Disconnect()
                    return
                end
                local myChar = LocalPlayer.Character
                if myChar then
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character then
                            for _, part in ipairs(plr.Character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end
                end
            end)
            table.insert(connections.FreezePlayer, conn)
        end
        local function stopWalkFling()
            walkflinging = false
        end
        local function startWalkFling()
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                local diedConn = humanoid.Died:Connect(function()
                    stopWalkFling()
                end)
                table.insert(connections.FreezePlayer, diedConn)
            end
            walkflinging = true
            local flingConn = coroutine.create(function()
                repeat
                    RunService.Heartbeat:Wait()
                    if not featureStates.FreezePlayer then
                        break
                    end
                    character = LocalPlayer.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    local vel, movel = nil, 0.1
                    while not (character and character.Parent and root and root.Parent) do
                        RunService.Heartbeat:Wait()
                        if not featureStates.FreezePlayer then
                            break
                        end
                        character = LocalPlayer.Character
                        root = character and character:FindFirstChild("HumanoidRootPart")
                    end
                    if not featureStates.FreezePlayer then
                        break
                    end
                    vel = root.Velocity
                    root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
                    RunService.RenderStepped:Wait()
                    if character and character.Parent and root and root.Parent then
                        root.Velocity = vel
                    end
                    RunService.Stepped:Wait()
                    if character and character.Parent and root and root.Parent then
                        root.Velocity = vel + Vector3.new(0, movel, 0)
                        movel = movel * -1
                    end
                until walkflinging == false or not featureStates.FreezePlayer
            end)
            coroutine.resume(flingConn)
            table.insert(connections.FreezePlayer, flingConn)
        end
        disablePlayerCollisions()
        startWalkFling()
    else
        featureStates.FreezePlayer = false
        for _, conn in ipairs(connections.FreezePlayer) do
            if conn then
                if typeof(conn) == "RBXScriptConnection" then
                    conn:Disconnect()
                elseif typeof(conn) == "thread" then
                    pcall(function() task.cancel(conn) end)
                end
            end
        end
        connections.FreezePlayer = {}
        walkflinging = false
    end
end

-- Eski menü ve Blur efektleri temizle
if CoreGui:FindFirstChild("LightHubIndependent") then
    CoreGui.LightHubIndependent:Destroy()
end
for _, child in ipairs(Lighting:GetChildren()) do
    if child.Name == "LightHubIntroBlur" then child:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LightHubIndependent"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true 

local parentTarget = CoreGui
if gethui then parentTarget = gethui() end
ScreenGui.Parent = parentTarget

----------------------------------------------------------------
-- KÜÇÜK ÖZELLİK BUTONLARI (her zaman görünür)
----------------------------------------------------------------
local defaultLayout = {
    ["Auto Left"]     = { X = 0.68, Y = 0.12 }, ["Auto Right"]    = { X = 0.82, Y = 0.12 },
    ["Carry Speed"]   = { X = 0.68, Y = 0.26 }, ["Drop Brainrot"] = { X = 0.82, Y = 0.26 },
    ["Bat Aimbot"]    = { X = 0.68, Y = 0.40 }, ["Tp down"]       = { X = 0.82, Y = 0.40 },
    ["Reset"]         = { X = 0.68, Y = 0.54 }, ["Lagger Speed"]  = { X = 0.82, Y = 0.54 },
    ["Lagger Steal"]  = { X = 0.68, Y = 0.68 }
}

local Buttons = {}          -- text -> TextButton
local ButtonStrokes = {}    -- text -> UIStroke
local ButtonToggled = {}    -- text -> boolean (for toggle buttons)
local ButtonKeyLabels = {}  -- text -> TextLabel (console keybind)

-- UI Color themes (Black = current default)
local UI_COLOR_NAMES = { "Black", "Blue", "Green", "Pink", "White" }
local UI_THEMES = {
    -- offBg, offText, offStroke, onBg, onText, onStroke, accent, barBg, barFill, hubBg
    Black = {
        offBg = Color3.fromRGB(30, 32, 45),
        offText = Color3.fromRGB(255, 255, 255),
        offStroke = Color3.fromRGB(255, 255, 255),
        onBg = Color3.fromRGB(255, 255, 255),
        onText = Color3.fromRGB(0, 0, 0),
        onStroke = Color3.fromRGB(40, 40, 40),
        accent = Color3.fromRGB(255, 255, 255),
        barBg = Color3.fromRGB(18, 20, 28),
        barFill = Color3.fromRGB(100, 180, 255),
        hubBg = Color3.fromRGB(22, 24, 34),
        panelStroke = Color3.fromRGB(255, 255, 255),
    },
    Blue = {
        offBg = Color3.fromRGB(20, 40, 80),
        offText = Color3.fromRGB(200, 230, 255),
        offStroke = Color3.fromRGB(80, 160, 255),
        onBg = Color3.fromRGB(60, 140, 255),
        onText = Color3.fromRGB(255, 255, 255),
        onStroke = Color3.fromRGB(30, 80, 180),
        accent = Color3.fromRGB(80, 160, 255),
        barBg = Color3.fromRGB(12, 24, 48),
        barFill = Color3.fromRGB(50, 140, 255),
        hubBg = Color3.fromRGB(15, 30, 60),
        panelStroke = Color3.fromRGB(80, 160, 255),
    },
    Green = {
        offBg = Color3.fromRGB(20, 50, 30),
        offText = Color3.fromRGB(200, 255, 210),
        offStroke = Color3.fromRGB(80, 220, 120),
        onBg = Color3.fromRGB(50, 200, 90),
        onText = Color3.fromRGB(0, 20, 0),
        onStroke = Color3.fromRGB(20, 80, 40),
        accent = Color3.fromRGB(80, 220, 120),
        barBg = Color3.fromRGB(12, 32, 18),
        barFill = Color3.fromRGB(60, 200, 100),
        hubBg = Color3.fromRGB(15, 40, 22),
        panelStroke = Color3.fromRGB(80, 220, 120),
    },
    Pink = {
        offBg = Color3.fromRGB(55, 25, 45),
        offText = Color3.fromRGB(255, 210, 235),
        offStroke = Color3.fromRGB(255, 120, 190),
        onBg = Color3.fromRGB(255, 120, 190),
        onText = Color3.fromRGB(40, 0, 25),
        onStroke = Color3.fromRGB(160, 50, 110),
        accent = Color3.fromRGB(255, 120, 190),
        barBg = Color3.fromRGB(40, 15, 32),
        barFill = Color3.fromRGB(255, 100, 180),
        hubBg = Color3.fromRGB(45, 18, 35),
        panelStroke = Color3.fromRGB(255, 120, 190),
    },
    White = {
        offBg = Color3.fromRGB(230, 230, 235),
        offText = Color3.fromRGB(20, 20, 25),
        offStroke = Color3.fromRGB(180, 180, 190),
        onBg = Color3.fromRGB(40, 40, 48),
        onText = Color3.fromRGB(255, 255, 255),
        onStroke = Color3.fromRGB(120, 120, 130),
        accent = Color3.fromRGB(200, 200, 210),
        barBg = Color3.fromRGB(240, 240, 245),
        barFill = Color3.fromRGB(80, 80, 90),
        hubBg = Color3.fromRGB(245, 245, 250),
        panelStroke = Color3.fromRGB(180, 180, 190),
    },
}

local function getCurrentTheme()
    local idx = tonumber(getgenv().LightHubConfig.UiColorIndex) or 1
    if idx < 1 then idx = 1 end
    if idx > #UI_COLOR_NAMES then idx = 1 end
    local name = UI_COLOR_NAMES[idx]
    return UI_THEMES[name] or UI_THEMES.Black, name, idx
end

local function setButtonVisual(btn, stroke, on)
    local theme = getCurrentTheme()
    if on then
        btn.BackgroundColor3 = theme.onBg
        btn.TextColor3 = theme.onText
        stroke.Color = theme.onStroke
    else
        btn.BackgroundColor3 = theme.offBg
        btn.TextColor3 = theme.offText
        stroke.Color = theme.offStroke
    end
end

local function applyUiColorTheme()
    local theme, name, idx
    local okTheme, themeOrErr, name2, idx2 = pcall(function()
        return getCurrentTheme()
    end)
    if okTheme then
        -- getCurrentTheme returns 3 values; pcall only returns first success value as themeOrErr
        theme, name, idx = getCurrentTheme()
    else
        theme = UI_THEMES.Black
        name = "Black"
        idx = 1
    end
    getgenv().LightHubConfig.UiColorIndex = idx
    pcall(SaveConfig)

    -- Feature buttons
    for text, btn in pairs(Buttons) do
        local stroke = ButtonStrokes[text]
        if btn and stroke then
            setButtonVisual(btn, stroke, ButtonToggled[text] == true)
        end
        local keyLbl = ButtonKeyLabels[text]
        if keyLbl then
            keyLbl.TextColor3 = theme.accent
        end
    end

    -- Hub main button + panel (FindFirstChild: local tanımlar daha sonra)
    local hubBtn = ScreenGui:FindFirstChild("LightHubMain")
    if hubBtn then
        hubBtn.BackgroundColor3 = theme.hubBg
        hubBtn.TextColor3 = theme.offText
        local hs = hubBtn:FindFirstChildOfClass("UIStroke")
        if hs then hs.Color = theme.panelStroke end
    end
    local panel = ScreenGui:FindFirstChild("LightHubPanel")
    if panel then
        local ps = panel:FindFirstChildOfClass("UIStroke")
        if ps then ps.Color = theme.panelStroke end
    end

    -- Auto Steal bar
    local parent = (gethui and gethui()) or CoreGui
    local asg = parent:FindFirstChild("LightHubAutoStealBar")
    if asg then
        local bar = asg:FindFirstChild("Bar")
        if bar then
            bar.BackgroundColor3 = theme.barBg
            local track = bar:FindFirstChild("Track")
            if track then
                local fill = track:FindFirstChild("Fill")
                if fill then fill.BackgroundColor3 = theme.barFill end
            end
            for _, child in ipairs(bar:GetDescendants()) do
                if child:IsA("TextLabel") then
                    child.TextColor3 = theme.offText
                elseif child:IsA("UIStroke") then
                    child.Color = theme.panelStroke
                end
            end
        end
    end

    return name
end

local function updateSpeedMode(newMode)
    local cfg = getgenv().LightHubConfig
    local oldMode = cfg.SpeedMode
    cfg.SpeedMode = newMode
    SaveConfig()

    -- Görselleri güncelle
    -- Carry Speed
    local carryOn = (newMode == "carry")
    ButtonToggled["Carry Speed"] = carryOn
    if Buttons["Carry Speed"] then
        setButtonVisual(Buttons["Carry Speed"], ButtonStrokes["Carry Speed"], carryOn)
    end

    -- Lagger Mode (eski Lagger Speed) — isim her zaman "Lagger Mode"
    local laggerOn = (newMode == "lagger" or newMode == "lagger_carry")
    ButtonToggled["Lagger Speed"] = laggerOn
    if Buttons["Lagger Speed"] then
        Buttons["Lagger Speed"].Text = "Lagger Mode"
        setButtonVisual(Buttons["Lagger Speed"], ButtonStrokes["Lagger Speed"], laggerOn)
    end

    -- Lagger Steal (Lagger Carry) — isim her zaman "Lagger Steal"
    local laggerCarryOn = (newMode == "lagger_carry")
    ButtonToggled["Lagger Steal"] = laggerCarryOn
    if Buttons["Lagger Steal"] then
        Buttons["Lagger Steal"].Text = "Lagger Steal"
        setButtonVisual(Buttons["Lagger Steal"], ButtonStrokes["Lagger Steal"], laggerCarryOn)
    end

    -- Hızı hemen uygula
    if LocalPlayer.Character then
        setupBoost(LocalPlayer.Character)
    end
end

for text, defaultPos in pairs(defaultLayout) do
    local initTheme = getCurrentTheme()
    local Btn = Instance.new("TextButton")
    Btn.Name = "Button_" .. text
    Btn.Parent = ScreenGui
    Btn.Text = (text == "Lagger Speed") and "Lagger Mode" or text
    Btn.TextColor3 = initTheme.offText
    Btn.TextSize = 11
    Btn.Font = Enum.Font.FredokaOne
    Btn.BackgroundColor3 = initTheme.offBg
    Btn.BackgroundTransparency = 0.2
    Btn.AutoButtonColor = false
    Btn.Size = UDim2.new(0.12, 0, 0.11, 0)
    Btn.ZIndex = 1
    Btn.Visible = true

    local saved = savedPositions[text]
    if saved then
        Btn.Position = UDim2.new(saved.ScaleX, saved.OffsetX, saved.ScaleY, saved.OffsetY)
    else
        Btn.Position = UDim2.new(defaultPos.X, 0, defaultPos.Y, 0)
    end

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Parent = Btn
    BtnStroke.Color = initTheme.offStroke
    BtnStroke.Thickness = 1.5
    BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    Buttons[text] = Btn
    ButtonStrokes[text] = BtnStroke
    ButtonToggled[text] = false

    -- Keybind etiketi: sağ üstte, buton yazısı / beyaz stroke ile çakışmasın
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Name = "KeybindLabel"
    keyLabel.Parent = Btn
    keyLabel.AnchorPoint = Vector2.new(1, 0)
    keyLabel.Size = UDim2.new(0, 32, 0, 14)
    keyLabel.Position = UDim2.new(1, -3, 0, 2)
    keyLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    keyLabel.BackgroundTransparency = 0.25
    keyLabel.Text = ""
    keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyLabel.TextSize = 11
    keyLabel.Font = Enum.Font.GothamBold
    keyLabel.TextXAlignment = Enum.TextXAlignment.Center
    keyLabel.TextYAlignment = Enum.TextYAlignment.Center
    keyLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    keyLabel.TextStrokeTransparency = 0.4
    keyLabel.ZIndex = 10
    keyLabel.Visible = false
    keyLabel.ClipsDescendants = false
    Instance.new("UICorner", keyLabel).CornerRadius = UDim.new(0, 4)
    -- Beyaz UIStroke yok (okunabilirliği bozuyordu)
    ButtonKeyLabels[text] = keyLabel

    local dragging, dragInput, dragStart, startPos, hasMoved = false, nil, nil, nil, false

    Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; hasMoved = false; dragStart = input.Position; startPos = Btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    SavePosition(text, Btn.Position)
                end
            end)
        end
    end)

    Btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then hasMoved = true end
            Btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Click logic
    if text == "Drop Brainrot" or text == "Tp down" or text == "Reset" then
        -- Instant flash buttons
        Btn.MouseButton1Click:Connect(function()
            if hasMoved then return end
            setButtonVisual(Btn, BtnStroke, true)
            task.delay(0.2, function()
                if Btn and Btn.Parent then
                    setButtonVisual(Btn, BtnStroke, false)
                end
            end)

            if text == "Reset" then
                -- 1 sn boyunca aşırı AngularVelocity ile dön
                task.spawn(function()
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if not root then return end
                    local start = tick()
                    local spinConn
                    spinConn = RunService.Heartbeat:Connect(function()
                        if tick() - start > 3 then
                            if spinConn then spinConn:Disconnect() end
                            pcall(function()
                                root.AssemblyAngularVelocity = Vector3.zero
                                root.RotVelocity = Vector3.zero
                            end)
                            return
                        end
                        pcall(function()
                            root.AssemblyAngularVelocity = Vector3.new(0, 999999999999999999999, 0)
                            root.RotVelocity = Vector3.new(0, 999999999999999999999, 0)
                        end)
                    end)
                end)
            elseif text == "Tp down" then
                doTpDown()
            elseif text == "Drop Brainrot" then
                local dropTypeBtn = ScreenGui:FindFirstChild("LightHubPanel") 
                    and ScreenGui.LightHubPanel:FindFirstChild("ContentScroll")
                    and ScreenGui.LightHubPanel.ContentScroll:FindFirstChild("DropTypeRow")
                    and ScreenGui.LightHubPanel.ContentScroll.DropTypeRow:FindFirstChild("DropTypeBtn")
                
                local currentDropType = "walkfling"
                if dropTypeBtn then
                    currentDropType = dropTypeBtn.Text
                end

                if currentDropType == "walkfling" then
                    -- Walkfling sadece 0.7sn aktif, sonra kapanır
                    walkfling(true)
                    task.delay(0.7, function()
                        walkfling(false)
                        getgenv().LightHubConfig.SpeedBoostEnabled = true
                        getgenv().LightHubConfig.MultiJumpEnabled = true
                        SaveConfig()
                        if LocalPlayer.Character then
                            setupBoost(LocalPlayer.Character)
                        end
                        if _G.LightHub_SetMultiJumpVisual then
                            _G.LightHub_SetMultiJumpVisual(true)
                        end
                    end)
                elseif currentDropType == "high jump" then
                    -- Anında güçlü zıplama, 0.6sn sonra spawn Y-3 TP
                    doStrongJumpOnce()
                    task.delay(0.6, function()
                        local char = LocalPlayer.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if not root then return end
                        local y = (savedSpawnY or root.Position.Y) - 3
                        root.CFrame = CFrame.new(root.Position.X, y, root.Position.Z)
                    end)
                end
            end
        end)
    elseif text == "Carry Speed" then
        Btn.MouseButton1Click:Connect(function()
            if hasMoved then return end
            local cfg = getgenv().LightHubConfig
            if cfg.SpeedMode == "carry" then
                -- Kapat → normal'e dön
                updateSpeedMode("normal")
            else
                -- Aç → Carry (StealSpeed). Lagger Speed ve Lagger Carry kapatılır
                updateSpeedMode("carry")
            end
        end)
    elseif text == "Lagger Speed" then
        Btn.MouseButton1Click:Connect(function()
            if hasMoved then return end
            local cfg = getgenv().LightHubConfig
            if cfg.SpeedMode == "lagger" or cfg.SpeedMode == "lagger_carry" then
                -- Kapat → normal
                updateSpeedMode("normal")
            else
                -- Aç → Lagger. Carry kapatılır (Lagger Carry zaten kapalı olacak)
                updateSpeedMode("lagger")
            end
        end)
    elseif text == "Lagger Steal" then
        -- Bu = Lagger Carry
        Btn.MouseButton1Click:Connect(function()
            if hasMoved then return end
            local cfg = getgenv().LightHubConfig
            if cfg.SpeedMode == "lagger_carry" then
                -- Kapat: Lagger Mode açıksa ona dön, değilse normal
                -- (lagger_carry iken Lagger Mode butonu da yanık görünür; yine de lagger'a dön)
                updateSpeedMode("lagger")
                -- Görseli zorla güncelle
                if Buttons["Lagger Steal"] then
                    Buttons["Lagger Steal"].Text = "Lagger Steal"
                    setButtonVisual(Buttons["Lagger Steal"], ButtonStrokes["Lagger Steal"], false)
                    ButtonToggled["Lagger Steal"] = false
                end
            else
                -- Aç → Lagger Carry
                updateSpeedMode("lagger_carry")
            end
        end)
    elseif text == "Bat Aimbot" then
        Btn.MouseButton1Click:Connect(function()
            if hasMoved then return end
            ButtonToggled[text] = not ButtonToggled[text]
            setButtonVisual(Btn, BtnStroke, ButtonToggled[text])
            getgenv().LightHubConfig.BatAimbotEnabled = ButtonToggled[text]
            SaveConfig()
            if ButtonToggled[text] then
                startBatAimbot()
            else
                stopBatAimbot()
            end
        end)
    else
        -- Diğer toggle butonlar (Auto Left, Auto Right ...)
        Btn.MouseButton1Click:Connect(function()
            if hasMoved then return end
            ButtonToggled[text] = not ButtonToggled[text]
            setButtonVisual(Btn, BtnStroke, ButtonToggled[text])
        end)
    end
end

-- Başlangıçta config'deki mode'u uygula
updateSpeedMode(getgenv().LightHubConfig.SpeedMode or "normal")

----------------------------------------------------------------
-- SOL ÜST LIGHT HUB TUŞU + BAĞIMSIZ BÜYÜK PANEL (sürüklenebilir)
----------------------------------------------------------------
local function MakeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    local hasMoved = false

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            hasMoved = false
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
                hasMoved = true
            end
            guiObject.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    return function() return hasMoved end
end

local HubBtn = Instance.new("TextButton")
HubBtn.Name = "LightHubMain"
HubBtn.Parent = ScreenGui
HubBtn.AnchorPoint = Vector2.new(0, 0)
HubBtn.Position = UDim2.new(0.02, 0, 0.14, 0)
HubBtn.Size = UDim2.new(0, 130, 0, 42)
HubBtn.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
HubBtn.BackgroundTransparency = 0.05
HubBtn.AutoButtonColor = false
HubBtn.Text = "Light Hub"
HubBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HubBtn.TextSize = 16
HubBtn.Font = Enum.Font.GothamBlack
HubBtn.ZIndex = 50
HubBtn.Visible = true

local HubCorner = Instance.new("UICorner")
HubCorner.CornerRadius = UDim.new(0, 10)
HubCorner.Parent = HubBtn

local HubStroke = Instance.new("UIStroke")
HubStroke.Parent = HubBtn
HubStroke.Color = Color3.fromRGB(255, 255, 255)
HubStroke.Thickness = 1.5
HubStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local hubWasDragged = MakeDraggable(HubBtn)

-- Bağımsız büyük panel
local HubPanel = Instance.new("Frame")
HubPanel.Name = "LightHubPanel"
HubPanel.Parent = ScreenGui
HubPanel.AnchorPoint = Vector2.new(0.5, 0.5)
HubPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
HubPanel.Size = UDim2.new(0, 280, 0, 320)
HubPanel.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
HubPanel.BackgroundTransparency = 1
HubPanel.Visible = false
HubPanel.ZIndex = 60
HubPanel.Active = true
HubPanel.ClipsDescendants = true

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 16)
PanelCorner.Parent = HubPanel

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Parent = HubPanel
PanelStroke.Color = Color3.fromRGB(255, 255, 255)
PanelStroke.Thickness = 1.8
PanelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- GUI arka plan fotoğrafı
local PanelBg = Instance.new("ImageLabel")
PanelBg.Name = "Background"
PanelBg.Parent = HubPanel
PanelBg.Size = UDim2.new(1, 0, 1, 0)
PanelBg.Position = UDim2.new(0, 0, 0, 0)
PanelBg.BackgroundTransparency = 1
PanelBg.Image = "rbxassetid://99416158073201"
PanelBg.ScaleType = Enum.ScaleType.Crop
PanelBg.ZIndex = 60

local PanelBgCorner = Instance.new("UICorner")
PanelBgCorner.CornerRadius = UDim.new(0, 16)
PanelBgCorner.Parent = PanelBg

-- Başlık yazısı
local PanelTitle = Instance.new("TextLabel")
PanelTitle.Name = "PanelTitle"
PanelTitle.Parent = HubPanel
PanelTitle.Size = UDim2.new(1, 0, 0, 48)
PanelTitle.Position = UDim2.new(0, 0, 0, 0)
PanelTitle.BackgroundTransparency = 1
PanelTitle.Text = "Light Hub"
PanelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
PanelTitle.TextSize = 22
PanelTitle.Font = Enum.Font.GothamBlack
PanelTitle.ZIndex = 62

-- Kaydırılabilir içerik alanı
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "ContentScroll"
ContentScroll.Parent = HubPanel
ContentScroll.Size = UDim2.new(1, -16, 1, -56)
ContentScroll.Position = UDim2.new(0, 8, 0, 48)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 4
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentScroll.ZIndex = 61
ContentScroll.Active = true

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = ContentScroll
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ContentPad = Instance.new("UIPadding")
ContentPad.Parent = ContentScroll
ContentPad.PaddingTop = UDim.new(0, 4)
ContentPad.PaddingBottom = UDim.new(0, 12)
ContentPad.PaddingLeft = UDim.new(0, 4)
ContentPad.PaddingRight = UDim.new(0, 8)

-- Sadece sayı (ve nokta) kabul eden textbox
local function NumbersOnly(box)
    box:GetPropertyChangedSignal("Text"):Connect(function()
        local filtered = box.Text:gsub("[^0-9%.]", "")
        local first = filtered:find("%.")
        if first then
            filtered = filtered:sub(1, first) .. filtered:sub(first + 1):gsub("%.", "")
        end
        if box.Text ~= filtered then
            box.Text = filtered
        end
    end)
end

local function MakeSectionTitle(text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = ContentScroll
    lbl.Size = UDim2.new(1, -8, 0, 28)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 18
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.ZIndex = 62
    return lbl
end

local function MakeRow(labelText, defaultValue, order)
    local row = Instance.new("Frame")
    row.Parent = ContentScroll
    row.Size = UDim2.new(1, -8, 0, 34)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.ZIndex = 62

    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.Size = UDim2.new(0.55, 0, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 15
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 63

    local box = Instance.new("TextBox")
    box.Parent = row
    box.Size = UDim2.new(0.42, 0, 0, 28)
    box.Position = UDim2.new(0.58, 0, 0.5, -14)
    box.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
    box.BackgroundTransparency = 0.25
    box.Text = tostring(defaultValue)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.ZIndex = 63

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = box

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Parent = box
    boxStroke.Color = Color3.fromRGB(255, 255, 255)
    boxStroke.Thickness = 1.5
    boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    NumbersOnly(box)
    return box
end

MakeSectionTitle("Speed Boost", 1)
local NormalSpeedBox = MakeRow("Normal Speed", tostring(getgenv().LightHubConfig.NormalSpeed), 2)
local StealSpeedBox = MakeRow("Steal Speed", tostring(getgenv().LightHubConfig.StealSpeed), 3)
local LaggerSpeedBox = MakeRow("Lagger Speed", tostring(getgenv().LightHubConfig.LaggerSpeed), 4)
local LaggerStealBox = MakeRow("Lagger Steal", tostring(getgenv().LightHubConfig.LaggerSteal), 5)

-- TextBox'ları config'e bağla
NormalSpeedBox.FocusLost:Connect(function(enter)
    local num = tonumber(NormalSpeedBox.Text)
    if num then
        getgenv().LightHubConfig.NormalSpeed = num
        SaveConfig()
        if getgenv().LightHubConfig.SpeedMode == "normal" and LocalPlayer.Character then
            setupBoost(LocalPlayer.Character)
        end
    else
        NormalSpeedBox.Text = tostring(getgenv().LightHubConfig.NormalSpeed)
    end
end)

StealSpeedBox.FocusLost:Connect(function(enter)
    local num = tonumber(StealSpeedBox.Text)
    if num then
        getgenv().LightHubConfig.StealSpeed = num
        SaveConfig()
        if getgenv().LightHubConfig.SpeedMode == "carry" and LocalPlayer.Character then
            setupBoost(LocalPlayer.Character)
        end
    else
        StealSpeedBox.Text = tostring(getgenv().LightHubConfig.StealSpeed)
    end
end)

LaggerSpeedBox.FocusLost:Connect(function(enter)
    local num = tonumber(LaggerSpeedBox.Text)
    if num then
        getgenv().LightHubConfig.LaggerSpeed = num
        SaveConfig()
        if getgenv().LightHubConfig.SpeedMode == "lagger" and LocalPlayer.Character then
            setupBoost(LocalPlayer.Character)
        end
    else
        LaggerSpeedBox.Text = tostring(getgenv().LightHubConfig.LaggerSpeed)
    end
end)

LaggerStealBox.FocusLost:Connect(function(enter)
    local num = tonumber(LaggerStealBox.Text)
    if num then
        getgenv().LightHubConfig.LaggerSteal = num
        SaveConfig()
        if getgenv().LightHubConfig.SpeedMode == "lagger_carry" and LocalPlayer.Character then
            setupBoost(LocalPlayer.Character)
        end
    else
        LaggerStealBox.Text = tostring(getgenv().LightHubConfig.LaggerSteal)
    end
end)

-- Drop Type satırı
local DropRow = Instance.new("Frame")
DropRow.Name = "DropTypeRow"
DropRow.Parent = ContentScroll
DropRow.Size = UDim2.new(1, -8, 0, 40)
DropRow.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
DropRow.BackgroundTransparency = 0.25
DropRow.LayoutOrder = 6
DropRow.ZIndex = 62

local DropRowCorner = Instance.new("UICorner")
DropRowCorner.CornerRadius = UDim.new(0, 8)
DropRowCorner.Parent = DropRow

local DropRowStroke = Instance.new("UIStroke")
DropRowStroke.Parent = DropRow
DropRowStroke.Color = Color3.fromRGB(255, 255, 255)
DropRowStroke.Thickness = 1.2

local DropLabel = Instance.new("TextLabel")
DropLabel.Parent = DropRow
DropLabel.Size = UDim2.new(0.58, -4, 1, 0)
DropLabel.Position = UDim2.new(0, 8, 0, 0)
DropLabel.BackgroundTransparency = 1
DropLabel.Text = "Drop Brainrot Type"
DropLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DropLabel.TextSize = 13
DropLabel.Font = Enum.Font.GothamBold
DropLabel.TextXAlignment = Enum.TextXAlignment.Left
DropLabel.TextTruncate = Enum.TextTruncate.AtEnd
DropLabel.ZIndex = 63

local DropTypeBtn = Instance.new("TextButton")
DropTypeBtn.Name = "DropTypeBtn"
DropTypeBtn.Parent = DropRow
DropTypeBtn.Size = UDim2.new(0.36, 0, 0, 26)
DropTypeBtn.Position = UDim2.new(0.62, 0, 0.5, -13)
DropTypeBtn.BackgroundColor3 = Color3.fromRGB(30, 34, 48)
DropTypeBtn.BackgroundTransparency = 0.1
DropTypeBtn.Text = "walkfling"
DropTypeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DropTypeBtn.TextSize = 13
DropTypeBtn.Font = Enum.Font.Gotham
DropTypeBtn.AutoButtonColor = false
DropTypeBtn.ZIndex = 63

local DropTypeBtnCorner = Instance.new("UICorner")
DropTypeBtnCorner.CornerRadius = UDim.new(0, 6)
DropTypeBtnCorner.Parent = DropTypeBtn

local DropTypeBtnStroke = Instance.new("UIStroke")
DropTypeBtnStroke.Parent = DropTypeBtn
DropTypeBtnStroke.Color = Color3.fromRGB(255, 255, 255)
DropTypeBtnStroke.Thickness = 1.5
DropTypeBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local dropModes = {"walkfling", "high jump"}
local dropIndex = 1
DropTypeBtn.MouseButton1Click:Connect(function()
    dropIndex = dropIndex % #dropModes + 1
    DropTypeBtn.Text = dropModes[dropIndex]
end)

-- Animasyonlu aç/kapa toggle
local function MakeToggle(labelText, order, initialOn, onChanged)
    local row = Instance.new("Frame")
    row.Parent = ContentScroll
    row.Size = UDim2.new(1, -8, 0, 36)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.ZIndex = 62

    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.Size = UDim2.new(0.62, 0, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 15
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 63

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Parent = row
    track.Size = UDim2.new(0, 52, 0, 26)
    track.Position = UDim2.new(1, -52, 0.5, -13)
    track.BackgroundColor3 = initialOn and Color3.fromRGB(150, 155, 170) or Color3.fromRGB(40, 42, 55)
    track.ZIndex = 63

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local trackStroke = Instance.new("UIStroke")
    trackStroke.Parent = track
    trackStroke.Color = Color3.fromRGB(255, 255, 255)
    trackStroke.Thickness = 1.2

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Parent = track
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = initialOn and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
    knob.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
    knob.ZIndex = 64

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local hit = Instance.new("TextButton")
    hit.Parent = track
    hit.Size = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.ZIndex = 65

    local on = initialOn
    hit.MouseButton1Click:Connect(function()
        on = not on
        local goalPos = on and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
        local goalColor = on and Color3.fromRGB(150, 155, 170) or Color3.fromRGB(40, 42, 55)
        TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = goalPos
        }):Play()
        TweenService:Create(track, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = goalColor
        }):Play()
        if onChanged then onChanged(on) end
    end)

    return function() return on end, function(newState)
        if on == newState then return end
        on = newState
        local goalPos = on and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
        local goalColor = on and Color3.fromRGB(150, 155, 170) or Color3.fromRGB(40, 42, 55)
        TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = goalPos
        }):Play()
        TweenService:Create(track, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = goalColor
        }):Play()
    end
end

local GetMultiJump, SetMultiJumpVisual = MakeToggle("Multi Jump", 7, getgenv().LightHubConfig.MultiJumpEnabled, function(state)
    getgenv().LightHubConfig.MultiJumpEnabled = state
    SaveConfig()
end)
_G.LightHub_SetMultiJumpVisual = SetMultiJumpVisual

local autoStealBarGui = nil
local autoStealBarConn = nil
local autoStealPromptConn = nil
local autoStealProgress = 0
local autoStealRadius = 50

local function destroyAutoStealBar()
    if autoStealBarConn then
        autoStealBarConn:Disconnect()
        autoStealBarConn = nil
    end
    if autoStealPromptConn then
        autoStealPromptConn:Disconnect()
        autoStealPromptConn = nil
    end
    if autoStealBarGui then
        pcall(function() autoStealBarGui:Destroy() end)
        autoStealBarGui = nil
    end
end

local function getStealRadius()
    if autoStealBarGui then
        local box = autoStealBarGui:FindFirstChild("Bar") and autoStealBarGui.Bar:FindFirstChild("RadiusBox")
        if box then
            local n = tonumber(box.Text)
            if n then autoStealRadius = n end
        end
    end
    return autoStealRadius or 50
end

local function processStealPrompt(prompt)
    pcall(function()
        if not prompt:IsA("ProximityPrompt") then return end
        local name = string.lower(prompt.Name)
        local parentName = prompt.Parent and string.lower(prompt.Parent.Name) or ""
        local action = string.lower(tostring(prompt.ActionText or ""))
        local obj = string.lower(tostring(prompt.ObjectText or ""))
        local isSteal = name:find("steal", 1, true)
            or parentName:find("steal", 1, true)
            or action:find("steal", 1, true)
            or obj:find("steal", 1, true)
        if not isSteal then return end
        prompt.HoldDuration = 1.3
        prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance, getStealRadius())
    end)
end

local function scanAllStealPrompts()
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                processStealPrompt(obj)
            end
        end
    end)
end

local holdingPrompt = nil
local holdStartTime = 0
local holdDuration = 1.3

local function tryHoldNearestSteal()
    pcall(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then
            holdingPrompt = nil
            holdStartTime = 0
            autoStealProgress = 0
            return
        end
        local radius = getStealRadius()
        local nearest, nearestDist = nil, radius + 1
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local name = string.lower(obj.Name)
                local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""
                local action = string.lower(tostring(obj.ActionText or ""))
                local isSteal = name:find("steal", 1, true)
                    or parentName:find("steal", 1, true)
                    or action:find("steal", 1, true)
                if isSteal then
                    local part = obj.Parent
                    local pos = nil
                    if part and part:IsA("BasePart") then
                        pos = part.Position
                    elseif part and part:IsA("Model") then
                        local pp = part:FindFirstChildWhichIsA("BasePart")
                        if pp then pos = pp.Position end
                    end
                    if pos then
                        local d = (pos - root.Position).Magnitude
                        if d < nearestDist then
                            nearestDist = d
                            nearest = obj
                        end
                    end
                end
            end
        end
        if nearest and nearestDist <= radius then
            processStealPrompt(nearest)
            holdDuration = tonumber(nearest.HoldDuration) or 1.3
            if holdDuration <= 0 then holdDuration = 0.05 end
            -- Radius icindeyken ASLA birakma; surekli basili tut
            -- Prompt yeniden baslasa bile tekrar InputHoldBegin
            pcall(function()
                nearest:InputHoldBegin()
            end)
            if holdingPrompt ~= nearest then
                holdingPrompt = nearest
                holdStartTime = tick()
            end
            local elapsed = tick() - holdStartTime
            autoStealProgress = math.clamp(elapsed / holdDuration, 0, 1)
            -- Hold tamamlandiysa (prompt firladi / reset) basariyi sifirla ama basili tutmaya devam
            if autoStealProgress >= 1 then
                holdStartTime = tick()
                autoStealProgress = 0
                pcall(function()
                    nearest:InputHoldBegin()
                end)
            end
        else
            -- Radius disina cikinca birak
            if holdingPrompt then
                pcall(function() holdingPrompt:InputHoldEnd() end)
            end
            holdingPrompt = nil
            holdStartTime = 0
            autoStealProgress = 0
        end
    end)
end

local function createAutoStealBar()
    destroyAutoStealBar()
    local theme = getCurrentTheme()
    local parent = (gethui and gethui()) or CoreGui
    autoStealBarGui = Instance.new("ScreenGui")
    autoStealBarGui.Name = "LightHubAutoStealBar"
    autoStealBarGui.ResetOnSpawn = false
    autoStealBarGui.IgnoreGuiInset = true
    autoStealBarGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    autoStealBarGui.Parent = parent

    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Parent = autoStealBarGui
    bar.AnchorPoint = Vector2.new(0.5, 1)
    bar.Position = UDim2.new(0.5, 0, 1, -16)
    bar.Size = UDim2.new(0, 420, 0, 30)
    bar.BackgroundColor3 = theme.barBg
    bar.BackgroundTransparency = 0.15
    bar.BorderSizePixel = 0
    bar.ZIndex = 100
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 8)
    local barStroke = Instance.new("UIStroke", bar)
    barStroke.Color = theme.panelStroke
    barStroke.Thickness = 1.2
    barStroke.Transparency = 0.35

    -- Light Hub
    local title = Instance.new("TextLabel")
    title.Parent = bar
    title.Size = UDim2.new(0, 68, 1, 0)
    title.Position = UDim2.new(0, 8, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Light Hub"
    title.TextColor3 = theme.offText
    title.TextSize = 11
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 101

    -- Loading track (yanında %)
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Parent = bar
    track.Size = UDim2.new(0, 110, 0, 12)
    track.Position = UDim2.new(0, 78, 0.5, -6)
    track.BackgroundColor3 = Color3.fromRGB(40, 44, 58)
    track.BorderSizePixel = 0
    track.ZIndex = 101
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 5)
    local ts = Instance.new("UIStroke", track)
    ts.Color = theme.accent
    ts.Thickness = 1

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Parent = track
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = theme.barFill
    fill.BorderSizePixel = 0
    fill.ZIndex = 102
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 5)

    -- % hemen barın yanında
    local pctLabel = Instance.new("TextLabel")
    pctLabel.Name = "Percent"
    pctLabel.Parent = bar
    pctLabel.Size = UDim2.new(0, 36, 1, 0)
    pctLabel.Position = UDim2.new(0, 192, 0, 0)
    pctLabel.BackgroundTransparency = 1
    pctLabel.Text = "0%"
    pctLabel.TextColor3 = theme.offText
    pctLabel.TextXAlignment = Enum.TextXAlignment.Left
    pctLabel.ZIndex = 101

    -- radius + box (barın dışında, sağa)
    local radiusLbl = Instance.new("TextLabel")
    radiusLbl.Parent = bar
    radiusLbl.Size = UDim2.new(0, 42, 1, 0)
    radiusLbl.Position = UDim2.new(0, 232, 0, 0)
    radiusLbl.BackgroundTransparency = 1
    radiusLbl.Text = "radius"
    radiusLbl.TextColor3 = theme.offText
    radiusLbl.TextSize = 11
    radiusLbl.Font = Enum.Font.GothamBold
    radiusLbl.ZIndex = 101

    local radiusBox = Instance.new("TextBox")
    radiusBox.Name = "RadiusBox"
    radiusBox.Parent = bar
    radiusBox.Size = UDim2.new(0, 36, 0, 20)
    radiusBox.Position = UDim2.new(0, 274, 0.5, -10)
    radiusBox.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
    radiusBox.Text = tostring(autoStealRadius or 50)
    radiusBox.TextColor3 = theme.offText
    radiusBox.TextSize = 12
    radiusBox.Font = Enum.Font.GothamBold
    radiusBox.ClearTextOnFocus = false
    radiusBox.ZIndex = 101
    Instance.new("UICorner", radiusBox).CornerRadius = UDim.new(0, 5)
    radiusBox:GetPropertyChangedSignal("Text"):Connect(function()
        local f = radiusBox.Text:gsub("[^0-9]", "")
        if radiusBox.Text ~= f then radiusBox.Text = f end
        local n = tonumber(radiusBox.Text)
        if n then autoStealRadius = n end
    end)

    -- Ping FPS en sağda
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "Stats"
    statsLabel.Parent = bar
    statsLabel.Size = UDim2.new(0, 100, 1, 0)
    statsLabel.Position = UDim2.new(1, -108, 0, 0)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "PING --  FPS --"
    statsLabel.TextColor3 = theme.offText
    statsLabel.TextSize = 10
    statsLabel.Font = Enum.Font.GothamBold
    statsLabel.TextXAlignment = Enum.TextXAlignment.Right
    statsLabel.ZIndex = 101

    autoStealProgress = 0
    scanAllStealPrompts()
    autoStealPromptConn = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("ProximityPrompt") then
            processStealPrompt(obj)
        end
    end)

    local StatsService = game:GetService("Stats")
    autoStealBarConn = RunService.Heartbeat:Connect(function(dt)
        pcall(function()
            if not autoStealBarGui or not autoStealBarGui.Parent then return end
            tryHoldNearestSteal()
            if fill then fill.Size = UDim2.new(autoStealProgress, 0, 1, 0) end
            if pctLabel then pctLabel.Text = string.format("%d%%", math.floor(autoStealProgress * 100 + 0.5)) end
            local ping, fps = "--", "--"
            pcall(function()
                ping = tostring(math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()))
                fps = tostring(math.floor(1 / math.max(dt, 0.001)))
            end)
            if statsLabel then statsLabel.Text = "PING " .. ping .. "  FPS " .. fps end
        end)
    end)
end

local GetAutoSteal = MakeToggle("Auto Steal", 8, false, function(state)
    safeCall(function()
        if state then
            createAutoStealBar()
        else
            if holdingPrompt then
                pcall(function() holdingPrompt:InputHoldEnd() end)
                holdingPrompt = nil
            end
            destroyAutoStealBar()
        end
    end)
end)


-- Anti Ragdoll logic
local antiRagdollEnabled = false
local antiRagdollResetCooldown = 0
local antiRagdollConnection = nil

local function forceAntiRagdollReset()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return end
    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        root.Velocity = Vector3.zero
        root.RotVelocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") then obj.Enabled = true end
            if obj:IsA("Constraint") then obj.Enabled = true end
        end
        workspace.CurrentCamera.CameraSubject = hum
        local PM = LocalPlayer:FindFirstChild("PlayerScripts") and LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
        if PM then
            local ok, CM = pcall(function()
                return require(PM:FindFirstChild("ControlModule"))
            end)
            if ok and CM and CM.Enable then pcall(function() CM:Enable() end) end
        end
        hum.AutoRotate = true
        hum.PlatformStand = false
        hum.Sit = false
    end)
end

local function startAntiRagdoll()
    if antiRagdollConnection then return end
    antiRagdollEnabled = true
    antiRagdollConnection = RunService.Heartbeat:Connect(function()
        if not antiRagdollEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local state = hum:GetState()
        local isRagdolled = (state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.Ragdoll
            or state == Enum.HumanoidStateType.FallingDown)
        if isRagdolled then
            local now = tick()
            if now - antiRagdollResetCooldown > 0.15 then
                antiRagdollResetCooldown = now
                forceAntiRagdollReset()
            end
        end
    end)
end

local function stopAntiRagdoll()
    antiRagdollEnabled = false
    if antiRagdollConnection then
        antiRagdollConnection:Disconnect()
        antiRagdollConnection = nil
    end
end

local GetAntiRagdoll = MakeToggle("Anti Ragdoll", 9, false, function(state)
    if state then startAntiRagdoll() else stopAntiRagdoll() end
end)
-- Medusa Counter
local medusaEnabled = false
local medusaCounterCount = 0
local medusaLastFire = 0
local medusaConnections = {}
local medusaGui = nil

local function findMedusaTool()
    local char = LocalPlayer.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("medusa") then return t end
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("medusa") then return t end
        end
    end
    return nil
end

local function counterMedusa(statusLbl, countLbl)
    local now = tick()
    if now - medusaLastFire < 1.5 then return end
    medusaLastFire = now
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local tool = findMedusaTool()
    if not tool then
        if statusLbl then
            statusLbl.Text = "No Medusa tool!"
            statusLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
            task.delay(1.5, function()
                if medusaEnabled and statusLbl then
                    statusLbl.Text = "Watching..."
                    statusLbl.TextColor3 = Color3.fromRGB(52, 218, 88)
                end
            end)
        end
        return
    end
    if tool.Parent ~= char then
        hum:EquipTool(tool)
    end
    pcall(function() tool:Activate() end)
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            pcall(function() v:FireServer() end)
        end
    end
    medusaCounterCount = medusaCounterCount + 1
    if countLbl then countLbl.Text = "Counters: " .. medusaCounterCount end
    if statusLbl then
        statusLbl.Text = "COUNTERED!"
        statusLbl.TextColor3 = Color3.fromRGB(200, 140, 255)
        task.delay(1.2, function()
            if medusaEnabled and statusLbl then
                statusLbl.Text = "Watching..."
                statusLbl.TextColor3 = Color3.fromRGB(52, 218, 88)
            end
        end)
    end
end

local function stopMedusaCounter()
    medusaEnabled = false
    for _, c in ipairs(medusaConnections) do
        pcall(function() c:Disconnect() end)
    end
    medusaConnections = {}
    if medusaGui then
        pcall(function() medusaGui:Destroy() end)
        medusaGui = nil
    end
end

local function startMedusaCounter()
    stopMedusaCounter()
    medusaEnabled = true

    local function hookCharacter(char)
        local head = char:WaitForChild("Head", 5)
        if head then
            table.insert(medusaConnections, head:GetPropertyChangedSignal("Anchored"):Connect(function()
                if not medusaEnabled then return end
                if head.Anchored then
                    task.spawn(function() counterMedusa(nil, nil) end)
                end
            end))
        end
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        if not torso then
            torso = char:WaitForChild("UpperTorso", 3)
        end
        if torso then
            table.insert(medusaConnections, torso:GetPropertyChangedSignal("Anchored"):Connect(function()
                if not medusaEnabled then return end
                if torso.Anchored then
                    task.spawn(function() counterMedusa(nil, nil) end)
                end
            end))
        end
    end

    if LocalPlayer.Character then
        task.spawn(function() hookCharacter(LocalPlayer.Character) end)
    end
    table.insert(medusaConnections, LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        if medusaEnabled then
            hookCharacter(char)
        end
    end))
end

local GetMedusaCounter = MakeToggle("Medusa Counter", 10, false, function(state)
    if state then startMedusaCounter() else stopMedusaCounter() end
end)

-- Auto Tp Down
local TpRow = Instance.new("Frame")
TpRow.Name = "AutoTpDownRow"
TpRow.Parent = ContentScroll
TpRow.Size = UDim2.new(1, -8, 0, 36)
TpRow.BackgroundTransparency = 1
TpRow.LayoutOrder = 11
TpRow.ZIndex = 62

local TpLabel = Instance.new("TextLabel")
TpLabel.Parent = TpRow
TpLabel.Size = UDim2.new(0.38, 0, 1, 0)
TpLabel.Position = UDim2.new(0, 0, 0, 0)
TpLabel.BackgroundTransparency = 1
TpLabel.Text = "Auto Tp Down"
TpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TpLabel.TextSize = 15
TpLabel.Font = Enum.Font.GothamBold
TpLabel.TextXAlignment = Enum.TextXAlignment.Left
TpLabel.ZIndex = 63

local TpBox = Instance.new("TextBox")
TpBox.Name = "AutoTpDownBox"
TpBox.Parent = TpRow
TpBox.Size = UDim2.new(0, 44, 0, 28)
TpBox.Position = UDim2.new(0.40, 0, 0.5, -14)
TpBox.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
TpBox.BackgroundTransparency = 0.25
TpBox.Text = "20"
TpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TpBox.TextSize = 14
TpBox.Font = Enum.Font.Gotham
TpBox.ClearTextOnFocus = false
TpBox.ZIndex = 63

local TpBoxCorner = Instance.new("UICorner")
TpBoxCorner.CornerRadius = UDim.new(0, 6)
TpBoxCorner.Parent = TpBox

local TpBoxStroke = Instance.new("UIStroke")
TpBoxStroke.Parent = TpBox
TpBoxStroke.Color = Color3.fromRGB(255, 255, 255)
TpBoxStroke.Thickness = 1.5
TpBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

TpBox:GetPropertyChangedSignal("Text"):Connect(function()
    local filtered = TpBox.Text:gsub("[^0-9]", "")
    if TpBox.Text ~= filtered then
        TpBox.Text = filtered
    end
end)

local TpTrack = Instance.new("Frame")
TpTrack.Name = "Track"
TpTrack.Parent = TpRow
TpTrack.Size = UDim2.new(0, 52, 0, 26)
TpTrack.Position = UDim2.new(1, -52, 0.5, -13)
TpTrack.BackgroundColor3 = Color3.fromRGB(40, 42, 55)
TpTrack.ZIndex = 63

local TpTrackCorner = Instance.new("UICorner")
TpTrackCorner.CornerRadius = UDim.new(1, 0)
TpTrackCorner.Parent = TpTrack

local TpTrackStroke = Instance.new("UIStroke")
TpTrackStroke.Parent = TpTrack
TpTrackStroke.Color = Color3.fromRGB(255, 255, 255)
TpTrackStroke.Thickness = 1.2

local TpKnob = Instance.new("Frame")
TpKnob.Name = "Knob"
TpKnob.Parent = TpTrack
TpKnob.Size = UDim2.new(0, 22, 0, 22)
TpKnob.Position = UDim2.new(0, 2, 0.5, -11)
TpKnob.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
TpKnob.ZIndex = 64

local TpKnobCorner = Instance.new("UICorner")
TpKnobCorner.CornerRadius = UDim.new(1, 0)
TpKnobCorner.Parent = TpKnob

local TpHit = Instance.new("TextButton")
TpHit.Parent = TpTrack
TpHit.Size = UDim2.new(1, 0, 1, 0)
TpHit.BackgroundTransparency = 1
TpHit.Text = ""
TpHit.ZIndex = 65

local tpOn = false
local autoTpDownConn = nil
local autoTpDownCooldown = 0

local function stopAutoTpDownLoop()
    if autoTpDownConn then
        autoTpDownConn:Disconnect()
        autoTpDownConn = nil
    end
end

local function startAutoTpDownLoop()
    stopAutoTpDownLoop()
    autoTpDownConn = RunService.Heartbeat:Connect(function()
        if not tpOn then return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local spawnY = savedSpawnY
        if spawnY == nil then return end
        local threshold = tonumber(TpBox and TpBox.Text) or 20
        if not threshold or threshold < 1 then threshold = 20 end
        -- Spawn'dan threshold (varsayılan 20) blok yukarı çıkınca
        -- mevcut XZ'de yere (spawn Y) TP — spawn noktasına fırlatmaz
        if root.Position.Y >= (spawnY + threshold) then
            local now = tick()
            if now - autoTpDownCooldown < 0.4 then return end
            autoTpDownCooldown = now
            local px, pz = root.Position.X, root.Position.Z
            pcall(function()
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                root.CFrame = CFrame.new(px, spawnY, pz)
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end)
end

TpHit.MouseButton1Click:Connect(function()
    tpOn = not tpOn
    local goalPos = tpOn and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
    local goalColor = tpOn and Color3.fromRGB(150, 155, 170) or Color3.fromRGB(40, 42, 55)
    TweenService:Create(TpKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = goalPos
    }):Play()
    TweenService:Create(TpTrack, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = goalColor
    }):Play()
    if tpOn then
        startAutoTpDownLoop()
    else
        stopAutoTpDownLoop()
    end
end)

----------------------------------------------------------------
-- VISUAL SECTION (Tryard Animation / No Animation / Anti Lag)
----------------------------------------------------------------
MakeSectionTitle("Visual", 12)

-- ========== TRYARD ANIMATION ==========
local ContentProvider = game:GetService("ContentProvider")
local TryardAnims = {
    idle1 = "rbxassetid://133806214992291",
    idle2 = "rbxassetid://94970088341563",
    walk  = "rbxassetid://707897309",
    run   = "rbxassetid://707861613",
    jump  = "rbxassetid://116936326516985",
    fall  = "rbxassetid://116936326516985",
    climb = "rbxassetid://116936326516985",
    swim  = "rbxassetid://116936326516985",
    swimidle = "rbxassetid://116936326516985",
}
task.spawn(function()
    pcall(function()
        ContentProvider:PreloadAsync({
            TryardAnims.idle1, TryardAnims.idle2, TryardAnims.walk, TryardAnims.run,
            TryardAnims.jump, TryardAnims.fall, TryardAnims.climb, TryardAnims.swim, TryardAnims.swimidle,
        })
    end)
end)

local tryardHeartbeatConn = nil
local originalTryardAnims = nil
local tryardAnimEnabled = false
local noAnimationEnabled = false

local function isTryardPackAnim(id)
    for _, v in pairs(TryardAnims) do
        if v == id then return true end
    end
    return false
end

local function saveOriginalTryardAnims(char)
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    local function g(obj) return obj and obj.AnimationId or nil end
    local ids = {
        idle1 = g(animate.idle and animate.idle.Animation1),
        idle2 = g(animate.idle and animate.idle.Animation2),
        walk  = g(animate.walk and animate.walk.WalkAnim),
        run   = g(animate.run  and animate.run.RunAnim),
        jump  = g(animate.jump and animate.jump.JumpAnim),
        fall  = g(animate.fall and animate.fall.FallAnim),
        climb = g(animate.climb and animate.climb.ClimbAnim),
        swim  = g(animate.swim and animate.swim.Swim),
        swimidle = g(animate.swimidle and animate.swimidle.SwimIdle),
    }
    if not isTryardPackAnim(ids.walk) then
        originalTryardAnims = ids
    end
end

local function applyTryardAnimPack(char)
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    local function s(obj, id) if obj then obj.AnimationId = id end end
    s(animate.idle and animate.idle.Animation1, TryardAnims.idle1)
    s(animate.idle and animate.idle.Animation2, TryardAnims.idle2)
    s(animate.walk and animate.walk.WalkAnim, TryardAnims.walk)
    s(animate.run  and animate.run.RunAnim,   TryardAnims.run)
    s(animate.jump and animate.jump.JumpAnim, TryardAnims.jump)
    s(animate.fall and animate.fall.FallAnim, TryardAnims.fall)
    s(animate.climb and animate.climb.ClimbAnim, TryardAnims.climb)
    s(animate.swim and animate.swim.Swim, TryardAnims.swim)
    s(animate.swimidle and animate.swimidle.SwimIdle, TryardAnims.swimidle)
end

local function stopTryardAnim()
    if tryardHeartbeatConn then
        tryardHeartbeatConn:Disconnect()
        tryardHeartbeatConn = nil
    end
    if originalTryardAnims and LocalPlayer.Character then
        local animate = LocalPlayer.Character:FindFirstChild("Animate")
        if animate then
            local function s(obj, id) if obj then obj.AnimationId = id end end
            s(animate.idle and animate.idle.Animation1, originalTryardAnims.idle1)
            s(animate.idle and animate.idle.Animation2, originalTryardAnims.idle2)
            s(animate.walk and animate.walk.WalkAnim, originalTryardAnims.walk)
            s(animate.run  and animate.run.RunAnim,   originalTryardAnims.run)
            s(animate.jump and animate.jump.JumpAnim, originalTryardAnims.jump)
            s(animate.fall and animate.fall.FallAnim, originalTryardAnims.fall)
            s(animate.climb and animate.climb.ClimbAnim, originalTryardAnims.climb)
            s(animate.swim and animate.swim.Swim, originalTryardAnims.swim)
            s(animate.swimidle and animate.swimidle.SwimIdle, originalTryardAnims.swimidle)
        end
    end
end

local function startTryardAnim()
    if tryardHeartbeatConn then tryardHeartbeatConn:Disconnect() end
    local char = LocalPlayer.Character
    if char then
        saveOriginalTryardAnims(char)
        applyTryardAnimPack(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                track:Stop(0)
            end
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
    tryardHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not tryardAnimEnabled or noAnimationEnabled then return end
        local c = LocalPlayer.Character
        if c then applyTryardAnimPack(c) end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if tryardAnimEnabled and not noAnimationEnabled then
        saveOriginalTryardAnims(char)
        applyTryardAnimPack(char)
    end
end)

local GetTryardAnim = MakeToggle("Tryard Animation", 13, false, function(state)
    tryardAnimEnabled = state
    if state then
        if noAnimationEnabled then return end -- No Animation açıksa uygulama
        startTryardAnim()
    else
        stopTryardAnim()
    end
end)

-- ========== NO ANIMATION ==========
local noAnimConn = nil
local function startNoAnimation()
    stopTryardAnim() -- Tryard'ı durdur (toggle state aynı kalır, sadece uygulama kesilir)
    local function clearTracks(char)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0) end)
            end
        end
        local animate = char and char:FindFirstChild("Animate")
        if animate then
            pcall(function() animate.Disabled = true end)
        end
    end
    if LocalPlayer.Character then clearTracks(LocalPlayer.Character) end
    if noAnimConn then noAnimConn:Disconnect() end
    noAnimConn = RunService.Heartbeat:Connect(function()
        if not noAnimationEnabled then return end
        local c = LocalPlayer.Character
        if c then clearTracks(c) end
    end)
end

local function stopNoAnimation()
    if noAnimConn then
        noAnimConn:Disconnect()
        noAnimConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        local animate = char:FindFirstChild("Animate")
        if animate then
            pcall(function() animate.Disabled = false end)
        end
    end
end

local GetNoAnimation = MakeToggle("No Animation", 14, false, function(state)
    noAnimationEnabled = state
    if state then
        startNoAnimation()
    else
        stopNoAnimation()
        -- Eğer Tryard açıksa tekrar başlat
        if tryardAnimEnabled then
            startTryardAnim()
        end
    end
end)

-- ========== ANTI LAG (sadece logic, GUI yok) ==========
local antiLagEnabled = false
local antiLagConnections = {}

local function cleanupAntiLag()
    for _, conn in ipairs(antiLagConnections) do
        pcall(function()
            if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
        end)
    end
    antiLagConnections = {}
end

local function startAntiLag()
    cleanupAntiLag()
    local Workspace = game:GetService("Workspace")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local function isProtectedInteraction(obj)
        if not obj then return false end
        if obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildOfClass("ClickDetector") or obj:FindFirstChildOfClass("SurfaceGui") then
            return true
        end
        if obj.Parent and (obj.Parent:FindFirstChildOfClass("ProximityPrompt") or obj.Parent:FindFirstChildOfClass("ClickDetector")) then
            return true
        end
        return false
    end

    local function stopAllOtherAnimations()
        pcall(function()
            local function checkAndDestroyAnim(obj)
                pcall(function()
                    if obj:IsA("Animator") or obj:IsA("Animation") or obj:IsA("AnimationTrack") then
                        local myChar = LocalPlayer.Character
                        if myChar and obj:IsDescendantOf(myChar) then return end
                        obj:Destroy()
                    end
                end)
            end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                checkAndDestroyAnim(obj)
            end
            local descConn = Workspace.DescendantAdded:Connect(function(descendant)
                task.defer(function() checkAndDestroyAnim(descendant) end)
            end)
            table.insert(antiLagConnections, descConn)
        end)
    end

    local function applyUltraAntiLag()
        pcall(function()
            local s = settings()
            if s and s.Rendering then
                pcall(function() s.Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
                pcall(function() s.Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04 end)
            end
            if setfpscap then pcall(function() setfpscap(360) end) end
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 1
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
            Lighting.ShadowSoftness = 0
            if workspace:FindFirstChildOfClass("Terrain") then
                local terrain = workspace:FindFirstChildOfClass("Terrain")
                terrain.Decoration = false
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 1
            end
            for _, effect in ipairs(Lighting:GetDescendants()) do
                pcall(function()
                    if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("DepthOfFieldEffect") or effect:IsA("Atmosphere") then
                        effect.Enabled = false
                        effect:Destroy()
                    end
                end)
            end
        end)
    end

    local function runUploadedScriptsLogic()
        pcall(function()
            local function processUploaded(obj)
                pcall(function()
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                        obj.Enabled = false
                        obj:Destroy()
                    elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceAppearance") then
                        obj:Destroy()
                    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                        obj.Enabled = false
                        obj:Destroy()
                    elseif obj:IsA("BasePart") and not obj:IsA("Terrain") then
                        obj.Material = Enum.Material.Plastic
                        obj.Reflectance = 0
                        obj.CastShadow = false
                        if obj:IsA("MeshPart") then
                            obj.TextureID = ""
                        end
                    elseif obj:IsA("Accessory") or obj:IsA("Hat") or obj:IsA("ShirtGraphic") or obj:IsA("Clothing") then
                        obj:Destroy()
                    end
                end)
            end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                processUploaded(obj)
            end
            local dConn = Workspace.DescendantAdded:Connect(function(descendant)
                task.defer(function() processUploaded(descendant) end)
            end)
            table.insert(antiLagConnections, dConn)

            local function stripAccessories(char)
                pcall(function()
                    for _, item in ipairs(char:GetChildren()) do
                        if item:IsA("Accessory") or item:IsA("Hat") or item:IsA("ShirtGraphic") then
                            item:Destroy()
                        end
                    end
                end)
            end
            for _, plr in ipairs(Players:GetPlayers()) do
                pcall(function()
                    if plr.Character then stripAccessories(plr.Character) end
                end)
            end
            local pConn = Players.PlayerAdded:Connect(function(plr)
                pcall(function()
                    plr.CharacterAdded:Connect(stripAccessories)
                end)
            end)
            table.insert(antiLagConnections, pConn)
        end)
    end

    local function runDistanceClean()
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local processed = 0
            for _, obj in ipairs(Workspace:GetDescendants()) do
                pcall(function()
                    if obj:IsA("BasePart") and not obj:IsDescendantOf(char) and not obj:IsA("Terrain") then
                        if not isProtectedInteraction(obj) then
                            local dist = (hrp.Position - obj.Position).Magnitude
                            if dist > 1000 then
                                obj:Destroy()
                            end
                        end
                    end
                end)
                processed = processed + 1
                if processed % 500 == 0 then task.wait(0.005) end
            end
        end)
    end

    local function runGarbageClean()
        pcall(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                pcall(function()
                    if obj:IsA("Sound") then
                        obj.Playing = false
                        obj:Destroy()
                    end
                end)
            end
        end)
    end

    task.spawn(function()
        pcall(applyUltraAntiLag)
        task.wait(0.05)
        pcall(stopAllOtherAnimations)
        task.wait(0.05)
        pcall(runUploadedScriptsLogic)
        task.wait(0.05)
        pcall(runDistanceClean)
        task.wait(0.05)
        pcall(runGarbageClean)
        pcall(function() ContentProvider:PreloadAsync({}) end)
    end)
end

local GetAntiLag = MakeToggle("Anti Lag", 15, false, function(state)
    antiLagEnabled = state
    if state then
        startAntiLag()
    else
        cleanupAntiLag()
    end
end)

----------------------------------------------------------------
-- BAT AIMBOT PANEL
----------------------------------------------------------------
MakeSectionTitle("Bat Aimbot", 16)
local BatAimbotSpeedBox = MakeRow("Bat Aimbot Speed", tostring(getgenv().LightHubConfig.BatAimbotSpeed or 65), 17)
BatAimbotSpeedBox.FocusLost:Connect(function()
    local num = tonumber(BatAimbotSpeedBox.Text)
    if num then
        getgenv().LightHubConfig.BatAimbotSpeed = num
        SaveConfig()
    else
        BatAimbotSpeedBox.Text = tostring(getgenv().LightHubConfig.BatAimbotSpeed or 65)
    end
end)

----------------------------------------------------------------
-- KEYBINDS (Console Mode + PC Keybinds)
----------------------------------------------------------------
local KEYBIND_DISPLAY = {
    DPadLeft = "←", DPadRight = "→", DPadUp = "↑", DPadDown = "↓",
    ButtonA = "✕", ButtonB = "○", ButtonX = "□", ButtonY = "△",
    ButtonL1 = "L1", ButtonR1 = "R1", ButtonL2 = "L2", ButtonR2 = "R2",
    ButtonL3 = "L3", ButtonR3 = "R3",
    ButtonStart = "Options", ButtonSelect = "Share",
}

local KEYBIND_ACTIONS = {
    "Auto Left", "Auto Right", "Tp down", "Bat Aimbot",
    "Carry Speed", "Reset", "Lagger Speed", "Drop Brainrot",
}

local PC_KEYBIND_ACTIONS = {
    "Auto Left", "Auto Right", "Drop Brainrot", "Reset",
    "Bat Aimbot", "Tp down", "Carry Speed", "Lagger Speed", "Lagger Steal",
}

if not getgenv().LightHubConfig.Keybinds then
    getgenv().LightHubConfig.Keybinds = {
        ["Auto Left"] = "DPadLeft", ["Auto Right"] = "DPadRight",
        ["Tp down"] = "DPadDown", ["Bat Aimbot"] = "ButtonB",
        ["Carry Speed"] = "ButtonL3", ["Reset"] = "ButtonY",
        ["Lagger Speed"] = "ButtonR3", ["Drop Brainrot"] = "ButtonX",
    }
end
if not getgenv().LightHubConfig.Keybinds["Drop Brainrot"] then
    getgenv().LightHubConfig.Keybinds["Drop Brainrot"] = "ButtonX"
end
if not getgenv().LightHubConfig.PCKeybinds then
    getgenv().LightHubConfig.PCKeybinds = {
        ["Auto Left"] = "L", ["Auto Right"] = "R", ["Drop Brainrot"] = "K",
        ["Reset"] = "T", ["Bat Aimbot"] = "B", ["Tp down"] = "Q",
        ["Carry Speed"] = "C", ["Lagger Speed"] = "J", ["Lagger Steal"] = "G",
    }
end
if getgenv().LightHubConfig.PCKeybinds["Drop Brainrot"] == "D" then
    getgenv().LightHubConfig.PCKeybinds["Drop Brainrot"] = "K"
end

local function updateKeybindLabels()
    local consoleOn = getgenv().LightHubConfig.ConsoleMode
    local pcOn = getgenv().LightHubConfig.PCKeybindsEnabled
    local binds = getgenv().LightHubConfig.Keybinds or {}
    local pcBinds = getgenv().LightHubConfig.PCKeybinds or {}
    for action, label in pairs(ButtonKeyLabels) do
        if consoleOn then
            if binds[action] then
                label.Text = KEYBIND_DISPLAY[binds[action]] or binds[action]
                label.Visible = true
            elseif action == "Lagger Steal" then
                label.Text = "L3"
                label.Visible = true
            else
                label.Text = ""
                label.Visible = false
            end
        elseif pcOn and pcBinds[action] then
            label.Text = pcBinds[action]
            label.Visible = true
        else
            label.Text = ""
            label.Visible = false
        end
    end
end

local waitingForRebind = nil -- "console:Action" or "pc:Action"
local rebindButtons = {}
local pcRebindButtons = {}

local function fireDropBrainrot()
    local b, s = Buttons["Drop Brainrot"], ButtonStrokes["Drop Brainrot"]
    if b then
        setButtonVisual(b, s, true)
        task.delay(0.2, function() setButtonVisual(b, s, false) end)
    end
    local dropTypeBtn = ScreenGui:FindFirstChild("LightHubPanel")
        and ScreenGui.LightHubPanel:FindFirstChild("ContentScroll")
        and ScreenGui.LightHubPanel.ContentScroll:FindFirstChild("DropTypeRow")
        and ScreenGui.LightHubPanel.ContentScroll.DropTypeRow:FindFirstChild("DropTypeBtn")
    local currentDropType = dropTypeBtn and dropTypeBtn.Text or "walkfling"
    if currentDropType == "walkfling" then
        walkfling(true)
        task.delay(0.7, function()
            walkfling(false)
            getgenv().LightHubConfig.SpeedBoostEnabled = true
            getgenv().LightHubConfig.MultiJumpEnabled = true
            SaveConfig()
            if LocalPlayer.Character then setupBoost(LocalPlayer.Character) end
            if _G.LightHub_SetMultiJumpVisual then _G.LightHub_SetMultiJumpVisual(true) end
        end)
    elseif currentDropType == "high jump" then
        doStrongJumpOnce()
        task.delay(0.6, function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local y = (savedSpawnY or root.Position.Y) - 3
            root.CFrame = CFrame.new(root.Position.X, y, root.Position.Z)
        end)
    end
end

local function triggerScreenButton(actionName)
    if actionName == "Carry Speed" then
        local cfg = getgenv().LightHubConfig
        if cfg.SpeedMode == "carry" then
            updateSpeedMode("normal")
        elseif cfg.SpeedMode == "lagger_carry" then
            updateSpeedMode("lagger")
            if Buttons["Lagger Steal"] then
                setButtonVisual(Buttons["Lagger Steal"], ButtonStrokes["Lagger Steal"], false)
                ButtonToggled["Lagger Steal"] = false
            end
        elseif cfg.SpeedMode == "lagger" then
            updateSpeedMode("lagger_carry")
        else
            updateSpeedMode("carry")
        end
    elseif actionName == "Lagger Speed" then
        local cfg = getgenv().LightHubConfig
        if cfg.SpeedMode == "lagger" or cfg.SpeedMode == "lagger_carry" then
            updateSpeedMode("normal")
        else
            updateSpeedMode("lagger")
        end
    elseif actionName == "Lagger Steal" then
        local cfg = getgenv().LightHubConfig
        if cfg.SpeedMode == "lagger_carry" then
            updateSpeedMode("lagger")
            if Buttons["Lagger Steal"] then
                setButtonVisual(Buttons["Lagger Steal"], ButtonStrokes["Lagger Steal"], false)
                ButtonToggled["Lagger Steal"] = false
            end
        else
            updateSpeedMode("lagger_carry")
        end
    elseif actionName == "Bat Aimbot" then
        ButtonToggled["Bat Aimbot"] = not ButtonToggled["Bat Aimbot"]
        setButtonVisual(Buttons["Bat Aimbot"], ButtonStrokes["Bat Aimbot"], ButtonToggled["Bat Aimbot"])
        getgenv().LightHubConfig.BatAimbotEnabled = ButtonToggled["Bat Aimbot"]
        SaveConfig()
        if ButtonToggled["Bat Aimbot"] then startBatAimbot() else stopBatAimbot() end
    elseif actionName == "Drop Brainrot" then
        fireDropBrainrot()
    elseif actionName == "Tp down" then
        local b, s = Buttons[actionName], ButtonStrokes[actionName]
        if b then
            setButtonVisual(b, s, true)
            task.delay(0.2, function() setButtonVisual(b, s, false) end)
        end
        doTpDown()
    elseif actionName == "Reset" then
        local b, s = Buttons[actionName], ButtonStrokes[actionName]
        if b then
            setButtonVisual(b, s, true)
            task.delay(0.2, function() setButtonVisual(b, s, false) end)
        end
        task.spawn(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local start = tick()
            local spinConn
            spinConn = RunService.Heartbeat:Connect(function()
                if tick() - start > 3 then
                    if spinConn then spinConn:Disconnect() end
                    pcall(function()
                        root.AssemblyAngularVelocity = Vector3.zero
                        root.RotVelocity = Vector3.zero
                    end)
                    return
                end
                pcall(function()
                    root.AssemblyAngularVelocity = Vector3.new(0, 999999999999999999999, 0)
                    root.RotVelocity = Vector3.new(0, 999999999999999999999, 0)
                end)
            end)
        end)
    else
        ButtonToggled[actionName] = not ButtonToggled[actionName]
        if Buttons[actionName] then
            setButtonVisual(Buttons[actionName], ButtonStrokes[actionName], ButtonToggled[actionName])
        end
    end
end

-- Console (Gamepad) input
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    safeCall(function()
    local isPad = input.UserInputType == Enum.UserInputType.Gamepad1
        or input.UserInputType == Enum.UserInputType.Gamepad2
        or input.UserInputType == Enum.UserInputType.Gamepad3
        or input.UserInputType == Enum.UserInputType.Gamepad4
    local isKey = input.UserInputType == Enum.UserInputType.Keyboard
    if not isPad and not isKey then return end

    local codeName = input.KeyCode.Name

    -- Rebind
    if waitingForRebind then
        local mode, action = waitingForRebind:match("^(%w+):(.+)$")
        if mode == "console" and isPad then
            getgenv().LightHubConfig.Keybinds[action] = codeName
            SaveConfig()
            if rebindButtons[action] then
                rebindButtons[action].Text = KEYBIND_DISPLAY[codeName] or codeName
                rebindButtons[action].BackgroundColor3 = Color3.fromRGB(30, 34, 48)
            end
            updateKeybindLabels()
            waitingForRebind = nil
            return
        elseif mode == "pc" and isKey then
            getgenv().LightHubConfig.PCKeybinds[action] = codeName
            SaveConfig()
            if pcRebindButtons[action] then
                pcRebindButtons[action].Text = codeName
                pcRebindButtons[action].BackgroundColor3 = Color3.fromRGB(30, 34, 48)
            end
            updateKeybindLabels()
            waitingForRebind = nil
            return
        end
    end

    if isPad and getgenv().LightHubConfig.ConsoleMode then
        local binds = getgenv().LightHubConfig.Keybinds or {}
        for action, bindName in pairs(binds) do
            if bindName == codeName then
                safeCall(function() triggerScreenButton(action) end)
                return
            end
        end
    end

    if isKey and getgenv().LightHubConfig.PCKeybindsEnabled then
        if UserInputService:GetFocusedTextBox() then return end
        local binds = getgenv().LightHubConfig.PCKeybinds or {}
        for action, bindName in pairs(binds) do
            if bindName == codeName then
                safeCall(function() triggerScreenButton(action) end)
                return
            end
        end
    end
    end) -- safeCall InputBegan
end)

MakeSectionTitle("Keybinds", 18)

local SetPCKeybindsVisual = nil -- forward
local GetConsoleMode, SetConsoleModeVisual = MakeToggle("Console Mode", 19, getgenv().LightHubConfig.ConsoleMode == true, function(state)
    getgenv().LightHubConfig.ConsoleMode = state
    if state then
        getgenv().LightHubConfig.PCKeybindsEnabled = false
        if SetPCKeybindsVisual then SetPCKeybindsVisual(false) end
    end
    SaveConfig()
    updateKeybindLabels()
end)

local keybindOrder = 20
for _, action in ipairs(KEYBIND_ACTIONS) do
    local row = Instance.new("Frame")
    row.Parent = ContentScroll
    row.Size = UDim2.new(1, -8, 0, 32)
    row.BackgroundTransparency = 1
    row.LayoutOrder = keybindOrder
    row.ZIndex = 62
    keybindOrder = keybindOrder + 1

    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.Size = UDim2.new(0.55, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = action == "Lagger Speed" and "Lagger Mode" or action
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 63

    local codeName = (getgenv().LightHubConfig.Keybinds and getgenv().LightHubConfig.Keybinds[action]) or "?"
    local rebindBtn = Instance.new("TextButton")
    rebindBtn.Parent = row
    rebindBtn.Size = UDim2.new(0.40, 0, 0, 26)
    rebindBtn.Position = UDim2.new(0.58, 0, 0.5, -13)
    rebindBtn.BackgroundColor3 = Color3.fromRGB(30, 34, 48)
    rebindBtn.BackgroundTransparency = 0.15
    rebindBtn.Text = KEYBIND_DISPLAY[codeName] or codeName
    rebindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rebindBtn.TextSize = 13
    rebindBtn.Font = Enum.Font.GothamBold
    rebindBtn.AutoButtonColor = false
    rebindBtn.ZIndex = 63
    Instance.new("UICorner", rebindBtn).CornerRadius = UDim.new(0, 6)
    -- Çizgi yok (okunabilirlik)

    rebindButtons[action] = rebindBtn

    rebindBtn.MouseButton1Click:Connect(function()
        if not getgenv().LightHubConfig.ConsoleMode then
            rebindBtn.Text = "Console ON!"
            task.delay(0.8, function()
                local cn = getgenv().LightHubConfig.Keybinds[action]
                rebindBtn.Text = KEYBIND_DISPLAY[cn] or cn or "?"
            end)
            return
        end
        waitingForRebind = "console:" .. action
        rebindBtn.Text = "..."
        rebindBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 20)
    end)
end

-- PC Keybinds
MakeSectionTitle("PC Keybinds", keybindOrder)
keybindOrder = keybindOrder + 1

local GetPCKeybinds
GetPCKeybinds, SetPCKeybindsVisual = MakeToggle("PC Keybinds", keybindOrder, getgenv().LightHubConfig.PCKeybindsEnabled == true, function(state)
    getgenv().LightHubConfig.PCKeybindsEnabled = state
    if state then
        getgenv().LightHubConfig.ConsoleMode = false
        if SetConsoleModeVisual then SetConsoleModeVisual(false) end
    end
    SaveConfig()
    updateKeybindLabels()
end)
keybindOrder = keybindOrder + 1

for _, action in ipairs(PC_KEYBIND_ACTIONS) do
    local row = Instance.new("Frame")
    row.Parent = ContentScroll
    row.Size = UDim2.new(1, -8, 0, 32)
    row.BackgroundTransparency = 1
    row.LayoutOrder = keybindOrder
    row.ZIndex = 62
    keybindOrder = keybindOrder + 1

    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.Size = UDim2.new(0.55, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = action == "Lagger Speed" and "Lagger Mode" or action
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 63

    local codeName = (getgenv().LightHubConfig.PCKeybinds and getgenv().LightHubConfig.PCKeybinds[action]) or "?"
    local rebindBtn = Instance.new("TextButton")
    rebindBtn.Parent = row
    rebindBtn.Size = UDim2.new(0.40, 0, 0, 26)
    rebindBtn.Position = UDim2.new(0.58, 0, 0.5, -13)
    rebindBtn.BackgroundColor3 = Color3.fromRGB(30, 34, 48)
    rebindBtn.BackgroundTransparency = 0.15
    rebindBtn.Text = codeName
    rebindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rebindBtn.TextSize = 13
    rebindBtn.Font = Enum.Font.GothamBold
    rebindBtn.AutoButtonColor = false
    rebindBtn.ZIndex = 63
    Instance.new("UICorner", rebindBtn).CornerRadius = UDim.new(0, 6)

    pcRebindButtons[action] = rebindBtn

    rebindBtn.MouseButton1Click:Connect(function()
        if not getgenv().LightHubConfig.PCKeybindsEnabled then
            rebindBtn.Text = "PC ON!"
            task.delay(0.8, function()
                local cn = getgenv().LightHubConfig.PCKeybinds[action]
                rebindBtn.Text = cn or "?"
            end)
            return
        end
        waitingForRebind = "pc:" .. action
        rebindBtn.Text = "..."
        rebindBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 20)
    end)
end

updateKeybindLabels()

----------------------------------------------------------------
-- INTRO SETTINGS + MUSIC
----------------------------------------------------------------
local musicURLs = {
    "https://files.catbox.moe/zuid5n.mp3",
    "https://files.catbox.moe/z6eqnt.mp3",
    "https://files.catbox.moe/t0nlhv.mp3",
    "https://files.catbox.moe/mthg31.mp3",
    "https://files.catbox.moe/ddnbup.mp3",
    "https://files.catbox.moe/hg5cr4.mp3",
    "https://files.catbox.moe/nps6gk.mp3",
    "https://files.catbox.moe/iyw1cb.mp3",
    "https://files.catbox.moe/2w0wtv.mp3",
}

local SONG_CACHE_PREFIX = "LightHubSongCache_"
local songAssetCache = {} -- idx -> custom asset id
local currentPreviewSound = nil
local introMusicSound = nil
local introSongReady = false

local function stopPreview()
    if currentPreviewSound then
        pcall(function() currentPreviewSound:Stop() end)
        pcall(function() currentPreviewSound:Destroy() end)
        currentPreviewSound = nil
    end
end

local function stopIntroMusic()
    if introMusicSound then
        pcall(function() introMusicSound:Stop() end)
        pcall(function() introMusicSound:Destroy() end)
        introMusicSound = nil
    end
end

local function loadSongAsset(idx)
    if songAssetCache[idx] then
        return songAssetCache[idx]
    end
    local cacheFile = SONG_CACHE_PREFIX .. tostring(idx) .. ".mp3"
    local ok, assetId = pcall(function()
        if isfile and isfile(cacheFile) then
            return getcustomasset(cacheFile)
        end
        local data = game:HttpGet(musicURLs[idx])
        writefile(cacheFile, data)
        return getcustomasset(cacheFile)
    end)
    if ok and assetId then
        songAssetCache[idx] = assetId
        return assetId
    end
    return nil
end

local function playPreview(idx)
    stopPreview()
    -- Intro müziğini kesme: sadece preview değiştir
    task.spawn(function()
        local ok, err = pcall(function()
            local assetId = loadSongAsset(idx)
            if not assetId then return end
            local parent = (gethui and gethui()) or CoreGui
            local snd = Instance.new("Sound")
            snd.Name = "LH_SongPreview"
            snd.Parent = parent
            snd.SoundId = assetId
            snd.Volume = 0.55
            snd.Looped = false
            currentPreviewSound = snd
            -- Tam yükleme: IsLoaded + TimeLength
            local t0 = tick()
            while tick() - t0 < 15 do
                if currentPreviewSound ~= snd then return end
                if snd.IsLoaded and (snd.TimeLength or 0) > 0.5 then
                    break
                end
                task.wait(0.08)
            end
            if currentPreviewSound ~= snd then return end
            if not snd.IsLoaded then
                -- Yine de dene
                pcall(function() snd:Play() end)
                return
            end
            snd.TimePosition = 0
            snd:Play()
            -- Kesme yok: şarkı bitince temizle
            local endedConn
            endedConn = snd.Ended:Connect(function()
                if endedConn then endedConn:Disconnect() end
                if currentPreviewSound == snd then
                    stopPreview()
                end
            end)
        end)
        if not ok then
            warn("[LightHub] playPreview error:", err)
        end
    end)
end

local function playIntroSong()
    stopIntroMusic()
    stopPreview()
    local idx = tonumber(getgenv().LightHubConfig.IntroSongIndex) or 1
    if idx < 1 then idx = 1 end
    if idx > #musicURLs then idx = #musicURLs end
    local assetId = loadSongAsset(idx)
    if not assetId then return false end
    local ok = pcall(function()
        local parent = (gethui and gethui()) or CoreGui
        local snd = Instance.new("Sound")
        snd.Name = "LH_IntroSong"
        snd.Parent = parent
        snd.SoundId = assetId
        snd.Volume = 0.6
        snd.Looped = false
        introMusicSound = snd
        local t0 = tick()
        while tick() - t0 < 15 do
            if introMusicSound ~= snd then return end
            if snd.IsLoaded and (snd.TimeLength or 0) > 0.5 then
                break
            end
            task.wait(0.08)
        end
        if introMusicSound ~= snd then return end
        snd.TimePosition = 0
        snd:Play()
        local endedConn
        endedConn = snd.Ended:Connect(function()
            if endedConn then endedConn:Disconnect() end
            if introMusicSound == snd then
                stopIntroMusic()
            end
        end)
    end)
    return ok
end

-- Önce seçili şarkıyı yükle, sonra diğerlerini arka planda cache'le
local function preloadAllSongs(priorityIdx)
    priorityIdx = priorityIdx or 1
    local ok = pcall(function()
        loadSongAsset(priorityIdx)
    end)
    introSongReady = ok
    task.spawn(function()
        for i = 1, #musicURLs do
            if i ~= priorityIdx then
                pcall(function() loadSongAsset(i) end)
                task.wait(0.05)
            end
        end
    end)
    return introSongReady
end

MakeSectionTitle("Intro", keybindOrder)
keybindOrder = keybindOrder + 1

local GetIntroToggle = MakeToggle("Intro", keybindOrder, getgenv().LightHubConfig.IntroEnabled ~= false, function(state)
    getgenv().LightHubConfig.IntroEnabled = state
    SaveConfig()
    if not state then
        stopIntroMusic()
        stopPreview()
        -- Aktif intro varsa kapat
        if _G.LightHub_CloseIntro then
            pcall(_G.LightHub_CloseIntro)
        end
    end
end)
keybindOrder = keybindOrder + 1

-- Intro Song satırı (Drop Type gibi)
local SongRow = Instance.new("Frame")
SongRow.Name = "IntroSongRow"
SongRow.Parent = ContentScroll
SongRow.Size = UDim2.new(1, -8, 0, 40)
SongRow.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
SongRow.BackgroundTransparency = 0.25
SongRow.LayoutOrder = keybindOrder
SongRow.ZIndex = 62
keybindOrder = keybindOrder + 1

local SongRowCorner = Instance.new("UICorner")
SongRowCorner.CornerRadius = UDim.new(0, 8)
SongRowCorner.Parent = SongRow

local SongLabel = Instance.new("TextLabel")
SongLabel.Parent = SongRow
SongLabel.Size = UDim2.new(0.50, -4, 1, 0)
SongLabel.Position = UDim2.new(0, 8, 0, 0)
SongLabel.BackgroundTransparency = 1
SongLabel.Text = "Intro Song"
SongLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SongLabel.TextSize = 14
SongLabel.Font = Enum.Font.GothamBold
SongLabel.TextXAlignment = Enum.TextXAlignment.Left
SongLabel.ZIndex = 63

local songIdx = tonumber(getgenv().LightHubConfig.IntroSongIndex) or 1
if songIdx < 1 or songIdx > 9 then songIdx = 1 end

local SongBtn = Instance.new("TextButton")
SongBtn.Name = "IntroSongBtn"
SongBtn.Parent = SongRow
SongBtn.Size = UDim2.new(0.42, 0, 0, 26)
SongBtn.Position = UDim2.new(0.55, 0, 0.5, -13)
SongBtn.BackgroundColor3 = Color3.fromRGB(30, 34, 48)
SongBtn.BackgroundTransparency = 0.1
SongBtn.Text = "Song " .. tostring(songIdx)
SongBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SongBtn.TextSize = 13
SongBtn.Font = Enum.Font.Gotham
SongBtn.AutoButtonColor = false
SongBtn.ZIndex = 63

Instance.new("UICorner", SongBtn).CornerRadius = UDim.new(0, 6)
local SongBtnStroke = Instance.new("UIStroke")
SongBtnStroke.Parent = SongBtn
SongBtnStroke.Color = Color3.fromRGB(255, 255, 255)
SongBtnStroke.Thickness = 1.5
SongBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

SongBtn.MouseButton1Click:Connect(function()
    songIdx = songIdx % 9 + 1
    getgenv().LightHubConfig.IntroSongIndex = songIdx
    SaveConfig()
    SongBtn.Text = "Song " .. tostring(songIdx)
    playPreview(songIdx)
end)

----------------------------------------------------------------
-- UI BACKGROUND
----------------------------------------------------------------
local BackgroundIDs = {
    "99416158073201",
    "126860692354524",
    "73226092831324",
    "90280869222992",
}

local function applyUiBackground(index)
    index = tonumber(index) or 1
    if index < 1 then index = 1 end
    if index > #BackgroundIDs then index = 1 end
    getgenv().LightHubConfig.UiBackgroundIndex = index
    SaveConfig()
    if PanelBg then
        PanelBg.Image = "rbxassetid://" .. BackgroundIDs[index]
        PanelBg.Visible = true
    end
    return index
end

-- Başlangıç arka planı
do
    local bi = tonumber(getgenv().LightHubConfig.UiBackgroundIndex) or 1
    applyUiBackground(bi)
end

MakeSectionTitle("Ui", keybindOrder)
keybindOrder = keybindOrder + 1

local UiBgRow = Instance.new("Frame")
UiBgRow.Name = "UiBackgroundRow"
UiBgRow.Parent = ContentScroll
UiBgRow.Size = UDim2.new(1, -8, 0, 40)
UiBgRow.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
UiBgRow.BackgroundTransparency = 0.25
UiBgRow.LayoutOrder = keybindOrder
UiBgRow.ZIndex = 62
keybindOrder = keybindOrder + 1
Instance.new("UICorner", UiBgRow).CornerRadius = UDim.new(0, 8)

local UiBgLabel = Instance.new("TextLabel")
UiBgLabel.Parent = UiBgRow
UiBgLabel.Size = UDim2.new(0.50, -4, 1, 0)
UiBgLabel.Position = UDim2.new(0, 8, 0, 0)
UiBgLabel.BackgroundTransparency = 1
UiBgLabel.Text = "Ui Background"
UiBgLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
UiBgLabel.TextSize = 14
UiBgLabel.Font = Enum.Font.GothamBold
UiBgLabel.TextXAlignment = Enum.TextXAlignment.Left
UiBgLabel.ZIndex = 63

local bgIdx = tonumber(getgenv().LightHubConfig.UiBackgroundIndex) or 1
local UiBgBtn = Instance.new("TextButton")
UiBgBtn.Name = "UiBackgroundBtn"
UiBgBtn.Parent = UiBgRow
UiBgBtn.Size = UDim2.new(0.42, 0, 0, 26)
UiBgBtn.Position = UDim2.new(0.55, 0, 0.5, -13)
UiBgBtn.BackgroundColor3 = Color3.fromRGB(30, 34, 48)
UiBgBtn.BackgroundTransparency = 0.1
UiBgBtn.Text = "Image " .. tostring(bgIdx)
UiBgBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UiBgBtn.TextSize = 13
UiBgBtn.Font = Enum.Font.Gotham
UiBgBtn.AutoButtonColor = false
UiBgBtn.ZIndex = 63
Instance.new("UICorner", UiBgBtn).CornerRadius = UDim.new(0, 6)
local UiBgStroke = Instance.new("UIStroke", UiBgBtn)
UiBgStroke.Color = Color3.fromRGB(255, 255, 255)
UiBgStroke.Thickness = 1.5
UiBgStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

UiBgBtn.MouseButton1Click:Connect(function()
    bgIdx = applyUiBackground(bgIdx % #BackgroundIDs + 1)
    UiBgBtn.Text = "Image " .. tostring(bgIdx)
end)

----------------------------------------------------------------
-- UI COLORS (Black / Blue / Green / Pink / White)
----------------------------------------------------------------
MakeSectionTitle("Ui Colors", keybindOrder)
keybindOrder = keybindOrder + 1

local UiColorRow = Instance.new("Frame")
UiColorRow.Name = "UiColorRow"
UiColorRow.Parent = ContentScroll
UiColorRow.Size = UDim2.new(1, -8, 0, 40)
UiColorRow.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
UiColorRow.BackgroundTransparency = 0.25
UiColorRow.LayoutOrder = keybindOrder
UiColorRow.ZIndex = 62
keybindOrder = keybindOrder + 1
Instance.new("UICorner", UiColorRow).CornerRadius = UDim.new(0, 8)

local UiColorLabel = Instance.new("TextLabel")
UiColorLabel.Parent = UiColorRow
UiColorLabel.Size = UDim2.new(0.50, -4, 1, 0)
UiColorLabel.Position = UDim2.new(0, 8, 0, 0)
UiColorLabel.BackgroundTransparency = 1
UiColorLabel.Text = "Ui Colors"
UiColorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
UiColorLabel.TextSize = 14
UiColorLabel.Font = Enum.Font.GothamBold
UiColorLabel.TextXAlignment = Enum.TextXAlignment.Left
UiColorLabel.ZIndex = 63

local colorIdx = tonumber(getgenv().LightHubConfig.UiColorIndex) or 1
if colorIdx < 1 or colorIdx > #UI_COLOR_NAMES then colorIdx = 1 end
getgenv().LightHubConfig.UiColorIndex = colorIdx

local UiColorBtn = Instance.new("TextButton")
UiColorBtn.Name = "UiColorBtn"
UiColorBtn.Parent = UiColorRow
UiColorBtn.Size = UDim2.new(0.42, 0, 0, 26)
UiColorBtn.Position = UDim2.new(0.55, 0, 0.5, -13)
UiColorBtn.BackgroundColor3 = Color3.fromRGB(30, 34, 48)
UiColorBtn.BackgroundTransparency = 0.1
UiColorBtn.Text = UI_COLOR_NAMES[colorIdx]
UiColorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UiColorBtn.TextSize = 13
UiColorBtn.Font = Enum.Font.GothamBold
UiColorBtn.AutoButtonColor = false
UiColorBtn.ZIndex = 63
Instance.new("UICorner", UiColorBtn).CornerRadius = UDim.new(0, 6)
local UiColorStroke = Instance.new("UIStroke", UiColorBtn)
UiColorStroke.Color = Color3.fromRGB(255, 255, 255)
UiColorStroke.Thickness = 1.5
UiColorStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

UiColorBtn.MouseButton1Click:Connect(function()
    colorIdx = colorIdx % #UI_COLOR_NAMES + 1
    getgenv().LightHubConfig.UiColorIndex = colorIdx
    local name = applyUiColorTheme()
    UiColorBtn.Text = name
end)

-- Kaydedilmiş rengi başlangıçta uygula
task.defer(function()
    applyUiColorTheme()
    if UiColorBtn then
        UiColorBtn.Text = UI_COLOR_NAMES[tonumber(getgenv().LightHubConfig.UiColorIndex) or 1]
    end
end)

----------------------------------------------------------------
-- RESET BUTTON POSITIONS
----------------------------------------------------------------
MakeSectionTitle("Reset Button Positions", keybindOrder)
keybindOrder = keybindOrder + 1

local ResetPosRow = Instance.new("Frame")
ResetPosRow.Name = "ResetPosRow"
ResetPosRow.Parent = ContentScroll
ResetPosRow.Size = UDim2.new(1, -8, 0, 40)
ResetPosRow.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
ResetPosRow.BackgroundTransparency = 0.25
ResetPosRow.LayoutOrder = keybindOrder
ResetPosRow.ZIndex = 62
keybindOrder = keybindOrder + 1
Instance.new("UICorner", ResetPosRow).CornerRadius = UDim.new(0, 8)

local ResetPosLabel = Instance.new("TextLabel")
ResetPosLabel.Parent = ResetPosRow
ResetPosLabel.Size = UDim2.new(0.55, -4, 1, 0)
ResetPosLabel.Position = UDim2.new(0, 8, 0, 0)
ResetPosLabel.BackgroundTransparency = 1
ResetPosLabel.Text = "Reset Button Positions"
ResetPosLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetPosLabel.TextSize = 13
ResetPosLabel.Font = Enum.Font.GothamBold
ResetPosLabel.TextXAlignment = Enum.TextXAlignment.Left
ResetPosLabel.ZIndex = 63

local ResetPosBtn = Instance.new("TextButton")
ResetPosBtn.Parent = ResetPosRow
ResetPosBtn.Size = UDim2.new(0.35, 0, 0, 26)
ResetPosBtn.Position = UDim2.new(0.62, 0, 0.5, -13)
ResetPosBtn.BackgroundColor3 = Color3.fromRGB(40, 42, 58)
ResetPosBtn.Text = "RESET"
ResetPosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetPosBtn.TextSize = 13
ResetPosBtn.Font = Enum.Font.GothamBold
ResetPosBtn.AutoButtonColor = false
ResetPosBtn.ZIndex = 63
Instance.new("UICorner", ResetPosBtn).CornerRadius = UDim.new(0, 6)
local ResetPosStroke = Instance.new("UIStroke", ResetPosBtn)
ResetPosStroke.Color = Color3.fromRGB(255, 255, 255)
ResetPosStroke.Thickness = 1.5

local function showResetConfirm()
    local confirmGui = Instance.new("Frame")
    confirmGui.Name = "ResetConfirm"
    confirmGui.Parent = HubPanel
    confirmGui.AnchorPoint = Vector2.new(0.5, 0.5)
    confirmGui.Position = UDim2.new(0.5, 0, 0.5, 0)
    confirmGui.Size = UDim2.new(0.92, 0, 0, 130)
    confirmGui.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
    confirmGui.BackgroundTransparency = 0.05
    confirmGui.ZIndex = 200
    Instance.new("UICorner", confirmGui).CornerRadius = UDim.new(0, 12)
    local cStroke = Instance.new("UIStroke", confirmGui)
    cStroke.Color = Color3.fromRGB(255, 255, 255)
    cStroke.Thickness = 1.5

    local msg = Instance.new("TextLabel")
    msg.Parent = confirmGui
    msg.Size = UDim2.new(1, -20, 0, 50)
    msg.Position = UDim2.new(0, 10, 0, 12)
    msg.BackgroundTransparency = 1
    msg.Text = "This Will Reset Buton Positions, Are you sure about that?"
    msg.TextColor3 = Color3.fromRGB(255, 255, 255)
    msg.TextSize = 13
    msg.Font = Enum.Font.GothamBold
    msg.TextWrapped = true
    msg.ZIndex = 201

    local noBtn = Instance.new("TextButton")
    noBtn.Parent = confirmGui
    noBtn.Size = UDim2.new(0.4, 0, 0, 32)
    noBtn.Position = UDim2.new(0.05, 0, 1, -44)
    noBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    noBtn.Text = "No"
    noBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    noBtn.TextSize = 14
    noBtn.Font = Enum.Font.GothamBold
    noBtn.AutoButtonColor = false
    noBtn.ZIndex = 201
    Instance.new("UICorner", noBtn).CornerRadius = UDim.new(0, 8)

    local yesBtn = Instance.new("TextButton")
    yesBtn.Parent = confirmGui
    yesBtn.Size = UDim2.new(0.4, 0, 0, 32)
    yesBtn.Position = UDim2.new(0.55, 0, 1, -44)
    yesBtn.BackgroundColor3 = Color3.fromRGB(40, 170, 70)
    yesBtn.Text = "Reset"
    yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    yesBtn.TextSize = 14
    yesBtn.Font = Enum.Font.GothamBold
    yesBtn.AutoButtonColor = false
    yesBtn.ZIndex = 201
    Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 8)

    noBtn.MouseButton1Click:Connect(function()
        confirmGui:Destroy()
    end)

    yesBtn.MouseButton1Click:Connect(function()
        confirmGui:Destroy()
        -- Kaydedilmiş pozisyonları temizle
        savedPositions = {}
        pcall(function()
            if writefile then
                writefile(SaveFileName, HttpService:JSONEncode({}))
            end
        end)
        -- Butonları orijinal yerlerine hızlıca kaydır (TP yok, tween)
        for name, btn in pairs(Buttons) do
            local def = defaultLayout[name]
            if def and btn then
                local target = UDim2.new(def.X, 0, def.Y, 0)
                TweenService:Create(btn, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = target
                }):Play()
            end
        end
    end)
end

ResetPosBtn.MouseButton1Click:Connect(function()
    showResetConfirm()
end)

MakeDraggable(HubPanel)


local panelOpen = false
HubBtn.MouseButton1Click:Connect(function()
    if hubWasDragged() then return end
    panelOpen = not panelOpen
    HubPanel.Visible = panelOpen
    HubStroke.Color = Color3.fromRGB(255, 255, 255)
    HubStroke.Thickness = 3
    task.delay(0.2, function()
        if HubStroke and HubStroke.Parent then
            HubStroke.Thickness = 1.5
        end
    end)
end)

----------------------------------------------------------------
----------------------------------------------------------------
-- KUSURSUZ SİNEMATİK İNTRO SİSTEMİ (ayrı scope - register limiti)
----------------------------------------------------------------
local function runCinematicIntro()
    local introEnabledNow = getgenv().LightHubConfig.IntroEnabled ~= false
    local SkipText = nil

    local IntroGui = Instance.new("Frame")
    IntroGui.Name = "CinematicIntro"
    IntroGui.Parent = ScreenGui
    IntroGui.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    IntroGui.BackgroundTransparency = 1 
    IntroGui.Size = UDim2.new(2, 0, 2, 0) 
    IntroGui.Position = UDim2.new(-0.5, 0, -0.5, 0)
    IntroGui.ZIndex = 100
    IntroGui.Active = false
    IntroGui.Visible = introEnabledNow

    local CinematicBlur = Instance.new("BlurEffect")
    CinematicBlur.Name = "LightHubIntroBlur"
    CinematicBlur.Size = 0
    CinematicBlur.Parent = Lighting

    if introEnabledNow then
        -- Önce şarkıyı yükle, sonra intro + müzik başlat
        task.spawn(function()
            safeCall(function()
                local idx = tonumber(getgenv().LightHubConfig.IntroSongIndex) or 1
                if preloadAllSongs then preloadAllSongs(idx) end
                if playIntroSong then playIntroSong() end
                if IntroGui and IntroGui.Parent then
                    TweenService:Create(IntroGui, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0.35}):Play()
                end
                if CinematicBlur and CinematicBlur.Parent then
                    TweenService:Create(CinematicBlur, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = 24}):Play()
                end
            end)
        end)
    else
        IntroGui.Visible = false
        pcall(function() CinematicBlur:Destroy() end)
        task.defer(function()
            pcall(function()
                if IntroGui and IntroGui.Parent then IntroGui:Destroy() end
                if SkipText and SkipText.Parent then SkipText:Destroy() end
            end)
        end)
    end

    local MainTitle = Instance.new("TextLabel")
    MainTitle.Parent = IntroGui
    MainTitle.AnchorPoint = Vector2.new(0.5, 0.5)
    MainTitle.Position = UDim2.new(0.5, 0, 0.22, 0)
    MainTitle.Size = UDim2.new(0, 500, 0, 80)
    MainTitle.BackgroundTransparency = 1
    MainTitle.Text = "LIGHT"
    MainTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainTitle.TextSize = 55
    MainTitle.Font = Enum.Font.GothamBlack
    MainTitle.TextTransparency = 1 
    MainTitle.ZIndex = 150

    local MainTitleStroke = Instance.new("UIStroke")
    MainTitleStroke.Parent = MainTitle
    MainTitleStroke.Color = Color3.fromRGB(130, 180, 255) 
    MainTitleStroke.Thickness = 3
    MainTitleStroke.Transparency = 1

    local CardContainer = Instance.new("Frame")
    CardContainer.Parent = IntroGui
    CardContainer.BackgroundTransparency = 1
    CardContainer.Size = UDim2.new(1, 0, 1, 0)
    CardContainer.ZIndex = 101

    local cards = {}
    local letters = {"L", "I", "G", "H", "T"}
    local targetRotations = {-24, -12, 0, 12, 24} 
    local targetXOffsets = {-220, -110, 0, 110, 220} 

    local stackOffsets = {-16, -8, 0, 8, 16}
    local stackRotations = {-9, -4.5, 0, 4.5, 9}

    for idx = 1, 5 do
        local wrapper = Instance.new("Frame")
        wrapper.Parent = CardContainer
        wrapper.AnchorPoint = Vector2.new(0.5, 1) 
        wrapper.Position = UDim2.new(0.5, targetXOffsets[idx], 0.5, 120)
        wrapper.Size = UDim2.new(0, 0, 0, 0) 
        wrapper.Rotation = targetRotations[idx]
        wrapper.BackgroundTransparency = 1
        wrapper.ZIndex = 100 + idx
        wrapper.Visible = false

        local front = Instance.new("Frame", wrapper)
        front.Name = "Front"
        front.Size = UDim2.new(1, 0, 1, 0); front.BackgroundColor3 = Color3.fromRGB(15, 15, 20); front.Visible = true
        front.AnchorPoint = Vector2.new(0.5, 0.5); front.Position = UDim2.new(0.5, 0, 0.5, 0)
        Instance.new("UICorner", front).CornerRadius = UDim.new(0, 10)
        local fStroke = Instance.new("UIStroke", front); fStroke.Color = Color3.fromRGB(255, 255, 255); fStroke.Thickness = 2

        local txt = Instance.new("TextLabel", front)
        txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1
        txt.Text = letters[idx]; txt.TextColor3 = Color3.fromRGB(255, 255, 255)
        txt.TextSize = 65; txt.Font = Enum.Font.GothamBlack

        local sym1 = Instance.new("TextLabel", front)
        sym1.Size = UDim2.new(0, 30, 0, 30); sym1.Position = UDim2.new(0, 5, 0, 5)
        sym1.BackgroundTransparency = 1; sym1.Text = "♠"; sym1.TextColor3 = Color3.fromRGB(255,255,255); sym1.TextSize = 22
        local sym2 = sym1:Clone(); sym2.Parent = front; sym2.Position = UDim2.new(1, -35, 1, -35); sym2.Rotation = 180

        local back = Instance.new("Frame", wrapper)
        back.Name = "Back"
        back.Size = UDim2.new(1, 0, 1, 0); back.BackgroundColor3 = Color3.fromRGB(15, 15, 20); back.Visible = false
        back.AnchorPoint = Vector2.new(0.5, 0.5); back.Position = UDim2.new(0.5, 0, 0.5, 0)
        Instance.new("UICorner", back).CornerRadius = UDim.new(0, 10)
        local bStroke = Instance.new("UIStroke", back); bStroke.Color = Color3.fromRGB(255, 255, 255); bStroke.Thickness = 2

        local bTxt = Instance.new("TextLabel", back)
        bTxt.Size = UDim2.new(1, 0, 1, 0); bTxt.BackgroundTransparency = 1
        bTxt.Text = "HUB"; bTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
        bTxt.TextSize = 42; bTxt.Font = Enum.Font.GothamBlack

        local bSym1 = Instance.new("TextLabel", back)
        bSym1.Size = UDim2.new(0, 30, 0, 30); bSym1.Position = UDim2.new(0, 5, 0, 5)
        bSym1.BackgroundTransparency = 1; bSym1.Text = "♠"; bSym1.TextColor3 = Color3.fromRGB(255, 255, 255); bSym1.TextSize = 22
        local bSym2 = bSym1:Clone(); bSym2.Parent = back; bSym2.Position = UDim2.new(1, -35, 1, -35); bSym2.Rotation = 180

        cards[idx] = {Wrapper = wrapper}
    end

    SkipText = Instance.new("TextLabel")
    SkipText.Name = "SkipHint"
    SkipText.Parent = ScreenGui
    SkipText.AnchorPoint = Vector2.new(0.5, 1)
    SkipText.Position = UDim2.new(0.5, 0, 0.94, 0)
    SkipText.Size = UDim2.new(0.95, 0, 0, 55)
    SkipText.BackgroundTransparency = 1
    SkipText.Text = "CLICK ANYWHERE TO SKIP"
    SkipText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SkipText.TextSize = 26
    SkipText.Font = Enum.Font.GothamBlack
    SkipText.TextTransparency = 1
    SkipText.ZIndex = 500
    SkipText.Visible = false

    local SkipButton = nil

    local isIntroActive = introEnabledNow
    local canSkip = false

    local function MakeIntroNonBlocking()
        if IntroGui then
            IntroGui.Active = false
            for _, d in ipairs(IntroGui:GetDescendants()) do
                if d:IsA("GuiObject") then
                    d.Active = false
                end
            end
        end
        if SkipText then
            SkipText.Active = false
        end
    end
    MakeIntroNonBlocking()

    local function FlipCards()
        local half = 0.40

        for _, c in ipairs(cards) do
            TweenService:Create(c.Wrapper, TweenInfo.new(half, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 210)
            }):Play()
        end
        task.wait(half)

        if not isIntroActive then return end

        for _, c in ipairs(cards) do
            local front = c.Wrapper:FindFirstChild("Front")
            local back = c.Wrapper:FindFirstChild("Back")
            if front and back then
                front.Visible = false
                back.Visible = true
            end
        end

        for _, c in ipairs(cards) do
            TweenService:Create(c.Wrapper, TweenInfo.new(half + 0.01, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 140, 0, 200)
            }):Play()
        end
        task.wait(half + 0.01)
    end

    local function CloseIntro()
        if not isIntroActive then return end
        isIntroActive = false
        canSkip = false
        if stopIntroMusic then stopIntroMusic() end
        if stopPreview then stopPreview() end
        if SkipText then SkipText.Visible = false end

        for _, c in ipairs(cards) do
            if c.Wrapper and c.Wrapper.Parent then
                TweenService:Create(c.Wrapper, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, 0, 1.5, 0),
                    Size = UDim2.new(0, 0, 0, 0)
                }):Play()
            end
        end

        if CinematicBlur and CinematicBlur.Parent then
            TweenService:Create(CinematicBlur, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = 0}):Play()
        end
        if IntroGui and IntroGui.Parent then
            TweenService:Create(IntroGui, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        end

        task.delay(0.5, function()
            if CinematicBlur and CinematicBlur.Parent then CinematicBlur:Destroy() end
            if IntroGui and IntroGui.Parent then IntroGui:Destroy() end
            if SkipText and SkipText.Parent then SkipText:Destroy() end
        end)
    end
    _G.LightHub_CloseIntro = CloseIntro

    task.spawn(function()
        if not introEnabledNow then return end
        -- Şarkı yüklenene kadar bekle (max 8sn)
        local t0 = tick()
        while not introSongReady and tick() - t0 < 8 do
            task.wait(0.1)
        end
        task.wait(0.3)
    
        for _, c in ipairs(cards) do
            c.Wrapper.Visible = true
            TweenService:Create(c.Wrapper, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 140, 0, 200)
            }):Play()
            task.wait(0.1)
        end
        task.wait(0.4)
    
        MainTitle.Visible = true
        TweenService:Create(MainTitle, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        TweenService:Create(MainTitleStroke, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = 0}):Play()
    
        task.wait(1.15)
        if not isIntroActive then return end
    
        TweenService:Create(MainTitle, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(MainTitleStroke, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Transparency = 1}):Play()
    
        task.wait(0.08)
        if not isIntroActive then return end
    
        for idx, c in ipairs(cards) do
            TweenService:Create(c.Wrapper, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, stackOffsets[idx], 0.5, 120),
                Rotation = stackRotations[idx]
            }):Play()
        end
    
        task.wait(0.5)
        if not isIntroActive then return end
    
        FlipCards()
    
        if not isIntroActive then return end
    
        SkipText.Visible = true
        SkipText.TextTransparency = 1
        TweenService:Create(SkipText, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            TextTransparency = 0
        }):Play()
    
        task.wait(0.3)
        if not isIntroActive then return end
    
        canSkip = true
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not isIntroActive or not canSkip then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            CloseIntro()
        end
    end)

end
safeCall(function()
    task.spawn(function()
        safeCall(runCinematicIntro)
    end)
end)

--========================================================================
-- Initialize
--========================================================================
safeCall(function()
    if LocalPlayer.Character then
        setupBoost(LocalPlayer.Character)
    end
end)
LocalPlayer.CharacterAdded:Connect(function(char)
    safeCall(function()
        setupBoost(char)
        task.wait(0.3)
        if getgenv().LightHubConfig and getgenv().LightHubConfig.BatAimbotEnabled then
            startBatAimbot()
        end
    end)
end)

-- Script açılışında her şey kapalı
safeCall(function()
    getgenv().LightHubConfig.BatAimbotEnabled = false
    getgenv().LightHubConfig.SpeedBoostEnabled = true
    getgenv().LightHubConfig.MultiJumpEnabled = false
    getgenv().LightHubConfig.SpeedMode = "normal"
    getgenv().LightHubConfig.ConsoleMode = false
    getgenv().LightHubConfig.PCKeybindsEnabled = false
end)
safeCall(function()
    if Buttons then
        for name, btn in pairs(Buttons) do
            ButtonToggled[name] = false
            if ButtonStrokes[name] then
                setButtonVisual(btn, ButtonStrokes[name], false)
            end
            if name == "Lagger Speed" and btn then
                btn.Text = "Lagger Mode"
            end
        end
    end
end)
safeCall(function() updateSpeedMode("normal") end)
safeCall(function() stopBatAimbot() end)
safeCall(function() if SetMultiJumpVisual then SetMultiJumpVisual(false) end end)
safeCall(function() if SetConsoleModeVisual then SetConsoleModeVisual(false) end end)
safeCall(function() if SetPCKeybindsVisual then SetPCKeybindsVisual(false) end end)

print("[Light Hub] Combined script loaded. Errors are skipped; features continue. All features start OFF.")
