-- BloxStrike Ultimate UI
-- UI customizada do zero

-- Aguardar carregamento
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Serviços
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

-- Configurações
local Settings = {
    Aim = {
        Enabled = false,
        Silent = false,
        Method = "Raycast",
        HitChance = 100,
        FOV = 250,
        Smoothing = 0,
        Prediction = 12,
        TargetPart = "Head",
        TeamCheck = true
    },
    Combat = {
        TriggerBot = false,
        TriggerDelay = 0.1,
        HitboxExpander = false,
        HitboxSize = 1.5,
        AutoShoot = false,
        WallBang = false
    },
    Visuals = {
        ESP = false,
        Box = false,
        Tracers = false,
        ShowNames = true,
        ShowHealth = true,
        ShowDistance = true,
        TeamCheck = true,
        Chams = false,
        HighlightColor = Color3.fromRGB(255, 0, 0)
    },
    Movement = {
        Fly = false,
        FlySpeed = 50,
        FlyKey = Enum.KeyCode.E,
        SpeedHack = false,
        SpeedAmount = 30,
        HighJump = false,
        JumpPower = 100,
        NoClip = false,
        InfiniteJump = false
    },
    Misc = {
        AntiAFK = false,
        FullBright = false,
        FOVChanger = false,
        CustomFOV = 120,
        Crosshair = false,
        NoRecoil = false,
        NoSpread = false
    }
}

-- Variáveis
local library = {}
local dragger = {}
local pages = {}
local connections = {}
local dragging = false
local dragInput
local dragStart
local startPos
local flyBodyVelocity

-- Cores
local accentColor = Color3.fromRGB(0, 170, 255)
local backgroundColor = Color3.fromRGB(20, 20, 25)
local elementColor = Color3.fromRGB(30, 30, 35)
local textColor = Color3.fromRGB(240, 240, 240)
local subTextColor = Color3.fromRGB(180, 180, 180)

-- Função para criar elementos UI
function library:CreateWindow(name)
    local screenGui = Instance.new("ScreenGui")
    if syn then
        syn.protect_gui(screenGui)
    end
    screenGui.Name = "BloxStrikeUI"
    screenGui.Parent = game.CoreGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 550, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    mainFrame.BackgroundColor3 = backgroundColor
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = mainFrame
    shadow.ZIndex = -1

    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "BloxStrike | " .. name
    title.TextColor3 = textColor
    title.TextSize = 14
    title.Font = Enum.Font.GothamSemibold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 2)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×"
    closeBtn.TextColor3 = subTextColor
    closeBtn.TextSize = 24
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    closeBtn.MouseEnter:Connect(function()
        closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        closeBtn.TextColor3 = subTextColor
    end)

    -- Barra lateral
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 140, 1, -35)
    sidebar.Position = UDim2.new(0, 0, 0, 35)
    sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    
    local sidebarList = Instance.new("UIListLayout")
    sidebarList.Parent = sidebar
    sidebarList.Padding = UDim.new(0, 5)
    
    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 10)
    sidebarPadding.PaddingLeft = UDim.new(0, 5)
    sidebarPadding.Parent = sidebar

    -- Container de páginas
    local pagesContainer = Instance.new("Frame")
    pagesContainer.Name = "PagesContainer"
    pagesContainer.Size = UDim2.new(1, -145, 1, -45)
    pagesContainer.Position = UDim2.new(0, 140, 0, 40)
    pagesContainer.BackgroundTransparency = 1
    pagesContainer.Parent = mainFrame
    
    local pagesList = Instance.new("UIListLayout")
    pagesList.Parent = pagesContainer
    pagesList.FillDirection = Enum.FillDirection.Vertical
    pagesList.Padding = UDim.new(0, 10)
    
    local pagesPadding = Instance.new("UIPadding")
    pagesPadding.PaddingTop = UDim.new(0, 5)
    pagesPadding.PaddingLeft = UDim.new(0, 5)
    pagesPadding.PaddingRight = UDim.new(0, 5)
    pagesPadding.Parent = pagesContainer

    -- Função para arrastar
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Sistema de páginas
    function library:CreateTab(name, icon)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "Tab"
        tabButton.Size = UDim2.new(1, -10, 0, 35)
        tabButton.BackgroundColor3 = elementColor
        tabButton.BorderSizePixel = 0
        tabButton.Text = ""
        tabButton.Parent = sidebar
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabButton
        
        local tabTitle = Instance.new("TextLabel")
        tabTitle.Name = "Title"
        tabTitle.Size = UDim2.new(1, 0, 1, 0)
        tabTitle.BackgroundTransparency = 1
        tabTitle.Text = name
        tabTitle.TextColor3 = subTextColor
        tabTitle.TextSize = 12
        tabTitle.Font = Enum.Font.GothamSemibold
        tabTitle.TextXAlignment = Enum.TextXAlignment.Left
        tabTitle.Position = UDim2.new(0, 35, 0, 0)
        tabTitle.Parent = tabButton
        
        local tabIcon = Instance.new("TextLabel")
        tabIcon.Name = "Icon"
        tabIcon.Size = UDim2.new(0, 25, 0, 25)
        tabIcon.Position = UDim2.new(0, 5, 0.5, -12.5)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Text = icon or "▷"
        tabIcon.TextColor3 = subTextColor
        tabIcon.TextSize = 14
        tabIcon.Font = Enum.Font.GothamBold
        tabIcon.Parent = tabButton
        
        local tabPage = Instance.new("ScrollingFrame")
        tabPage.Name = name .. "Page"
        tabPage.Size = UDim2.new(1, 0, 1, 0)
        tabPage.BackgroundTransparency = 1
        tabPage.BorderSizePixel = 0
        tabPage.ScrollBarThickness = 3
        tabPage.ScrollBarImageColor3 = accentColor
        tabPage.Visible = false
        tabPage.Parent = pagesContainer
        
        local tabPageList = Instance.new("UIListLayout")
        tabPageList.Parent = tabPage
        tabPageList.Padding = UDim.new(0, 10)
        
        local tabPagePadding = Instance.new("UIPadding")
        tabPagePadding.PaddingTop = UDim.new(0, 5)
        tabPagePadding.PaddingLeft = UDim.new(0, 5)
        tabPagePadding.PaddingRight = UDim.new(0, 5)
        tabPagePadding.Parent = tabPage
        
        pages[name] = tabPage
        
        tabButton.MouseButton1Click:Connect(function()
            for _, page in pairs(pages) do
                page.Visible = false
            end
            
            for _, btn in pairs(sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    local title = btn:FindFirstChild("Title")
                    local icon = btn:FindFirstChild("Icon")
                    if title then
                        title.TextColor3 = subTextColor
                    end
                    if icon then
                        icon.TextColor3 = subTextColor
                    end
                    btn.BackgroundColor3 = elementColor
                end
            end
            
            tabPage.Visible = true
            tabButton.BackgroundColor3 = accentColor
            tabTitle.TextColor3 = textColor
            tabIcon.TextColor3 = textColor
        end)
        
        tabButton.MouseEnter:Connect(function()
            if tabPage.Visible == false then
                tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                tabTitle.TextColor3 = textColor
                tabIcon.TextColor3 = textColor
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if tabPage.Visible == false then
                tabButton.BackgroundColor3 = elementColor
                tabTitle.TextColor3 = subTextColor
                tabIcon.TextColor3 = subTextColor
            end
        end)
        
        return tabPage
    end
    
    function library:CreateSection(parent, name)
        local section = Instance.new("Frame")
        section.Name = name .. "Section"
        section.Size = UDim2.new(1, 0, 0, 30)
        section.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        section.BorderSizePixel = 0
        section.Parent = parent
        
        local sectionCorner = Instance.new("UICorner")
        sectionCorner.CornerRadius = UDim.new(0, 6)
        sectionCorner.Parent = section
        
        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Name = "Title"
        sectionTitle.Size = UDim2.new(1, -20, 1, 0)
        sectionTitle.Position = UDim2.new(0, 10, 0, 0)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Text = name
        sectionTitle.TextColor3 = textColor
        sectionTitle.TextSize = 12
        sectionTitle.Font = Enum.Font.GothamBold
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        sectionTitle.Parent = section
        
        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Size = UDim2.new(1, -20, 0, 0)
        content.Position = UDim2.new(0, 10, 0, 35)
        content.BackgroundTransparency = 1
        content.Parent = section
        
        local contentList = Instance.new("UIListLayout")
        contentList.Parent = content
        contentList.Padding = UDim.new(0, 8)
        
        return content
    end
    
    function library:CreateToggle(parent, config)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = config.Name .. "Toggle"
        toggleFrame.Size = UDim2.new(1, 0, 0, 25)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = parent
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "Button"
        toggleButton.Size = UDim2.new(0, 40, 0, 20)
        toggleButton.Position = UDim2.new(1, -45, 0, 2)
        toggleButton.BackgroundColor3 = config.Default and accentColor or Color3.fromRGB(60, 60, 65)
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = ""
        toggleButton.Parent = toggleFrame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 10)
        toggleCorner.Parent = toggleButton
        
        local toggleCircle = Instance.new("Frame")
        toggleCircle.Name = "Circle"
        toggleCircle.Size = UDim2.new(0, 16, 0, 16)
        toggleCircle.Position = config.Default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        toggleCircle.BorderSizePixel = 0
        toggleCircle.Parent = toggleButton
        
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(0, 8)
        circleCorner.Parent = toggleCircle
        
        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Name = "Label"
        toggleLabel.Size = UDim2.new(1, -50, 1, 0)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Text = config.Name
        toggleLabel.TextColor3 = textColor
        toggleLabel.TextSize = 12
        toggleLabel.Font = Enum.Font.Gotham
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.Parent = toggleFrame
        
        local state = config.Default or false
        
        local function updateToggle()
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            if state then
                local tween1 = TweenService:Create(toggleButton, tweenInfo, {BackgroundColor3 = accentColor})
                local tween2 = TweenService:Create(toggleCircle, tweenInfo, {Position = UDim2.new(1, -18, 0.5, -8)})
                tween1:Play()
                tween2:Play()
            else
                local tween1 = TweenService:Create(toggleButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 60, 65)})
                local tween2 = TweenService:Create(toggleCircle, tweenInfo, {Position = UDim2.new(0, 2, 0.5, -8)})
                tween1:Play()
                tween2:Play()
            end
        end
        
        toggleButton.MouseButton1Click:Connect(function()
            state = not state
            updateToggle()
            if config.Callback then
                config.Callback(state)
            end
        end)
        
        updateToggle()
        
        return {
            Set = function(value)
                state = value
                updateToggle()
            end,
            Get = function()
                return state
            end
        }
    end
    
    function library:CreateSlider(parent, config)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = config.Name .. "Slider"
        sliderFrame.Size = UDim2.new(1, 0, 0, 50)
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Parent = parent
        
        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Name = "Label"
        sliderLabel.Size = UDim2.new(1, 0, 0, 20)
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.Text = config.Name
        sliderLabel.TextColor3 = textColor
        sliderLabel.TextSize = 12
        sliderLabel.Font = Enum.Font.Gotham
        sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        sliderLabel.Parent = sliderFrame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Name = "Value"
        valueLabel.Size = UDim2.new(0, 60, 0, 20)
        valueLabel.Position = UDim2.new(1, -60, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(config.Default)
        valueLabel.TextColor3 = subTextColor
        valueLabel.TextSize = 12
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = sliderFrame
        
        local sliderBar = Instance.new("Frame")
        sliderBar.Name = "Bar"
        sliderBar.Size = UDim2.new(1, 0, 0, 4)
        sliderBar.Position = UDim2.new(0, 0, 1, -15)
        sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        sliderBar.BorderSizePixel = 0
        sliderBar.Parent = sliderFrame
        
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 2)
        barCorner.Parent = sliderBar
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Name = "Fill"
        sliderFill.Size = UDim2.new((config.Default - config.Min) / (config.Max - config.Min), 0, 1, 0)
        sliderFill.BackgroundColor3 = accentColor
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBar
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 2)
        fillCorner.Parent = sliderFill
        
        local sliderDot = Instance.new("Frame")
        sliderDot.Name = "Dot"
        sliderDot.Size = UDim2.new(0, 12, 0, 12)
        sliderDot.Position = UDim2.new((config.Default - config.Min) / (config.Max - config.Min), -6, 0.5, -6)
        sliderDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderDot.BorderSizePixel = 0
        sliderDot.Parent = sliderBar
        
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(0, 6)
        dotCorner.Parent = sliderDot
        
        local dragging = false
        local value = config.Default
        
        local function updateSlider(mouseX)
            local relativeX = math.clamp(mouseX - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
            local percentage = relativeX / sliderBar.AbsoluteSize.X
            value = math.floor(config.Min + (config.Max - config.Min) * percentage)
            
            if config.Suffix then
                valueLabel.Text = tostring(value) .. config.Suffix
            else
                valueLabel.Text = tostring(value)
            end
            
            sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            sliderDot.Position = UDim2.new(percentage, -6, 0.5, -6)
            
            if config.Callback then
                config.Callback(value)
            end
        end
        
        sliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input.Position.X)
            end
        end)
        
        sliderBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input.Position.X)
            end
        end)
        
        return {
            Set = function(newValue)
                value = math.clamp(newValue, config.Min, config.Max)
                local percentage = (value - config.Min) / (config.Max - config.Min)
                
                if config.Suffix then
                    valueLabel.Text = tostring(value) .. config.Suffix
                else
                    valueLabel.Text = tostring(value)
                end
                
                sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                sliderDot.Position = UDim2.new(percentage, -6, 0.5, -6)
            end,
            Get = function()
                return value
            end
        }
    end
    
    function library:CreateDropdown(parent, config)
        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Name = config.Name .. "Dropdown"
        dropdownFrame.Size = UDim2.new(1, 0, 0, 30)
        dropdownFrame.BackgroundTransparency = 1
        dropdownFrame.Parent = parent
        
        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Name = "Button"
        dropdownButton.Size = UDim2.new(1, 0, 0, 30)
        dropdownButton.BackgroundColor3 = elementColor
        dropdownButton.BorderSizePixel = 0
        dropdownButton.Text = ""
        dropdownButton.Parent = dropdownFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = dropdownButton
        
        local dropdownLabel = Instance.new("TextLabel")
        dropdownLabel.Name = "Label"
        dropdownLabel.Size = UDim2.new(1, -30, 1, 0)
        dropdownLabel.Position = UDim2.new(0, 10, 0, 0)
        dropdownLabel.BackgroundTransparency = 1
        dropdownLabel.Text = config.Name .. ": " .. config.Default
        dropdownLabel.TextColor3 = textColor
        dropdownLabel.TextSize = 12
        dropdownLabel.Font = Enum.Font.Gotham
        dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        dropdownLabel.Parent = dropdownFrame
        
        local dropdownIcon = Instance.new("TextLabel")
        dropdownIcon.Name = "Icon"
        dropdownIcon.Size = UDim2.new(0, 20, 0, 20)
        dropdownIcon.Position = UDim2.new(1, -25, 0.5, -10)
        dropdownIcon.BackgroundTransparency = 1
        dropdownIcon.Text = "▼"
        dropdownIcon.TextColor3 = subTextColor
        dropdownIcon.TextSize = 12
        dropdownIcon.Font = Enum.Font.GothamBold
        dropdownIcon.Parent = dropdownFrame
        
        local dropdownList = Instance.new("ScrollingFrame")
        dropdownList.Name = "List"
        dropdownList.Size = UDim2.new(1, 0, 0, 0)
        dropdownList.Position = UDim2.new(0, 0, 1, 5)
        dropdownList.BackgroundColor3 = elementColor
        dropdownList.BorderSizePixel = 0
        dropdownList.ScrollBarThickness = 3
        dropdownList.ScrollBarImageColor3 = accentColor
        dropdownList.Visible = false
        dropdownList.ClipsDescendants = true
        dropdownList.Parent = dropdownFrame
        
        local listCorner = Instance.new("UICorner")
        listCorner.CornerRadius = UDim.new(0, 6)
        listCorner.Parent = dropdownList
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Parent = dropdownList
        
        for _, option in pairs(config.Options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Name = option
            optionButton.Size = UDim2.new(1, 0, 0, 25)
            optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            optionButton.BorderSizePixel = 0
            optionButton.Text = option
            optionButton.TextColor3 = textColor
            optionButton.TextSize = 11
            optionButton.Font = Enum.Font.Gotham
            optionButton.Parent = dropdownList
            
            local optionCorner = Instance.new("UICorner")
            optionCorner.CornerRadius = UDim.new(0, 4)
            optionCorner.Parent = optionButton
            
            optionButton.MouseButton1Click:Connect(function()
                dropdownLabel.Text = config.Name .. ": " .. option
                dropdownList.Visible = false
                dropdownIcon.Text = "▼"
                if config.Callback then
                    config.Callback(option)
                end
            end)
            
            optionButton.MouseEnter:Connect(function()
                optionButton.BackgroundColor3 = accentColor
            end)
            
            optionButton.MouseLeave:Connect(function()
                optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            end)
        end
        
        local open = false
        
        dropdownButton.MouseButton1Click:Connect(function()
            open = not open
            dropdownList.Visible = open
            
            if open then
                dropdownList.Size = UDim2.new(1, 0, 0, math.min(#config.Options * 30 + 5, 150))
                dropdownIcon.Text = "▲"
            else
                dropdownList.Size = UDim2.new(1, 0, 0, 0)
                dropdownIcon.Text = "▼"
            end
        end)
        
        return {
            Set = function(option)
                if table.find(config.Options, option) then
                    dropdownLabel.Text = config.Name .. ": " .. option
                    if config.Callback then
                        config.Callback(option)
                    end
                end
            end,
            Get = function()
                return dropdownLabel.Text:gsub(config.Name .. ": ", "")
            end
        }
    end
    
    function library:CreateButton(parent, config)
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Name = config.Name .. "Button"
        buttonFrame.Size = UDim2.new(1, 0, 0, 30)
        buttonFrame.BackgroundTransparency = 1
        buttonFrame.Parent = parent
        
        local button = Instance.new("TextButton")
        button.Name = "Button"
        button.Size = UDim2.new(1, 0, 0, 30)
        button.BackgroundColor3 = accentColor
        button.BorderSizePixel = 0
        button.Text = config.Name
        button.TextColor3 = textColor
        button.TextSize = 12
        button.Font = Enum.Font.GothamSemibold
        button.Parent = buttonFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button
        
        button.MouseButton1Click:Connect(function()
            if config.Callback then
                config.Callback()
            end
        end)
        
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(0, 190, 255)
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = accentColor
        end)
    end
    
    -- Selecionar primeira aba
    task.spawn(function()
        wait(0.1)
        local firstTab = sidebar:FindFirstChildOfClass("TextButton")
        if firstTab then
            firstTab:MouseButton1Click()
        end
    end)
    
    return library
end

-- Criar interface
local ui = library:CreateWindow("Ultimate Hack")

-- Criar abas
local aimTab = ui:CreateTab("AIMBOT", "🎯")
local visualTab = ui:CreateTab("VISUALS", "👁")
local moveTab = ui:CreateTab("MOVEMENT", "🏃")
local miscTab = ui:CreateTab("MISC", "⚙")

-- ABA AIMBOT
local aimSection = ui:CreateSection(aimTab, "AIMBOT")
local silentSection = ui:CreateSection(aimTab, "SILENT AIM")
local hitboxSection = ui:CreateSection(aimTab, "HITBOX")

-- Aimbot toggles
local aimToggle = ui:CreateToggle(aimSection, {
    Name = "Enable Aimbot",
    Default = false,
    Callback = function(state)
        Settings.Aim.Enabled = state
    end
})

local silentToggle = ui:CreateToggle(silentSection, {
    Name = "Enable Silent Aim",
    Default = false,
    Callback = function(state)
        Settings.Aim.Silent = state
    end
})

local teamToggle = ui:CreateToggle(silentSection, {
    Name = "Team Check",
    Default = true,
    Callback = function(state)
        Settings.Aim.TeamCheck = state
    end
})

local hitboxToggle = ui:CreateToggle(hitboxSection, {
    Name = "Hitbox Expander",
    Default = false,
    Callback = function(state)
        Settings.Combat.HitboxExpander = state
    end
})

local triggerToggle = ui:CreateToggle(aimSection, {
    Name = "Trigger Bot",
    Default = false,
    Callback = function(state)
        Settings.Combat.TriggerBot = state
    end
})

-- Dropdowns
local methodDropdown = ui:CreateDropdown(silentSection, {
    Name = "Method",
    Default = "Raycast",
    Options = {"Raycast", "Mouse", "Camera"},
    Callback = function(option)
        Settings.Aim.Method = option
    end
})

local partDropdown = ui:CreateDropdown(silentSection, {
    Name = "Target Part",
    Default = "Head",
    Options = {"Head", "HumanoidRootPart", "Torso", "Random"},
    Callback = function(option)
        Settings.Aim.TargetPart = option
    end
})

-- Sliders
local hitChanceSlider = ui:CreateSlider(silentSection, {
    Name = "Hit Chance %",
    Min = 0,
    Max = 100,
    Default = 100,
    Suffix = "%",
    Callback = function(value)
        Settings.Aim.HitChance = value
    end
})

local fovSlider = ui:CreateSlider(silentSection, {
    Name = "FOV Radius",
    Min = 0,
    Max = 500,
    Default = 250,
    Suffix = "px",
    Callback = function(value)
        Settings.Aim.FOV = value
    end
})

local smoothSlider = ui:CreateSlider(silentSection, {
    Name = "Smoothing",
    Min = 0,
    Max = 1,
    Default = 0,
    Suffix = "",
    Callback = function(value)
        Settings.Aim.Smoothing = value
    end
})

local predictSlider = ui:CreateSlider(silentSection, {
    Name = "Prediction",
    Min = 0,
    Max = 50,
    Default = 12,
    Suffix = "ms",
    Callback = function(value)
        Settings.Aim.Prediction = value
    end
})

local hitboxSlider = ui:CreateSlider(hitboxSection, {
    Name = "Hitbox Size",
    Min = 1,
    Max = 3,
    Default = 1.5,
    Suffix = "x",
    Callback = function(value)
        Settings.Combat.HitboxSize = value
    end
})

local delaySlider = ui:CreateSlider(aimSection, {
    Name = "Trigger Delay",
    Min = 0.05,
    Max = 1,
    Default = 0.1,
    Suffix = "s",
    Callback = function(value)
        Settings.Combat.TriggerDelay = value
    end
})

-- ABA VISUALS
local espSection = ui:CreateSection(visualTab, "ESP")
local chamsSection = ui:CreateSection(visualTab, "CHAMS")
local crossSection = ui:CreateSection(visualTab, "CROSSHAIR")

-- ESP toggles
local espToggle = ui:CreateToggle(espSection, {
    Name = "Enable ESP",
    Default = false,
    Callback = function(state)
        Settings.Visuals.ESP = state
    end
})

local boxToggle = ui:CreateToggle(espSection, {
    Name = "Box ESP",
    Default = false,
    Callback = function(state)
        Settings.Visuals.Box = state
    end
})

local tracerToggle = ui:CreateToggle(espSection, {
    Name = "Tracers",
    Default = false,
    Callback = function(state)
        Settings.Visuals.Tracers = state
    end
})

local nameToggle = ui:CreateToggle(espSection, {
    Name = "Show Names",
    Default = true,
    Callback = function(state)
        Settings.Visuals.ShowNames = state
    end
})

local healthToggle = ui:CreateToggle(espSection, {
    Name = "Show Health",
    Default = true,
    Callback = function(state)
        Settings.Visuals.ShowHealth = state
    end
})

local distanceToggle = ui:CreateToggle(espSection, {
    Name = "Show Distance",
    Default = true,
    Callback = function(state)
        Settings.Visuals.ShowDistance = state
    end
})

local teamVizToggle = ui:CreateToggle(espSection, {
    Name = "Team Check",
    Default = true,
    Callback = function(state)
        Settings.Visuals.TeamCheck = state
    end
})

local chamToggle = ui:CreateToggle(chamsSection, {
    Name = "Enable Chams",
    Default = false,
    Callback = function(state)
        Settings.Visuals.Chams = state
    end
})

local crossToggle = ui:CreateToggle(crossSection, {
    Name = "Crosshair",
    Default = false,
    Callback = function(state)
        Settings.Misc.Crosshair = state
    end
})

local fullToggle = ui:CreateToggle(visualTab, {
    Name = "Full Bright",
    Default = false,
    Callback = function(state)
        Settings.Misc.FullBright = state
    end
})

local fovToggle = ui:CreateToggle(visualTab, {
    Name = "FOV Changer",
    Default = false,
    Callback = function(state)
        Settings.Misc.FOVChanger = state
    end
})

local fovSlider2 = ui:CreateSlider(visualTab, {
    Name = "Custom FOV",
    Min = 70,
    Max = 120,
    Default = 90,
    Suffix = "°",
    Callback = function(value)
        Settings.Misc.CustomFOV = value
    end
})

-- ABA MOVEMENT
local flySection = ui:CreateSection(moveTab, "FLY")
local speedSection = ui:CreateSection(moveTab, "SPEED")
local jumpSection = ui:CreateSection(moveTab, "JUMP")
local noclipSection = ui:CreateSection(moveTab, "NOCLIP")

-- Movement toggles
local flyToggle = ui:CreateToggle(flySection, {
    Name = "Enable Fly",
    Default = false,
    Callback = function(state)
        Settings.Movement.Fly = state
    end
})

local speedToggle = ui:CreateToggle(speedSection, {
    Name = "Speed Hack",
    Default = false,
    Callback = function(state)
        Settings.Movement.SpeedHack = state
    end
})

local jumpToggle = ui:CreateToggle(jumpSection, {
    Name = "High Jump",
    Default = false,
    Callback = function(state)
        Settings.Movement.HighJump = state
    end
})

local noclipToggle = ui:CreateToggle(noclipSection, {
    Name = "NoClip",
    Default = false,
    Callback = function(state)
        Settings.Movement.NoClip = state
    end
})

local infJumpToggle = ui:CreateToggle(jumpSection, {
    Name = "Infinite Jump",
    Default = false,
    Callback = function(state)
        Settings.Movement.InfiniteJump = state
    end
})

-- Sliders
local flySlider = ui:CreateSlider(flySection, {
    Name = "Fly Speed",
    Min = 1,
    Max = 200,
    Default = 50,
    Suffix = " studs/s",
    Callback = function(value)
        Settings.Movement.FlySpeed = value
    end
})

local speedSlider = ui:CreateSlider(speedSection, {
    Name = "Speed Amount",
    Min = 16,
    Max = 200,
    Default = 30,
    Suffix = " speed",
    Callback = function(value)
        Settings.Movement.SpeedAmount = value
    end
})

local jumpSlider = ui:CreateSlider(jumpSection, {
    Name = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 100,
    Suffix = " power",
    Callback = function(value)
        Settings.Movement.JumpPower = value
    end
})

-- Dropdown para tecla de fly
local keyDropdown = ui:CreateDropdown(flySection, {
    Name = "Fly Key",
    Default = "E",
    Options = {"E", "Q", "F", "X", "C", "V", "LeftShift", "Space"},
    Callback = function(option)
        Settings.Movement.FlyKey = Enum.KeyCode[option]
    end
})

-- ABA MISC
local combatSection = ui:CreateSection(miscTab, "COMBAT")
local utilitySection = ui:CreateSection(miscTab, "UTILITY")
local serverSection = ui:CreateSection(miscTab, "SERVER")

-- Misc toggles
local noRecoilToggle = ui:CreateToggle(combatSection, {
    Name = "No Recoil",
    Default = false,
    Callback = function(state)
        Settings.Misc.NoRecoil = state
    end
})

local noSpreadToggle = ui:CreateToggle(combatSection, {
    Name = "No Spread",
    Default = false,
    Callback = function(state)
        Settings.Misc.NoSpread = state
    end
})

local autoToggle = ui:CreateToggle(combatSection, {
    Name = "Auto Shoot",
    Default = false,
    Callback = function(state)
        Settings.Combat.AutoShoot = state
    end
})

local wallToggle = ui:CreateToggle(combatSection, {
    Name = "Wall Bang",
    Default = false,
    Callback = function(state)
        Settings.Combat.WallBang = state
    end
})

local afkToggle = ui:CreateToggle(utilitySection, {
    Name = "Anti-AFK",
    Default = false,
    Callback = function(state)
        Settings.Misc.AntiAFK = state
    end
})

-- Botões
ui:CreateButton(serverSection, {
    Name = "Server Hop",
    Callback = function()
        -- Server hop function
    end
})

ui:CreateButton(serverSection, {
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
})

ui:CreateButton(utilitySection, {
    Name = "Kill All Bots",
    Callback = function()
        -- Kill all function
    end
})

ui:CreateButton(miscTab, {
    Name = "Destroy UI",
    Callback = function()
        game.CoreGui:FindFirstChild("BloxStrikeUI"):Destroy()
    end
})

-- FUNCIONALIDADES DO HACK

-- Sistema ESP
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESPFolder"
ESPFolder.Parent = Camera

local function createESP(player)
    if player == LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name .. "_ESP"
    highlight.FillColor = Settings.Visuals.HighlightColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Enabled = Settings.Visuals.ESP
    highlight.Adornee = character
    highlight.Parent = ESPFolder
    
    -- Billboard para informações
    local billboard = Instance.new("BillboardGui")
    billboard.Name = player.Name .. "_Info"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = Settings.Visuals.ESP and Settings.Visuals.ShowNames
    billboard.Parent = ESPFolder
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = player.Name
    textLabel.TextColor3 = Settings.Visuals.HighlightColor
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Parent = billboard
    
    if character:FindFirstChild("Head") then
        billboard.Adornee = character.Head
    end
    
    return {Highlight = highlight, Billboard = billboard}
end

-- Setup ESP inicial
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if player ~= LocalPlayer then
            createESP(player)
        end
    end)
end)

-- Sistema Fly
local function toggleFly()
    if Settings.Movement.Fly then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBodyVelocity.P = 1250
            flyBodyVelocity.Parent = rootPart
            
            local flyConnection
            flyConnection = RunService.Heartbeat:Connect(function()
                if not character or not character.Parent then
                    flyConnection:Disconnect()
                    return
                end
                
                local cam = Workspace.CurrentCamera
                local moveDirection = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Settings.Movement.FlyKey) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                
                if moveDirection.Magnitude > 0 then
                    flyBodyVelocity.Velocity = moveDirection.Unit * Settings.Movement.FlySpeed
                else
                    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
            end)
        end
    else
        if flyBodyVelocity then
            flyBodyVelocity:Destroy()
            flyBodyVelocity = nil
        end
    end
end

-- Conexões para atualizar sistemas
RunService.Heartbeat:Connect(function()
    -- Atualizar FOV
    if Settings.Misc.FOVChanger then
        Camera.FieldOfView = Settings.Misc.CustomFOV
    end
    
    -- Atualizar Full Bright
    if Settings.Misc.FullBright then
        game.Lighting.Brightness = 2
        game.Lighting.ClockTime = 14
        game.Lighting.GlobalShadows = false
    end
    
    -- Atualizar ESP
    for _, child in pairs(ESPFolder:GetChildren()) do
        if child:IsA("Highlight") then
            child.Enabled = Settings.Visuals.ESP
        elseif child:IsA("BillboardGui") then
            child.Enabled = Settings.Visuals.ESP and Settings.Visuals.ShowNames
        end
    end
    
    -- Atualizar Fly
    toggleFly()
    
    -- Atualizar Speed
    if Settings.Movement.SpeedHack then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Settings.Movement.SpeedAmount
            end
        end
    end
    
    -- Atualizar Jump
    if Settings.Movement.HighJump then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = Settings.Movement.JumpPower
            end
        end
    end
    
    -- NoClip
    if Settings.Movement.NoClip then
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Sistema Trigger Bot
local lastTrigger = 0
RunService.Heartbeat:Connect(function()
    if Settings.Combat.TriggerBot then
        local now = tick()
        if now - lastTrigger >= Settings.Combat.TriggerDelay then
            -- Encontrar alvo
            local closestPlayer = nil
            local closestDistance = math.huge
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    local head = player.Character:FindFirstChild("Head")
                    
                    if humanoid and humanoid.Health > 0 and head then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - 
                                            Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                            
                            if distance < closestDistance and distance < Settings.Aim.FOV then
                                closestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
            
            -- Atirar
            if closestPlayer then
                mouse1press()
                task.wait(0.05)
                mouse1release()
                lastTrigger = now
            end
        end
    end
end)

-- Sistema Hitbox Expander
local expandedHitboxes = {}
RunService.Heartbeat:Connect(function()
    if Settings.Combat.HitboxExpander then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                
                if not expandedHitboxes[player] then
                    expandedHitboxes[player] = {}
                end
                
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") and not expandedHitboxes[player][part] then
                        local originalSize = part.Size
                        expandedHitboxes[player][part] = originalSize
                        
                        part.Size = originalSize * Settings.Combat.HitboxSize
                        part.Transparency = 0.5
                        part.Color = Color3.fromRGB(255, 0, 0)
                    end
                end
            end
        end
    else
        -- Restaurar hitboxes
        for player, parts in pairs(expandedHitboxes) do
            if player and player.Character then
                for part, originalSize in pairs(parts) do
                    if part and part.Parent then
                        part.Size = originalSize
                        part.Transparency = 0
                        part.Color = Color3.fromRGB(255, 255, 255)
                    end
                end
            end
        end
        expandedHitboxes = {}
    end
end)

-- Sistema Anti-AFK
if Settings.Misc.AntiAFK then
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local antiAFKConnection
    
    antiAFKConnection = RunService.Heartbeat:Connect(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
        task.wait(1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
    end)
end

-- Notificação inicial
task.wait(2)
local notification = Instance.new("ScreenGui")
notification.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 100)
frame.Position = UDim2.new(0.5, -150, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Parent = notification

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "BloxStrike Hack 🎯\nLoaded Successfully!\nPress RightShift to toggle"
label.TextColor3 = Color3.fromRGB(0, 170, 255)
label.TextSize = 14
label.Font = Enum.Font.GothamBold
label.TextStrokeTransparency = 0.5
label.Parent = frame

task.wait(3)
notification:Destroy()

-- Toggle da UI com RightShift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightShift then
        local ui = game.CoreGui:FindFirstChild("BloxStrikeUI")
        if ui then
            ui.Enabled = not ui.Enabled
        end
    end
end)

print("BloxStrike Ultimate Hack loaded!")
print("UI created with custom design")
print("Press RightShift to toggle menu")