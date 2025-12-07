-- ============================================
-- AGALIK HUB v5.1 | ULTIMATE EDITION
-- Добавлена КРУТИЛКА, оптимизация, новые фичи
-- ============================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = Workspace.CurrentCamera

-- ============================================
-- КОНФИГУРАЦИЯ И НАСТРОЙКИ
-- ============================================

local config = {
    theme = {
        main = Color3.fromRGB(25, 25, 35),
        secondary = Color3.fromRGB(35, 35, 45),
        accent = Color3.fromRGB(0, 150, 255),
        text = Color3.fromRGB(240, 240, 240),
        subtext = Color3.fromRGB(180, 180, 200),
        success = Color3.fromRGB(0, 200, 83),
        danger = Color3.fromRGB(255, 80, 90),
        warning = Color3.fromRGB(255, 184, 0),
        purple = Color3.fromRGB(180, 80, 255),
        pink = Color3.fromRGB(255, 100, 200),
        cyan = Color3.fromRGB(0, 200, 255)
    },
    
    settings = {
        language = "english",
        menuPosition = UDim2.new(0.5, -225, 0.5, -200),
        showTutorial = true,
        soundEffects = true,
        animations = true
    }
}

-- Кэш для оптимизации
local cache = {
    character = nil,
    humanoid = nil,
    rootPart = nil,
    connections = {},
    espDrawings = {},
    espPlayers = {},
    spinning = false,
    spinSpeed = 50
}

-- ============================================
-- УТИЛИТЫ И ХЕЛПЕРЫ
-- ============================================

local Utils = {
    -- Локализация
    translations = {
        english = {
            welcome = "AGALIK HUB - WELCOME",
            selectLang = "Please select your language:",
            accept = "ACCEPT",
            
            features = {
                nochip = "NOCHIP",
                speed = "SPEED HACK",
                invisible = "INVISIBLE",
                esp = "PLAYER ESP",
                xray = "X-RAY",
                fullbright = "FULLBRIGHT",
                spinner = "SPINNER MODE",
                noclip = "NO CLIP",
                fly = "FLY MODE"
            },
            
            notifications = {
                loaded = "AGALIK HUB v5.1 LOADED",
                controls = "Press RightControl to open menu",
                enabled = "ENABLED",
                disabled = "DISABLED",
                teleported = "TELEPORTED",
                spunUp = "SPEED INCREASED",
                spunDown = "SPEED DECREASED",
                spinning = "SPINNING MODE",
                stopped = "STOPPED"
            }
        },
        
        russian = {
            welcome = "AGALIK HUB - ДОБРО ПОЖАЛОВАТЬ",
            selectLang = "Пожалуйста, выберите язык:",
            accept = "ПРИНЯТЬ",
            
            features = {
                nochip = "НОЧИП",
                speed = "СКОРОСТЬ",
                invisible = "НЕВИДИМКА",
                esp = "ИГРОКИ ESP",
                xray = "РЕНТГЕН",
                fullbright = "ЯРКОСТЬ",
                spinner = "КРУТИЛКА",
                noclip = "СКВОЗЬ СТЕНЫ",
                fly = "ПОЛЕТ"
            },
            
            notifications = {
                loaded = "AGALIK HUB v5.1 ЗАГРУЖЕН",
                controls = "Нажмите RightControl для открытия меню",
                enabled = "ВКЛЮЧЕНО",
                disabled = "ВЫКЛЮЧЕНО",
                teleported = "ТЕЛЕПОРТИРОВАН",
                spunUp = "СКОРОСТЬ УВЕЛИЧЕНА",
                spunDown = "СКОРОСТЬ УМЕНЬШЕНА",
                spinning = "РЕЖИМ ВРАЩЕНИЯ",
                stopped = "ОСТАНОВЛЕНО"
            }
        }
    },
    
    -- Получить переведенный текст
    t = function(key)
        local lang = config.settings.language
        local parts = key:split(".")
        local current = Utils.translations[lang]
        
        for _, part in ipairs(parts) do
            current = current[part]
            if not current then return key end
        end
        
        return current or key
    end,
    
    -- Воспроизвести звук (визуальный)
    playSound = function(pitch)
        if not config.settings.soundEffects then return end
        
        spawn(function()
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://2036919227"
            sound.Volume = 0.3
            sound.Pitch = pitch or 1
            sound.Parent = Workspace
            sound:Play()
            Debris:AddItem(sound, 2)
        end)
    end,
    
    -- Создать эффект частиц
    createParticles = function(position, color, count)
        for i = 1, count do
            local part = Instance.new("Part")
            part.Size = Vector3.new(0.2, 0.2, 0.2)
            part.Position = position + Vector3.new(
                math.random(-2, 2),
                math.random(0, 3),
                math.random(-2, 2)
            )
            part.Color = color
            part.Material = Enum.Material.Neon
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 0.5
            part.Parent = Workspace
            
            local tween = TweenService:Create(part, TweenInfo.new(0.5), {
                Position = part.Position + Vector3.new(0, 3, 0),
                Transparency = 1
            })
            tween:Play()
            
            Debris:AddItem(part, 0.6)
        end
    end,
    
    -- Обновить кэш персонажа
    updateCharacterCache = function()
        cache.character = player.Character
        if cache.character then
            cache.humanoid = cache.character:FindFirstChild("Humanoid")
            cache.rootPart = cache.character:FindFirstChild("HumanoidRootPart")
        else
            cache.humanoid = nil
            cache.rootPart = nil
        end
    end,
    
    -- Безопасное выполнение
    safeCall = function(func, ...)
        local success, result = pcall(func, ...)
        if not success then
            warn("[AGALIK HUB] Error:", result)
        end
        return success, result
    end
}

-- ============================================
-- ГРАФИЧЕСКИЙ ИНТЕРФЕЙС
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AgalikHubUltimate"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

if gethui then
    screenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(screenGui)
    screenGui.Parent = player:WaitForChild("PlayerGui")
else
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- Стили для элементов
local function createStyledFrame(name, size, position, parent)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = config.theme.main
    frame.BorderColor3 = Color3.fromRGB(50, 50, 70)
    frame.BorderSizePixel = 1
    frame.ClipsDescendants = true
    
    if parent then
        frame.Parent = parent
    end
    
    return frame
end

local function createGradient(parent)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    }
    gradient.Rotation = 90
    gradient.Parent = parent
end

-- ============================================
-- ТУТОРИАЛ (УЛУЧШЕННЫЙ)
-- ============================================

local tutorialFrame = createStyledFrame("Tutorial", UDim2.new(0, 520, 0, 500), UDim2.new(0.5, -260, 0.5, -250), screenGui)
createGradient(tutorialFrame)

-- Анимированный фон
local particlesFrame = Instance.new("Frame")
particlesFrame.Size = UDim2.new(1, 0, 1, 0)
particlesFrame.BackgroundTransparency = 1
particlesFrame.Parent = tutorialFrame

spawn(function()
    while particlesFrame.Parent do
        local particle = Instance.new("TextLabel")
        particle.Size = UDim2.new(0, 20, 0, 20)
        particle.Position = UDim2.new(math.random(), 0, 0, -20)
        particle.BackgroundTransparency = 1
        particle.Font = Enum.Font.GothamBold
        particle.Text = {"⭐", "✨", "🔷", "🔶", "⚡"}[math.random(1, 5)]
        particle.TextColor3 = Color3.fromRGB(
            math.random(100, 255),
            math.random(100, 255),
            math.random(100, 255)
        )
        particle.TextSize = math.random(14, 24)
        particle.Parent = particlesFrame
        
        TweenService:Create(particle, TweenInfo.new(math.random(2, 4)), {
            Position = UDim2.new(particle.Position.X.Scale, 0, 1, 20),
            TextTransparency = 1
        }):Play()
        
        task.wait(math.random(0.1, 0.3))
        Debris:AddItem(particle, 5)
    end
end)

local tutorialTitle = Instance.new("TextLabel")
tutorialTitle.Name = "Title"
tutorialTitle.Size = UDim2.new(1, 0, 0, 70)
tutorialTitle.Position = UDim2.new(0, 0, 0, 0)
tutorialTitle.BackgroundColor3 = config.theme.secondary
tutorialTitle.BorderSizePixel = 0
tutorialTitle.Font = Enum.Font.GothamBold
tutorialTitle.Text = Utils.t("welcome")
tutorialTitle.TextColor3 = config.theme.accent
tutorialTitle.TextSize = 24
tutorialTitle.Parent = tutorialFrame

-- Добавляем свечение заголовку
local titleGlow = Instance.new("Frame")
titleGlow.Size = UDim2.new(1, 0, 0, 5)
titleGlow.Position = UDim2.new(0, 0, 1, -5)
titleGlow.BackgroundColor3 = config.theme.accent
titleGlow.BorderSizePixel = 0
titleGlow.Parent = tutorialTitle

local glowGradient = Instance.new("UIGradient")
glowGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255, 0))
}
glowGradient.Parent = titleGlow

-- Выбор языка
local languageQuestion = Instance.new("TextLabel")
languageQuestion.Name = "LanguageQuestion"
languageQuestion.Size = UDim2.new(1, -40, 0, 60)
languageQuestion.Position = UDim2.new(0, 20, 0, 90)
languageQuestion.BackgroundTransparency = 1
languageQuestion.Font = Enum.Font.GothamSemibold
languageQuestion.Text = Utils.t("selectLang")
languageQuestion.TextColor3 = config.theme.text
languageQuestion.TextSize = 18
languageQuestion.TextWrapped = true
languageQuestion.Parent = tutorialFrame

-- Кнопки языка с анимацией
local function createLanguageButton(name, text, color, position)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 220, 0, 50)
    button.Position = position
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 18
    button.Parent = tutorialFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 230, 0, 55),
            Position = position - UDim2.new(0, 5, 0, 2.5)
        }):Play()
        Utils.playSound(1.1)
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 220, 0, 50),
            Position = position
        }):Play()
    end)
    
    return button
end

local englishBtn = createLanguageButton("EnglishBtn", "🇺🇸 ENGLISH", config.theme.accent, UDim2.new(0.5, -230, 0, 170))
local russianBtn = createLanguageButton("RussianBtn", "🇷🇺 RUSSIAN", Color3.fromRGB(255, 50, 50), UDim2.new(0.5, 10, 0, 170))

-- Область с инструкцией
local tutorialContent = Instance.new("ScrollingFrame")
tutorialContent.Name = "Content"
tutorialContent.Size = UDim2.new(1, -40, 0, 220)
tutorialContent.Position = UDim2.new(0, 20, 0, 240)
tutorialContent.BackgroundColor3 = config.theme.secondary
tutorialContent.BorderSizePixel = 0
tutorialContent.ScrollBarThickness = 8
tutorialContent.ScrollBarImageColor3 = config.theme.accent
tutorialContent.CanvasSize = UDim2.new(0, 0, 0, 0)
tutorialContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
tutorialContent.Visible = false
tutorialContent.Parent = tutorialFrame

local tutorialCorner = Instance.new("UICorner")
tutorialCorner.CornerRadius = UDim.new(0, 8)
tutorialCorner.Parent = tutorialContent

local tutorialLayout = Instance.new("UIListLayout")
tutorialLayout.Padding = UDim.new(0, 12)
tutorialLayout.SortOrder = Enum.SortOrder.LayoutOrder
tutorialLayout.Parent = tutorialContent

local tutorialPadding = Instance.new("UIPadding")
tutorialPadding.PaddingTop = UDim.new(0, 20)
tutorialPadding.PaddingLeft = UDim.new(0, 20)
tutorialPadding.PaddingRight = UDim.new(0, 20)
tutorialPadding.Parent = tutorialContent

-- Кнопка принятия
local acceptBtn = Instance.new("TextButton")
acceptBtn.Name = "AcceptBtn"
acceptBtn.Size = UDim2.new(0, 150, 0, 50)
acceptBtn.Position = UDim2.new(0.5, -75, 1, -70)
acceptBtn.AnchorPoint = Vector2.new(0.5, 0)
acceptBtn.BackgroundColor3 = config.theme.success
acceptBtn.BorderSizePixel = 0
acceptBtn.AutoButtonColor = false
acceptBtn.Font = Enum.Font.GothamBold
acceptBtn.Text = Utils.t("accept")
acceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
acceptBtn.TextSize = 18
acceptBtn.Visible = false
acceptBtn.Parent = tutorialFrame

local acceptCorner = Instance.new("UICorner")
acceptCorner.CornerRadius = UDim.new(0, 8)
acceptCorner.Parent = acceptBtn

acceptBtn.MouseEnter:Connect(function()
    TweenService:Create(acceptBtn, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 160, 0, 55),
        Position = UDim2.new(0.5, -80, 1, -72.5)
    }):Play()
    Utils.playSound(1.05)
end)

acceptBtn.MouseLeave:Connect(function()
    TweenService:Create(acceptBtn, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 150, 0, 50),
        Position = UDim2.new(0.5, -75, 1, -70)
    }):Play()
end)

-- Функция создания пункта инструкции
local function createTutorialItem(text, icon, color)
    local itemFrame = Instance.new("Frame")
    itemFrame.Name = "Item"
    itemFrame.Size = UDim2.new(1, 0, 0, 45)
    itemFrame.BackgroundColor3 = config.theme.main
    itemFrame.BorderSizePixel = 0
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 6)
    itemCorner.Parent = itemFrame
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(0, 35, 0, 35)
    iconLabel.Position = UDim2.new(0, 10, 0.5, -17.5)
    iconLabel.AnchorPoint = Vector2.new(0, 0.5)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Text = icon
    iconLabel.TextColor3 = color or config.theme.accent
    iconLabel.TextSize = 20
    iconLabel.Parent = itemFrame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.Size = UDim2.new(1, -60, 0, 35)
    textLabel.Position = UDim2.new(0, 55, 0.5, -17.5)
    textLabel.AnchorPoint = Vector2.new(0, 0.5)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.Gotham
    textLabel.Text = text
    textLabel.TextColor3 = config.theme.text
    textLabel.TextSize = 14
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    textLabel.Parent = itemFrame
    
    return itemFrame
end

-- Тексты инструкций
local tutorialTexts = {
    english = {
        {text = "🎮 WELCOME TO AGALIK HUB v5.1!", icon = "🎮", color = config.theme.accent},
        {text = "✅ Ultimate script for Prison Life", icon = "✅", color = config.theme.success},
        {text = "", icon = "", color = nil},
        {text = "🔑 CONTROLS:", icon = "🔑", color = config.theme.warning},
        {text = "• RightControl - Open/Close menu", icon = "⌨️", color = config.theme.text},
        {text = "• Drag title bar - Move window", icon = "🖱️", color = config.theme.text},
        {text = "", icon = "", color = nil},
        {text = "🚀 NEW FEATURES:", icon = "🚀", color = config.theme.accent},
        {text = "• SPINNER MODE - Crazy rotation (F key)", icon = "🌀", color = config.theme.purple},
        {text = "• PARTICLE EFFECTS - Visual feedback", icon = "✨", color = config.theme.pink},
        {text = "• OPTIMIZED ESP - Better performance", icon = "👁️", color = config.theme.cyan},
        {text = "", icon = "", color = nil},
        {text = "⚠️ WARNING:", icon = "⚠️", color = config.theme.danger},
        {text = "Use responsibly! For educational purposes.", icon = "📚", color = config.theme.text}
    },
    
    russian = {
        {text = "🎮 ДОБРО ПОЖАЛОВАТЬ В AGALIK HUB v5.1!", icon = "🎮", color = config.theme.accent},
        {text = "✅ Ультимейт скрипт для Prison Life", icon = "✅", color = config.theme.success},
        {text = "", icon = "", color = nil},
        {text = "🔑 УПРАВЛЕНИЕ:", icon = "🔑", color = config.theme.warning},
        {text = "• RightControl - Открыть/Закрыть меню", icon = "⌨️", color = config.theme.text},
        {text = "• Тащить заголовок - Перемещать окно", icon = "🖱️", color = config.theme.text},
        {text = "", icon = "", color = nil},
        {text = "🚀 НОВЫЕ ФУНКЦИИ:", icon = "🚀", color = config.theme.accent},
        {text = "• КРУТИЛКА - Безумное вращение (клавиша F)", icon = "🌀", color = config.theme.purple},
        {text = "• ЭФФЕКТЫ ЧАСТИЦ - Визуальная обратная связь", icon = "✨", color = config.theme.pink},
        {text = "• ОПТИМИЗИРОВАННЫЙ ESP - Лучшая производительность", icon = "👁️", color = config.theme.cyan},
        {text = "", icon = "", color = nil},
        {text = "⚠️ ПРЕДУПРЕЖДЕНИЕ:", icon = "⚠️", color = config.theme.danger},
        {text = "Используйте ответственно! В образовательных целях.", icon = "📚", color = config.theme.text}
    }
}

-- Функция показа инструкции
local function showTutorial(language)
    config.settings.language = language
    
    -- Очистка контента
    for _, child in ipairs(tutorialContent:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Заполнение
    local texts = tutorialTexts[language]
    for i, item in ipairs(texts) do
        if item.text ~= "" then
            local tutorialItem = createTutorialItem(item.text, item.icon, item.color)
            tutorialItem.LayoutOrder = i
            tutorialItem.Parent = tutorialContent
        else
            local spacer = Instance.new("Frame")
            spacer.Size = UDim2.new(1, 0, 0, 5)
            spacer.BackgroundTransparency = 1
            spacer.LayoutOrder = i
            spacer.Parent = tutorialContent
        end
    end
    
    -- Показываем элементы
    tutorialContent.Visible = true
    acceptBtn.Visible = true
    
    -- Анимация появления
    tutorialContent.Position = UDim2.new(0, 20, 0.5, 0)
    tutorialContent.Size = UDim2.new(1, -40, 0, 0)
    
    if config.settings.animations then
        TweenService:Create(tutorialContent, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
            Position = UDim2.new(0, 20, 0, 240),
            Size = UDim2.new(1, -40, 0, 220)
        }):Play()
    else
        tutorialContent.Position = UDim2.new(0, 20, 0, 240)
        tutorialContent.Size = UDim2.new(1, -40, 0, 220)
    end
end

-- Обработчики кнопок
englishBtn.MouseButton1Click:Connect(function()
    Utils.playSound()
    showTutorial("english")
    tutorialTitle.Text = Utils.t("welcome")
    languageQuestion.Text = Utils.t("selectLang")
    acceptBtn.Text = Utils.t("accept")
end)

russianBtn.MouseButton1Click:Connect(function()
    Utils.playSound()
    showTutorial("russian")
    tutorialTitle.Text = Utils.t("welcome")
    languageQuestion.Text = Utils.t("selectLang")
    acceptBtn.Text = Utils.t("accept")
end)

-- ============================================
-- ОСНОВНОЕ МЕНЮ
-- ============================================

local mainFrame = createStyledFrame("MainFrame", UDim2.new(0, 480, 0, 450), config.settings.menuPosition, screenGui)
mainFrame.Visible = false
createGradient(mainFrame)

-- Панель заголовка с свечением
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = config.theme.secondary
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleGlowBar = Instance.new("Frame")
titleGlowBar.Size = UDim2.new(1, 0, 0, 3)
titleGlowBar.Position = UDim2.new(0, 0, 1, -3)
titleGlowBar.BackgroundColor3 = config.theme.accent
titleGlowBar.BorderSizePixel = 0
titleGlowBar.Parent = titleBar

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "AGALIK HUB v5.1 | ULTIMATE"
title.TextColor3 = config.theme.accent
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextSize = 20
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Боковая панель
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 110, 1, -45)
sidebar.Position = UDim2.new(0, 0, 0, 45)
sidebar.BackgroundColor3 = config.theme.secondary
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

-- Область контента
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -110, 1, -45)
contentFrame.Position = UDim2.new(0, 110, 0, 45)
contentFrame.BackgroundColor3 = config.theme.main
contentFrame.BorderSizePixel = 0
contentFrame.ClipsDescendants = true
contentFrame.Parent = mainFrame

-- ============================================
-- ВКЛАДКИ МЕНЮ
-- ============================================

local tabs = {
    {Name = "Player", Icon = "👤", Color = config.theme.accent},
    {Name = "Visual", Icon = "👁️", Color = config.theme.cyan},
    {Name = "Teleport", Icon = "📍", Color = config.theme.warning},
    {Name = "Fun", Icon = "🎮", Color = config.theme.pink},
    {Name = "Credits", Icon = "⭐", Color = Color3.fromRGB(255, 215, 0)}
}

local tabFrames = {}
local tabButtons = {}
local activeTab = 1

for i, tab in ipairs(tabs) do
    -- Кнопка вкладки
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tab.Name .. "Tab"
    tabButton.Size = UDim2.new(1, 0, 0, 50)
    tabButton.Position = UDim2.new(0, 0, 0, (i-1) * 55)
    tabButton.BackgroundColor3 = i == 1 and Color3.fromRGB(45, 45, 60) or config.theme.secondary
    tabButton.BorderSizePixel = 0
    tabButton.AutoButtonColor = false
    tabButton.Font = Enum.Font.Gotham
    tabButton.Text = ""
    tabButton.Parent = sidebar
    
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0.5, -15, 0, 8)
    icon.BackgroundTransparency = 1
    icon.Font = Enum.Font.GothamBold
    icon.Text = tab.Icon
    icon.TextColor3 = i == 1 and tab.Color or config.theme.subtext
    icon.TextSize = 18
    icon.Parent = tabButton
    
    local text = Instance.new("TextLabel")
    text.Name = "Text"
    text.Size = UDim2.new(1, -10, 0, 20)
    text.Position = UDim2.new(0, 5, 1, -25)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.Gotham
    text.Text = tab.Name
    text.TextColor3 = i == 1 and config.theme.text or config.theme.subtext
    text.TextSize = 12
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.Parent = tabButton
    
    -- Фрейм контента
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Name = tab.Name .. "Content"
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.BorderSizePixel = 0
    tabFrame.ScrollBarThickness = 5
    tabFrame.ScrollBarImageColor3 = tab.Color
    tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabFrame.Visible = i == 1
    tabFrame.Parent = contentFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = tabFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = tabFrame
    
    tabButtons[i] = tabButton
    tabFrames[i] = tabFrame
    
    -- Обработчик клика
    tabButton.MouseButton1Click:Connect(function()
        if activeTab == i then return end
        Utils.playSound(1.1)
        activeTab = i
        
        for idx, btn in ipairs(tabButtons) do
            local isActive = idx == i
            
            if config.settings.animations then
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = isActive and Color3.fromRGB(45, 45, 60) or config.theme.secondary
                }):Play()
                
                TweenService:Create(btn:FindFirstChild("Icon"), TweenInfo.new(0.2), {
                    TextColor3 = isActive and tabs[idx].Color or config.theme.subtext
                }):Play()
                
                TweenService:Create(btn:FindFirstChild("Text"), TweenInfo.new(0.2), {
                    TextColor3 = isActive and config.theme.text or config.theme.subtext
                }):Play()
            else
                btn.BackgroundColor3 = isActive and Color3.fromRGB(45, 45, 60) or config.theme.secondary
                btn.Icon.TextColor3 = isActive and tabs[idx].Color or config.theme.subtext
                btn.Text.TextColor3 = isActive and config.theme.text or config.theme.subtext
            end
            
            tabFrames[idx].Visible = isActive
        end
    end)
end

-- Кнопка открытия меню
local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0, 60, 0, 60)
openButton.Position = UDim2.new(1, -70, 0, 20)
openButton.BackgroundColor3 = config.theme.accent
openButton.BorderSizePixel = 0
openButton.AutoButtonColor = false
openButton.Font = Enum.Font.GothamBold
openButton.Text = "A"
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.TextSize = 22
openButton.Visible = false
openButton.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 12)
openCorner.Parent = openButton

-- Анимация пульсации кнопки
spawn(function()
    while openButton.Parent do
        if openButton.Visible then
            TweenService:Create(openButton, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
                Size = UDim2.new(0, 65, 0, 65),
                Position = UDim2.new(1, -72.5, 0, 17.5)
            }):Play()
            task.wait(0.8)
            TweenService:Create(openButton, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
                Size = UDim2.new(0, 60, 0, 60),
                Position = UDim2.new(1, -70, 0, 20)
            }):Play()
            task.wait(0.8)
        else
            task.wait(1)
        end
    end
end)

openButton.MouseEnter:Connect(function()
    TweenService:Create(openButton, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 70, 0, 70),
        Position = UDim2.new(1, -75, 0, 15)
    }):Play()
    Utils.playSound(1.05)
end)

openButton.MouseLeave:Connect(function()
    TweenService:Create(openButton, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.new(1, -70, 0, 20)
    }):Play()
end)

-- ============================================
-- СИСТЕМА УВЕДОМЛЕНИЙ
-- ============================================

local notifications = {}

local function showNotification(text, color, icon, duration)
    duration = duration or 2
    
    spawn(function()
        local notification = Instance.new("Frame")
        notification.Size = UDim2.new(0, 350, 0, 60)
        notification.Position = UDim2.new(0.5, -175, 0.05, 0)
        notification.AnchorPoint = Vector2.new(0.5, 0)
        notification.BackgroundColor3 = config.theme.secondary
        notification.BorderSizePixel = 0
        notification.ZIndex = 1000
        notification.Parent = screenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = notification
        
        local border = Instance.new("Frame")
        border.Size = UDim2.new(1, 0, 0, 4)
        border.Position = UDim2.new(0, 0, 1, -4)
        border.BackgroundColor3 = color
        border.BorderSizePixel = 0
        border.Parent = notification
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -20, 1, 0)
        textLabel.Position = UDim2.new(0, 10, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.GothamBold
        textLabel.Text = icon .. " " .. text .. " " .. icon
        textLabel.TextColor3 = color
        textLabel.TextSize = 16
        textLabel.TextXAlignment = Enum.TextXAlignment.Center
        textLabel.Parent = notification
        
        -- Анимация
        notification.Position = UDim2.new(0.5, -175, -0.1, 0)
        notification.BackgroundTransparency = 1
        textLabel.TextTransparency = 1
        
        if config.settings.animations then
            TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                Position = UDim2.new(0.5, -175, 0.05, 0),
                BackgroundTransparency = 0
            }):Play()
            
            TweenService:Create(textLabel, TweenInfo.new(0.3), {
                TextTransparency = 0
            }):Play()
        else
            notification.Position = UDim2.new(0.5, -175, 0.05, 0)
            notification.BackgroundTransparency = 0
            textLabel.TextTransparency = 0
        end
        
        Utils.playSound(0.9)
        
        -- Сдвиг предыдущих уведомлений
        for _, notif in ipairs(notifications) do
            if notif and notif.Parent then
                TweenService:Create(notif, TweenInfo.new(0.2), {
                    Position = UDim2.new(notif.Position.X.Scale, notif.Position.X.Offset, notif.Position.Y.Scale, notif.Position.Y.Offset + 70)
                }):Play()
            end
        end
        
        table.insert(notifications, 1, notification)
        
        task.wait(duration)
        
        if config.settings.animations then
            TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                Position = UDim2.new(0.5, -175, -0.1, 0),
                BackgroundTransparency = 1
            }):Play()
            
            TweenService:Create(textLabel, TweenInfo.new(0.3), {
                TextTransparency = 1
            }):Play()
        end
        
        task.wait(0.3)
        
        -- Удаление из массива
        for i, notif in ipairs(notifications) do
            if notif == notification then
                table.remove(notifications, i)
                break
            end
        end
        
        notification:Destroy()
    end)
end

-- ============================================
-- КОМПОНЕНТ КНОПКИ
-- ============================================

local function createButton(parent, title, description, icon, color, isToggle, keybind)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = title .. "Button"
    buttonFrame.Size = UDim2.new(1, 0, 0, 70)
    buttonFrame.BackgroundColor3 = config.theme.secondary
    buttonFrame.BorderSizePixel = 0
    buttonFrame.LayoutOrder = #parent:GetChildren()
    buttonFrame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = buttonFrame
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(0, 40, 0, 40)
    iconLabel.Position = UDim2.new(0, 15, 0.5, -20)
    iconLabel.AnchorPoint = Vector2.new(0, 0.5)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Text = icon
    iconLabel.TextColor3 = color
    iconLabel.TextSize = 22
    iconLabel.Parent = buttonFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0.7, -70, 0, 30)
    titleLabel.Position = UDim2.new(0, 70, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title .. (isToggle and " [OFF]" or "")
    titleLabel.TextColor3 = config.theme.text
    titleLabel.TextSize = 15
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = buttonFrame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(0.7, -70, 0, 25)
    descLabel.Position = UDim2.new(0, 70, 0, 40)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.Text = description .. (keybind and " [" .. keybind .. "]" or "")
    descLabel.TextColor3 = config.theme.subtext
    descLabel.TextSize = 12
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = buttonFrame
    
    local actionButton = Instance.new("TextButton")
    actionButton.Name = "Action"
    actionButton.Size = UDim2.new(0, 80, 0, 30)
    actionButton.Position = UDim2.new(1, -20, 0.5, -15)
    actionButton.AnchorPoint = Vector2.new(1, 0.5)
    actionButton.BackgroundColor3 = isToggle and Color3.fromRGB(60, 60, 80) or color
    actionButton.BorderSizePixel = 0
    actionButton.AutoButtonColor = false
    actionButton.Font = Enum.Font.GothamBold
    actionButton.Text = isToggle and "OFF" or "USE"
    actionButton.TextColor3 = isToggle and config.theme.subtext or Color3.fromRGB(255, 255, 255)
    actionButton.TextSize = 13
    actionButton.Parent = buttonFrame
    
    local actionCorner = Instance.new("UICorner")
    actionCorner.CornerRadius = UDim.new(0, 6)
    actionCorner.Parent = actionButton
    
    -- Эффекты
    actionButton.MouseEnter:Connect(function()
        TweenService:Create(actionButton, TweenInfo.new(0.2), {
            BackgroundColor3 = isToggle and Color3.fromRGB(70, 70, 90) or Color3.fromRGB(
                math.min(color.R * 255 + 20, 255)/255,
                math.min(color.G * 255 + 20, 255)/255,
                math.min(color.B * 255 + 20, 255)/255
            ),
            Size = UDim2.new(0, 85, 0, 33)
        }):Play()
        Utils.playSound(1.05)
    end)
    
    actionButton.MouseLeave:Connect(function()
        TweenService:Create(actionButton, TweenInfo.new(0.2), {
            BackgroundColor3 = isToggle and Color3.fromRGB(60, 60, 80) or color,
            Size = UDim2.new(0, 80, 0, 30)
        }):Play()
    end)
    
    return actionButton, buttonFrame
end

-- ============================================
-- ФУНКЦИИ ИГРОКА (ВКЛАДКА 1)
-- ============================================

local playerTab = tabFrames[1]

-- NOCHIP
local nochipBtn, nochipFrame = createButton(
    playerTab,
    Utils.t("features.nochip"),
    "Walk through walls",
    "🚶",
    config.theme.accent,
    true
)

cache.connections.nochip = nil
nochipBtn.MouseButton1Click:Connect(function()
    nochipBtn.Text = nochipBtn.Text == "OFF" and "ON" or "OFF"
    local enabled = nochipBtn.Text == "ON"
    
    nochipBtn.BackgroundColor3 = enabled and config.theme.success or Color3.fromRGB(60, 60, 80)
    nochipBtn.TextColor3 = enabled and Color3.fromRGB(255, 255, 255) or config.theme.subtext
    nochipFrame.Title.Text = Utils.t("features.nochip") .. (enabled and " [ON]" or " [OFF]")
    
    if enabled then
        if cache.connections.nochip then
            cache.connections.nochip:Disconnect()
        end
        
        cache.connections.nochip = RunService.Stepped:Connect(function()
            Utils.updateCharacterCache()
            if cache.character then
                for _, part in pairs(cache.character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        
        showNotification(Utils.t("features.nochip") .. " " .. Utils.t("notifications.enabled"), config.theme.success, "✅")
        Utils.createParticles(cache.rootPart and cache.rootPart.Position or Vector3.new(0, 5, 0), config.theme.success, 10)
    else
        if cache.connections.nochip then
            cache.connections.nochip:Disconnect()
            cache.connections.nochip = nil
        end
        showNotification(Utils.t("features.nochip") .. " " .. Utils.t("notifications.disabled"), config.theme.danger, "❌")
    end
end)

-- SPEED HACK
local speedBtn, speedFrame = createButton(
    playerTab,
    Utils.t("features.speed"),
    "Run faster",
    "⚡",
    config.theme.cyan,
    true,
    "Q"
)

speedBtn.MouseButton1Click:Connect(function()
    Utils.updateCharacterCache()
    if cache.humanoid then
        local newSpeed = cache.humanoid.WalkSpeed == 16 and 50 or 16
        cache.humanoid.WalkSpeed = newSpeed
        
        speedBtn.Text = newSpeed == 50 and "ON" or "OFF"
        speedBtn.BackgroundColor3 = newSpeed == 50 and config.theme.success or Color3.fromRGB(60, 60, 80)
        speedBtn.TextColor3 = newSpeed == 50 and Color3.fromRGB(255, 255, 255) or config.theme.subtext
        speedFrame.Title.Text = Utils.t("features.speed") .. (newSpeed == 50 and " [ON]" or " [OFF]")
        
        local notifText = newSpeed == 50 and Utils.t("notifications.spunUp") or Utils.t("notifications.spunDown")
        showNotification(notifText .. " (" .. newSpeed .. ")", 
                        newSpeed == 50 and config.theme.success or config.theme.danger, 
                        newSpeed == 50 and "⚡" or "🐢")
        
        if cache.rootPart then
            Utils.createParticles(cache.rootPart.Position, newSpeed == 50 and config.theme.success or config.theme.danger, 8)
        end
    end
end)

-- INVISIBLE
local invisibleBtn, invisibleFrame = createButton(
    playerTab,
    Utils.t("features.invisible"),
    "Become invisible",
    "👻",
    config.theme.purple,
    true
)

invisibleBtn.MouseButton1Click:Connect(function()
    Utils.updateCharacterCache()
    if cache.character then
        local isNowInvisible = false
        
        for _, part in pairs(cache.character:GetDescendants()) do
            if part:IsA("BasePart") then
                if part.Transparency < 0.5 then
                    part.Transparency = 1
                    isNowInvisible = true
                else
                    part.Transparency = 0
                    isNowInvisible = false
                end
            elseif part:IsA("Accessory") and part.Handle then
                if part.Handle.Transparency < 0.5 then
                    part.Handle.Transparency = 1
                else
                    part.Handle.Transparency = 0
                end
            end
        end
        
        invisibleBtn.Text = isNowInvisible and "ON" or "OFF"
        invisibleBtn.BackgroundColor3 = isNowInvisible and config.theme.success or Color3.fromRGB(60, 60, 80)
        invisibleBtn.TextColor3 = isNowInvisible and Color3.fromRGB(255, 255, 255) or config.theme.subtext
        invisibleFrame.Title.Text = Utils.t("features.invisible") .. (isNowInvisible and " [ON]" or " [OFF]")
        
        local notifText = Utils.t("features.invisible") .. " " .. 
                         (isNowInvisible and Utils.t("notifications.enabled") or Utils.t("notifications.disabled"))
        showNotification(notifText, 
                        isNowInvisible and config.theme.success or config.theme.danger, 
                        isNowInvisible and "👻" or "👤")
        
        if cache.rootPart then
            Utils.createParticles(cache.rootPart.Position, isNowInvisible and config.theme.purple or config.theme.text, 10)
        end
    end
end)

-- ============================================
-- КРУТИЛКА (ГЛАВНАЯ ФИЧА!)
-- ============================================

local spinnerBtn, spinnerFrame = createButton(
    playerTab,
    Utils.t("features.spinner"),
    "Crazy rotation mode",
    "🌀",
    config.theme.purple,
    true,
    "F"
)

cache.connections.spinner = nil
cache.spinSpeed = 50

spinnerBtn.MouseButton1Click:Connect(function()
    cache.spinning = not cache.spinning
    spinnerBtn.Text = cache.spinning and "ON" or "OFF"
    spinnerBtn.BackgroundColor3 = cache.spinning and config.theme.success or Color3.fromRGB(60, 60, 80)
    spinnerBtn.TextColor3 = cache.spinning and Color3.fromRGB(255, 255, 255) or config.theme.subtext
    spinnerFrame.Title.Text = Utils.t("features.spinner") .. (cache.spinning and " [ON]" or " [OFF]")
    
    if cache.spinning then
        -- Запускаем крутилку
        if cache.connections.spinner then
            cache.connections.spinner:Disconnect()
        end
        
        cache.connections.spinner = RunService.RenderStepped:Connect(function()
            Utils.updateCharacterCache()
            if cache.rootPart then
                -- Вращение персонажа
                local currentCFrame = cache.rootPart.CFrame
                local rotation = CFrame.Angles(0, math.rad(cache.spinSpeed), 0)
                cache.rootPart.CFrame = currentCFrame * rotation
                
                -- Визуальные эффекты (только для меня)
                local ray = Ray.new(cache.rootPart.Position, Vector3.new(0, -10, 0))
                local hit = Workspace:FindPartOnRay(ray, cache.character)
                
                if hit then
                    -- Создаем частицы под ногами
                    if math.random(1, 3) == 1 then
                        Utils.createParticles(
                            cache.rootPart.Position - Vector3.new(0, 3, 0),
                            Color3.fromRGB(
                                math.random(100, 255),
                                math.random(100, 255),
                                math.random(100, 255)
                            ),
                            2
                        )
                    end
                end
            end
        end)
        
        showNotification(Utils.t("notifications.spinning") .. " (F: +/- speed)", config.theme.purple, "🌀")
        Utils.playSound(1.2)
        
        if cache.rootPart then
            Utils.createParticles(cache.rootPart.Position, config.theme.purple, 15)
        end
    else
        -- Останавливаем крутилку
        if cache.connections.spinner then
            cache.connections.spinner:Disconnect()
            cache.connections.spinner = nil
        end
        
        showNotification(Utils.t("notifications.stopped"), config.theme.danger, "⏹️")
        Utils.playSound(0.8)
    end
end)

-- Кнопки управления скоростью крутилки
local speedUpBtn = Instance.new("TextButton")
speedUpBtn.Name = "SpeedUp"
speedUpBtn.Size = UDim2.new(0, 40, 0, 25)
speedUpBtn.Position = UDim2.new(1, -120, 0, 45)
speedUpBtn.AnchorPoint = Vector2.new(1, 0)
speedUpBtn.BackgroundColor3 = config.theme.success
speedUpBtn.BorderSizePixel = 0
speedUpBtn.AutoButtonColor = false
speedUpBtn.Font = Enum.Font.GothamBold
speedUpBtn.Text = "+"
speedUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUpBtn.TextSize = 16
speedUpBtn.Visible = false
speedUpBtn.Parent = spinnerFrame

local speedDownBtn = Instance.new("TextButton")
speedDownBtn.Name = "SpeedDown"
speedDownBtn.Size = UDim2.new(0, 40, 0, 25)
speedDownBtn.Position = UDim2.new(1, -70, 0, 45)
speedDownBtn.AnchorPoint = Vector2.new(1, 0)
speedDownBtn.BackgroundColor3 = config.theme.danger
speedDownBtn.BorderSizePixel = 0
speedDownBtn.AutoButtonColor = false
speedDownBtn.Font = Enum.Font.GothamBold
speedDownBtn.Text = "-"
speedDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDownBtn.TextSize = 16
speedDownBtn.Visible = false
speedDownBtn.Parent = spinnerFrame

local speedDisplay = Instance.new("TextLabel")
speedDisplay.Name = "SpeedDisplay"
speedDisplay.Size = UDim2.new(0, 50, 0, 20)
speedDisplay.Position = UDim2.new(1, -165, 0, 47)
speedDisplay.AnchorPoint = Vector2.new(1, 0)
speedDisplay.BackgroundTransparency = 1
speedDisplay.Font = Enum.Font.GothamBold
speedDisplay.Text = cache.spinSpeed .. "°"
speedDisplay.TextColor3 = config.theme.purple
speedDisplay.TextSize = 14
speedDisplay.Visible = false
speedDisplay.Parent = spinnerFrame

-- Показываем кнопки скорости при включении крутилки
spinnerBtn.MouseButton1Click:Connect(function()
    task.wait(0.1)
    speedUpBtn.Visible = cache.spinning
    speedDownBtn.Visible = cache.spinning
    speedDisplay.Visible = cache.spinning
end)

speedUpBtn.MouseButton1Click:Connect(function()
    cache.spinSpeed = math.min(cache.spinSpeed + 10, 200)
    speedDisplay.Text = cache.spinSpeed .. "°"
    showNotification("Speed: " .. cache.spinSpeed .. "°", config.theme.success, "⚡", 1)
    Utils.playSound(1.1)
end)

speedDownBtn.MouseButton1Click:Connect(function()
    cache.spinSpeed = math.max(cache.spinSpeed - 10, 10)
    speedDisplay.Text = cache.spinSpeed .. "°"
    showNotification("Speed: " .. cache.spinSpeed .. "°", config.theme.danger, "🐌", 1)
    Utils.playSound(0.9)
end)

-- Горячая клавиша для крутилки
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        if cache.spinning then
            -- Увеличиваем скорость при зажатии F
            cache.spinSpeed = math.min(cache.spinSpeed + 5, 250)
            speedDisplay.Text = cache.spinSpeed .. "°"
            
            if cache.rootPart then
                Utils.createParticles(cache.rootPart.Position, Color3.fromRGB(255, 50, 255), 3)
            end
        end
    elseif input.KeyCode == Enum.KeyCode.Q then
        -- Быстрое переключение скорости через Q
        Utils.updateCharacterCache()
        if cache.humanoid then
            cache.humanoid.WalkSpeed = cache.humanoid.WalkSpeed == 16 and 50 or 16
            showNotification("Speed: " .. cache.humanoid.WalkSpeed, 
                           cache.humanoid.WalkSpeed == 50 and config.theme.success or config.theme.danger,
                           cache.humanoid.WalkSpeed == 50 and "⚡" or "🐢",
                           1)
        end
    end
end)

-- ============================================
-- ВИЗУАЛЬНЫЕ ФУНКЦИИ (ВКЛАДКА 2)
-- ============================================

local visualTab = tabFrames[2]

-- ESP
local espBtn, espFrame = createButton(
    visualTab,
    Utils.t("features.esp"),
    "See all players",
    "👁️",
    config.theme.pink,
    true
)

cache.connections.esp = nil

espBtn.MouseButton1Click:Connect(function()
    espBtn.Text = espBtn.Text == "OFF" and "ON" or "OFF"
    local enabled = espBtn.Text == "ON"
    
    espBtn.BackgroundColor3 = enabled and config.theme.success or Color3.fromRGB(60, 60, 80)
    espBtn.TextColor3 = enabled and Color3.fromRGB(255, 255, 255) or config.theme.subtext
    espFrame.Title.Text = Utils.t("features.esp") .. (enabled and " [ON]" or " [OFF]")
    
    if enabled then
        -- Оптимизированный ESP
        cache.connections.esp = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = p.Character.HumanoidRootPart
                    local pos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                    
                    if onScreen then
                        if not cache.espDrawings[p] then
                            cache.espDrawings[p] = {
                                box = Drawing.new("Square"),
                                name = Drawing.new("Text"),
                                health = Drawing.new("Text")
                            }
                            
                            local drawings = cache.espDrawings[p]
                            drawings.box.Visible = true
                            drawings.box.Color = Color3.new(1, 0, 0)
                            drawings.box.Thickness = 2
                            drawings.box.Filled = false
                            
                            drawings.name.Visible = true
                            drawings.name.Color = Color3.new(1, 1, 1)
                            drawings.name.Size = 14
                            drawings.name.Text = p.Name
                            
                            drawings.health.Visible = true
                            drawings.health.Color = Color3.new(0, 1, 0)
                            drawings.health.Size = 12
                        end
                        
                        local drawings = cache.espDrawings[p]
                        local hum = p.Character:FindFirstChild("Humanoid")
                        local health = hum and math.floor(hum.Health) or "N/A"
                        
                        drawings.box.Position = Vector2.new(pos.X - 25, pos.Y - 40)
                        drawings.box.Size = Vector2.new(50, 80)
                        
                        drawings.name.Position = Vector2.new(pos.X, pos.Y - 50)
                        
                        if cache.rootPart then
                            local distance = (cache.rootPart.Position - rootPart.Position).Magnitude
                            drawings.health.Text = health .. " HP | " .. math.floor(distance) .. " studs"
                            drawings.health.Position = Vector2.new(pos.X, pos.Y + 45)
                        end
                    end
                end
            end
        end)
        
        showNotification(Utils.t("features.esp") .. " " .. Utils.t("notifications.enabled"), config.theme.success, "👁️")
    else
        if cache.connections.esp then
            cache.connections.esp:Disconnect()
            cache.connections.esp = nil
        end
        
        -- Очистка Drawing объектов
        for _, drawings in pairs(cache.espDrawings) do
            if drawings.box then drawings.box:Remove() end
            if drawings.name then drawings.name:Remove() end
            if drawings.health then drawings.health:Remove() end
        end
        cache.espDrawings = {}
        
        showNotification(Utils.t("features.esp") .. " " .. Utils.t("notifications.disabled"), config.theme.danger, "👁️")
    end
end)

-- X-RAY
local xrayBtn, xrayFrame = createButton(
    visualTab,
    Utils.t("features.xray"),
    "See through walls",
    "🔍",
    config.theme.cyan,
    true
)

xrayBtn.MouseButton1Click:Connect(function()
    xrayBtn.Text = xrayBtn.Text == "OFF" and "ON" or "OFF"
    local enabled = xrayBtn.Text == "ON"
    
    xrayBtn.BackgroundColor3 = enabled and config.theme.success or Color3.fromRGB(60, 60, 80)
    xrayBtn.TextColor3 = enabled and Color3.fromRGB(255, 255, 255) or config.theme.subtext
    xrayFrame.Title.Text = Utils.t("features.xray") .. (enabled and " [ON]" or " [OFF]")
    
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and (part.Name:lower():find("wall") or part.Name:lower():find("fence") or part.Name:lower():find("barrier")) then
            part.LocalTransparencyModifier = enabled and 0.6 or 0
        end
    end
    
    showNotification(Utils.t("features.xray") .. " " .. 
                     (enabled and Utils.t("notifications.enabled") or Utils.t("notifications.disabled")),
                     enabled and config.theme.success or config.theme.danger,
                     enabled and "🔍" or "🚫")
end)

-- FULLBRIGHT
local brightBtn, brightFrame = createButton(
    visualTab,
    Utils.t("features.fullbright"),
    "Remove darkness",
    "💡",
    Color3.fromRGB(255, 255, 100),
    true
)

brightBtn.MouseButton1Click:Connect(function()
    brightBtn.Text = brightBtn.Text == "OFF" and "ON" or "OFF"
    local enabled = brightBtn.Text == "ON"
    
    brightBtn.BackgroundColor3 = enabled and config.theme.success or Color3.fromRGB(60, 60, 80)
    brightBtn.TextColor3 = enabled and Color3.fromRGB(255, 255, 255) or config.theme.subtext
    brightFrame.Title.Text = Utils.t("features.fullbright") .. (enabled and " [ON]" or " [OFF]")
    
    if enabled then
        Lighting.GlobalShadows = false
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.ClockTime = 14
    else
        Lighting.GlobalShadows = true
        Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    end
    
    showNotification(Utils.t("features.fullbright") .. " " .. 
                     (enabled and Utils.t("notifications.enabled") or Utils.t("notifications.disabled")),
                     enabled and config.theme.success or config.theme.danger,
                     enabled and "💡" or "🌙")
end)

-- ============================================
-- ТЕЛЕПОРТЫ (ВКЛАДКА 3)
-- ============================================

local teleportTab = tabFrames[3]

-- Guard Room
local guardBtn = createButton(
    teleportTab,
    "GUARD ROOM",
    "Teleport to police spawn",
    "👮",
    Color3.fromRGB(100, 150, 255),
    false
)

guardBtn.MouseButton1Click:Connect(function()
    Utils.updateCharacterCache()
    if cache.rootPart then
        cache.rootPart.CFrame = CFrame.new(807.032, 99.99, 2307.153)
        showNotification(Utils.t("notifications.teleported") .. ": Guard Room", config.theme.success, "👮")
        Utils.createParticles(cache.rootPart.Position, Color3.fromRGB(100, 150, 255), 12)
        Utils.playSound()
    end
end)

-- Yard
local yardBtn = createButton(
    teleportTab,
    "PRISON YARD",
    "Teleport to main yard",
    "🏀",
    Color3.fromRGB(100, 255, 150),
    false
)

yardBtn.MouseButton1Click:Connect(function()
    Utils.updateCharacterCache()
    if cache.rootPart then
        cache.rootPart.CFrame = CFrame.new(803, 98, 2457)
        showNotification(Utils.t("notifications.teleported") .. ": Prison Yard", config.theme.success, "🏀")
        Utils.createParticles(cache.rootPart.Position, Color3.fromRGB(100, 255, 150), 12)
        Utils.playSound()
    end
end)

-- Criminal Base
local crimBtn = createButton(
    teleportTab,
    "CRIMINAL BASE",
    "Teleport to criminal spawn",
    "🔫",
    Color3.fromRGB(255, 100, 100),
    false
)

crimBtn.MouseButton1Click:Connect(function()
    Utils.updateCharacterCache()
    if cache.rootPart then
        cache.rootPart.CFrame = CFrame.new(-920, 94, 2137)
        showNotification(Utils.t("notifications.teleported") .. ": Criminal Base", config.theme.success, "🔫")
        Utils.createParticles(cache.rootPart.Position, Color3.fromRGB(255, 100, 100), 12)
        Utils.playSound()
    end
end)

-- ============================================
-- РАЗВЛЕЧЕНИЯ (ВКЛАДКА 4)
-- ============================================

local funTab = tabFrames[4]
local spawnedCubes = {}

-- Spawn Cube
local cubeBtn = createButton(
    funTab,
    "SPAWN CUBE",
    "Create colorful platform",
    "◼",
    Color3.fromRGB(100, 200, 255),
    false
)

cubeBtn.MouseButton1Click:Connect(function()
    Utils.updateCharacterCache()
    if cache.rootPart then
        local cube = Instance.new("Part")
        cube.Name = "AgalikCube"
        cube.Size = Vector3.new(5, 5, 5)
        cube.Position = cache.rootPart.Position + Vector3.new(0, -5, 0)
        cube.Anchored = true
        cube.CanCollide = true
        cube.Color = Color3.fromRGB(
            math.random(50, 255),
            math.random(50, 255),
            math.random(50, 255)
        )
        cube.Material = Enum.Material.Neon
        cube.Transparency = 0.3
        cube.Parent = Workspace
        
        -- Добавляем свечение
        local pointLight = Instance.new("PointLight")
        pointLight.Color = cube.Color
        pointLight.Brightness = 2
        pointLight.Range = 10
        pointLight.Parent = cube
        
        table.insert(spawnedCubes, cube)
        
        showNotification("Cube Spawned!", cube.Color, "◼")
        Utils.createParticles(cube.Position, cube.Color, 15)
        Utils.playSound(1.2)
    end
end)

-- Grenade Rain
local grenadeBtn = createButton(
    funTab,
    "GRENADE RAIN",
    "Spawn explosive rain",
    "💣",
    Color3.fromRGB(255, 50, 50),
    false
)

grenadeBtn.MouseButton1Click:Connect(function()
    Utils.updateCharacterCache()
    if cache.rootPart then
        for i = 1, 15 do
            spawn(function()
                local grenade = Instance.new("Part")
                grenade.Name = "Grenade"
                grenade.Shape = Enum.PartType.Ball
                grenade.Size = Vector3.new(2, 2, 2)
                grenade.Position = cache.rootPart.Position + Vector3.new(
                    math.random(-30, 30),
                    math.random(30, 50),
                    math.random(-30, 30)
                )
                grenade.Color = Color3.fromRGB(255, 50, 50)
                grenade.Material = Enum.Material.Neon
                grenade.Parent = Workspace
                
                -- Анимация падения
                local tween = TweenService:Create(grenade, TweenInfo.new(0.5), {
                    Position = grenade.Position - Vector3.new(0, 40, 0)
                })
                tween:Play()
                
                task.wait(0.5)
                
                local explosion = Instance.new("Explosion")
                explosion.Position = grenade.Position
                explosion.BlastRadius = 12
                explosion.BlastPressure = 1000
                explosion.DestroyJointRadiusPercent = 0
                explosion.Parent = Workspace
                
                Utils.createParticles(grenade.Position, Color3.fromRGB(255, 150, 50), 8)
                grenade:Destroy()
            end)
            task.wait(0.1)
        end
        
        showNotification("GRENADE RAIN!", Color3.fromRGB(255, 100, 100), "💣")
        Utils.playSound(0.7)
    end
end)

-- Clear Cubes
local clearBtn = createButton(
    funTab,
    "CLEAR CUBES",
    "Remove all spawned cubes",
    "🗑️",
    Color3.fromRGB(255, 150, 50),
    false
)

clearBtn.MouseButton1Click:Connect(function()
    local count = 0
    for _, cube in pairs(spawnedCubes) do
        if cube and cube.Parent then
            cube:Destroy()
            count = count + 1
        end
    end
    spawnedCubes = {}
    
    showNotification("Cleared " .. count .. " cubes", config.theme.success, "🗑️")
    Utils.playSound(0.9)
end)

-- ============================================
-- КРЕДИТЫ (ВКЛАДКА 5)
-- ============================================

local creditsTab = tabFrames[5]

local creditsFrame = Instance.new("Frame")
creditsFrame.Size = UDim2.new(1, 0, 1, 0)
creditsFrame.BackgroundTransparency = 1
creditsFrame.Parent = creditsTab

local creditsText = Instance.new("TextLabel")
creditsText.Size = UDim2.new(1, -20, 1, -20)
creditsText.Position = UDim2.new(0, 10, 0, 10)
creditsText.BackgroundTransparency = 1
creditsText.Font = Enum.Font.GothamBold
creditsText.Text = [[🎮 AGALIK HUB v5.1 | ULTIMATE 🎮

✨ CREATED BY: ]] .. player.Name .. [[ ✨

🌟 SPECIAL THANKS:
• Roblox - For the platform
• Prison Life - For the game
• You - For using this script!

🔥 FEATURES:
• NOCHIP - Walk through walls
• SPEED HACK - 3x speed boost
• INVISIBLE - Ghost mode
• SPINNER - Crazy rotation (NEW!)
• ESP - See all players
• X-RAY - Wallhack vision
• FULLBRIGHT - No darkness
• Teleports - Quick travel
• Fun Tools - Cubes & Grenades

⚠️ DISCLAIMER:
For educational purposes only!
Use at your own risk.

💖 Enjoy AGALIK HUB!]]
creditsText.TextColor3 = config.theme.text
creditsText.TextSize = 14
creditsText.TextXAlignment = Enum.TextXAlignment.Left
creditsText.TextYAlignment = Enum.TextYAlignment.Top
creditsText.TextWrapped = true
creditsText.Parent = creditsFrame

-- ============================================
-- УПРАВЛЕНИЕ МЕНЮ
-- ============================================

local menuVisible = false

local function toggleMenu()
    menuVisible = not menuVisible
    
    if menuVisible then
        mainFrame.Visible = true
        openButton.Visible = false
        
        if config.settings.animations then
            mainFrame.Size = UDim2.new(0, 10, 0, 10)
            mainFrame.Position = UDim2.new(0.5, -5, 0.5, -5)
            mainFrame.BackgroundTransparency = 1
            
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 480, 0, 450),
                Position = config.settings.menuPosition,
                BackgroundTransparency = 0
            }):Play()
        else
            mainFrame.Visible = true
            openButton.Visible = false
        end
    else
        if config.settings.animations then
            TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 10, 0, 10),
                Position = UDim2.new(0.5, -5, 0.5, -5),
                BackgroundTransparency = 1
            }):Play()
            
            task.wait(0.2)
            mainFrame.Visible = false
            mainFrame.Size = UDim2.new(0, 480, 0, 450)
            mainFrame.BackgroundTransparency = 0
        else
            mainFrame.Visible = false
        end
        
        openButton.Visible = true
    end
    
    Utils.playSound()
end

-- Кнопка принятия инструкции
acceptBtn.MouseButton1Click:Connect(function()
    if config.settings.animations then
        TweenService:Create(tutorialFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new(0.5, -5, 0.5, -5),
            BackgroundTransparency = 1
        }):Play()
        
        task.wait(0.3)
        tutorialFrame.Visible = false
    else
        tutorialFrame.Visible = false
    end
    
    openButton.Visible = true
    
    showNotification(Utils.t("notifications.loaded"), config.theme.accent, "🎮", 2)
    task.wait(0.5)
    showNotification(Utils.t("notifications.controls"), config.theme.warning, "⌨️", 2)
    
    config.settings.showTutorial = false
    Utils.playSound(1.1)
end)

-- Обработчики кнопок
openButton.MouseButton1Click:Connect(toggleMenu)
closeBtn.MouseButton1Click:Connect(toggleMenu)

-- Горячая клавиша
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        if not config.settings.showTutorial then
            toggleMenu()
        end
    end
end)

-- Перетаскивание окна с ограничениями
local dragging = false
local dragStart, startPos

local function clampPosition(position)
    local viewportSize = camera.ViewportSize
    local frameSize = mainFrame.AbsoluteSize
    
    local x = math.clamp(position.X.Offset, 0, viewportSize.X - frameSize.X)
    local y = math.clamp(position.Y.Offset, 0, viewportSize.Y - frameSize.Y)
    
    return UDim2.new(position.X.Scale, x, position.Y.Scale, y)
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
        
        mainFrame.Position = clampPosition(newPos)
        config.settings.menuPosition = mainFrame.Position
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ============================================
-- АВТООБНОВЛЕНИЕ КЭША ПЕРСОНАЖА
-- ============================================

player.CharacterAdded:Connect(function()
    Utils.updateCharacterCache()
    
    if cache.spinning then
        showNotification("Character changed - Spinner reactivated", config.theme.purple, "🌀", 1.5)
    end
end)

player.CharacterRemoving:Connect(function()
    cache.character = nil
    cache.humanoid = nil
    cache.rootPart = nil
end)

-- Первоначальное обновление кэша
Utils.updateCharacterCache()

-- ============================================
-- ЗАГРУЗКА И ИНИЦИАЛИЗАЦИЯ
-- ============================================

task.wait(1)

print("\n" .. string.rep("=", 60))
print("🚀 AGALIK HUB v5.1 | ULTIMATE EDITION")
print(string.rep("=", 60))
print("✅ Version: 5.1 - With Spinner Mode")
print("✅ Features: NOCHIP, SPEED, INVISIBLE, ESP, X-RAY")
print("✅ NEW: Spinner Mode (Press F to activate)")
print("✅ Optimized: Better performance, less lag")
print("✅ Visuals: Particles, animations, effects")
print(string.rep("=", 60))
print("🎮 Ready to use! Press RightControl to open menu")
print(string.rep("=", 60) .. "\n")

-- Показываем туториал при первом запуске
if config.settings.showTutorial then
    tutorialFrame.Visible = true
else
    tutorialFrame.Visible = false
    openButton.Visible = true
    
    showNotification(Utils.t("notifications.loaded"), config.theme.accent, "🎮", 2)
    task.wait(0.5)
    showNotification(Utils.t("notifications.controls"), config.theme.warning, "⌨️", 2)
end
