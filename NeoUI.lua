-- NeoLib.lua
-- Simple UI Library for Roblox

local UserInputService = game:GetService("UserInputService")

local Neo = {}
Neo.__index = Neo

local colors = {
    Background = Color3.fromRGB(24, 24, 28),
    Sidebar = Color3.fromRGB(18, 18, 22),
    Button = Color3.fromRGB(35, 35, 40),
    ButtonActive = Color3.fromRGB(0, 162, 255),
    Text = Color3.fromRGB(230, 230, 230),
    Section = Color3.fromRGB(40, 40, 48),
    Slider = Color3.fromRGB(0, 162, 255),
    Toggle = Color3.fromRGB(0, 162, 255)
}

----------------------------------------------------------------------
-- Helper: Highlight Active Tab
----------------------------------------------------------------------
local function highlightTab(sidebar, activeButton)
    for _, b in ipairs(sidebar:GetChildren()) do
        if b:IsA("TextButton") then
            b.BackgroundColor3 = colors.Button
        end
    end
    activeButton.BackgroundColor3 = colors.ButtonActive
end

----------------------------------------------------------------------
-- Create Main Window
----------------------------------------------------------------------
function Neo.new(title)
    local self = setmetatable({}, Neo)

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "NeoUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.Parent = game.CoreGui

    -- Draggable main frame
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 500, 0, 350)
    main.Position = UDim2.new(0.5, -250, 0.5, -175)
    main.BackgroundColor3 = colors.Background
    main.Active = true
    main.Draggable = true
    main.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = main

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 120, 1, 0)
    sidebar.BackgroundColor3 = colors.Sidebar
    sidebar.Parent = main

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Padding = UDim.new(0, 8)
    sidebarLayout.FillDirection = Enum.FillDirection.Vertical
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Parent = sidebar

    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 10)
    sidebarPadding.PaddingLeft = UDim.new(0, 10)
    sidebarPadding.PaddingRight = UDim.new(0, 10)
    sidebarPadding.Parent = sidebar

    -- Content
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Position = UDim2.new(0, 120, 0, 0)
    content.Size = UDim2.new(1, -120, 1, 0)
    content.BackgroundTransparency = 1
    content.Parent = main

    self.GUI = gui
    self.MainFrame = main
    self.Sidebar = sidebar
    self.Content = content
    self.Pages = {}
    self._hasDefaultTab = false

    -- Default keybinds
    self.ToggleBind = Enum.KeyCode.Insert
    self.UnloadBind = Enum.KeyCode.Delete

    -- Toggle visibility
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == self.ToggleBind then
            self.MainFrame.Visible = not self.MainFrame.Visible
        elseif input.KeyCode == self.UnloadBind then
            self.GUI:Destroy()
        end
    end)

    -- Add settings tab at bottom
    self:_createSettingsTab()

    return self
end

----------------------------------------------------------------------
-- Tabs
----------------------------------------------------------------------
function Neo:CreateTab(name: string, isSettings: boolean?)
    local tab = {}
    setmetatable(tab, Neo)

    -- Sidebar button
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Tab"
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = colors.Button
    btn.TextColor3 = colors.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Text = name
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = self.Sidebar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    -- Page (scrollable, scrollbar hidden)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.None
    page.ScrollBarThickness = 0 -- hide scrollbar
    page.Parent = self.Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.Parent = page

    -- ✅ Dynamic canvas resize with 4px gap
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 4)
    end)

    self.Pages[name] = page
    tab.Page = page
    tab._mainFrame = self.MainFrame

    local function selectThis()
        for _, p in pairs(self.Pages) do p.Visible = false end
        page.Visible = true
        highlightTab(self.Sidebar, btn)
    end

    btn.MouseButton1Click:Connect(selectThis)

    if not self._hasDefaultTab and not isSettings then
        self._hasDefaultTab = true
        selectThis()
    end

    if isSettings then
        btn.LayoutOrder = 9999 -- always bottom
    end

    return tab
end

----------------------------------------------------------------------
-- Components
----------------------------------------------------------------------
function Neo:CreateSection(tab, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = colors.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 18
    lbl.Parent = tab.Page
    return lbl
end

function Neo:CreateButton(tab, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.BackgroundColor3 = colors.Button
    btn.TextColor3 = colors.Text
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Parent = tab.Page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

function Neo:CreateToggle(tab, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Page

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = colors.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 16
    lbl.Parent = frame

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 25, 0, 25)
    box.Position = UDim2.new(1, -30, 0.5, -12)
    box.BackgroundColor3 = default and colors.Toggle or colors.Button
    box.Text = ""
    box.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = box

    local state = default
    box.MouseButton1Click:Connect(function()
        state = not state
        box.BackgroundColor3 = state and colors.Toggle or colors.Button
        if callback then callback(state) end
    end)
end

function Neo:CreateSlider(tab, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Page

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = colors.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 16
    lbl.Parent = frame

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0, 50, 0, 20)
    val.Position = UDim2.new(1, -50, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = tostring(default)
    val.TextColor3 = colors.Text
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Font = Enum.Font.Gotham
    val.TextSize = 14
    val.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 1, -10)
    bar.BackgroundColor3 = colors.Button
    bar.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = colors.Slider
    fill.Parent = bar

    local dragging = false
    local function update(input)
        local size = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(size, 0, 1, 0)
        local v = math.floor(min + (max - min) * size)
        val.Text = tostring(v)
        if callback then callback(v) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
end

function Neo:CreateKeybind(tab, text, defaultKey, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Page

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -100, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = colors.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 16
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 25)
    btn.Position = UDim2.new(1, -85, 0.5, -12)
    btn.BackgroundColor3 = colors.Button
    btn.TextColor3 = colors.Text
    btn.Text = defaultKey.Name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    local current = defaultKey
    local waiting = false

    btn.MouseButton1Click:Connect(function()
        if waiting then return end
        waiting = true
        btn.Text = "Press a key..."
        local conn
        conn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                current = input.KeyCode
                btn.Text = current.Name
                waiting = false
                conn:Disconnect()
                if callback then callback(current) end
            end
        end)
    end)
end

----------------------------------------------------------------------
-- Settings Tab
----------------------------------------------------------------------
function Neo:_createSettingsTab()
    local settings = self:CreateTab("Settings", true)

    self:CreateSection(settings, "Menu Controls")

    self:CreateKeybind(settings, "Toggle Menu", self.ToggleBind, function(newKey)
        self.ToggleBind = newKey
    end)

    self:CreateKeybind(settings, "Unload Menu", self.UnloadBind, function(newKey)
        self.UnloadBind = newKey
    end)
end

return Neo
