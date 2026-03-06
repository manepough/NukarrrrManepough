-- ============================================================
-- BLOCK FIST v5
-- • Tap a PLAYER-PLACED brick (ignores map/baseplate)
-- • Draw on canvas → blocks arrange into that shape in 3D
-- • FE — everyone sees the block movement
-- credit: stik
-- ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local player           = Players.LocalPlayer
local camera           = workspace.CurrentCamera

-- ============================================================
-- CONFIG
-- ============================================================
local MAX_BLOCKS    = 25      -- max blocks you can grab
local BLOCK_SPACING = 3.5     -- studs between blocks in formation
local CANVAS_GRID   = 10      -- 10x10 draw grid
local PUNCH_DIST    = 14
local PUNCH_SPEED   = 0.07
local RETURN_SPEED  = 0.18

-- ============================================================
-- STATE
-- ============================================================
local grabbedBlocks  = {}     -- {brick, originalCFrame}
local isActive       = false
local isPunching     = false
local aimH           = 0
local aimV           = 0
local heightOffset   = 2
local selectMode     = false  -- true = clicking selects blocks
local drawnCells     = {}     -- [row][col] = true/false (the drawing)
local isDrawing      = false
local drawValue      = true   -- true=paint, false=erase
local cellButtons    = {}     -- GUI grid buttons
local holding        = {up=false,down=false,left=false,right=false,hiUp=false,hiDown=false}

-- Init drawn cells
for r = 1, CANVAS_GRID do
    drawnCells[r] = {}
    for c = 1, CANVAS_GRID do drawnCells[r][c] = false end
end

-- ============================================================
-- FE — TAKE NETWORK OWNERSHIP
-- ============================================================
local function claimOwnership(brick)
    pcall(function() brick:SetNetworkOwner(player) end)
end

-- ============================================================
-- PLAYER BRICKS FOLDER — only grab from here
-- ============================================================
local function getPlayerBricksFolder()
    local names = {"Bricks","Build","Placed","UserBricks","PlayerBricks","Blocks"}
    for _, name in ipairs(names) do
        local f = workspace:FindFirstChild(name)
        if f then return f end
    end
    return nil
end

local function isPlayerBrick(part)
    if not part then return false end
    if not part:IsA("BasePart") then return false end
    if part == workspace.Terrain then return false end
    local folder = getPlayerBricksFolder()
    if folder and part:IsDescendantOf(folder) then return true end
    return false
end

-- ============================================================
-- RAYCAST — click a player-placed block only
-- ============================================================
local function raycastBlock(screenPos)
    local unitRay = camera:ScreenPointToRay(screenPos.X, screenPos.Y)
    local params  = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    -- Exclude all player characters
    local chars = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then table.insert(chars, p.Character) end
    end
    params.FilterDescendantsInstances = chars

    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, params)
    if result and result.Instance then
        local part = result.Instance
        -- ONLY accept bricks inside the player bricks folder
        -- Tapping the map, baseplate, terrain → ignored
        if isPlayerBrick(part) then
            return part
        end
    end
    return nil
end

-- ============================================================
-- GRAB / RELEASE
-- ============================================================
local selectionBoxes = {} -- visual highlight

local function addBlock(brick)
    -- Already grabbed?
    for _, b in ipairs(grabbedBlocks) do if b == brick then return end end
    if #grabbedBlocks >= MAX_BLOCKS then
        print("[FIST] Max blocks reached ("..MAX_BLOCKS..")"); return
    end

    claimOwnership(brick)
    table.insert(grabbedBlocks, brick)

    -- Visual: selection box highlight
    local box = Instance.new("SelectionBox", workspace)
    box.Adornee       = brick
    box.Color3        = Color3.fromRGB(11, 95, 226)
    box.LineThickness = 0.06
    box.SurfaceTransparency = 0.7
    box.SurfaceColor3 = Color3.fromRGB(11, 95, 226)
    selectionBoxes[brick] = box

    print("[FIST] Grabbed: "..brick.Name.." ("..#grabbedBlocks.." total)")
end

local function removeBlock(brick)
    for i, b in ipairs(grabbedBlocks) do
        if b == brick then
            table.remove(grabbedBlocks, i)
            if selectionBoxes[brick] then
                selectionBoxes[brick]:Destroy()
                selectionBoxes[brick] = nil
            end
            return
        end
    end
end

local function releaseAll()
    for _, box in pairs(selectionBoxes) do box:Destroy() end
    selectionBoxes  = {}
    grabbedBlocks   = {}
    isActive        = false
    print("[FIST] Released all blocks")
end

-- ============================================================
-- POSITION MATH — base CFrame in front of player
-- ============================================================
local function getBaseCFrame()
    local char = player.Character; if not char then return nil end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    return hrp.CFrame
        * CFrame.Angles(0, math.rad(aimH), 0)
        * CFrame.Angles(math.rad(aimV), 0, 0)
        * CFrame.new(0, heightOffset, -7)
end

-- Convert drawn cells into world offsets
-- Returns array of Vector3 offsets from base position
local function getCellOffsets()
    local cells = {}
    for r = 1, CANVAS_GRID do
        for c = 1, CANVAS_GRID do
            if drawnCells[r][c] then
                -- Center the drawing
                local offX = (c - (CANVAS_GRID/2 + 0.5)) * BLOCK_SPACING
                local offY = ((CANVAS_GRID/2 + 0.5) - r) * BLOCK_SPACING
                table.insert(cells, Vector3.new(offX, offY, 0))
            end
        end
    end
    return cells
end

-- Get default formation offsets (when no drawing)
local function getDefaultOffsets(count)
    local offsets = {}
    for i = 1, count do
        local col = (i-1) % 5
        local row = math.floor((i-1) / 5)
        table.insert(offsets, Vector3.new((col-2)*BLOCK_SPACING, (1-row)*BLOCK_SPACING, 0))
    end
    return offsets
end

-- ============================================================
-- FOLLOW HEARTBEAT — blocks follow player in drawn pattern
-- ============================================================
local hbConn    = nil
local useDrawing = false  -- whether to use drawn shape or default
local cellOffsets = {}    -- cached offsets from drawing

local function startFollow()
    if hbConn then hbConn:Disconnect() end
    hbConn = RunService.Heartbeat:Connect(function()
        if not isActive or isPunching or #grabbedBlocks == 0 then return end
        local base = getBaseCFrame(); if not base then return end
        local offsets = useDrawing and cellOffsets or getDefaultOffsets(#grabbedBlocks)

        for i, brick in ipairs(grabbedBlocks) do
            if brick and brick.Parent then
                local offset = offsets[i] or offsets[#offsets] or Vector3.new(0,0,0)
                brick.CFrame = base * CFrame.new(offset)
            end
        end
    end)
end

-- ============================================================
-- APPLY DRAWING TO BLOCKS
-- Arranges grabbed blocks into the drawn shape
-- ============================================================
local function applyDrawing()
    cellOffsets = getCellOffsets()
    local needed = #cellOffsets
    local have   = #grabbedBlocks

    if needed == 0 then
        useDrawing = false
        print("[FIST] No drawing — using default formation")
        return
    end

    if have < needed then
        print("[FIST] Need "..needed.." blocks but only have "..have.." — grab more!")
    end

    useDrawing = true
    print("[FIST] Drawing applied — "..needed.." cells, "..have.." blocks")
end

-- ============================================================
-- PUNCH
-- ============================================================
local function doPunch()
    if isPunching or #grabbedBlocks == 0 then return end
    isPunching = true

    local char = player.Character; if not char then isPunching=false; return end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then isPunching=false; return end
    local base = getBaseCFrame(); if not base then isPunching=false; return end
    local fwd  = base.LookVector

    local offsets  = useDrawing and cellOffsets or getDefaultOffsets(#grabbedBlocks)
    local startCFs = {}
    for i, brick in ipairs(grabbedBlocks) do
        local offset = offsets[i] or offsets[#offsets] or Vector3.new(0,0,0)
        startCFs[i] = base * CFrame.new(offset)
    end

    for step = 1, 6 do
        if not isActive then break end
        for i, brick in ipairs(grabbedBlocks) do
            if brick and brick.Parent and startCFs[i] then
                brick.CFrame = startCFs[i]:Lerp(startCFs[i] + fwd*PUNCH_DIST, step/6)
            end
        end
        task.wait(PUNCH_SPEED/6)
    end

    task.wait(0.05)
    local punchedCFs = {}
    for i, s in ipairs(startCFs) do punchedCFs[i] = s + fwd*PUNCH_DIST end

    for step = 1, 8 do
        if not isActive then break end
        for i, brick in ipairs(grabbedBlocks) do
            if brick and brick.Parent and punchedCFs[i] and startCFs[i] then
                brick.CFrame = punchedCFs[i]:Lerp(startCFs[i], step/8)
            end
        end
        task.wait(RETURN_SPEED/8)
    end

    isPunching = false
end

-- ============================================================
-- Hold-to-aim heartbeat
-- ============================================================
local holdTimer = 0
RunService.Heartbeat:Connect(function(dt)
    holdTimer = holdTimer + dt
    if holdTimer < 0.1 then return end
    holdTimer = 0
    if holding.left   then aimH = aimH - 15 end
    if holding.right  then aimH = aimH + 15 end
    if holding.up     then aimV = math.clamp(aimV-15,-80,80) end
    if holding.down   then aimV = math.clamp(aimV+15,-80,80) end
    if holding.hiUp   then heightOffset = heightOffset + 2 end
    if holding.hiDown then heightOffset = heightOffset - 2 end
end)

-- ============================================================
-- INPUT — click block to select when in select mode
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    -- Block selection click
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
            -- If already grabbed, remove it (deselect)
            local found = false
            for _, b in ipairs(grabbedBlocks) do if b == brick then found=true; break end end
            if found then
                removeBlock(brick)
                print("[FIST] Deselected: "..brick.Name)
            else
                addBlock(brick)
                if not isActive then
                    isActive = true
                    startFollow()
                end
            end
        end
    end
end)

-- ============================================================
-- CLEANUP OLD GUI
-- ============================================================
if player.PlayerGui:FindFirstChild("FistPad") then
    player.PlayerGui.FistPad:Destroy()
end

-- ============================================================
-- GUI ROOT
-- ============================================================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name           = "FistPad"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ============================================================
-- STATUS BAR
-- ============================================================
local statusBar = Instance.new("Frame", gui)
statusBar.Size             = UDim2.new(1, 0, 0, 44)
statusBar.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
statusBar.BorderSizePixel  = 0

local statusLbl = Instance.new("TextLabel", statusBar)
statusLbl.Size                   = UDim2.new(1, -140, 1, 0)
statusLbl.Position               = UDim2.fromOffset(8, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Font                   = Enum.Font.GothamBold
statusLbl.TextSize               = 13
statusLbl.TextColor3             = Color3.fromRGB(11, 95, 226)
statusLbl.Text                   = "Tap SELECT then tap blocks in the world"
statusLbl.TextXAlignment         = Enum.TextXAlignment.Left

local function setStatus(t) statusLbl.Text = t end

-- ============================================================
-- BUTTON FACTORY
-- ============================================================
local function mkBtn(parent, text, x, y, w, h, col, ts)
    local origCol = col or Color3.fromRGB(38, 38, 60)
    local btn = Instance.new("TextButton", parent)
    btn.Size             = UDim2.fromOffset(w, h)
    btn.Position         = UDim2.fromOffset(x, y)
    btn.Text             = text
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = ts or 16
    btn.TextColor3       = Color3.fromRGB(230, 230, 255)
    btn.BackgroundColor3 = origCol
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    local function pressColor()
        TweenService:Create(btn, TweenInfo.new(0.06), {BackgroundColor3=Color3.fromRGB(11,95,226)}):Play()
    end
    local function releaseColor()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=origCol}):Play()
    end
    btn.MouseButton1Down:Connect(pressColor)
    btn.MouseButton1Up:Connect(releaseColor)
    btn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then pressColor() end end)
    btn.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then releaseColor() end end)
    return btn
end

local function holdBtn(btn, key)
    btn.MouseButton1Down:Connect(function() holding[key]=true end)
    btn.MouseButton1Up:Connect(function()   holding[key]=false end)
    btn.InputBegan:Connect(function(i)  if i.UserInputType==Enum.UserInputType.Touch then holding[key]=true end end)
    btn.InputEnded:Connect(function(i)  if i.UserInputType==Enum.UserInputType.Touch then holding[key]=false end end)
end

-- ============================================================
-- DRAWER PANEL TOGGLE (top right)
-- ============================================================
local drawerToggleBtn = Instance.new("TextButton", statusBar)
drawerToggleBtn.Size             = UDim2.fromOffset(130, 44)
drawerToggleBtn.Position         = UDim2.new(1, -130, 0, 0)
drawerToggleBtn.Text             = "🖊 DRAW"
drawerToggleBtn.Font             = Enum.Font.GothamBold
drawerToggleBtn.TextSize         = 14
drawerToggleBtn.TextColor3       = Color3.fromRGB(230, 230, 255)
drawerToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 90)
drawerToggleBtn.BorderSizePixel  = 0
drawerToggleBtn.AutoButtonColor  = false
Instance.new("UICorner", drawerToggleBtn).CornerRadius = UDim.new(0, 0)

-- ============================================================
-- DRAWER PANEL — the drawing canvas
-- ============================================================
local drawerPanel = Instance.new("Frame", gui)
drawerPanel.Size             = UDim2.new(1, 0, 1, -44)
drawerPanel.Position         = UDim2.fromOffset(0, 44)
drawerPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
drawerPanel.BorderSizePixel  = 0
drawerPanel.Visible          = false
drawerPanel.ZIndex           = 20

-- Header
local dHeader = Instance.new("Frame", drawerPanel)
dHeader.Size             = UDim2.new(1, 0, 0, 50)
dHeader.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
dHeader.BorderSizePixel  = 0

local dTitle = Instance.new("TextLabel", dHeader)
dTitle.Size=UDim2.fromOffset(260,50); dTitle.Position=UDim2.fromOffset(8,0)
dTitle.BackgroundTransparency=1; dTitle.Text="🖊  DRAW YOUR SHAPE"
dTitle.Font=Enum.Font.GothamBold; dTitle.TextSize=16
dTitle.TextColor3=Color3.fromRGB(11,95,226); dTitle.TextXAlignment=Enum.TextXAlignment.Left

-- Close drawer
local dClose = mkBtn(dHeader,"✕",0,0,100,50,Color3.fromRGB(80,20,20),14)
dClose.Position = UDim2.new(1,-104,0,0)
dClose.MouseButton1Click:Connect(function()
    drawerPanel.Visible=false
    drawerToggleBtn.BackgroundColor3=Color3.fromRGB(60,20,90)
end)

-- Instructions
local dInfo = Instance.new("TextLabel", drawerPanel)
dInfo.Size=UDim2.new(1,-16,0,32); dInfo.Position=UDim2.fromOffset(8,54)
dInfo.BackgroundTransparency=1
dInfo.Text="Draw your shape ↓  Each filled cell = 1 block. Grab enough blocks first!"
dInfo.Font=Enum.Font.Gotham; dInfo.TextSize=12
dInfo.TextColor3=Color3.fromRGB(116,113,117); dInfo.TextXAlignment=Enum.TextXAlignment.Left
dInfo.TextWrapped=true

-- ============================================================
-- CANVAS GRID — 10×10 cells
-- ============================================================
local CELL = 46   -- cell size in pixels (big enough for touch)
local GPAD = 2    -- gap between cells
local gridStartX = 8
local gridStartY = 92

local canvasContainer = Instance.new("Frame", drawerPanel)
canvasContainer.Size             = UDim2.fromOffset(CANVAS_GRID*(CELL+GPAD), CANVAS_GRID*(CELL+GPAD))
canvasContainer.Position         = UDim2.fromOffset(gridStartX, gridStartY)
canvasContainer.BackgroundColor3 = Color3.fromRGB(24, 24, 40)
canvasContainer.BorderSizePixel  = 0
Instance.new("UICorner",canvasContainer).CornerRadius = UDim.new(0,8)

local COL_OFF = Color3.fromRGB(28, 28, 48)
local COL_ON  = Color3.fromRGB(11, 95, 226)

-- Cell counter label
local cellCountLbl = Instance.new("TextLabel", drawerPanel)
cellCountLbl.Size=UDim2.fromOffset(300,28); cellCountLbl.Position=UDim2.fromOffset(8,gridStartY + CANVAS_GRID*(CELL+GPAD)+6)
cellCountLbl.BackgroundTransparency=1
cellCountLbl.Text="Cells drawn: 0 (need 0 blocks)"
cellCountLbl.Font=Enum.Font.GothamBold; cellCountLbl.TextSize=13
cellCountLbl.TextColor3=Color3.fromRGB(116,113,117); cellCountLbl.TextXAlignment=Enum.TextXAlignment.Left

local function countCells()
    local n = 0
    for r=1,CANVAS_GRID do for c=1,CANVAS_GRID do if drawnCells[r][c] then n=n+1 end end end
    return n
end

local function updateCellCount()
    local n = countCells()
    cellCountLbl.Text = "Cells: "..n.."  (need "..n.." blocks)  grabbed: "..#grabbedBlocks
    if n > #grabbedBlocks and #grabbedBlocks > 0 then
        cellCountLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
        cellCountLbl.Text = cellCountLbl.Text .. "  ⚠ need more!"
    else
        cellCountLbl.TextColor3 = Color3.fromRGB(116, 113, 117)
    end
end

-- Build the grid cells
for r = 1, CANVAS_GRID do
    cellButtons[r] = {}
    for c = 1, CANVAS_GRID do
        local cell = Instance.new("TextButton", canvasContainer)
        cell.Size             = UDim2.fromOffset(CELL, CELL)
        cell.Position         = UDim2.fromOffset((c-1)*(CELL+GPAD)+GPAD, (r-1)*(CELL+GPAD)+GPAD)
        cell.Text             = ""
        cell.BackgroundColor3 = COL_OFF
        cell.BorderSizePixel  = 0
        cell.AutoButtonColor  = false
        Instance.new("UICorner",cell).CornerRadius=UDim.new(0,6)

        local function setCell(row, col, val)
            drawnCells[row][col] = val
            cellButtons[row][col].BackgroundColor3 = val and COL_ON or COL_OFF
            updateCellCount()
        end

        cell.MouseButton1Down:Connect(function()
            isDrawing = true
            drawValue = not drawnCells[r][c]
            setCell(r, c, drawValue)
        end)
        cell.MouseButton1Up:Connect(function() isDrawing=false end)
        cell.MouseEnter:Connect(function()
            if isDrawing then setCell(r, c, drawValue) end
        end)

        -- Touch support
        cell.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.Touch then
                isDrawing=true
                drawValue=not drawnCells[r][c]
                setCell(r,c,drawValue)
            end
        end)
        cell.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.Touch then isDrawing=false end
        end)
        cell.InputChanged:Connect(function(i)
            if isDrawing and i.UserInputType==Enum.UserInputType.Touch then
                setCell(r,c,drawValue)
            end
        end)

        cellButtons[r][c] = cell
    end
end

-- Touch drag across cells (mobile finger swipe painting)
drawerPanel.InputChanged:Connect(function(input)
    if not isDrawing then return end
    if input.UserInputType ~= Enum.UserInputType.Touch and
       input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    -- Find which cell the touch is over
    local absPos = canvasContainer.AbsolutePosition
    local absSize = canvasContainer.AbsoluteSize
    local relX = input.Position.X - absPos.X
    local relY = input.Position.Y - absPos.Y
    if relX<0 or relY<0 or relX>absSize.X or relY>absSize.Y then return end
    local col = math.clamp(math.floor(relX/(CELL+GPAD))+1, 1, CANVAS_GRID)
    local row = math.clamp(math.floor(relY/(CELL+GPAD))+1, 1, CANVAS_GRID)
    if drawnCells[row][col] ~= drawValue then
        drawnCells[row][col] = drawValue
        cellButtons[row][col].BackgroundColor3 = drawValue and COL_ON or COL_OFF
        updateCellCount()
    end
end)
drawerPanel.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
        isDrawing=false
    end
end)

-- ============================================================
-- CANVAS ACTION BUTTONS (below grid — right side)
-- ============================================================
local btnAreaX = CANVAS_GRID*(CELL+GPAD) + gridStartX + 10
local btnAreaY = gridStartY

local applyBtn  = mkBtn(drawerPanel,"✓ FORM SHAPE",  btnAreaX, btnAreaY,    160, 60, Color3.fromRGB(20,90,20), 14)
local clearBtn  = mkBtn(drawerPanel,"✕ CLEAR",        btnAreaX, btnAreaY+68, 160, 50, Color3.fromRGB(80,20,20), 14)
local fillBtn   = mkBtn(drawerPanel,"▣ FILL ALL",     btnAreaX, btnAreaY+126,160, 50, Color3.fromRGB(40,40,80), 13)

-- Preset shapes
local presetLbl = Instance.new("TextLabel", drawerPanel)
presetLbl.Size=UDim2.fromOffset(160,24); presetLbl.Position=UDim2.fromOffset(btnAreaX, btnAreaY+184)
presetLbl.BackgroundTransparency=1; presetLbl.Text="PRESETS"
presetLbl.Font=Enum.Font.GothamBold; presetLbl.TextSize=12
presetLbl.TextColor3=Color3.fromRGB(80,80,120)

local circleBtn = mkBtn(drawerPanel,"◯ CIRCLE",   btnAreaX, btnAreaY+208, 160, 46, Color3.fromRGB(40,20,80), 13)
local xBtn      = mkBtn(drawerPanel,"✕ X SHAPE",  btnAreaX, btnAreaY+262, 160, 46, Color3.fromRGB(40,20,80), 13)
local lineBtn   = mkBtn(drawerPanel,"— LINE",      btnAreaX, btnAreaY+316, 160, 46, Color3.fromRGB(40,20,80), 13)
local arrowBtn  = mkBtn(drawerPanel,"▲ ARROW",     btnAreaX, btnAreaY+370, 160, 46, Color3.fromRGB(40,20,80), 13)

-- Clear canvas
local function clearCanvas()
    for r=1,CANVAS_GRID do for c=1,CANVAS_GRID do
        drawnCells[r][c]=false
        cellButtons[r][c].BackgroundColor3=COL_OFF
    end end
    updateCellCount()
end

-- Fill canvas
local function fillCanvas()
    for r=1,CANVAS_GRID do for c=1,CANVAS_GRID do
        drawnCells[r][c]=true
        cellButtons[r][c].BackgroundColor3=COL_ON
    end end
    updateCellCount()
end

-- Draw presets
local function drawPreset(preset)
    clearCanvas()
    local n = CANVAS_GRID
    if preset == "circle" then
        local cx, cy = (n+1)/2, (n+1)/2
        local radius  = (n/2)-0.5
        for r=1,n do for c=1,n do
            local d = math.sqrt((r-cy)^2+(c-cx)^2)
            if math.abs(d - radius) < 0.9 then
                drawnCells[r][c]=true; cellButtons[r][c].BackgroundColor3=COL_ON
            end
        end end
    elseif preset == "x" then
        for i=1,n do
            drawnCells[i][i]=true; cellButtons[i][i].BackgroundColor3=COL_ON
            drawnCells[i][n+1-i]=true; cellButtons[i][n+1-i].BackgroundColor3=COL_ON
        end
    elseif preset == "line" then
        local mid = math.ceil(n/2)
        for c=1,n do
            drawnCells[mid][c]=true; cellButtons[mid][c].BackgroundColor3=COL_ON
        end
    elseif preset == "arrow" then
        -- Horizontal arrow pointing right
        local mid = math.ceil(n/2)
        -- Shaft
        for c=1,n-2 do drawnCells[mid][c]=true; cellButtons[mid][c].BackgroundColor3=COL_ON end
        -- Arrowhead
        for i=0,3 do
            local r1,r2 = mid-i, mid+i
            local col   = n-1-i
            if r1>=1 then drawnCells[r1][col]=true; cellButtons[r1][col].BackgroundColor3=COL_ON end
            if r2<=n then drawnCells[r2][col]=true; cellButtons[r2][col].BackgroundColor3=COL_ON end
        end
    end
    updateCellCount()
end

clearBtn.MouseButton1Click:Connect(clearCanvas)
fillBtn.MouseButton1Click:Connect(fillCanvas)
circleBtn.MouseButton1Click:Connect(function() drawPreset("circle") end)
xBtn.MouseButton1Click:Connect(function()      drawPreset("x") end)
lineBtn.MouseButton1Click:Connect(function()   drawPreset("line") end)
arrowBtn.MouseButton1Click:Connect(function()  drawPreset("arrow") end)

applyBtn.MouseButton1Click:Connect(function()
    applyDrawing()
    local cells = countCells()
    local have  = #grabbedBlocks
    if cells == 0 then
        setStatus("Draw something first!")
    elseif have == 0 then
        setStatus("Grab blocks first! Need "..cells.." blocks")
    elseif have < cells then
        setStatus("Shape needs "..cells.." blocks, you have "..have.." — partial shape shown")
    else
        setStatus("Shape applied! "..cells.." blocks forming your drawing ✓")
    end
    drawerPanel.Visible=false
    drawerToggleBtn.BackgroundColor3=Color3.fromRGB(60,20,90)
end)

-- Open/close drawer
drawerToggleBtn.MouseButton1Click:Connect(function()
    drawerPanel.Visible = not drawerPanel.Visible
    updateCellCount()
    drawerToggleBtn.BackgroundColor3 = drawerPanel.Visible
        and Color3.fromRGB(11,95,226)
        or Color3.fromRGB(60,20,90)
end)

-- ============================================================
-- CONTROL PADS
-- ============================================================

-- LEFT PAD — AIM
local leftPad = Instance.new("Frame", gui)
leftPad.Size             = UDim2.fromOffset(220, 220)
leftPad.Position         = UDim2.new(0, 8, 1, -228)
leftPad.BackgroundColor3 = Color3.fromRGB(14,14,24)
leftPad.BorderSizePixel  = 0
Instance.new("UICorner",leftPad).CornerRadius=UDim.new(0,16)
Instance.new("UIStroke",leftPad).Color=Color3.fromRGB(11,95,226)

local lTitle=Instance.new("TextLabel",leftPad)
lTitle.Size=UDim2.new(1,0,0,20); lTitle.BackgroundTransparency=1
lTitle.Text="AIM"; lTitle.Font=Enum.Font.GothamBold; lTitle.TextSize=12
lTitle.TextColor3=Color3.fromRGB(11,95,226)

local cx,cy,bs=75,80,66
local dUp    = mkBtn(leftPad,"▲",cx,      cy-bs-2,bs,bs)
local dDown  = mkBtn(leftPad,"▼",cx,      cy+bs+2,bs,bs)
local dLeft  = mkBtn(leftPad,"◀",cx-bs-2, cy,     bs,bs)
local dRight = mkBtn(leftPad,"▶",cx+bs+2, cy,     bs,bs)
local dDot=Instance.new("Frame",leftPad)
dDot.Size=UDim2.fromOffset(18,18); dDot.Position=UDim2.fromOffset(cx+24,cy+24)
dDot.BackgroundColor3=Color3.fromRGB(11,95,226); dDot.BorderSizePixel=0
Instance.new("UICorner",dDot).CornerRadius=UDim.new(1,0)

holdBtn(dUp,"up"); holdBtn(dDown,"down"); holdBtn(dLeft,"left"); holdBtn(dRight,"right")
dUp.MouseButton1Click:Connect(function()    aimV=math.clamp(aimV-15,-80,80) end)
dDown.MouseButton1Click:Connect(function()  aimV=math.clamp(aimV+15,-80,80) end)
dLeft.MouseButton1Click:Connect(function()  aimH=aimH-15 end)
dRight.MouseButton1Click:Connect(function() aimH=aimH+15 end)

-- RIGHT PAD — ACTIONS
local rightPad=Instance.new("Frame",gui)
rightPad.Size=UDim2.fromOffset(220,220); rightPad.Position=UDim2.new(1,-228,1,-228)
rightPad.BackgroundColor3=Color3.fromRGB(14,14,24); rightPad.BorderSizePixel=0
Instance.new("UICorner",rightPad).CornerRadius=UDim.new(0,16)
Instance.new("UIStroke",rightPad).Color=Color3.fromRGB(11,95,226)

local rTitle=Instance.new("TextLabel",rightPad)
rTitle.Size=UDim2.new(1,0,0,20); rTitle.BackgroundTransparency=1
rTitle.Text="ACTIONS"; rTitle.Font=Enum.Font.GothamBold; rTitle.TextSize=12
rTitle.TextColor3=Color3.fromRGB(11,95,226)

-- SELECT MODE toggle
local selectBtn  = mkBtn(rightPad,"👆 SELECT",     4, 24, 104, 70, Color3.fromRGB(20,70,120), 14)
local releaseBtn = mkBtn(rightPad,"✋ RELEASE",   112, 24, 104, 70, Color3.fromRGB(90,20,20), 14)
local hiUpBtn    = mkBtn(rightPad,"↑ HIGH",        4,102, 104, 44)
local hiDnBtn    = mkBtn(rightPad,"↓ LOW",        112,102, 104, 44)
local blockCountLbl=Instance.new("TextLabel",rightPad)
blockCountLbl.Size=UDim2.fromOffset(210,22); blockCountLbl.Position=UDim2.fromOffset(4,152)
blockCountLbl.BackgroundTransparency=1; blockCountLbl.Text="0 blocks grabbed"
blockCountLbl.Font=Enum.Font.GothamBold; blockCountLbl.TextSize=12
blockCountLbl.TextColor3=Color3.fromRGB(116,113,117)

local function updateBlockCount()
    blockCountLbl.Text = #grabbedBlocks.." block(s) grabbed"
    updateCellCount()
end

holdBtn(hiUpBtn,"hiUp"); holdBtn(hiDnBtn,"hiDown")
hiUpBtn.MouseButton1Click:Connect(function() heightOffset=heightOffset+2 end)
hiDnBtn.MouseButton1Click:Connect(function() heightOffset=heightOffset-2 end)

-- Select mode toggle
selectBtn.MouseButton1Click:Connect(function()
    selectMode = not selectMode
    if selectMode then
        selectBtn.BackgroundColor3 = Color3.fromRGB(11,95,226)
        setStatus("SELECT ON — tap blocks in the world to grab them")
    else
        selectBtn.BackgroundColor3 = Color3.fromRGB(20,70,120)
        setStatus("SELECT OFF — "..#grabbedBlocks.." block(s) grabbed")
    end
end)

releaseBtn.MouseButton1Click:Connect(function()
    releaseAll()
    useDrawing=false
    selectBtn.BackgroundColor3=Color3.fromRGB(20,70,120)
    selectMode=false
    updateBlockCount()
    setStatus("Released all blocks")
end)

-- Highlight select btn visually
RunService.Heartbeat:Connect(function()
    updateBlockCount()
end)

-- ============================================================
-- PUNCH BUTTON (center bottom)
-- ============================================================
local punchBtn=Instance.new("TextButton",gui)
punchBtn.Size=UDim2.new(0.44,0,0,84); punchBtn.Position=UDim2.new(0.28,0,1,-94)
punchBtn.Text="👊  PUNCH"; punchBtn.Font=Enum.Font.GothamBold; punchBtn.TextSize=26
punchBtn.TextColor3=Color3.new(1,1,1); punchBtn.BackgroundColor3=Color3.fromRGB(180,30,30)
punchBtn.BorderSizePixel=0; punchBtn.AutoButtonColor=false
Instance.new("UICorner",punchBtn).CornerRadius=UDim.new(0,18)
Instance.new("UIStroke",punchBtn).Color=Color3.fromRGB(255,80,80)
punchBtn.MouseButton1Down:Connect(function()
    TweenService:Create(punchBtn,TweenInfo.new(0.06),{BackgroundColor3=Color3.fromRGB(255,50,50)}):Play()
end)
punchBtn.MouseButton1Up:Connect(function()
    TweenService:Create(punchBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(180,30,30)}):Play()
end)
punchBtn.MouseButton1Click:Connect(function() task.spawn(doPunch) end)

-- ============================================================
-- KEYBOARD
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local k=input.KeyCode
    if     k==Enum.KeyCode.T     then selectBtn:MouseButton1Click()
    elseif k==Enum.KeyCode.R     then releaseBtn:MouseButton1Click()
    elseif k==Enum.KeyCode.F     then task.spawn(doPunch)
    elseif k==Enum.KeyCode.D     then drawerPanel.Visible=not drawerPanel.Visible; updateCellCount()
    elseif k==Enum.KeyCode.Left  then aimH=aimH-15
    elseif k==Enum.KeyCode.Right then aimH=aimH+15
    elseif k==Enum.KeyCode.Up    then aimV=math.clamp(aimV-15,-80,80)
    elseif k==Enum.KeyCode.Down  then aimV=math.clamp(aimV+15,-80,80)
    elseif k==Enum.KeyCode.Q     then heightOffset=heightOffset+2
    elseif k==Enum.KeyCode.E     then heightOffset=heightOffset-2
    end
end)

-- ============================================================
-- RESPAWN
-- ============================================================
player.CharacterAdded:Connect(function()
    releaseAll()
    selectMode=false
    setStatus("Respawned — tap SELECT then tap blocks in the world")
end)

print("[BLOCK FIST v4] Loaded!")
print("  T=SelectMode  R=Release  F=Punch  D=Drawer")
print("  Arrows=Aim  Q/E=Height")
print("  In select mode: CLICK a block in the world to grab it")
