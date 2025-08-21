local NeoUI = {}
NeoUI.__index = NeoUI

function NeoUI.new()
    local self = setmetatable({}, NeoUI)

    self.Players = game:GetService("Players")
    self.UserInputService = game:GetService("UserInputService")
    self.LocalPlayer = self.Players.LocalPlayer
    self.PlayerGui = self.LocalPlayer:WaitForChild("PlayerGui")
    
    self.toggleKey = Enum.KeyCode.Insert
    self.unloadKey = Enum.KeyCode.Delete

    self.colors = {
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

    self.isBindingKey = false
    self.suppressKeyCode = nil

    -- Creating the UI structure
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "NeoModMenu"
    self.screenGui.Parent = self.PlayerGui
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Size = UDim2.new(0, 440, 0, 400)
    self.mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Active = true
    self.mainFrame.Draggable = true
    self.mainFrame.Visible = true
    self.mainFrame.Parent = self.screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = self.mainFrame

    -- Topbar
    self.topBar = Instance.new("Frame")
    self.topBar.Size = UDim2.new(1, 0, 0, 40)
    self.topBar.BackgroundColor3 = self.colors.Topbar
    self.topBar.BorderSizePixel = 0
    self.topBar.Parent = self.mainFrame

    -- Title Label (changed to "NeoUI")
    self.titleLabel = Instance.new("TextLabel")
    self.titleLabel.Size = UDim2.new(1, -10, 1, 0)
    self.titleLabel.Position = UDim2.new(0, 10, 0, 0)
    self.titleLabel.BackgroundTransparency = 1
    self.titleLabel.Text = "NeoUI" -- Changed to NeoUI
    self.titleLabel.Font = Enum.Font.GothamBold
    self.titleLabel.TextSize = 20
    self.titleLabel.TextColor3 = self.colors.TitleText
    self.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.titleLabel.Parent = self.topBar

    -- Sidebar
    self.sidebar = Instance.new("Frame")
    self.sidebar.Size = UDim2.new(0, 150, 1, -40)
    self.sidebar.Position = UDim2.new(0, 0, 0, 40)
    self.sidebar.BackgroundColor3 = self.colors.Sidebar
    self.sidebar.BorderSizePixel = 0
    self.sidebar.Parent = self.mainFrame

    -- Create sidebar layout
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.FillDirection = Enum.FillDirection.Vertical
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 6)
    sidebarLayout.Parent = self.sidebar

    -- Create tabs
    self.demoTab = self:createTabButton("Demo")
    self.settingsTab = self:createTabButton("Settings")

    -- Content frame
    self.contentFrame = Instance.new("Frame")
    self.contentFrame.Size = UDim2.new(1, -150, 1, -40)
    self.contentFrame.Position = UDim2.new(0, 150, 0, 40)
    self.contentFrame.BackgroundColor3 = self.colors.Content
    self.contentFrame.BorderSizePixel = 0
    self.contentFrame.Parent = self.mainFrame

    self.pages = {}

    -- Create pages
    self.demoPage = self:createPage("Demo")
    self.settingsPage = self:createPage("Settings")

    -- Setup default page and highlight (Settings tab is always visible)
    self:switchPage("Settings")
    self:highlightTab(self.settingsTab)

    -- Create settings page keybinds
    self:createKeybindButton("Toggle Menu", self.toggleKey, self.settingsPage)
    self:createKeybindButton("Unload Menu", self.unloadKey, self.settingsPage)

    return self
end

function NeoUI:createTabButton(name)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Tab"
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = self.colors.ButtonIdle
    btn.TextColor3 = self.colors.ButtonText
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Text = name
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = self.sidebar
    return btn
end

function NeoUI:createPage(name)
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

function NeoUI:createKeybindButton(text, key, parent)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0, 260, 0, 30)
    row.BackgroundTransparency = 1

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = self.colors.ButtonIdle
    btn.Text = text .. ": " .. key.Name
    btn.TextColor3 = self.colors.ButtonText
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = row

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        btn.Text = text .. ": Press a key..."
        self.isBindingKey = true
        self.suppressKeyCode = nil

        local beganConn, endedConn
        beganConn = self.UserInputService.InputBegan:Connect(function(input, gpe)
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                key = input.KeyCode
                btn.Text = text .. ": " .. key.Name
                self.suppressKeyCode = input.KeyCode
                if endedConn then endedConn:Disconnect() end
                endedConn = self.UserInputService.InputEnded:Connect(function(endInput, _)
                    if endInput.UserInputType == Enum.UserInputType.Keyboard and endInput.KeyCode == self.suppressKeyCode then
                        self.isBindingKey = false
                        self.suppressKeyCode = nil
                        if beganConn then beganConn:Disconnect() end
                        if endedConn then endedConn:Disconnect() end
                    end
                end)
            end
        end)
    end)

    row.Parent = parent
end

function NeoUI:switchPage(pageName)
    for _, page in pairs(self.pages) do
        page.Visible = false
    end
    self.pages[pageName].Visible = true
end

function NeoUI
