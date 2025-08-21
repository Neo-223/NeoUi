-- Neo UI Library with forced Settings tab and fixed slider/toggle
-- Default keys: Insert (show/hide), Delete (unload)

local Neo = {}
Neo.__index = Neo

-- Services
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Library constructor
function Neo:CreateWindow(title)
    local window = setmetatable({}, Neo)

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "NeoUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = game:GetService("CoreGui")
    window.Gui = gui

    -- Main Frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 600, 0, 400)
    main.Position = UDim2.new(0.5, -300, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = gui
    window.Main = main

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 150, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    window.Sidebar = sidebar

    local listLayout = Instance.new("UIListLayout", sidebar)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- TopBar (title)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleLabel.Text = title or "Neo"
    titleLabel.TextColor3 = Color3.new(1,1,1)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.Parent = main

    -- Content container
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -150, 1, -40)
    content.Position = UDim2.new(0, 150, 0, 40)
    content.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    content.BorderSizePixel = 0
    content.Parent = main
    window.Content = content

    -- Tabs
    window.Tabs = {}

    function window:CreateTab(name)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, 0, 0, 40)
        tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        tabBtn.Text = name
        tabBtn.TextColor3 = Color3.new(1,1,1)
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.TextSize = 16
        tabBtn.Parent = sidebar

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.ScrollBarThickness = 4
        page.Parent = content

        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        local tab = {
            Button = tabBtn,
            Page = page
        }
        self.Tabs[name] = tab

        tabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(self.Tabs) do
                t.Page.Visible = false
                t.Button.BackgroundColor3 = Color3.fromRGB(40,40,40)
            end
            page.Visible = true
            tabBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        end)

        if not self.CurrentTab then
            tabBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
            page.Visible = true
            self.CurrentTab = tab
        end

        -- Tab component creators
        function tab:CreateLabel(text)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -10, 0, 30)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = Color3.new(1,1,1)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 16
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = page
            return lbl
        end

        function tab:CreateButton(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 35)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = text
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 16
            btn.Parent = page
            btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            return btn
        end

        function tab:CreateToggle(text, default, callback)
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, -10, 0, 35)
            holder.BackgroundTransparency = 1
            holder.Parent = page

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.7, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = Color3.new(1,1,1)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 16
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = holder

            local box = Instance.new("TextButton")
            box.Size = UDim2.new(0, 30, 0, 30)
            box.Position = UDim2.new(1, -35, 0.5, -15)
            box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            box.Text = ""
            box.Parent = holder

            local enabled = default or false
            local function update()
                box.BackgroundColor3 = enabled and Color3.fromRGB(0,170,255) or Color3.fromRGB(50,50,50)
            end
            update()

            box.MouseButton1Click:Connect(function()
                enabled = not enabled
                update()
                if callback then callback(enabled) end
            end)

            return box
        end

        function tab:CreateSlider(text, min, max, default, callback)
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, -10, 0, 50)
            holder.BackgroundTransparency = 1
            holder.Parent = page

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 20)
            lbl.BackgroundTransparency = 1
            lbl.Text = text .. ": " .. tostring(default)
            lbl.TextColor3 = Color3.new(1,1,1)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 16
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = holder

            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, 0, 0, 8)
            bar.Position = UDim2.new(0, 0, 0, 30)
            bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            bar.BorderSizePixel = 0
            bar.Parent = holder

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
            fill.BorderSizePixel = 0
            fill.Parent = bar

            local dragging = false
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            bar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            UIS.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max-min)*rel)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    lbl.Text = text .. ": " .. tostring(val)
                    if callback then callback(val) end
                end
            end)

            return holder
        end

        return tab
    end

    function window:Toggle()
        self.Main.Visible = not self.Main.Visible
    end

    function window:Destroy()
        self.Gui:Destroy()
    end

    -- Settings tab (always last)
    local function createSettings()
        local settingsTab = window:CreateTab("Settings")
        settingsTab.Button.LayoutOrder = 999

        local hideKey = Enum.KeyCode.Insert
        local listening = false

        settingsTab:CreateLabel("Menu Settings")

        local rebindBtn
        rebindBtn = settingsTab:CreateButton("Rebind Hide/Show (Current: " .. hideKey.Name .. ")", function()
            rebindBtn.Text = "Press any key..."
            listening = true
        end)

        UIS.InputBegan:Connect(function(input, gpe)
            if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                hideKey = input.KeyCode
                rebindBtn.Text = "Rebind Hide/Show (Current: " .. hideKey.Name .. ")"
                listening = false
            elseif not gpe and input.KeyCode == hideKey then
                window:Toggle()
            elseif not gpe and input.KeyCode == Enum.KeyCode.Delete then
                window:Destroy()
            end
        end)

        settingsTab:CreateButton("Unload Menu (Delete)", function()
            window:Destroy()
        end)
    end

    createSettings()

    return window
end

return Neo
