local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Neo = {}
Neo.__index = Neo

-- Glassmorphic Palette
local colors = {
    Background = Color3.fromRGB(20, 20, 25),
    Sidebar    = Color3.fromRGB(30, 30, 40),
    Content    = Color3.fromRGB(15, 15, 20),
    Button     = Color3.fromRGB(50, 50, 65),
    Topbar     = Color3.fromRGB(35, 35, 45),
    Accent     = Color3.fromRGB(0, 170, 255),
    Success    = Color3.fromRGB(0, 200, 120),
    Text       = Color3.fromRGB(255, 255, 255),
    GlassTrans = 0.3,
}

local function highlightTab(sidebar: Frame, selectedBtn: TextButton)
    for _, child in ipairs(sidebar:GetChildren()) do
        if child:IsA("TextButton") then
            child.BackgroundColor3 = colors.Button
            child.BackgroundTransparency = 0.5
        end
    end
    selectedBtn.BackgroundColor3 = colors.Accent
    selectedBtn.BackgroundTransparency = 0.2
end

local function createRebindRow(parent: Instance, labelText: string, defaultKey: Enum.KeyCode, onSet: (Enum.KeyCode)->(), state)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0, 260, 0, 30)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = colors.Button
    btn.BackgroundTransparency = 0.4
    btn.Text = labelText .. ": " .. defaultKey.Name
    btn.TextColor3 = colors.Text
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
    mainFrame.BackgroundTransparency = colors.GlassTrans
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Visible = true
    mainFrame.ClipsDescendants = true 
    mainFrame.Parent = screenGui
    window.MainFrame = mainFrame

    -- OUTER ROUNDED EDGES (Requested)
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainFrame

    -- GLASS BORDER
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(255, 255, 255)
    mainStroke.Transparency = 0.85
    mainStroke.Thickness = 1.2
    mainStroke.Parent = mainFrame

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 45)
    topBar.BackgroundColor3 = colors.Topbar
    topBar.BackgroundTransparency = 0.4
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Neo"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextColor3 = colors.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    local sidebar = Instance.new("ScrollingFrame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 150, 1, -45)
    sidebar.Position = UDim2.new(0, 0, 0, 45)
    sidebar.BackgroundColor3 = colors.Sidebar
    sidebar.BackgroundTransparency = 0.6
    sidebar.BorderSizePixel = 0
    sidebar.ScrollBarThickness = 0
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebar.Parent = mainFrame
    window.Sidebar = sidebar

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Padding = UDim.new(0, 6)
    sidebarLayout.Parent = sidebar
    
    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 10)
    sidebarPadding.PaddingLeft = UDim.new(0, 10)
    sidebarPadding.PaddingRight = UDim.new(0, 10)
    sidebarPadding.Parent = sidebar

    local contentHolder = Instance.new("ScrollingFrame")
    contentHolder.Name = "ContentHolder"
    contentHolder.Size = UDim2.new(1, -150, 1, -45)
    contentHolder.Position = UDim2.new(0, 150, 0, 45)
    contentHolder.BackgroundColor3 = colors.Content
    contentHolder.BackgroundTransparency = 0.8
    contentHolder.BorderSizePixel = 0
    contentHolder.ScrollBarThickness = 0
    contentHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentHolder.Parent = mainFrame
    window.Content = contentHolder

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
        if gpe or window._state.isBindingKey then return end
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

    local tab = self:CreateTab("Settings")
    
    createRebindRow(tab.Page, "Toggle Menu", self._state.toggleKey, function(newKey)
        self._state.toggleKey = newKey
    end, self._state)

    createRebindRow(tab.Page, "Unload Menu", self._state.unloadKey, function(newKey)
        self._state.unloadKey = newKey
    end, self._state)
end

function Neo:CreateTab(name: string)
    if string.lower(name) == "settings" and self._settingsCreated and self.Pages["Settings"] then
        -- Return the existing settings tab object
        local tab = {Page = self.Pages["Settings"], _mainFrame = self.MainFrame}
        setmetatable(tab, Neo)
        return tab
    end

    local tab = {}
    setmetatable(tab, Neo)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = colors.Button
    btn.BackgroundTransparency = 0.5
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = name
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    self._tabOrder += 1
    btn.LayoutOrder = (name == "Settings") and 1000000 or self._tabOrder
    btn.Parent = self.Sidebar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = self.Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
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

    if not self._hasDefaultTab and name ~= "Settings" then
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
    lbl.TextColor3 = colors.Text
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
    btn.BackgroundTransparency = 0.4
    btn.Text = text
    btn.TextColor3 = colors.Text
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
    lbl.Size = UDim2.new(1, -45, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 16
    lbl.TextColor3 = colors.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 40, 0, 24)
    box.Position = UDim2.new(1, -40, 0.5, -12)
    box.BackgroundColor3 = colors.Button
    box.BackgroundTransparency = 0.4
    box.Text = ""
    box.AutoButtonColor = false
    box.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = box

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 18, 0, 18)
    dot.Position = UDim2.new(0, 3, 0.5, -9)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.Parent = box
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local state = false
    box.MouseButton1Click:Connect(function()
        state = not state
        dot:TweenPosition(state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9), "Out", "Quad", 0.15, true)
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
    lbl.TextColor3 = colors.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 60, 0, 20)
    valLbl.Position = UDim2.new(1, -60, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(defaultValue)
    valLbl.Font = Enum.Font.Gotham
    valLbl.TextSize = 14
    valLbl.TextColor3 = colors.Accent
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 25)
    bar.BackgroundColor3 = colors.Button
    bar.BackgroundTransparency = 0.5
    bar.Parent = frame
    Instance.new("UICorner", bar)

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = colors.Accent
    fill.Size = UDim2.new(math.clamp((defaultValue - min) / (max - min), 0, 1), 0, 1, 0)
    fill.Parent = bar
    Instance.new("UICorner", fill)

    local function update(input)
        local pct = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local rawValue = min + (max - min) * pct
        local value = math.clamp(math.floor(rawValue / step + 0.5) * step, min, max)
        
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        local decimals = tostring(step):find("%.") and #tostring(step):split(".")[2] or 0
        valLbl.Text = string.format("%." .. decimals .. "f", value)
        if callback then callback(value) end
    end

    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            if self._mainFrame then self._mainFrame.Draggable = false end
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            if self._mainFrame then self._mainFrame.Draggable = true end
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
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
    box.BackgroundTransparency = 0.4
    box.TextColor3 = colors.Text
    box.Text = defaultOption or options[1] or ""
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.AutoButtonColor = false
    box.Parent = frame
    Instance.new("UICorner", box)

    local list = Instance.new("Frame")
    list.Position = UDim2.new(0, 0, 0, 35)
    list.BackgroundColor3 = colors.Sidebar
    list.BackgroundTransparency = 0.2
    list.ClipsDescendants = true
    list.Visible = false
    list.ZIndex = 20
    list.Parent = frame
    Instance.new("UICorner", list)

    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = list
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 5)
    listPadding.PaddingBottom = UDim.new(0, 5)
    listPadding.PaddingLeft = UDim.new(0, 5)
    listPadding.PaddingRight = UDim.new(0, 5)
    listPadding.Parent = list

    local expanded = false
    box.MouseButton1Click:Connect(function()
        expanded = not expanded
        list.Visible = expanded
        local height = expanded and (listLayout.AbsoluteContentSize.Y + 10) or 0
        list.Size = UDim2.new(1, 0, 0, height)
    end)

    for _, option in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 25)
        optBtn.BackgroundTransparency = 1
        optBtn.TextColor3 = colors.Text
        optBtn.Text = option
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 13
        optBtn.Parent = list
        optBtn.MouseButton1Click:Connect(function()
            box.Text = option
            expanded = false
            list.Visible = false
            list.Size = UDim2.new(1, 0, 0, 0)
            if callback then callback(option) end
        end)
    end
    return frame
end

return Neo
