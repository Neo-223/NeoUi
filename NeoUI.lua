-- NeoUI.lua

local NeoUI = {}

-- Color palette (fully customizable)
NeoUI.colors = {
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

-- Create UI Function
function NeoUI.createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NeoModMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    return screenGui
end

-- Create Main Frame
function NeoUI.createMainFrame(parent)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 440, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Visible = true
    mainFrame.Parent = parent
    return mainFrame
end

-- Create a Top Bar
function NeoUI.createTopBar(parent, title)
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = NeoUI.colors.Topbar
    topBar.BorderSizePixel = 0
    topBar.Parent = parent
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 20
    titleLabel.TextColor3 = NeoUI.colors.TitleText
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
end

-- Create Sidebar
function NeoUI.createSidebar(parent)
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 150, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = NeoUI.colors.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = parent
    
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
    return sidebar
end

-- Create Button
function NeoUI.createButton(text, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 260, 0, 30)
    btn.BackgroundColor3 = NeoUI.colors.ButtonIdle
    btn.Text = text
    btn.TextColor3 = NeoUI.colors.ButtonText
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Create Toggle
function NeoUI.createToggle(text, parent, callback)
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
    lbl.TextColor3 = NeoUI.colors.LabelText
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 30, 0, 30)
    box.Position = UDim2.new(1, -35, 0, 0)
    box.BackgroundColor3 = NeoUI.colors.ToggleOff
    box.Text = ""
    box.BorderSizePixel = 0
    box.AutoButtonColor = false
    box.Parent = frame
    
    local state = false
    box.MouseButton1Click:Connect(function()
        state = not state
        box.BackgroundColor3 = state and NeoUI.colors.ToggleOn or NeoUI.colors.ToggleOff
        callback(state)
    end)
end

-- Add More UI Elements Here...

return NeoUI
