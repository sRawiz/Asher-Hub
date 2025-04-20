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
    SpeedIncreaseKey = Enum.KeyCode.Q,
    SpeedDecreaseKey = Enum.KeyCode.Z,
    MaxSpeed = 100,
    MinSpeed = 5,
    SpeedIncrement = 5,
    PrintCooldown = 1,
    ToggleUIKey = Enum.KeyCode.RightControl
}

local UI = LoadModule("UI")
local FlyModule = LoadModule("FlyModule")
local NoClipModule = LoadModule("NoClipModule")
local InvisibleModule = LoadModule("InvisibleModule")

if not UI then
    warn("Failed to load UI module")
    return
end

if not FlyModule then
    warn("Failed to load FlyModule")
    return
end 

if not NoClipModule then
    warn("Failed to load NoClipModule")
    return
end

if not InvisibleModule then
    warn("Failed to load InvisibleModule")
    return
end

local IsFlying = false
local IsNoClipping = false
local IsInvisible = false

local flyInterface = FlyModule.new(Configuration)
local noClipInterface = NoClipModule.new()
local invisibleInterface = InvisibleModule.new()
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
    
    if KeyCode == Configuration.SpeedIncreaseKey then
        uiInterface.OnIncreaseSpeed()
    elseif KeyCode == Configuration.SpeedDecreaseKey then
        uiInterface.OnDecreaseSpeed()
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

LocalPlayer.CharacterAdded:Connect(function(Character)
    flyInterface:SetCharacter(Character)
    noClipInterface:SetCharacter(Character)
    invisibleInterface:SetCharacter(Character)
    
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
end)

if LocalPlayer.Character then
    flyInterface:SetCharacter(LocalPlayer.Character)
    noClipInterface:SetCharacter(LocalPlayer.Character)
    invisibleInterface:SetCharacter(LocalPlayer.Character)
end

print("AsherHub loaded successfully!")