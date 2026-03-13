local plr = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local ts = game:GetService("TweenService")
local ws = workspace
local cg = game:GetService("CoreGui")
local rep = game:GetService("ReplicatedStorage")
loadstring(game:HttpGet("https://pastebin.com/raw/kQwnUAh4"))()

local par = (gethui and gethui()) or cg
local cam = ws.CurrentCamera

-- Black color palette
local pd = Color3.fromRGB(0, 0, 0)
local pm = Color3.fromRGB(15, 15, 15)
local pl = Color3.fromRGB(30, 30, 30)
local pa = Color3.fromRGB(50, 50, 50)
local pb = Color3.fromRGB(180, 180, 180)
local pg = Color3.fromRGB(220, 220, 220)
local bgc = Color3.fromRGB(0, 0, 0)
local wh = Color3.fromRGB(255, 255, 255)

local speed55 = false
local speedSteal = false
local spinbot = false
local autograb = false
local xrayon = false
local antirag = false
local floaton = false
local infjump = false

local xrayOg = {}
local xrayConns = {}
local conns = {}

local blocked = {
    [Enum.HumanoidStateType.Ragdoll] = true,
    [Enum.HumanoidStateType.FallingDown] = true,
    [Enum.HumanoidStateType.Physics] = true,
    [Enum.HumanoidStateType.Dead] = true
}

local target = nil
local floatConn = nil
local floatSpeed = 56.1
local vertSpeed = 35

local movingDots = {}
local sprintMovingDots = {}

local function spinOn(c)
    local hrp = c:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end
    for _, v in pairs(hrp:GetChildren()) do
        if v:IsA("BodyAngularVelocity") then
            v:Destroy()
        end
    end
    local bv = Instance.new("BodyAngularVelocity")
    bv.MaxTorque = Vector3.new(0, math.huge, 0)
    bv.AngularVelocity = Vector3.new(0, 40, 0)
    bv.Parent = hrp
end

local function spinOff(c)
    if c then
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v:IsA("BodyAngularVelocity") then
                    v:Destroy()
                end
            end
        end
    end
end

local function toggleSpin(b)
    spinbot = b
    if b then
        if plr.Character then
            spinOn(plr.Character)
        end
        table.insert(conns, plr.CharacterAdded:Connect(function(c)
            spinOn(c)
        end))
    else
        if plr.Character then
            spinOff(plr.Character)
        end
    end
end

local function createDots(parent)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 1, 0)
    container.Position = UDim2.new(0, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.ZIndex = 0
    container.Name = "DotBackground"
    
    local dots = {}
    for i = 1, 40 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 3, 0, 3)
        dot.Position = UDim2.new(math.random(), 0, math.random(), 0)
        dot.BackgroundColor3 = pa
        dot.BackgroundTransparency = 0.4
        dot.BorderSizePixel = 0
        dot.Parent = container
        dot.ZIndex = 0
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = dot
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = pb
        stroke.Thickness = 1
        stroke.Transparency = 0.7
        stroke.Parent = dot
        
        table.insert(dots, {
            frame = dot,
            sx = (math.random() - 0.5) * 0.015,
            sy = (math.random() - 0.5) * 0.015,
            pulse = math.random() * 2
        })
    end
    
    return container, dots
end

local anti = {}
local antiMode = nil
local ragConns = {}
local charCache = {}

local function cacheChar()
    local c = plr.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if not h or not r then return false end
    charCache = {
        char = c,
        hum = h,
        root = r
    }
    return true
end

local function killConns()
    for _, c in pairs(ragConns) do
        pcall(function() c:Disconnect() end)
    end
    ragConns = {}
end

local function isRagdoll()
    if not charCache.hum then return false end
    local s = charCache.hum:GetState()
    if s == Enum.HumanoidStateType.Physics or s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown then
        return true
    end
    local et = plr:GetAttribute("RagdollEndTime")
    if et then
        local n = workspace:GetServerTimeNow()
        if (et - n) > 0 then
            return true
        end
    end
    return false
end

local function removeCons()
    if not charCache.char then return end
    for _, d in pairs(charCache.char:GetDescendants()) do
        if d:IsA("BallSocketConstraint") or (d:IsA("Attachment") and string.find(d.Name, "RagdollAttachment")) then
            pcall(function() d:Destroy() end)
        end
    end
end

local function forceExit()
    if not charCache.hum or not charCache.root then return end
    pcall(function()
        plr:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow())
    end)
    if charCache.hum.Health > 0 then
        charCache.hum:ChangeState(Enum.HumanoidStateType.Running)
    end
    charCache.root.Anchored = false
    charCache.root.AssemblyLinearVelocity = Vector3.zero
end

local function antiLoop()
    while antiMode == "v1" and charCache.hum do
        task.wait()
        if isRagdoll() then
            removeCons()
            forceExit()
        end
    end
end

local function setupCam()
    if not charCache.hum then return end
    table.insert(ragConns, rs.RenderStepped:Connect(function()
        if antiMode ~= "v1" then return end
        local c = workspace.CurrentCamera
        if c and charCache.hum and c.CameraSubject ~= charCache.hum then
            c.CameraSubject = charCache.hum
        end
    end))
end

local function onChar(c)
    task.wait(0.5)
    if not antiMode then return end
    if cacheChar() then
        if antiMode == "v1" then
            setupCam()
            task.spawn(antiLoop)
        end
    end
end

function anti.Enable(m)
    if m ~= "v1" then return end
    if antiMode == m then return end
    anti.Disable()
    if not cacheChar() then return end
    antiMode = m
    table.insert(ragConns, plr.CharacterAdded:Connect(onChar))
    setupCam()
    task.spawn(antiLoop)
    print("anti on")
end

function anti.Disable()
    if not antiMode then return end
    antiMode = nil
    killConns()
    charCache = {}
    print("anti off")
end

local AnimalsData = require(rep:WaitForChild("Datas"):WaitForChild("Animals"))

local animalCache = {}
local promptMem = {}
local stealMem = {}
local lastUid = nil
local lastPos = nil

local radius = 150
local stealing = false
local stealProg = 0
local curTarget = nil
local stealStart = 0
local stealConn = nil
local velConn = nil

local grabUI = nil
local progBar = nil
local dotsFolder = nil

local function hrp()
    local c = plr.Character
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso")
end

local function isMyBase(n)
    local p = workspace.Plots:FindFirstChild(n)
    if not p then return false end
    local s = p:FindFirstChild("PlotSign")
    if s then
        local y = s:FindFirstChild("YourBase")
        if y and y:IsA("BillboardGui") then
            return y.Enabled == true
        end
    end
    return false
end

local function scanPlot(p)
    if not p or not p:IsA("Model") then return end
    if isMyBase(p.Name) then return end
    local pods = p:FindFirstChild("AnimalPodiums")
    if not pods then return end
    for _, pod in pairs(pods:GetChildren()) do
        if pod:IsA("Model") and pod:FindFirstChild("Base") then
            local name = "Unknown"
            local spawn = pod.Base:FindFirstChild("Spawn")
            if spawn then
                for _, c in pairs(spawn:GetChildren()) do
                    if c:IsA("Model") and c.Name ~= "PromptAttachment" then
                        name = c.Name
                        local info = AnimalsData[name]
                        if info and info.DisplayName then
                            name = info.DisplayName
                        end
                        break
                    end
                end
            end
            table.insert(animalCache, {
                name = name,
                plot = p.Name,
                slot = pod.Name,
                pos = pod:GetPivot().Position,
                uid = p.Name .. "_" .. pod.Name,
            })
        end
    end
end

local function setupScanner()
    task.wait(2)
    local plots = workspace:WaitForChild("Plots", 10)
    if not plots then return end
    for _, p in pairs(plots:GetChildren()) do
        if p:IsA("Model") then
            scanPlot(p)
        end
    end
    plots.ChildAdded:Connect(function(p)
        if p:IsA("Model") then
            task.wait(0.5)
            scanPlot(p)
        end
    end)
    task.spawn(function()
        while task.wait(5) do
            if autograb then
                animalCache = {}
                for _, p in pairs(plots:GetChildren()) do
                    if p:IsA("Model") then
                        scanPlot(p)
                    end
                end
            end
        end
    end)
end

local function findPrompt(d)
    if not d then return nil end
    local cached = promptMem[d.uid]
    if cached and cached.Parent then
        return cached
    end
    local p = workspace.Plots:FindFirstChild(d.plot)
    if not p then return nil end
    local pods = p:FindFirstChild("AnimalPodiums")
    if not pods then return nil end
    local pod = pods:FindFirstChild(d.slot)
    if not pod then return nil end
    local b = pod:FindFirstChild("Base")
    if not b then return nil end
    local s = b:FindFirstChild("Spawn")
    if not s then return nil end
    local a = s:FindFirstChild("PromptAttachment")
    if not a then return nil end
    for _, pr in
