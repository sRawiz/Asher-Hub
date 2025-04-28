local WalkSpeed = {}
WalkSpeed.__index = WalkSpeed

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function WalkSpeed.new(config)
    local self = setmetatable({}, WalkSpeed)
    
    self.Character = nil
    self.Humanoid = nil
    self.DefaultWalkSpeed = 16 -- Default Roblox walk speed
    self.IsSpeedModified = false
    
    self.Config = config or {
        WalkSpeed = 32,
        MaxWalkSpeed = 100,
        MinWalkSpeed = 16,
        SpeedIncrement = 5
    }
    
    return self
end

function WalkSpeed:SetCharacter(character)
    self.Character = character
    if self.Character then
        self.Humanoid = self.Character:WaitForChild("Humanoid")
        
        if self.Humanoid then
            -- Store the original walk speed
            self.DefaultWalkSpeed = self.Humanoid.WalkSpeed
            
            self.Humanoid.Died:Connect(function()
                if self.IsSpeedModified then
                    self:Disable()
                end
            end)
        end
    end
end

function WalkSpeed:Enable()
    if not self.Character then
        self:SetCharacter(LocalPlayer.Character)
        if not self.Character or not self.Humanoid then return false end
    end
    
    if self.IsSpeedModified then return true end
    
    self.IsSpeedModified = true
    self.Humanoid.WalkSpeed = self.Config.WalkSpeed
    
    return true
end

function WalkSpeed:Disable()
    if not self.IsSpeedModified then return false end
    
    self.IsSpeedModified = false
    
    if self.Humanoid then
        self.Humanoid.WalkSpeed = self.DefaultWalkSpeed
    end
    
    return true
end

function WalkSpeed:Toggle()
    if self.IsSpeedModified then
        return self:Disable()
    else
        return self:Enable()
    end
end

function WalkSpeed:SetSpeed(speed)
    self.Config.WalkSpeed = math.clamp(
        speed,
        self.Config.MinWalkSpeed,
        self.Config.MaxWalkSpeed
    )
    
    if self.IsSpeedModified and self.Humanoid then
        self.Humanoid.WalkSpeed = self.Config.WalkSpeed
    end
    
    return self.Config.WalkSpeed
end

function WalkSpeed:AdjustSpeed(increment)
    return self:SetSpeed(self.Config.WalkSpeed + increment)
end

function WalkSpeed:GetSpeed()
    return self.Config.WalkSpeed
end

function WalkSpeed:IsEnabled()
    return self.IsSpeedModified
end

return WalkSpeed