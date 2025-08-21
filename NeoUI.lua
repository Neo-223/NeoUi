-- NeoUI Library
-- Cleaned & Patched Version

local Neo = {}
Neo.__index = Neo

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Theme Colors
local colors = {
    Background = Color3.fromRGB(20, 20, 25),
    Sidebar = Color3.fromRGB(30, 30, 35),
    Topbar = Color3.fromRGB(25, 25, 30),
    Button = Color3.fromRGB(40, 40, 45),
    Accent = Color3.fromRGB(0, 170, 255),
    Text = Color3.fromRGB(230, 230, 230)
}

-- Create Window
function Neo:CreateWindow(title: string)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NeoUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainFrame.BackgroundColor3 = colors.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 35)
    topbar.BackgroundColor3 = colors.Topbar
    topbar.BorderSizePixel = 0
    topbar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = colors.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topbar

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 120, 1, -35)
    sidebar.Position = UDim2.new(0, 0, 0, 35)
    sidebar.BackgroundColor3 = colors.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame

    local contentHolder = Instance.new("ScrollingFrame")
    contentHolder.Size = UDim2.new(1, -120, 1, -35)
    contentHolder.Position = UDim2.new(0, 120, 0, 35)
    contentHolder.BackgroundTransparency = 1
    contentHolder.BorderSizePixel = 0
    contentHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentHolder.ScrollBarThickness = 6
    contentHolder.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 85)
    contentHolder.Parent = mainFrame

    local chPadding = Instance.new("UIPadding")
    chPadding.PaddingTop = UDim.new(0, 20) -- Global top spacing
    chPadding.PaddingLeft = UDim.new(0, 0)
    chPadding.PaddingBottom = UDim.new(0, 4)
    chPadding.Parent = contentHolder

    local pages = {}
    local buttons = {}

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 5)
    sidebarLayout.Parent = sidebar

    self.MainFrame = mainFrame
    self.Sidebar = sidebar
    self.Content = contentHolder
    self.Pages = pages
    self.Buttons = buttons

    self:_createSettingsTab()

    return self
end

-- Create Tab
function Neo:CreateTab(name: string)
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.Parent = self.Content

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 0)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = page

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = page

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 30)
    button.BackgroundColor3 = colors.Button
    button.Text = name
    button.TextColor3 = colors.Text
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = self.Sidebar

    button.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Pages) do
            p.Visible = false
        end
        for _, b in pairs(self.Buttons) do
            b.BackgroundColor3 = colors.Button
            b.TextColor3 = colors.Text
        end
        page.Visible = true
        button.BackgroundColor3 = colors.Accent
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    self.Pages[name] = page
    self.Buttons[name] = button

    return page
end

-- Settings Tab
function Neo:_createSettingsTab()
    local page = self:CreateTab("Settings")
    page.Visible = false

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(1, -10, 0, 25)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = "Toggle Menu: Insert"
    toggleLabel.TextColor3 = colors.Text
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextSize = 14
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = page

    local unloadLabel = Instance.new("TextLabel")
    unloadLabel.Size = UDim2.new(1, -10, 0, 25)
    unloadLabel.BackgroundTransparency = 1
    unloadLabel.Text = "Unload Menu: Delete"
    unloadLabel.TextColor3 = colors.Text
    unloadLabel.Font = Enum.Font.Gotham
    unloadLabel.TextSize = 14
    unloadLabel.TextXAlignment = Enum.TextXAlignment.Left
    unloadLabel.Parent = page
end

-- Slider Component
function Neo:CreateSlider(tab, name: string, min: number, max: number, default: number, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = tab

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 10)
    bar.Position = UDim2.new(0, 0, 0, 25)
    bar.BackgroundColor3 = colors.Button
    bar.BorderSizePixel = 0
    bar.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = colors.Accent
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 4)
    uicorner.Parent = bar

    local uicornerFill = Instance.new("UICorner")
    uicornerFill.CornerRadius = UDim.new(0, 4)
    uicornerFill.Parent = fill

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 0, 20)
    sliderLabel.Position = UDim2.new(0, 0, 0, -20)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = name .. ": " .. tostring(default)
    sliderLabel.TextColor3 = colors.Text
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.TextSize = 14
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = frame

    local function setSliderValue(alpha: number)
        alpha = math.clamp(alpha, 0, 1)
        local value = math.floor(min + (max - min) * alpha)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        sliderLabel.Text = name .. ": " .. tostring(value)
        if callback then
            callback(value)
        end
    end

    local UserInputService = game:GetService("UserInputService")
    local dragging = false

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local px = UserInputService:GetMouseLocation().X
            local relX = (px - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
            setSliderValue(relX)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local px = UserInputService:GetMouseLocation().X
            local relX = (px - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
            setSliderValue(relX)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local alphaDefault = (default - min) / (max - min)
    setSliderValue(alphaDefault)

    return frame
end

return Neo
