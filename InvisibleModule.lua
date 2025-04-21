local InvisibleModule = {}
InvisibleModule.__index = InvisibleModule

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

function InvisibleModule.new()
    local self = setmetatable({}, InvisibleModule)
    
    self.Character = nil
    self.Humanoid = nil
    self.IsInvisible = false
    self.OriginalParts = {}
    self.InvisibilityConnection = nil
    
    return self
end

function InvisibleModule:SetCharacter(character)
    self.Character = character
    if self.Character then
        self.Humanoid = self.Character:WaitForChild("Humanoid")
        
        if self.Humanoid then
            self.Humanoid.Died:Connect(function()
                if self.IsInvisible then
                    self:Disable()
                end
            end)
        end
    end
end

function InvisibleModule:Enable()
    if not self.Character then
        self:SetCharacter(LocalPlayer.Character)
        if not self.Character then return false end
    end
    
    if self.IsInvisible then return true end
    
    self.IsInvisible = true
    self.OriginalParts = {}
    
    for _, part in pairs(self.Character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") or part:IsA("ParticleEmitter") then
            self.OriginalParts[part] = part.Transparency
            part.Transparency = 1
        elseif part:IsA("BillboardGui") or part:IsA("SurfaceGui") or part:IsA("Beam") then
            self.OriginalParts[part] = part.Enabled
            part.Enabled = false
        end
    end
    
    self.InvisibilityConnection = self.Character.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture") or descendant:IsA("ParticleEmitter") then
            self.OriginalParts[descendant] = descendant.Transparency
            descendant.Transparency = 1
        elseif descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") or descendant:IsA("Beam") then
            self.OriginalParts[descendant] = descendant.Enabled
            descendant.Enabled = false
        end
    end)
    
    return true
end

function InvisibleModule:Disable()
    if not self.IsInvisible then return false end
    
    self.IsInvisible = false
    
    for part, originalValue in pairs(self.OriginalParts) do
        if part and part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") or part:IsA("ParticleEmitter") then
            part.Transparency = originalValue
        elseif part and (part:IsA("BillboardGui") or part:IsA("SurfaceGui") or part:IsA("Beam")) then
            part.Enabled = originalValue
        end
    end
    
    self.OriginalParts = {}
    
    if self.InvisibilityConnection then
        self.InvisibilityConnection:Disconnect()
        self.InvisibilityConnection = nil
    end
    
    return true
end

function InvisibleModule:Toggle()
    if self.IsInvisible then
        return self:Disable()
    else
        return self:Enable()
    end
end

function InvisibleModule:IsEnabled()
    return self.IsInvisible
end

return InvisibleModule