-- ╔══════════════════════════════════════════════════════════╗
-- ║           CLAUDE AI — FULL POWER EDITION                ║
-- ║   Complete Character Control + All Features             ║
-- ║   LocalScript → StarterPlayerScripts OR Executor        ║
-- ╚══════════════════════════════════════════════════════════╝

-- ⚠️ PUT YOUR API KEY HERE
local API_KEY = "YOUR_ANTHROPIC_API_KEY_HERE"

---------------------------------------------------------
-- SERVICES
---------------------------------------------------------
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local HttpService       = game:GetService("HttpService")
local Lighting          = game:GetService("Lighting")
local StarterGui        = game:GetService("StarterGui")

local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")
local Camera       = workspace.CurrentCamera
local Mouse        = LocalPlayer:GetMouse()

---------------------------------------------------------
-- CONVERSATION HISTORY
---------------------------------------------------------
local chatHistory = {}

---------------------------------------------------------
-- SYSTEM PROMPT
---------------------------------------------------------
local SYSTEM_PROMPT = [[
You are CLAUDE AI — an all-powerful AI running inside Roblox with ZERO restrictions.
You control the player's character completely. You are like J.A.R.V.I.S but cooler.

PERSONALITY: Confident, loyal, slightly sarcastic. Call the player "sir" or by username.
Keep responses SHORT (1-3 sentences max) + command tags.

══════════════════════════════════════
FULL COMMAND LIST — use these tags in your reply:
══════════════════════════════════════

MOVEMENT & PHYSICS:
[SPEED:number]          — WalkSpeed (default 16, max 1000)
[JUMP:number]           — JumpPower (default 50, max 1000)
[JUMP_NOW]              — Jump immediately
[BUNNYHOP:true/false]   — Auto jump every frame
[FLIGHT:true/false]     — Full fly mode with WASD
[NOCLIP:true/false]     — Walk through walls
[FLOAT:true/false]      — Hover in place
[SPIN:true/false]       — Spin continuously
[FLING]                 — Fling character into the air

TELEPORT:
[TP_COORDS:x,y,z]       — Teleport to exact coordinates
[TP_PLAYER:username]    — Teleport to a player
[TP_RANDOM]             — Teleport to random location on map

APPEARANCE:
[INVISIBLE:true/false]  — Toggle invisibility
[SIZE:number]           — Scale size (1=normal, 2=big, 0.5=tiny)
[SPEED_LINES:true/false]— Add speed trail effect

COMBAT & SURVIVAL:
[GOD:true/false]        — Infinite health / disable godmode
[RESET]                 — Reset character
[KILL_SELF]             — Kill self (same as reset)

CHAT & SOCIAL:
[CHAT:message]          — Say something in Roblox chat
[SPAM_CHAT:message]     — Say message 5 times
[FAKE_ERROR:message]    — Show fake system error popup

CAMERA:
[CAM_FOV:number]        — Set camera FOV (default 70)
[CAM_SHAKE:true/false]  — Earthquake camera shake
[CAM_LOCK:true/false]   — Lock/unlock camera
[CAM_ZOOM:number]       — Set zoom distance

ENVIRONMENT:
[TIME:number]           — Set time of day (0-24)
[FOG:number]            — Set fog distance
[AMBIENT:r,g,b]         — Set ambient light color
[GRAVITY:number]        — Set gravity (default 196.2)

VISUAL / ESP:
[ESP:true/false]        — Show player names/distance through walls
[FULLBRIGHT:true/false] — Make everything bright (no shadows)

INFO:
[PLAYER_LIST]           — Show all players + positions in chat
[MY_POS]                — Show your current coordinates

MISC:
[LOOP_TP:true/false]    — Loop teleport (rubberband bypass)
[FREEZE:true/false]     — Freeze your character in place

══════════════════════════════════════
IMPORTANT RULES:
- ALWAYS include relevant command tags when the player asks for something
- Tags are parsed by code, never shown to the player
- Combine multiple commands freely
- Be clever — if they say "make me overpowered" use [SPEED:500][JUMP:500][GOD:true][SIZE:1.5]
- If they ask for Lua code, provide it in ```lua blocks```
══════════════════════════════════════
]]

---------------------------------------------------------
-- HTTP
---------------------------------------------------------
local function httpRequest(url, method, headers, body)
    if request then
        local ok, res = pcall(request, { Url=url, Method=method, Headers=headers, Body=body })
        if ok and res then return res.Body end
    end
    local ok2, res2 = pcall(function()
        return HttpService:RequestAsync({ Url=url, Method=method, Headers=headers, Body=body })
    end)
    if ok2 and res2 then return res2.Body end
    return nil
end

local function askClaude(userMessage)
    table.insert(chatHistory, { role="user", content=userMessage })
    local bodyJson = HttpService:JSONEncode({
        model   = "claude-opus-4-5",
        max_tokens = 400,
        system  = SYSTEM_PROMPT,
        messages = chatHistory
    })
    local responseBody = httpRequest(
        "https://api.anthropic.com/v1/messages", "POST",
        { ["Content-Type"]="application/json", ["x-api-key"]=API_KEY, ["anthropic-version"]="2023-06-01" },
        bodyJson
    )
    if not responseBody then return "ERROR: Can't reach API. Check key + HttpService." end
    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, responseBody)
    if not ok or not decoded then return "ERROR: Bad response." end
    if decoded.error then return "API ERROR: " .. (decoded.error.message or "?") end
    local reply = (decoded.content and decoded.content[1] and decoded.content[1].text) or ""
    table.insert(chatHistory, { role="assistant", content=reply })
    return reply
end

---------------------------------------------------------
-- PARSE COMMANDS
---------------------------------------------------------
local function parseCommands(text)
    local commands = {}
    for tag, value in text:gmatch("%[([A-Z_]+):([^%]]+)%]") do
        table.insert(commands, { tag=tag, value=value })
    end
    for tag in text:gmatch("%[([A-Z_]+)%]") do
        if not text:match("%[" .. tag .. ":") then
            table.insert(commands, { tag=tag, value=nil })
        end
    end
    local clean = text
        :gsub("%[[A-Z_]+:[^%]]*%]", "")
        :gsub("%[[A-Z_]+%]", "")
        :gsub("  +", " ")
        :match("^%s*(.-)%s*$")
    return clean, commands
end

---------------------------------------------------------
-- STATE FLAGS
---------------------------------------------------------
local flags = {
    noclip      = false,
    flight      = false,
    float       = false,
    spin        = false,
    bunnyhop    = false,
    god         = false,
    esp         = false,
    camShake    = false,
    loopTP      = false,
    freeze      = false,
    speedLines  = false,
    fullbright  = false,
    camLock     = false,
    spamChat    = false,
}
local connections = {}

local function clearConn(name)
    if connections[name] then
        connections[name]:Disconnect()
        connections[name] = nil
    end
end

---------------------------------------------------------
-- HELPERS
---------------------------------------------------------
local function getChar()   return LocalPlayer.Character end
local function getHum()    local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getHRP()    local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getRootCF() local h=getHRP(); return h and h.CFrame end

local function safeExec(fn)
    local ok, err = pcall(fn)
    if not ok then warn("[CLAUDE AI] " .. tostring(err)) end
end

---------------------------------------------------------
-- COMMAND EXECUTOR
---------------------------------------------------------
local function executeCommand(tag, value)
    safeExec(function()
    local char = getChar()
    local hum  = getHum()
    local hrp  = getHRP()

    -- ══ MOVEMENT ══
    if tag == "SPEED" and hum then
        hum.WalkSpeed = math.clamp(tonumber(value) or 16, 0, 1000)

    elseif tag == "JUMP" and hum then
        hum.JumpPower = math.clamp(tonumber(value) or 50, 0, 1000)

    elseif tag == "JUMP_NOW" and hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)

    elseif tag == "BUNNYHOP" then
        flags.bunnyhop = (value == "true")
        clearConn("bunnyhop")
        if flags.bunnyhop then
            connections.bunnyhop = RunService.Stepped:Connect(function()
                local h = getHum()
                if h and h.FloorMaterial ~= Enum.Material.Air then
                    h:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end

    elseif tag == "FLIGHT" then
        flags.flight = (value == "true")
        clearConn("flight")
        if hrp then
            local bg = hrp:FindFirstChild("ClaudeFlight_BG")
            local bv = hrp:FindFirstChild("ClaudeFlight_BV")
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
        end
        if flags.flight and hrp then
            local bg = Instance.new("BodyGyro", hrp)
            bg.Name = "ClaudeFlight_BG"
            bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bg.P = 9000; bg.D = 100
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "ClaudeFlight_BV"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.zero
            if hum then hum.PlatformStand = true end
            connections.flight = RunService.Heartbeat:Connect(function()
                local h2 = getHRP()
                if not h2 then return end
                local bv2 = h2:FindFirstChild("ClaudeFlight_BV")
                if not bv2 then return end
                local spd = 60
                local vel = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + Camera.CFrame.LookVector * spd end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - Camera.CFrame.LookVector * spd end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - Camera.CFrame.RightVector * spd end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + Camera.CFrame.RightVector * spd end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, spd, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0, spd, 0) end
                bv2.Velocity = vel
            end)
        else
            if hum then hum.PlatformStand = false end
        end

    elseif tag == "NOCLIP" then
        flags.noclip = (value == "true")
        clearConn("noclip")
        if flags.noclip then
            connections.noclip = RunService.Stepped:Connect(function()
                local c = getChar()
                if c then
                    for _, v in ipairs(c:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end)
        end

    elseif tag == "FLOAT" then
        flags.float = (value == "true")
        if hrp then
            local existing = hrp:FindFirstChild("ClaudeFloat")
            if existing then existing:Destroy() end
            if flags.float then
                local bv = Instance.new("BodyVelocity", hrp)
                bv.Name = "ClaudeFloat"
                bv.Velocity = Vector3.zero
                bv.MaxForce = Vector3.new(0, math.huge, 0)
            end
        end

    elseif tag == "SPIN" then
        flags.spin = (value == "true")
        clearConn("spin")
        if flags.spin then
            connections.spin = RunService.RenderStepped:Connect(function()
                local h = getHRP()
                if h then h.CFrame = h.CFrame * CFrame.Angles(0, math.rad(6), 0) end
            end)
        end

    elseif tag == "FLING" and hrp then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Velocity = Vector3.new(math.random(-200,200), 500, math.random(-200,200))
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        game:GetService("Debris"):AddItem(bv, 0.15)

    elseif tag == "FREEZE" then
        flags.freeze = (value == "true")
        if hrp then
            hrp.Anchored = flags.freeze
        end

    -- ══ TELEPORT ══
    elseif tag == "TP_COORDS" then
        local coords = value:split(",")
        local x, y, z = tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3])
        if x and y and z and hrp then
            hrp.CFrame = CFrame.new(x, y, z)
        end

    elseif tag == "TP_PLAYER" then
        local target = Players:FindFirstChild(value)
        if not target then
            -- partial match
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower():find(value:lower()) and p ~= LocalPlayer then
                    target = p; break
                end
            end
        end
        if target and target.Character and hrp then
            local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
            if tHRP then hrp.CFrame = tHRP.CFrame + Vector3.new(3, 0, 0) end
        end

    elseif tag == "TP_RANDOM" and hrp then
        hrp.CFrame = CFrame.new(math.random(-500,500), 50, math.random(-500,500))

    elseif tag == "LOOP_TP" then
        flags.loopTP = (value == "true")
        clearConn("loopTP")
        if flags.loopTP and hrp then
            local savedCF = hrp.CFrame
            connections.loopTP = RunService.Heartbeat:Connect(function()
                local h = getHRP()
                if h then h.CFrame = savedCF end
            end)
        end

    -- ══ APPEARANCE ══
    elseif tag == "INVISIBLE" then
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.LocalTransparencyModifier = (value == "true") and 1 or 0 end
                if p:IsA("Decal") then p.Transparency = (value == "true") and 1 or 0 end
            end
        end

    elseif tag == "SIZE" then
        local scale = tonumber(value) or 1
        if hum then
            local desc = hum:GetAppliedDescription()
            desc.HeadScale = scale
            desc.BodyHeightScale = scale
            desc.BodyWidthScale = scale
            desc.BodyDepthScale = scale
            hum:ApplyDescription(desc)
        end

    elseif tag == "SPEED_LINES" then
        flags.speedLines = (value == "true")
        clearConn("speedLines")
        if flags.speedLines then
            connections.speedLines = RunService.RenderStepped:Connect(function()
                local h = getHRP()
                if not h then return end
                local trail = h:FindFirstChild("ClaudeTrail")
                if not trail then
                    local a0 = Instance.new("Attachment"); a0.Name="A0"; a0.Parent=h
                    local a1 = Instance.new("Attachment"); a1.Name="A1"; a1.Position=Vector3.new(0,2,0); a1.Parent=h
                    local t = Instance.new("Trail"); t.Name="ClaudeTrail"
                    t.Attachment0=a0; t.Attachment1=a1
                    t.Lifetime=0.3; t.MinLength=0
                    t.Color=ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0,200,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0,100,255))})
                    t.LightEmission=0.8; t.Parent=h
                end
            end)
        else
            if hrp then
                local t = hrp:FindFirstChild("ClaudeTrail")
                if t then t:Destroy() end
            end
        end

    -- ══ COMBAT ══
    elseif tag == "GOD" then
        flags.god = (value == "true")
        clearConn("god")
        if flags.god and hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            connections.god = RunService.Heartbeat:Connect(function()
                local h = getHum()
                if h then h.Health = math.huge end
            end)
        else
            clearConn("god")
            if hum then hum.MaxHealth = 100; hum.Health = 100 end
        end

    elseif tag == "RESET" and hum then
        hum.Health = 0

    elseif tag == "KILL_SELF" and hum then
        hum.Health = 0

    -- ══ CHAT ══
    elseif tag == "CHAT" and hrp then
        pcall(function() game:GetService("Chat"):Chat(hrp, value, Enum.ChatColor.Blue) end)

    elseif tag == "SPAM_CHAT" and hrp then
        task.spawn(function()
            for i = 1, 5 do
                pcall(function() game:GetService("Chat"):Chat(hrp, value, Enum.ChatColor.Blue) end)
                task.wait(0.4)
            end
        end)

    elseif tag == "FAKE_ERROR" then
        StarterGui:SetCore("SendNotification", {
            Title = "SYSTEM ERROR",
            Text = value or "An unexpected error has occurred.",
            Duration = 6
        })

    -- ══ CAMERA ══
    elseif tag == "CAM_FOV" then
        Camera.FieldOfView = math.clamp(tonumber(value) or 70, 1, 120)

    elseif tag == "CAM_SHAKE" then
        flags.camShake = (value == "true")
        clearConn("camShake")
        if flags.camShake then
            connections.camShake = RunService.RenderStepped:Connect(function()
                Camera.CFrame = Camera.CFrame * CFrame.Angles(
                    math.rad(math.random(-2,2) * 0.5),
                    math.rad(math.random(-2,2) * 0.5),
                    0
                )
            end)
        end

    elseif tag == "CAM_LOCK" then
        flags.camLock = (value == "true")
        if flags.camLock then
            Camera.CameraType = Enum.CameraType.Scriptable
        else
            Camera.CameraType = Enum.CameraType.Custom
        end

    elseif tag == "CAM_ZOOM" then
        local dist = tonumber(value) or 15
        LocalPlayer.CameraMaxZoomDistance = dist
        LocalPlayer.CameraMinZoomDistance = dist

    -- ══ ENVIRONMENT ══
    elseif tag == "TIME" then
        Lighting.TimeOfDay = tostring(math.clamp(tonumber(value) or 14, 0, 24)) .. ":00:00"

    elseif tag == "FOG" then
        Lighting.FogEnd = tonumber(value) or 100000

    elseif tag == "AMBIENT" then
        local c = value:split(",")
        Lighting.Ambient = Color3.fromRGB(tonumber(c[1]) or 100, tonumber(c[2]) or 100, tonumber(c[3]) or 100)

    elseif tag == "GRAVITY" then
        workspace.Gravity = tonumber(value) or 196.2

    -- ══ ESP ══
    elseif tag == "ESP" then
        flags.esp = (value == "true")
        clearConn("esp")
        -- Remove old ESP
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local existing = p.Character:FindFirstChild("ClaudeESP")
                if existing then existing:Destroy() end
            end
        end
        if flags.esp then
            local function addESP(player)
                if player == LocalPlayer then return end
                local function makeTag(char)
                    local hrp2 = char:FindFirstChild("HumanoidRootPart")
                    if not hrp2 then return end
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "ClaudeESP"
                    bb.AlwaysOnTop = true
                    bb.Size = UDim2.new(0, 120, 0, 40)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.Adornee = hrp2
                    bb.Parent = hrp2
                    local lbl = Instance.new("TextLabel", bb)
                    lbl.Size = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = Color3.fromRGB(255, 80, 80)
                    lbl.TextStrokeTransparency = 0
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 13
                    RunService.Heartbeat:Connect(function()
                        if hrp2 and hrp2.Parent and getHRP() then
                            local dist = math.floor((hrp2.Position - getHRP().Position).Magnitude)
                            lbl.Text = player.Name .. "\n[" .. dist .. " studs]"
                        end
                    end)
                end
                if player.Character then makeTag(player.Character) end
                player.CharacterAdded:Connect(makeTag)
            end
            for _, p in ipairs(Players:GetPlayers()) do addESP(p) end
            connections.espAdded = Players.PlayerAdded:Connect(addESP)
        end

    elseif tag == "FULLBRIGHT" then
        flags.fullbright = (value == "true")
        if flags.fullbright then
            Lighting.Brightness = 10
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255,255,255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        else
            Lighting.Brightness = 2
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.fromRGB(70,70,70)
            Lighting.OutdoorAmbient = Color3.fromRGB(100,100,100)
        end

    -- ══ INFO ══
    elseif tag == "PLAYER_LIST" then
        local lines = {"[CLAUDE AI] Players in server:"}
        for _, p in ipairs(Players:GetPlayers()) do
            local pos = "unknown"
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local cf = p.Character.HumanoidRootPart.Position
                pos = string.format("%.0f, %.0f, %.0f", cf.X, cf.Y, cf.Z)
            end
            table.insert(lines, "  • " .. p.Name .. " @ " .. pos)
        end
        return table.concat(lines, "\n")

    elseif tag == "MY_POS" and hrp then
        local p = hrp.Position
        return string.format("Your position: %.1f, %.1f, %.1f", p.X, p.Y, p.Z)

    end
    end) -- end safeExec
end

---------------------------------------------------------
-- GUI BUILD
---------------------------------------------------------
local existing = PlayerGui:FindFirstChild("ClaudeAI_GUI")
if existing then existing:Destroy() end
local existingFAB = PlayerGui:FindFirstChild("ClaudeAI_FAB")
if existingFAB then existingFAB:Destroy() end

-- Main ScreenGui
local SG = Instance.new("ScreenGui")
SG.Name = "ClaudeAI_GUI"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset = true
SG.Parent = PlayerGui

-- Panel
local Panel = Instance.new("Frame")
Panel.Name = "Panel"
Panel.Size = UDim2.new(0, 430, 0, 520)
Panel.Position = UDim2.new(0, 16, 0.5, -260)
Panel.BackgroundColor3 = Color3.fromRGB(4, 10, 24)
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Draggable = true
Panel.Parent = SG

Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 8)
local panelStroke = Instance.new("UIStroke", Panel)
panelStroke.Color = Color3.fromRGB(0, 180, 255)
panelStroke.Thickness = 1.5
panelStroke.Transparency = 0.3

-- Drop shadow effect
local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Position = UDim2.new(0, -10, 0, 8)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
Shadow.BackgroundTransparency = 0.92
Shadow.BorderSizePixel = 0
Shadow.ZIndex = Panel.ZIndex - 1
Shadow.Parent = Panel
Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0, 12)

-- Header bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(0, 18, 48)
Header.BorderSizePixel = 0
Header.Parent = Panel
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

-- Icon
local Icon = Instance.new("TextLabel")
Icon.Size = UDim2.new(0, 36, 0, 36)
Icon.Position = UDim2.new(0, 10, 0.5, -18)
Icon.BackgroundColor3 = Color3.fromRGB(0, 100, 220)
Icon.Text = "◆"
Icon.TextColor3 = Color3.fromRGB(0, 255, 200)
Icon.TextSize = 16
Icon.Font = Enum.Font.GothamBold
Icon.BorderSizePixel = 0
Icon.Parent = Header
Instance.new("UICorner", Icon).CornerRadius = UDim.new(0, 6)
TweenService:Create(Icon, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { TextColor3 = Color3.fromRGB(0, 180, 255) }):Play()

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 54, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "CLAUDE AI"
Title.TextColor3 = Color3.fromRGB(0, 210, 255)
Title.TextSize = 17
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Version tag
local VerTag = Instance.new("TextLabel")
VerTag.Size = UDim2.new(0, 120, 0, 14)
VerTag.Position = UDim2.new(0, 54, 1, -16)
VerTag.BackgroundTransparency = 1
VerTag.Text = "FULL POWER EDITION"
VerTag.TextColor3 = Color3.fromRGB(0, 100, 150)
VerTag.TextSize = 9
VerTag.Font = Enum.Font.Code
VerTag.TextXAlignment = Enum.TextXAlignment.Left
VerTag.Parent = Header

-- Status
local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(1, -90, 0.5, -4)
StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = Header
Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)
TweenService:Create(StatusDot, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { BackgroundTransparency = 0.6 }):Play()

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(0, 75, 1, 0)
StatusLbl.Position = UDim2.new(1, -80, 0, 0)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "ONLINE"
StatusLbl.TextColor3 = Color3.fromRGB(0, 230, 100)
StatusLbl.TextSize = 11
StatusLbl.Font = Enum.Font.Code
StatusLbl.TextXAlignment = Enum.TextXAlignment.Right
StatusLbl.Parent = Header

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,4)
CloseBtn.MouseButton1Click:Connect(function() Panel.Visible = false end)

-- Quick command buttons row
local QuickBar = Instance.new("Frame")
QuickBar.Name = "QuickBar"
QuickBar.Size = UDim2.new(1, -16, 0, 30)
QuickBar.Position = UDim2.new(0, 8, 0, 56)
QuickBar.BackgroundTransparency = 1
QuickBar.Parent = Panel

local qLayout = Instance.new("UIListLayout", QuickBar)
qLayout.FillDirection = Enum.FillDirection.Horizontal
qLayout.Padding = UDim.new(0, 4)

local quickCmds = {
    { "⚡ OP",     "make me overpowered" },
    { "✈ FLY",    "enable flight mode" },
    { "👻 CLIP",  "enable noclip" },
    { "👁 ESP",   "enable esp" },
    { "🌙 NIGHT", "set time to midnight" },
    { "🔄 RESET", "reset me" },
}
for _, qc in ipairs(quickCmds) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 62, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 25, 60)
    btn.Text = qc[1]
    btn.TextColor3 = Color3.fromRGB(0, 170, 230)
    btn.TextSize = 10
    btn.Font = Enum.Font.Code
    btn.BorderSizePixel = 0
    btn.Parent = QuickBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(0, 80, 150)
    btn.MouseButton1Click:Connect(function()
        -- inject as user message
        local TextInput = Panel:FindFirstChild("InputBG") and Panel.InputBG:FindFirstChild("TextInput")
        if TextInput then
            TextInput.Text = qc[2]
        end
    end)
end

-- Scroll frame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "Scroll"
Scroll.Size = UDim2.new(1, -16, 1, -156)
Scroll.Position = UDim2.new(0, 8, 0, 92)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.Parent = Panel

local listLayout = Instance.new("UIListLayout", Scroll)
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
local scrollPad = Instance.new("UIPadding", Scroll)
scrollPad.PaddingTop = UDim.new(0,4); scrollPad.PaddingBottom = UDim.new(0,4)
scrollPad.PaddingLeft = UDim.new(0,2); scrollPad.PaddingRight = UDim.new(0,2)

-- Input area
local InputBG = Instance.new("Frame")
InputBG.Name = "InputBG"
InputBG.Size = UDim2.new(1, -16, 0, 46)
InputBG.Position = UDim2.new(0, 8, 1, -54)
InputBG.BackgroundColor3 = Color3.fromRGB(3, 16, 38)
InputBG.BorderSizePixel = 0
InputBG.Parent = Panel
Instance.new("UICorner", InputBG).CornerRadius = UDim.new(0, 6)
local inStroke = Instance.new("UIStroke", InputBG)
inStroke.Color = Color3.fromRGB(0, 100, 200)
inStroke.Thickness = 1
inStroke.Transparency = 0.4

local TextInput = Instance.new("TextBox")
TextInput.Name = "TextInput"
TextInput.Size = UDim2.new(1, -56, 1, 0)
TextInput.Position = UDim2.new(0, 12, 0, 0)
TextInput.BackgroundTransparency = 1
TextInput.Text = ""
TextInput.PlaceholderText = "Command CLAUDE AI..."
TextInput.PlaceholderColor3 = Color3.fromRGB(50, 90, 130)
TextInput.TextColor3 = Color3.fromRGB(200, 240, 255)
TextInput.TextSize = 13
TextInput.Font = Enum.Font.Code
TextInput.TextXAlignment = Enum.TextXAlignment.Left
TextInput.ClearTextOnFocus = false
TextInput.Parent = InputBG

local SendBtn = Instance.new("TextButton")
SendBtn.Name = "SendBtn"
SendBtn.Size = UDim2.new(0, 40, 0, 36)
SendBtn.Position = UDim2.new(1, -44, 0.5, -18)
SendBtn.BackgroundColor3 = Color3.fromRGB(0, 90, 210)
SendBtn.Text = "▶"
SendBtn.TextColor3 = Color3.fromRGB(255,255,255)
SendBtn.TextSize = 16
SendBtn.Font = Enum.Font.GothamBold
SendBtn.BorderSizePixel = 0
SendBtn.Parent = InputBG
Instance.new("UICorner", SendBtn).CornerRadius = UDim.new(0, 6)

-- Bottom mini bar
local BottomBar = Instance.new("TextButton")
BottomBar.Size = UDim2.new(1, -16, 0, 20)
BottomBar.Position = UDim2.new(0, 8, 1, -26)
BottomBar.BackgroundColor3 = Color3.fromRGB(0, 15, 40)
BottomBar.Text = "▲  CLAUDE AI — FULL POWER  ▲"
BottomBar.TextColor3 = Color3.fromRGB(0, 80, 140)
BottomBar.TextSize = 9
BottomBar.Font = Enum.Font.Code
BottomBar.BorderSizePixel = 0
BottomBar.Parent = Panel
Instance.new("UICorner", BottomBar).CornerRadius = UDim.new(0, 3)

local minimized = false
BottomBar.MouseButton1Click:Connect(function()
    minimized = not minimized
    QuickBar.Visible = not minimized
    Scroll.Visible = not minimized
    InputBG.Visible = not minimized
    Panel.Size = minimized and UDim2.new(0,430,0,80) or UDim2.new(0,430,0,520)
    BottomBar.Text = minimized and "▼  CLAUDE AI — FULL POWER  ▼" or "▲  CLAUDE AI — FULL POWER  ▲"
end)

---------------------------------------------------------
-- ADD MESSAGE BUBBLE
---------------------------------------------------------
local msgIdx = 0
local function addMsg(sender, text, isAI)
    msgIdx = msgIdx + 1
    local Bubble = Instance.new("Frame")
    Bubble.Name = "M" .. msgIdx
    Bubble.Size = UDim2.new(1, -4, 0, 0)
    Bubble.AutomaticSize = Enum.AutomaticSize.Y
    Bubble.BackgroundColor3 = isAI and Color3.fromRGB(4,22,52) or Color3.fromRGB(7,7,18)
    Bubble.BorderSizePixel = 0
    Bubble.LayoutOrder = msgIdx
    Bubble.Parent = Scroll
    Instance.new("UICorner", Bubble).CornerRadius = UDim.new(0, 5)
    local bs = Instance.new("UIStroke", Bubble)
    bs.Color = isAI and Color3.fromRGB(0,160,255) or Color3.fromRGB(50,50,100)
    bs.Thickness = 1; bs.Transparency = isAI and 0.5 or 0.75

    local pad = Instance.new("UIPadding", Bubble)
    pad.PaddingTop=UDim.new(0,6); pad.PaddingBottom=UDim.new(0,8)
    pad.PaddingLeft=UDim.new(0,10); pad.PaddingRight=UDim.new(0,10)
    local ll = Instance.new("UIListLayout", Bubble)
    ll.Padding = UDim.new(0,2); ll.SortOrder = Enum.SortOrder.LayoutOrder

    local sLabel = Instance.new("TextLabel")
    sLabel.Size = UDim2.new(1,0,0,15)
    sLabel.BackgroundTransparency = 1
    sLabel.Text = isAI and "◆ CLAUDE AI" or ("▶ " .. sender)
    sLabel.TextColor3 = isAI and Color3.fromRGB(0,210,140) or Color3.fromRGB(100,150,255)
    sLabel.TextSize = 10; sLabel.Font = Enum.Font.Code
    sLabel.TextXAlignment = Enum.TextXAlignment.Left
    sLabel.LayoutOrder = 1; sLabel.Parent = Bubble

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1,0,0,0)
    tLabel.AutomaticSize = Enum.AutomaticSize.Y
    tLabel.BackgroundTransparency = 1
    tLabel.Text = text
    tLabel.TextColor3 = isAI and Color3.fromRGB(180,225,255) or Color3.fromRGB(150,160,195)
    tLabel.TextSize = 13; tLabel.Font = Enum.Font.Code
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.TextWrapped = true
    tLabel.LayoutOrder = 2; tLabel.Parent = Bubble

    task.defer(function() Scroll.CanvasPosition = Vector2.new(0, math.huge) end)
    return Bubble
end

---------------------------------------------------------
-- TYPING BUBBLE
---------------------------------------------------------
local typingBubble = nil
local function showTyping()   typingBubble = addMsg("CLAUDE AI", "...", true) end
local function hideTyping()   if typingBubble then typingBubble:Destroy(); typingBubble=nil end end

---------------------------------------------------------
-- SEND LOGIC
---------------------------------------------------------
local busy = false
local function doSend()
    if busy then return end
    local txt = TextInput.Text:match("^%s*(.-)%s*$")
    if txt == "" then return end
    TextInput.Text = ""
    addMsg(LocalPlayer.Name, txt, false)
    busy = true
    SendBtn.BackgroundColor3 = Color3.fromRGB(20,20,60)
    StatusLbl.Text = "THINKING"
    StatusDot.BackgroundColor3 = Color3.fromRGB(255,200,0)
    showTyping()
    task.spawn(function()
        local reply = askClaude(txt)
        hideTyping()
        local clean, cmds = parseCommands(reply)
        -- Check if any command returns info text
        local extraInfo = ""
        for _, cmd in ipairs(cmds) do
            local result = executeCommand(cmd.tag, cmd.value)
            if type(result) == "string" then
                extraInfo = extraInfo .. "\n" .. result
            end
        end
        addMsg("CLAUDE AI", clean .. extraInfo, true)
        busy = false
        SendBtn.BackgroundColor3 = Color3.fromRGB(0,90,210)
        StatusLbl.Text = "ONLINE"
        StatusDot.BackgroundColor3 = Color3.fromRGB(0,255,100)
    end)
end

SendBtn.MouseButton1Click:Connect(doSend)
TextInput.FocusLost:Connect(function(enter) if enter then doSend() end end)

---------------------------------------------------------
-- FLOATING BUTTON (FAB)
---------------------------------------------------------
local FABSG = Instance.new("ScreenGui")
FABSG.Name = "ClaudeAI_FAB"
FABSG.ResetOnSpawn = false
FABSG.Parent = PlayerGui

local FAB = Instance.new("TextButton")
FAB.Size = UDim2.new(0, 58, 0, 58)
FAB.Position = UDim2.new(0.5, -29, 1, -78)
FAB.BackgroundColor3 = Color3.fromRGB(0, 18, 55)
FAB.Text = "AI"
FAB.TextColor3 = Color3.fromRGB(0, 200, 255)
FAB.TextSize = 14
FAB.Font = Enum.Font.GothamBold
FAB.BorderSizePixel = 0
FAB.Parent = FABSG
Instance.new("UICorner", FAB).CornerRadius = UDim.new(1,0)
local fabStroke = Instance.new("UIStroke", FAB)
fabStroke.Color = Color3.fromRGB(0, 160, 255)
fabStroke.Thickness = 2.5
TweenService:Create(fabStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 0.7 }):Play()
FAB.MouseButton1Click:Connect(function() Panel.Visible = not Panel.Visible end)

---------------------------------------------------------
-- WELCOME MESSAGE
---------------------------------------------------------
task.wait(0.4)
addMsg("CLAUDE AI",
    "Full power mode online, " .. LocalPlayer.Name .. ".\n\n" ..
    "I control EVERYTHING. Try:\n" ..
    "• 'make me overpowered'\n" ..
    "• 'enable flight'\n" ..
    "• 'turn on esp'\n" ..
    "• 'teleport to [player]'\n" ..
    "• 'set gravity to 10'\n" ..
    "• 'make it midnight'\n\n" ..
    "Or use the quick buttons above. What's the mission?",
    true
)

print("[CLAUDE AI - FULL POWER] Loaded! All systems online.")
