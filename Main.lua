-- AsherHub with Fluent UI Integration

-- Load Fluent UI Library and Addons
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Load AsherHub Modules
local FlyModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/sRawiz/Asher-Hub/main/Features/FlyModule.lua"))()
local InvisibleModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/sRawiz/Asher-Hub/main/Features/InvisibleModule.lua"))()
local NoClipModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/sRawiz/Asher-Hub/main/Features/NoClipModule.lua"))()

-- Configuration
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

-- Initialize Fluent UI Window
local Window = Fluent:CreateWindow({
    Title = "AsherHub " .. Fluent.Version,
    SubTitle = "by sRawiz",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Configuration.ToggleUIKey
})

-- Create Tabs
local Tabs = {
    Movement = Window:AddTab({ Title = "Movement", Icon = "move" }),
    Character = Window:AddTab({ Title = "Character", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Setup module interfaces
local flyInterface = FlyModule.new(Configuration)
local noClipInterface = NoClipModule.new()
local invisibleInterface = InvisibleModule.new()

-- Track states
local IsFlying = false
local IsNoClipping = false
local IsInvisible = false

-- Setup Players reference
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Welcome Notification
Fluent:Notify({
    Title = "AsherHub Loaded",
    Content = "Welcome to AsherHub with Fluent UI!",
    Duration = 5
})

-- Movement Tab Content
Tabs.Movement:AddParagraph({
    Title = "Movement Controls",
    Content = "Enhance your mobility with flight and noclip features."
})

-- Fly Toggle
local FlyToggle = Tabs.Movement:AddToggle("FlyToggle", {
    Title = "Fly",
    Description = "Toggle flying ability (Default key: E)",
    Default = false
})

FlyToggle:OnChanged(function()
    if FlyToggle.Value then
        flyInterface:Start()
        IsFlying = true
        Fluent:Notify({
            Title = "Fly Enabled",
            Content = "Use WASD to move, Space to go up, Shift to go down",
            Duration = 3
        })
    else
        flyInterface:Stop()
        IsFlying = false
        Fluent:Notify({
            Title = "Fly Disabled",
            Content = "Flight mode turned off",
            Duration = 2
        })
    end
end)

-- NoClip Toggle
local NoClipToggle = Tabs.Movement:AddToggle("NoClipToggle", {
    Title = "NoClip",
    Description = "Toggle noclip through walls (Default key: C)",
    Default = false
})

NoClipToggle:OnChanged(function()
    if NoClipToggle.Value then
        noClipInterface:Enable()
        IsNoClipping = true
        Fluent:Notify({
            Title = "NoClip Enabled",
            Content = "You can now pass through objects",
            Duration = 2
        })
    else
        noClipInterface:Disable()
        IsNoClipping = false
        Fluent:Notify({
            Title = "NoClip Disabled",
            Content = "Collision returned to normal",
            Duration = 2
        })
    end
end)

-- Fly Speed Slider
local FlySpeedSlider = Tabs.Movement:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Description = "Adjust your flight speed",
    Default = Configuration.FlySpeed,
    Min = Configuration.MinSpeed,
    Max = Configuration.MaxSpeed,
    Rounding = 0,
    Callback = function(Value)
        Configuration.FlySpeed = Value
        if flyInterface then
            flyInterface.Config.FlySpeed = Value
        end
    end
})

-- Character Tab Content
Tabs.Character:AddParagraph({
    Title = "Character Modifications",
    Content = "Modify your character's appearance and physics."
})

-- Invisible Toggle
local InvisibleToggle = Tabs.Character:AddToggle("InvisibleToggle", {
    Title = "Invisible",
    Description = "Toggle invisibility (Default key: X)",
    Default = false
})

InvisibleToggle:OnChanged(function()
    if InvisibleToggle.Value then
        invisibleInterface:Enable()
        IsInvisible = true
        Fluent:Notify({
            Title = "Invisibility Enabled",
            Content = "You are now invisible to other players",
            Duration = 2
        })
    else
        invisibleInterface:Disable()
        IsInvisible = false
        Fluent:Notify({
            Title = "Invisibility Disabled",
            Content = "You are now visible to other players",
            Duration = 2
        })
    end
end)

-- Keybind section in Settings tab
Tabs.Settings:AddParagraph({
    Title = "Keybinds",
    Content = "Customize your keyboard shortcuts"
})

-- Fly Keybind
local FlyKeybind = Tabs.Settings:AddKeybind("FlyKeybind", {
    Title = "Fly Toggle Key",
    Description = "Key to toggle flight mode",
    Default = Configuration.ToggleFlyKey.Name,
    Mode = "Toggle", -- แก้ไข Mode เป็น Toggle จาก KeyDown
    ChangedCallback = function(NewKey)
        Configuration.ToggleFlyKey = NewKey
    end
})

-- แก้ไขเพื่อให้ FlyKeybind ทำงานโดยตรงกับ FlyToggle
FlyKeybind:OnClick(function()
    FlyToggle:SetValue(not FlyToggle.Value)
end)

-- NoClip Keybind
local NoClipKeybind = Tabs.Settings:AddKeybind("NoClipKeybind", {
    Title = "NoClip Toggle Key",
    Description = "Key to toggle noclip mode",
    Default = Configuration.ToggleNoClipKey.Name,
    Mode = "Toggle", -- แก้ไข Mode เป็น Toggle จาก KeyDown
    ChangedCallback = function(NewKey)
        Configuration.ToggleNoClipKey = NewKey
    end
})

-- แก้ไขเพื่อให้ NoClipKeybind ทำงานโดยตรงกับ NoClipToggle
NoClipKeybind:OnClick(function()
    NoClipToggle:SetValue(not NoClipToggle.Value)
end)

-- Invisible Keybind
local InvisibleKeybind = Tabs.Settings:AddKeybind("InvisibleKeybind", {
    Title = "Invisible Toggle Key",
    Description = "Key to toggle invisibility",
    Default = Configuration.ToggleInvisibleKey.Name,
    Mode = "Toggle", -- แก้ไข Mode เป็น Toggle จาก KeyDown
    ChangedCallback = function(NewKey)
        Configuration.ToggleInvisibleKey = NewKey
    end
})

-- แก้ไขเพื่อให้ InvisibleKeybind ทำงานโดยตรงกับ InvisibleToggle
InvisibleKeybind:OnClick(function()
    InvisibleToggle:SetValue(not InvisibleToggle.Value)
end)

-- ปรับปรุงระบบการจัดการ Input ให้ดีขึ้น
local UserInputService = game:GetService("UserInputService")

-- ลบคำสั่งระบบ debounce เดิมและปรับปรุงใหม่
local keyPressTime = {}

UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
    if GameProcessedEvent then return end
    
    local KeyCode = Input.KeyCode
    local currentTime = tick()
    
    -- ป้องกันการกดปุ่มที่เร็วเกินไป แต่ให้กดได้เลยถ้าปุ่มนั้นยังไม่เคยถูกกด
    if keyPressTime[KeyCode] and (currentTime - keyPressTime[KeyCode] < 0.2) then
        return
    end
    
    keyPressTime[KeyCode] = currentTime
    
    -- ตรวจสอบปุ่มและสั่งการทำงานของฟังก์ชันแต่ละปุ่ม
    if KeyCode == Configuration.ToggleFlyKey then
        -- เรียกใช้ฟังก์ชันโดยตรงแทนการใช้ToggleValue
        if IsFlying then
            flyInterface:Stop()
            IsFlying = false
            FlyToggle:SetValue(false)
            Fluent:Notify({
                Title = "Fly Disabled",
                Content = "Flight mode turned off",
                Duration = 2
            })
        else
            flyInterface:Start()
            IsFlying = true
            FlyToggle:SetValue(true)
            Fluent:Notify({
                Title = "Fly Enabled",
                Content = "Use WASD to move, Space to go up, Shift to go down",
                Duration = 3
            })
        end
    end
    
    if KeyCode == Configuration.ToggleNoClipKey then
        if IsNoClipping then
            noClipInterface:Disable()
            IsNoClipping = false
            NoClipToggle:SetValue(false)
            Fluent:Notify({
                Title = "NoClip Disabled",
                Content = "Collision returned to normal",
                Duration = 2
            })
        else
            noClipInterface:Enable()
            IsNoClipping = true
            NoClipToggle:SetValue(true)
            Fluent:Notify({
                Title = "NoClip Enabled",
                Content = "You can now pass through objects",
                Duration = 2
            })
        end
    end
    
    if KeyCode == Configuration.ToggleInvisibleKey then
        if IsInvisible then
            invisibleInterface:Disable()
            IsInvisible = false
            InvisibleToggle:SetValue(false)
            Fluent:Notify({
                Title = "Invisibility Disabled",
                Content = "You are now visible to other players",
                Duration = 2
            })
        else
            invisibleInterface:Enable()
            IsInvisible = true
            InvisibleToggle:SetValue(true)
            Fluent:Notify({
                Title = "Invisibility Enabled",
                Content = "You are now invisible to other players",
                Duration = 2
            })
        end
    end
    
    if KeyCode == Configuration.SpeedIncreaseKey then
        local newSpeed = math.min(Configuration.FlySpeed + Configuration.SpeedIncrement, Configuration.MaxSpeed)
        FlySpeedSlider:SetValue(newSpeed)
    elseif KeyCode == Configuration.SpeedDecreaseKey then
        local newSpeed = math.max(Configuration.FlySpeed - Configuration.SpeedIncrement, Configuration.MinSpeed)
        FlySpeedSlider:SetValue(newSpeed)
    end
    
    flyInterface:HandleInput(KeyCode, true)
end)

UserInputService.InputEnded:Connect(function(Input)
    flyInterface:HandleInput(Input.KeyCode, false)
end)

-- Handle character respawning
LocalPlayer.CharacterAdded:Connect(function(Character)
    flyInterface:SetCharacter(Character)
    noClipInterface:SetCharacter(Character)
    invisibleInterface:SetCharacter(Character)
    
    -- Re-enable features if they were active before
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

-- Initialize with current character
if LocalPlayer.Character then
    flyInterface:SetCharacter(LocalPlayer.Character)
    noClipInterface:SetCharacter(LocalPlayer.Character)
    invisibleInterface:SetCharacter(LocalPlayer.Character)
end

-- Set up SaveManager and InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"FlyKeybind", "NoClipKeybind", "InvisibleKeybind"})
InterfaceManager:SetFolder("AsherHub")
SaveManager:SetFolder("AsherHub/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Select first tab by default
Window:SelectTab(1)

print("AsherHub with Fluent UI loaded successfully!")