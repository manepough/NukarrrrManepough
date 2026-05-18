local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local brick = ReplicatedStorage:WaitForChild("Brick")

local isNuking = false
local key = "both \u{1F91D}"
local PURE_BLACK = Color3.fromRGB(0, 0, 0)

-- Whitelist - Add player names here to give them access to options 1-2
local whitelist = {
    ["YourUsernameHere"] = true,  -- Replace with actual usernames
}

local function isWhitelisted()
    local playerName = LocalPlayer.Name
    return whitelist[playerName] or false
end

-- Smart Device Detection
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- GUI Variables
local guiEnabled = false
local screenGui = nil
local circleButton = nil
local mainFrame = nil
local textBoxes = {}
local selectedOption = nil
local selectedColor = Color3.fromRGB(255, 255, 255)

-- Find and equip Paint tool
local function equipPaintTool()
    local tool = LocalPlayer.Backpack:FindFirstChild("Paint")
    if tool then
        Character:WaitForChild("Humanoid"):EquipTool(tool)
        return tool
    end
    
    tool = Character:FindFirstChild("Paint")
    if tool then
        return tool
    end
    
    return nil
end

-- Create Circle Button
local function createCircleButton()
    circleButton = Instance.new("ImageButton")
    circleButton.Size = UDim2.new(0, 50, 0, 50)
    circleButton.Position = UDim2.new(0, 20, 1, -70)
    circleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
    circleButton.BackgroundTransparency = 0
    circleButton.BorderSizePixel = 0
    circleButton.Image = "rbxassetid://3926305904"
    circleButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    circleButton.ImageTransparency = 0.3
    circleButton.ZIndex = 10
    
    local glow = Instance.new("UICorner")
    glow.CornerRadius = UDim.new(1, 0)
    glow.Parent = circleButton
    
    circleButton.Parent = screenGui
    
    circleButton.MouseEnter:Connect(function()
        TweenService:Create(circleButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 55, 0, 55)}):Play()
    end)
    
    circleButton.MouseLeave:Connect(function()
        TweenService:Create(circleButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 50, 0, 50)}):Play()
    end)
    
    circleButton.MouseButton1Click:Connect(function()
        toggleGUI()
    end)
end

-- Create Color Picker Button
local function createColorPicker(parent, x, y, currentColor)
    local colorButton = Instance.new("ImageButton")
    colorButton.Size = UDim2.new(0, 30, 0, 30)
    colorButton.Position = UDim2.new(x, 0, y, 0)
    colorButton.BackgroundColor3 = currentColor
    colorButton.BackgroundTransparency = 0
    colorButton.BorderSizePixel = 1
    colorButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
    colorButton.Parent = parent
    
    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 5)
    colorCorner.Parent = colorButton
    
    -- Color picker popup
    colorButton.MouseButton1Click:Connect(function()
        local colorFrame = Instance.new("Frame")
        colorFrame.Size = UDim2.new(0, 200, 0, 150)
        colorFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
        colorFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        colorFrame.BackgroundTransparency = 0
        colorFrame.BorderSizePixel = 0
        colorFrame.Parent = mainFrame
        colorFrame.ZIndex = 20
        
        local colorCornerBig = Instance.new("UICorner")
        colorCornerBig.CornerRadius = UDim.new(0, 10)
        colorCornerBig.Parent = colorFrame
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        title.Text = "Pick a Color"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 14
        title.Font = Enum.Font.GothamBold
        title.Parent = colorFrame
        
        local titleCorner = Instance.new("UICorner")
        titleCorner.CornerRadius = UDim.new(0, 10)
        titleCorner.Parent = title
        
        -- Color presets
        local colors = {
            Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 0, 255), Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0), Color3.fromRGB(128, 128, 128),
            Color3.fromRGB(255, 128, 0), Color3.fromRGB(128, 0, 255), Color3.fromRGB(255, 192, 203)
        }
        
        for i, color in ipairs(colors) do
            local row = math.floor((i-1) / 4)
            local col = (i-1) % 4
            local colorPick = Instance.new("ImageButton")
            colorPick.Size = UDim2.new(0, 40, 0, 40)
            colorPick.Position = UDim2.new(0, 10 + (col * 45), 0, 40 + (row * 45))
            colorPick.BackgroundColor3 = color
            colorPick.BackgroundTransparency = 0
            colorPick.BorderSizePixel = 1
            colorPick.BorderColor3 = Color3.fromRGB(255, 255, 255)
            colorPick.Parent = colorFrame
            
            local pickCorner = Instance.new("UICorner")
            pickCorner.CornerRadius = UDim.new(0, 5)
            pickCorner.Parent = colorPick
            
            colorPick.MouseButton1Click:Connect(function()
                selectedColor = color
                colorButton.BackgroundColor3 = color
                colorFrame:Destroy()
                StarterGui:SetCore("SendNotification", {
                    Title = "Color Picker",
                    Text = "Color selected!",
                    Duration = 1
                })
            end)
        end
        
        local closeColor = Instance.new("TextButton")
        closeColor.Size = UDim2.new(0, 60, 0, 25)
        closeColor.Position = UDim2.new(1, -70, 1, -35)
        closeColor.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
        closeColor.Text = "Close"
        closeColor.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeColor.TextSize = 12
        closeColor.Font = Enum.Font.GothamBold
        closeColor.BorderSizePixel = 0
        closeColor.Parent = colorFrame
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 5)
        closeCorner.Parent = closeColor
        
        closeColor.MouseButton1Click:Connect(function()
            colorFrame:Destroy()
        end)
    end)
    
    return colorButton
end

-- Create Main GUI
local function createGUI()
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.ZIndex = 5
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -50, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Synapse Nuke v4"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.Parent = titleBar
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 35, 1, 0)
    closeButton.Position = UDim2.new(1, -40, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 22
    closeButton.Font = Enum.Font.GothamBold
    closeButton.BorderSizePixel = 0
    closeButton.Parent = titleBar
    
    closeButton.MouseButton1Click:Connect(function()
        toggleGUI()
    end)
    
    -- Scrollable Options Container
    local optionsContainer = Instance.new("ScrollingFrame")
    optionsContainer.Size = UDim2.new(1, -20, 0, 380)
    optionsContainer.Position = UDim2.new(0, 10, 0, 50)
    optionsContainer.BackgroundTransparency = 1
    optionsContainer.BorderSizePixel = 0
    optionsContainer.CanvasSize = UDim2.new(0, 0, 0, 420)
    optionsContainer.ScrollBarThickness = 6
    optionsContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 100)
    optionsContainer.Parent = mainFrame
    
    local optionsList = Instance.new("UIListLayout")
    optionsList.Padding = UDim.new(0, 8)
    optionsList.SortOrder = Enum.SortOrder.LayoutOrder
    optionsList.Parent = optionsContainer
    
    local whitelisted = isWhitelisted()
    
    -- Option 1 (Locked for non-whitelisted)
    local option1Frame = Instance.new("Frame")
    option1Frame.Size = UDim2.new(1, 0, 0, 75)
    option1Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    option1Frame.BorderSizePixel = 0
    option1Frame.Parent = optionsContainer
    
    local option1Corner = Instance.new("UICorner")
    option1Corner.CornerRadius = UDim.new(0, 8)
    option1Corner.Parent = option1Frame
    
    local option1Title = Instance.new("TextLabel")
    option1Title.Size = UDim2.new(1, -20, 0, 25)
    option1Title.Position = UDim2.new(0, 10, 0, 5)
    option1Title.BackgroundTransparency = 1
    option1Title.Text = "Option 1 (Discord Link)"
    option1Title.TextColor3 = whitelisted and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    option1Title.TextSize = 13
    option1Title.TextXAlignment = Enum.TextXAlignment.Left
    option1Title.Font = Enum.Font.GothamBold
    option1Title.Parent = option1Frame
    
    local option1Text = Instance.new("TextLabel")
    option1Text.Size = UDim2.new(1, -110, 0, 30)
    option1Text.Position = UDim2.new(0, 10, 0, 35)
    option1Text.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    option1Text.BackgroundTransparency = 0
    option1Text.BorderSizePixel = 0
    option1Text.Text = "https://discord.gg/Udpd9dKZVV"
    option1Text.TextColor3 = Color3.fromRGB(200, 200, 200)
    option1Text.TextSize = 11
    option1Text.TextXAlignment = Enum.TextXAlignment.Left
    option1Text.Font = Enum.Font.Gotham
    option1Text.Parent = option1Frame
    
    local option1Corner2 = Instance.new("UICorner")
    option1Corner2.CornerRadius = UDim.new(0, 5)
    option1Corner2.Parent = option1Text
    
    -- Color picker for option 1
    local option1Color = createColorPicker(option1Frame, 1, -40, selectedColor)
    option1Color.Position = UDim2.new(1, -45, 0, 38)
    
    local option1Lock = Instance.new("TextButton")
    option1Lock.Size = UDim2.new(0, 70, 0, 28)
    option1Lock.Position = UDim2.new(1, -120, 0, 38)
    option1Lock.BackgroundColor3 = whitelisted and Color3.fromRGB(75, 150, 75) or Color3.fromRGB(100, 100, 100)
    option1Lock.Text = whitelisted and "USE" or "LOCKED"
    option1Lock.TextColor3 = Color3.fromRGB(255, 255, 255)
    option1Lock.TextSize = 11
    option1Lock.Font = Enum.Font.GothamBold
    option1Lock.BorderSizePixel = 0
    option1Lock.Parent = option1Frame
    
    local option1LockCorner = Instance.new("UICorner")
    option1LockCorner.CornerRadius = UDim.new(0, 5)
    option1LockCorner.Parent = option1Lock
    
    if whitelisted then
        option1Lock.MouseButton1Click:Connect(function()
            selectedOption = option1Text.Text
            StarterGui:SetCore("SendNotification", {
                Title = "Selected",
                Text = "Selected: Discord Link",
                Duration = 1
            })
        end)
    else
        option1Lock.MouseButton1Click:Connect(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Locked",
                Text = "You need to be whitelisted to use this option!",
                Duration = 2
            })
        end)
    end
    
    -- Option 2 (Locked for non-whitelisted)
    local option2Frame = Instance.new("Frame")
    option2Frame.Size = UDim2.new(1, 0, 0, 75)
    option2Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    option2Frame.BorderSizePixel = 0
    option2Frame.Parent = optionsContainer
    
    local option2Corner = Instance.new("UICorner")
    option2Corner.CornerRadius = UDim.new(0, 8)
    option2Corner.Parent = option2Frame
    
    local option2Title = Instance.new("TextLabel")
    option2Title.Size = UDim2.new(1, -20, 0, 25)
    option2Title.Position = UDim2.new(0, 10, 0, 5)
    option2Title.BackgroundTransparency = 1
    option2Title.Text = "Option 2 (Synapse Text)"
    option2Title.TextColor3 = whitelisted and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    option2Title.TextSize = 13
    option2Title.TextXAlignment = Enum.TextXAlignment.Left
    option2Title.Font = Enum.Font.GothamBold
    option2Title.Parent = option2Frame
    
    local option2Text = Instance.new("TextLabel")
    option2Text.Size = UDim2.new(1, -110, 0, 30)
    option2Text.Position = UDim2.new(0, 10, 0, 35)
    option2Text.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    option2Text.BackgroundTransparency = 0
    option2Text.BorderSizePixel = 0
    option2Text.Text = "Synapse on top🔥🔥🔥"
    option2Text.TextColor3 = Color3.fromRGB(200, 200, 200)
    option2Text.TextSize = 11
    option2Text.TextXAlignment = Enum.TextXAlignment.Left
    option2Text.Font = Enum.Font.Gotham
    option2Text.Parent = option2Frame
    
    local option2Corner2 = Instance.new("UICorner")
    option2Corner2.CornerRadius = UDim.new(0, 5)
    option2Corner2.Parent = option2Text
    
    -- Color picker for option 2
    local option2Color = createColorPicker(option2Frame, 1, -40, selectedColor)
    option2Color.Position = UDim2.new(1, -45, 0, 38)
    
    local option2Lock = Instance.new("TextButton")
    option2Lock.Size = UDim2.new(0, 70, 0, 28)
    option2Lock.Position = UDim2.new(1, -120, 0, 38)
    option2Lock.BackgroundColor3 = whitelisted and Color3.fromRGB(75, 150, 75) or Color3.fromRGB(100, 100, 100)
    option2Lock.Text = whitelisted and "USE" or "LOCKED"
    option2Lock.TextColor3 = Color3.fromRGB(255, 255, 255)
    option2Lock.TextSize = 11
    option2Lock.Font = Enum.Font.GothamBold
    option2Lock.BorderSizePixel = 0
    option2Lock.Parent = option2Frame
    
    local option2LockCorner = Instance.new("UICorner")
    option2LockCorner.CornerRadius = UDim.new(0, 5)
    option2LockCorner.Parent = option2Lock
    
    if whitelisted then
        option2Lock.MouseButton1Click:Connect(function()
            selectedOption = option2Text.Text
            StarterGui:SetCore("SendNotification", {
                Title = "Selected",
                Text = "Selected: Synapse Text",
                Duration = 1
            })
        end)
    else
        option2Lock.MouseButton1Click:Connect(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Locked",
                Text = "You need to be whitelisted to use this option!",
                Duration = 2
            })
        end)
    end
    
    -- Options 3-6 (Editable text boxes)
    for i = 3, 6 do
        local optionFrame = Instance.new("Frame")
        optionFrame.Size = UDim2.new(1, 0, 0, 75)
        optionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        optionFrame.BorderSizePixel = 0
        optionFrame.Parent = optionsContainer
        
        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 8)
        optionCorner.Parent = optionFrame
        
        local optionTitle = Instance.new("TextLabel")
        optionTitle.Size = UDim2.new(1, -20, 0, 25)
        optionTitle.Position = UDim2.new(0, 10, 0, 5)
        optionTitle.BackgroundTransparency = 1
        optionTitle.Text = "Option " .. i .. " (Custom Text)"
        optionTitle.TextColor3 = Color3.fromRGB(100, 255, 100)
        optionTitle.TextSize = 13
        optionTitle.TextXAlignment = Enum.TextXAlignment.Left
        optionTitle.Font = Enum.Font.GothamBold
        optionTitle.Parent = optionFrame
        
        local optionTextBox = Instance.new("TextBox")
        optionTextBox.Size = UDim2.new(1, -110, 0, 30)
        optionTextBox.Position = UDim2.new(0, 10, 0, 35)
        optionTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        optionTextBox.BackgroundTransparency = 0
        optionTextBox.BorderSizePixel = 0
        optionTextBox.PlaceholderText = "Enter your text here..."
        optionTextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        optionTextBox.Text = "Custom Text " .. i
        optionTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        optionTextBox.TextSize = 11
        optionTextBox.Font = Enum.Font.Gotham
        optionTextBox.ClearTextOnFocus = false
        optionTextBox.Parent = optionFrame
        
        local optionBoxCorner = Instance.new("UICorner")
        optionBoxCorner.CornerRadius = UDim.new(0, 5)
        optionBoxCorner.Parent = optionTextBox
        
        -- Color picker for custom options
        local customColor = createColorPicker(optionFrame, 1, -40, selectedColor)
        customColor.Position = UDim2.new(1, -45, 0, 38)
        
        local useButton = Instance.new("TextButton")
        useButton.Size = UDim2.new(0, 70, 0, 28)
        useButton.Position = UDim2.new(1, -120, 0, 38)
        useButton.BackgroundColor3 = Color3.fromRGB(75, 150, 75)
        useButton.Text = "USE"
        useButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        useButton.TextSize = 11
        useButton.Font = Enum.Font.GothamBold
        useButton.BorderSizePixel = 0
        useButton.Parent = optionFrame
        
        local useCorner = Instance.new("UICorner")
        useCorner.CornerRadius = UDim.new(0, 5)
        useCorner.Parent = useButton
        
        useButton.MouseButton1Click:Connect(function()
            selectedOption = optionTextBox.Text
            StarterGui:SetCore("SendNotification", {
                Title = "Selected",
                Text = "Selected: Option " .. i .. " - " .. optionTextBox.Text,
                Duration = 1
            })
        end)
        
        textBoxes[i] = optionTextBox
    end
    
    -- Whitelist Status Label
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, -20, 0, 35)
    statusFrame.Position = UDim2.new(0, 10, 1, -90)
    statusFrame.BackgroundColor3 = whitelisted and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
    statusFrame.BackgroundTransparency = 0.3
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = mainFrame
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 5)
    statusCorner.Parent = statusFrame
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 1, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = whitelisted and "✅ WHITELISTED - Full Access" or "❌ NOT WHITELISTED - Options 3-6 Only"
    statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusText.TextSize = 11
    statusText.Font = Enum.Font.GothamBold
    statusText.Parent = statusFrame
    
    -- Execute Button
    local executeButton = Instance.new("TextButton")
    executeButton.Size = UDim2.new(0, 160, 0, 40)
    executeButton.Position = UDim2.new(0.5, -80, 1, -45)
    executeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
    executeButton.Text = "EXECUTE NUKE"
    executeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    executeButton.TextSize = 14
    executeButton.Font = Enum.Font.GothamBold
    executeButton.BorderSizePixel = 0
    executeButton.Parent = mainFrame
    
    local executeCorner = Instance.new("UICorner")
    executeCorner.CornerRadius = UDim.new(0, 8)
    executeCorner.Parent = executeButton
    
    executeButton.MouseButton1Click:Connect(function()
        if selectedOption then
            applyGlitchWithText(selectedOption)
        else
            StarterGui:SetCore("SendNotification", {
                Title = "Synapse v4",
                Text = "Please select an option first!",
                Duration = 2
            })
        end
    end)
    
    mainFrame.Parent = screenGui
end

-- Apply glitch function with custom text (EQUIPS TOOL FIRST)
local function applyGlitchWithText(customText)
    if isNuking then return end
    
    -- Equip the Paint tool
    local tool = equipPaintTool()
    if not tool then
        StarterGui:SetCore("SendNotification", {
            Title = "Synapse v4",
            Text = "Paint tool not found in inventory!",
            Duration = 2
        })
        return
    end
    
    isNuking = true
    
    -- Wait a moment for tool to be equipped
    task.wait(0.3)

    local remote = tool:FindFirstChild("Event", true) or tool:FindFirstChildWhichIsA("RemoteEvent", true)
    if not remote then 
        isNuking = false
        StarterGui:SetCore("SendNotification", {
            Title = "Synapse v4",
            Text = "Remote event not found!",
            Duration = 2
        })
        return
    end

    local rootPos = Character.PrimaryPart.Position
    local mainText = customText
    local otherTexts = {
        "Side Text 1",
        "Side Text 2", 
        "Side Text 3",
        "Side Text 4",
        "Side Text 5"
    }

    -- 1. THE RESET (Kill duplication by changing material state)
    remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, PURE_BLACK, "toxic", "")
    remote:FireServer(brick, Enum.NormalId.Top, rootPos, "material", PURE_BLACK, "plastic", "")
    task.wait(0.25)

    -- 2. THE SPRAY (One side at a time with refresh)
    local sides = {
        Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Top, 
        Enum.NormalId.Bottom, Enum.NormalId.Right, Enum.NormalId.Left
    }

    for _, side in ipairs(sides) do
        local text = (side == Enum.NormalId.Bottom) and mainText or otherTexts[math.random(1, #otherTexts)]
        -- Use selected color
        local color = selectedColor
        
        remote:FireServer(brick, side, rootPos, key, color, "spray", text)
        -- Force server to "re-render" the brick to prevent stacking
        remote:FireServer(brick, Enum.NormalId.Top, rootPos, "material", PURE_BLACK, "neon", "")
        task.wait(0.15) 
    end

    -- 3. FINALIZATION
    remote:FireServer(brick, Enum.NormalId.Top, rootPos, "material", PURE_BLACK, "anchor", "")
    
    StarterGui:SetCore("SendNotification", {
        Title = "Synapse v4",
        Text = "Successfully Nuked! Text: " .. mainText,
        Duration = 3
    })

    task.wait(1)
    isNuking = false
end

-- Toggle GUI function
function toggleGUI()
    guiEnabled = not guiEnabled
    mainFrame.Visible = guiEnabled
    if guiEnabled then
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {BackgroundTransparency = 0}):Play()
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        task.wait(0.2)
        mainFrame.Visible = false
    end
end

-- Create ScreenGui
screenGui = Instance.new("ScreenGui")
screenGui.Name = "SynapseGUI"
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Create GUI elements
createGUI()
createCircleButton()

-- Set default selected text
if isWhitelisted() then
    selectedOption = "https://discord.gg/Udpd9dKZVV"
else
    selectedOption = "Custom Text 3"
end

-- PC Activation (Keybind: Z)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Z and selectedOption then
        applyGlitchWithText(selectedOption)
    end
end)

-- Drag functionality
local dragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)