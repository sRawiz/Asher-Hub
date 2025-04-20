local UI = {}
UI.__index = UI

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

function UI.new(config)
    local self = setmetatable({}, UI)
    
    self.Config = config or {
        FlySpeed = 25,
        MaxSpeed = 100,
        MinSpeed = 5,
        SpeedIncrement = 5
    }
    
    self.UIVisible = true
    self.IsFlying = false
    self.IsNoClipping = false
    self.IsGodMode = false
    
    -- Callback functions (to be set by Main.lua)
    self.OnToggleFly = function() end
    self.OnToggleNoClip = function() end
    self.OnToggleGodMode = function() end
    self.OnIncreaseSpeed = function() end
    self.OnDecreaseSpeed = function() end
    
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
    self.MainFrame.Size = UDim2.new(0, 200, 0, 220) -- Increased height for GodMode
    self.MainFrame.Position = UDim2.new(0.85, -100, 0.3, 0)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true
    self.MainFrame.Parent = self.AsherHubGui
    
    -- Add rounded corners to Frame
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = self.MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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
    FixCorners.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    FixCorners.BorderSizePixel = 0
    FixCorners.Parent = TitleBar
    
    -- Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Size = UDim2.new(1, -40, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "AsherHub Tools"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 16
    TitleText.Font = Enum.Font.SourceSansBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Close Button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 24, 0, 24)
    self.CloseButton.Position = UDim2.new(1, -27, 0, 3)
    self.CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    self.CloseButton.Text = "X"
    self.CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.CloseButton.TextSize = 14
    self.CloseButton.Font = Enum.Font.SourceSansBold
    self.CloseButton.Parent = TitleBar
    
    -- Close Button Round Corners
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = self.CloseButton
    
    -- Status Section
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Name = "StatusFrame"
    StatusFrame.Size = UDim2.new(1, -20, 0, 85) -- Increased height for GodMode status
    StatusFrame.Position = UDim2.new(0, 10, 0, 40)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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
    self.FlyStatus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.FlyStatus.BorderSizePixel = 0
    self.FlyStatus.Text = "Fly: OFF"
    self.FlyStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
    self.FlyStatus.TextSize = 14
    self.FlyStatus.Font = Enum.Font.SourceSans
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
    self.NoClipStatus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.NoClipStatus.BorderSizePixel = 0
    self.NoClipStatus.Text = "NoClip: OFF"
    self.NoClipStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
    self.NoClipStatus.TextSize = 14
    self.NoClipStatus.Font = Enum.Font.SourceSans
    self.NoClipStatus.Parent = StatusFrame
    
    -- GodMode Status
    self.GodModeStatus = Instance.new("TextLabel")
    self.GodModeStatus.Name = "GodModeStatus"
    self.GodModeStatus.Size = UDim2.new(1, -20, 0, 25)
    self.GodModeStatus.Position = UDim2.new(0, 10, 0, 35)
    self.GodModeStatus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.GodModeStatus.BorderSizePixel = 0
    self.GodModeStatus.Text = "God Mode: OFF"
    self.GodModeStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
    self.GodModeStatus.TextSize = 14
    self.GodModeStatus.Font = Enum.Font.SourceSans
    self.GodModeStatus.Parent = StatusFrame
    
    -- GodMode Status Round Corners
    local GodModeStatusCorner = Instance.new("UICorner")
    GodModeStatusCorner.CornerRadius = UDim.new(0, 4)
    GodModeStatusCorner.Parent = self.GodModeStatus
    
    -- Speed Label
    self.SpeedLabel = Instance.new("TextLabel")
    self.SpeedLabel.Name = "SpeedLabel"
    self.SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
    self.SpeedLabel.Position = UDim2.new(0, 10, 0, 65)
    self.SpeedLabel.BackgroundTransparency = 1
    self.SpeedLabel.Text = "Speed: " .. self.Config.FlySpeed
    self.SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.SpeedLabel.TextSize = 14
    self.SpeedLabel.Font = Enum.Font.SourceSans
    self.SpeedLabel.Parent = StatusFrame
    
    -- Controls Section
    local ControlsFrame = Instance.new("Frame")
    ControlsFrame.Name = "ControlsFrame"
    ControlsFrame.Size = UDim2.new(1, -20, 0, 80)
    ControlsFrame.Position = UDim2.new(0, 10, 0, 135) -- Adjusted position
    ControlsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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
    self.ToggleFlyButton.Size = UDim2.new(0.5, -15, 0, 25)
    self.ToggleFlyButton.Position = UDim2.new(0, 10, 0, 10)
    self.ToggleFlyButton.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
    self.ToggleFlyButton.Text = "Toggle Fly (E)"
    self.ToggleFlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.ToggleFlyButton.TextSize = 14
    self.ToggleFlyButton.Font = Enum.Font.SourceSans
    self.ToggleFlyButton.Parent = ControlsFrame
    
    -- Toggle Fly Button Round Corners
    local FlyButtonCorner = Instance.new("UICorner")
    FlyButtonCorner.CornerRadius = UDim.new(0, 4)
    FlyButtonCorner.Parent = self.ToggleFlyButton
    
    -- Toggle NoClip Button
    self.ToggleNoClipButton = Instance.new("TextButton")
    self.ToggleNoClipButton.Name = "ToggleNoClipButton"
    self.ToggleNoClipButton.Size = UDim2.new(0.5, -15, 0, 25)
    self.ToggleNoClipButton.Position = UDim2.new(0.5, 5, 0, 10)
    self.ToggleNoClipButton.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
    self.ToggleNoClipButton.Text = "Toggle NoClip (C)"
    self.ToggleNoClipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.ToggleNoClipButton.TextSize = 14
    self.ToggleNoClipButton.Font = Enum.Font.SourceSans
    self.ToggleNoClipButton.Parent = ControlsFrame
    
    -- Toggle NoClip Button Round Corners
    local NoClipButtonCorner = Instance.new("UICorner")
    NoClipButtonCorner.CornerRadius = UDim.new(0, 4)
    NoClipButtonCorner.Parent = self.ToggleNoClipButton
    
    -- Second row - God Mode Button
    self.ToggleGodModeButton = Instance.new("TextButton")
    self.ToggleGodModeButton.Name = "ToggleGodModeButton"
    self.ToggleGodModeButton.Size = UDim2.new(1, -20, 0, 25)
    self.ToggleGodModeButton.Position = UDim2.new(0, 10, 0, 45)
    self.ToggleGodModeButton.BackgroundColor3 = Color3.fromRGB(180, 60, 180)
    self.ToggleGodModeButton.Text = "Toggle God Mode (G)"
    self.ToggleGodModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.ToggleGodModeButton.TextSize = 14
    self.ToggleGodModeButton.Font = Enum.Font.SourceSans
    self.ToggleGodModeButton.Parent = ControlsFrame
    
    -- Toggle God Mode Button Round Corners
    local GodModeButtonCorner = Instance.new("UICorner")
    GodModeButtonCorner.CornerRadius = UDim.new(0, 4)
    GodModeButtonCorner.Parent = self.ToggleGodModeButton
    
    -- Speed Control Frame
    local SpeedControlFrame = Instance.new("Frame")
    SpeedControlFrame.Name = "SpeedControlFrame"
    SpeedControlFrame.Size = UDim2.new(1, -20, 0, 25)
    SpeedControlFrame.Position = UDim2.new(0, 10, 0, 45)
    SpeedControlFrame.BackgroundTransparency = 1
    SpeedControlFrame.Parent = StatusFrame
    
    -- Speed Decrease Button
    self.SpeedDecreaseButton = Instance.new("TextButton")
    self.SpeedDecreaseButton.Name = "SpeedDecreaseButton"
    self.SpeedDecreaseButton.Size = UDim2.new(0, 25, 0, 25)
    self.SpeedDecreaseButton.Position = UDim2.new(0, 0, 0, 0)
    self.SpeedDecreaseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    self.SpeedDecreaseButton.Text = "-"
    self.SpeedDecreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.SpeedDecreaseButton.TextSize = 18
    self.SpeedDecreaseButton.Font = Enum.Font.SourceSansBold
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
    SpeedBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SpeedBar.BorderSizePixel = 0
    SpeedBar.Parent = SpeedControlFrame
    
    -- Speed Bar Round Corners
    local SpeedBarCorner = Instance.new("UICorner")
    SpeedBarCorner.CornerRadius = UDim.new(0, 4)
    SpeedBarCorner.Parent = SpeedBar
    
    -- Speed Fill
    self.SpeedFill = Instance.new("Frame")
    self.SpeedFill.Name = "SpeedFill"
    self.SpeedFill.Size = UDim2.new((self.Config.FlySpeed - self.Config.MinSpeed) / (self.Config.MaxSpeed - self.Config.MinSpeed), 0, 1, 0)
    self.SpeedFill.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
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
    self.SpeedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.SpeedValue.TextSize = 14
    self.SpeedValue.Font = Enum.Font.SourceSansBold
    self.SpeedValue.Parent = SpeedBar
    
    -- Speed Increase Button
    self.SpeedIncreaseButton = Instance.new("TextButton")
    self.SpeedIncreaseButton.Name = "SpeedIncreaseButton"
    self.SpeedIncreaseButton.Size = UDim2.new(0, 25, 0, 25)
    self.SpeedIncreaseButton.Position = UDim2.new(1, -25, 0, 0)
    self.SpeedIncreaseButton.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
    self.SpeedIncreaseButton.Text = "+"
    self.SpeedIncreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.SpeedIncreaseButton.TextSize = 18
    self.SpeedIncreaseButton.Font = Enum.Font.SourceSansBold
    self.SpeedIncreaseButton.Parent = SpeedControlFrame
    
    -- Connect button events
    self:ConnectEvents()
end

function UI:ConnectEvents()
    -- UI Button Events
    self.ToggleFlyButton.MouseButton1Click:Connect(function()
        self.OnToggleFly()
    end)
    
    self.ToggleNoClipButton.MouseButton1Click:Connect(function()
        self.OnToggleNoClip()
    end)
    
    self.ToggleGodModeButton.MouseButton1Click:Connect(function()
        self.OnToggleGodMode()
    end)
    
    self.SpeedDecreaseButton.MouseButton1Click:Connect(function()
        self.OnDecreaseSpeed()
    end)
    
    self.SpeedIncreaseButton.MouseButton1Click:Connect(function()
        self.OnIncreaseSpeed()
    end)
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self:ToggleVisibility()
    end)
end

function UI:UpdateFlyStatus(isFlying)
    self.IsFlying = isFlying
    
    if isFlying then
        self.FlyStatus.Text = "Fly: ON"
        self.FlyStatus.TextColor3 = Color3.fromRGB(60, 200, 100)
    else
        self.FlyStatus.Text = "Fly: OFF"
        self.FlyStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end

function UI:UpdateNoClipStatus(isNoClipping)
    self.IsNoClipping = isNoClipping
    
    if isNoClipping then
        self.NoClipStatus.Text = "NoClip: ON"
        self.NoClipStatus.TextColor3 = Color3.fromRGB(60, 200, 100)
    else
        self.NoClipStatus.Text = "NoClip: OFF"
        self.NoClipStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end

function UI:UpdateGodModeStatus(isGodMode)
    self.IsGodMode = isGodMode
    
    if isGodMode then
        self.GodModeStatus.Text = "God Mode: ON"
        self.GodModeStatus.TextColor3 = Color3.fromRGB(60, 200, 100)
    else
        self.GodModeStatus.Text = "God Mode: OFF"
        self.GodModeStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end

function UI:UpdateSpeed(speed)
    -- Update speed value
    self.SpeedValue.Text = speed
    self.SpeedLabel.Text = "Speed: " .. speed
    
    -- Update speed fill bar
    local fillRatio = (speed - self.Config.MinSpeed) / (self.Config.MaxSpeed - self.Config.MinSpeed)
    self.SpeedFill:TweenSize(
        UDim2.new(fillRatio, 0, 1, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.2,
        true
    )
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