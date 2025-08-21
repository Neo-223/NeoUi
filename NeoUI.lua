local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Neo = {}
Neo.__index = Neo

-- Color palette
local colors = {
    Background = Color3.fromRGB(18, 18, 22),   -- main background
    Sidebar    = Color3.fromRGB(28, 28, 34),   -- sidebar
    Content    = Color3.fromRGB(24, 24, 30),   -- content area
    Button     = Color3.fromRGB(45, 45, 55),   -- buttons
    Topbar     = Color3.fromRGB(30, 30, 38),   -- top bar
    Accent     = Color3.fromRGB(0, 170, 255),  -- bright cyan/blue
    Success    = Color3.fromRGB(0, 200, 120),  -- green toggle on
}

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------
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

----------------------------------------------------------------------
-- Window
----------------------------------------------------------------------
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
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui
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
    chPadding.PaddingTop = UDim.new(0, 0)      
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

----------------------------------------------------------------------
-- Tabs
----------------------------------------------------------------------
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
padding.PaddingTop = UDim.new(0, 400) -- was 25, bump up to 40
padding.PaddingLeft = UDim.new(0, 15)
padding.PaddingBottom = UDim.new(0, 10) -- optional, keeps spacing clean
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
    padding.PaddingTop = UDim.new(0, 25)
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

----------------------------------------------------------------------
-- Components
----------------------------------------------------------------------
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

function Neo:CreateSlider(text: string, min: number, max: number, defaultValue: number, callback: (number)->())
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
    valLbl.Size = UDim2.new(0, 50, 0, 20)
    valLbl.Position = UDim2.new(1, -50, 0, 0)
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
    local startAlpha = (defaultValue - min) / math.max(1, (max - min))
    fill.Size = UDim2.new(math.clamp(startAlpha, 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = colors.Accent
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local dragging = false
    local function setFromAlpha(alpha: number)
        alpha = math.clamp(alpha, 0, 1)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        local value = math.floor(min + (max - min) * alpha + 0.5)
        valLbl.Text = tostring(value)
        if callback then callback(value) end
    end

    local function updateFromMouse(px: number)
        local relX = (px - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
        setFromAlpha(relX)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            if self._mainFrame then self._mainFrame.Active = false end
            updateFromMouse(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromMouse(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            if self._mainFrame then self._mainFrame.Active = true end
        end
    end)

    return frame
end

return Neo
