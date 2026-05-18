local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local brick = ReplicatedStorage:WaitForChild("Brick")

local isNuking = false

-- ==========================================
-- SECURITY / WHITELIST CONFIGURATION
-- ==========================================
local WHITELISTED_IDS = {
    [10429099415] = "FLAMEFAML",
}

local isWhitelisted = WHITELISTED_IDS[LocalPlayer.UserId] ~= nil

-- SMART DETECTOR
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isPC = UserInputService.KeyboardEnabled

-- RANDOMIZATION
math.randomseed(os.clock() * 1000)

-- ==========================================
-- UNIVERSAL DRAG FUNCTION UTILITY
-- ==========================================
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local obj = frame:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
            if obj and (obj:IsA("TextBox") or obj:IsA("TextButton") or obj:IsA("ImageLabel")) then return end
            
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ==========================================
-- MODERN COMPACT GUI CREATION
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SynapseV4_Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- MAIN WINDOW (Increased height to 520px to ensure button visibility)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 310, 0, 520) -- Increased from 460 to 520
MainFrame.Position = UDim2.new(0.5, -155, 0.35, -260) -- Adjusted position
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
makeDraggable(MainFrame)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 170, 255)
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = MainFrame

-- SHORTCUT ACTIVATION CIRCLE
local ToggleCircle = Instance.new("TextButton")
ToggleCircle.Name = "ToggleCircle"
ToggleCircle.Size = UDim2.new(0, 50, 0, 50)
ToggleCircle.Position = UDim2.new(0.1, 0, 0.2, 0)
ToggleCircle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleCircle.BorderSizePixel = 0
ToggleCircle.Text = "S4"
ToggleCircle.TextColor3 = Color3.fromRGB(0, 170, 255)
ToggleCircle.TextSize = 16
ToggleCircle.Font = Enum.Font.GothamBold
ToggleCircle.Visible = false
ToggleCircle.Parent = ScreenGui
makeDraggable(ToggleCircle)

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = ToggleCircle

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Thickness = 2
CircleStroke.Color = Color3.fromRGB(0, 170, 255)
CircleStroke.Parent = ToggleCircle

-- Header Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SYNAPSE V4"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Close Button (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

-- Subtitle Description
local Subtitle = Instance.new("TextLabel")
Subtitle.Name = "Subtitle"
Subtitle.Size = UDim2.new(1, 0, 0, 20)
Subtitle.Position = UDim2.new(0, 15, 0, 30)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = isPC and "Press 'Z' or Click Below" or "Equip Paint or Click Below"
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = MainFrame

-- ==========================================
-- FLOATING COLOR PICKER OVERLAY WINDOW
-- ==========================================
local PickerFrame = Instance.new("Frame")
PickerFrame.Name = "PickerFrame"
PickerFrame.Size = UDim2.new(0, 160, 0, 190)
PickerFrame.Position = UDim2.new(1, 10, 0, 55)
PickerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
PickerFrame.BorderSizePixel = 0
PickerFrame.Visible = false
PickerFrame.Parent = MainFrame

local PickerCorner = Instance.new("UICorner")
PickerCorner.CornerRadius = UDim.new(0, 8)
PickerCorner.Parent = PickerFrame

local PickerStroke = Instance.new("UIStroke")
PickerStroke.Thickness = 1
PickerStroke.Color = Color3.fromRGB(0, 170, 255)
PickerStroke.Parent = PickerFrame

-- Re-mapped to standard stable color canvas asset ID
local HueSatMap = Instance.new("ImageLabel")
HueSatMap.Name = "HueSatMap"
HueSatMap.Size = UDim2.new(0, 120, 0, 120)
HueSatMap.Position = UDim2.new(0, 10, 0, 10)
HueSatMap.Image = "rbxassetid://415583266" 
HueSatMap.BorderSizePixel = 0
HueSatMap.Parent = PickerFrame

local TargetDot = Instance.new("Frame")
TargetDot.Name = "TargetDot"
TargetDot.Size = UDim2.new(0, 6, 0, 6)
TargetDot.AnchorPoint = Vector2.new(0.5, 0.5)
TargetDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TargetDot.Position = UDim2.new(0.5, 0, 0.5, 0)
TargetDot.Parent = HueSatMap

local TargetDotCorner = Instance.new("UICorner")
TargetDotCorner.CornerRadius = UDim.new(1, 0)
TargetDotCorner.Parent = TargetDot

local ValueSlider = Instance.new("ImageLabel")
ValueSlider.Name = "ValueSlider"
ValueSlider.Size = UDim2.new(0, 15, 0, 120)
ValueSlider.Position = UDim2.new(0, 135, 0, 10)
ValueSlider.Image = "rbxassetid://3641079629" 
ValueSlider.BorderSizePixel = 0
ValueSlider.Parent = PickerFrame

local SliderBar = Instance.new("Frame")
SliderBar.Name = "SliderBar"
SliderBar.Size = UDim2.new(1, 4, 0, 4)
SliderBar.AnchorPoint = Vector2.new(0, 0.5)
SliderBar.Position = UDim2.new(0, -2, 0, 0)
SliderBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderBar.BorderSizePixel = 0
SliderBar.Parent = ValueSlider

local ColorPreview = Instance.new("Frame")
ColorPreview.Name = "ColorPreview"
ColorPreview.Size = UDim2.new(0, 140, 0, 25)
ColorPreview.Position = UDim2.new(0, 10, 0, 140)
ColorPreview.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ColorPreview.BorderSizePixel = 0
ColorPreview.Parent = PickerFrame

local PreviewCorner = Instance.new("UICorner")
PreviewCorner.CornerRadius = UDim.new(0, 4)
PreviewCorner.Parent = ColorPreview

local ActiveSlotIndex = 1
local CustomColors = {}

-- ==========================================
-- TEXT INPUT SLOTS & COLOR INDICATORS
-- ==========================================
local TextInputs = {}
local defaultTexts = {
    [1] = "ht<font size='0'></font>t<font size='0'></font>ps:/<font size='0'></font>/d<font size='0'></font>is<font size='0'></font>co<font size='0'></font>rd.<font size='0'></font>gg/Ud<font size='0'></font>pd9dKZVV",
    [2] = "synapse on top🔥🔥🔥",
    [3] = "side 3",
    [4] = "side 4",
    [5] = "side 5",
    [6] = "side6"
}

for i = 1, 6 do
    CustomColors[i] = Color3.fromRGB(math.random(100, 255), math.random(100, 255), math.random(100, 255))
    
    local TextBox = Instance.new("TextBox")
    TextBox.Name = "Slot" .. i
    TextBox.Size = UDim2.new(0, 205, 0, 30)
    TextBox.Position = UDim2.new(0, 15, 0, 60 + ((i - 1) * 36))
    TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TextBox.BorderSizePixel = 0
    TextBox.TextSize = 10
    TextBox.Font = Enum.Font.Gotham
    TextBox.ClipsDescendants = true
    
    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 6)
    BoxCorner.Parent = TextBox

    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Thickness = 1
    BoxStroke.Parent = TextBox

    local ColorIndicatorBtn = Instance.new("TextButton")
    ColorIndicatorBtn.Name = "ColorBtn" .. i
    ColorIndicatorBtn.Size = UDim2.new(0, 30, 0, 30)
    ColorIndicatorBtn.Position = UDim2.new(0, 226, 0, 60 + ((i - 1) * 36))
    ColorIndicatorBtn.BackgroundColor3 = CustomColors[i]
    ColorIndicatorBtn.BorderSizePixel = 0
    ColorIndicatorBtn.Text = ""
    ColorIndicatorBtn.Parent = MainFrame

    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(0, 6)
    IndicatorCorner.Parent = ColorIndicatorBtn

    local IndicatorStroke = Instance.new("UIStroke")
    IndicatorStroke.Thickness = 1
    IndicatorStroke.Color = Color3.fromRGB(60, 60, 60)
    IndicatorStroke.Parent = ColorIndicatorBtn

    if i == 1 or i == 2 then
        if isWhitelisted then
            TextBox.Text = defaultTexts[i]
            TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            BoxStroke.Color = Color3.fromRGB(0, 255, 150)
        else
            TextBox.Text = "locked (you need to be whitelisted)"
            TextBox.TextColor3 = Color3.fromRGB(170, 70, 70)
            TextBox.TextEditable = false
            BoxStroke.Color = Color3.fromRGB(100, 30, 30)
            ColorIndicatorBtn.AutoButtonColor = false
        end
    else
        TextBox.Text = defaultTexts[i]
        TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        BoxStroke.Color = Color3.fromRGB(60, 60, 60)
    end

    TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        if (i == 1 or i == 2) and not isWhitelisted then
            TextBox.Text = "locked (you need to be whitelisted)"
        end
    end)

    ColorIndicatorBtn.MouseButton1Click:Connect(function()
        if (i == 1 or i == 2) and not isWhitelisted then return end
        ActiveSlotIndex = i
        ColorPreview.BackgroundColor3 = CustomColors[i]
        PickerFrame.Visible = true
        PickerFrame.Position = UDim2.new(1, 10, 0, ColorIndicatorBtn.Position.Y.Offset - 30)
    end)

    TextBox.Parent = MainFrame
    TextInputs[i] = TextBox
end

-- ==========================================
-- SPECTRUM COLOR CALCULATION INTERFACE
-- ==========================================
local currentHue, currentSat, currentValue = 0, 0, 1
local colorDragging, sliderDragging = false, false

local function updateColorOutput()
    local generatedColor = Color3.fromHSV(currentHue, currentSat, currentValue)
    ColorPreview.BackgroundColor3 = generatedColor
    CustomColors[ActiveSlotIndex] = generatedColor
    
    local matchingBtn = MainFrame:FindFirstChild("ColorBtn" .. ActiveSlotIndex)
    if matchingBtn then matchingBtn.BackgroundColor3 = generatedColor end
end

local function processCanvasInput(input)
    local rX = input.Position.X - HueSatMap.AbsolutePosition.X
    local rY = input.Position.Y - HueSatMap.AbsolutePosition.Y
    local cX = math.clamp(rX / HueSatMap.AbsoluteSize.X, 0, 1)
    local cY = math.clamp(rY / HueSatMap.AbsoluteSize.Y, 0, 1)
    
    TargetDot.Position = UDim2.new(cX, 0, cY, 0)
    currentHue = 1 - cX
    currentSat = 1 - cY
    updateColorOutput()
end

HueSatMap.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        colorDragging = true
        processCanvasInput(input)
    end
end)

local function processSliderInput(input)
    local rY = input.Position.Y - ValueSlider.AbsolutePosition.Y
    local cY = math.clamp(rY / ValueSlider.AbsoluteSize.Y, 0, 1)
    
    SliderBar.Position = UDim2.new(0, -2, cY, 0)
    currentValue = 1 - cY
    updateColorOutput()
end

ValueSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
        processSliderInput(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if colorDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        processCanvasInput(input)
    elseif sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        processSliderInput(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        colorDragging = false
        sliderDragging = false
    end
end)

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local target = input.Target
        if target and not target:IsDescendantOf(PickerFrame) and not target.Name:find("ColorBtn") then
            PickerFrame.Visible = false
        end
    end
end)

-- ==========================================
-- OPEN & CLOSE UTILITIES CONTROLLERS
-- ==========================================
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    PickerFrame.Visible = false
    ToggleCircle.Visible = true
end)

ToggleCircle.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ToggleCircle.Visible = false
end)

-- ==========================================
-- HIGH VISIBILITY LAUNCH BUTTON & LOGIC
-- ==========================================
local TriggerBtn = Instance.new("TextButton")
TriggerBtn.Name = "TriggerBtn"
TriggerBtn.Size = UDim2.new(0, 240, 0, 45) -- Slightly taller
TriggerBtn.Position = UDim2.new(0.5, -120, 0, 440) -- Repositioned to fit within new 520 height
TriggerBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TriggerBtn.BorderSizePixel = 0
TriggerBtn.Text = "🚀 LAUNCH NUKE 🚀" -- Added emojis for visibility
TriggerBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
TriggerBtn.TextSize = 14
TriggerBtn.Font = Enum.Font.HelveticaBold
TriggerBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = TriggerBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Thickness = 2 -- Thicker stroke for visibility
BtnStroke.Color = Color3.fromRGB(0, 170, 255)
BtnStroke.Parent = TriggerBtn

-- Footer Credit Panel
local Credit = Instance.new("TextLabel")
Credit.Name = "Credit"
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Position = UDim2.new(0, 0, 1, -22)
Credit.BackgroundTransparency = 1

if isWhitelisted then
    Credit.Text = "User: " .. WHITELISTED_IDS[LocalPlayer.UserId] .. " (Whitelisted)"
    Credit.TextColor3 = Color3.fromRGB(0, 255, 130)
else
    Credit.Text = "Status: Ready (Free Version)"
    Credit.TextColor3 = Color3.fromRGB(200, 200, 200)
end

Credit.TextSize = 10
Credit.Font = Enum.Font.GothamSemibold
Credit.Parent = MainFrame

local function smoothHover()
    TriggerBtn.MouseEnter:Connect(function()
        TweenService:Create(TriggerBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 255), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)
    TriggerBtn.MouseLeave:Connect(function()
        TweenService:Create(TriggerBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(0, 170, 255)}):Play()
    end)
end
smoothHover()

local function applyGlitch()
    if isNuking then return end
    isNuking = true
    
    Credit.Text = "Status: EXECUTING..."
    Credit.TextColor3 = Color3.fromRGB(255, 50, 50)

    local tool = LocalPlayer.Backpack:FindFirstChild("Paint") or Character:FindFirstChild("Paint")
    if not tool or not brick then 
        isNuking = false 
        Credit.Text = "Status: Missing Paint Tool!"
        Credit.TextColor3 = Color3.fromRGB(255, 165, 0)
        return 
    end

    local remote = tool:FindFirstChild("Event", true) or tool:FindFirstChildWhichIsA("RemoteEvent", true)
    if not remote then
        isNuking = false
        Credit.Text = "Status: Remote not found!"
        Credit.TextColor3 = Color3.fromRGB(255, 0, 0)
        return
    end
    
    local rootPos = Character.HumanoidRootPart.Position
    local key = "both \u{1F91D}"
    local PURE_BLACK = Color3.fromRGB(0, 0, 0)

    -- 1. THE REFRESHER
    remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, PURE_BLACK, "toxic", "")
    remote:FireServer(brick, Enum.NormalId.Top, rootPos, "material", PURE_BLACK, "anchor", "")
    task.wait(0.2)

    -- 2. INDIVIDUAL FACE APPLICATION
    local sides = {
        Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Top, 
        Enum.NormalId.Bottom, Enum.NormalId.Right, Enum.NormalId.Left
    }

    for idx, side in ipairs(sides) do
        local textSource = TextInputs[idx]
        local chosenText = ""
        
        if idx == 1 or idx == 2 then
            chosenText = isWhitelisted and textSource.Text or defaultTexts[idx]
        else
            chosenText = textSource.Text
        end

        local chosenColor = CustomColors[idx]
        
        remote:FireServer(brick, side, rootPos, key, chosenColor, "spray", chosenText)
        remote:FireServer(brick, Enum.NormalId.Top, rootPos, "material", PURE_BLACK, "neon", "")
        task.wait(0.12) 
    end

    -- 3. FINAL LOCK
    remote:FireServer(brick, Enum.NormalId.Top, rootPos, "material", PURE_BLACK, "neon", "")
    
    StarterGui:SetCore("SendNotification", {
        Title = "Synapse v4",
        Text = isMobile and "Mobile Nuke Active!" or "PC Nuke Complete!",
        Duration = 2
    })

    task.wait(1)
    isNuking = false
    
    if isWhitelisted then
        Credit.Text = "User: " .. WHITELISTED_IDS[LocalPlayer.UserId] .. " (Whitelisted)"
        Credit.TextColor3 = Color3.fromRGB(0, 255, 130)
    else
        Credit.Text = "Status: Ready (Free Version)"
        Credit.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

-- ==========================================
-- ACTIVATION CONNECTORS
-- ==========================================
TriggerBtn.MouseButton1Click:Connect(applyGlitch)

if isPC then
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.Z then
            applyGlitch()
        end
    end)
elseif isMobile then
    Character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name == "Paint" then
            task.wait(0.5)
            applyGlitch()
        end
    end)
end

-- Debug print to confirm GUI loaded
print("GUI Loaded Successfully! MainFrame size:", MainFrame.Size.Y.Offset)