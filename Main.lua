local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- โหลดโมดูลจาก GitHub
local FlyModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/sRawiz/Asher-Hub/main/Features/FlyModule.lua"))()
local InvisibleModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/sRawiz/Asher-Hub/main/Features/InvisibleModule.lua"))()
local NoClipModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/sRawiz/Asher-Hub/main/Features/NoClipModule.lua"))()

-- ตั้งค่าเริ่มต้น
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

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

-- สร้าง Instance ของโมดูลต่างๆ
local flyInterface = FlyModule.new(Configuration)
local noClipInterface = NoClipModule.new()
local invisibleInterface = InvisibleModule.new()

-- สถานะการใช้งาน
local IsFlying = false
local IsNoClipping = false
local IsInvisible = false

-- สร้าง UI Window
local Window = Fluent:CreateWindow({
    Title = "AsherHub " .. "v1.0.0",
    SubTitle = "by Asher",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Configuration.ToggleUIKey
})

-- สร้าง Tab ใน UI
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- เก็บ Options สำหรับ Fluent
local Options = Fluent.Options

-- แสดงการแจ้งเตือนเมื่อโหลดสคริปต์
Fluent:Notify({
    Title = "AsherHub",
    Content = "AsherHub has been loaded successfully!",
    Duration = 5
})

-- สร้าง Section Movement ใน Tab Main
local MovementSection = Tabs.Main:AddSection("Movement")

-- เพิ่ม Toggle สำหรับ Fly
local FlyToggle = Tabs.Main:AddToggle("FlyToggle", {
    Title = "Fly",
    Description = "Allows you to fly around the map",
    Default = IsFlying
})

FlyToggle:OnChanged(function()
    if Options.FlyToggle.Value then
        flyInterface:Start()
        IsFlying = true
    else
        flyInterface:Stop()
        IsFlying = false
    end
end)

-- เพิ่ม Toggle สำหรับ NoClip
local NoClipToggle = Tabs.Main:AddToggle("NoClipToggle", {
    Title = "NoClip",
    Description = "Allows you to walk through walls",
    Default = IsNoClipping
})

NoClipToggle:OnChanged(function()
    if Options.NoClipToggle.Value then
        noClipInterface:Enable()
        IsNoClipping = true
    else
        noClipInterface:Disable()
        IsNoClipping = false
    end
end)

-- เพิ่ม Slider สำหรับ Fly Speed
local SpeedSlider = Tabs.Main:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Description = "Adjust your flying speed",
    Default = Configuration.FlySpeed,
    Min = Configuration.MinSpeed,
    Max = Configuration.MaxSpeed,
    Rounding = 0,
    Callback = function(Value)
        Configuration.FlySpeed = Value
        flyInterface.Config.FlySpeed = Value
    end
})

-- สร้าง Section Visibility ใน Tab Main
local VisibilitySection = Tabs.Main:AddSection("Visibility")

-- เพิ่ม Toggle สำหรับ Invisible
local InvisibleToggle = Tabs.Main:AddToggle("InvisibleToggle", {
    Title = "Invisible",
    Description = "Makes your character invisible to yourself",
    Default = IsInvisible
})

InvisibleToggle:OnChanged(function()
    if Options.InvisibleToggle.Value then
        invisibleInterface:Enable()
        IsInvisible = true
    else
        invisibleInterface:Disable()
        IsInvisible = false
    end
end)

-- สร้าง Section Controls ใน Tab Settings
local KeybindsSection = Tabs.Settings:AddSection("Keybinds")

-- เพิ่ม Keybind สำหรับ Toggle Fly
local FlyKeybind = Tabs.Settings:AddKeybind("FlyKeybind", {
    Title = "Toggle Fly",
    Description = "Key to toggle flying mode",
    Default = Configuration.ToggleFlyKey,
    Mode = "Toggle",
    Callback = function(Value)
        if Value then
            FlyToggle:SetValue(not Options.FlyToggle.Value)
        end
    end
})

-- เพิ่ม Keybind สำหรับ Toggle NoClip
local NoClipKeybind = Tabs.Settings:AddKeybind("NoClipKeybind", {
    Title = "Toggle NoClip",
    Description = "Key to toggle noclip mode",
    Default = Configuration.ToggleNoClipKey,
    Mode = "Toggle",
    Callback = function(Value)
        if Value then
            NoClipToggle:SetValue(not Options.NoClipToggle.Value)
        end
    end
})

-- เพิ่ม Keybind สำหรับ Toggle Invisible
local InvisibleKeybind = Tabs.Settings:AddKeybind("InvisibleKeybind", {
    Title = "Toggle Invisible",
    Description = "Key to toggle invisibility",
    Default = Configuration.ToggleInvisibleKey,
    Mode = "Toggle",
    Callback = function(Value)
        if Value then
            InvisibleToggle:SetValue(not Options.InvisibleToggle.Value)
        end
    end
})

-- เพิ่ม Keybind สำหรับเพิ่มความเร็ว
local SpeedUpKeybind = Tabs.Settings:AddKeybind("SpeedUpKeybind", {
    Title = "Increase Speed",
    Description = "Key to increase fly speed",
    Default = Configuration.SpeedIncreaseKey,
    Mode = "Toggle",
    Callback = function(Value)
        if Value then
            local newSpeed = math.min(Configuration.FlySpeed + Configuration.SpeedIncrement, Configuration.MaxSpeed)
            SpeedSlider:SetValue(newSpeed)
        end
    end
})

-- เพิ่ม Keybind สำหรับลดความเร็ว
local SpeedDownKeybind = Tabs.Settings:AddKeybind("SpeedDownKeybind", {
    Title = "Decrease Speed",
    Description = "Key to decrease fly speed",
    Default = Configuration.SpeedDecreaseKey,
    Mode = "Toggle",
    Callback = function(Value)
        if Value then
            local newSpeed = math.max(Configuration.FlySpeed - Configuration.SpeedIncrement, Configuration.MinSpeed)
            SpeedSlider:SetValue(newSpeed)
        end
    end
})

-- เพิ่ม Paragraph แสดงข้อมูลการใช้งาน
Tabs.Main:AddParagraph({
    Title = "How to Use",
    Content = "Press E to toggle fly mode\nPress C to toggle noclip mode\nPress X to toggle invisibility\nPress Q to increase fly speed\nPress Z to decrease fly speed\nPress Right Control to toggle UI"
})

-- เพิ่ม Input Handler สำหรับควบคุมการบิน
UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
    if GameProcessedEvent then return end
    
    local KeyCode = Input.KeyCode
    flyInterface:HandleInput(KeyCode, true)
end)

UserInputService.InputEnded:Connect(function(Input)
    flyInterface:HandleInput(Input.KeyCode, false)
end)

-- ตั้งค่า Character สำหรับโมดูลต่างๆ เมื่อเกิด Character ใหม่
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

-- ตั้งค่า Character เริ่มต้น
if LocalPlayer.Character then
    flyInterface:SetCharacter(LocalPlayer.Character)
    noClipInterface:SetCharacter(LocalPlayer.Character)
    invisibleInterface:SetCharacter(LocalPlayer.Character)
end

-- เพิ่ม Interface Manager และ Save Manager
InterfaceManager:SetLibrary(Fluent)
SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"FlyToggle", "NoClipToggle", "InvisibleToggle"})

InterfaceManager:SetFolder("AsherHub")
SaveManager:SetFolder("AsherHub/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- เลือก Tab แรกโดยอัตโนมัติ
Window:SelectTab(1)

-- โหลดการตั้งค่าอัตโนมัติ (ถ้ามี)
SaveManager:LoadAutoloadConfig()

print("AsherHub loaded successfully!")