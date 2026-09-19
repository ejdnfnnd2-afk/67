--[[
    UAI Easy Library V13 • SPECTRAL LUXE INFINITE
    UAI-inspired adaptive glass UI with cinematic depth, prismatic crystal lighting, layered surfaces, premium navigation and high-end micro-interactions.

    API:
      local Library = loadstring(...)()
      local Window = Library:AddWindow("Title", config)
      local Tab = Window:AddTab("Main")
      Tab:AddButton("Button", function() end)
      Tab:AddSwitch("Switch", function(value) end)
      Tab:AddLabel("Text")
      Tab:AddTextBox("Placeholder", function(text) end)
      Tab:AddSlider("Speed", function(value) end, {min=0,max=100,default=50})
      Tab:AddDropdown("Mode", function(value) end):Add("One")
      Tab:AddKeybind("Action", function(key) end, {default=Enum.KeyCode.RightShift}) -- callback al pulsar; options.onBind para cambios
      local Folder = Tab:AddFolder("Folder")
      Folder:AddLabel("Contenido")
      Window:Toggle()
      Window:SetVisible(true)
      Window:SetTheme("Midnight")
      Window:AddNotification("Title", "Message", 3)
      Window:Destroy()

    This is intentionally independent from UAI's agent/runtime modules.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

local function getParent()
    if type(gethui) == "function" then
        local ok, gui = pcall(gethui)
        if ok and gui then return gui end
    end
    return CoreGui
end

local Library = {}
Library.__index = Library

local DEFAULTS = {
    main_color = Color3.fromRGB(100, 180, 255),
    background = Color3.fromRGB(20, 21, 24),
    surface = Color3.fromRGB(27, 29, 33),
    surface2 = Color3.fromRGB(34, 36, 41),
    text = Color3.fromRGB(235, 237, 242),
    muted = Color3.fromRGB(145, 150, 160),
    border = Color3.fromRGB(54, 57, 64),
    min_size = Vector2.new(500, 350),
    size = Vector2.new(720, 500),
    toggle_key = Enum.KeyCode.RightShift,
    can_resize = true,
    tween_time = 0.16,
    title_bar = true,
    transparency = 0,
    click_sound = true,
    click_sound_id = "rbxassetid://113397864512278", -- UI Click 1 (short)
    click_volume = 0.18,
    glow = true,
    animated = true,

    -- Animaciones avanzadas
    entrance_animation = true,
    hover_animation = true,
    tab_animation = true,
    pulse_animation = true,
    card_animation = true,
    animation_speed = 0.22,

    -- Visuales ULTRA
    glass = true,
    particles = true,
    particle_count = 18,
    ambient_glow = true,
    neon_border = true,
    scanline = true,
    floating_orbs = true,
    sidebar_glow = true,
    rounded_ui = true,
    depth_shadow = true,

    -- Ventana holográfica
    holographic_window = true,
    animated_frame = true,
    corner_lights = true,
    top_orb = true,
    energy_line = true,
    inner_glow = true,
    window_breath = true,
    glass_highlight = true,

    -- Premium modern UI
    modern_sidebar = true,
    sidebar_width = 190,
    show_tab_icons = true,
    show_search = true,
    show_subtitle = true,
    clean_background = true,
    pill_tabs = true,
    micro_interactions = true,
    responsive = true,
    responsive_min_scale = 0.78,
    responsive_max_scale = 1.04,
    focus_ring = true,
    tooltips = true,
    theme_name = "Dark",
    accent_style = "Solid",
    search_placeholder = "  Buscar pestaña...",
    subtitle = "Premium Interface",
    status_text = "ONLINE",
    show_close_button = true,
    show_minimize_button = true,
    escape_to_close = true,
    draggable = true,

    -- V10 Aurora visual system
    aurora = true,
    aurora_intensity = 0.34,
    background_blur = true,
    glass_opacity = 0.08,
    card_highlight = true,
    card_gradient = true,
    active_nav_glow = true,
    active_nav_indicator = true,
    content_header = true,
    content_header_height = 54,
    section_dividers = true,
    premium_shadows = true,
    animated_background = true,
    cursor_glow = true,
    soft_noise = true,
    compact_controls = true,
    control_radius = 9,

    -- V11 "Luxe Prism" visual layer
    luxe_prism = true,
    prism_intensity = 0.9,
    card_lift = true,
    card_spotlight = true,
    card_sheen = true,
    animated_strokes = true,
    nav_glass = true,
    nav_active_fill = true,
    header_orbit = true,
    header_badge = true,
    chrome_controls = true,
    ambient_particles = true,
    particle_count_v11 = 14,
    vignette = true,
    content_fade = true,
    button_shine = true,
    slider_glow = true,
    input_focus_glow = true,
    status_pill = true,
    density = "comfortable",

    -- V12 "Nebula Crystal" elite visual layer
    nebula_crystal = true,
    crystal_intensity = 1.0,
    prism_spectrum = true,
    specular_sweep = true,
    crystal_corners = true,
    glass_depth = true,
    ambient_bloom = true,
    ambient_bloom_count = 5,
    animated_surface = true,
    surface_shimmer = true,
    nav_chrome = true,
    nav_particles = true,
    control_depth = true,
    control_ripple = true,
    premium_header = true,
    header_lighting = true,
    edge_lighting = true,
    focus_bloom = true,

    -- V13 "Spectral Luxe" visual layer
    spectral_luxe = true,
    spectral_intensity = 1.0,
    chroma_frame = true,
    glass_refraction = true,
    cinematic_lighting = true,
    edge_bevel = true,
    topographic_glow = true,
    luxury_badges = true,
    nav_depth = true,
    content_depth = true,
    ambient_rings = true,
    starfield = true,
    starfield_count = 22,
    motion_accents = true,
}

local function merge(a, b)
    local r = {}
    for k,v in pairs(a) do r[k] = v end
    for k,v in pairs(b or {}) do r[k] = v end
    return r
end

local function new(class, props, parent)
    local x = Instance.new(class)
    for k,v in pairs(props or {}) do
        pcall(function() x[k] = v end)
    end
    x.Parent = parent
    return x
end

local function corner(parent, radius)
    return new("UICorner", {CornerRadius = UDim.new(0, radius or 8)}, parent)
end

local function stroke(parent, color, transparency)
    return new("UIStroke", {
        Color = color,
        Transparency = transparency or 0,
        Thickness = 1,
    }, parent)
end

local function pad(parent, l, r, t, b)
    return new("UIPadding", {
        PaddingLeft = UDim.new(0,l or 0),
        PaddingRight = UDim.new(0,r or 0),
        PaddingTop = UDim.new(0,t or 0),
        PaddingBottom = UDim.new(0,b or 0),
    }, parent)
end

local function tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local TAB_ICONS = {
    Home="⌂", Dashboard="◆", Main="●", Controls="◈",
    Visual="✦", Tools="⚙", Settings="⚙", Info="ⓘ",
    Farm="◆", Pets="◇", Player="●"
}

local function getTabIcon(name)
    return TAB_ICONS[name] or "•"
end

local function addSearchBox(parent, config, callback)
    if not config.show_search then return nil end

    local box = new("TextBox", {
        Name = "SearchBox",
        Size = UDim2.new(1,-20,0,32),
        Position = UDim2.fromOffset(10,8),
        BackgroundColor3 = config.surface2,
        BackgroundTransparency = .12,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = config.search_placeholder or "  Buscar pestaña...",
        PlaceholderColor3 = config.muted,
        TextColor3 = config.text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ClearTextOnFocus = false,
        ZIndex = 20,
        LayoutOrder = -100,
    }, parent)

    addCorner(box, 9)

    box.Focused:Connect(function()
        tween(box, TweenInfo.new(.15, Enum.EasingStyle.Quad), {
            BackgroundTransparency = .02
        })
    end)

    box.FocusLost:Connect(function()
        tween(box, TweenInfo.new(.18, Enum.EasingStyle.Quad), {
            BackgroundTransparency = .12
        })
    end)

    box:GetPropertyChangedSignal("Text"):Connect(function()
        if callback then callback(box.Text) end
    end)

    return box
end


local function addTooltip(guiObject, text, config)
    if not config.tooltips or not guiObject then return end
    local tip
    guiObject.MouseEnter:Connect(function()
        if tip then return end
        tip = new("TextLabel", {
            Name = "Tooltip",
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromOffset(0,26),
            Position = UDim2.new(1,8,.5,-13),
            BackgroundColor3 = config.surface2,
            BackgroundTransparency = .03,
            Text = tostring(text),
            TextColor3 = config.text,
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 500,
        }, guiObject.Parent)
        addCorner(tip, 7)
        stroke(tip, config.border, .25)
        pad(tip, 9, 9, 0, 0)
        tip.TextTransparency = 1
        tween(tip, TweenInfo.new(.12, Enum.EasingStyle.Quad), {TextTransparency = 0})
    end)
    guiObject.MouseLeave:Connect(function()
        if tip then
            local old = tip
            tip = nil
            tween(old, TweenInfo.new(.10, Enum.EasingStyle.Quad), {TextTransparency = 1})
            task.delay(.11, function()
                if old then old:Destroy() end
            end)
        end
    end)
end

local function modernTabHover(button, config)
    if not config.micro_interactions then return end
    local scale = addScale(button, 1)
    button.MouseEnter:Connect(function()
        tween(scale, TweenInfo.new(.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Scale = 1.025
        })
    end)
    button.MouseLeave:Connect(function()
        tween(scale, TweenInfo.new(.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Scale = 1
        })
    end)
end

local function addHoloCorner(parent, config, side)
    if not config.corner_lights then return end
    local holder = new("Frame", {
        Name = "CornerLight_" .. side,
        Size = UDim2.fromOffset(34, 3),
        BackgroundColor3 = config.main_color,
        BackgroundTransparency = .08,
        BorderSizePixel = 0,
        ZIndex = 20,
    }, parent)
    new("UICorner", {CornerRadius = UDim.new(1,0)}, holder)

    local holder2 = new("Frame", {
        Size = UDim2.fromOffset(3, 34),
        BackgroundColor3 = Color3.fromRGB(175,75,255),
        BackgroundTransparency = .08,
        BorderSizePixel = 0,
        ZIndex = 20,
    }, parent)
    new("UICorner", {CornerRadius = UDim.new(1,0)}, holder2)

    if side == "TL" then
        holder.Position = UDim2.fromOffset(10,10)
        holder2.Position = UDim2.fromOffset(10,10)
    elseif side == "TR" then
        holder.AnchorPoint = Vector2.new(1,0)
        holder.Position = UDim2.new(1,-10,0,10)
        holder2.AnchorPoint = Vector2.new(1,0)
        holder2.Position = UDim2.new(1,-10,0,10)
    elseif side == "BL" then
        holder.Position = UDim2.new(0,10,1,-13)
        holder2.Position = UDim2.new(0,10,1,-44)
    else
        holder.AnchorPoint = Vector2.new(1,1)
        holder.Position = UDim2.new(1,-10,1,-13)
        holder2.AnchorPoint = Vector2.new(1,1)
        holder2.Position = UDim2.new(1,-10,1,-44)
    end

    task.spawn(function()
        while holder and holder.Parent do
            tween(holder, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = .55
            })
            tween(holder2, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = .65
            })
            task.wait(1.1)
            if not (holder and holder.Parent) then break end
            tween(holder, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = .08
            })
            tween(holder2, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = .08
            })
            task.wait(1.1)
        end
    end)
end

local function addWindowEnergyLine(parent, config)
    if not config.energy_line then return end
    local line = new("Frame", {
        Name = "EnergyLine",
        Size = UDim2.new(0, 90, 0, 1),
        Position = UDim2.new(0, -100, 0, 2),
        BackgroundColor3 = config.main_color,
        BackgroundTransparency = .05,
        BorderSizePixel = 0,
        ZIndex = 30,
    }, parent)
    new("UICorner", {CornerRadius = UDim.new(1,0)}, line)

    local glow = new("Frame", {
        Size = UDim2.new(1, 18, 0, 5),
        Position = UDim2.new(0,-9,0,-2),
        BackgroundColor3 = Color3.fromRGB(175,75,255),
        BackgroundTransparency = .82,
        BorderSizePixel = 0,
        ZIndex = 29,
    }, line)
    new("UICorner", {CornerRadius = UDim.new(1,0)}, glow)

    task.spawn(function()
        while line and line.Parent do
            line.Position = UDim2.new(0,-100,0,2)
            tween(line, TweenInfo.new(2.6, Enum.EasingStyle.Linear), {
                Position = UDim2.new(1,10,0,2)
            })
            task.wait(2.7)
        end
    end)
end

local function addGlassHighlight(parent, config)
    if not config.glass_highlight then return end
    local shine = new("Frame", {
        Name = "GlassHighlight",
        Size = UDim2.new(.42,0,1,-20),
        Position = UDim2.new(-.5,0,0,10),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = .96,
        BorderSizePixel = 0,
        Rotation = 8,
        ZIndex = 3,
    }, parent)

    task.spawn(function()
        while shine and shine.Parent do
            shine.Position = UDim2.new(-.5,0,0,10)
            tween(shine, TweenInfo.new(3.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(1.15,0,0,10)
            })
            task.wait(4.2)
        end
    end)
end

local function addWindowBreath(parent, config)
    if not config.window_breath then return end
    local stroke = parent:FindFirstChild("NeonStroke")
    if not stroke then return end

    task.spawn(function()
        while parent and parent.Parent do
            tween(stroke, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = .32
            })
            task.wait(1.8)
            if not (parent and parent.Parent) then break end
            tween(stroke, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = .08
            })
            task.wait(1.8)
        end
    end)
end

local function addCorner(parent, radius)
    if not parent then return end
    local c = parent:FindFirstChildOfClass("UICorner")
    if not c then
        c = new("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, parent)
    else
        c.CornerRadius = UDim.new(0, radius or 10)
    end
    return c
end

local function addShadow(parent, transparency, blur, offset)
    if not parent then return end
    local shadow = new("ImageLabel", {
        Name = "SoftShadow",
        AnchorPoint = Vector2.new(.5,.5),
        Position = UDim2.new(.5, offset or 8, .5, offset or 10),
        Size = UDim2.new(1, 28, 1, 28),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageTransparency = transparency or .55,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49,49,450,450),
        ZIndex = math.max((parent.ZIndex or 1) - 1, 0),
    }, parent)
    return shadow
end

local function addNeonStroke(parent, color1, color2, thickness)
    if not parent then return end
    local s = parent:FindFirstChild("NeonStroke")
    if not s then
        s = new("UIStroke", {
            Name = "NeonStroke",
            Thickness = thickness or 1,
            Transparency = .12,
            Color = color1 or Color3.fromRGB(0, 200, 255),
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, parent)
    end

    local g = s:FindFirstChildOfClass("UIGradient")
    if not g then
        g = new("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, color1 or Color3.fromRGB(0,200,255)),
                ColorSequenceKeypoint.new(.5, color2 or Color3.fromRGB(170,70,255)),
                ColorSequenceKeypoint.new(1, color1 or Color3.fromRGB(0,200,255)),
            })
        }, s)
    end
    return s
end

local function addScanline(parent, config)
    if not config.scanline then return end
    local line = new("Frame", {
        Name = "Scanline",
        Size = UDim2.new(1,0,0,1),
        Position = UDim2.new(0,0,0,-2),
        BackgroundColor3 = config.main_color,
        BackgroundTransparency = .72,
        BorderSizePixel = 0,
        ZIndex = 50,
    }, parent)

    task.spawn(function()
        while line and line.Parent do
            line.Position = UDim2.new(0,0,0,-2)
            tween(line, TweenInfo.new(2.8, Enum.EasingStyle.Linear), {
                Position = UDim2.new(0,0,1,2)
            })
            task.wait(2.9)
        end
    end)
end

local function addFloatingOrbs(parent, config)
    if not config.floating_orbs then return end
    for i = 1, 5 do
        local orb = new("Frame", {
            Name = "Orb"..i,
            Size = UDim2.fromOffset(2 + i%3, 2 + i%3),
            Position = UDim2.new(.12 + i*.15, 0, .18 + (i%3)*.22, 0),
            BackgroundColor3 = i%2 == 0 and config.main_color or Color3.fromRGB(175,75,255),
            BackgroundTransparency = .28,
            BorderSizePixel = 0,
            ZIndex = 1,
        }, parent)
        new("UICorner", {CornerRadius = UDim.new(1,0)}, orb)

        task.spawn(function()
            while orb and orb.Parent do
                local p = orb.Position
                tween(orb, TweenInfo.new(2.2 + i*.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Position = p + UDim2.fromOffset(0, i%2 == 0 and 12 or -12)
                })
                task.wait(2.2 + i*.25)
                if not (orb and orb.Parent) then break end
                tween(orb, TweenInfo.new(2.2 + i*.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Position = p
                })
                task.wait(2.2 + i*.25)
            end
        end)
    end
end

local function addParticles(parent, config)
    if not config.particles then return end
    local count = math.clamp(config.particle_count or 18, 1, 40)
    for i = 1, count do
        local dot = new("Frame", {
            Name = "Particle"..i,
            Size = UDim2.fromOffset(math.random(1,3), math.random(1,3)),
            Position = UDim2.new(math.random(),0,math.random(),0),
            BackgroundColor3 = i%2 == 0 and config.main_color or Color3.fromRGB(175,75,255),
            BackgroundTransparency = math.random(35,75)/100,
            BorderSizePixel = 0,
            ZIndex = 2,
        }, parent)
        new("UICorner", {CornerRadius = UDim.new(1,0)}, dot)

        task.spawn(function()
            while dot and dot.Parent do
                local start = dot.Position
                local target = UDim2.new(
                    math.clamp(start.X.Scale + (math.random(-12,12)/100), 0, 1), 0,
                    math.clamp(start.Y.Scale + (math.random(-18,18)/100), 0, 1), 0
                )
                tween(dot, TweenInfo.new(math.random(18,34)/10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Position = target,
                    BackgroundTransparency = math.random(25,80)/100
                })
                task.wait(math.random(18,34)/10)
            end
        end)
    end
end

local function addScale(parent, value)
    local s = parent:FindFirstChildOfClass("UIScale")
    if not s then
        s = new("UIScale", {Scale = value or 1}, parent)
    else
        s.Scale = value or 1
    end
    return s
end

local function animateScale(parent, fromScale, toScale, duration, style, direction)
    local s = addScale(parent, fromScale)
    tween(s, TweenInfo.new(
        duration or 0.22,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    ), {Scale = toScale or 1})
    return s
end

local function hoverScale(guiObject, config, amount)
    if not config.hover_animation then return end
    local scale = addScale(guiObject, 1)
    guiObject.MouseEnter:Connect(function()
        tween(scale, TweenInfo.new(.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Scale = amount or 1.025
        })
    end)
    guiObject.MouseLeave:Connect(function()
        tween(scale, TweenInfo.new(.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Scale = 1
        })
    end)
end

local function pulse(guiObject, config, minScale, maxScale)
    if not config.pulse_animation then return end
    task.spawn(function()
        while guiObject and guiObject.Parent do
            tween(guiObject, TweenInfo.new(.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                TextTransparency = 0.12
            })
            task.wait(.8)
            if not (guiObject and guiObject.Parent) then break end
            tween(guiObject, TweenInfo.new(.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                TextTransparency = 0
            })
            task.wait(.8)
        end
    end)
end

local function animateCardIn(card, delayTime, config)
    if not config.card_animation then return end
    task.delay(delayTime or 0, function()
        if not (card and card.Parent) then return end
        local scale = addScale(card, .965)
        local originalPos = card.Position
        card.Position = originalPos + UDim2.fromOffset(12, 0)
        tween(card, TweenInfo.new(config.animation_speed, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = originalPos
        })
        tween(scale, TweenInfo.new(config.animation_speed, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Scale = 1
        })
    end)
end

local function sweepGlow(frame, config)
    if not config.animated then return end
    task.spawn(function()
        local gradient = frame:FindFirstChildOfClass("UIGradient")
        if not gradient then return end
        while frame and frame.Parent do
            gradient.Offset = Vector2.new(-1.2, 0)
            tween(gradient, TweenInfo.new(1.8, Enum.EasingStyle.Linear), {
                Offset = Vector2.new(1.2, 0)
            })
            task.wait(2.0)
        end
    end)
end

local function makeDraggable(handle, target)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and
           input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = true
        dragStart = input.Position
        startPos = target.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and
           input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - dragStart
        target.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end)
end


local function playClick(config)
    if not config or not config.click_sound or tostring(config.click_sound_id or "") == "" then return end
    local ok, sound = pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = tostring(config.click_sound_id)
        s.Volume = tonumber(config.click_volume) or 0.18
        s.PlayOnRemove = false
        s.Parent = SoundService
        return s
    end)
    if not ok or not sound then return end
    sound:Play()
    task.delay(2, function() pcall(function() sound:Destroy() end) end)
end

local function addGradient(parent, color1, color2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(color1, color2)
    g.Rotation = rotation or 0
    g.Parent = parent
    return g
end

local function addGlow(parent, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = transparency or 0.55
    s.Thickness = 2
    s.Parent = parent
    return s
end

local function addText(parent, text, size, color, font)
    return new("TextLabel", {
        BackgroundTransparency = 1,
        Text = tostring(text or ""),
        TextColor3 = color,
        TextSize = size or 14,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ClipsDescendants = true,
    }, parent)
end

local function bindCommon(control, callback)
    control.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end


local THEMES = {
    Dark = {
        background = Color3.fromRGB(15,16,20),
        surface = Color3.fromRGB(21,23,28),
        surface2 = Color3.fromRGB(29,32,39),
        text = Color3.fromRGB(242,244,248),
        muted = Color3.fromRGB(145,151,163),
        border = Color3.fromRGB(48,52,62),
        main_color = Color3.fromRGB(105,178,255),
    },
    Midnight = {
        background = Color3.fromRGB(10,13,20),
        surface = Color3.fromRGB(16,20,29),
        surface2 = Color3.fromRGB(25,30,42),
        text = Color3.fromRGB(238,242,250),
        muted = Color3.fromRGB(139,149,168),
        border = Color3.fromRGB(45,53,70),
        main_color = Color3.fromRGB(92,154,255),
    },
    Violet = {
        background = Color3.fromRGB(16,13,22),
        surface = Color3.fromRGB(23,19,31),
        surface2 = Color3.fromRGB(34,27,45),
        text = Color3.fromRGB(245,241,250),
        muted = Color3.fromRGB(158,148,173),
        border = Color3.fromRGB(60,48,75),
        main_color = Color3.fromRGB(160,112,255),
    },
    Emerald = {
        background = Color3.fromRGB(11,18,17),
        surface = Color3.fromRGB(17,27,25),
        surface2 = Color3.fromRGB(24,38,34),
        text = Color3.fromRGB(236,247,243),
        muted = Color3.fromRGB(139,163,154),
        border = Color3.fromRGB(43,67,60),
        main_color = Color3.fromRGB(76,207,153),
    },
    Crimson = {
        background = Color3.fromRGB(19,12,15),
        surface = Color3.fromRGB(29,18,22),
        surface2 = Color3.fromRGB(43,25,31),
        text = Color3.fromRGB(248,240,242),
        muted = Color3.fromRGB(169,143,150),
        border = Color3.fromRGB(70,43,50),
        main_color = Color3.fromRGB(238,92,116),
    },
    Amber = {
        background = Color3.fromRGB(20,17,11),
        surface = Color3.fromRGB(30,25,16),
        surface2 = Color3.fromRGB(44,36,22),
        text = Color3.fromRGB(248,244,232),
        muted = Color3.fromRGB(171,159,133),
        border = Color3.fromRGB(70,59,39),
        main_color = Color3.fromRGB(240,184,72),
    },
}

local function replaceColor(root, oldColor, newColor)
    if not root or not oldColor or not newColor then return end
    for _, obj in ipairs(root:GetDescendants()) do
        pcall(function()
            if obj:IsA("GuiObject") and obj.BackgroundColor3 == oldColor then
                obj.BackgroundColor3 = newColor
            end
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if obj.TextColor3 == oldColor then
                    obj.TextColor3 = newColor
                end
            end
            if obj:IsA("UIStroke") and obj.Color == oldColor then
                obj.Color = newColor
            end
        end)
    end
end

local function applyTheme(window, themeName)
    local theme = THEMES[themeName] or THEMES.Dark
    local old = window.Config
    local root = window.Root
    if not root then return end

    replaceColor(root, old.background, theme.background)
    replaceColor(root, old.surface, theme.surface)
    replaceColor(root, old.surface2, theme.surface2)
    replaceColor(root, old.text, theme.text)
    replaceColor(root, old.muted, theme.muted)
    replaceColor(root, old.border, theme.border)
    replaceColor(root, old.main_color, theme.main_color)
    replaceGradientColors(root, old.main_color, theme.main_color)

    window.Config.background = theme.background
    window.Config.surface = theme.surface
    window.Config.surface2 = theme.surface2
    window.Config.text = theme.text
    window.Config.muted = theme.muted
    window.Config.border = theme.border
    window.Config.main_color = theme.main_color
    window.Config.theme_name = themeName
    if window._cursorGlow then window._cursorGlow.BackgroundColor3 = theme.main_color end

    pcall(function()
        root.BackgroundColor3 = theme.background
    end)

    return themeName
end

local function setupResponsive(window)
    if not window.Config.responsive or not window.Root then return end

    local scale = addScale(window.Root, 1)

    local function update()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local viewport = camera.ViewportSize
        local base = Vector2.new(1440, 900)
        local sx = viewport.X / base.X
        local sy = viewport.Y / base.Y
        local value = math.min(sx, sy)
        value = math.clamp(
            value,
            window.Config.responsive_min_scale or .78,
            window.Config.responsive_max_scale or 1.04
        )
        tween(scale, TweenInfo.new(.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Scale = value
        })
    end

    task.defer(update)

    local camera = workspace.CurrentCamera
    if camera then
        window._viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
    end
end

local function replaceGradientColors(root, oldColor, newColor)
    if not root or not oldColor or not newColor then return end
    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("UIGradient") then
            pcall(function()
                local keys = obj.Color.Keypoints
                local changed = false
                local out = {}
                for _, key in ipairs(keys) do
                    local c = key.Value
                    if c == oldColor then
                        c = newColor
                        changed = true
                    end
                    out[#out + 1] = ColorSequenceKeypoint.new(key.Time, c)
                end
                if changed then
                    obj.Color = ColorSequence.new(out)
                end
            end)
        end
    end
end

local function disconnectAll(window)
    if not window or not window._connections then return end
    for i, connection in ipairs(window._connections) do
        pcall(function() connection:Disconnect() end)
        window._connections[i] = nil
    end
end

local function trackConnection(window, connection)
    if window and connection then
        window._connections = window._connections or {}
        table.insert(window._connections, connection)
    end
    return connection
end


local function addAuroraBackdrop(parent, config)
    if not config.aurora then return end
    local holder = new("Frame", {
        Name = "AuroraBackdrop",
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 0,
        ClipsDescendants = true,
    }, parent)
    addCorner(holder, 14)

    local blobs = {
        {Color = config.main_color, Size = UDim2.fromOffset(330,330), Position = UDim2.new(-.12,0,-.18,0), Transparency = .90},
        {Color = Color3.fromRGB(170,75,255), Size = UDim2.fromOffset(280,280), Position = UDim2.new(.76,0,.58,0), Transparency = .92},
        {Color = Color3.fromRGB(55,210,255), Size = UDim2.fromOffset(210,210), Position = UDim2.new(.42,0,-.14,0), Transparency = .94},
    }
    for i,b in ipairs(blobs) do
        local blob = new("Frame", {
            Name = "AuroraBlob"..i,
            Size = b.Size,
            Position = b.Position,
            BackgroundColor3 = b.Color,
            BackgroundTransparency = b.Transparency,
            BorderSizePixel = 0,
            ZIndex = 0,
        }, holder)
        addCorner(blob, 999)
        local grad = new("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, .05),
                NumberSequenceKeypoint.new(.65, .45),
                NumberSequenceKeypoint.new(1, 1),
            }),
        }, blob)
        task.spawn(function()
            while blob and blob.Parent and config.animated_background do
                local dx = (i == 1 and 28 or (i == 2 and -24 or 18))
                local dy = (i == 1 and 18 or (i == 2 and -16 or 24))
                tween(blob, TweenInfo.new(4.5 + i, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Position = b.Position + UDim2.fromOffset(dx,dy),
                    Rotation = i * 9,
                })
                task.wait(4.5 + i)
                if not (blob and blob.Parent) then break end
                tween(blob, TweenInfo.new(4.5 + i, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Position = b.Position,
                    Rotation = 0,
                })
                task.wait(4.5 + i)
            end
        end)
    end
    return holder
end

local function addGlassOverlay(parent, config)
    if not config.glass then return end
    local overlay = new("Frame", {
        Name = "GlassOverlay",
        Size = UDim2.fromScale(1,1),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 0.985,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, parent)
    addCorner(overlay, 14)
    new("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(.45, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180,210,255)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, .25),
            NumberSequenceKeypoint.new(.25, .72),
            NumberSequenceKeypoint.new(1, .96),
        }),
    }, overlay)
    return overlay
end

local function addContentHeader(parent, tab, config)
    if not config.content_header then return end
    local header = new("Frame", {
        Name = "ContentHeader",
        Size = UDim2.new(1,0,0,config.content_header_height or 54),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = -100,
    }, parent)
    addPrismGradient(header, config, 0)
    local title = addText(header, tab.Name, 18, config.text, Enum.Font.GothamSemibold)
    title.Size = UDim2.new(1,-120,0,26)
    title.Position = UDim2.fromOffset(2,2)
    local sub = addText(header, tostring(config.subtitle or "Configuración y controles"), 10, config.muted, Enum.Font.Gotham)
    sub.Size = UDim2.new(1,-120,0,18)
    sub.Position = UDim2.fromOffset(3,28)
    local line = new("Frame", {
        Size = UDim2.new(.28,0,0,2),
        Position = UDim2.new(0,2,1,-4),
        BackgroundColor3 = config.main_color,
        BackgroundTransparency = .12,
        BorderSizePixel = 0,
    }, header)
    addCorner(line, 2)
    if config.animated then sweepGlow(line, config) end
    return header
end

local function enhanceCard(card, config)
    if not card then return end
    addCorner(card, config.control_radius or 9)
    if config.card_gradient then
        local g = new("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, config.background),
                ColorSequenceKeypoint.new(1, config.surface),
            }),
        }, card)
    end
    if config.card_highlight then
        local edge = new("Frame", {
            Name = "TopHighlight",
            Size = UDim2.new(.34,0,0,1),
            Position = UDim2.fromOffset(10,0),
            BackgroundColor3 = config.main_color,
            BackgroundTransparency = .72,
            BorderSizePixel = 0,
            ZIndex = 3,
        }, card)
        addCorner(edge, 2)
    end
end

local function addNavRailGlow(parent, config)
    if not config.sidebar_glow then return end
    local glow = new("Frame", {
        Name = "NavRailGlow",
        Size = UDim2.new(0,1,1,-22),
        Position = UDim2.new(1,-1,0,11),
        BackgroundColor3 = config.main_color,
        BackgroundTransparency = .62,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, parent)
    addCorner(glow, 2)
    if config.animated then sweepGlow(glow, config) end
end


local function addCrystalCorner(parent, cornerName, config)
    if not config.crystal_corners then return end
    local holder = new("Frame", {
        Name = "CrystalCorner_"..cornerName,
        Size = UDim2.fromOffset(46,46),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 28,
    }, parent)
    local pos = {
        TL = UDim2.fromOffset(7,7), TR = UDim2.new(1,-53,0,7),
        BL = UDim2.new(0,7,1,-53), BR = UDim2.new(1,-53,1,-53)
    }
    holder.Position = pos[cornerName] or pos.TL
    local h = new("Frame", {Size=UDim2.new(0,30,0,1), Position=UDim2.fromOffset(8,23), BackgroundColor3=config.main_color, BackgroundTransparency=.15, BorderSizePixel=0, Rotation=(cornerName=="TR" or cornerName=="BR") and -18 or 18, ZIndex=29}, holder)
    corner(h,2)
    local v = new("Frame", {Size=UDim2.new(0,1,0,30), Position=UDim2.fromOffset(23,8), BackgroundColor3=Color3.fromRGB(220,235,255), BackgroundTransparency=.45, BorderSizePixel=0, Rotation=(cornerName=="TR" or cornerName=="BR") and 18 or -18, ZIndex=29}, holder)
    corner(v,2)
    local diamond = new("Frame", {Size=UDim2.fromOffset(7,7), Position=UDim2.fromOffset(20,20), BackgroundColor3=config.main_color, BackgroundTransparency=.1, BorderSizePixel=0, Rotation=45, ZIndex=30}, holder)
    stroke(diamond, Color3.fromRGB(255,255,255), .35, .7)
    task.spawn(function()
        local a=0
        while holder and holder.Parent do
            a += 1
            diamond.Rotation = 45 + math.sin(a*.045)*14
            diamond.BackgroundTransparency = .1 + (math.sin(a*.06)+1)*.12
            task.wait(.03)
        end
    end)
end

local function addSpecularSweep(parent, config)
    if not config.specular_sweep then return end
    local sweep = new("Frame", {
        Name="SpecularSweep",
        Size=UDim2.new(.18,0,1.7,0),
        Position=UDim2.new(-.35,0,-.35,0),
        Rotation=17,
        BackgroundColor3=Color3.fromRGB(255,255,255),
        BackgroundTransparency=.965,
        BorderSizePixel=0,
        ZIndex=31,
    }, parent)
    task.spawn(function()
        while sweep and sweep.Parent do
            tween(sweep,TweenInfo.new(3.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Position=UDim2.new(1.25,0,-.35,0)})
            task.wait(3.9)
            if not (sweep and sweep.Parent) then break end
            sweep.Position=UDim2.new(-.35,0,-.35,0)
            task.wait(.25)
        end
    end)
end

local function addCrystalSurface(parent, config)
    if not config.nebula_crystal then return end
    local surface = new("Frame", {
        Name="CrystalSurface",
        Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ZIndex=3,
        ClipsDescendants=true,
    }, parent)
    new("UIGradient", {
        Rotation=35,
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(.22, config.main_color),
            ColorSequenceKeypoint.new(.52, Color3.fromRGB(190,110,255)),
            ColorSequenceKeypoint.new(.78, Color3.fromRGB(70,210,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
        }),
        Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,.995),
            NumberSequenceKeypoint.new(.25,.982),
            NumberSequenceKeypoint.new(.5,.994),
            NumberSequenceKeypoint.new(.75,.982),
            NumberSequenceKeypoint.new(1,.996),
        }),
    }, surface)
    task.spawn(function()
        local g=surface:FindFirstChildOfClass("UIGradient")
        while surface and surface.Parent and g do
            g.Offset=Vector2.new(-1.2,0)
            tween(g,TweenInfo.new(8,Enum.EasingStyle.Linear),{Offset=Vector2.new(1.2,0)})
            task.wait(8.1)
        end
    end)
end

local function addAmbientBloom(parent, config)
    if not config.ambient_bloom then return end
    local holder=new("Frame",{Name="AmbientBloom",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=1,ClipsDescendants=true},parent)
    local palette={config.main_color,Color3.fromRGB(170,75,255),Color3.fromRGB(45,205,255),Color3.fromRGB(110,255,205),Color3.fromRGB(255,110,205)}
    local count=math.clamp(config.ambient_bloom_count or 5,3,8)
    for i=1,count do
        local orb=new("Frame",{
            Name="Bloom"..i,Size=UDim2.fromOffset(80+(i*27),80+(i*27)),
            Position=UDim2.new((i*19%91)/100,0,(i*31%83)/100,0),
            BackgroundColor3=palette[((i-1)%#palette)+1],BackgroundTransparency=.975,
            BorderSizePixel=0,ZIndex=1,
        },holder)
        corner(orb,999)
        local grad=new("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.05),NumberSequenceKeypoint.new(.55,.55),NumberSequenceKeypoint.new(1,1)})},orb)
        task.spawn(function()
            local base=orb.Position
            while orb and orb.Parent do
                tween(orb,TweenInfo.new(4.2+(i*.3),Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{
                    Position=base+UDim2.fromOffset(math.sin(i*1.7)*22,math.cos(i*1.3)*18),
                    Size=UDim2.fromOffset(92+(i*27),92+(i*27))
                })
                task.wait(4.3+(i*.3))
                if not (orb and orb.Parent) then break end
                tween(orb,TweenInfo.new(4.2+(i*.3),Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Position=base,Size=UDim2.fromOffset(80+(i*27),80+(i*27))})
                task.wait(4.3+(i*.3))
            end
        end)
    end
end

local function addHeaderLighting(top, config)
    if not config.header_lighting then return end
    local wash=new("Frame",{
        Name="HeaderLightWash",Size=UDim2.new(1,-20,1,-12),Position=UDim2.fromOffset(10,6),
        BackgroundColor3=config.main_color,BackgroundTransparency=.975,BorderSizePixel=0,ZIndex=2,
    },top)
    corner(wash,14)
    new("UIGradient",{
        Rotation=0,
        Color=ColorSequence.new({ColorSequenceKeypoint.new(0,config.main_color),ColorSequenceKeypoint.new(.5,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(150,90,255))}),
        Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.9),NumberSequenceKeypoint.new(.5,.98),NumberSequenceKeypoint.new(1,.92)})
    },wash)
    addSpecularSweep(wash,config)
end

local function addControlDepth(instance, config)
    if not config.control_depth or not instance then return end
    local s=instance:FindFirstChild("ControlDepth")
    if not s then
        s=new("UIStroke",{Name="ControlDepth",Color=Color3.fromRGB(255,255,255),Thickness=.6,Transparency=.86,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},instance)
    end
end


local function addSpectralLuxe(parent, config)
    if not config.spectral_luxe then return end
    local intensity = math.clamp(tonumber(config.spectral_intensity) or 1, 0, 1.5)

    -- Ultra-thin chromatic perimeter: feels like polished glass rather than a heavy border.
    if config.chroma_frame then
        local frame = new("Frame", {
            Name = "SpectralFrame",
            Size = UDim2.new(1,-4,1,-4),
            Position = UDim2.fromOffset(2,2),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 27,
        }, parent)
        corner(frame, 15)
        local s = stroke(frame, Color3.fromRGB(255,255,255), .72)
        s.Thickness = 1.15
        local g = new("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(70,220,255)),
                ColorSequenceKeypoint.new(.22, Color3.fromRGB(160,90,255)),
                ColorSequenceKeypoint.new(.48, Color3.fromRGB(255,255,255)),
                ColorSequenceKeypoint.new(.72, Color3.fromRGB(255,110,210)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(70,220,255)),
            }),
            Rotation = 0,
        }, s)
        task.spawn(function()
            local off = -1
            while s and s.Parent and g do
                off = -1
                g.Offset = Vector2.new(off,0)
                tween(g, TweenInfo.new(4.8, Enum.EasingStyle.Linear), {Offset = Vector2.new(1,0)})
                task.wait(4.9)
            end
        end)
    end

    -- Beveled inner rails give the window a physical, layered chassis.
    if config.edge_bevel then
        local rails = new("Frame", {
            Name = "EdgeBevel",
            Size = UDim2.new(1,-18,1,-18),
            Position = UDim2.fromOffset(9,9),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 26,
        }, parent)
        corner(rails, 12)
        local rs = stroke(rails, Color3.fromRGB(255,255,255), .93)
        rs.Thickness = .8
        local top = new("Frame", {Size=UDim2.new(.62,0,0,1),Position=UDim2.fromOffset(20,0),BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=.86,BorderSizePixel=0,ZIndex=27}, rails)
        local bot = new("Frame", {Size=UDim2.new(.42,0,0,1),Position=UDim2.new(.58,-20,1,-1),BackgroundColor3=config.main_color,BackgroundTransparency=.76,BorderSizePixel=0,ZIndex=27}, rails)
        corner(top, 2); corner(bot,2)
    end

    -- Cinematic light source bands.
    if config.cinematic_lighting then
        local light = new("Frame", {
            Name = "CinematicLight",
            Size = UDim2.new(.58,0,1.5,0),
            Position = UDim2.new(-.48,0,-.25,0),
            Rotation = 13,
            BackgroundColor3 = Color3.fromRGB(210,235,255),
            BackgroundTransparency = .975,
            BorderSizePixel = 0,
            ZIndex = 2,
        }, parent)
        task.spawn(function()
            while light and light.Parent do
                light.Position = UDim2.new(-.48,0,-.25,0)
                tween(light, TweenInfo.new(5.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position=UDim2.new(1.08,0,-.25,0)})
                task.wait(5.8)
            end
        end)
    end

    -- Fine starfield: sparse enough to feel premium, not noisy.
    if config.starfield then
        local field = new("Frame", {
            Name="SpectralStarfield", Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
            BorderSizePixel=0, ZIndex=1, ClipsDescendants=true,
        }, parent)
        local count = math.clamp(tonumber(config.starfield_count) or 22, 8, 40)
        for i=1,count do
            local d = new("Frame", {
                Name="Star"..i,
                Size=UDim2.fromOffset(i%2==0 and 2 or 1, i%2==0 and 2 or 1),
                Position=UDim2.new((i*41%97)/100,0,(i*67%91)/100,0),
                BackgroundColor3=(i%3==0 and Color3.fromRGB(180,110,255) or Color3.fromRGB(140,225,255)),
                BackgroundTransparency=.72+(i%4)*.05,
                BorderSizePixel=0,
                ZIndex=1,
            }, field)
            corner(d, 99)
            task.spawn(function()
                while d and d.Parent do
                    tween(d, TweenInfo.new(1.1+(i%5)*.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency=.35})
                    task.wait(1.1+(i%5)*.35)
                    if not (d and d.Parent) then break end
                    tween(d, TweenInfo.new(1.1+(i%5)*.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency=.82})
                    task.wait(1.1+(i%5)*.35)
                end
            end)
        end
    end

    -- Four restrained ambient rings suggest depth around the glass shell.
    if config.ambient_rings then
        local ringHolder = new("Frame", {Name="AmbientRings",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=1}, parent)
        for i=1,4 do
            local ring = new("Frame", {
                Size=UDim2.fromOffset(150+i*85,150+i*85),
                AnchorPoint=Vector2.new(.5,.5),
                Position=UDim2.new(i%2==0 and .88 or .08,0,i%2==0 and .18 or .82,0),
                BackgroundTransparency=1,
                BorderSizePixel=0,
                ZIndex=1,
            }, ringHolder)
            corner(ring,999)
            local rs=stroke(ring, i%2==0 and Color3.fromRGB(70,220,255) or Color3.fromRGB(180,90,255), .96)
            rs.Thickness=1
            task.spawn(function()
                while ring and ring.Parent do
                    tween(ring,TweenInfo.new(3.6+i*.45,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Size=UDim2.fromOffset(165+i*85,165+i*85)})
                    tween(rs,TweenInfo.new(3.6+i*.45,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=.91})
                    task.wait(3.7+i*.45)
                    if not (ring and ring.Parent) then break end
                    tween(ring,TweenInfo.new(3.6+i*.45,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Size=UDim2.fromOffset(150+i*85,150+i*85)})
                    tween(rs,TweenInfo.new(3.6+i*.45,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=.96})
                    task.wait(3.7+i*.45)
                end
            end)
        end
    end

    -- Motion accents on the top edge: tiny traveling light particles.
    if config.motion_accents then
        local track = new("Frame", {Name="MotionAccentTrack",Size=UDim2.new(.72,0,0,1),Position=UDim2.new(.14,0,0,4),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=30}, parent)
        local dot = new("Frame", {Size=UDim2.fromOffset(26,1),Position=UDim2.new(-.08,0,0,0),BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=.25,BorderSizePixel=0,ZIndex=31}, track)
        corner(dot,2)
        task.spawn(function()
            while dot and dot.Parent do
                dot.Position=UDim2.new(-.08,0,0,0)
                tween(dot,TweenInfo.new(2.7,Enum.EasingStyle.Linear),{Position=UDim2.new(1.02,0,0,0)})
                task.wait(2.85)
            end
        end)
    end
end

local function addLuxeDepthToPanels(window, config)
    if not config.spectral_luxe then return end
    if config.nav_depth and window.Nav then
        local s=window.Nav:FindFirstChildOfClass("UIStroke")
        if s then s.Transparency=.24; s.Thickness=1.15 end
        local edge=new("Frame",{Name="NavInnerEdge",Size=UDim2.new(0,1,1,-26),Position=UDim2.new(1,-3,0,13),BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=.88,BorderSizePixel=0,ZIndex=7},window.Nav)
        corner(edge,2)
        local lower=new("Frame",{Name="NavLowerGlow",Size=UDim2.new(.72,0,0,1),Position=UDim2.new(.14,0,1,-7),BackgroundColor3=config.main_color,BackgroundTransparency=.58,BorderSizePixel=0,ZIndex=7},window.Nav)
        corner(lower,2)
        sweepGlow(lower,config)
    end
    if config.content_depth and window.Content then
        local s=window.Content:FindFirstChildOfClass("UIStroke")
        if s then s.Transparency=.22; s.Thickness=1.05 end
        local inner=new("Frame",{Name="ContentInnerEdge",Size=UDim2.new(1,-12,1,-12),Position=UDim2.fromOffset(6,6),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=4},window.Content)
        corner(inner,9)
        local is=stroke(inner,Color3.fromRGB(255,255,255),.95); is.Thickness=.7
    end
end

function Library:AddWindow(title, config)
    config = merge(DEFAULTS, config)
    local window = {
        Library = self,
        Config = config,
        Tabs = {},
        ActiveTab = nil,
        Visible = true,
        _connections = {},
        _destroyed = false,
    }
    setmetatable(window, {__index = Library.WindowMethods})

    local gui = new("ScreenGui", {
        Name = "UAI_EasyLibrary",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 2147480000,
    }, getParent())
    window.Gui = gui

    local root = new("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(.5,.5),
        Position = UDim2.fromScale(.5,.5),
        Size = UDim2.fromOffset(config.size.X, config.size.Y),
        BackgroundColor3 = config.background,
        BackgroundTransparency = config.transparency,
        BorderSizePixel = 0,
    }, gui)
    addAuroraBackdrop(root, config)
    addGlassOverlay(root, config)
    addCrystalSurface(root, config)
    addAmbientBloom(root, config)
    addCorner(root, 14)
    if config.depth_shadow then addShadow(root, .48, 24, 7) end
    if config.neon_border then addNeonStroke(root, config.main_color, Color3.fromRGB(175,75,255), 1.2) end
    if not config.clean_background then
        addParticles(root, config)
        addFloatingOrbs(root, config)
        addScanline(root, config)
    end
    addGlassHighlight(root, config)
    addWindowBreath(root, config)
    addWindowEnergyLine(root, config)
    addHoloCorner(root, config, "TL")
    addHoloCorner(root, config, "TR")
    addHoloCorner(root, config, "BL")
    addHoloCorner(root, config, "BR")
    addCrystalCorner(root, "TL", config)
    addCrystalCorner(root, "TR", config)
    addCrystalCorner(root, "BL", config)
    addCrystalCorner(root, "BR", config)

    if config.top_orb then
        local orb = new("Frame", {
            Name = "TopOrb",
            Size = UDim2.fromOffset(8,8),
            AnchorPoint = Vector2.new(.5,.5),
            Position = UDim2.new(.5,0,0,0),
            BackgroundColor3 = config.main_color,
            BorderSizePixel = 0,
            ZIndex = 40,
        }, root)
        new("UICorner", {CornerRadius = UDim.new(1,0)}, orb)
        task.spawn(function()
            while orb and orb.Parent do
                tween(orb, TweenInfo.new(.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Size = UDim2.fromOffset(12,12),
                    BackgroundTransparency = .35
                })
                task.wait(.8)
                tween(orb, TweenInfo.new(.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Size = UDim2.fromOffset(8,8),
                    BackgroundTransparency = 0
                })
                task.wait(.8)
            end
        end)
    end

    corner(root, 12)
    stroke(root, config.border)
    if config.glow then addGlow(root, config.main_color, 0.72) end
    window.Root = root
    setupResponsive(window)

    -- Futuristic top glow line
    local topGlow = new("Frame", {
        Name = "TopGlow",
        Size = UDim2.new(1, -32, 0, 2),
        Position = UDim2.new(0, 16, 0, 46),
        BackgroundColor3 = config.main_color,
        BorderSizePixel = 0,
        BackgroundTransparency = 0.05,
    }, root)
    if config.animated then
        addGradient(topGlow, config.main_color, Color3.fromRGB(180, 90, 255), 0)
        sweepGlow(topGlow, config)
        local rootStroke = root:FindFirstChild("NeonStroke")
        if rootStroke then
            task.spawn(function()
                local g = rootStroke:FindFirstChildOfClass("UIGradient")
                if g then
                    while root and root.Parent do
                        g.Offset = Vector2.new(-1,0)
                        tween(g, TweenInfo.new(2.2, Enum.EasingStyle.Linear), {Offset = Vector2.new(1,0)})
                        task.wait(2.25)
                    end
                end
            end)
        end
    end

    if config.entrance_animation then
        addScale(root, .88)
        root.BackgroundTransparency = 1
        tween(root, TweenInfo.new(.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundTransparency = config.transparency
        })
        tween(root:FindFirstChildOfClass("UIScale"), TweenInfo.new(.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Scale = 1
        })
    end

    addAmbientDust(root, config)
    addVignette(root, config)

    local top = new("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1,0,0,48),
        BackgroundTransparency = 1,
    }, root)
    window.TopBar = top
    addHeaderLighting(top, config)
    if config.draggable ~= false then makeDraggable(top, root) end

    local accent = new("Frame", {
        Size = UDim2.new(0,3,0,22),
        Position = UDim2.new(0,14,0,13),
        BackgroundColor3 = config.main_color,
        BorderSizePixel = 0,
    }, top)
    corner(accent, 2)

    local titleLabel = addText(top, title or "UAI", 15, config.text, Enum.Font.GothamSemibold)
    titleLabel.Name = "TitleLabel"
    titleLabel.Position = UDim2.new(0,45,0,0)
    titleLabel.Size = UDim2.new(1,-190,1,0)
    window._titleLabel = titleLabel

    if config.show_subtitle then
        local subtitle = addText(top, config.subtitle or "Premium Interface", 10, config.muted, Enum.Font.Gotham)
        subtitle.Name = "SubtitleLabel"
        subtitle.Position = UDim2.new(0,45,0,25)
        subtitle.Size = UDim2.new(0,210,0,16)
        window._subtitleLabel = subtitle
    end

    local status = addText(top, "● " .. tostring(config.status_text or "ONLINE"), 10, config.main_color, Enum.Font.GothamMedium)
    status.Position = UDim2.new(1,-155,0,0)
    status.Size = UDim2.fromOffset(85,48)
    status.TextXAlignment = Enum.TextXAlignment.Right
    pulse(status, config)
    window._statusLabel = status

    if config.status_pill then
        local pill = new("Frame", {
            Name="StatusPill",
            Size=UDim2.fromOffset(104,26),
            Position=UDim2.new(1,-188,0,11),
            BackgroundColor3=config.surface2,
            BackgroundTransparency=.16,
            BorderSizePixel=0,
            ZIndex=8,
        }, top)
        corner(pill,13)
        stroke(pill, config.main_color, .58)
        local pText=addText(pill,tostring(config.status_text or "ONLINE"),10,config.main_color,Enum.Font.GothamMedium)
        pText.Size=UDim2.new(1,-16,1,0); pText.Position=UDim2.fromOffset(8,0)
        pText.TextXAlignment=Enum.TextXAlignment.Center
        window._statusPill=pill
    end

    if config.header_badge then
        local badge=new("Frame",{
            Name="HeaderBadge",
            Size=UDim2.fromOffset(30,30),
            Position=UDim2.fromOffset(8,9),
            BackgroundColor3=config.main_color,
            BackgroundTransparency=.82,
            BorderSizePixel=0,
            ZIndex=8,
        },top)
        corner(badge,10)
        stroke(badge,config.main_color,.25)
        local b=addText(badge,"✦",15,config.text,Enum.Font.GothamBold)
        b.Size=UDim2.fromScale(1,1); b.TextXAlignment=Enum.TextXAlignment.Center
        b.TextYAlignment=Enum.TextYAlignment.Center
        if config.header_orbit then
            local orbit=new("Frame",{Name="Orbit",Size=UDim2.fromOffset(4,4),Position=UDim2.new(1,-2,.5,-2),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=9},badge)
            corner(orbit,99)
            task.spawn(function()
                local angle=0
                while orbit and orbit.Parent do
                    angle=angle+3
                    local r=14
                    orbit.Position=UDim2.new(.5,math.cos(math.rad(angle))*r-.5,.5,math.sin(math.rad(angle))*r-.5)
                    task.wait(.03)
                end
            end)
        end
    end

    local statusDot = new("Frame", {
        Size = UDim2.fromOffset(5,5),
        Position = UDim2.new(1,-62,.5,-2),
        BackgroundColor3 = Color3.fromRGB(80,255,170),
        BorderSizePixel = 0,
        ZIndex = 20,
    }, top)
    new("UICorner", {CornerRadius = UDim.new(1,0)}, statusDot)
    window._statusDot = statusDot
    task.spawn(function()
        while statusDot and statusDot.Parent do
            tween(statusDot, TweenInfo.new(.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = .7
            })
            task.wait(.75)
            tween(statusDot, TweenInfo.new(.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0
            })
            task.wait(.75)
        end
    end)

    local titleLine = new("Frame", {
        Name = "TitleEnergyLine",
        Size = UDim2.new(.32,0,0,1),
        Position = UDim2.new(0,18,1,-1),
        BackgroundColor3 = config.main_color,
        BackgroundTransparency = .12,
        BorderSizePixel = 0,
        ZIndex = 30,
    }, top)
    new("UICorner", {CornerRadius = UDim.new(1,0)}, titleLine)

    local close
    local minimize

    if config.show_close_button then
        close = new("TextButton", {
            Name = "CloseButton",
            Text = "×",
            TextColor3 = config.muted,
            TextSize = 23,
            Font = Enum.Font.Gotham,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(38,38),
            Position = UDim2.new(1,-45,0,5),
            AutoButtonColor = false,
        }, top)
        close.MouseEnter:Connect(function() tween(close,TweenInfo.new(.1),{TextColor3=config.text}) end)
        close.MouseLeave:Connect(function() tween(close,TweenInfo.new(.1),{TextColor3=config.muted}) end)
        close.MouseButton1Click:Connect(function() window:Toggle() end)
        addTooltip(close, "Cerrar", config)
    end

    if config.show_minimize_button then
        local xOffset = config.show_close_button and 82 or 45
        minimize = new("TextButton", {
            Name = "MinimizeButton",
            Text = "—",
            TextColor3 = config.muted,
            TextSize = 18,
            Font = Enum.Font.GothamMedium,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(32,32),
            Position = UDim2.new(1,-xOffset,0,8),
            AutoButtonColor = false,
        }, top)
        minimize.MouseEnter:Connect(function() tween(minimize,TweenInfo.new(.1),{TextColor3=config.text}) end)
        minimize.MouseLeave:Connect(function() tween(minimize,TweenInfo.new(.1),{TextColor3=config.muted}) end)
        minimize.MouseButton1Click:Connect(function() window:Minimize() end)
        addTooltip(minimize, "Minimizar", config)
    end

    local body = new("Frame", {
        Name = "Body",
        Position = UDim2.new(0,10,0,48),
        Size = UDim2.new(1,-20,1,-58),
        BackgroundTransparency = 1,
    }, root)

    local nav = new("ScrollingFrame", {
        Name = "Navigation",
        Size = UDim2.new(0, config.sidebar_width or 190, 1, 0),
        BackgroundColor3 = config.surface,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, body)
    corner(nav, 10)
    pad(nav,6,6,7,7)
    if config.nav_glass then
        addPrismGradient(nav, config, 90)
        addAnimatedBorder(nav, config)
    end
    addNavRailGlow(nav, config)
    if config.nav_chrome then
        local chrome=new("Frame",{Name="NavChrome",Size=UDim2.new(1,-16,0,1),Position=UDim2.new(0,8,0,7),BackgroundColor3=config.main_color,BackgroundTransparency=.35,BorderSizePixel=0,ZIndex=6},nav)
        corner(chrome,2)
        if config.animated then sweepGlow(chrome,config) end
    end

    addSearchBox(nav, config, function(query)
        query = string.lower(query or "")
        for _, tab in ipairs(window.Tabs) do
            if tab.NavButton then
                local tabName = string.lower(tab.Name or "")
                tab.NavButton.Visible =
                    query == "" or string.find(tabName, query, 1, true) ~= nil
            end
        end
    end)
    local navLayout = new("UIListLayout", {
        Padding=UDim.new(0,4),
        SortOrder=Enum.SortOrder.LayoutOrder,
    }, nav)
    navLayout.Padding = UDim.new(0,4)

    local content = new("Frame", {
        Name = "Content",
        Position = UDim2.new(0,(config.sidebar_width or 190) + 8,0,0),
        Size = UDim2.new(1,-(config.sidebar_width or 190) - 8,1,0),
        BackgroundColor3 = config.surface,
        BorderSizePixel = 0,
    }, body)
    corner(content, 10)
    stroke(content, config.border, .32)
    local contentTop = new("Frame", {
        Name = "ContentTopGlow",
        Size = UDim2.new(.52,0,0,1),
        Position = UDim2.new(0,18,0,0),
        BackgroundColor3 = config.main_color,
        BackgroundTransparency = .55,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, content)
    addCorner(contentTop, 2)
    if config.animated then sweepGlow(contentTop, config) end

    local pageHolder = new("Frame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
    }, content)
    pad(pageHolder,14,14,12,12)

    window.Nav = nav
    window.Content = content
    window.PageHolder = pageHolder
    addLuxeDepthToPanels(window, config)
    addSpectralLuxe(root, config)

    if config.cursor_glow then
        local cursor = new("Frame", {
            Name = "CursorGlow", Size = UDim2.fromOffset(110,110),
            AnchorPoint = Vector2.new(.5,.5), BackgroundColor3 = config.main_color,
            BackgroundTransparency = .96, BorderSizePixel = 0, ZIndex = 2,
            Visible = false,
        }, root)
        addCorner(cursor, 999)
        trackConnection(window, UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and root.Visible then
                cursor.Visible = true
                local p = root.AbsolutePosition
                cursor.Position = UDim2.fromOffset(input.Position.X-p.X, input.Position.Y-p.Y)
            end
        end))
        window._cursorGlow = cursor
    end

    if config.can_resize then
        local grip = new("TextButton", {
            Size = UDim2.fromOffset(18,18),
            Position = UDim2.new(1,-18,1,-18),
            Text = "",
            BackgroundTransparency = 1,
            AutoButtonColor = false,
        }, root)
        local resizing, startMouse, startSize
        trackConnection(window, grip.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            resizing = true
            startMouse = input.Position
            startSize = root.AbsoluteSize
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end))
        trackConnection(window, UserInputService.InputChanged:Connect(function(input)
            if not resizing then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local d = input.Position - startMouse
            local x = math.max(config.min_size.X, startSize.X+d.X)
            local y = math.max(config.min_size.Y, startSize.Y+d.Y)
            root.Size = UDim2.fromOffset(x,y)
        end))
    end

    trackConnection(window, UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if config.escape_to_close and input.KeyCode == Enum.KeyCode.Escape and window.Visible then
            window:Hide()
        elseif input.KeyCode == config.toggle_key then
            window:Toggle()
        end
    end))

    return window
end

Library.WindowMethods = {}

function Library.WindowMethods:AddTab(name)
    local window = self
    local tab = {
        Window = window,
        Name = tostring(name),
        Controls = {},
    }
    setmetatable(tab, {__index = Library.TabMethods})

    local navButton = new("TextButton", {
        Name = "Tab_"..tostring(name),
        Size = UDim2.new(1,0,0,36),
        BackgroundColor3 = window.Config.surface2,
        BackgroundTransparency = 1,
        Text = (window.Config.show_tab_icons and (getTabIcon(tostring(name)) .. "   ") or "") .. tostring(name),
        TextColor3 = window.Config.muted,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    }, window.Nav)
    corner(navButton, 9)
    pad(navButton,11,6,0,0)
    local indicator = new("Frame", {
        Name = "ActiveIndicator",
        Size = UDim2.fromOffset(3,18),
        Position = UDim2.new(0,3,.5,-9),
        BackgroundColor3 = window.Config.main_color,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, navButton)
    corner(indicator, 3)
    local navGlow = nil
    if window.Config.active_nav_glow then
        navGlow = new("UIStroke", {Name="ActiveGlow", Color=window.Config.main_color, Transparency=1, Thickness=1}, navButton)
    end
    hoverScale(navButton, window.Config, 1.025)
    modernTabHover(navButton, window.Config)
    addTooltip(navButton, tostring(name), window.Config)
    addCorner(navButton, 8)
    if window.Config.neon_border then
        addNeonStroke(navButton, window.Config.main_color, Color3.fromRGB(175,75,255), .7)
    end

    local page = new("ScrollingFrame", {
        Name = tostring(name),
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = window.Config.border,
        Visible = false,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, window.PageHolder)
    local layout = new("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, page)
    pad(page,2,5,2,2)
    addContentHeader(page, tab, window.Config)

    tab.NavButton = navButton
    tab.Page = page
    tab.Layout = layout
    table.insert(window.Tabs, tab)

    navButton.MouseButton1Click:Connect(function()
        window:SelectTab(tab)
    end)

    if not window.ActiveTab then window:SelectTab(tab) end
    return tab
end

function Library.WindowMethods:SelectTab(tab)
    playClick(self.Config)
    for _,t in ipairs(self.Tabs) do
        local active = t == tab
        t.Page.Visible = active
        t.NavButton.BackgroundTransparency = active and (self.Config.nav_active_fill and 0.03 or 0.06) or 1
        t.NavButton.BackgroundColor3 = active and self.Config.surface2 or self.Config.surface
        local activeGradient = t.NavButton:FindFirstChild("ActiveFill")
        if active and not activeGradient and self.Config.nav_active_fill then
            activeGradient = new("UIGradient", {
                Name="ActiveFill",
                Rotation=0,
                Color=ColorSequence.new({
                    ColorSequenceKeypoint.new(0,self.Config.main_color),
                    ColorSequenceKeypoint.new(.55,self.Config.surface2),
                    ColorSequenceKeypoint.new(1,self.Config.surface),
                }),
                Transparency=NumberSequence.new({
                    NumberSequenceKeypoint.new(0,.72),
                    NumberSequenceKeypoint.new(.5,.9),
                    NumberSequenceKeypoint.new(1,.96),
                }),
            },t.NavButton)
        end
        t.NavButton.TextColor3 = active and self.Config.text or self.Config.muted
        local indicator = t.NavButton:FindFirstChild("ActiveIndicator")
        if indicator then
            tween(indicator, TweenInfo.new(.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = active and .05 or 1,
                Size = active and UDim2.fromOffset(3,22) or UDim2.fromOffset(3,18),
            })
        end
        local navGlow = t.NavButton:FindFirstChild("ActiveGlow")
        if navGlow then
            tween(navGlow, TweenInfo.new(.18, Enum.EasingStyle.Quad), {Transparency = active and .42 or 1})
        end

        if active then
            t.NavButton.TextColor3 = self.Config.main_color
            if self.Config.tab_animation then
                animateScale(t.NavButton, .96, 1, .20, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                t.Page.CanvasPosition = Vector2.new(0, 0)
            end

            if self.Config.card_animation then
                for i, child in ipairs(t.Page:GetChildren()) do
                    if child:IsA("GuiObject") and child ~= t.Layout then
                        animateCardIn(child, math.min((i - 1) * .035, .28), self.Config)
                    end
                end
            end
        end
    end
    self.ActiveTab = tab
end

function Library.WindowMethods:Toggle()
    if self.Visible then
        self:Hide()
    else
        self:Show()
    end
end

function Library.WindowMethods:Show()
    self.Visible = true
    self.Root.Visible = true
    if self.Config.entrance_animation then
        local scale = addScale(self.Root, .90)
        tween(scale, TweenInfo.new(.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
    end
end

function Library.WindowMethods:Hide()
    if self.Config.entrance_animation then
        local scale = addScale(self.Root, 1)
        tween(scale, TweenInfo.new(.20, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Scale = .90})
        task.delay(.20, function()
            if self.Root then
                self.Visible = false
                self.Root.Visible = false
            end
        end)
    else
        self.Visible = false
        self.Root.Visible = false
    end
end

function Library.WindowMethods:FormatWindows()
    return self
end


function Library.WindowMethods:SetTheme(name)
    return applyTheme(self, tostring(name or "Dark"))
end

function Library.WindowMethods:GetTheme()
    return self.Config.theme_name or "Dark"
end

function Library.WindowMethods:GetThemes()
    local list = {}
    for name in pairs(THEMES) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

function Library.WindowMethods:SetResponsive(enabled)
    self.Config.responsive = enabled ~= false
    if self.Config.responsive then
        setupResponsive(self)
    elseif self.Root then
        local scale = self.Root:FindFirstChildOfClass("UIScale")
        if scale then scale.Scale = 1 end
    end
    return self
end

function Library.WindowMethods:Focus()
    if not self.Root then return self end
    self.Root.ZIndex = 100
    if self.Config.focus_ring then
        local ring = self.Root:FindFirstChild("FocusRing")
        if not ring then
            ring = new("UIStroke", {
                Name = "FocusRing",
                Color = self.Config.main_color,
                Transparency = .72,
                Thickness = 1,
            }, self.Root)
        end
        tween(ring, TweenInfo.new(.12, Enum.EasingStyle.Quad), {Transparency = .38})
        task.delay(.18, function()
            if ring and ring.Parent then
                tween(ring, TweenInfo.new(.35, Enum.EasingStyle.Quad), {Transparency = .72})
            end
        end)
    end
    return self
end

function Library.WindowMethods:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    if self._viewportConnection then
        pcall(function() self._viewportConnection:Disconnect() end)
        self._viewportConnection = nil
    end
    disconnectAll(self)
    if self.Gui then self.Gui:Destroy() end
    self.Gui = nil
    self.Root = nil
end

-- Tab methods must exist before defining methods with the `Library.TabMethods:...` syntax.
-- Without this table, Lua tries to index nil while loading the library.
Library.TabMethods = {}


local function addPrismGradient(parent, config, rotation)
    if not parent or not config.luxe_prism then return end
    local old = parent:FindFirstChild("PrismGradient")
    if old then old:Destroy() end
    local g = new("UIGradient", {
        Name = "PrismGradient",
        Rotation = rotation or 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, config.surface2),
            ColorSequenceKeypoint.new(.42, config.background),
            ColorSequenceKeypoint.new(.72, Color3.fromRGB(
                math.clamp(config.main_color.R*255 + 10,0,255),
                math.clamp(config.main_color.G*255 + 10,0,255),
                math.clamp(config.main_color.B*255 + 10,0,255)
            )),
            ColorSequenceKeypoint.new(1, config.surface),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, .08),
            NumberSequenceKeypoint.new(.52, .02),
            NumberSequenceKeypoint.new(1, .12),
        }),
    }, parent)
    return g
end

local function addCardSpotlight(card, config)
    if not config.card_spotlight then return end
    local glow = new("Frame", {
        Name = "CardSpotlight",
        Size = UDim2.fromOffset(130,130),
        AnchorPoint = Vector2.new(.5,.5),
        Position = UDim2.new(.18,0,.2,0),
        BackgroundColor3 = config.main_color,
        BackgroundTransparency = .975,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, card)
    addCorner(glow, 999)

    card.MouseEnter:Connect(function()
        tween(glow, TweenInfo.new(.22, Enum.EasingStyle.Quad), {
            BackgroundTransparency = .91
        })
        tween(card, TweenInfo.new(.18, Enum.EasingStyle.Quad), {
            BackgroundTransparency = .025
        })
    end)
    card.MouseLeave:Connect(function()
        tween(glow, TweenInfo.new(.28, Enum.EasingStyle.Quad), {
            BackgroundTransparency = .975
        })
        tween(card, TweenInfo.new(.22, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0
        })
    end)
end

local function addCardSheen(card, config)
    if not config.card_sheen then return end
    local sheen = new("Frame", {
        Name = "CardSheen",
        Size = UDim2.new(.22,0,1.8,0),
        Position = UDim2.new(-.38,0,-.4,0),
        Rotation = 16,
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = .965,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, card)
    task.spawn(function()
        while sheen and sheen.Parent do
            tween(sheen, TweenInfo.new(2.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(1.25,0,-.4,0)
            })
            task.wait(3.05)
            if not (sheen and sheen.Parent) then break end
            sheen.Position = UDim2.new(-.38,0,-.4,0)
            task.wait(.25)
        end
    end)
end

local function addAnimatedBorder(parent, config)
    if not config.animated_strokes or not config.luxe_prism then return end
    local s = parent:FindFirstChild("LuxeBorder")
    if not s then
        s = new("UIStroke", {
            Name = "LuxeBorder",
            Color = config.main_color,
            Thickness = .75,
            Transparency = .62,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, parent)
    end
    local g = s:FindFirstChild("BorderGradient")
    if not g then
        g = new("UIGradient", {
            Name = "BorderGradient",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, config.main_color),
                ColorSequenceKeypoint.new(.48, Color3.fromRGB(190,90,255)),
                ColorSequenceKeypoint.new(1, config.main_color),
            }),
        }, s)
    end
    task.spawn(function()
        while parent and parent.Parent and g and g.Parent do
            g.Offset = Vector2.new(-1,0)
            tween(g, TweenInfo.new(2.4, Enum.EasingStyle.Linear), {Offset=Vector2.new(1,0)})
            task.wait(2.55)
        end
    end)
end

local function addFocusRing(input, config)
    if not config.input_focus_glow then return end
    local ring = new("UIStroke", {
        Name = "FocusRing",
        Color = config.main_color,
        Thickness = 1,
        Transparency = 1,
    }, input)
    input.Focused:Connect(function()
        tween(ring, TweenInfo.new(.16, Enum.EasingStyle.Quad), {Transparency=.18})
    end)
    input.FocusLost:Connect(function()
        tween(ring, TweenInfo.new(.22, Enum.EasingStyle.Quad), {Transparency=1})
    end)
end

local function addButtonShine(button, config)
    if not config.button_shine then return end
    local shine = new("Frame", {
        Name="ButtonShine",
        Size=UDim2.new(.18,0,1.8,0),
        Position=UDim2.new(-.3,0,-.4,0),
        Rotation=14,
        BackgroundColor3=Color3.fromRGB(255,255,255),
        BackgroundTransparency=.96,
        BorderSizePixel=0,
        ZIndex=3,
    }, button)
    task.spawn(function()
        while shine and shine.Parent do
            tween(shine,TweenInfo.new(2.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{
                Position=UDim2.new(1.25,0,-.4,0)
            })
            task.wait(2.45)
            if not (shine and shine.Parent) then break end
            shine.Position=UDim2.new(-.3,0,-.4,0)
        end
    end)
end

local function addVignette(parent, config)
    if not config.vignette then return end
    local v = new("Frame", {
        Name="Vignette",
        Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ZIndex=7,
        ClipsDescendants=true,
    }, parent)
    local edges = {
        {Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,0,0,0),Rotation=0},
        {Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,1,-30),Rotation=180},
        {Size=UDim2.new(0,28,1,0),Position=UDim2.new(0,0,0,0),Rotation=90},
        {Size=UDim2.new(0,28,1,0),Position=UDim2.new(1,-28,0,0),Rotation=-90},
    }
    for _,e in ipairs(edges) do
        local f=new("Frame",{
            Size=e.Size,Position=e.Position,BackgroundColor3=Color3.fromRGB(0,0,0),
            BackgroundTransparency=.94,BorderSizePixel=0,ZIndex=7,
        },v)
        new("UIGradient",{
            Rotation=e.Rotation,
            Transparency=NumberSequence.new({
                NumberSequenceKeypoint.new(0,.12),
                NumberSequenceKeypoint.new(1,1)
            })
        },f)
    end
end

local function addAmbientDust(parent, config)
    if not config.ambient_particles then return end
    local holder=new("Frame",{
        Name="AmbientDust",Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,BorderSizePixel=0,ZIndex=1,
        ClipsDescendants=true,
    },parent)
    for i=1,(config.particle_count_v11 or 14) do
        local dot=new("Frame",{
            Name="Dust"..i,
            Size=UDim2.fromOffset((i%3)+1,(i%3)+1),
            Position=UDim2.new((i*37%97)/100,0,(i*53%89)/100,0),
            BackgroundColor3=(i%2==0 and config.main_color or Color3.fromRGB(210,180,255)),
            BackgroundTransparency=.55+(i%4)*.08,
            BorderSizePixel=0,ZIndex=1,
        },holder)
        addCorner(dot,99)
        task.spawn(function()
            while dot and dot.Parent do
                local y=((i*53%89)/100)+((i%2==0 and .045 or -.04))
                tween(dot,TweenInfo.new(2.8+(i%4)*.35,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{
                    Position=UDim2.new((i*37%97)/100,0,math.clamp(y,0.03,.95),0)
                })
                task.wait(2.9+(i%4)*.35)
                if not (dot and dot.Parent) then break end
                dot.Position=UDim2.new((i*37%97)/100,0,(i*53%89)/100,0)
            end
        end)
    end
end

local function addCard(tab, height)
    local card = new("Frame", {
        Size = UDim2.new(1,-4,0,height or 44),
        BackgroundColor3 = tab.Window.Config.background,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, tab.Page)
    corner(card, tab.Window.Config.control_radius or 9)
    stroke(card, tab.Window.Config.border, .22)
    enhanceCard(card, tab.Window.Config)
    addPrismGradient(card, tab.Window.Config, 90)
    addAnimatedBorder(card, tab.Window.Config)
    addCardSpotlight(card, tab.Window.Config)
    addCardSheen(card, tab.Window.Config)
    if tab.Window.Config.surface_shimmer then addSpecularSweep(card, tab.Window.Config) end
    animateCardIn(card, 0, tab.Window.Config)
    hoverScale(card, tab.Window.Config, tab.Window.Config.card_lift and 1.012 or 1.008)
    return card
end

function Library.TabMethods:AddLabel(text)
    local card = addCard(self, 40)
    local label = addText(card,text,13,self.Window.Config.text)
    label.Position = UDim2.new(0,12,0,0)
    label.Size = UDim2.new(1,-24,1,0)
    return label
end

function Library.TabMethods:AddButton(text, callback)
    local card = addCard(self, 44)
    local button = new("TextButton", {
        Size=UDim2.new(1,-8,1,-8), Position=UDim2.new(0,4,0,4),
        BackgroundColor3=self.Window.Config.surface2, Text=tostring(text),
        TextColor3=self.Window.Config.text, TextSize=13, Font=Enum.Font.GothamMedium,
        AutoButtonColor=false,
    }, card)
    corner(button,7)
    addButtonShine(button, self.Window.Config)
    addAnimatedBorder(button, self.Window.Config)
    addControlDepth(button, self.Window.Config)
    hoverScale(button, self.Window.Config, 1.035)
    button.MouseEnter:Connect(function()
        tween(button,TweenInfo.new(.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{
            BackgroundColor3=self.Window.Config.main_color
        })
    end)
    button.MouseLeave:Connect(function()
        tween(button,TweenInfo.new(.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),{
            BackgroundColor3=self.Window.Config.surface2
        })
    end)
    button.MouseButton1Click:Connect(function()
        playClick(self.Window.Config)
        if self.Window.Config.animated then
            local s = addScale(button, 1)
            tween(s, TweenInfo.new(.07, Enum.EasingStyle.Quad), {Scale = .96})
            task.delay(.07, function()
                if s and s.Parent then
                    tween(s, TweenInfo.new(.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
                end
            end)
        end
        if callback then callback() end
    end)
    return button
end

function Library.TabMethods:AddSwitch(text, callback)
    local card=addCard(self,44)
    local label=addText(card,text,13,self.Window.Config.text)
    label.Position=UDim2.new(0,12,0,0); label.Size=UDim2.new(1,-75,1,0)
    local sw=new("TextButton",{Size=UDim2.fromOffset(42,22),Position=UDim2.new(1,-54,.5,-11),Text="",AutoButtonColor=false,BackgroundColor3=self.Window.Config.surface2},card)
    corner(sw,11); stroke(sw,self.Window.Config.border)
    addControlDepth(sw, self.Window.Config)
    hoverScale(sw, self.Window.Config, 1.08)
    local knob=new("Frame",{Size=UDim2.fromOffset(16,16),Position=UDim2.new(0,3,.5,-8),BackgroundColor3=self.Window.Config.muted,BorderSizePixel=0},sw)
    corner(knob,8)
    local state=false
    local function set(v, silent)
        state=not not v
        tween(sw,TweenInfo.new(.12),{BackgroundColor3=state and self.Window.Config.main_color or self.Window.Config.surface2})
        tween(knob,TweenInfo.new(.12),{Position=state and UDim2.new(1,-19,.5,-8) or UDim2.new(0,3,.5,-8),BackgroundColor3=state and Color3.new(1,1,1) or self.Window.Config.muted})
        if not silent and callback then callback(state) end
    end
    sw.MouseButton1Click:Connect(function()
        playClick(self.Window.Config)
        set(not state)
    end)
    return {Set=set,Get=function() return state end,Instance=sw}
end

function Library.TabMethods:AddToggle(text, callback)
    return self:AddSwitch(text, callback)
end

function Library.TabMethods:AddTextArea(placeholder, callback, options)
    options = options or {}
    options.multiline = true
    local card = addCard(self, options.height or 96)
    local box = new("TextBox", {
        Size=UDim2.new(1,-16,1,-12),
        Position=UDim2.new(0,8,0,6),
        BackgroundColor3=self.Window.Config.surface2,
        TextColor3=self.Window.Config.text,
        PlaceholderColor3=self.Window.Config.muted,
        PlaceholderText=tostring(placeholder or ""),
        Text="",
        TextSize=13,
        Font=Enum.Font.Gotham,
        ClearTextOnFocus=false,
        MultiLine=true,
        TextWrapped=true,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Top,
    },card)
    corner(box,7)
    addControlDepth(box, self.Window.Config)
    addFocusRing(box, self.Window.Config)
    pad(box,10,10,8,8)
    box.FocusLost:Connect(function(enter)
        if callback then callback(box.Text,enter) end
    end)
    return box
end

function Library.TabMethods:AddTextBox(placeholder, callback, options)
    options=options or {}
    local card=addCard(self,44)
    local box=new("TextBox",{Size=UDim2.new(1,-16,1,-12),Position=UDim2.new(0,8,0,6),BackgroundColor3=self.Window.Config.surface2,TextColor3=self.Window.Config.text,PlaceholderColor3=self.Window.Config.muted,PlaceholderText=tostring(placeholder),Text="",TextSize=13,Font=Enum.Font.Gotham,ClearTextOnFocus=false},card)
    corner(box,7); addFocusRing(box, self.Window.Config); pad(box,10,10,0,0)
    box.FocusLost:Connect(function(enter) if callback then callback(box.Text,enter) end end)
    return box
end

function Library.TabMethods:AddSlider(text, callback, options)
    options=options or {}
    local min,max=tonumber(options.min) or 0, tonumber(options.max) or 100
    if max <= min then max = min + 1 end
    local value=math.clamp(tonumber(options.default) or min,min,max)
    local card=addCard(self,58)
    local label=addText(card,text,12,self.Window.Config.text); label.Position=UDim2.new(0,12,0,5); label.Size=UDim2.new(1,-80,0,20)
    local val=addText(card,tostring(value),12,self.Window.Config.muted); val.Position=UDim2.new(1,-55,0,5); val.Size=UDim2.new(0,43,0,20); val.TextXAlignment=Enum.TextXAlignment.Right
    local bar=new("TextButton",{Size=UDim2.new(1,-24,0,6),Position=UDim2.new(0,12,1,-15),Text="",AutoButtonColor=false,BackgroundColor3=self.Window.Config.surface2},card); corner(bar,3)
    local fill=new("Frame",{Size=UDim2.new((value-min)/(max-min),0,1,0),BackgroundColor3=self.Window.Config.main_color,BorderSizePixel=0},bar); corner(fill,3)
    if self.Window.Config.slider_glow then
        addAnimatedBorder(bar, self.Window.Config)
        local shine = new("Frame",{Size=UDim2.new(.16,0,1.8,0),Position=UDim2.new(-.25,0,-.4,0),Rotation=8,BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=.95,BorderSizePixel=0,ZIndex=4},fill)
        task.spawn(function()
            while shine and shine.Parent do
                tween(shine,TweenInfo.new(1.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Position=UDim2.new(1.15,0,-.4,0)})
                task.wait(1.9)
                if not (shine and shine.Parent) then break end
                shine.Position=UDim2.new(-.25,0,-.4,0)
            end
        end)
    end
    local function set(v)
        value=math.clamp(v,min,max); local a=(value-min)/(max-min)
        fill.Size=UDim2.new(a,0,1,0); val.Text=tostring(math.floor(value*100)/100)
        if callback then callback(value) end
    end
    bar.MouseButton1Down:Connect(function()
        local move
        local function update(x) set(min+(max-min)*math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)) end
        update(UserInputService:GetMouseLocation().X)
        move=UserInputService.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end end)
        local endc
        endc=UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then move:Disconnect(); endc:Disconnect() end end)
    end)
    return {Set=set,Get=function() return value end}
end

function Library.TabMethods:AddDropdown(text, callback)
    local card = addCard(self,44)
    local button = new("TextButton",{
        Size=UDim2.new(1,-16,1,-12),
        Position=UDim2.new(0,8,0,6),
        BackgroundColor3=self.Window.Config.surface2,
        Text=tostring(text).."  ▾",
        TextColor3=self.Window.Config.text,
        TextSize=13,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        AutoButtonColor=false
    },card)
    corner(button,7)
    addControlDepth(button, self.Window.Config)
    pad(button,10,10,0,0)

    local drop = {Items={}, Button=button, Selected=nil}
    local menu

    local function ensureMenu()
        if menu then return menu end
        menu = new("Frame",{
            Name="Menu",
            Position=UDim2.new(0,0,1,5),
            Size=UDim2.new(1,0,0,0),
            BackgroundColor3=self.Window.Config.surface2,
            BorderSizePixel=0,
            ZIndex=40,
            Visible=false,
        },card)
        corner(menu,7)
        stroke(menu,self.Window.Config.border)
        new("UIListLayout",{Padding=UDim.new(0,2)},menu)
        return menu
    end

    function drop:Add(item)
        item = tostring(item)
        table.insert(self.Items,item)
        local m = ensureMenu()

        local b = new("TextButton",{
            Size=UDim2.new(1,0,0,30),
            BackgroundTransparency=1,
            Text=tostring(item),
            TextColor3=self.Window.Config.text,
            TextSize=12,
            Font=Enum.Font.Gotham,
            AutoButtonColor=false,
            ZIndex=41,
        },m)

        b.MouseButton1Click:Connect(function()
            playClick(self.Window.Config)
            self.Selected = item
            button.Text = item.."  ▾"
            m.Visible = false
            if callback then callback(item) end
        end)

        m.Size=UDim2.new(1,0,0,#self.Items*32+4)
        return self
    end

    function drop:Set(item, silent)
        item = tostring(item)
        for _, candidate in ipairs(self.Items) do
            if candidate == item then
                self.Selected = item
                button.Text = item.."  ▾"
                if not silent and callback then callback(item) end
                return self
            end
        end
        return self
    end

    function drop:Get()
        return self.Selected
    end

    function drop:Clear()
        self.Selected = nil
        button.Text = tostring(text).."  ▾"
        if menu then
            for _, child in ipairs(menu:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            self.Items = {}
            menu.Size = UDim2.new(1,0,0,0)
        end
        return self
    end

    button.MouseButton1Click:Connect(function()
        playClick(self.Window.Config)
        local m = ensureMenu()
        m.Visible = not m.Visible
    end)

    return drop
end

function Library.TabMethods:AddKeybind(text, callback, options)
    options = options or {}
    local key = options.default or Enum.KeyCode.RightShift
    local card = addCard(self,44)
    local label = addText(card,text,13,self.Window.Config.text)
    label.Position = UDim2.new(0,12,0,0)
    label.Size = UDim2.new(1,-110,1,0)

    local b = new("TextButton", {
        Size = UDim2.fromOffset(82,28),
        Position = UDim2.new(1,-94,.5,-14),
        BackgroundColor3 = self.Window.Config.surface2,
        Text = key.Name,
        TextColor3 = self.Window.Config.muted,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
    }, card)
    corner(b,6)
    addControlDepth(b, self.Window.Config)

    local listening = false
    local api = {}

    b.MouseButton1Click:Connect(function()
        playClick(self.Window.Config)
        listening = true
        b.Text = "Press key..."
    end)

    trackConnection(self.Window, UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end

        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            key = input.KeyCode
            listening = false
            b.Text = key.Name
            if options.onBind then options.onBind(key) end
            return
        end

        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key then
            if options.onPress then
                options.onPress(key)
            elseif callback then
                callback(key)
            end
        end
    end))

    function api:Get()
        return key
    end

    function api:Set(k)
        if typeof(k) == "EnumItem" and k.EnumType == Enum.KeyCode then
            key = k
            b.Text = key.Name
            if options.onBind then options.onBind(key) end
        end
        return api
    end

    function api:SetListening(value)
        listening = value == true
        b.Text = listening and "Press key..." or key.Name
        return api
    end

    api.Instance = b
    return api
end

function Library.TabMethods:AddColorPicker(callback)
    local card=addCard(self,44)
    local current=self.Window.Config.main_color
    local button=new("TextButton",{Size=UDim2.fromOffset(90,28),Position=UDim2.new(1,-102,.5,-14),BackgroundColor3=current,Text="Color",TextColor3=Color3.new(1,1,1),TextSize=12,Font=Enum.Font.Gotham,AutoButtonColor=false},card); corner(button,6)
    button.MouseButton1Click:Connect(function()
        playClick(self.Window.Config)
        if callback then callback(current) end
    end)
    return {Set=function(c) current=c; button.BackgroundColor3=c; if callback then callback(c) end end,Get=function() return current end}
end

function Library.TabMethods:AddHorizontalAlignment()
    local holder=new("Frame",{Size=UDim2.new(1,-4,0,2),BackgroundTransparency=1},self.Page)
    return holder
end

function Library.TabMethods:AddFolder(name, options)
    options = options or {}
    local outer = new("Frame", {
        Name = "Folder_" .. tostring(name),
        Size = UDim2.new(1,-4,0,0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = options.layout_order or 0,
    }, self.Page)

    local header = new("TextButton", {
        Size = UDim2.new(1,0,0,38),
        BackgroundColor3 = self.Window.Config.background,
        Text = (options.collapsed and "▸  " or "▾  ") .. tostring(name),
        TextColor3 = self.Window.Config.main_color,
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    }, outer)
    corner(header,8)
    stroke(header,self.Window.Config.border)
    pad(header,12,8,0,0)

    local body = new("Frame", {
        Name = "Content",
        Position = UDim2.new(0,0,0,44),
        Size = UDim2.new(1,0,0,0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = not options.collapsed,
    }, outer)
    local layout = new("UIListLayout", {
        Padding = UDim.new(0,8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, body)

    local folder = {
        Name = tostring(name),
        Window = self.Window,
        Page = body,
        Layout = layout,
        Header = header,
        Expanded = not options.collapsed,
    }
    setmetatable(folder,{__index=self})

    header.MouseButton1Click:Connect(function()
        folder.Expanded = not folder.Expanded
        body.Visible = folder.Expanded
        header.Text = (folder.Expanded and "▾  " or "▸  ") .. tostring(name)
    end)

    return folder
end


function Library.WindowMethods:SetVisible(visible)
    if visible then self:Show() else self:Hide() end
    return self
end

function Library.WindowMethods:IsVisible()
    return self.Visible == true
end

function Library.WindowMethods:SetSubtitle(text)
    self.Config.subtitle = tostring(text or "")
    if self._subtitleLabel then
        self._subtitleLabel.Text = self.Config.subtitle
    end
    return self
end

function Library.WindowMethods:SetStatus(text, color)
    self.Config.status_text = tostring(text or "")
    if self._statusLabel then
        self._statusLabel.Text = "● " .. self.Config.status_text
        self._statusLabel.TextColor3 = color or self.Config.main_color
    end
    if self._statusDot and color then
        self._statusDot.BackgroundColor3 = color
    end
    return self
end

function Library.WindowMethods:GetTab(name)
    local target = string.lower(tostring(name or ""))
    for _, tab in ipairs(self.Tabs) do
        if string.lower(tab.Name) == target then return tab end
    end
    return nil
end

function Library.WindowMethods:RemoveTab(tabOrName)
    local target = tabOrName
    if type(tabOrName) == "string" then target = self:GetTab(tabOrName) end
    if not target then return false end

    for i, tab in ipairs(self.Tabs) do
        if tab == target then
            if self.ActiveTab == tab then
                local nextTab = self.Tabs[i + 1] or self.Tabs[i - 1]
                self.ActiveTab = nil
                if nextTab then
                    self:SelectTab(nextTab)
                end
            end
            if tab.NavButton then tab.NavButton:Destroy() end
            if tab.Page then tab.Page:Destroy() end
            table.remove(self.Tabs, i)
            if not self.ActiveTab and self.Tabs[1] then
                self:SelectTab(self.Tabs[1])
            end
            return true
        end
    end
    return false
end

function Library.WindowMethods:Notify(title, message, duration)
    return self:AddNotification(title, message, duration)
end

--==============================================================
-- Extra UAI-style features
--==============================================================

function Library.WindowMethods:SetTitle(text)
    local value = tostring(text or "")
    self.Config.title = value
    if self._titleLabel then
        self._titleLabel.Text = value
    elseif self.TopBar then
        local label = self.TopBar:FindFirstChild("TitleLabel")
        if label then label.Text = value end
    end
    return self
end

function Library.WindowMethods:SetSize(width, height)
    local w = math.max(self.Config.min_size.X, tonumber(width) or self.Config.size.X)
    local h = math.max(self.Config.min_size.Y, tonumber(height) or self.Config.size.Y)
    self.Config.size = Vector2.new(w, h)
    self.Root.Size = UDim2.fromOffset(w, h)
    return self
end

function Library.WindowMethods:Restore()
    if self._minimized then
        self:Minimize()
    end
    return self
end

function Library.WindowMethods:Center()
    if self.Root then
        self.Root.AnchorPoint = Vector2.new(.5,.5)
        self.Root.Position = UDim2.fromScale(.5,.5)
    end
    return self
end

function Library.WindowMethods:SetPosition(x, y)
    if self.Root then
        self.Root.AnchorPoint = Vector2.new(0,0)
        self.Root.Position = UDim2.fromOffset(tonumber(x) or 0, tonumber(y) or 0)
    end
    return self
end

function Library.WindowMethods:GetConfig()
    return self.Config
end

function Library.WindowMethods:Minimize()
    if self._minimized then
        self._minimized = false
        self.Body.Visible = true
        self.Root.Size = self._oldSize or UDim2.fromOffset(self.Config.size.X, self.Config.size.Y)
    else
        self._oldSize = self.Root.Size
        self._minimized = true
        self.Body.Visible = false
        self.Root.Size = UDim2.fromOffset(math.max(self.Config.min_size.X, 360), 48)
    end
    return self
end

function Library.WindowMethods:AddNotification(title, message, duration)
    duration = tonumber(duration) or 3
    local gui = self.Gui
    if not gui then return end

    local holder = gui:FindFirstChild("UAI_Notifications")
    if not holder then
        holder = new("Frame", {
            Name = "UAI_Notifications",
            AnchorPoint = Vector2.new(1,1),
            Position = UDim2.new(1,-18,1,-18),
            Size = UDim2.fromOffset(320, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            ZIndex = 1000,
        }, gui)
        new("UIListLayout", {
            Padding = UDim.new(0,8),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, holder)
    end

    local card = new("Frame", {
        Size = UDim2.new(1,0,0,72),
        BackgroundColor3 = self.Config.surface,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        ZIndex = 1001,
    }, holder)
    corner(card, 9)
    stroke(card, self.Config.border)

    local accent = new("Frame", {
        Size = UDim2.new(0,3,1,-20),
        Position = UDim2.new(0,8,0,10),
        BackgroundColor3 = self.Config.main_color,
        BorderSizePixel = 0,
        ZIndex = 1002,
    }, card)
    corner(accent, 2)

    local t = addText(card, title or "UAI", 13, self.Config.text, Enum.Font.GothamSemibold)
    t.Position = UDim2.new(0,22,0,8)
    t.Size = UDim2.new(1,-32,0,20)
    t.ZIndex = 1002

    local m = addText(card, message or "", 11, self.Config.muted)
    m.Position = UDim2.new(0,22,0,29)
    m.Size = UDim2.new(1,-32,0,35)
    m.TextWrapped = true
    m.ZIndex = 1002

    tween(card, TweenInfo.new(.18), {BackgroundTransparency = 0})
    task.delay(duration, function()
        if card and card.Parent then
            tween(card, TweenInfo.new(.18), {BackgroundTransparency = 1})
            task.wait(.2)
            -- Keep the control alive after selection; only close the menu.
            if m then
                m.Visible = false
            end
        end
    end)

    return card
end

function Library.TabMethods:AddSeparator()
    local line = new("Frame", {
        Size = UDim2.new(1,-4,0,1),
        BackgroundColor3 = self.Window.Config.border,
        BorderSizePixel = 0,
    }, self.Page)
    return line
end

function Library.TabMethods:AddSection(title, subtitle)
    local card = addCard(self, subtitle and 58 or 38)
    local label = addText(card, title or "Section", 13, self.Window.Config.main_color, Enum.Font.GothamSemibold)
    label.Position = UDim2.new(0,12,0,6)
    label.Size = UDim2.new(1,-24,0,20)

    if subtitle then
        local desc = addText(card, subtitle, 11, self.Window.Config.muted)
        desc.Position = UDim2.new(0,12,0,27)
        desc.Size = UDim2.new(1,-24,0,20)
        desc.TextWrapped = true
    end
    return card
end

function Library.TabMethods:AddParagraph(title, text)
    local card = addCard(self, 76)
    local head = addText(card, title or "Information", 13, self.Window.Config.text, Enum.Font.GothamSemibold)
    head.Position = UDim2.new(0,12,0,7)
    head.Size = UDim2.new(1,-24,0,20)

    local body = addText(card, text or "", 11, self.Window.Config.muted)
    body.Position = UDim2.new(0,12,0,28)
    body.Size = UDim2.new(1,-24,0,40)
    body.TextWrapped = true
    body.TextYAlignment = Enum.TextYAlignment.Top
    return card
end

function Library.TabMethods:AddProgressBar(text, options)
    options = options or {}
    local value = tonumber(options.default) or 0
    local min = tonumber(options.min) or 0
    local max = tonumber(options.max) or 100
    if max <= min then max = min + 1 end

    local card = addCard(self, 58)
    local label = addText(card, text or "Progress", 12, self.Window.Config.text)
    label.Position = UDim2.new(0,12,0,6)
    label.Size = UDim2.new(1,-75,0,18)

    local valueLabel = addText(card, "", 11, self.Window.Config.muted)
    valueLabel.Position = UDim2.new(1,-58,0,6)
    valueLabel.Size = UDim2.fromOffset(46,18)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local bar = new("Frame", {
        Size = UDim2.new(1,-24,0,7),
        Position = UDim2.new(0,12,1,-17),
        BackgroundColor3 = self.Window.Config.surface2,
        BorderSizePixel = 0,
    }, card)
    corner(bar, 4)

    local fill = new("Frame", {
        Size = UDim2.new(0,0,1,0),
        BackgroundColor3 = self.Window.Config.main_color,
        BorderSizePixel = 0,
    }, bar)
    corner(fill, 4)

    local api = {}
    function api:Set(v)
        value = math.clamp(tonumber(v) or min, min, max)
        local a = (value-min)/(max-min)
        fill.Size = UDim2.new(a,0,1,0)
        valueLabel.Text = tostring(math.floor(value*100)/100)
        return api
    end
    function api:Get() return value end
    api:Set(value)
    return api
end

function Library.TabMethods:AddStatus(text, status)
    local card = addCard(self, 42)
    local dot = new("Frame", {
        Size = UDim2.fromOffset(9,9),
        Position = UDim2.new(0,12,.5,-4),
        BackgroundColor3 = self.Window.Config.main_color,
        BorderSizePixel = 0,
    }, card)
    corner(dot, 5)

    local label = addText(card, text or "Status", 12, self.Window.Config.text)
    label.Position = UDim2.new(0,30,0,0)
    label.Size = UDim2.new(1,-42,1,0)

    local api = {}
    function api:Set(value)
        status = tostring(value or "")
        label.Text = tostring(text or "Status") .. (status ~= "" and " • "..status or "")
        return api
    end
    function api:SetColor(color)
        dot.BackgroundColor3 = color
        return api
    end
    api:Set(status)
    return api
end

function Library.TabMethods:AddMultiDropdown(text, callback)
    local card = addCard(self, 44)
    local button = new("TextButton", {
        Size=UDim2.new(1,-16,1,-12),
        Position=UDim2.new(0,8,0,6),
        BackgroundColor3=self.Window.Config.surface2,
        Text=tostring(text or "Select"),
        TextColor3=self.Window.Config.text,
        TextSize=13,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        AutoButtonColor=false,
    }, card)
    corner(button,7)
    addControlDepth(button, self.Window.Config)
    pad(button,10,10,0,0)

    local api = {Items={}, Selected={}, Button=button}

    local menu = new("Frame", {
        Name="MultiMenu",
        Position=UDim2.new(0,0,1,5),
        Size=UDim2.new(1,0,0,4),
        BackgroundColor3=self.Window.Config.surface2,
        BorderSizePixel=0,
        ZIndex=30,
        Visible=false,
    }, card)
    corner(menu,7)
    stroke(menu,self.Window.Config.border)
    new("UIListLayout",{Padding=UDim.new(0,2)},menu)

    local function refresh()
        local names = {}
        for item, selected in pairs(api.Selected) do
            if selected then names[#names+1] = tostring(item) end
        end
        button.Text = (#names > 0 and table.concat(names,", ") or tostring(text or "Select")) .. "  ▾"
        if callback then callback(names, api.Selected) end
    end

    function api:Add(item)
        item = tostring(item)
        table.insert(self.Items,item)

        local row = new("TextButton", {
            Size=UDim2.new(1,0,0,30),
            BackgroundTransparency=1,
            Text="□  "..item,
            TextColor3=self.Window.Config.text,
            TextSize=12,
            Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
            AutoButtonColor=false,
            ZIndex=31,
        }, menu)
        pad(row,10,4,0,0)

        row.MouseButton1Click:Connect(function()
            playClick(self.Window.Config)
            self.Selected[item] = not self.Selected[item]
            row.Text = (self.Selected[item] and "✓  " or "□  ")..item
            refresh()
        end)

        menu.Size=UDim2.new(1,0,0,#self.Items*32+4)
        return self
    end

    button.MouseButton1Click:Connect(function()
        playClick(self.Window.Config)
        menu.Visible = not menu.Visible
    end)

    return api
end

function Library.TabMethods:AddImage(asset, height)
    local card = addCard(self, tonumber(height) or 150)
    local image = new("ImageLabel", {
        Size=UDim2.new(1,-12,1,-12),
        Position=UDim2.new(0,6,0,6),
        BackgroundColor3=self.Window.Config.surface2,
        Image=tostring(asset or ""),
        ScaleType=Enum.ScaleType.Crop,
        BorderSizePixel=0,
    }, card)
    corner(image,7)
    stroke(image, self.Window.Config.border, 0.15)
    return image
end

function Library.TabMethods:AddColorLabel(text, color)
    local card = addCard(self, 42)
    local label = addText(card, text or "Color", 12, self.Window.Config.text)
    label.Position = UDim2.new(0,12,0,0)
    label.Size = UDim2.new(1,-65,1,0)

    local swatch = new("Frame", {
        Size=UDim2.fromOffset(30,20),
        Position=UDim2.new(1,-42,.5,-10),
        BackgroundColor3=color or self.Window.Config.main_color,
        BorderSizePixel=0,
    }, card)
    corner(swatch,6)
    stroke(swatch,self.Window.Config.border)
    return swatch
end

return setmetatable({}, {__index=Library})


-- ==========================================
-- SEARPH V13 - DEMO INTEGRADA
-- ==========================================

-- ==========================================
-- UAI Easy Library V13 - DEMO COMPLETA
-- ==========================================

local Window = Library:AddWindow("SEARPH • V13 DEMO", {
    main_color = Color3.fromRGB(100, 180, 255),
    theme_name = "Midnight",
    size = Vector2.new(720, 500),
    min_size = Vector2.new(500, 350),

    animated = true,
    glass = true,
    spectral_luxe = true,
    nebula_crystal = true,
    luxe_prism = true,

    particles = true,
    floating_orbs = true,
    aurora = true,
    starfield = true,

    modern_sidebar = true,
    show_tab_icons = true,
    show_search = true,
    show_subtitle = true,

    subtitle = "Spectral Luxe Interface",
    status_text = "ONLINE",

    can_resize = true,
    draggable = true,
    show_close_button = true,
    show_minimize_button = true,
    toggle_key = Enum.KeyCode.RightShift
})

-- HOME
local Home = Window:AddTab("Home")

Home:AddLabel("Bienvenido a SEARPH")
Home:AddLabel("UAI Easy Library V13 • Spectral Luxe")
Home:AddLabel("Demo completa de componentes")

Home:AddButton("Mostrar notificación", function()
    Window:AddNotification(
        "SEARPH",
        "La interfaz está funcionando correctamente.",
        3
    )
end)

Home:AddButton("Ocultar / Mostrar ventana", function()
    Window:Toggle()
end)

-- CONTROLES
local Controls = Window:AddTab("Controls")

Controls:AddLabel("Controles interactivos")

Controls:AddSwitch("Modo Premium", function(value)
    print("Modo Premium:", value)

    Window:AddNotification(
        "Premium",
        value and "Modo activado." or "Modo desactivado.",
        2
    )
end)

Controls:AddTextBox("Escribí algo...", function(text)
    print("Texto recibido:", text)

    Window:AddNotification(
        "Texto",
        "Ingresaste: " .. tostring(text),
        2
    )
end)

Controls:AddSlider("Intensidad", function(value)
    print("Intensidad:", value)
end, {
    min = 0,
    max = 100,
    default = 50
})

local ModeDropdown = Controls:AddDropdown("Modo", function(value)
    print("Modo seleccionado:", value)

    Window:AddNotification(
        "Modo",
        "Seleccionaste: " .. tostring(value),
        2
    )
end)

ModeDropdown:Add("Normal")
ModeDropdown:Add("Premium")
ModeDropdown:Add("Experimental")
ModeDropdown:Add("Minimal")

Controls:AddKeybind(
    "Mostrar ventana",
    function(key)
        print("Keybind ejecutado:", key)
        Window:Toggle()
    end,
    {
        default = Enum.KeyCode.RightShift
    }
)

-- FOLDER
local Advanced = Controls:AddFolder("Advanced")

Advanced:AddLabel("Opciones avanzadas")

Advanced:AddButton("Test 1", function()
    Window:AddNotification(
        "Advanced",
        "Test 1 ejecutado.",
        2
    )
end)

Advanced:AddButton("Test 2", function()
    Window:AddNotification(
        "Advanced",
        "Test 2 ejecutado.",
        2
    )
end)

Advanced:AddSwitch("Animaciones", function(value)
    print("Animaciones:", value)
end)

-- VISUAL
local Visual = Window:AddTab("Visual")

Visual:AddLabel("Configuración visual")

Visual:AddButton("Tema Midnight", function()
    Window:SetTheme("Midnight")
end)

Visual:AddButton("Tema Dark", function()
    Window:SetTheme("Dark")
end)

Visual:AddButton("Tema Violet", function()
    Window:SetTheme("Violet")
end)

Visual:AddButton("Tema Emerald", function()
    Window:SetTheme("Emerald")
end)

Visual:AddButton("Tema Crimson", function()
    Window:SetTheme("Crimson")
end)

Visual:AddButton("Tema Amber", function()
    Window:SetTheme("Amber")
end)

-- SETTINGS
local Settings = Window:AddTab("Settings")

Settings:AddLabel("Configuración")

Settings:AddSwitch("Notificaciones", function(value)
    print("Notificaciones:", value)
end)

Settings:AddSwitch("Animaciones", function(value)
    print("Animaciones:", value)
end)

Settings:AddSlider("Velocidad", function(value)
    print("Velocidad:", value)
end, {
    min = 1,
    max = 100,
    default = 25
})

-- INFO
local Info = Window:AddTab("Info")

Info:AddLabel("SEARPH")
Info:AddLabel("UAI Easy Library V13")
Info:AddLabel("Spectral Luxe Infinite")
Info:AddLabel("Interfaz de demostración")

Info:AddButton("Test Notification", function()
    Window:AddNotification(
        "V13",
        "Todos los componentes principales funcionan.",
        4
    )
end)

-- MOSTRAR
Window:SetVisible(true)

Window:AddNotification(
    "SEARPH",
    "Bienvenido a la demo completa de V13.",
    4
)
