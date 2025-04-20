local RepoURL = "https://raw.githubusercontent.com/sRawiz/Asher-Hub/main"

local function LoadModule(moduleName)
    local success, moduleContent = pcall(function()
        return game:HttpGet(RepoURL .. "/" .. moduleName .. ".lua")
    end)
    
    if success then
        local moduleFunction, loadError = loadstring(moduleContent)
        if moduleFunction then
            local success, moduleResult = pcall(moduleFunction)
            if success then
                return moduleResult
            else
                return nil
            end
        else
            return nil
        end
    else
        return nil
    end
end

local Configuration = {
    FlySpeed = 25,
    ToggleFlyKey = Enum.KeyCode.E,
    ToggleNoClipKey = Enum.KeyCode.C,
    ToggleGodModeKey = Enum.KeyCode.G,
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
local GodModeModule = LoadModule("GodModeModule")

if not UI or not FlyModule or not NoClipModule then
    return
end

local IsFlying = false
local IsNoClipping = false
local IsGodMode = false

local flyInterface = FlyModule.new(Configuration)
local noClipInterface = NoClipModule.new()
local godModeInterface = GodModeModule and GodModeModule.new() or nil
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

uiInterface.OnToggleGodMode = function()
    if godModeInterface then
        if IsGodMode then
            godModeInterface:Disable()
            IsGodMode = false
        else
            godModeInterface:Enable()
            IsGodMode = true
        end
        uiInterface:UpdateGodModeStatus and uiInterface:UpdateGodModeStatus(IsGodMode)
    end
end

uiInterface.OnIncreaseSpeed = function()
    flyInterface:AdjustSpeed(Configuration.SpeedIncrement)
    uiInterface:UpdateSpeed(flyInterface:GetSpeed())
end

uiInterface.OnDecreaseSpeed = function()
    flyInterface:AdjustSpeed(-Configuration.SpeedIncrement)
    uiInterface:UpdateSpeed(flyInterface:GetSpeed())
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
    
    if KeyCode == Configuration.ToggleGodModeKey and godModeInterface then
        uiInterface.OnToggleGodMode()
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

-- Character handling
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

LocalPlayer.CharacterAdded:Connect(function(Character)
    flyInterface:SetCharacter(Character)
    noClipInterface:SetCharacter(Character)
    if godModeInterface then
        godModeInterface:SetCharacter(Character)
    end
    
    if IsFlying then
        flyInterface:Stop()
        task.wait(0.5)
        flyInterface:Start()
    end
    
    if IsNoClipping then
        noClipInterface:Enable()
    end
    
    if IsGodMode and godModeInterface then
        godModeInterface:Enable()
    end
end)

if LocalPlayer.Character then
    flyInterface:SetCharacter(LocalPlayer.Character)
    noClipInterface:SetCharacter(LocalPlayer.Character)
    if godModeInterface then
        godModeInterface:SetCharacter(LocalPlayer.Character)
    end
end