-- ============================================================
-- BLOCK FIST v6
-- Grab method: rawscripts.net/raw/Universal-Script-Unanchored-Part-Abuse-WIP-23861
-- Click ANY block (anchored or not) → owned instantly via SimulationRadius
-- Canvas = top-down surround view — draw circle → blocks circle around you
-- ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player           = Players.LocalPlayer
local camera           = workspace.CurrentCamera

-- ============================================================
-- CONFIG
-- ============================================================
local MAX_BLOCKS    = 25
local BLOCK_SPACING = 5       -- studs between blocks in surround formation
local CANVAS_GRID   = 10      -- 10x10 top-down canvas
local SURROUND_Y    = 3       -- height blocks float above player
local PUNCH_DIST    = 20      -- how far blocks fly outward on punch
local PUNCH_STEPS   = 8
local RETURN_STEPS  = 10
local STEP_WAIT     = 0.05

-- ============================================================
-- STATE
-- ============================================================
local grabbedBlocks = {}
local selectMode    = false
local isPunching    = false
local isActive      = false
local drawnCells    = {}
local cellButtons   = {}
local useDrawing    = false
local cellOffsets   = {}   -- cached XZ offsets (top-down, surrounding player)

for r = 1, CANVAS_GRID do
    drawnCells[r] = {}
    for c = 1, CANVAS_GRID do drawnCells[r][c] = false end
end

-- ============================================================
-- GRAB METHOD — exact SimulationRadius + BodyPosition from source
-- rawscripts.net/raw/Universal-Script-Unanchored-Part-Abuse-WIP-23861
-- ============================================================
local networkOwned  = {}  -- [brick] = {canCollide,canTouch,cPhys,cGroup,anchored}
local bodyPositions = {}  -- [brick] = BodyPosition
local angleAccum    = {}  -- [brick] = angle accumulator (for orbit spin)

local function setSimRadius(r)
    pcall(function() sethiddenproperty(player, "SimulationRadius", r) end)
end

-- retain() from source — zero friction, no collision, unanchor
local function retain(brick)
    if networkOwned[brick] then return end
    local props = {brick.CanCollide, brick.CanTouch, brick.CustomPhysicalProperties,
                   brick.CollisionGroup or "Default", brick.Anchored}
    networkOwned[brick] = props
    pcall(function()
        brick.CustomPhysicalProperties = PhysicalProperties.new(0.01,0,0,0,0)
    end)
    brick.CanCollide = false
    brick.CanTouch   = false
    brick.Anchored   = false  -- unanchor so BodyPosition can drive it
end

-- unretain() — restore all original properties, destroy BodyPosition
local function unretain(brick)
    local props = networkOwned[brick]
    if not props then return end
    networkOwned[brick] = nil
    angleAccum[brick]   = nil
    local bp = bodyPositions[brick]
    if bp then pcall(function() bp:Destroy() end); bodyPositions[brick] = nil end
    pcall(function() brick.CollisionGroup = props[4] end)
    pcall(function() brick.CustomPhysicalProperties = props[3] end)
    brick.CanCollide = props[1]
    brick.CanTouch   = props[2]
    brick.Anchored   = props[5]
end

-- dopart2() from source — mass-scaled BodyPosition
local function dopart2(brick)
    if player.Character and brick:IsDescendantOf(player.Character) then return end
    retain(brick)
    setSimRadius(2000)
    if bodyPositions[brick] and bodyPositions[brick].Parent == brick then return end
    local m  = brick:GetMass()
    local bp = Instance.new("BodyPosition")
    bp.Name     = "FistBP"
    bp.P        = m / 0.64e-5
    bp.D        = m / 0.64e-3
    bp.MaxForce = Vector3.new(m/0.64e-6, m/0.64e-6, m/0.64e-6)
    bp.Position = brick.Position
    bp.Parent   = brick
    bodyPositions[brick] = bp
    -- Give each block a unique starting angle so they don't all stack
    angleAccum[brick] = math.random() * math.pi * 2
end

-- ============================================================
-- PLAYER BRICKS CHECK — accept any workspace part that's not terrain/char
-- ============================================================
local function isGrabbable(part)
    if not part or not part:IsA("BasePart") then return false end
    if part == workspace.Terrain then return false end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and part:IsDescendantOf(p.Character) then return false end
    end
    return true
end

-- ============================================================
-- RAYCAST — click any grabbable block
-- ============================================================
local function raycastBlock(screenPos)
    local ray    = camera:ScreenPointToRay(screenPos.X, screenPos.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local chars = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then table.insert(chars, p.Character) end
    end
    params.FilterDescendantsInstances = chars
    local result = workspace:Raycast(ray.Origin, ray.Direction * 600, params)
    if result and result.Instance and isGrabbable(result.Instance) then
        return result.Instance
    end
    return nil
end

-- ============================================================
-- GRAB / RELEASE
-- ============================================================
local selectionBoxes = {}

local function addBlock(brick)
    for _, b in ipairs(grabbedBlocks) do if b == brick then return end end
    if #grabbedBlocks >= MAX_BLOCKS then print("[FIST] Max "..MAX_BLOCKS.." blocks"); return end
    dopart2(brick)
    table.insert(grabbedBlocks, brick)
    isActive = true
    local box = Instance.new("SelectionBox", workspace)
    box.Adornee = brick
    box.Color3  = Color3.fromRGB(11, 95, 226)
    box.LineThickness = 0.06
    box.SurfaceTransparency = 0.7
    box.SurfaceColor3 = Color3.fromRGB(11, 95, 226)
    selectionBoxes[brick] = box
    print("[FIST] Grabbed: "..brick.Name.." ("..#grabbedBlocks.."/"..MAX_BLOCKS..")")
end

local function removeBlock(brick)
    for i, b in ipairs(grabbedBlocks) do
        if b == brick then
            table.remove(grabbedBlocks, i)
            if selectionBoxes[brick] then selectionBoxes[brick]:Destroy(); selectionBoxes[brick] = nil end
            unretain(brick)
            break
        end
    end
    if #grabbedBlocks == 0 then
        isActive = false
        setSimRadius(0)
    end
end

local function releaseAll()
    for _, box in pairs(selectionBoxes) do box:Destroy() end
    selectionBoxes = {}
    for _, brick in ipairs(grabbedBlocks) do pcall(function() unretain(brick) end) end
    grabbedBlocks = {}
    isActive      = false
    isPunching    = false
    setSimRadius(0)
    print("[FIST] Released all — ownership restored")
end

-- ============================================================
-- CANVAS → TOP-DOWN SURROUND OFFSETS
-- Canvas represents a bird's eye view around the player.
-- Center cell (5,5) = on top of player.
-- Drawn cells = XZ positions where blocks will float around you.
-- Draw a circle = blocks form a ring around you.
-- ============================================================
local function getCellOffsets()
    local cells = {}
    for r = 1, CANVAS_GRID do
        for c = 1, CANVAS_GRID do
            if drawnCells[r][c] then
                -- X = left/right, Z = forward/back around player
                local offX = (c - (CANVAS_GRID/2 + 0.5)) * BLOCK_SPACING
                local offZ = (r - (CANVAS_GRID/2 + 0.5)) * BLOCK_SPACING
                table.insert(cells, Vector3.new(offX, 0, offZ))
            end
        end
    end
    return cells
end

-- Default: evenly spaced ring around player
local function getDefaultOffsets(count)
    local offsets = {}
    local radius  = math.max(6, count * 1.2)
    for i = 1, count do
        local angle = (i-1) / count * math.pi * 2
        table.insert(offsets, Vector3.new(math.cos(angle)*radius, 0, math.sin(angle)*radius))
    end
    return offsets
end

local function applyDrawing()
    cellOffsets = getCellOffsets()
    if #cellOffsets == 0 then
        useDrawing = false
        print("[FIST] No drawing — using default ring")
        return
    end
    useDrawing = true
    print("[FIST] Drawing applied — "..#cellOffsets.." positions around you")
end

-- ============================================================
-- FOLLOW HEARTBEAT — blocks surround player at drawn positions
-- ============================================================
local hbConn = nil

local function startFollow()
    if hbConn then hbConn:Disconnect() end
    hbConn = RunService.Heartbeat:Connect(function()
        if not isActive or isPunching or #grabbedBlocks == 0 then return end
        setSimRadius(2000)  -- keep alive every frame (source method)

        local char = player.Character; if not char then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local center = hrp.Position + Vector3.new(0, SURROUND_Y, 0)

        local offsets = useDrawing and cellOffsets or getDefaultOffsets(#grabbedBlocks)

        for i, brick in ipairs(grabbedBlocks) do
            if brick and brick.Parent then
                local off    = offsets[i] or offsets[((i-1) % #offsets) + 1]
                local target = center + off  -- XZ surround in world space
                local bp     = bodyPositions[brick]
                if bp then bp.Position = target end
            end
        end
    end)
end

-- ============================================================
-- PUNCH — blocks explode outward from player then return
-- ============================================================
local function doPunch()
    if isPunching or #grabbedBlocks == 0 then return end
    isPunching = true

    local char = player.Character; if not char then isPunching=false; return end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then isPunching=false; return end
    local center = hrp.Position + Vector3.new(0, SURROUND_Y, 0)
    local offsets = useDrawing and cellOffsets or getDefaultOffsets(#grabbedBlocks)

    -- Capture current positions as start
    local startPositions = {}
    for i, brick in ipairs(grabbedBlocks) do
        local off = offsets[i] or offsets[((i-1) % #offsets) + 1]
        startPositions[i] = center + off
    end

    -- PUNCH OUT — each block flies outward from player center
    for step = 1, PUNCH_STEPS do
        if not isActive then break end
        setSimRadius(2000)
        local newCenter = hrp.Position + Vector3.new(0, SURROUND_Y, 0)
        for i, brick in ipairs(grabbedBlocks) do
            if brick and brick.Parent then
                local sp  = startPositions[i]
                local dir = (sp - newCenter)
                local len = dir.Magnitude
                if len < 0.1 then dir = Vector3.new(1,0,0) end
                local target = newCenter + dir.Unit * (len + PUNCH_DIST * (step/PUNCH_STEPS))
                local bp = bodyPositions[brick]
                if bp then bp.Position = target end
            end
        end
        task.wait(STEP_WAIT)
    end

    task.wait(0.08)

    -- RETURN — fly back to surround positions
    for step = 1, RETURN_STEPS do
        if not isActive then break end
        setSimRadius(2000)
        local newCenter = hrp.Position + Vector3.new(0, SURROUND_Y, 0)
        for i, brick in ipairs(grabbedBlocks) do
            if brick and brick.Parent then
                local off    = offsets[i] or offsets[((i-1) % #offsets) + 1]
                local dest   = newCenter + off
                local bp     = bodyPositions[brick]
                if bp then bp.Position = bp.Position:Lerp(dest, step/RETURN_STEPS) end
            end
        end
        task.wait(STEP_WAIT)
    end

    isPunching = false
end

-- ============================================================
-- INPUT
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if selectMode and (
        input.UserInputType == Enum.UserInputType.MouseButton1 or
        input.UserInputType == Enum.UserInputType.Touch) then
        local pos
        if input.UserInputType == Enum.UserInputType.Touch then
            pos = input.Position
        else
            pos = UserInputService:GetMouseLocation()
        end
        local brick = raycastBlock(pos)
        if brick then
            -- Toggle: click again to deselect
            local found = false
            for _, b in ipairs(grabbedBlocks) do
                if b == brick then found = true; break end
            end
            if found then
                removeBlock(brick)
                print("[FIST] Deselected: "..brick.Name)
            else
                addBlock(brick)
            end
        end
    end

    if input.KeyCode == Enum.KeyCode.T then
        selectMode = not selectMode
        print("[FIST] Select mode: "..(selectMode and "ON" or "OFF"))
    end
    if input.KeyCode == Enum.KeyCode.R then releaseAll() end
    if input.KeyCode == Enum.KeyCode.F then task.spawn(doPunch) end
end)

-- ============================================================
-- GUI
-- ============================================================
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name           = "FistController"
screenGui.ResetOnSpawn   = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function mkFrame(parent, size, pos, color, alpha, radius)
    local f = Instance.new("Frame", parent)
    f.Size = size; f.Position = pos
    f.BackgroundColor3 = color or Color3.fromRGB(30,30,50)
    f.BackgroundTransparency = alpha or 0
    f.BorderSizePixel = 0
    if radius then Instance.new("UICorner", f).CornerRadius = UDim.new(0, radius) end
    return f
end

local function mkBtn(parent, text, size, pos, color, textColor, fontSize)
    local b = Instance.new("TextButton", parent)
    b.Size = size; b.Position = pos
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = fontSize or 13
    b.TextColor3 = textColor or Color3.new(1,1,1)
    b.BackgroundColor3 = color or Color3.fromRGB(40,40,70)
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local function mkLbl(parent, text, size, pos, fontSize, color)
    local l = Instance.new("TextLabel", parent)
    l.Size = size; l.Position = pos
    l.Text = text; l.Font = Enum.Font.GothamBold
    l.TextSize = fontSize or 11
    l.TextColor3 = color or Color3.fromRGB(160,160,200)
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Center
    return l
end

-- Main panel
local panel = mkFrame(screenGui, UDim2.fromOffset(380, 480),
    UDim2.new(0.5,-190,0.5,-240), Color3.fromRGB(22,22,38), 0, 16)

mkLbl(panel, "🖐  BLOCK FIST v6", UDim2.fromOffset(380,28), UDim2.fromOffset(0,6), 15, Color3.fromRGB(11,95,226))

-- Status label
local statusLbl = mkLbl(panel, "Select: OFF  |  Blocks: 0/25",
    UDim2.fromOffset(360,18), UDim2.fromOffset(10,32), 10, Color3.fromRGB(100,100,140))

local function updateStatus()
    statusLbl.Text = "Select: "..(selectMode and "ON" or "OFF").."  |  Blocks: "..#grabbedBlocks.."/"..MAX_BLOCKS
end

-- ============================================================
-- CANVAS — top-down 10×10 grid
-- ============================================================
local canvasPanel = mkFrame(panel, UDim2.fromOffset(220,220), UDim2.fromOffset(10,58),
    Color3.fromRGB(16,16,30), 0, 10)

local CELL = 20  -- px per cell
local isMouseDown = false

local function updateCell(r, c, val)
    if r < 1 or r > CANVAS_GRID or c < 1 or c > CANVAS_GRID then return end
    drawnCells[r][c] = val
    local btn = cellButtons[r] and cellButtons[r][c]
    if btn then
        btn.BackgroundColor3 = val and Color3.fromRGB(11,95,226) or Color3.fromRGB(30,30,50)
    end
end

local function clearCanvas()
    for r = 1, CANVAS_GRID do
        for c = 1, CANVAS_GRID do updateCell(r,c,false) end
    end
    useDrawing = false
    cellOffsets = {}
end

-- Build grid
for r = 1, CANVAS_GRID do
    cellButtons[r] = {}
    for c = 1, CANVAS_GRID do
        local btn = Instance.new("TextButton", canvasPanel)
        btn.Size = UDim2.fromOffset(CELL-1, CELL-1)
        btn.Position = UDim2.fromOffset((c-1)*CELL+1, (r-1)*CELL+1)
        btn.Text = ""
        btn.BackgroundColor3 = Color3.fromRGB(30,30,50)
        btn.BorderSizePixel  = 0
        btn.AutoButtonColor  = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,3)
        cellButtons[r][c] = btn

        btn.MouseButton1Down:Connect(function()
            isMouseDown = true
            local newVal = not drawnCells[r][c]
            updateCell(r, c, newVal)
        end)
        btn.MouseEnter:Connect(function()
            if isMouseDown then
                updateCell(r, c, true)
            end
        end)
    end
end

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        isMouseDown = false
    end
end)

-- Preset: circle
local function presetCircle()
    clearCanvas()
    local cx, cy = CANVAS_GRID/2+0.5, CANVAS_GRID/2+0.5
    local rad = 4
    for r = 1, CANVAS_GRID do
        for c = 1, CANVAS_GRID do
            local dx = c - cx; local dy = r - cy
            local d  = math.sqrt(dx*dx+dy*dy)
            if d >= rad-0.7 and d <= rad+0.7 then updateCell(r,c,true) end
        end
    end
end

-- Preset: ring close
local function presetRingClose()
    clearCanvas()
    local cx, cy = CANVAS_GRID/2+0.5, CANVAS_GRID/2+0.5
    local rad = 2.5
    for r = 1, CANVAS_GRID do
        for c = 1, CANVAS_GRID do
            local dx = c-cx; local dy = r-cy
            local d = math.sqrt(dx*dx+dy*dy)
            if d >= rad-0.6 and d <= rad+0.6 then updateCell(r,c,true) end
        end
    end
end

-- Preset: X
local function presetX()
    clearCanvas()
    for i = 1, CANVAS_GRID do updateCell(i,i,true); updateCell(i,CANVAS_GRID+1-i,true) end
end

-- Preset: line (horizontal ring)
local function presetLine()
    clearCanvas()
    local mid = math.floor(CANVAS_GRID/2)+1
    for c = 1, CANVAS_GRID do updateCell(mid,c,true) end
end

-- Canvas action buttons (right side of canvas)
local btnX = 238
local function mkSmallBtn(label, yPos, cb)
    local b = mkBtn(panel, label, UDim2.fromOffset(128,26),
        UDim2.fromOffset(btnX, yPos), Color3.fromRGB(35,35,60),
        Color3.fromRGB(180,180,220), 11)
    b.MouseButton1Click:Connect(cb)
    return b
end

mkSmallBtn("◯ Circle",        58,  presetCircle)
mkSmallBtn("◉ Small Ring",    88,  presetRingClose)
mkSmallBtn("✕ X",             118, presetX)
mkSmallBtn("— Line",          148, presetLine)
mkSmallBtn("🗑 Clear",         178, clearCanvas)
mkSmallBtn("✓ Apply Shape",   208, function()
    applyDrawing()
end)
mkLbl(panel, "Top-down view — draw where\nblocks surround you",
    UDim2.fromOffset(128,30), UDim2.fromOffset(btnX,240), 9, Color3.fromRGB(80,80,110))

-- ============================================================
-- CONTROL BUTTONS
-- ============================================================
local function mkCtrlBtn(label, xOff, yOff, color, cb)
    local b = mkBtn(panel, label, UDim2.fromOffset(82,38),
        UDim2.fromOffset(xOff,yOff), color)
    b.MouseButton1Click:Connect(cb)
    return b
end

local selBtn = mkCtrlBtn("👆 SELECT", 10, 292, Color3.fromRGB(30,80,160), function()
    selectMode = not selectMode
    updateStatus()
end)

mkCtrlBtn("🗑 RELEASE", 100, 292, Color3.fromRGB(120,40,40), function()
    releaseAll(); updateStatus()
end)

mkCtrlBtn("✓ APPLY",   190, 292, Color3.fromRGB(20,100,60), function()
    applyDrawing()
end)

-- BIG PUNCH
local punchBtn = mkBtn(panel, "💥  PUNCH",
    UDim2.fromOffset(340,50), UDim2.fromOffset(10,338),
    Color3.fromRGB(160,30,30), Color3.new(1,1,1), 18)
punchBtn.MouseButton1Click:Connect(function() task.spawn(doPunch) end)

-- Height control
mkLbl(panel, "Height offset: "..SURROUND_Y.." studs",
    UDim2.fromOffset(340,16), UDim2.fromOffset(10,396), 10)
local heightLbl = mkLbl(panel, tostring(SURROUND_Y),
    UDim2.fromOffset(60,24), UDim2.fromOffset(150,418), 14, Color3.fromRGB(11,95,226))

mkCtrlBtn("▲ UP",   10,  418, Color3.fromRGB(40,60,100), function()
    SURROUND_Y = SURROUND_Y + 2; heightLbl.Text = tostring(SURROUND_Y)
end)
mkCtrlBtn("▼ DOWN", 100, 418, Color3.fromRGB(40,60,100), function()
    SURROUND_Y = SURROUND_Y - 2; heightLbl.Text = tostring(SURROUND_Y)
end)
mkCtrlBtn("R RESET",200, 418, Color3.fromRGB(60,40,80), function()
    SURROUND_Y = 3; heightLbl.Text = tostring(SURROUND_Y)
end)

-- Drag handle
local dragging, dragStart, startPos = false, nil, nil
panel.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = i.Position; startPos = panel.Position
    end
end)
panel.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
                                    startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)

-- Keyboard shortcuts label
mkLbl(panel, "T=Select  R=Release  F=Punch",
    UDim2.fromOffset(340,14), UDim2.fromOffset(10,460), 9, Color3.fromRGB(60,60,90))

-- ============================================================
-- STATUS LOOP
-- ============================================================
RunService.Heartbeat:Connect(function()
    updateStatus()
    local sel = selectMode
    selBtn.BackgroundColor3 = sel and Color3.fromRGB(11,95,226) or Color3.fromRGB(30,80,160)
end)

-- ============================================================
-- START
-- ============================================================
startFollow()
presetCircle()  -- default to circle so blocks surround immediately
print("[FIST v6] Loaded — T=Select blocks, draw canvas, Apply Shape, F=Punch")
