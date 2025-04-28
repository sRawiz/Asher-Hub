local NoClip = {}
NoClip.__index = NoClip

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function NoClip.new()
    local self = setmetatable({}, NoClip)
    
    self.Character = nil
    self.Humanoid = nil
    self.IsNoClipping = false
    self.NoClipConnection = nil
    
    return self
end

function NoClip:SetCharacter(character)
    self.Character = character
    if self.Character then
        self.Humanoid = self.Character:WaitForChild("Humanoid")
        
        if self.Humanoid then
            self.Humanoid.Died:Connect(function()
                if self.IsNoClipping then
                    self:Disable()
                end
            end)
        end
        
        self.Character.DescendantAdded:Connect(function(descendant)
            if self.IsNoClipping and descendant:IsA("BasePart") then
                descendant.CanCollide = false
            end
        end)
    end
end

function NoClip:Enable()
    if not self.Character then
        self:SetCharacter(LocalPlayer.Character)
        if not self.Character then return end
    end
    
    self.IsNoClipping = true
    
    self:UpdateNoClipForAllParts()
    
    self:SetupNoClipLoop()
    
    return true
end

function NoClip:Disable()
    self.IsNoClipping = false
    
    if self.NoClipConnection then
        self.NoClipConnection:Disconnect()
        self.NoClipConnection = nil
    end
    
    if self.Character then
        for _, part in pairs(self.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    
    return true
end

function NoClip:UpdateNoClipForAllParts()
    if not self.Character or not self.IsNoClipping then return end
    
    for _, part in pairs(self.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

function NoClip:SetupNoClipLoop()
    if self.NoClipConnection then
        self.NoClipConnection:Disconnect()
    end
    
    self.NoClipConnection = RunService.Stepped:Connect(function()
        if self.IsNoClipping and self.Character then
            for _, part in pairs(self.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

function NoClip:Toggle()
    if self.IsNoClipping then
        return self:Disable()
    else
        return self:Enable()
    end
end

function NoClip:IsEnabled()
    return self.IsNoClipping
end

return NoClip