-- Cachos Studio: native implementation of the approved Interface V3.1.
-- Existing libraries retain their controls, callbacks and configuration APIs.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Input = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Runtime = {}
local C = {
    Red = Color3.fromRGB(242, 60, 80), Green = Color3.fromRGB(99, 229, 171),
    Background = Color3.fromRGB(16, 16, 21), Sidebar = Color3.fromRGB(18, 18, 24),
    Panel = Color3.fromRGB(28, 28, 36), Line = Color3.fromRGB(45, 45, 55),
    Text = Color3.fromRGB(242, 242, 245), Muted = Color3.fromRGB(132, 132, 143),
}

local function new(class, parent, properties)
    local object = Instance.new(class)
    for property, value in pairs(properties or {}) do object[property] = value end
    object.Parent = parent
    return object
end
local function frame(parent, position, size, color, radius)
    local object = new("Frame", parent, {
        Position = position, Size = size, BackgroundColor3 = color or C.Panel,
        BorderSizePixel = 0,
    })
    if radius then new("UICorner", object, { CornerRadius = UDim.new(0, radius) }) end
    return object
end
local function stroke(parent, color, transparency)
    return new("UIStroke", parent, {
        Color = color or C.Line, Thickness = 1, Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end
local function text(parent, value, position, size, fontSize, color, bold)
    return new("TextLabel", parent, {
        BackgroundTransparency = 1, Text = tostring(value), Position = position, Size = size,
        Font = bold and Enum.Font.GothamSemibold or Enum.Font.Gotham,
        TextSize = fontSize or 12, TextColor3 = color or C.Text,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    })
end
local function button(parent, value, position, size)
    local object = new("TextButton", parent, {
        Position = position, Size = size, Text = value, BackgroundColor3 = C.Panel,
        BorderSizePixel = 0, AutoButtonColor = false, TextColor3 = C.Text,
        Font = Enum.Font.GothamMedium, TextSize = 11,
    })
    new("UICorner", object, { CornerRadius = UDim.new(0, 8) })
    return object
end
local function tween(object, properties, seconds)
    local motion = TweenService:Create(object, TweenInfo.new(seconds or .28,
        Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties)
    motion:Play()
    return motion
end
local function gui(name)
    local screen = new("ScreenGui", nil, {
        Name = name, ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 100000,
    })
    local candidates = {}
    if gethui then
        local ok, hidden = pcall(gethui)
        if ok and hidden then table.insert(candidates, hidden) end
    end
    table.insert(candidates, game:GetService("CoreGui"))
    table.insert(candidates, LocalPlayer:WaitForChild("PlayerGui"))
    for _, parent in ipairs(candidates) do
        local ok = pcall(function() screen.Parent = parent end)
        if ok then
            local previous = parent:FindFirstChild(name)
            if previous and previous ~= screen then previous:Destroy() end
            return screen
        end
    end
    screen:Destroy()
    error("Não foi possível criar a interface Cachos Studio")
end
local function fit(root, width, height)
    local scale = root:FindFirstChildOfClass("UIScale") or new("UIScale", root, { Scale = 1 })
    local function update()
        local camera = workspace.CurrentCamera
        local size = camera and camera.ViewportSize or Vector2.new(1280, 720)
        scale.Scale = math.min(1, (size.X - 24) / width, (size.Y - 32) / height)
    end
    local viewportConnection
    local function cameraChanged()
        if viewportConnection then viewportConnection:Disconnect() end
        local camera = workspace.CurrentCamera
        if camera then viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(update) end
        update()
    end
    local connection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(cameraChanged)
    cameraChanged()
    root.Destroying:Once(function()
        connection:Disconnect()
        if viewportConnection then viewportConnection:Disconnect() end
    end)
    return scale
end

function Runtime:Notify(message, failed)
    local screen = gui("CachosStudioNotification")
    local card = frame(screen, UDim2.new(1, -24, 1, -24), UDim2.fromOffset(370, 76), C.Panel, 12)
    card.AnchorPoint = Vector2.new(1, 1)
    stroke(card, failed and C.Red or C.Green, .4)
    text(card, failed and "×" or "✓", UDim2.fromOffset(16, 14), UDim2.fromOffset(24, 24), 22,
        failed and C.Red or C.Green, true)
    text(card, "Cachos Studio", UDim2.fromOffset(52, 10), UDim2.new(1, -68, 0, 20), 12, C.Text, true)
    local description = text(card, message, UDim2.fromOffset(52, 32), UDim2.new(1, -68, 0, 32), 11, C.Muted)
    description.TextWrapped, description.TextTruncate = true, Enum.TextTruncate.None
    fit(card, 394, 100)
    task.delay(6, function() if screen.Parent then screen:Destroy() end end)
end

function Runtime:CreateLoader()
    local screen = gui("CachosStudioLoader")
    screen.DisplayOrder = 100001
    local backdrop = frame(screen, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Color3.fromRGB(8, 8, 12))
    backdrop.BackgroundTransparency = .35
    local card = new("CanvasGroup", screen, {
        Name = "Loader", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromOffset(355, 335), BackgroundColor3 = C.Background, BorderSizePixel = 0,
        GroupTransparency = 1,
    })
    new("UICorner", card, { CornerRadius = UDim.new(0, 19) })
    stroke(card, Color3.fromRGB(66, 64, 74))
    new("UIGradient", card, { Rotation = 125, Color = ColorSequence.new(
        Color3.fromRGB(33, 32, 41), Color3.fromRGB(17, 17, 23)) })
    local scale = fit(card, 355, 335)
    local finalScale = scale.Scale
    scale.Scale = finalScale * .88
    tween(scale, { Scale = finalScale }, .65)
    tween(card, { GroupTransparency = 0 }, .65)
    text(card, "CACHOS STUDIO", UDim2.fromOffset(26, 20), UDim2.fromOffset(220, 22), 10, C.Muted, true)
    local close = button(card, "×", UDim2.new(1, -44, 0, 18), UDim2.fromOffset(24, 24))
    close.BackgroundTransparency, close.TextColor3, close.TextSize = 1, C.Muted, 20
    local ring = frame(card, UDim2.new(.5, -58, 0, 65), UDim2.fromOffset(116, 116), C.Panel, 58)
    ring.BackgroundTransparency = 1
    local base = stroke(ring, C.Red, .7)
    local arc = frame(ring, UDim2.fromScale(.5, .5), UDim2.fromScale(1, 1))
    arc.BackgroundTransparency, arc.AnchorPoint = 1, Vector2.new(.5, .5)
    local segments = {}
    -- Draw a real partial arc; rotating a full circle would be invisible.
    for index = 0, 24 do
        local degrees = -135 + index * 4
        local angle = math.rad(degrees)
        local dot = frame(arc, UDim2.fromOffset(58 + math.cos(angle) * 57,
            58 + math.sin(angle) * 57), UDim2.fromOffset(4, 5), C.Red, 2)
        dot.AnchorPoint, dot.Rotation = Vector2.new(.5, .5), degrees + 90
        table.insert(segments, dot)
    end
    local halo = frame(ring, UDim2.fromScale(.5, .5), UDim2.fromOffset(92, 92), C.Red, 46)
    halo.AnchorPoint, halo.BackgroundTransparency = Vector2.new(.5, .5), .94
    local core = frame(ring, UDim2.fromScale(.5, .5), UDim2.fromOffset(76, 76),
        Color3.fromRGB(31, 21, 29), 38)
    core.AnchorPoint = Vector2.new(.5, .5)
    local coreStroke = stroke(core, C.Red, .25)
    local symbol = text(core, "ϟ", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 38, C.Red, true)
    symbol.TextXAlignment = Enum.TextXAlignment.Center
    local symbolScale = new("UIScale", symbol, { Scale = 1 })
    local title = text(card, "Procurando seu script", UDim2.fromOffset(22, 205),
        UDim2.new(1, -44, 0, 26), 18, C.Text, true)
    title.TextXAlignment = Enum.TextXAlignment.Center
    local description = text(card, "", UDim2.fromOffset(26, 240), UDim2.new(1, -52, 0, 36), 11, C.Muted)
    description.TextXAlignment, description.TextWrapped = Enum.TextXAlignment.Center, true
    description.TextTruncate = Enum.TextTruncate.None
    local steps = {}
    for index = 1, 3 do
        steps[index] = frame(card, UDim2.new(.5, -77 + (index - 1) * 53, 0, 291),
            UDim2.fromOffset(47, 3), index == 1 and C.Red or C.Line, 2)
    end
    local meta = text(card, "", UDim2.fromOffset(20, 303), UDim2.new(1, -40, 0, 16), 9, C.Muted)
    meta.TextXAlignment = Enum.TextXAlignment.Center
    local active, color = true, C.Red
    local started = os.clock()
    local heartbeat = RunService.Heartbeat:Connect(function(dt)
        if not active or not screen.Parent then return end
        arc.Rotation = (arc.Rotation + dt * 288) % 360
        local pulse = (math.sin((os.clock() - started) * math.pi * 1.25) + 1) / 2
        halo.Size = UDim2.fromOffset(88 + pulse * 16, 88 + pulse * 16)
        halo.BackgroundTransparency = .96 - pulse * .1
        coreStroke.Transparency = .4 - pulse * .3
        symbolScale.Scale = 1 + pulse * .07
    end)
    screen.Destroying:Once(function() active = false; heartbeat:Disconnect() end)
    local api = { Closed = false }
    function api:Destroy()
        if self.Closed then return end
        self.Closed = true
        active = false
        heartbeat:Disconnect()
        if screen.Parent then
            tween(card, { GroupTransparency = 1 }, .22)
            tween(backdrop, { BackgroundTransparency = 1 }, .22)
            task.delay(.24, function() screen:Destroy() end)
        end
    end
    close.Activated:Connect(function() api:Destroy() end)
    local function paint(nextColor, count)
        color = nextColor
        base.Color, coreStroke.Color, halo.BackgroundColor3, symbol.TextColor3 = color, color, color, color
        for _, segment in ipairs(segments) do segment.BackgroundColor3 = color end
        for index, step in ipairs(steps) do
            tween(step, { BackgroundColor3 = index <= count and color or C.Line }, .3)
        end
    end
    function api:SetLoading(placeId)
        if self.Closed then return end
        paint(C.Red, 1)
        symbol.Text, title.Text = "ϟ", "Procurando seu script"
        description.Text = "Identificando o jogo e consultando\no banco de scripts."
        meta.Text = "PLACE ID · " .. tostring(placeId)
    end
    function api:SetSearching()
        if not self.Closed then paint(C.Red, 2) end
    end
    function api:SetSuccess(name)
        if self.Closed then return end
        paint(C.Green, 3)
        symbol.Text, title.Text = "✓", "Script encontrado"
        description.Text = tostring(name) .. "\nPreparando sua interface."
        meta.Text = "ROTA ENCONTRADA · GUI PRONTA"
    end
    function api:SetFailure(message, placeId)
        if self.Closed then Runtime:Notify(message, true); return end
        paint(C.Red, 2)
        symbol.Text = "×"
        title.Text = string.find(tostring(message), "encontrar", 1, true)
            and "Jogo sem suporte" or "Não foi possível carregar"
        description.Text = tostring(message)
        meta.Text = "PLACE ID · " .. tostring(placeId)
        symbolScale.Scale = .5
        tween(symbolScale, { Scale = 1 }, .35)
        Runtime:Notify(message, true)
    end
    return api
end

local function playerProfile(sidebar)
    frame(sidebar, UDim2.new(0, 18, 1, -81), UDim2.new(1, -36, 0, 1), C.Line)
    local profile = frame(sidebar, UDim2.new(0, 18, 1, -67), UDim2.new(1, -36, 0, 48))
    profile.BackgroundTransparency = 1
    local fallback = frame(profile, UDim2.fromOffset(0, 6), UDim2.fromOffset(36, 36), C.Panel, 18)
    stroke(fallback, C.Red, .6)
    local initial = text(fallback, string.sub(LocalPlayer.DisplayName, 1, 1),
        UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 14, C.Text, true)
    initial.TextXAlignment = Enum.TextXAlignment.Center
    local avatar = new("ImageLabel", fallback, {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = "", Visible = false,
        ScaleType = Enum.ScaleType.Crop,
    })
    new("UICorner", avatar, { CornerRadius = UDim.new(1, 0) })
    text(profile, LocalPlayer.DisplayName, UDim2.fromOffset(46, 7),
        UDim2.new(1, -46, 0, 18), 11, C.Text, true)
    text(profile, "@" .. LocalPlayer.Name, UDim2.fromOffset(46, 26),
        UDim2.new(1, -46, 0, 14), 9, C.Muted)
    task.spawn(function()
        for _ = 1, 3 do
            local ok, image, ready = pcall(Players.GetUserThumbnailAsync, Players,
                LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
            if not avatar.Parent then return end
            if ok and ready and image ~= "" then
                avatar.Image, avatar.Visible, initial.Visible = image, true, false
                return
            end
            task.wait(1)
        end
    end)
end

local function makeShell(root, existingContent, gameName, onClose)
    -- Keep the original root and library lifecycle, replacing only its chrome.
    for _, child in ipairs(root:GetChildren()) do
        if child:IsA("GuiObject") and child ~= existingContent then child.Visible = false end
        if child:IsA("UIGradient") then child.Enabled = false end
    end
    root.BackgroundColor3, root.BackgroundTransparency, root.BorderSizePixel = C.Background, 0, 0
    local corner = root:FindFirstChildOfClass("UICorner") or new("UICorner", root)
    corner.CornerRadius = UDim.new(0, 20)
    local border = root:FindFirstChildOfClass("UIStroke") or stroke(root)
    border.Color, border.Transparency = Color3.fromRGB(52, 52, 61), 0
    local approvedSize = UDim2.fromOffset(1020, 650)
    root.Size, root.AnchorPoint, root.Position = approvedSize,
        Vector2.new(.5, .5), UDim2.fromScale(.5, .5)
    root.ClipsDescendants = true
    local chrome = new("CanvasGroup", root, {
        Name = "CachosApprovedUI", Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, GroupTransparency = 1,
    })
    local header = frame(chrome, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 76), Color3.fromRGB(21, 21, 28))
    new("UIGradient", header, { Color = ColorSequence.new(
        Color3.fromRGB(31, 20, 27), Color3.fromRGB(21, 21, 28)) })
    frame(header, UDim2.new(0, 0, 1, -1), UDim2.new(1, 0, 0, 1), C.Line)
    local mark = frame(header, UDim2.fromOffset(26, 20), UDim2.fromOffset(37, 37), C.Red, 11)
    local bolt = text(mark, "ϟ", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 27, C.Text, true)
    bolt.TextXAlignment = Enum.TextXAlignment.Center
    text(header, "Cachos Studio.", UDim2.fromOffset(76, 17), UDim2.fromOffset(270, 26), 17, C.Text, true)
    text(header, "SCRIPT WORKSPACE", UDim2.fromOffset(76, 43), UDim2.fromOffset(220, 16), 9, C.Muted)
    local close = button(header, "×", UDim2.new(1, -48, 0, 22), UDim2.fromOffset(28, 28))
    close.BackgroundTransparency, close.TextSize, close.TextColor3 = 1, 21, C.Muted
    close.Activated:Connect(onClose)
    local sidebar = frame(chrome, UDim2.fromOffset(0, 76), UDim2.new(0, 208, 1, -76), C.Sidebar)
    frame(sidebar, UDim2.new(1, -1, 0, 0), UDim2.new(0, 1, 1, 0), C.Line)
    text(sidebar, "JOGO CONECTADO", UDim2.fromOffset(18, 24), UDim2.fromOffset(170, 16), 9, C.Muted, true)
    local gameCard = frame(sidebar, UDim2.fromOffset(18, 52), UDim2.fromOffset(172, 201),
        Color3.fromRGB(29, 26, 36), 12)
    stroke(gameCard, Color3.fromRGB(52, 48, 58))
    new("UIGradient", gameCard, { Rotation = 120, Color = ColorSequence.new(
        Color3.fromRGB(48, 27, 39), Color3.fromRGB(28, 27, 38)) })
    local art = text(gameCard, "◇", UDim2.fromOffset(12, 12), UDim2.fromOffset(148, 84), 62, Color3.fromRGB(255, 163, 175))
    art.TextXAlignment, art.Rotation = Enum.TextXAlignment.Center, -12
    local gameTitle = text(gameCard, gameName, UDim2.fromOffset(12, 98),
        UDim2.fromOffset(148, 46), 12, C.Text, true)
    gameTitle.TextWrapped, gameTitle.TextTruncate = true, Enum.TextTruncate.None
    text(gameCard, tostring(game.PlaceId), UDim2.fromOffset(12, 146), UDim2.fromOffset(148, 14), 9, C.Muted)
    text(gameCard, "●  Script disponível", UDim2.fromOffset(12, 172), UDim2.fromOffset(148, 16), 10, C.Green)
    playerProfile(sidebar)
    local content = frame(chrome, UDim2.fromOffset(236, 100), UDim2.new(1, -264, 1, -120))
    content.BackgroundTransparency = 1
    local title = text(content, "Visão geral", UDim2.fromOffset(0, 0),
        UDim2.new(1, 0, 0, 32), 24, C.Text, true)
    local description = text(content, "Seu script. Tudo no lugar certo.", UDim2.fromOffset(0, 34),
        UDim2.new(1, 0, 0, 22), 11, C.Muted)
    local nav = new("ScrollingFrame", content, {
        Name = "Tabs", Position = UDim2.fromOffset(0, 77), Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Color3.fromRGB(22, 22, 29), BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0), ScrollBarThickness = 2,
        ScrollBarImageColor3 = C.Red, ScrollingDirection = Enum.ScrollingDirection.X,
    })
    new("UICorner", nav, { CornerRadius = UDim.new(0, 11) })
    stroke(nav)
    local indicator = frame(nav, UDim2.fromOffset(4, 4), UDim2.fromOffset(140, 34),
        Color3.fromRGB(49, 25, 35), 8)
    stroke(indicator, C.Red, .65)
    local slot = new("CanvasGroup", content, {
        Name = "ScriptControls", Position = UDim2.fromOffset(0, 140),
        Size = UDim2.new(1, 0, 1, -175), BackgroundTransparency = 1,
    })
    existingContent.Parent = slot
    local resetting = false
    local function pinContent()
        if resetting or not existingContent.Parent then return end
        resetting = true
        existingContent.AnchorPoint, existingContent.Position, existingContent.Size =
            Vector2.zero, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1)
        existingContent.BackgroundTransparency, existingContent.Visible = 1, true
        resetting = false
    end
    pinContent()
    local connections = {
        existingContent:GetPropertyChangedSignal("Size"):Connect(pinContent),
        existingContent:GetPropertyChangedSignal("Position"):Connect(pinContent),
        root:GetPropertyChangedSignal("Size"):Connect(function()
            -- Legacy opening tweens must not restore the previous window dimensions.
            if root.Size ~= approvedSize then root.Size = approvedSize end
        end),
    }
    frame(content, UDim2.new(0, 0, 1, -25), UDim2.new(1, 0, 0, 1), C.Line)
    text(content, "●  Cachos Studio", UDim2.new(0, 0, 1, -19), UDim2.fromOffset(250, 16), 9, C.Muted)
    local shortcut = text(content, "Menu · RightShift", UDim2.new(1, -170, 1, -19), UDim2.fromOffset(170, 16), 9, C.Muted)
    shortcut.TextXAlignment = Enum.TextXAlignment.Right
    local settings = button(sidebar, "⚙  Configurações", UDim2.fromOffset(18, 277), UDim2.fromOffset(172, 34))
    settings.BackgroundTransparency, settings.TextColor3 = 1, C.Muted
    local entries, selected = {}, nil
    local shell = { Root = root, Slot = slot }
    local function arrange()
        local width = math.max(132, nav.AbsoluteSize.X / math.max(1, #entries))
        for index, entry in ipairs(entries) do
            entry.Button.Position, entry.Button.Size = UDim2.fromOffset((index - 1) * width + 4, 4),
                UDim2.fromOffset(width - 8, 34)
        end
        nav.CanvasSize = UDim2.fromOffset(#entries * width, 0)
        if selected then
            tween(indicator, { Position = selected.Button.Position, Size = selected.Button.Size }, .32)
        end
    end
    function shell:AddTab(name, activate)
        local entry = { Name = tostring(name), Activate = activate }
        entry.Button = button(nav, entry.Name, UDim2.fromOffset(0, 4), UDim2.fromOffset(132, 34))
        entry.Button.BackgroundTransparency, entry.Button.TextColor3 = 1, C.Muted
        entry.Button.Activated:Connect(function() activate(); self:Select(entry) end)
        table.insert(entries, entry)
        arrange()
        if not selected then self:Select(entry) end
        return entry
    end
    function shell:Select(entry)
        selected = entry
        title.Text = entry.Name
        description.Text = "Configure as opções de " .. entry.Name .. "."
        for _, other in ipairs(entries) do
            tween(other.Button, { TextColor3 = other == entry and Color3.fromRGB(255, 157, 170) or C.Muted }, .2)
        end
        arrange()
        slot.GroupTransparency, slot.Position = .8, UDim2.fromOffset(12, 140)
        tween(slot, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 140) }, .3)
    end
    settings.Activated:Connect(function()
        for _, entry in ipairs(entries) do
            local name = string.lower(entry.Name)
            if name == "settings" or string.find(name, "config") then entry.Activate(); shell:Select(entry); return end
        end
    end)
    table.insert(connections, nav:GetPropertyChangedSignal("AbsoluteSize"):Connect(arrange))
    -- Dragging supports both pointer and touch without modifying library widgets.
    local dragInput, dragging, dragStart, origin
    table.insert(connections, header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, origin = true, input.Position, root.Position
        end
    end))
    table.insert(connections, header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end))
    table.insert(connections, Input.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(origin.X.Scale, origin.X.Offset + delta.X, origin.Y.Scale, origin.Y.Offset + delta.Y)
        end
    end))
    table.insert(connections, Input.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
    root.Destroying:Once(function() for _, connection in ipairs(connections) do connection:Disconnect() end end)
    fit(root, 1020, 650)
    tween(chrome, { GroupTransparency = 0 }, .6)
    return shell
end

function Runtime:MountNotice(screen, existingContent, gameName)
    for _, child in ipairs(screen:GetChildren()) do
        if child:IsA("GuiObject") then child.Visible = false end
    end
    local root = frame(screen, UDim2.fromScale(.5, .5), UDim2.fromOffset(1020, 650), C.Background, 20)
    local function close()
        screen:Destroy()
        local blur = game:GetService("Lighting"):FindFirstChild("DQ_NoticeBlur")
        if blur then blur:Destroy() end
    end
    local shell = makeShell(root, existingContent, gameName, close)
    shell:AddTab("Informações", function() existingContent.Visible = true end)
    local blur = game:GetService("Lighting"):FindFirstChild("DQ_NoticeBlur")
    if blur then tween(blur, { Size = 0 }, .2) end
    local connection = Input.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightShift then root.Visible = not root.Visible end
    end)
    root.Destroying:Once(function() connection:Disconnect() end)
end

function Runtime:WrapModule(name, library, gameName)
    if name ~= "Library" and name ~= "Fluent" and name ~= "OuroFlow" and name ~= "Sirius" then return library end
    local originalCreate = (name == "Fluent" or name == "OuroFlow") and library.Window or library.CreateWindow
    if type(originalCreate) ~= "function" then return library end
    if name == "Library" then
        library.Scheme.BackgroundColor, library.Scheme.MainColor = C.Background, C.Panel
        library.Scheme.AccentColor, library.Scheme.OutlineColor, library.Scheme.FontColor = C.Red, C.Line, C.Text
        library.Scheme.Font = Font.fromEnum(Enum.Font.Gotham)
    end
    local function create(self, options, ...)
        options = type(options) == "table" and table.clone(options) or {}
        if name == "Library" then
            options.Title, options.CornerRadius, options.Font = "Cachos Studio", 12, Enum.Font.Gotham
            options.Center, options.AutoShow, options.Size = true, true, UDim2.fromOffset(1020, 650)
            options.ToggleKeybind, options.ShowCustomCursor = Enum.KeyCode.RightShift, false
            options.Animations = {
                ToggleWindow = true, TabSwitch = true, Groupbox = true,
                GroupboxCollapse = true, Dropdown = true, KeyPicker = true, SubTabUnderline = true,
            }
            options.TabTransitionTime, options.Resizable = .28, false
            options.EnableSidebarResize, options.EnableCompacting, options.SidebarCompacted = false, false, false
            options.Minimizable = false
        elseif name == "Fluent" then
            options.Title, options.Size, options.MinimizeKey = "Cachos Studio", UDim2.fromOffset(1020, 650), Enum.KeyCode.RightShift
            options.Acrylic = false
        elseif name == "OuroFlow" then
            options.Title, options.Size, options.Keybind = "Cachos Studio", UDim2.fromOffset(1020, 650), Enum.KeyCode.RightShift
            if library.SetTheme then
                library:SetTheme({
                    Background = C.Background, Surface = C.Sidebar, Surface2 = C.Panel,
                    Surface3 = C.Panel, Stroke = C.Line, Accent = C.Red, Text = C.Text, Muted = C.Muted,
                }, true)
            end
        elseif name == "Sirius" then
            options.name = "Cachos Studio"
            options.theme = type(options.theme) == "table" and table.clone(options.theme) or {}
            options.theme.AccentColor, options.theme.AccentStroke = C.Red, C.Red
        end
        local window = originalCreate(self, options, ...)
        local root, content
        if name == "Library" then root, content = window.MainFrame, library.WindowContainer
        elseif name == "Fluent" then root, content = window.Root, window.ContainerCanvas
        elseif name == "OuroFlow" then root, content = window.Body, window.Content
        elseif name == "Sirius" then root, content = window.main, window.elements end
        if not root or not content then error("Estrutura da GUI não reconhecida: " .. name) end
        local shell = makeShell(root, content, gameName, function()
            if name == "Library" then window:Toggle(false)
            elseif name == "Fluent" then window:Minimize()
            elseif name == "OuroFlow" then window:Toggle(false)
            else window:Hide() end
        end)
        local wrapped, selectionEntries, tabCount = {}, {}, 0
        local function wrapTabMethod(method)
            local original = window[method]
            if type(original) ~= "function" then return end
            window[method] = function(win, ...)
                local tab = original(win, ...)
                if wrapped[tab] then return tab end
                wrapped[tab] = true
                tabCount += 1
                local tabIndex = tabCount
                local first = select(1, ...)
                local tabName = tab.Name or tab.name or (type(first) == "table" and (first.Title or first.Name or first.name)) or first or "Main"
                local entry
                local function activate()
                    if name == "Library" then tab:Show()
                    elseif name == "Fluent" then window:SelectTab(tabIndex)
                    elseif name == "OuroFlow" then window:SelectTab(tab)
                    else tab:Select() end
                end
                entry = shell:AddTab(tabName, activate)
                selectionEntries[name == "Fluent" and tabIndex or tab] = entry
                if name == "Library" then
                    local show = tab.Show
                    tab.Show = function(t, ...) local result = show(t, ...); shell:Select(entry); return result end
                end
                return tab
            end
        end
        if name == "Library" then wrapTabMethod("AddTab"); wrapTabMethod("AddKeyTab")
        elseif name == "Fluent" then wrapTabMethod("Tab"); wrapTabMethod("AddTab"); wrapTabMethod("CreateTab")
        elseif name == "OuroFlow" then wrapTabMethod("Tab"); wrapTabMethod("AddTab"); wrapTabMethod("CreateTab")
        else wrapTabMethod("CreateTab") end
        if name == "Fluent" or name == "OuroFlow" then
            local selectTab = window.SelectTab
            window.SelectTab = function(win, selected, ...)
                local result = selectTab(win, selected, ...)
                if selectionEntries[selected] then shell:Select(selectionEntries[selected]) end
                return result
            end
        end
        if name == "Library" then
            library:UpdateColorsUsingRegistry()
            -- Native subtab chips are inside the retained content, so remain available.
        end
        return window
    end
    library.CreateWindow = create
    if library.Window == originalCreate then library.Window = create end
    return library
end

return Runtime
