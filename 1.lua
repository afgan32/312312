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

local function MT(dur, style, dir)
    return TweenInfo.new(
        dur   or 0.35,
        style or Enum.EasingStyle.Quart,
        dir   or Enum.EasingDirection.Out
    )
end

local TW = {
    OPEN   = MT(0.55, Enum.EasingStyle.Back,   Enum.EasingDirection.Out),
    CLOSE  = MT(0.40, Enum.EasingStyle.Quart,  Enum.EasingDirection.In),
    HOVER  = MT(0.28, Enum.EasingStyle.Quart,  Enum.EasingDirection.Out),
    FAST   = MT(0.14, Enum.EasingStyle.Quart,  Enum.EasingDirection.Out),
    GLOW   = MT(0.45, Enum.EasingStyle.Sine,   Enum.EasingDirection.InOut),
    MORPH  = MT(0.42, Enum.EasingStyle.Back,   Enum.EasingDirection.Out),
    KNOB   = MT(0.32, Enum.EasingStyle.Back,   Enum.EasingDirection.Out),
    LINEAR = MT(1.00, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
}

local G = {
    Rim          = Color3.fromRGB(255, 255, 255),
    GlowInner    = Color3.fromRGB(200, 225, 255),
    GlowAccent   = Color3.fromRGB(140, 200, 255),
    Frost        = Color3.fromRGB(180, 205, 240),
    TextBright   = Color3.fromRGB(255, 255, 255),
    TextDim      = Color3.fromRGB(200, 215, 235),
    TextGhost    = Color3.fromRGB(150, 170, 200),
    Blue         = Color3.fromRGB(100, 185, 255),
    Purple       = Color3.fromRGB(175, 130, 255),
    Green        = Color3.fromRGB(100, 235, 165),
    Red          = Color3.fromRGB(255, 95,  105),
    Orange       = Color3.fromRGB(255, 185, 70),
    Dark         = Color3.fromRGB(8,   10,  18),
    Mid          = Color3.fromRGB(15,  18,  30),
    TrackOff     = Color3.fromRGB(55,  60,  82),
}

local U = {}

function U.Tw(i, p, t) local x = TweenService:Create(i, t or TW.HOVER, p) x:Play() return x end

function U.Rim(p, col, th, al)
    local o = p:FindFirstChildOfClass("UIStroke")
    if o then o:Destroy() end
    local s = Instance.new("UIStroke")
    s.Color = col or G.Rim; s.Thickness = th or 1
    s.Transparency = al or 0.22
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.LineJoinMode = Enum.LineJoinMode.Round
    s.Parent = p; return s
end

function U.Rnd(p, r)
    local o = p:FindFirstChildOfClass("UICorner")
    if o then o:Destroy() end
    local c = Instance.new("UICorner")
    c.CornerRadius = r or UDim.new(0, 16); c.Parent = p; return c
end

function U.Grad(p, cols, tras, rot)
    local o = p:FindFirstChildOfClass("UIGradient")
    if o then o:Destroy() end
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(cols)
    g.Transparency = NumberSequence.new(tras)
    g.Rotation = rot or 135; g.Parent = p; return g
end

function U.Glow(p, col, z)
    local g = Instance.new("ImageLabel")
    g.Name = "Glow"; g.Size = UDim2.new(1,24,1,24)
    g.Position = UDim2.new(0,-12,0,-12)
    g.BackgroundTransparency = 1
    g.Image = "rbxassetid://5028857084"
    g.ImageColor3 = col or G.GlowInner
    g.ImageTransparency = 0.85
    g.ScaleType = Enum.ScaleType.Slice
    g.SliceCenter = Rect.new(24,24,276,276)
    g.ZIndex = (z or 10)-1; g.Parent = p; return g
end

function U.Shine(p, z)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(0.72,0,0,1); s.Position = UDim2.new(0.14,0,0,2)
    s.BackgroundColor3 = Color3.fromRGB(255,255,255)
    s.BackgroundTransparency = 0.28; s.BorderSizePixel = 0
    s.ZIndex = z or 20; s.Parent = p; U.Rnd(s, UDim.new(1,0)); return s
end

function U.BotRef(p, z)
    local r = Instance.new("Frame")
    r.Size = UDim2.new(0.5,0,0,1); r.Position = UDim2.new(0.25,0,1,-2)
    r.BackgroundColor3 = Color3.fromRGB(255,255,255)
    r.BackgroundTransparency = 0.62; r.BorderSizePixel = 0
    r.ZIndex = z or 20; r.Parent = p; U.Rnd(r, UDim.new(1,0)); return r
end

function U.Lens(p, z)
    local l = Instance.new("ImageLabel")
    l.Size = UDim2.new(1,8,1,8); l.Position = UDim2.new(0,-4,0,-4)
    l.BackgroundTransparency = 1
    l.Image = "rbxassetid://6014261993"
    l.ImageColor3 = G.GlowInner; l.ImageTransparency = 0.90
    l.ScaleType = Enum.ScaleType.Slice
    l.SliceCenter = Rect.new(49,49,450,450)
    l.ZIndex = (z or 10)-1; l.Parent = p; return l
end

function U.Card(parent, h, z)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1,0,0,h or 58)
    c.BackgroundColor3 = Color3.fromRGB(255,255,255)
    c.BackgroundTransparency = 0.88
    c.BorderSizePixel = 0; c.ZIndex = z or 13
    c.ClipsDescendants = false; c.Parent = parent
    U.Rnd(c, UDim.new(0,16)); U.Rim(c, G.Rim, 1, 0.28)
    U.Shine(c, (z or 13)+2); U.BotRef(c, (z or 13)+2)
    U.Lens(c, z or 13)
    U.Grad(c, {
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.5, G.Frost),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(155,180,225)),
    },{
        NumberSequenceKeypoint.new(0,   0.82),
        NumberSequenceKeypoint.new(0.5, 0.88),
        NumberSequenceKeypoint.new(1,   0.93),
    }, 140)
    local cg = U.Glow(c, G.GlowInner, z or 13)
    cg.ImageTransparency = 0.90
    c.MouseEnter:Connect(function()
        U.Tw(c,  {BackgroundTransparency=0.78}, TW.FAST)
        U.Tw(cg, {ImageTransparency=0.72},      TW.GLOW)
    end)
    c.MouseLeave:Connect(function()
        U.Tw(c,  {BackgroundTransparency=0.88}, TW.FAST)
        U.Tw(cg, {ImageTransparency=0.90},      TW.GLOW)
    end)
    return c, cg
end

function U.Lbl(parent, txt, sz, font, col, z, xa)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = txt or ""; l.TextColor3 = col or G.TextBright
    l.TextSize = sz or 13; l.Font = font or Enum.Font.Gotham
    l.TextXAlignment = xa or Enum.TextXAlignment.Left
    l.ZIndex = z or 14; l.Parent = parent; return l
end

function U.NameDesc(card, name, desc, rightOffset)
    local ro = rightOffset or 0
    local n = U.Lbl(card, name, 14, Enum.Font.GothamSemibold, G.TextBright, 15)
    n.Size = UDim2.new(1, -ro-16, 0, 22); n.Position = UDim2.new(0,16,0,10)
    if desc then
        local d = U.Lbl(card, desc, 11, Enum.Font.Gotham, G.TextGhost, 15)
        d.Size = UDim2.new(1,-ro-16,0,15); d.Position = UDim2.new(0,16,0,33)
    end
end

local DepthOfField, BloomFX, ColorFX

local function SetupLighting()
    DepthOfField = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")
    if not DepthOfField then
        DepthOfField = Instance.new("DepthOfFieldEffect")
        DepthOfField.Parent = Lighting
    end
    DepthOfField.FarIntensity=0; DepthOfField.NearIntensity=0
    DepthOfField.FocusDistance=50; DepthOfField.InFocusRadius=50
    DepthOfField.Enabled=false

    BloomFX = Lighting:FindFirstChildOfClass("BloomEffect")
    if not BloomFX then BloomFX=Instance.new("BloomEffect"); BloomFX.Parent=Lighting end
    BloomFX.Intensity=0; BloomFX.Size=24; BloomFX.Threshold=0.95; BloomFX.Enabled=false

    ColorFX = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    if not ColorFX then ColorFX=Instance.new("ColorCorrectionEffect"); ColorFX.Parent=Lighting end
    ColorFX.Enabled=false
end

local function Blur(on)
    if on then
        DepthOfField.FocusDistance=10; DepthOfField.InFocusRadius=8
        DepthOfField.Enabled=true; BloomFX.Enabled=true
        ColorFX.Saturation=-0.08; ColorFX.Contrast=0.04; ColorFX.Enabled=true
        U.Tw(DepthOfField,{FarIntensity=1}, MT(0.55,Enum.EasingStyle.Quart,Enum.EasingDirection.Out))
        U.Tw(BloomFX,{Intensity=0.55},      MT(0.55,Enum.EasingStyle.Quart,Enum.EasingDirection.Out))
    else
        U.Tw(DepthOfField,{FarIntensity=0,NearIntensity=0},TW.CLOSE)
        U.Tw(BloomFX,{Intensity=0},TW.CLOSE)
        task.delay(0.5,function()
            DepthOfField.Enabled=false; BloomFX.Enabled=false; ColorFX.Enabled=false
        end)
    end
end

local function EnvTint()
    local h = Lighting.ClockTime
    if h>=6 and h<=18 then return Color3.fromRGB(200,215,240),0.80
    else return Color3.fromRGB(10,15,35),0.65 end
end

local NotifHolder
local function GetNotifHolder()
    if NotifHolder and NotifHolder.Parent then return NotifHolder end
    local ok,sg = pcall(function()
        local g=Instance.new("ScreenGui")
        g.Name="LG_N"; g.ResetOnSpawn=false
        g.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
        g.IgnoreGuiInset=true; g.Parent=CoreGui; return g
    end)
    if not ok then
        sg=Instance.new("ScreenGui"); sg.Name="LG_N"
        sg.ResetOnSpawn=false; sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
        sg.IgnoreGuiInset=true
        sg.Parent=LocalPlayer:WaitForChild("PlayerGui")
    end
    local h=Instance.new("Frame")
    h.Name="H"; h.Size=UDim2.new(0,340,1,0)
    h.Position=UDim2.new(1,-358,0,0)
    h.BackgroundTransparency=1; h.ZIndex=9999; h.Parent=sg
    local l=Instance.new("UIListLayout")
    l.SortOrder=Enum.SortOrder.LayoutOrder
    l.VerticalAlignment=Enum.VerticalAlignment.Bottom
    l.HorizontalAlignment=Enum.HorizontalAlignment.Center
    l.Padding=UDim.new(0,10); l.Parent=h
    local p=Instance.new("UIPadding")
    p.PaddingBottom=UDim.new(0,24); p.Parent=h
    NotifHolder=h; return h
end

function LiquidGlass.new(title, subtitle)
    local self=setmetatable({},LiquidGlass)
    self.Connections={}; self.Tabs={}
    self.ActiveTab=nil; self.Visible=true
    SetupLighting()

    local ok,sg=pcall(function()
        local g=Instance.new("ScreenGui")
        g.Name="LG_"..tostring(math.random(1000,9999))
        g.ResetOnSpawn=false; g.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
        g.IgnoreGuiInset=true; g.Parent=CoreGui; return g
    end)
    if not ok then
        sg=Instance.new("ScreenGui"); sg.Name="LG"
        sg.ResetOnSpawn=false; sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
        sg.IgnoreGuiInset=true
        sg.Parent=LocalPlayer:WaitForChild("PlayerGui")
    end
    self.ScreenGui=sg

    local bd=Instance.new("Frame")
    bd.Name="Backdrop"; bd.Size=UDim2.new(1,0,1,0)
    bd.BackgroundColor3=G.Dark; bd.BackgroundTransparency=0.38
    bd.ZIndex=1; bd.BorderSizePixel=0; bd.Parent=sg
    U.Grad(bd,{
        ColorSequenceKeypoint.new(0,  G.Dark),
        ColorSequenceKeypoint.new(0.5,G.Mid),
        ColorSequenceKeypoint.new(1,  G.Dark),
    },{
        NumberSequenceKeypoint.new(0,  0.20),
        NumberSequenceKeypoint.new(0.5,0.45),
        NumberSequenceKeypoint.new(1,  0.20),
    },45)

    local et,ea=EnvTint()
    local win=Instance.new("Frame")
    win.Name="Win"; win.Size=UDim2.new(0,750,0,520)
    win.Position=UDim2.new(0.5,-375,0.5,-260)
    win.BackgroundColor3=et; win.BackgroundTransparency=ea
    win.BorderSizePixel=0; win.ZIndex=10; win.ClipsDescendants=false
    win.Parent=sg
    U.Rnd(win,UDim.new(0,26)); U.Rim(win,G.Rim,1.2,0.18)
    U.Glow(win,G.GlowInner,10); U.Lens(win,10)
    U.Shine(win,15); U.BotRef(win,15)
    U.Grad(win,{
        ColorSequenceKeypoint.new(0,  Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.3,G.Frost),
        ColorSequenceKeypoint.new(0.7,Color3.fromRGB(160,185,230)),
        ColorSequenceKeypoint.new(1,  Color3.fromRGB(120,150,210)),
    },{
        NumberSequenceKeypoint.new(0,  0.72),
        NumberSequenceKeypoint.new(0.3,0.80),
        NumberSequenceKeypoint.new(0.7,0.85),
        NumberSequenceKeypoint.new(1,  0.90),
    },140)

    local gorb=Instance.new("ImageLabel")
    gorb.Name="GOrb"; gorb.Size=UDim2.new(0,200,0,100)
    gorb.AnchorPoint=Vector2.new(0.5,0.5)
    gorb.Position=UDim2.new(0.35,0,0.25,0)
    gorb.BackgroundTransparency=1
    gorb.Image="rbxassetid://5028857084"
    gorb.ImageColor3=Color3.fromRGB(255,255,255)
    gorb.ImageTransparency=0.72
    gorb.ScaleType=Enum.ScaleType.Slice
    gorb.SliceCenter=Rect.new(24,24,276,276)
    gorb.ZIndex=16; gorb.Parent=win

    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        if not win or not win.Parent then return end
        local mp=UserInputService:GetMouseLocation()
        local ap=win.AbsolutePosition; local as=win.AbsoluteSize
        local rx=math.clamp((mp.X-ap.X)/as.X,0,1)
        local ry=math.clamp((mp.Y-ap.Y)/as.Y,0,1)
        local tx=0.1+rx*0.8; local ty=0.05+ry*0.55
        local cp=gorb.Position
        local dist=math.sqrt((rx-0.5)^2+(ry-0.5)^2)
        gorb.Position=UDim2.new(cp.X.Scale+(tx-cp.X.Scale)*0.06,0,cp.Y.Scale+(ty-cp.Y.Scale)*0.06,0)
        gorb.ImageTransparency=0.58+dist*0.35
    end))

    table.insert(self.Connections, RunService.Heartbeat:Connect(function()
        local t,a=EnvTint()
        win.BackgroundColor3=t; win.BackgroundTransparency=a
    end))

    local tb=Instance.new("Frame")
    tb.Name="TBar"; tb.Size=UDim2.new(1,0,0,62)
    tb.BackgroundTransparency=1; tb.ZIndex=12
    tb.BorderSizePixel=0; tb.Parent=win

    local tgf=Instance.new("Frame")
    tgf.Size=UDim2.new(1,0,0,62)
    tgf.BackgroundColor3=Color3.fromRGB(255,255,255)
    tgf.BackgroundTransparency=0.93; tgf.BorderSizePixel=0
    tgf.ZIndex=11; tgf.Parent=win
    U.Grad(tgf,{
        ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(200,220,255)),
    },{
        NumberSequenceKeypoint.new(0,0.88),
        NumberSequenceKeypoint.new(1,1.0),
    },90)

    local div=Instance.new("Frame")
    div.Size=UDim2.new(0.9,0,0,1); div.Position=UDim2.new(0.05,0,0,61)
    div.BackgroundColor3=G.Rim; div.BackgroundTransparency=0.55
    div.ZIndex=13; div.BorderSizePixel=0; div.Parent=win
    U.Grad(div,{
        ColorSequenceKeypoint.new(0,  Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.5,G.GlowAccent),
        ColorSequenceKeypoint.new(1,  Color3.fromRGB(255,255,255)),
    },{
        NumberSequenceKeypoint.new(0,  1),
        NumberSequenceKeypoint.new(0.5,0.4),
        NumberSequenceKeypoint.new(1,  1),
    },0)

    local tl=U.Lbl(tb,title or "Liquid Glass",18,Enum.Font.GothamBold,G.TextBright,14)
    tl.Size=UDim2.new(1,-40,0,28); tl.Position=UDim2.new(0,22,0,8)
    local tlg=Instance.new("UIGradient")
    tlg.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1,G.GlowAccent),
    }); tlg.Rotation=0; tlg.Parent=tl

    local sl=U.Lbl(tb,subtitle or "Liquid Glass UI",11,Enum.Font.Gotham,G.TextGhost,14)
    sl.Size=UDim2.new(1,-40,0,16); sl.Position=UDim2.new(0,22,0,38)

    local bindHint=U.Lbl(tb,"[INSERT] Toggle",11,Enum.Font.Gotham,G.TextGhost,14)
    bindHint.Size=UDim2.new(0,120,0,16)
    bindHint.Position=UDim2.new(1,-130,0.5,-8)
    bindHint.TextXAlignment=Enum.TextXAlignment.Right

    self.Window=win

    do
        local drag,ds,sp=false,nil,nil
        tb.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                drag=true; ds=i.Position; sp=win.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
                local d=i.Position-ds
                win.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
        end)
    end

    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(i,gpe)
        if gpe then return end
        if i.KeyCode==Enum.KeyCode.Insert then self:Toggle() end
    end))

    local sidebar=Instance.new("Frame")
    sidebar.Name="Side"; sidebar.Size=UDim2.new(0,172,1,-72)
    sidebar.Position=UDim2.new(0,8,0,66)
    sidebar.BackgroundColor3=Color3.fromRGB(255,255,255)
    sidebar.BackgroundTransparency=0.93; sidebar.BorderSizePixel=0
    sidebar.ZIndex=12; sidebar.ClipsDescendants=true; sidebar.Parent=win
    U.Rnd(sidebar,UDim.new(0,18)); U.Rim(sidebar,G.Rim,1,0.30)
    U.Shine(sidebar,14)

    local sl2=Instance.new("UIListLayout")
    sl2.SortOrder=Enum.SortOrder.LayoutOrder; sl2.Padding=UDim.new(0,5); sl2.Parent=sidebar
    local sp2=Instance.new("UIPadding")
    sp2.PaddingTop=UDim.new(0,10); sp2.PaddingLeft=UDim.new(0,8); sp2.PaddingRight=UDim.new(0,8)
    sp2.Parent=sidebar

    local ch=Instance.new("ScrollingFrame")
    ch.Name="Content"; ch.Size=UDim2.new(1,-192,1,-72)
    ch.Position=UDim2.new(0,186,0,66)
    ch.BackgroundTransparency=1; ch.ZIndex=12; ch.BorderSizePixel=0
    ch.ScrollBarThickness=3; ch.ScrollBarImageColor3=G.GlowAccent
    ch.ScrollBarImageTransparency=0.4
    ch.CanvasSize=UDim2.new(0,0,0,0)
    ch.AutomaticCanvasSize=Enum.AutomaticSize.Y; ch.Parent=win

    local cl=Instance.new("UIListLayout")
    cl.SortOrder=Enum.SortOrder.LayoutOrder; cl.Padding=UDim.new(0,8); cl.Parent=ch
    local cp=Instance.new("UIPadding")
    cp.PaddingTop=UDim.new(0,6); cp.PaddingBottom=UDim.new(0,18)
    cp.PaddingLeft=UDim.new(0,6); cp.PaddingRight=UDim.new(0,12); cp.Parent=ch

    self.Sidebar=sidebar; self.Content=ch
    self.NotifGui=GetNotifHolder()

    win.Size=UDim2.new(0,0,0,0); win.Position=UDim2.new(0.5,0,0.5,0)
    Blur(true)
    task.delay(0.05,function()
        U.Tw(win,{Size=UDim2.new(0,750,0,520),Position=UDim2.new(0.5,-375,0.5,-260)},TW.OPEN)
    end)

    return self
end

function LiquidGlass:Toggle(state)
    self.Visible=(state~=nil) and state or (not self.Visible)
    if self.Visible then
        self.Window.Visible=true; Blur(true)
        U.Tw(self.Window,{Size=UDim2.new(0,750,0,520),Position=UDim2.new(0.5,-375,0.5,-260)},TW.OPEN)
    else
        Blur(false)
        local t=U.Tw(self.Window,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)},TW.CLOSE)
        t.Completed:Connect(function() self.Window.Visible=false end)
    end
end

function LiquidGlass:SetKeybind(key)
    table.insert(self.Connections,UserInputService.InputBegan:Connect(function(i,gpe)
        if gpe then return end
        if i.KeyCode==key then self:Toggle() end
    end))
end

function LiquidGlass:AddTab(name, icon)
    local idx=#self.Tabs+1

    local btn=Instance.new("TextButton")
    btn.Name="T_"..name; btn.Size=UDim2.new(1,0,0,46)
    btn.BackgroundColor3=Color3.fromRGB(255,255,255)
    btn.BackgroundTransparency=0.92; btn.Text=""
    btn.ZIndex=13; btn.BorderSizePixel=0
    btn.LayoutOrder=idx; btn.Parent=self.Sidebar
    U.Rnd(btn,UDim.new(0,14)); U.Rim(btn,G.Rim,1,0.50)
    local bg=U.Glow(btn,G.GlowAccent,13); bg.ImageTransparency=1

    local il=U.Lbl(btn,icon or "o",15,Enum.Font.GothamBold,G.TextDim,14)
    il.Size=UDim2.new(0,28,0,28); il.Position=UDim2.new(0,8,0.5,-14)
    il.TextXAlignment=Enum.TextXAlignment.Center

    local nl=U.Lbl(btn,name,13,Enum.Font.Gotham,G.TextDim,14)
    nl.Size=UDim2.new(1,-44,1,0); nl.Position=UDim2.new(0,40,0,0)

    local ind=Instance.new("Frame")
    ind.Size=UDim2.new(0,3,0.55,0); ind.Position=UDim2.new(0,1,0.225,0)
    ind.BackgroundColor3=G.Blue; ind.BackgroundTransparency=1
    ind.ZIndex=15; ind.BorderSizePixel=0; ind.Parent=btn
    U.Rnd(ind,UDim.new(1,0))

    local cf=Instance.new("Frame")
    cf.Name="CF_"..name; cf.Size=UDim2.new(1,0,0,0)
    cf.AutomaticSize=Enum.AutomaticSize.Y
    cf.BackgroundTransparency=1; cf.Visible=false
    cf.ZIndex=12; cf.BorderSizePixel=0
    cf.LayoutOrder=idx; cf.Parent=self.Content
    local ilay=Instance.new("UIListLayout")
    ilay.SortOrder=Enum.SortOrder.LayoutOrder; ilay.Padding=UDim.new(0,7); ilay.Parent=cf

    local td={Name=name,Btn=btn,CF=cf,Ind=ind,Icon=il,Lbl=nl,BG=bg,Idx=idx}
    table.insert(self.Tabs,td)
    local sr=self

    local function Act()
        for _,t in ipairs(sr.Tabs) do
            t.CF.Visible=false
            U.Tw(t.Btn,{BackgroundTransparency=0.92},TW.FAST)
            U.Tw(t.Ind,{BackgroundTransparency=1.0}, TW.FAST)
            U.Tw(t.Lbl,{TextColor3=G.TextDim},       TW.FAST)
            U.Tw(t.Icon,{TextColor3=G.TextDim},      TW.FAST)
            U.Tw(t.BG, {ImageTransparency=1.0},      TW.FAST)
            U.Rim(t.Btn,G.Rim,1,0.50)
        end
        cf.Visible=true; sr.ActiveTab=td
        U.Tw(btn,{BackgroundTransparency=0.70},TW.HOVER)
        U.Tw(ind,{BackgroundTransparency=0.0}, TW.MORPH)
        U.Tw(nl, {TextColor3=G.Blue},          TW.HOVER)
        U.Tw(il, {TextColor3=G.Blue},          TW.HOVER)
        U.Tw(bg, {ImageTransparency=0.65},     TW.GLOW)
        U.Rim(btn,G.Blue,1.0,0.35)
    end

    btn.MouseEnter:Connect(function()
        if sr.ActiveTab~=td then
            U.Tw(btn,{BackgroundTransparency=0.83},TW.FAST)
            U.Tw(bg, {ImageTransparency=0.80},     TW.FAST)
        end
    end)
    btn.MouseLeave:Connect(function()
        if sr.ActiveTab~=td then
            U.Tw(btn,{BackgroundTransparency=0.92},TW.FAST)
            U.Tw(bg, {ImageTransparency=1.0},      TW.FAST)
        end
    end)
    btn.MouseButton1Click:Connect(Act)
    if idx==1 then Act() end

    local Tab={}; Tab._f=cf

    local function nextOrder() return #cf:GetChildren() end

    function Tab:AddSection(sn)
        local sf=Instance.new("Frame")
        sf.Size=UDim2.new(1,0,0,28); sf.BackgroundTransparency=1
        sf.ZIndex=13; sf.LayoutOrder=nextOrder(); sf.Parent=cf

        local bg2=Instance.new("Frame")
        bg2.Size=UDim2.new(0,12,0,18); bg2.Position=UDim2.new(0,0,0.5,-9)
        bg2.BackgroundColor3=Color3.fromRGB(8,10,22)
        bg2.BackgroundTransparency=0.05; bg2.ZIndex=14
        bg2.BorderSizePixel=0; bg2.Parent=sf; U.Rnd(bg2,UDim.new(0,6))

        local lb=U.Lbl(sf,sn,10,Enum.Font.GothamBold,G.TextGhost,15)
        lb.Size=UDim2.new(1,-8,1,0); lb.Position=UDim2.new(0,4,0,0)
        lb.Parent=bg2

        task.defer(function()
            local tw=lb.TextBounds.X
            bg2.Size=UDim2.new(0,tw+16,0,18)
        end)

        local ln=Instance.new("Frame")
        ln.Size=UDim2.new(1,-8,0,1); ln.Position=UDim2.new(0,4,1,-1)
        ln.BackgroundColor3=G.Rim; ln.BackgroundTransparency=0.70
        ln.ZIndex=13; ln.BorderSizePixel=0; ln.Parent=sf
        U.Grad(ln,{
            ColorSequenceKeypoint.new(0,  Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.5,G.GlowAccent),
            ColorSequenceKeypoint.new(1,  Color3.fromRGB(255,255,255)),
        },{
            NumberSequenceKeypoint.new(0,  1),
            NumberSequenceKeypoint.new(0.5,0.5),
            NumberSequenceKeypoint.new(1,  1),
        },0)
    end

    function Tab:AddLabel(txt, style)
        local fr=Instance.new("Frame")
        fr.Size=UDim2.new(1,0,0,28); fr.BackgroundTransparency=1
        fr.ZIndex=13; fr.LayoutOrder=nextOrder(); fr.Parent=cf

        local lb=U.Lbl(fr,txt,13,Enum.Font.Gotham,G.TextDim,14)
        lb.Size=UDim2.new(1,-8,1,0); lb.Position=UDim2.new(0,4,0,0)

        if style=="accent" then lb.TextColor3=G.Blue; lb.TextSize=15; lb.Font=Enum.Font.GothamBold
        elseif style=="muted" then lb.TextColor3=G.TextGhost; lb.TextSize=11
        elseif style=="success" then lb.TextColor3=G.Green; lb.TextSize=13; lb.Font=Enum.Font.GothamSemibold
        elseif style=="warn" then lb.TextColor3=G.Orange; lb.TextSize=13; lb.Font=Enum.Font.GothamSemibold
        elseif style=="error" then lb.TextColor3=G.Red; lb.TextSize=13; lb.Font=Enum.Font.GothamSemibold
        end

        local o={}
        function o:Set(t) lb.Text=t end
        function o:SetColor(c) lb.TextColor3=c end
        function o:SetStyle(s)
            if s=="accent" then lb.TextColor3=G.Blue; lb.TextSize=15; lb.Font=Enum.Font.GothamBold
            elseif s=="muted" then lb.TextColor3=G.TextGhost; lb.TextSize=11
            elseif s=="success" then lb.TextColor3=G.Green
            elseif s=="warn" then lb.TextColor3=G.Orange
            elseif s=="error" then lb.TextColor3=G.Red end
        end
        return o
    end

    function Tab:AddButton(nm, desc, cb)
        local card,cg=U.Card(cf,58,13)
        card.LayoutOrder=nextOrder()
        U.NameDesc(card,nm,desc,116)

        local pill=Instance.new("TextButton")
        pill.Size=UDim2.new(0,82,0,32); pill.Position=UDim2.new(1,-94,0.5,-16)
        pill.BackgroundColor3=G.Blue; pill.BackgroundTransparency=0.30
        pill.Text="Run"; pill.TextColor3=Color3.fromRGB(255,255,255)
        pill.TextSize=12; pill.Font=Enum.Font.GothamSemibold
        pill.ZIndex=16; pill.BorderSizePixel=0; pill.Parent=card
        U.Rnd(pill,UDim.new(1,0)); U.Rim(pill,G.Blue,1,0.35)
        local pg=U.Glow(pill,G.Blue,16)

        pill.MouseEnter:Connect(function()
            U.Tw(pill,{BackgroundTransparency=0.0,Size=UDim2.new(0,86,0,34)},TW.HOVER)
            U.Tw(pg,  {ImageTransparency=0.40},TW.GLOW)
            U.Tw(cg,  {ImageTransparency=0.65},TW.GLOW)
        end)
        pill.MouseLeave:Connect(function()
            U.Tw(pill,{BackgroundTransparency=0.30,Size=UDim2.new(0,82,0,32)},TW.HOVER)
            U.Tw(pg,  {ImageTransparency=1.0},TW.GLOW)
            U.Tw(cg,  {ImageTransparency=0.90},TW.GLOW)
        end)
        pill.MouseButton1Click:Connect(function()
            U.Tw(pill,{BackgroundTransparency=0.0},TW.FAST)
            U.Tw(pg,  {ImageTransparency=0.20},TW.FAST)
            U.Tw(card,{BackgroundTransparency=0.72},TW.FAST)
            task.delay(0.18,function()
                U.Tw(pill,{BackgroundTransparency=0.30},TW.HOVER)
                U.Tw(pg,  {ImageTransparency=1.0},TW.GLOW)
                U.Tw(card,{BackgroundTransparency=0.88},TW.HOVER)
            end)
            if cb then pcall(cb) end
        end)
    end

    function Tab:AddCheckbox(nm, desc, default, cb, bindKey)
        local enabled=default or false
        local card,cg=U.Card(cf,58,13)
        card.LayoutOrder=nextOrder()

        local checkW = bindKey~=nil and 160 or 80
        U.NameDesc(card,nm,desc,checkW)

        local box=Instance.new("Frame")
        box.Size=UDim2.new(0,26,0,26)
        box.Position=UDim2.new(1,-checkW+2,0.5,-13)
        box.BackgroundColor3=enabled and G.Blue or G.TrackOff
        box.BackgroundTransparency=enabled and 0.15 or 0.55
        box.ZIndex=16; box.BorderSizePixel=0; box.Parent=card
        U.Rnd(box,UDim.new(0,7))
        U.Rim(box,enabled and G.Blue or G.TextGhost,1,0.45)
        local boxGlow=U.Glow(box,G.Blue,16)
        boxGlow.ImageTransparency=enabled and 0.55 or 1.0

        local tick=U.Lbl(box,"v",14,Enum.Font.GothamBold,Color3.fromRGB(255,255,255),17)
        tick.Size=UDim2.new(1,0,1,0); tick.TextXAlignment=Enum.TextXAlignment.Center
        tick.BackgroundTransparency=1
        tick.TextTransparency=enabled and 0 or 1

        local keyLbl
        if bindKey then
            keyLbl=Instance.new("TextButton")
            keyLbl.Size=UDim2.new(0,80,0,28)
            keyLbl.Position=UDim2.new(1,-82,0.5,-14)
            keyLbl.BackgroundColor3=Color3.fromRGB(255,255,255)
            keyLbl.BackgroundTransparency=0.87
            keyLbl.Text=bindKey==Enum.KeyCode.Unknown and "None" or bindKey.Name
            keyLbl.TextColor3=G.Blue; keyLbl.TextSize=11
            keyLbl.Font=Enum.Font.GothamSemibold
            keyLbl.ZIndex=17; keyLbl.BorderSizePixel=0; keyLbl.Parent=card
            U.Rnd(keyLbl,UDim.new(1,0)); U.Rim(keyLbl,G.Blue,1,0.40)
        end

        local currentKey=bindKey or Enum.KeyCode.Unknown
        local waitKey=false

        local function Update()
            if enabled then
                U.Tw(box,{BackgroundColor3=G.Blue,BackgroundTransparency=0.15},TW.MORPH)
                U.Tw(tick,{TextTransparency=0},TW.FAST)
                U.Tw(boxGlow,{ImageTransparency=0.55},TW.GLOW)
                U.Tw(cg,{ImageTransparency=0.70},TW.GLOW)
                U.Rim(box,G.Blue,1,0.35)
            else
                U.Tw(box,{BackgroundColor3=G.TrackOff,BackgroundTransparency=0.55},TW.MORPH)
                U.Tw(tick,{TextTransparency=1},TW.FAST)
                U.Tw(boxGlow,{ImageTransparency=1.0},TW.GLOW)
                U.Tw(cg,{ImageTransparency=0.90},TW.GLOW)
                U.Rim(box,G.TextGhost,1,0.55)
            end
            if cb then pcall(cb,enabled) end
        end

        local cr=Instance.new("TextButton")
        cr.Size=UDim2.new(1,0,1,0); cr.BackgroundTransparency=1
        cr.Text=""; cr.ZIndex=18; cr.Parent=card
        cr.MouseButton1Click:Connect(function()
            enabled=not enabled; Update()
        end)

        if keyLbl then
            local kconn
            keyLbl.MouseButton1Click:Connect(function()
                if waitKey then return end
                waitKey=true
                keyLbl.Text="..."; keyLbl.TextColor3=G.Orange
                U.Rim(keyLbl,G.Orange,1,0.30)
                if kconn then kconn:Disconnect() end
                kconn=UserInputService.InputBegan:Connect(function(inp,gpe)
                    if gpe then return end
                    if inp.UserInputType==Enum.UserInputType.Keyboard then
                        currentKey=inp.KeyCode
                        waitKey=false
                        keyLbl.Text=currentKey.Name
                        keyLbl.TextColor3=G.Blue
                        U.Rim(keyLbl,G.Blue,1,0.40)
                        kconn:Disconnect()
                    end
                end)
            end)

            table.insert(self.Connections,UserInputService.InputBegan:Connect(function(inp,gpe)
                if gpe then return end
                if inp.KeyCode==currentKey and currentKey~=Enum.KeyCode.Unknown then
                    enabled=not enabled; Update()
                end
            end))
        end

        local o={Value=enabled}
        function o:Set(v) enabled=v; o.Value=v; Update() end
        function o:GetKey() return currentKey end
        return o
    end

    function Tab:AddToggle(nm, desc, default, cb)
        local enabled=default or false
        local card,cg=U.Card(cf,58,13)
        card.LayoutOrder=nextOrder()
        U.NameDesc(card,nm,desc,90)

        local track=Instance.new("Frame")
        track.Size=UDim2.new(0,52,0,28); track.Position=UDim2.new(1,-66,0.5,-14)
        track.BackgroundColor3=enabled and G.Blue or G.TrackOff
        track.BackgroundTransparency=enabled and 0.15 or 0.55
        track.ZIndex=16; track.BorderSizePixel=0; track.Parent=card
        U.Rnd(track,UDim.new(1,0))
        U.Rim(track,enabled and G.Blue or G.TextGhost,1,0.45)
        local tg=U.Glow(track,G.Blue,16)
        tg.ImageTransparency=enabled and 0.55 or 1.0

        local knob=Instance.new("Frame")
        knob.Size=UDim2.new(0,22,0,22); knob.AnchorPoint=Vector2.new(0,0.5)
        knob.Position=enabled and UDim2.new(1,-25,0.5,0) or UDim2.new(0,3,0.5,0)
        knob.BackgroundColor3=Color3.fromRGB(255,255,255)
        knob.BackgroundTransparency=0; knob.ZIndex=17
        knob.BorderSizePixel=0; knob.Parent=track
        U.Rnd(knob,UDim.new(1,0)); U.Rim(knob,G.Rim,1,0.40)

        local function Update()
            if enabled then
                U.Tw(track,{BackgroundColor3=G.Blue,BackgroundTransparency=0.15},TW.MORPH)
                U.Tw(knob, {Position=UDim2.new(1,-25,0.5,0)},TW.KNOB)
                U.Tw(tg,   {ImageTransparency=0.55},TW.GLOW)
                U.Tw(cg,   {ImageTransparency=0.70},TW.GLOW)
                U.Rim(track,G.Blue,1,0.35)
            else
                U.Tw(track,{BackgroundColor3=G.TrackOff,BackgroundTransparency=0.55},TW.MORPH)
                U.Tw(knob, {Position=UDim2.new(0,3,0.5,0)},TW.KNOB)
                U.Tw(tg,   {ImageTransparency=1.0},TW.GLOW)
                U.Tw(cg,   {ImageTransparency=0.90},TW.GLOW)
                U.Rim(track,G.TextGhost,1,0.55)
            end
            if cb then pcall(cb,enabled) end
        end

        local cr=Instance.new("TextButton")
        cr.Size=UDim2.new(1,0,1,0); cr.BackgroundTransparency=1
        cr.Text=""; cr.ZIndex=18; cr.Parent=card
        cr.MouseButton1Click:Connect(function() enabled=not enabled; Update() end)

        local o={Value=enabled}
        function o:Set(v) enabled=v; o.Value=v; Update() end
        return o
    end

    function Tab:AddSlider(nm, desc, min, max, default, step, cb)
        step=step or 1
        local value=math.clamp(default or min,min,max)
        local card,cg=U.Card(cf,72,13)
        card.LayoutOrder=nextOrder()

        local nl=U.Lbl(card,nm,14,Enum.Font.GothamSemibold,G.TextBright,15)
        nl.Size=UDim2.new(1,-80,0,20); nl.Position=UDim2.new(0,16,0,8)

        local vl=U.Lbl(card,tostring(value),14,Enum.Font.GothamBold,G.Blue,15)
        vl.Size=UDim2.new(0,60,0,20); vl.Position=UDim2.new(1,-74,0,8)
        vl.TextXAlignment=Enum.TextXAlignment.Right

        if desc then
            local d=U.Lbl(card,desc,10,Enum.Font.Gotham,G.TextGhost,15)
            d.Size=UDim2.new(1,-80,0,13); d.Position=UDim2.new(0,16,0,27)
        end

        local tbg=Instance.new("Frame")
        tbg.Size=UDim2.new(1,-32,0,6); tbg.Position=UDim2.new(0,16,1,-20)
        tbg.BackgroundColor3=Color3.fromRGB(50,55,80)
        tbg.BackgroundTransparency=0.35; tbg.ZIndex=15
        tbg.BorderSizePixel=0; tbg.Parent=card
        U.Rnd(tbg,UDim.new(1,0)); U.Rim(tbg,G.Rim,1,0.55)

        local fill=Instance.new("Frame")
        fill.Size=UDim2.new((value-min)/(max-min),0,1,0)
        fill.ZIndex=16; fill.BorderSizePixel=0; fill.Parent=tbg
        U.Rnd(fill,UDim.new(1,0))
        U.Grad(fill,{
            ColorSequenceKeypoint.new(0,G.Blue),
            ColorSequenceKeypoint.new(1,G.Purple),
        },{
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(1,0),
        },0)

        local thumb=Instance.new("Frame")
        thumb.Size=UDim2.new(0,18,0,18); thumb.AnchorPoint=Vector2.new(0.5,0.5)
        thumb.Position=UDim2.new((value-min)/(max-min),0,0.5,0)
        thumb.BackgroundColor3=Color3.fromRGB(255,255,255)
        thumb.ZIndex=17; thumb.BorderSizePixel=0; thumb.Parent=tbg
        U.Rnd(thumb,UDim.new(1,0)); U.Rim(thumb,G.Blue,2,0.15)
        local thg=U.Glow(thumb,G.Blue,17); thg.ImageTransparency=0.70

        local drag=false
        tbg.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                drag=false
                U.Tw(thumb,{Size=UDim2.new(0,18,0,18)},TW.HOVER)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
                local ap=tbg.AbsolutePosition; local as=tbg.AbsoluteSize
                local rel=math.clamp((i.Position.X-ap.X)/as.X,0,1)
                local raw=min+rel*(max-min)
                value=math.floor(raw/step+0.5)*step
                value=math.clamp(value,min,max)
                local r2=(value-min)/(max-min)
                vl.Text=tostring(value)
                U.Tw(fill, {Size=UDim2.new(r2,0,1,0)},TW.FAST)
                U.Tw(thumb,{Position=UDim2.new(r2,0,0.5,0),Size=UDim2.new(0,20,0,20)},TW.FAST)
                if cb then pcall(cb,value) end
            end
        end)

        local o={Value=value}
        function o:Set(v)
            v=math.clamp(math.floor(v/step+0.5)*step,min,max)
            value=v; o.Value=v
            local r=(v-min)/(max-min)
            vl.Text=tostring(v)
            U.Tw(fill, {Size=UDim2.new(r,0,1,0)}, TW.MORPH)
            U.Tw(thumb,{Position=UDim2.new(r,0,0.5,0)},TW.MORPH)
            if cb then pcall(cb,v) end
        end
        return o
    end

    function Tab:AddCombobox(nm, desc, options, default, cb)
        local selected=default or (options and options[1]) or "None"
        local open=false
        local card,_=U.Card(cf,58,13)
        card.LayoutOrder=nextOrder(); card.ClipsDescendants=false

        U.NameDesc(card,nm,desc,165)

        local hdr=Instance.new("TextButton")
        hdr.Size=UDim2.new(0,140,0,32); hdr.Position=UDim2.new(1,-152,0.5,-16)
        hdr.BackgroundColor3=Color3.fromRGB(255,255,255)
        hdr.BackgroundTransparency=0.85; hdr.Text=""
        hdr.ZIndex=16; hdr.BorderSizePixel=0; hdr.Parent=card
        U.Rnd(hdr,UDim.new(1,0)); U.Rim(hdr,G.Rim,1,0.35)
        U.Glow(hdr,G.GlowInner,16)

        local sl3=U.Lbl(hdr,selected,12,Enum.Font.GothamSemibold,G.Blue,17)
        sl3.Size=UDim2.new(1,-28,1,0); sl3.Position=UDim2.new(0,10,0,0)

        local arr=U.Lbl(hdr,"v",11,Enum.Font.GothamBold,G.TextGhost,17)
        arr.Size=UDim2.new(0,20,1,0); arr.Position=UDim2.new(1,-22,0,0)
        arr.TextXAlignment=Enum.TextXAlignment.Center

        local lh=math.min(#options,6)*34+10
        local lf=Instance.new("Frame")
        lf.Size=UDim2.new(0,140,0,lh); lf.Position=UDim2.new(1,-152,1,6)
        lf.BackgroundColor3=Color3.fromRGB(15,18,32)
        lf.BackgroundTransparency=0.12; lf.ZIndex=30
        lf.Visible=false; lf.ClipsDescendants=true
        lf.BorderSizePixel=0; lf.Parent=card
        U.Rnd(lf,UDim.new(0,14)); U.Rim(lf,G.Rim,1,0.28)

        local ll=Instance.new("UIListLayout")
        ll.SortOrder=Enum.SortOrder.LayoutOrder; ll.Padding=UDim.new(0,2); ll.Parent=lf
        local lp=Instance.new("UIPadding")
        lp.PaddingTop=UDim.new(0,5); lp.PaddingLeft=UDim.new(0,5); lp.PaddingRight=UDim.new(0,5)
        lp.Parent=lf

        for i,opt in ipairs(options or {}) do
            local ob=Instance.new("TextButton")
            ob.Size=UDim2.new(1,0,0,30)
            ob.BackgroundColor3=Color3.fromRGB(255,255,255)
            ob.BackgroundTransparency=0.90; ob.Text=opt
            ob.TextColor3=G.TextDim; ob.TextSize=12
            ob.Font=Enum.Font.Gotham; ob.ZIndex=31
            ob.BorderSizePixel=0; ob.LayoutOrder=i; ob.Parent=lf
            U.Rnd(ob,UDim.new(0,10))
            ob.MouseEnter:Connect(function()
                U.Tw(ob,{BackgroundTransparency=0.65,TextColor3=G.Blue},TW.FAST)
            end)
            ob.MouseLeave:Connect(function()
                U.Tw(ob,{BackgroundTransparency=0.90,TextColor3=G.TextDim},TW.FAST)
            end)
            ob.MouseButton1Click:Connect(function()
                selected=opt; sl3.Text=opt
                open=false; lf.Visible=false
                U.Tw(arr,{Rotation=0},TW.FAST)
                U.Tw(hdr,{BackgroundTransparency=0.85},TW.FAST)
                if cb then pcall(cb,opt) end
            end)
        end

        hdr.MouseButton1Click:Connect(function()
            open=not open; lf.Visible=open
            U.Tw(arr,{Rotation=open and 180 or 0},TW.FAST)
            U.Tw(hdr,{BackgroundTransparency=open and 0.70 or 0.85},TW.FAST)
        end)

        local o={Value=selected}
        function o:Set(v) selected=v; sl3.Text=v; o.Value=v; if cb then pcall(cb,v) end end
        function o:SetOptions(newOpts)
            for _,c in ipairs(lf:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for i,opt in ipairs(newOpts) do
                local ob=Instance.new("TextButton")
                ob.Size=UDim2.new(1,0,0,30)
                ob.BackgroundColor3=Color3.fromRGB(255,255,255)
                ob.BackgroundTransparency=0.90; ob.Text=opt
                ob.TextColor3=G.TextDim; ob.TextSize=12
                ob.Font=Enum.Font.Gotham; ob.ZIndex=31
                ob.BorderSizePixel=0; ob.LayoutOrder=i; ob.Parent=lf
                U.Rnd(ob,UDim.new(0,10))
                ob.MouseEnter:Connect(function()
                    U.Tw(ob,{BackgroundTransparency=0.65,TextColor3=G.Blue},TW.FAST)
                end)
                ob.MouseLeave:Connect(function()
                    U.Tw(ob,{BackgroundTransparency=0.90,TextColor3=G.TextDim},TW.FAST)
                end)
                ob.MouseButton1Click:Connect(function()
                    selected=opt; sl3.Text=opt
                    open=false; lf.Visible=false
                    if cb then pcall(cb,opt) end
                end)
            end
        end
        return o
    end

    function Tab:AddMultiCombobox(nm, desc, options, defaults, cb)
        local selected={}
        if defaults then for _,v in ipairs(defaults) do selected[v]=true end end
        local open=false
        local card,_=U.Card(cf,58,13)
        card.LayoutOrder=nextOrder(); card.ClipsDescendants=false

        U.NameDesc(card,nm,desc,165)

        local function GetText()
            local t={}
            for _,opt in ipairs(options) do
                if selected[opt] then table.insert(t,opt) end
            end
            if #t==0 then return "None"
            elseif #t==1 then return t[1]
            else return t[1].." +"..tostring(#t-1) end
        end

        local hdr=Instance.new("TextButton")
        hdr.Size=UDim2.new(0,140,0,32); hdr.Position=UDim2.new(1,-152,0.5,-16)
        hdr.BackgroundColor3=Color3.fromRGB(255,255,255)
        hdr.BackgroundTransparency=0.85; hdr.Text=""
        hdr.ZIndex=16; hdr.BorderSizePixel=0; hdr.Parent=card
        U.Rnd(hdr,UDim.new(1,0)); U.Rim(hdr,G.Rim,1,0.35)

        local sl4=U.Lbl(hdr,GetText(),12,Enum.Font.GothamSemibold,G.Blue,17)
        sl4.Size=UDim2.new(1,-28,1,0); sl4.Position=UDim2.new(0,10,0,0)

        local arr2=U.Lbl(hdr,"v",11,Enum.Font.GothamBold,G.TextGhost,17)
        arr2.Size=UDim2.new(0,20,1,0); arr2.Position=UDim2.new(1,-22,0,0)
        arr2.TextXAlignment=Enum.TextXAlignment.Center

        local lh=math.min(#options,6)*36+10
        local lf=Instance.new("Frame")
        lf.Size=UDim2.new(0,140,0,lh); lf.Position=UDim2.new(1,-152,1,6)
        lf.BackgroundColor3=Color3.fromRGB(15,18,32)
        lf.BackgroundTransparency=0.12; lf.ZIndex=30
        lf.Visible=false; lf.ClipsDescendants=true
        lf.BorderSizePixel=0; lf.Parent=card
        U.Rnd(lf,UDim.new(0,14)); U.Rim(lf,G.Rim,1,0.28)

        local ll=Instance.new("UIListLayout")
        ll.SortOrder=Enum.SortOrder.LayoutOrder; ll.Padding=UDim.new(0,2); ll.Parent=lf
        local lp=Instance.new("UIPadding")
        lp.PaddingTop=UDim.new(0,5); lp.PaddingLeft=UDim.new(0,5); lp.PaddingRight=UDim.new(0,5)
        lp.Parent=lf

        local checkframes={}
        for i,opt in ipairs(options or {}) do
            local row=Instance.new("TextButton")
            row.Size=UDim2.new(1,0,0,32)
            row.BackgroundColor3=Color3.fromRGB(255,255,255)
            row.BackgroundTransparency=selected[opt] and 0.72 or 0.92
            row.Text=""; row.ZIndex=31
            row.BorderSizePixel=0; row.LayoutOrder=i; row.Parent=lf
            U.Rnd(row,UDim.new(0,10))

            local chk=Instance.new("Frame")
            chk.Size=UDim2.new(0,18,0,18); chk.Position=UDim2.new(0,6,0.5,-9)
            chk.BackgroundColor3=selected[opt] and G.Blue or G.TrackOff
            chk.BackgroundTransparency=selected[opt] and 0.15 or 0.55
            chk.ZIndex=32; chk.BorderSizePixel=0; chk.Parent=row
            U.Rnd(chk,UDim.new(0,5))
            U.Rim(chk,selected[opt] and G.Blue or G.TextGhost,1,0.45)

            local tick=U.Lbl(chk,"v",11,Enum.Font.GothamBold,Color3.fromRGB(255,255,255),33)
            tick.Size=UDim2.new(1,0,1,0); tick.TextXAlignment=Enum.TextXAlignment.Center
            tick.BackgroundTransparency=1
            tick.TextTransparency=selected[opt] and 0 or 1

            local ol=U.Lbl(row,opt,12,Enum.Font.Gotham,selected[opt] and G.Blue or G.TextDim,32)
            ol.Size=UDim2.new(1,-32,1,0); ol.Position=UDim2.new(0,30,0,0)

            checkframes[opt]={row=row,chk=chk,tick=tick,ol=ol}

            row.MouseEnter:Connect(function()
                U.Tw(row,{BackgroundTransparency=selected[opt] and 0.60 or 0.82},TW.FAST)
            end)
            row.MouseLeave:Connect(function()
                U.Tw(row,{BackgroundTransparency=selected[opt] and 0.72 or 0.92},TW.FAST)
            end)
            row.MouseButton1Click:Connect(function()
                selected[opt]=not selected[opt]
                local s=selected[opt]
                U.Tw(chk,{BackgroundColor3=s and G.Blue or G.TrackOff,BackgroundTransparency=s and 0.15 or 0.55},TW.MORPH)
                U.Tw(tick,{TextTransparency=s and 0 or 1},TW.FAST)
                U.Tw(ol,{TextColor3=s and G.Blue or G.TextDim},TW.FAST)
                U.Tw(row,{BackgroundTransparency=s and 0.72 or 0.92},TW.FAST)
                U.Rim(chk,s and G.Blue or G.TextGhost,1,s and 0.35 or 0.55)
                sl4.Text=GetText()
                if cb then
                    local out={}
                    for _,o2 in ipairs(options) do
                        if selected[o2] then table.insert(out,o2) end
                    end
                    pcall(cb,out)
                end
            end)
        end

        hdr.MouseButton1Click:Connect(function()
            open=not open; lf.Visible=open
            U.Tw(arr2,{Rotation=open and 180 or 0},TW.FAST)
            U.Tw(hdr,{BackgroundTransparency=open and 0.70 or 0.85},TW.FAST)
        end)

        local o={Selected=selected}
        function o:GetSelected()
            local out={}
            for _,opt in ipairs(options) do
                if selected[opt] then table.insert(out,opt) end
            end
            return out
        end
        function o:SetSelected(arr)
            selected={}
            for _,v in ipairs(arr) do selected[v]=true end
            for opt,frames in pairs(checkframes) do
                local s=selected[opt] or false
                frames.chk.BackgroundColor3=s and G.Blue or G.TrackOff
                frames.chk.BackgroundTransparency=s and 0.15 or 0.55
                frames.tick.TextTransparency=s and 0 or 1
                frames.ol.TextColor3=s and G.Blue or G.TextDim
                frames.row.BackgroundTransparency=s and 0.72 or 0.92
            end
            sl4.Text=GetText()
        end
        return o
    end

    function Tab:AddTextbox(nm, desc, placeholder, cb)
        local card,_=U.Card(cf,72,13)
        card.LayoutOrder=nextOrder()

        local nl=U.Lbl(card,nm,14,Enum.Font.GothamSemibold,G.TextBright,15)
        nl.Size=UDim2.new(1,-20,0,20); nl.Position=UDim2.new(0,16,0,8)
        if desc then
            local d=U.Lbl(card,desc,10,Enum.Font.Gotham,G.TextGhost,15)
            d.Size=UDim2.new(1,-20,0,13); d.Position=UDim2.new(0,16,0,26)
        end

        local ih=Instance.new("Frame")
        ih.Size=UDim2.new(1,-32,0,28); ih.Position=UDim2.new(0,16,1,-36)
        ih.BackgroundColor3=Color3.fromRGB(10,14,26)
        ih.BackgroundTransparency=0.25; ih.ZIndex=15
        ih.BorderSizePixel=0; ih.Parent=card
        U.Rnd(ih,UDim.new(0,10)); U.Rim(ih,G.Rim,1,0.55)

        local tb=Instance.new("TextBox")
        tb.Size=UDim2.new(1,-16,1,0); tb.Position=UDim2.new(0,8,0,0)
        tb.BackgroundTransparency=1; tb.Text=""
        tb.PlaceholderText=placeholder or "Type..."
        tb.PlaceholderColor3=G.TextGhost; tb.TextColor3=G.TextBright
        tb.TextSize=13; tb.Font=Enum.Font.Gotham
        tb.TextXAlignment=Enum.TextXAlignment.Left
        tb.ClearTextOnFocus=false; tb.ZIndex=16; tb.Parent=ih

        tb.Focused:Connect(function()
            U.Tw(ih,{BackgroundTransparency=0.10},TW.FAST)
            U.Rim(ih,G.Blue,1.5,0.25)
        end)
        tb.FocusLost:Connect(function(enter)
            U.Tw(ih,{BackgroundTransparency=0.25},TW.FAST)
            U.Rim(ih,G.Rim,1,0.55)
            if cb then pcall(cb,tb.Text,enter) end
        end)
        return tb
    end

    function Tab:AddKeybind(nm, desc, default, cb)
        local key=default or Enum.KeyCode.Unknown
        local waiting=false
        local card,_=U.Card(cf,58,13)
        card.LayoutOrder=nextOrder()
        U.NameDesc(card,nm,desc,148)

        local pill=Instance.new("TextButton")
        pill.Size=UDim2.new(0,126,0,32); pill.Position=UDim2.new(1,-138,0.5,-16)
        pill.BackgroundColor3=Color3.fromRGB(255,255,255)
        pill.BackgroundTransparency=0.87
        pill.Text=key==Enum.KeyCode.Unknown and "None" or key.Name
        pill.TextColor3=G.Blue; pill.TextSize=12
        pill.Font=Enum.Font.GothamSemibold
        pill.ZIndex=16; pill.BorderSizePixel=0; pill.Parent=card
        U.Rnd(pill,UDim.new(1,0)); U.Rim(pill,G.Blue,1,0.40)
        U.Glow(pill,G.Blue,16)

        pill.MouseEnter:Connect(function()
            U.Tw(pill,{BackgroundTransparency=0.70},TW.FAST)
        end)
        pill.MouseLeave:Connect(function()
            if not waiting then U.Tw(pill,{BackgroundTransparency=0.87},TW.FAST) end
        end)
        pill.MouseButton1Click:Connect(function()
            if waiting then return end
            waiting=true; pill.Text="Press..."
            pill.TextColor3=G.Orange
            U.Rim(pill,G.Orange,1,0.30)
            local conn
            conn=UserInputService.InputBegan:Connect(function(i,gpe)
                if gpe then return end
                if i.UserInputType==Enum.UserInputType.Keyboard then
                    key=i.KeyCode; waiting=false
                    pill.Text=key.Name; pill.TextColor3=G.Blue
                    U.Rim(pill,G.Blue,1,0.40)
                    conn:Disconnect()
                    if cb then pcall(cb,key) end
                end
            end)
        end)

        local o={Value=key}
        function o:Set(k) key=k; pill.Text=k.Name; o.Value=k end
        return o
    end

    function Tab:AddColorPicker(nm, desc, default, cb)
        local color=default or Color3.fromRGB(100,180,255)
        local open=false; local pp
        local card,_=U.Card(cf,58,13)
        card.LayoutOrder=nextOrder(); card.ClipsDescendants=false
        U.NameDesc(card,nm,desc,90)

        local prev=Instance.new("Frame")
        prev.Size=UDim2.new(0,38,0,38); prev.Position=UDim2.new(1,-54,0.5,-19)
        prev.BackgroundColor3=color; prev.ZIndex=16
        prev.BorderSizePixel=0; prev.Parent=card
        U.Rnd(prev,UDim.new(0,12)); U.Rim(prev,G.Rim,1.5,0.30)
        U.Shine(prev,17)

        local function BuildPicker()
            pp=Instance.new("Frame")
            pp.Size=UDim2.new(1,0,0,120); pp.Position=UDim2.new(0,0,1,6)
            pp.BackgroundColor3=Color3.fromRGB(12,15,28)
            pp.BackgroundTransparency=0.12; pp.ZIndex=25
            pp.BorderSizePixel=0; pp.ClipsDescendants=true; pp.Parent=card
            U.Rnd(pp,UDim.new(0,14)); U.Rim(pp,G.Rim,1,0.30)

            local vals={color.R*255,color.G*255,color.B*255}
            local chs={
                {n="R",c=Color3.fromRGB(255,80,80),  i=1},
                {n="G",c=Color3.fromRGB(80,220,120), i=2},
                {n="B",c=Color3.fromRGB(80,160,255), i=3},
            }
            local function Rebuild()
                color=Color3.fromRGB(vals[1],vals[2],vals[3])
                prev.BackgroundColor3=color
                if cb then pcall(cb,color) end
            end
            for _,ch in ipairs(chs) do
                local row=Instance.new("Frame")
                row.Size=UDim2.new(1,-16,0,28)
                row.Position=UDim2.new(0,8,0,8+(ch.i-1)*36)
                row.BackgroundTransparency=1; row.ZIndex=26; row.Parent=pp

                local cl2=U.Lbl(row,ch.n,11,Enum.Font.GothamBold,ch.c,27)
                cl2.Size=UDim2.new(0,14,1,0)

                local tr=Instance.new("Frame")
                tr.Size=UDim2.new(1,-58,0,6); tr.Position=UDim2.new(0,18,0.5,-3)
                tr.BackgroundColor3=Color3.fromRGB(40,45,70)
                tr.BackgroundTransparency=0.20; tr.ZIndex=26
                tr.BorderSizePixel=0; tr.Parent=row
                U.Rnd(tr,UDim.new(1,0))

                local fi=Instance.new("Frame")
                fi.Size=UDim2.new(vals[ch.i]/255,0,1,0)
                fi.BackgroundColor3=ch.c; fi.ZIndex=27
                fi.BorderSizePixel=0; fi.Parent=tr
                U.Rnd(fi,UDim.new(1,0))

                local th=Instance.new("Frame")
                th.Size=UDim2.new(0,12,0,12); th.AnchorPoint=Vector2.new(0.5,0.5)
                th.Position=UDim2.new(vals[ch.i]/255,0,0.5,0)
                th.BackgroundColor3=Color3.fromRGB(255,255,255)
                th.ZIndex=28; th.BorderSizePixel=0; th.Parent=tr
                U.Rnd(th,UDim.new(1,0))

                local vl2=U.Lbl(row,tostring(math.floor(vals[ch.i])),10,Enum.Font.Gotham,G.TextDim,27)
                vl2.Size=UDim2.new(0,32,1,0); vl2.Position=UDim2.new(1,-32,0,0)
                vl2.TextXAlignment=Enum.TextXAlignment.Right

                local dc=false
                tr.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then dc=true end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then dc=false end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if dc and i.UserInputType==Enum.UserInputType.MouseMovement then
                        local ap=tr.AbsolutePosition; local as=tr.AbsoluteSize
                        local rel=math.clamp((i.Position.X-ap.X)/as.X,0,1)
                        vals[ch.i]=math.floor(rel*255)
                        vl2.Text=tostring(vals[ch.i])
                        U.Tw(fi,{Size=UDim2.new(rel,0,1,0)},TW.FAST)
                        U.Tw(th,{Position=UDim2.new(rel,0,0.5,0)},TW.FAST)
                        Rebuild()
                    end
                end)
            end
        end

        local cb2=Instance.new("TextButton")
        cb2.Size=UDim2.new(0,38,0,38); cb2.Position=UDim2.new(1,-54,0.5,-19)
        cb2.BackgroundTransparency=1; cb2.Text=""
        cb2.ZIndex=18; cb2.Parent=card
        cb2.MouseButton1Click:Connect(function()
            open=not open
            if open then
                BuildPicker()
                U.Tw(card,{Size=UDim2.new(1,0,0,188)},TW.MORPH)
            else
                if pp then pcall(function() pp:Destroy() end); pp=nil end
                U.Tw(card,{Size=UDim2.new(1,0,0,58)},TW.MORPH)
            end
        end)

        local o={Value=color}
        function o:Set(c)
            color=c; prev.BackgroundColor3=c; o.Value=c
            if cb then pcall(cb,c) end
        end
        return o
    end

    function Tab:AddDivider()
        local f=Instance.new("Frame")
        f.Size=UDim2.new(1,0,0,14); f.BackgroundTransparency=1
        f.ZIndex=13; f.LayoutOrder=nextOrder(); f.Parent=cf
        local ln=Instance.new("Frame")
        ln.Size=UDim2.new(0.85,0,0,1); ln.Position=UDim2.new(0.075,0,0.5,0)
        ln.BackgroundColor3=G.Rim; ln.BackgroundTransparency=0.68
        ln.ZIndex=14; ln.BorderSizePixel=0; ln.Parent=f
        U.Grad(ln,{
            ColorSequenceKeypoint.new(0,  Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.5,G.GlowAccent),
            ColorSequenceKeypoint.new(1,  Color3.fromRGB(255,255,255)),
        },{
            NumberSequenceKeypoint.new(0,  1),
            NumberSequenceKeypoint.new(0.5,0.45),
            NumberSequenceKeypoint.new(1,  1),
        },0)
    end

    function Tab:AddInfoBox(txt, style)
        style=style or "info"
        local accent=({info=G.Blue,success=G.Green,warn=G.Orange,error=G.Red})[style] or G.Blue
        local fr=Instance.new("Frame")
        fr.Size=UDim2.new(1,0,0,42); fr.BackgroundColor3=Color3.fromRGB(255,255,255)
        fr.BackgroundTransparency=0.90; fr.ZIndex=13
        fr.BorderSizePixel=0; fr.LayoutOrder=nextOrder(); fr.Parent=cf
        U.Rnd(fr,UDim.new(0,12)); U.Rim(fr,accent,1,0.38)
        U.Lens(fr,13)

        local bar=Instance.new("Frame")
        bar.Size=UDim2.new(0,3,0.6,0); bar.Position=UDim2.new(0,6,0.2,0)
        bar.BackgroundColor3=accent; bar.ZIndex=15
        bar.BorderSizePixel=0; bar.Parent=fr
        U.Rnd(bar,UDim.new(1,0)); U.Glow(bar,accent,15)

        local lb=U.Lbl(fr,txt,12,Enum.Font.Gotham,G.TextDim,15)
        lb.Size=UDim2.new(1,-24,1,0); lb.Position=UDim2.new(0,18,0,0)
        lb.TextWrapped=true

        local o={}
        function o:Set(t) lb.Text=t end
        return o
    end

    return Tab
end

function LiquidGlass:Notify(title, message, ntype, duration)
    duration=duration or 4; ntype=ntype or "info"
    local accent=({info=G.Blue,success=G.Green,error=G.Red,warning=G.Orange})[ntype] or G.Blue

    local card=Instance.new("Frame")
    card.Name="Notif"; card.Size=UDim2.new(1,0,0,80)
    card.BackgroundColor3=Color3.fromRGB(12,15,28)
    card.BackgroundTransparency=0.12; card.ZIndex=9999
    card.BorderSizePixel=0; card.Parent=self.NotifGui
    U.Rnd(card,UDim.new(0,18)); U.Rim(card,accent,1.2,0.25)
    U.Shine(card,10000); U.Glow(card,accent,9999); U.Lens(card,9999)
    U.Grad(card,{
        ColorSequenceKeypoint.new(0,Color3.fromRGB(28,32,58)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(12,15,28)),
    },{
        NumberSequenceKeypoint.new(0,0.18),
        NumberSequenceKeypoint.new(1,0.08),
    },140)

    local ab=Instance.new("Frame")
    ab.Size=UDim2.new(0,3,0.65,0); ab.Position=UDim2.new(0,8,0.175,0)
    ab.BackgroundColor3=accent; ab.ZIndex=10001
    ab.BorderSizePixel=0; ab.Parent=card
    U.Rnd(ab,UDim.new(1,0)); U.Glow(ab,accent,10001)

    local tl2=U.Lbl(card,title or "Notice",14,Enum.Font.GothamBold,G.TextBright,10001)
    tl2.Size=UDim2.new(1,-40,0,22); tl2.Position=UDim2.new(0,20,0,12)

    local ml=U.Lbl(card,message or "",12,Enum.Font.Gotham,G.TextDim,10001)
    ml.Size=UDim2.new(1,-40,0,32); ml.Position=UDim2.new(0,20,0,36)
    ml.TextWrapped=true

    local pg=Instance.new("Frame")
    pg.Size=UDim2.new(1,-16,0,2); pg.Position=UDim2.new(0,8,1,-6)
    pg.BackgroundColor3=accent; pg.BackgroundTransparency=0.20
    pg.ZIndex=10002; pg.BorderSizePixel=0; pg.Parent=card
    U.Rnd(pg,UDim.new(1,0))

    card.Position=UDim2.new(1,30,0,0)
    U.Tw(card,{Position=UDim2.new(0,0,0,0)},MT(0.55,Enum.EasingStyle.Back,Enum.EasingDirection.Out))
    U.Tw(pg,{Size=UDim2.new(0,0,0,2)},MT(duration,Enum.EasingStyle.Linear,Enum.EasingDirection.In))

    task.delay(duration,function()
        U.Tw(card,{Position=UDim2.new(1,30,0,0)},TW.CLOSE)
        task.delay(0.5,function()
            if card and card.Parent then card:Destroy() end
        end)
    end)
    return card
end

function LiquidGlass:Destroy()
    for _,c in ipairs(self.Connections) do pcall(function() c:Disconnect() end) end
    self.Connections={}
    if DepthOfField then DepthOfField.Enabled=false end
    if BloomFX then BloomFX.Enabled=false end
    if ColorFX then ColorFX.Enabled=false end
    if self.ScreenGui and self.ScreenGui.Parent then self.ScreenGui:Destroy() end
end

return LiquidGlass
