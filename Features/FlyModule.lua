local FlyModule = {}
FlyModule.__index = FlyModule

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function FlyModule.new(config)
    local self = setmetatable({}, FlyModule)
    
    self.Character = nil
    self.HumanoidRootPart = nil
    self.Humanoid = nil
    self.BodyVelocity = nil
    self.BodyGyro = nil
    self.IsFlying = false
    self.MoveDirection = Vector3.new(0, 0, 0)
    self.LastSpeedPrint = 0
    
    self.Controls = {
        Forward = false,
        Backward = false,
        Left = false,
        Right = false,
        Up = false,
        Down = false
    }
    
    self.Config = config or {
        FlySpeed = 25,
        MaxSpeed = 100,
        MinSpeed = 5,
        SpeedIncrement = 5,
        PrintCooldown = 1
    }
    
    return self
end

function FlyModule:SetCharacter(character)
    self.Character = character
    if self.Character then
        self.HumanoidRootPart = self.Character:WaitForChild("HumanoidRootPart")
        self.Humanoid = self.Character:WaitForChild("Humanoid")
        
        if self.Humanoid then
            self.Humanoid.Died:Connect(function()
                if self.IsFlying then
                    self:Stop()
                end
            end)
        end
    end
end

function FlyModule:CreateFlyObjects()
    if not self.HumanoidRootPart then return end
    
    if self.BodyVelocity then
        self.BodyVelocity:Destroy()
    end
    
    if self.BodyGyro then
        self.BodyGyro:Destroy()
    end
    
    self.BodyVelocity = Instance.new("BodyVelocity")
    self.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    self.BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    self.BodyVelocity.Parent = self.HumanoidRootPart
    
    self.BodyGyro = Instance.new("BodyGyro")
    self.BodyGyro.CFrame = self.HumanoidRootPart.CFrame
    self.BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    self.BodyGyro.P = 1000
    self.BodyGyro.D = 50
    self.BodyGyro.Parent = self.HumanoidRootPart
end

function FlyModule:DestroyFlyObjects()
    if self.BodyVelocity then
        self.BodyVelocity:Destroy()
        self.BodyVelocity = nil
    end
    if self.BodyGyro then
        self.BodyGyro:Destroy()
        self.BodyGyro = nil
    end
end

function FlyModule:Start()
    if not self.Character or not self.Humanoid then
        self:SetCharacter(LocalPlayer.Character)
        if not self.Character or not self.Humanoid then 
            warn("FlyModule: No character found!")
            return 
        end
    end
    
    self.IsFlying = true
    self.Humanoid.PlatformStand = true
    self:CreateFlyObjects()
    
    -- Reset controls
    for key, _ in pairs(self.Controls) do
        self.Controls[key] = false
    end
    
    -- Start update loop if not already started
    if not self.RenderSteppedConnection then
        self.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
            self:Update()
        end)
    end
    
    print("FlyModule: Started flying")
end

function FlyModule:Stop()
    self.IsFlying = false
    
    if self.Humanoid then
        self.Humanoid.PlatformStand = false
    end
    
    self:DestroyFlyObjects()
    
    if self.HumanoidRootPart then
        self.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    end
    
    if self.RenderSteppedConnection then
        self.RenderSteppedConnection:Disconnect()
        self.RenderSteppedConnection = nil
    end
    
    print("FlyModule: Stopped flying")
end

function FlyModule:UpdateMoveDirection()
    local camera = workspace.CurrentCamera
    self.MoveDirection = Vector3.new(0, 0, 0)
    
    if self.Controls.Forward then
        self.MoveDirection = self.MoveDirection + camera.CFrame.LookVector
    end
    if self.Controls.Backward then
        self.MoveDirection = self.MoveDirection - camera.CFrame.LookVector
    end
    if self.Controls.Left then
        self.MoveDirection = self.MoveDirection - camera.CFrame.RightVector
    end
    if self.Controls.Right then
        self.MoveDirection = self.MoveDirection + camera.CFrame.RightVector
    end
    if self.Controls.Up then
        self.MoveDirection = self.MoveDirection + Vector3.new(0, 1, 0)
    end
    if self.Controls.Down then
        self.MoveDirection = self.MoveDirection - Vector3.new(0, 1, 0)
    end
    
    -- Normalize only if there's movement
    if self.MoveDirection.Magnitude > 0 then
        self.MoveDirection = self.MoveDirection.Unit
    end
end

function FlyModule:Update()
    if not self.IsFlying then return end
    
    -- Make sure we have a character
    if not self.HumanoidRootPart or not self.Humanoid then
        if LocalPlayer.Character then
            self:SetCharacter(LocalPlayer.Character)
            if not self.HumanoidRootPart then
                self:Stop()
                return
            end
        else
            self:Stop()
            return
        end
    end
    
    -- Re-create the fly objects if missing
    if not self.BodyVelocity or not self.BodyGyro then
        self:CreateFlyObjects()
    end
    
    -- Update movement direction
    self:UpdateMoveDirection()
    
    -- Apply velocity
    if self.BodyVelocity then
        if self.MoveDirection.Magnitude > 0 then
            self.BodyVelocity.Velocity = self.MoveDirection * self.Config.FlySpeed
        else
            self.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end
    
    -- Update gyro orientation
    if self.BodyGyro then
        self.BodyGyro.CFrame = workspace.CurrentCamera.CFrame
    end
end

function FlyModule:HandleInput(keyCode, isBegin)
    -- Only process input if flying
    if not self.IsFlying then return end
    
    -- Map keys to controls
    if keyCode == Enum.KeyCode.W then
        self.Controls.Forward = isBegin
        print("FlyModule: Forward = " .. tostring(isBegin))
    elseif keyCode == Enum.KeyCode.S then
        self.Controls.Backward = isBegin
        print("FlyModule: Backward = " .. tostring(isBegin))
    elseif keyCode == Enum.KeyCode.A then
        self.Controls.Left = isBegin
        print("FlyModule: Left = " .. tostring(isBegin))
    elseif keyCode == Enum.KeyCode.D then
        self.Controls.Right = isBegin
        print("FlyModule: Right = " .. tostring(isBegin))
    elseif keyCode == Enum.KeyCode.Space then
        self.Controls.Up = isBegin
        print("FlyModule: Up = " .. tostring(isBegin))
    elseif keyCode == Enum.KeyCode.LeftShift or keyCode == Enum.KeyCode.RightShift then
        self.Controls.Down = isBegin
        print("FlyModule: Down = " .. tostring(isBegin))
    end
end

function FlyModule:PrintWithCooldown(message)
    local currentTime = tick()
    if currentTime - self.LastSpeedPrint >= self.Config.PrintCooldown then
        print(message)
        self.LastSpeedPrint = currentTime
    end
end

function FlyModule:AdjustSpeed(increment)
    local oldSpeed = self.Config.FlySpeed
    self.Config.FlySpeed = math.clamp(
        self.Config.FlySpeed + increment, 
        self.Config.MinSpeed, 
        self.Config.MaxSpeed
    )
    
    if oldSpeed ~= self.Config.FlySpeed then
        self:PrintWithCooldown("FlySpeed: " .. self.Config.FlySpeed)
    end
    
    return self.Config.FlySpeed
end

function FlyModule:GetSpeed()
    return self.Config.FlySpeed
end

return FlyModule