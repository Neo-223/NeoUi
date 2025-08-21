-- NeoUI Library (NeoUI.lua)
-- This will be saved as a module script or pasted directly into a loadstring.

local NeoUI = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

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

NeoUI.new = function()
    local self = {}

    -- Create screenGui
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "NeoModMenu"
    self.screenGui.Parent = PlayerGui
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Create main frame
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

    -- Create top bar
    self.topBar = Instance.new("Frame")
    self.topBar.Size = UDim2.new(1, 0, 0, 40)
    self.topBar.BackgroundColor3 = colors.Topbar
    self.topBar.BorderSizePixel = 0
    self.topBar.Parent = self.mainFrame

    -- Title in top bar
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

    -- Create sidebar
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

    -- Create content area
    self.contentFrame = Instance.new("Frame")
    self.contentFrame.Size = UDim2.new(1, -150, 1, -40)
    self.contentFrame.Position = UDim2.new(0, 150, 0, 40)
    self.contentFrame.BackgroundColor3 = colors.Content
    self.contentFrame.BorderSizePixel = 0
    self.contentFrame.Parent = self.mainFrame

    -- Tab and page management
    self.pages = {}
    self.createTabButton = function(name)
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

    self.createPage = function(name)
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

    -- Show page
    self.switchPage = function(name)
        for _, page in pairs(self.pages) do
            page.Visible = false
        end
        if self.pages[name] then
            self.pages[name].Visible = true
        end
    end

    -- Bind a key to toggle the menu visibility
    self.toggleKey = Enum.KeyCode.Insert
    self.unloadKey = Enum.KeyCode.Delete

    self.inputConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == self.toggleKey then
                self.mainFrame.Visible = not self.mainFrame.Visible
            elseif input.KeyCode == self.unloadKey then
                self.screenGui:Destroy()
            end
        end
    end)

    return self
end

return NeoUI
