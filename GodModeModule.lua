local GodModeModule = {}
GodModeModule.__index = GodModeModule

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

function GodModeModule.new()
    local self = setmetatable({}, GodModeModule)
    
    self.Character = nil
    self.Humanoid = nil
    self.IsGodModeEnabled = false
    self.OriginalMaxHealth = 100
    self.GodModeConnection = nil
    self.FallDamageConnection = nil
    self.StateChangedConnection = nil
    self.HealthChangedConnection = nil
    self.SteppedConnection = nil
    self.PreviousHealth = nil
    self.PreviousState = nil
    self.HealRate = 100
    self.MonitorFrequency = 0.1
    self.LastHealTime = 0
    
    return self
end

function GodModeModule:SetCharacter(character)
    if self.IsGodModeEnabled then
        self:Disable()
    end
    
    self.Character = character
    if self.Character then
        self.Humanoid = self.Character:WaitForChild("Humanoid")
        
        if self.Humanoid then
            self.OriginalMaxHealth = self.Humanoid.MaxHealth
            
            if self.DiedConnection then
                self.DiedConnection:Disconnect()
            end
            
            self.DiedConnection = self.Humanoid.Died:Connect(function()
                if self.IsGodModeEnabled then
                    self:Disable()
                end
            end)
            
            if self.IsGodModeEnabled then
                task.wait(0.5)
                self:Enable()
            end
        end
    end
end

function GodModeModule:MonitorHealth()
    if not self.Character or not self.Humanoid then return end
    
    if self.PreviousHealth and self.Humanoid.Health < self.PreviousHealth then
        self.Humanoid.Health = self.Humanoid.MaxHealth
    elseif self.Humanoid.Health < self.Humanoid.MaxHealth then
        local currentTime = tick()
        local timeDiff = currentTime - self.LastHealTime
        
        if timeDiff > self.MonitorFrequency then
            local healAmount = self.HealRate * timeDiff
            self.Humanoid.Health = math.min(self.Humanoid.Health + healAmount, self.Humanoid.MaxHealth)
            self.LastHealTime = currentTime
        end
    end
    
    self.PreviousHealth = self.Humanoid.Health
    
    local currentState = self.Humanoid:GetState()
    if self.PreviousState ~= currentState then
        if currentState == Enum.HumanoidStateType.FallingDown or
           currentState == Enum.HumanoidStateType.Ragdoll or
           currentState == Enum.HumanoidStateType.Physics then
            self.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        self.PreviousState = currentState
    end
end

function GodModeModule:HandleDisasters()
    if not self.Character then return end
    
    for _, instance in pairs(self.Character:GetDescendants()) do
        if instance:IsA("Fire") or instance:IsA("Smoke") then
            instance.Enabled = false
        end
        
        if instance.Name == "Fire" or 
           instance.Name == "Poison" or 
           instance.Name:find("Damage") or
           instance.Name:find("Effect") then
            
            if instance:IsA("BasePart") or instance:IsA("ParticleEmitter") then
                pcall(function() instance.Enabled = false end)
            end
            
            pcall(function() instance.Transparency = 1 end)
        end
    end
end

function GodModeModule:Enable()
    if not self.Character then
        self:SetCharacter(LocalPlayer.Character)
        if not self.Character or not self.Humanoid then return false end
    end
    
    self.IsGodModeEnabled = true
    
    self.OriginalMaxHealth = self.Humanoid.MaxHealth
    self.Humanoid.MaxHealth = self.OriginalMaxHealth * 100
    self.Humanoid.Health = self.Humanoid.MaxHealth
    
    self.PreviousHealth = self.Humanoid.Health
    self.LastHealTime = tick()
    
    if not self.SteppedConnection then
        self.SteppedConnection = RunService.Stepped:Connect(function()
            if not self.IsGodModeEnabled then return end
            self:MonitorHealth()
            self:HandleDisasters()
        end)
    end
    
    if not self.HealthChangedConnection then
        self.HealthChangedConnection = self.Humanoid.HealthChanged:Connect(function(health)
            if not self.IsGodModeEnabled then return end
            
            if health < self.PreviousHealth - 10 or health < self.Humanoid.MaxHealth * 0.5 then
                self.Humanoid.Health = self.Humanoid.MaxHealth
            end
        end)
    end
    
    if not self.StateChangedConnection then
        self.StateChangedConnection = self.Humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
            if not self.IsGodModeEnabled then return end
            
            if self.Humanoid.PlatformStand then
                self.Humanoid.PlatformStand = false
            end
        end)
    end
    
    self.Humanoid.FallDistance = 0
    
    local oldWalkSpeed = self.Humanoid.WalkSpeed
    local oldJumpPower = self.Humanoid.JumpPower
    
    self.WalkSpeedConnection = self.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if self.IsGodModeEnabled and self.Humanoid.WalkSpeed < oldWalkSpeed then
            self.Humanoid.WalkSpeed = oldWalkSpeed
        else
            oldWalkSpeed = self.Humanoid.WalkSpeed
        end
    end)
    
    self.JumpPowerConnection = self.Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if self.IsGodModeEnabled and self.Humanoid.JumpPower < oldJumpPower then
            self.Humanoid.JumpPower = oldJumpPower
        else
            oldJumpPower = self.Humanoid.JumpPower
        end
    end)
    
    pcall(function()
        for _, part in pairs(self.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanTouch = false end)
                pcall(function() part.Massless = true end)
            end
        end
    end)
    
    task.spawn(function()
        while self.IsGodModeEnabled and self.Humanoid do
            -- If in a bad state, force back to normal
            local state = self.Humanoid:GetState()
            if state == Enum.HumanoidStateType.Dead or 
               state == Enum.HumanoidStateType.FallingDown or 
               state == Enum.HumanoidStateType.Ragdoll then
                pcall(function() self.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            end
            task.wait(0.1)
        end
    end)
    
    return true
end

function GodModeModule:Disable()
    self.IsGodModeEnabled = false
    
    for _, connection in pairs({
        self.GodModeConnection,
        self.FallDamageConnection, 
        self.StateChangedConnection,
        self.HealthChangedConnection,
        self.SteppedConnection,
        self.WalkSpeedConnection,
        self.JumpPowerConnection
    }) do
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
    
    if self.Humanoid then
        self.Humanoid.MaxHealth = self.OriginalMaxHealth
        self.Humanoid.Health = self.OriginalMaxHealth
        
        pcall(function() self.Humanoid.FallDistance = 200 end) -- Default for most games
    end
    
    if self.Character then
        for _, part in pairs(self.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanTouch = true end)
                pcall(function() part.Massless = false end)
            end
        end
    end
    
    self.PreviousHealth = nil
    self.PreviousState = nil
    
    return true
end

function GodModeModule:Toggle()
    if self.IsGodModeEnabled then
        return self:Disable()
    else
        return self:Enable()
    end
end

function GodModeModule:IsEnabled()
    return self.IsGodModeEnabled
end

return GodModeModule