local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- โหลดโมดูลจาก Features
local FlyModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/sRawiz/Asher-Hub/main/Features/FlyModule.lua"))()
local InvisibleModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/sRawiz/Asher-Hub/main/Features/InvisibleModule.lua"))()
local NoClipModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/sRawiz/Asher-Hub/main/Features/NoClipModule.lua"))()

-- สร้างอินสแตนซ์ของแต่ละโมดูล
local flySystem = FlyModule.new({
    FlySpeed = 50,
    MaxSpeed = 200,
    MinSpeed = 10,
    SpeedIncrement = 10,
    PrintCooldown = 1
})

local invisibleSystem = InvisibleModule.new()
local noClipSystem = NoClipModule.new()

local Window = Fluent:CreateWindow({
    Title = "Roblox Script Hub v1.0",
    SubTitle = "by Me",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "rocket" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- แจ้งเตือนเมื่อเริ่มโปรแกรม
Fluent:Notify({
    Title = "Script Hub",
    Content = "Script Hub ถูกโหลดเรียบร้อยแล้ว!",
    Duration = 5
})

-- เพิ่มข้อความอธิบาย
Tabs.Main:AddParagraph({
    Title = "Roblox Script Hub",
    Content = "โปรแกรมนี้มีฟีเจอร์การบินได้ (Fly), การล่องหน (Invisible), และการทะลุวัตถุ (NoClip) ซึ่งคุณสามารถเปิด/ปิดได้ด้านล่าง"
})

-- ส่วนของ Fly Module
local flySection = Tabs.Main:AddSection("Fly Module")

-- ปุ่มเปิด/ปิดการบิน
local flyToggle = Tabs.Main:AddToggle("FlyToggle", {
    Title = "เปิด/ปิดการบิน",
    Default = false,
    Callback = function(Value)
        if Value then
            flySystem:Start()
        else
            flySystem:Stop()
        end
    end
})

-- ตัวปรับความเร็วการบิน
local flySpeedSlider = Tabs.Main:AddSlider("FlySpeed", {
    Title = "ความเร็วการบิน",
    Description = "ปรับความเร็วในการบิน",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        flySystem.Config.FlySpeed = Value
    end
})

-- คำอธิบายการควบคุม
Tabs.Main:AddParagraph({
    Title = "คำแนะนำการบิน",
    Content = "ใช้ W A S D เพื่อบินไปด้านหน้า ซ้าย หลัง ขวา\nใช้ Space เพื่อบินขึ้น และ Shift เพื่อบินลง"
})

-- ส่วนของ Invisible Module
local invisibleSection = Tabs.Main:AddSection("Invisible Module")

-- ปุ่มเปิด/ปิดการล่องหน
local invisibleToggle = Tabs.Main:AddToggle("InvisibleToggle", {
    Title = "เปิด/ปิดการล่องหน",
    Default = false,
    Callback = function(Value)
        if Value then
            invisibleSystem:Enable()
        else
            invisibleSystem:Disable()
        end
    end
})

-- ส่วนของ NoClip Module
local noClipSection = Tabs.Main:AddSection("NoClip Module")

-- ปุ่มเปิด/ปิด NoClip
local noClipToggle = Tabs.Main:AddToggle("NoClipToggle", {
    Title = "เปิด/ปิดการทะลุวัตถุ",
    Default = false,
    Callback = function(Value)
        if Value then
            noClipSystem:Enable()
        else
            noClipSystem:Disable()
        end
    end
})

-- ปุ่มรีเซ็ตตัวละคร
Tabs.Main:AddButton({
    Title = "รีเซ็ตตัวละคร",
    Description = "รีเซ็ตตัวละครและปิดฟีเจอร์ทั้งหมด",
    Callback = function()
        if flySystem.IsFlying then
            flySystem:Stop()
            Options.FlyToggle:SetValue(false)
        end
        
        if invisibleSystem.IsInvisible then
            invisibleSystem:Disable()
            Options.InvisibleToggle:SetValue(false)
        end
        
        if noClipSystem.IsNoClipping then
            noClipSystem:Disable()
            Options.NoClipToggle:SetValue(false)
        end
        
        -- รีเซ็ตตัวละคร
        local humanoid = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
        
        -- แจ้งเตือน
        Fluent:Notify({
            Title = "รีเซ็ตตัวละคร",
            Content = "ตัวละครถูกรีเซ็ตเรียบร้อยแล้ว!",
            Duration = 3
        })
    end
})

-- เพิ่มฟังก์ชัน Input เมื่อกดปุ่มบนคีย์บอร์ด
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and flySystem.IsFlying then
        flySystem:HandleInput(input.KeyCode, true)
    end
    
    -- สลับเปิด/ปิด Fly ด้วยปุ่ม F
    if input.KeyCode == Enum.KeyCode.F and not gameProcessed then
        local newState = not flySystem.IsFlying
        Options.FlyToggle:SetValue(newState)
    end
    
    -- สลับเปิด/ปิด NoClip ด้วยปุ่ม N
    if input.KeyCode == Enum.KeyCode.N and not gameProcessed then
        local newState = not noClipSystem.IsNoClipping
        Options.NoClipToggle:SetValue(newState)
    end
    
    -- สลับเปิด/ปิด Invisible ด้วยปุ่ม I
    if input.KeyCode == Enum.KeyCode.I and not gameProcessed then
        local newState = not invisibleSystem.IsInvisible
        Options.InvisibleToggle:SetValue(newState)
    end
    
    -- เพิ่มความเร็วการบิน
    if input.KeyCode == Enum.KeyCode.Equal and not gameProcessed and flySystem.IsFlying then
        local newSpeed = flySystem:AdjustSpeed(flySystem.Config.SpeedIncrement)
        flySpeedSlider:SetValue(newSpeed)
        
        Fluent:Notify({
            Title = "ความเร็วการบิน",
            Content = "เพิ่มความเร็วเป็น: " .. newSpeed,
            Duration = 1
        })
    end
    
    -- ลดความเร็วการบิน
    if input.KeyCode == Enum.KeyCode.Minus and not gameProcessed and flySystem.IsFlying then
        local newSpeed = flySystem:AdjustSpeed(-flySystem.Config.SpeedIncrement)
        flySpeedSlider:SetValue(newSpeed)
        
        Fluent:Notify({
            Title = "ความเร็วการบิน",
            Content = "ลดความเร็วเป็น: " .. newSpeed,
            Duration = 1
        })
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if not gameProcessed and flySystem.IsFlying then
        flySystem:HandleInput(input.KeyCode, false)
    end
end)

-- ฟังก์ชันที่ทำงานเมื่อมีตัวละครใหม่
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    flySystem:SetCharacter(character)
    invisibleSystem:SetCharacter(character)
    noClipSystem:SetCharacter(character)
end)

-- ตั้งค่าตัวละครปัจจุบัน
if game.Players.LocalPlayer.Character then
    flySystem:SetCharacter(game.Players.LocalPlayer.Character)
    invisibleSystem:SetCharacter(game.Players.LocalPlayer.Character)
    noClipSystem:SetCharacter(game.Players.LocalPlayer.Character)
end

-- คำอธิบายปุ่มลัด
local hotkeysSection = Tabs.Main:AddSection("ปุ่มลัด")

Tabs.Main:AddParagraph({
    Title = "ปุ่มลัดที่ใช้ได้",
    Content = "F - เปิด/ปิดการบิน\nI - เปิด/ปิดการล่องหน\nN - เปิด/ปิดการทะลุวัตถุ\n+ - เพิ่มความเร็วการบิน\n- - ลดความเร็วการบิน"
})

-- ตั้งค่าผู้จัดการการบันทึกและอินเทอร์เฟซ
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("RobloxScriptHub")
SaveManager:SetFolder("RobloxScriptHub/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- เลือกแท็บเริ่มต้น
Window:SelectTab(1)

-- โหลดการตั้งค่าอัตโนมัติ
SaveManager:LoadAutoloadConfig()