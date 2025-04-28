local Fly = {}
Fly.__index = Fly

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function Fly.new(config)
    local self = setmetatable({}, Fly)
    
    self.Character = nil
    self.HumanoidRootPart = nil
    self.Humanoid = nil
    self.BodyVelocity = nil
    self.BodyGyro = nil
    self.IsFlying = false
    self.MoveDirection = Vector3.zero
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

function Fly:SetCharacter(character)
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

function Fly:CreateFlyObjects()
    if not self.HumanoidRootPart then return end
    
    self.BodyVelocity = Instance.new("BodyVelocity")
    self.BodyVelocity.Velocity = Vector3.zero
    self.BodyVelocity.MaxForce = Vector3.new(9e4, 9e4, 9e4)
    self.BodyVelocity.Parent = self.HumanoidRootPart
    
    self.BodyGyro = Instance.new("BodyGyro")
    self.BodyGyro.CFrame = self.HumanoidRootPart.CFrame
    self.BodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
    self.BodyGyro.Parent = self.HumanoidRootPart
end

function Fly:DestroyFlyObjects()
    if self.BodyVelocity then
        self.BodyVelocity:Destroy()
        self.BodyVelocity = nil
    end
    if self.BodyGyro then
        self.BodyGyro:Destroy()
        self.BodyGyro = nil
    end
end

function Fly:Start()
    if not self.Character or not self.Humanoid then
        self:SetCharacter(LocalPlayer.Character)
        if not self.Character or not self.Humanoid then return end
    end
    
    self.IsFlying = true
    self.Humanoid.PlatformStand = true
    self:CreateFlyObjects()
    
    if not self.RenderSteppedConnection then
        self.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
            self:Update()
        end)
    end
    
end

function Fly:Stop()
    self.IsFlying = false
    
    if self.Humanoid then
        self.Humanoid.PlatformStand = false
    end
    
    self:DestroyFlyObjects()
    
    if self.HumanoidRootPart then
        self.HumanoidRootPart.Velocity = Vector3.zero
    end
    
    if self.RenderSteppedConnection then
        self.RenderSteppedConnection:Disconnect()
        self.RenderSteppedConnection = nil
    end
    
end

function Fly:UpdateMoveDirection()
    self.MoveDirection = Vector3.zero
    
    if self.Controls.Forward then
        self.MoveDirection = self.MoveDirection + workspace.CurrentCamera.CFrame.LookVector
    end
    if self.Controls.Backward then
        self.MoveDirection = self.MoveDirection - workspace.CurrentCamera.CFrame.LookVector
    end
    if self.Controls.Left then
        self.MoveDirection = self.MoveDirection - workspace.CurrentCamera.CFrame.RightVector
    end
    if self.Controls.Right then
        self.MoveDirection = self.MoveDirection + workspace.CurrentCamera.CFrame.RightVector
    end
    if self.Controls.Up then
        self.MoveDirection = self.MoveDirection + Vector3.new(0, 1, 0)
    end
    if self.Controls.Down then
        self.MoveDirection = self.MoveDirection - Vector3.new(0, 1, 0)
    end
    
    if self.MoveDirection.Magnitude > 0 then
        self.MoveDirection = self.MoveDirection.Unit
    end
end

function Fly:Update()
    if not self.IsFlying then return end
    
    if not self.HumanoidRootPart or not self.Humanoid then
        if LocalPlayer.Character then
            self:SetCharacter(LocalPlayer.Character)
        else
            self:Stop()
            return
        end
    end
    
    if not self.BodyVelocity or not self.BodyGyro then
        self:CreateFlyObjects() 
    end
    
    self:UpdateMoveDirection()
    
    if self.BodyVelocity then
        if self.MoveDirection.Magnitude > 0 then
            self.BodyVelocity.Velocity = self.MoveDirection * self.Config.FlySpeed
        else
            self.BodyVelocity.Velocity = Vector3.zero
        end
    end
    
    if self.BodyGyro then
        self.BodyGyro.CFrame = workspace.CurrentCamera.CFrame
    end
end

function Fly:HandleInput(keyCode, isBegin)
    if keyCode == Enum.KeyCode.W then
        self.Controls.Forward = isBegin
    elseif keyCode == Enum.KeyCode.S then
        self.Controls.Backward = isBegin
    elseif keyCode == Enum.KeyCode.A then
        self.Controls.Left = isBegin
    elseif keyCode == Enum.KeyCode.D then
        self.Controls.Right = isBegin
    elseif keyCode == Enum.KeyCode.Space then
        self.Controls.Up = isBegin
    elseif keyCode == Enum.KeyCode.LeftShift then
        self.Controls.Down = isBegin
    end
end

function Fly:PrintWithCooldown(message)
    local currentTime = tick()
    if currentTime - self.LastSpeedPrint >= self.Config.PrintCooldown then
        self.LastSpeedPrint = currentTime
    end
end


function Fly:AdjustSpeed(increment)
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

function Fly:GetSpeed()
    return self.Config.FlySpeed
end

return Fly