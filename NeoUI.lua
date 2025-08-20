local Neo = {}
Neo.__index = Neo

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")


local colors = {
    Background = Color3.fromRGB(24, 24, 28),
    Sidebar    = Color3.fromRGB(35, 35, 40),
    Content    = Color3.fromRGB(30, 30, 35),
    Button     = Color3.fromRGB(50, 50, 60),
    Topbar     = Color3.fromRGB(40, 40, 50),
}


local function newCorner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
end


function Neo:CreateWindow(title: string)
    local self = setmetatable({}, Neo)

    self._screenGui = Instance.new("ScreenGui")
    self._screenGui.Name = "NeoUI"
    self._screenGui.Parent = PlayerGui
    self._screenGui.ResetOnSpawn = false
    self._screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 440, 0, 400)
    self.MainFrame.Position = UDim2.new(0.5, -220, 0.5, -200)
    self.MainFrame.BackgroundColor3 = colors.Background
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true
    self.MainFrame.Parent = self._screenGui
    newCorner(10, self.MainFrame)


    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = colors.Topbar
    topBar.Parent = self.MainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 20
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar


    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Size = UDim2.new(0, 150, 1, -40)
    self.Sidebar.Position = UDim2.new(0, 0, 0, 40)
    self.Sidebar.BackgroundColor3 = colors.Sidebar
    self.Sidebar.Parent = self.MainFrame

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 6)
    sidebarLayout.Parent = self.Sidebar

    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 8)
    sidebarPadding.PaddingLeft = UDim.new(0, 10)
    sidebarPadding.PaddingRight = UDim.new(0, 10)
    sidebarPadding.Parent = self.Sidebar


    self.Content = Instance.new("Frame")
    self.Content.Size = UDim2.new(1, -150, 1, -40)
    self.Content.Position = UDim2.new(0, 150, 0, 40)
    self.Content.BackgroundColor3 = colors.Content
    self.Content.Parent = self.MainFrame

    self.Pages = {}
    self.CurrentPage = nil


    self._isBinding = false
    self._suppressKey = nil
    self.ToggleKey = Enum.KeyCode.Insert
    self.UnloadKey = Enum.KeyCode.Delete


    self._inputConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if self._isBinding then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == self.ToggleKey then
                self.MainFrame.Visible = not self.MainFrame.Visible
            elseif input.KeyCode == self.UnloadKey then
                if self._inputConn then self._inputConn:Disconnect() end
                self._screenGui:Destroy()
            end
        end
    end)


    local settings = self:CreateTab("Settings")
    settings:CreateLabel("Keybinds")
    settings:CreateKeybind("Toggle Menu", self.ToggleKey, function(newKey)
        self.ToggleKey = newKey
    end)
    settings:CreateKeybind("Unload Menu", self.UnloadKey, function(newKey)
        self.UnloadKey = newKey
    end)

    return self
end


function Neo:CreateTab(name: string)
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = self.Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.Parent = page

    self.Pages[name] = page

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = colors.Button
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(230,230,230)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    btn.Parent = self.Sidebar
    newCorner(6, btn)

    btn.MouseButton1Click:Connect(function()
        for _, pg in pairs(self.Pages) do pg.Visible = false end
        page.Visible = true
        self.CurrentPage = page
    end)

    return setmetatable({Page = page, Window = self}, {__index = Neo})
end

return Neo
