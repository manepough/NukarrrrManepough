local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local brick = ReplicatedStorage:WaitForChild("Brick")

local isNuking = false
local key = "both \u{1F91D}"
local PURE_BLACK = Color3.fromRGB(0, 0, 0)

------------------------------------------------------------------------
-- Whitelist
------------------------------------------------------------------------
local Whitelist = {
    "YourNameHere",
    "AnotherName",
}

local isWhitelisted = false
for _, name in ipairs(Whitelist) do
    if name == LocalPlayer.Name then
        isWhitelisted = true
        break
    end
end

------------------------------------------------------------------------
-- Side Enums (index matches row number)
------------------------------------------------------------------------
local SideEnums = {
    [1] = Enum.NormalId.Top,
    [2] = Enum.NormalId.Bottom,
    [3] = Enum.NormalId.Front,
    [4] = Enum.NormalId.Back,
    [5] = Enum.NormalId.Right,
    [6] = Enum.NormalId.Left,
}

------------------------------------------------------------------------
-- Default texts per side
------------------------------------------------------------------------
local DefaultSideTexts = {
    [1] = "ht<font size='0'></font>t<font size='0'></font>ps:/<font size='0'></font>/d<font size='0'></font>is<font size='0'></font>co<font size='0'></font>rd.<font size='0'></font>gg/Ud<font size='0'></font>pd9dKZVV",
    [2] = "Synapse On Top\u{1F525}\u{1F525}\u{1F525}",
    [3] = "",
    [4] = "",
    [5] = "",
    [6] = "",
}

------------------------------------------------------------------------
-- Color Options
------------------------------------------------------------------------
local ColorOptions = {
    {Name = "Blue",       Value = Color3.fromRGB(30,  144, 255)},
    {Name = "Yellow",     Value = Color3.fromRGB(255, 215, 0)},
    {Name = "Pink",       Value = Color3.fromRGB(255, 105, 180)},
    {Name = "Purple",     Value = Color3.fromRGB(138, 43,  226)},
    {Name = "Red",        Value = Color3.fromRGB(220, 20,  20)},
    {Name = "Green",      Value = Color3.fromRGB(0,   200, 60)},
    {Name = "Black",      Value = Color3.fromRGB(10,  10,  10)},
    {Name = "White",      Value = Color3.fromRGB(255, 255, 255)},
    {Name = "Cyan",       Value = Color3.fromRGB(0,   220, 220)},
    {Name = "Dark Green", Value = Color3.fromRGB(0,   90,  30)},
    {Name = "Orange",     Value = Color3.fromRGB(255, 130, 0)},
    {Name = "Lime",       Value = Color3.fromRGB(160, 255, 0)},
    {Name = "Magenta",    Value = Color3.fromRGB(255, 0,   200)},
    {Name = "Teal",       Value = Color3.fromRGB(0,   150, 150)},
    {Name = "Brown",      Value = Color3.fromRGB(140, 80,  30)},
    {Name = "Navy",       Value = Color3.fromRGB(0,   0,   100)},
}

------------------------------------------------------------------------
-- Per-row state
------------------------------------------------------------------------
local rowData = {}
for i = 1, 6 do
    rowData[i] = {
        text      = DefaultSideTexts[i],
        color     = ColorOptions[1].Value,
        colorName = ColorOptions[1].Name,
    }
end

------------------------------------------------------------------------
-- ScreenGui
------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SynapseGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

------------------------------------------------------------------------
-- Circle Toggle
------------------------------------------------------------------------
local CircleButton = Instance.new("TextButton")
CircleButton.Name = "CircleToggle"
CircleButton.Size = UDim2.new(0, 52, 0, 52)
CircleButton.Position = UDim2.new(0, 18, 0.5, -26)
CircleButton.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
CircleButton.BorderSizePixel = 0
CircleButton.Text = "S"
CircleButton.TextColor3 = Color3.fromRGB(90, 130, 255)
CircleButton.TextSize = 18
CircleButton.Font = Enum.Font.GothamBold
CircleButton.Parent = ScreenGui
Instance.new("UICorner", CircleButton).CornerRadius = UDim.new(1, 0)
local circleStroke = Instance.new("UIStroke", CircleButton)
circleStroke.Color = Color3.fromRGB(70, 110, 240)
circleStroke.Thickness = 2

------------------------------------------------------------------------
-- Main Frame
------------------------------------------------------------------------
local FRAME_W = 400

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, FRAME_W, 0, 100)
MainFrame.Position = UDim2.new(0.5, -FRAME_W / 2, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(11, 11, 19)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Color3.fromRGB(55, 95, 215)
mainStroke.Thickness = 1.5

------------------------------------------------------------------------
-- Title Bar
------------------------------------------------------------------------
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 46)
TitleBar.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local titleFix = Instance.new("Frame", TitleBar)
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
titleFix.BorderSizePixel = 0
titleFix.ZIndex = 2

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Synapse v4"
TitleLabel.TextColor3 = Color3.fromRGB(200, 210, 255)
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 3

local CloseButton = Instance.new("TextButton", TitleBar)
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -38, 0, 9)
CloseButton.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 12
CloseButton.Font = Enum.Font.GothamBold
CloseButton.ZIndex = 4
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

------------------------------------------------------------------------
-- Status Label
------------------------------------------------------------------------
local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, -28, 0, 18)
StatusLabel.Position = UDim2.new(0, 14, 0, 50)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = isWhitelisted
    and "Access: Full  (All 6 sides unlocked)"
    or  "Access: Limited  (Sides 3-6 only)"
StatusLabel.TextColor3 = isWhitelisted
    and Color3.fromRGB(80, 240, 120)
    or  Color3.fromRGB(255, 175, 60)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

------------------------------------------------------------------------
-- Divider helper
------------------------------------------------------------------------
local function makeDivider(y)
    local d = Instance.new("Frame", MainFrame)
    d.Size = UDim2.new(1, -28, 0, 1)
    d.Position = UDim2.new(0, 14, 0, y)
    d.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    d.BorderSizePixel = 0
end

makeDivider(72)

------------------------------------------------------------------------
-- Picker Popup (shared, one at a time)
------------------------------------------------------------------------
local activePickerRow = nil

local PickerPopup = Instance.new("Frame", ScreenGui)
PickerPopup.Name = "PickerPopup"
PickerPopup.Size = UDim2.new(0, 220, 0, 200)
PickerPopup.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
PickerPopup.BorderSizePixel = 0
PickerPopup.Visible = false
PickerPopup.ZIndex = 20
Instance.new("UICorner", PickerPopup).CornerRadius = UDim.new(0, 10)
local popupStroke = Instance.new("UIStroke", PickerPopup)
popupStroke.Color = Color3.fromRGB(55, 95, 215)
popupStroke.Thickness = 1.5

local PopupScroll = Instance.new("ScrollingFrame", PickerPopup)
PopupScroll.Size = UDim2.new(1, -10, 1, -10)
PopupScroll.Position = UDim2.new(0, 5, 0, 5)
PopupScroll.BackgroundTransparency = 1
PopupScroll.BorderSizePixel = 0
PopupScroll.ScrollBarThickness = 3
PopupScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 100, 210)
PopupScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PopupScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
PopupScroll.ZIndex = 20

local popupGrid = Instance.new("UIGridLayout", PopupScroll)
popupGrid.CellSize = UDim2.new(0, 90, 0, 26)
popupGrid.CellPadding = UDim2.new(0, 5, 0, 5)
popupGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center

local popupPad = Instance.new("UIPadding", PopupScroll)
popupPad.PaddingTop = UDim.new(0, 5)
popupPad.PaddingBottom = UDim.new(0, 5)

local function closePopup()
    PickerPopup.Visible = false
    activePickerRow = nil
end

------------------------------------------------------------------------
-- Build rows
------------------------------------------------------------------------
local ROW_START_Y = 82
local ROW_H       = 44
local ROW_GAP     = 6
local PAD         = 14
local NUM_W       = 26
local SWATCH_W    = 28
local SPACING     = 6
local BOX_W       = FRAME_W - PAD * 2 - NUM_W - SWATCH_W - SPACING * 2

local colorSwatches = {}

local headerLabel = Instance.new("TextLabel", MainFrame)
headerLabel.Size = UDim2.new(1, -28, 0, 16)
headerLabel.Position = UDim2.new(0, PAD, 0, ROW_START_Y)
headerLabel.BackgroundTransparency = 1
headerLabel.Text = "Side Texts"
headerLabel.TextColor3 = Color3.fromRGB(120, 130, 180)
headerLabel.TextSize = 11
headerLabel.Font = Enum.Font.GothamSemibold
headerLabel.TextXAlignment = Enum.TextXAlignment.Left

for i = 1, 6 do
    local locked = (i == 1 or i == 2) and not isWhitelisted
    local rowY = ROW_START_Y + 20 + (i - 1) * (ROW_H + ROW_GAP)

    local numLabel = Instance.new("TextLabel", MainFrame)
    numLabel.Size = UDim2.new(0, NUM_W, 0, ROW_H)
    numLabel.Position = UDim2.new(0, PAD, 0, rowY)
    numLabel.BackgroundTransparency = 1
    numLabel.Text = tostring(i) .. "."
    numLabel.TextColor3 = locked
        and Color3.fromRGB(70, 70, 100)
        or  Color3.fromRGB(160, 170, 220)
    numLabel.TextSize = 14
    numLabel.Font = Enum.Font.GothamBold
    numLabel.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", MainFrame)
    box.Size = UDim2.new(0, BOX_W, 0, ROW_H)
    box.Position = UDim2.new(0, PAD + NUM_W + SPACING, 0, rowY)
    box.BackgroundColor3 = locked
        and Color3.fromRGB(15, 15, 24)
        or  Color3.fromRGB(20, 20, 34)
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.TextEditable = not locked
    box.Text = locked and "" or rowData[i].text
    box.PlaceholderText = locked
        and "LOCKED - Need Whitelist"
        or  "Enter text for side " .. i
    box.TextColor3 = locked
        and Color3.fromRGB(60, 60, 90)
        or  Color3.fromRGB(210, 220, 255)
    box.PlaceholderColor3 = locked
        and Color3.fromRGB(100, 60, 60)
        or  Color3.fromRGB(75, 85, 130)
    box.TextSize = 12
    box.Font = Enum.Font.Gotham
    box.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    local boxPad = Instance.new("UIPadding", box)
    boxPad.PaddingLeft = UDim.new(0, 8)
    boxPad.PaddingRight = UDim.new(0, 6)

    local boxStroke = Instance.new("UIStroke", box)
    boxStroke.Color = locked
        and Color3.fromRGB(35, 25, 45)
        or  Color3.fromRGB(45, 55, 130)
    boxStroke.Thickness = 1.2

    if not locked then
        box.FocusLost:Connect(function()
            rowData[i].text = box.Text
        end)
    end

    local swatch = Instance.new("TextButton", MainFrame)
    swatch.Name = "Swatch" .. i
    swatch.Size = UDim2.new(0, SWATCH_W, 0, SWATCH_W)
    swatch.Position = UDim2.new(
        0,
        PAD + NUM_W + SPACING + BOX_W + SPACING,
        0,
        rowY + (ROW_H - SWATCH_W) / 2
    )
    swatch.BackgroundColor3 = rowData[i].color
    swatch.BorderSizePixel = 0
    swatch.Text = ""
    swatch.ZIndex = 5
    Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 6)
    local swatchStroke = Instance.new("UIStroke", swatch)
    swatchStroke.Color = Color3.fromRGB(80, 80, 120)
    swatchStroke.Thickness = 1.5

    colorSwatches[i] = swatch

    local rowIndex = i
    swatch.MouseButton1Click:Connect(function()
        if activePickerRow == rowIndex then
            closePopup()
            return
        end
        activePickerRow = rowIndex

        local sp = swatch.AbsolutePosition
        local ss = swatch.AbsoluteSize
        local popW, popH = 220, 200
        local px = sp.X + ss.X + 6
        local py = sp.Y
        local vp = ScreenGui.AbsoluteSize
        if px + popW > vp.X then px = sp.X - popW - 6 end
        if py + popH > vp.Y then py = vp.Y - popH - 6 end

        PickerPopup.Position = UDim2.new(0, px, 0, py)
        PickerPopup.Visible = true
    end)
end

------------------------------------------------------------------------
-- Populate picker color buttons
------------------------------------------------------------------------
for _, opt in ipairs(ColorOptions) do
    local cb = Instance.new("TextButton", PopupScroll)
    cb.BackgroundColor3 = opt.Value
    cb.BorderSizePixel = 0
    cb.Text = opt.Name
    local darkText = opt.Name == "Black" or opt.Name == "Navy"
        or opt.Name == "Dark Green" or opt.Name == "Purple" or opt.Name == "Brown"
    cb.TextColor3 = darkText and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(0, 0, 0)
    cb.TextSize = 10
    cb.Font = Enum.Font.GothamBold
    cb.ZIndex = 21
    Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 6)
    local cbStroke = Instance.new("UIStroke", cb)
    cbStroke.Thickness = 1
    cbStroke.Color = Color3.fromRGB(50, 50, 70)
    cbStroke.ZIndex = 21

    local capturedOpt = opt
    cb.MouseButton1Click:Connect(function()
        if not activePickerRow then return end
        local idx = activePickerRow
        rowData[idx].color = capturedOpt.Value
        rowData[idx].colorName = capturedOpt.Name
        colorSwatches[idx].BackgroundColor3 = capturedOpt.Value
        closePopup()
    end)
end

------------------------------------------------------------------------
-- Close popup on outside click
------------------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gpe)
    if not PickerPopup.Visible then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
    and input.UserInputType ~= Enum.UserInputType.Touch then return end

    local pos = input.Position
    local pp = PickerPopup.AbsolutePosition
    local ps = PickerPopup.AbsoluteSize

    local hitPopup = pos.X >= pp.X and pos.X <= pp.X + ps.X
        and pos.Y >= pp.Y and pos.Y <= pp.Y + ps.Y

    local hitSwatch = false
    for _, sw in ipairs(colorSwatches) do
        local sp = sw.AbsolutePosition
        local ss = sw.AbsoluteSize
        if pos.X >= sp.X and pos.X <= sp.X + ss.X
        and pos.Y >= sp.Y and pos.Y <= sp.Y + ss.Y then
            hitSwatch = true
            break
        end
    end

    if not hitPopup and not hitSwatch then
        closePopup()
    end
end)

------------------------------------------------------------------------
-- Execute Button
------------------------------------------------------------------------
local ROWS_BOTTOM = ROW_START_Y + 20 + 6 * (ROW_H + ROW_GAP) + 4
makeDivider(ROWS_BOTTOM)

local ExecuteButton = Instance.new("TextButton", MainFrame)
ExecuteButton.Size = UDim2.new(1, -28, 0, 44)
ExecuteButton.Position = UDim2.new(0, 14, 0, ROWS_BOTTOM + 10)
ExecuteButton.BackgroundColor3 = Color3.fromRGB(48, 88, 210)
ExecuteButton.BorderSizePixel = 0
ExecuteButton.Text = "Execute"
ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteButton.TextSize = 16
ExecuteButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", ExecuteButton).CornerRadius = UDim.new(0, 10)
local execStroke = Instance.new("UIStroke", ExecuteButton)
execStroke.Color = Color3.fromRGB(100, 140, 255)
execStroke.Thickness = 1.5

local FINAL_H = ROWS_BOTTOM + 10 + 44 + 14
MainFrame.Size = UDim2.new(0, FRAME_W, 0, FINAL_H)
MainFrame.Position = UDim2.new(0.5, -FRAME_W / 2, 0.5, -FINAL_H / 2)

ExecuteButton.MouseEnter:Connect(function()
    TweenService:Create(ExecuteButton, TweenInfo.new(0.14), {BackgroundColor3 = Color3.fromRGB(68, 108, 240)}):Play()
end)
ExecuteButton.MouseLeave:Connect(function()
    TweenService:Create(ExecuteButton, TweenInfo.new(0.14), {BackgroundColor3 = Color3.fromRGB(48, 88, 210)}):Play()
end)
CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.14), {BackgroundColor3 = Color3.fromRGB(230, 55, 55)}):Play()
end)
CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.14), {BackgroundColor3 = Color3.fromRGB(190, 45, 45)}):Play()
end)

------------------------------------------------------------------------
-- Dragging
------------------------------------------------------------------------
local dragging = false
local dragStart = nil
local frameStart = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        frameStart = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
    and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - dragStart
    TweenService:Create(MainFrame, TweenInfo.new(0.06, Enum.EasingStyle.Linear), {
        Position = UDim2.new(
            frameStart.X.Scale, frameStart.X.Offset + delta.X,
            frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
        )
    }):Play()
end)

------------------------------------------------------------------------
-- Open / Close
------------------------------------------------------------------------
local function openGUI()
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, FRAME_W, 0, FINAL_H),
        Position = UDim2.new(0.5, -FRAME_W / 2, 0.5, -FINAL_H / 2),
    }):Play()
end

local function closeGUI()
    closePopup()
    local t = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
    })
    t:Play()
    t.Completed:Connect(function() MainFrame.Visible = false end)
end

CircleButton.MouseButton1Click:Connect(function()
    if MainFrame.Visible then closeGUI() else openGUI() end
end)
CloseButton.MouseButton1Click:Connect(closeGUI)

------------------------------------------------------------------------
-- Nuke Logic (restored original proven fire pattern)
------------------------------------------------------------------------
local function applyNuke()
    local Character = LocalPlayer.Character
    if not Character or isNuking then return end

    local tool = Character:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
    if not tool then
        StarterGui:SetCore("SendNotification", {
            Title = "Synapse v4",
            Text = "Paint tool not found.",
            Duration = 3,
        })
        return
    end

    isNuking = true

    if tool.Parent ~= Character then
        Character:WaitForChild("Humanoid"):EquipTool(tool)
        task.wait(0.5)
    end

    local remote = tool:FindFirstChild("Event", true)
        or tool:FindFirstChildWhichIsA("RemoteEvent", true)
    if not remote then
        isNuking = false
        return
    end

    if not Character.PrimaryPart then
        isNuking = false
        return
    end

    local rootPos = Character.PrimaryPart.Position

    -- Step 1: anchor and clean (original working pattern)
    remote:FireServer(brick, Enum.NormalId.Top, rootPos, "material", PURE_BLACK, "anchor", "")
    task.wait(0.1)
    remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, PURE_BLACK, "toxic", "")
    task.wait(0.6)

    -- Step 2: paint each side with its own color and text
    for i = 1, 6 do
        local data = rowData[i]
        local sideEnum = SideEnums[i]
        local textToSend = (data.text ~= nil and data.text ~= "")
            and data.text
            or ("side " .. i)

        remote:FireServer(brick, sideEnum, rootPos, key, data.color, "spray", textToSend)
        -- material sync keeps text from stacking (original pattern)
        remote:FireServer(brick, Enum.NormalId.Top, rootPos, "material", PURE_BLACK, "neon", "")
        task.wait(0.45)
    end

    -- Step 3: final anchor
    remote:FireServer(brick, Enum.NormalId.Top, rootPos, "material", PURE_BLACK, "anchor", "")

    StarterGui:SetCore("SendNotification", {
        Title = "Synapse v4",
        Text = "All 6 sides painted.",
        Duration = 3,
    })

    task.wait(1)
    isNuking = false
end

------------------------------------------------------------------------
-- Activation
------------------------------------------------------------------------
ExecuteButton.MouseButton1Click:Connect(applyNuke)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Z then
        applyNuke()
    end
end)

local function setupMobile(char)
    char.ChildAdded:Connect(function(child)
        if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
            if child:IsA("Tool") and child.Name == "Paint" and not isNuking then
                task.wait(0.2)
                applyNuke()
            end
        end
    end)
end

if LocalPlayer.Character then setupMobile(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupMobile)

------------------------------------------------------------------------
-- Startup
------------------------------------------------------------------------
StarterGui:SetCore("SendNotification", {
    Title = "Synapse v4",
    Text = isWhitelisted
        and "Full access. All 6 sides unlocked."
        or  "Limited access. Sides 3-6 available.",
    Duration = 5,
})
