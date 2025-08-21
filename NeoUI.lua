-- NeoModUI.lua

local NeoModUI = {}
NeoModUI.__index = NeoModUI

-- Color palette
local colors = {
    Sidebar           = Color3.fromRGB(28, 28, 34),
    Content           = Color3.fromRGB(24, 24, 30),
    Topbar            = Color3.fromRGB(30, 30, 38),
    ButtonIdle        = Color3.fromRGB(45, 45, 55),
    ButtonText        = Color3.fromRGB(255, 255, 255),
    ButtonHighlight   = Color3.fromRGB(0, 170, 255),
    TitleText         = Color3.fromRGB(255, 255, 255),
    SectionHeaderText = Color3.fromRGB(255, 255, 255),
    LabelText         = Color3.fromRGB(255, 255, 255),
    ValueText         = Color3.fromRGB(150, 200, 255),
    ToggleOff         = Color3.fromRGB(45, 45, 55),
    ToggleOn          = Color3.fromRGB(0, 200, 120),
    SliderBar         = Color3.fromRGB(45, 45, 55),
    SliderFill        = Color3.fromRGB(0, 170, 255),
    Accent            = Color3.fromRGB(0, 170, 255),
}

-- NeoModUI constructor
function NeoModUI.new(playerGui)
    local self = setmetatable({}, NeoModUI)

    self.playerGui = playerGui
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "NeoModMenu"
    self.screenGui.Parent = playerGui
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Size = UDim2.new(0, 440, 0, 400)
    self.mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Active = true
    self.mainFrame.Draggable = true
    self.mainFrame.Parent = self.screenGui

    self.mainCorner = Instance.new("UICorner")
    self.mainCorner.CornerRadius = UDim.new(0, 10)
    self.mainCorner.Parent = self.mainFrame

    self.topBar = Instance.new("Frame")
    self.topBar.Size = UDim2.new(1, 0, 0, 40)
    self.topBar.BackgroundColor3 = colors.Topbar
    self.topBar.BorderSizePixel = 0
    self.topBar.Parent = self.mainFrame

    self.titleLabel = Instance.new("TextLabel")
    self.titleLabel.Size = UDim2.new(1, -10, 1, 0)
    self.titleLabel.Position = UDim2.new(0, 10, 0, 0)
    self.titleLabel.BackgroundTransparency = 1
    self.titleLabel.Text = "Neo"
    self.titleLabel.Font = Enum.Font.GothamBold
    self.titleLabel.TextSize = 20
    self.titleLabel.TextColor3 = colors.TitleText
    self.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.titleLabel.Parent = self.topBar

    self.sidebar = Instance.new("Frame")
    self.sidebar.Size = UDim2.new(0, 150, 1, -40)
    self.sidebar.Position = UDim2.new(0, 0, 0, 40)
    self.sidebar.BackgroundColor3 = colors.Sidebar
    self.sidebar.BorderSizePixel = 0
    self.sidebar.Parent = self.mainFrame

    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 8)
    sidebarPadding.PaddingLeft = UDim.new(0, 10)
    sidebarPadding.PaddingRight = UDim.new(0, 10)
    sidebarPadding.Parent = self.sidebar

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.FillDirection = Enum.FillDirection.Vertical
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 6)
    sidebarLayout.Parent = self.sidebar

    self.contentFrame = Instance.new("Frame")
    self.contentFrame.Size = UDim2.new(1, -150, 1, -40)
    self.contentFrame.Position = UDim2.new(0, 150, 0, 40)
    self.contentFrame.BackgroundColor3 = colors.Content
    self.contentFrame.BorderSizePixel = 0
    self.contentFrame.Parent = self.mainFrame

    self.pages = {}

    return self
end

-- Create Tab Button
function NeoModUI:createTabButton(name)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Tab"
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = colors.ButtonIdle
    btn.TextColor3 = colors.ButtonText
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Text = name
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.Parent = self.sidebar
    return btn
end

-- Create Page
function NeoModUI:createPage(name)
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = self.contentFrame

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

    self.pages[name] = page
    return page
end

-- Create Label
function NeoModUI:createLabel(text, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 18
    lbl.TextColor3 = colors.SectionHeaderText
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

-- Create Button
function NeoModUI:createButton(text, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 260, 0, 30)
    btn.BackgroundColor3 = colors.ButtonIdle
    btn.Text = text
    btn.TextColor3 = colors.ButtonText
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Create Toggle
function NeoModUI:createToggle(text, parent, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 265, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 16
    lbl.TextColor3 = colors.LabelText
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 30, 0, 30)
    box.Position = UDim2.new(1, -35, 0, 0)
    box.BackgroundColor3 = colors.ToggleOff
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
        box.BackgroundColor3 = state and colors.ToggleOn or colors.ToggleOff
        callback(state)
    end)

    return frame
end

-- Create Slider
function NeoModUI:createSlider(text, min, max, defaultValue, parent, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = colors.LabelText
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 0, 20)
    valLbl.Position = UDim2.new(1, -50, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(defaultValue)
    valLbl.Font = Enum.Font.Gotham
    valLbl.TextSize = 14
    valLbl.TextColor3 = colors.ValueText
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 10)
    bar.Position = UDim2.new(0, 0, 0, 25)
    bar.BackgroundColor3 = colors.SliderBar
    bar.BorderSizePixel = 0
    bar.Parent = frame

    local fill = Instance.new("Frame")
    local startAlpha = (defaultValue - min) / (max - min)
    fill.Size = UDim2.new(startAlpha, 0, 1, 0)
    fill.BackgroundColor3 = colors.SliderFill
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local dragging = false
    local function updateFromMouse(px)
        local relX = math.clamp((px - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        local value = math.floor(min + (max - min) * relX + 0.5)
        valLbl.Text = tostring(value)
        callback(value)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
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
        end
    end)

    return frame
end

return NeoModUI
