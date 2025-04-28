local RepoURL = "https://raw.githubusercontent.com/sRawiz/Asher-Hub/main"

local function LoadModule(moduleName)
    local success, moduleContent = pcall(function()
        return game:HttpGet(RepoURL .. "/" .. moduleName .. ".lua")
    end)
    
    if success then
        local moduleFunction, loadError = loadstring(moduleContent)
        if moduleFunction then
            local moduleSuccess, moduleResult = pcall(moduleFunction)
            if moduleSuccess then
                print("Successfully loaded " .. moduleName)
                return moduleResult
            else
                warn("Error executing " .. moduleName .. ": " .. tostring(moduleResult))
                return nil
            end
        else
            warn("Error loading " .. moduleName .. ": " .. tostring(loadError))
            return nil
        end
    else
        warn("Error fetching " .. moduleName .. ": " .. tostring(moduleContent))
        return nil
    end
end

local Configuration = {
    FlySpeed = 25,
    ToggleFlyKey = Enum.KeyCode.E,
    ToggleNoClipKey = Enum.KeyCode.C,
    ToggleInvisibleKey = Enum.KeyCode.X,
    ToggleWalkSpeedKey = Enum.KeyCode.R,
    SpeedIncreaseKey = Enum.KeyCode.Q,
    SpeedDecreaseKey = Enum.KeyCode.Z,
    MaxSpeed = 100,
    MinSpeed = 5,
    SpeedIncrement = 5,
    PrintCooldown = 1,
    ToggleUIKey = Enum.KeyCode.RightControl,
    WalkSpeed = 32,
    MaxWalkSpeed = 100,
    MinWalkSpeed = 16,

}

local UI = LoadModule("UI")
local Fly = LoadModule("Fly")
local NoClip = LoadModule("NoClip")
local Invisible = LoadModule("Invisible")
local WalkSpeed = LoadModule("WalkSpeed")

if not UI then
    warn("Failed to load UI module")
    return
end

if not Fly then
    warn("Failed to load FlyModule")
    return
end 

if not NoClip then
    warn("Failed to load NoClipModule")
    return
end

if not Invisible then
    warn("Failed to load InvisibleModule")
    return
end

local IsFlying = false
local IsNoClipping = false
local IsInvisible = false
local IsWalkSpeedModified = false

local flyInterface = Fly.new(Configuration)
local noClipInterface = NoClip.new()
local invisibleInterface = Invisible.new()
local walkSpeedInterface = WalkSpeed.new(Configuration)
local uiInterface = UI.new(Configuration)

uiInterface.OnToggleFly = function()
    if IsFlying then
        flyInterface:Stop()
        IsFlying = false
    else
        flyInterface:Start()
        IsFlying = true
    end
    uiInterface:UpdateFlyStatus(IsFlying)
end

uiInterface.OnToggleNoClip = function()
    if IsNoClipping then
        noClipInterface:Disable()
        IsNoClipping = false
    else
        noClipInterface:Enable()
        IsNoClipping = true
    end
    uiInterface:UpdateNoClipStatus(IsNoClipping)
end

uiInterface.OnToggleWalkSpeed = function()
    if IsWalkSpeedModified then
        walkSpeedInterface:Disable()
        IsWalkSpeedModified = false
    else
        walkSpeedInterface:Enable()
        IsWalkSpeedModified = true
    end
    uiInterface:UpdateWalkSpeedStatus(IsWalkSpeedModified, walkSpeedInterface:GetSpeed())
end

uiInterface.OnToggleInvisible = function() 
    if IsInvisible then
        invisibleInterface:Disable()
        IsInvisible = false
    else
        invisibleInterface:Enable()
        IsInvisible = true
    end
    uiInterface:UpdateInvisibleStatus(IsInvisible)
end

uiInterface.OnIncreaseSpeed = function()
    local newSpeed = flyInterface:AdjustSpeed(Configuration.SpeedIncrement)
    uiInterface:UpdateSpeed(newSpeed)
end

uiInterface.OnDecreaseSpeed = function()
    local newSpeed = flyInterface:AdjustSpeed(-Configuration.SpeedIncrement)
    uiInterface:UpdateSpeed(newSpeed)
end

uiInterface.OnIncreaseWalkSpeed = function()
    if IsWalkSpeedModified then
        local newSpeed = walkSpeedInterface:AdjustSpeed(Configuration.SpeedIncrement)
        uiInterface:UpdateWalkSpeedStatus(true, newSpeed)
    end
end

uiInterface.OnDecreaseWalkSpeed = function()
    if IsWalkSpeedModified then
        local newSpeed = walkSpeedInterface:AdjustSpeed(-Configuration.SpeedIncrement)
        uiInterface:UpdateWalkSpeedStatus(true, newSpeed)
    end
end

local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
    if GameProcessedEvent then return end
    
    local KeyCode = Input.KeyCode
    
    if KeyCode == Configuration.ToggleFlyKey then
        uiInterface.OnToggleFly()
    end
    
    if KeyCode == Configuration.ToggleNoClipKey then
        uiInterface.OnToggleNoClip()
    end
    
    if KeyCode == Configuration.ToggleInvisibleKey then
        uiInterface.OnToggleInvisible()
    end
    
    if KeyCode == Configuration.ToggleWalkSpeedKey then
        uiInterface.OnToggleWalkSpeed()
    end
    
    if KeyCode == Configuration.SpeedIncreaseKey then
        if IsFlying then
            uiInterface.OnIncreaseSpeed()
        elseif IsWalkSpeedModified then
            local newSpeed = walkSpeedInterface:AdjustSpeed(Configuration.SpeedIncrement)
            uiInterface:UpdateWalkSpeedStatus(IsWalkSpeedModified, newSpeed)
        end
    elseif KeyCode == Configuration.SpeedDecreaseKey then
        if IsFlying then
            uiInterface.OnDecreaseSpeed()
        elseif IsWalkSpeedModified then
            local newSpeed = walkSpeedInterface:AdjustSpeed(-Configuration.SpeedIncrement)
            uiInterface:UpdateWalkSpeedStatus(IsWalkSpeedModified, newSpeed)
        end
    end
    
    if KeyCode == Configuration.ToggleUIKey then
        uiInterface:ToggleVisibility()
    end
    
    flyInterface:HandleInput(KeyCode, true)
end)

UserInputService.InputEnded:Connect(function(Input)
    flyInterface:HandleInput(Input.KeyCode, false)
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Character Respawn
LocalPlayer.CharacterAdded:Connect(function(Character)
    flyInterface:SetCharacter(Character)
    noClipInterface:SetCharacter(Character)
    invisibleInterface:SetCharacter(Character)
    walkSpeedInterface:SetCharacter(Character)  -- เพิ่มบรรทัดนี้
    
    if IsFlying then
        flyInterface:Stop()
        task.wait(0.5)
        flyInterface:Start()
    end
    
    if IsNoClipping then
        noClipInterface:Enable()
    end
    
    if IsInvisible then
        invisibleInterface:Enable()
    end
    
    if IsWalkSpeedModified then
        walkSpeedInterface:Enable()
    end
end)

if LocalPlayer.Character then
    flyInterface:SetCharacter(LocalPlayer.Character)
    noClipInterface:SetCharacter(LocalPlayer.Character)
    invisibleInterface:SetCharacter(LocalPlayer.Character)
    walkSpeedInterface:SetCharacter(LocalPlayer.Character)
end

print("AsherHub loaded successfully!")