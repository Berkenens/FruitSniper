--=============================================================================

--=============================================================================
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")


if CoreGui:FindFirstChild("Adminus") then
    CoreGui.Adminus:Destroy()
end

self = {}
self.Adminus = Instance.new("ScreenGui")
self.Main = Instance.new("Frame")
self.UIGradient = Instance.new("UIGradient")
self.UICorner = Instance.new("UICorner")
self.Title = Instance.new("TextLabel")
self.Subtitle = Instance.new("TextLabel")
self.Holder = Instance.new("Frame")
self.UICorner_2 = Instance.new("UICorner")


self.information = Instance.new("Frame")
self.UIListLayout = Instance.new("UIListLayout")
self.Status = Instance.new("TextLabel")
self.TweenStatus = Instance.new("TextLabel")
self.StoringStatus = Instance.new("TextLabel")
self.FruitDistance = Instance.new("TextLabel")
self.FruitType = Instance.new("TextLabel")
self.UIPadding = Instance.new("UIPadding")


self.settings = Instance.new("Frame")
self.UIListLayout_2 = Instance.new("UIListLayout")


self.Buttons = Instance.new("Frame")
self.UIListLayout_3 = Instance.new("UIListLayout")
self.Status_2 = Instance.new("TextButton") 
self.UICorner_7 = Instance.new("UICorner")
self.UIStroke_5 = Instance.new("UIStroke")
self.Settings = Instance.new("TextButton") 
self.UICorner_8 = Instance.new("UICorner")
self.UIStroke_6 = Instance.new("UIStroke")


self.Notifications = Instance.new("Frame")
self.NotificationTemplate = Instance.new("Frame")


self.Adminus.Name = "Adminus"
self.Adminus.Parent = CoreGui
self.Adminus.ResetOnSpawn = false

self.Main.Name = "Main"
self.Main.Parent = self.Adminus
self.Main.AnchorPoint = Vector2.new(0.5, 0.5)
self.Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
self.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
self.Main.Size = UDim2.new(0, 551, 0, 364)

self.Main.GroupTransparency = 1 
self.Main.Size = UDim2.new(0, 500, 0, 330)

self.UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)), 
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(101, 20, 136))
}
self.UIGradient.Rotation = 75
self.UIGradient.Parent = self.Main

self.UICorner.CornerRadius = UDim.new(0, 5)
self.UICorner.Parent = self.Main

self.Title.Name = "Title"
self.Title.Parent = self.Main
self.Title.BackgroundTransparency = 1.000
self.Title.Position = UDim2.new(0.027, 0, 0.068, 0)
self.Title.Size = UDim2.new(0, 200, 0, 20)
self.Title.Font = Enum.Font.GothamBold
self.Title.Text = "ADMINUS | Fruit Sniper"
self.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
self.Title.TextSize = 16.000
self.Title.TextXAlignment = Enum.TextXAlignment.Left

self.Subtitle.Name = "Subtitle"
self.Subtitle.Parent = self.Main
self.Subtitle.BackgroundTransparency = 1.000
self.Subtitle.Position = UDim2.new(0.027, 0, 0.144, 0)
self.Subtitle.Size = UDim2.new(0, 276, 0, 35)
self.Subtitle.Font = Enum.Font.Gotham
self.Subtitle.Text = "Automated fruit targeting and storage system."
self.Subtitle.TextColor3 = Color3.fromRGB(202, 202, 202)
self.Subtitle.TextSize = 12.000
self.Subtitle.TextWrapped = true
self.Subtitle.TextXAlignment = Enum.TextXAlignment.Left

self.Holder.Name = "Holder"
self.Holder.Parent = self.Main
self.Holder.AnchorPoint = Vector2.new(0.5, 1)
self.Holder.BackgroundTransparency = 0.900
self.Holder.Position = UDim2.new(0.5, 0, 0.958, 0)
self.Holder.Size = UDim2.new(0, 521, 0, 216)

self.UICorner_2.CornerRadius = UDim.new(0, 5)
self.UICorner_2.Parent = self.Holder


self.information.Name = "information"
self.information.Parent = self.Holder
self.information.AnchorPoint = Vector2.new(0.5, 0.5)
self.information.BackgroundTransparency = 1.000
self.information.Position = UDim2.new(0.5, 0, 0.5, 0)
self.information.Size = UDim2.new(1, 0, 1, 0)

self.UIListLayout.Parent = self.information
self.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
self.UIListLayout.Padding = UDim.new(0, 15)


local function createStatusLabel(name, text, layoutOrder)
    local lbl = Instance.new("TextLabel")
    lbl.Name = name
    lbl.Parent = self.information
    lbl.BackgroundTransparency = 1.000
    lbl.Size = UDim2.new(0, 400, 0, 24)
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 14.000
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.RichText = true
    lbl.LayoutOrder = layoutOrder
    return lbl
end

self.Status = createStatusLabel("Status", "Status: <font color='rgb(255,255,0)'>Waiting...</font>", 1)
self.TweenStatus = createStatusLabel("TweenStatus", "Tweening Status: <font color='rgb(150,150,150)'>Idle</font>", 2)
self.StoringStatus = createStatusLabel("StoringStatus", "Storing Status: <font color='rgb(150,150,150)'>Idle</font>", 3)
self.FruitDistance = createStatusLabel("FruitDistance", "Fruit Distance: <font color='rgb(150,150,150)'>0</font>", 4)
self.FruitType = createStatusLabel("FruitType", "Fruit Type: <font color='rgb(150,150,150)'>None</font>", 5)

self.UIPadding.Parent = self.information
self.UIPadding.PaddingLeft = UDim.new(0, 20)


self.settings.Name = "settings"
self.settings.Parent = self.Holder
self.settings.AnchorPoint = Vector2.new(0.5, 0.5)
self.settings.BackgroundTransparency = 1.000
self.settings.Position = UDim2.new(0.5, 0, 0.5, 0)
self.settings.Size = UDim2.new(1, 0, 1, 0)
self.settings.Visible = false


self.Buttons.Name = "Buttons"
self.Buttons.Parent = self.Main
self.Buttons.BackgroundTransparency = 1.000
self.Buttons.Position = UDim2.new(0, 15, 0.35, 0)
self.Buttons.Size = UDim2.new(0, 521, 0, 40)

self.UIListLayout_3.Parent = self.Buttons
self.UIListLayout_3.FillDirection = Enum.FillDirection.Horizontal
self.UIListLayout_3.Padding = UDim.new(0, 10)

self.Status_2.Name = "StatusBtn"
self.Status_2.Parent = self.Buttons
self.Status_2.BackgroundTransparency = 0.5
self.Status_2.Size = UDim2.new(0, 100, 0, 30)
self.Status_2.Font = Enum.Font.GothamBold
self.Status_2.Text = "STATUS"
self.Status_2.TextColor3 = Color3.fromRGB(255, 255, 255)
self.Status_2.TextSize = 14.000
Instance.new("UICorner", self.Status_2).CornerRadius = UDim.new(0, 6)

self.Settings.Name = "SettingsBtn"
self.Settings.Parent = self.Buttons
self.Settings.BackgroundTransparency = 0.9
self.Settings.Size = UDim2.new(0, 100, 0, 30)
self.Settings.Font = Enum.Font.GothamBold
self.Settings.Text = "SETTINGS"
self.Settings.TextColor3 = Color3.fromRGB(150, 150, 150)
self.Settings.TextSize = 14.000
Instance.new("UICorner", self.Settings).CornerRadius = UDim.new(0, 6)

--=============================================================================

--=============================================================================
local function switchTab(activeTab, inactiveTab, activeButton, inactiveButton)
    activeTab.Visible = true
    inactiveTab.Visible = false
    

    TweenService:Create(activeButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.5,
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    TweenService:Create(inactiveButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.9,
        TextColor3 = Color3.fromRGB(150, 150, 150)
    }):Play()
end

self.Status_2.MouseButton1Click:Connect(function()
    switchTab(self.information, self.settings, self.Status_2, self.Settings)
end)

self.Settings.MouseButton1Click:Connect(function()
    switchTab(self.settings, self.information, self.Settings, self.Status_2)
end)

--=============================================================================

--=============================================================================
local dragging, dragInput, dragStart, startPos
self.Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = self.Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

self.Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        self.Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X, 
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

--=============================================================================

--=============================================================================
local openTween = TweenService:Create(
    self.Main, 
    TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
    {
        Size = UDim2.new(0, 551, 0, 364),
        GroupTransparency = 0 
    }
)
openTween:Play()

return self
