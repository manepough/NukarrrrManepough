local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local pathsToRemove = {
    {"Map", "Ground", "Road", "Deco"},
    {"Map", "StartArea", "Decorations", "Vegetation"},
    {"Map", "StartArea", "Decorations", "Ground", "Line"},
    {"Map", "StartArea", "Decorations", "Boulders"},
    {"Vehicles", "Claptima", "geo", "body"}
}

for _, path in ipairs(pathsToRemove) do
    local current = workspace
    for _, name in ipairs(path) do
        current = current:FindFirstChild(name)
        if not current then break end
    end
    if current then
        current:Destroy()
    end
end

local INFINITE_DAMAGE = math.huge
local TOGGLE_KEY = Enum.KeyCode.RightShift

local TARGET_KEYWORDS = {"silver", "trophy", "laptop", "gold", "diamond", "table", "phone", "wallet"}

local autoKillDistance = 10
local autoLootDistance = 10
local isAutoKillEnabled = false
local isAutoLootNearbyEnabled = false
local isVictoryRunning = false

-- AUTO WIN PERSISTENT STATE
local AUTO_WIN_SAVE_FILE = "autowin_state.txt"
local isAutoWinEnabled = false
local autoWinThread = nil

local function saveAutoWinState(state)
    local ok, err = pcall(function()
        writefile(AUTO_WIN_SAVE_FILE, state and "true" or "false")
    end)
end

local function loadAutoWinState()
    local ok, result = pcall(function()
        if isfile(AUTO_WIN_SAVE_FILE) then
            local content = readfile(AUTO_WIN_SAVE_FILE)
            return content == "true"
        end
        return false
    end)
    return ok and result or false
end

local FlowClient = ReplicatedStorage:WaitForChild("FlowClient"):WaitForChild("ClientRunner")
local RemoteFunction = FlowClient:WaitForChild("Function")
local RemoteEvent = FlowClient:WaitForChild("Event")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TabbedUtilityGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local NoticeFrame = Instance.new("Frame")
NoticeFrame.Name = "NoticeFrame"
NoticeFrame.Size = UDim2.new(0, 200, 0, 32)
NoticeFrame.Position = UDim2.new(0, 15, 0, 65)
NoticeFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
NoticeFrame.BackgroundTransparency = 0.2
NoticeFrame.Parent = ScreenGui

local NoticeCorner = Instance.new("UICorner")
NoticeCorner.CornerRadius = UDim.new(0, 6)
NoticeCorner.Parent = NoticeFrame

local NoticeText = Instance.new("TextLabel")
NoticeText.Size = UDim2.new(1, 0, 1, 0)
NoticeText.Text = "SCRIPT BY CHAIRESL"
NoticeText.TextColor3 = Color3.fromRGB(255, 215, 0)
NoticeText.TextSize = 14
NoticeText.Font = Enum.Font.SourceSansBold
NoticeText.BackgroundTransparency = 1
NoticeText.Parent = NoticeFrame

task.spawn(function()
    task.wait(4)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    local fadeFrame = TweenService:Create(NoticeFrame, tweenInfo, {BackgroundTransparency = 1})
    local fadeText = TweenService:Create(NoticeText, tweenInfo, {TextTransparency = 1})
    
    fadeFrame:Play()
    fadeText:Play()
    
    fadeFrame.Completed:Connect(function()
        NoticeFrame:Destroy()
    end)
end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 290, 0, 420)
MainFrame.Position = UDim2.new(0.5, -145, 0.4, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local UITheme = Instance.new("UICorner")
UITheme.CornerRadius = UDim.new(0, 8)
UITheme.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "OpenCloseToggle"
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 15, 0, 15)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
ToggleBtn.Text = "UI"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 18
ToggleBtn.Parent = ScreenGui

local ToggleBtnCorner = Instance.new("UICorner")
ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
ToggleBtnCorner.Parent = ToggleBtn

local function toggleUI()
    MainFrame.Visible = not MainFrame.Visible
end

ToggleBtn.MouseButton1Click:Connect(toggleUI)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == TOGGLE_KEY then
        toggleUI()
    end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "RUNAWAYS - CHAIRESL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -28, 0, 3)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 30)
TabBar.Position = UDim2.new(0, 10, 0, 35)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local TabMainBtn = Instance.new("TextButton")
TabMainBtn.Size = UDim2.new(0.31, 0, 1, 0)
TabMainBtn.Position = UDim2.new(0, 0, 0, 0)
TabMainBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
TabMainBtn.Text = "MAIN"
TabMainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TabMainBtn.Font = Enum.Font.SourceSansBold
TabMainBtn.Parent = TabBar

local TabLootBtn = Instance.new("TextButton")
TabLootBtn.Size = UDim2.new(0.31, 0, 1, 0)
TabLootBtn.Position = UDim2.new(0.34, 0, 0, 0)
TabLootBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
TabLootBtn.Text = "Loot Items"
TabLootBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
TabLootBtn.Font = Enum.Font.SourceSansBold
TabLootBtn.Parent = TabBar

local TabNPCBtn = Instance.new("TextButton")
TabNPCBtn.Size = UDim2.new(0.31, 0, 1, 0)
TabNPCBtn.Position = UDim2.new(0.68, 0, 0, 0)
TabNPCBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
TabNPCBtn.Text = "NPCs Target"
TabNPCBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
TabNPCBtn.Font = Enum.Font.SourceSansBold
TabNPCBtn.Parent = TabBar

Instance.new("UICorner", TabMainBtn).CornerRadius = UDim.new(0, 4)
Instance.new("UICorner", TabLootBtn).CornerRadius = UDim.new(0, 4)
Instance.new("UICorner", TabNPCBtn).CornerRadius = UDim.new(0, 4)

local MainContainer = Instance.new("Frame")
MainContainer.Size = UDim2.new(1, -20, 0, 335)
MainContainer.Position = UDim2.new(0, 10, 0, 75)
MainContainer.BackgroundTransparency = 1
MainContainer.Visible = true
MainContainer.Parent = MainFrame

local LootContainer = Instance.new("Frame")
LootContainer.Size = UDim2.new(1, -20, 0, 335)
LootContainer.Position = UDim2.new(0, 10, 0, 75)
LootContainer.BackgroundTransparency = 1
LootContainer.Visible = false
LootContainer.Parent = MainFrame

local NPCContainer = Instance.new("Frame")
NPCContainer.Size = UDim2.new(1, -20, 0, 335)
NPCContainer.Position = UDim2.new(0, 10, 0, 75)
NPCContainer.BackgroundTransparency = 1
NPCContainer.Visible = false
NPCContainer.Parent = MainFrame

local function switchTab(tabIndex)
    MainContainer.Visible = (tabIndex == 1)
    LootContainer.Visible = (tabIndex == 2)
    NPCContainer.Visible = (tabIndex == 3)

    TabMainBtn.BackgroundColor3 = (tabIndex == 1) and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
    TabMainBtn.TextColor3 = (tabIndex == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)

    TabLootBtn.BackgroundColor3 = (tabIndex == 2) and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
    TabLootBtn.TextColor3 = (tabIndex == 2) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)

    TabNPCBtn.BackgroundColor3 = (tabIndex == 3) and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
    TabNPCBtn.TextColor3 = (tabIndex == 3) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
end

TabMainBtn.MouseButton1Click:Connect(function() switchTab(1) end)
TabLootBtn.MouseButton1Click:Connect(function() switchTab(2) end)
TabNPCBtn.MouseButton1Click:Connect(function() switchTab(3) end)

local VictoryBtn = Instance.new("TextButton")
VictoryBtn.Size = UDim2.new(1, 0, 0, 45)
VictoryBtn.Position = UDim2.new(0, 0, 0, 10)
VictoryBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 50)
VictoryBtn.Text = "VICTORY!!!"
VictoryBtn.TextColor3 = Color3.fromRGB(200, 255, 200)
VictoryBtn.Font = Enum.Font.SourceSansBold
VictoryBtn.TextSize = 18
VictoryBtn.Parent = MainContainer
Instance.new("UICorner", VictoryBtn).CornerRadius = UDim.new(0, 6)

local AutoKillToggle = Instance.new("TextButton")
AutoKillToggle.Size = UDim2.new(1, 0, 0, 45)
AutoKillToggle.Position = UDim2.new(0, 0, 0, 65)
AutoKillToggle.BackgroundColor3 = Color3.fromRGB(70, 40, 40)
AutoKillToggle.Text = "Auto Kill Nearby NPCs: OFF"
AutoKillToggle.TextColor3 = Color3.fromRGB(255, 180, 180)
AutoKillToggle.Font = Enum.Font.SourceSansBold
AutoKillToggle.TextSize = 16
AutoKillToggle.Parent = MainContainer
Instance.new("UICorner", AutoKillToggle).CornerRadius = UDim.new(0, 6)

local AutoLootNearbyToggle = Instance.new("TextButton")
AutoLootNearbyToggle.Size = UDim2.new(1, 0, 0, 45)
AutoLootNearbyToggle.Position = UDim2.new(0, 0, 0, 120)
AutoLootNearbyToggle.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
AutoLootNearbyToggle.Text = "Auto Loot Nearby Targets: OFF"
AutoLootNearbyToggle.TextColor3 = Color3.fromRGB(180, 220, 255)
AutoLootNearbyToggle.Font = Enum.Font.SourceSansBold
AutoLootNearbyToggle.TextSize = 16
AutoLootNearbyToggle.Parent = MainContainer
Instance.new("UICorner", AutoLootNearbyToggle).CornerRadius = UDim.new(0, 6)

local AutoWinToggle = Instance.new("TextButton")
AutoWinToggle.Size = UDim2.new(1, 0, 0, 45)
AutoWinToggle.Position = UDim2.new(0, 0, 0, 175)
AutoWinToggle.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
AutoWinToggle.Text = "AUTO WIN (AFK): OFF"
AutoWinToggle.TextColor3 = Color3.fromRGB(180, 255, 180)
AutoWinToggle.Font = Enum.Font.SourceSansBold
AutoWinToggle.TextSize = 16
AutoWinToggle.Parent = MainContainer
Instance.new("UICorner", AutoWinToggle).CornerRadius = UDim.new(0, 6)

local AutoWinStatusLabel = Instance.new("TextLabel")
AutoWinStatusLabel.Size = UDim2.new(1, 0, 0, 20)
AutoWinStatusLabel.Position = UDim2.new(0, 0, 0, 228)
AutoWinStatusLabel.BackgroundTransparency = 1
AutoWinStatusLabel.Text = "Status: Idle"
AutoWinStatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
AutoWinStatusLabel.Font = Enum.Font.SourceSans
AutoWinStatusLabel.TextSize = 13
AutoWinStatusLabel.Parent = MainContainer

AutoKillToggle.MouseButton1Click:Connect(function()
    isAutoKillEnabled = not isAutoKillEnabled
    if isAutoKillEnabled then
        AutoKillToggle.Text = "Auto Kill Nearby NPCs: ON"
        AutoKillToggle.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
        AutoKillToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        AutoKillToggle.Text = "Auto Kill Nearby NPCs: OFF"
        AutoKillToggle.BackgroundColor3 = Color3.fromRGB(70, 40, 40)
        AutoKillToggle.TextColor3 = Color3.fromRGB(255, 180, 180)
    end
end)

AutoLootNearbyToggle.MouseButton1Click:Connect(function()
    isAutoLootNearbyEnabled = not isAutoLootNearbyEnabled
    if isAutoLootNearbyEnabled then
        AutoLootNearbyToggle.Text = "Auto Loot Nearby Targets: ON"
        AutoLootNearbyToggle.BackgroundColor3 = Color3.fromRGB(40, 110, 180)
        AutoLootNearbyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        AutoLootNearbyToggle.Text = "Auto Loot Nearby Targets: OFF"
        AutoLootNearbyToggle.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
        AutoLootNearbyToggle.TextColor3 = Color3.fromRGB(180, 220, 255)
    end
end)

local function runVictoryScript()
    if isVictoryRunning then return end
    isVictoryRunning = true
    VictoryBtn.Text = "RUNNING VICTORY..."
    VictoryBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 40)

    task.spawn(function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local OFFSET_FAR = CFrame.new(0, 5, 20)

        local noclipConnection
        noclipConnection = RunService.Stepped:Connect(function()
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)

        local function safeTeleport(targetCFrame)
            hrp.Anchored = true
            character:PivotTo(targetCFrame)
            task.wait(1.5)
            hrp.Anchored = false
        end

        local function triggerFirePrompt(prompt)
            if not prompt or not prompt:IsA("ProximityPrompt") then return end
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = 99999
            prompt.HoldDuration = 0

            if typeof(fireproximityprompt) == "function" then
                fireproximityprompt(prompt)
            end
        end

        safeTeleport(CFrame.new(1780, 1940, 83615) * CFrame.new(0, 5, 0))
        task.wait(0.5)

        local map = workspace:WaitForChild("Map", 10)
        local customsFinal = map and map:WaitForChild("Buildings", 10):WaitForChild("CustomsFinal", 10)

        if customsFinal then
            local targetCFrame = customsFinal:IsA("Model") and customsFinal:GetPivot() or customsFinal.CFrame
            safeTeleport(targetCFrame * OFFSET_FAR)
        end

        task.wait(0.5)

        local commandDoor = customsFinal 
            and customsFinal:WaitForChild("CustomsBuilding", 10)
            and customsFinal.CustomsBuilding:WaitForChild("FinalDoor", 10)
            and customsFinal.CustomsBuilding.FinalDoor:WaitForChild("Command", 10)

        if commandDoor then
            local doorCFrame = commandDoor:IsA("Model") and commandDoor:GetPivot() or commandDoor.CFrame
            safeTeleport(doorCFrame * CFrame.new(0, 0, 5))

            local commandButton = commandDoor:WaitForChild("CommandButton", 5)
            local promptFolder = commandButton and commandButton:WaitForChild("Prompt", 5)
            local targetPrompt = promptFolder and promptFolder:WaitForChild("ProximityPrompt", 5)

            if not targetPrompt and commandButton then
                targetPrompt = commandButton:FindFirstChildWhichIsA("ProximityPrompt", true)
            end

            if targetPrompt then
                task.spawn(function()
                    while isVictoryRunning do
                        triggerFirePrompt(targetPrompt)
                        task.wait(0.1)
                    end
                end)
            end
        end

        task.wait(0.5)

        local flowEvent = ReplicatedStorage:WaitForChild("FlowClient", 10)
            and ReplicatedStorage.FlowClient:WaitForChild("ClientRunner", 10)
            and ReplicatedStorage.FlowClient.ClientRunner:WaitForChild("Event", 10)

        if flowEvent then
            task.spawn(function()
                while isVictoryRunning do
                    flowEvent:FireServer("GameManager", "Replay")
                    task.wait(0.1)
                end
            end)
        end

        task.wait(130)

        local mapCurrent = workspace:FindFirstChild("Map")
        local targetCF = mapCurrent and mapCurrent:FindFirstChild("Buildings") and mapCurrent.Buildings:FindFirstChild("CustomsFinal")

        if targetCF then
            local targetCFrame = targetCF:IsA("Model") and targetCF:GetPivot() or targetCF.CFrame
            safeTeleport(targetCFrame * OFFSET_FAR)
        end

        if noclipConnection then
            noclipConnection:Disconnect()
        end
        isVictoryRunning = false
        VictoryBtn.Text = "VICTORY!!!"
        VictoryBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 50)
    end)
end

-- AUTO WIN CORE FUNCTIONS
local function killAllNPCs()
    local npcFolder = workspace:FindFirstChild("NPCs")
    if npcFolder then
        for _, npc in ipairs(npcFolder:GetChildren()) do
            local humanoid = npc:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                hitNPC(humanoid)
                task.wait(0.01)
            end
        end
    end
end

local function lootAllItems()
    local lootFolder = workspace:FindFirstChild("Loot")
    if lootFolder then
        for _, item in ipairs(lootFolder:GetChildren()) do
            lootSingleItem(item)
            task.wait(0.01)
        end
    end
end

local function getPawnCounterCFrame()
    local pawnShop = workspace:FindFirstChild("Map")
        and workspace.Map:FindFirstChild("Buildings")
        and workspace.Map.Buildings:FindFirstChild("PawnShop")
        and workspace.Map.Buildings.PawnShop:FindFirstChild("Templates")
        and workspace.Map.Buildings.PawnShop.Templates:FindFirstChild("Template1")
        and workspace.Map.Buildings.PawnShop.Templates.Template1:FindFirstChild("PawnCounter")

    if pawnShop then
        local balance = pawnShop:FindFirstChild("Balance")
        if balance and balance:IsA("BasePart") then
            return balance.CFrame * CFrame.new(0, 3, 3)
        end
        local border = pawnShop:FindFirstChildWhichIsA("BasePart", true)
        if border then
            return border.CFrame * CFrame.new(0, 3, 3)
        end
    end
    return nil
end

local function getCallBellPrompt()
    local ok, prompt = pcall(function()
        return workspace.Map.Buildings.PawnShop.Templates.Template1.PawnCounter.CallBell.Attachment.ProximityPrompt
    end)
    return ok and prompt or nil
end

local function dropItemOnCounter(item)
    -- Try dropping via FlowClient RemoteEvent (same pattern as Loot)
    pcall(function()
        local target = item:FindFirstChild("Handle") or item
        RemoteEvent:FireServer("Inventory", "Drop", target)
    end)
    pcall(function()
        local target = item:FindFirstChild("Handle") or item
        RemoteFunction:InvokeServer("Inventory", "Drop", target)
    end)
end

local function fireCallBell()
    local prompt = getCallBellPrompt()
    if prompt then
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 99999
        prompt.HoldDuration = 0
        if typeof(fireproximityprompt) == "function" then
            fireproximityprompt(prompt)
        end
    end
end

local function teleportToCounter()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local cf = getPawnCounterCFrame()
    if cf then
        hrp.Anchored = true
        character:PivotTo(cf)
        task.wait(1)
        hrp.Anchored = false
    end
end

local function dropAllAtSell()
    -- Step 1: Teleport to pawn counter
    teleportToCounter()
    task.wait(0.5)

    -- Step 2: Drop all inventory items onto counter
    -- Try FlowClient pattern first (same remote the game uses everywhere)
    pcall(function()
        RemoteEvent:FireServer("Inventory", "DropAll")
    end)
    pcall(function()
        RemoteFunction:InvokeServer("Inventory", "DropAll")
    end)

    -- Also try dropping each loot item individually
    local lootFolder = workspace:FindFirstChild("Loot")
    if lootFolder then
        for _, item in ipairs(lootFolder:GetChildren()) do
            dropItemOnCounter(item)
            task.wait(0.05)
        end
    end

    task.wait(1)

    -- Step 3: Ring the bell to sell
    for i = 1, 5 do
        fireCallBell()
        task.wait(0.2)
    end

    task.wait(1)
end

local function setAutoWinUI(enabled)
    if enabled then
        AutoWinToggle.Text = "AUTO WIN (AFK): ON"
        AutoWinToggle.BackgroundColor3 = Color3.fromRGB(30, 160, 50)
        AutoWinToggle.TextColor3 = Color3.fromRGB(220, 255, 220)
    else
        AutoWinToggle.Text = "AUTO WIN (AFK): OFF"
        AutoWinToggle.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
        AutoWinToggle.TextColor3 = Color3.fromRGB(180, 255, 180)
        AutoWinStatusLabel.Text = "Status: Idle"
    end
end

local function startAutoWinLoop()
    if autoWinThread then
        task.cancel(autoWinThread)
        autoWinThread = nil
    end

    autoWinThread = task.spawn(function()
        while isAutoWinEnabled do
            -- Step 1: Trigger Victory in background (teleports to end, fires prompts, waits 130s then goes to gate)
            AutoWinStatusLabel.Text = "Status: Starting Victory..."
            isVictoryRunning = false
            task.spawn(runVictoryScript)
            task.wait(3) -- give victory script time to teleport to end first

            -- Step 2: During the 130s victory window, keep looping kill/loot/sell
            local loopStart = tick()
            local loopDuration = 118 -- stop loop a bit before victory ends (130s)

            while isAutoWinEnabled and (tick() - loopStart) < loopDuration do
                -- Kill NPCs
                AutoWinStatusLabel.Text = "Status: Killing NPCs..."
                killAllNPCs()
                task.wait(1)

                -- Loot all
                AutoWinStatusLabel.Text = "Status: Looting items..."
                lootAllItems()
                task.wait(1)

                -- Go to PawnShop and sell
                AutoWinStatusLabel.Text = "Status: Going to sell..."
                teleportToCounter()
                task.wait(0.5)

                AutoWinStatusLabel.Text = "Status: Dropping loot..."
                pcall(function() RemoteEvent:FireServer("Inventory", "DropAll") end)
                pcall(function() RemoteFunction:InvokeServer("Inventory", "DropAll") end)
                local lootFolder = workspace:FindFirstChild("Loot")
                if lootFolder then
                    for _, item in ipairs(lootFolder:GetChildren()) do
                        dropItemOnCounter(item)
                        task.wait(0.05)
                    end
                end
                task.wait(0.5)

                AutoWinStatusLabel.Text = "Status: Selling loot..."
                for i = 1, 5 do
                    fireCallBell()
                    task.wait(0.2)
                end
                task.wait(1)
            end

            -- Step 3: Time is up — go back to border near the end gate
            -- Victory script handles going to the gate at 130s naturally, just wait for it
            AutoWinStatusLabel.Text = "Status: Waiting for gate..."
            local gateWait = 0
            repeat
                task.wait(1)
                gateWait = gateWait + 1
            until not isVictoryRunning or gateWait >= 20

            AutoWinStatusLabel.Text = "Status: Round done. Restarting..."
            task.wait(3)
        end
    end)
end

local function stopAutoWinLoop()
    if autoWinThread then
        task.cancel(autoWinThread)
        autoWinThread = nil
    end
end

AutoWinToggle.MouseButton1Click:Connect(function()
    isAutoWinEnabled = not isAutoWinEnabled
    saveAutoWinState(isAutoWinEnabled)
    setAutoWinUI(isAutoWinEnabled)

    if isAutoWinEnabled then
        startAutoWinLoop()
    else
        stopAutoWinLoop()
    end
end)

VictoryBtn.MouseButton1Click:Connect(runVictoryScript)

local function isTargetItem(itemName)
    local lowerName = string.lower(itemName)
    for _, kw in ipairs(TARGET_KEYWORDS) do
        if string.find(lowerName, kw) then
            return true
        end
    end
    return false
end

local function highlightItem(item)
    if not item:FindFirstChild("ValuableHighlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "ValuableHighlight"
        hl.FillColor = Color3.fromRGB(255, 215, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.3
        hl.OutlineTransparency = 0
        hl.Adornee = item
        hl.Parent = item
    end
end

local function getItemPosition(item)
    if item:IsA("BasePart") then
        return item.Position
    elseif item:IsA("Model") then
        local handle = item:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then
            return handle.Position
        elseif item.PrimaryPart then
            return item.PrimaryPart.Position
        else
            local part = item:FindFirstChildWhichIsA("BasePart", true)
            if part then return part.Position end
        end
    end
    return nil
end

local function lootSingleItem(item)
    if item and item.Parent then
        local target = item:FindFirstChild("Handle") or item
        RemoteFunction:InvokeServer("Loot", "LootEquip", target)
    end
end

local function hitNPC(humanoid)
    if humanoid and humanoid.Parent and humanoid.Health > 0 then
        RemoteEvent:FireServer("NPCs", "Damage", humanoid, INFINITE_DAMAGE)
    end
end

local LootScroll = Instance.new("ScrollingFrame")
LootScroll.Size = UDim2.new(1, 0, 0, 240)
LootScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
LootScroll.ScrollBarThickness = 6
LootScroll.Parent = LootContainer

local LootLayout = Instance.new("UIListLayout", LootScroll)
LootLayout.Padding = UDim.new(0, 5)
LootLayout.SortOrder = Enum.SortOrder.LayoutOrder
LootLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    LootScroll.CanvasSize = UDim2.new(0, 0, 0, LootLayout.AbsoluteContentSize.Y + 10)
end)

local function refreshLootList()
    for _, child in ipairs(LootScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local lootFolder = workspace:FindFirstChild("Loot")
    if not lootFolder then return end

    local groupedItems = {}
    for _, item in ipairs(lootFolder:GetChildren()) do
        if isTargetItem(item.Name) then
            highlightItem(item)
        end

        if not groupedItems[item.Name] then
            groupedItems[item.Name] = {}
        end
        table.insert(groupedItems[item.Name], item)
    end

    local sortedList = {}
    for itemName, itemList in pairs(groupedItems) do
        table.insert(sortedList, {
            name = itemName,
            list = itemList,
            isPriority = isTargetItem(itemName)
        })
    end

    table.sort(sortedList, function(a, b)
        if a.isPriority ~= b.isPriority then
            return a.isPriority
        end
        return a.name < b.name
    end)

    for index, data in ipairs(sortedList) do
        local ItemBtn = Instance.new("TextButton")
        ItemBtn.Size = UDim2.new(1, -10, 0, 30)
        ItemBtn.LayoutOrder = index

        if data.isPriority then
            ItemBtn.BackgroundColor3 = Color3.fromRGB(180, 130, 20)
            ItemBtn.Text = string.format("[!] %s (x%d)", data.name, #data.list)
            ItemBtn.TextColor3 = Color3.fromRGB(255, 255, 200)
        else
            ItemBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            ItemBtn.Text = string.format("%s (x%d)", data.name, #data.list)
            ItemBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
        end

        ItemBtn.Font = Enum.Font.SourceSansBold
        ItemBtn.Parent = LootScroll
        Instance.new("UICorner", ItemBtn).CornerRadius = UDim.new(0, 4)

        ItemBtn.MouseButton1Click:Connect(function()
            ItemBtn.Text = "Looting..."
            ItemBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 50)
            
            for _, item in ipairs(data.list) do
                lootSingleItem(item)
                task.wait(0.02)
            end
            
            refreshLootList()
        end)
    end
end

local RefreshLootBtn = Instance.new("TextButton")
RefreshLootBtn.Size = UDim2.new(0.48, 0, 0, 35)
RefreshLootBtn.Position = UDim2.new(0, 0, 1, -35)
RefreshLootBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
RefreshLootBtn.Text = "Refresh"
RefreshLootBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshLootBtn.Font = Enum.Font.SourceSansBold
RefreshLootBtn.Parent = LootContainer
Instance.new("UICorner", RefreshLootBtn).CornerRadius = UDim.new(0, 4)
RefreshLootBtn.MouseButton1Click:Connect(refreshLootList)

local LootAllBtn = Instance.new("TextButton")
LootAllBtn.Size = UDim2.new(0.48, 0, 0, 35)
LootAllBtn.Position = UDim2.new(0.52, 0, 1, -35)
LootAllBtn.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
LootAllBtn.Text = "LOOT ALL"
LootAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LootAllBtn.Font = Enum.Font.SourceSansBold
LootAllBtn.Parent = LootContainer
Instance.new("UICorner", LootAllBtn).CornerRadius = UDim.new(0, 4)

LootAllBtn.MouseButton1Click:Connect(function()
    local lootFolder = workspace:FindFirstChild("Loot")
    if lootFolder then
        for _, item in ipairs(lootFolder:GetChildren()) do
            lootSingleItem(item)
            task.wait(0.01)
        end
        refreshLootList()
    end
end)

local NPCScroll = Instance.new("ScrollingFrame")
NPCScroll.Size = UDim2.new(1, 0, 0, 240)
NPCScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
NPCScroll.ScrollBarThickness = 6
NPCScroll.Parent = NPCContainer

local NPCLayout = Instance.new("UIListLayout", NPCScroll)
NPCLayout.Padding = UDim.new(0, 5)
NPCLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    NPCScroll.CanvasSize = UDim2.new(0, 0, 0, NPCLayout.AbsoluteContentSize.Y + 10)
end)

local function refreshNPCList()
    for _, child in ipairs(NPCScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local npcFolder = workspace:FindFirstChild("NPCs")
    if not npcFolder then return end

    local groupedNPCs = {}
    for _, npc in ipairs(npcFolder:GetChildren()) do
        local humanoid = npc:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            if not groupedNPCs[npc.Name] then
                groupedNPCs[npc.Name] = {}
            end
            table.insert(groupedNPCs[npc.Name], humanoid)
        end
    end

    for npcName, humanoidList in pairs(groupedNPCs) do
        local NPCBtn = Instance.new("TextButton")
        NPCBtn.Size = UDim2.new(1, -10, 0, 30)
        NPCBtn.BackgroundColor3 = Color3.fromRGB(80, 45, 45)
        NPCBtn.Text = string.format("Kill %s (x%d)", npcName, #humanoidList)
        NPCBtn.TextColor3 = Color3.fromRGB(255, 220, 220)
        NPCBtn.Font = Enum.Font.SourceSansBold
        NPCBtn.Parent = NPCScroll
        Instance.new("UICorner", NPCBtn).CornerRadius = UDim.new(0, 4)

        NPCBtn.MouseButton1Click:Connect(function()
            for _, humanoid in ipairs(humanoidList) do
                hitNPC(humanoid)
                task.wait(0.01)
            end
            refreshNPCList()
        end)
    end
end

local RefreshNPCBtn = Instance.new("TextButton")
RefreshNPCBtn.Size = UDim2.new(0.48, 0, 0, 35)
RefreshNPCBtn.Position = UDim2.new(0, 0, 1, -35)
RefreshNPCBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
RefreshNPCBtn.Text = "Refresh"
RefreshNPCBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshNPCBtn.Font = Enum.Font.SourceSansBold
RefreshNPCBtn.Parent = NPCContainer
Instance.new("UICorner", RefreshNPCBtn).CornerRadius = UDim.new(0, 4)
RefreshNPCBtn.MouseButton1Click:Connect(refreshNPCList)

local AttackAllBtn = Instance.new("TextButton")
AttackAllBtn.Size = UDim2.new(0.48, 0, 0, 35)
AttackAllBtn.Position = UDim2.new(0.52, 0, 1, -35)
AttackAllBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
AttackAllBtn.Text = "KILL ALL"
AttackAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AttackAllBtn.Font = Enum.Font.SourceSansBold
AttackAllBtn.Parent = NPCContainer
Instance.new("UICorner", AttackAllBtn).CornerRadius = UDim.new(0, 4)

AttackAllBtn.MouseButton1Click:Connect(function()
    local npcFolder = workspace:FindFirstChild("NPCs")
    if npcFolder then
        for _, npc in ipairs(npcFolder:GetChildren()) do
            local humanoid = npc:FindFirstChildOfClass("Humanoid")
            hitNPC(humanoid)
            task.wait(0.01)
        end
        refreshNPCList()
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        if isAutoKillEnabled and rootPart then
            local myPos = rootPart.Position
            local npcFolder = workspace:FindFirstChild("NPCs")
            
            if npcFolder then
                for _, npc in ipairs(npcFolder:GetChildren()) do
                    local humanoid = npc:FindFirstChildOfClass("Humanoid")
                    local npcRoot = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChild("UpperTorso")
                    
                    if humanoid and humanoid.Health > 0 and npcRoot then
                        local distance = (npcRoot.Position - myPos).Magnitude
                        if distance <= autoKillDistance then
                            hitNPC(humanoid)
                        end
                    end
                end
            end
        end

        if isAutoLootNearbyEnabled and rootPart then
            local myPos = rootPart.Position
            local lootFolder = workspace:FindFirstChild("Loot")
            
            if lootFolder then
                for _, item in ipairs(lootFolder:GetChildren()) do
                    if isTargetItem(item.Name) then
                        local itemPos = getItemPosition(item)
                        if itemPos then
                            local distance = (itemPos - myPos).Magnitude
                            if distance <= autoLootDistance then
                                lootSingleItem(item)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- AUTO-LOAD PERSISTENT AUTO WIN STATE ON SCRIPT START
isAutoWinEnabled = loadAutoWinState()
if isAutoWinEnabled then
    setAutoWinUI(true)
    startAutoWinLoop()
end

refreshLootList()
refreshNPCList()