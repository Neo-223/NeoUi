local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Neo = {}
Neo.__index = Neo

-- Updated Colors for Glassmorphism
local colors = {
    Background = Color3.fromRGB(25, 25, 35), -- Slightly lighter for glass effect
    Sidebar    = Color3.fromRGB(35, 35, 45),
    Content    = Color3.fromRGB(20, 20, 25),
    Button     = Color3.fromRGB(60, 60, 75),
    Topbar     = Color3.fromRGB(40, 40, 50),
    Accent     = Color3.fromRGB(0, 170, 255),
    Success    = Color3.fromRGB(0, 200, 120),
    GlassTrans = 0.25, -- Transparency for the glass effect
}

local function highlightTab(sidebar: Frame, selectedBtn: TextButton)
    for _, child in ipairs(sidebar:GetChildren()) do
        if child:IsA("TextButton") then
            child.BackgroundColor3 = colors.Button
            child.BackgroundTransparency = 0.5
        end
    end
    selectedBtn.BackgroundColor3 = colors.Accent
    selectedBtn.BackgroundTransparency = 0
end

-- ... [Keep createRebindRow unchanged] ...

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
    -- Note: CoreGui requires higher permissions; use PlayerGui for testing if needed
    screenGui.Parent = game:GetService("CoreGui") 
    window.Gui = screenGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 440, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -220, 0.5, -200)
    mainFrame.BackgroundColor3 = colors.Background
    mainFrame.BackgroundTransparency = colors.GlassTrans -- GLASS EFFECT
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Visible = true
    mainFrame.ClipsDescendants = true -- Ensures children don't pop out of rounded corners
    mainFrame.Parent = screenGui
    window.MainFrame = mainFrame

    -- OUTER ROUNDED EDGES
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15) -- Increased for aesthetic
    mainCorner.Parent = mainFrame

    -- BORDER STROKE (The "Glow/Edge" of the glass)
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Thickness = 1.5
    mainStroke.Color = Color3.fromRGB(255, 255, 255)
    mainStroke.Transparency = 0.8
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    mainStroke.Parent = mainFrame

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 45)
    topBar.BackgroundColor3 = colors.Topbar
    topBar.BackgroundTransparency = 0.4
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "NEO"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    local sidebar = Instance.new("ScrollingFrame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 150, 1, -45)
    sidebar.Position = UDim2.new(0, 0, 0, 45)
    sidebar.BackgroundColor3 = colors.Sidebar
    sidebar.BackgroundTransparency = 0.6 -- Glassy Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.ScrollBarThickness = 0
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebar.Parent = mainFrame
    window.Sidebar = sidebar

    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 10)
    sidebarPadding.PaddingLeft = UDim.new(0, 10)
    sidebarPadding.PaddingRight = UDim.new(0, 10)
    sidebarPadding.Parent = sidebar

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Padding = UDim.new(0, 8)
    sidebarLayout.Parent = sidebar

    local contentHolder = Instance.new("ScrollingFrame")
    contentHolder.Name = "ContentHolder"
    contentHolder.Size = UDim2.new(1, -150, 1, -45)
    contentHolder.Position = UDim2.new(0, 150, 0, 45)
    contentHolder.BackgroundColor3 = colors.Content
    contentHolder.BackgroundTransparency = 0.8 -- Even clearer content area
    contentHolder.BorderSizePixel = 0
    contentHolder.ScrollBarThickness = 0
    contentHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentHolder.Parent = mainFrame
    window.Content = contentHolder

    -- ... [Keep the rest of the window setup and page logic] ...
    
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
