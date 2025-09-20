```lua
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileESPMenu"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local mainButton = Instance.new("ImageButton")
mainButton.Name = "MainButton"
mainButton.Size = UDim2.new(0, 70, 0, 70)
mainButton.Position = UDim2.new(0.02, 0, 0.85, 0)
mainButton.Image = "rbxassetid://7072716642"
mainButton.ScaleType = Enum.ScaleType.Fit
mainButton.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
mainButton.AutoButtonColor = true
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 250, 0, 200)
menuFrame.Position = UDim2.new(0, -260, 0.5, -100)
menuFrame.AnchorPoint = Vector2.new(0, 0.5)
menuFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
menuFrame.BorderSizePixel = 0
local espButton = Instance.new("TextButton")
espButton.Name = "ESPButton"
espButton.Size = UDim2.new(0.9, 0, 0, 60)
espButton.Position = UDim2.new(0.05, 0, 0.1, 0)
espButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.Text = "🔄 Show Brainrot"
espButton.TextScaled = true
espButton.Font = Enum.Font.GothamBold
espButton.Parent = menuFrame
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0.9, 0, 0, 40)
statusLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Text = "Ready to work"
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = menuFrame
mainButton.Parent = screenGui
menuFrame.Parent = screenGui
screenGui.Parent = playerGui
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local menuVisible = false
local function toggleMenu()
    menuVisible = not menuVisible
    local targetPosition = menuVisible and UDim2.new(0.02, 0, 0.5, -100) or UDim2.new(0, -260, 0.5, -100)
    local tween = TweenService:Create(menuFrame, tweenInfo, {Position = targetPosition})
    tween:Play()
end
mainButton.MouseButton1Click:Connect(toggleMenu)
mainButton.TouchTap:Connect(toggleMenu)
local espEnabled = false
local brainrotEspFolders = {}
local brainrotModule
local function loadBrainrotModule()
    if brainrotModule then return true end
    local success, result = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Brainrots"))
    end)
    if success then
        brainrotModule = result
        return true
    else
        statusLabel.Text = "Module load error"
        return false
    end
end
local function createEspLabel(brainrotModel)
    if not loadBrainrotModule() then return end
    local success, data = pcall(function()
        return brainrotModule.FindById(brainrotModel.Name)
    end)
    if not success or not data then return end
    local targetPart = brainrotModel.PrimaryPart or brainrotModel:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "BrainrotESP"
    billboardGui.Adornee = targetPart
    billboardGui.Size = UDim2.new(0, 120, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.MaxDistance = 150
    billboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 0.7
    textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Text = data.Name
    textLabel.TextColor3 = Color3.fromRGB(255, 105, 180)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboardGui
    if not brainrotEspFolders[brainrotModel] then
        brainrotEspFolders[brainrotModel] = {}
    end
    table.insert(brainrotEspFolders[brainrotModel], billboardGui)
    billboardGui.Parent = brainrotModel
    return true
end
local function updateEsp()
    for brainrotModel, labels in pairs(brainrotEspFolders) do
        if not brainrotModel or not brainrotModel.Parent then
            for _, label in ipairs(labels) do
                pcall(function() label:Destroy() end)
            end
            brainrotEspFolders[brainrotModel] = nil
        end
    end
end
local function toggleEsp()
    if not loadBrainrotModule() then
        statusLabel.Text = "Error: Module not found"
        return
    end
    espEnabled = not espEnabled
    statusLabel.Text = espEnabled and "Searching Brainrot..." or "ESP disabled"
    espButton.Text = espEnabled and "❌ Hide Brainrot" or "🔄 Show Brainrot"
    if espEnabled then
        local found = 0
        for _, object in ipairs(workspace:GetChildren()) do
            local success = pcall(function()
                local data = brainrotModule.FindById(object.Name)
                if data then
                    if createEspLabel(object) then
                        found = found + 1
                    end
                end
            end)
        end
        statusLabel.Text = "Found: " .. found .. " Brainrot"
        local connection
        connection = workspace.ChildAdded:Connect(function(child)
            task.wait(0.5)
            pcall(function()
                local data = brainrotModule.FindById(child.Name)
                if data then
                    createEspLabel(child)
                    statusLabel.Text = "New Brainrot found!"
                    task.wait(2)
                    statusLabel.Text = "Monitoring active"
                end
            end)
        end)
        brainrotEspFolders._connection = connection
        brainrotEspFolders._renderConnection = RunService.RenderStepped:Connect(updateEsp)
    else
        if brainrotEspFolders._connection then
            brainrotEspFolders._connection:Disconnect()
        end
        if brainrotEspFolders._renderConnection then
            brainrotEspFolders._renderConnection:Disconnect()
        end
        for brainrotModel, labels in pairs(brainrotEspFolders) do
            for _, label in ipairs(labels) do
                pcall(function() label:Destroy() end)
            end
        end
        brainrotEspFolders = {}
    end
end
espButton.MouseButton1Click:Connect(toggleEsp)
espButton.TouchTap:Connect(toggleEsp)
if UserInputService.TouchEnabled then
    mainButton.Size = UDim2.new(0, 80, 0, 80)
    menuFrame.Size = UDim2.new(0, 280, 0, 220)
    espButton.Size = UDim2.new(0.9, 0, 0, 70)
    espButton.TextSize = 18
end
statusLabel.Text = "System ready. Press button"
print("Brainrot ESP Menu loaded successfully!")
```
