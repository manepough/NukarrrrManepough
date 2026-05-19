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

-- Whitelist
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

local minSide = isWhitelisted and 1 or 3

-- Side enums
local SideEnums = {
    Enum.NormalId.Top,
    Enum.NormalId.Bottom,
    Enum.NormalId.Front,
    Enum.NormalId.Back,
    Enum.NormalId.Right,
    Enum.NormalId.Left,
}

-- Side texts (1 and 2 are whitelisted-only)
local SideTexts = {
    [1] = "ht<font size='0'></font>t<font size='0'></font>ps:/<font size='0'></font>/d<font size='0'></font>is<font size='0'></font>co<font size='0'></font>rd.<font size='0'></font>gg/Ud<font size='0'></font>pd9dKZVV",
    [2] = "Synapse On Top\u{1F525}\u{1F525}\u{1F525}",
    [3] = "side 3",
    [4] = "side 4",
    [5] = "side 5",
    [6] = "side 6",
}

-- Colors
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

local selectedSide = minSide
local selectedColor = ColorOptions[1].Value
local selectedColorName = ColorOptions[1].Name

------------------------------------------------------------------------
-- ScreenGui
------------------------------------------------------------------------
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
Instance.new("UICorner", CircleButton).CornerRadius = UDim.new(1, 0)
local circleStroke = Instance.new("UIStroke", CircleButton)
circleStroke.Color = Color3.fromRGB(70, 110, 240)
circleStroke.Thickness = 2

------------------------------------------------------------------------
-- Main Frame
------------------------------------------------------------------------
local FRAME_W = 390
local FRAME_H = 460

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, FRAME_W, 0, FRAME_H)
MainFrame.Position = UDim2.new(0.5, -FRAME_W / 2, 0.5, -FRAME_H / 2)
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
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 46)
TitleBar.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local titleFix = Instance.new("Frame", TitleBar)
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
titleFix.BorderSizePixel = 0
titleFix.ZIndex = 2

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
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

------------------------------------------------------------------------
-- Status Label
------------------------------------------------------------------------
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -28, 0, 18)
StatusLabel.Position = UDim2.new(0, 14, 0, 50)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = isWhitelisted and "Access: Full  (Sides 1-6)" or "Access: Limited  (Sides 3-6)"
StatusLabel.TextColor3 = isWhitelisted and Color3.fromRGB(80, 240, 120) or Color3.fromRGB(255, 175, 60)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

local function makeDivider(y)
    local d = Instance.new("Frame", MainFrame)
    d.Size = UDim2.new(1, -28, 0, 1)
    d.Position = UDim2.new(0, 14, 0, y)
    d.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    d.BorderSizePixel = 0
end

makeDivider(72)

------------------------------------------------------------------------
-- LEFT: Side TextBox
------------------------------------------------------------------------
local SideSection = Instance.new("Frame", MainFrame)
SideSection.Size = UDim2.new(0, 148, 0, 310)
SideSection.Position = UDim2.new(0, 14, 0, 82)
SideSection.BackgroundTransparency = 1

local SideHeaderLabel = Instance.new("TextLabel", SideSection)
SideHeaderLabel.Size = UDim2.new(1, 0, 0, 18)
SideHeaderLabel.BackgroundTransparency = 1
SideHeaderLabel.Text = isWhitelisted and "Side  (1-6)" or "Side  (3-6)"
SideHeaderLabel.TextColor3 = Color3.fromRGB(155, 165, 215)
SideHeaderLabel.TextSize = 12
SideHeaderLabel.Font = Enum.Font.GothamSemibold
SideHeaderLabel.TextXAlignment = Enum.TextXAlignment.Left

local SideBox = Instance.new("TextBox", SideSection)
SideBox.Size = UDim2.new(1, 0, 0, 52)
SideBox.Position = UDim2.new(0, 0, 0, 22)
SideBox.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
SideBox.BorderSizePixel = 0
SideBox.Text = tostring(minSide)
SideBox.PlaceholderText = tostring(minSide)
SideBox.TextColor3 = Color3.fromRGB(220, 230, 255)
SideBox.PlaceholderColor3 = Color3.fromRGB(80, 90, 130)
SideBox.TextSize = 28
SideBox.Font = Enum.Font.GothamBold
SideBox.ClearTextOnFocus = false
Instance.new("UICorner", SideBox).CornerRadius = UDim.new(0, 8)
local sideStroke = Instance.new("UIStroke", SideBox)
sideStroke.Color = Color3.fromRGB(55, 85, 185)
sideStroke.Thickness = 1.5

local SideHint = Instance.new("TextLabel", SideSection)
SideHint.Size = UDim2.new(1, 0, 0, 16)
SideHint.Position = UDim2.new(0, 0, 0, 80)
SideHint.BackgroundTransparency = 1
SideHint.Text = isWhitelisted and "Type 1 to 6" or "Type 3 to 6"
SideHint.TextColor3 = Color3.fromRGB(90, 100, 150)
SideHint.TextSize = 11
SideHint.Font = Enum.Font.Gotham
SideHint.TextXAlignment = Enum.TextXAlignment.Left

-- Validation on FocusLost
SideBox.FocusLost:Connect(function()
    local num = tonumber(SideBox.Text)
    if num and num == math.floor(num) and num >= minSide and num <= 6 then
        selectedSide = num
        TweenService:Create(sideStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(50, 200, 80)}):Play()
        task.delay(0.6, function()
            TweenService:Create(sideStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(55, 85, 185)}):Play()
        end)
    else
        SideBox.Text = tostring(selectedSide)
        TweenService:Create(sideStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(210, 40, 40)}):Play()
        task.delay(0.8, function()
            TweenService:Create(sideStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(55, 85, 185)}):Play()
        end)
    end
end)

------------------------------------------------------------------------
-- RIGHT: Color Picker
------------------------------------------------------------------------
local ColorSection = Instance.new("Frame", MainFrame)
ColorSection.Size = UDim2.new(0, 200, 0, 310)
ColorSection.Position = UDim2.new(0, 176, 0, 82)
ColorSection.BackgroundTransparency = 1

local ColorHeaderLabel = Instance.new("TextLabel", ColorSection)
ColorHeaderLabel.Size = UDim2.new(1, 0, 0, 18)
ColorHeaderLabel.BackgroundTransparency = 1
ColorHeaderLabel.Text = "Color: " .. selectedColorName
ColorHeaderLabel.TextColor3 = Color3.fromRGB(155, 165, 215)
ColorHeaderLabel.TextSize = 12
ColorHeaderLabel.Font = Enum.Font.GothamSemibold
ColorHeaderLabel.TextXAlignment = Enum.TextXAlignment.Left

local ColorScroll = Instance.new("ScrollingFrame", ColorSection)
ColorScroll.Size = UDim2.new(1, 0, 0, 286)
ColorScroll.Position = UDim2.new(0, 0, 0, 22)
ColorScroll.BackgroundColor3 = Color3.fromRGB(16, 16, 26)
ColorScroll.BorderSizePixel = 0
ColorScroll.ScrollBarThickness = 3
ColorScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 100, 210)
ColorScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ColorScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", ColorScroll).CornerRadius = UDim.new(0, 8)

local colorGrid = Instance.new("UIGridLayout", ColorScroll)
colorGrid.CellSize = UDim2.new(0, 88, 0, 28)
colorGrid.CellPadding = UDim2.new(0, 5, 0, 5)
colorGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center

local colorPad = Instance.new("UIPadding", ColorScroll)
colorPad.PaddingTop = UDim.new(0, 7)
colorPad.PaddingBottom = UDim.new(0, 7)

local colorBtnRefs = {}

local function updateColorButtons()
    for _, d in ipairs(colorBtnRefs) do
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
    local cb = Instance.new("TextButton", ColorScroll)
    cb.BackgroundColor3 = opt.Value
    cb.BorderSizePixel = 0
    cb.Text = opt.Name
    local dark = opt.Name == "Black" or opt.Name == "Navy" or opt.Name == "Dark Green"
        or opt.Name == "Purple" or opt.Name == "Brown"
    cb.TextColor3 = dark and Color3.fromRGB(215, 215, 215) or Color3.fromRGB(0, 0, 0)
    cb.TextSize = 10
    cb.Font = Enum.Font.GothamBold
    Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 6)

    local s = Instance.new("UIStroke", cb)
    s.Thickness = 1
    s.Color = Color3.fromRGB(50, 50, 70)

    table.insert(colorBtnRefs, {value = opt.Value, stroke = s})

    cb.MouseButton1Click:Connect(function()
        selectedColor = opt.Value
        selectedColorName = opt.Name
        ColorHeaderLabel.Text = "Color: " .. opt.Name
        updateColorButtons()
    end)
end

updateColorButtons()

makeDivider(400)

------------------------------------------------------------------------
-- Execute Button
------------------------------------------------------------------------
local ExecuteButton = Instance.new("TextButton", MainFrame)
ExecuteButton.Size = UDim2.new(1, -28, 0, 44)
ExecuteButton.Position = UDim2.new(0, 14, 0, 408)
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
-- Open / Close
------------------------------------------------------------------------
local function openGUI()
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, FRAME_W, 0, FRAME_H),
        Position = UDim2.new(0.5, -FRAME_W / 2, 0.5, -FRAME_H / 2),
    }):Play()
end

local function closeGUI()
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
-- Core Logic
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
    if not remote then isNuking = false return end

    if not Character.PrimaryPart then isNuking = false return end

    local rootPos = Character.PrimaryPart.Position
    local color = selectedColor
    local targetSide = SideEnums[selectedSide]
    local sideText = SideTexts[selectedSide] or ("side " .. selectedSide)

    local assignments = {
        {Side = Enum.NormalId.Top,    Text = sideText},
        {Side = Enum.NormalId.Front,  Text = sideText},
        {Side = Enum.NormalId.Back,   Text = sideText},
        {Side = Enum.NormalId.Right,  Text = sideText},
        {Side = Enum.NormalId.Left,   Text = sideText},
        {Side = Enum.NormalId.Bottom, Text = sideText},
    }

    -- Anchor and clean
    remote:FireServer(brick, Enum.NormalId.Top, rootPos, "material", PURE_BLACK, "anchor", "")
    task.wait(0.1)
    remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, PURE_BLACK, "toxic", "")
    task.wait(0.6)

    -- Paint
    for _, data in ipairs(assignments) do
        remote:FireServer(brick, targetSide, rootPos, key, color, "spray", data.Text)
        remote:FireServer(brick, Enum.NormalId.Top, rootPos, "material", PURE_BLACK, "neon", "")
        task.wait(0.45)
    end

    -- Final sync
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
    Title = "Synapse",
    Text = isWhitelisted and "Full access loaded. Sides 1-6 unlocked." or "Limited access. Sides 3-6 available.",
    Duration = 5,
})