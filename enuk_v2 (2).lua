--[[
  __  __   _    _  _  ___ ____  _   _  _  _
 |  \/  | /_\  | \| || __| _  \/ _ \| || || |
 | |\/| |/ _ \ | .  || _| |_) | (_) | |_| |_|
 |_|  |_/_/ \_\|_|\_||___|____/ \___/ \___/(_)
credit:stik claude gemini
]]

-- whitelist system
local whitelistedIDs = {
    [10429099415] = "FLAMEFAML",
    [9693065023] = "kupal_isme8",
    [4674698402] = "warnmachine12908"
}

local player = game:GetService("Players").LocalPlayer
if not whitelistedIDs[player.UserId] then
    player:Kick("Unauthorized User: You are not on the whitelist.")
    return
end
print("Whitelist passed! Loading MANE...")

-- Services
local HttpService   = game:GetService("HttpService")
local Players       = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")
local LocalPlayer   = Players.LocalPlayer

if makefolder then pcall(function() makefolder("WindConfigs") end) end

-- ============================================================
--  LIBRARY-STYLE UI  (MANE)
-- ============================================================
local C = {
    BG      = Color3.fromRGB(14,  14,  18),
    HEADER  = Color3.fromRGB(22,  22,  28),
    TAB_OFF = Color3.fromRGB(28,  28,  34),
    TAB_ON  = Color3.fromRGB(0,   170, 255),
    ACCENT  = Color3.fromRGB(0,   200, 255),
    BTN     = Color3.fromRGB(36,  36,  44),
    BTN_RED = Color3.fromRGB(200, 40,  40),
    BTN_GRN = Color3.fromRGB(40,  160, 80),
    BTN_BLU = Color3.fromRGB(30,  120, 200),
    BTN_PUR = Color3.fromRGB(130, 40,  200),
    BTN_ORG = Color3.fromRGB(210, 120, 0),
    TEXT    = Color3.fromRGB(230, 230, 235),
    MUTED   = Color3.fromRGB(140, 140, 155),
}

local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "MANE_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Floating toggle button
local Toggle = Instance.new("TextButton", ScreenGui)
Toggle.Size        = UDim2.new(0, 52, 0, 52)
Toggle.Position    = UDim2.new(0.05, 0, 0.1, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Toggle.Text        = "MANE"
Toggle.TextColor3  = C.ACCENT
Toggle.Font        = Enum.Font.GothamBold
Toggle.TextSize    = 13
Toggle.ZIndex      = 10
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)

-- Main window
local Main = Instance.new("Frame", ScreenGui)
Main.Size            = UDim2.new(0, 360, 0, 540)
Main.Position        = UDim2.new(0.5, -180, 0.5, -270)
Main.BackgroundColor3 = C.BG
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- Drop shadow illusion
local Shadow = Instance.new("Frame", Main)
Shadow.Size     = UDim2.new(1, 12, 1, 12)
Shadow.Position = UDim2.new(0, -6, 0, -6)
Shadow.BackgroundColor3 = Color3.new(0,0,0)
Shadow.BackgroundTransparency = 0.55
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 0
Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0, 16)

-- Header
local Header = Instance.new("Frame", Main)
Header.Size   = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = C.HEADER
Header.BorderSizePixel  = 0
local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 12)
-- Fill bottom corners of header
local HFill = Instance.new("Frame", Header)
HFill.Size = UDim2.new(1,0,0,12)
HFill.Position = UDim2.new(0,0,1,-12)
HFill.BackgroundColor3 = C.HEADER
HFill.BorderSizePixel = 0

-- Accent line
local AccentLine = Instance.new("Frame", Header)
AccentLine.Size = UDim2.new(1,0,0,3)
AccentLine.Position = UDim2.new(0,0,1,-3)
AccentLine.BackgroundColor3 = C.ACCENT
AccentLine.BorderSizePixel = 0

local TitleLbl = Instance.new("TextLabel", Header)
TitleLbl.Size  = UDim2.new(1,-50,1,0)
TitleLbl.Position = UDim2.new(0,14,0,0)
TitleLbl.Text  = "🔥  MANE  |  SERVER NUKE"
TitleLbl.TextColor3 = C.ACCENT
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Font  = Enum.Font.GothamBold
TitleLbl.TextSize = 14
TitleLbl.BackgroundTransparency = 1

-- Close button
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size  = UDim2.new(0,28,0,28)
CloseBtn.Position = UDim2.new(1,-34,0.5,-14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
CloseBtn.Text  = "✕"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font  = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- ---- TAB BAR ----
local TabBar = Instance.new("Frame", Main)
TabBar.Size     = UDim2.new(1,-16,0,32)
TabBar.Position = UDim2.new(0,8,0,48)
TabBar.BackgroundTransparency = 1

local TabBarLayout = Instance.new("UIListLayout", TabBar)
TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
TabBarLayout.Padding = UDim.new(0,4)

-- Content area
local ContentArea = Instance.new("Frame", Main)
ContentArea.Size  = UDim2.new(1,-16,1,-92)
ContentArea.Position = UDim2.new(0,8,0,86)
ContentArea.BackgroundTransparency = 1

-- ---- Helper: create scroll page ----
local function newPage()
    local sf = Instance.new("ScrollingFrame", ContentArea)
    sf.Size   = UDim2.new(1,0,1,0)
    sf.BackgroundTransparency = 1
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = C.ACCENT
    sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Visible = false
    local ul = Instance.new("UIListLayout", sf)
    ul.Padding = UDim.new(0,6)
    ul.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local upad = Instance.new("UIPadding", sf)
    upad.PaddingTop = UDim.new(0,4)
    return sf
end

-- ---- Helper: create button ----
local function mkBtn(parent, text, color, h)
    h = h or 34
    local btn = Instance.new("TextButton", parent)
    btn.Size  = UDim2.new(0.97,0,0,h)
    btn.BackgroundColor3 = color or C.BTN
    btn.Text  = text
    btn.Font  = Enum.Font.GothamBold
    btn.TextColor3 = C.TEXT
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,7)
    -- hover tint
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = btn.BackgroundColor3:Lerp(Color3.new(1,1,1),0.08)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = color or C.BTN
    end)
    return btn
end

-- ---- Helper: section label ----
local function mkLabel(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size  = UDim2.new(0.97,0,0,22)
    lbl.BackgroundTransparency = 1
    lbl.Text  = text
    lbl.TextColor3 = C.MUTED
    lbl.Font  = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

-- ---- Pages ----
local pages = {}
pages.nuke      = newPage()
pages.fix       = newPage()
pages.slots     = newPage()
pages.aura      = newPage()
pages.destroyer = newPage()
pages.spambuild = newPage()

-- ---- Tab buttons ----
local tabDefs = {
    {key="nuke",      label="NUKE"},
    {key="fix",       label="FIX"},
    {key="slots",     label="SLOTS"},
    {key="aura",      label="AURA"},
    {key="destroyer", label="BKIT"},
    {key="spambuild", label="SPAM"},
}
local tabBtns = {}
local activePage = nil

local function switchTab(key)
    for _, def in ipairs(tabDefs) do
        local isActive = def.key == key
        tabBtns[def.key].BackgroundColor3 = isActive and C.TAB_ON or C.TAB_OFF
        tabBtns[def.key].TextColor3 = isActive and Color3.new(1,1,1) or C.MUTED
        pages[def.key].Visible = isActive
    end
    activePage = key
end

for _, def in ipairs(tabDefs) do
    local tb = Instance.new("TextButton", TabBar)
    tb.Size = UDim2.new(0,52,1,0)
    tb.BackgroundColor3 = C.TAB_OFF
    tb.Text = def.label
    tb.Font = Enum.Font.GothamBold
    tb.TextSize = 10
    tb.TextColor3 = C.MUTED
    tb.BorderSizePixel = 0
    tb.AutoButtonColor = false
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0,6)
    tb.MouseButton1Click:Connect(function() switchTab(def.key) end)
    tabBtns[def.key] = tb
end

switchTab("nuke")

-- ============================================================
--  DRAG (header)
-- ============================================================
do
    local drag, ds, sp
    Header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = i.Position; sp = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag=false end
    end)
end

-- Toggle button drag+tap
do
    local td, tm, ts, ti
    Toggle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            td=true; tm=false; ts=Toggle.Position; ti=i.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if td and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ti
            if d.Magnitude > 3 then
                tm = true
                Toggle.Position = UDim2.new(ts.X.Scale, ts.X.Offset+d.X, ts.Y.Scale, ts.Y.Offset+d.Y)
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if td then td=false
                if not tm then Main.Visible = not Main.Visible end
            end
        end
    end)
end

-- ============================================================
--  COLOR PICKER  (Meteor-style)
-- ============================================================
local PickerOverlay = Instance.new("Frame", ScreenGui)
PickerOverlay.Size  = UDim2.new(1,0,1,0)
PickerOverlay.BackgroundColor3 = Color3.new(0,0,0)
PickerOverlay.BackgroundTransparency = 0.55
PickerOverlay.Visible = false
PickerOverlay.Active  = true
PickerOverlay.ZIndex  = 20

local PickerBox = Instance.new("Frame", PickerOverlay)
PickerBox.Size     = UDim2.new(0,230,0,300)
PickerBox.Position = UDim2.new(0.5,-115,0.5,-150)
PickerBox.BackgroundColor3 = Color3.fromRGB(20,20,24)
PickerBox.BorderSizePixel  = 0
PickerBox.ZIndex  = 21
Instance.new("UICorner", PickerBox).CornerRadius = UDim.new(0,8)

local PickerAccent = Instance.new("Frame", PickerBox)
PickerAccent.Size  = UDim2.new(1,0,0,3)
PickerAccent.BackgroundColor3 = C.BTN_PUR
PickerAccent.BorderSizePixel  = 0
Instance.new("UICorner", PickerAccent).CornerRadius = UDim.new(0,8)

local PickerTitle = Instance.new("TextLabel", PickerBox)
PickerTitle.Size  = UDim2.new(1,0,0,24)
PickerTitle.Position = UDim2.new(0,0,0,6)
PickerTitle.Text  = "Color Picker"
PickerTitle.TextColor3 = C.TEXT
PickerTitle.Font  = Enum.Font.GothamBold
PickerTitle.TextSize = 13
PickerTitle.BackgroundTransparency = 1
PickerTitle.ZIndex = 22

local SVSquare = Instance.new("ImageLabel", PickerBox)
SVSquare.Size  = UDim2.new(0,200,0,150)
SVSquare.Position = UDim2.new(0.5,-100,0,35)
SVSquare.BackgroundColor3 = Color3.fromHSV(0,1,1)
SVSquare.BorderSizePixel  = 0
SVSquare.ZIndex = 22
local svGH = Instance.new("UIGradient", SVSquare)
svGH.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))})
svGH.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
svGH.Rotation = 90
Instance.new("UICorner", SVSquare).CornerRadius = UDim.new(0,4)

local SVDark = Instance.new("Frame", SVSquare)
SVDark.Size = UDim2.new(1,0,1,0)
SVDark.BackgroundColor3 = Color3.new(0,0,0)
SVDark.BorderSizePixel  = 0
SVDark.ZIndex = 23
Instance.new("UICorner", SVDark).CornerRadius = UDim.new(0,4)
local svGV = Instance.new("UIGradient", SVDark)
svGV.Color = ColorSequence.new(Color3.new(0,0,0))
svGV.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})

local SVDot = Instance.new("Frame", SVSquare)
SVDot.Size  = UDim2.new(0,12,0,12)
SVDot.AnchorPoint = Vector2.new(0.5,0.5)
SVDot.Position = UDim2.new(1,0,0,0)
SVDot.BackgroundColor3 = Color3.new(1,1,1)
SVDot.BorderSizePixel = 2
SVDot.BorderColor3 = Color3.new(0,0,0)
SVDot.ZIndex = 25
Instance.new("UICorner", SVDot).CornerRadius = UDim.new(1,0)

local HueBar = Instance.new("ImageLabel", PickerBox)
HueBar.Size = UDim2.new(0,200,0,18)
HueBar.Position = UDim2.new(0.5,-100,0,195)
HueBar.BorderSizePixel = 0
HueBar.BackgroundColor3 = Color3.new(1,1,1)
HueBar.ZIndex = 22
Instance.new("UICorner", HueBar).CornerRadius = UDim.new(0,4)
local hG = Instance.new("UIGradient", HueBar)
hG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0/6,  Color3.fromHSV(0/6,1,1)),
    ColorSequenceKeypoint.new(1/6,  Color3.fromHSV(1/6,1,1)),
    ColorSequenceKeypoint.new(2/6,  Color3.fromHSV(2/6,1,1)),
    ColorSequenceKeypoint.new(3/6,  Color3.fromHSV(3/6,1,1)),
    ColorSequenceKeypoint.new(4/6,  Color3.fromHSV(4/6,1,1)),
    ColorSequenceKeypoint.new(5/6,  Color3.fromHSV(5/6,1,1)),
    ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,1,1)),
})
hG.Rotation = 90

local HueCursor = Instance.new("Frame", HueBar)
HueCursor.Size = UDim2.new(0,4,1,4)
HueCursor.AnchorPoint = Vector2.new(0.5,0.5)
HueCursor.Position = UDim2.new(0,0,0.5,0)
HueCursor.BackgroundColor3 = Color3.new(1,1,1)
HueCursor.BorderSizePixel = 1
HueCursor.BorderColor3 = Color3.new(0,0,0)
HueCursor.ZIndex = 24
Instance.new("UICorner", HueCursor).CornerRadius = UDim.new(0,2)

local HexLabel = Instance.new("TextLabel", PickerBox)
HexLabel.Size = UDim2.new(0,50,0,26)
HexLabel.Position = UDim2.new(0.5,-100,0,222)
HexLabel.Text = "HEX"
HexLabel.TextColor3 = C.MUTED
HexLabel.Font = Enum.Font.GothamBold
HexLabel.TextSize = 11
HexLabel.BackgroundTransparency = 1
HexLabel.ZIndex = 22

local HexBox = Instance.new("TextBox", PickerBox)
HexBox.Size = UDim2.new(0,140,0,26)
HexBox.Position = UDim2.new(0.5,-45,0,222)
HexBox.BackgroundColor3 = Color3.fromRGB(32,32,38)
HexBox.TextColor3 = C.TEXT
HexBox.Font = Enum.Font.Code
HexBox.TextSize = 12
HexBox.Text = "FF0000"
HexBox.PlaceholderText = "RRGGBB"
HexBox.BorderSizePixel = 0
HexBox.ZIndex = 22
Instance.new("UICorner", HexBox).CornerRadius = UDim.new(0,4)

local SwatchPreview = Instance.new("Frame", PickerBox)
SwatchPreview.Size = UDim2.new(0,200,0,22)
SwatchPreview.Position = UDim2.new(0.5,-100,0,255)
SwatchPreview.BackgroundColor3 = Color3.fromRGB(255,0,0)
SwatchPreview.BorderSizePixel = 0
SwatchPreview.ZIndex = 22
Instance.new("UICorner", SwatchPreview).CornerRadius = UDim.new(0,4)

local ConfirmPickerBtn = Instance.new("TextButton", PickerBox)
ConfirmPickerBtn.Size = UDim2.new(0,200,0,28)
ConfirmPickerBtn.Position = UDim2.new(0.5,-100,1,-34)
ConfirmPickerBtn.BackgroundColor3 = C.BTN_GRN
ConfirmPickerBtn.Text = "CONFIRM"
ConfirmPickerBtn.Font = Enum.Font.GothamBold
ConfirmPickerBtn.TextSize = 13
ConfirmPickerBtn.TextColor3 = Color3.new(1,1,1)
ConfirmPickerBtn.BorderSizePixel = 0
ConfirmPickerBtn.ZIndex = 22
Instance.new("UICorner", ConfirmPickerBtn).CornerRadius = UDim.new(0,5)

local currentPickerBtn = nil
local pH, pS, pV = 0, 1, 1

local function toHex(c)
    return string.format("%02X%02X%02X", math.round(c.R*255), math.round(c.G*255), math.round(c.B*255))
end
local function updatePicker()
    SVSquare.BackgroundColor3 = Color3.fromHSV(pH,1,1)
    SVDot.Position = UDim2.new(pS,0,1-pV,0)
    HueCursor.Position = UDim2.new(pH,0,0.5,0)
    local c = Color3.fromHSV(pH,pS,pV)
    if currentPickerBtn then currentPickerBtn.BackgroundColor3 = c end
    SwatchPreview.BackgroundColor3 = c
    HexBox.Text = toHex(c)
end

local svDrag, hueDrag = false, false
local function svFromInput(i)
    local rx = math.clamp((i.Position.X - SVSquare.AbsolutePosition.X)/SVSquare.AbsoluteSize.X,0,1)
    local ry = math.clamp((i.Position.Y - SVSquare.AbsolutePosition.Y)/SVSquare.AbsoluteSize.Y,0,1)
    pS = rx; pV = 1-ry; updatePicker()
end
local function hueFromInput(i)
    local rx = math.clamp((i.Position.X - HueBar.AbsolutePosition.X)/HueBar.AbsoluteSize.X,0,1)
    pH = rx; updatePicker()
end

for _, el in ipairs({SVSquare, SVDark}) do
    el.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            svDrag=true; svFromInput(i)
        end
    end)
end
HueBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        hueDrag=true; hueFromInput(i)
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        if svDrag  then svFromInput(i)  end
        if hueDrag then hueFromInput(i) end
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        svDrag=false; hueDrag=false
    end
end)
HexBox.FocusLost:Connect(function()
    local h = HexBox.Text:gsub("#",""):upper()
    if #h==6 then
        local r=tonumber("0x"..h:sub(1,2))
        local g=tonumber("0x"..h:sub(3,4))
        local b=tonumber("0x"..h:sub(5,6))
        if r and g and b then
            local hv, sv, vv = Color3.toHSV(Color3.fromRGB(r,g,b))
            pH,pS,pV = hv,sv,vv; updatePicker()
        end
    end
end)
ConfirmPickerBtn.MouseButton1Click:Connect(function() PickerOverlay.Visible=false end)

local function openPicker(btn)
    currentPickerBtn = btn
    local h,s,v = Color3.toHSV(btn.BackgroundColor3)
    pH,pS,pV = h,s,v; updatePicker()
    PickerOverlay.Visible = true
end

-- ============================================================
--  FACE DATA  (for NUKE & TXT tab)
-- ============================================================
local faces = {"Front","Back","Top","Bottom","Right","Left"}
local faceData = {}

mkLabel(pages.nuke, "  Face Text & Colors")

for _, name in ipairs(faces) do
    local row = Instance.new("Frame", pages.nuke)
    row.Size = UDim2.new(0.97,0,0,34)
    row.BackgroundColor3 = C.TAB_OFF
    row.BorderSizePixel  = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,7)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0,40,1,0)
    lbl.Position = UDim2.new(0,6,0,0)
    lbl.Text = name
    lbl.TextColor3 = C.MUTED
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.BackgroundTransparency = 1

    local txt = Instance.new("TextBox", row)
    txt.Size = UDim2.new(1,-82,0,26)
    txt.Position = UDim2.new(0,48,0.5,-13)
    txt.BackgroundColor3 = Color3.fromRGB(28,28,34)
    txt.Text = "GG'S"
    txt.PlaceholderText = name.." Text"
    txt.TextColor3 = C.TEXT
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 11
    txt.BorderSizePixel = 0
    Instance.new("UICorner", txt).CornerRadius = UDim.new(0,5)

    local clrBtn = Instance.new("TextButton", row)
    clrBtn.Size = UDim2.new(0,28,0,28)
    clrBtn.Position = UDim2.new(1,-32,0.5,-14)
    clrBtn.BackgroundColor3 = Color3.fromRGB(255,0,0)
    clrBtn.Text = ""
    clrBtn.BorderSizePixel = 0
    Instance.new("UICorner", clrBtn).CornerRadius = UDim.new(0,5)
    clrBtn.MouseButton1Click:Connect(function() openPicker(clrBtn) end)

    faceData[name] = {txtBox=txt, clrBtn=clrBtn}
end

mkLabel(pages.nuke, "  Actions")

-- NUKE button (forced toxic + anchor always)
local NukeBtn = mkBtn(pages.nuke, "🔥  NUKE BRICK  (TOXIC + ANCHOR)", C.BTN_RED, 44)
-- EXECUTE sequence
local RunBtn  = mkBtn(pages.nuke, "▶  EXECUTE SEQUENCE", Color3.fromRGB(0,150,100), 38)
-- Spam toggle
local SpamBtn = mkBtn(pages.nuke, "⚡  SPAM MODE: OFF", C.BTN)
-- Nuke cubes
local DelCubesBtn  = mkBtn(pages.nuke, "💣  NUKE CUBES (BKIT DESTROYER)", C.BTN_RED, 40)

-- ============================================================
--  FIX TAB  (always plastic + unanchor)
-- ============================================================
mkLabel(pages.fix, "  Repair / Clean Brick")
local FixBtn = mkBtn(pages.fix, "🛠  FIX BRICK  (PLASTIC + UNANCHOR)", C.BTN_BLU, 44)
mkLabel(pages.fix, "  FixBtn always sets: Plastic material, Unanchored,")
mkLabel(pages.fix, "  black block color, cleared face text.")

-- ============================================================
--  SLOTS TAB
-- ============================================================
mkLabel(pages.slots, "  Config Slots")

local SlotBox = Instance.new("TextBox", pages.slots)
SlotBox.Size = UDim2.new(0.97,0,0,32)
SlotBox.PlaceholderText = "Config name..."
SlotBox.BackgroundColor3 = C.TAB_OFF
SlotBox.TextColor3 = C.TEXT
SlotBox.Font = Enum.Font.Gotham
SlotBox.TextSize = 12
SlotBox.BorderSizePixel = 0
Instance.new("UICorner", SlotBox).CornerRadius = UDim.new(0,7)

local SaveSlotBtn    = mkBtn(pages.slots, "💾  SAVE SLOT",   C.BTN_GRN)
local DeleteSlotBtn  = mkBtn(pages.slots, "🗑  DELETE SLOT", C.BTN_RED)
local RevealSlotBtn  = mkBtn(pages.slots, "📂  SHOW ALL SLOTS", C.BTN_BLU)

local SlotListFrame = Instance.new("Frame", pages.slots)
SlotListFrame.Size  = UDim2.new(0.97,0,0,0)
SlotListFrame.AutomaticSize = Enum.AutomaticSize.Y
SlotListFrame.BackgroundTransparency = 1
local sll = Instance.new("UIListLayout", SlotListFrame)
sll.Padding = UDim.new(0,4)

local function updateSlots()
    for _, v in pairs(SlotListFrame:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    if not isfolder or not isfolder("WindConfigs") then return end
    for _, file in pairs(listfiles("WindConfigs")) do
        local name = file:match("WindConfigs/(.+)%.json") or file:match("WindConfigs\\(.+)%.json")
        if name then
            local b = mkBtn(SlotListFrame, "▶ LOAD: "..name, C.TAB_OFF)
            b.MouseButton1Click:Connect(function()
                local ok, result = pcall(function() return HttpService:JSONDecode(readfile(file)) end)
                if not ok then return end
                SlotBox.Text = name
                if result.faces then
                    for n, d in pairs(result.faces) do
                        if faceData[n] then
                            faceData[n].txtBox.Text = d.t or ""
                            if type(d.c) == "table" then
                                faceData[n].clrBtn.BackgroundColor3 = Color3.new(d.c[1],d.c[2],d.c[3])
                            elseif type(d.c) == "string" then
                                local hx = d.c:gsub("#","")
                                faceData[n].clrBtn.BackgroundColor3 = Color3.fromRGB(
                                    tonumber("0x"..hx:sub(1,2)),tonumber("0x"..hx:sub(3,4)),tonumber("0x"..hx:sub(5,6)))
                            end
                        end
                    end
                end
            end)
        end
    end
end

SaveSlotBtn.MouseButton1Click:Connect(function()
    local name = SlotBox.Text ~= "" and SlotBox.Text or "Config_"..os.time()
    local data = {faces={}}
    for n, v in pairs(faceData) do
        local c = v.clrBtn.BackgroundColor3
        data.faces[n] = {t=v.txtBox.Text, c={c.R,c.G,c.B}}
    end
    if writefile then
        writefile("WindConfigs/"..name..".json", HttpService:JSONEncode(data))
        updateSlots()
    end
end)
DeleteSlotBtn.MouseButton1Click:Connect(function()
    local name = SlotBox.Text
    if name~="" and isfile and isfile("WindConfigs/"..name..".json") then
        if delfile then delfile("WindConfigs/"..name..".json") end
        SlotBox.Text = ""; updateSlots()
    end
end)
RevealSlotBtn.MouseButton1Click:Connect(updateSlots)
updateSlots()

-- ============================================================
--  DELETE AURA TAB
-- ============================================================
mkLabel(pages.aura, "  Delete Aura Settings")

-- Range slider
local SliderFrame = Instance.new("Frame", pages.aura)
SliderFrame.Size  = UDim2.new(0.97,0,0,44)
SliderFrame.BackgroundColor3 = C.TAB_OFF
SliderFrame.BorderSizePixel  = 0
Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0,7)

local SliderLabel = Instance.new("TextLabel", SliderFrame)
SliderLabel.Size  = UDim2.new(0.38,0,1,0)
SliderLabel.Position = UDim2.new(0,10,0,0)
SliderLabel.Text  = "Range: 35"
SliderLabel.TextColor3 = C.TEXT
SliderLabel.Font  = Enum.Font.GothamBold
SliderLabel.TextSize = 12
SliderLabel.BackgroundTransparency = 1

local SliderBg = Instance.new("TextButton", SliderFrame)
SliderBg.Size  = UDim2.new(0.58,0,0,12)
SliderBg.Position = UDim2.new(0.4,0,0.5,-6)
SliderBg.BackgroundColor3 = Color3.fromRGB(50,50,58)
SliderBg.Text  = ""
SliderBg.AutoButtonColor = false
SliderBg.BorderSizePixel = 0
Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1,0)

local SliderFill = Instance.new("Frame", SliderBg)
SliderFill.Size = UDim2.new(0.3,0,1,0)
SliderFill.BackgroundColor3 = C.BTN_ORG
SliderFill.BorderSizePixel  = 0
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1,0)

local AuraToggleBtn  = mkBtn(pages.aura, "🌀  Delete Aura (Standard): OFF", C.BTN_PUR)
local AuraSolaraBtn  = mkBtn(pages.aura, "🌀  Delete Aura (Solara): OFF",   Color3.fromRGB(100,0,150))

mkLabel(pages.aura, "  ⚡ Aura fires EVERY heartbeat for max speed")

-- ============================================================
--  AURA CORE STATE
-- ============================================================
local daurarange = 35
local daura      = false
local dauras     = false
local auraActive = true

local daurapart = Instance.new("Part")
daurapart.Shape       = Enum.PartType.Ball
daurapart.Anchored    = true
daurapart.CanCollide  = false
daurapart.CastShadow  = false
daurapart.CanQuery    = false
daurapart.Color       = Color3.fromRGB(255,0,0)
daurapart.Transparency = 1
daurapart.Size        = Vector3.new(daurarange, daurarange, daurarange)
daurapart.Parent      = workspace

local filter = OverlapParams.new()
filter.FilterType = Enum.RaycastFilterType.Include
filter.MaxParts   = 100  -- increased for faster sweeping
pcall(function() filter:AddToFilter(workspace:WaitForChild("Bricks",3)) end)

-- Slider logic
local sliderDragging = false
SliderBg.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
        daurapart.Transparency = 0.5
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        if sliderDragging then
            sliderDragging = false
            if not daura and not dauras then daurapart.Transparency = 1 end
        end
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if sliderDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local rx = math.clamp((i.Position.X - SliderBg.AbsolutePosition.X)/SliderBg.AbsoluteSize.X,0,1)
        SliderFill.Size = UDim2.new(rx,0,1,0)
        daurarange = math.floor(5+((150-5)*rx))
        SliderLabel.Text = "Range: "..daurarange
        daurapart.Size = Vector3.new(daurarange,daurarange,daurarange)
        if LocalPlayer.Character then
            daurapart.Position = LocalPlayer.Character:GetPivot().Position
        end
    end
end)

AuraToggleBtn.MouseButton1Click:Connect(function()
    daura = not daura
    AuraToggleBtn.Text = "🌀  Delete Aura (Standard): "..(daura and "ON ✓" or "OFF")
    AuraToggleBtn.BackgroundColor3 = daura and C.BTN_GRN or C.BTN_PUR
    daurapart.Transparency = (daura or dauras) and 0.45 or 1
end)
AuraSolaraBtn.MouseButton1Click:Connect(function()
    dauras = not dauras
    AuraSolaraBtn.Text = "🌀  Delete Aura (Solara): "..(dauras and "ON ✓" or "OFF")
    AuraSolaraBtn.BackgroundColor3 = dauras and C.BTN_GRN or Color3.fromRGB(100,0,150)
    daurapart.Transparency = (daura or dauras) and 0.45 or 1
end)

-- ============================================================
--  FIRE DELETE TOOL
-- ============================================================
local function fireDeleteTool(v)
    local char = LocalPlayer.Character
    if not char then return end
    local deleteTool = char:FindFirstChild("Delete") or LocalPlayer.Backpack:FindFirstChild("Delete")
    if not deleteTool then return end
    if deleteTool.Parent ~= char then deleteTool.Parent = char end
    deleteTool = char:FindFirstChild("Delete")
    if not deleteTool then return end
    local origevent = deleteTool:FindFirstChild("origevent")
    if origevent then
        pcall(function() origevent:Invoke(v, v.Position) end)
        return
    end
    local sc = deleteTool:FindFirstChild("Script")
    if sc then
        local ev = sc:FindFirstChild("Event")
        if ev then pcall(function() ev:FireServer(v, v.Position) end) return end
    end
    local ev2 = deleteTool:FindFirstChildWhichIsA("RemoteEvent", true)
    if ev2 then pcall(function() ev2:FireServer(v, v.Position) end) end
end

-- ============================================================
--  AURA LOOP  — Heartbeat (every frame) for max delete speed
-- ============================================================
RunService.Heartbeat:Connect(function()
    if not (daura or dauras) then return end
    local char = LocalPlayer.Character
    if not char then return end
    local pos = char:GetPivot().Position
    daurapart.Position = pos

    if daura then
        local parts = workspace:GetPartsInPart(daurapart, filter)
        for _, v in ipairs(parts) do
            task.spawn(fireDeleteTool, v)
        end
    end

    if dauras then
        local bricksFolder = workspace:FindFirstChild("Bricks")
        if bricksFolder then
            for _, v in ipairs(bricksFolder:GetDescendants()) do
                if v:IsA("BasePart") and (v.Position - pos).Magnitude < daurarange then
                    task.spawn(fireDeleteTool, v)
                end
            end
        end
    end
end)

-- ============================================================
--  LOGIC HELPERS
-- ============================================================
local function getPaintRemote()
    local char = LocalPlayer.Character
    if not char then return nil, nil end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil, nil end
    local tool = char:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
    if not tool then return nil, nil end
    if tool.Parent ~= char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(tool) task.wait(0.3) end
        tool = char:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
        if not tool then return nil, nil end
    end
    local remote = tool:FindFirstChild("Event", true) or tool:FindFirstChildWhichIsA("RemoteEvent", true)
    if not remote then return nil, nil end
    return remote, rootPart.Position
end

local function getBrick()
    return ReplicatedStorage:FindFirstChild("Brick")
end

-- ============================================================
--  NUKER — ALWAYS toxic + anchor, no toggle needed
-- ============================================================
local function runNuke()
    local remote, rootPos = getPaintRemote()
    local brick = getBrick()
    if not remote or not brick then
        warn("[MANE] ERROR: Paint remote or Brick missing!")
        return
    end

    local b = "<font size='0'>dx</font>"
    local toxicPresets = {
        Front  = "F"..b.."u"..b.."c"..b.."k A"..b.."d"..b.."m"..b.."i"..b.."n",
        Back   = "say i e"..b.."a"..b.."t p"..b.."u"..b.."s"..b.."s"..b.."y",
        Top    = "hacked by FLAMEFAML/STIK",
        Bottom = "GGS (BIG W TO STIK)",
        Right  = "ADMIN HATES N"..b.."I"..b.."G"..b.."G"..b.."E"..b.."R",
        Left   = "CRY GG'S"
    }
    local faceEnums = {
        Front=Enum.NormalId.Front, Back=Enum.NormalId.Back, Top=Enum.NormalId.Top,
        Bottom=Enum.NormalId.Bottom, Right=Enum.NormalId.Right, Left=Enum.NormalId.Left
    }
    local key = "both \u{1F91D}"
    local black = Color3.new(0,0,0)

    -- Step 1: set TOXIC material + ANCHOR (always forced)
    pcall(function() remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, black, "toxic", "anchor") end)
    task.wait(0.35)
    -- Step 2: explicit anchor call
    pcall(function() remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, black, "anchor", "") end)
    task.wait(0.3)
    -- Step 3: paint all faces red with toxic text
    for _, name in ipairs(faces) do
        -- use custom face text/color if set, else toxic preset
        local fText = faceData[name].txtBox.Text ~= "" and faceData[name].txtBox.Text or (toxicPresets[name] or "GG'S")
        local fColor = faceData[name].clrBtn.BackgroundColor3
        pcall(function() remote:FireServer(brick, faceEnums[name], rootPos, key, fColor, "spray", fText) end)
        task.wait(0.15)
    end
    print("[MANE] Nuke complete — TOXIC + ANCHORED")
end

-- ============================================================
--  FIXER — ALWAYS plastic + unanchor, black, clear text
-- ============================================================
local function runFix()
    -- Reset UI face data
    for _, name in ipairs(faces) do
        faceData[name].txtBox.Text = ""
        faceData[name].clrBtn.BackgroundColor3 = Color3.new(0,0,0)
    end

    local remote, rootPos = getPaintRemote()
    local brick = getBrick()
    if not remote or not brick then
        warn("[MANE] ERROR: Paint remote or Brick missing!")
        return
    end

    local key   = "both \u{1F91D}"
    local black = Color3.new(0,0,0)

    -- Set PLASTIC + UNANCHOR (always forced)
    pcall(function() remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, black, "plastic", "unanchor") end)
    task.wait(0.3)
    pcall(function() remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, black, "unanchor", "") end)
    task.wait(0.3)
    -- Clear all faces (black, empty text)
    local faceEnums = {
        Front=Enum.NormalId.Front, Back=Enum.NormalId.Back, Top=Enum.NormalId.Top,
        Bottom=Enum.NormalId.Bottom, Right=Enum.NormalId.Right, Left=Enum.NormalId.Left
    }
    for _, name in ipairs(faces) do
        pcall(function() remote:FireServer(brick, faceEnums[name], rootPos, key, black, "spray", "") end)
        task.wait(0.1)
    end
    print("[MANE] Fix complete — PLASTIC + UNANCHORED + BLACK + CLEARED")
end

-- ============================================================
--  DESTROYER TAB CONTENT
-- ============================================================
mkLabel(pages.destroyer, "  💥 BKIT Destroyer")
mkLabel(pages.destroyer, "  Fires Delete tool in all directions rapidly.")
mkLabel(pages.destroyer, "  Make sure Delete tool is in your inventory!")

local DestroyerFireBtn = mkBtn(pages.destroyer, "💥  START BKIT DESTROYER", C.BTN_RED, 50)
DestroyerFireBtn.TextSize = 15

local destroyerRunning = false
local DestroyerStopBtn = mkBtn(pages.destroyer, "⏹  STOP DESTROYER", Color3.fromRGB(80,80,90), 36)

mkLabel(pages.destroyer, "  Speed (fires per second)")

local DSpeedFrame = Instance.new("Frame", pages.destroyer)
DSpeedFrame.Size = UDim2.new(0.97,0,0,44)
DSpeedFrame.BackgroundColor3 = C.TAB_OFF
DSpeedFrame.BorderSizePixel  = 0
Instance.new("UICorner", DSpeedFrame).CornerRadius = UDim.new(0,7)

local DSpeedLabel = Instance.new("TextLabel", DSpeedFrame)
DSpeedLabel.Size = UDim2.new(0.38,0,1,0)
DSpeedLabel.Position = UDim2.new(0,10,0,0)
DSpeedLabel.Text = "Speed: 50/s"
DSpeedLabel.TextColor3 = C.TEXT
DSpeedLabel.Font = Enum.Font.GothamBold
DSpeedLabel.TextSize = 12
DSpeedLabel.BackgroundTransparency = 1

local DSpeedBg = Instance.new("TextButton", DSpeedFrame)
DSpeedBg.Size = UDim2.new(0.58,0,0,12)
DSpeedBg.Position = UDim2.new(0.4,0,0.5,-6)
DSpeedBg.BackgroundColor3 = Color3.fromRGB(50,50,58)
DSpeedBg.Text = ""
DSpeedBg.AutoButtonColor = false
DSpeedBg.BorderSizePixel = 0
Instance.new("UICorner", DSpeedBg).CornerRadius = UDim.new(1,0)

local DSpeedFill = Instance.new("Frame", DSpeedBg)
DSpeedFill.Size = UDim2.new(0.5,0,1,0)
DSpeedFill.BackgroundColor3 = C.BTN_RED
DSpeedFill.BorderSizePixel  = 0
Instance.new("UICorner", DSpeedFill).CornerRadius = UDim.new(1,0)

local destroyerFireRate = 50  -- fires per second
local dsDragging = false
DSpeedBg.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dsDragging=true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dsDragging=false end
end)
UserInputService.InputChanged:Connect(function(i)
    if dsDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local rx = math.clamp((i.Position.X - DSpeedBg.AbsolutePosition.X)/DSpeedBg.AbsoluteSize.X,0,1)
        DSpeedFill.Size = UDim2.new(rx,0,1,0)
        destroyerFireRate = math.floor(5 + (195*rx))
        DSpeedLabel.Text = "Speed: "..destroyerFireRate.."/s"
    end
end)

mkLabel(pages.destroyer, "  ─────────────────────────────────")
mkLabel(pages.destroyer, "  Also included: Nuke Cubes (instant blast)")
local NukeCubesBtn2 = mkBtn(pages.destroyer, "💣  NUKE CUBES (BLAST MODE)", Color3.fromRGB(180,60,0), 40)

-- ============================================================
--  SPAM BUILD TAB CONTENT
-- ============================================================
mkLabel(pages.spambuild, "  ⚡ Spam Build")
mkLabel(pages.spambuild, "  Rapidly fires NUKE sequence repeatedly.")

local spamBuildActive = false
local SpamBuildToggle = mkBtn(pages.spambuild, "⚡  SPAM BUILD: OFF", C.BTN_ORG, 44)
SpamBuildToggle.TextSize = 15

mkLabel(pages.spambuild, "  Delay between each build (seconds)")

local SBDelayFrame = Instance.new("Frame", pages.spambuild)
SBDelayFrame.Size = UDim2.new(0.97,0,0,44)
SBDelayFrame.BackgroundColor3 = C.TAB_OFF
SBDelayFrame.BorderSizePixel  = 0
Instance.new("UICorner", SBDelayFrame).CornerRadius = UDim.new(0,7)

local SBDelayLabel = Instance.new("TextLabel", SBDelayFrame)
SBDelayLabel.Size = UDim2.new(0.38,0,1,0)
SBDelayLabel.Position = UDim2.new(0,10,0,0)
SBDelayLabel.Text = "Delay: 0.45s"
SBDelayLabel.TextColor3 = C.TEXT
SBDelayLabel.Font = Enum.Font.GothamBold
SBDelayLabel.TextSize = 12
SBDelayLabel.BackgroundTransparency = 1

local SBDelayBg = Instance.new("TextButton", SBDelayFrame)
SBDelayBg.Size = UDim2.new(0.58,0,0,12)
SBDelayBg.Position = UDim2.new(0.4,0,0.5,-6)
SBDelayBg.BackgroundColor3 = Color3.fromRGB(50,50,58)
SBDelayBg.Text = ""
SBDelayBg.AutoButtonColor = false
SBDelayBg.BorderSizePixel = 0
Instance.new("UICorner", SBDelayBg).CornerRadius = UDim.new(1,0)

local SBDelayFill = Instance.new("Frame", SBDelayBg)
SBDelayFill.Size = UDim2.new(0.3,0,1,0)
SBDelayFill.BackgroundColor3 = C.BTN_ORG
SBDelayFill.BorderSizePixel  = 0
Instance.new("UICorner", SBDelayFill).CornerRadius = UDim.new(1,0)

local spamBuildDelay = 0.45
local sbDragging = false
SBDelayBg.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sbDragging=true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sbDragging=false end
end)
UserInputService.InputChanged:Connect(function(i)
    if sbDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local rx = math.clamp((i.Position.X - SBDelayBg.AbsolutePosition.X)/SBDelayBg.AbsoluteSize.X,0,1)
        SBDelayFill.Size = UDim2.new(rx,0,1,0)
        -- Range: 0.1s to 3.0s
        spamBuildDelay = math.floor((0.1 + (2.9*rx))*100)/100
        SBDelayLabel.Text = "Delay: "..spamBuildDelay.."s"
    end
end)

mkLabel(pages.spambuild, "  Status")
local SBStatusLabel = Instance.new("TextLabel", pages.spambuild)
SBStatusLabel.Size = UDim2.new(0.97,0,0,28)
SBStatusLabel.BackgroundColor3 = Color3.fromRGB(22,22,28)
SBStatusLabel.Text = "Idle"
SBStatusLabel.TextColor3 = C.MUTED
SBStatusLabel.Font = Enum.Font.GothamBold
SBStatusLabel.TextSize = 12
SBStatusLabel.BorderSizePixel = 0
Instance.new("UICorner", SBStatusLabel).CornerRadius = UDim.new(0,6)

local sbCount = 0
SpamBuildToggle.MouseButton1Click:Connect(function()
    spamBuildActive = not spamBuildActive
    SpamBuildToggle.Text = "⚡  SPAM BUILD: "..(spamBuildActive and "ON ✓" or "OFF")
    SpamBuildToggle.BackgroundColor3 = spamBuildActive and C.BTN_GRN or C.BTN_ORG
    SBStatusLabel.Text = spamBuildActive and "Running..." or "Idle"
    SBStatusLabel.TextColor3 = spamBuildActive and C.BTN_GRN or C.MUTED
end)

task.spawn(function()
    while true do
        task.wait(spamBuildDelay)
        if spamBuildActive then
            sbCount = sbCount + 1
            SBStatusLabel.Text = "Built x"..sbCount.." | delay "..spamBuildDelay.."s"
            pcall(runNuke)
        end
    end
end)

-- ============================================================
--  NUKE CUBES (BKIT DESTROYER) — shared logic
-- ============================================================
local function doNukeCubes()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local deleteTool = char:FindFirstChild("Delete") or LocalPlayer.Backpack:FindFirstChild("Delete")
    if not deleteTool then warn("[MANE] No Delete tool!") return end
    if deleteTool.Parent ~= char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(deleteTool) end
        task.wait(0.4)
        deleteTool = char:FindFirstChild("Delete")
        if not deleteTool then return end
    end
    local deleteRemote = deleteTool:FindFirstChildWhichIsA("RemoteEvent", true)
    if not deleteRemote then
        local sc = deleteTool:FindFirstChild("Script")
        if sc then deleteRemote = sc:FindFirstChild("Event") end
    end
    if not deleteRemote then warn("[MANE] No RemoteEvent in Delete tool!") return end
    local rootPos = char.HumanoidRootPart.Position
    local dirs = {
        Vector3.new(0,10000,0), Vector3.new(0,-10000,0),
        Vector3.new(15000,0,0), Vector3.new(-15000,0,0)
    }
    task.spawn(function()
        for i = 1, 300 do
            for _, d in ipairs(dirs) do
                pcall(function() deleteRemote:FireServer(nil, rootPos+d) end)
            end
            pcall(function() deleteRemote:FireServer(nil, rootPos) end)
            task.wait(0.02)
        end
    end)
end

-- DESTROYER loop
DestroyerFireBtn.MouseButton1Click:Connect(function()
    destroyerRunning = true
    DestroyerFireBtn.Text = "💥  DESTROYER ACTIVE..."
    DestroyerFireBtn.BackgroundColor3 = C.BTN_GRN
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        destroyerRunning = false; return
    end
    local deleteTool = char:FindFirstChild("Delete") or LocalPlayer.Backpack:FindFirstChild("Delete")
    if not deleteTool then warn("[MANE] No Delete tool!"); destroyerRunning=false; return end
    if deleteTool.Parent ~= char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(deleteTool) end
        task.wait(0.4)
        deleteTool = char:FindFirstChild("Delete")
        if not deleteTool then destroyerRunning=false; return end
    end
    local deleteRemote = deleteTool:FindFirstChildWhichIsA("RemoteEvent", true)
    if not deleteRemote then
        local sc = deleteTool:FindFirstChild("Script")
        if sc then deleteRemote = sc:FindFirstChild("Event") end
    end
    if not deleteRemote then warn("[MANE] No RemoteEvent!"); destroyerRunning=false; return end
    task.spawn(function()
        while destroyerRunning do
            local rootPos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
                and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.zero
            local dirs = {
                Vector3.new(0,10000,0), Vector3.new(0,-10000,0),
                Vector3.new(15000,0,0), Vector3.new(-15000,0,0),
                Vector3.new(0,0,10000),  Vector3.new(0,0,-10000)
            }
            for _, d in ipairs(dirs) do
                pcall(function() deleteRemote:FireServer(nil, rootPos+d) end)
            end
            pcall(function() deleteRemote:FireServer(nil, rootPos) end)
            task.wait(1/destroyerFireRate)
        end
        DestroyerFireBtn.Text = "💥  START BKIT DESTROYER"
        DestroyerFireBtn.BackgroundColor3 = C.BTN_RED
    end)
end)

DestroyerStopBtn.MouseButton1Click:Connect(function()
    destroyerRunning = false
end)

NukeCubesBtn2.MouseButton1Click:Connect(doNukeCubes)

-- ============================================================
--  NUKE CUBES (BKIT DESTROYER)
-- ============================================================
DelCubesBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local deleteTool = char:FindFirstChild("Delete") or LocalPlayer.Backpack:FindFirstChild("Delete")
    if not deleteTool then warn("[MANE] No Delete tool!") return end
    if deleteTool.Parent ~= char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(deleteTool) end
        task.wait(0.4)
        deleteTool = char:FindFirstChild("Delete")
        if not deleteTool then return end
    end
    local deleteRemote = deleteTool:FindFirstChildWhichIsA("RemoteEvent", true)
    if not deleteRemote then
        local sc = deleteTool:FindFirstChild("Script")
        if sc then deleteRemote = sc:FindFirstChild("Event") end
    end
    if not deleteRemote then warn("[MANE] No RemoteEvent in Delete tool!") return end
    local rootPos = char.HumanoidRootPart.Position
    local dirs = {
        Vector3.new(0,10000,0), Vector3.new(0,-10000,0),
        Vector3.new(15000,0,0), Vector3.new(-15000,0,0)
    }
    task.spawn(function()
        for i = 1, 300 do
            for _, d in ipairs(dirs) do
                pcall(function() deleteRemote:FireServer(nil, rootPos+d) end)
            end
            pcall(function() deleteRemote:FireServer(nil, rootPos) end)
            task.wait(0.02)
        end
    end)
end)

-- ============================================================
--  BUTTON WIRING
-- ============================================================
NukeBtn.MouseButton1Click:Connect(function()
    print("[MANE] NUKE called")
    runNuke()
end)

RunBtn.MouseButton1Click:Connect(function()
    print("[MANE] Execute Sequence called")
    runNuke()
end)

FixBtn.MouseButton1Click:Connect(function()
    print("[MANE] FIX called")
    runFix()
end)

local spamming = false
SpamBtn.MouseButton1Click:Connect(function()
    spamming = not spamming
    SpamBtn.Text = "⚡  SPAM MODE: "..(spamming and "ON ✓" or "OFF")
    SpamBtn.BackgroundColor3 = spamming and C.BTN_ORG or C.BTN
end)

task.spawn(function()
    while task.wait(0.45) do
        if spamming then runNuke() end
    end
end)

print("[MANE] UI Loaded — Tabs: NUKE & TXT | FIX | SLOTS | AURA | BKIT | SPAM BUILD")
