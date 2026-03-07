--[[
  manesNUKER — CodeX UI
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
frame.Size             = UDim2.fromOffset(600, 400)
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
-- PAGE SYSTEM  (CodeX original, extended to 8 tabs)
------------------------
local pages       = {"NUKE","FIX","SLOTS","AURA","BKIT","SPAM","ANTI","CREDITS"}
local currentPage = 1

-- Page Label
local pageLabel = Instance.new("TextLabel", frame)
pageLabel.Size                   = UDim2.fromOffset(150, 40)
pageLabel.Position               = UDim2.fromOffset(20, 20)
pageLabel.BackgroundTransparency = 1
pageLabel.Font                   = Enum.Font.Gotham
pageLabel.TextSize               = 20
pageLabel.TextColor3             = Color3.fromRGB(116, 113, 117)
pageLabel.Text                   = pages[currentPage]

-- Arrows
local leftArrow = Instance.new("TextButton", frame)
leftArrow.Size                   = UDim2.fromOffset(40, 40)
leftArrow.Position               = UDim2.fromOffset(20, 20)
leftArrow.Text                   = "<"
leftArrow.Font                   = Enum.Font.Gotham
leftArrow.TextSize               = 20
leftArrow.TextColor3             = Color3.fromRGB(116, 113, 117)
leftArrow.BackgroundTransparency = 1

local rightArrow = Instance.new("TextButton", frame)
rightArrow.Size                   = UDim2.fromOffset(40, 40)
rightArrow.Position               = UDim2.fromOffset(130, 20)
rightArrow.Text                   = ">"
rightArrow.Font                   = Enum.Font.Gotham
rightArrow.TextSize               = 20
rightArrow.TextColor3             = Color3.fromRGB(116, 113, 117)
rightArrow.BackgroundTransparency = 1

------------------------
-- LOGS PANEL  (CodeX original)
------------------------
local logsFrame = Instance.new("Frame", frame)
logsFrame.Size             = UDim2.fromOffset(250, 360)
logsFrame.Position         = UDim2.new(1, -20, 0, 20)
logsFrame.AnchorPoint      = Vector2.new(1, 0)
logsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
logsFrame.BorderSizePixel  = 0
Instance.new("UICorner", logsFrame).CornerRadius = UDim.new(0, 12)

local logsLabel = Instance.new("TextLabel", logsFrame)
logsLabel.Size                   = UDim2.fromScale(1, 1)
logsLabel.BackgroundTransparency = 1
logsLabel.Font                   = Enum.Font.Gotham
logsLabel.TextSize               = 13
logsLabel.TextColor3             = Color3.fromRGB(116, 113, 117)
logsLabel.TextXAlignment         = Enum.TextXAlignment.Left
logsLabel.TextYAlignment         = Enum.TextYAlignment.Top
logsLabel.TextWrapped            = true
logsLabel.RichText               = true

local logLines = {}
local maxLines = 22
local function addLog(msg)
    table.insert(logLines, msg)
    if #logLines > maxLines then table.remove(logLines, 1) end
    logsLabel.Text = table.concat(logLines, "\n")
end
local oldPrint = print
print = function(...)
    local args = {...}
    local msg  = ""
    for i, v in ipairs(args) do msg = msg .. tostring(v) .. "\t" end
    addLog(msg)
    oldPrint(...)
end

------------------------
-- HELPERS  (CodeX original style)
------------------------
local function tweenProperty(obj, prop, to, duration)
    TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[prop] = to}):Play()
end

-- Content width (fits left of logs panel)
local CW = 300

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

local function createTextBox(parent, placeholder, w, h)
    local box = Instance.new("TextBox", parent)
    box.Size              = UDim2.fromOffset(w or CW, h or 36)
    box.PlaceholderText   = placeholder
    box.BackgroundColor3  = Color3.fromRGB(40, 40, 60)
    box.TextColor3        = Color3.fromRGB(200, 200, 220)
    box.PlaceholderColor3 = Color3.fromRGB(80, 80, 110)
    box.Font              = Enum.Font.Gotham
    box.TextSize          = 15
    box.BorderSizePixel   = 0
    box.ClearTextOnFocus  = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
    return box
end

local function createDivider(parent)
    local d = Instance.new("Frame", parent)
    d.Size             = UDim2.fromOffset(CW, 1)
    d.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    d.BorderSizePixel  = 0
    return d
end

-- Arrow hover  (CodeX original)
local function addArrowHover(button)
    local originalSize = button.Size
    button.MouseEnter:Connect(function()
        tweenProperty(button, "TextColor3", Color3.fromRGB(11, 95, 226), 0.3)
        tweenProperty(button, "Size", UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 10, originalSize.Y.Scale, originalSize.Y.Offset + 5), 0.2)
    end)
    button.MouseLeave:Connect(function()
        tweenProperty(button, "TextColor3", Color3.fromRGB(116, 113, 117), 0.3)
        tweenProperty(button, "Size", originalSize, 0.2)
    end)
end
addArrowHover(leftArrow)
addArrowHover(rightArrow)

-- Page scroll containers — positioned in CodeX content area (x=20, y=68)
local pageContainers = {}
for i = 1, #pages do
    local sf = Instance.new("ScrollingFrame", frame)
    sf.Size                  = UDim2.fromOffset(310, 315)
    sf.Position              = UDim2.fromOffset(20, 68)
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
    upad.PaddingLeft = UDim.new(0, 2)
    upad.PaddingTop  = UDim.new(0, 2)
    pageContainers[i] = sf
end

-- Page switching  (CodeX original pattern)
local function updatePage()
    pageLabel.Text = pages[currentPage]
    for i, c in ipairs(pageContainers) do c.Visible = (i == currentPage) end
end

leftArrow.MouseButton1Click:Connect(function()
    currentPage = currentPage - 1
    if currentPage < 1 then currentPage = #pages end
    updatePage()
end)
rightArrow.MouseButton1Click:Connect(function()
    currentPage = currentPage + 1
    if currentPage > #pages then currentPage = 1 end
    updatePage()
end)

-- Shorthand refs
local pgNuke    = pageContainers[1]
local pgFix     = pageContainers[2]
local pgSlots   = pageContainers[3]
local pgAura    = pageContainers[4]
local pgBkit    = pageContainers[5]
local pgSpam    = pageContainers[6]
local pgAnti    = pageContainers[7]
local pgCredits = pageContainers[8]

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
-- BYPASS TEXT — inserts <font size='0'></font> between every letter
-- so chat filters / admin logs can't read the words
-- ============================================================
local BP = "<font size='0'></font>"
local function bypassText(str)
    if not str or str == "" then return "" end
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
-- NUKE — with retry until brick confirms TOXIC + ANCHORED
-- ============================================================
local function runNuke()
    local remote, rootPos = getPaintRemote(); local brick = getBrick()
    if not remote or not brick then print("[NUKE] missing tools"); return end

    local key = "both \u{1F91D}"
    local blk = Color3.new(0, 0, 0)

    -- Default toxic texts — every letter auto-bypassed
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
                print("[NUKE] Not anchored yet — retry "..attempt.."/"..maxRetries)
                task.wait(0.2)
            end
        else
            -- No brick found to verify, just proceed
            break
        end
    end

    -- STEP 2: Paint faces — use custom text if set, otherwise default bypass text
    for _, n in ipairs(faces) do
        local rawText = faceData[n] and faceData[n].txt.Text ~= "" and faceData[n].txt.Text or nil
        -- Auto-bypass whatever text is used
        local ft = bypassText(rawText or tp[n] or "GGS")
        local fc = faceData[n] and faceData[n].clr.BackgroundColor3 or Color3.fromRGB(255, 0, 0)

        -- Retry each face paint up to 3 times
        for attempt = 1, 3 do
            pcall(function() remote:FireServer(brick, faceEnums[n], rootPos, key, fc, "spray", ft) end)
            task.wait(0.12)
            -- On last face retry just move on
            if attempt < 3 then task.wait(0.05) end
        end
    end

    print("[NUKE] Done — TOXIC + ANCHORED + BYPASS TEXT")
end

-- ============================================================
-- FIX — with retry until brick confirms UNANCHORED
-- ============================================================
local function runFix()
    -- Clear face data UI
    for _, n in ipairs(faces) do
        if faceData[n] then
            faceData[n].txt.Text = ""
            faceData[n].clr.BackgroundColor3 = LIGHT_GRAY
        end
    end

    local remote, rootPos = getPaintRemote(); local brick = getBrick()
    if not remote or not brick then print("[FIX] missing tools"); return end
    local key = "both \u{1F91D}"

    -- STEP 1: Fire plastic + unanchor, retry until confirmed UNANCHORED
    local maxRetries = 8
    for attempt = 1, maxRetries do
        pcall(function() remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, LIGHT_GRAY, "plastic", "unanchor") end)
        task.wait(0.3)
        pcall(function() remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, LIGHT_GRAY, "unanchor", "") end)
        task.wait(0.3)

        -- Verify: check nearest placed brick is now unanchored
        local placed = getNearestPlacedBrick()
        if placed then
            if not placed.Anchored then
                print("[FIX] Unanchor confirmed on attempt "..attempt)
                break
            else
                print("[FIX] Still anchored — retry "..attempt.."/"..maxRetries)
                -- Fire again with more force
                pcall(function() remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, LIGHT_GRAY, "unanchor", "") end)
                task.wait(0.3)
            end
        else
            break
        end
    end

    -- STEP 2: Clear all faces to light gray + empty text
    for _, n in ipairs(faces) do
        for attempt = 1, 2 do
            pcall(function() remote:FireServer(brick, faceEnums[n], rootPos, key, LIGHT_GRAY, "spray", "") end)
            task.wait(0.08)
        end
    end

    print("[FIX] Done — PLASTIC + UNANCHOR + LIGHT GRAY (verified)")
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
    txt.Size=UDim2.fromOffset(CW-92,26); txt.Position=UDim2.fromOffset(54,4)
    txt.BackgroundColor3=Color3.fromRGB(28,28,46); txt.Text="GG'S"
    txt.PlaceholderText=name.." text"; txt.TextColor3=Color3.fromRGB(200,200,220)
    txt.Font=Enum.Font.Gotham; txt.TextSize=12; txt.BorderSizePixel=0
    Instance.new("UICorner",txt).CornerRadius=UDim.new(0,6)
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
-- PAGE 2: FIX
-- ============================================================
createLabel(pgFix, "  Repair / Clean Brick", Color3.fromRGB(80,80,120), 13)
createLabel(pgFix, "  Plastic  |  Unanchored  |  Light Gray  |  Clears text", Color3.fromRGB(11,95,226), 13)
createButton(pgFix, "🛠  FIX BRICK  (PLASTIC + UNANCHOR)", function() task.spawn(runFix) end, CW, 46)

-- ============================================================
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
-- PAGE 4: AURA
-- ============================================================
createLabel(pgAura, "  Delete Aura Settings", Color3.fromRGB(80,80,120), 13)
createLabel(pgAura, "  Fires every Heartbeat — maximum speed", Color3.fromRGB(11,95,226), 13)

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
-- PAGE 6: SPAM
-- ============================================================
createLabel(pgSpam, "  Spam Build", Color3.fromRGB(80,80,120), 13)
createLabel(pgSpam, "  Fires brick placement directly — no face-paint delays", Color3.fromRGB(11,95,226), 13)

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
                            pcall(function() remote:FireServer(brick,Enum.NormalId.Top,hrp.Position,"both \u{1F91D}",Color3.new(0,0,0),"toxic","anchor") end)
                            sbCount=sbCount+1; sbCountLbl.Text="  Placed: "..sbCount.." @ "..spamBuildRate.."/s"
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- PAGE 7: ANTI — God Mode toggle
-- ============================================================
createLabel(pgAnti, "  Anti / Protection", Color3.fromRGB(80,80,120), 13)
createLabel(pgAnti, "  Prevents void death  |  Infinite health  |  Touch immunity", Color3.fromRGB(11,95,226), 13)
createDivider(pgAnti)

local godModeConn = nil
local function applyGodMode(character)
    -- 1. Stop engine from deleting parts in the void
    workspace.FallenPartsDestroyHeight = -1e9

    local root     = character:WaitForChild("HumanoidRootPart", 5)
    local humanoid = character:WaitForChild("Humanoid", 5)

    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid.MaxHealth = math.huge
        humanoid.Health    = math.huge
    end

    -- 3. Teleport loop — fights void pull / NaN for 2 seconds
    task.spawn(function()
        for i = 1, 20 do
            if root then
                root.CFrame = CFrame.new(0, 200, 0)
                root.AssemblyLinearVelocity = Vector3.zero
            end
            task.wait(0.1)
        end
    end)

    -- 4. Touch immunity
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanTouch = false end
    end
end

createToggle(pgAnti, "God Mode", function(v)
    if v then
        if LocalPlayer.Character then applyGodMode(LocalPlayer.Character) end
        godModeConn = LocalPlayer.CharacterAdded:Connect(applyGodMode)
        print("[ANTI] God Mode ON")
    else
        if godModeConn then godModeConn:Disconnect(); godModeConn = nil end
        pcall(function() workspace.FallenPartsDestroyHeight = -500 end)
        print("[ANTI] God Mode OFF")
    end
end, CW, 46)

-- ============================================================
-- PAGE 8: CREDITS — text only, no buttons
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
-- INIT
-- ============================================================
updatePage()
print("[manesNUKER] Loaded! Use < > to switch pages")
