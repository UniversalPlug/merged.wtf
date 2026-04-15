local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Library = {
    Theme = {
        Main = Color3.fromRGB(10, 10, 10),
        Navbar = Color3.fromRGB(14, 14, 14),
        Accent = Color3.fromRGB(115, 218, 255),
        Section = Color3.fromRGB(18, 18, 18),
        SectionTitle = Color3.fromRGB(24, 24, 24),
        Border = Color3.fromRGB(32, 32, 32),
        TextMain = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(120, 120, 120)
    },
    Components = {},
    KeybindRegistry = {}
}

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local bindGroup = Library.KeybindRegistry[input.KeyCode]
    if bindGroup then
        for _, cb in pairs(bindGroup) do
            cb()
        end
    end
end)
function Library:RegisterKeybind(key, id, callback)
    if not key or not id then return end
    self.KeybindRegistry[key] = self.KeybindRegistry[key] or {}
    self.KeybindRegistry[key][id] = callback
end
function Library:UnregisterKeybind(key, id)
    if not key or not id or not self.KeybindRegistry[key] then return end
    self.KeybindRegistry[key][id] = nil
end
function Library:Tween(object, time, properties)
    local tween = TweenService:Create(object, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end
function Library:MakeDraggable(frame, trigger)
    local dragging, dragInput, dragStart, startPos
    trigger.InputBegan:Connect(function(input)
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
    trigger.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
function Library:CreateWindow(title, subtitle)
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "merged_wtf"
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.Parent = CoreGui

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 730, 0, 520)
    Main.Position = UDim2.new(0.5, -365, 0.5, -260)
    Main.BackgroundColor3 = Library.Theme.Main
    Main.BorderSizePixel = 1
    Main.BorderColor3 = Library.Theme.Border
    Main.Parent = Gui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 4)
    MainCorner.Parent = Main

    -- Navbar
    local Navbar = Instance.new("Frame")
    Navbar.Name = "Navbar"
    Navbar.Size = UDim2.new(1, 0, 0, 42)
    Navbar.BackgroundColor3 = Library.Theme.Navbar
    Navbar.BorderSizePixel = 0
    Navbar.Parent = Main

    local NavbarCorner = Instance.new("UICorner")
    NavbarCorner.CornerRadius = UDim.new(0, 4)
    NavbarCorner.Parent = Navbar

    -- Navbar Bottom Hide Corners
    local NavbarHideLine = Instance.new("Frame")
    NavbarHideLine.Size = UDim2.new(1, 0, 0, 2)
    NavbarHideLine.Position = UDim2.new(0, 0, 1, -2)
    NavbarHideLine.BackgroundColor3 = Library.Theme.Navbar
    NavbarHideLine.BorderSizePixel = 0
    NavbarHideLine.Parent = Navbar

    local NavbarLine = Instance.new("Frame")
    NavbarLine.Size = UDim2.new(1, 0, 0, 1)
    NavbarLine.Position = UDim2.new(0, 0, 1, 0)
    NavbarLine.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    NavbarLine.BorderSizePixel = 0
    NavbarLine.Parent = Navbar

    -- Logo
    local LogoContainer = Instance.new("Frame")
    LogoContainer.Size = UDim2.new(0, 200, 1, 0)
    LogoContainer.Position = UDim2.new(0, 25, 0, 0)
    LogoContainer.BackgroundTransparency = 1
    LogoContainer.Parent = Navbar

    local LogoLayout = Instance.new("UIListLayout")
    LogoLayout.FillDirection = Enum.FillDirection.Horizontal
    LogoLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LogoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    LogoLayout.Padding = UDim.new(0, 0)
    LogoLayout.Parent = LogoContainer

    local LogoMain = Instance.new("TextLabel")
    LogoMain.Text = title or "merged"
    LogoMain.Font = Enum.Font.GothamBold
    LogoMain.TextSize = 18
    LogoMain.TextColor3 = Library.Theme.TextMain
    LogoMain.Size = UDim2.new(0, 0, 0, 0)
    LogoMain.AutomaticSize = Enum.AutomaticSize.XY
    LogoMain.BackgroundTransparency = 1
    LogoMain.LayoutOrder = 1
    LogoMain.Parent = LogoContainer

    local LogoSub = Instance.new("TextLabel")
    LogoSub.Text = subtitle or ".wtf"
    LogoSub.Font = Enum.Font.GothamBold
    LogoSub.TextSize = 18
    LogoSub.TextColor3 = Library.Theme.Accent
    LogoSub.Size = UDim2.new(0, 0, 0, 0)
    LogoSub.AutomaticSize = Enum.AutomaticSize.XY
    LogoSub.BackgroundTransparency = 1
    LogoSub.LayoutOrder = 2
    LogoSub.Parent = LogoContainer

    Library:MakeDraggable(Main, Navbar)

    -- Tabs Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 360, 1, 0)
    TabContainer.Position = UDim2.new(1, -375, 0, 0) -- size.x - 4*90 - 15
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = Navbar

    local TabsLayout = Instance.new("UIListLayout")
    TabsLayout.FillDirection = Enum.FillDirection.Horizontal
    TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabsLayout.Parent = TabContainer

    -- Content Area
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -10, 1, -52)
    Content.Position = UDim2.new(0, 5, 0, 47)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    local Window = {
        Tabs = {},
        ActiveTab = nil,
        Gui = Gui,
        Main = Main
    }
    
    function Window:Destroy()
        Gui:Destroy()
    end

    function Window:CreateTab(name)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "Tab"
        TabButton.Size = UDim2.new(0, 90, 1, 0)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = name
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 14
        TabButton.TextColor3 = Library.Theme.TextDim
        TabButton.Parent = TabContainer

        local AccentLine = Instance.new("Frame")
        AccentLine.Size = UDim2.new(1, -30, 0, 2)
        AccentLine.Position = UDim2.new(0, 15, 1, -1)
        AccentLine.BackgroundColor3 = Library.Theme.Accent
        AccentLine.BorderSizePixel = 0
        AccentLine.Transparency = 1
        AccentLine.Parent = TabButton

        local Glow = Instance.new("Frame")
        Glow.Size = UDim2.new(1, -30, 0, 14)
        Glow.Position = UDim2.new(0, 15, 1, -15)
        Glow.BackgroundTransparency = 1
        Glow.BorderSizePixel = 0
        Glow.Parent = TabButton

        local GlowGradient = Instance.new("UIGradient")
        GlowGradient.Rotation = 270
        GlowGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library.Theme.Accent),
            ColorSequenceKeypoint.new(1, Library.Theme.Accent)
        })
        GlowGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.84),
            NumberSequenceKeypoint.new(1, 1)
        })
        GlowGradient.Parent = Glow

        local Page = Instance.new("ScrollingFrame")
        Page.Name = name .. "Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Visible = false
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 45)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Parent = Content

        local LeftColumn = Instance.new("Frame")
        LeftColumn.Name = "Left"
        LeftColumn.Size = UDim2.new(0, 350, 0, 0)
        LeftColumn.Position = UDim2.new(0, 5, 0, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.AutomaticSize = Enum.AutomaticSize.Y
        LeftColumn.Parent = Page

        local LeftList = Instance.new("UIListLayout")
        LeftList.Padding = UDim.new(0, 10)
        LeftList.SortOrder = Enum.SortOrder.LayoutOrder
        LeftList.Parent = LeftColumn

        local LeftPadding = Instance.new("UIPadding")
        LeftPadding.PaddingTop = UDim.new(0, 10)
        LeftPadding.Parent = LeftColumn

        local RightColumn = Instance.new("Frame")
        RightColumn.Name = "Right"
        RightColumn.Size = UDim2.new(0, 350, 0, 0)
        RightColumn.Position = UDim2.new(0, 365, 0, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.AutomaticSize = Enum.AutomaticSize.Y
        RightColumn.Parent = Page

        local RightList = Instance.new("UIListLayout")
        RightList.Padding = UDim.new(0, 10)
        RightList.SortOrder = Enum.SortOrder.LayoutOrder
        RightList.Parent = RightColumn

        local RightPadding = Instance.new("UIPadding")
        RightPadding.PaddingTop = UDim.new(0, 10)
        RightPadding.Parent = RightColumn

        -- Section logic
        local Tab = {
            Sections = {}
        }

        function Tab:CreateSection(title, side)
            local Column = (side == "Right" and RightColumn or LeftColumn)
            local Section = Instance.new("Frame")
            Section.Name = title
            Section.Size = UDim2.new(1, 0, 0, 0)
            Section.AutomaticSize = Enum.AutomaticSize.Y
            Section.BackgroundColor3 = Library.Theme.Section
            Section.BorderSizePixel = 1
            Section.BorderColor3 = Library.Theme.Border
            Section.Parent = Column

            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 4)
            SectionCorner.Parent = Section

            local SectionTitle = Instance.new("Frame")
            SectionTitle.Name = "TitleBar"
            SectionTitle.Size = UDim2.new(1, 0, 0, 28)
            SectionTitle.BackgroundColor3 = Library.Theme.SectionTitle
            SectionTitle.BorderSizePixel = 0
            SectionTitle.Parent = Section

            local SectionTitleCorner = Instance.new("UICorner")
            SectionTitleCorner.CornerRadius = UDim.new(0, 4)
            SectionTitleCorner.Parent = SectionTitle

            -- Hide bottom corners of titlebar
            local TitleHide = Instance.new("Frame")
            TitleHide.Size = UDim2.new(1, 0, 0, 2)
            TitleHide.Position = UDim2.new(0, 0, 1, -2)
            TitleHide.BackgroundColor3 = Library.Theme.SectionTitle
            TitleHide.BorderSizePixel = 0
            TitleHide.Parent = SectionTitle

            local TitleLine = Instance.new("Frame")
            TitleLine.Size = UDim2.new(1, 0, 0, 1)
            TitleLine.Position = UDim2.new(0, 0, 1, 0)
            TitleLine.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            TitleLine.BorderSizePixel = 0
            TitleLine.Parent = SectionTitle

            local TitleText = Instance.new("TextLabel")
            TitleText.Text = title
            TitleText.Font = Enum.Font.Gotham
            TitleText.TextSize = 13
            TitleText.TextColor3 = Library.Theme.TextMain
            TitleText.Position = UDim2.new(0, 10, 0, 0)
            TitleText.Size = UDim2.new(1, -10, 1, 0)
            TitleText.TextXAlignment = Enum.TextXAlignment.Left
            TitleText.BackgroundTransparency = 1
            TitleText.Parent = SectionTitle

            local Container = Instance.new("Frame")
            Container.Name = "Container"
            Container.Position = UDim2.new(0, 0, 0, 33)
            Container.Size = UDim2.new(1, 0, 0, 0)
            Container.AutomaticSize = Enum.AutomaticSize.Y
            Container.BackgroundTransparency = 1
            Container.Parent = Section

            local ContainerPadding = Instance.new("UIPadding")
            ContainerPadding.PaddingLeft = UDim.new(0, 15)
            ContainerPadding.PaddingRight = UDim.new(0, 15)
            ContainerPadding.PaddingBottom = UDim.new(0, 10)
            ContainerPadding.PaddingTop = UDim.new(0, 10)
            ContainerPadding.Parent = Container

            local ContainerLayout = Instance.new("UIListLayout")
            ContainerLayout.Padding = UDim.new(0, 8)
            ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContainerLayout.Parent = Container

            local SectionObj = {}

            function SectionObj:Clear()
                for _, v in ipairs(Container:GetChildren()) do
                    if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
                        v:Destroy()
                    end
                end
            end

            function SectionObj:Render(callback)
                self.RenderCallback = callback
                self:Refresh()
            end

            function SectionObj:Refresh()
                if self.RenderCallback then
                    self:Clear()
                    self.RenderCallback()
                end
            end

            function SectionObj:CreateToggle(label, default, callback)
                local Toggle = Instance.new("TextButton")
                Toggle.Name = label
                Toggle.Size = UDim2.new(1, 0, 0, 20)
                Toggle.BackgroundTransparency = 1
                Toggle.Text = ""
                Toggle.Parent = Container

                local Title = Instance.new("TextLabel")
                Title.Text = label
                Title.Font = Enum.Font.Gotham
                Title.TextSize = 13
                Title.TextColor3 = default and Library.Theme.TextMain or Library.Theme.TextDim
                Title.Size = UDim2.new(1, 0, 1, 0)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.BackgroundTransparency = 1
                Title.Parent = Toggle

                local Track = Instance.new("Frame")
                Track.Size = UDim2.new(0, 30, 0, 16)
                Track.Position = UDim2.new(1, -30, 0.5, -8)
                Track.BackgroundColor3 = default and Library.Theme.Accent or Color3.fromRGB(40, 40, 40)
                Track.BackgroundTransparency = 0.7
                Track.BorderSizePixel = 0
                Track.Parent = Toggle

                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(0, 8)
                TrackCorner.Parent = Track

                local TrackStroke = Instance.new("UIStroke")
                TrackStroke.Thickness = 1
                TrackStroke.Color = default and Library.Theme.Accent or Color3.fromRGB(45, 45, 45)
                TrackStroke.Transparency = 0 -- Fully visible outline
                TrackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                TrackStroke.Parent = Track

                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0, 12, 0, 12)
                Knob.Position = UDim2.new(default and 1 or 0, default and -14 or 2, 0.5, -6)
                Knob.BackgroundColor3 = default and Library.Theme.Accent or Color3.fromRGB(100, 100, 100)
                Knob.BorderSizePixel = 0
                Knob.Parent = Track

                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(0, 6)
                KnobCorner.Parent = Knob

                local Toggled = default or false
                local function SetState(state)
                    Toggled = state
                    Library:Tween(Title, 0.2, {TextColor3 = Toggled and Library.Theme.TextMain or Library.Theme.TextDim})
                    Library:Tween(Track, 0.2, {BackgroundColor3 = Toggled and Library.Theme.Accent or Color3.fromRGB(40, 40, 40)})
                    Library:Tween(TrackStroke, 0.2, {Color = Toggled and Library.Theme.Accent or Color3.fromRGB(45, 45, 45)})
                    Library:Tween(Knob, 0.2, {Position = UDim2.new(Toggled and 1 or 0, Toggled and -14 or 2, 0.5, -6)})
                    Library:Tween(Knob, 0.2, {BackgroundColor3 = Toggled and Library.Theme.Accent or Color3.fromRGB(100, 100, 100)})
                    if callback then callback(Toggled) end
                    task.delay(0.2, function()
                        self:Refresh()
                    end)
                end

                Toggle.MouseButton1Click:Connect(function()
                    SetState(not Toggled)
                end)

                local ToggleObj = {
                    Set = SetState,
                    Visible = function(self, bool)
                        Toggle.Visible = bool
                    end
                }

                function ToggleObj:AddKeybind(key, callback)
                    local BoundKey = key
                    local Listening = false
                    local BindId = label .. "_" .. Section.Name

                    local function TriggerAction()
                        SetState(not Toggled)
                    end

                    if BoundKey then
                        Library:RegisterKeybind(BoundKey, BindId, TriggerAction)
                    end

                    local BlacklistedKeys = {
                        [Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true, [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
                        [Enum.KeyCode.Tab] = true, [Enum.KeyCode.Slash] = true, [Enum.KeyCode.Period] = true, [Enum.KeyCode.Comma] = true
                    }

                    local KeyButton = Instance.new("TextButton")
                    KeyButton.Name = "Keybind"
                    KeyButton.Text = BoundKey and "[ " .. BoundKey.Name .. " ]" or "[ - ]"
                    KeyButton.Font = Enum.Font.Gotham
                    KeyButton.TextSize = 12
                    KeyButton.TextColor3 = Library.Theme.TextDim
                    KeyButton.Position = UDim2.new(1, -75, 0, 0)
                    KeyButton.Size = UDim2.new(0, 40, 1, 0)
                    KeyButton.TextXAlignment = Enum.TextXAlignment.Right
                    KeyButton.BackgroundTransparency = 1
                    KeyButton.Parent = Toggle

                    KeyButton.MouseButton1Click:Connect(function()
                        if Listening then return end
                        Listening = true
                        KeyButton.Text = "[ ... ]"
                        KeyButton.TextColor3 = Library.Theme.TextMain
                        
                        local Connection
                        Connection = UserInputService.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                local newKey = input.KeyCode
                                if newKey == Enum.KeyCode.Escape then
                                    Library:UnregisterKeybind(BoundKey, BindId)
                                    BoundKey = nil
                                elseif BlacklistedKeys[newKey] then
                                    return
                                else
                                    Library:UnregisterKeybind(BoundKey, BindId)
                                    BoundKey = newKey
                                    Library:RegisterKeybind(BoundKey, BindId, TriggerAction)
                                end
                                
                                KeyButton.Text = BoundKey and "[ " .. BoundKey.Name .. " ]" or "[ - ]"
                                KeyButton.TextColor3 = Library.Theme.TextDim
                                if callback then callback(BoundKey) end
                                
                                Listening = false
                                Connection:Disconnect()
                            end
                        end)
                    end)

                    return ToggleObj
                end

                function ToggleObj:AddColorPicker(defaultCol, callback)
                    local CurrentColor = defaultCol or Color3.new(1, 1, 1)
                    local CurrentAlpha = 1
                    local h, s, v = Color3.toHSV(CurrentColor)

                    local ColorSq = Instance.new("TextButton")
                    ColorSq.Name = "ColorPicker"
                    ColorSq.Size = UDim2.new(0, 14, 0, 14)
                    ColorSq.Position = UDim2.new(1, -50, 0.5, -7)
                    ColorSq.BackgroundColor3 = CurrentColor
                    ColorSq.Text = ""
                    ColorSq.BorderSizePixel = 0
                    ColorSq.Parent = Toggle
                    
                    local Corner = Instance.new("UICorner")
                    Corner.CornerRadius = UDim.new(0, 2)
                    Corner.Parent = ColorSq

                    local Stroke = Instance.new("UIStroke")
                    Stroke.Color = Color3.fromRGB(60, 60, 60)
                    Stroke.Thickness = 1
                    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    Stroke.Parent = ColorSq

                    local PickerFrame = Instance.new("Frame")
                    PickerFrame.Size = UDim2.new(0, 180, 0, 200)
                    PickerFrame.BackgroundColor3 = Library.Theme.Main
                    PickerFrame.BorderColor3 = Library.Theme.Border
                    PickerFrame.BorderSizePixel = 1
                    PickerFrame.ZIndex = 5000
                    PickerFrame.Visible = false
                    PickerFrame.Parent = Gui

                    local PickerCorner = Instance.new("UICorner")
                    PickerCorner.CornerRadius = UDim.new(0, 4)
                    PickerCorner.Parent = PickerFrame

                    local SVBox = Instance.new("Frame")
                    SVBox.Size = UDim2.new(0, 150, 0, 150)
                    SVBox.Position = UDim2.new(0, 5, 0, 5)
                    SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    SVBox.BorderSizePixel = 0
                    SVBox.Parent = PickerFrame

                    local SGradient = Instance.new("UIGradient")
                    SGradient.Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromHSV(h, 1, 1))
                    SGradient.Parent = SVBox

                    local VBox = Instance.new("Frame")
                    VBox.Size = UDim2.new(1, 0, 1, 0)
                    VBox.BackgroundTransparency = 0
                    VBox.BorderSizePixel = 0
                    VBox.Parent = SVBox

                    local VGradient = Instance.new("UIGradient")
                    VGradient.Rotation = 90
                    VGradient.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(0,0,0))
                    VGradient.Transparency = NumberSequence.new(1, 0)
                    VGradient.Parent = VBox

                    local SVSwitcher = Instance.new("Frame")
                    SVSwitcher.Size = UDim2.new(0, 4, 0, 4)
                    SVSwitcher.BackgroundColor3 = Color3.new(1, 1, 1)
                    SVSwitcher.Position = UDim2.new(s, -2, 1-v, -2)
                    SVSwitcher.Parent = SVBox

                    local HueBar = Instance.new("Frame")
                    HueBar.Size = UDim2.new(0, 15, 0, 150)
                    HueBar.Position = UDim2.new(0, 160, 0, 5)
                    HueBar.BackgroundColor3 = Color3.new(1, 1, 1)
                    HueBar.BorderSizePixel = 0
                    HueBar.Parent = PickerFrame

                    local HueGradient = Instance.new("UIGradient")
                    HueGradient.Rotation = 90
                    HueGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.new(1, 1, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.new(0, 1, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),
                        ColorSequenceKeypoint.new(0.67, Color3.new(0, 0, 1)),
                        ColorSequenceKeypoint.new(0.83, Color3.new(1, 0, 1)),
                        ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
                    })
                    HueGradient.Parent = HueBar

                    local HueSwitcher = Instance.new("Frame")
                    HueSwitcher.Size = UDim2.new(1, 2, 0, 2)
                    HueSwitcher.Position = UDim2.new(0, -1, h, -1)
                    HueSwitcher.BackgroundColor3 = Color3.new(1, 1, 1)
                    HueSwitcher.Parent = HueBar

                    local AlphaBar = Instance.new("Frame")
                    AlphaBar.Size = UDim2.new(0, 170, 0, 15)
                    AlphaBar.Position = UDim2.new(0, 5, 0, 165)
                    AlphaBar.BackgroundColor3 = Color3.new(1, 1, 1)
                    AlphaBar.BorderSizePixel = 0
                    AlphaBar.Parent = PickerFrame

                    local AlphaGradient = Instance.new("UIGradient")
                    AlphaGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1))
                    AlphaGradient.Transparency = NumberSequence.new(0, 1)
                    AlphaGradient.Parent = AlphaBar

                    local AlphaSwitcher = Instance.new("Frame")
                    AlphaSwitcher.Size = UDim2.new(0, 2, 1, 2)
                    AlphaSwitcher.Position = UDim2.new(1 - CurrentAlpha, -1, 0, -1)
                    AlphaSwitcher.BackgroundColor3 = Color3.new(1, 1, 1)
                    AlphaSwitcher.Parent = AlphaBar

                    local function UpdateColor()
                        CurrentColor = Color3.fromHSV(h, s, v)
                        ColorSq.BackgroundColor3 = CurrentColor
                        SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        SGradient.Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromHSV(h, 1, 1))
                        AlphaGradient.Color = ColorSequence.new(CurrentColor, CurrentColor)
                        if callback then callback(CurrentColor, CurrentAlpha) end
                    end

                    local draggingSV = false
                    SVBox.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            draggingSV = true
                        end
                    end)

                    local draggingHue = false
                    HueBar.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            draggingHue = true
                        end
                    end)

                    local draggingAlpha = false
                    AlphaBar.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            draggingAlpha = true
                        end
                    end)

                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            draggingSV = false
                            draggingHue = false
                            draggingAlpha = false
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if draggingSV then
                                local rPos = math.clamp((input.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
                                local tPos = math.clamp((input.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
                                s = rPos
                                v = 1 - tPos
                                SVSwitcher.Position = UDim2.new(s, -2, 1-v, -2)
                                UpdateColor()
                            elseif draggingHue then
                                local tPos = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                                h = tPos
                                HueSwitcher.Position = UDim2.new(0, -1, h, -1)
                                UpdateColor()
                            elseif draggingAlpha then
                                local rPos = math.clamp((input.Position.X - AlphaBar.AbsolutePosition.X) / AlphaBar.AbsoluteSize.X, 0, 1)
                                CurrentAlpha = 1 - rPos
                                AlphaSwitcher.Position = UDim2.new(rPos, -1, 0, -1)
                                UpdateColor()
                            end
                        end
                    end)

                    local function UpdatePos()
                        local pos = ColorSq.AbsolutePosition
                        PickerFrame.Position = UDim2.new(0, pos.X + 25, 0, pos.Y)
                    end

                    ColorSq.MouseButton1Click:Connect(function()
                        PickerFrame.Visible = not PickerFrame.Visible
                        if PickerFrame.Visible then
                            UpdatePos()
                        end
                    end)

                    RunService.Heartbeat:Connect(function()
                        if PickerFrame.Visible then
                            UpdatePos()
                        end
                    end)

                    return ToggleObj
                end

                return ToggleObj
            end

            function SectionObj:CreateSlider(label, min, max, default, format, callback)
                if type(format) == "function" then
                    callback = format
                    format = nil
                end
                local Slider = Instance.new("Frame")
                Slider.Name = label
                Slider.Size = UDim2.new(1, 0, 0, 32)
                Slider.BackgroundTransparency = 1
                Slider.Parent = Container

                local Title = Instance.new("TextLabel")
                Title.Text = label
                Title.Font = Enum.Font.Gotham
                Title.TextSize = 13
                Title.TextColor3 = Library.Theme.TextDim
                Title.Size = UDim2.new(1, 0, 0, 16)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.BackgroundTransparency = 1
                Title.Parent = Slider

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Text = string.format(format or "%.0f", default)
                ValueLabel.Font = Enum.Font.Gotham
                ValueLabel.TextSize = 13
                ValueLabel.TextColor3 = Library.Theme.TextDim
                ValueLabel.Position = UDim2.new(1, -30, 0, 0)
                ValueLabel.Size = UDim2.new(0, 30, 0, 16)
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Parent = Slider

                local Track = Instance.new("Frame")
                Track.Size = UDim2.new(1, -10, 0, 4)
                Track.Position = UDim2.new(0, 5, 0, 22)
                Track.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                Track.BorderSizePixel = 0
                Track.Parent = Slider

                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(0, 2)
                TrackCorner.Parent = Track

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                Fill.BackgroundColor3 = Library.Theme.Accent
                Fill.BorderSizePixel = 0
                Fill.Parent = Track

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(0, 2)
                FillCorner.Parent = Fill

                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0, 12, 0, 12)
                Knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
                Knob.BackgroundColor3 = Library.Theme.TextMain
                Knob.BorderSizePixel = 0
                Knob.Parent = Track

                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(0, 6)
                KnobCorner.Parent = Knob

                local currentPos = (default - min) / (max - min)
                local targetPos = currentPos

                local function UpdateValue(input)
                    targetPos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local value = min + (targetPos * (max - min))
                    ValueLabel.Text = string.format(format or "%.0f", value)
                    if callback then callback(value) end
                end

                RunService.RenderStepped:Connect(function(dt)
                    currentPos = currentPos + (targetPos - currentPos) * math.clamp(dt * 15, 0, 1)
                    if math.abs(targetPos - currentPos) < 0.001 then currentPos = targetPos end
                    
                    Fill.Size = UDim2.new(currentPos, 0, 1, 0)
                    Knob.Position = UDim2.new(currentPos, -6, 0.5, -6)
                end)

                local dragging = false
                Slider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateValue(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateValue(input)
                    end
                end)

                return {
                    Set = function(val)
                        local pos = math.clamp((val - min) / (max - min), 0, 1)
                        ValueLabel.Text = string.format(format or "%.0f", val)
                        Fill.Size = UDim2.new(pos, 0, 1, 0)
                        Knob.Position = UDim2.new(pos, -6, 0.5, -6)
                    end,
                    Visible = function(self, bool)
                        Slider.Visible = bool
                    end
                }
            end

            function SectionObj:CreateButton(label, callback)
                local Button = Instance.new("TextButton")
                Button.Name = label
                Button.Size = UDim2.new(1, -10, 0, 28)
                Button.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                Button.BorderSizePixel = 1
                Button.BorderColor3 = Color3.fromRGB(45, 45, 45)
                Button.Text = label
                Button.Font = Enum.Font.Gotham
                Button.TextSize = 13
                Button.TextColor3 = Color3.fromRGB(150, 150, 150)
                Button.Parent = Container

                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 2)
                Corner.Parent = Button

                Button.MouseEnter:Connect(function()
                    Library:Tween(Button, 0.2, {BackgroundColor3 = Color3.fromRGB(35, 35, 35), TextColor3 = Color3.fromRGB(200, 200, 200)})
                end)

                Button.MouseLeave:Connect(function()
                    Library:Tween(Button, 0.2, {BackgroundColor3 = Color3.fromRGB(28, 28, 28), TextColor3 = Color3.fromRGB(150, 150, 150)})
                end)

                Button.MouseButton1Click:Connect(function()
                    local oldCol = Button.BackgroundColor3
                    Button.BackgroundColor3 = Library.Theme.Accent
                    Button.BackgroundTransparency = 0.8
                    task.wait(0.1)
                    Button.BackgroundColor3 = oldCol
                    Button.BackgroundTransparency = 0
                    if callback then callback() end
                    self:Refresh()
                end)

                return {
                    Visible = function(self, bool)
                        Button.Visible = bool
                    end
                }
            end

            function SectionObj:CreateInput(label, placeholder, callback)
                local InputFrame = Instance.new("Frame")
                InputFrame.Size = UDim2.new(1, 0, 0, 48)
                InputFrame.BackgroundTransparency = 1
                InputFrame.Parent = Container

                local Title = Instance.new("TextLabel")
                Title.Text = label
                Title.Font = Enum.Font.Gotham
                Title.TextSize = 12
                Title.TextColor3 = Library.Theme.TextDim
                Title.Size = UDim2.new(1, 0, 0, 16)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.BackgroundTransparency = 1
                Title.Parent = InputFrame

                local Box = Instance.new("TextBox")
                Box.Size = UDim2.new(1, -10, 0, 28)
                Box.Position = UDim2.new(0, 0, 0, 20)
                Box.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                Box.BorderSizePixel = 1
                Box.BorderColor3 = Color3.fromRGB(45, 45, 45)
                Box.PlaceholderText = placeholder or "..."
                Box.Text = ""
                Box.Font = Enum.Font.Gotham
                Box.TextSize = 13
                Box.TextColor3 = Library.Theme.TextMain
                Box.ClearTextOnFocus = false
                Box.Parent = InputFrame

                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 2)
                Corner.Parent = Box

                Box.Focused:Connect(function()
                    Library:Tween(Box, 0.2, {BorderColor3 = Library.Theme.Accent})
                end)

                Box.FocusLost:Connect(function()
                    Library:Tween(Box, 0.2, {BorderColor3 = Color3.fromRGB(45, 45, 45)})
                    if callback then callback(Box.Text) end
                    self:Refresh()
                end)

                return {
                    Visible = function(self, bool)
                        InputFrame.Visible = bool
                    end
                }
            end

            return SectionObj
        end

        TabButton.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Library:Tween(TabButton, 0.2, {TextColor3 = Library.Theme.TextMain})
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Library:Tween(TabButton, 0.2, {TextColor3 = Library.Theme.TextDim})
            end
        end)

        TabButton.MouseButton1Click:Connect(function()
            if Window.ActiveTab == Tab then return end
            
            if Window.ActiveTab then
                Library:Tween(Window.ActiveTab.Button, 0.2, {TextColor3 = Library.Theme.TextDim})
                Library:Tween(Window.ActiveTab.Accent, 0.2, {Transparency = 1})
                Library:Tween(Window.ActiveTab.Glow, 0.2, {Transparency = 1})
                Window.ActiveTab.Page.Visible = false
            end

            Window.ActiveTab = Tab
            Library:Tween(TabButton, 0.2, {TextColor3 = Library.Theme.TextMain})
            Library:Tween(AccentLine, 0.2, {Transparency = 0})
            Library:Tween(Glow, 0.2, {Transparency = 0})
            Page.Visible = true
        end)

        Tab.Button = TabButton
        Tab.Accent = AccentLine
        Tab.Glow = Glow
        Tab.Page = Page
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            Window.ActiveTab = Tab
            TabButton.TextColor3 = Library.Theme.TextMain
            AccentLine.Transparency = 0
            Glow.Transparency = 0
            Page.Visible = true
        end

        return Tab
    end

    return Window
end
return Library
