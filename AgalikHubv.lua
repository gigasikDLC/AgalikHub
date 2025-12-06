-- AGALIK HUB v5.1 | MOBILE FIX
-- Автоматическое определение устройства и адаптация

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer

-- ============================================
-- АВТОМАТИЧЕСКОЕ ОПРЕДЕЛЕНИЕ УСТРОЙСТВА
-- ============================================

local isMobile = UIS.TouchEnabled
local isDesktop = not isMobile
local screenSize = workspace.CurrentCamera.ViewportSize

print("=" .. string.rep("=", 50))
print("📱 DEVICE DETECTION:")
print("   Platform: " .. (isMobile and "MOBILE 📱" or "PC 🖥️"))
print("   Screen: " .. math.floor(screenSize.X) .. "x" .. math.floor(screenSize.Y))
print("=" .. string.rep("=", 50))

-- ============================================
-- АДАПТИВНЫЕ НАСТРОЙКИ
-- ============================================

local settings = {
    -- Размеры для разных устройств
    pc = {
        tutorialSize = UDim2.new(0, 500, 0, 450),
        tutorialPos = UDim2.new(0.5, -250, 0.5, -225),
        menuSize = UDim2.new(0, 450, 0, 400),
        menuPos = UDim2.new(0.5, -225, 0.5, -200),
        openBtnSize = UDim2.new(0, 50, 0, 50),
        openBtnPos = UDim2.new(1, -60, 0, 20),
        fontSize = {
            title = 16,
            normal = 14,
            small = 11
        },
        buttonHeight = 60,
        sidebarWidth = 100
    },
    
    mobile = {
        tutorialSize = UDim2.new(0.9, 0, 0.85, 0),
        tutorialPos = UDim2.new(0.5, 0, 0.5, 0),
        menuSize = UDim2.new(0.9, 0, 0.8, 0),
        menuPos = UDim2.new(0.5, 0, 0.5, 0),
        openBtnSize = UDim2.new(0, 70, 0, 70),
        openBtnPos = UDim2.new(1, -80, 0, 30),
        fontSize = {
            title = 18,
            normal = 16,
            small = 13
        },
        buttonHeight = 70,
        sidebarWidth = 120
    }
}

-- Выбираем настройки для устройства
local deviceSettings = isMobile and settings.mobile or settings.pc

-- Тема
local theme = {
    main = Color3.fromRGB(25, 25, 35),
    secondary = Color3.fromRGB(35, 35, 45),
    accent = Color3.fromRGB(0, 150, 255),
    text = Color3.fromRGB(240, 240, 240),
    subtext = Color3.fromRGB(180, 180, 200),
    success = Color3.fromRGB(0, 200, 83),
    danger = Color3.fromRGB(255, 80, 90)
}

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AgalikHub"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

-- Для мобильных - Fullscreen адаптация
if isMobile then
    screenGui.IgnoreGuiInset = true
end

if gethui then
    screenGui.Parent = gethui()
else
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- ============================================
-- АДАПТИВНАЯ ФУНКЦИЯ СОЗДАНИЯ ТЕКСТА
-- ============================================

local function createTextLabel(props)
    local textLabel = Instance.new("TextLabel")
    
    -- Основные свойства
    textLabel.Size = props.Size or UDim2.new(1, 0, 0, 30)
    textLabel.Position = props.Position or UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = props.BackgroundTransparency or 1
    textLabel.Text = props.Text or ""
    textLabel.TextColor3 = props.TextColor3 or theme.text
    textLabel.Font = props.Font or Enum.Font.Gotham
    
    -- Адаптивный размер шрифта
    if props.TextSize then
        textLabel.TextSize = props.TextSize
    elseif props.Type == "title" then
        textLabel.TextSize = deviceSettings.fontSize.title
    elseif props.Type == "small" then
        textLabel.TextSize = deviceSettings.fontSize.small
    else
        textLabel.TextSize = deviceSettings.fontSize.normal
    end
    
    -- Дополнительные свойства
    if props.TextXAlignment then
        textLabel.TextXAlignment = props.TextXAlignment
    end
    
    if props.TextWrapped ~= nil then
        textLabel.TextWrapped = props.TextWrapped
    end
    
    if props.TextScaled ~= nil then
        textLabel.TextScaled = props.TextScaled
        if isMobile then
            textLabel.TextScaled = true
        end
    end
    
    if props.AnchorPoint then
        textLabel.AnchorPoint = props.AnchorPoint
    end
    
    return textLabel
end

-- ============================================
-- АДАПТИВНАЯ ФУНКЦИЯ СОЗДАНИЯ КНОПКИ
-- ============================================

local function createTextButton(props)
    local textButton = Instance.new("TextButton")
    
    -- Основные свойства
    textButton.Size = props.Size
    textButton.Position = props.Position
    textButton.BackgroundColor3 = props.BackgroundColor3 or theme.secondary
    textButton.BorderSizePixel = props.BorderSizePixel or 0
    textButton.AutoButtonColor = props.AutoButtonColor or false
    textButton.Text = props.Text or ""
    textButton.TextColor3 = props.TextColor3 or theme.text
    textButton.Font = props.Font or Enum.Font.Gotham
    
    -- Адаптивный размер шрифта
    if props.TextSize then
        textButton.TextSize = props.TextSize
    else
        textButton.TextSize = deviceSettings.fontSize.normal
    end
    
    if isMobile and props.TextScaled ~= false then
        textButton.TextScaled = true
    end
    
    -- Дополнительные свойства
    if props.AnchorPoint then
        textButton.AnchorPoint = props.AnchorPoint
    end
    
    return textButton
end

-- ============================================
-- ИНСТРУКЦИЯ ПРИ ЗАПУСКЕ (АДАПТИВНАЯ)
-- ============================================

local tutorialFrame = Instance.new("Frame")
tutorialFrame.Name = "Tutorial"
tutorialFrame.Size = deviceSettings.tutorialSize
tutorialFrame.Position = deviceSettings.tutorialPos
tutorialFrame.AnchorPoint = Vector2.new(0.5, 0.5)
tutorialFrame.BackgroundColor3 = theme.main
tutorialFrame.BorderSizePixel = 1
tutorialFrame.BorderColor3 = Color3.fromRGB(50, 50, 70)
tutorialFrame.ClipsDescendants = true
tutorialFrame.Visible = true
tutorialFrame.Parent = screenGui

-- Заголовок инструкции
local tutorialTitle = createTextButton({
    Size = UDim2.new(1, 0, 0, isMobile and 70 or 60),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = theme.secondary,
    Text = "AGALIK HUB - WELCOME",
    TextColor3 = theme.accent,
    Font = Enum.Font.GothamBold,
    TextSize = isMobile and 22 or 20,
    AutoButtonColor = false
})
tutorialTitle.Parent = tutorialFrame

-- Вопрос о языке
local languageQuestion = createTextLabel({
    Size = UDim2.new(1, -40, 0, isMobile and 70 : 50),
    Position = UDim2.new(0, 20, 0, isMobile and 80 : 80),
    Text = "Please select your language / Пожалуйста, выберите язык:",
    TextColor3 = theme.text,
    Type = "normal",
    TextWrapped = true
})
languageQuestion.Parent = tutorialFrame

-- Кнопка English
local englishBtn = createTextButton({
    Size = UDim2.new(isMobile and 0.45 or 0, isMobile and 0 or 200, 0, isMobile and 50 : 40),
    Position = UDim2.new(isMobile and 0.025 or 0.5, isMobile and 0 or -220, 0, isMobile and 170 : 150),
    BackgroundColor3 = theme.accent,
    Text = "🇺🇸 ENGLISH",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = isMobile and 18 : 16
})
englishBtn.Parent = tutorialFrame

-- Кнопка Russian
local russianBtn = createTextButton({
    Size = UDim2.new(isMobile and 0.45 or 0, isMobile and 0 or 200, 0, isMobile and 50 : 40),
    Position = UDim2.new(isMobile and 0.525 or 0.5, isMobile and 0 or 20, 0, isMobile and 170 : 150),
    BackgroundColor3 = Color3.fromRGB(255, 50, 50),
    Text = "🇷🇺 RUSSIAN",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = isMobile and 18 : 16
})
russianBtn.Parent = tutorialFrame

-- Область с инструкцией
local tutorialContent = Instance.new("ScrollingFrame")
tutorialContent.Name = "Content"
tutorialContent.Size = UDim2.new(1, -40, 0, isMobile and 250 : 200)
tutorialContent.Position = UDim2.new(0, 20, 0, isMobile and 240 : 210)
tutorialContent.BackgroundColor3 = theme.secondary
tutorialContent.BorderSizePixel = 0
tutorialContent.ScrollBarThickness = isMobile and 8 : 6
tutorialContent.ScrollBarImageColor3 = theme.accent
tutorialContent.CanvasSize = UDim2.new(0, 0, 0, 0)
tutorialContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
tutorialContent.Visible = false
tutorialContent.Parent = tutorialFrame

local tutorialLayout = Instance.new("UIListLayout")
tutorialLayout.Padding = UDim.new(0, isMobile and 15 : 10)
tutorialLayout.SortOrder = Enum.SortOrder.LayoutOrder
tutorialLayout.Parent = tutorialContent

local tutorialPadding = Instance.new("UIPadding")
tutorialPadding.PaddingTop = UDim.new(0, isMobile and 20 : 15)
tutorialPadding.PaddingLeft = UDim.new(0, isMobile and 20 : 15)
tutorialPadding.PaddingRight = UDim.new(0, isMobile and 20 : 15)
tutorialPadding.Parent = tutorialContent

-- Кнопка принятия (адаптивная)
local acceptBtn = createTextButton({
    Size = UDim2.new(0, isMobile and 140 : 120, 0, isMobile and 50 : 40),
    Position = UDim2.new(1, isMobile and -150 : -140, 1, isMobile and -70 : -60),
    BackgroundColor3 = theme.success,
    Text = "ACCEPT",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = isMobile and 18 : 16
})
acceptBtn.Visible = false
acceptBtn.Parent = tutorialFrame

-- ============================================
-- ОСНОВНОЕ МЕНЮ (АДАПТИВНОЕ)
-- ============================================

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = deviceSettings.menuSize
mainFrame.Position = deviceSettings.menuPos
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = theme.main
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(50, 50, 70)
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Панель заголовка
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, isMobile and 50 : 40)
titleBar.BackgroundColor3 = theme.secondary
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local title = createTextLabel({
    Size = UDim2.new(1, isMobile and -90 : -80, 1, 0),
    Position = UDim2.new(0, isMobile and 15 : 10, 0, 0),
    Text = "AGALIK HUB v5.1",
    TextColor3 = theme.accent,
    Type = "title",
    TextXAlignment = Enum.TextXAlignment.Left
})
title.Parent = titleBar

local closeBtn = createTextButton({
    Size = UDim2.new(0, isMobile and 40 : 30, 0, isMobile and 40 : 30),
    Position = UDim2.new(1, isMobile and -45 : -35, 0, isMobile and 5 : 5),
    BackgroundColor3 = Color3.fromRGB(60, 0, 0),
    Text = "×",
    TextColor3 = Color3.fromRGB(255, 100, 100),
    Font = Enum.Font.GothamBold,
    TextSize = isMobile and 22 : 18
})
closeBtn.Parent = titleBar

-- Боковая панель (адаптивная ширина)
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, deviceSettings.sidebarWidth, 1, isMobile and -50 : -40)
sidebar.Position = UDim2.new(0, 0, 0, isMobile and 50 : 40)
sidebar.BackgroundColor3 = theme.secondary
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

-- Область контента (адаптивная)
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -deviceSettings.sidebarWidth, 1, isMobile and -50 : -40)
contentFrame.Position = UDim2.new(0, deviceSettings.sidebarWidth, 0, isMobile and 50 : 40)
contentFrame.BackgroundColor3 = theme.main
contentFrame.BorderSizePixel = 0
contentFrame.ClipsDescendants = true
contentFrame.Parent = mainFrame

-- Вкладки (адаптивные)
local tabs = {
    {Name = "Player", Icon = "👤", Color = theme.accent},
    {Name = "Visual", Icon = "👁️", Color = Color3.fromRGB(0, 200, 255)},
    {Name = "Teleport", Icon = "📍", Color = Color3.fromRGB(255, 184, 0)},
    {Name = "Fun", Icon = "🎮", Color = Color3.fromRGB(235, 77, 75)},
    {Name = "Credits", Icon = "⭐", Color = Color3.fromRGB(255, 215, 0)}
}

local tabFrames = {}
local tabButtons = {}
local activeTab = 1

for i, tab in ipairs(tabs) do
    -- Кнопка вкладки (адаптивная высота)
    local tabHeight = isMobile and 55 : 45
    local tabSpacing = isMobile and 60 : 50
    
    local tabButton = createTextButton({
        Size = UDim2.new(1, 0, 0, tabHeight),
        Position = UDim2.new(0, 0, 0, (i-1) * tabSpacing),
        BackgroundColor3 = i == 1 and Color3.fromRGB(45, 45, 60) or theme.secondary,
        Text = "",
        AutoButtonColor = false
    })
    tabButton.Parent = sidebar
    
    local icon = createTextLabel({
        Size = UDim2.new(0, isMobile and 35 : 25, 0, isMobile and 35 : 25),
        Position = UDim2.new(0, isMobile and 15 : 10, 0, isMobile and 10 : 10),
        Text = tab.Icon,
        TextColor3 = i == 1 and tab.Color or theme.subtext,
        TextSize = isMobile and 22 : 16
    })
    icon.Parent = tabButton
    
    local text = createTextLabel({
        Size = UDim2.new(1, isMobile and -15 : -10, 0, isMobile and 25 : 20),
        Position = UDim2.new(0, isMobile and 8 : 5, 0, isMobile and 38 : 28),
        Text = tab.Name,
        TextColor3 = i == 1 and theme.text or theme.subtext,
        Type = "small",
        TextXAlignment = Enum.TextXAlignment.Center
    })
    text.Parent = tabButton
    
    -- Фрейм контента
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Name = tab.Name .. "Content"
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.BorderSizePixel = 0
    tabFrame.ScrollBarThickness = isMobile and 6 : 4
    tabFrame.ScrollBarImageColor3 = tab.Color
    tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabFrame.Visible = i == 1
    tabFrame.Parent = contentFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, isMobile and 12 : 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = tabFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, isMobile and 15 : 10)
    padding.PaddingLeft = UDim.new(0, isMobile and 15 : 10)
    padding.PaddingRight = UDim.new(0, isMobile and 15 : 10)
    padding.Parent = tabFrame
    
    tabButtons[i] = tabButton
    tabFrames[i] = tabFrame
    
    -- Обработчик клика
    tabButton.MouseButton1Click:Connect(function()
        if activeTab == i then return end
        
        activeTab = i
        
        for idx, btn in ipairs(tabButtons) do
            local isActive = idx == i
            
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = isActive and Color3.fromRGB(45, 45, 60) or theme.secondary
            }):Play()
            
            local icon = btn:FindFirstChildWhichIsA("TextLabel")
            if icon then
                TweenService:Create(icon, TweenInfo.new(0.2), {
                    TextColor3 = isActive and tabs[idx].Color or theme.subtext
                }):Play()
            end
            
            local text = btn:FindFirstChildWhichIsA("TextLabel", true)
            if text then
                TweenService:Create(text, TweenInfo.new(0.2), {
                    TextColor3 = isActive and theme.text or theme.subtext
                }):Play()
            end
            
            tabFrames[idx].Visible = isActive
        end
    end)
    
    -- Для мобильных - добавляем обработчик Touch
    if isMobile then
        tabButton.TouchTap:Connect(function()
            if activeTab == i then return end
            
            activeTab = i
            
            for idx, btn in ipairs(tabButtons) do
                local isActive = idx == i
                btn.BackgroundColor3 = isActive and Color3.fromRGB(45, 45, 60) or theme.secondary
                
                local icon = btn:FindFirstChildWhichIsA("TextLabel")
                if icon then
                    icon.TextColor3 = isActive and tabs[idx].Color or theme.subtext
                end
                
                local text = btn:FindFirstChildWhichIsA("TextLabel", true)
                if text then
                    text.TextColor3 = isActive and theme.text or theme.subtext
                end
                
                tabFrames[idx].Visible = isActive
            end
        end)
    end
end

-- Кнопка открытия меню (адаптивная)
local openButton = createTextButton({
    Size = deviceSettings.openBtnSize,
    Position = deviceSettings.openBtnPos,
    BackgroundColor3 = theme.accent,
    Text = "A",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = isMobile and 24 : 18,
    AnchorPoint = isMobile and Vector2.new(1, 0) or Vector2.new(0, 0)
})
openButton.Visible = false
openButton.Parent = screenGui

-- Для мобильных - делаем кнопку круглой
if isMobile then
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = openButton
end

-- ============================================
-- АДАПТИВНАЯ ФУНКЦИЯ СОЗДАНИЯ КНОПКИ ФУНКЦИИ
-- ============================================

local function createFeatureButton(parent, text, description, icon, color, isToggle)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = text .. "Button"
    buttonFrame.Size = UDim2.new(1, 0, 0, deviceSettings.buttonHeight)
    buttonFrame.BackgroundColor3 = theme.secondary
    buttonFrame.BorderSizePixel = 0
    buttonFrame.LayoutOrder = #parent:GetChildren()
    buttonFrame.Parent = parent
    
    local iconSize = isMobile and 45 : 35
    local iconLabel = createTextLabel({
        Size = UDim2.new(0, iconSize, 0, iconSize),
        Position = UDim2.new(0, isMobile and 15 : 10, 0.5, -iconSize/2),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = icon,
        TextColor3 = color,
        TextSize = isMobile and 26 : 20
    })
    iconLabel.Parent = buttonFrame
    
    local titleLabel = createTextLabel({
        Size = UDim2.new(0.6, isMobile and -70 : -50, 0, isMobile and 30 : 25),
        Position = UDim2.new(0, isMobile and 70 : 55, 0, isMobile and 12 : 10),
        Text = text .. (isToggle and " [OFF]" or ""),
        TextColor3 = theme.text,
        Type = "normal",
        TextXAlignment = Enum.TextXAlignment.Left
    })
    titleLabel.Parent = buttonFrame
    
    local descLabel = createTextLabel({
        Size = UDim2.new(0.6, isMobile and -70 : -50, 0, isMobile and 25 : 20),
        Position = UDim2.new(0, isMobile and 70 : 55, 0, isMobile and 42 : 35),
        Text = description,
        TextColor3 = theme.subtext,
        Type = "small",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    descLabel.Parent = buttonFrame
    
    local actionButton = createTextButton({
        Size = UDim2.new(0, isMobile and 90 : 70, 0, isMobile and 35 : 25),
        Position = UDim2.new(1, isMobile and -100 : -80, 0.5, isMobile and -17.5 : -12.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = isToggle and Color3.fromRGB(60, 60, 80) or color,
        Text = isToggle and "OFF" or "USE",
        TextColor3 = isToggle and theme.subtext or Color3.fromRGB(255, 255, 255),
        TextSize = isMobile and 14 : 12
    })
    actionButton.Parent = buttonFrame
    
    -- Для мобильных - добавляем TouchTap
    if isMobile then
        actionButton.TouchTap:Connect(function()
            actionButton.MouseButton1Click:Fire()
        end)
    end
    
    return actionButton, buttonFrame, titleLabel
end

-- ============================================
-- ФУНКЦИИ (вставь сюда все функции из предыдущей версии)
-- ============================================

-- Тут должен быть код всех функций:
-- NOCHIP, SPEED HACK, INVISIBLE, ESP и т.д.
-- Только используй createFeatureButton вместо старой функции

-- ============================================
-- УПРАВЛЕНИЕ 
