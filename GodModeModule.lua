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
    
    return self
end

function GodModeModule:SetCharacter(character)
    self.Character = character
    if self.Character then
        self.Humanoid = self.Character:WaitForChild("Humanoid")
        
        if self.Humanoid then
            -- Store original health values
            self.OriginalMaxHealth = self.Humanoid.MaxHealth
            
            self.Humanoid.Died:Connect(function()
                if self.IsGodModeEnabled then
                    self:Disable()
                end
            end)
        end
    end
end

function GodModeModule:Enable()
    if not self.Character then
        self:SetCharacter(LocalPlayer.Character)
        if not self.Character or not self.Humanoid then return false end
    end
    
    self.IsGodModeEnabled = true
    
    -- Make character invincible
    self.Humanoid.MaxHealth = math.huge
    self.Humanoid.Health = math.huge
    
    -- Prevent fall damage and other damage
    if not self.GodModeConnection then
        self.GodModeConnection = RunService.Heartbeat:Connect(function()
            if not self.Character or not self.Humanoid then return end
            if self.Humanoid.Health < math.huge then
                self.Humanoid.Health = math.huge
            end
        end)
    end
    
    -- Additional handling for fall damage specifically
    if not self.FallDamageConnection then
        self.FallDamageConnection = self.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if self.IsGodModeEnabled and self.Humanoid.Health < math.huge then
                self.Humanoid.Health = math.huge
            end
        end)
    end
    
    print("God Mode เปิดใช้งาน")
    return true
end

function GodModeModule:Disable()
    self.IsGodModeEnabled = false
    
    if self.GodModeConnection then
        self.GodModeConnection:Disconnect()
        self.GodModeConnection = nil
    end
    
    if self.FallDamageConnection then
        self.FallDamageConnection:Disconnect()
        self.FallDamageConnection = nil
    end
    
    if self.Humanoid then
        -- Restore original health values
        self.Humanoid.MaxHealth = self.OriginalMaxHealth
        self.Humanoid.Health = self.OriginalMaxHealth
    end
    
    print("God Mode ปิดใช้งาน")
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