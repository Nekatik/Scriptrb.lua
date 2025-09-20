--[[
    Гипотетический скрипт для режима Steal a Brainrot в Roblox.
    Включает меню с функциями ESP: Игроки, Brainrot, База.
    Использует Drawing API для совместимости с мобильными платформами.
    AOIRUSRA Research Framework | 2025
--]]

-- Конфигурация
local BrainrotAssetId = 105845629652615 -- ID модели Brainrot
local CaptureZoneName = "CaptureZone" -- Имя части зоны захвата

-- Основные сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Таблицы для хранения ESP объектов
local ESPPlayers = {}
local ESPBrainrots = {}
local ESPBase = nil

-- Флаги состояния функций
local Settings = {
    ESPPlayers = false,
    ESPBrainrots = false,
    ESPBase = false,
    MenuVisible = true
}

-- Создание интерфейса меню
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotESPMenu"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 200)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "Steal a Brainrot ESP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 30, 0, 30)
ToggleButton.Position = UDim2.new(1, -30, 0, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Text = "-"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Parent = Frame

-- Функции переключения
local function CreateToggle(Name, Parent, YPosition, Callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 25)
    ToggleFrame.Position = UDim2.new(0, 5, 0, YPosition)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = Parent

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 1, 0)
    ToggleButton.Position = UDim2.new(1, -40, 0, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    ToggleButton.Text = "Off"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Parent = ToggleFrame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = ToggleButton

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    ToggleButton.MouseButton1Click:Connect(function()
        local newState = ToggleButton.Text == "Off"
        ToggleButton.Text = newState and "On" or "Off"
        ToggleButton.BackgroundColor3 = newState and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(80, 80, 80)
        Callback(newState)
    end)

    return ToggleFrame
end

-- Создание переключателей в меню
CreateToggle("ESP Players", Frame, 35, function(State)
    Settings.ESPPlayers = State
    if not State then
        for _, esp in pairs(ESPPlayers) do
            if esp.Text then esp.Text:Remove() end
            if esp.Tracer then esp.Tracer:Remove() end
        end
        ESPPlayers = {}
    end
end)

CreateToggle("ESP Brainrot", Frame, 65, function(State)
    Settings.ESPBrainrots = State
    if not State then
        for _, esp in pairs(ESPBrainrots) do
            if esp.Text then esp.Text:Remove() end
            if esp.Tracer then esp.Tracer:Remove() end
        end
        ESPBrainrots = {}
    end
end)

CreateToggle("ESP Base", Frame, 95, function(State)
    Settings.ESPBase = State
    if not State and ESPBase then
        for _, part in pairs(ESPBase) do
            if part then part:Remove() end
        end
        ESPBase = nil
    end
end)

-- Кнопка сворачивания/разворачивания меню
ToggleButton.MouseButton1Click:Connect(function()
    Settings.MenuVisible = not Settings.MenuVisible
    local targetSize = Settings.MenuVisible and UDim2.new(0, 200, 0, 200) or UDim2.new(0, 200, 0, 30)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(Frame, tweenInfo, {Size = targetSize})
    tween:Play()
    ToggleButton.Text = Settings.MenuVisible and "-" or "+"
end)

-- Функция обновления ESP игроков
local function UpdatePlayerESP()
    if not Settings.ESPPlayers then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if humanoidRootPart and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                
                if onScreen then
                    if not ESPPlayers[player] then
                        -- Создаем текст для игрока
                        local Text = Drawing.new("Text")
                        Text.Text = player.Name
                        Text.Size = 16
                        Text.Color = Color3.new(1, 1, 1)
                        Text.Outline = true
                        Text.OutlineColor = Color3.new(0, 0, 0)
                        Text.Center = true
                        
                        -- Создаем линию (трасер)
                        local Tracer = Drawing.new("Line")
                        Tracer.Color = Color3.new(1, 0, 0)
                        Tracer.Thickness = 1
                        
                        ESPPlayers[player] = {Text = Text, Tracer = Tracer}
                    end
                    
                    -- Обновляем позицию текста
                    ESPPlayers[player].Text.Position = Vector2.new(screenPos.X, screenPos.Y)
                    
                    -- Обновляем позицию трасера (от низа экрана к игроку)
                    local ViewportSize = Workspace.CurrentCamera.ViewportSize
                    ESPPlayers[player].Tracer.From = Vector2.new(ViewportSize.X / 2, ViewportSize.Y)
                    ESPPlayers[player].Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                else
                    -- Игрок не на экране, удаляем ESP
                    if ESPPlayers[player] then
                        ESPPlayers[player].Text:Remove()
                        ESPPlayers[player].Tracer:Remove()
                        ESPPlayers[player] = nil
                    end
                end
            else
                -- Игрок мертв или не имеет нужных частей, удаляем ESP
                if ESPPlayers[player] then
                    ESPPlayers[player].Text:Remove()
                    ESPPlayers[player].Tracer:Remove()
                    ESPPlayers[player] = nil
                end
            end
        else
            -- Игрок не подходит, удаляем ESP
            if ESPPlayers[player] then
                ESPPlayers[player].Text:Remove()
                ESPPlayers[player].Tracer:Remove()
                ESPPlayers[player] = nil
            end
        end
    end
end

-- Функция обновления ESP Brainrot
local function UpdateBrainrotESP()
    if not Settings.ESPBrainrots then return end

    -- Ищем все объекты Brainrot в рабочем пространстве
    for _, object in ipairs(Workspace:GetChildren()) do
        if object.Name == "Brainrot" or (object:IsA("Model") and object:GetAttribute("BrainrotAsset") == BrainrotAssetId) then
            local primaryPart = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
            
            if primaryPart then
                local screenPos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(primaryPart.Position)
                
                if onScreen then
                    if not ESPBrainrots[object] then
                        -- Создаем текст для Brainrot
                        local Text = Drawing.new("Text")
                        Text.Text = "Brainrot"
                        Text.Size = 16
                        Text.Color = Color3.new(0, 1, 0)
                        Text.Outline = true
                        Text.OutlineColor = Color3.new(0, 0, 0)
                        Text.Center = true
                        
                        -- Создаем линию (трасер)
                        local Tracer = Drawing.new("Line")
                        Tracer.Color = Color3.new(0, 1, 0)
                        Tracer.Thickness = 1
                        
                        ESPBrainrots[object] = {Text = Text, Tracer = Tracer}
                    end
                    
                    -- Обновляем позицию текста
                    ESPBrainrots[object].Text.Position = Vector2.new(screenPos.X, screenPos.Y)
                    
                    -- Обновляем позицию трасера (от низа экрана к объекту)
                    local ViewportSize = Workspace.CurrentCamera.ViewportSize
                    ESPBrainrots[object].Tracer.From = Vector2.new(ViewportSize.X / 2, ViewportSize.Y)
                    ESPBrainrots[object].Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                else
                    -- Объект не на экране, удаляем ESP
                    if ESPBrainrots[object] then
                        ESPBrainrots[object].Text:Remove()
                        ESPBrainrots[object].Tracer:Remove()
                        ESPBrainrots[object] = nil
                    end
                end
            end
        else
            -- Это не Brainrot, удаляем ESP если он был
            if ESPBrainrots[object] then
                ESPBrainrots[object].Text:Remove()
                ESPBrainrots[object].Tracer:Remove()
                ESPBrainrots[object] = nil
            end
        end
    end
end

-- Функция обновления ESP Базы (зоны захвата)
local function UpdateBaseESP()
    if not Settings.ESPBase then
        if ESPBase then
            for _, part in pairs(ESPBase) do
                if part then part:Remove() end
            end
            ESPBase = nil
        end
        return
    end

    -- Ищем зону захвата в рабочем пространстве
    local zone = Workspace:FindFirstChild(CaptureZoneName)
    if zone and zone:IsA("BasePart") then
        if not ESPBase then
            -- Создаем эффект подсветки для зоны
            ESPBase = {}
            
            -- Создаем рамку вокруг зоны
            local highlight = Instance.new("BoxHandleAdornment")
            highlight.Name = "ESPBaseHighlight"
            highlight.Adornee = zone
            highlight.AlwaysOnTop = true
            highlight.ZIndex = 1
            highlight.Size = zone.Size
            highlight.Color3 = Color3.new(1, 0.5, 0) -- Оранжевый цвет
            highlight.Transparency = 0.5
            highlight.Parent = zone
            
            table.insert(ESPBase, highlight)
            
            -- Создаем текст над зоной
            local screenPos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(zone.Position + Vector3.new(0, zone.Size.Y/2 + 2, 0))
            if onScreen then
                local text = Drawing.new("Text")
                text.Text = "Capture Zone"
                text.Size = 18
                text.Color = Color3.new(1, 0.5, 0)
                text.Outline = true
                text.OutlineColor = Color3.new(0, 0, 0)
                text.Center = true
                text.Position = Vector2.new(screenPos.X, screenPos.Y)
                table.insert(ESPBase, text)
            end
        end
    else
        -- Зона не найдена, очищаем ESP
        if ESPBase then
            for _, part in pairs(ESPBase) do
                if part then part:Remove() end
            end
            ESPBase = nil
        end
    end
end

-- Основной цикл обновления
RunService.RenderStepped:Connect(function()
    UpdatePlayerESP()
    UpdateBrainrotESP()
    UpdateBaseESP()
end)

-- Функция очистки при отключении скрипта
local function Cleanup()
    for _, esp in pairs(ESPPlayers) do
        if esp.Text then esp.Text:Remove() end
        if esp.Tracer then esp.Tracer:Remove() end
    end
    ESPPlayers = {}

    for _, esp in pairs(ESPBrainrots) do
        if esp.Text then esp.Text:Remove() end
        if esp.Tracer then esp.Tracer:Remove() end
    end
    ESPBrainrots = {}

    if ESPBase then
        for _, part in pairs(ESPBase) do
            if part then part:Remove() end
        end
        ESPBase = nil
    end

    if ScreenGui then
        ScreenGui:Destroy()
    end
end

-- Очистка при отключении скрипта
game:GetService("UserInputService").WindowFocused:Connect(Cleanup)
LocalPlayer.CharacterRemoving:Connect(Cleanup)
