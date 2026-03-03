-- 5XR8FCGB3LucyUWFaQw0vkb5AwasAxCT
local _ENV = _ENV or getfenv() 


local _LSFJVTJI = {
    [10429099415] = "FLAMEFAML",
    [9693065023] = "kupal_isme8",
    [4674698402] = "warnmachine12908"
}

local _SXLmzrXN = game:GetService("Players").LocalPlayer

if not _LSFJVTJI[_SXLmzrXN.UserId] then
    _SXLmzrXN:Kick("Unauthorized User: You are not on the whitelist.")
    return 
end

print("Whitelist passed! Loading Nuke...")

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

if makefolder then pcall(function() makefolder("WindConfigs") end) end

local _dCSxufdl = Instance.new("_dCSxufdl", LocalPlayer:WaitForChild("PlayerGui"))
_dCSxufdl.Name = "WindUltimate_GodMode"
_dCSxufdl.ResetOnSpawn = false
_dCSxufdl.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local _yJAXcqNB = Instance.new("TextButton", _dCSxufdl)
_yJAXcqNB.Size = UDim2.new(0, 45, 0, 45)
_yJAXcqNB.Position = UDim2.new(0.05, 0, 0.1, 0)
_yJAXcqNB.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
_yJAXcqNB.Text = "MANE"
_yJAXcqNB.TextColor3 = Color3.fromRGB(0, 255, 150)
_yJAXcqNB.Font = Enum.Font.GothamBold
_yJAXcqNB.TextSize = 14
Instance.new("UICorner", _yJAXcqNB).CornerRadius = UDim.new(1, 0)

local _vxOnNTEO = Instance.new("Frame", _dCSxufdl)
_vxOnNTEO.Size = UDim2.new(0, 340, 0, 520)
_vxOnNTEO.Position = UDim2.new(0.5, -170, 0.5, -260)
_vxOnNTEO.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
_vxOnNTEO.BorderSizePixel = 0
Instance.new("UICorner", _vxOnNTEO).CornerRadius = UDim.new(0, 10)

local _zMnodvnX, hasMoved = false, false
local _OufZsRDc, toggleStartInput

_yJAXcqNB.InputBegan:Connect(function(_vOzJczBF)
    if _vOzJczBF.UserInputType == Enum.UserInputType.MouseButton1 or _vOzJczBF.UserInputType == Enum.UserInputType.Touch then
        _zMnodvnX = true
        hasMoved = false
        _OufZsRDc = _yJAXcqNB.Position
        toggleStartInput = _vOzJczBF.Position
    end
end)

UserInputService.InputChanged:Connect(function(_vOzJczBF)
    if _zMnodvnX and (_vOzJczBF.UserInputType == Enum.UserInputType.MouseMovement or _vOzJczBF.UserInputType == Enum.UserInputType.Touch) then
        local _SXpfNnJt = _vOzJczBF.Position - toggleStartInput
        if _SXpfNnJt.Magnitude > 3 then 
            hasMoved = true
            _yJAXcqNB.Position = UDim2.new(
                _OufZsRDc.X.Scale, _OufZsRDc.X.Offset + _SXpfNnJt.X,
                _OufZsRDc.Y.Scale, _OufZsRDc.Y.Offset + _SXpfNnJt.Y
            )
        end
    end
end)

UserInputService.InputEnded:Connect(function(_vOzJczBF)
    if _vOzJczBF.UserInputType == Enum.UserInputType.MouseButton1 or _vOzJczBF.UserInputType == Enum.UserInputType.Touch then
        if _zMnodvnX then
            _zMnodvnX = false
            if not hasMoved then _vxOnNTEO.Visible = not _vxOnNTEO.Visible end
        end
    end
end)

local _pFqaLRWL = Instance.new("Frame", _vxOnNTEO)
_pFqaLRWL.Size = UDim2.new(1, 0, 0, 40)
_pFqaLRWL.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Instance.new("UICorner", _pFqaLRWL).CornerRadius = UDim.new(0, 10)

local _nVboyXFL = Instance.new("TextLabel", _pFqaLRWL)
_nVboyXFL.Size = UDim2.new(1, -15, 1, 0)
_nVboyXFL.Position = UDim2.new(0, 15, 0, 0)
_nVboyXFL.Text = "MANE | SERVER NUKE & AURA"
_nVboyXFL.TextColor3 = Color3.fromRGB(0, 200, 255)
_nVboyXFL.TextXAlignment = Enum.TextXAlignment.Left
_nVboyXFL.Font = Enum.Font.GothamBold
_nVboyXFL.TextSize = 14
_nVboyXFL.BackgroundTransparency = 1

local _PNippQna = Instance.new("ScrollingFrame", _vxOnNTEO)
_PNippQna.Size = UDim2.new(1, -20, 1, -55)
_PNippQna.Position = UDim2.new(0, 10, 0, 50)
_PNippQna.BackgroundTransparency = 1
_PNippQna.ScrollBarThickness = 2
_PNippQna.CanvasSize = UDim2.new(0, 0, 0, 1800)

local _ewyHbjBm = Instance.new("UIListLayout", _PNippQna)
_ewyHbjBm.Padding = UDim.new(0, 6)
_ewyHbjBm.HorizontalAlignment = Enum.HorizontalAlignment.Center

local _eciOfgsa = Instance.new("Frame", _dCSxufdl)
_eciOfgsa.Size = UDim2.new(1, 0, 1, 0)
_eciOfgsa.BackgroundColor3 = Color3.new(0,0,0)
_eciOfgsa.BackgroundTransparency = 0.6
_eciOfgsa.Visible = false
_eciOfgsa.Active = true

local _lOSwTfqY = Instance.new("Frame", _eciOfgsa)
_lOSwTfqY.Size = UDim2.new(0, 230, 0, 300)
_lOSwTfqY.Position = UDim2.new(0.5, -115, 0.5, -150)
_lOSwTfqY.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
_lOSwTfqY.BorderSizePixel = 0
Instance.new("UICorner", _lOSwTfqY).CornerRadius = UDim.new(0, 8)

local _TdEfxzOT = Instance.new("Frame", _lOSwTfqY)
_TdEfxzOT.Size = UDim2.new(1, 0, 0, 3)
_TdEfxzOT.Position = UDim2.new(0, 0, 0, 0)
_TdEfxzOT.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
_TdEfxzOT.BorderSizePixel = 0
Instance.new("UICorner", _TdEfxzOT).CornerRadius = UDim.new(0, 8)

local _liTsLXSE = Instance.new("TextLabel", _lOSwTfqY)
_liTsLXSE.Size = UDim2.new(1, 0, 0, 24)
_liTsLXSE.Position = UDim2.new(0, 0, 0, 6)
_liTsLXSE.Text = "Color Picker"
_liTsLXSE.TextColor3 = Color3.fromRGB(200, 200, 210)
_liTsLXSE.Font = Enum.Font.GothamBold
_liTsLXSE.TextSize = 13
_liTsLXSE.BackgroundTransparency = 1

local _qwNvHYpB = Instance.new("ImageLabel", _lOSwTfqY)
_qwNvHYpB.Name = "_qwNvHYpB"
_qwNvHYpB.Size = UDim2.new(0, 200, 0, 150)
_qwNvHYpB.Position = UDim2.new(0.5, -100, 0, 35)
_qwNvHYpB.BackgroundColor3 = Color3.fromHSV(0, 1, 1) 
_qwNvHYpB.BorderSizePixel = 0

local _JVvxCRoa = Instance.new("UIGradient", _qwNvHYpB)
_JVvxCRoa.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
    ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
})
_JVvxCRoa.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(1, 1)
})
_JVvxCRoa.Rotation = 90
Instance.new("UICorner", _qwNvHYpB).CornerRadius = UDim.new(0, 4)

local _fsYyQXaQ = Instance.new("Frame", _qwNvHYpB)
_fsYyQXaQ.Size = UDim2.new(1, 0, 1, 0)
_fsYyQXaQ.BackgroundColor3 = Color3.new(0, 0, 0)
_fsYyQXaQ.BorderSizePixel = 0
_fsYyQXaQ.BackgroundTransparency = 0
Instance.new("UICorner", _fsYyQXaQ).CornerRadius = UDim.new(0, 4)
local _UxEhbBcf = Instance.new("UIGradient", _fsYyQXaQ)
_UxEhbBcf.Color = ColorSequence.new(Color3.new(0,0,0))
_UxEhbBcf.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(1, 0)
})
_UxEhbBcf.Rotation = 0 

local _VfJOMqjN = Instance.new("Frame", _qwNvHYpB)
_VfJOMqjN.Size = UDim2.new(0, 12, 0, 12)
_VfJOMqjN.AnchorPoint = Vector2.new(0.5, 0.5)
_VfJOMqjN.Position = UDim2.new(1, 0, 0, 0)
_VfJOMqjN.BackgroundColor3 = Color3.new(1,1,1)
_VfJOMqjN.BorderSizePixel = 2
_VfJOMqjN.BorderColor3 = Color3.new(0,0,0)
_VfJOMqjN.ZIndex = 5
Instance.new("UICorner", _VfJOMqjN).CornerRadius = UDim.new(1, 0)

local _ymxIOgeb = Instance.new("ImageLabel", _lOSwTfqY)
_ymxIOgeb.Size = UDim2.new(0, 200, 0, 18)
_ymxIOgeb.Position = UDim2.new(0.5, -100, 0, 195)
_ymxIOgeb.BorderSizePixel = 0
_ymxIOgeb.BackgroundColor3 = Color3.new(1,1,1)
Instance.new("UICorner", _ymxIOgeb).CornerRadius = UDim.new(0, 4)
local _lVlruGSa = Instance.new("UIGradient", _ymxIOgeb)
_lVlruGSa.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0/6,  Color3.fromHSV(0/6,  1, 1)),
    ColorSequenceKeypoint.new(1/6,  Color3.fromHSV(1/6,  1, 1)),
    ColorSequenceKeypoint.new(2/6,  Color3.fromHSV(2/6,  1, 1)),
    ColorSequenceKeypoint.new(3/6,  Color3.fromHSV(3/6,  1, 1)),
    ColorSequenceKeypoint.new(4/6,  Color3.fromHSV(4/6,  1, 1)),
    ColorSequenceKeypoint.new(5/6,  Color3.fromHSV(5/6,  1, 1)),
    ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,     1, 1)),
})
_lVlruGSa.Rotation = 90

local _TrzQPOje = Instance.new("Frame", _ymxIOgeb)
_TrzQPOje.Size = UDim2.new(0, 4, 1, 4)
_TrzQPOje.AnchorPoint = Vector2.new(0.5, 0.5)
_TrzQPOje.Position = UDim2.new(0, 0, 0.5, 0)
_TrzQPOje.BackgroundColor3 = Color3.new(1,1,1)
_TrzQPOje.BorderSizePixel = 1
_TrzQPOje.BorderColor3 = Color3.new(0,0,0)
_TrzQPOje.ZIndex = 5
Instance.new("UICorner", _TrzQPOje).CornerRadius = UDim.new(0, 2)

local _ZHBysggy = Instance.new("TextLabel", _lOSwTfqY)
_ZHBysggy.Size = UDim2.new(0, 50, 0, 26)
_ZHBysggy.Position = UDim2.new(0.5, -100, 0, 222)
_ZHBysggy.Text = "HEX"
_ZHBysggy.TextColor3 = Color3.fromRGB(140, 140, 155)
_ZHBysggy.Font = Enum.Font.GothamBold
_ZHBysggy.TextSize = 11
_ZHBysggy.BackgroundTransparency = 1

local _lHaOsbpU = Instance.new("TextBox", _lOSwTfqY)
_lHaOsbpU.Size = UDim2.new(0, 140, 0, 26)
_lHaOsbpU.Position = UDim2.new(0.5, -45, 0, 222)
_lHaOsbpU.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
_lHaOsbpU.TextColor3 = Color3.fromRGB(220, 220, 230)
_lHaOsbpU.Font = Enum.Font.Code
_lHaOsbpU.TextSize = 12
_lHaOsbpU.Text = "FF0000"
_lHaOsbpU.PlaceholderText = "RRGGBB"
_lHaOsbpU.BorderSizePixel = 0
Instance.new("UICorner", _lHaOsbpU).CornerRadius = UDim.new(0, 4)

local _SkjybzUl = Instance.new("Frame", _lOSwTfqY)
_SkjybzUl.Size = UDim2.new(0, 200, 0, 22)
_SkjybzUl.Position = UDim2.new(0.5, -100, 0, 255)
_SkjybzUl.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
_SkjybzUl.BorderSizePixel = 0
Instance.new("UICorner", _SkjybzUl).CornerRadius = UDim.new(0, 4)

local _cBWrdSUO = Instance.new("TextButton", _lOSwTfqY)
_cBWrdSUO.Size = UDim2.new(0, 200, 0, 28)
_cBWrdSUO.Position = UDim2.new(0.5, -100, 1, -34)
_cBWrdSUO.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
_cBWrdSUO.Text = "CONFIRM"
_cBWrdSUO.Font = Enum.Font.GothamBold
_cBWrdSUO.TextSize = 13
_cBWrdSUO.TextColor3 = Color3.new(1,1,1)
_cBWrdSUO.BorderSizePixel = 0
Instance.new("UICorner", _cBWrdSUO).CornerRadius = UDim.new(0, 5)

local _apGHtjYP = nil
local _oSuCoBRI, currentSat, currentVal = 0, 1, 1

local function toHexStr(c)
    return string.format("%02X%02X%02X", math.round(c.R*255), math.round(c.G*255), math.round(c.B*255))
end

local function updatePickerUI()
    
    _qwNvHYpB.BackgroundColor3 = Color3.fromHSV(_oSuCoBRI, 1, 1)
    
    _VfJOMqjN.Position = UDim2.new(currentSat, 0, 1 - currentVal, 0)
    
    _TrzQPOje.Position = UDim2.new(_oSuCoBRI, 0, 0.5, 0)
    
    local c = Color3.fromHSV(_oSuCoBRI, currentSat, currentVal)
    if _apGHtjYP then _apGHtjYP.BackgroundColor3 = c end
    _SkjybzUl.BackgroundColor3 = c
    _lHaOsbpU.Text = toHexStr(c)
end

local _EMKXXykn = false
local function updateSVFromInput(_vOzJczBF)
    local _jFOqYaeq = math.clamp((_vOzJczBF.Position.X - _qwNvHYpB.AbsolutePosition.X) / _qwNvHYpB.AbsoluteSize.X, 0, 1)
    local _cCJrXvvW = math.clamp((_vOzJczBF.Position.Y - _qwNvHYpB.AbsolutePosition.Y) / _qwNvHYpB.AbsoluteSize.Y, 0, 1)
    currentSat = _jFOqYaeq
    currentVal = 1 - _cCJrXvvW
    updatePickerUI()
end

_qwNvHYpB.InputBegan:Connect(function(_vOzJczBF)
    if _vOzJczBF.UserInputType == Enum.UserInputType.MouseButton1 or _vOzJczBF.UserInputType == Enum.UserInputType.Touch then
        _EMKXXykn = true
        updateSVFromInput(_vOzJczBF)
    end
end)

_fsYyQXaQ.InputBegan:Connect(function(_vOzJczBF)
    if _vOzJczBF.UserInputType == Enum.UserInputType.MouseButton1 or _vOzJczBF.UserInputType == Enum.UserInputType.Touch then
        _EMKXXykn = true
        updateSVFromInput(_vOzJczBF)
    end
end)

local _fBKopGKn = false
local function updateHueFromInput(_vOzJczBF)
    local _jFOqYaeq = math.clamp((_vOzJczBF.Position.X - _ymxIOgeb.AbsolutePosition.X) / _ymxIOgeb.AbsoluteSize.X, 0, 1)
    _oSuCoBRI = _jFOqYaeq
    updatePickerUI()
end

_ymxIOgeb.InputBegan:Connect(function(_vOzJczBF)
    if _vOzJczBF.UserInputType == Enum.UserInputType.MouseButton1 or _vOzJczBF.UserInputType == Enum.UserInputType.Touch then
        _fBKopGKn = true
        updateHueFromInput(_vOzJczBF)
    end
end)

UserInputService.InputChanged:Connect(function(_vOzJczBF)
    if _vOzJczBF.UserInputType == Enum.UserInputType.MouseMovement or _vOzJczBF.UserInputType == Enum.UserInputType.Touch then
        if _EMKXXykn then updateSVFromInput(_vOzJczBF) end
        if _fBKopGKn then updateHueFromInput(_vOzJczBF) end
    end
end)
UserInputService.InputEnded:Connect(function(_vOzJczBF)
    if _vOzJczBF.UserInputType == Enum.UserInputType.MouseButton1 or _vOzJczBF.UserInputType == Enum.UserInputType.Touch then
        _EMKXXykn = false
        _fBKopGKn = false
    end
end)

_lHaOsbpU.FocusLost:Connect(function()
    local _hnQLdfwr = _lHaOsbpU.Text:gsub("#",""):upper()
    if #_hnQLdfwr == 6 then
        local r = tonumber("0x".._hnQLdfwr:sub(1,2))
        local g = tonumber("0x".._hnQLdfwr:sub(3,4))
        local b = tonumber("0x".._hnQLdfwr:sub(5,6))
        if r and g and b then
            local c = Color3.fromRGB(r, g, b)
            local h, s, v = Color3.toHSV(c)
            _oSuCoBRI, currentSat, currentVal = h, s, v
            updatePickerUI()
        end
    end
end)

_cBWrdSUO.MouseButton1Click:Connect(function() _eciOfgsa.Visible = false end)

local function openPicker(_iTGuMwae)
    _apGHtjYP = _iTGuMwae
    local c = _iTGuMwae.BackgroundColor3
    local h, s, v = Color3.toHSV(c)
    _oSuCoBRI, currentSat, currentVal = h, s, v
    updatePickerUI()
    _eciOfgsa.Visible = true
end

local _wCYRKXCE = {"Front", "Back", "Top", "Bottom", "Right", "Left"}
local _kTbaCWkh = {}

for _, _FHiYXeXM in ipairs(_wCYRKXCE) do
    local _aCaObOUi = Instance.new("Frame", _PNippQna)
    _aCaObOUi.Size = UDim2.new(0.95, 0, 0, 35)
    _aCaObOUi.BackgroundTransparency = 1
    local _nwTIxDkb = Instance.new("TextBox", _aCaObOUi)
    _nwTIxDkb.Size = UDim2.new(0.75, 0, 0, 30)
    _nwTIxDkb.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    _nwTIxDkb.Text = "GG'S"
    _nwTIxDkb.PlaceholderText = _FHiYXeXM .. " Text"
    _nwTIxDkb.TextColor3 = Color3.new(1, 1, 1)
    _nwTIxDkb.Font = Enum.Font.Gotham
    _nwTIxDkb.TextSize = 12
    Instance.new("UICorner", _nwTIxDkb)
    local _LKlMAfJV = Instance.new("TextButton", _aCaObOUi)
    _LKlMAfJV.Size = UDim2.new(0.2, 0, 0, 30)
    _LKlMAfJV.Position = UDim2.new(0.8, 0, 0, 0)
    _LKlMAfJV.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    _LKlMAfJV.Text = ""
    Instance.new("UICorner", _LKlMAfJV)
    _LKlMAfJV.MouseButton1Click:Connect(function() openPicker(_LKlMAfJV) end)
    _kTbaCWkh[_FHiYXeXM] = {txtBox = _nwTIxDkb, _LKlMAfJV = _LKlMAfJV}
end

local function createBtn(_NPgoFraX, _tRClAhuJ)
    local _iTGuMwae = Instance.new("TextButton", _PNippQna)
    _iTGuMwae.Size = UDim2.new(0.95, 0, 0, 35)
    _iTGuMwae.BackgroundColor3 = _tRClAhuJ
    _iTGuMwae.Text = _NPgoFraX
    _iTGuMwae.Font = Enum.Font.GothamBold
    _iTGuMwae.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", _iTGuMwae)
    return _iTGuMwae
end

local _AcGQrshs = createBtn("Material: PLASTIC", Color3.fromRGB(120, 0, 200))
local _aRnXwpVh = createBtn("Auto-Anchor: OFF", Color3.fromRGB(0, 120, 200))
local _OYnuQmAv = createBtn("Spam Mode: OFF", Color3.fromRGB(40, 40, 45))
local _DsFIqTey = createBtn("LOAD TOXIC PRESETS", Color3.fromRGB(150, 0, 0))
local _RgHTIPlc = createBtn("FIX / CLEAN BRICK", Color3.fromRGB(150, 150, 160))
local _XqjwCbgO = createBtn("EXECUTE SEQUENCE", Color3.fromRGB(0, 150, 100))
_XqjwCbgO.Size = UDim2.new(0.95, 0, 0, 45)

local _qCdTDhTR = createBtn("NUKE CUBES", Color3.fromRGB(200, 50, 0))
local _jxROvTFh = createBtn("BKIT DESTROYER (CAREFUL)", Color3.fromRGB(220, 20, 20))
_jxROvTFh.Size = UDim2.new(0.95, 0, 0, 50)
_jxROvTFh.TextColor3 = Color3.fromRGB(255, 255, 200)
_jxROvTFh.Font = Enum.Font.GothamBlack
_jxROvTFh.TextSize = 18

local _WvUSSajZ = 35
local _ULpOEffV = false
local _IgFLnRKt = false
local _uDYntway = true

local _ZUvfVyuY = Instance.new("Part")
_ZUvfVyuY.Shape = Enum.PartType.Ball
_ZUvfVyuY.Anchored = true
_ZUvfVyuY.CanCollide = false
_ZUvfVyuY.CastShadow = false
_ZUvfVyuY.CanQuery = false
_ZUvfVyuY.Color = Color3.fromRGB(255, 0, 0)
_ZUvfVyuY.Transparency = 1
_ZUvfVyuY.Size = Vector3.new(_WvUSSajZ, _WvUSSajZ, _WvUSSajZ)
_ZUvfVyuY.Parent = workspace

local _mXwrIMHm = OverlapParams.new()
_mXwrIMHm.FilterType = Enum.RaycastFilterType.Include
_mXwrIMHm.MaxParts = 8
pcall(function() _mXwrIMHm:AddToFilter(workspace:WaitForChild("Bricks", 3)) end)

local _QKGIicJn = Instance.new("TextLabel", _PNippQna)
_QKGIicJn.Size = UDim2.new(0.95, 0, 0, 30)
_QKGIicJn.Text = "
_QKGIicJn.TextColor3 = Color3.new(0.6, 0.6, 0.6)
_QKGIicJn.Font = Enum.Font.GothamBold
_QKGIicJn.TextSize = 14
_QKGIicJn.BackgroundTransparency = 1

local _evaaDzBE = Instance.new("Frame", _PNippQna)
_evaaDzBE.Size = UDim2.new(0.95, 0, 0, 40)
_evaaDzBE.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Instance.new("UICorner", _evaaDzBE)

local _OGQbQQOy = Instance.new("TextLabel", _evaaDzBE)
_OGQbQQOy.Size = UDim2.new(0.4, 0, 1, 0)
_OGQbQQOy.Text = "Range: 35"
_OGQbQQOy.TextColor3 = Color3.new(1,1,1)
_OGQbQQOy.Font = Enum.Font.GothamBold
_OGQbQQOy.TextSize = 12
_OGQbQQOy.BackgroundTransparency = 1

local _WomFMUlA = Instance.new("TextButton", _evaaDzBE)
_WomFMUlA.Size = UDim2.new(0.55, 0, 0, 12)
_WomFMUlA.Position = UDim2.new(0.4, 0, 0.5, -6)
_WomFMUlA.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
_WomFMUlA.Text = ""
_WomFMUlA.AutoButtonColor = false
Instance.new("UICorner", _WomFMUlA).CornerRadius = UDim.new(1, 0)

local _eXgrgdxM = Instance.new("Frame", _WomFMUlA)
_eXgrgdxM.Size = UDim2.new(0.35, 0, 1, 0)
_eXgrgdxM.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
Instance.new("UICorner", _eXgrgdxM).CornerRadius = UDim.new(1, 0)

local _JriiznWh = false
_WomFMUlA.InputBegan:Connect(function(_vOzJczBF)
    if _vOzJczBF.UserInputType == Enum.UserInputType.MouseButton1 or _vOzJczBF.UserInputType == Enum.UserInputType.Touch then
        _JriiznWh = true
        _ZUvfVyuY.Transparency = 0.5
    end
end)
UserInputService.InputEnded:Connect(function(_vOzJczBF)
    if _vOzJczBF.UserInputType == Enum.UserInputType.MouseButton1 or _vOzJczBF.UserInputType == Enum.UserInputType.Touch then
        if _JriiznWh then
            _JriiznWh = false
            if not _ULpOEffV and not _IgFLnRKt then _ZUvfVyuY.Transparency = 1 end
        end
    end
end)
UserInputService.InputChanged:Connect(function(_vOzJczBF)
    if _JriiznWh and (_vOzJczBF.UserInputType == Enum.UserInputType.MouseMovement or _vOzJczBF.UserInputType == Enum.UserInputType.Touch) then
        local _nXVhSocD = _vOzJczBF.Position.X - _WomFMUlA.AbsolutePosition.X
        local _bCkHoUIx = math.clamp(_nXVhSocD / _WomFMUlA.AbsoluteSize.X, 0, 1)
        _eXgrgdxM.Size = UDim2.new(_bCkHoUIx, 0, 1, 0)
        _WvUSSajZ = math.floor(5 + ((100 - 5) * _bCkHoUIx))
        _OGQbQQOy.Text = "Range: " .. _WvUSSajZ
        _ZUvfVyuY.Size = Vector3.new(_WvUSSajZ, _WvUSSajZ, _WvUSSajZ)
        _ZUvfVyuY.Position = LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position or Vector3.zero
    end
end)

local _ciYYnFzW = createBtn("Delete Aura: OFF", Color3.fromRGB(150, 0, 150))
_ciYYnFzW.MouseButton1Click:Connect(function()
    _ULpOEffV = not _ULpOEffV
    _ciYYnFzW.Text = "Delete Aura: " .. (_ULpOEffV and "ON" or "OFF")
    _ZUvfVyuY.Transparency = (_ULpOEffV or _IgFLnRKt) and 0.5 or 1
end)

local _EvVhjXob = createBtn("Delete Aura (Solara): OFF", Color3.fromRGB(100, 0, 150))
_EvVhjXob.MouseButton1Click:Connect(function()
    _IgFLnRKt = not _IgFLnRKt
    _EvVhjXob.Text = "Delete Aura (Solara): " .. (_IgFLnRKt and "ON" or "OFF")
    _ZUvfVyuY.Transparency = (_ULpOEffV or _IgFLnRKt) and 0.5 or 1
end)

local _PFuDMOzb = Instance.new("TextBox", _PNippQna)
_PFuDMOzb.Size = UDim2.new(0.95, 0, 0, 30)
_PFuDMOzb.PlaceholderText = "Type Config Name..."
_PFuDMOzb.BackgroundColor3 = Color3.fromRGB(30,30,35)
_PFuDMOzb.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", _PFuDMOzb)

local _XTUiibEe = createBtn("SAVE NEW SLOT", Color3.fromRGB(40, 100, 50))
local _hUBgMjGw = createBtn("DELETE SELECTED SLOT", Color3.fromRGB(150, 40, 40))
local _kVFlXPat = createBtn("REVEAL ALL SLOTS", Color3.fromRGB(0, 100, 150))
local _zsGwpxkV = Instance.new("Frame", _PNippQna)
_zsGwpxkV.Size = UDim2.new(0.95, 0, 0, 0)
_zsGwpxkV.AutomaticSize = Enum.AutomaticSize.Y
_zsGwpxkV.BackgroundTransparency = 1
Instance.new("UIListLayout", _zsGwpxkV).Padding = UDim.new(0, 4)

local function updateSlots()
    for _, v in pairs(_zsGwpxkV:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    if not isfolder or not isfolder("WindConfigs") then return end
    for _, file in pairs(listfiles("WindConfigs")) do
        local _FHiYXeXM = file:match("WindConfigs/(.+)%.json") or file:match("WindConfigs\\(.+)%.json")
        if _FHiYXeXM then
            local b = createBtn("LOAD: ".._FHiYXeXM, Color3.fromRGB(40, 40, 45))
            b.Parent = _zsGwpxkV
            b.MouseButton1Click:Connect(function()
                local _hGRsjxZl, result = pcall(function() return HttpService:JSONDecode(readfile(file)) end)
                if not _hGRsjxZl then warn("[WIND GUI] Failed to load slot: "..tostring(result)) return end
                local _xrhwCvZZ = result
                _PFuDMOzb.Text = _FHiYXeXM
                if _xrhwCvZZ._wCYRKXCE then
                    for n, d in pairs(_xrhwCvZZ._wCYRKXCE) do
                        if _kTbaCWkh[n] then
                            _kTbaCWkh[n].txtBox.Text = d.t or ""
                            
                            if type(d.c) == "table" then
                                _kTbaCWkh[n]._LKlMAfJV.BackgroundColor3 = Color3.new(d.c[1], d.c[2], d.c[3])
                            elseif type(d.c) == "string" then
                                local _hnQLdfwr = d.c:gsub("#","")
                                _kTbaCWkh[n]._LKlMAfJV.BackgroundColor3 = Color3.fromRGB(
                                    tonumber("0x".._hnQLdfwr:sub(1,2)),
                                    tonumber("0x".._hnQLdfwr:sub(3,4)),
                                    tonumber("0x".._hnQLdfwr:sub(5,6))
                                )
                            end
                        end
                    end
                end
            end)
        end
    end
end

_XTUiibEe.MouseButton1Click:Connect(function()
    local _FHiYXeXM = _PFuDMOzb.Text ~= "" and _PFuDMOzb.Text or "Config_"..os.time()
    local _xrhwCvZZ = {_wCYRKXCE = {}}
    for n, v in pairs(_kTbaCWkh) do
        local c = v._LKlMAfJV.BackgroundColor3
        _xrhwCvZZ._wCYRKXCE[n] = {t = v.txtBox.Text, c = {c.R, c.G, c.B}}
    end
    if writefile then
        writefile("WindConfigs/".._FHiYXeXM..".json", HttpService:JSONEncode(_xrhwCvZZ))
        updateSlots()
    end
end)

_hUBgMjGw.MouseButton1Click:Connect(function()
    local _FHiYXeXM = _PFuDMOzb.Text
    if _FHiYXeXM ~= "" and isfile and isfile("WindConfigs/".._FHiYXeXM..".json") then
        if delfile then delfile("WindConfigs/".._FHiYXeXM..".json") end
        _PFuDMOzb.Text = ""
        updateSlots()
    end
end)

_kVFlXPat.MouseButton1Click:Connect(updateSlots)
updateSlots()

local _VbXeLyoe, autoAnchor, useToxic = false, false, false
local function fromHex(_hnQLdfwr)
    _hnQLdfwr = _hnQLdfwr:gsub("#","")
    return Color3.fromRGB(tonumber("0x".._hnQLdfwr:sub(1,2)), tonumber("0x".._hnQLdfwr:sub(3,4)), tonumber("0x".._hnQLdfwr:sub(5,6)))
end

local function runFix()
    local _XcKBLpID = LocalPlayer.Character
    if not _XcKBLpID then warn("[WIND GUI] Error: Character not found!") return end

    local _MmhRUhed = _XcKBLpID:FindFirstChild("HumanoidRootPart")
    if not _MmhRUhed then warn("[WIND GUI] Error: HumanoidRootPart missing!") return end

    
    local _vLWSYihP = _XcKBLpID:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
    if not _vLWSYihP then
        warn("[WIND GUI] ERROR: 'Paint' _vLWSYihP missing! You must have the Paint _vLWSYihP in your inventory.")
        return
    end

    local _zWGJfAuo = ReplicatedStorage:FindFirstChild("Brick")
    if not _zWGJfAuo then
        warn("[WIND GUI] ERROR: 'Brick' not found in ReplicatedStorage!")
        return
    end

    
    if _vLWSYihP.Parent ~= _XcKBLpID then
        local _CXwjrKxf = _XcKBLpID:FindFirstChildOfClass("Humanoid")
        if _CXwjrKxf then
            _CXwjrKxf:EquipTool(_vLWSYihP)
            task.wait(0.35)
        end
        
        _vLWSYihP = _XcKBLpID:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
        if not _vLWSYihP then warn("[WIND GUI] ERROR: Paint _vLWSYihP lost after equip attempt.") return end
    end

    
    local _bfiLzzvN = _vLWSYihP:FindFirstChild("Event", true) or _vLWSYihP:FindFirstChildWhichIsA("RemoteEvent", true)
    if not _bfiLzzvN then
        warn("[WIND GUI] ERROR: RemoteEvent not found inside the Paint _vLWSYihP.")
        return
    end

    local _GKlyfDdV = _MmhRUhed.Position
    local _iGgEDzLH = "both \u{1F91D}"
    local _YVtjoXvh = useToxic and "toxic" or "plastic"
    
    local _jJmjyiqZ = Color3.new(0, 0, 0)

    print("[WIND GUI] Running Sequence...")

    
    pcall(function() _bfiLzzvN:FireServer(_zWGJfAuo, Enum.NormalId.Top, _GKlyfDdV, _iGgEDzLH, _jJmjyiqZ, _YVtjoXvh, "anchor") end)
    task.wait(0.4)

    
    if autoAnchor then
        pcall(function() _bfiLzzvN:FireServer(_zWGJfAuo, Enum.NormalId.Top, _GKlyfDdV, _iGgEDzLH, _jJmjyiqZ, "anchor", "") end)
        task.wait(0.4)
    end

    
    local _qseKcsMW = {
        Front  = Enum.NormalId.Front,
        Back   = Enum.NormalId.Back,
        Top    = Enum.NormalId.Top,
        Bottom = Enum.NormalId.Bottom,
        Right  = Enum.NormalId.Right,
        Left   = Enum.NormalId.Left
    }
    for _, _FHiYXeXM in ipairs(_wCYRKXCE) do
        local _xrhwCvZZ = _kTbaCWkh[_FHiYXeXM]
        pcall(function()
            _bfiLzzvN:FireServer(_zWGJfAuo, _qseKcsMW[_FHiYXeXM], _GKlyfDdV, _iGgEDzLH, _xrhwCvZZ._LKlMAfJV.BackgroundColor3, "spray", _xrhwCvZZ.txtBox.Text)
        end)
        task.wait(0.2)
    end

    print("[WIND GUI] Sequence Complete!")
end

local function fireDeleteTool(v)
    local _XcKBLpID = LocalPlayer.Character
    if not _XcKBLpID then return end
    
    local _akpiUClC = _XcKBLpID:FindFirstChild("Delete") or LocalPlayer.Backpack:FindFirstChild("Delete")
    if not _akpiUClC then return end
    if _akpiUClC.Parent ~= _XcKBLpID then
        _akpiUClC.Parent = _XcKBLpID
        task.wait(0.05)
    end
    _akpiUClC = _XcKBLpID:FindFirstChild("Delete")
    if not _akpiUClC then return end
    
    local _lDUHdIwp = _akpiUClC:FindFirstChild("_lDUHdIwp")
    if _lDUHdIwp then
        pcall(function() _lDUHdIwp:Invoke(v, v.Position) end)
        return
    end
    local _RVpEodvX = _akpiUClC:FindFirstChild("Script")
    if _RVpEodvX then
        local _UEsLHuKK = _RVpEodvX:FindFirstChild("Event")
        if _UEsLHuKK then
            pcall(function() _UEsLHuKK:FireServer(v, v.Position) end)
            return
        end
    end
    
    local _UEsLHuKK = _akpiUClC:FindFirstChildWhichIsA("RemoteEvent", true)
    if _UEsLHuKK then
        pcall(function() _UEsLHuKK:FireServer(v, v.Position) end)
    end
end

coroutine.wrap(function()
    while _uDYntway do
        task.wait()
        pcall(function()
            
            if _ULpOEffV and LocalPlayer.Character then
                _ZUvfVyuY.Position = LocalPlayer.Character:GetPivot().Position
                local _fIchspWf = workspace:GetPartsInPart(_ZUvfVyuY, _mXwrIMHm)
                for _, v in pairs(_fIchspWf) do
                    coroutine.wrap(function() fireDeleteTool(v) end)()
                end
            end
            
            if _IgFLnRKt and LocalPlayer.Character then
                
                local _dzeIlBKg = workspace:FindFirstChild("Bricks")
                if _dzeIlBKg then
                    _ZUvfVyuY.Position = LocalPlayer.Character:GetPivot().Position
                    local _fIchspWf = {}
                    for _, v in pairs(_dzeIlBKg:GetDescendants()) do
                        if v:IsA("BasePart") and (v.Position - _ZUvfVyuY.Position).Magnitude < _WvUSSajZ then
                            table.insert(_fIchspWf, v)
                        end
                    end
                    for _, v in pairs(_fIchspWf) do
                        coroutine.wrap(function() fireDeleteTool(v) end)()
                    end
                end
            end
        end)
    end
end)()

_qCdTDhTR.MouseButton1Click:Connect(function()
    local _XcKBLpID = LocalPlayer.Character
    if not _XcKBLpID or not _XcKBLpID:FindFirstChild("HumanoidRootPart") then return end

    
    local _akpiUClC = _XcKBLpID:FindFirstChild("Delete") or LocalPlayer.Backpack:FindFirstChild("Delete")
    if not _akpiUClC then warn("[WIND GUI] Nuke Failed: No Delete _vLWSYihP found!") return end
    if _akpiUClC.Parent ~= _XcKBLpID then
        local _CXwjrKxf = _XcKBLpID:FindFirstChildOfClass("Humanoid")
        if _CXwjrKxf then _CXwjrKxf:EquipTool(_akpiUClC) end
        task.wait(0.45)
        _akpiUClC = _XcKBLpID:FindFirstChild("Delete")
        if not _akpiUClC then warn("[WIND GUI] Nuke Failed: Delete _vLWSYihP lost after equip!") return end
    end

    
    local _jgPrepaO = _akpiUClC:FindFirstChildWhichIsA("RemoteEvent", true)
    if not _jgPrepaO then
        
        local _RVpEodvX = _akpiUClC:FindFirstChild("Script")
        if _RVpEodvX then _jgPrepaO = _RVpEodvX:FindFirstChild("Event") end
    end
    if not _jgPrepaO then
        warn("[WIND GUI] Nuke Failed: RemoteEvent not found in Delete _vLWSYihP!")
        return
    end

    local _GKlyfDdV = _XcKBLpID.HumanoidRootPart.Position
    local _Miqtrxcc = {
        Vector3.new(0, 10000, 0),
        Vector3.new(0, -10000, 0),
        Vector3.new(15000, 0, 0),
        Vector3.new(-15000, 0, 0)
    }
    task.spawn(function()
        local _fFCLeWKh = 0
        while _fFCLeWKh < 300 do
            _fFCLeWKh = _fFCLeWKh + 1
            for _, dir in ipairs(_Miqtrxcc) do
                pcall(function() _jgPrepaO:FireServer(nil, _GKlyfDdV + dir) end)
            end
            pcall(function() _jgPrepaO:FireServer(nil, _GKlyfDdV) end)
            task.wait(0.04)
        end
    end)
end)

_jxROvTFh.MouseButton1Click:Connect(function()
    local _XcKBLpID = LocalPlayer.Character
    if not _XcKBLpID then return end

    local _akpiUClC = _XcKBLpID:FindFirstChild("Delete") or LocalPlayer.Backpack:FindFirstChild("Delete")
    if not _akpiUClC then warn("[WIND GUI] Destroyer Failed: No Delete _vLWSYihP found!") return end
    if _akpiUClC.Parent ~= _XcKBLpID then
        local _CXwjrKxf = _XcKBLpID:FindFirstChildOfClass("Humanoid")
        if _CXwjrKxf then
            _CXwjrKxf:EquipTool(_akpiUClC)
            task.wait(0.2)
        end
        _akpiUClC = _XcKBLpID:FindFirstChild("Delete")
        if not _akpiUClC then return end
    end

    pcall(function()
        local _ERkgKNdM = _akpiUClC:FindFirstChild("Script") and _akpiUClC.Script:FindFirstChild("Event")
        local _zWGJfAuo = ReplicatedStorage:FindFirstChild("Brick")
        if _ERkgKNdM and _zWGJfAuo and _XcKBLpID:FindFirstChild("HumanoidRootPart") then
            _ERkgKNdM:FireServer(_zWGJfAuo, _XcKBLpID.HumanoidRootPart.Position)
        end
    end)
end)

_RgHTIPlc.MouseButton1Click:Connect(function()
    print("[WIND GUI] Fix: Unanchor + Plastic + Clear...")
    
    useToxic = false
    autoAnchor = false
    _AcGQrshs.Text = "Material: PLASTIC"
    _aRnXwpVh.Text = "Auto-Anchor: OFF"
    
    for _, _FHiYXeXM in ipairs(_wCYRKXCE) do
        _kTbaCWkh[_FHiYXeXM].txtBox.Text = ""
        _kTbaCWkh[_FHiYXeXM]._LKlMAfJV.BackgroundColor3 = Color3.new(0, 0, 0)
    end
    
    
    local _XcKBLpID = LocalPlayer.Character
    if _XcKBLpID then
        local _MmhRUhed = _XcKBLpID:FindFirstChild("HumanoidRootPart")
        local _vLWSYihP = _XcKBLpID:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
        local _zWGJfAuo = ReplicatedStorage:FindFirstChild("Brick")
        if _MmhRUhed and _vLWSYihP and _zWGJfAuo then
            if _vLWSYihP.Parent ~= _XcKBLpID then
                local _CXwjrKxf = _XcKBLpID:FindFirstChildOfClass("Humanoid")
                if _CXwjrKxf then _CXwjrKxf:EquipTool(_vLWSYihP) task.wait(0.35) end
                _vLWSYihP = _XcKBLpID:FindFirstChild("Paint") or LocalPlayer.Backpack:FindFirstChild("Paint")
            end
            if _vLWSYihP then
                local _bfiLzzvN = _vLWSYihP:FindFirstChild("Event", true) or _vLWSYihP:FindFirstChildWhichIsA("RemoteEvent", true)
                if _bfiLzzvN then
                    local _GKlyfDdV = _MmhRUhed.Position
                    local _iGgEDzLH = "both \u{1F91D}"
                    
                    pcall(function() _bfiLzzvN:FireServer(_zWGJfAuo, Enum.NormalId.Top, _GKlyfDdV, _iGgEDzLH, Color3.new(0,0,0), "plastic", "unanchor") end)
                    task.wait(0.35)
                    
                    pcall(function() _bfiLzzvN:FireServer(_zWGJfAuo, Enum.NormalId.Top, _GKlyfDdV, _iGgEDzLH, Color3.new(0,0,0), "unanchor", "") end)
                    task.wait(0.35)
                    print("[WIND GUI] Fix complete: block is plastic, unanchored, black.")
                end
            end
        end
    end
end)

_DsFIqTey.MouseButton1Click:Connect(function()
    useToxic = true
    _AcGQrshs.Text = "Material: TOXIC"
    local b = "<font size= '0'>dx</font>"
    local _KKthJnJY = {
        Front  = "GG'S",
        Back   = "GG'S",
        Top    = "hacked by MANE",
        Bottom = "GGS",
        Right  = "MANE SCRIPT",
        Left   = "CRY GG'S"
    }
    for _, _FHiYXeXM in ipairs(_wCYRKXCE) do
        _kTbaCWkh[_FHiYXeXM].txtBox.Text = _KKthJnJY[_FHiYXeXM]
        _kTbaCWkh[_FHiYXeXM]._LKlMAfJV.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

_AcGQrshs.MouseButton1Click:Connect(function()
    useToxic = not useToxic
    _AcGQrshs.Text = "Material: " .. (useToxic and "TOXIC" or "PLASTIC")
end)

_aRnXwpVh.MouseButton1Click:Connect(function()
    autoAnchor = not autoAnchor
    _aRnXwpVh.Text = "Auto-Anchor: " .. (autoAnchor and "ON" or "OFF")
end)

_OYnuQmAv.MouseButton1Click:Connect(function()
    _VbXeLyoe = not _VbXeLyoe
    _OYnuQmAv.Text = "Spam Mode: " .. (_VbXeLyoe and "ON" or "OFF")
end)

_XqjwCbgO.MouseButton1Click:Connect(function()
    print("[WIND GUI] Execute Sequence button clicked.")
    runFix()
end)

local _ViZqPAVZ, dragStart, startPos
_pFqaLRWL.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        _ViZqPAVZ = true
        dragStart = i.Position
        startPos = _vxOnNTEO.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if _ViZqPAVZ and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        _vxOnNTEO.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        _ViZqPAVZ = false
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if _VbXeLyoe then runFix() end
    end
end)
