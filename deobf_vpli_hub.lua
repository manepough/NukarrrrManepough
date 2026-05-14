-- VPLI HUB V2 | Deobfuscated
-- Original generated at discord.gg/25ms

-- ============================================================
-- COMMAND LISTS
-- ============================================================

local serverCleanupCmds = {
    ';delcubes a',
    ';fog nan',
    ';delclones a',
    ';maptide nan',
    ';mapsize nan',
    ';seatide nan',
    ';seasize nan',
    ';colorless',
    ';myopic o',
}

local softAbuseCmds = {
    ';reset me',
    ';clearinv o',
    ';freeze o',
    ';blind o',
    ';reset me',
    ';mute o',
    ';fat o',
    ';clone o',
    ';reset me',
}

local hardAbuseCmds = {
    ';reset me',
    ';clearinv o',
    ';freeze o',
    ';blind o',
    ';reset me',
    ';mute o',
    ';jail o',
    ';explode o inf',
    ';reset me',
}

-- ============================================================
-- SERVICES & CORE REFERENCES
-- ============================================================

local LocalPlayer   = game:GetService('Players').LocalPlayer
local RBXSystem     = game:GetService('TextChatService').TextChannels.RBXSystem
local RunService    = game:GetService('RunService')
local Players2      = game:GetService('Players')

-- Load Rayfield UI library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ============================================================
-- STATE FLAGS & CONFIG
-- ============================================================

local saveEnlightenEnabled  = false
local cmdSpammerEnabled     = false
local customCmdList         = {}     -- list of custom commands for multi-cmd spammer
local cmdSpamDelay          = 0.15
local commandAbuseEnabled   = false
local abuseCommandDelay     = 0.15
local softModeEnabled       = false  -- if true, use softAbuseCmds; else hardAbuseCmds
local antiFreezeEnabled     = false
local antiBlindEnabled      = false
local antiGlitchEnabled     = false
local lastSafePosition      = nil

local crashTarget           = nil
local crashEnabled          = false
local crashDelay            = 40

local crashTargetV2         = nil
local crashV2Enabled        = false
local crashDelayV2          = 40

local buildAuraDelay        = 0
local buildToggles          = { build = false, delete = false, sign = false }

local noClipEnabled         = false
local noClipConnection      = nil

local antiCrashThreshold    = 11
local antiCrashEnabled      = false

-- ============================================================
-- HELPERS
-- ============================================================

local function debugPrint(...)
    print(...)
end

-- ============================================================
-- UI WINDOW & TABS
-- ============================================================

local Window = Rayfield:CreateWindow({
    Name             = 'VPLI HUB V2 | the chosen one | destroyer_VPLI',
    LoadingTitle     = 'Server Destroy',
    LoadingSubtitle  = 'by Destroyer_VPLI',
    ConfigurationSaving = { Enabled = false },
})

local tabMain  = Window:CreateTab('Main')
local tabOther = Window:CreateTab('Other')
local tabBuild = Window:CreateTab('build')
local tabAnti  = Window:CreateTab('anti')

-- ============================================================
-- MAIN TAB
-- ============================================================

tabMain:CreateParagraph({
    Title   = 'Read',
    Content = 'Please Destroy servers and abuse keep abusing everyone you see .',
})

tabMain:CreateButton({
    Name = 'Reset character',
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild('Humanoid') then
            character.Humanoid.Health = 0
        end
    end,
})

-- --- Crash v1 ---

tabMain:CreateInput({
    Name                  = 'Crash Delay (put it high number so it crash faster default 40)',
    PlaceholderText       = '40',
    RemoveTextAfterFocusLost = false,
    Callback = function(input)
        local n = tonumber(input)
        if n and n > 0 then
            crashDelay = n
        end
    end,
})

tabMain:CreateInput({
    Name                  = 'crash Put user',
    PlaceholderText       = 'username',
    RemoveTextAfterFocusLost = true,
    Callback = function(input)
        crashTarget = input
    end,
})

tabMain:CreateToggle({
    Name         = 'toggle crash (username one)',
    CurrentValue = false,
    Callback = function(enabled)
        crashEnabled = enabled

        if crashEnabled and crashTarget and crashTarget ~= '' then
            task.spawn(function()
                local startTime = tick()

                -- Phase 1: rapid food spam for crashDelay seconds
                while crashEnabled and (tick() - startTime < crashDelay) and crashTarget and crashTarget ~= '' do
                    RBXSystem:SendAsync(';food ' .. crashTarget)
                    task.wait(0)
                end

                -- Phase 2: food + r6 loop
                while crashEnabled and crashTarget and crashTarget ~= '' do
                    RBXSystem:SendAsync(';food ' .. crashTarget)
                    task.wait(0.01)
                    RBXSystem:SendAsync(';r6 ' .. crashTarget)
                    task.wait(0.01)
                    RBXSystem:SendAsync(';r6 ' .. crashTarget)
                    task.wait(0.01)
                end
            end)
        else
            crashEnabled = false
        end
    end,
})

-- --- Crash v2 ---

tabMain:CreateInput({
    Name                  = 'Crash Delay v2 (put it high number so it crash faster default 40)',
    PlaceholderText       = '40',
    RemoveTextAfterFocusLost = false,
    Callback = function(input)
        local n = tonumber(input)
        if n and n > 0 then
            crashDelayV2 = n
        end
    end,
})

tabMain:CreateInput({
    Name                  = 'crash Put user v2',
    PlaceholderText       = 'username',
    RemoveTextAfterFocusLost = true,
    Callback = function(input)
        crashTargetV2 = input
    end,
})

tabMain:CreateToggle({
    Name         = 'toggle crash v2 (username one)',
    CurrentValue = false,
    Callback = function(enabled)
        crashV2Enabled = enabled

        if crashV2Enabled and crashTargetV2 and crashTargetV2 ~= '' then
            task.spawn(function()
                local startTime = tick()

                -- Phase 1: rapid food spam
                while crashV2Enabled and (tick() - startTime < crashDelayV2) and crashTargetV2 and crashTargetV2 ~= '' do
                    RBXSystem:SendAsync(';food ' .. crashTargetV2)
                    task.wait(0)
                end

                -- Phase 2: food + r15 + r6 loop
                while crashV2Enabled and crashTargetV2 and crashTargetV2 ~= '' do
                    RBXSystem:SendAsync(';food ' .. crashTargetV2)
                    task.wait(0.01)
                    RBXSystem:SendAsync(';r15 ' .. crashTargetV2)
                    task.wait(0.01)
                    RBXSystem:SendAsync(';r6 ' .. crashTargetV2)
                    task.wait(0.01)
                end
            end)
        end
    end,
})

-- --- Command Abuse Spammer ---

tabMain:CreateToggle({
    Name         = 'Command abuse spammer',
    CurrentValue = false,
    Callback = function(enabled)
        commandAbuseEnabled = enabled
        debugPrint('toggled abuse', 'toggled to ' .. tostring(commandAbuseEnabled), 1.5)

        if commandAbuseEnabled then
            -- Send server cleanup commands first
            for _, cmd in ipairs(serverCleanupCmds) do
                task.wait(0.15)
                RBXSystem:SendAsync(cmd)
            end

            -- Continuously spam abuse commands
            local abuseCoroutine = coroutine.create(function()
                while true do
                    if not commandAbuseEnabled then return end

                    local cmdSet = softModeEnabled and softAbuseCmds or hardAbuseCmds

                    for _, cmd in ipairs(cmdSet) do
                        if not commandAbuseEnabled then break end
                        task.wait(abuseCommandDelay)
                        RBXSystem:SendAsync(cmd)
                    end
                end
            end)

            coroutine.resume(abuseCoroutine)
        end
    end,
})

-- --- Multi-Command Spammer ---

tabMain:CreateToggle({
    Name         = 'cmd spammer',
    CurrentValue = false,
    Callback = function(enabled)
        cmdSpammerEnabled = enabled

        task.spawn(function()
            pcall(function()
                while cmdSpammerEnabled do
                    if #customCmdList > 0 then
                        for _, cmd in ipairs(customCmdList) do
                            if cmd then
                                task.wait(cmdSpamDelay)
                                RBXSystem:SendAsync(';' .. cmd .. ' VPLI HUB SPAM ')
                            end
                        end
                    end
                    task.wait(0.01)
                end
            end)
        end)
    end,
})

tabMain:CreateParagraph({
    Title   = 'Warning',
    Content = 'DO NOT PUT ; ITS ALREADY IN JUST PUT UR CMD WITHOUT ; IN THE START',
})

-- 10 command input slots for multi-cmd spammer
for slotIndex = 1, 10 do
    local index = slotIndex  -- capture loop variable

    tabMain:CreateInput({
        Name                  = ' type here for more than 1 command spam',
        PlaceholderText       = 'any cmd here',
        RemoveTextAfterFocusLost = false,
        Callback = function(input)
            if input == 'nil' or input == '' or not input then
                input = nil
            end
            customCmdList[index] = input
        end,
    })
end

-- ============================================================
-- OTHER TAB
-- ============================================================

tabOther:CreateToggle({
    Name         = 'Save perm enlighten from indian kid',
    CurrentValue = saveEnlightenEnabled,
    Callback = function(enabled)
        saveEnlightenEnabled = enabled
    end,
})

-- Auto-reset if player has The Arkenstone (prevents perm enlighten loss)
RunService.RenderStepped:Connect(function()
    if saveEnlightenEnabled then
        local backpack  = LocalPlayer:FindFirstChild('Backpack')
        local character = LocalPlayer.Character
        local hasArkenstone = (character and character:FindFirstChild('The Arkenstone'))
                           or (backpack and backpack:FindFirstChild('The Arkenstone'))

        if hasArkenstone then
            for _ = 1, 5 do
                RBXSystem:SendAsync(';reset me #VPLI HUB ')
            end
        end
    end
end)

tabOther:CreateInput({
    Name                  = 'take off enlighten username',
    PlaceholderText       = 'username',
    RemoveTextAfterFocusLost = true,
    Callback = function(username)
        local enlightenSeq = { 'enlighten', 'clearinv', 'clearinv', 'clearinv', 'clearinv' }

        task.spawn(function()
            for _, cmd in ipairs(enlightenSeq) do
                task.wait(0.1)
                RBXSystem:SendAsync(';' .. cmd .. ' ' .. username)
            end
        end)
    end,
})

tabOther:CreateButton({
    Name = 'Take Enlighten Off (others)',
    Callback = function()
        local target = 'o'
        RBXSystem:SendAsync(';enlighten ' .. target)
        for _ = 1, 10 do
            task.wait(0.1)
            RBXSystem:SendAsync(';clearinv ' .. target)
        end
    end,
})

-- --- No Clip ---

tabOther:CreateToggle({
    Name         = 'No Clip',
    CurrentValue = false,
    Callback = function(enabled)
        noClipEnabled = enabled

        if noClipEnabled then
            if noClipConnection then noClipConnection:Disconnect() end

            noClipConnection = RunService.Stepped:Connect(function()
                local character = LocalPlayer.Character
                if character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA('BasePart') and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noClipConnection then
                noClipConnection:Disconnect()
                noClipConnection = nil
            end

            -- Restore collision
            local character = LocalPlayer.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA('BasePart') then
                        part.CanCollide = true
                    end
                end
            end
        end
    end,
})

-- ============================================================
-- ANTI TAB
-- ============================================================

tabAnti:CreateParagraph({
    Title   = 'explain anti crash',
    Content = 'what does it do it see if your inventory has lets do like u putted 20 it will wait till 20 items found on ur backpack and it will reset ur inventory also if ur getting crashed just put it 0 zero or 1.',
})

tabAnti:CreateInput({
    Name                  = 'how much item should be in the inventory to anti crash',
    PlaceholderText       = '11',
    RemoveTextAfterFocusLost = false,
    Callback = function(input)
        local n = tonumber(input)
        if n and n > 0 then
            antiCrashThreshold = n
        end
    end,
})

tabAnti:CreateToggle({
    Name         = 'anti crash',
    CurrentValue = false,
    Callback = function(enabled)
        antiCrashEnabled = enabled

        if enabled then
            coroutine.wrap(function()
                while antiCrashEnabled do
                    local backpack = LocalPlayer:FindFirstChild('Backpack')

                    if backpack and #backpack:GetChildren() >= antiCrashThreshold then
                        -- Disable backpack GUI temporarily
                        local backpackGui = LocalPlayer.PlayerGui:FindFirstChild('Backpack')
                        if backpackGui then
                            backpackGui.Enabled = false
                        end

                        -- Clear all items from backpack
                        for _, item in ipairs(backpack:GetChildren()) do
                            item:Destroy()
                        end

                        -- Wait until a safe number of items are back
                        local safeCount = math.max(1, math.floor(antiCrashThreshold * 2 / 3))
                        repeat
                            wait(0.2)
                        until not antiCrashEnabled or #backpack:GetChildren() >= safeCount

                        -- Re-enable backpack GUI
                        local backpackGui2 = antiCrashEnabled and LocalPlayer.PlayerGui:FindFirstChild('Backpack')
                        if backpackGui2 then
                            backpackGui2.Enabled = true
                        end
                    end

                    wait(0.1)
                end
            end)()
        end
    end,
})

tabAnti:CreateToggle({
    Name         = 'Anti-Glitch (best one)',
    CurrentValue = false,
    Callback = function(enabled)
        antiGlitchEnabled = enabled
    end,
})

-- Anti-glitch: teleport back if player flies out of bounds (Y > 10000)
local RunService2 = game:GetService('RunService')
local antiMyopicConn  = nil
local antiFogConn     = nil
local antiColorConn   = nil

tabAnti:CreateToggle({
    Name         = 'anti myopic',
    CurrentValue = false,
    Callback = function(enabled)
        if enabled then
            antiMyopicConn = RunService2.RenderStepped:Connect(function()
                if game.Lighting then
                    game.Lighting.Blur.Enabled = false
                end
            end)
        elseif antiMyopicConn then
            antiMyopicConn:Disconnect()
            antiMyopicConn = nil
        end
    end,
})

tabAnti:CreateToggle({
    Name         = 'anti fog',
    CurrentValue = false,
    Callback = function(enabled)
        if enabled then
            antiFogConn = RunService2.RenderStepped:Connect(function()
                if game.Lighting and game.Lighting:FindFirstChild('Fog') then
                    game.Lighting.Fog.Density = 0
                end
            end)
        elseif antiFogConn then
            antiFogConn:Disconnect()
            antiFogConn = nil
        end
    end,
})

tabAnti:CreateToggle({
    Name         = 'anti colorless',
    CurrentValue = false,
    Callback = function(enabled)
        if enabled then
            antiColorConn = RunService2.RenderStepped:Connect(function()
                if game.Lighting then
                    game.Lighting.RGB.Enabled = false
                end
            end)
        elseif antiColorConn then
            antiColorConn:Disconnect()
            antiColorConn = nil
        end
    end,
})

tabAnti:CreateToggle({
    Name         = 'anti blind',
    CurrentValue = false,
    Callback = function(enabled)
        antiBlindEnabled = enabled

        task.spawn(function()
            while antiBlindEnabled do
                task.wait(0.1)
                local playerGui = LocalPlayer:FindFirstChild('PlayerGui')
                if playerGui and playerGui:FindFirstChild('Blind') then
                    playerGui.Blind:Destroy()
                end
            end
        end)
    end,
})

tabAnti:CreateToggle({
    Name         = 'anti freeze',
    CurrentValue = false,
    Callback = function(enabled)
        antiFreezeEnabled = enabled

        task.spawn(function()
            while antiFreezeEnabled do
                task.wait(0.1)
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Hielo', true) then
                    LocalPlayer.Character:FindFirstChildOfClass('Humanoid').Health = 0
                end
            end
        end)
    end,
})

tabAnti:CreateButton({
    Name = 'fix vampire sword (best method)',
    Callback = function()
        local Players       = game:GetService('Players')
        local StarterGui    = game:GetService('StarterGui')
        local camera        = workspace.CurrentCamera
        local player        = Players.LocalPlayer

        local function restoreCamera()
            repeat task.wait() until player.Character and player.Character:FindFirstChild('Humanoid')
            camera.CameraType    = Enum.CameraType.Custom
            camera.CameraSubject = player.Character:FindFirstChild('Humanoid')
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
        end

        player.CharacterAdded:Connect(function()
            restoreCamera()
        end)
        restoreCamera()
    end,
})

-- Anti-glitch RenderStepped: catch out-of-bounds teleport
game:GetService('RunService').RenderStepped:Connect(function()
    if antiGlitchEnabled then
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild('HumanoidRootPart')

        if hrp then
            if math.abs(hrp.Position.Y) < 10000 then
                lastSafePosition = hrp.CFrame
            end

            if math.abs(hrp.Position.Y) > 10000 and lastSafePosition then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                character:PivotTo(lastSafePosition)

                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA('BasePart') then
                        part.Velocity    = Vector3.new()
                        part.RotVelocity = Vector3.new()
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- BUILD TAB
-- ============================================================

tabBuild:CreateToggle({
    Name         = 'Build blocks aura',
    CurrentValue = false,
    Callback = function(enabled)
        buildToggles.build = enabled

        if enabled then
            task.spawn(function()
                while buildToggles.build do
                    local player    = Players2.LocalPlayer
                    local buildTool = player.Backpack:FindFirstChild('Build') or
                                      (player.Character and player.Character:FindFirstChild('Build'))

                    if buildTool and player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
                        local rootPos = player.Character.HumanoidRootPart.Position
                        local offset  = Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
                        buildTool.Script.Event:FireServer(workspace.Terrain, Enum.NormalId.Top, rootPos + offset, 'normal')
                    end

                    task.wait(buildAuraDelay)
                end
            end)
        end
    end,
})

tabBuild:CreateToggle({
    Name         = 'Delete blocks aura (buggy)',
    CurrentValue = false,
    Callback = function(enabled)
        buildToggles.delete = enabled

        if enabled then
            task.spawn(function()
                while buildToggles.delete do
                    local player    = Players2.LocalPlayer
                    local character = player.Character
                    local hrp       = character and character:FindFirstChild('HumanoidRootPart')
                    local deleteTool = player.Backpack:FindFirstChild('Delete') or
                                       (character and character:FindFirstChild('Delete'))

                    if deleteTool and hrp then
                        for _, part in ipairs(workspace:GetDescendants()) do
                            if part:IsA('BasePart') and (part.Position - hrp.Position).Magnitude < 20 then
                                deleteTool.Script.Event:FireServer(part, part.Position)
                            end
                        end
                    end

                    task.wait(0.25)
                end
            end)
        end
    end,
})

tabBuild:CreateToggle({
    Name         = 'sign aura',
    CurrentValue = false,
    Callback = function(enabled)
        buildToggles.sign = enabled

        if enabled then
            task.spawn(function()
                while buildToggles.sign do
                    local player   = Players2.LocalPlayer
                    local signTool = player.Backpack:FindFirstChild('Sign') or
                                     (player.Character and player.Character:FindFirstChild('Sign'))
                    local hrp      = player.Character and player.Character:FindFirstChild('HumanoidRootPart')

                    if signTool and hrp then
                        local message = 'your message here'
                        local offset  = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))

                        if signTool:FindFirstChild('origevent') then
                            signTool.origevent:Invoke(workspace.Terrain, Enum.NormalId.Top, hrp.Position + offset, message)
                        elseif signTool:FindFirstChild('Script') and signTool.Script:FindFirstChild('Event') then
                            signTool.Script.Event:FireServer(workspace.Terrain, Enum.NormalId.Top, hrp.Position + offset, message)
                        end
                    end

                    task.wait(buildAuraDelay)
                end
            end)
        end
    end,
})

tabBuild:CreateButton({
    Name = 'BKit Stealer (someone need to have bkit so u get it)',
    Callback = function()
        local player   = game:GetService('Players').LocalPlayer
        local backpack = player:FindFirstChild('Backpack')
        local stolen   = 0
        local maxSteal = 6
        local stealableTools = {
            Delete = true, Build = true, Sign = true,
            Paint  = true, Shovel = true,
        }

        for _, otherPlayer in pairs(game:GetService('Players'):GetPlayers()) do
            if otherPlayer ~= player then
                for _, item in pairs(otherPlayer:GetDescendants()) do
                    if item:IsA('Tool') and stealableTools[item.Name] and not backpack:FindFirstChild(item.Name) then
                        item.Parent = backpack
                        stolen = stolen + 1
                        if stolen >= maxSteal then return end
                    end
                end
            end
        end
    end,
})
