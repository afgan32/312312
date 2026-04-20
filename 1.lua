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

local SPRING = {
    OPEN   = TweenInfo.new(0.7,  Enum.EasingStyle.Spring, Enum.EasingDirection.Out),
    CLOSE  = TweenInfo.new(0.45, Enum.EasingStyle.Quart,  Enum.EasingDirection.In),
    HOVER  = TweenInfo.new(0.35, Enum.EasingStyle.Spring, Enum.EasingDirection.Out),
    FAST   = TweenInfo.new(0.18, Enum.EasingStyle.Quart,  Enum.EasingDirection.Out),
    GLOW   = TweenInfo.new(0.55, Enum.EasingStyle.Sine,   Enum.EasingDirection.InOut),
    MORPH  = TweenInfo.new(0.5,  Enum.EasingStyle.Spring, Enum.EasingDirection.Out),
}

local GLASS = {
    RimLight         = Color3.fromRGB(255, 255, 255),
    GlowInner        = Color3.fromRGB(200, 225, 255),
    GlowAccent       = Color3.fromRGB(140, 200, 255),
    GlowPulse        = Color3.fromRGB(180, 150, 255),
    SurfaceLight     = Color3.fromRGB(255, 255, 255),
    FrostTint        = Color3.fromRGB(180, 205, 240),
    ClearTint        = Color3.fromRGB(240, 245, 255),
    TextBright       = Color3.fromRGB(255, 255, 255),
    TextDim          = Color3.fromRGB(200, 215, 235),
    TextGhost        = Color3.fromRGB(150, 170, 200),
    AccentBlue       = Color3.fromRGB(100, 185, 255),
    AccentPurple     = Color3.fromRGB(175, 130, 255),
    AccentGreen      = Color3.fromRGB(100, 235, 165),
    AccentRed        = Color3.fromRGB(255, 95,  105),
    AccentOrange     = Color3.fromRGB(255, 185, 70),
    GlassDark        = Color3.fromRGB(8,   10,  18),
    GlassMid         = Color3.fromRGB(15,  18,  30),
    PanelAlpha       = 0.78,
    ClearAlpha       = 0.88,
    RimAlpha         = 0.22,
    GlowAlpha        = 0.60,
    ShineAlpha       = 0.40,
}

local Util = {}

function Util.Spring(inst, props, info)
    local t = TweenService:Create(inst, info or SPRING.HOVER, props)
    t:Play()
    return t
end

function Util.Rim(parent, color, thickness, alpha)
    local old = parent:FindFirstChildOfClass("UIStroke")
    if old then old:Destroy() end
    local s = Instance.new("UIStroke")
    s.Color           = color      or GLASS.RimLight
    s.Thickness       = thickness  or 1.0
    s.Transparency    = alpha      or GLASS.RimAlpha
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.LineJoinMode    = Enum.LineJoinMode.Round
    s.Parent          = parent
    return s
end

function Util.Round(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 20)
    c.Parent = parent
    return c
end

function Util.Gradient(parent, colors, transparencies, rotation)
    local g = Instance.new("UIGradient")
    g.Color        = ColorSequence.new(colors)
    g.Transparency = NumberSequence.new(transparencies)
    g.Rotation     = rotation or 135
    g.Parent       = parent
    return g
end

function Util.GlowFrame(parent, size, pos, zindex, alpha, tint, radius)
    local f = Instance.new("Frame")
    f.Size                   = size
    f.Position               = pos
    f.BackgroundColor3       = tint  or GLASS.FrostTint
    f.BackgroundTransparency = alpha or GLASS.PanelAlpha
    f.BorderSizePixel        = 0
    f.ZIndex                 = zindex or 10
    f.ClipsDescendants       = false
    f.Parent                 = parent
    Util.Round(f, radius or UDim.new(0, 20))
    Util.Rim(f)
    return f
end

function Util.InnerGlow(parent, color, zindex)
    local glow = Instance.new("ImageLabel")
    glow.Name                   = "InnerGlow"
    glow.Size                   = UDim2.new(1, 24, 1, 24)
    glow.Position               = UDim2.new(0, -12, 0, -12)
    glow.BackgroundTransparency = 1
    glow.Image                  = "rbxassetid://5028857084"
    glow.ImageColor3            = color or GLASS.GlowInner
    glow.ImageTransparency      = 0.82
    glow.ScaleType              = Enum.ScaleType.Slice
    glow.SliceCenter            = Rect.new(24, 24, 276, 276)
    glow.ZIndex                 = (zindex or 10) - 1
    glow.Parent                 = parent
    return glow
end

function Util.TopShine(parent, zindex)
    local shine = Instance.new("Frame")
    shine.Name                   = "TopShine"
    shine.Size                   = UDim2.new(0.7, 0, 0, 1)
    shine.Position               = UDim2.new(0.15, 0, 0, 2)
    shine.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    shine.BackgroundTransparency = 0.3
    shine.BorderSizePixel        = 0
    shine.ZIndex                 = zindex or 20
    shine.Parent                 = parent
    Util.Round(shine, UDim.new(1, 0))
    return shine
end

function Util.BottomReflect(parent, zindex)
    local ref = Instance.new("Frame")
    ref.Name                   = "BottomReflect"
    ref.Size                   = UDim2.new(0.5, 0, 0, 1)
    ref.Position               = UDim2.new(0.25, 0, 1, -2)
    ref.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    ref.BackgroundTransparency = 0.65
    ref.BorderSizePixel        = 0
    ref.ZIndex                 = zindex or 20
    ref.Parent                 = parent
    Util.Round(ref, UDim.new(1, 0))
    return ref
end

function Util.LensingDistort(parent, zindex)
    local lens = Instance.new("ImageLabel")
    lens.Name                   = "LensDistort"
    lens.Size                   = UDim2.new(1, 8, 1, 8)
    lens.Position               = UDim2.new(0, -4, 0, -4)
    lens.BackgroundTransparency = 1
    lens.Image                  = "rbxassetid://6014261993"
    lens.ImageColor3            = GLASS.GlowInner
    lens.ImageTransparency      = 0.90
    lens.ScaleType              = Enum.ScaleType.Slice
    lens.SliceCenter            = Rect.new(49, 49, 450, 450)
    lens.ZIndex                 = (zindex or 10) - 1
    lens.Parent                 = parent
    return lens
end

local DepthOfField
local BloomEffect
local ColorCorrectionEffect

local function SetupLightingEffects()
    DepthOfField = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")
    if not DepthOfField then
        DepthOfField = Instance.new("DepthOfFieldEffect")
        DepthOfField.Parent = Lighting
    end
    DepthOfField.FarIntensity  = 0
    DepthOfField.NearIntensity = 0
    DepthOfField.FocusDistance = 50
    DepthOfField.InFocusRadius = 50
    DepthOfField.Enabled       = false

    BloomEffect = Lighting:FindFirstChildOfClass("BloomEffect")
    if not BloomEffect then
        BloomEffect = Instance.new("BloomEffect")
        BloomEffect.Parent = Lighting
    end
    BloomEffect.Intensity  = 0
    BloomEffect.Size       = 24
    BloomEffect.Threshold  = 0.95
    BloomEffect.Enabled    = false

    ColorCorrectionEffect = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    if not ColorCorrectionEffect then
        ColorCorrectionEffect = Instance.new("ColorCorrectionEffect")
        ColorCorrectionEffect.Parent = Lighting
    end
    ColorCorrectionEffect.Enabled = false
end

local function EnableGlassBlur(open)
    if open then
        DepthOfField.FarIntensity  = 1
        DepthOfField.NearIntensity = 0
        DepthOfField.FocusDistance = 10
        DepthOfField.InFocusRadius = 8
        DepthOfField.Enabled       = true

        BloomEffect.Intensity = 0.6
        BloomEffect.Enabled   = true

        ColorCorrectionEffect.Saturation = -0.08
        ColorCorrectionEffect.Contrast   = 0.04
        ColorCorrectionEffect.Enabled    = true

        TweenService:Create(DepthOfField, SPRING.OPEN, {
            FarIntensity  = 1,
            FocusDistance = 10,
        }):Play()
    else
        TweenService:Create(DepthOfField, SPRING.CLOSE, {
            FarIntensity  = 0,
            NearIntensity = 0,
        }):Play()
        TweenService:Create(BloomEffect, SPRING.CLOSE, {
            Intensity = 0,
        }):Play()
        task.delay(0.5, function()
            DepthOfField.Enabled          = false
            BloomEffect.Enabled           = false
            ColorCorrectionEffect.Enabled = false
        end)
    end
end

local function DetectEnvironmentTint()
    local hour = Lighting.ClockTime
    if hour >= 6 and hour <= 18 then
        return Color3.fromRGB(200, 215, 240), 0.80
    else
        return Color3.fromRGB(10, 15, 35), 0.65
    end
end

local GlassPart
local SurfaceGui
local GlassPartConn

local function CreateGlassPart(screenGui)
    if GlassPart then
        pcall(function() GlassPart:Destroy() end)
    end

    GlassPart = Instance.new("Part")
    GlassPart.Name          = "LiquidGlassPart"
    GlassPart.Size          = Vector3.new(14, 9, 0.05)
    GlassPart.Anchored      = true
    GlassPart.CanCollide    = false
    GlassPart.CastShadow    = false
    GlassPart.Material      = Enum.Material.Glass
    GlassPart.Transparency  = 0.96
    GlassPart.Color         = Color3.fromRGB(200, 225, 255)
    GlassPart.Parent        = workspace

    local weld = Instance.new("SpecialMesh")
    weld.MeshType = Enum.MeshType.Brick
    weld.Parent   = GlassPart

    GlassPartConn = RunService.RenderStepped:Connect(function()
        if not Camera then return end
        local cf  = Camera.CFrame
        local fwd = cf.LookVector
        GlassPart.CFrame = CFrame.new(cf.Position + fwd * 12) * CFrame.Angles(cf:ToEulerAnglesXYZ())
    end)

    SurfaceGui = Instance.new("SurfaceGui")
    SurfaceGui.Name           = "LiquidGlassSurface"
    SurfaceGui.Face           = Enum.NormalId.Front
    SurfaceGui.SizingMode     = Enum.SurfaceGuiSizingMode.PixelsPerStud
    SurfaceGui.PixelsPerStud  = 50
    SurfaceGui.LightInfluence = 0
    SurfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    SurfaceGui.Parent         = GlassPart

    return GlassPart, SurfaceGui
end

local function DestroyGlassPart()
    if GlassPartConn then
        GlassPartConn:Disconnect()
        GlassPartConn = nil
    end
    if GlassPart then
        pcall(function() GlassPart:Destroy() end)
        GlassPart  = nil
        SurfaceGui = nil
    end
end

local NotifGui

local function EnsureNotifGui()
    if NotifGui and NotifGui.Parent then return NotifGui end
    local ok, g = pcall(function()
        local ng = Instance.new("ScreenGui")
        ng.Name            = "LG_Notifs"
        ng.ResetOnSpawn    = false
        ng.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
        ng.IgnoreGuiInset  = true
        ng.Parent          = CoreGui
        return ng
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
    holder.Position               = UDim2.new(1, -355, 0, 0)
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

    NotifGui = holder
    return NotifGui
end

function LiquidGlass.new(title, subtitle)
    local self = setmetatable({}, LiquidGlass)
    self.Connections = {}
    self.Tabs        = {}
    self.ActiveTab   = nil
    self.Visible     = true

    SetupLightingEffects()

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
        screenGui = Instance.new("ScreenGui")
        screenGui.Name            = "LiquidGlass"
        screenGui.ResetOnSpawn    = false
        screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
        screenGui.IgnoreGuiInset  = true
        screenGui.Parent          = LocalPlayer:WaitForChild("PlayerGui")
    end
    self.ScreenGui = screenGui

    local envTint, envAlpha = DetectEnvironmentTint()

    local backdrop = Instance.new("Frame")
    backdrop.Name                   = "Backdrop"
    backdrop.Size                   = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3       = GLASS.GlassDark
    backdrop.BackgroundTransparency = 0.35
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
    Util.LensingDistort(window, 10)

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

    Util.TopShine(window, 15)
    Util.BottomReflect(window, 15)

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
        local t, a = DetectEnvironmentTint()
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

    local titleGlow = Instance.new("Frame")
    titleGlow.Name                   = "TitleGlow"
    titleGlow.Size                   = UDim2.new(1, 0, 0, 62)
    titleGlow.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    titleGlow.BackgroundTransparency = 0.93
    titleGlow.BorderSizePixel        = 0
    titleGlow.ZIndex                 = 11
    titleGlow.Parent                 = window
    Util.Gradient(titleGlow, {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200,220,255)),
    }, {
        NumberSequenceKeypoint.new(0, 0.88),
        NumberSequenceKeypoint.new(1, 1.0),
    }, 90)

    local divider = Instance.new("Frame")
    divider.Name                   = "Divider"
    divider.Size                   = UDim2.new(0.9, 0, 0, 1)
    divider.Position               = UDim2.new(0.05, 0, 0, 61)
    divider.BackgroundColor3       = GLASS.RimLight
    divider.BackgroundTransparency = 0.55
    divider.ZIndex                 = 13
    divider.BorderSizePixel        = 0
    divider.Parent                 = window
    Util.Gradient(divider, {
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.5, GLASS.GlowAccent),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(255,255,255)),
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
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
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

    local function MakePillBtn(parent, xOffset, color, symbol)
        local pill = Instance.new("TextButton")
        pill.Size                   = UDim2.new(0, 30, 0, 30)
        pill.Position               = UDim2.new(1, xOffset, 0.5, -15)
        pill.BackgroundColor3       = color
        pill.BackgroundTransparency = 0.25
        pill.Text                   = ""
        pill.ZIndex                 = 14
        pill.BorderSizePixel        = 0
        pill.Parent                 = parent
        Util.Round(pill, UDim.new(1, 0))
        Util.Rim(pill, GLASS.RimLight, 1, 0.35)
        Util.InnerGlow(pill, color, 14)

        local sym = Instance.new("TextLabel")
        sym.Size                   = UDim2.new(1, 0, 1, 0)
        sym.BackgroundTransparency = 1
        sym.Text                   = symbol
        sym.TextColor3             = Color3.fromRGB(255, 255, 255)
        sym.TextSize               = 13
        sym.Font                   = Enum.Font.GothamBold
        sym.ZIndex                 = 15
        sym.Parent                 = pill

        pill.MouseEnter:Connect(function()
            Util.Spring(pill, {BackgroundTransparency = 0.0, Size = UDim2.new(0, 33, 0, 33)}, SPRING.HOVER)
            Util.Spring(pill, {ImageTransparency = 0.5}, SPRING.GLOW)
        end)
        pill.MouseLeave:Connect(function()
            Util.Spring(pill, {BackgroundTransparency = 0.25, Size = UDim2.new(0, 30, 0, 30)}, SPRING.HOVER)
        end)

        return pill
    end

    local closeBtn = MakePillBtn(titleBar, -40,  GLASS.AccentRed,    "x")
    local minBtn   = MakePillBtn(titleBar, -80,  GLASS.AccentOrange, "-")

    self.Window = window

    closeBtn.MouseButton1Click:Connect(function()
        self:Toggle(false)
    end)

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Util.Spring(window, {Size = UDim2.new(0, 720, 0, 62)}, SPRING.MORPH)
        else
            Util.Spring(window, {Size = UDim2.new(0, 720, 0, 500)}, SPRING.MORPH)
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
    contentHost.Name                   = "ContentHost"
    contentHost.Size                   = UDim2.new(1, -188, 1, -72)
    contentHost.Position               = UDim2.new(0, 182, 0, 66)
    contentHost.BackgroundTransparency = 1
    contentHost.ZIndex                 = 12
    contentHost.BorderSizePixel        = 0
    contentHost.ScrollBarThickness     = 3
    contentHost.ScrollBarImageColor3   = GLASS.GlowAccent
    contentHost.ScrollBarImageTransparency = 0.4
    contentHost.CanvasSize             = UDim2.new(0, 0, 0, 0)
    contentHost.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    contentHost.Parent                 = window

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
    self.NotifGui    = EnsureNotifGui()

    window.Size     = UDim2.new(0, 0, 0, 0)
    window.Position = UDim2.new(0.5, 0, 0.5, 0)
    EnableGlassBlur(true)

    task.delay(0.05, function()
        Util.Spring(window, {
            Size     = UDim2.new(0, 720, 0, 500),
            Position = UDim2.new(0.5, -360, 0.5, -250),
        }, TweenInfo.new(0.75, Enum.EasingStyle.Spring, Enum.EasingDirection.Out))
    end)

    return self
end

function LiquidGlass:Toggle(state)
    self.Visible = (state ~= nil) and state or (not self.Visible)
    if self.Visible then
        self.Window.Visible = true
        EnableGlassBlur(true)
        Util.Spring(self.Window, {
            Size     = UDim2.new(0, 720, 0, 500),
            Position = UDim2.new(0.5, -360, 0.5, -250),
        }, TweenInfo.new(0.75, Enum.EasingStyle.Spring, Enum.EasingDirection.Out))
    else
        EnableGlassBlur(false)
        local t = Util.Spring(self.Window, {
            Size     = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
        }, SPRING.CLOSE)
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
    tabGlow.ImageTransparency = 1

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
    indicator.Name                   = "Indicator"
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
            Util.Spring(t.Button,    {BackgroundTransparency = 0.92}, SPRING.FAST)
            Util.Spring(t.Indicator, {BackgroundTransparency = 1.0},  SPRING.FAST)
            Util.Spring(t.Label,     {TextColor3 = GLASS.TextDim},    SPRING.FAST)
            Util.Spring(t.Icon,      {TextColor3 = GLASS.TextDim},    SPRING.FAST)
            Util.Spring(t.Glow,      {ImageTransparency = 1.0},       SPRING.FAST)
        end
        contentFrame.Visible = true
        selfRef.ActiveTab    = tabData

        Util.Spring(tabBtn,    {BackgroundTransparency = 0.70},       SPRING.HOVER)
        Util.Spring(indicator, {BackgroundTransparency = 0.0},        SPRING.MORPH)
        Util.Spring(nameLbl,   {TextColor3 = GLASS.AccentBlue},       SPRING.HOVER)
        Util.Spring(iconLbl,   {TextColor3 = GLASS.AccentBlue},       SPRING.HOVER)
        Util.Spring(tabGlow,   {ImageTransparency = 0.65},            SPRING.GLOW)
        Util.Rim(tabBtn, GLASS.AccentBlue, 1.0, 0.35)
    end

    tabBtn.MouseEnter:Connect(function()
        if selfRef.ActiveTab ~= tabData then
            Util.Spring(tabBtn, {BackgroundTransparency = 0.83}, SPRING.FAST)
            Util.Spring(tabGlow, {ImageTransparency = 0.80}, SPRING.FAST)
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if selfRef.ActiveTab ~= tabData then
            Util.Spring(tabBtn, {BackgroundTransparency = 0.92}, SPRING.FAST)
            Util.Spring(tabGlow, {ImageTransparency = 1.0}, SPRING.FAST)
        end
    end)
    tabBtn.MouseButton1Click:Connect(ActivateTab)

    if idx == 1 then ActivateTab() end

    local Tab = {}
    Tab._frame = contentFrame

    local function GlassCard(h, zindex)
        local card = Instance.new("Frame")
        card.Size                   = UDim2.new(1, 0, 0, h)
        card.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
        card.BackgroundTransparency = 0.88
        card.BorderSizePixel        = 0
        card.ZIndex                 = zindex or 13
        card.ClipsDescendants       = false
        card.Parent                 = contentFrame
        Util.Round(card, UDim.new(0, 16))
        Util.Rim(card, GLASS.RimLight, 1, 0.28)
        Util.TopShine(card, (zindex or 13) + 2)
        Util.BottomReflect(card, (zindex or 13) + 2)
        Util.LensingDistort(card, zindex or 13)

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
            Util.Spring(card, {BackgroundTransparency = 0.78}, SPRING.FAST)
            Util.Spring(cardGlow, {ImageTransparency = 0.72}, SPRING.GLOW)
        end)
        card.MouseLeave:Connect(function()
            Util.Spring(card, {BackgroundTransparency = 0.88}, SPRING.FAST)
            Util.Spring(cardGlow, {ImageTransparency = 0.90}, SPRING.GLOW)
        end)

        return card, cardGlow
    end

    function Tab:AddSection(sectionName)
        local sf = Instance.new("Frame")
        sf.Name                   = "Sec_" .. sectionName
        sf.Size                   = UDim2.new(1, 0, 0, 28)
        sf.BackgroundTransparency = 1
        sf.ZIndex                 = 13
        sf.LayoutOrder            = #contentFrame:GetChildren()
        sf.Parent                 = contentFrame

        local line = Instance.new("Frame")
        line.Size                   = UDim2.new(1, -8, 0, 1)
        line.Position               = UDim2.new(0, 4, 0.5, 0)
        line.BackgroundColor3       = GLASS.RimLight
        line.BackgroundTransparency = 0.65
        line.ZIndex                 = 14
        line.BorderSizePixel        = 0
        line.Parent                 = sf
        Util.Gradient(line, {
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.4, GLASS.GlowAccent),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(255,255,255)),
        }, {
            NumberSequenceKeypoint.new(0,   1),
            NumberSequenceKeypoint.new(0.4, 0.5),
            NumberSequenceKeypoint.new(1,   1),
        }, 0)

        local lbl = Instance.new("TextLabel")
        lbl.Size                   = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundColor3       = GLASS.GlassDark
        lbl.BackgroundTransparency = 1
        lbl.Text                   = sectionName
        lbl.TextColor3             = GLASS.TextGhost
        lbl.TextSize               = 10
        lbl.Font                   = Enum.Font.GothamBold
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.ZIndex                 = 15
        lbl.Parent                 = sf

        local bg = Instance.new("Frame")
        bg.Size                   = UDim2.new(0, lbl.TextBounds.X + 12, 0, 16)
        bg.Position               = UDim2.new(0, 0, 0.5, -8)
        bg.BackgroundColor3       = GLASS.GlassDark
        bg.BackgroundTransparency = 0.1
        bg.ZIndex                 = 14
        bg.BorderSizePixel        = 0
        bg.Parent                 = sf
        Util.Round(bg, UDim.new(0, 6))
        lbl.ZIndex = 15
        lbl.Parent = bg
    end

    function Tab:AddButton(btnName, description, callback)
        local card, cardGlow = GlassCard(58)
        card.LayoutOrder = #contentFrame:GetChildren()

        local lbl = Instance.new("TextLabel")
        lbl.Size                   = UDim2.new(1, -120, 0, 22)
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
            desc.Size                   = UDim2.new(1, -120, 0, 15)
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
            Util.Spring(pill, {BackgroundTransparency = 0.0, Size = UDim2.new(0, 84, 0, 34)}, SPRING.HOVER)
            Util.Spring(pillGlow, {ImageTransparency = 0.45}, SPRING.GLOW)
            Util.Spring(cardGlow, {ImageTransparency = 0.65}, SPRING.GLOW)
        end)
        pill.MouseLeave:Connect(function()
            Util.Spring(pill, {BackgroundTransparency = 0.30, Size = UDim2.new(0, 80, 0, 32)}, SPRING.HOVER)
            Util.Spring(pillGlow, {ImageTransparency = 1.0}, SPRING.GLOW)
            Util.Spring(cardGlow, {ImageTransparency = 0.90}, SPRING.GLOW)
        end)
        pill.MouseButton1Click:Connect(function()
            Util.Spring(pill, {BackgroundTransparency = 0.0}, SPRING.FAST)
            Util.Spring(pillGlow, {ImageTransparency = 0.25}, SPRING.FAST)
            Util.Spring(card, {BackgroundTransparency = 0.72}, SPRING.FAST)
            task.delay(0.15, function()
                Util.Spring(pill, {BackgroundTransparency = 0.30}, SPRING.HOVER)
                Util.Spring(pillGlow, {ImageTransparency = 1.0}, SPRING.GLOW)
                Util.Spring(card, {BackgroundTransparency = 0.88}, SPRING.HOVER)
            end)
            if callback then pcall(callback) end
        end)
    end

    function Tab:AddToggle(toggleName, description, default, callback)
        local enabled   = default or false
        local card, cardGlow = GlassCard(58)
        card.LayoutOrder = #contentFrame:GetChildren()

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
        track.Name                   = "Track"
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
        trackGlow.ImageTransparency = enabled and 0.55 or 1

        local knob = Instance.new("Frame")
        knob.Name                   = "Knob"
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
        Util.InnerGlow(knob, Color3.fromRGB(255,255,255), 17)

        local function UpdateToggle()
            if enabled then
                Util.Spring(track, {BackgroundColor3 = GLASS.AccentBlue, BackgroundTransparency = 0.15}, SPRING.MORPH)
                Util.Spring(knob,  {Position = UDim2.new(1, -25, 0.5, 0)}, TweenInfo.new(0.45, Enum.EasingStyle.Spring, Enum.EasingDirection.Out))
                Util.Spring(trackGlow, {ImageTransparency = 0.55}, SPRING.GLOW)
                Util.Spring(cardGlow,  {ImageTransparency = 0.70}, SPRING.GLOW)
                Util.Rim(track, GLASS.AccentBlue, 1, 0.35)
            else
                Util.Spring(track, {BackgroundColor3 = Color3.fromRGB(60, 65, 85), BackgroundTransparency = 0.55}, SPRING.MORPH)
                Util.Spring(knob,  {Position = UDim2.new(0, 3, 0.5, 0)}, TweenInfo.new(0.45, Enum.EasingStyle.Spring, Enum.EasingDirection.Out))
                Util.Spring(trackGlow, {ImageTransparency = 1.0}, SPRING.GLOW)
                Util.Spring(cardGlow,  {ImageTransparency = 0.90}, SPRING.GLOW)
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
        local value     = math.clamp(default or min, min, max)
        local card, cardGlow = GlassCard(72)
        card.LayoutOrder = #contentFrame:GetChildren()

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
        trackBg.Name                   = "TrackBg"
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
        fill.Name                   = "Fill"
        fill.Size                   = UDim2.new((value - min) / (max - min), 0, 1, 0)
        fill.BackgroundTransparency = 0
        fill.ZIndex                 = 16
        fill.BorderSizePixel        = 0
        fill.Parent                 = trackBg
        Util.Round(fill, UDim.new(1, 0))
        Util.Gradient(fill, {
            ColorSequenceKeypoint.new(0, GLASS.AccentBlue),
            ColorSequenceKeypoint.new(1, GLASS.AccentPurple),
        }, {
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 0),
        }, 0)

        local thumb = Instance.new("Frame")
        thumb.Name                   = "Thumb"
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
                Util.Spring(thumb, {Size = UDim2.new(0, 18, 0, 18)}, SPRING.HOVER)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local ap  = trackBg.AbsolutePosition
                local as  = trackBg.AbsoluteSize
                local rel = math.clamp((inp.Position.X - ap.X) / as.X, 0, 1)
                value     = math.floor(min + rel * (max - min))
                valLbl.Text = tostring(value)
                Util.Spring(fill,  {Size     = UDim2.new(rel, 0, 1, 0)},   SPRING.FAST)
                Util.Spring(thumb, {Position = UDim2.new(rel, 0, 0.5, 0), Size = UDim2.new(0, 20, 0, 20)}, SPRING.FAST)
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
            Util.Spring(fill,  {Size     = UDim2.new(rel, 0, 1, 0)},   SPRING.MORPH)
            Util.Spring(thumb, {Position = UDim2.new(rel, 0, 0.5, 0)}, SPRING.MORPH)
            if callback then pcall(callback, v) end
        end
        return obj
    end

    function Tab:AddDropdown(dropName, description, options, default, callback)
        local selected = default or (options and options[1]) or "None"
        local open     = false
        local card, _  = GlassCard(58)
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

        local listH   = math.min(#options, 5) * 34 + 10
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
                Util.Spring(optBtn, {BackgroundTransparency = 0.65, TextColor3 = GLASS.AccentBlue}, SPRING.FAST)
            end)
            optBtn.MouseLeave:Connect(function()
                Util.Spring(optBtn, {BackgroundTransparency = 0.90, TextColor3 = GLASS.TextDim}, SPRING.FAST)
            end)
            optBtn.MouseButton1Click:Connect(function()
                selected      = opt
                selLbl.Text   = opt
                open          = false
                listFrame.Visible = false
                Util.Spring(arrow, {Rotation = 0}, SPRING.FAST)
                if callback then pcall(callback, opt) end
            end)
        end

        header.MouseButton1Click:Connect(function()
            open              = not open
            listFrame.Visible = open
            Util.Spring(arrow, {Rotation = open and 180 or 0}, SPRING.FAST)
            if open then
                Util.Spring(header, {BackgroundTransparency = 0.70}, SPRING.FAST)
            else
                Util.Spring(header, {BackgroundTransparency = 0.85}, SPRING.FAST)
            end
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
        local card, _ = GlassCard(72)
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
            Util.Spring(inputHolder, {BackgroundTransparency = 0.10}, SPRING.FAST)
            Util.Rim(inputHolder, GLASS.AccentBlue, 1.5, 0.25)
        end)
        tb.FocusLost:Connect(function(enter)
            Util.Spring(inputHolder, {BackgroundTransparency = 0.25}, SPRING.FAST)
            Util.Rim(inputHolder, GLASS.RimLight, 1, 0.55)
            if callback then pcall(callback, tb.Text, enter) end
        end)
        return tb
    end

    function Tab:AddLabel(text, style)
        local fr = Instance.new("Frame")
        fr.Name                   = "LabelRow"
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
        function obj:SetText(t) lbl.Text       = t end
        function obj:SetColor(c) lbl.TextColor3 = c end
        return obj
    end

    function Tab:AddColorPicker(pickerName, description, default, callback)
        local color     = default or Color3.fromRGB(100, 180, 255)
        local open      = false
        local pickerPanel
        local card, _   = GlassCard(58)
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
            pickerPanel = Instance.new("Frame")
            pickerPanel.Size                   = UDim2.new(1, 0, 0, 120)
            pickerPanel.Position               = UDim2.new(0, 0, 1, 6)
            pickerPanel.BackgroundColor3       = Color3.fromRGB(12, 15, 28)
            pickerPanel.BackgroundTransparency = 0.12
            pickerPanel.ZIndex                 = 25
            pickerPanel.BorderSizePixel        = 0
            pickerPanel.ClipsDescendants       = true
            pickerPanel.Parent                 = card
            Util.Round(pickerPanel, UDim.new(0, 14))
            Util.Rim(pickerPanel, GLASS.RimLight, 1, 0.30)

            local vals = {color.R * 255, color.G * 255, color.B * 255}
            local chs  = {
                {n="R", c=Color3.fromRGB(255, 80, 80),  i=1},
                {n="G", c=Color3.fromRGB(80, 220, 120), i=2},
                {n="B", c=Color3.fromRGB(80, 160, 255), i=3},
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
                tr.BackgroundTransparency = 0.2
                tr.ZIndex                 = 26
                tr.BorderSizePixel        = 0
                tr.Parent                 = row
                Util.Round(tr, UDim.new(1, 0))

                local fi = Instance.new("Frame")
                fi.Size                   = UDim2.new(vals[ch.i] / 255, 0, 1, 0)
                fi.BackgroundColor3       = ch.c
                fi.ZIndex                 = 27
                fi.BorderSizePixel        = 0
                fi.Parent                 = tr
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
                        Util.Spring(fi, {Size     = UDim2.new(rel, 0, 1, 0)},   SPRING.FAST)
                        Util.Spring(th, {Position = UDim2.new(rel, 0, 0.5, 0)}, SPRING.FAST)
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
                Util.Spring(card, {Size = UDim2.new(1, 0, 0, 188)}, SPRING.MORPH)
            else
                if pickerPanel then pcall(function() pickerPanel:Destroy() end) end
                Util.Spring(card, {Size = UDim2.new(1, 0, 0, 58)}, SPRING.MORPH)
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
        local card, _ = GlassCard(58)
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
            Util.Spring(pill, {BackgroundTransparency = 0.70}, SPRING.FAST)
        end)
        pill.MouseLeave:Connect(function()
            if not waiting then
                Util.Spring(pill, {BackgroundTransparency = 0.87}, SPRING.FAST)
            end
        end)
        pill.MouseButton1Click:Connect(function()
            if waiting then return end
            waiting       = true
            pill.Text     = "Press..."
            pill.TextColor3 = GLASS.AccentOrange
            Util.Rim(pill, GLASS.AccentOrange, 1, 0.30)

            local conn
            conn = UserInputService.InputBegan:Connect(function(inp, gpe)
                if gpe then return end
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    key           = inp.KeyCode
                    waiting       = false
                    pill.Text     = key.Name
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
    Util.LensingDistort(card, 9999)

    Util.Gradient(card, {
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(30, 35, 60)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(12, 15, 28)),
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

    local glowBar = Util.InnerGlow(accentBar, accent, 10001)
    glowBar.ImageTransparency = 0.45

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

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size                   = UDim2.new(0, 22, 0, 22)
    iconLbl.Position               = UDim2.new(1, -30, 0, 8)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text                   = ({info="i", success="ok", error="x", warning="!"})[notifType] or "i"
    iconLbl.TextColor3             = accent
    iconLbl.TextSize               = 12
    iconLbl.Font                   = Enum.Font.GothamBold
    iconLbl.ZIndex                 = 10001
    iconLbl.Parent                 = card

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
    Util.Spring(card, {Position = UDim2.new(0, 0, 0, 0)}, TweenInfo.new(0.6, Enum.EasingStyle.Spring, Enum.EasingDirection.Out))
    Util.Spring(prog, {Size = UDim2.new(0, 0, 0, 2)}, TweenInfo.new(duration, Enum.EasingStyle.Linear))

    task.delay(duration, function()
        Util.Spring(card, {Position = UDim2.new(1, 30, 0, 0)}, SPRING.CLOSE)
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
    DestroyGlassPart()
    if DepthOfField then
        DepthOfField.Enabled = false
    end
    if BloomEffect then
        BloomEffect.Enabled = false
    end
    if ColorCorrectionEffect then
        ColorCorrectionEffect.Enabled = false
    end
    if self.ScreenGui and self.ScreenGui.Parent then
        self.ScreenGui:Destroy()
    end
end

return LiquidGlass
