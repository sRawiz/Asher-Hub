local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character
local HumanoidRootPart
local Humanoid
local BodyVelocity
local BodyGyro
local IsFlying = false
local IsNoClipping = false
local MoveDirection = Vector3.zero
local lastSpeedPrint = 0

-- การตั้งค่าเริ่มต้น
local Configuration = {
    FlySpeed = 25,
    ToggleFlyKey = Enum.KeyCode.E,
    ToggleNoClipKey = Enum.KeyCode.C,
    SpeedIncreaseKey = Enum.KeyCode.Q,
    SpeedDecreaseKey = Enum.KeyCode.Z,
    MaxSpeed = 100,
    MinSpeed = 5,
    SpeedIncrement = 5,
    PrintCooldown = 1,
    ToggleUIKey = Enum.KeyCode.RightControl
}

local Controls = {
    Forward = false,
    Backward = false,
    Left = false,
    Right = false,
    Up = false,
    Down = false
}

-- สร้าง UI
local UIVisible = true
local AsherHubGui = Instance.new("ScreenGui")
AsherHubGui.Name = "AsherHubGui"
AsherHubGui.ResetOnSpawn = false

-- พยายามตั้งค่า Parent เป็น CoreGui ถ้าเป็นไปได้ (ป้องกันไม่ให้ UI หายเมื่อ reset character)
local success, result = pcall(function()
    AsherHubGui.Parent = CoreGui
    return true
end)

if not success then
    AsherHubGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- สร้าง Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 180)
MainFrame.Position = UDim2.new(0.85, -100, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = AsherHubGui

-- เพิ่มความโค้งมนให้กับ Frame
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

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
TitleText.Text = "AsherHub Fly & NoClip"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -27, 0, 3)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Parent = TitleBar

-- Close Button Round Corners
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

-- Status Section
local StatusFrame = Instance.new("Frame")
StatusFrame.Name = "StatusFrame"
StatusFrame.Size = UDim2.new(1, -20, 0, 50)
StatusFrame.Position = UDim2.new(0, 10, 0, 40)
StatusFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = MainFrame

-- Status Section Round Corners
local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusFrame

-- Fly Status
local FlyStatus = Instance.new("TextLabel")
FlyStatus.Name = "FlyStatus"
FlyStatus.Size = UDim2.new(0.5, -5, 0, 25)
FlyStatus.Position = UDim2.new(0, 10, 0, 5)
FlyStatus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FlyStatus.BorderSizePixel = 0
FlyStatus.Text = "Fly: OFF"
FlyStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
FlyStatus.TextSize = 14
FlyStatus.Font = Enum.Font.SourceSans
FlyStatus.Parent = StatusFrame

-- Fly Status Round Corners
local FlyStatusCorner = Instance.new("UICorner")
FlyStatusCorner.CornerRadius = UDim.new(0, 4)
FlyStatusCorner.Parent = FlyStatus

-- NoClip Status
local NoClipStatus = Instance.new("TextLabel")
NoClipStatus.Name = "NoClipStatus"
NoClipStatus.Size = UDim2.new(0.5, -5, 0, 25)
NoClipStatus.Position = UDim2.new(0.5, -5, 0, 5)
NoClipStatus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
NoClipStatus.BorderSizePixel = 0
NoClipStatus.Text = "NoClip: OFF"
NoClipStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
NoClipStatus.TextSize = 14
NoClipStatus.Font = Enum.Font.SourceSans
NoClipStatus.Parent = StatusFrame

-- NoClip Status Round Corners
local NoClipStatusCorner = Instance.new("UICorner")
NoClipStatusCorner.CornerRadius = UDim.new(0, 4)
NoClipStatusCorner.Parent = NoClipStatus

-- Speed Label
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
SpeedLabel.Position = UDim2.new(0, 10, 0, 35)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: " .. Configuration.FlySpeed
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 14
SpeedLabel.Font = Enum.Font.SourceSans
SpeedLabel.Parent = StatusFrame

-- Controls Section
local ControlsFrame = Instance.new("Frame")
ControlsFrame.Name = "ControlsFrame"
ControlsFrame.Size = UDim2.new(1, -20, 0, 80)
ControlsFrame.Position = UDim2.new(0, 10, 0, 100)
ControlsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ControlsFrame.BorderSizePixel = 0
ControlsFrame.Parent = MainFrame

-- Controls Section Round Corners
local ControlsCorner = Instance.new("UICorner")
ControlsCorner.CornerRadius = UDim.new(0, 6)
ControlsCorner.Parent = ControlsFrame

-- Toggle Fly Button
local ToggleFlyButton = Instance.new("TextButton")
ToggleFlyButton.Name = "ToggleFlyButton"
ToggleFlyButton.Size = UDim2.new(0.5, -15, 0, 25)
ToggleFlyButton.Position = UDim2.new(0, 10, 0, 10)
ToggleFlyButton.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
ToggleFlyButton.Text = "Toggle Fly (E)"
ToggleFlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleFlyButton.TextSize = 14
ToggleFlyButton.Font = Enum.Font.SourceSans
ToggleFlyButton.Parent = ControlsFrame

-- Toggle Fly Button Round Corners
local FlyButtonCorner = Instance.new("UICorner")
FlyButtonCorner.CornerRadius = UDim.new(0, 4)
FlyButtonCorner.Parent = ToggleFlyButton

-- Toggle NoClip Button
local ToggleNoClipButton = Instance.new("TextButton")
ToggleNoClipButton.Name = "ToggleNoClipButton"
ToggleNoClipButton.Size = UDim2.new(0.5, -15, 0, 25)
ToggleNoClipButton.Position = UDim2.new(0.5, 5, 0, 10)
ToggleNoClipButton.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
ToggleNoClipButton.Text = "Toggle NoClip (C)"
ToggleNoClipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleNoClipButton.TextSize = 14
ToggleNoClipButton.Font = Enum.Font.SourceSans
ToggleNoClipButton.Parent = ControlsFrame

-- Toggle NoClip Button Round Corners
local NoClipButtonCorner = Instance.new("UICorner")
NoClipButtonCorner.CornerRadius = UDim.new(0, 4)
NoClipButtonCorner.Parent = ToggleNoClipButton

-- Speed Control Frame
local SpeedControlFrame = Instance.new("Frame")
SpeedControlFrame.Name = "SpeedControlFrame"
SpeedControlFrame.Size = UDim2.new(1, -20, 0, 25)
SpeedControlFrame.Position = UDim2.new(0, 10, 0, 45)
SpeedControlFrame.BackgroundTransparency = 1
SpeedControlFrame.Parent = ControlsFrame

-- Speed Decrease Button
local SpeedDecreaseButton = Instance.new("TextButton")
SpeedDecreaseButton.Name = "SpeedDecreaseButton"
SpeedDecreaseButton.Size = UDim2.new(0, 25, 0, 25)
SpeedDecreaseButton.Position = UDim2.new(0, 0, 0, 0)
SpeedDecreaseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
SpeedDecreaseButton.Text = "-"
SpeedDecreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedDecreaseButton.TextSize = 18
SpeedDecreaseButton.Font = Enum.Font.SourceSansBold
SpeedDecreaseButton.Parent = SpeedControlFrame

-- Speed Decrease Button Round Corners
local DecreaseCorner = Instance.new("UICorner")
DecreaseCorner.CornerRadius = UDim.new(0, 4)
DecreaseCorner.Parent = SpeedDecreaseButton

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
local SpeedFill = Instance.new("Frame")
SpeedFill.Name = "SpeedFill"
SpeedFill.Size = UDim2.new((Configuration.FlySpeed - Configuration.MinSpeed) / (Configuration.MaxSpeed - Configuration.MinSpeed), 0, 1, 0)
SpeedFill.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
SpeedFill.BorderSizePixel = 0
SpeedFill.Parent = SpeedBar

-- Speed Fill Round Corners
local SpeedFillCorner = Instance.new("UICorner")
SpeedFillCorner.CornerRadius = UDim.new(0, 4)
SpeedFillCorner.Parent = SpeedFill

-- Speed Value
local SpeedValue = Instance.new("TextLabel")
SpeedValue.Name = "SpeedValue"
SpeedValue.Size = UDim2.new(1, 0, 1, 0)
SpeedValue.BackgroundTransparency = 1
SpeedValue.Text = Configuration.FlySpeed
SpeedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedValue.TextSize = 14
SpeedValue.Font = Enum.Font.SourceSansBold
SpeedValue.Parent = SpeedBar

-- Speed Increase Button
local SpeedIncreaseButton = Instance.new("TextButton")
SpeedIncreaseButton.Name = "SpeedIncreaseButton"
SpeedIncreaseButton.Size = UDim2.new(0, 25, 0, 25)
SpeedIncreaseButton.Position = UDim2.new(1, -25, 0, 0)
SpeedIncreaseButton.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
SpeedIncreaseButton.Text = "+"
SpeedIncreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedIncreaseButton.TextSize = 18
SpeedIncreaseButton.Font = Enum.Font.SourceSansBold
SpeedIncreaseButton.Parent = SpeedControlFrame

-- Speed Increase Button Round Corners
local IncreaseCorner = Instance.new("UICorner")
IncreaseCorner.CornerRadius = UDim.new(0, 4)
IncreaseCorner.Parent = SpeedIncreaseButton

-- ฟังก์ชันเพื่อตั้งค่าตัวละคร
local function SetupCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
end

-- ฟังก์ชันเพื่ออัพเดตค่าสถานะใน UI
local function UpdateUI()
    SpeedValue.Text = Configuration.FlySpeed
    
    -- อัพเดต SpeedFill
    local fillRatio = (Configuration.FlySpeed - Configuration.MinSpeed) / (Configuration.MaxSpeed - Configuration.MinSpeed)
    SpeedFill:TweenSize(
        UDim2.new(fillRatio, 0, 1, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.2,
        true
    )
    
    -- อัพเดต FlyStatus
    if IsFlying then
        FlyStatus.Text = "Fly: ON"
        FlyStatus.TextColor3 = Color3.fromRGB(60, 200, 100)
    else
        FlyStatus.Text = "Fly: OFF"
        FlyStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
    
    -- อัพเดต NoClipStatus
    if IsNoClipping then
        NoClipStatus.Text = "NoClip: ON"
        NoClipStatus.TextColor3 = Color3.fromRGB(60, 200, 100)
    else
        NoClipStatus.Text = "NoClip: OFF"
        NoClipStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
    
    -- อัพเดต SpeedLabel
    SpeedLabel.Text = "Speed: " .. Configuration.FlySpeed
end

-- ฟังก์ชันเพื่อสร้างอ็อบเจกต์สำหรับบิน
local function CreateFlyObjects()
    if not HumanoidRootPart then return end
    
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Velocity = Vector3.zero
    BodyVelocity.MaxForce = Vector3.new(9e4, 9e4, 9e4)
    BodyVelocity.Parent = HumanoidRootPart
    
    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.CFrame = HumanoidRootPart.CFrame
    BodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
    BodyGyro.Parent = HumanoidRootPart
end

-- ฟังก์ชันเพื่อลบอ็อบเจกต์การบิน
local function DestroyFlyObjects()
    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
    if BodyGyro then
        BodyGyro:Destroy()
        BodyGyro = nil
    end
end

-- ฟังก์ชันเพื่ออัพเดตทิศทางการเคลื่อนที่
local function UpdateMoveDirection()
    MoveDirection = Vector3.zero
    
    if Controls.Forward then
        MoveDirection = MoveDirection + workspace.CurrentCamera.CFrame.LookVector
    end
    if Controls.Backward then
        MoveDirection = MoveDirection - workspace.CurrentCamera.CFrame.LookVector
    end
    if Controls.Left then
        MoveDirection = MoveDirection - workspace.CurrentCamera.CFrame.RightVector
    end
    if Controls.Right then
        MoveDirection = MoveDirection + workspace.CurrentCamera.CFrame.RightVector
    end
    if Controls.Up then
        MoveDirection = MoveDirection + Vector3.new(0, 1, 0)
    end
    if Controls.Down then
        MoveDirection = MoveDirection - Vector3.new(0, 1, 0)
    end
    
    if MoveDirection.Magnitude > 0 then
        MoveDirection = MoveDirection.Unit
    end
end

-- ฟังก์ชันเพื่อพิมพ์ข้อความแบบมีการหน่วงเวลา
local function PrintWithCooldown(message)
    local currentTime = tick()
    if currentTime - lastSpeedPrint >= Configuration.PrintCooldown then
        print(message)
        lastSpeedPrint = currentTime
    end
end

-- ฟังก์ชันเพื่อสลับการแสดง/ซ่อน UI
local function ToggleUI()
    UIVisible = not UIVisible
    MainFrame.Visible = UIVisible
end

-- ฟังก์ชันสำหรับ NoClip
local function SetNoClip(enabled)
    IsNoClipping = enabled
    
    if Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not enabled
            end
        end
    end
    
    UpdateUI()
    
    if enabled then
        print("NoClip เปิดใช้งาน")
    else
        print("NoClip ปิดใช้งาน")
    end
end

-- ฟังก์ชันเพื่อเริ่มบิน
local function StartFlying()
    SetupCharacter()
    IsFlying = true
    Humanoid.PlatformStand = true
    CreateFlyObjects()
    UpdateUI()
    print("เริ่มบิน - ความเร็ว: " .. Configuration.FlySpeed)
end

-- ฟังก์ชันเพื่อหยุดบิน
local function StopFlying()
    IsFlying = false
    if Humanoid then
        Humanoid.PlatformStand = false
    end
    DestroyFlyObjects()
    if HumanoidRootPart then
        HumanoidRootPart.Velocity = Vector3.zero
    end
    UpdateUI()
    print("หยุดบิน")
end

-- ฟังก์ชันเพื่อสลับการบิน
local function ToggleFlying()
    if IsFlying then
        StopFlying()
    else
        StartFlying()
    end
end

-- ฟังก์ชันเพื่อสลับ NoClip
local function ToggleNoClip()
    SetNoClip(not IsNoClipping)
end

-- ฟังก์ชันเพื่อปรับความเร็ว
local function AdjustSpeed(increment)
    local oldSpeed = Configuration.FlySpeed
    Configuration.FlySpeed = math.clamp(
        Configuration.FlySpeed + increment, 
        Configuration.MinSpeed, 
        Configuration.MaxSpeed
    )
    
    UpdateUI()
    
    -- แสดงข้อความเฉพาะเมื่อความเร็วเปลี่ยน
    if oldSpeed ~= Configuration.FlySpeed then
        PrintWithCooldown("FlySpeed: " .. Configuration.FlySpeed)
    end
end

-- อัพเดต NoClip สำหรับชิ้นส่วนใหม่ที่เพิ่มเข้ามา
local function UpdateNoClipForDescendants()
    if IsNoClipping and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- การเชื่อมต่อกับเหตุการณ์เมื่อมีชิ้นส่วนใหม่เพิ่มเข้ามา
local function ConnectDescendantAddedEvent()
    if Character then
        Character.DescendantAdded:Connect(function(descendant)
            if IsNoClipping and descendant:IsA("BasePart") then
                descendant.CanCollide = false
            end
        end)
    end
end

-- เชื่อมต่อกับเหตุการณ์เมื่อตัวละครเพิ่มเข้ามา
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    
    -- รอให้ตัวละครโหลดเสร็จ
    task.wait(0.5)
    
    -- ตั้งค่าใหม่หากจำเป็น
    if IsFlying then
        SetupCharacter()
        Humanoid.PlatformStand = true
        CreateFlyObjects()
    end
    
    -- ตั้งค่า NoClip หากเปิดใช้งานอยู่
    if IsNoClipping then
        SetNoClip(true)
    end
    
    -- เชื่อมต่อกับเหตุการณ์
    ConnectDescendantAddedEvent()
    ConnectDiedEvent()
    
    -- อัพเดต UI
    UpdateUI()
end)

-- UI Button Events
ToggleFlyButton.MouseButton1Click:Connect(ToggleFlying)
ToggleNoClipButton.MouseButton1Click:Connect(ToggleNoClip)
SpeedDecreaseButton.MouseButton1Click:Connect(function()
    AdjustSpeed(-Configuration.SpeedIncrement)
end)
SpeedIncreaseButton.MouseButton1Click:Connect(function()
    AdjustSpeed(Configuration.SpeedIncrement)
end)
CloseButton.MouseButton1Click:Connect(function()
    ToggleUI()
end)

-- การจัดการการป้อนข้อมูล
UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
    if GameProcessedEvent then return end
    
    local KeyCode = Input.KeyCode
    
    -- สลับการบิน
    if KeyCode == Configuration.ToggleFlyKey then
        ToggleFlying()
    end
    
    -- สลับ NoClip
    if KeyCode == Configuration.ToggleNoClipKey then
        ToggleNoClip()
    end
    
    -- ปรับความเร็ว
    if KeyCode == Configuration.SpeedIncreaseKey then
        AdjustSpeed(Configuration.SpeedIncrement)
    elseif KeyCode == Configuration.SpeedDecreaseKey then
        AdjustSpeed(-Configuration.SpeedIncrement)
    end
    
    -- สลับการแสดง/ซ่อน UI
    if KeyCode == Configuration.ToggleUIKey then
        ToggleUI()
    end
    
    -- การควบคุมการเคลื่อนที่
    if KeyCode == Enum.KeyCode.W then
        Controls.Forward = true
    elseif KeyCode == Enum.KeyCode.S then
        Controls.Backward = true
    elseif KeyCode == Enum.KeyCode.A then
        Controls.Left = true
    elseif KeyCode == Enum.KeyCode.D then
        Controls.Right = true
    elseif KeyCode == Enum.KeyCode.Space then
        Controls.Up = true
    elseif KeyCode == Enum.KeyCode.LeftShift then
        Controls.Down = true
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    local KeyCode = Input.KeyCode
    
    if KeyCode == Enum.KeyCode.W then
        Controls.Forward = false
    elseif KeyCode == Enum.KeyCode.S then
        Controls.Backward = false
    elseif KeyCode == Enum.KeyCode.A then
        Controls.Left = false
    elseif KeyCode == Enum.KeyCode.D then
        Controls.Right = false
    elseif KeyCode == Enum.KeyCode.Space then
        Controls.Up = false
    elseif KeyCode == Enum.KeyCode.LeftShift then
        Controls.Down = false
    end
end)

-- การเชื่อมต่อกับเหตุการณ์เสียชีวิต
local function ConnectDiedEvent()
    if Humanoid then
        -- เชื่อมต่อเหตุการณ์เสียชีวิตเพียงครั้งเดียว
        local deathConnection
        deathConnection = Humanoid.Died:Connect(function()
            if IsFlying then
                StopFlying()
            end
            -- ปิด NoClip เมื่อตาย
            if IsNoClipping then
                SetNoClip(false)
            end
            if deathConnection then
                deathConnection:Disconnect()
            end
        end)
    end
end

-- ฟังก์ชันอัพเดตสำหรับ NoClip
local noClipConnection
local function SetupNoClipLoop()
    if noClipConnection then
        noClipConnection:Disconnect()
    end
    
    noClipConnection = RunService.Stepped:Connect(function()
        if IsNoClipping and Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- อัพเดตในแต่ละเฟรม
RunService.RenderStepped:Connect(function()
    if IsFlying then
        if not HumanoidRootPart or not Humanoid then
            -- ตรวจสอบว่ามีตัวละคร
            if LocalPlayer.Character then
                SetupCharacter()
                ConnectDiedEvent()
            else
                StopFlying() -- หยุดบินถ้าไม่มีตัวละคร
                return
            end
        end
        
        if not BodyVelocity or not BodyGyro then
            CreateFlyObjects() -- สร้างอ็อบเจกต์ใหม่ถ้าหายไป
        end
        
        UpdateMoveDirection()
        
        if BodyVelocity then
            if MoveDirection.Magnitude > 0 then
                BodyVelocity.Velocity = MoveDirection * Configuration.FlySpeed
            else
                BodyVelocity.Velocity = Vector3.zero
            end
        end
        
        if BodyGyro then
            BodyGyro.CFrame = workspace.CurrentCamera.CFrame
        end
    end
end)

-- ตั้งค่าเริ่มต้น
if LocalPlayer.Character then
    SetupCharacter()
    ConnectDiedEvent()
    ConnectDescendantAddedEvent()
end

-- ตั้งค่า NoClip Loop
SetupNoClipLoop()

-- อัพเดต UI เริ่มต้น
UpdateUI()

print("Script พร้อมใช้งานแล้ว | กด E เพื่อบิน | กด C เพื่อทะลุกำแพง | Q/Z เพื่อปรับความเร็ว | Right Ctrl เพื่อซ่อน/แสดง UI")