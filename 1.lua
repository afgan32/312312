local LiquidGlass = {}
LiquidGlass.__index = LiquidGlass

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

local function MakeTween(duration, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    return TweenInfo.new(duration or 0.35, style, dir)
end

local TWEEN = {
    OPEN  = MakeTween(0.55, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
    CLOSE = MakeTween(0.40, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
    HOVER = MakeTween(0.30, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    FAST  = MakeTween(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    GLOW  = MakeTween(0.45, Enum.EasingStyle.Sine,  Enum.EasingDirection.InOut),
    MORPH = MakeTween(0.45, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
    KNOB  = MakeTween(0.35, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
    SLIDE = MakeTween(0.50, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
    LINEAR = MakeTween(1.0, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
}

local GLASS = {
    RimLight     = Color3.fromRGB(255, 255, 255),
    GlowInner    = Color3.fromRGB(200, 225, 255),
    GlowAccent   = Color3.fromRGB(140, 200, 255),
    FrostTint    = Color3.fromRGB(180, 205, 240),
    TextBright   = Color3.fromRGB(255, 255, 255),
    TextDim      = Color3.fromRGB(200, 215, 235),
    TextGhost    = Color3.fromRGB(150, 170, 200),
    AccentBlue   = Color3.fromRGB(100, 185, 255),
    AccentPurple = Color3.fromRGB(175, 130, 255),
    AccentGreen  = Color3.fromRGB(100, 235, 165),
    AccentRed    = Color3.fromRGB(255, 95,  105),
    AccentOrange = Color3.fromRGB(255, 185, 70),
    GlassDark    = Color3.fromRGB(8,   10,  18),
    GlassMid     = Color3.fromRGB(15,  18,  30),
}

local Util = {}

function Util.Tween(inst, props, tweenInfo)
    local t = TweenService:Create(inst, tweenInfo or TWEEN.HOVER, props)
    t:Play()
    return t
end

function Util.Rim(parent, color, thickness, alpha)
    local old = parent:FindFirstChildOfClass("UIStroke")
    if old then old:Destroy() end
    local s = Instance.new("UIStroke")
    s.Color           = color     or GLASS.RimLight
    s.Thickness       = thickness or 1.0
    s.Transparency    = alpha     or 0.22
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.LineJoinMode    = Enum.LineJoinMode.Round
    s.Parent          = parent
    return s
end

function Util.Round(parent, radius)
    local old = parent:FindFirstChildOfClass("UICorner")
    if old then old:Destroy() end
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 20)
    c.Parent       = parent
    return c
end

function Util.Gradient(parent, colors, transparencies, rotation)
    local old = parent:FindFirstChildOfClass("UIGradient")
    if old then old:Destroy() end
    local g = Instance.new("UIGradient")
    g.Color        = ColorSequence.new(colors)
    g.Transparency = NumberSequence.new(transparencies)
    g.Rotation     = rotation or 135
    g.Parent       = parent
    return g
end

function Util.InnerGlow(parent, color, zindex)
    local glow = Instance.new("ImageLabel")
    glow.Name                   = "InnerGlow"
    glow.Size                   = UDim2.new(1, 24, 1, 24)
    glow.Position               = UDim2.new(0, -12, 0, -12)
    glow.BackgroundTransparency = 1
    glow.Image                  = "rbxassetid://5028857084"
    glow.ImageColor3            = color or GLASS.GlowInner
    glow.ImageTransparency      = 0.85
    glow.ScaleType              = Enum.ScaleType.Slice
    glow.SliceCenter            = Rect.new(24, 24, 276, 276)
    glow.ZIndex                 = (zindex or 10) - 1
    glow.Parent                 = parent
    return glow
end

function Util.TopShine(parent, zindex)
    local s = Instance.new("Frame")
    s.Name                   = "TopShine"
    s.Size                   = UDim2.new(0.7, 0, 0, 1)
    s.Position               = UDim2.new(0.15, 0, 0, 2)
    s.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    s.BackgroundTransparency = 0.30
    s.BorderSizePixel        = 0
    s.ZIndex                 = zindex or 20
    s.Parent                 = parent
    Util.Round(s, UDim.new(1, 0))
    return s
end

function Util.BottomReflect(parent, zindex)
    local r = Instance.new("Frame")
    r.Name                   = "BottomRef"
    r.Size                   = UDim2.new(0.5, 0, 0, 1)
    r.Position               = UDim2.new(0.25, 0, 1, -2)
    r.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    r.BackgroundTransparency = 0.65
    r.BorderSizePixel        = 0
    r.ZIndex                 = zindex or 20
    r.Parent                 = parent
    Util.Round(r, UDim.new(1, 0))
    return r
end

function Util.LensDist(parent, zindex)
    local l = Instance.new("ImageLabel")
    l.Name                   = "LensDist"
    l.Size                   = UDim2.new(1, 8, 1, 8)
    l.Position               = UDim2.new(0, -4, 0, -4)
    l.BackgroundTransparency = 1
    l.Image                  = "rbxassetid://6014261993"
    l.ImageColor3            = GLASS.GlowInner
    l.ImageTransparency      = 0.90
    l.ScaleType              = Enum.ScaleType.Slice
    l.SliceCenter            = Rect.new(49, 49, 450, 450)
    l.ZIndex                 = (zindex or 10) - 1
    l.Parent                 = parent
    return l
end

function Util.GlassCard(parent, h, zindex)
    local card = Instance.new("Frame")
    card.Size                   = UDim2.new(1, 0, 0, h or 58)
    card.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    card.BackgroundTransparency = 0.88
    card.BorderSizePixel        = 0
    card.ZIndex                 = zindex or 13
    card.ClipsDescendants       = false
    card.Parent                 = parent
    Util.Round(card, UDim.new(0, 16))
    Util.Rim(card, GLASS.RimLight, 1, 0.28)
    Util.TopShine(card, (zindex or 13) + 2)
    Util.BottomReflect(card, (zindex or 13) + 2)
    Util.LensDist(card, zindex or 13)

    Util.Gradient(card, {
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, GLASS.FrostTint),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(160, 185, 225)),
    }, {
        NumberSequenceKeypoint.new(0,   0.82),
        NumberSequenceKeypoint.new(0.5, 0.88),
        NumberSequenceKeypoint.new(1,   0.92),
    }, 140)

    local cardGlow = Util.InnerGlow(card, GLASS.GlowInner, zindex or 13)
    cardGlow.ImageTransparency = 0.90

    card.MouseEnter:Connect(function()
        Util.Tween(card,     {BackgroundTransparency = 0.78}, TWEEN.FAST)
        Util.Tween(cardGlow, {ImageTransparency = 0.72},      TWEEN.GLOW)
    end)
    card.MouseLeave:Connect(function()
        Util.Tween(card,     {BackgroundTransparency = 0.88}, TWEEN.FAST)
        Util.Tween(cardGlow, {ImageTransparency = 0.90},      TWEEN.GLOW)
    end)

    return card, cardGlow
end

local DepthOfField
local BloomEffect
local ColorCorrect

local function SetupLighting()
    DepthOfField = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")
    if not DepthOfField then
        DepthOfField        = Instance.new("DepthOfFieldEffect")
        DepthOfField.Parent = Lighting
    end
    DepthOfField.FarIntensity  = 0
    DepthOfField.NearIntensity = 0
    DepthOfField.FocusDistance = 50
    DepthOfField.InFocusRadius = 50
    DepthOfField.Enabled       = false

    BloomEffect = Lighting:FindFirstChildOfClass("BloomEffect")
    if not BloomEffect then
        BloomEffect        = Instance.new("BloomEffect")
        BloomEffect.Parent = Lighting
    end
    BloomEffect.Intensity = 0
    BloomEffect.Size      = 24
    BloomEffect.Threshold = 0.95
    BloomEffect.Enabled   = false

    ColorCorrect = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    if not ColorCorrect then
        ColorCorrect        = Instance.new("ColorCorrectionEffect")
        ColorCorrect.Parent = Lighting
    end
    ColorCorrect.Enabled = false
end

local function EnableBlur(on)
    if on then
        DepthOfField.FarIntensity  = 0
        DepthOfField.NearIntensity = 0
        DepthOfField.FocusDistance = 10
        DepthOfField.InFocusRadius = 8
        DepthOfField.Enabled       = true
        BloomEffect.Intensity      = 0
        BloomEffect.Enabled        = true
        ColorCorrect.Saturation    = -0.08
        ColorCorrect.Contrast      = 0.04
        ColorCorrect.Enabled       = true
        Util.Tween(DepthOfField, {FarIntensity = 1}, MakeTween(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
        Util.Tween(BloomEffect,  {Intensity = 0.55}, MakeTween(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
    else
        Util.Tween(DepthOfField, {FarIntensity = 0, NearIntensity = 0}, TWEEN.CLOSE)
        Util.Tween(BloomEffect,  {Intensity = 0},                        TWEEN.CLOSE)
        task.delay(0.5, function()
            DepthOfField.Enabled = false
            BloomEffect.Enabled  = false
            ColorCorrect.Enabled = false
        end)
    end
end

local function GetEnvTint()
    local h = Lighting.ClockTime
    if h >= 6 and h <= 18 then
        return Color3.fromRGB(200, 215, 240), 0.80
    else
        return Color3.fromRGB(10, 15, 35), 0.65
    end
end

local NotifHolder

local function EnsureNotifHolder()
    if NotifHolder and NotifHolder.Parent then return NotifHolder end

    local ok, g = pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name           = "LG_Notifs"
        sg.ResetOnSpawn   = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.IgnoreGuiInset = true
        sg.Parent         = CoreGui
        return sg
    end)
    if not ok then
        g = Instance.new("ScreenGui")
        g.Name           = "LG_Notifs"
        g.ResetOnSpawn   = false
        g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        g.IgnoreGuiInset = true
        g.Parent         = LocalPlayer:WaitForChild("PlayerGui")
    end

    local holder = Instance.new("Frame")
    holder.Name                   = "Holder"
    holder.Size                   = UDim2.new(0, 340, 1, 0)
    holder.Position               = UDim2.new(1, -358, 0, 0)
    holder.BackgroundTransparency = 1
    holder.ZIndex                 = 9999
    holder.Parent                 = g

    local lay = Instance.new("UIListLayout")
    lay.SortOrder           = Enum.SortOrder.LayoutOrder
    lay.VerticalAlignment   = Enum.VerticalAlignment.Bottom
    lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
    lay.Padding             = UDim.new(0, 10)
    lay.Parent              = holder

    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0, 24)
    pad.Parent        = holder

    NotifHolder = holder
    return NotifHolder
end

function LiquidGlass.new(title, subtitle)
    local self       = setmetatable({}, LiquidGlass)
    self.Connections = {}
    self.Tabs        = {}
    self.ActiveTab   = nil
    self.Visible     = true

    SetupLighting()

    local ok, screenGui = pcall(function()
        local g = Instance.new("ScreenGui")
        g.Name            = "LiquidGlass_" .. tostring(math.random(1000, 9999))
        g.ResetOnSpawn    = false
        g.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
        g.IgnoreGuiInset  = true
        g.Parent          = CoreGui
        return g
    end)
    if not ok then
        screenGui             = Instance.new("ScreenGui")
        screenGui.Name        = "LiquidGlass"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.IgnoreGuiInset = true
        screenGui.Parent      = LocalPlayer:WaitForChild("PlayerGui")
    end
    self.ScreenGui = screenGui

    local backdrop = Instance.new("Frame")
    backdrop.Name                   = "Backdrop"
    backdrop.Size                   = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3       = GLASS.GlassDark
    backdrop.BackgroundTransparency = 0.38
    backdrop.ZIndex                 = 1
    backdrop.BorderSizePixel        = 0
    backdrop.Parent                 = screenGui
    Util.Gradient(backdrop, {
        ColorSequenceKeypoint.new(0,   GLASS.GlassDark),
        ColorSequenceKeypoint.new(0.5, GLASS.GlassMid),
        ColorSequenceKeypoint.new(1,   GLASS.GlassDark),
    }, {
        NumberSequenceKeypoint.new(0,   0.20),
        NumberSequenceKeypoint.new(0.5, 0.45),
        NumberSequenceKeypoint.new(1,   0.20),
    }, 45)

    local envTint, envAlpha = GetEnvTint()

    local window = Instance.new("Frame")
    window.Name                   = "MainWindow"
    window.Size                   = UDim2.new(0, 720, 0, 500)
    window.Position               = UDim2.new(0.5, -360, 0.5, -250)
    window.BackgroundColor3       = envTint
    window.BackgroundTransparency = envAlpha
    window.BorderSizePixel        = 0
    window.ZIndex                 = 10
    window.ClipsDescendants       = false
    window.Parent                 = screenGui
    Util.Round(window, UDim.new(0, 26))
    Util.Rim(window, GLASS.RimLight, 1.2, 0.18)
    Util.InnerGlow(window, GLASS.GlowInner, 10)
    Util.LensDist(window, 10)
    Util.TopShine(window, 15)
    Util.BottomReflect(window, 15)

    Util.Gradient(window, {
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.3, GLASS.FrostTint),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(160, 185, 230)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(120, 150, 210)),
    }, {
        NumberSequenceKeypoint.new(0,   0.72),
        NumberSequenceKeypoint.new(0.3, 0.80),
        NumberSequenceKeypoint.new(0.7, 0.85),
        NumberSequenceKeypoint.new(1,   0.90),
    }, 140)

    local glintOrb = Instance.new("ImageLabel")
    glintOrb.Name                   = "GlintOrb"
    glintOrb.Size                   = UDim2.new(0, 180, 0, 90)
    glintOrb.AnchorPoint            = Vector2.new(0.5, 0.5)
    glintOrb.Position               = UDim2.new(0.35, 0, 0.25, 0)
    glintOrb.BackgroundTransparency = 1
    glintOrb.Image                  = "rbxassetid://5028857084"
    glintOrb.ImageColor3            = Color3.fromRGB(255, 255, 255)
    glintOrb.ImageTransparency      = 0.72
    glintOrb.ScaleType              = Enum.ScaleType.Slice
    glintOrb.SliceCenter            = Rect.new(24, 24, 276, 276)
    glintOrb.ZIndex                 = 16
    glintOrb.Parent                 = window

    local glintConn = RunService.RenderStepped:Connect(function()
        if not window or not window.Parent then return end
        local mp   = UserInputService:GetMouseLocation()
        local ap   = window.AbsolutePosition
        local as   = window.AbsoluteSize
        local rx   = math.clamp((mp.X - ap.X) / as.X, 0, 1)
        local ry   = math.clamp((mp.Y - ap.Y) / as.Y, 0, 1)
        local tx   = 0.1 + rx * 0.8
        local ty   = 0.05 + ry * 0.55
        local cp   = glintOrb.Position
        local dist = math.sqrt((rx - 0.5)^2 + (ry - 0.5)^2)
        glintOrb.Position = UDim2.new(
            cp.X.Scale + (tx - cp.X.Scale) * 0.06, 0,
            cp.Y.Scale + (ty - cp.Y.Scale) * 0.06, 0
        )
        glintOrb.ImageTransparency = 0.58 + dist * 0.35
    end)
    table.insert(self.Connections, glintConn)

    local envConn = RunService.Heartbeat:Connect(function()
        local t, a = GetEnvTint()
        window.BackgroundColor3       = t
        window.BackgroundTransparency = a
    end)
    table.insert(self.Connections, envConn)

    local titleBar = Instance.new("Frame")
    titleBar.Name                   = "TitleBar"
    titleBar.Size                   = UDim2.new(1, 0, 0, 62)
    titleBar.BackgroundTransparency = 1
    titleBar.ZIndex                 = 12
    titleBar.BorderSizePixel        = 0
    titleBar.Parent                 = window

    local titleGlowFrame = Instance.new("Frame")
    titleGlowFrame.Size                   = UDim2.new(1, 0, 0, 62)
    titleGlowFrame.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    titleGlowFrame.BackgroundTransparency = 0.93
    titleGlowFrame.BorderSizePixel        = 0
    titleGlowFrame.ZIndex                 = 11
    titleGlowFrame.Parent                 = window
    Util.Gradient(titleGlowFrame, {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 220, 255)),
    }, {
        NumberSequenceKeypoint.new(0, 0.88),
        NumberSequenceKeypoint.new(1, 1.0),
    }, 90)

    local divider = Instance.new("Frame")
    divider.Size                   = UDim2.new(0.9, 0, 0, 1)
    divider.Position               = UDim2.new(0.05, 0, 0, 61)
    divider.BackgroundColor3       = GLASS.RimLight
    divider.BackgroundTransparency = 0.55
    divider.ZIndex                 = 13
    divider.BorderSizePixel        = 0
    divider.Parent                 = window
    Util.Gradient(divider, {
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, GLASS.GlowAccent),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 255, 255)),
    }, {
        NumberSequenceKeypoint.new(0,   1),
        NumberSequenceKeypoint.new(0.5, 0.4),
        NumberSequenceKeypoint.new(1,   1),
    }, 0)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size                   = UDim2.new(1, -160, 1, 0)
    titleLabel.Position               = UDim2.new(0, 22, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text                   = title or "Liquid Glass"
    titleLabel.TextColor3             = GLASS.TextBright
    titleLabel.TextSize               = 18
    titleLabel.Font                   = Enum.Font.GothamBold
    titleLabel.TextXAlignment         = Enum.TextXAlignment.Left
    titleLabel.ZIndex                 = 14
    titleLabel.Parent                 = titleBar

    local titleGrad = Instance.new("UIGradient")
    titleGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, GLASS.GlowAccent),
    })
    titleGrad.Rotation = 0
    titleGrad.Parent   = titleLabel

    local subLabel = Instance.new("TextLabel")
    subLabel.Size                   = UDim2.new(1, -160, 0, 16)
    subLabel.Position               = UDim2.new(0, 22, 0, 38)
    subLabel.BackgroundTransparency = 1
    subLabel.Text                   = subtitle or "Liquid Glass UI"
    subLabel.TextColor3             = GLASS.TextGhost
    subLabel.TextSize               = 11
    subLabel.Font                   = Enum.Font.Gotham
    subLabel.TextXAlignment         = Enum.TextXAlignment.Left
    subLabel.ZIndex                 = 14
    subLabel.Parent                 = titleBar

    local function MakePillBtn(parent, xOff, color, sym)
        local btn = Instance.new("TextButton")
        btn.Size                   = UDim2.new(0, 30, 0, 30)
        btn.Position               = UDim2.new(1, xOff, 0.5, -15)
        btn.BackgroundColor3       = color
        btn.BackgroundTransparency = 0.25
        btn.Text                   = ""
        btn.ZIndex                 = 14
        btn.BorderSizePixel        = 0
        btn.Parent                 = parent
        Util.Round(btn, UDim.new(1, 0))
        Util.Rim(btn, GLASS.RimLight, 1, 0.35)
        Util.InnerGlow(btn, color, 14)

        local lbl = Instance.new("TextLabel")
        lbl.Size                   = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text                   = sym
        lbl.TextColor3             = Color3.fromRGB(255, 255, 255)
        lbl.TextSize               = 13
        lbl.Font                   = Enum.Font.GothamBold
        lbl.ZIndex                 = 15
        lbl.Parent                 = btn

        btn.MouseEnter:Connect(function()
            Util.Tween(btn, {BackgroundTransparency = 0.0, Size = UDim2.new(0, 33, 0, 33)}, TWEEN.HOVER)
        end)
        btn.MouseLeave:Connect(function()
            Util.Tween(btn, {BackgroundTransparency = 0.25, Size = UDim2.new(0, 30, 0, 30)}, TWEEN.HOVER)
        end)
        return btn
    end

    local closeBtn = MakePillBtn(titleBar, -42,  GLASS.AccentRed,    "x")
    local minBtn   = MakePillBtn(titleBar, -82,  GLASS.AccentOrange, "-")

    self.Window = window

    closeBtn.MouseButton1Click:Connect(function()
        self:Toggle(false)
    end)

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Util.Tween(window, {Size = UDim2.new(0, 720, 0, 62)}, TWEEN.MORPH)
        else
            Util.Tween(window, {Size = UDim2.new(0, 720, 0, 500)}, TWEEN.MORPH)
        end
    end)

    do
        local dragging, dragStart, startPos = false, nil, nil
        titleBar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging  = true
                dragStart = inp.Position
                startPos  = window.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local d = inp.Position - dragStart
                window.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    local sidebar = Instance.new("Frame")
    sidebar.Name                   = "Sidebar"
    sidebar.Size                   = UDim2.new(0, 168, 1, -72)
    sidebar.Position               = UDim2.new(0, 8, 0, 66)
    sidebar.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    sidebar.BackgroundTransparency = 0.93
    sidebar.BorderSizePixel        = 0
    sidebar.ZIndex                 = 12
    sidebar.ClipsDescendants       = true
    sidebar.Parent                 = window
    Util.Round(sidebar, UDim.new(0, 18))
    Util.Rim(sidebar, GLASS.RimLight, 1, 0.30)
    Util.TopShine(sidebar, 14)

    local sideLayout = Instance.new("UIListLayout")
    sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sideLayout.Padding   = UDim.new(0, 5)
    sideLayout.Parent    = sidebar

    local sidePad = Instance.new("UIPadding")
    sidePad.PaddingTop   = UDim.new(0, 10)
    sidePad.PaddingLeft  = UDim.new(0, 8)
    sidePad.PaddingRight = UDim.new(0, 8)
    sidePad.Parent       = sidebar

    local contentHost = Instance.new("ScrollingFrame")
    contentHost.Name                       = "ContentHost"
    contentHost.Size                       = UDim2.new(1, -188, 1, -72)
    contentHost.Position                   = UDim2.new(0, 182, 0, 66)
    contentHost.BackgroundTransparency     = 1
    contentHost.ZIndex                     = 12
    contentHost.BorderSizePixel            = 0
    contentHost.ScrollBarThickness         = 3
    contentHost.ScrollBarImageColor3       = GLASS.GlowAccent
    contentHost.ScrollBarImageTransparency = 0.4
    contentHost.CanvasSize                 = UDim2.new(0, 0, 0, 0)
    contentHost.AutomaticCanvasSize        = Enum.AutomaticSize.Y
    contentHost.Parent                     = window

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding   = UDim.new(0, 8)
    contentLayout.Parent    = contentHost

    local contentPad = Instance.new("UIPadding")
    contentPad.PaddingTop    = UDim.new(0, 6)
    contentPad.PaddingBottom = UDim.new(0, 18)
    contentPad.PaddingLeft   = UDim.new(0, 6)
    contentPad.PaddingRight  = UDim.new(0, 12)
    contentPad.Parent        = contentHost

    self.Sidebar     = sidebar
    self.ContentHost = contentHost
    self.NotifGui    = EnsureNotifHolder()

    window.Size     = UDim2.new(0, 0, 0, 0)
    window.Position = UDim2.new(0.5, 0, 0.5, 0)
    EnableBlur(true)

    task.delay(0.05, function()
        Util.Tween(window, {
            Size     = UDim2.new(0, 720, 0, 500),
            Position = UDim2.new(0.5, -360, 0.5, -250),
        }, TWEEN.OPEN)
    end)

    return self
end

function LiquidGlass:Toggle(state)
    self.Visible = (state ~= nil) and state or (not self.Visible)
    if self.Visible then
        self.Window.Visible = true
        EnableBlur(true)
        Util.Tween(self.Window, {
            Size     = UDim2.new(0, 720, 0, 500),
            Position = UDim2.new(0.5, -360, 0.5, -250),
        }, TWEEN.OPEN)
    else
        EnableBlur(false)
        local t = Util.Tween(self.Window, {
            Size     = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
        }, TWEEN.CLOSE)
        t.Completed:Connect(function()
            self.Window.Visible = false
        end)
    end
end

function LiquidGlass:SetKeybind(key)
    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.KeyCode == key then self:Toggle() end
    end))
end

function LiquidGlass:AddTab(name, icon)
    local idx = #self.Tabs + 1

    local tabBtn = Instance.new("TextButton")
    tabBtn.Name                   = "Tab_" .. name
    tabBtn.Size                   = UDim2.new(1, 0, 0, 46)
    tabBtn.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    tabBtn.BackgroundTransparency = 0.92
    tabBtn.Text                   = ""
    tabBtn.ZIndex                 = 13
    tabBtn.BorderSizePixel        = 0
    tabBtn.LayoutOrder            = idx
    tabBtn.Parent                 = self.Sidebar
    Util.Round(tabBtn, UDim.new(0, 14))
    Util.Rim(tabBtn, GLASS.RimLight, 1, 0.50)

    local tabGlow = Util.InnerGlow(tabBtn, GLASS.GlowAccent, 13)
    tabGlow.ImageTransparency = 1.0

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size                   = UDim2.new(0, 28, 0, 28)
    iconLbl.Position               = UDim2.new(0, 8, 0.5, -14)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text                   = icon or "o"
    iconLbl.TextColor3             = GLASS.TextDim
    iconLbl.TextSize               = 15
    iconLbl.Font                   = Enum.Font.GothamBold
    iconLbl.ZIndex                 = 14
    iconLbl.Parent                 = tabBtn

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size                   = UDim2.new(1, -44, 1, 0)
    nameLbl.Position               = UDim2.new(0, 40, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text                   = name
    nameLbl.TextColor3             = GLASS.TextDim
    nameLbl.TextSize               = 13
    nameLbl.Font                   = Enum.Font.Gotham
    nameLbl.TextXAlignment         = Enum.TextXAlignment.Left
    nameLbl.ZIndex                 = 14
    nameLbl.Parent                 = tabBtn

    local indicator = Instance.new("Frame")
    indicator.Size                   = UDim2.new(0, 3, 0.55, 0)
    indicator.Position               = UDim2.new(0, 1, 0.225, 0)
    indicator.BackgroundColor3       = GLASS.AccentBlue
    indicator.BackgroundTransparency = 1
    indicator.ZIndex                 = 15
    indicator.BorderSizePixel        = 0
    indicator.Parent                 = tabBtn
    Util.Round(indicator, UDim.new(1, 0))

    local contentFrame = Instance.new("Frame")
    contentFrame.Name                   = "Content_" .. name
    contentFrame.Size                   = UDim2.new(1, 0, 0, 0)
    contentFrame.AutomaticSize          = Enum.AutomaticSize.Y
    contentFrame.BackgroundTransparency = 1
    contentFrame.Visible                = false
    contentFrame.ZIndex                 = 12
    contentFrame.BorderSizePixel        = 0
    contentFrame.LayoutOrder            = idx
    contentFrame.Parent                 = self.ContentHost

    local itemLayout = Instance.new("UIListLayout")
    itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
    itemLayout.Padding   = UDim.new(0, 7)
    itemLayout.Parent    = contentFrame

    local tabData = {
        Name      = name,
        Button    = tabBtn,
        Content   = contentFrame,
        Indicator = indicator,
        Icon      = iconLbl,
        Label     = nameLbl,
        Glow      = tabGlow,
        Index     = idx,
    }
    table.insert(self.Tabs, tabData)

    local selfRef = self

    local function ActivateTab()
        for _, t in ipairs(selfRef.Tabs) do
            t.Content.Visible = false
            Util.Tween(t.Button,    {BackgroundTransparency = 0.92},             TWEEN.FAST)
            Util.Tween(t.Indicator, {BackgroundTransparency = 1.0},              TWEEN.FAST)
            Util.Tween(t.Label,     {TextColor3 = GLASS.TextDim},                TWEEN.FAST)
            Util.Tween(t.Icon,      {TextColor3 = GLASS.TextDim},                TWEEN.FAST)
            Util.Tween(t.Glow,      {ImageTransparency = 1.0},                   TWEEN.FAST)
            Util.Rim(t.Button, GLASS.RimLight, 1, 0.50)
        end
        contentFrame.Visible = true
        selfRef.ActiveTab    = tabData
        Util.Tween(tabBtn,    {BackgroundTransparency = 0.70},      TWEEN.HOVER)
        Util.Tween(indicator, {BackgroundTransparency = 0.0},       TWEEN.MORPH)
        Util.Tween(nameLbl,   {TextColor3 = GLASS.AccentBlue},      TWEEN.HOVER)
        Util.Tween(iconLbl,   {TextColor3 = GLASS.AccentBlue},      TWEEN.HOVER)
        Util.Tween(tabGlow,   {ImageTransparency = 0.65},           TWEEN.GLOW)
        Util.Rim(tabBtn, GLASS.AccentBlue, 1.0, 0.35)
    end

    tabBtn.MouseEnter:Connect(function()
        if selfRef.ActiveTab ~= tabData then
            Util.Tween(tabBtn,  {BackgroundTransparency = 0.83}, TWEEN.FAST)
            Util.Tween(tabGlow, {ImageTransparency = 0.80},      TWEEN.FAST)
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if selfRef.ActiveTab ~= tabData then
            Util.Tween(tabBtn,  {BackgroundTransparency = 0.92}, TWEEN.FAST)
            Util.Tween(tabGlow, {ImageTransparency = 1.0},       TWEEN.FAST)
        end
    end)
    tabBtn.MouseButton1Click:Connect(ActivateTab)

    if idx == 1 then ActivateTab() end

    local Tab  = {}
    Tab._frame = contentFrame

    function Tab:AddSection(sectionName)
        local sf = Instance.new("Frame")
        sf.Name                   = "Sec_" .. sectionName
        sf.Size                   = UDim2.new(1, 0, 0, 28)
        sf.BackgroundTransparency = 1
        sf.ZIndex                 = 13
        sf.LayoutOrder            = #contentFrame:GetChildren()
        sf.Parent                 = contentFrame

        local bg = Instance.new("Frame")
        bg.Size                   = UDim2.new(0, 10, 0, 18)
        bg.Position               = UDim2.new(0, 0, 0.5, -9)
        bg.BackgroundColor3       = Color3.fromRGB(8, 10, 22)
        bg.BackgroundTransparency = 0.05
        bg.ZIndex                 = 14
        bg.BorderSizePixel        = 0
        bg.Parent                 = sf
        Util.Round(bg, UDim.new(0, 6))

        local lbl = Instance.new("TextLabel")
        lbl.Size                   = UDim2.new(1, -8, 1, 0)
        lbl.Position               = UDim2.new(0, 4, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text                   = sectionName
        lbl.TextColor3             = GLASS.TextGhost
        lbl.TextSize               = 10
        lbl.Font                   = Enum.Font.GothamBold
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.ZIndex                 = 15
        lbl.Parent                 = sf

        task.defer(function()
            local tw = lbl.TextBounds.X
            bg.Size = UDim2.new(0, tw + 14, 0, 18)
        end)

        local line = Instance.new("Frame")
        line.Size                   = UDim2.new(1, -8, 0, 1)
        line.Position               = UDim2.new(0, 4, 1, -1)
        line.BackgroundColor3       = GLASS.RimLight
        line.BackgroundTransparency = 0.70
        line.ZIndex                 = 13
        line.BorderSizePixel        = 0
        line.Parent                 = sf
        Util.Gradient(line, {
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, GLASS.GlowAccent),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 255, 255)),
        }, {
            NumberSequenceKeypoint.new(0,   1),
            NumberSequenceKeypoint.new(0.5, 0.5),
            NumberSequenceKeypoint.new(1,   1),
        }, 0)
    end

    function Tab:AddButton(btnName, description, callback)
        local card, cardGlow = Util.GlassCard(contentFrame, 58, 13)
        card.LayoutOrder = #contentFrame:GetChildren()

        local lbl = Instance.new("TextLabel")
        lbl.Size                   = UDim2.new(1, -116, 0, 22)
        lbl.Position               = UDim2.new(0, 16, 0, 10)
        lbl.BackgroundTransparency = 1
        lbl.Text                   = btnName
        lbl.TextColor3             = GLASS.TextBright
        lbl.TextSize               = 14
        lbl.Font                   = Enum.Font.GothamSemibold
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.ZIndex                 = 15
        lbl.Parent                 = card

        if description then
            local desc = Instance.new("TextLabel")
            desc.Size                   = UDim2.new(1, -116, 0, 15)
            desc.Position               = UDim2.new(0, 16, 0, 33)
            desc.BackgroundTransparency = 1
            desc.Text                   = description
            desc.TextColor3             = GLASS.TextGhost
            desc.TextSize               = 11
            desc.Font                   = Enum.Font.Gotham
            desc.TextXAlignment         = Enum.TextXAlignment.Left
            desc.ZIndex                 = 15
            desc.Parent                 = card
        end

        local pill = Instance.new("TextButton")
        pill.Size                   = UDim2.new(0, 80, 0, 32)
        pill.Position               = UDim2.new(1, -92, 0.5, -16)
        pill.BackgroundColor3       = GLASS.AccentBlue
        pill.BackgroundTransparency = 0.30
        pill.Text                   = "Run"
        pill.TextColor3             = Color3.fromRGB(255, 255, 255)
        pill.TextSize               = 12
        pill.Font                   = Enum.Font.GothamSemibold
        pill.ZIndex                 = 16
        pill.BorderSizePixel        = 0
        pill.Parent                 = card
        Util.Round(pill, UDim.new(1, 0))
        Util.Rim(pill, GLASS.AccentBlue, 1, 0.35)
        local pillGlow = Util.InnerGlow(pill, GLASS.AccentBlue, 16)

        pill.MouseEnter:Connect(function()
            Util.Tween(pill,     {BackgroundTransparency = 0.0, Size = UDim2.new(0, 84, 0, 34)}, TWEEN.HOVER)
            Util.Tween(pillGlow, {ImageTransparency = 0.45},                                      TWEEN.GLOW)
            Util.Tween(cardGlow, {ImageTransparency = 0.65},                                      TWEEN.GLOW)
        end)
        pill.MouseLeave:Connect(function()
            Util.Tween(pill,     {BackgroundTransparency = 0.30, Size = UDim2.new(0, 80, 0, 32)}, TWEEN.HOVER)
            Util.Tween(pillGlow, {ImageTransparency = 1.0},                                        TWEEN.GLOW)
            Util.Tween(cardGlow, {ImageTransparency = 0.90},                                       TWEEN.GLOW)
        end)
        pill.MouseButton1Click:Connect(function()
            Util.Tween(pill,     {BackgroundTransparency = 0.0},  TWEEN.FAST)
            Util.Tween(pillGlow, {ImageTransparency = 0.25},      TWEEN.FAST)
            Util.Tween(card,     {BackgroundTransparency = 0.72}, TWEEN.FAST)
            task.delay(0.18, function()
                Util.Tween(pill,     {BackgroundTransparency = 0.30}, TWEEN.HOVER)
                Util.Tween(pillGlow, {ImageTransparency = 1.0},       TWEEN.GLOW)
                Util.Tween(card,     {BackgroundTransparency = 0.88}, TWEEN.HOVER)
            end)
            if callback then pcall(callback) end
        end)
    end

    function Tab:AddToggle(toggleName, description, default, callback)
        local enabled        = default or false
        local card, cardGlow = Util.GlassCard(contentFrame, 58, 13)
        card.LayoutOrder     = #contentFrame:GetChildren()

        local lbl = Instance.new("TextLabel")
        lbl.Size                   = UDim2.new(1, -90, 0, 22)
        lbl.Position               = UDim2.new(0, 16, 0, 10)
        lbl.BackgroundTransparency = 1
        lbl.Text                   = toggleName
        lbl.TextColor3             = GLASS.TextBright
        lbl.TextSize               = 14
        lbl.Font                   = Enum.Font.GothamSemibold
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.ZIndex                 = 15
        lbl.Parent                 = card

        if description then
            local desc = Instance.new("TextLabel")
            desc.Size                   = UDim2.new(1, -90, 0, 15)
            desc.Position               = UDim2.new(0, 16, 0, 33)
            desc.BackgroundTransparency = 1
            desc.Text                   = description
            desc.TextColor3             = GLASS.TextGhost
            desc.TextSize               = 11
            desc.Font                   = Enum.Font.Gotham
            desc.TextXAlignment         = Enum.TextXAlignment.Left
            desc.ZIndex                 = 15
            desc.Parent                 = card
        end

        local track = Instance.new("Frame")
        track.Size                   = UDim2.new(0, 52, 0, 28)
        track.Position               = UDim2.new(1, -66, 0.5, -14)
        track.BackgroundColor3       = enabled and GLASS.AccentBlue or Color3.fromRGB(60, 65, 85)
        track.BackgroundTransparency = enabled and 0.15 or 0.55
        track.ZIndex                 = 16
        track.BorderSizePixel        = 0
        track.Parent                 = card
        Util.Round(track, UDim.new(1, 0))
        Util.Rim(track, enabled and GLASS.AccentBlue or GLASS.TextGhost, 1, 0.45)
        local trackGlow = Util.InnerGlow(track, GLASS.AccentBlue, 16)
        trackGlow.ImageTransparency = enabled and 0.55 or 1.0

        local knob = Instance.new("Frame")
        knob.Size                   = UDim2.new(0, 22, 0, 22)
        knob.AnchorPoint            = Vector2.new(0, 0.5)
        knob.Position               = enabled and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        knob.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
        knob.BackgroundTransparency = 0
        knob.ZIndex                 = 17
        knob.BorderSizePixel        = 0
        knob.Parent                 = track
        Util.Round(knob, UDim.new(1, 0))
        Util.Rim(knob, GLASS.RimLight, 1, 0.40)

        local function UpdateToggle()
            if enabled then
                Util.Tween(track,     {BackgroundColor3 = GLASS.AccentBlue, BackgroundTransparency = 0.15}, TWEEN.MORPH)
                Util.Tween(knob,      {Position = UDim2.new(1, -25, 0.5, 0)},                               TWEEN.KNOB)
                Util.Tween(trackGlow, {ImageTransparency = 0.55},                                            TWEEN.GLOW)
                Util.Tween(cardGlow,  {ImageTransparency = 0.70},                                            TWEEN.GLOW)
                Util.Rim(track, GLASS.AccentBlue, 1, 0.35)
            else
                Util.Tween(track,     {BackgroundColor3 = Color3.fromRGB(60, 65, 85), BackgroundTransparency = 0.55}, TWEEN.MORPH)
                Util.Tween(knob,      {Position = UDim2.new(0, 3, 0.5, 0)},                                           TWEEN.KNOB)
                Util.Tween(trackGlow, {ImageTransparency = 1.0},                                                       TWEEN.GLOW)
                Util.Tween(cardGlow,  {ImageTransparency = 0.90},                                                      TWEEN.GLOW)
                Util.Rim(track, GLASS.TextGhost, 1, 0.55)
            end
            if callback then pcall(callback, enabled) end
        end

        local clickRegion = Instance.new("TextButton")
        clickRegion.Size                   = UDim2.new(1, 0, 1, 0)
        clickRegion.BackgroundTransparency = 1
        clickRegion.Text                   = ""
        clickRegion.ZIndex                 = 18
        clickRegion.Parent                 = card
        clickRegion.MouseButton1Click:Connect(function()
            enabled = not enabled
            UpdateToggle()
        end)

        local obj = {Value = enabled}
        function obj:Set(v)
            enabled   = v
            obj.Value = v
            UpdateToggle()
        end
        return obj
    end

    function Tab:AddSlider(sliderName, description, min, max, default, callback)
        local value          = math.clamp(default or min, min, max)
        local card, cardGlow = Util.GlassCard(contentFrame, 72, 13)
        card.LayoutOrder     = #contentFrame:GetChildren()

        local lbl = Instance.new("TextLabel")
        lbl.Size                   = UDim2.new(1, -80, 0, 20)
        lbl.Position               = UDim2.new(0, 16, 0, 8)
        lbl.BackgroundTransparency = 1
        lbl.Text                   = sliderName
        lbl.TextColor3             = GLASS.TextBright
        lbl.TextSize               = 14
        lbl.Font                   = Enum.Font.GothamSemibold
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.ZIndex                 = 15
        lbl.Parent                 = card

        local valLbl = Instance.new("TextLabel")
        valLbl.Size                   = UDim2.new(0, 60, 0, 20)
        valLbl.Position               = UDim2.new(1, -74, 0, 8)
        valLbl.BackgroundTransparency = 1
        valLbl.Text                   = tostring(value)
        valLbl.TextColor3             = GLASS.AccentBlue
        valLbl.TextSize               = 14
        valLbl.Font                   = Enum.Font.GothamBold
        valLbl.TextXAlignment         = Enum.TextXAlignment.Right
        valLbl.ZIndex                 = 15
        valLbl.Parent                 = card

        if description then
            local desc = Instance.new("TextLabel")
            desc.Size                   = UDim2.new(1, -80, 0, 13)
            desc.Position               = UDim2.new(0, 16, 0, 27)
            desc.BackgroundTransparency = 1
            desc.Text                   = description
            desc.TextColor3             = GLASS.TextGhost
            desc.TextSize               = 10
            desc.Font                   = Enum.Font.Gotham
            desc.TextXAlignment         = Enum.TextXAlignment.Left
            desc.ZIndex                 = 15
            desc.Parent                 = card
        end

        local trackBg = Instance.new("Frame")
        trackBg.Size                   = UDim2.new(1, -32, 0, 6)
        trackBg.Position               = UDim2.new(0, 16, 1, -20)
        trackBg.BackgroundColor3       = Color3.fromRGB(50, 55, 80)
        trackBg.BackgroundTransparency = 0.35
        trackBg.ZIndex                 = 15
        trackBg.BorderSizePixel        = 0
        trackBg.Parent                 = card
        Util.Round(trackBg, UDim.new(1, 0))
        Util.Rim(trackBg, GLASS.RimLight, 1, 0.55)

        local fill = Instance.new("Frame")
        fill.Size             = UDim2.new((value - min) / (max - min), 0, 1, 0)
        fill.ZIndex           = 16
        fill.BorderSizePixel  = 0
        fill.Parent           = trackBg
        Util.Round(fill, UDim.new(1, 0))
        Util.Gradient(fill, {
            ColorSequenceKeypoint.new(0, GLASS.AccentBlue),
            ColorSequenceKeypoint.new(1, GLASS.AccentPurple),
        }, {
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 0),
        }, 0)

        local thumb = Instance.new("Frame")
        thumb.Size                   = UDim2.new(0, 18, 0, 18)
        thumb.AnchorPoint            = Vector2.new(0.5, 0.5)
        thumb.Position               = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
        thumb.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
        thumb.ZIndex                 = 17
        thumb.BorderSizePixel        = 0
        thumb.Parent                 = trackBg
        Util.Round(thumb, UDim.new(1, 0))
        Util.Rim(thumb, GLASS.AccentBlue, 2, 0.15)
        local thumbGlow = Util.InnerGlow(thumb, GLASS.AccentBlue, 17)
        thumbGlow.ImageTransparency = 0.70

        local dragging = false
        trackBg.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                Util.Tween(thumb, {Size = UDim2.new(0, 18, 0, 18)}, TWEEN.HOVER)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local ap  = trackBg.AbsolutePosition
                local as  = trackBg.AbsoluteSize
                local rel = math.clamp((inp.Position.X - ap.X) / as.X, 0, 1)
                value     = math.floor(min + rel * (max - min))
                valLbl.Text = tostring(value)
                Util.Tween(fill,  {Size     = UDim2.new(rel, 0, 1, 0)},                         TWEEN.FAST)
                Util.Tween(thumb, {Position = UDim2.new(rel, 0, 0.5, 0), Size = UDim2.new(0, 20, 0, 20)}, TWEEN.FAST)
                if callback then pcall(callback, value) end
            end
        end)

        local obj = {Value = value}
        function obj:Set(v)
            v         = math.clamp(v, min, max)
            value     = v
            obj.Value = v
            local rel = (v - min) / (max - min)
            valLbl.Text = tostring(v)
            Util.Tween(fill,  {Size     = UDim2.new(rel, 0, 1, 0)},   TWEEN.MORPH)
            Util.Tween(thumb, {Position = UDim2.new(rel, 0, 0.5, 0)}, TWEEN.MORPH)
            if callback then pcall(callback, v) end
        end
        return obj
    end

    function Tab:AddDropdown(dropName, description, options, default, callback)
        local selected       = default or (options and options[1]) or "None"
        local open           = false
        local card, _        = Util.GlassCard(contentFrame, 58, 13)
        card.LayoutOrder      = #contentFrame:GetChildren()
        card.ClipsDescendants = false

        local lbl = Instance.new("TextLabel")
        lbl.Size                   = UDim2.new(1, -160, 0, 22)
        lbl.Position               = UDim2.new(0, 16, 0, 10)
        lbl.BackgroundTransparency = 1
        lbl.Text                   = dropName
        lbl.TextColor3             = GLASS.TextBright
        lbl.TextSize               = 14
        lbl.Font                   = Enum.Font.GothamSemibold
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.ZIndex                 = 15
        lbl.Parent                 = card

        if description then
            local desc = Instance.new("TextLabel")
            desc.Size                   = UDim2.new(1, -160, 0, 15)
            desc.Position               = UDim2.new(0, 16, 0, 33)
            desc.BackgroundTransparency = 1
            desc.Text                   = description
            desc.TextColor3             = GLASS.TextGhost
            desc.TextSize               = 11
            desc.Font                   = Enum.Font.Gotham
            desc.TextXAlignment         = Enum.TextXAlignment.Left
            desc.ZIndex                 = 15
            desc.Parent                 = card
        end

        local header = Instance.new("TextButton")
        header.Size                   = UDim2.new(0, 130, 0, 32)
        header.Position               = UDim2.new(1, -144, 0.5, -16)
        header.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
        header.BackgroundTransparency = 0.85
        header.Text                   = ""
        header.ZIndex                 = 16
        header.BorderSizePixel        = 0
        header.Parent                 = card
        Util.Round(header, UDim.new(1, 0))
        Util.Rim(header, GLASS.RimLight, 1, 0.35)
        Util.InnerGlow(header, GLASS.GlowInner, 16)

        local selLbl = Instance.new("TextLabel")
        selLbl.Size                   = UDim2.new(1, -28, 1, 0)
        selLbl.Position               = UDim2.new(0, 10, 0, 0)
        selLbl.BackgroundTransparency = 1
        selLbl.Text                   = selected
        selLbl.TextColor3             = GLASS.AccentBlue
        selLbl.TextSize               = 12
        selLbl.Font                   = Enum.Font.GothamSemibold
        selLbl.TextXAlignment         = Enum.TextXAlignment.Left
        selLbl.ZIndex                 = 17
        selLbl.Parent                 = header

        local arrow = Instance.new("TextLabel")
        arrow.Size                   = UDim2.new(0, 20, 1, 0)
        arrow.Position               = UDim2.new(1, -22, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text                   = "v"
        arrow.TextColor3             = GLASS.TextGhost
        arrow.TextSize               = 11
        arrow.Font                   = Enum.Font.GothamBold
        arrow.ZIndex                 = 17
        arrow.Parent                 = header

        local listH     = math.min(#options, 5) * 34 + 10
        local listFrame = Instance.new("Frame")
        listFrame.Size                   = UDim2.new(0, 130, 0, listH)
        listFrame.Position               = UDim2.new(1, -144, 1, 6)
        listFrame.BackgroundColor3       = Color3.fromRGB(15, 18, 32)
        listFrame.BackgroundTransparency = 0.15
        listFrame.ZIndex                 = 30
        listFrame.Visible                = false
        listFrame.ClipsDescendants       = true
        listFrame.BorderSizePixel        = 0
        listFrame.Parent                 = card
        Util.Round(listFrame, UDim.new(0, 14))
        Util.Rim(listFrame, GLASS.RimLight, 1, 0.28)

        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding   = UDim.new(0, 2)
        listLayout.Parent    = listFrame

        local listPad = Instance.new("UIPadding")
        listPad.PaddingTop   = UDim.new(0, 5)
        listPad.PaddingLeft  = UDim.new(0, 5)
        listPad.PaddingRight = UDim.new(0, 5)
        listPad.Parent       = listFrame

        for i, opt in ipairs(options or {}) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size                   = UDim2.new(1, 0, 0, 30)
            optBtn.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
            optBtn.BackgroundTransparency = 0.90
            optBtn.Text                   = opt
            optBtn.TextColor3             = GLASS.TextDim
            optBtn.TextSize               = 12
            optBtn.Font                   = Enum.Font.Gotham
            optBtn.ZIndex                 = 31
            optBtn.BorderSizePixel        = 0
            optBtn.LayoutOrder            = i
            optBtn.Parent                 = listFrame
            Util.Round(optBtn, UDim.new(0, 10))

            optBtn.MouseEnter:Connect(function()
                Util.Tween(optBtn, {BackgroundTransparency = 0.65, TextColor3 = GLASS.AccentBlue}, TWEEN.FAST)
            end)
            optBtn.MouseLeave:Connect(function()
                Util.Tween(optBtn, {BackgroundTransparency = 0.90, TextColor3 = GLASS.TextDim}, TWEEN.FAST)
            end)
            optBtn.MouseButton1Click:Connect(function()
                selected          = opt
                selLbl.Text       = opt
                open              = false
                listFrame.Visible = false
                Util.Tween(arrow, {Rotation = 0}, TWEEN.FAST)
                if callback then pcall(callback, opt) end
            end)
        end

        header.MouseButton1Click:Connect(function()
            open              = not open
            listFrame.Visible = open
            Util.Tween(arrow, {Rotation = open and 180 or 0}, TWEEN.FAST)
            Util.Tween(header, {BackgroundTransparency = open and 0.70 or 0.85}, TWEEN.FAST)
        end)

        local obj = {Value = selected}
        function obj:Set(v)
            selected    = v
            selLbl.Text = v
            obj.Value   = v
            if callback then pcall(callback, v) end
        end
        return obj
    end

    function Tab:AddTextbox(boxName, description, placeholder, callback)
        local card, _ = Util.GlassCard(contentFrame, 72, 13)
        card.LayoutOrder = #contentFrame:GetChildren()

        local lbl = Instance.new("TextLabel")
        lbl.Size                   = UDim2.new(1, -20, 0, 20)
        lbl.Position               = UDim2.new(0, 16, 0, 8)
        lbl.BackgroundTransparency = 1
        lbl.Text                   = boxName
        lbl.TextColor3             = GLASS.TextBright
        lbl.TextSize               = 14
        lbl.Font                   = Enum.Font.GothamSemibold
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.ZIndex                 = 15
        lbl.Parent                 = card

        if description then
            local desc = Instance.new("TextLabel")
            desc.Size                   = UDim2.new(1, -20, 0, 13)
            desc.Position               = UDim2.new(0, 16, 0, 26)
            desc.BackgroundTransparency = 1
            desc.Text                   = description
            desc.TextColor3             = GLASS.TextGhost
            desc.TextSize               = 10
            desc.Font                   = Enum.Font.Gotham
            desc.TextXAlignment         = Enum.TextXAlignment.Left
            desc.ZIndex                 = 15
            desc.Parent                 = card
        end

        local inputHolder = Instance.new("Frame")
        inputHolder.Size                   = UDim2.new(1, -32, 0, 28)
        inputHolder.Position               = UDim2.new(0, 16, 1, -36)
        inputHolder.BackgroundColor3       = Color3.fromRGB(10, 14, 26)
        inputHolder.BackgroundTransparency = 0.25
        inputHolder.ZIndex                 = 15
        inputHolder.BorderSizePixel        = 0
        inputHolder.Parent                 = card
        Util.Round(inputHolder, UDim.new(0, 10))
        Util.Rim(inputHolder, GLASS.RimLight, 1, 0.55)

        local tb = Instance.new("TextBox")
        tb.Size                   = UDim2.new(1, -16, 1, 0)
        tb.Position               = UDim2.new(0, 8, 0, 0)
        tb.BackgroundTransparency = 1
        tb.Text                   = ""
        tb.PlaceholderText        = placeholder or "Type here..."
        tb.PlaceholderColor3      = GLASS.TextGhost
        tb.TextColor3             = GLASS.TextBright
        tb.TextSize               = 13
        tb.Font                   = Enum.Font.Gotham
        tb.TextXAlignment         = Enum.TextXAlignment.Left
        tb.ClearTextOnFocus       = false
        tb.ZIndex                 = 16
        tb.Parent                 = inputHolder

        tb.Focused:Connect(function()
            Util.Tween(inputHolder, {BackgroundTransparency = 0.10}, TWEEN.FAST)
            Util.Rim(inputHolder, GLASS.AccentBlue, 1.5, 0.25)
        end)
        tb.FocusLost:Connect(function(enter)
            Util.Tween(inputHolder, {BackgroundTransparency = 0.25}, TWEEN.FAST)
            Util.Rim(inputHolder, GLASS.RimLight, 1, 0.55)
            if callback then pcall(callback, tb.Text, enter) end
        end)
        return tb
    end

    function Tab:AddLabel(text, style)
        local fr = Instance.new("Frame")
        fr.Size                   = UDim2.new(1, 0, 0, 28)
        fr.BackgroundTransparency = 1
        fr.ZIndex                 = 13
        fr.LayoutOrder            = #contentFrame:GetChildren()
        fr.Parent                 = contentFrame

        local lbl = Instance.new("TextLabel")
        lbl.Size                   = UDim2.new(1, -8, 1, 0)
        lbl.Position               = UDim2.new(0, 4, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text                   = text
        lbl.ZIndex                 = 14
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.Font                   = Enum.Font.Gotham
        lbl.Parent                 = fr

        if style == "accent" then
            lbl.TextColor3 = GLASS.AccentBlue
            lbl.TextSize   = 15
            lbl.Font       = Enum.Font.GothamBold
        elseif style == "muted" then
            lbl.TextColor3 = GLASS.TextGhost
            lbl.TextSize   = 11
        else
            lbl.TextColor3 = GLASS.TextDim
            lbl.TextSize   = 13
        end

        local obj = {}
        function obj:SetText(t)  lbl.Text        = t end
        function obj:SetColor(c) lbl.TextColor3  = c end
        return obj
    end

    function Tab:AddColorPicker(pickerName, description, default, callback)
        local color          = default or Color3.fromRGB(100, 180, 255)
        local open           = false
        local pickerPanel
        local card, _        = Util.GlassCard(contentFrame, 58, 13)
        card.LayoutOrder      = #contentFrame:GetChildren()
        card.ClipsDescendants = false

        local lbl = Instance.new("TextLabel")
        lbl.Size                   = UDim2.new(1, -90, 0, 22)
        lbl.Position               = UDim2.new(0, 16, 0, 10)
        lbl.BackgroundTransparency = 1
        lbl.Text                   = pickerName
        lbl.TextColor3             = GLASS.TextBright
        lbl.TextSize               = 14
        lbl.Font                   = Enum.Font.GothamSemibold
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.ZIndex                 = 15
        lbl.Parent                 = card

        if description then
            local desc = Instance.new("TextLabel")
            desc.Size                   = UDim2.new(1, -90, 0, 15)
            desc.Position               = UDim2.new(0, 16, 0, 33)
            desc.BackgroundTransparency = 1
            desc.Text                   = description
            desc.TextColor3             = GLASS.TextGhost
            desc.TextSize               = 11
            desc.Font                   = Enum.Font.Gotham
            desc.TextXAlignment         = Enum.TextXAlignment.Left
            desc.ZIndex                 = 15
            desc.Parent                 = card
        end

        local preview = Instance.new("Frame")
        preview.Size                   = UDim2.new(0, 38, 0, 38)
        preview.Position               = UDim2.new(1, -54, 0.5, -19)
        preview.BackgroundColor3       = color
        preview.ZIndex                 = 16
        preview.BorderSizePixel        = 0
        preview.Parent                 = card
        Util.Round(preview, UDim.new(0, 12))
        Util.Rim(preview, GLASS.RimLight, 1.5, 0.30)
        Util.TopShine(preview, 17)

        local function BuildPicker()
            pickerPanel                    = Instance.new("Frame")
            pickerPanel.Size               = UDim2.new(1, 0, 0, 120)
            pickerPanel.Position           = UDim2.new(0, 0, 1, 6)
            pickerPanel.BackgroundColor3   = Color3.fromRGB(12, 15, 28)
            pickerPanel.BackgroundTransparency = 0.12
            pickerPanel.ZIndex             = 25
            pickerPanel.BorderSizePixel    = 0
            pickerPanel.ClipsDescendants   = true
            pickerPanel.Parent             = card
            Util.Round(pickerPanel, UDim.new(0, 14))
            Util.Rim(pickerPanel, GLASS.RimLight, 1, 0.30)

            local vals = {color.R * 255, color.G * 255, color.B * 255}
            local chs  = {
                {n = "R", c = Color3.fromRGB(255, 80, 80),  i = 1},
                {n = "G", c = Color3.fromRGB(80, 220, 120), i = 2},
                {n = "B", c = Color3.fromRGB(80, 160, 255), i = 3},
            }

            local function Rebuild()
                color                    = Color3.fromRGB(vals[1], vals[2], vals[3])
                preview.BackgroundColor3 = color
                if callback then pcall(callback, color) end
            end

            for _, ch in ipairs(chs) do
                local row = Instance.new("Frame")
                row.Size                   = UDim2.new(1, -16, 0, 28)
                row.Position               = UDim2.new(0, 8, 0, 8 + (ch.i - 1) * 36)
                row.BackgroundTransparency = 1
                row.ZIndex                 = 26
                row.Parent                 = pickerPanel

                local chLbl = Instance.new("TextLabel")
                chLbl.Size                   = UDim2.new(0, 14, 1, 0)
                chLbl.BackgroundTransparency = 1
                chLbl.Text                   = ch.n
                chLbl.TextColor3             = ch.c
                chLbl.TextSize               = 11
                chLbl.Font                   = Enum.Font.GothamBold
                chLbl.ZIndex                 = 27
                chLbl.Parent                 = row

                local tr = Instance.new("Frame")
                tr.Size                   = UDim2.new(1, -58, 0, 6)
                tr.Position               = UDim2.new(0, 18, 0.5, -3)
                tr.BackgroundColor3       = Color3.fromRGB(40, 45, 70)
                tr.BackgroundTransparency = 0.20
                tr.ZIndex                 = 26
                tr.BorderSizePixel        = 0
                tr.Parent                 = row
                Util.Round(tr, UDim.new(1, 0))

                local fi = Instance.new("Frame")
                fi.Size             = UDim2.new(vals[ch.i] / 255, 0, 1, 0)
                fi.BackgroundColor3 = ch.c
                fi.ZIndex           = 27
                fi.BorderSizePixel  = 0
                fi.Parent           = tr
                Util.Round(fi, UDim.new(1, 0))

                local th = Instance.new("Frame")
                th.Size                   = UDim2.new(0, 12, 0, 12)
                th.AnchorPoint            = Vector2.new(0.5, 0.5)
                th.Position               = UDim2.new(vals[ch.i] / 255, 0, 0.5, 0)
                th.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
                th.ZIndex                 = 28
                th.BorderSizePixel        = 0
                th.Parent                 = tr
                Util.Round(th, UDim.new(1, 0))

                local vLbl = Instance.new("TextLabel")
                vLbl.Size                   = UDim2.new(0, 32, 1, 0)
                vLbl.Position               = UDim2.new(1, -32, 0, 0)
                vLbl.BackgroundTransparency = 1
                vLbl.Text                   = tostring(math.floor(vals[ch.i]))
                vLbl.TextColor3             = GLASS.TextDim
                vLbl.TextSize               = 10
                vLbl.Font                   = Enum.Font.Gotham
                vLbl.ZIndex                 = 27
                vLbl.Parent                 = row

                local draggingCh = false
                tr.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingCh = true end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingCh = false end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if draggingCh and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local ap  = tr.AbsolutePosition
                        local as  = tr.AbsoluteSize
                        local rel = math.clamp((inp.Position.X - ap.X) / as.X, 0, 1)
                        vals[ch.i] = math.floor(rel * 255)
                        vLbl.Text  = tostring(vals[ch.i])
                        Util.Tween(fi, {Size     = UDim2.new(rel, 0, 1, 0)},   TWEEN.FAST)
                        Util.Tween(th, {Position = UDim2.new(rel, 0, 0.5, 0)}, TWEEN.FAST)
                        Rebuild()
                    end
                end)
            end
        end

        local clickBtn = Instance.new("TextButton")
        clickBtn.Size                   = UDim2.new(0, 38, 0, 38)
        clickBtn.Position               = UDim2.new(1, -54, 0.5, -19)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text                   = ""
        clickBtn.ZIndex                 = 18
        clickBtn.Parent                 = card
        clickBtn.MouseButton1Click:Connect(function()
            open = not open
            if open then
                BuildPicker()
                Util.Tween(card, {Size = UDim2.new(1, 0, 0, 188)}, TWEEN.MORPH)
            else
                if pickerPanel then pcall(function() pickerPanel:Destroy() end) pickerPanel = nil end
                Util.Tween(card, {Size = UDim2.new(1, 0, 0, 58)}, TWEEN.MORPH)
            end
        end)

        local obj = {Value = color}
        function obj:Set(c)
            color                    = c
            preview.BackgroundColor3 = c
            obj.Value                = c
            if callback then pcall(callback, c) end
        end
        return obj
    end

    function Tab:AddKeybind(bindName, description, default, callback)
        local key     = default or Enum.KeyCode.Unknown
        local waiting = false
        local card, _ = Util.GlassCard(contentFrame, 58, 13)
        card.LayoutOrder = #contentFrame:GetChildren()

        local lbl = Instance.new("TextLabel")
        lbl.Size                   = UDim2.new(1, -150, 0, 22)
        lbl.Position               = UDim2.new(0, 16, 0, 10)
        lbl.BackgroundTransparency = 1
        lbl.Text                   = bindName
        lbl.TextColor3             = GLASS.TextBright
        lbl.TextSize               = 14
        lbl.Font                   = Enum.Font.GothamSemibold
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.ZIndex                 = 15
        lbl.Parent                 = card

        if description then
            local desc = Instance.new("TextLabel")
            desc.Size                   = UDim2.new(1, -150, 0, 15)
            desc.Position               = UDim2.new(0, 16, 0, 33)
            desc.BackgroundTransparency = 1
            desc.Text                   = description
            desc.TextColor3             = GLASS.TextGhost
            desc.TextSize               = 11
            desc.Font                   = Enum.Font.Gotham
            desc.TextXAlignment         = Enum.TextXAlignment.Left
            desc.ZIndex                 = 15
            desc.Parent                 = card
        end

        local pill = Instance.new("TextButton")
        pill.Size                   = UDim2.new(0, 120, 0, 32)
        pill.Position               = UDim2.new(1, -134, 0.5, -16)
        pill.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
        pill.BackgroundTransparency = 0.87
        pill.Text                   = key == Enum.KeyCode.Unknown and "None" or key.Name
        pill.TextColor3             = GLASS.AccentBlue
        pill.TextSize               = 12
        pill.Font                   = Enum.Font.GothamSemibold
        pill.ZIndex                 = 16
        pill.BorderSizePixel        = 0
        pill.Parent                 = card
        Util.Round(pill, UDim.new(1, 0))
        Util.Rim(pill, GLASS.AccentBlue, 1, 0.40)
        Util.InnerGlow(pill, GLASS.AccentBlue, 16)

        pill.MouseEnter:Connect(function()
            Util.Tween(pill, {BackgroundTransparency = 0.70}, TWEEN.FAST)
        end)
        pill.MouseLeave:Connect(function()
            if not waiting then
                Util.Tween(pill, {BackgroundTransparency = 0.87}, TWEEN.FAST)
            end
        end)
        pill.MouseButton1Click:Connect(function()
            if waiting then return end
            waiting         = true
            pill.Text       = "Press..."
            pill.TextColor3 = GLASS.AccentOrange
            Util.Rim(pill, GLASS.AccentOrange, 1, 0.30)

            local conn
            conn = UserInputService.InputBegan:Connect(function(inp, gpe)
                if gpe then return end
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    key             = inp.KeyCode
                    waiting         = false
                    pill.Text       = key.Name
                    pill.TextColor3 = GLASS.AccentBlue
                    Util.Rim(pill, GLASS.AccentBlue, 1, 0.40)
                    conn:Disconnect()
                    if callback then pcall(callback, key) end
                end
            end)
        end)

        local obj = {Value = key}
        function obj:Set(k)
            key       = k
            pill.Text = k.Name
            obj.Value = k
        end
        return obj
    end

    return Tab
end

function LiquidGlass:Notify(title, message, notifType, duration)
    duration  = duration  or 4
    notifType = notifType or "info"

    local accent = ({
        info    = GLASS.AccentBlue,
        success = GLASS.AccentGreen,
        error   = GLASS.AccentRed,
        warning = GLASS.AccentOrange,
    })[notifType] or GLASS.AccentBlue

    local card = Instance.new("Frame")
    card.Name                   = "Notif"
    card.Size                   = UDim2.new(1, 0, 0, 75)
    card.BackgroundColor3       = Color3.fromRGB(12, 15, 28)
    card.BackgroundTransparency = 0.12
    card.ZIndex                 = 9999
    card.BorderSizePixel        = 0
    card.Parent                 = self.NotifGui
    Util.Round(card, UDim.new(0, 18))
    Util.Rim(card, accent, 1.2, 0.25)
    Util.TopShine(card, 10000)
    Util.InnerGlow(card, accent, 9999)
    Util.LensDist(card, 9999)

    Util.Gradient(card, {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 35, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 15, 28)),
    }, {
        NumberSequenceKeypoint.new(0, 0.20),
        NumberSequenceKeypoint.new(1, 0.10),
    }, 140)

    local accentBar = Instance.new("Frame")
    accentBar.Size                   = UDim2.new(0, 3, 0.65, 0)
    accentBar.Position               = UDim2.new(0, 8, 0.175, 0)
    accentBar.BackgroundColor3       = accent
    accentBar.BackgroundTransparency = 0
    accentBar.ZIndex                 = 10001
    accentBar.BorderSizePixel        = 0
    accentBar.Parent                 = card
    Util.Round(accentBar, UDim.new(1, 0))
    Util.InnerGlow(accentBar, accent, 10001)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size                   = UDim2.new(1, -40, 0, 22)
    titleLbl.Position               = UDim2.new(0, 20, 0, 10)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text                   = title or "Notice"
    titleLbl.TextColor3             = GLASS.TextBright
    titleLbl.TextSize               = 14
    titleLbl.Font                   = Enum.Font.GothamBold
    titleLbl.TextXAlignment         = Enum.TextXAlignment.Left
    titleLbl.ZIndex                 = 10001
    titleLbl.Parent                 = card

    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size                   = UDim2.new(1, -40, 0, 30)
    msgLbl.Position               = UDim2.new(0, 20, 0, 33)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Text                   = message or ""
    msgLbl.TextColor3             = GLASS.TextDim
    msgLbl.TextSize               = 12
    msgLbl.Font                   = Enum.Font.Gotham
    msgLbl.TextXAlignment         = Enum.TextXAlignment.Left
    msgLbl.TextWrapped            = true
    msgLbl.ZIndex                 = 10001
    msgLbl.Parent                 = card

    local prog = Instance.new("Frame")
    prog.Size                   = UDim2.new(1, -16, 0, 2)
    prog.Position               = UDim2.new(0, 8, 1, -6)
    prog.BackgroundColor3       = accent
    prog.BackgroundTransparency = 0.20
    prog.ZIndex                 = 10002
    prog.BorderSizePixel        = 0
    prog.Parent                 = card
    Util.Round(prog, UDim.new(1, 0))

    card.Position = UDim2.new(1, 30, 0, 0)
    Util.Tween(card, {Position = UDim2.new(0, 0, 0, 0)},
        MakeTween(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
    Util.Tween(prog, {Size = UDim2.new(0, 0, 0, 2)},
        MakeTween(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In))

    task.delay(duration, function()
        Util.Tween(card, {Position = UDim2.new(1, 30, 0, 0)}, TWEEN.CLOSE)
        task.delay(0.5, function()
            if card and card.Parent then card:Destroy() end
        end)
    end)

    return card
end

function LiquidGlass:Destroy()
    for _, c in ipairs(self.Connections) do
        pcall(function() c:Disconnect() end)
    end
    self.Connections = {}
    if DepthOfField    then DepthOfField.Enabled    = false end
    if BloomEffect     then BloomEffect.Enabled      = false end
    if ColorCorrect    then ColorCorrect.Enabled     = false end
    if self.ScreenGui and self.ScreenGui.Parent then
        self.ScreenGui:Destroy()
    end
end

return LiquidGlass
