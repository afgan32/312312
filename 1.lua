-- LiquidGlass UI Library | v1.0.0
local LiquidGlass = {}
LiquidGlass.__index = LiquidGlass

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")

local THEME = {
    GlassBase        = Color3.fromRGB(255, 255, 255),
    GlassTint        = Color3.fromRGB(180, 210, 255),
    GlassEdge        = Color3.fromRGB(255, 255, 255),
    GlassShine       = Color3.fromRGB(220, 235, 255),
    BackdropDark     = Color3.fromRGB(10,  12,  20 ),
    BackdropMid      = Color3.fromRGB(18,  22,  38 ),
    AccentPrimary    = Color3.fromRGB(100, 180, 255),
    AccentSecondary  = Color3.fromRGB(180, 130, 255),
    AccentSuccess    = Color3.fromRGB(100, 230, 160),
    AccentDanger     = Color3.fromRGB(255, 100, 110),
    AccentWarning    = Color3.fromRGB(255, 200,  80),
    TextPrimary      = Color3.fromRGB(255, 255, 255),
    TextSecondary    = Color3.fromRGB(180, 195, 220),
    TextMuted        = Color3.fromRGB(120, 140, 170),
    GlassAlpha       = 0.72,
    EdgeAlpha        = 0.45,
    ShineAlpha       = 0.55,
    OverlayAlpha     = 0.60,
    TweenSpeed       = 0.35,
    TweenStyle       = Enum.EasingStyle.Quart,
    TweenDir         = Enum.EasingDirection.Out,
    CornerRadius     = UDim.new(0, 18),
    PanelCorner      = UDim.new(0, 22),
    ButtonCorner     = UDim.new(0, 14),
    SmallCorner      = UDim.new(0, 10),
}

local Util = {}

function Util.Tween(instance, props, duration, style, dir)
    local info = TweenInfo.new(
        duration or THEME.TweenSpeed,
        style    or THEME.TweenStyle,
        dir      or THEME.TweenDir
    )
    local t = TweenService:Create(instance, info, props)
    t:Play()
    return t
end

function Util.AddCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or THEME.CornerRadius
    c.Parent = parent
    return c
end

function Util.AddStroke(parent, color, thickness, transparency)
    local existing = parent:FindFirstChildOfClass("UIStroke")
    if existing then existing:Destroy() end
    local s = Instance.new("UIStroke")
    s.Color           = color        or THEME.GlassEdge
    s.Thickness       = thickness    or 1.2
    s.Transparency    = transparency or THEME.EdgeAlpha
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent          = parent
    return s
end

function Util.AddShadow(parent, size, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name                   = "Shadow"
    shadow.AnchorPoint            = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position               = UDim2.new(0.5, 0, 0.5, 4)
    shadow.Size                   = UDim2.new(1, size or 40, 1, size or 40)
    shadow.ZIndex                 = (parent.ZIndex or 1) - 1
    shadow.Image                  = "rbxassetid://6014261993"
    shadow.ImageColor3            = Color3.fromRGB(0, 5, 20)
    shadow.ImageTransparency      = transparency or 0.5
    shadow.ScaleType              = Enum.ScaleType.Slice
    shadow.SliceCenter            = Rect.new(49, 49, 450, 450)
    shadow.Parent                 = parent
    return shadow
end

function Util.GlassPanel(parent, size, position, name, zindex)
    local frame = Instance.new("Frame")
    frame.Name                   = name or "GlassPanel"
    frame.Size                   = size or UDim2.new(0, 300, 0, 200)
    frame.Position               = position or UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3       = THEME.GlassTint
    frame.BackgroundTransparency = THEME.GlassAlpha
    frame.BorderSizePixel        = 0
    frame.ZIndex                 = zindex or 10
    frame.ClipsDescendants       = true
    frame.Parent                 = parent

    Util.AddCorner(frame, THEME.PanelCorner)
    Util.AddStroke(frame, THEME.GlassEdge, 1.2, 0.35)

    local shine = Instance.new("Frame")
    shine.Name                   = "InnerShine"
    shine.Size                   = UDim2.new(0.85, 0, 0, 1.5)
    shine.Position               = UDim2.new(0.075, 0, 0, 3)
    shine.BackgroundColor3       = THEME.GlassShine
    shine.BackgroundTransparency = THEME.ShineAlpha
    shine.BorderSizePixel        = 0
    shine.ZIndex                 = frame.ZIndex + 1
    shine.Parent                 = frame
    Util.AddCorner(shine, UDim.new(1, 0))

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(200, 220, 255)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(150, 180, 255)),
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   0.70),
        NumberSequenceKeypoint.new(0.5, 0.80),
        NumberSequenceKeypoint.new(1,   0.88),
    })
    gradient.Rotation = 135
    gradient.Parent   = frame

    return frame
end

local function CreateGlintLayer(parent, zindex)
    local glint = Instance.new("Frame")
    glint.Name                   = "GlintLayer"
    glint.Size                   = UDim2.new(1, 0, 1, 0)
    glint.BackgroundTransparency = 1
    glint.ZIndex                 = zindex or 20
    glint.BorderSizePixel        = 0
    glint.Parent                 = parent

    local orb = Instance.new("ImageLabel")
    orb.Name                  = "GlintOrb"
    orb.Size                  = UDim2.new(0, 120, 0, 60)
    orb.AnchorPoint           = Vector2.new(0.5, 0.5)
    orb.Position              = UDim2.new(0.3, 0, 0.25, 0)
    orb.BackgroundTransparency = 1
    orb.Image                 = "rbxassetid://6014261993"
    orb.ImageColor3           = Color3.fromRGB(255, 255, 255)
    orb.ImageTransparency     = 0.75
    orb.ScaleType             = Enum.ScaleType.Slice
    orb.SliceCenter           = Rect.new(49, 49, 450, 450)
    orb.ZIndex                = glint.ZIndex + 1
    orb.Parent                = glint

    return glint, orb
end

local function AttachGlintToMouse(panel, glintOrb)
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not panel or not panel.Parent then
            connection:Disconnect()
            return
        end
        local mousePos = UserInputService:GetMouseLocation()
        local absPos   = panel.AbsolutePosition
        local absSize  = panel.AbsoluteSize
        local relX     = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
        local relY     = math.clamp((mousePos.Y - absPos.Y) / absSize.Y, 0, 1)
        local targetX  = 0.1 + relX * 0.8
        local targetY  = 0.05 + relY * 0.5
        local curPos   = glintOrb.Position
        local smoothed = UDim2.new(
            curPos.X.Scale + (targetX - curPos.X.Scale) * 0.08, 0,
            curPos.Y.Scale + (targetY - curPos.Y.Scale) * 0.08, 0
        )
        glintOrb.Position = smoothed
        local dist = math.sqrt((relX - 0.5)^2 + (relY - 0.5)^2)
        glintOrb.ImageTransparency = 0.60 + dist * 0.30
    end)
    return connection
end

local NotifHolder

local function EnsureNotifHolder(screenGui)
    if NotifHolder and NotifHolder.Parent then return NotifHolder end
    NotifHolder = Instance.new("Frame")
    NotifHolder.Name                   = "NotifHolder"
    NotifHolder.Size                   = UDim2.new(0, 320, 1, 0)
    NotifHolder.Position               = UDim2.new(1, -335, 0, 0)
    NotifHolder.BackgroundTransparency = 1
    NotifHolder.ZIndex                 = 9999
    NotifHolder.Parent                 = screenGui

    local layout = Instance.new("UIListLayout")
    layout.SortOrder             = Enum.SortOrder.LayoutOrder
    layout.Padding               = UDim.new(0, 10)
    layout.VerticalAlignment     = Enum.VerticalAlignment.Bottom
    layout.HorizontalAlignment   = Enum.HorizontalAlignment.Center
    layout.Parent                = NotifHolder

    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 20)
    padding.Parent        = NotifHolder

    return NotifHolder
end

function LiquidGlass.new(title, subtitle)
    local self = setmetatable({}, LiquidGlass)

    local ok, gui = pcall(function()
        local g = Instance.new("ScreenGui")
        g.Name             = "LiquidGlassUI_" .. tostring(math.random(1000, 9999))
        g.ResetOnSpawn     = false
        g.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
        g.IgnoreGuiInset   = true
        g.Parent           = CoreGui
        return g
    end)

    if not ok then
        gui = Instance.new("ScreenGui")
        gui.Name           = "LiquidGlassUI"
        gui.ResetOnSpawn   = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.IgnoreGuiInset = true
        gui.Parent         = Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    self.ScreenGui   = gui
    self.Connections = {}
    self.Tabs        = {}
    self.ActiveTab   = nil
    self.Visible     = true

    local backdrop = Instance.new("Frame")
    backdrop.Name                   = "Backdrop"
    backdrop.Size                   = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3       = THEME.BackdropDark
    backdrop.BackgroundTransparency = 0.45
    backdrop.ZIndex                 = 1
    backdrop.BorderSizePixel        = 0
    backdrop.Parent                 = gui

    local backdropGrad = Instance.new("UIGradient")
    backdropGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, THEME.BackdropDark),
        ColorSequenceKeypoint.new(1, THEME.BackdropMid),
    })
    backdropGrad.Rotation = 45
    backdropGrad.Parent   = backdrop

    local window = Util.GlassPanel(
        gui,
        UDim2.new(0, 680, 0, 480),
        UDim2.new(0.5, -340, 0.5, -240),
        "MainWindow",
        10
    )
    self.Window = window

    Util.AddShadow(window, 60, 0.35)

    local _, glintOrb = CreateGlintLayer(window, 11)
    table.insert(self.Connections, AttachGlintToMouse(window, glintOrb))

    local titleBar = Instance.new("Frame")
    titleBar.Name                   = "TitleBar"
    titleBar.Size                   = UDim2.new(1, 0, 0, 58)
    titleBar.BackgroundColor3       = THEME.GlassTint
    titleBar.BackgroundTransparency = 0.80
    titleBar.ZIndex                 = 12
    titleBar.BorderSizePixel        = 0
    titleBar.Parent                 = window

    local titleBarGrad = Instance.new("UIGradient")
    titleBarGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 200, 255)),
    })
    titleBarGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.70),
        NumberSequenceKeypoint.new(1, 0.90),
    })
    titleBarGrad.Rotation = 90
    titleBarGrad.Parent   = titleBar

    local separator = Instance.new("Frame")
    separator.Name                   = "Separator"
    separator.Size                   = UDim2.new(1, 0, 0, 1)
    separator.Position               = UDim2.new(0, 0, 1, -1)
    separator.BackgroundColor3       = THEME.GlassEdge
    separator.BackgroundTransparency = 0.60
    separator.ZIndex                 = 13
    separator.BorderSizePixel        = 0
    separator.Parent                 = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name                   = "Title"
    titleLabel.Size                   = UDim2.new(1, -120, 1, 0)
    titleLabel.Position               = UDim2.new(0, 18, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text                   = title or "LiquidGlass UI"
    titleLabel.TextColor3             = THEME.TextPrimary
    titleLabel.TextSize               = 17
    titleLabel.Font                   = Enum.Font.GothamBold
    titleLabel.TextXAlignment         = Enum.TextXAlignment.Left
    titleLabel.ZIndex                 = 13
    titleLabel.Parent                 = titleBar

    local subLabel = Instance.new("TextLabel")
    subLabel.Name                   = "Subtitle"
    subLabel.Size                   = UDim2.new(1, -120, 0, 18)
    subLabel.Position               = UDim2.new(0, 18, 0, 34)
    subLabel.BackgroundTransparency = 1
    subLabel.Text                   = subtitle or "Liquid Glass Theme"
    subLabel.TextColor3             = THEME.TextMuted
    subLabel.TextSize               = 11
    subLabel.Font                   = Enum.Font.Gotham
    subLabel.TextXAlignment         = Enum.TextXAlignment.Left
    subLabel.ZIndex                 = 13
    subLabel.Parent                 = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name                   = "CloseButton"
    closeBtn.Size                   = UDim2.new(0, 28, 0, 28)
    closeBtn.Position               = UDim2.new(1, -42, 0.5, -14)
    closeBtn.BackgroundColor3       = THEME.AccentDanger
    closeBtn.BackgroundTransparency = 0.30
    closeBtn.Text                   = "x"
    closeBtn.TextColor3             = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize               = 13
    closeBtn.Font                   = Enum.Font.GothamBold
    closeBtn.ZIndex                 = 14
    closeBtn.BorderSizePixel        = 0
    closeBtn.Parent                 = titleBar
    Util.AddCorner(closeBtn, UDim.new(1, 0))
    Util.AddStroke(closeBtn, Color3.fromRGB(255, 100, 110), 1, 0.50)

    closeBtn.MouseEnter:Connect(function()
        Util.Tween(closeBtn, {BackgroundTransparency = 0.0}, 0.2)
    end)
    closeBtn.MouseLeave:Connect(function()
        Util.Tween(closeBtn, {BackgroundTransparency = 0.30}, 0.2)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        self:Toggle(false)
    end)

    local minBtn = Instance.new("TextButton")
    minBtn.Name                   = "MinButton"
    minBtn.Size                   = UDim2.new(0, 28, 0, 28)
    minBtn.Position               = UDim2.new(1, -78, 0.5, -14)
    minBtn.BackgroundColor3       = THEME.AccentWarning
    minBtn.BackgroundTransparency = 0.30
    minBtn.Text                   = "-"
    minBtn.TextColor3             = Color3.fromRGB(255, 255, 255)
    minBtn.TextSize               = 13
    minBtn.Font                   = Enum.Font.GothamBold
    minBtn.ZIndex                 = 14
    minBtn.BorderSizePixel        = 0
    minBtn.Parent                 = titleBar
    Util.AddCorner(minBtn, UDim.new(1, 0))
    Util.AddStroke(minBtn, THEME.AccentWarning, 1, 0.50)

    minBtn.MouseEnter:Connect(function()
        Util.Tween(minBtn, {BackgroundTransparency = 0.0}, 0.2)
    end)
    minBtn.MouseLeave:Connect(function()
        Util.Tween(minBtn, {BackgroundTransparency = 0.30}, 0.2)
    end)

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Util.Tween(window, {Size = UDim2.new(0, 680, 0, 58)}, 0.4)
        else
            Util.Tween(window, {Size = UDim2.new(0, 680, 0, 480)}, 0.4)
        end
    end)

    do
        local dragging, dragStart, startPos = false, nil, nil
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging  = true
                dragStart = input.Position
                startPos  = window.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                window.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    local sidebar = Util.GlassPanel(
        window,
        UDim2.new(0, 160, 1, -58),
        UDim2.new(0, 0, 0, 58),
        "Sidebar",
        12
    )
    sidebar.BackgroundTransparency = 0.85
    sidebar.ClipsDescendants       = true

    local sideEdge = Instance.new("Frame")
    sideEdge.Name                   = "SideEdge"
    sideEdge.Size                   = UDim2.new(0, 1, 1, 0)
    sideEdge.Position               = UDim2.new(1, -1, 0, 0)
    sideEdge.BackgroundColor3       = THEME.GlassEdge
    sideEdge.BackgroundTransparency = 0.55
    sideEdge.ZIndex                 = 13
    sideEdge.BorderSizePixel        = 0
    sideEdge.Parent                 = sidebar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding   = UDim.new(0, 6)
    tabLayout.Parent    = sidebar

    local tabPad = Instance.new("UIPadding")
    tabPad.PaddingTop   = UDim.new(0, 12)
    tabPad.PaddingLeft  = UDim.new(0, 10)
    tabPad.PaddingRight = UDim.new(0, 10)
    tabPad.Parent       = sidebar

    local contentArea = Instance.new("ScrollingFrame")
    contentArea.Name                   = "ContentArea"
    contentArea.Size                   = UDim2.new(1, -168, 1, -68)
    contentArea.Position               = UDim2.new(0, 164, 0, 62)
    contentArea.BackgroundTransparency = 1
    contentArea.ZIndex                 = 12
    contentArea.BorderSizePixel        = 0
    contentArea.ScrollBarThickness     = 4
    contentArea.ScrollBarImageColor3   = THEME.AccentPrimary
    contentArea.CanvasSize             = UDim2.new(0, 0, 0, 0)
    contentArea.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    contentArea.Parent                 = window

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding   = UDim.new(0, 10)
    contentLayout.Parent    = contentArea

    local contentPad = Instance.new("UIPadding")
    contentPad.PaddingTop    = UDim.new(0, 8)
    contentPad.PaddingBottom = UDim.new(0, 16)
    contentPad.PaddingLeft   = UDim.new(0, 10)
    contentPad.PaddingRight  = UDim.new(0, 16)
    contentPad.Parent        = contentArea

    self.Sidebar     = sidebar
    self.ContentArea = contentArea
    self.NotifGui    = EnsureNotifHolder(gui)

    window.Size     = UDim2.new(0, 0, 0, 0)
    window.Position = UDim2.new(0.5, 0, 0.5, 0)
    Util.Tween(window, {
        Size     = UDim2.new(0, 680, 0, 480),
        Position = UDim2.new(0.5, -340, 0.5, -240),
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    return self
end

function LiquidGlass:Toggle(state)
    self.Visible = (state ~= nil) and state or (not self.Visible)
    if self.Visible then
        self.Window.Visible = true
        Util.Tween(self.Window, {
            Size     = UDim2.new(0, 680, 0, 480),
            Position = UDim2.new(0.5, -340, 0.5, -240),
        }, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        local t = Util.Tween(self.Window, {
            Size     = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
        }, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        t.Completed:Connect(function()
            self.Window.Visible = false
        end)
    end
end

function LiquidGlass:SetKeybind(key)
    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == key then
            self:Toggle()
        end
    end))
end

function LiquidGlass:AddTab(name, icon)
    local tabIndex = #self.Tabs + 1

    local tabBtn = Instance.new("TextButton")
    tabBtn.Name                   = "Tab_" .. name
    tabBtn.Size                   = UDim2.new(1, 0, 0, 42)
    tabBtn.BackgroundColor3       = THEME.GlassTint
    tabBtn.BackgroundTransparency = 0.85
    tabBtn.Text                   = ""
    tabBtn.ZIndex                 = 13
    tabBtn.BorderSizePixel        = 0
    tabBtn.LayoutOrder            = tabIndex
    tabBtn.Parent                 = self.Sidebar
    Util.AddCorner(tabBtn, THEME.ButtonCorner)

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name                   = "Icon"
    iconLabel.Size                   = UDim2.new(0, 24, 0, 24)
    iconLabel.Position               = UDim2.new(0, 10, 0.5, -12)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text                   = icon or "o"
    iconLabel.TextColor3             = THEME.TextSecondary
    iconLabel.TextSize               = 16
    iconLabel.Font                   = Enum.Font.GothamBold
    iconLabel.ZIndex                 = 14
    iconLabel.Parent                 = tabBtn

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name                   = "Label"
    nameLabel.Size                   = UDim2.new(1, -42, 1, 0)
    nameLabel.Position               = UDim2.new(0, 40, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text                   = name
    nameLabel.TextColor3             = THEME.TextSecondary
    nameLabel.TextSize               = 13
    nameLabel.Font                   = Enum.Font.Gotham
    nameLabel.TextXAlignment         = Enum.TextXAlignment.Left
    nameLabel.ZIndex                 = 14
    nameLabel.Parent                 = tabBtn

    local indicator = Instance.new("Frame")
    indicator.Name                   = "Indicator"
    indicator.Size                   = UDim2.new(0, 3, 0.6, 0)
    indicator.Position               = UDim2.new(0, 0, 0.2, 0)
    indicator.BackgroundColor3       = THEME.AccentPrimary
    indicator.BackgroundTransparency = 1
    indicator.ZIndex                 = 15
    indicator.BorderSizePixel        = 0
    indicator.Parent                 = tabBtn
    Util.AddCorner(indicator, UDim.new(1, 0))

    local contentFrame = Instance.new("Frame")
    contentFrame.Name              = "Content_" .. name
    contentFrame.Size              = UDim2.new(1, 0, 0, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.AutomaticSize    = Enum.AutomaticSize.Y
    contentFrame.Visible          = false
    contentFrame.ZIndex           = 12
    contentFrame.BorderSizePixel  = 0
    contentFrame.LayoutOrder      = tabIndex
    contentFrame.Parent           = self.ContentArea

    local itemLayout = Instance.new("UIListLayout")
    itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
    itemLayout.Padding   = UDim.new(0, 8)
    itemLayout.Parent    = contentFrame

    local tabData = {
        Name      = name,
        Button    = tabBtn,
        Content   = contentFrame,
        Indicator = indicator,
        Icon      = iconLabel,
        Label     = nameLabel,
        Index     = tabIndex,
    }
    table.insert(self.Tabs, tabData)

    local selfRef = self

    local function ActivateTab()
        for _, t in ipairs(selfRef.Tabs) do
            t.Content.Visible = false
            Util.Tween(t.Button,    {BackgroundTransparency = 0.85}, 0.2)
            Util.Tween(t.Indicator, {BackgroundTransparency = 1.0},  0.2)
            Util.Tween(t.Label,     {TextColor3 = THEME.TextSecondary}, 0.2)
            Util.Tween(t.Icon,      {TextColor3 = THEME.TextSecondary}, 0.2)
        end
        contentFrame.Visible = true
        selfRef.ActiveTab    = tabData
        Util.Tween(tabBtn,    {BackgroundTransparency = 0.55}, 0.2)
        Util.Tween(indicator, {BackgroundTransparency = 0.0},  0.25)
        Util.Tween(nameLabel, {TextColor3 = THEME.AccentPrimary}, 0.2)
        Util.Tween(iconLabel, {TextColor3 = THEME.AccentPrimary}, 0.2)
        Util.AddStroke(tabBtn, THEME.AccentPrimary, 1.0, 0.50)
    end

    tabBtn.MouseEnter:Connect(function()
        if selfRef.ActiveTab ~= tabData then
            Util.Tween(tabBtn, {BackgroundTransparency = 0.72}, 0.15)
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if selfRef.ActiveTab ~= tabData then
            Util.Tween(tabBtn, {BackgroundTransparency = 0.85}, 0.15)
        end
    end)
    tabBtn.MouseButton1Click:Connect(ActivateTab)

    if tabIndex == 1 then
        ActivateTab()
    end

    local Tab = {}
    Tab._frame = contentFrame

    function Tab:AddSection(sectionName)
        local order = #contentFrame:GetChildren()
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Name              = "Section_" .. sectionName
        sectionFrame.Size              = UDim2.new(1, 0, 0, 30)
        sectionFrame.BackgroundTransparency = 1
        sectionFrame.ZIndex           = 13
        sectionFrame.LayoutOrder      = order
        sectionFrame.Parent           = contentFrame

        local line = Instance.new("Frame")
        line.Size                   = UDim2.new(0.35, 0, 0, 1)
        line.Position               = UDim2.new(0, 0, 0.5, 0)
        line.BackgroundColor3       = THEME.TextMuted
        line.BackgroundTransparency = 0.5
        line.ZIndex                 = 14
        line.BorderSizePixel        = 0
        line.Parent                 = sectionFrame

        local label = Instance.new("TextLabel")
        label.Size                   = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text                   = "  " .. sectionName
        label.TextColor3             = THEME.TextMuted
        label.TextSize               = 11
        label.Font                   = Enum.Font.GothamBold
        label.TextXAlignment         = Enum.TextXAlignment.Left
        label.ZIndex                 = 14
        label.Parent                 = sectionFrame
    end

    function Tab:AddButton(btnName, description, callback)
        local order     = #contentFrame:GetChildren()
        local container = Util.GlassPanel(
            contentFrame,
            UDim2.new(1, 0, 0, 52),
            UDim2.new(0, 0, 0, 0),
            "Btn_" .. btnName,
            13
        )
        container.LayoutOrder = order
        container.Position    = UDim2.new(0, 0, 0, 0)

        local label = Instance.new("TextLabel")
        label.Size                   = UDim2.new(1, -100, 0, 22)
        label.Position               = UDim2.new(0, 14, 0, 8)
        label.BackgroundTransparency = 1
        label.Text                   = btnName
        label.TextColor3             = THEME.TextPrimary
        label.TextSize               = 14
        label.Font                   = Enum.Font.GothamSemibold
        label.TextXAlignment         = Enum.TextXAlignment.Left
        label.ZIndex                 = 14
        label.Parent                 = container

        if description then
            local desc = Instance.new("TextLabel")
            desc.Size                   = UDim2.new(1, -100, 0, 16)
            desc.Position               = UDim2.new(0, 14, 0, 30)
            desc.BackgroundTransparency = 1
            desc.Text                   = description
            desc.TextColor3             = THEME.TextMuted
            desc.TextSize               = 11
            desc.Font                   = Enum.Font.Gotham
            desc.TextXAlignment         = Enum.TextXAlignment.Left
            desc.ZIndex                 = 14
            desc.Parent                 = container
        end

        local execBtn = Instance.new("TextButton")
        execBtn.Name                   = "ExecBtn"
        execBtn.Size                   = UDim2.new(0, 72, 0, 30)
        execBtn.Position               = UDim2.new(1, -84, 0.5, -15)
        execBtn.BackgroundColor3       = THEME.AccentPrimary
        execBtn.BackgroundTransparency = 0.35
        execBtn.Text                   = "Execute"
        execBtn.TextColor3             = Color3.fromRGB(255, 255, 255)
        execBtn.TextSize               = 12
        execBtn.Font                   = Enum.Font.GothamSemibold
        execBtn.ZIndex                 = 15
        execBtn.BorderSizePixel        = 0
        execBtn.Parent                 = container
        Util.AddCorner(execBtn, THEME.SmallCorner)
        Util.AddStroke(execBtn, THEME.AccentPrimary, 1, 0.45)

        execBtn.MouseEnter:Connect(function()
            Util.Tween(execBtn, {BackgroundTransparency = 0.0, Size = UDim2.new(0, 76, 0, 32)}, 0.15)
        end)
        execBtn.MouseLeave:Connect(function()
            Util.Tween(execBtn, {BackgroundTransparency = 0.35, Size = UDim2.new(0, 72, 0, 30)}, 0.15)
        end)
        execBtn.MouseButton1Click:Connect(function()
            Util.Tween(execBtn, {BackgroundTransparency = 0.0}, 0.05)
            task.delay(0.1, function()
                Util.Tween(execBtn, {BackgroundTransparency = 0.35}, 0.2)
            end)
            if callback then pcall(callback) end
        end)
    end

    function Tab:AddToggle(toggleName, description, default, callback)
        local order   = #contentFrame:GetChildren()
        local enabled = default or false

        local container = Util.GlassPanel(
            contentFrame,
            UDim2.new(1, 0, 0, 52),
            UDim2.new(0, 0, 0, 0),
            "Toggle_" .. toggleName,
            13
        )
        container.LayoutOrder = order
        container.Position    = UDim2.new(0, 0, 0, 0)

        local label = Instance.new("TextLabel")
        label.Size                   = UDim2.new(1, -80, 0, 22)
        label.Position               = UDim2.new(0, 14, 0, 8)
        label.BackgroundTransparency = 1
        label.Text                   = toggleName
        label.TextColor3             = THEME.TextPrimary
        label.TextSize               = 14
        label.Font                   = Enum.Font.GothamSemibold
        label.TextXAlignment         = Enum.TextXAlignment.Left
        label.ZIndex                 = 14
        label.Parent                 = container

        if description then
            local desc = Instance.new("TextLabel")
            desc.Size                   = UDim2.new(1, -80, 0, 16)
            desc.Position               = UDim2.new(0, 14, 0, 30)
            desc.BackgroundTransparency = 1
            desc.Text                   = description
            desc.TextColor3             = THEME.TextMuted
            desc.TextSize               = 11
            desc.Font                   = Enum.Font.Gotham
            desc.TextXAlignment         = Enum.TextXAlignment.Left
            desc.ZIndex                 = 14
            desc.Parent                 = container
        end

        local track = Instance.new("Frame")
        track.Name                   = "Track"
        track.Size                   = UDim2.new(0, 46, 0, 26)
        track.Position               = UDim2.new(1, -60, 0.5, -13)
        track.BackgroundColor3       = enabled and THEME.AccentPrimary or THEME.BackdropMid
        track.BackgroundTransparency = enabled and 0.2 or 0.5
        track.ZIndex                 = 15
        track.BorderSizePixel        = 0
        track.Parent                 = container
        Util.AddCorner(track, UDim.new(1, 0))
        Util.AddStroke(track, enabled and THEME.AccentPrimary or THEME.TextMuted, 1, 0.5)

        local knob = Instance.new("Frame")
        knob.Name                   = "Knob"
        knob.Size                   = UDim2.new(0, 20, 0, 20)
        knob.Position               = enabled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        knob.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
        knob.BackgroundTransparency = 0
        knob.ZIndex                 = 16
        knob.BorderSizePixel        = 0
        knob.Parent                 = track
        Util.AddCorner(knob, UDim.new(1, 0))

        local function UpdateToggle()
            if enabled then
                Util.Tween(track, {BackgroundColor3 = THEME.AccentPrimary, BackgroundTransparency = 0.2}, 0.25)
                Util.Tween(knob,  {Position = UDim2.new(1, -23, 0.5, -10)}, 0.25, Enum.EasingStyle.Back)
            else
                Util.Tween(track, {BackgroundColor3 = THEME.BackdropMid, BackgroundTransparency = 0.5}, 0.25)
                Util.Tween(knob,  {Position = UDim2.new(0, 3, 0.5, -10)}, 0.25, Enum.EasingStyle.Back)
            end
            if callback then pcall(callback, enabled) end
        end

        local clickRegion = Instance.new("TextButton")
        clickRegion.Size                   = UDim2.new(1, 0, 1, 0)
        clickRegion.BackgroundTransparency = 1
        clickRegion.Text                   = ""
        clickRegion.ZIndex                 = 17
        clickRegion.Parent                 = container
        clickRegion.MouseButton1Click:Connect(function()
            enabled = not enabled
            UpdateToggle()
        end)

        local toggleObj  = {Value = enabled}
        function toggleObj:Set(val)
            enabled          = val
            toggleObj.Value  = val
            UpdateToggle()
        end
        return toggleObj
    end

    function Tab:AddSlider(sliderName, description, min, max, default, callback)
        local order = #contentFrame:GetChildren()
        local value = math.clamp(default or min, min, max)

        local container = Util.GlassPanel(
            contentFrame,
            UDim2.new(1, 0, 0, 65),
            UDim2.new(0, 0, 0, 0),
            "Slider_" .. sliderName,
            13
        )
        container.LayoutOrder = order
        container.Position    = UDim2.new(0, 0, 0, 0)

        local label = Instance.new("TextLabel")
        label.Size                   = UDim2.new(1, -80, 0, 20)
        label.Position               = UDim2.new(0, 14, 0, 8)
        label.BackgroundTransparency = 1
        label.Text                   = sliderName
        label.TextColor3             = THEME.TextPrimary
        label.TextSize               = 14
        label.Font                   = Enum.Font.GothamSemibold
        label.TextXAlignment         = Enum.TextXAlignment.Left
        label.ZIndex                 = 14
        label.Parent                 = container

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size                   = UDim2.new(0, 60, 0, 20)
        valueLabel.Position               = UDim2.new(1, -72, 0, 8)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text                   = tostring(value)
        valueLabel.TextColor3             = THEME.AccentPrimary
        valueLabel.TextSize               = 14
        valueLabel.Font                   = Enum.Font.GothamBold
        valueLabel.TextXAlignment         = Enum.TextXAlignment.Right
        valueLabel.ZIndex                 = 14
        valueLabel.Parent                 = container

        if description then
            local desc = Instance.new("TextLabel")
            desc.Size                   = UDim2.new(1, -20, 0, 14)
            desc.Position               = UDim2.new(0, 14, 0, 27)
            desc.BackgroundTransparency = 1
            desc.Text                   = description
            desc.TextColor3             = THEME.TextMuted
            desc.TextSize               = 10
            desc.Font                   = Enum.Font.Gotham
            desc.TextXAlignment         = Enum.TextXAlignment.Left
            desc.ZIndex                 = 14
            desc.Parent                 = container
        end

        local sliderTrack = Instance.new("Frame")
        sliderTrack.Name                   = "Track"
        sliderTrack.Size                   = UDim2.new(1, -28, 0, 6)
        sliderTrack.Position               = UDim2.new(0, 14, 1, -18)
        sliderTrack.BackgroundColor3       = THEME.BackdropMid
        sliderTrack.BackgroundTransparency = 0.3
        sliderTrack.ZIndex                 = 14
        sliderTrack.BorderSizePixel        = 0
        sliderTrack.Parent                 = container
        Util.AddCorner(sliderTrack, UDim.new(1, 0))

        local fill = Instance.new("Frame")
        fill.Name                   = "Fill"
        fill.Size                   = UDim2.new((value - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3       = THEME.AccentPrimary
        fill.BackgroundTransparency = 0.1
        fill.ZIndex                 = 15
        fill.BorderSizePixel        = 0
        fill.Parent                 = sliderTrack
        Util.AddCorner(fill, UDim.new(1, 0))

        local fillGrad = Instance.new("UIGradient")
        fillGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, THEME.AccentPrimary),
            ColorSequenceKeypoint.new(1, THEME.AccentSecondary),
        })
        fillGrad.Parent = fill

        local thumb = Instance.new("Frame")
        thumb.Name                   = "Thumb"
        thumb.Size                   = UDim2.new(0, 16, 0, 16)
        thumb.AnchorPoint            = Vector2.new(0.5, 0.5)
        thumb.Position               = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
        thumb.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
        thumb.ZIndex                 = 16
        thumb.BorderSizePixel        = 0
        thumb.Parent                 = sliderTrack
        Util.AddCorner(thumb, UDim.new(1, 0))
        Util.AddStroke(thumb, THEME.AccentPrimary, 2, 0.2)

        local draggingSlider = false
        sliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = true
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                local absPos  = sliderTrack.AbsolutePosition
                local absSize = sliderTrack.AbsoluteSize
                local rel     = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
                value         = math.floor(min + rel * (max - min))
                valueLabel.Text = tostring(value)
                Util.Tween(fill,  {Size     = UDim2.new(rel, 0, 1, 0)},          0.05)
                Util.Tween(thumb, {Position = UDim2.new(rel, 0, 0.5, 0)},        0.05)
                if callback then pcall(callback, value) end
            end
        end)

        local sliderObj = {Value = value}
        function sliderObj:Set(val)
            val             = math.clamp(val, min, max)
            value           = val
            sliderObj.Value = val
            local rel       = (val - min) / (max - min)
            valueLabel.Text = tostring(val)
            Util.Tween(fill,  {Size     = UDim2.new(rel, 0, 1, 0)},   0.15)
            Util.Tween(thumb, {Position = UDim2.new(rel, 0, 0.5, 0)}, 0.15)
            if callback then pcall(callback, val) end
        end
        return sliderObj
    end

    function Tab:AddDropdown(dropName, description, options, default, callback)
        local order    = #contentFrame:GetChildren()
        local selected = default or (options and options[1]) or "None"
        local open     = false

        local container = Util.GlassPanel(
            contentFrame,
            UDim2.new(1, 0, 0, 52),
            UDim2.new(0, 0, 0, 0),
            "Drop_" .. dropName,
            13
        )
        container.LayoutOrder      = order
        container.Position         = UDim2.new(0, 0, 0, 0)
        container.ClipsDescendants = false
        container.ZIndex           = 20

        local label = Instance.new("TextLabel")
        label.Size                   = UDim2.new(1, -140, 0, 22)
        label.Position               = UDim2.new(0, 14, 0, 8)
        label.BackgroundTransparency = 1
        label.Text                   = dropName
        label.TextColor3             = THEME.TextPrimary
        label.TextSize               = 14
        label.Font                   = Enum.Font.GothamSemibold
        label.TextXAlignment         = Enum.TextXAlignment.Left
        label.ZIndex                 = 21
        label.Parent                 = container

        if description then
            local desc = Instance.new("TextLabel")
            desc.Size                   = UDim2.new(1, -140, 0, 16)
            desc.Position               = UDim2.new(0, 14, 0, 30)
            desc.BackgroundTransparency = 1
            desc.Text                   = description
            desc.TextColor3             = THEME.TextMuted
            desc.TextSize               = 11
            desc.Font                   = Enum.Font.Gotham
            desc.TextXAlignment         = Enum.TextXAlignment.Left
            desc.ZIndex                 = 21
            desc.Parent                 = container
        end

        local header = Instance.new("TextButton")
        header.Name                   = "DropHeader"
        header.Size                   = UDim2.new(0, 120, 0, 30)
        header.Position               = UDim2.new(1, -132, 0.5, -15)
        header.BackgroundColor3       = THEME.GlassTint
        header.BackgroundTransparency = 0.65
        header.Text                   = ""
        header.ZIndex                 = 22
        header.BorderSizePixel        = 0
        header.Parent                 = container
        Util.AddCorner(header, THEME.SmallCorner)
        Util.AddStroke(header, THEME.GlassEdge, 1, 0.45)

        local selectedLabel = Instance.new("TextLabel")
        selectedLabel.Size                   = UDim2.new(1, -24, 1, 0)
        selectedLabel.Position               = UDim2.new(0, 8, 0, 0)
        selectedLabel.BackgroundTransparency = 1
        selectedLabel.Text                   = selected
        selectedLabel.TextColor3             = THEME.AccentPrimary
        selectedLabel.TextSize               = 12
        selectedLabel.Font                   = Enum.Font.GothamSemibold
        selectedLabel.TextXAlignment         = Enum.TextXAlignment.Left
        selectedLabel.ZIndex                 = 23
        selectedLabel.Parent                 = header

        local arrow = Instance.new("TextLabel")
        arrow.Size                   = UDim2.new(0, 20, 1, 0)
        arrow.Position               = UDim2.new(1, -22, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text                   = "v"
        arrow.TextColor3             = THEME.TextMuted
        arrow.TextSize               = 14
        arrow.Font                   = Enum.Font.GothamBold
        arrow.ZIndex                 = 23
        arrow.Parent                 = header

        local optionHeight = 32
        local listFrame    = Util.GlassPanel(
            container,
            UDim2.new(0, 120, 0, #options * optionHeight + 8),
            UDim2.new(1, -132, 0, 52),
            "DropList",
            30
        )
        listFrame.Visible          = false
        listFrame.ClipsDescendants = true

        local optLayout = Instance.new("UIListLayout")
        optLayout.SortOrder = Enum.SortOrder.LayoutOrder
        optLayout.Padding   = UDim.new(0, 2)
        optLayout.Parent    = listFrame

        local optPad = Instance.new("UIPadding")
        optPad.PaddingTop   = UDim.new(0, 4)
        optPad.PaddingLeft  = UDim.new(0, 4)
        optPad.PaddingRight = UDim.new(0, 4)
        optPad.Parent       = listFrame

        for i, opt in ipairs(options or {}) do
            local optBtn = Instance.new("TextButton")
            optBtn.Name                   = "Opt_" .. tostring(i)
            optBtn.Size                   = UDim2.new(1, 0, 0, optionHeight - 4)
            optBtn.BackgroundColor3       = THEME.GlassTint
            optBtn.BackgroundTransparency = 0.80
            optBtn.Text                   = opt
            optBtn.TextColor3             = THEME.TextSecondary
            optBtn.TextSize               = 12
            optBtn.Font                   = Enum.Font.Gotham
            optBtn.ZIndex                 = 31
            optBtn.BorderSizePixel        = 0
            optBtn.LayoutOrder            = i
            optBtn.Parent                 = listFrame
            Util.AddCorner(optBtn, THEME.SmallCorner)

            optBtn.MouseEnter:Connect(function()
                Util.Tween(optBtn, {BackgroundTransparency = 0.50, TextColor3 = THEME.AccentPrimary}, 0.15)
            end)
            optBtn.MouseLeave:Connect(function()
                if selected ~= opt then
                    Util.Tween(optBtn, {BackgroundTransparency = 0.80, TextColor3 = THEME.TextSecondary}, 0.15)
                end
            end)
            optBtn.MouseButton1Click:Connect(function()
                selected            = opt
                selectedLabel.Text  = opt
                open                = false
                listFrame.Visible   = false
                Util.Tween(arrow, {Rotation = 0}, 0.2)
                if callback then pcall(callback, opt) end
            end)
        end

        header.MouseButton1Click:Connect(function()
            open              = not open
            listFrame.Visible = open
            Util.Tween(arrow, {Rotation = open and 180 or 0}, 0.2)
        end)

        local dropObj = {Value = selected}
        function dropObj:Set(val)
            selected           = val
            selectedLabel.Text = val
            dropObj.Value      = val
            if callback then pcall(callback, val) end
        end
        return dropObj
    end

    function Tab:AddTextbox(boxName, description, placeholder, callback)
        local order = #contentFrame:GetChildren()

        local container = Util.GlassPanel(
            contentFrame,
            UDim2.new(1, 0, 0, 65),
            UDim2.new(0, 0, 0, 0),
            "TBox_" .. boxName,
            13
        )
        container.LayoutOrder = order
        container.Position    = UDim2.new(0, 0, 0, 0)

        local label = Instance.new("TextLabel")
        label.Size                   = UDim2.new(1, -20, 0, 20)
        label.Position               = UDim2.new(0, 14, 0, 8)
        label.BackgroundTransparency = 1
        label.Text                   = boxName
        label.TextColor3             = THEME.TextPrimary
        label.TextSize               = 14
        label.Font                   = Enum.Font.GothamSemibold
        label.TextXAlignment         = Enum.TextXAlignment.Left
        label.ZIndex                 = 14
        label.Parent                 = container

        if description then
            local desc = Instance.new("TextLabel")
            desc.Size                   = UDim2.new(1, -20, 0, 14)
            desc.Position               = UDim2.new(0, 14, 0, 26)
            desc.BackgroundTransparency = 1
            desc.Text                   = description
            desc.TextColor3             = THEME.TextMuted
            desc.TextSize               = 10
            desc.Font                   = Enum.Font.Gotham
            desc.TextXAlignment         = Enum.TextXAlignment.Left
            desc.ZIndex                 = 14
            desc.Parent                 = container
        end

        local inputFrame = Instance.new("Frame")
        inputFrame.Size                   = UDim2.new(1, -28, 0, 28)
        inputFrame.Position               = UDim2.new(0, 14, 1, -36)
        inputFrame.BackgroundColor3       = THEME.BackdropDark
        inputFrame.BackgroundTransparency = 0.40
        inputFrame.ZIndex                 = 14
        inputFrame.BorderSizePixel        = 0
        inputFrame.Parent                 = container
        Util.AddCorner(inputFrame, THEME.SmallCorner)
        Util.AddStroke(inputFrame, THEME.GlassEdge, 1, 0.60)

        local textBox = Instance.new("TextBox")
        textBox.Size                   = UDim2.new(1, -16, 1, 0)
        textBox.Position               = UDim2.new(0, 8, 0, 0)
        textBox.BackgroundTransparency = 1
        textBox.Text                   = ""
        textBox.PlaceholderText        = placeholder or "Enter text..."
        textBox.PlaceholderColor3      = THEME.TextMuted
        textBox.TextColor3             = THEME.TextPrimary
        textBox.TextSize               = 13
        textBox.Font                   = Enum.Font.Gotham
        textBox.TextXAlignment         = Enum.TextXAlignment.Left
        textBox.ClearTextOnFocus       = false
        textBox.ZIndex                 = 15
        textBox.Parent                 = inputFrame

        textBox.Focused:Connect(function()
            Util.Tween(inputFrame, {BackgroundTransparency = 0.2}, 0.2)
            Util.AddStroke(inputFrame, THEME.AccentPrimary, 1.5, 0.3)
        end)
        textBox.FocusLost:Connect(function(enter)
            Util.Tween(inputFrame, {BackgroundTransparency = 0.40}, 0.2)
            Util.AddStroke(inputFrame, THEME.GlassEdge, 1, 0.60)
            if callback then pcall(callback, textBox.Text, enter) end
        end)

        return textBox
    end

    function Tab:AddLabel(text, style)
        local order = #contentFrame:GetChildren()
        style = style or "default"

        local frame = Instance.new("Frame")
        frame.Name                   = "Label"
        frame.Size                   = UDim2.new(1, 0, 0, 30)
        frame.BackgroundTransparency = 1
        frame.ZIndex                 = 13
        frame.LayoutOrder            = order
        frame.Parent                 = contentFrame

        local lbl = Instance.new("TextLabel")
        lbl.Size                   = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text                   = text
        lbl.ZIndex                 = 14
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.Font                   = Enum.Font.Gotham
        lbl.Parent                 = frame

        if style == "accent" then
            lbl.TextColor3 = THEME.AccentPrimary
            lbl.TextSize   = 15
            lbl.Font       = Enum.Font.GothamBold
        elseif style == "muted" then
            lbl.TextColor3 = THEME.TextMuted
            lbl.TextSize   = 12
        else
            lbl.TextColor3 = THEME.TextSecondary
            lbl.TextSize   = 13
        end

        local labelObj = {}
        function labelObj:SetText(t) lbl.Text        = t end
        function labelObj:SetColor(c) lbl.TextColor3 = c end
        return labelObj
    end

    function Tab:AddColorPicker(pickerName, description, default, callback)
        local order = #contentFrame:GetChildren()
        local color = default or Color3.fromRGB(100, 180, 255)

        local container = Util.GlassPanel(
            contentFrame,
            UDim2.new(1, 0, 0, 52),
            UDim2.new(0, 0, 0, 0),
            "ColorPick_" .. pickerName,
            13
        )
        container.LayoutOrder = order
        container.Position    = UDim2.new(0, 0, 0, 0)

        local label = Instance.new("TextLabel")
        label.Size                   = UDim2.new(1, -80, 0, 22)
        label.Position               = UDim2.new(0, 14, 0, 8)
        label.BackgroundTransparency = 1
        label.Text                   = pickerName
        label.TextColor3             = THEME.TextPrimary
        label.TextSize               = 14
        label.Font                   = Enum.Font.GothamSemibold
        label.TextXAlignment         = Enum.TextXAlignment.Left
        label.ZIndex                 = 14
        label.Parent                 = container

        if description then
            local desc = Instance.new("TextLabel")
            desc.Size                   = UDim2.new(1, -80, 0, 16)
            desc.Position               = UDim2.new(0, 14, 0, 30)
            desc.BackgroundTransparency = 1
            desc.Text                   = description
            desc.TextColor3             = THEME.TextMuted
            desc.TextSize               = 11
            desc.Font                   = Enum.Font.Gotham
            desc.TextXAlignment         = Enum.TextXAlignment.Left
            desc.ZIndex                 = 14
            desc.Parent                 = container
        end

        local preview = Instance.new("Frame")
        preview.Name                   = "ColorPreview"
        preview.Size                   = UDim2.new(0, 34, 0, 34)
        preview.Position               = UDim2.new(1, -48, 0.5, -17)
        preview.BackgroundColor3       = color
        preview.ZIndex                 = 15
        preview.BorderSizePixel        = 0
        preview.Parent                 = container
        Util.AddCorner(preview, THEME.SmallCorner)
        Util.AddStroke(preview, THEME.GlassEdge, 1.5, 0.40)

        local open       = false
        local pickerPanel

        local function CreatePicker()
            pickerPanel = Util.GlassPanel(
                container,
                UDim2.new(1, 0, 0, 115),
                UDim2.new(0, 0, 1, 4),
                "PickerPanel",
                25
            )
            pickerPanel.ClipsDescendants = true

            local channels = {
                {name = "R", color = Color3.fromRGB(255, 80,  80),  index = 1},
                {name = "G", color = Color3.fromRGB(80,  220, 120), index = 2},
                {name = "B", color = Color3.fromRGB(80,  160, 255), index = 3},
            }
            local vals = {color.R * 255, color.G * 255, color.B * 255}

            local function Rebuild()
                color   = Color3.fromRGB(vals[1], vals[2], vals[3])
                preview.BackgroundColor3 = color
                if callback then pcall(callback, color) end
            end

            for _, ch in ipairs(channels) do
                local rowFrame = Instance.new("Frame")
                rowFrame.Size                   = UDim2.new(1, -16, 0, 28)
                rowFrame.Position               = UDim2.new(0, 8, 0, 8 + (ch.index - 1) * 34)
                rowFrame.BackgroundTransparency = 1
                rowFrame.ZIndex                 = 26
                rowFrame.Parent                 = pickerPanel

                local chLabel = Instance.new("TextLabel")
                chLabel.Size                   = UDim2.new(0, 16, 1, 0)
                chLabel.BackgroundTransparency = 1
                chLabel.Text                   = ch.name
                chLabel.TextColor3             = ch.color
                chLabel.TextSize               = 12
                chLabel.Font                   = Enum.Font.GothamBold
                chLabel.ZIndex                 = 27
                chLabel.Parent                 = rowFrame

                local chTrack = Instance.new("Frame")
                chTrack.Size                   = UDim2.new(1, -60, 0, 6)
                chTrack.Position               = UDim2.new(0, 20, 0.5, -3)
                chTrack.BackgroundColor3       = THEME.BackdropDark
                chTrack.BackgroundTransparency = 0.3
                chTrack.ZIndex                 = 26
                chTrack.BorderSizePixel        = 0
                chTrack.Parent                 = rowFrame
                Util.AddCorner(chTrack, UDim.new(1, 0))

                local chFill = Instance.new("Frame")
                chFill.Size                   = UDim2.new(vals[ch.index] / 255, 0, 1, 0)
                chFill.BackgroundColor3       = ch.color
                chFill.BackgroundTransparency = 0.1
                chFill.ZIndex                 = 27
                chFill.BorderSizePixel        = 0
                chFill.Parent                 = chTrack
                Util.AddCorner(chFill, UDim.new(1, 0))

                local chThumb = Instance.new("Frame")
                chThumb.Size                   = UDim2.new(0, 12, 0, 12)
                chThumb.AnchorPoint            = Vector2.new(0.5, 0.5)
                chThumb.Position               = UDim2.new(vals[ch.index] / 255, 0, 0.5, 0)
                chThumb.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
                chThumb.ZIndex                 = 28
                chThumb.BorderSizePixel        = 0
                chThumb.Parent                 = chTrack
                Util.AddCorner(chThumb, UDim.new(1, 0))

                local chVal = Instance.new("TextLabel")
                chVal.Size                   = UDim2.new(0, 34, 1, 0)
                chVal.Position               = UDim2.new(1, -34, 0, 0)
                chVal.BackgroundTransparency = 1
                chVal.Text                   = tostring(math.floor(vals[ch.index]))
                chVal.TextColor3             = THEME.TextSecondary
                chVal.TextSize               = 11
                chVal.Font                   = Enum.Font.Gotham
                chVal.ZIndex                 = 27
                chVal.Parent                 = rowFrame

                local draggingCh = false
                chTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingCh = true
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingCh = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if draggingCh and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local abs = chTrack.AbsolutePosition
                        local sz  = chTrack.AbsoluteSize
                        local rel = math.clamp((input.Position.X - abs.X) / sz.X, 0, 1)
                        vals[ch.index] = math.floor(rel * 255)
                        chVal.Text     = tostring(vals[ch.index])
                        Util.Tween(chFill,  {Size     = UDim2.new(rel, 0, 1, 0)},   0.05)
                        Util.Tween(chThumb, {Position = UDim2.new(rel, 0, 0.5, 0)}, 0.05)
                        Rebuild()
                    end
                end)
            end
        end

        preview.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                open = not open
                if open then
                    CreatePicker()
                    Util.Tween(container, {Size = UDim2.new(1, 0, 0, 175)}, 0.3, Enum.EasingStyle.Back)
                else
                    if pickerPanel then
                        pickerPanel:Destroy()
                        pickerPanel = nil
                    end
                    Util.Tween(container, {Size = UDim2.new(1, 0, 0, 52)}, 0.25)
                end
            end
        end)

        local pickerObj = {Value = color}
        function pickerObj:Set(c)
            color          = c
            preview.BackgroundColor3 = c
            pickerObj.Value = c
            if callback then pcall(callback, c) end
        end
        return pickerObj
    end

    function Tab:AddKeybind(bindName, description, default, callback)
        local order   = #contentFrame:GetChildren()
        local key     = default or Enum.KeyCode.Unknown
        local waiting = false

        local container = Util.GlassPanel(
            contentFrame,
            UDim2.new(1, 0, 0, 52),
            UDim2.new(0, 0, 0, 0),
            "Bind_" .. bindName,
            13
        )
        container.LayoutOrder = order
        container.Position    = UDim2.new(0, 0, 0, 0)

        local label = Instance.new("TextLabel")
        label.Size                   = UDim2.new(1, -120, 0, 22)
        label.Position               = UDim2.new(0, 14, 0, 8)
        label.BackgroundTransparency = 1
        label.Text                   = bindName
        label.TextColor3             = THEME.TextPrimary
        label.TextSize               = 14
        label.Font                   = Enum.Font.GothamSemibold
        label.TextXAlignment         = Enum.TextXAlignment.Left
        label.ZIndex                 = 14
        label.Parent                 = container

        if description then
            local desc = Instance.new("TextLabel")
            desc.Size                   = UDim2.new(1, -120, 0, 16)
            desc.Position               = UDim2.new(0, 14, 0, 30)
            desc.BackgroundTransparency = 1
            desc.Text                   = description
            desc.TextColor3             = THEME.TextMuted
            desc.TextSize               = 11
            desc.Font                   = Enum.Font.Gotham
            desc.TextXAlignment         = Enum.TextXAlignment.Left
            desc.ZIndex                 = 14
            desc.Parent                 = container
        end

        local bindBtn = Instance.new("TextButton")
        bindBtn.Name                   = "BindBtn"
        bindBtn.Size                   = UDim2.new(0, 100, 0, 30)
        bindBtn.Position               = UDim2.new(1, -112, 0.5, -15)
        bindBtn.BackgroundColor3       = THEME.GlassTint
        bindBtn.BackgroundTransparency = 0.65
        bindBtn.Text                   = key == Enum.KeyCode.Unknown and "None" or key.Name
        bindBtn.TextColor3             = THEME.AccentPrimary
        bindBtn.TextSize               = 12
        bindBtn.Font                   = Enum.Font.GothamSemibold
        bindBtn.ZIndex                 = 15
        bindBtn.BorderSizePixel        = 0
        bindBtn.Parent                 = container
        Util.AddCorner(bindBtn, THEME.SmallCorner)
        Util.AddStroke(bindBtn, THEME.AccentPrimary, 1, 0.55)

        bindBtn.MouseButton1Click:Connect(function()
            if waiting then return end
            waiting            = true
            bindBtn.Text       = "Press key..."
            bindBtn.TextColor3 = THEME.AccentWarning
            Util.AddStroke(bindBtn, THEME.AccentWarning, 1, 0.30)

            local conn
            conn = UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    key                = input.KeyCode
                    waiting            = false
                    bindBtn.Text       = key.Name
                    bindBtn.TextColor3 = THEME.AccentPrimary
                    Util.AddStroke(bindBtn, THEME.AccentPrimary, 1, 0.55)
                    conn:Disconnect()
                    if callback then pcall(callback, key) end
                end
            end)
        end)

        local bindObj = {Value = key}
        function bindObj:Set(k)
            key            = k
            bindBtn.Text   = k.Name
            bindObj.Value  = k
        end
        return bindObj
    end

    return Tab
end

function LiquidGlass:Notify(title, message, notifType, duration)
    duration  = duration  or 4
    notifType = notifType or "info"

    local accentColor = ({
        info    = THEME.AccentPrimary,
        success = THEME.AccentSuccess,
        error   = THEME.AccentDanger,
        warning = THEME.AccentWarning,
    })[notifType] or THEME.AccentPrimary

    local notif = Util.GlassPanel(
        self.NotifGui,
        UDim2.new(1, 0, 0, 70),
        UDim2.new(0, 0, 0, 0),
        "Notif",
        9999
    )

    local bar = Instance.new("Frame")
    bar.Size                   = UDim2.new(0, 3, 0.7, 0)
    bar.Position               = UDim2.new(0, 6, 0.15, 0)
    bar.BackgroundColor3       = accentColor
    bar.BackgroundTransparency = 0
    bar.ZIndex                 = 10000
    bar.BorderSizePixel        = 0
    bar.Parent                 = notif
    Util.AddCorner(bar, UDim.new(1, 0))

    local ntitle = Instance.new("TextLabel")
    ntitle.Size                   = UDim2.new(1, -30, 0, 22)
    ntitle.Position               = UDim2.new(0, 18, 0, 10)
    ntitle.BackgroundTransparency = 1
    ntitle.Text                   = title or "Notification"
    ntitle.TextColor3             = THEME.TextPrimary
    ntitle.TextSize               = 14
    ntitle.Font                   = Enum.Font.GothamBold
    ntitle.TextXAlignment         = Enum.TextXAlignment.Left
    ntitle.ZIndex                 = 10000
    ntitle.Parent                 = notif

    local nmsg = Instance.new("TextLabel")
    nmsg.Size                   = UDim2.new(1, -30, 0, 28)
    nmsg.Position               = UDim2.new(0, 18, 0, 32)
    nmsg.BackgroundTransparency = 1
    nmsg.Text                   = message or ""
    nmsg.TextColor3             = THEME.TextSecondary
    nmsg.TextSize               = 12
    nmsg.Font                   = Enum.Font.Gotham
    nmsg.TextXAlignment         = Enum.TextXAlignment.Left
    nmsg.TextWrapped            = true
    nmsg.ZIndex                 = 10000
    nmsg.Parent                 = notif

    local icon = Instance.new("TextLabel")
    icon.Size                   = UDim2.new(0, 20, 0, 20)
    icon.Position               = UDim2.new(1, -26, 0, 8)
    icon.BackgroundTransparency = 1
    icon.Text                   = ({info="i", success="v", error="x", warning="!"})[notifType] or "i"
    icon.TextColor3             = accentColor
    icon.TextSize               = 14
    icon.Font                   = Enum.Font.GothamBold
    icon.ZIndex                 = 10000
    icon.Parent                 = notif

    local progress = Instance.new("Frame")
    progress.Name                   = "Progress"
    progress.Size                   = UDim2.new(1, 0, 0, 2)
    progress.Position               = UDim2.new(0, 0, 1, -2)
    progress.BackgroundColor3       = accentColor
    progress.BackgroundTransparency = 0.2
    progress.ZIndex                 = 10001
    progress.BorderSizePixel        = 0
    progress.Parent                 = notif
    Util.AddCorner(progress, UDim.new(1, 0))

    notif.Position = UDim2.new(1, 20, 0, 0)
    Util.Tween(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Util.Tween(progress, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        Util.Tween(notif, {Position = UDim2.new(1, 20, 0, 0)}, 0.35)
        task.delay(0.4, function()
            if notif and notif.Parent then
                notif:Destroy()
            end
        end)
    end)

    return notif
end

function LiquidGlass:Destroy()
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}
    if self.ScreenGui and self.ScreenGui.Parent then
        self.ScreenGui:Destroy()
    end
end

-- THIS LINE IS CRITICAL - loadstring needs this
return LiquidGlass
