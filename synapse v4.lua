local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local brick = ReplicatedStorage:WaitForChild("Brick")

local isNuking = false
local key = "both"
local PURE_BLACK = Color3.fromRGB(0, 0, 0)

-- Whitelist (add usernames here)
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

-- Palettes
local Palettes = {
    Gold   = {Color3.fromRGB(255, 215, 0), Color3.fromRGB(218, 165, 32), Color3.fromRGB(255, 223, 0)},
    Purple = {Color3.fromRGB(128, 0, 128), Color3.fromRGB(147, 112, 219), Color3.fromRGB(75, 0, 130)},
    Silver = {Color3.fromRGB(192, 192, 192), Color3.fromRGB(211, 211, 211), Color3.fromRGB(169, 169, 169)},
    Orange = {Color3.fromRGB(255, 165, 0), Color3.fromRGB(255, 140, 0), Color3.fromRGB(255, 69, 0)},
    Green  = {Color3.fromRGB(0, 255, 0), Color3.fromRGB(50, 205, 50), Color3.fromRGB(0, 128, 0)},
    Blue   = {Color3.fromRGB(0, 0, 255), Color3.fromRGB(30, 144, 255), Color3.fromRGB(0, 191, 255)},
}

-- Side Enums
local SideEnums = {
    Enum.NormalId.Top,
    Enum.NormalId.Bottom,
    Enum.NormalId.Front,
    Enum.NormalId.Back,
    Enum.NormalId.Right,
    Enum.NormalId.Left,
}

-- Color Options
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

-- State
local selectedSide = isWhitelisted and 1 or 3
local selectedColor = ColorOptions[1].Value
local selectedColorName = ColorOptions[1].Name

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SynapseGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

------------------------------------------------------------------------
-- Circle Toggle Button
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

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = CircleButton
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(70, 110, 240)
    s.Thickness = 2
    s.Parent = CircleButton
end

------------------------------------------------------------------------
-- Main Frame
------------------------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 490)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -245)
MainFrame.BackgroundColor3 = Color3.fromRGB(11, 11, 19)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = MainFrame
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(55, 95, 215)
    s.Thickness = 1.5
    s.Parent = MainFrame
end

------------------------------------------------------------------------
-- Title Bar
------------------------------------------------------------------------
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 46)
TitleBar.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = TitleBar
    -- fill bottom rounded corners
    local fix = Instance.new("Frame")
    fix.Size = UDim2.new(1, 0, 0.5, 0)
    fix.Position = UDim2.new(0, 0, 0.5, 0)
    fix.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
    fix.BorderSizePixel = 0
    fix.ZIndex = 2
    fix.Parent = TitleBar
end

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Synapse"
TitleLabel.TextColor3 = Color3.fromRGB(200, 210, 255)
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -38, 0, 9)
CloseButton.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 12
CloseButton.Font = Enum.Font.GothamBold
CloseButton.ZIndex = 4
CloseButton.Parent = TitleBar

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = CloseButton
end

------------------------------------------------------------------------
-- Access Status Label
------------------------------------------------------------------------
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -14, 0, 18)
StatusLabel.Position = UDim2.new(0, 14, 0, 50)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = isWhitelisted and "Access: Full  (Sides 1-6)" or "Access: Limited  (Sides 3-6)"
StatusLabel.TextColor3 = isWhitelisted and Color3.fromRGB(80, 240, 120) or Color3.fromRGB(255, 175, 60)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

------------------------------------------------------------------------
-- Divider
------------------------------------------------------------------------
local function makeDivider(posY)
    local div = Instance.new("Frame")
    div.Size = UDim2.new(1, -28, 0, 1)
    div.Position = UDim2.new(0, 14, 0, posY)
    div.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    div.BorderSizePixel = 0
    div.Parent = MainFrame
    return div
end

makeDivider(72)

------------------------------------------------------------------------
-- Side Selector
------------------------------------------------------------------------
local SideLabel = Instance.new("TextLabel")
SideLabel.Size = UDim2.new(1, -14, 0, 20)
SideLabel.Position = UDim2.new(0, 14, 0, 78)
SideLabel.BackgroundTransparency = 1
SideLabel.Text = "Select Side"
SideLabel.TextColor3 = Color3.fromRGB(155, 165, 215)
SideLabel.TextSize = 12
SideLabel.Font = Enum.Font.GothamSemibold
SideLabel.TextXAlignment = Enum.TextXAlignment.Left
SideLabel.Parent = MainFrame

local SideFrame = Instance.new("Frame")
SideFrame.Size = UDim2.new(1, -28, 0, 38)
SideFrame.Position = UDim2.new(0, 14, 0, 100)
SideFrame.BackgroundTransparency = 1
SideFrame.Parent = MainFrame

do
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 6)
    layout.Parent = SideFrame
end

local sideButtons = {}

local function updateSideButtons()
    for i, btn in ipairs(sideButtons) do
        if i == selectedSide then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(60, 100, 220)}):Play()
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            local locked = not isWhitelisted and (i == 1 or i == 2)
            TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundColor3 = locked and Color3.fromRGB(18, 18, 30) or Color3.fromRGB(26, 26, 42)
            }):Play()
            btn.TextColor3 = locked and Color3.fromRGB(55, 55, 75) or Color3.fromRGB(130, 145, 195)
        end
    end
end

for i = 1, 6 do
    local locked = not isWhitelisted and (i == 1 or i == 2)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 46, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(26, 26, 42)
    btn.BorderSizePixel = 0
    btn.Text = tostring(i)
    btn.TextColor3 = Color3.fromRGB(130, 145, 195)
    btn.TextSize = 15
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = not locked
    btn.Parent = SideFrame

    do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = btn
    end

    if not locked then
        btn.MouseButton1Click:Connect(function()
            selectedSide = i
            updateSideButtons()
        end)
    end

    sideButtons[i] = btn
end

updateSideButtons()

makeDivider(145)

------------------------------------------------------------------------
-- Color Picker
------------------------------------------------------------------------
local ColorPickerLabel = Instance.new("TextLabel")
ColorPickerLabel.Size = UDim2.new(1, -14, 0, 20)
ColorPickerLabel.Position = UDim2.new(0, 14, 0, 151)
ColorPickerLabel.BackgroundTransparency = 1
ColorPickerLabel.Text = "Color: " .. selectedColorName
ColorPickerLabel.TextColor3 = Color3.fromRGB(155, 165, 215)
ColorPickerLabel.TextSize = 12
ColorPickerLabel.Font = Enum.Font.GothamSemibold
ColorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
ColorPickerLabel.Parent = MainFrame

local ColorScroll = Instance.new("ScrollingFrame")
ColorScroll.Size = UDim2.new(1, -28, 0, 208)
ColorScroll.Position = UDim2.new(0, 14, 0, 174)
ColorScroll.BackgroundColor3 = Color3.fromRGB(16, 16, 26)
ColorScroll.BorderSizePixel = 0
ColorScroll.ScrollBarThickness = 4
ColorScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 100, 210)
ColorScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ColorScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ColorScroll.Parent = MainFrame

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 9)
    c.Parent = ColorScroll

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, 72, 0, 32)
    grid.CellPadding = UDim2.new(0, 6, 0, 6)
    grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    grid.Parent = ColorScroll

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.Parent = ColorScroll
end

local colorBtnData = {}

local function updateColorButtons()
    for _, d in ipairs(colorBtnData) do
        if d.value == selectedColor then
            d.stroke.Thickness = 2.5
            d.stroke.Color = Color3.fromRGB(255, 255, 255)
        else
            d.stroke.Thickness = 1
            d.stroke.Color = Color3.fromRGB(50, 50, 70)
        end
    end
end

for _, opt in ipairs(ColorOptions) do
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = opt.Value
    btn.BorderSizePixel = 0
    btn.Text = opt.Name
    btn.TextColor3 = (opt.Name == "Black" or opt.Name == "Navy" or opt.Name == "Dark Green")
        and Color3.fromRGB(200, 200, 200)
        or Color3.fromRGB(0, 0, 0)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = ColorScroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = btn

    local s = Instance.new("UIStroke")
    s.Thickness = 1
    s.Color = Color3.fromRGB(50, 50, 70)
    s.Parent = btn

    table.insert(colorBtnData, {value = opt.Value, stroke = s})

    btn.MouseButton1Click:Connect(function()
        selectedColor = opt.Value
        selectedColorName = opt.Name
        ColorPickerLabel.Text = "Color: " .. opt.Name
        updateColorButtons()
    end)
end

updateColorButtons()

makeDivider(388)

------------------------------------------------------------------------
-- Execute Button
------------------------------------------------------------------------
local ExecuteButton = Instance.new("TextButton")
ExecuteButton.Size = UDim2.new(1, -28, 0, 44)
ExecuteButton.Position = UDim2.new(0, 14, 0, 396)
ExecuteButton.BackgroundColor3 = Color3.fromRGB(48, 88, 210)
ExecuteButton.BorderSizePixel = 0
ExecuteButton.Text = "Execute"
ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteButton.TextSize = 16
ExecuteButton.Font = Enum.Font.GothamBold
ExecuteButton.Parent = MainFrame

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = ExecuteButton
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(100, 140, 255)
    s.Thickness = 1.5
    s.Parent = ExecuteButton
end

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
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        TweenService:Create(MainFrame, TweenInfo.new(0.06, Enum.EasingStyle.Linear), {
            Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
        }):Play()
    end
end)

------------------------------------------------------------------------
-- Toggle Open / Close
------------------------------------------------------------------------
local function openGUI()
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 350, 0, 490),
        Position = UDim2.new(0.5, -175, 0.5, -245),
    }):Play()
end

local function closeGUI()
    local t = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
    })
    t:Play()
    t.Completed:Connect(function()
        MainFrame.Visible = false
    end)
end

CircleButton.MouseButton1Click:Connect(function()
    if MainFrame.Visible then
        closeGUI()
    else
        openGUI()
    end
end)

CloseButton.MouseButton1Click:Connect(closeGUI)

------------------------------------------------------------------------
-- Core Nuke Logic
------------------------------------------------------------------------
local function applyNuke()
    local Character = LocalPlayer.Character
    if not Character or isNuking then return end

    local tool = Character:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
    if not tool then return end

    isNuking = true

    if tool.Parent ~= Character then
        Character:WaitForChild("Humanoid"):EquipTool(tool)
        task.wait(0.5)
    end

    local remote = tool:FindFirstChild("Event", true) or tool:FindFirstChildWhichIsA("RemoteEvent", true)
    if not remote then
        isNuking = false
        return
    end

    if not Character.PrimaryPart then
        isNuking = false
        return
    end

    local rootPos = Character.PrimaryPart.Position
    local color = selectedColor

    local assignments = {
        {Side = Enum.NormalId.Top,    Text = "side 2"},
        {Side = Enum.NormalId.Front,  Text = "side 3"},
        {Side = Enum.NormalId.Back,   Text = "side 4"},
        {Side = Enum.NormalId.Right,  Text = "side 5"},
        {Side = Enum.NormalId.Left,   Text = "side 6"},
        {Side = Enum.NormalId.Bottom, Text = "side 1"},
    }

    -- Anchor and clean phase
    remote:FireServer(brick, Enum.NormalId.Top, rootPos, "material", PURE_BLACK, "anchor", "")
    task.wait(0.1)
    remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, PURE_BLACK, "toxic", "")
    task.wait(0.6)

    -- Paint phase using selected side index
    local targetSide = SideEnums[selectedSide]
    for _, data in ipairs(assignments) do
        remote:FireServer(brick, targetSide, rootPos, key, color, "spray", data.Text)
        remote:FireServer(brick, Enum.NormalId.Top, rootPos, "material", PURE_BLACK, "neon", "")
        task.wait(0.45)
    end

    -- Final anchor sync
    remote:FireServer(brick, Enum.NormalId.Top, rootPos, "material", PURE_BLACK, "anchor", "")

    StarterGui:SetCore("SendNotification", {
        Title = "Synapse",
        Text = "Side: " .. selectedSide .. "  |  Color: " .. selectedColorName,
        Duration = 3,
    })

    task.wait(1)
    isNuking = false
end

------------------------------------------------------------------------
-- Buttons and Keybind
ExecuteButton.MouseButton1Click:Connect(applyNuke)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Z then
        applyNuke()
    end
end)

-- Mobile
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
-- Startup Notification
------------------------------------------------------------------------
StarterGui:SetCore("SendNotification", {
      Title = "Synapse V4", 
      Text = isWhitelisted and "Full acces loaded use Z in pc or circle button in mobile." or "limit acces ur not whitelisted only 3-6 Z if ur in pc or Circle button if ur in mobile", 
      Duration = 5, 
})
