-- Neo GUI Library (with Settings tab + default keybinds)
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

local function highlightTab(sidebar: Frame, selectedBtn: TextButton)
    for _, child in ipairs(sidebar:GetChildren()) do
        if child:IsA("TextButton") then
            child.BackgroundColor3 = colors.Button
        end
    end
    selectedBtn.BackgroundColor3 = colors.Accent
end

----------------------------------------------------------------------

function Neo:CreateWindow(title: string)
    local window = {}
    setmetatable(window, Neo)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NeoModMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui
    window.Gui = screenGui

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

    -- === Inject permanent Settings tab ===
    local function addSettingsTab()
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
        btn.LayoutOrder = 9999 -- always bottom
        btn.Parent = self.Sidebar

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn

        local page = Instance.new("Frame")
        page.Name = "SettingsPage"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.Parent = self.Content

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = page

        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 15)
        padding.PaddingLeft = UDim.new(0, 15)
        padding.Parent = page

        self.Pages["Settings"] = page

        local function selectThis()
            for _, p in pairs(self.Pages) do p.Visible = false end
            page.Visible = true
            highlightTab(self.Sidebar, btn)
        end
        btn.MouseButton1Click:Connect(selectThis)

        -- Default contents:
        -- Rebindable Hide/Show
        local hideBind = Enum.KeyCode.Insert
        local unloadBind = Enum.KeyCode.Delete

        local hideBtn = Instance.new("TextButton")
        hideBtn.Size = UDim2.new(0, 260, 0, 30)
        hideBtn.BackgroundColor3 = colors.Button
        hideBtn.Text = "Rebind Hide/Show (Insert)"
        hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        hideBtn.Font = Enum.Font.Gotham
        hideBtn.TextSize = 14
        hideBtn.Parent = page
        Instance.new("UICorner", hideBtn)

        hideBtn.MouseButton1Click:Connect(function()
            hideBtn.Text = "Press a key..."
            local conn; conn = UserInputService.InputBegan:Connect(function(input, gpe)
                if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
                    hideBind = input.KeyCode
                    hideBtn.Text = "Rebind Hide/Show ("..hideBind.Name..")"
                    conn:Disconnect()
                end
            end)
        end)

        local unloadBtn = Instance.new("TextButton")
        unloadBtn.Size = UDim2.new(0, 260, 0, 30)
        unloadBtn.BackgroundColor3 = colors.Button
        unloadBtn.Text = "Rebind Unload (Delete)"
        unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        unloadBtn.Font = Enum.Font.Gotham
        unloadBtn.TextSize = 14
        unloadBtn.Parent = page
        Instance.new("UICorner", unloadBtn)

        unloadBtn.MouseButton1Click:Connect(function()
            unloadBtn.Text = "Press a key..."
            local conn; conn = UserInputService.InputBegan:Connect(function(input, gpe)
                if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
                    unloadBind = input.KeyCode
                    unloadBtn.Text = "Rebind Unload ("..unloadBind.Name..")"
                    conn:Disconnect()
                end
            end)
        end)

        -- Bind handling
        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == hideBind then
                self:Toggle()
            elseif input.KeyCode == unloadBind then
                self:Destroy()
            end
        end)
    end

    addSettingsTab()

    return window
end

----------------------------------------------------------------------

-- Tab, Button, Toggle, Slider functions remain the same as your code...
-- (keep your existing CreateTab, CreateButton, CreateToggle, CreateSlider etc.)

return Neo
