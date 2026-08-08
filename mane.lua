--[[
    mane.lua
    Rewritten & extended from kks.txt deobfuscation.
    UI: Rayfield (https://sirius.menu/rayfield)

    Button bar: [X] [M] [O]
      X = remove GUI (confirm first)
      M = script label
      O = open / toggle GUI visibility

    Tabs:
      1. Bring & Store
      2. Auto Zombie
      3. Player & Weapons
      4. ESP
--]]

do
    -- ══════════════════════════════════════════════════════════
    --  HELPERS
    -- ══════════════════════════════════════════════════════════
    -- ══════════════════════════════════════════════════════════
    --  SERVICES
    -- ══════════════════════════════════════════════════════════
    local Players          = game:GetService("Players")
    local RunService       = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Lighting         = game:GetService("Lighting")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace        = game:GetService("Workspace")
    local TweenService     = game:GetService("TweenService")
    local CoreGui          = game:GetService("CoreGui")

    local LocalPlayer = Players.LocalPlayer

    -- ══════════════════════════════════════════════════════════
    --  LOAD RAYFIELD
    -- ══════════════════════════════════════════════════════════
    local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

    -- ══════════════════════════════════════════════════════════
    --  RAYFIELD WINDOW
    -- ══════════════════════════════════════════════════════════
    local Window = Rayfield:CreateWindow({
        Name             = "mane",
        LoadingTitle     = "mane",
        LoadingSubtitle  = "loading...",
        ConfigurationSaving = {
            Enabled    = false,
            FolderName = nil,
            FileName   = "mane",
        },
        KeySystem = false,
    })

    -- ══════════════════════════════════════════════════════════
    --  REMOVE OLD GUI
    -- ══════════════════════════════════════════════════════════
    local guiParent = (gethui and gethui()) or CoreGui
        or LocalPlayer:WaitForChild("PlayerGui")

    if guiParent:FindFirstChild("mane_bar") then
        guiParent.mane_bar:Destroy()
    end

    -- ══════════════════════════════════════════════════════════
    --  BUTTON BAR:  [ X ]  [ M ]  [ O ]
    --  Draggable. Red theme. No emojis.
    -- ══════════════════════════════════════════════════════════
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name          = "mane_bar"
    screenGui.ResetOnSpawn  = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent        = guiParent

    -- Container frame (the draggable bar)
    local bar = Instance.new("Frame")
    bar.Name             = "Bar"
    bar.Size             = UDim2.new(0, 126, 0, 36)
    bar.Position         = UDim2.new(0.02, 0, 0.4, 0)
    bar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    bar.BorderSizePixel  = 0
    bar.Active           = true
    bar.Parent           = screenGui

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 8)
    barCorner.Parent = bar

    local barStroke = Instance.new("UIStroke")
    barStroke.Color     = Color3.fromRGB(190, 30, 30)
    barStroke.Thickness = 1.5
    barStroke.Parent    = bar

    local barLayout = Instance.new("UIListLayout")
    barLayout.FillDirection = Enum.FillDirection.Horizontal
    barLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    barLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
    barLayout.Padding = UDim.new(0, 2)
    barLayout.Parent  = bar

    local barPad = Instance.new("UIPadding")
    barPad.PaddingLeft   = UDim.new(0, 4)
    barPad.PaddingRight  = UDim.new(0, 4)
    barPad.Parent = bar

    -- Helper: make one button cell
    local function makeBtn(label, bgColor, textColor)
        local btn = Instance.new("TextButton")
        btn.Size             = UDim2.new(0, 34, 0, 26)
        btn.BackgroundColor3 = bgColor
        btn.Text             = label
        btn.TextColor3       = textColor
        btn.Font             = Enum.Font.GothamBold
        btn.TextSize         = 13
        btn.BorderSizePixel  = 0
        btn.AutoButtonColor  = false
        btn.Parent           = bar

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = btn

        -- hover tint
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundColor3 = bgColor:Lerp(Color3.new(1,1,1), 0.12)
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundColor3 = bgColor
            }):Play()
        end)

        return btn
    end

    -- [X] – remove (with confirm dialog)
    local btnX = makeBtn("X", Color3.fromRGB(160, 25, 25), Color3.fromRGB(255, 255, 255))

    -- [M] – label / drag handle
    local btnM = makeBtn("M", Color3.fromRGB(30, 30, 38), Color3.fromRGB(200, 200, 210))
    btnM.AutoButtonColor = false

    -- [O] – open/toggle Rayfield UI
    local btnO = makeBtn("O", Color3.fromRGB(22, 100, 200), Color3.fromRGB(255, 255, 255))

    -- ── Drag logic (drag by the whole bar) ───────────────────
    local dragging, dragInput, dragStart, dragStartPos

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging     = true
            dragStart    = input.Position
            dragStartPos = bar.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end

    bar.InputBegan:Connect(onInputBegan)
    btnM.InputBegan:Connect(onInputBegan)

    bar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            bar.Position = UDim2.new(
                dragStartPos.X.Scale,
                dragStartPos.X.Offset + delta.X,
                dragStartPos.Y.Scale,
                dragStartPos.Y.Offset + delta.Y
            )
        end
    end)

    -- ── [O] toggle Rayfield ────────────────────────────────────
    local guiVisible = true
    btnO.MouseButton1Click:Connect(function()
        guiVisible = not guiVisible
        Rayfield:ToggleUI()
        btnO.BackgroundColor3 = guiVisible
            and Color3.fromRGB(22, 100, 200)
            or  Color3.fromRGB(40, 40, 50)
    end)

    -- ── [X] remove with confirm overlay ───────────────────────
    btnX.MouseButton1Click:Connect(function()
        -- Build confirm overlay
        local overlay = Instance.new("Frame")
        overlay.Name             = "ConfirmOverlay"
        overlay.Size             = UDim2.new(0, 220, 0, 90)
        overlay.Position         = UDim2.new(
            0,
            bar.AbsolutePosition.X,
            0,
            bar.AbsolutePosition.Y + bar.AbsoluteSize.Y + 4
        )
        overlay.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
        overlay.BorderSizePixel  = 0
        overlay.ZIndex           = 20
        overlay.Parent           = screenGui

        local oc = Instance.new("UICorner")
        oc.CornerRadius = UDim.new(0, 8)
        oc.Parent = overlay

        local os = Instance.new("UIStroke")
        os.Color     = Color3.fromRGB(190, 30, 30)
        os.Thickness = 1.5
        os.Parent    = overlay

        local msg = Instance.new("TextLabel")
        msg.Size             = UDim2.new(1, -16, 0, 36)
        msg.Position         = UDim2.new(0, 8, 0, 8)
        msg.BackgroundTransparency = 1
        msg.Text             = "Are you sure you want to remove this?"
        msg.TextColor3       = Color3.fromRGB(220, 220, 230)
        msg.Font             = Enum.Font.Gotham
        msg.TextSize         = 12
        msg.TextWrapped      = true
        msg.ZIndex           = 21
        msg.Parent           = overlay

        local function makeConfirmBtn(lbl, bg, xOff)
            local b = Instance.new("TextButton")
            b.Size             = UDim2.new(0, 90, 0, 26)
            b.Position         = UDim2.new(0, xOff, 1, -34)
            b.BackgroundColor3 = bg
            b.Text             = lbl
            b.TextColor3       = Color3.fromRGB(255, 255, 255)
            b.Font             = Enum.Font.GothamBold
            b.TextSize         = 12
            b.BorderSizePixel  = 0
            b.ZIndex           = 21
            b.Parent           = overlay
            local cc = Instance.new("UICorner")
            cc.CornerRadius = UDim.new(0, 6)
            cc.Parent = b
            return b
        end

        local yesBtn    = makeConfirmBtn("Yes, remove", Color3.fromRGB(155, 20, 20),   10)
        local cancelBtn = makeConfirmBtn("Cancel",      Color3.fromRGB(35, 35, 50),    112)

        yesBtn.MouseButton1Click:Connect(function()
            -- Destroy everything
            overlay:Destroy()
            screenGui:Destroy()
            Rayfield:Destroy()
        end)

        cancelBtn.MouseButton1Click:Connect(function()
            overlay:Destroy()
        end)
    end)

    -- ══════════════════════════════════════════════════════════
    --  GAME REMOTES & FOLDERS
    -- ══════════════════════════════════════════════════════════
    local eventsFolder   = ReplicatedStorage:WaitForChild("Events",          5)
    local storeRequest   = eventsFolder and eventsFolder:WaitForChild("StoreRequest",          5)
    local chopTreeEvent  = eventsFolder and eventsFolder:WaitForChild("ChopTreeEvent",         5)
    local zombieHitBatch = eventsFolder and eventsFolder:WaitForChild("LocalZombieHitBatch",   5)
    local eatRequest     = eventsFolder and eventsFolder:WaitForChild("EatRequest",            5)

    local survivorsFolder = Workspace:WaitForChild("Survivors",  5)
    local grownFoodFolder = Workspace:WaitForChild("GrownFood",  5)

    -- Gun config module
    local configModule =
        ReplicatedStorage:FindFirstChild("ValidGunsData")
        or (ReplicatedStorage:FindFirstChild("Shared")
            and ReplicatedStorage.Shared:FindFirstChild("ValidGunsData"))
        or ReplicatedStorage:FindFirstChild("ValidGunsData", true)

    local configRequired   = nil
    local originalGetConfig = nil
    if configModule then
        pcall(function()
            configRequired = require(configModule)
            if configRequired and configRequired.GetConfig then
                originalGetConfig = configRequired.GetConfig
            end
        end)
    end

    -- ══════════════════════════════════════════════════════════
    --  SHARED STATE
    -- ══════════════════════════════════════════════════════════
    local opGunsEnabled = false
    local opDamage      = 999999
    local opMaxAmmo     = 99999
    local opSpread      = 0.01
    local opFireDelay   = 0.01
    local opMaxReserve  = 99999
    local opBulletSpeed = 10000

    local function isNight()
        local ct = Lighting.ClockTime
        return (ct >= 18) or (ct < 6)
    end

    local function getPatchedConfig(self, weaponName)
        if not originalGetConfig or not configRequired then return nil end
        local cfg = originalGetConfig(configRequired, weaponName)
        if not cfg then return cfg end
        cfg.ReserveAmmo        = opMaxReserve
        cfg.MaxReserve         = opMaxReserve
        cfg.IsAutomatic        = true
        cfg.Spread             = 0
        cfg.BulletSpeed        = opBulletSpeed
        cfg.Ammo               = opMaxAmmo
        cfg.HeadshotMultiplier = 100
        cfg.FireDelay          = opFireDelay
        cfg.ReloadTime         = 0.01
        cfg.BulletGravity      = 0
        cfg.Recoil             = 0
        cfg.VerticalMin        = 0
        cfg.VerticalMax        = 0
        cfg.HorizontalMin      = 0
        cfg.HorizontalMax      = 0
        cfg.Damage             = opDamage
        return cfg
    end

    -- ══════════════════════════════════════════════════════════
    --  TAB 1 – BRING & STORE
    -- ══════════════════════════════════════════════════════════
    local tab_store = Window:CreateTab("Bring and Store", "box")

    tab_store:CreateSection("Auto Chest")

    local autoStoreActive = false
    tab_store:CreateToggle({
        Name         = "Auto Open All Chests",
        CurrentValue = false,
        Flag         = "AutoAllChestToggle",
        Callback     = function(state)
            autoStoreActive = state
            if state then
                task.spawn(function()
                    local originCF = LocalPlayer.Character
                        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        and LocalPlayer.Character.HumanoidRootPart.CFrame

                    local chestsFolder = Workspace:FindFirstChild("Chests")
                    if not chestsFolder then
                        Rayfield:Notify({
                            Title    = "Error",
                            Content  = "Chests folder not found in Workspace.",
                            Duration = 3,
                        })
                        autoStoreActive = false
                        return
                    end

                    local opened = 0
                    for _, chest in ipairs(chestsFolder:GetChildren()) do
                        if not autoStoreActive then break end
                        local tag = "OpenedByUser_" .. LocalPlayer.UserId
                        if not chest:GetAttribute(tag) then
                            local hrpTarget = chest:IsA("BasePart") and chest.CFrame
                                or (chest.PrimaryPart and chest.PrimaryPart.CFrame)
                            if hrpTarget and LocalPlayer.Character
                            and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = hrpTarget
                            end
                            pcall(function() storeRequest:FireServer(chest) end)
                            chest:SetAttribute(tag, true)
                            opened += 1
                            task.wait(0.4)
                        end
                    end

                    if originCF and LocalPlayer.Character
                    and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = originCF
                    end

                    Rayfield:Notify({
                        Title    = "Done",
                        Content  = "Opened " .. opened .. " chests and returned to start.",
                        Duration = 3,
                    })
                    autoStoreActive = false
                end)
            end
        end,
    })

    tab_store:CreateSection("Survivors")

    local autoRescueActive = false
    tab_store:CreateToggle({
        Name         = "Auto Rescue All Survivors",
        CurrentValue = false,
        Flag         = "AutoRescueToggle",
        Callback     = function(state)
            autoRescueActive = state
            if state then
                task.spawn(function()
                    local originCF = LocalPlayer.Character
                        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        and LocalPlayer.Character.HumanoidRootPart.CFrame

                    if survivorsFolder then
                        for _, s in ipairs(survivorsFolder:GetChildren()) do
                            if not autoRescueActive then break end
                            local hrp = s:FindFirstChild("HumanoidRootPart")
                                or (s:IsA("BasePart") and s)
                            if hrp and LocalPlayer.Character
                            and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame
                            end
                            pcall(function() storeRequest:FireServer(s) end)
                            task.wait(0.3)
                        end
                    end

                    if originCF and LocalPlayer.Character
                    and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = originCF
                    end

                    Rayfield:Notify({
                        Title    = "Done",
                        Content  = "All survivors rescued. Returned to start.",
                        Duration = 3,
                    })
                    autoRescueActive = false
                end)
            end
        end,
    })

    tab_store:CreateSection("Trees")

    local autoChopActive = false
    tab_store:CreateToggle({
        Name         = "Auto Chop All Trees",
        CurrentValue = false,
        Flag         = "AutoChopToggle",
        Callback     = function(state)
            autoChopActive = state
            if state then
                task.spawn(function()
                    if not chopTreeEvent then
                        Rayfield:Notify({
                            Title    = "Error",
                            Content  = "ChopTreeEvent remote not found.",
                            Duration = 3,
                        })
                        autoChopActive = false
                        return
                    end

                    local treeFolder = Workspace:FindFirstChild("Map_V5")
                        or Workspace:FindFirstChild("Pine Trees")
                    if not treeFolder then
                        Rayfield:Notify({
                            Title    = "Error",
                            Content  = "Tree folder not found in Workspace.",
                            Duration = 3,
                        })
                        autoChopActive = false
                        return
                    end

                    for _, tree in ipairs(treeFolder:GetChildren()) do
                        if not autoChopActive then break end
                        if tree:FindFirstChild("Leaves") then
                            pcall(function() chopTreeEvent:FireServer(tree) end)
                            task.wait(0.15)
                        end
                    end

                    Rayfield:Notify({
                        Title    = "Done",
                        Content  = "All trees with leaves have been chopped.",
                        Duration = 3,
                    })
                    autoChopActive = false
                end)
            end
        end,
    })

    -- ══════════════════════════════════════════════════════════
    --  TAB 2 – AUTO ZOMBIE
    -- ══════════════════════════════════════════════════════════
    local tab_zombie = Window:CreateTab("Auto Zombie", "skull")

    local onlyNight     = false
    local zombieRange   = 80
    local attackDelay   = 0.1
    local autoKillActive = false

    tab_zombie:CreateSection("Filters")

    tab_zombie:CreateToggle({
        Name         = "Only Run at Night",
        CurrentValue = false,
        Flag         = "OnlyNightToggle",
        Callback     = function(state) onlyNight = state end,
    })

    tab_zombie:CreateSection("Detection")

    tab_zombie:CreateSlider({
        Name      = "Detection Range (studs)",
        Range     = {10, 300},
        Increment = 5,
        CurrentValue = 80,
        Flag      = "ZombieRangeSlider",
        Callback  = function(val) zombieRange = val end,
    })

    tab_zombie:CreateSlider({
        Name      = "Attack Delay (seconds)",
        Range     = {0.05, 2},
        Increment = 0.05,
        CurrentValue = 0.1,
        Flag      = "AttackDelaySlider",
        Callback  = function(val) attackDelay = val end,
    })

    tab_zombie:CreateSection("Auto Kill")

    tab_zombie:CreateToggle({
        Name         = "Auto Kill Zombies",
        CurrentValue = false,
        Flag         = "AutoZombieToggle",
        Callback     = function(state)
            autoKillActive = state
            if state then
                task.spawn(function()
                    while autoKillActive do
                        if onlyNight and not isNight() then
                            task.wait(1)
                        else
                            local playerRoot = LocalPlayer.Character
                                and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

                            if playerRoot then
                                for _, obj in ipairs(Workspace:GetChildren()) do
                                    if not autoKillActive then break end
                                    local name = obj.Name:lower()
                                    if name:find("zombie") or name:find("npc")
                                    or name:find("rotter") or name:find("eye")
                                    or name:find("crawler") then
                                        local hum  = obj:FindFirstChildOfClass("Humanoid")
                                        local root = obj:FindFirstChild("HumanoidRootPart")
                                            or obj:FindFirstChild("Torso")
                                        if hum and hum.Health > 0 and root then
                                            local dist = (root.Position - playerRoot.Position).Magnitude
                                            if dist <= zombieRange then
                                                pcall(function()
                                                    zombieHitBatch:FireServer({{
                                                        zombie   = obj,
                                                        headshot = false,
                                                    }})
                                                end)
                                                task.wait(attackDelay)
                                            end
                                        end
                                    end
                                end
                            end
                            task.wait(0.05)
                        end
                    end
                end)
            end
        end,
    })

    -- ══════════════════════════════════════════════════════════
    --  TAB 3 – PLAYER & WEAPONS
    -- ══════════════════════════════════════════════════════════
    local tab_player = Window:CreateTab("Player and Weapons", "user")

    -- ── Food ──────────────────────────────────────────────────
    tab_player:CreateSection("Auto Eat")

    local autoEatActive = false
    local eatFoodType   = "All Foods"
    local eatThreshold  = 80

    tab_player:CreateDropdown({
        Name          = "Food Type",
        Options       = {"All Foods", "noodle", "food", "eat"},
        CurrentOption = {"All Foods"},
        Flag          = "FoodTypeDropdown",
        Callback      = function(val) eatFoodType = val[1] or val end,
    })

    tab_player:CreateSlider({
        Name         = "Eat When Hunger Below (%)",
        Range        = {1, 100},
        Increment    = 1,
        CurrentValue = 80,
        Flag         = "EatThresholdSlider",
        Callback     = function(val) eatThreshold = val end,
    })

    tab_player:CreateToggle({
        Name         = "Auto Eat Food",
        CurrentValue = false,
        Flag         = "AutoEatToggle",
        Callback     = function(state)
            autoEatActive = state
            if state then
                task.spawn(function()
                    while autoEatActive do
                        local hunger = LocalPlayer:GetAttribute("Food")
                            or LocalPlayer:GetAttribute("Hunger")
                            or 100

                        if hunger < eatThreshold and eatRequest then
                            local foodItem = nil
                            if grownFoodFolder then
                                for _, item in ipairs(grownFoodFolder:GetChildren()) do
                                    if eatFoodType == "All Foods" or item.Name == eatFoodType then
                                        foodItem = item
                                        break
                                    end
                                end
                            end
                            if not foodItem then
                                for _, obj in ipairs(Workspace:GetChildren()) do
                                    if not obj:IsA("Folder") then
                                        if eatFoodType == "All Foods" then
                                            if obj.Name:lower():find("noodle")
                                            or obj.Name:lower():find("food") then
                                                foodItem = obj; break
                                            end
                                        elseif obj.Name == eatFoodType then
                                            foodItem = obj; break
                                        end
                                    end
                                end
                            end
                            if foodItem then
                                pcall(function() eatRequest:FireServer(foodItem) end)
                                task.wait(0.3)
                            end
                        end
                        task.wait(1)
                    end
                end)
            end
        end,
    })

    -- ── World ─────────────────────────────────────────────────
    tab_player:CreateSection("Movement")

    tab_player:CreateSlider({
        Name         = "Walk Speed",
        Range        = {16, 500},
        Increment    = 2,
        CurrentValue = 16,
        Flag         = "WalkSpeedSlider",
        Callback     = function(val)
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end,
    })

    tab_player:CreateSlider({
        Name         = "Jump Power",
        Range        = {50, 500},
        Increment    = 5,
        CurrentValue = 50,
        Flag         = "JumpPowerSlider",
        Callback     = function(val)
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower    = val
            end
        end,
    })

    tab_player:CreateToggle({
        Name         = "No Clip",
        CurrentValue = false,
        Flag         = "NoClipToggle",
        Callback     = function(state)
            if state then
                RunService.Stepped:Connect(function()
                    if _G.mane_noclip then
                        local char = LocalPlayer.Character
                        if char then
                            for _, part in ipairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end
                end)
                _G.mane_noclip = true
            else
                _G.mane_noclip = false
                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end,
    })

    tab_player:CreateToggle({
        Name         = "Fly",
        CurrentValue = false,
        Flag         = "FlyToggle",
        Callback     = function(state)
            _G.mane_fly = state
            if state then
                local char = LocalPlayer.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then
                    Rayfield:Notify({ Title="Error", Content="Spawn first.", Duration=2 })
                    return
                end

                local bv = Instance.new("BodyVelocity")
                bv.Name         = "mane_fly_bv"
                bv.Velocity     = Vector3.zero
                bv.MaxForce     = Vector3.new(1e5, 1e5, 1e5)
                bv.Parent       = hrp

                local bg = Instance.new("BodyGyro")
                bg.Name      = "mane_fly_bg"
                bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                bg.D         = 100
                bg.Parent    = hrp

                hum.PlatformStand = true

                local flySpeed = 60
                local conn
                conn = RunService.Heartbeat:Connect(function()
                    if not _G.mane_fly then
                        bv:Destroy()
                        bg:Destroy()
                        hum.PlatformStand = false
                        conn:Disconnect()
                        return
                    end
                    local cam = Workspace.CurrentCamera
                    local dir = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        dir = dir + cam.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        dir = dir - cam.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        dir = dir - cam.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        dir = dir + cam.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        dir = dir + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        dir = dir - Vector3.new(0, 1, 0)
                    end
                    if dir.Magnitude > 0 then dir = dir.Unit end
                    bv.Velocity = dir * flySpeed
                    bg.CFrame   = cam.CFrame
                end)
            else
                _G.mane_fly = false
            end
        end,
    })

    tab_player:CreateSection("World")

    tab_player:CreateToggle({
        Name         = "Hide All Zombies",
        CurrentValue = false,
        Flag         = "HideZombieToggle",
        Callback     = function(state)
            for _, obj in ipairs(Workspace:GetChildren()) do
                local n = obj.Name:lower()
                if n:find("zombie") or n:find("npc") then
                    for _, part in ipairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("Decal") then
                            if state then
                                part:SetAttribute("OldTransparency", part.Transparency)
                                part.Transparency = 1
                            else
                                local old = part:GetAttribute("OldTransparency")
                                if old then part.Transparency = old end
                            end
                        end
                    end
                end
            end
            Rayfield:Notify({
                Title    = state and "Hidden" or "Visible",
                Content  = state and "All zombies hidden." or "Zombies visible again.",
                Duration = 2,
            })
        end,
    })

    tab_player:CreateButton({
        Name     = "Delete Fog of War",
        Callback = function()
            local fog = Workspace:FindFirstChild("FogOfWar")
            if fog then
                fog:Destroy()
                Rayfield:Notify({ Title="Done", Content="FogOfWar removed.", Duration=2 })
            else
                Rayfield:Notify({ Title="Not Found", Content="FogOfWar not found.", Duration=2 })
            end
        end,
    })

    tab_player:CreateSlider({
        Name         = "Render Distance",
        Range        = {64, 2048},
        Increment    = 64,
        CurrentValue = 512,
        Flag         = "RenderDistanceSlider",
        Callback     = function(val)
            Workspace.StreamingMinRadius = val
        end,
    })

    -- ── Weapons ───────────────────────────────────────────────
    tab_player:CreateSection("OP Weapons")

    tab_player:CreateToggle({
        Name         = "Enable OP Guns",
        CurrentValue = false,
        Flag         = "OPToggleUI",
        Callback     = function(state)
            opGunsEnabled = state
            if not configRequired or not originalGetConfig then
                Rayfield:Notify({
                    Title    = "Error",
                    Content  = "ValidGunsData module not found.",
                    Duration = 3,
                })
                return
            end
            if state then
                configRequired.GetConfig = getPatchedConfig
                Rayfield:Notify({ Title="OP Guns On", Content="Weapon stats set to max.", Duration=2 })
            else
                configRequired.GetConfig = originalGetConfig
                Rayfield:Notify({ Title="OP Guns Off", Content="Weapon stats restored.", Duration=2 })
            end
        end,
    })

    tab_player:CreateInput({
        Name                     = "Weapon Damage",
        PlaceholderText          = "999999",
        RemoveTextAfterFocusLost = false,
        Callback = function(val)
            local n = tonumber(val)
            if n then opDamage = n end
        end,
    })

    tab_player:CreateInput({
        Name                     = "Fire Delay",
        PlaceholderText          = "0.01",
        RemoveTextAfterFocusLost = false,
        Callback = function(val)
            local n = tonumber(val)
            if n then opFireDelay = n end
        end,
    })

    tab_player:CreateInput({
        Name                     = "Max Ammo",
        PlaceholderText          = "99999",
        RemoveTextAfterFocusLost = false,
        Callback = function(val)
            local n = tonumber(val)
            if n then opMaxReserve = n end
        end,
    })

    tab_player:CreateButton({
        Name     = "Set 99999 Ammo - All Inventory",
        Callback = function()
            local function setAmmo(container)
                for _, item in ipairs(container:GetChildren()) do
                    if item:IsA("Tool") or item:IsA("Model") then
                        item:SetAttribute("CurrentAmmo", 99999)
                        item:SetAttribute("ReserveAmmo", 99999)
                    end
                end
            end
            if LocalPlayer.Character then setAmmo(LocalPlayer.Character) end
            if LocalPlayer:FindFirstChild("Backpack") then setAmmo(LocalPlayer.Backpack) end
            Rayfield:Notify({
                Title    = "Done",
                Content  = "All inventory ammo set to 99999.",
                Duration = 3,
            })
        end,
    })

    -- ══════════════════════════════════════════════════════════
    --  TAB 4 – ESP
    -- ══════════════════════════════════════════════════════════
    local tab_esp = Window:CreateTab("ESP", "eye")

    -- ── ESP State ─────────────────────────────────────────────
    local espEnabled       = false
    local espZombies       = false
    local espBosses        = false
    local espPlayers       = false
    local espItems         = false
    local espBoosts        = false
    local espMaxDist       = 500
    local espShowDistance  = true
    local espShowName      = true

    -- Color settings
    local ESP_COLOR = {
        zombie  = Color3.fromRGB(255, 60,  60),   -- red
        boss    = Color3.fromRGB(255, 140, 0),    -- orange
        player  = Color3.fromRGB(80,  180, 255),  -- blue
        item    = Color3.fromRGB(80,  255, 130),  -- green
        boost   = Color3.fromRGB(230, 80,  255),  -- purple
    }

    -- Keywords for classification
    local ZOMBIE_NAMES  = {"zombie","rotter","crawler","eye","npc"}
    local BOSS_NAMES    = {"boss","giant","alpha","mega","king","queen","brute"}
    local ITEM_NAMES    = {"chest","med","loot","supply","crate","box","ammo","package"}
    local BOOST_NAMES   = {"boost","powerup","power","speed","buff","stimpack","adrenaline"}

    -- BillboardGui storage: [instance] = billboard
    local espBillboards = {}

    local function classifyObject(obj)
        local n = obj.Name:lower()
        for _, kw in ipairs(BOSS_NAMES) do
            if n:find(kw) then return "boss" end
        end
        for _, kw in ipairs(ZOMBIE_NAMES) do
            if n:find(kw) then return "zombie" end
        end
        for _, kw in ipairs(BOOST_NAMES) do
            if n:find(kw) then return "boost" end
        end
        for _, kw in ipairs(ITEM_NAMES) do
            if n:find(kw) then return "item" end
        end
        return nil
    end

    local function getRootPart(obj)
        if obj:IsA("BasePart") then return obj end
        return obj:FindFirstChild("HumanoidRootPart")
            or obj:FindFirstChild("Torso")
            or obj:FindFirstChildWhichIsA("BasePart")
            or (obj.PrimaryPart)
    end

    local function getHealthText(obj)
        local hum = obj:FindFirstChildOfClass("Humanoid")
        if hum then
            return string.format(" [%d/%d]", math.floor(hum.Health), math.floor(hum.MaxHealth))
        end
        return ""
    end

    local function removeESPFor(obj)
        if espBillboards[obj] then
            pcall(function() espBillboards[obj]:Destroy() end)
            espBillboards[obj] = nil
        end
    end

    local function createESPFor(obj, category)
        if espBillboards[obj] then return end
        local root = getRootPart(obj)
        if not root then return end

        local color = ESP_COLOR[category] or Color3.fromRGB(255,255,255)

        local bb = Instance.new("BillboardGui")
        bb.Name            = "mane_esp"
        bb.AlwaysOnTop     = true
        bb.Size            = UDim2.new(0, 120, 0, 40)
        bb.StudsOffset     = Vector3.new(0, 2.5, 0)
        bb.Adornee         = root
        bb.Parent          = root

        local box = Instance.new("Frame")
        box.Size             = UDim2.new(1, 0, 1, 0)
        box.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        box.BackgroundTransparency = 0.55
        box.BorderSizePixel  = 0
        box.Parent           = bb

        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 4)
        bc.Parent = box

        local bs = Instance.new("UIStroke")
        bs.Color     = color
        bs.Thickness = 1.2
        bs.Parent    = box

        local label = Instance.new("TextLabel")
        label.Name               = "ESPLabel"
        label.Size               = UDim2.new(1, -4, 1, 0)
        label.Position           = UDim2.new(0, 2, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3         = color
        label.Font               = Enum.Font.GothamBold
        label.TextSize           = 11
        label.TextTruncate       = Enum.TextTruncate.AtEnd
        label.Text               = obj.Name
        label.Parent             = bb

        espBillboards[obj] = bb

        -- Update label every frame
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not espEnabled or not espBillboards[obj] then
                conn:Disconnect()
                removeESPFor(obj)
                return
            end
            -- Check category toggle
            local catOn = (category == "zombie" and espZombies)
                or (category == "boss" and espBosses)
                or (category == "player" and espPlayers)
                or (category == "item" and espItems)
                or (category == "boost" and espBoosts)

            if not catOn then
                bb.Enabled = false
                return
            end

            local playerRoot = LocalPlayer.Character
                and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not playerRoot then bb.Enabled = false; return end

            local rootOk, actualRoot = pcall(function() return getRootPart(obj) end)
            if not rootOk or not actualRoot then
                conn:Disconnect()
                removeESPFor(obj)
                return
            end

            local dist = (actualRoot.Position - playerRoot.Position).Magnitude
            if dist > espMaxDist then
                bb.Enabled = false
                return
            end

            bb.Enabled = true

            -- Build label text
            local txt = ""
            if espShowName then txt = obj.Name end
            txt = txt .. getHealthText(obj)
            if espShowDistance then
                txt = txt .. string.format("\n%.0f studs", dist)
            end
            label.Text = txt
        end)

        -- Clean up when object removed
        obj.AncestryChanged:Connect(function(_, parent)
            if parent == nil then
                conn:Disconnect()
                removeESPFor(obj)
            end
        end)
    end

    -- Scan and tag all current + future Workspace children
    local function scanWorkspaceForESP()
        for _, obj in ipairs(Workspace:GetChildren()) do
            local cat = classifyObject(obj)
            if cat then createESPFor(obj, cat) end
        end
        -- Players
        if espPlayers then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    createESPFor(plr.Character, "player")
                end
            end
        end
    end

    local espScanConn
    local function startESPScan()
        scanWorkspaceForESP()
        espScanConn = Workspace.ChildAdded:Connect(function(obj)
            task.wait(0.1)  -- let object fully load
            local cat = classifyObject(obj)
            if cat and espEnabled then createESPFor(obj, cat) end
        end)
        -- Watch for new player characters
        Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function(char)
                if espPlayers and espEnabled then
                    task.wait(0.5)
                    createESPFor(char, "player")
                end
            end)
        end)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                plr.CharacterAdded:Connect(function(char)
                    if espPlayers and espEnabled then
                        task.wait(0.5)
                        createESPFor(char, "player")
                    end
                end)
            end
        end
    end

    local function stopESP()
        if espScanConn then espScanConn:Disconnect() end
        for obj, bb in pairs(espBillboards) do
            pcall(function() bb:Destroy() end)
            espBillboards[obj] = nil
        end
    end

    -- ── ESP Controls ──────────────────────────────────────────
    tab_esp:CreateSection("Master")

    tab_esp:CreateToggle({
        Name         = "ESP Master Switch",
        CurrentValue = false,
        Flag         = "ESPMaster",
        Callback     = function(state)
            espEnabled = state
            if state then
                startESPScan()
                Rayfield:Notify({ Title="ESP On", Content="ESP is now active.", Duration=2 })
            else
                stopESP()
                Rayfield:Notify({ Title="ESP Off", Content="ESP cleared.", Duration=2 })
            end
        end,
    })

    tab_esp:CreateSlider({
        Name         = "Max ESP Distance (studs)",
        Range        = {50, 2000},
        Increment    = 50,
        CurrentValue = 500,
        Flag         = "ESPDistSlider",
        Callback     = function(val) espMaxDist = val end,
    })

    tab_esp:CreateToggle({
        Name         = "Show Name",
        CurrentValue = true,
        Flag         = "ESPShowName",
        Callback     = function(state) espShowName = state end,
    })

    tab_esp:CreateToggle({
        Name         = "Show Distance",
        CurrentValue = true,
        Flag         = "ESPShowDist",
        Callback     = function(state) espShowDistance = state end,
    })

    tab_esp:CreateSection("Categories")

    tab_esp:CreateToggle({
        Name         = "Zombies  (red)",
        CurrentValue = false,
        Flag         = "ESPZombies",
        Callback     = function(state)
            espZombies = state
            if espEnabled then scanWorkspaceForESP() end
        end,
    })

    tab_esp:CreateToggle({
        Name         = "Bosses  (orange)",
        CurrentValue = false,
        Flag         = "ESPBosses",
        Callback     = function(state)
            espBosses = state
            if espEnabled then scanWorkspaceForESP() end
        end,
    })

    tab_esp:CreateToggle({
        Name         = "Players  (blue)",
        CurrentValue = false,
        Flag         = "ESPPlayers",
        Callback     = function(state)
            espPlayers = state
            if espEnabled then scanWorkspaceForESP() end
        end,
    })

    tab_esp:CreateToggle({
        Name         = "Items and Loot  (green)",
        CurrentValue = false,
        Flag         = "ESPItems",
        Callback     = function(state)
            espItems = state
            if espEnabled then scanWorkspaceForESP() end
        end,
    })

    tab_esp:CreateToggle({
        Name         = "Boosts and Powerups  (purple)",
        CurrentValue = false,
        Flag         = "ESPBoosts",
        Callback     = function(state)
            espBoosts = state
            if espEnabled then scanWorkspaceForESP() end
        end,
    })

    tab_esp:CreateSection("Debug")

    tab_esp:CreateButton({
        Name     = "Refresh ESP Scan",
        Callback = function()
            if espEnabled then
                stopESP()
                task.wait(0.1)
                startESPScan()
                Rayfield:Notify({ Title="Refreshed", Content="ESP re-scanned Workspace.", Duration=2 })
            else
                Rayfield:Notify({ Title="ESP Off", Content="Enable the master switch first.", Duration=2 })
            end
        end,
    })

end  -- end do block
