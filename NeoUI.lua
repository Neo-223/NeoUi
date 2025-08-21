--// Neo UI Library
--// https://github.com/Neo-223/NeoUi
--// v2.0

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library

-- Theme
local Theme = {
    Background = Color3.fromRGB(25, 25, 25),
    Topbar = Color3.fromRGB(30, 30, 30),
    Sidebar = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(0, 120, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Outline = Color3.fromRGB(50, 50, 50)
}

-- Utility
local function MakeDraggable(frame, dragHandle)
    local dragging, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Create Window
function Library:CreateWindow(title)
    local Window = {}
    Window.Tabs = {}

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game:GetService("CoreGui")

    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 600, 0, 400)
    Main.Position = UDim2.new(0.5, -300, 0.5, -200)
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    -- UICorner
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 30)
    Topbar.BackgroundColor3 = Theme.Topbar
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Main

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -10, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar

    MakeDraggable(Main, Topbar)

    -- Sidebar (with scrolling)
    local SidebarHolder = Instance.new("ScrollingFrame")
    SidebarHolder.Size = UDim2.new(0, 150, 1, -30)
    SidebarHolder.Position = UDim2.new(0, 0, 0, 30)
    SidebarHolder.BackgroundColor3 = Theme.Sidebar
    SidebarHolder.BorderSizePixel = 0
    SidebarHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    SidebarHolder.ScrollBarThickness = 0
    SidebarHolder.Parent = Main

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Parent = SidebarHolder
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SidebarHolder.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 4)
    end)

    -- Content Area (with scrolling)
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Size = UDim2.new(1, -150, 1, -30)
    ContentHolder.Position = UDim2.new(0, 150, 0, 30)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = Main

    local function CreateTab(name)
        local Tab = {}
        Tab.Objects = {}

        -- Tab Button
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 30)
        Button.Text = name
        Button.TextColor3 = Theme.Text
        Button.Font = Enum.Font.SourceSans
        Button.TextSize = 16
        Button.BackgroundTransparency = 1
        Button.Parent = SidebarHolder

        -- Tab Page (scrollable)
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Visible = false
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 0
        Page.Parent = ContentHolder

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Page
        PageLayout.Padding = UDim.new(0, 4)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 4)
        end)

        -- Tab Switching
        Button.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                t.Button.BackgroundColor3 = Theme.Sidebar
            end
            Page.Visible = true
            Button.BackgroundColor3 = Theme.Topbar
        end)

        -- Component APIs
        function Tab:CreateLabel(text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -10, 0, 25)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.Text
            Label.Font = Enum.Font.SourceSans
            Label.TextSize = 16
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Page
            return Label
        end

        function Tab:CreateButton(text, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -10, 0, 30)
            Button.BackgroundColor3 = Theme.Outline
            Button.Text = text
            Button.TextColor3 = Theme.Text
            Button.Font = Enum.Font.SourceSans
            Button.TextSize = 16
            Button.Parent = Page
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)
            Button.MouseButton1Click:Connect(callback)
            return Button
        end

        function Tab:CreateToggle(text, callback)
            local Toggle = Instance.new("TextButton")
            Toggle.Size = UDim2.new(1, -10, 0, 30)
            Toggle.BackgroundColor3 = Theme.Outline
            Toggle.TextColor3 = Theme.Text
            Toggle.Font = Enum.Font.SourceSans
            Toggle.TextSize = 16
            Toggle.TextXAlignment = Enum.TextXAlignment.Left
            Toggle.Text = text .. ": OFF"
            Toggle.Parent = Page
            Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 4)

            local state = false
            Toggle.MouseButton1Click:Connect(function()
                state = not state
                Toggle.Text = text .. (state and ": ON" or ": OFF")
                callback(state)
            end)
            return Toggle
        end

        function Tab:CreateSlider(text, min, max, defaultValue, callback)
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -10, 0, 40)
            Frame.BackgroundTransparency = 1
            Frame.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 20)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Theme.Text
            Label.Font = Enum.Font.SourceSans
            Label.TextSize = 16
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Text = text .. ": " .. defaultValue
            Label.Parent = Frame

            local SliderBack = Instance.new("Frame")
            SliderBack.Size = UDim2.new(1, 0, 0, 10)
            SliderBack.Position = UDim2.new(0, 0, 0, 25)
            SliderBack.BackgroundColor3 = Theme.Outline
            SliderBack.BorderSizePixel = 0
            SliderBack.Parent = Frame

            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Theme.Accent
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBack

            local dragging = false
            SliderBack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * pos)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    Label.Text = text .. ": " .. val
                    callback(val)
                end
            end)

            return Frame
        end

        function Tab:CreateRebind(text, defaultKey, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -10, 0, 30)
            Button.BackgroundColor3 = Theme.Outline
            Button.TextColor3 = Theme.Text
            Button.Font = Enum.Font.SourceSans
            Button.TextSize = 16
            Button.TextXAlignment = Enum.TextXAlignment.Left
            Button.Text = text .. ": " .. defaultKey.Name
            Button.Parent = Page
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)

            local binding = false
            local currentKey = defaultKey

            Button.MouseButton1Click:Connect(function()
                if not binding then
                    binding = true
                    Button.Text = text .. ": ..."
                    local inputConn
                    inputConn = UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            Button.Text = text .. ": " .. currentKey.Name
                            callback(currentKey)
                            binding = false
                            inputConn:Disconnect()
                        end
                    end)
                end
            end)

            return Button
        end

        Tab.Page = Page
        Tab.Button = Button
        table.insert(Window.Tabs, Tab)
        return Tab
    end

    Window.CreateTab = CreateTab

    -- Default Settings Tab (no "Keybinds" label now)
    local settingsTab = CreateTab("Settings")

    local toggleKey = Enum.KeyCode.Insert
    local unloadKey = Enum.KeyCode.Delete

    settingsTab:CreateRebind("Toggle Menu", toggleKey, function(key)
        toggleKey = key
    end)

    settingsTab:CreateRebind("Unload Menu", unloadKey, function(key)
        unloadKey = key
    end)

    -- Keybind Functions
    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == toggleKey then
            Main.Visible = not Main.Visible
        elseif input.KeyCode == unloadKey then
            ScreenGui:Destroy()
        end
    end)

    return Window
end

return Library
