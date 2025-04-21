local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- โหลดโมดูลทั้งหมด
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
local invisibleInterface = InvisibleModule.new()
local noClipInterface = NoClipModule.new()

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
    Content = "AsherHub ได้โหลดเสร็จสมบูรณ์แล้ว!",
    Duration = 5
})

-- สร้าง Section Movement ใน Tab Main
local MovementSection = Tabs.Main:AddSection("Movement")

-- เพิ่ม Toggle สำหรับ Fly
local FlyToggle = Tabs.Main:AddToggle("FlyToggle", {
    Title = "Fly",
    Description = "อนุญาตให้คุณบินรอบแมพ",
    Default = IsFlying
})

FlyToggle:OnChanged(function()
    if Options.FlyToggle.Value then
        flyInterface:Start()
        IsFlying = true
        print("เริ่มการบิน")
    else
        flyInterface:Stop()
        IsFlying = false
        print("หยุดการบิน")
    end
end)

-- เพิ่ม Toggle สำหรับ NoClip
local NoClipToggle = Tabs.Main:AddToggle("NoClipToggle", {
    Title = "NoClip",
    Description = "อนุญาตให้คุณเดินทะลุกำแพง",
    Default = IsNoClipping
})

NoClipToggle:OnChanged(function()
    if Options.NoClipToggle.Value then
        noClipInterface:Enable()
        IsNoClipping = true
        print("เปิดใช้งาน NoClip")
    else
        noClipInterface:Disable()
        IsNoClipping = false
        print("ปิดใช้งาน NoClip")
    end
end)

-- เพิ่ม Slider สำหรับ Fly Speed
local SpeedSlider = Tabs.Main:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Description = "ปรับความเร็วในการบิน",
    Default = Configuration.FlySpeed,
    Min = Configuration.MinSpeed,
    Max = Configuration.MaxSpeed,
    Rounding = 0,
    Callback = function(Value)
        Configuration.FlySpeed = Value
        flyInterface.Config.FlySpeed = Value
        print("ตั้งค่าความเร็วการบินเป็น: " .. Value)
    end
})

-- สร้าง Section Visibility ใน Tab Main
local VisibilitySection = Tabs.Main:AddSection("Visibility")

-- เพิ่ม Toggle สำหรับ Invisible
local InvisibleToggle = Tabs.Main:AddToggle("InvisibleToggle", {
    Title = "Invisible",
    Description = "ทำให้ตัวละครของคุณมองไม่เห็น",
    Default = IsInvisible
})

InvisibleToggle:OnChanged(function()
    if Options.InvisibleToggle.Value then
        invisibleInterface:Enable()
        IsInvisible = true
        print("เปิดใช้งานการล่องหน")
    else
        invisibleInterface:Disable()
        IsInvisible = false
        print("ปิดใช้งานการล่องหน")
    end
end)

-- สร้าง Section Controls ใน Tab Settings
local KeybindsSection = Tabs.Settings:AddSection("Keybinds")

-- แก้ไขการแสดงผลคีย์ตัวเองให้เป็นข้อความ
local function KeyToString(key)
    if typeof(key) == "EnumItem" then
        return tostring(key):gsub("Enum.KeyCode.", "")
    end
    return tostring(key)
end

-- เพิ่ม Keybind สำหรับ Toggle Fly
local FlyKeybind = Tabs.Settings:AddKeybind("FlyKeybind", {
    Title = "Toggle Fly",
    Description = "ปุ่มสำหรับเปิด/ปิดโหมดบิน",
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
    Description = "ปุ่มสำหรับเปิด/ปิดโหมด NoClip",
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
    Description = "ปุ่มสำหรับเปิด/ปิดโหมดล่องหน",
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
    Description = "ปุ่มสำหรับเพิ่มความเร็วการบิน",
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
    Description = "ปุ่มสำหรับลดความเร็วการบิน",
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
    Title = "วิธีใช้งาน",
    Content = "กด E เพื่อเปิด/ปิดโหมดบิน\nกด C เพื่อเปิด/ปิดโหมดเดินทะลุ\nกด X เพื่อเปิด/ปิดโหมดล่องหน\nกด Q เพื่อเพิ่มความเร็วการบิน\nกด Z เพื่อลดความเร็วการบิน\nกด Right Control เพื่อเปิด/ปิด UI"
})

-- การตรวจจับการกดปุ่มควบคุมทั้งหมด
UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
    if GameProcessedEvent then return end
    
    -- ตรวจสอบว่ากดปุ่มที่กำหนดไว้หรือไม่โดยตรง
    local KeyCode = Input.KeyCode
    
    if KeyCode == Configuration.ToggleFlyKey then
        FlyToggle:SetValue(not Options.FlyToggle.Value)
    elseif KeyCode == Configuration.ToggleNoClipKey then
        NoClipToggle:SetValue(not Options.NoClipToggle.Value)
    elseif KeyCode == Configuration.ToggleInvisibleKey then
        InvisibleToggle:SetValue(not Options.InvisibleToggle.Value)
    elseif KeyCode == Configuration.SpeedIncreaseKey then
        local newSpeed = math.min(Configuration.FlySpeed + Configuration.SpeedIncrement, Configuration.MaxSpeed)
        SpeedSlider:SetValue(newSpeed)
    elseif KeyCode == Configuration.SpeedDecreaseKey then
        local newSpeed = math.max(Configuration.FlySpeed - Configuration.SpeedIncrement, Configuration.MinSpeed)
        SpeedSlider:SetValue(newSpeed)
    end
    
    -- ส่งข้อมูลการควบคุมการบินไปยังโมดูล Fly
    if IsFlying then
        flyInterface:HandleInput(KeyCode, true)
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    -- ส่งข้อมูลการปล่อยปุ่มไปยังโมดูล Fly
    if IsFlying then
        flyInterface:HandleInput(Input.KeyCode, false)
    end
end)

-- ตั้งค่า Character สำหรับโมดูลต่างๆ เมื่อเกิด Character ใหม่
LocalPlayer.CharacterAdded:Connect(function(Character)
    flyInterface:SetCharacter(Character)
    noClipInterface:SetCharacter(Character)
    invisibleInterface:SetCharacter(Character)
    
    -- ตั้งค่าสถานะอีกครั้งหลังเกิดใหม่
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

print("AsherHub โหลดเสร็จสมบูรณ์!")