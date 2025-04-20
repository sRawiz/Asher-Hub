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
                warn("Error running module: " .. moduleName .. " | " .. tostring(moduleResult))
                return nil
            end
        else
            warn("Error loading module: " .. moduleName .. " | " .. tostring(loadError))
            return nil
        end
    else
        warn("Error fetching module: " .. moduleName .. " | " .. tostring(moduleContent))
        return nil
    end
end

local Configuration = {
    FlySpeed = 25,
    ToggleFlyKey = Enum.KeyCode.E,
    ToggleNoClipKey = Enum.KeyCode.C,
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

if not UI or not FlyModule or not NoClipModule then
    warn("AsherHub: ไม่สามารถโหลดโมดูลที่จำเป็นได้")
    return
end

local IsFlying = false
local IsNoClipping = false

local flyInterface = FlyModule.new(Configuration)
local noClipInterface = NoClipModule.new()
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
    
    if IsFlying then
        flyInterface:Stop()
        task.wait(0.5)
        flyInterface:Start()
    end
    
    if IsNoClipping then
        noClipInterface:Enable()
    end
end)

if LocalPlayer.Character then
    flyInterface:SetCharacter(LocalPlayer.Character)
    noClipInterface:SetCharacter(LocalPlayer.Character)
end

print("Asher Hub พร้อมใช้งานแล้ว | กด E เพื่อบิน | กด C เพื่อทะลุกำแพง | Q/Z เพื่อปรับความเร็ว | Right Ctrl เพื่อซ่อน/แสดง UI")