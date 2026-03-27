local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Neo = {}
Neo.__index = Neo

local colors = {
    Background = Color3.fromRGB(18, 18, 22),
    Sidebar    = Color3.fromRGB(28, 28, 34),
    Content    = Color3.fromRGB(24, 24, 30),
    Button     = Color3.fromRGB(45, 45, 55),
    Topbar     = Color3.fromRGB(30, 30, 38),
    Accent     = Color3.fromRGB(0, 170, 255),
    Success    = Color3.fromRGB(0, 200, 120),
}

local function highlightTab(sidebar: Frame, selectedBtn: TextButton)
    for _, child in ipairs(sidebar:GetChildren()) do
        if child:IsA("TextButton") then
            child.BackgroundColor3 = colors.Button
        end
    end
    selectedBtn.BackgroundColor3 = colors.Accent
end

local function createRebindRow(parent: Instance, labelText: string, defaultKey: Enum.KeyCode, onSet: (Enum.KeyCode)->(), state)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0, 260, 0, 30)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = colors.Button
    btn.Text = labelText .. ": " .. defaultKey.Name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = row

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        btn.Text = labelText .. ": Press a key..."
        state.isBindingKey = true
        state.suppressKeyCode = nil

        local beganConn, endedConn
        beganConn = UserInputService.InputBegan:Connect(function(input, gpe)
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                onSet(input.KeyCode)
                btn.Text = labelText .. ": " .. input.KeyCode.Name
                state.suppressKeyCode = input.KeyCode

                if endedConn then endedConn:Disconnect() end
                endedConn = UserInputService.InputEnded:Connect(function(endInput, _)
                    if endInput.UserInputType == Enum.UserInputType.Keyboard and endInput.KeyCode == state.suppressKeyCode then
                        state.isBindingKey = false
                        state.suppressKeyCode = nil
                        if beganConn then beganConn:Disconnect() end
                        if endedConn then endedConn:Disconnect() end
                    end
                end)
            end
        end)
    end)

    return row
end

function Neo:CreateWindow(title: string)
    local window = {}
    setmetatable(window, Neo)

    window._state = {
        isBindingKey = false,
        suppressKeyCode = nil,
        toggleKey = Enum.KeyCode.Insert,
        unloadKey = Enum.KeyCode.Delete,
    }

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NeoModMenu"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = game:GetService("CoreGui")
    window.Gui = screenGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 440, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -220, 0.5, -200)
    mainFrame.BackgroundColor3 = colors.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Visible = true
    mainFrame.Parent = screenGui
    window.MainFrame = mainFrame

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainFrame

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = colors.Topbar
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Neo"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 20
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    local sidebar = Instance.new("ScrollingFrame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 150, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = colors.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.ScrollBarThickness = 0
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebar.Parent = mainFrame
    window.Sidebar = sidebar

    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 8)
    sidebarPadding.PaddingLeft = UDim.new(0, 10)
    sidebarPadding.PaddingRight = UDim.new(0, 10)
    sidebarPadding.PaddingBottom = UDim.new(0, 4)
    sidebarPadding.Parent = sidebar

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.FillDirection = Enum.FillDirection.Vertical
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 6)
    sidebarLayout.Parent = sidebar

    local contentHolder = Instance.new("ScrollingFrame")
    contentHolder.Name = "ContentHolder"
    contentHolder.Size = UDim2.new(1, -150, 1, -40)
    contentHolder.Position = UDim2.new(0, 150, 0, 40)
    contentHolder.BackgroundColor3 = colors.Content
    contentHolder.BorderSizePixel = 0
    contentHolder.ScrollBarThickness = 0
    contentHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentHolder.Parent = mainFrame
    window.Content = contentHolder

    local chPadding = Instance.new("UIPadding")
    chPadding.PaddingTop = UDim.new(0, 10)
    chPadding.PaddingLeft = UDim.new(0, 0)
    chPadding.PaddingBottom = UDim.new(0, 4)
    chPadding.Parent = contentHolder

    window.Pages = {}
    window._hasDefaultTab = false
    window._tabOrder = 0
    window._settingsCreated = false
    window._connections = {}

    function window:Toggle()
        self.MainFrame.Visible = not self.MainFrame.Visible
    end

    function window:Destroy()
        for _, c in ipairs(self._connections) do
            pcall(function() c:Disconnect() end)
        end
        if self.Gui then self.Gui:Destroy() end
    end

    table.insert(window._connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if window._state.isBindingKey then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == window._state.toggleKey then
                window:Toggle()
            elseif input.KeyCode == window._state.unloadKey then
                window:Destroy()
            end
        end
    end))

    window:_createSettingsTab()

    return window
end

function Neo:_createSettingsTab()
    if self._settingsCreated then return end
    self._settingsCreated = true

    local tab = {}
    setmetatable(tab, Neo)

    local btn = Instance.new("TextButton")
    btn.Name = "SettingsTab"
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = colors.Button
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Text = "Settings"
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.LayoutOrder = 1_000_000
    btn.Parent = self.Sidebar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local page = Instance.new("Frame")
    page.Name = "SettingsPage"
    page.Size = UDim2.new(1, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = self.Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.Parent = page

    self.Pages["Settings"] = page

    tab.Page = page
    tab._mainFrame = self.MainFrame

    local function selectThis()
        for _, p in pairs(self.Pages) do p.Visible = false end
        page.Visible = true
        highlightTab(self.Sidebar, btn)
    end

    btn.MouseButton1Click:Connect(selectThis)

    createRebindRow(page, "Toggle Menu", self._state.toggleKey, function(newKey)
        self._state.toggleKey = newKey
    end, self._state)

    createRebindRow(page, "Unload Menu", self._state.unloadKey, function(newKey)
        self._state.unloadKey = newKey
    end, self._state)
end

function Neo:CreateTab(name: string)
    if string.lower(name) == "settings" then
        warn("[Neo] 'Settings' tab name is reserved by the library. Your tab will be named 'Settings (Custom)'.")
        name = "Settings (Custom)"
    end

    local tab = {}
    setmetatable(tab, Neo)

    local btn = Instance.new("TextButton")
    btn.Name = name .. "Tab"
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = colors.Button
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Text = name
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    self._tabOrder += 1
    btn.LayoutOrder = self._tabOrder
    btn.Parent = self.Sidebar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = self.Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.Parent = page

    self.Pages[name] = page

    tab.Page = page
    tab._mainFrame = self.MainFrame

    local function selectThis()
        for _, p in pairs(self.Pages) do p.Visible = false end
        page.Visible = true
        highlightTab(self.Sidebar, btn)
    end

    btn.MouseButton1Click:Connect(selectThis)

    if not self._hasDefaultTab then
        self._hasDefaultTab = true
        selectThis()
    end

    return tab
end

function Neo:CreateLabel(text: string)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 18
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = self.Page
    return lbl
end

function Neo:UpdateLabelText(label: TextLabel, newText: string)
    if label and label:IsA("TextLabel") then
        label.Text = newText
    else
        warn("[Neo] Tried to update label text on invalid object.")
    end
end

function Neo:CreateButton(text: string, callback: ()->())
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 260, 0, 30)
    btn.BackgroundColor3 = colors.Button
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = self.Page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return btn
end

function Neo:CreateToggle(text: string, callback: (boolean)->())
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 265, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = self.Page

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 16
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 30, 0, 30)
    box.Position = UDim2.new(1, -35, 0, 0)
    box.BackgroundColor3 = colors.Button
    box.Text = ""
    box.BorderSizePixel = 0
    box.AutoButtonColor = false
    box.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = box

    local state = false
    box.MouseButton1Click:Connect(function()
        state = not state
        box.BackgroundColor3 = state and colors.Success or colors.Button
        if callback then callback(state) end
    end)

    return frame
end

function Neo:CreateSlider(text: string, min: number, max: number, defaultValue: number, step: number, callback: (number)->())
    step = step or 1

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = self.Page

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 60, 0, 20)
    valLbl.Position = UDim2.new(1, -60, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(defaultValue)
    valLbl.Font = Enum.Font.Gotham
    valLbl.TextSize = 14
    valLbl.TextColor3 = Color3.fromRGB(150, 200, 255)
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 10)
    bar.Position = UDim2.new(0, 0, 0, 25)
    bar.BackgroundColor3 = colors.Button
    bar.BorderSizePixel = 0
    bar.Parent = frame

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = colors.Accent
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local function roundToStep(value, step)
        return math.floor(value / step + 0.5) * step
    end

    local startValue = math.clamp(defaultValue, min, max)
    startValue = roundToStep(startValue, step)
    local startPct = (startValue - min) / (max - min)
    fill.Size = UDim2.new(startPct, 0, 1, 0)

    valLbl.Text = tostring(startValue)

    local dragging = false
    local mainFrame = self._mainFrame

    local function update(input)
        local rel = input.Position.X - bar.AbsolutePosition.X
        local pct = math.clamp(rel / bar.AbsoluteSize.X, 0, 1)

        local rawValue = min + (max - min) * pct
        local steppedValue = roundToStep(rawValue, step)
        local value = math.clamp(steppedValue, min, max)

        local newPct = (value - min) / (max - min)
        fill.Size = UDim2.new(newPct, 0, 1, 0)

        local decimals = tostring(step):find("%.") and #tostring(step):split(".")[2] or 0
        valLbl.Text = string.format("%." .. decimals .. "f", value)

        if callback then
            callback(value)
        end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            if mainFrame then
                mainFrame.Active = false
                mainFrame.Draggable = false
            end
            update(input)
        end
    end)

    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            if mainFrame then
                mainFrame.Active = true
                mainFrame.Draggable = true
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)

    return frame
end

function Neo:CreateColorPicker(text: string, defaultColor: Color3, callback: (Color3)->())
    defaultColor = defaultColor or colors.Accent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = self.Page

    local mainButton = Instance.new("TextButton")
    mainButton.Size = UDim2.new(1, 0, 0, 30)
    mainButton.BackgroundColor3 = colors.Button
    mainButton.Text = ""
    mainButton.BorderSizePixel = 0
    mainButton.AutoButtonColor = false
    mainButton.Parent = frame

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 6)
    mainCorner.Parent = mainButton

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -115, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = text
    title.Font = Enum.Font.Gotham
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainButton

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 70, 1, 0)
    valueLabel.Position = UDim2.new(1, -100, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = ""
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 12
    valueLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = mainButton

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 20, 0, 20)
    preview.Position = UDim2.new(1, -25, 0.5, -10)
    preview.BackgroundColor3 = defaultColor
    preview.BorderSizePixel = 0
    preview.Parent = mainButton

    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 5)
    previewCorner.Parent = preview

    local expandedHolder = Instance.new("Frame")
    expandedHolder.Size = UDim2.new(1, 0, 0, 142)
    expandedHolder.Position = UDim2.new(0, 0, 0, 35)
    expandedHolder.BackgroundColor3 = colors.Sidebar
    expandedHolder.BorderSizePixel = 0
    expandedHolder.Visible = false
    expandedHolder.Parent = frame

    local holderCorner = Instance.new("UICorner")
    holderCorner.CornerRadius = UDim.new(0, 6)
    holderCorner.Parent = expandedHolder

    local holderPadding = Instance.new("UIPadding")
    holderPadding.PaddingTop = UDim.new(0, 8)
    holderPadding.PaddingBottom = UDim.new(0, 8)
    holderPadding.PaddingLeft = UDim.new(0, 8)
    holderPadding.PaddingRight = UDim.new(0, 8)
    holderPadding.Parent = expandedHolder

    local currentColor = defaultColor
    local isExpanded = false
    local mainFrame = self._mainFrame
    local currentH, currentS, currentV = Color3.toHSV(defaultColor)

    local function getRgbString(color: Color3)
        return string.format("%d,%d,%d", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
    end

    local function applyColor(color: Color3)
        currentColor = color
        preview.BackgroundColor3 = color
        valueLabel.Text = getRgbString(color)
        if callback then
            callback(color)
        end
    end

    local pickerBody = Instance.new("Frame")
    pickerBody.Size = UDim2.new(1, -16, 0, 105)
    pickerBody.Position = UDim2.new(0, 8, 0, 8)
    pickerBody.BackgroundTransparency = 1
    pickerBody.Parent = expandedHolder

    local svPicker = Instance.new("Frame")
    svPicker.Size = UDim2.new(1, -28, 0, 105)
    svPicker.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
    svPicker.BorderSizePixel = 0
    svPicker.Parent = pickerBody

    local svCorner = Instance.new("UICorner")
    svCorner.CornerRadius = UDim.new(0, 5)
    svCorner.Parent = svPicker

    local satOverlay = Instance.new("Frame")
    satOverlay.Size = UDim2.new(1, 0, 1, 0)
    satOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    satOverlay.BorderSizePixel = 0
    satOverlay.Parent = svPicker

    local satGradient = Instance.new("UIGradient")
    satGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
    })
    satGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    satOverlay.BorderSizePixel = 0
    satGradient.Parent = satOverlay

    local valOverlay = Instance.new("Frame")
    valOverlay.Size = UDim2.new(1, 0, 1, 0)
    valOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    valOverlay.BorderSizePixel = 0
    valOverlay.Parent = svPicker

    local valGradient = Instance.new("UIGradient")
    valGradient.Rotation = 90
    valGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
    })
    valGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })
    valGradient.Parent = valOverlay

    local svCursor = Instance.new("Frame")
    svCursor.Size = UDim2.new(0, 8, 0, 8)
    svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    svCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    svCursor.BorderSizePixel = 0
    svCursor.Parent = svPicker

    local svCursorCorner = Instance.new("UICorner")
    svCursorCorner.CornerRadius = UDim.new(1, 0)
    svCursorCorner.Parent = svCursor

    local svCursorStroke = Instance.new("UIStroke")
    svCursorStroke.Color = Color3.fromRGB(0, 0, 0)
    svCursorStroke.Thickness = 1
    svCursorStroke.Parent = svCursor

    local hueBar = Instance.new("Frame")
    hueBar.Size = UDim2.new(0, 16, 0, 105)
    hueBar.Position = UDim2.new(1, -16, 0, 0)
    hueBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    hueBar.BorderSizePixel = 0
    hueBar.Parent = pickerBody

    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 5)
    hueCorner.Parent = hueBar

    local hueGradient = Instance.new("UIGradient")
    hueGradient.Rotation = 90
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
    })
    hueGradient.Parent = hueBar

    local hueCursor = Instance.new("Frame")
    hueCursor.Size = UDim2.new(1, 0, 0, 2)
    hueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueCursor.BorderSizePixel = 0
    hueCursor.Parent = hueBar

    local hueCursorStroke = Instance.new("UIStroke")
    hueCursorStroke.Color = Color3.fromRGB(0, 0, 0)
    hueCursorStroke.Thickness = 1
    hueCursorStroke.Parent = hueCursor

    local svDragging = false
    local hueDragging = false

    local function updateVisualsFromHSV()
        svPicker.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
        svCursor.Position = UDim2.new(currentS, 0, 1 - currentV, 0)
        hueCursor.Position = UDim2.new(0, 0, currentH, -1)
    end

    local function applyFromHSV()
        applyColor(Color3.fromHSV(currentH, currentS, currentV))
        updateVisualsFromHSV()
    end

    local function updateSV(input)
        local relX = input.Position.X - svPicker.AbsolutePosition.X
        local relY = input.Position.Y - svPicker.AbsolutePosition.Y
        currentS = math.clamp(relX / svPicker.AbsoluteSize.X, 0, 1)
        currentV = 1 - math.clamp(relY / svPicker.AbsoluteSize.Y, 0, 1)
        applyFromHSV()
    end

    local function updateHue(input)
        local relY = input.Position.Y - hueBar.AbsolutePosition.Y
        currentH = math.clamp(relY / hueBar.AbsoluteSize.Y, 0, 1)
        applyFromHSV()
    end

    svPicker.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = true
            if mainFrame then
                mainFrame.Active = false
                mainFrame.Draggable = false
            end
            updateSV(input)
        end
    end)

    svPicker.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = false
            if not hueDragging and mainFrame then
                mainFrame.Active = true
                mainFrame.Draggable = true
            end
        end
    end)

    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
            if mainFrame then
                mainFrame.Active = false
                mainFrame.Draggable = false
            end
            updateHue(input)
        end
    end)

    hueBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
            if not svDragging and mainFrame then
                mainFrame.Active = true
                mainFrame.Draggable = true
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if svDragging then
                updateSV(input)
            elseif hueDragging then
                updateHue(input)
            end
        end
    end)

    local function setExpanded(state: boolean)
        isExpanded = state
        expandedHolder.Visible = state
        frame.Size = state and UDim2.new(0, 260, 0, 182) or UDim2.new(0, 260, 0, 30)
    end

    mainButton.MouseButton1Click:Connect(function()
        setExpanded(not isExpanded)
    end)

    applyFromHSV()

    return frame
end

function Neo:CreateDropdown(options: {string}, defaultOption: string, callback: (string) -> ())
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 30)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 10
    frame.Parent = self.Page

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(1, 0, 1, 0)
    box.BackgroundColor3 = colors.Button
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Text = defaultOption or options[1] or ""
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.BorderSizePixel = 0
    box.AutoButtonColor = false
    box.ZIndex = 11
    box.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = box

    local list = Instance.new("Frame")
    list.Size = UDim2.new(1, 0, 0, 0)
    list.Position = UDim2.new(0, 0, 0, 30)
    list.BackgroundColor3 = colors.Sidebar
    list.BorderSizePixel = 0
    list.ClipsDescendants = true
    list.Visible = false
    list.ZIndex = 20
    list.Parent = frame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = list

    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 0)
    listPadding.PaddingBottom = UDim.new(0, 4)
    listPadding.PaddingLeft = UDim.new(0, 4)
    listPadding.PaddingRight = UDim.new(0, 4)
    listPadding.Parent = list

    local expanded = false

    local function setExpanded(state: boolean)
        expanded = state
        list.Visible = state

        if state then
            local contentHeight = listLayout.AbsoluteContentSize.Y
            local padTop = listPadding.PaddingTop.Offset
            local padBottom = listPadding.PaddingBottom.Offset
            local listHeight = contentHeight + padTop + padBottom
            list.Size = UDim2.new(1, 0, 0, listHeight)
            frame.Size = UDim2.new(0, 260, 0, 30 + listHeight)
        else
            list.Size = UDim2.new(1, 0, 0, 0)
            frame.Size = UDim2.new(0, 260, 0, 30)
        end
    end

    for i, option in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 25)
        optBtn.BackgroundColor3 = colors.Sidebar
        optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        optBtn.Text = option
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 14
        optBtn.BorderSizePixel = 0
        optBtn.AutoButtonColor = false
        optBtn.ZIndex = 21
        optBtn.Parent = list

        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 6)
        optCorner.Parent = optBtn

        optBtn.MouseButton1Click:Connect(function()
            box.Text = option
            setExpanded(false)
            if callback then callback(option) end
        end)

        optBtn.MouseEnter:Connect(function()
            optBtn.BackgroundColor3 = colors.Accent
        end)
        optBtn.MouseLeave:Connect(function()
            optBtn.BackgroundColor3 = colors.Sidebar
        end)
    end

    box.MouseButton1Click:Connect(function()
        setExpanded(not expanded)
    end)

    return frame
end

return Neo
