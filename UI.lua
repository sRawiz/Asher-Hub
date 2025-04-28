local UI = {}
UI.__index = UI

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Discord-like colors
local Colors = {
    Background = Color3.fromRGB(54, 57, 63),       -- Main background
    SecondaryBg = Color3.fromRGB(47, 49, 54),      -- Secondary background
    Accent = Color3.fromRGB(114, 137, 218),        -- Discord blurple
    TextPrimary = Color3.fromRGB(255, 255, 255),   -- White text
    TextSecondary = Color3.fromRGB(185, 187, 190), -- Light gray text
    StatusOn = Color3.fromRGB(67, 181, 129),       -- Green for "ON" status
    StatusOff = Color3.fromRGB(240, 71, 71),       -- Red for "OFF" status
    HighlightButton = Color3.fromRGB(88, 101, 242) -- Brighter accent for buttons
}

function UI.new(config)
    local self = setmetatable({}, UI)

    self.Config = config or {
        FlySpeed = 25,
        MaxSpeed = 100,
        MinSpeed = 5,
        SpeedIncrement = 5,
        WalkSpeed = 16,
        MaxWalkSpeed = 50,
        MinWalkSpeed = 10
    }

    self.UIVisible = true
    self.IsFlying = false
    self.IsNoClipping = false
    self.IsInvisible = false
    self.IsWalkSpeedModified = false

    -- Callback functions (to be set by Main.lua)
    self.OnToggleFly = function() end
    self.OnToggleNoClip = function() end
    self.OnToggleInvisible = function() end
    self.OnIncreaseSpeed = function() end
    self.OnDecreaseSpeed = function() end
    self.OnToggleWalkSpeed = function() end
    self.OnIncreaseWalkSpeed = function() end
    self.OnDecreaseWalkSpeed = function() end

    -- Create UI
    self:CreateUI()

    return self
end

function UI:CreateUI()
    -- Create ScreenGui
    self.AsherHubGui = Instance.new("ScreenGui")
    self.AsherHubGui.Name = "AsherHubGui"
    self.AsherHubGui.ResetOnSpawn = false

    -- Try to set Parent to CoreGui for persistence across character respawns
    local success, result = pcall(function()
        self.AsherHubGui.Parent = CoreGui
        return true
    end)

    if not success then
        self.AsherHubGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Create Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 300, 0, 230) -- Changed width from 220 to 300
    self.MainFrame.Position = UDim2.new(0.85, -150, 0.3, 0) -- Adjusted position
    self.MainFrame.BackgroundColor3 = Colors.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true
    self.MainFrame.Parent = self.AsherHubGui

    -- Add rounded corners to Frame
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = self.MainFrame

    -- Add Shadow Effect
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.ZIndex = -1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.Parent = self.MainFrame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Colors.SecondaryBg
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = self.MainFrame

    -- Title Bar Corners
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar

    -- Fix Title Bar lower corners
    local FixCorners = Instance.new("Frame")
    FixCorners.Size = UDim2.new(1, 0, 0, 15)
    FixCorners.Position = UDim2.new(0, 0, 0.5, 0)
    FixCorners.BackgroundColor3 = Colors.SecondaryBg
    FixCorners.BorderSizePixel = 0
    FixCorners.Parent = TitleBar

    -- Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Size = UDim2.new(1, -40, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "AsherHub"
    TitleText.TextColor3 = Colors.TextPrimary
    TitleText.TextSize = 16
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    -- Close Button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 24, 0, 24)
    self.CloseButton.Position = UDim2.new(1, -27, 0, 3)
    self.CloseButton.BackgroundColor3 = Colors.StatusOff
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = Colors.TextPrimary
    self.CloseButton.TextSize = 18
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.Parent = TitleBar

    -- Close Button Round Corners
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = self.CloseButton

    -- Status Section
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Name = "StatusFrame"
    StatusFrame.Size = UDim2.new(1, -20, 0, 85) -- Increased height for Invisible status
    StatusFrame.Position = UDim2.new(0, 10, 0, 40)
    StatusFrame.BackgroundColor3 = Colors.SecondaryBg
    StatusFrame.BorderSizePixel = 0
    StatusFrame.Parent = self.MainFrame

    -- Status Section Round Corners
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 6)
    StatusCorner.Parent = StatusFrame

    -- Fly Status
    self.FlyStatus = Instance.new("TextLabel")
    self.FlyStatus.Name = "FlyStatus"
    self.FlyStatus.Size = UDim2.new(0.5, -5, 0, 25)
    self.FlyStatus.Position = UDim2.new(0, 10, 0, 5)
    self.FlyStatus.BackgroundColor3 = Colors.Background
    self.FlyStatus.BorderSizePixel = 0
    self.FlyStatus.Text = "Fly: OFF"
    self.FlyStatus.TextColor3 = Colors.StatusOff
    self.FlyStatus.TextSize = 14
    self.FlyStatus.Font = Enum.Font.Gotham
    self.FlyStatus.Parent = StatusFrame

    -- Fly Status Round Corners
    local FlyStatusCorner = Instance.new("UICorner")
    FlyStatusCorner.CornerRadius = UDim.new(0, 4)
    FlyStatusCorner.Parent = self.FlyStatus

    -- NoClip Status
    self.NoClipStatus = Instance.new("TextLabel")
    self.NoClipStatus.Name = "NoClipStatus"
    self.NoClipStatus.Size = UDim2.new(0.5, -5, 0, 25)
    self.NoClipStatus.Position = UDim2.new(0.5, -5, 0, 5)
    self.NoClipStatus.BackgroundColor3 = Colors.Background
    self.NoClipStatus.BorderSizePixel = 0
    self.NoClipStatus.Text = "NoClip: OFF"
    self.NoClipStatus.TextColor3 = Colors.StatusOff
    self.NoClipStatus.TextSize = 14
    self.NoClipStatus.Font = Enum.Font.Gotham
    self.NoClipStatus.Parent = StatusFrame

    -- Walk Speed Status Round Corners
    local WalkSpeedStatusCorner = Instance.new("UICorner")
    WalkSpeedStatusCorner.CornerRadius = UDim.new(0, 4)
    WalkSpeedStatusCorner.Parent = self.WalkSpeedStatus

    -- WalkSpeed Status
    self.WalkSpeedStatus = Instance.new("TextLabel")
    self.WalkSpeedStatus.Name = "WalkSpeedStatus"
    self.WalkSpeedStatus.Size = UDim2.new(0.5, -5, 0, 25)
    self.WalkSpeedStatus.Position = UDim2.new(0.5, -5, 0, 35) -- Position right of NoClip
    self.WalkSpeedStatus.BackgroundColor3 = Colors.Background
    self.WalkSpeedStatus.BorderSizePixel = 0
    self.WalkSpeedStatus.Text = "Speed: OFF"
    self.WalkSpeedStatus.TextColor3 = Colors.StatusOff
    self.WalkSpeedStatus.TextSize = 14
    self.WalkSpeedStatus.Font = Enum.Font.Gotham
    self.WalkSpeedStatus.Parent = StatusFrame

    -- Invisible Status
    self.InvisibleStatus = Instance.new("TextLabel")
    self.InvisibleStatus.Name = "InvisibleStatus"
    self.InvisibleStatus.Size = UDim2.new(1, -20, 0, 25)
    self.InvisibleStatus.Position = UDim2.new(0, 10, 0, 35)
    self.InvisibleStatus.BackgroundColor3 = Colors.Background
    self.InvisibleStatus.BorderSizePixel = 0
    self.InvisibleStatus.Text = "Invisible: OFF"
    self.InvisibleStatus.TextColor3 = Colors.StatusOff
    self.InvisibleStatus.TextSize = 14
    self.InvisibleStatus.Font = Enum.Font.Gotham
    self.InvisibleStatus.Parent = StatusFrame

    -- Invisible Status Round Corners
    local InvisibleStatusCorner = Instance.new("UICorner")
    InvisibleStatusCorner.CornerRadius = UDim.new(0, 4)
    InvisibleStatusCorner.Parent = self.InvisibleStatus

    -- Speed Label
    self.SpeedLabel = Instance.new("TextLabel")
    self.SpeedLabel.Name = "SpeedLabel"
    self.SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
    self.SpeedLabel.Position = UDim2.new(0, 10, 0, 65)
    self.SpeedLabel.BackgroundTransparency = 1
    self.SpeedLabel.Text = "Speed: " .. self.Config.FlySpeed
    self.SpeedLabel.TextColor3 = Colors.TextPrimary
    self.SpeedLabel.TextSize = 14
    self.SpeedLabel.Font = Enum.Font.Gotham
    self.SpeedLabel.Parent = StatusFrame

    -- Controls Section
    local ControlsFrame = Instance.new("Frame")
    ControlsFrame.Name = "ControlsFrame"
    ControlsFrame.Size = UDim2.new(1, -20, 0, 95)     -- Increased height for Invisible button
    ControlsFrame.Position = UDim2.new(0, 10, 0, 135) -- Adjusted position
    ControlsFrame.BackgroundColor3 = Colors.SecondaryBg
    ControlsFrame.BorderSizePixel = 0
    ControlsFrame.Parent = self.MainFrame

    -- Controls Section Round Corners
    local ControlsCorner = Instance.new("UICorner")
    ControlsCorner.CornerRadius = UDim.new(0, 6)
    ControlsCorner.Parent = ControlsFrame

    -- First row of buttons
    -- Toggle Fly Button
    self.ToggleFlyButton = Instance.new("TextButton")
    self.ToggleFlyButton.Name = "ToggleFlyButton"
    self.ToggleFlyButton.Size = UDim2.new(0.5, -15, 0, 30)
    self.ToggleFlyButton.Position = UDim2.new(0, 10, 0, 10)
    self.ToggleFlyButton.BackgroundColor3 = Colors.HighlightButton
    self.ToggleFlyButton.Text = "Fly (E)"
    self.ToggleFlyButton.TextColor3 = Colors.TextPrimary
    self.ToggleFlyButton.TextSize = 14
    self.ToggleFlyButton.Font = Enum.Font.GothamSemibold
    self.ToggleFlyButton.Parent = ControlsFrame

    -- Toggle Fly Button Round Corners
    local FlyButtonCorner = Instance.new("UICorner")
    FlyButtonCorner.CornerRadius = UDim.new(0, 4)
    FlyButtonCorner.Parent = self.ToggleFlyButton

    -- Toggle NoClip Button
    self.ToggleNoClipButton = Instance.new("TextButton")
    self.ToggleNoClipButton.Name = "ToggleNoClipButton"
    self.ToggleNoClipButton.Size = UDim2.new(0.5, -15, 0, 30)
    self.ToggleNoClipButton.Position = UDim2.new(0.5, 5, 0, 10)
    self.ToggleNoClipButton.BackgroundColor3 = Colors.HighlightButton
    self.ToggleNoClipButton.Text = "NoClip (C)"
    self.ToggleNoClipButton.TextColor3 = Colors.TextPrimary
    self.ToggleNoClipButton.TextSize = 14
    self.ToggleNoClipButton.Font = Enum.Font.GothamSemibold
    self.ToggleNoClipButton.Parent = ControlsFrame

    -- Toggle NoClip Button Round Corners
    local NoClipButtonCorner = Instance.new("UICorner")
    NoClipButtonCorner.CornerRadius = UDim.new(0, 4)
    NoClipButtonCorner.Parent = self.ToggleNoClipButton

    -- Toggle Walk Speed Button
    self.ToggleWalkSpeedButton = Instance.new("TextButton")
    self.ToggleWalkSpeedButton.Name = "ToggleWalkSpeedButton"
    self.ToggleWalkSpeedButton.Size = UDim2.new(0.5, -15, 0, 30)
    self.ToggleWalkSpeedButton.Position = UDim2.new(0, 10, 0, 80) -- Position below Invisible
    self.ToggleWalkSpeedButton.BackgroundColor3 = Colors.HighlightButton
    self.ToggleWalkSpeedButton.Text = "Walk Speed (R)"
    self.ToggleWalkSpeedButton.TextColor3 = Colors.TextPrimary
    self.ToggleWalkSpeedButton.TextSize = 14
    self.ToggleWalkSpeedButton.Font = Enum.Font.GothamSemibold
    self.ToggleWalkSpeedButton.Parent = ControlsFrame

    -- Toggle Walk Speed Button Round Corners
    local WalkSpeedButtonCorner = Instance.new("UICorner")
    WalkSpeedButtonCorner.CornerRadius = UDim.new(0, 4)
    WalkSpeedButtonCorner.Parent = self.ToggleWalkSpeedButton

    -- Toggle Invisible Button
    self.ToggleInvisibleButton = Instance.new("TextButton")
    self.ToggleInvisibleButton.Name = "ToggleInvisibleButton"
    self.ToggleInvisibleButton.Size = UDim2.new(1, -20, 0, 30)
    self.ToggleInvisibleButton.Position = UDim2.new(0, 10, 0, 45)
    self.ToggleInvisibleButton.BackgroundColor3 = Colors.HighlightButton
    self.ToggleInvisibleButton.Text = "Invisible (X)"
    self.ToggleInvisibleButton.TextColor3 = Colors.TextPrimary
    self.ToggleInvisibleButton.TextSize = 14
    self.ToggleInvisibleButton.Font = Enum.Font.GothamSemibold
    self.ToggleInvisibleButton.Parent = ControlsFrame

    -- Toggle Invisible Button Round Corners
    local InvisibleButtonCorner = Instance.new("UICorner")
    InvisibleButtonCorner.CornerRadius = UDim.new(0, 4)
    InvisibleButtonCorner.Parent = self.ToggleInvisibleButton

    -- Speed Control Frame
    local SpeedControlFrame = Instance.new("Frame")
    SpeedControlFrame.Name = "SpeedControlFrame"
    SpeedControlFrame.Size = UDim2.new(1, -20, 0, 25)
    SpeedControlFrame.Position = UDim2.new(0, 10, 0, 80) -- Adjusted position
    SpeedControlFrame.BackgroundTransparency = 1
    SpeedControlFrame.Parent = ControlsFrame

    -- Speed Decrease Button
    self.SpeedDecreaseButton = Instance.new("TextButton")
    self.SpeedDecreaseButton.Name = "SpeedDecreaseButton"
    self.SpeedDecreaseButton.Size = UDim2.new(0, 25, 0, 25)
    self.SpeedDecreaseButton.Position = UDim2.new(0, 0, 0, 0)
    self.SpeedDecreaseButton.BackgroundColor3 = Colors.StatusOff
    self.SpeedDecreaseButton.Text = "-"
    self.SpeedDecreaseButton.TextColor3 = Colors.TextPrimary
    self.SpeedDecreaseButton.TextSize = 18
    self.SpeedDecreaseButton.Font = Enum.Font.GothamBold
    self.SpeedDecreaseButton.Parent = SpeedControlFrame

    -- Speed Decrease Button Round Corners
    local DecreaseCorner = Instance.new("UICorner")
    DecreaseCorner.CornerRadius = UDim.new(0, 4)
    DecreaseCorner.Parent = self.SpeedDecreaseButton

    -- Speed Bar
    local SpeedBar = Instance.new("Frame")
    SpeedBar.Name = "SpeedBar"
    SpeedBar.Size = UDim2.new(1, -60, 0, 25)
    SpeedBar.Position = UDim2.new(0, 30, 0, 0)
    SpeedBar.BackgroundColor3 = Colors.Background
    SpeedBar.BorderSizePixel = 0
    SpeedBar.Parent = SpeedControlFrame

    -- Speed Bar Round Corners
    local SpeedBarCorner = Instance.new("UICorner")
    SpeedBarCorner.CornerRadius = UDim.new(0, 4)
    SpeedBarCorner.Parent = SpeedBar

    -- Speed Fill
    self.SpeedFill = Instance.new("Frame")
    self.SpeedFill.Name = "SpeedFill"
    self.SpeedFill.Size = UDim2.new(
        (self.Config.FlySpeed - self.Config.MinSpeed) / (self.Config.MaxSpeed - self.Config.MinSpeed), 0, 1, 0)
    self.SpeedFill.BackgroundColor3 = Colors.Accent
    self.SpeedFill.BorderSizePixel = 0
    self.SpeedFill.Parent = SpeedBar

    -- Speed Fill Round Corners
    local SpeedFillCorner = Instance.new("UICorner")
    SpeedFillCorner.CornerRadius = UDim.new(0, 4)
    SpeedFillCorner.Parent = self.SpeedFill

    -- Speed Value
    self.SpeedValue = Instance.new("TextLabel")
    self.SpeedValue.Name = "SpeedValue"
    self.SpeedValue.Size = UDim2.new(1, 0, 1, 0)
    self.SpeedValue.BackgroundTransparency = 1
    self.SpeedValue.Text = self.Config.FlySpeed
    self.SpeedValue.TextColor3 = Colors.TextPrimary
    self.SpeedValue.TextSize = 14
    self.SpeedValue.Font = Enum.Font.GothamBold
    self.SpeedValue.Parent = SpeedBar

    -- Speed Increase Button
    self.SpeedIncreaseButton = Instance.new("TextButton")
    self.SpeedIncreaseButton.Name = "SpeedIncreaseButton"
    self.SpeedIncreaseButton.Size = UDim2.new(0, 25, 0, 25)
    self.SpeedIncreaseButton.Position = UDim2.new(1, -25, 0, 0)
    self.SpeedIncreaseButton.BackgroundColor3 = Colors.StatusOn
    self.SpeedIncreaseButton.Text = "+"
    self.SpeedIncreaseButton.TextColor3 = Colors.TextPrimary
    self.SpeedIncreaseButton.TextSize = 18
    self.SpeedIncreaseButton.Font = Enum.Font.GothamBold
    self.SpeedIncreaseButton.Parent = SpeedControlFrame

    -- Walk Speed Control Frame
    local WalkSpeedControlFrame = Instance.new("Frame")
    WalkSpeedControlFrame.Name = "WalkSpeedControlFrame" 
    WalkSpeedControlFrame.Size = UDim2.new(1, -20, 0, 25)
    WalkSpeedControlFrame.Position = UDim2.new(0, 10, 0, 115) -- Position below Speed Control
    WalkSpeedControlFrame.BackgroundTransparency = 1
    WalkSpeedControlFrame.Parent = ControlsFrame

    -- Walk Speed Decrease Button
    self.WalkSpeedDecreaseButton = Instance.new("TextButton")
    self.WalkSpeedDecreaseButton.Name = "WalkSpeedDecreaseButton"
    self.WalkSpeedDecreaseButton.Size = UDim2.new(0, 25, 0, 25)
    self.WalkSpeedDecreaseButton.Position = UDim2.new(0, 0, 0, 0)
    self.WalkSpeedDecreaseButton.BackgroundColor3 = Colors.StatusOff
    self.WalkSpeedDecreaseButton.Text = "-"
    self.WalkSpeedDecreaseButton.TextColor3 = Colors.TextPrimary
    self.WalkSpeedDecreaseButton.TextSize = 18
    self.WalkSpeedDecreaseButton.Font = Enum.Font.GothamBold
    self.WalkSpeedDecreaseButton.Parent = WalkSpeedControlFrame

    -- Walk Speed Decrease Button Round Corners
    local WalkDecreaseCorner = Instance.new("UICorner")
    WalkDecreaseCorner.CornerRadius = UDim.new(0, 4)
    WalkDecreaseCorner.Parent = self.WalkSpeedDecreaseButton

    -- Walk Speed Bar
    local WalkSpeedBar = Instance.new("Frame")
    WalkSpeedBar.Name = "WalkSpeedBar"
    WalkSpeedBar.Size = UDim2.new(1, -60, 0, 25)
    WalkSpeedBar.Position = UDim2.new(0, 30, 0, 0)
    WalkSpeedBar.BackgroundColor3 = Colors.Background
    WalkSpeedBar.BorderSizePixel = 0
    WalkSpeedBar.Parent = WalkSpeedControlFrame

    -- Walk Speed Bar Round Corners
    local WalkSpeedBarCorner = Instance.new("UICorner")
    WalkSpeedBarCorner.CornerRadius = UDim.new(0, 4)
    WalkSpeedBarCorner.Parent = WalkSpeedBar

    -- Walk Speed Fill
    self.WalkSpeedFill = Instance.new("Frame")
    self.WalkSpeedFill.Name = "WalkSpeedFill"
    self.WalkSpeedFill.Size = UDim2.new(
        (self.Config.WalkSpeed - self.Config.MinWalkSpeed) / (self.Config.MaxWalkSpeed - self.Config.MinWalkSpeed),
        0, 1, 0
    )
    self.WalkSpeedFill.BackgroundColor3 = Colors.Accent
    self.WalkSpeedFill.BorderSizePixel = 0
    self.WalkSpeedFill.Parent = WalkSpeedBar

    -- Walk Speed Fill Round Corners
    local WalkSpeedFillCorner = Instance.new("UICorner")
    WalkSpeedFillCorner.CornerRadius = UDim.new(0, 4)
    WalkSpeedFillCorner.Parent = self.WalkSpeedFill

    -- Walk Speed Value
    self.WalkSpeedValue = Instance.new("TextLabel")
    self.WalkSpeedValue.Name = "WalkSpeedValue"
    self.WalkSpeedValue.Size = UDim2.new(1, 0, 1, 0)
    self.WalkSpeedValue.BackgroundTransparency = 1
    self.WalkSpeedValue.Text = self.Config.WalkSpeed
    self.WalkSpeedValue.TextColor3 = Colors.TextPrimary
    self.WalkSpeedValue.TextSize = 14
    self.WalkSpeedValue.Font = Enum.Font.GothamBold
    self.WalkSpeedValue.Parent = WalkSpeedBar

    -- Walk Speed Increase Button
    self.WalkSpeedIncreaseButton = Instance.new("TextButton")
    self.WalkSpeedIncreaseButton.Name = "WalkSpeedIncreaseButton"
    self.WalkSpeedIncreaseButton.Size = UDim2.new(0, 25, 0, 25)
    self.WalkSpeedIncreaseButton.Position = UDim2.new(1, -25, 0, 0)
    self.WalkSpeedIncreaseButton.BackgroundColor3 = Colors.StatusOn
    self.WalkSpeedIncreaseButton.Text = "+"
    self.WalkSpeedIncreaseButton.TextColor3 = Colors.TextPrimary
    self.WalkSpeedIncreaseButton.TextSize = 18
    self.WalkSpeedIncreaseButton.Font = Enum.Font.GothamBold
    self.WalkSpeedIncreaseButton.Parent = WalkSpeedControlFrame

    -- Add hover effects
    self:AddButtonEffects(self.ToggleFlyButton, Colors.HighlightButton)
    self:AddButtonEffects(self.ToggleNoClipButton, Colors.HighlightButton)
    self:AddButtonEffects(self.ToggleInvisibleButton, Colors.HighlightButton)
    self:AddButtonEffects(self.ToggleWalkSpeedButton, Colors.HighlightButton)
    self:AddButtonEffects(self.SpeedDecreaseButton, Colors.StatusOff)
    self:AddButtonEffects(self.SpeedIncreaseButton, Colors.StatusOn)
    self:AddButtonEffects(self.WalkSpeedDecreaseButton, Colors.StatusOff)
    self:AddButtonEffects(self.WalkSpeedIncreaseButton, Colors.StatusOn)
    self:AddButtonEffects(self.CloseButton, Colors.StatusOff)

    -- Connect button events
    self:ConnectEvents()
end

function UI:AddButtonEffects(button, defaultColor)
    local originalColor = defaultColor
    local hoverColor = Color3.new(
        math.min(originalColor.R * 1.1, 1),
        math.min(originalColor.G * 1.1, 1),
        math.min(originalColor.B * 1.1, 1)
    )

    local clickColor = Color3.new(
        originalColor.R * 0.9,
        originalColor.G * 0.9,
        originalColor.B * 0.9
    )

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = hoverColor }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = originalColor }):Play()
    end)

    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), { BackgroundColor3 = clickColor }):Play()
    end)

    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), { BackgroundColor3 = hoverColor }):Play()
    end)
end

function UI:ConnectEvents()
    -- UI Button Events
    self.ToggleFlyButton.MouseButton1Click:Connect(function()
        self.OnToggleFly()
    end)

    self.ToggleNoClipButton.MouseButton1Click:Connect(function()
        self.OnToggleNoClip()
    end)

    self.ToggleInvisibleButton.MouseButton1Click:Connect(function()
        self.OnToggleInvisible()
    end)

    self.ToggleWalkSpeedButton.MouseButton1Click:Connect(function()
        self.OnToggleWalkSpeed()
    end)

    self.SpeedDecreaseButton.MouseButton1Click:Connect(function()
        self.OnDecreaseSpeed()
    end)

    self.SpeedIncreaseButton.MouseButton1Click:Connect(function()
        self.OnIncreaseSpeed()
    end)

    self.WalkSpeedDecreaseButton.MouseButton1Click:Connect(function()
        if self.OnDecreaseWalkSpeed then
            self.OnDecreaseWalkSpeed()
        end
    end)

    self.WalkSpeedIncreaseButton.MouseButton1Click:Connect(function()
        if self.OnIncreaseWalkSpeed then
            self.OnIncreaseWalkSpeed()
        end
    end)

    self.CloseButton.MouseButton1Click:Connect(function()
        self:ToggleVisibility()
    end)
end

function UI:UpdateFlyStatus(isFlying)
    self.IsFlying = isFlying

    if isFlying then
        self.FlyStatus.Text = "Fly: ON"
        self.FlyStatus.TextColor3 = Colors.StatusOn
    else
        self.FlyStatus.Text = "Fly: OFF"
        self.FlyStatus.TextColor3 = Colors.StatusOff
    end
end

function UI:UpdateNoClipStatus(isNoClipping)
    self.IsNoClipping = isNoClipping

    if isNoClipping then
        self.NoClipStatus.Text = "NoClip: ON"
        self.NoClipStatus.TextColor3 = Colors.StatusOn
    else
        self.NoClipStatus.Text = "NoClip: OFF"
        self.NoClipStatus.TextColor3 = Colors.StatusOff
    end
end

function UI:UpdateWalkSpeedStatus(isEnabled, speed)
    self.IsWalkSpeedModified = isEnabled
    
    if isEnabled then
        self.WalkSpeedStatus.Text = "Speed: " .. speed
        self.WalkSpeedStatus.TextColor3 = Colors.StatusOn
    else
        self.WalkSpeedStatus.Text = "Speed: OFF"
        self.WalkSpeedStatus.TextColor3 = Colors.StatusOff
    end
end

function UI:UpdateInvisibleStatus(isInvisible)
    self.IsInvisible = isInvisible

    if isInvisible then
        self.InvisibleStatus.Text = "Invisible: ON"
        self.InvisibleStatus.TextColor3 = Colors.StatusOn
    else
        self.InvisibleStatus.Text = "Invisible: OFF"
        self.InvisibleStatus.TextColor3 = Colors.StatusOff
    end
end

function UI:UpdateSpeed(speed)
    -- Update speed value
    self.SpeedValue.Text = speed
    self.SpeedLabel.Text = "Speed: " .. speed

    -- Update speed fill bar with smooth animation
    local fillRatio = (speed - self.Config.MinSpeed) / (self.Config.MaxSpeed - self.Config.MinSpeed)
    TweenService:Create(
        self.SpeedFill,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.new(fillRatio, 0, 1, 0) }
    ):Play()
end

function UI:UpdateWalkSpeed(speed)
    -- Update walk speed value
    self.WalkSpeedValue.Text = speed

    -- Update walk speed fill bar with smooth animation
    local fillRatio = (speed - self.Config.MinWalkSpeed) / (self.Config.MaxWalkSpeed - self.Config.MinWalkSpeed)
    TweenService:Create(
        self.WalkSpeedFill,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.new(fillRatio, 0, 1, 0) }
    ):Play()
end

function UI:UpdateWalkSpeedUI(speed)
    -- Update walk speed value
    self.WalkSpeedValue.Text = speed
    
    -- Update walk speed fill bar with smooth animation
    local fillRatio = (speed - self.Config.MinWalkSpeed) / (self.Config.MaxWalkSpeed - self.Config.MinWalkSpeed)
    TweenService:Create(
        self.WalkSpeedFill,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.new(fillRatio, 0, 1, 0) }
    ):Play()
end

function UI:ToggleVisibility()
    self.UIVisible = not self.UIVisible
    self.MainFrame.Visible = self.UIVisible
end

function UI:IsVisible()
    return self.UIVisible
end

function UI:Destroy()
    if self.AsherHubGui then
        self.AsherHubGui:Destroy()
    end
end

return UI
