--[[
  __  __   _    _  _  ___ ____  _   _  _  _
 |  \/  | /_\  | \| || __| _  \/ _ \| || || |
 | |\/| |/ _ \ | .  || _| |_) | (_) | |_| |_|
 |_|  |_/_/ \_\|_|\_||___|____/ \___/ \___/(_)
credit: stik claude gemini
manesNUKER
]]

-- ============================================================
--  WHITELIST
-- ============================================================
local whitelistedIDs = {
    [10429099415] = "FLAMEFAML",
    [9693065023]  = "kupal_isme8",
    [4674698402]  = "warnmachine12908"
}
local player = game:GetService("Players").LocalPlayer
if not whitelistedIDs[player.UserId] then
    player:Kick("Unauthorized: not whitelisted.")
    return
end
print("[manesNUKER] Whitelist passed!")

-- ============================================================
--  SERVICES
-- ============================================================
local HttpService       = game:GetService("HttpService")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local LocalPlayer       = Players.LocalPlayer

if makefolder then pcall(function() makefolder("WindConfigs") end) end

-- ============================================================
--  COLORS
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
local LIGHT_GRAY = Color3.fromRGB(200, 200, 200)

-- ============================================================
--  SCREEN GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name          = "manesNUKER_GUI"
ScreenGui.ResetOnSpawn  = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Floating toggle
local Toggle = Instance.new("TextButton", ScreenGui)
Toggle.Size             = UDim2.new(0, 52, 0, 52)
Toggle.Position         = UDim2.new(0.05, 0, 0.1, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Toggle.Text             = "MANE"
Toggle.TextColor3       = C.ACCENT
Toggle.Font             = Enum.Font.GothamBold
Toggle.TextSize         = 13
Toggle.ZIndex           = 10
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)

-- Main window
local Main = Instance.new("Frame", ScreenGui)
Main.Size             = UDim2.new(0, 368, 0, 548)
Main.Position         = UDim2.new(0.5, -184, 0.5, -274)
Main.BackgroundColor3 = C.BG
Main.BorderSizePixel  = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- Header
local Header = Instance.new("Frame", Main)
Header.Size             = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = C.HEADER
Header.BorderSizePixel  = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)
local HFill = Instance.new("Frame", Header)
HFill.Size             = UDim2.new(1,0,0,12)
HFill.Position         = UDim2.new(0,0,1,-12)
HFill.BackgroundColor3 = C.HEADER
HFill.BorderSizePixel  = 0
local AccentLine = Instance.new("Frame", Header)
AccentLine.Size             = UDim2.new(1,0,0,2)
AccentLine.Position         = UDim2.new(0,0,1,-2)
AccentLine.BackgroundColor3 = C.ACCENT
AccentLine.BorderSizePixel  = 0

local TitleLbl = Instance.new("TextLabel", Header)
TitleLbl.Size               = UDim2.new(1,-50,1,0)
TitleLbl.Position           = UDim2.new(0,14,0,0)
TitleLbl.Text               = "🔥  manesNUKER"
TitleLbl.TextColor3         = C.ACCENT
TitleLbl.TextXAlignment     = Enum.TextXAlignment.Left
TitleLbl.Font               = Enum.Font.GothamBold
TitleLbl.TextSize           = 14
TitleLbl.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size             = UDim2.new(0,26,0,26)
CloseBtn.Position         = UDim2.new(1,-32,0.5,-13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
CloseBtn.Text             = "✕"
CloseBtn.TextColor3       = Color3.new(1,1,1)
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.TextSize         = 13
CloseBtn.BorderSizePixel  = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- Tab bar
local TabBar = Instance.new("Frame", Main)
TabBar.Size                 = UDim2.new(1,-16,0,30)
TabBar.Position             = UDim2.new(0,8,0,48)
TabBar.BackgroundTransparency = 1
local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection     = Enum.FillDirection.Horizontal
TabLayout.Padding           = UDim.new(0,3)

-- Content area
local ContentArea = Instance.new("Frame", Main)
ContentArea.Size              = UDim2.new(1,-14,1,-90)
ContentArea.Position          = UDim2.new(0,7,0,84)
ContentArea.BackgroundTransparency = 1

-- ============================================================
--  HELPERS
-- ============================================================
local function newPage()
    local sf = Instance.new("ScrollingFrame", ContentArea)
    sf.Size                 = UDim2.new(1,0,1,0)
    sf.BackgroundTransparency = 1
    sf.ScrollBarThickness   = 3
    sf.ScrollBarImageColor3 = C.ACCENT
    sf.CanvasSize           = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize  = Enum.AutomaticSize.Y
    sf.Visible              = false
    local ul = Instance.new("UIListLayout", sf)
    ul.Padding              = UDim.new(0,5)
    ul.HorizontalAlignment  = Enum.HorizontalAlignment.Center
    local upad = Instance.new("UIPadding", sf)
    upad.PaddingTop = UDim.new(0,4)
    return sf
end

local function mkBtn(parent, text, color, h)
    h = h or 34
    local btn = Instance.new("TextButton", parent)
    btn.Size             = UDim2.new(0.97,0,0,h)
    btn.BackgroundColor3 = color or C.BTN
    btn.Text             = text
    btn.Font             = Enum.Font.GothamBold
    btn.TextColor3       = C.TEXT
    btn.TextSize         = 13
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,7)
    local orig = color or C.BTN
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = orig:Lerp(Color3.new(1,1,1),0.1) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = orig end)
    return btn
end

local function mkLabel(parent, text, color)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size                = UDim2.new(0.97,0,0,20)
    lbl.BackgroundTransparency = 1
    lbl.Text                = text
    lbl.TextColor3          = color or C.MUTED
    lbl.Font                = Enum.Font.GothamBold
    lbl.TextSize            = 11
    lbl.TextXAlignment      = Enum.TextXAlignment.Left
    return lbl
end

local function mkSlider(parent, labelText, min, max, default, onChange)
    local frame = Instance.new("Frame", parent)
    frame.Size             = UDim2.new(0.97,0,0,40)
    frame.BackgroundColor3 = C.TAB_OFF
    frame.BorderSizePixel  = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,7)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size               = UDim2.new(0.38,0,1,0)
    lbl.Position           = UDim2.new(0,8,0,0)
    lbl.Text               = labelText..": "..default
    lbl.TextColor3         = C.TEXT
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextSize           = 11
    lbl.BackgroundTransparency = 1

    local bg = Instance.new("TextButton", frame)
    bg.Size             = UDim2.new(0.58,0,0,10)
    bg.Position         = UDim2.new(0.4,0,0.5,-5)
    bg.BackgroundColor3 = Color3.fromRGB(50,50,58)
    bg.Text             = ""
    bg.AutoButtonColor  = false
    bg.BorderSizePixel  = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame", bg)
    local initPct = (default - min)/(max - min)
    fill.Size             = UDim2.new(initPct,0,1,0)
    fill.BackgroundColor3 = C.BTN_ORG
    fill.BorderSizePixel  = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local dragging = false
    bg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local rx = math.clamp((i.Position.X - bg.AbsolutePosition.X)/bg.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(rx,0,1,0)
            local val = min + (max-min)*rx
            lbl.Text = labelText..": "..string.format("%.2g", val)
            onChange(val)
        end
    end)
    return frame, lbl
end

-- ============================================================
--  PAGES
-- ============================================================
local pages    = {}
local tabBtns  = {}
local tabDefs  = {
    {key="nuke",      label="NUKE"},
    {key="fix",       label="FIX"},
    {key="slots",     label="SLOTS"},
    {key="aura",      label="AURA"},
    {key="destroyer", label="BKIT"},
    {key="spambuild", label="SPAM"},
}
for _, d in ipairs(tabDefs) do pages[d.key] = newPage() end

local function switchTab(key)
    for _, d in ipairs(tabDefs) do
        local on = d.key == key
        tabBtns[d.key].BackgroundColor3 = on and C.TAB_ON or C.TAB_OFF
        tabBtns[d.key].TextColor3       = on and Color3.new(1,1,1) or C.MUTED
        pages[d.key].Visible            = on
    end
end
for _, d in ipairs(tabDefs) do
    local tb = Instance.new("TextButton", TabBar)
    tb.Size             = UDim2.new(0,53,1,0)
    tb.BackgroundColor3 = C.TAB_OFF
    tb.Text             = d.label
    tb.Font             = Enum.Font.GothamBold
    tb.TextSize         = 10
    tb.TextColor3       = C.MUTED
    tb.BorderSizePixel  = 0
    tb.AutoButtonColor  = false
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0,6)
    tb.MouseButton1Click:Connect(function() switchTab(d.key) end)
    tabBtns[d.key] = tb
end
switchTab("nuke")

-- ============================================================
--  DRAG
-- ============================================================
do
    local drag, ds, sp
    Header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag=true; ds=i.Position; sp=Main.Position
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

-- Toggle drag+tap
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
                tm=true
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
--  COLOR PICKER (Meteor style)
-- ============================================================
local PickerOverlay = Instance.new("Frame", ScreenGui)
PickerOverlay.Size                  = UDim2.new(1,0,1,0)
PickerOverlay.BackgroundColor3      = Color3.new(0,0,0)
PickerOverlay.BackgroundTransparency = 0.55
PickerOverlay.Visible               = false
PickerOverlay.Active                = true
PickerOverlay.ZIndex                = 20

local PickerBox = Instance.new("Frame", PickerOverlay)
PickerBox.Size             = UDim2.new(0,230,0,300)
PickerBox.Position         = UDim2.new(0.5,-115,0.5,-150)
PickerBox.BackgroundColor3 = Color3.fromRGB(20,20,24)
PickerBox.BorderSizePixel  = 0
PickerBox.ZIndex           = 21
Instance.new("UICorner", PickerBox).CornerRadius = UDim.new(0,8)
local PA = Instance.new("Frame", PickerBox)
PA.Size             = UDim2.new(1,0,0,3)
PA.BackgroundColor3 = C.BTN_PUR
PA.BorderSizePixel  = 0
Instance.new("UICorner", PA).CornerRadius = UDim.new(0,8)
local PT = Instance.new("TextLabel", PickerBox)
PT.Size = UDim2.new(1,0,0,24); PT.Position = UDim2.new(0,0,0,6)
PT.Text = "Color Picker"; PT.TextColor3 = C.TEXT
PT.Font = Enum.Font.GothamBold; PT.TextSize = 13
PT.BackgroundTransparency = 1; PT.ZIndex = 22

local SVSquare = Instance.new("ImageLabel", PickerBox)
SVSquare.Size = UDim2.new(0,200,0,150); SVSquare.Position = UDim2.new(0.5,-100,0,35)
SVSquare.BackgroundColor3 = Color3.fromHSV(0,1,1); SVSquare.BorderSizePixel=0; SVSquare.ZIndex=22
local svGH = Instance.new("UIGradient", SVSquare)
svGH.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))})
svGH.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
svGH.Rotation = 90
Instance.new("UICorner", SVSquare).CornerRadius = UDim.new(0,4)
local SVDark = Instance.new("Frame", SVSquare)
SVDark.Size=UDim2.new(1,0,1,0); SVDark.BackgroundColor3=Color3.new(0,0,0)
SVDark.BorderSizePixel=0; SVDark.ZIndex=23
Instance.new("UICorner", SVDark).CornerRadius = UDim.new(0,4)
local svGV = Instance.new("UIGradient", SVDark)
svGV.Color = ColorSequence.new(Color3.new(0,0,0))
svGV.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})
local SVDot = Instance.new("Frame", SVSquare)
SVDot.Size=UDim2.new(0,12,0,12); SVDot.AnchorPoint=Vector2.new(0.5,0.5)
SVDot.Position=UDim2.new(1,0,0,0); SVDot.BackgroundColor3=Color3.new(1,1,1)
SVDot.BorderSizePixel=2; SVDot.BorderColor3=Color3.new(0,0,0); SVDot.ZIndex=25
Instance.new("UICorner", SVDot).CornerRadius = UDim.new(1,0)

local HueBar = Instance.new("ImageLabel", PickerBox)
HueBar.Size=UDim2.new(0,200,0,18); HueBar.Position=UDim2.new(0.5,-100,0,195)
HueBar.BorderSizePixel=0; HueBar.BackgroundColor3=Color3.new(1,1,1); HueBar.ZIndex=22
Instance.new("UICorner", HueBar).CornerRadius = UDim.new(0,4)
local hG = Instance.new("UIGradient", HueBar)
hG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromHSV(0,   1,1)),
    ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6, 1,1)),
    ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6, 1,1)),
    ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6, 1,1)),
    ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6, 1,1)),
    ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6, 1,1)),
    ColorSequenceKeypoint.new(1,   Color3.fromHSV(1,   1,1)),
})
hG.Rotation = 90
local HueCursor = Instance.new("Frame", HueBar)
HueCursor.Size=UDim2.new(0,4,1,4); HueCursor.AnchorPoint=Vector2.new(0.5,0.5)
HueCursor.Position=UDim2.new(0,0,0.5,0); HueCursor.BackgroundColor3=Color3.new(1,1,1)
HueCursor.BorderSizePixel=1; HueCursor.BorderColor3=Color3.new(0,0,0); HueCursor.ZIndex=24
Instance.new("UICorner", HueCursor).CornerRadius = UDim.new(0,2)

local HexLabel = Instance.new("TextLabel", PickerBox)
HexLabel.Size=UDim2.new(0,50,0,26); HexLabel.Position=UDim2.new(0.5,-100,0,222)
HexLabel.Text="HEX"; HexLabel.TextColor3=C.MUTED
HexLabel.Font=Enum.Font.GothamBold; HexLabel.TextSize=11
HexLabel.BackgroundTransparency=1; HexLabel.ZIndex=22
local HexBox = Instance.new("TextBox", PickerBox)
HexBox.Size=UDim2.new(0,140,0,26); HexBox.Position=UDim2.new(0.5,-45,0,222)
HexBox.BackgroundColor3=Color3.fromRGB(32,32,38); HexBox.TextColor3=C.TEXT
HexBox.Font=Enum.Font.Code; HexBox.TextSize=12
HexBox.Text="FF0000"; HexBox.PlaceholderText="RRGGBB"
HexBox.BorderSizePixel=0; HexBox.ZIndex=22
Instance.new("UICorner", HexBox).CornerRadius = UDim.new(0,4)
local SwatchPreview = Instance.new("Frame", PickerBox)
SwatchPreview.Size=UDim2.new(0,200,0,22); SwatchPreview.Position=UDim2.new(0.5,-100,0,255)
SwatchPreview.BackgroundColor3=Color3.fromRGB(255,0,0); SwatchPreview.BorderSizePixel=0; SwatchPreview.ZIndex=22
Instance.new("UICorner", SwatchPreview).CornerRadius = UDim.new(0,4)
local ConfirmPickerBtn = Instance.new("TextButton", PickerBox)
ConfirmPickerBtn.Size=UDim2.new(0,200,0,28); ConfirmPickerBtn.Position=UDim2.new(0.5,-100,1,-34)
ConfirmPickerBtn.BackgroundColor3=C.BTN_GRN; ConfirmPickerBtn.Text="CONFIRM"
ConfirmPickerBtn.Font=Enum.Font.GothamBold; ConfirmPickerBtn.TextSize=13
ConfirmPickerBtn.TextColor3=Color3.new(1,1,1); ConfirmPickerBtn.BorderSizePixel=0; ConfirmPickerBtn.ZIndex=22
Instance.new("UICorner", ConfirmPickerBtn).CornerRadius = UDim.new(0,5)

local currentPickerBtn = nil
local pH, pS, pV = 0, 1, 1
local function toHex(c) return string.format("%02X%02X%02X",math.round(c.R*255),math.round(c.G*255),math.round(c.B*255)) end
local function updatePicker()
    SVSquare.BackgroundColor3 = Color3.fromHSV(pH,1,1)
    SVDot.Position = UDim2.new(pS,0,1-pV,0)
    HueCursor.Position = UDim2.new(pH,0,0.5,0)
    local c = Color3.fromHSV(pH,pS,pV)
    if currentPickerBtn then currentPickerBtn.BackgroundColor3=c end
    SwatchPreview.BackgroundColor3=c; HexBox.Text=toHex(c)
end
local svDrag, hueDrag = false, false
local function svFromInput(i)
    local rx=math.clamp((i.Position.X-SVSquare.AbsolutePosition.X)/SVSquare.AbsoluteSize.X,0,1)
    local ry=math.clamp((i.Position.Y-SVSquare.AbsolutePosition.Y)/SVSquare.AbsoluteSize.Y,0,1)
    pS=rx; pV=1-ry; updatePicker()
end
local function hueFromInput(i)
    local rx=math.clamp((i.Position.X-HueBar.AbsolutePosition.X)/HueBar.AbsoluteSize.X,0,1)
    pH=rx; updatePicker()
end
for _, el in ipairs({SVSquare, SVDark}) do
    el.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then svDrag=true; svFromInput(i) end
    end)
end
HueBar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then hueDrag=true; hueFromInput(i) end
end)
UserInputService.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
        if svDrag then svFromInput(i) end
        if hueDrag then hueFromInput(i) end
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then svDrag=false; hueDrag=false end
end)
HexBox.FocusLost:Connect(function()
    local h=HexBox.Text:gsub("#",""):upper()
    if #h==6 then
        local r=tonumber("0x"..h:sub(1,2)); local g=tonumber("0x"..h:sub(3,4)); local b=tonumber("0x"..h:sub(5,6))
        if r and g and b then local hv,sv,vv=Color3.toHSV(Color3.fromRGB(r,g,b)); pH,pS,pV=hv,sv,vv; updatePicker() end
    end
end)
ConfirmPickerBtn.MouseButton1Click:Connect(function() PickerOverlay.Visible=false end)
local function openPicker(btn)
    currentPickerBtn=btn
    local h,s,v=Color3.toHSV(btn.BackgroundColor3); pH,pS,pV=h,s,v; updatePicker()
    PickerOverlay.Visible=true
end

-- ============================================================
--  FACE DATA
-- ============================================================
local faces = {"Front","Back","Top","Bottom","Right","Left"}
local faceData = {}
local faceEnums = {
    Front=Enum.NormalId.Front, Back=Enum.NormalId.Back, Top=Enum.NormalId.Top,
    Bottom=Enum.NormalId.Bottom, Right=Enum.NormalId.Right, Left=Enum.NormalId.Left
}

-- ============================================================
--  TAB: NUKE & TXT
-- ============================================================
mkLabel(pages.nuke, "  Face Text & Colors")
for _, name in ipairs(faces) do
    local row = Instance.new("Frame", pages.nuke)
    row.Size             = UDim2.new(0.97,0,0,34)
    row.BackgroundColor3 = C.TAB_OFF
    row.BorderSizePixel  = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,7)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size=UDim2.new(0,40,1,0); lbl.Position=UDim2.new(0,6,0,0)
    lbl.Text=name; lbl.TextColor3=C.MUTED
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=10; lbl.BackgroundTransparency=1
    local txt = Instance.new("TextBox", row)
    txt.Size=UDim2.new(1,-82,0,26); txt.Position=UDim2.new(0,48,0.5,-13)
    txt.BackgroundColor3=Color3.fromRGB(28,28,34); txt.Text="GG'S"
    txt.PlaceholderText=name.." Text"; txt.TextColor3=C.TEXT
    txt.Font=Enum.Font.Gotham; txt.TextSize=11; txt.BorderSizePixel=0
    Instance.new("UICorner", txt).CornerRadius = UDim.new(0,5)
    local clrBtn = Instance.new("TextButton", row)
    clrBtn.Size=UDim2.new(0,28,0,28); clrBtn.Position=UDim2.new(1,-32,0.5,-14)
    clrBtn.BackgroundColor3=Color3.fromRGB(255,0,0); clrBtn.Text=""
    clrBtn.BorderSizePixel=0
    Instance.new("UICorner", clrBtn).CornerRadius = UDim.new(0,5)
    clrBtn.MouseButton1Click:Connect(function() openPicker(clrBtn) end)
    faceData[name] = {txtBox=txt, clrBtn=clrBtn}
end
mkLabel(pages.nuke, "  Actions")
local NukeBtn     = mkBtn(pages.nuke, "🔥  NUKE BRICK  (TOXIC + ANCHOR)", C.BTN_RED, 42)
local RunBtn      = mkBtn(pages.nuke, "▶  EXECUTE SEQUENCE", Color3.fromRGB(0,150,100), 36)
local SpamNukeBtn = mkBtn(pages.nuke, "⚡  SPAM NUKE: OFF", C.BTN)
local DelCubesBtn = mkBtn(pages.nuke, "💣  NUKE CUBES (BKIT)", C.BTN_RED, 38)

-- ============================================================
--  TAB: FIX  — always plastic + unanchor + LIGHT GRAY
-- ============================================================
mkLabel(pages.fix, "  Repair / Clean Brick")
mkLabel(pages.fix, "  → Sets: Plastic, Unanchored, Light Gray, clears text", C.ACCENT)
local FixBtn = mkBtn(pages.fix, "🛠  FIX BRICK  (PLASTIC + UNANCHOR)", C.BTN_BLU, 44)

-- ============================================================
--  TAB: SLOTS
-- ============================================================
mkLabel(pages.slots, "  Config Slots")
local SlotBox = Instance.new("TextBox", pages.slots)
SlotBox.Size=UDim2.new(0.97,0,0,30); SlotBox.PlaceholderText="Config name..."
SlotBox.BackgroundColor3=C.TAB_OFF; SlotBox.TextColor3=C.TEXT
SlotBox.Font=Enum.Font.Gotham; SlotBox.TextSize=12; SlotBox.BorderSizePixel=0
Instance.new("UICorner", SlotBox).CornerRadius = UDim.new(0,7)
local SaveSlotBtn   = mkBtn(pages.slots, "💾  SAVE SLOT",      C.BTN_GRN)
local DeleteSlotBtn = mkBtn(pages.slots, "🗑  DELETE SLOT",    C.BTN_RED)
local RevealSlotBtn = mkBtn(pages.slots, "📂  SHOW ALL SLOTS", C.BTN_BLU)
local SlotListFrame = Instance.new("Frame", pages.slots)
SlotListFrame.Size=UDim2.new(0.97,0,0,0); SlotListFrame.AutomaticSize=Enum.AutomaticSize.Y
SlotListFrame.BackgroundTransparency=1
Instance.new("UIListLayout", SlotListFrame).Padding = UDim.new(0,4)

local function updateSlots()
    for _, v in pairs(SlotListFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
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
                            if type(d.c)=="table" then
                                faceData[n].clrBtn.BackgroundColor3 = Color3.new(d.c[1],d.c[2],d.c[3])
                            elseif type(d.c)=="string" then
                                local hx=d.c:gsub("#","")
                                faceData[n].clrBtn.BackgroundColor3 = Color3.fromRGB(
                                    tonumber("0x"..hx:sub(1,2)), tonumber("0x"..hx:sub(3,4)), tonumber("0x"..hx:sub(5,6)))
                            end
                        end
                    end
                end
            end)
        end
    end
end
SaveSlotBtn.MouseButton1Click:Connect(function()
    local name = SlotBox.Text~="" and SlotBox.Text or "Config_"..os.time()
    local data = {faces={}}
    for n, v in pairs(faceData) do local c=v.clrBtn.BackgroundColor3; data.faces[n]={t=v.txtBox.Text,c={c.R,c.G,c.B}} end
    if writefile then writefile("WindConfigs/"..name..".json", HttpService:JSONEncode(data)); updateSlots() end
end)
DeleteSlotBtn.MouseButton1Click:Connect(function()
    local name=SlotBox.Text
    if name~="" and isfile and isfile("WindConfigs/"..name..".json") then
        if delfile then delfile("WindConfigs/"..name..".json") end
        SlotBox.Text=""; updateSlots()
    end
end)
RevealSlotBtn.MouseButton1Click:Connect(updateSlots)
updateSlots()

-- ============================================================
--  TAB: DELETE AURA
-- ============================================================
mkLabel(pages.aura, "  Delete Aura Settings")
mkSlider(pages.aura, "Range", 5, 150, 35, function(v)
    _G.manesAuraRange = math.floor(v)
end)
_G.manesAuraRange = 35

local daura  = false
local dauras = false

local daurapart = Instance.new("Part")
daurapart.Shape       = Enum.PartType.Ball
daurapart.Anchored    = true; daurapart.CanCollide=false
daurapart.CastShadow  = false; daurapart.CanQuery=false
daurapart.Color       = Color3.fromRGB(255,0,0)
daurapart.Transparency = 1; daurapart.Size=Vector3.new(35,35,35)
daurapart.Parent      = workspace

local filter = OverlapParams.new()
filter.FilterType = Enum.RaycastFilterType.Include
filter.MaxParts   = 100
pcall(function() filter:AddToFilter(workspace:WaitForChild("Bricks",3)) end)

local AuraToggleBtn = mkBtn(pages.aura, "🌀  Delete Aura (Standard): OFF", C.BTN_PUR)
local AuraSolaraBtn = mkBtn(pages.aura, "🌀  Delete Aura (Solara): OFF",   Color3.fromRGB(100,0,150))
mkLabel(pages.aura, "  ⚡ Fires every Heartbeat — maximum speed")

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

-- Aura delete tool helper
local function fireDeleteTool(v)
    local char = LocalPlayer.Character
    if not char then return end
    local del = char:FindFirstChild("Delete") or LocalPlayer.Backpack:FindFirstChild("Delete")
    if not del then return end
    if del.Parent ~= char then del.Parent = char end
    del = char:FindFirstChild("Delete"); if not del then return end
    local origevent = del:FindFirstChild("origevent")
    if origevent then pcall(function() origevent:Invoke(v, v.Position) end); return end
    local sc = del:FindFirstChild("Script")
    if sc then
        local ev = sc:FindFirstChild("Event")
        if ev then pcall(function() ev:FireServer(v, v.Position) end); return end
    end
    local ev2 = del:FindFirstChildWhichIsA("RemoteEvent", true)
    if ev2 then pcall(function() ev2:FireServer(v, v.Position) end) end
end

-- Aura loop — Heartbeat, every frame
RunService.Heartbeat:Connect(function()
    if not (daura or dauras) then return end
    local char = LocalPlayer.Character; if not char then return end
    local pos = char:GetPivot().Position
    local r = _G.manesAuraRange or 35
    daurapart.Size = Vector3.new(r,r,r)
    daurapart.Position = pos
    if daura then
        local parts = workspace:GetPartsInPart(daurapart, filter)
        for _, v in ipairs(parts) do task.spawn(fireDeleteTool, v) end
    end
    if dauras then
        local bf = workspace:FindFirstChild("Bricks")
        if bf then
            for _, v in ipairs(bf:GetDescendants()) do
                if v:IsA("BasePart") and (v.Position-pos).Magnitude < r then task.spawn(fireDeleteTool, v) end
            end
        end
    end
end)

-- ============================================================
--  TAB: BKIT DESTROYER
--  Exact call: pc.Delete.Script.Event:FireServer(Brick, pc.HumanoidRootPart.Position)
-- ============================================================
mkLabel(pages.destroyer, "  💥 BKIT Destroyer")
mkLabel(pages.destroyer, "  Uses: Delete.Script.Event:FireServer(Brick, HRP.Position)", C.ACCENT)
mkLabel(pages.destroyer, "  Needs Delete tool in character!")

local DestroyerFireBtn = mkBtn(pages.destroyer, "💥  START BKIT DESTROYER", C.BTN_RED, 48)
DestroyerFireBtn.TextSize = 14
local DestroyerStopBtn = mkBtn(pages.destroyer, "⏹  STOP", Color3.fromRGB(70,70,80), 32)

local destroyerRunning = false
local destroyerRate    = 50

mkSlider(pages.destroyer, "Rate", 1, 200, 50, function(v) destroyerRate = math.floor(v) end)

mkLabel(pages.destroyer, "  ──────────────────────────────")
local NukeCubesBKIT = mkBtn(pages.destroyer, "💣  NUKE CUBES (200 rapid bursts)", Color3.fromRGB(180,60,0), 38)

-- The exact BKIT fire function
local function fireDestroyer()
    local pc = LocalPlayer.Character
    if not pc then return end
    local hrp = pc:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    -- Auto-equip Delete from backpack if needed
    if not pc:FindFirstChild("Delete") then
        local bp = LocalPlayer.Backpack:FindFirstChild("Delete")
        if bp then bp.Parent = pc; task.wait(0.05) end
    end
    local del = pc:FindFirstChild("Delete")
    if not del then return end
    local sc = del:FindFirstChild("Script")
    if not sc then return end
    local ev = sc:FindFirstChild("Event")
    if not ev then return end
    local brick = ReplicatedStorage:FindFirstChild("Brick")
    if not brick then return end
    -- EXACT call as specified:
    pcall(function()
        ev:FireServer(brick, hrp.Position)
    end)
end

DestroyerFireBtn.MouseButton1Click:Connect(function()
    if destroyerRunning then return end
    destroyerRunning = true
    DestroyerFireBtn.Text             = "💥  DESTROYER RUNNING..."
    DestroyerFireBtn.BackgroundColor3 = C.BTN_GRN
    task.spawn(function()
        while destroyerRunning do
            fireDestroyer()
            task.wait(1 / math.max(destroyerRate, 1))
        end
        DestroyerFireBtn.Text             = "💥  START BKIT DESTROYER"
        DestroyerFireBtn.BackgroundColor3 = C.BTN_RED
    end)
end)

DestroyerStopBtn.MouseButton1Click:Connect(function()
    destroyerRunning = false
end)

NukeCubesBKIT.MouseButton1Click:Connect(function()
    task.spawn(function()
        for i = 1, 200 do
            fireDestroyer()
            task.wait(0.02)
        end
    end)
end)

-- Also wire DelCubesBtn on NUKE tab to the same function
DelCubesBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        for i = 1, 200 do
            fireDestroyer()
            task.wait(0.02)
        end
    end)
end)

-- ============================================================
--  TAB: SPAM BUILD
--  Spams the PAINT remote to place bricks as fast as possible
-- ============================================================
mkLabel(pages.spambuild, "  ⚡ Spam Build — spams brick placement")
mkLabel(pages.spambuild, "  Fires Paint remote directly (no face-paint waits)", C.ACCENT)

local spamBuildActive = false
local SpamBuildToggle = mkBtn(pages.spambuild, "⚡  SPAM BUILD: OFF", C.BTN_ORG, 44)
SpamBuildToggle.TextSize = 14

local spamBuildRate = 20  -- bricks per second
mkSlider(pages.spambuild, "Rate", 1, 60, 20, function(v) spamBuildRate = math.floor(v) end)

mkLabel(pages.spambuild, "  Status")
local SBStatus = Instance.new("TextLabel", pages.spambuild)
SBStatus.Size               = UDim2.new(0.97,0,0,26)
SBStatus.BackgroundColor3   = Color3.fromRGB(22,22,28)
SBStatus.Text               = "Idle"
SBStatus.TextColor3         = C.MUTED
SBStatus.Font               = Enum.Font.GothamBold
SBStatus.TextSize           = 12
SBStatus.BorderSizePixel    = 0
Instance.new("UICorner", SBStatus).CornerRadius = UDim.new(0,6)

SpamBuildToggle.MouseButton1Click:Connect(function()
    spamBuildActive = not spamBuildActive
    SpamBuildToggle.Text             = "⚡  SPAM BUILD: "..(spamBuildActive and "ON ✓" or "OFF")
    SpamBuildToggle.BackgroundColor3 = spamBuildActive and C.BTN_GRN or C.BTN_ORG
    SBStatus.Text      = spamBuildActive and "Running..." or "Idle"
    SBStatus.TextColor3 = spamBuildActive and C.BTN_GRN or C.MUTED
end)

-- ============================================================
--  CORE LOGIC
-- ============================================================
local function getPaintRemote()
    local char = LocalPlayer.Character; if not char then return nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil, nil end
    local tool = char:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
    if not tool then return nil, nil end
    if tool.Parent ~= char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(tool); task.wait(0.25) end
        tool = char:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
        if not tool then return nil, nil end
    end
    local remote = tool:FindFirstChild("Event", true) or tool:FindFirstChildWhichIsA("RemoteEvent", true)
    if not remote then return nil, nil end
    return remote, hrp.Position
end

local function getBrick()
    return ReplicatedStorage:FindFirstChild("Brick")
end

-- NUKER — always TOXIC + ANCHOR
local function runNuke()
    local remote, rootPos = getPaintRemote()
    local brick = getBrick()
    if not remote or not brick then warn("[manesNUKER] Paint remote or Brick missing!"); return end

    local b = "<font size='0'>dx</font>"
    local toxicPresets = {
        Front  = "F"..b.."u"..b.."c"..b.."k A"..b.."d"..b.."m"..b.."i"..b.."n",
        Back   = "say i e"..b.."a"..b.."t p"..b.."u"..b.."s"..b.."s"..b.."y",
        Top    = "hacked by FLAMEFAML/STIK",
        Bottom = "GGS (BIG W TO STIK)",
        Right  = "ADMIN HATES N"..b.."I"..b.."G"..b.."G"..b.."E"..b.."R",
        Left   = "CRY GG'S"
    }
    local key   = "both \u{1F91D}"
    local black = Color3.new(0,0,0)

    -- Step 1: toxic + anchor (forced, always)
    pcall(function() remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, black, "toxic", "anchor") end)
    task.wait(0.3)
    pcall(function() remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, black, "anchor", "") end)
    task.wait(0.25)
    -- Step 2: paint faces
    for _, name in ipairs(faces) do
        local fText  = faceData[name].txtBox.Text ~= "" and faceData[name].txtBox.Text or (toxicPresets[name] or "GG'S")
        local fColor = faceData[name].clrBtn.BackgroundColor3
        pcall(function() remote:FireServer(brick, faceEnums[name], rootPos, key, fColor, "spray", fText) end)
        task.wait(0.12)
    end
    print("[manesNUKER] Nuke done — TOXIC + ANCHORED")
end

-- FIXER — always PLASTIC + UNANCHOR + LIGHT GRAY
local function runFix()
    for _, name in ipairs(faces) do
        faceData[name].txtBox.Text = ""
        faceData[name].clrBtn.BackgroundColor3 = LIGHT_GRAY
    end
    local remote, rootPos = getPaintRemote()
    local brick = getBrick()
    if not remote or not brick then warn("[manesNUKER] Paint remote or Brick missing!"); return end
    local key = "both \u{1F91D}"
    -- plastic + unanchor (forced, always) + light gray
    pcall(function() remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, LIGHT_GRAY, "plastic", "unanchor") end)
    task.wait(0.3)
    pcall(function() remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, LIGHT_GRAY, "unanchor", "") end)
    task.wait(0.3)
    for _, name in ipairs(faces) do
        pcall(function() remote:FireServer(brick, faceEnums[name], rootPos, key, LIGHT_GRAY, "spray", "") end)
        task.wait(0.08)
    end
    print("[manesNUKER] Fix done — PLASTIC + UNANCHOR + LIGHT GRAY")
end

-- SPAM BUILD loop — fires Paint remote directly, no per-face waits
-- This is a tight loop that just keeps placing/painting bricks as fast as possible
task.spawn(function()
    local sbCount = 0
    while true do
        if spamBuildActive then
            -- Get remote fresh each iteration (character may respawn)
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local tool = char:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
                if hrp and tool then
                    if tool.Parent ~= char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then hum:EquipTool(tool) end
                        task.wait(0.2)
                        tool = char:FindFirstChild("Paint")
                    end
                    if tool then
                        local remote = tool:FindFirstChild("Event",true) or tool:FindFirstChildWhichIsA("RemoteEvent",true)
                        local brick  = getBrick()
                        if remote and brick then
                            local key   = "both \u{1F91D}"
                            local black = Color3.new(0,0,0)
                            local rootPos = hrp.Position
                            -- Fire the brick placement call directly — no face paint waits
                            pcall(function() remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, black, "toxic", "anchor") end)
                            sbCount = sbCount + 1
                            SBStatus.Text = "Placed x"..sbCount.." @ "..spamBuildRate.."/s"
                        end
                    end
                end
            end
        end
        task.wait(1 / math.max(spamBuildRate, 1))
    end
end)

-- ============================================================
--  BUTTON WIRING
-- ============================================================
NukeBtn.MouseButton1Click:Connect(function()
    print("[manesNUKER] NUKE")
    task.spawn(runNuke)
end)

RunBtn.MouseButton1Click:Connect(function()
    print("[manesNUKER] Execute Sequence")
    task.spawn(runNuke)
end)

FixBtn.MouseButton1Click:Connect(function()
    print("[manesNUKER] FIX")
    task.spawn(runFix)
end)

local spamNuking = false
SpamNukeBtn.MouseButton1Click:Connect(function()
    spamNuking = not spamNuking
    SpamNukeBtn.Text             = "⚡  SPAM NUKE: "..(spamNuking and "ON ✓" or "OFF")
    SpamNukeBtn.BackgroundColor3 = spamNuking and C.BTN_ORG or C.BTN
end)
task.spawn(function()
    while task.wait(0.5) do
        if spamNuking then pcall(runNuke) end
    end
end)

print("[manesNUKER] Loaded — NUKE | FIX | SLOTS | AURA | BKIT | SPAM")
