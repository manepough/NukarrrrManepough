-- ============================================================
-- BLOCK FIST CONTROLLER v3
-- FE (others see it) | Multi-block | Painter GUI | Mobile
-- credit: stik
-- ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player           = Players.LocalPlayer

-- ============================================================
-- CONFIG
-- ============================================================
local MAX_BRICKS   = 5      -- max bricks you can carry
local PUNCH_DIST   = 14
local PUNCH_SPEED  = 0.07
local RETURN_SPEED = 0.18
local ROTATE_STEP  = 15
local MOVE_STEP    = 2

-- Formation offsets for multiple bricks (relative to fist position)
local FORMATIONS = {
    single = {Vector3.new(0, 0, 0)},
    line   = {Vector3.new(0,0,0), Vector3.new(3.2,0,0), Vector3.new(-3.2,0,0), Vector3.new(6.4,0,0), Vector3.new(-6.4,0,0)},
    stack  = {Vector3.new(0,0,0), Vector3.new(0,3.2,0), Vector3.new(0,-3.2,0), Vector3.new(0,6.4,0), Vector3.new(0,-6.4,0)},
    wall   = {Vector3.new(0,0,0), Vector3.new(3.2,0,0), Vector3.new(-3.2,0,0), Vector3.new(0,3.2,0), Vector3.new(0,-3.2,0)},
}
local currentFormation = "single"

-- ============================================================
-- STATE
-- ============================================================
local fistBricks  = {}   -- array of grabbed bricks
local fistActive  = false
local isPunching  = false
local aimH        = 0
local aimV        = 0
local extraOffset = Vector3.new(0, 2, 0)
local holding     = {up=false,down=false,left=false,right=false,hiUp=false,hiDown=false}

-- ============================================================
-- FE — TAKE NETWORK OWNERSHIP
-- This makes the server replicate our position changes to everyone
-- ============================================================
local function claimOwnership(brick)
    pcall(function() brick:SetNetworkOwner(player) end)
    -- Also try via exploit API
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(brick, "NetworkOwnerV3", player)
        end
    end)
end

-- ============================================================
-- PAINT REMOTE — for applying colors/text to bricks (FE)
-- ============================================================
local function getPaintRemote()
    local char = player.Character; if not char then return nil, nil end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil, nil end
    local tool = char:FindFirstChild("Paint") or player.Backpack:FindFirstChild("Paint")
    if not tool then return nil, nil end
    if tool.Parent ~= char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(tool); task.wait(0.2) end
        tool = char:FindFirstChild("Paint")
        if not tool then return nil, nil end
    end
    local remote = tool:FindFirstChild("Event", true) or tool:FindFirstChildWhichIsA("RemoteEvent", true)
    return remote, hrp.Position
end

local function paintFace(brick, face, color, text)
    local remote, rootPos = getPaintRemote()
    if not remote then return end
    local key = "both \u{1F91D}"
    pcall(function()
        remote:FireServer(brick, face, rootPos, key, color, "spray", text or "")
    end)
end

-- ============================================================
-- FIND NEAREST ANCHORED BRICKS (returns up to N)
-- ============================================================
local function findNearestBricks(count)
    local char = player.Character; if not char then return {} end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return {} end

    local candidates = {}
    local charSet    = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do charSet[part]=true end
        end
    end

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Anchored and v ~= workspace.Terrain and not charSet[v] then
            table.insert(candidates, {brick=v, dist=(v.Position-hrp.Position).Magnitude})
        end
    end
    table.sort(candidates, function(a,b) return a.dist < b.dist end)

    local result = {}
    for i = 1, math.min(count, #candidates) do
        table.insert(result, candidates[i].brick)
    end
    return result
end

-- ============================================================
-- FIST POSITION MATH
-- ============================================================
local function getBaseCFrame()
    local char = player.Character; if not char then return nil end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    return hrp.CFrame
        * CFrame.Angles(0, math.rad(aimH), 0)
        * CFrame.Angles(math.rad(aimV), 0, 0)
        * CFrame.new(Vector3.new(0, 0, -6) + extraOffset)
end

local function getBrickCFrame(index)
    local base = getBaseCFrame(); if not base then return nil end
    local formation = FORMATIONS[currentFormation] or FORMATIONS.single
    local offset    = formation[index] or formation[1]
    return base * CFrame.new(offset)
end

-- ============================================================
-- PUNCH
-- ============================================================
local function doPunch()
    if isPunching or #fistBricks == 0 then return end
    isPunching = true

    local char = player.Character; if not char then isPunching=false; return end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then isPunching=false; return end

    local forward = (hrp.CFrame
        * CFrame.Angles(0, math.rad(aimH), 0)
        * CFrame.Angles(math.rad(aimV), 0, 0)).LookVector

    -- Save start positions
    local starts = {}
    for i, _ in ipairs(fistBricks) do
        starts[i] = getBrickCFrame(i)
    end

    -- Punch out
    for step = 1, 6 do
        if not fistActive then break end
        for i, brick in ipairs(fistBricks) do
            if brick and brick.Parent and starts[i] then
                brick.CFrame = starts[i]:Lerp(starts[i] + forward * PUNCH_DIST, step/6)
            end
        end
        task.wait(PUNCH_SPEED/6)
    end

    task.wait(0.06)

    -- Pull back
    local punched = {}
    for i, brick in ipairs(fistBricks) do
        if brick and brick.Parent and starts[i] then
            punched[i] = starts[i] + forward * PUNCH_DIST
        end
    end
    for step = 1, 8 do
        if not fistActive then break end
        for i, brick in ipairs(fistBricks) do
            if brick and brick.Parent and starts[i] and punched[i] then
                brick.CFrame = punched[i]:Lerp(starts[i], step/8)
            end
        end
        task.wait(RETURN_SPEED/8)
    end

    isPunching = false
end

-- ============================================================
-- FOLLOW HEARTBEAT
-- ============================================================
local hbConn = nil
local function startFollow()
    if hbConn then hbConn:Disconnect() end
    hbConn = RunService.Heartbeat:Connect(function()
        if not fistActive or isPunching then return end
        for i, brick in ipairs(fistBricks) do
            if brick and brick.Parent then
                local cf = getBrickCFrame(i)
                if cf then brick.CFrame = cf end
            end
        end
    end)
end

-- Hold-to-aim
local holdInterval = 0.1
local holdTimer    = 0
RunService.Heartbeat:Connect(function(dt)
    holdTimer = holdTimer + dt
    if holdTimer < holdInterval then return end
    holdTimer = 0
    if holding.left  then aimH = aimH - ROTATE_STEP end
    if holding.right then aimH = aimH + ROTATE_STEP end
    if holding.up    then aimV = math.clamp(aimV-ROTATE_STEP,-80,80) end
    if holding.down  then aimV = math.clamp(aimV+ROTATE_STEP,-80,80) end
    if holding.hiUp  then extraOffset = extraOffset + Vector3.new(0,MOVE_STEP,0) end
    if holding.hiDown then extraOffset = extraOffset - Vector3.new(0,MOVE_STEP,0) end
end)

-- ============================================================
-- ACTIVATE / RELEASE
-- ============================================================
local brickCount = 1 -- how many to grab

local function activate()
    -- Release old bricks first
    fistBricks = {}
    fistActive  = false

    local found = findNearestBricks(brickCount)
    if #found == 0 then return false end

    for _, brick in ipairs(found) do
        brick.Anchored   = true
        brick.CanCollide = true
        claimOwnership(brick)   -- FE: everyone sees movement
        table.insert(fistBricks, brick)
    end

    fistActive = true
    startFollow()
    return true
end

local function deactivate()
    fistActive = false
    if hbConn then hbConn:Disconnect(); hbConn=nil end
    fistBricks = {}
end

-- ============================================================
-- PAINTER DATA
-- ============================================================
-- 8x8 pixel canvas per face
local CANVAS_SIZE = 8
local painterFace = Enum.NormalId.Front
local painterColor = Color3.fromRGB(255, 0, 0)
local painterText  = ""
-- Canvas grid: [face][row][col] = Color3
local canvases = {}
for _, face in ipairs({
    Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Top,
    Enum.NormalId.Bottom, Enum.NormalId.Left, Enum.NormalId.Right
}) do
    canvases[face] = {}
    for r = 1, CANVAS_SIZE do
        canvases[face][r] = {}
        for c = 1, CANVAS_SIZE do
            canvases[face][r][c] = Color3.fromRGB(200, 200, 200)
        end
    end
end

local faceNames = {
    [Enum.NormalId.Front]  = "Front",
    [Enum.NormalId.Back]   = "Back",
    [Enum.NormalId.Top]    = "Top",
    [Enum.NormalId.Bottom] = "Bottom",
    [Enum.NormalId.Left]   = "Left",
    [Enum.NormalId.Right]  = "Right",
}
local faceList = {
    Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Top,
    Enum.NormalId.Bottom, Enum.NormalId.Left, Enum.NormalId.Right
}

-- ============================================================
-- APPLY PAINTER TO BRICKS (FE — uses Paint remote)
-- ============================================================
local function applyPainterToBricks()
    for _, brick in ipairs(fistBricks) do
        if brick and brick.Parent then
            for _, face in ipairs(faceList) do
                -- Pick dominant color from canvas (average)
                local r, g, b, count = 0, 0, 0, 0
                for row = 1, CANVAS_SIZE do
                    for col = 1, CANVAS_SIZE do
                        local c = canvases[face][row][col]
                        r = r + c.R; g = g + c.G; b = b + c.B; count = count + 1
                    end
                end
                local avgColor = Color3.new(r/count, g/count, b/count)

                -- Apply via Paint remote (FE — server + everyone sees it)
                paintFace(brick, face, avgColor, painterText)
                task.wait(0.05)
            end
        end
    end
end

-- Quick solid color apply (one color all faces)
local function applySolidColor(color)
    painterColor = color
    for _, brick in ipairs(fistBricks) do
        if brick and brick.Parent then
            for _, face in ipairs(faceList) do
                paintFace(brick, face, color, painterText)
                task.wait(0.04)
            end
        end
    end
end

-- ============================================================
-- CLEANUP OLD GUI
-- ============================================================
if player.PlayerGui:FindFirstChild("FistPad") then
    player.PlayerGui.FistPad:Destroy()
end

-- ============================================================
-- MAIN GUI
-- ============================================================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name           = "FistPad"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Status bar (top)
local statusBar = Instance.new("Frame", gui)
statusBar.Size             = UDim2.new(1, 0, 0, 40)
statusBar.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
statusBar.BorderSizePixel  = 0

local statusLbl = Instance.new("TextLabel", statusBar)
statusLbl.Size                   = UDim2.fromScale(1, 1)
statusLbl.BackgroundTransparency = 1
statusLbl.Font                   = Enum.Font.GothamBold
statusLbl.TextSize               = 14
statusLbl.TextColor3             = Color3.fromRGB(11, 95, 226)
statusLbl.Text                   = "BLOCK FIST  |  Inactive"

local function setStatus(txt)
    statusLbl.Text = "BLOCK FIST  |  " .. txt
end

-- ============================================================
-- BUTTON FACTORY
-- ============================================================
local function mkBtn(parent, text, x, y, w, h, col, ts)
    local btn = Instance.new("TextButton", parent)
    btn.Size             = UDim2.fromOffset(w, h)
    btn.Position         = UDim2.fromOffset(x, y)
    btn.Text             = text
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = ts or 18
    btn.TextColor3       = Color3.fromRGB(230, 230, 255)
    btn.BackgroundColor3 = col or Color3.fromRGB(38, 38, 60)
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    local origCol = col or Color3.fromRGB(38, 38, 60)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.06), {BackgroundColor3=Color3.fromRGB(11,95,226)}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=origCol}):Play()
    end)
    btn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch then
            TweenService:Create(btn, TweenInfo.new(0.06), {BackgroundColor3=Color3.fromRGB(11,95,226)}):Play()
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=origCol}):Play()
        end
    end)
    return btn
end

local function makeHoldBtn(btn, holdKey)
    btn.MouseButton1Down:Connect(function() holding[holdKey]=true end)
    btn.MouseButton1Up:Connect(function()   holding[holdKey]=false end)
    btn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then holding[holdKey]=true end end)
    btn.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then holding[holdKey]=false end end)
end

-- ============================================================
-- LEFT PAD — AIM D-PAD
-- ============================================================
local leftPad = Instance.new("Frame", gui)
leftPad.Size             = UDim2.fromOffset(224, 224)
leftPad.Position         = UDim2.new(0, 8, 1, -232)
leftPad.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
leftPad.BorderSizePixel  = 0
Instance.new("UICorner", leftPad).CornerRadius = UDim.new(0, 16)
Instance.new("UIStroke", leftPad).Color = Color3.fromRGB(11, 95, 226)

local lTitle = Instance.new("TextLabel", leftPad)
lTitle.Size=UDim2.new(1,0,0,22); lTitle.BackgroundTransparency=1
lTitle.Text="AIM"; lTitle.Font=Enum.Font.GothamBold; lTitle.TextSize=12
lTitle.TextColor3=Color3.fromRGB(11,95,226)

local cx, cy, bs = 77, 80, 68
local dUp    = mkBtn(leftPad,"▲", cx,       cy-bs-2,  bs, bs)
local dDown  = mkBtn(leftPad,"▼", cx,       cy+bs+2,  bs, bs)
local dLeft  = mkBtn(leftPad,"◀", cx-bs-2,  cy,       bs, bs)
local dRight = mkBtn(leftPad,"▶", cx+bs+2,  cy,       bs, bs)

local dCenter = Instance.new("Frame", leftPad)
dCenter.Size=UDim2.fromOffset(20,20); dCenter.Position=UDim2.fromOffset(cx+24,cy+24)
dCenter.BackgroundColor3=Color3.fromRGB(11,95,226); dCenter.BorderSizePixel=0
Instance.new("UICorner",dCenter).CornerRadius=UDim.new(1,0)

makeHoldBtn(dUp,"up"); makeHoldBtn(dDown,"down")
makeHoldBtn(dLeft,"left"); makeHoldBtn(dRight,"right")
dUp.MouseButton1Click:Connect(function()    aimV=math.clamp(aimV-ROTATE_STEP,-80,80) end)
dDown.MouseButton1Click:Connect(function()  aimV=math.clamp(aimV+ROTATE_STEP,-80,80) end)
dLeft.MouseButton1Click:Connect(function()  aimH=aimH-ROTATE_STEP end)
dRight.MouseButton1Click:Connect(function() aimH=aimH+ROTATE_STEP end)

-- ============================================================
-- RIGHT PAD — ACTIONS
-- ============================================================
local rightPad = Instance.new("Frame", gui)
rightPad.Size             = UDim2.fromOffset(224, 224)
rightPad.Position         = UDim2.new(1, -232, 1, -232)
rightPad.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
rightPad.BorderSizePixel  = 0
Instance.new("UICorner", rightPad).CornerRadius = UDim.new(0, 16)
Instance.new("UIStroke", rightPad).Color = Color3.fromRGB(11, 95, 226)

local rTitle = Instance.new("TextLabel", rightPad)
rTitle.Size=UDim2.new(1,0,0,22); rTitle.BackgroundTransparency=1
rTitle.Text="ACTIONS"; rTitle.Font=Enum.Font.GothamBold; rTitle.TextSize=12
rTitle.TextColor3=Color3.fromRGB(11,95,226)

local grabBtn    = mkBtn(rightPad,"✊ GRAB",   4,  26, 106, 80, Color3.fromRGB(20,90,20),  15)
local releaseBtn = mkBtn(rightPad,"✋ DROP",   114, 26, 106, 80, Color3.fromRGB(90,20,20),  15)
local hiUpBtn    = mkBtn(rightPad,"↑ UP",     4,  114, 106, 46, nil, 14)
local hiDnBtn    = mkBtn(rightPad,"↓ DOWN",   114, 114, 106, 46, nil, 14)

-- Brick count selector
local cntLabel = Instance.new("TextLabel", rightPad)
cntLabel.Size=UDim2.fromOffset(204,22); cntLabel.Position=UDim2.fromOffset(10,164)
cntLabel.BackgroundTransparency=1; cntLabel.Text="Bricks: 1"
cntLabel.Font=Enum.Font.GothamBold; cntLabel.TextSize=12
cntLabel.TextColor3=Color3.fromRGB(80,80,130)

local cntMinus = mkBtn(rightPad,"−", 4,   184, 50, 34, nil, 20)
local cntPlus  = mkBtn(rightPad,"+", 60,  184, 50, 34, nil, 20)

-- Formation selector
local fmtBtn = mkBtn(rightPad, "⊞ LINE", 114, 184, 106, 34, Color3.fromRGB(40,40,80), 12)
local fmtIndex = 1
local fmtNames = {"single","line","stack","wall"}
fmtBtn.MouseButton1Click:Connect(function()
    fmtIndex = fmtIndex % #fmtNames + 1
    currentFormation = fmtNames[fmtIndex]
    fmtBtn.Text = "⊞ " .. currentFormation:upper()
end)

cntMinus.MouseButton1Click:Connect(function()
    brickCount = math.max(1, brickCount-1)
    cntLabel.Text = "Bricks: " .. brickCount
end)
cntPlus.MouseButton1Click:Connect(function()
    brickCount = math.min(MAX_BRICKS, brickCount+1)
    cntLabel.Text = "Bricks: " .. brickCount
end)

makeHoldBtn(hiUpBtn,"hiUp"); makeHoldBtn(hiDnBtn,"hiDown")
hiUpBtn.MouseButton1Click:Connect(function() extraOffset=extraOffset+Vector3.new(0,MOVE_STEP,0) end)
hiDnBtn.MouseButton1Click:Connect(function() extraOffset=extraOffset-Vector3.new(0,MOVE_STEP,0) end)

grabBtn.MouseButton1Click:Connect(function()
    local ok = activate()
    if ok then
        TweenService:Create(grabBtn,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(11,95,226)}):Play()
        setStatus("Active — " .. #fistBricks .. " brick(s) grabbed [FE]")
    else
        setStatus("No bricks found nearby!")
    end
end)
releaseBtn.MouseButton1Click:Connect(function()
    deactivate()
    TweenService:Create(grabBtn,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(20,90,20)}):Play()
    setStatus("Released")
end)

-- ============================================================
-- PUNCH BUTTON (center bottom)
-- ============================================================
local punchBtn = Instance.new("TextButton", gui)
punchBtn.Size             = UDim2.new(0.44, 0, 0, 86)
punchBtn.Position         = UDim2.new(0.28, 0, 1, -96)
punchBtn.Text             = "👊  PUNCH"
punchBtn.Font             = Enum.Font.GothamBold
punchBtn.TextSize         = 26
punchBtn.TextColor3       = Color3.new(1,1,1)
punchBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
punchBtn.BorderSizePixel  = 0
punchBtn.AutoButtonColor  = false
Instance.new("UICorner", punchBtn).CornerRadius = UDim.new(0, 18)
Instance.new("UIStroke", punchBtn).Color = Color3.fromRGB(255, 80, 80)

punchBtn.MouseButton1Down:Connect(function()
    TweenService:Create(punchBtn,TweenInfo.new(0.06),{BackgroundColor3=Color3.fromRGB(255,50,50)}):Play()
end)
punchBtn.MouseButton1Up:Connect(function()
    TweenService:Create(punchBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(180,30,30)}):Play()
end)
punchBtn.MouseButton1Click:Connect(function()
    task.spawn(doPunch)
    setStatus("PUNCH!")
    task.delay(0.5, function() setStatus(fistActive and (#fistBricks.." brick(s) active") or "Inactive") end)
end)

-- ============================================================
-- PAINTER BUTTON (top right of status bar)
-- ============================================================
local painterToggleBtn = mkBtn(statusBar, "🎨 PAINTER", 0, 0, 130, 40, Color3.fromRGB(60,20,90), 13)
painterToggleBtn.Position = UDim2.new(1, -134, 0, 0)
painterToggleBtn.Size     = UDim2.fromOffset(130, 40)

-- ============================================================
-- PAINTER GUI (full overlay panel)
-- ============================================================
local painterPanel = Instance.new("Frame", gui)
painterPanel.Size             = UDim2.new(1, 0, 1, -40)
painterPanel.Position         = UDim2.fromOffset(0, 40)
painterPanel.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
painterPanel.BorderSizePixel  = 0
painterPanel.Visible          = false
painterPanel.ZIndex           = 20

-- Close button
local closeBtn = mkBtn(painterPanel, "✕ CLOSE", 0, 0, 110, 40, Color3.fromRGB(90,20,20), 14)
closeBtn.Position = UDim2.new(1,-114,0,4)

local painterTitle = Instance.new("TextLabel", painterPanel)
painterTitle.Size=UDim2.fromOffset(300,38); painterTitle.Position=UDim2.fromOffset(8,4)
painterTitle.BackgroundTransparency=1; painterTitle.Text="🎨  BLOCK PAINTER"
painterTitle.Font=Enum.Font.GothamBold; painterTitle.TextSize=18
painterTitle.TextColor3=Color3.fromRGB(11,95,226); painterTitle.TextXAlignment=Enum.TextXAlignment.Left

-- ── FACE SELECTOR ─────────────────────────────────────────
local faceSelectorFrame = Instance.new("Frame", painterPanel)
faceSelectorFrame.Size=UDim2.new(1,0,0,48); faceSelectorFrame.Position=UDim2.fromOffset(0,46)
faceSelectorFrame.BackgroundTransparency=1

local faceButtons = {}
local faceX = 8
for _, face in ipairs(faceList) do
    local fb = mkBtn(faceSelectorFrame, faceNames[face], faceX, 4, 80, 38,
        face==painterFace and Color3.fromRGB(11,95,226) or Color3.fromRGB(38,38,60), 12)
    faceButtons[face] = fb
    faceX = faceX + 84
    fb.MouseButton1Click:Connect(function()
        painterFace = face
        for f, b in pairs(faceButtons) do
            b.BackgroundColor3 = (f==face) and Color3.fromRGB(11,95,226) or Color3.fromRGB(38,38,60)
        end
    end)
end

-- ── COLOR PALETTE ──────────────────────────────────────────
local palette = {
    Color3.fromRGB(255,0,0),   Color3.fromRGB(255,128,0),
    Color3.fromRGB(255,255,0), Color3.fromRGB(0,255,0),
    Color3.fromRGB(0,200,255), Color3.fromRGB(0,0,255),
    Color3.fromRGB(180,0,255), Color3.fromRGB(255,0,180),
    Color3.fromRGB(255,255,255), Color3.fromRGB(180,180,180),
    Color3.fromRGB(80,80,80),  Color3.fromRGB(0,0,0),
    Color3.fromRGB(160,80,40), Color3.fromRGB(255,200,100),
    Color3.fromRGB(100,255,200), Color3.fromRGB(200,100,255),
}

local paletteFrame = Instance.new("Frame", painterPanel)
paletteFrame.Size=UDim2.new(1,0,0,90); paletteFrame.Position=UDim2.fromOffset(0,100)
paletteFrame.BackgroundTransparency=1

local paletteLbl = Instance.new("TextLabel", paletteFrame)
paletteLbl.Size=UDim2.fromOffset(200,22); paletteLbl.Position=UDim2.fromOffset(8,0)
paletteLbl.BackgroundTransparency=1; paletteLbl.Text="COLOR PALETTE"
paletteLbl.Font=Enum.Font.GothamBold; paletteLbl.TextSize=11
paletteLbl.TextColor3=Color3.fromRGB(80,80,120); paletteLbl.TextXAlignment=Enum.TextXAlignment.Left

local selectedColorFrame = Instance.new("Frame", paletteFrame)
selectedColorFrame.Size=UDim2.fromOffset(52,52); selectedColorFrame.Position=UDim2.fromOffset(8,24)
selectedColorFrame.BackgroundColor3=painterColor; selectedColorFrame.BorderSizePixel=0
Instance.new("UICorner",selectedColorFrame).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",selectedColorFrame).Color=Color3.new(1,1,1)

local px = 68
for i, col in ipairs(palette) do
    local swatch = Instance.new("TextButton", paletteFrame)
    swatch.Size=UDim2.fromOffset(36,36); swatch.Position=UDim2.fromOffset(px + ((i-1)%10)*38, 24 + math.floor((i-1)/10)*38)
    swatch.BackgroundColor3=col; swatch.Text=""; swatch.BorderSizePixel=0
    swatch.AutoButtonColor=false
    Instance.new("UICorner",swatch).CornerRadius=UDim.new(0,6)
    swatch.MouseButton1Click:Connect(function()
        painterColor = col
        selectedColorFrame.BackgroundColor3 = col
    end)
end

-- ── TEXT INPUT ─────────────────────────────────────────────
local textFrame = Instance.new("Frame", painterPanel)
textFrame.Size=UDim2.new(1,-16,0,60); textFrame.Position=UDim2.fromOffset(8,198)
textFrame.BackgroundTransparency=1

local textLbl = Instance.new("TextLabel", textFrame)
textLbl.Size=UDim2.fromOffset(200,22); textLbl.BackgroundTransparency=1
textLbl.Text="FACE TEXT (optional)"; textLbl.Font=Enum.Font.GothamBold; textLbl.TextSize=11
textLbl.TextColor3=Color3.fromRGB(80,80,120); textLbl.TextXAlignment=Enum.TextXAlignment.Left

local textInput = Instance.new("TextBox", textFrame)
textInput.Size=UDim2.new(1,0,0,36); textInput.Position=UDim2.fromOffset(0,24)
textInput.BackgroundColor3=Color3.fromRGB(28,28,46)
textInput.TextColor3=Color3.fromRGB(220,220,240)
textInput.PlaceholderText="Enter text for this face..."
textInput.PlaceholderColor3=Color3.fromRGB(80,80,110)
textInput.Font=Enum.Font.Gotham; textInput.TextSize=15
textInput.BorderSizePixel=0; textInput.ClearTextOnFocus=false
Instance.new("UICorner",textInput).CornerRadius=UDim.new(0,10)
textInput.Changed:Connect(function() painterText = textInput.Text end)

-- ── APPLY BUTTONS ──────────────────────────────────────────
local applyFrame = Instance.new("Frame", painterPanel)
applyFrame.Size=UDim2.new(1,-16,0,50); applyFrame.Position=UDim2.fromOffset(8,268)
applyFrame.BackgroundTransparency=1

-- Apply selected color to current face
local applyFaceBtn = mkBtn(applyFrame,"🖌 PAINT FACE",  0, 0, 180, 46, Color3.fromRGB(11,95,226), 14)
-- Apply selected color to all faces
local applyAllBtn  = mkBtn(applyFrame,"🖌 ALL FACES",  188, 0, 160, 46, Color3.fromRGB(60,20,90), 14)
-- Apply full canvas average to all faces
local applyCanvasBtn = mkBtn(applyFrame,"✓ APPLY CANVAS", 356, 0, 170, 46, Color3.fromRGB(20,90,20), 13)

applyFaceBtn.MouseButton1Click:Connect(function()
    if #fistBricks == 0 then setStatus("Grab a brick first!"); return end
    for _, brick in ipairs(fistBricks) do
        if brick and brick.Parent then
            paintFace(brick, painterFace, painterColor, painterText)
        end
    end
    setStatus("Painted " .. faceNames[painterFace] .. " face on " .. #fistBricks .. " brick(s)")
end)

applyAllBtn.MouseButton1Click:Connect(function()
    if #fistBricks == 0 then setStatus("Grab a brick first!"); return end
    task.spawn(function() applySolidColor(painterColor) end)
    setStatus("Painted all faces on " .. #fistBricks .. " brick(s)")
end)

applyCanvasBtn.MouseButton1Click:Connect(function()
    if #fistBricks == 0 then setStatus("Grab a brick first!"); return end
    task.spawn(function() applyPainterToBricks() end)
    setStatus("Applied full canvas to " .. #fistBricks .. " brick(s)")
end)

-- ── MATERIAL SELECTOR ──────────────────────────────────────
local matFrame = Instance.new("Frame", painterPanel)
matFrame.Size=UDim2.new(1,-16,0,70); matFrame.Position=UDim2.fromOffset(8,326)
matFrame.BackgroundTransparency=1

local matLbl = Instance.new("TextLabel", matFrame)
matLbl.Size=UDim2.fromOffset(200,22); matLbl.BackgroundTransparency=1
matLbl.Text="MATERIAL"; matLbl.Font=Enum.Font.GothamBold; matLbl.TextSize=11
matLbl.TextColor3=Color3.fromRGB(80,80,120); matLbl.TextXAlignment=Enum.TextXAlignment.Left

local materials = {"plastic","neon","glass","wood","metal","slate"}
local matX = 0
for _, mat in ipairs(materials) do
    local mb = mkBtn(matFrame, mat, matX, 24, 100, 38, Color3.fromRGB(38,38,60), 11)
    matX = matX + 104
    mb.MouseButton1Click:Connect(function()
        local remote, rootPos = getPaintRemote()
        local brick = getBrick and getBrick() or ReplicatedStorage:FindFirstChild("Brick")
        if remote and brick then
            for _, fb in ipairs(fistBricks) do
                if fb and fb.Parent then
                    pcall(function() remote:FireServer(brick, Enum.NormalId.Top, rootPos, "both \u{1F91D}", painterColor, mat, "") end)
                end
            end
            setStatus("Material set: " .. mat)
        end
    end)
end

-- ── ANCHOR TOGGLE ──────────────────────────────────────────
local anchorBtn = mkBtn(painterPanel,"⚓ TOGGLE ANCHOR", 8, 404, 200, 44, Color3.fromRGB(40,60,20), 14)
anchorBtn.MouseButton1Click:Connect(function()
    for _, brick in ipairs(fistBricks) do
        if brick and brick.Parent then
            brick.Anchored = not brick.Anchored
            claimOwnership(brick)
        end
    end
    setStatus("Anchor toggled on " .. #fistBricks .. " brick(s)")
end)

local sizeBtn = mkBtn(painterPanel,"📐 RESIZE BRICKS", 216, 404, 200, 44, Color3.fromRGB(40,40,70), 14)
local sizeVal = 3
sizeBtn.MouseButton1Click:Connect(function()
    sizeVal = sizeVal == 3 and 5 or (sizeVal == 5 and 7 or 3)
    for _, brick in ipairs(fistBricks) do
        if brick and brick.Parent then
            brick.Size = Vector3.new(sizeVal, sizeVal, sizeVal)
        end
    end
    setStatus("Bricks resized to " .. sizeVal)
    sizeBtn.Text = "📐 SIZE: " .. sizeVal
end)

-- ============================================================
-- PAINTER TOGGLE
-- ============================================================
painterToggleBtn.MouseButton1Click:Connect(function()
    painterPanel.Visible = not painterPanel.Visible
    painterToggleBtn.BackgroundColor3 = painterPanel.Visible
        and Color3.fromRGB(11,95,226)
        or Color3.fromRGB(60,20,90)
end)
closeBtn.MouseButton1Click:Connect(function()
    painterPanel.Visible = false
    painterToggleBtn.BackgroundColor3 = Color3.fromRGB(60,20,90)
end)

-- ============================================================
-- KEYBOARD (PC)
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local k = input.KeyCode
    if     k==Enum.KeyCode.G     then grabBtn:MouseButton1Click()
    elseif k==Enum.KeyCode.R     then releaseBtn:MouseButton1Click()
    elseif k==Enum.KeyCode.F     then task.spawn(doPunch)
    elseif k==Enum.KeyCode.P     then painterPanel.Visible=not painterPanel.Visible
    elseif k==Enum.KeyCode.Left  then aimH=aimH-ROTATE_STEP
    elseif k==Enum.KeyCode.Right then aimH=aimH+ROTATE_STEP
    elseif k==Enum.KeyCode.Up    then aimV=math.clamp(aimV-ROTATE_STEP,-80,80)
    elseif k==Enum.KeyCode.Down  then aimV=math.clamp(aimV+ROTATE_STEP,-80,80)
    elseif k==Enum.KeyCode.Q     then extraOffset=extraOffset+Vector3.new(0,MOVE_STEP,0)
    elseif k==Enum.KeyCode.E     then extraOffset=extraOffset-Vector3.new(0,MOVE_STEP,0)
    end
end)

-- ============================================================
-- RESET ON RESPAWN
-- ============================================================
player.CharacterAdded:Connect(function()
    deactivate()
    setStatus("Respawned — grab a brick again")
end)

print("[BLOCK FIST v3] Loaded!")
print("  G=Grab  R=Release  F=Punch  P=Painter")
print("  Arrows=Aim  Q/E=Height")
