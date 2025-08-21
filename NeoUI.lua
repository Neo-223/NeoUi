-- Neo GUI Library (with Settings tab + Keybind release fix)
-- Load with: local Neo = loadstring(game:HttpGet("https://raw.githubusercontent.com/you/repo/main/NeoLib.lua"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

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

-- Utilities
local function highlightTab(sidebar: Frame, selectedBtn: TextButton)
    for _, child in ipairs(sidebar:GetChildren()) do
        if child:IsA("TextButton") then
            child.BackgroundColor3 = colors.Button
        end
    end
    selectedBtn.BackgroundColor3 = colors.Accent
end

----------------------------------------------------------------------
-- Window
----------------------------------------------------------------------
function Neo:CreateWindow(title: string)
    local window = {}
    setmetatable(window, Neo)

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NeoModMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui
    window.Gui = screenGui

    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 440, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
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

    -- Topbar
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = colors.Topbar
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 20
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 150, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = colors.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    window.Sidebar = sidebar

    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 8)
    sidebarPadding.PaddingLeft = UDim.new(0, 10)
    sidebarPadding.PaddingRight = UDim.new(0, 10)
    sidebarPadding.Parent = sidebar

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.FillDirection = Enum.FillDirection.Vertical
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 6)
    sidebarLayout.Parent = sidebar

    -- Content
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -150, 1, -40)
    contentFrame.Position = UDim2.new(0, 150, 0, 40)
    contentFrame.BackgroundColor3 = colors.Content
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame
    window.Content = contentFrame

    window.Pages = {}
    window._hasDefaultTab = false

    function window:Toggle()
        self.MainFrame.Visible = not self.MainFrame.Visible
    end
    function window:Destroy()
        if self.Gui then self.Gui:Destroy() end
    end

    -- Create Settings Tab at bottom automatically
    local function createSettingsTab()
        local tab = window:CreateTab("Settings", true) -- mark as settings

        tab:CreateKeybind("Toggle Menu", Enum.KeyCode.Insert, function()
            window:Toggle()
        end)

        tab:CreateKeybind("Unload Menu", Enum.KeyCode.Delete, function()
            window:Destroy()
        end)
    end
    window._createSettings = createSettingsTab

    return window
end

----------------------------------------------------------------------
-- Tabs
----------------------------------------------------------------------
function Neo:CreateTab(name: string, isSettings: boolean)
    local tab = {}
    setmetatable(tab, Neo)

    -- Sidebar button
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
    btn.Parent = self.Sidebar

    if isSettings then
        btn.LayoutOrder = 9999 -- force bottom
    end

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    -- Page
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
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
    padding.PaddingTop = UDim.new(0, 15)
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

    if not self._hasDefaultTab and not isSettings then
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

-- Rebind Component (waits for key release)
function Neo:CreateKeybind(text: string, defaultKey: Enum.KeyCode, callback: ()->())
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 265, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = self.Page

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 16
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.4, -5, 1, 0)
    btn.Position = UDim2.new(0.6, 5, 0, 0)
    btn.BackgroundColor3 = colors.Button
    btn.Text = "["..defaultKey.Name.."]"
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local currentKey = defaultKey
    local waiting = false

    local function bindInput(input)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
            callback()
        end
    end

    UserInputService.InputBegan:Connect(bindInput)

    btn.MouseButton1Click:Connect(function()
        if waiting then return end
        waiting = true
        btn.Text = "Press a key..."

        local releaseConn
        releaseConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                btn.Text = "["..currentKey.Name.."]"
                waiting = false
                releaseConn:Disconnect()
            end
        end)
    end)

    return frame
end

return Neo
