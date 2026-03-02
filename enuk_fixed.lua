
-- make the loadstring work
local function safeLoad(url)
    local success, code = pcall(game.HttpGet, game, url)
    if not success then warn("Failed to fetch code: " .. tostring(code)) return end
    local executable, compileError = loadstring(code)
    if executable then
        local runSuccess, runError = pcall(executable)
        if not runSuccess then warn("Code ran but crashed: " .. tostring(runError)) end
    else
        warn("Syntax error in loaded code: " .. tostring(compileError))
    end
end



-- whitelist system
local whitelistedIDs = {
    [10429099415] = "FLAMEFAML",
    [9693065023] = "kupal_isme8",
}

local player = game:GetService("Players").LocalPlayer

if not whitelistedIDs[player.UserId] then
    player:Kick("Unauthorized User: You are not on the whitelist.")
    return 
end

print("Whitelist passed! Loading Nuke...")

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Workspace Setup
if makefolder then pcall(function() makefolder("WindConfigs") end) end

-- UI Root
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "WindUltimate_GodMode"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- --- FLOATING MOBILE TOGGLE ---
local MobileToggle = Instance.new("TextButton", ScreenGui)
MobileToggle.Size = UDim2.new(0, 45, 0, 45)
MobileToggle.Position = UDim2.new(0.05, 0, 0.1, 0)
MobileToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MobileToggle.Text = "MANE"
MobileToggle.TextColor3 = Color3.fromRGB(0, 255, 150)
MobileToggle.Font = Enum.Font.GothamBold
MobileToggle.TextSize = 14
Instance.new("UICorner", MobileToggle).CornerRadius = UDim.new(1, 0)

-- --- MAIN FRAME ---
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 340, 0, 520)
Main.Position = UDim2.new(0.5, -170, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- [[ Custom Drag & Tap Logic for MobileToggle ]] --
local toggleDrag, hasMoved = false, false
local toggleStartPos, toggleStartInput

MobileToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleDrag = true
        hasMoved = false
        toggleStartPos = MobileToggle.Position
        toggleStartInput = input.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if toggleDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - toggleStartInput
        if delta.Magnitude > 3 then 
            hasMoved = true
            MobileToggle.Position = UDim2.new(
                toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X,
                toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y
            )
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if toggleDrag then
            toggleDrag = false
            if not hasMoved then Main.Visible = not Main.Visible end
        end
    end
end)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -15, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "MANE | SERVER NUKE & AURA"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -55)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 2
Container.CanvasSize = UDim2.new(0, 0, 0, 1800)

local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 6)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- [[ COLOR PICKER CORE ]] --
local PickerOverlay = Instance.new("Frame", ScreenGui)
PickerOverlay.Size = UDim2.new(1, 0, 1, 0)
PickerOverlay.BackgroundColor3 = Color3.new(0,0,0)
PickerOverlay.BackgroundTransparency = 0.5
PickerOverlay.Visible = false
PickerOverlay.Active = true
local PickerBox = Instance.new("Frame", PickerOverlay)
PickerBox.Size = UDim2.new(0, 220, 0, 280)
PickerBox.Position = UDim2.new(0.5, -110, 0.5, -140)
PickerBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Instance.new("UICorner", PickerBox).CornerRadius = UDim.new(0, 10)
local WheelImage = Instance.new("ImageLabel", PickerBox)
WheelImage.Name = "Wheel"
WheelImage.Size = UDim2.new(0, 160, 0, 160)
WheelImage.Position = UDim2.new(0.5, -80, 0, 20)
WheelImage.Image = "rbxassetid://6020299385"
WheelImage.BackgroundTransparency = 1
local SelectorDot = Instance.new("Frame", PickerBox)
SelectorDot.Size = UDim2.new(0, 18, 0, 18)
SelectorDot.AnchorPoint = Vector2.new(0.5, 0.5)
SelectorDot.BackgroundColor3 = Color3.new(1,1,1)
SelectorDot.BackgroundTransparency = 0.15
SelectorDot.BorderSizePixel = 3
SelectorDot.BorderColor3 = Color3.new(0.1,0.1,0.1)
Instance.new("UICorner", SelectorDot).CornerRadius = UDim.new(1,0)
SelectorDot.Visible = false
local RGBDisplay = Instance.new("TextLabel", PickerBox)
RGBDisplay.Size = UDim2.new(1, 0, 0, 20)
RGBDisplay.Position = UDim2.new(0, 0, 0, 190)
RGBDisplay.Text = "255, 255, 255"
RGBDisplay.TextColor3 = Color3.new(1,1,1)
RGBDisplay.Font = Enum.Font.GothamBold
RGBDisplay.TextSize = 14
RGBDisplay.BackgroundTransparency = 1
local ClosePickerBtn = Instance.new("TextButton", PickerBox)
ClosePickerBtn.Size = UDim2.new(0.8, 0, 0, 35)
ClosePickerBtn.Position = UDim2.new(0.1, 0, 1, -45)
ClosePickerBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
ClosePickerBtn.Text = "CONFIRM"
ClosePickerBtn.Font = Enum.Font.GothamBold
ClosePickerBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", ClosePickerBtn)

local currentTargetButton, currentHue, currentSat = nil, 0, 0
local WHEEL_RADIUS = 80

local function updateColorMath(input)
    local center = WheelImage.AbsolutePosition + (WheelImage.AbsoluteSize / 2)
    local delta = Vector2.new(input.Position.X, input.Position.Y) - center
    local dist = delta.Magnitude
    local sat = math.clamp(dist / WHEEL_RADIUS, 0, 1)
    local rawAngle = math.atan2(delta.Y, delta.X)
    local hue = (rawAngle + math.pi / 2) / (math.pi * 2)
    if hue < 0 then hue = hue + 1 end
    hue = hue % 1
    local c = Color3.fromHSV(hue, sat, 1)
    if currentTargetButton then
        currentTargetButton.BackgroundColor3 = c
        RGBDisplay.Text = string.format("%d, %d, %d", math.round(c.R*255), math.round(c.G*255), math.round(c.B*255))
    end
    if dist > 2 then
        SelectorDot.Position = UDim2.new(0.5, (delta.Unit * (sat * WHEEL_RADIUS)).X, 0.5, (delta.Unit * (sat * WHEEL_RADIUS)).Y)
        SelectorDot.Visible = true
    else
        SelectorDot.Visible = false
    end
    currentHue, currentSat = hue, sat
end

local mConn, eConn
WheelImage.InputBegan:Connect(function(input)
    if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then return end
    updateColorMath(input)
    if mConn then mConn:Disconnect() end
    if eConn then eConn:Disconnect() end
    mConn = UserInputService.InputChanged:Connect(function(changed)
        if changed.UserInputType == Enum.UserInputType.MouseMovement or changed.UserInputType == Enum.UserInputType.Touch then
            updateColorMath(changed)
        end
    end)
    eConn = UserInputService.InputEnded:Connect(function(ended)
        if ended.UserInputType == Enum.UserInputType.MouseButton1 or ended.UserInputType == Enum.UserInputType.Touch then
            if mConn then mConn:Disconnect() end
            if eConn then eConn:Disconnect() end
        end
    end)
end)

ClosePickerBtn.MouseButton1Click:Connect(function() PickerOverlay.Visible = false end)

local function openPicker(btn)
    currentTargetButton = btn
    local c = btn.BackgroundColor3
    RGBDisplay.Text = string.format("%d, %d, %d", math.round(c.R*255), math.round(c.G*255), math.round(c.B*255))
    local h, s, _ = Color3.toHSV(c)
    currentHue = h
    currentSat = s
    local angleRad = (h * math.pi * 2) - math.pi / 2
    local offset = Vector2.new(math.cos(angleRad), math.sin(angleRad)) * s * WHEEL_RADIUS
    SelectorDot.Position = UDim2.new(0.5, offset.X, 0.5, offset.Y)
    SelectorDot.Visible = (s > 0.05)
    PickerOverlay.Visible = true
end

-- --- UI CONTENT CREATION ---
local faces = {"Front", "Back", "Top", "Bottom", "Right", "Left"}
local faceData = {}

for _, name in ipairs(faces) do
    local row = Instance.new("Frame", Container)
    row.Size = UDim2.new(0.95, 0, 0, 35)
    row.BackgroundTransparency = 1
    local txt = Instance.new("TextBox", row)
    txt.Size = UDim2.new(0.75, 0, 0, 30)
    txt.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    txt.Text = "GG'S"
    txt.PlaceholderText = name .. " Text"
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 12
    Instance.new("UICorner", txt)
    local clrBtn = Instance.new("TextButton", row)
    clrBtn.Size = UDim2.new(0.2, 0, 0, 30)
    clrBtn.Position = UDim2.new(0.8, 0, 0, 0)
    clrBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    clrBtn.Text = ""
    Instance.new("UICorner", clrBtn)
    clrBtn.MouseButton1Click:Connect(function() openPicker(clrBtn) end)
    faceData[name] = {txtBox = txt, clrBtn = clrBtn}
end

local function createBtn(text, color)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(0.95, 0, 0, 35)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn)
    return btn
end

local MaterialBtn = createBtn("Material: PLASTIC", Color3.fromRGB(120, 0, 200))
local AnchorBtn = createBtn("Auto-Anchor: ON", Color3.fromRGB(0, 120, 200))
local SpamBtn = createBtn("Spam Mode: OFF", Color3.fromRGB(40, 40, 45))
local ToxicBtn = createBtn("LOAD TOXIC PRESETS", Color3.fromRGB(150, 0, 0))
local FixBtn = createBtn("FIX / CLEAN BRICK", Color3.fromRGB(150, 150, 160))
local RunBtn = createBtn("EXECUTE SEQUENCE", Color3.fromRGB(0, 150, 100))
RunBtn.Size = UDim2.new(0.95, 0, 0, 45)

local DelCubesBtn = createBtn("NUKE CUBES", Color3.fromRGB(200, 50, 0))
local DestroyerBtn = createBtn("BKIT DESTROYER (CAREFUL)", Color3.fromRGB(220, 20, 20))
DestroyerBtn.Size = UDim2.new(0.95, 0, 0, 50)
DestroyerBtn.TextColor3 = Color3.fromRGB(255, 255, 200)
DestroyerBtn.Font = Enum.Font.GothamBlack
DestroyerBtn.TextSize = 18

-- [[ DELETE AURA SETUP ]] --
local daurarange = 35
local daura = false
local dauras = false
local ors = true

local daurapart = Instance.new("Part")
daurapart.Shape = Enum.PartType.Ball
daurapart.Anchored = true
daurapart.CanCollide = false
daurapart.CastShadow = false
daurapart.CanQuery = false
daurapart.Color = Color3.fromRGB(255, 0, 0)
daurapart.Transparency = 1
daurapart.Size = Vector3.new(daurarange, daurarange, daurarange)
daurapart.Parent = workspace

local filter = OverlapParams.new()
filter.FilterType = Enum.RaycastFilterType.Include
filter.MaxParts = 8
pcall(function() filter:AddToFilter(workspace:WaitForChild("Bricks", 3)) end)

-- [[ AURA SLIDER UI ]] --
local AuraHeader = Instance.new("TextLabel", Container)
AuraHeader.Size = UDim2.new(0.95, 0, 0, 30)
AuraHeader.Text = "--- DELETE AURA ---"
AuraHeader.TextColor3 = Color3.new(0.6, 0.6, 0.6)
AuraHeader.Font = Enum.Font.GothamBold
AuraHeader.TextSize = 14
AuraHeader.BackgroundTransparency = 1

local SliderContainer = Instance.new("Frame", Container)
SliderContainer.Size = UDim2.new(0.95, 0, 0, 40)
SliderContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Instance.new("UICorner", SliderContainer)

local SliderLabel = Instance.new("TextLabel", SliderContainer)
SliderLabel.Size = UDim2.new(0.4, 0, 1, 0)
SliderLabel.Text = "Range: 35"
SliderLabel.TextColor3 = Color3.new(1,1,1)
SliderLabel.Font = Enum.Font.GothamBold
SliderLabel.TextSize = 12
SliderLabel.BackgroundTransparency = 1

local SliderBg = Instance.new("TextButton", SliderContainer)
SliderBg.Size = UDim2.new(0.55, 0, 0, 12)
SliderBg.Position = UDim2.new(0.4, 0, 0.5, -6)
SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
SliderBg.Text = ""
SliderBg.AutoButtonColor = false
Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

local SliderFill = Instance.new("Frame", SliderBg)
SliderFill.Size = UDim2.new(0.35, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

local draggingSlider = false
SliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
        daurapart.Transparency = 0.5
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if draggingSlider then
            draggingSlider = false
            if not daura and not dauras then daurapart.Transparency = 1 end
        end
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relativeX = input.Position.X - SliderBg.AbsolutePosition.X
        local percentage = math.clamp(relativeX / SliderBg.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        daurarange = math.floor(5 + ((100 - 5) * percentage))
        SliderLabel.Text = "Range: " .. daurarange
        daurapart.Size = Vector3.new(daurarange, daurarange, daurarange)
        daurapart.Position = LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position or Vector3.zero
    end
end)

local AuraToggleBtn = createBtn("Delete Aura: OFF", Color3.fromRGB(150, 0, 150))
AuraToggleBtn.MouseButton1Click:Connect(function()
    daura = not daura
    AuraToggleBtn.Text = "Delete Aura: " .. (daura and "ON" or "OFF")
    daurapart.Transparency = (daura or dauras) and 0.5 or 1
end)

local AuraSolaraBtn = createBtn("Delete Aura (Solara): OFF", Color3.fromRGB(100, 0, 150))
AuraSolaraBtn.MouseButton1Click:Connect(function()
    dauras = not dauras
    AuraSolaraBtn.Text = "Delete Aura (Solara): " .. (dauras and "ON" or "OFF")
    daurapart.Transparency = (daura or dauras) and 0.5 or 1
end)

-- SLOT SYSTEM
local SlotBox = Instance.new("TextBox", Container)
SlotBox.Size = UDim2.new(0.95, 0, 0, 30)
SlotBox.PlaceholderText = "Type Config Name..."
SlotBox.BackgroundColor3 = Color3.fromRGB(30,30,35)
SlotBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", SlotBox)

local SaveBtn = createBtn("SAVE NEW SLOT", Color3.fromRGB(40, 100, 50))
local DeleteSlotBtn = createBtn("DELETE SELECTED SLOT", Color3.fromRGB(150, 40, 40))
local RevealBtn = createBtn("REVEAL ALL SLOTS", Color3.fromRGB(0, 100, 150))
local SlotListFrame = Instance.new("Frame", Container)
SlotListFrame.Size = UDim2.new(0.95, 0, 0, 0)
SlotListFrame.AutomaticSize = Enum.AutomaticSize.Y
SlotListFrame.BackgroundTransparency = 1
Instance.new("UIListLayout", SlotListFrame).Padding = UDim.new(0, 4)

local function updateSlots()
    for _, v in pairs(SlotListFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    if not isfolder or not isfolder("WindConfigs") then return end
    for _, file in pairs(listfiles("WindConfigs")) do
        local name = file:match("WindConfigs/(.+)%.json") or file:match("WindConfigs\\(.+)%.json")
        if name then
            local b = createBtn("LOAD: "..name, Color3.fromRGB(40, 40, 45))
            b.Parent = SlotListFrame
            b.MouseButton1Click:Connect(function()
                local ok, result = pcall(function() return HttpService:JSONDecode(readfile(file)) end)
                if not ok then warn("[WIND GUI] Failed to load slot: "..tostring(result)) return end
                local data = result
                SlotBox.Text = name
                if data.faces then
                    for n, d in pairs(data.faces) do
                        if faceData[n] then
                            faceData[n].txtBox.Text = d.t or ""
                            -- Support both RGB array {R,G,B} and hex string formats
                            if type(d.c) == "table" then
                                faceData[n].clrBtn.BackgroundColor3 = Color3.new(d.c[1], d.c[2], d.c[3])
                            elseif type(d.c) == "string" then
                                local hex = d.c:gsub("#","")
                                faceData[n].clrBtn.BackgroundColor3 = Color3.fromRGB(
                                    tonumber("0x"..hex:sub(1,2)),
                                    tonumber("0x"..hex:sub(3,4)),
                                    tonumber("0x"..hex:sub(5,6))
                                )
                            end
                        end
                    end
                end
            end)
        end
    end
end

SaveBtn.MouseButton1Click:Connect(function()
    local name = SlotBox.Text ~= "" and SlotBox.Text or "Config_"..os.time()
    local data = {faces = {}}
    for n, v in pairs(faceData) do
        local c = v.clrBtn.BackgroundColor3
        data.faces[n] = {t = v.txtBox.Text, c = {c.R, c.G, c.B}}
    end
    if writefile then
        writefile("WindConfigs/"..name..".json", HttpService:JSONEncode(data))
        updateSlots()
    end
end)

DeleteSlotBtn.MouseButton1Click:Connect(function()
    local name = SlotBox.Text
    if name ~= "" and isfile and isfile("WindConfigs/"..name..".json") then
        if delfile then delfile("WindConfigs/"..name..".json") end
        SlotBox.Text = ""
        updateSlots()
    end
end)

RevealBtn.MouseButton1Click:Connect(updateSlots)
updateSlots()

-- --- LOGIC & FUNCTIONS ---
local spamming, autoAnchor, useToxic = false, true, false
local function toHex(c) return string.format("#%02X%02X%02X", math.round(c.R*255), math.round(c.G*255), math.round(c.B*255)) end
local function fromHex(hex)
    hex = hex:gsub("#","")
    return Color3.fromRGB(tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)))
end

-- [[ EXECUTION SEQUENCE ]] --
local function runFix()
    local char = LocalPlayer.Character
    if not char then warn("[WIND GUI] Error: Character not found!") return end

    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then warn("[WIND GUI] Error: HumanoidRootPart missing!") return end

    -- Find Paint tool in character or backpack
    local tool = char:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
    if not tool then
        warn("[WIND GUI] ERROR: 'Paint' tool missing! You must have the Paint tool in your inventory.")
        return
    end

    local brick = ReplicatedStorage:FindFirstChild("Brick")
    if not brick then
        warn("[WIND GUI] ERROR: 'Brick' not found in ReplicatedStorage!")
        return
    end

    -- Equip tool if not already equipped
    if tool.Parent ~= char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:EquipTool(tool)
            task.wait(0.35)
        end
        -- Re-reference after equip
        tool = char:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
        if not tool then warn("[WIND GUI] ERROR: Paint tool lost after equip attempt.") return end
    end

    -- Search recursively for RemoteEvent inside Paint tool
    local remote = tool:FindFirstChild("Event", true) or tool:FindFirstChildWhichIsA("RemoteEvent", true)
    if not remote then
        warn("[WIND GUI] ERROR: RemoteEvent not found inside the Paint tool.")
        return
    end

    local rootPos = rootPart.Position
    local key = "both \u{1F91D}"
    local mat = useToxic and "toxic" or "plastic"
    local baseCol = useToxic and Color3.new(0,0,0) or Color3.fromRGB(163, 162, 165)

    print("[WIND GUI] Running Sequence...")

    -- Step 1: Set material
    pcall(function() remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, baseCol, mat, "anchor") end)
    task.wait(0.4)

    -- Step 2: Anchor if enabled
    if autoAnchor then
        pcall(function() remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, baseCol, "anchor", "") end)
        task.wait(0.4)
    end

    -- Step 3: Paint all faces
    local faceEnums = {
        Front  = Enum.NormalId.Front,
        Back   = Enum.NormalId.Back,
        Top    = Enum.NormalId.Top,
        Bottom = Enum.NormalId.Bottom,
        Right  = Enum.NormalId.Right,
        Left   = Enum.NormalId.Left
    }
    for _, name in ipairs(faces) do
        local data = faceData[name]
        pcall(function()
            remote:FireServer(brick, faceEnums[name], rootPos, key, data.clrBtn.BackgroundColor3, "spray", data.txtBox.Text)
        end)
        task.wait(0.2)
    end

    print("[WIND GUI] Sequence Complete!")
end

-- --- AURA LOOP CORE ---
local function fireDeleteTool(v)
    local char = LocalPlayer.Character
    if not char then return end
    -- Move Delete tool from backpack to character if needed
    local deleteTool = char:FindFirstChild("Delete") or LocalPlayer.Backpack:FindFirstChild("Delete")
    if not deleteTool then return end
    if deleteTool.Parent ~= char then
        deleteTool.Parent = char
        task.wait(0.05)
    end
    deleteTool = char:FindFirstChild("Delete")
    if not deleteTool then return end
    -- Try origevent (RemoteFunction) first, then Script.Event (RemoteEvent)
    local origevent = deleteTool:FindFirstChild("origevent")
    if origevent then
        pcall(function() origevent:Invoke(v, v.Position) end)
        return
    end
    local scriptChild = deleteTool:FindFirstChild("Script")
    if scriptChild then
        local ev = scriptChild:FindFirstChild("Event")
        if ev then
            pcall(function() ev:FireServer(v, v.Position) end)
            return
        end
    end
    -- Fallback: search recursively for any RemoteEvent
    local ev = deleteTool:FindFirstChildWhichIsA("RemoteEvent", true)
    if ev then
        pcall(function() ev:FireServer(v, v.Position) end)
    end
end

coroutine.wrap(function()
    while ors do
        task.wait()
        pcall(function()
            -- Standard Delete Aura (workspace overlap)
            if daura and LocalPlayer.Character then
                daurapart.Position = LocalPlayer.Character:GetPivot().Position
                local parts = workspace:GetPartsInPart(daurapart, filter)
                for _, v in pairs(parts) do
                    coroutine.wrap(function() fireDeleteTool(v) end)()
                end
            end
            -- Solara Delete Aura (workspace.Bricks descendants)
            if dauras and LocalPlayer.Character then
                -- FIX: was `workspace: FindfirstChildren` (space + wrong method)
                local bricksFolder = workspace:FindFirstChild("Bricks")
                if bricksFolder then
                    daurapart.Position = LocalPlayer.Character:GetPivot().Position
                    local parts = {}
                    for _, v in pairs(bricksFolder:GetDescendants()) do
                        if v:IsA("BasePart") and (v.Position - daurapart.Position).Magnitude < daurarange then
                            table.insert(parts, v)
                        end
                    end
                    for _, v in pairs(parts) do
                        coroutine.wrap(function() fireDeleteTool(v) end)()
                    end
                end
            end
        end)
    end
end)()

-- --- Nuke Logic ---
DelCubesBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    -- Equip Delete tool
    local deleteTool = char:FindFirstChild("Delete") or LocalPlayer.Backpack:FindFirstChild("Delete")
    if not deleteTool then warn("[WIND GUI] Nuke Failed: No Delete tool found!") return end
    if deleteTool.Parent ~= char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(deleteTool) end
        task.wait(0.45)
        deleteTool = char:FindFirstChild("Delete")
        if not deleteTool then warn("[WIND GUI] Nuke Failed: Delete tool lost after equip!") return end
    end

    -- Find RemoteEvent inside Delete tool (search recursively)
    local deleteRemote = deleteTool:FindFirstChildWhichIsA("RemoteEvent", true)
    if not deleteRemote then
        -- Try Script.Event fallback
        local scriptChild = deleteTool:FindFirstChild("Script")
        if scriptChild then deleteRemote = scriptChild:FindFirstChild("Event") end
    end
    if not deleteRemote then
        warn("[WIND GUI] Nuke Failed: RemoteEvent not found in Delete tool!")
        return
    end

    local rootPos = char.HumanoidRootPart.Position
    local directions = {
        Vector3.new(0, 10000, 0),
        Vector3.new(0, -10000, 0),
        Vector3.new(15000, 0, 0),
        Vector3.new(-15000, 0, 0)
    }
    task.spawn(function()
        local attempts = 0
        while attempts < 300 do
            attempts = attempts + 1
            for _, dir in ipairs(directions) do
                pcall(function() deleteRemote:FireServer(nil, rootPos + dir) end)
            end
            pcall(function() deleteRemote:FireServer(nil, rootPos) end)
            task.wait(0.04)
        end
    end)
end)

DestroyerBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    local deleteTool = char:FindFirstChild("Delete") or LocalPlayer.Backpack:FindFirstChild("Delete")
    if not deleteTool then warn("[WIND GUI] Destroyer Failed: No Delete tool found!") return end
    if deleteTool.Parent ~= char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:EquipTool(deleteTool)
            task.wait(0.2)
        end
        deleteTool = char:FindFirstChild("Delete")
        if not deleteTool then return end
    end

    pcall(function()
        local scriptEvent = deleteTool:FindFirstChild("Script") and deleteTool.Script:FindFirstChild("Event")
        local brick = ReplicatedStorage:FindFirstChild("Brick")
        if scriptEvent and brick and char:FindFirstChild("HumanoidRootPart") then
            scriptEvent:FireServer(brick, char.HumanoidRootPart.Position)
        end
    end)
end)

-- --- EVENTS ---
FixBtn.MouseButton1Click:Connect(function()
    print("[WIND GUI] Resetting visual variables and initiating Fix...")
    useToxic = false
    autoAnchor = true
    MaterialBtn.Text = "Material: PLASTIC"
    AnchorBtn.Text = "Auto-Anchor: ON"
    for _, name in ipairs(faces) do
        faceData[name].txtBox.Text = " "
        faceData[name].clrBtn.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
    end
    runFix()
end)

ToxicBtn.MouseButton1Click:Connect(function()
    useToxic = true
    MaterialBtn.Text = "Material: TOXIC"
    local b = "<font size= '0'>dx</font>"
    local presets = {
        Front  = "F"..b.."u"..b.."c"..b.."k A"..b.."d"..b.."m"..b.."i"..b.."n",
        Back   = "say i e"..b.."a"..b.."t p"..b.."u"..b.."s"..b.."s"..b.."y",
        Top    = "hacked by FLAMEFAML/STIK",
        Bottom = "GGS (BIG W TO STIK)",
        Right  = "ADMIN HATES N"..b.."I"..b.."G"..b.."G"..b.."E"..b.."R",
        Left   = "CRY GG'S"
    }
    for _, name in ipairs(faces) do
        faceData[name].txtBox.Text = presets[name]
        faceData[name].clrBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- FIX: MaterialBtn toggle now correctly shows PLASTIC instead of OFF
MaterialBtn.MouseButton1Click:Connect(function()
    useToxic = not useToxic
    MaterialBtn.Text = "Material: " .. (useToxic and "TOXIC" or "PLASTIC")
end)

AnchorBtn.MouseButton1Click:Connect(function()
    autoAnchor = not autoAnchor
    AnchorBtn.Text = "Auto-Anchor: " .. (autoAnchor and "ON" or "OFF")
end)

-- FIX: SpamBtn removed from spam loop — spamming runFix() plants bricks uncontrollably
-- Spam mode is now disabled to prevent accidental spam painting
SpamBtn.MouseButton1Click:Connect(function()
    spamming = not spamming
    SpamBtn.Text = "Spam Mode: " .. (spamming and "ON" or "OFF")
end)

-- Run button
RunBtn.MouseButton1Click:Connect(function()
    print("[WIND GUI] Execute Sequence button clicked.")
    runFix()
end)

-- Main Menu Draggable Logic
local drag, dragStart, startPos
Header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true
        dragStart = i.Position
        startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = false
    end
end)

-- FIX: Spam loop now respects the spamming flag properly
task.spawn(function()
    while task.wait(0.5) do
        if spamming then runFix() end
    end
end)
