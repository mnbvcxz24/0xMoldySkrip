-- RAPSkrip Settings controls module
-- This file is fetched and compiled separately to keep UI locals out of the main chunk.
return function(ctx)
    local RAPSkripFunctions = ctx.RAPSkripFunctions
    local SettingsPage = ctx.SettingsPage
    local player = ctx.player
    local VirtualUser = ctx.VirtualUser
    local isAntiAFKEnabled = ctx.isAntiAFKEnabled
    local setAntiAFKEnabled = ctx.setAntiAFKEnabled

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, -10, 0, 30)
SettingsTitle.Position = UDim2.fromOffset(5, 5)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "Settings"
SettingsTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
SettingsTitle.TextSize = RAPSkripFunctions.textSize(16)
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
SettingsTitle.Parent = SettingsPage

local AutoExecuteLabel = Instance.new("TextLabel")
AutoExecuteLabel.Size = UDim2.new(1, -85, 0, 22)
AutoExecuteLabel.Position = UDim2.fromOffset(5, 45)
AutoExecuteLabel.BackgroundTransparency = 1
AutoExecuteLabel.Text = "Create Auto Execute"
AutoExecuteLabel.TextColor3 = Color3.fromRGB(210, 210, 218)
AutoExecuteLabel.TextSize = RAPSkripFunctions.textSize(10)
AutoExecuteLabel.Font = Enum.Font.GothamMedium
AutoExecuteLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoExecuteLabel.Parent = SettingsPage

local AutoExecuteButton = Instance.new("TextButton")
AutoExecuteButton.Size = UDim2.fromOffset(62, 27)
AutoExecuteButton.Position = UDim2.new(1, -67, 0, 42)
AutoExecuteButton.BackgroundColor3 = Color3.fromRGB(45, 45, 53)
AutoExecuteButton.Text = "CREATE"
AutoExecuteButton.TextColor3 = Color3.fromRGB(220, 220, 225)
AutoExecuteButton.TextSize = RAPSkripFunctions.textSize(10)
AutoExecuteButton.Font = Enum.Font.GothamBold
AutoExecuteButton.AutoButtonColor = false
AutoExecuteButton.Active = true
AutoExecuteButton.Selectable = true
AutoExecuteButton.Parent = SettingsPage

local AutoExecuteCorner = Instance.new("UICorner")
AutoExecuteCorner.CornerRadius = UDim.new(0, 6)
AutoExecuteCorner.Parent = AutoExecuteButton

local AutoExecuteStatus = Instance.new("TextLabel")
AutoExecuteStatus.Size = UDim2.new(1, -10, 0, 25)
AutoExecuteStatus.Position = UDim2.fromOffset(5, 70)
AutoExecuteStatus.BackgroundTransparency = 1
AutoExecuteStatus.Text = "Creates rap_skrip_test.txt"
AutoExecuteStatus.TextColor3 = Color3.fromRGB(145, 145, 155)
AutoExecuteStatus.TextSize = RAPSkripFunctions.textSize(9)
AutoExecuteStatus.Font = Enum.Font.Gotham
AutoExecuteStatus.TextXAlignment = Enum.TextXAlignment.Left
AutoExecuteStatus.Parent = SettingsPage

local ConfigLabel = Instance.new("TextLabel")
ConfigLabel.Size = UDim2.new(1, -85, 0, 22)
ConfigLabel.Position = UDim2.fromOffset(5, 105)
ConfigLabel.BackgroundTransparency = 1
ConfigLabel.Text = "Config"
ConfigLabel.TextColor3 = Color3.fromRGB(210, 210, 218)
ConfigLabel.TextSize = RAPSkripFunctions.textSize(10)
ConfigLabel.Font = Enum.Font.GothamMedium
ConfigLabel.TextXAlignment = Enum.TextXAlignment.Left
ConfigLabel.Parent = SettingsPage

local ConfigSaveButton = Instance.new("TextButton")
ConfigSaveButton.Size = UDim2.fromOffset(62, 27)
ConfigSaveButton.Position = UDim2.new(1, -67, 0, 102)
ConfigSaveButton.BackgroundColor3 = Color3.fromRGB(45, 45, 53)
ConfigSaveButton.Text = "SAVE"
ConfigSaveButton.TextColor3 = Color3.fromRGB(220, 220, 225)
ConfigSaveButton.TextSize = RAPSkripFunctions.textSize(10)
ConfigSaveButton.Font = Enum.Font.GothamBold
ConfigSaveButton.AutoButtonColor = false
ConfigSaveButton.Active = true
ConfigSaveButton.Selectable = true
ConfigSaveButton.Parent = SettingsPage

local ConfigSaveCorner = Instance.new("UICorner")
ConfigSaveCorner.CornerRadius = UDim.new(0, 6)
ConfigSaveCorner.Parent = ConfigSaveButton

local AntiAFKLabel = Instance.new("TextLabel")
AntiAFKLabel.Size = UDim2.new(1, -85, 0, 22)
AntiAFKLabel.Position = UDim2.fromOffset(5, 138)
AntiAFKLabel.BackgroundTransparency = 1
AntiAFKLabel.Text = "Anti AFK"
AntiAFKLabel.TextColor3 = Color3.fromRGB(210, 210, 218)
AntiAFKLabel.TextSize = RAPSkripFunctions.textSize(10)
AntiAFKLabel.Font = Enum.Font.GothamMedium
AntiAFKLabel.TextXAlignment = Enum.TextXAlignment.Left
AntiAFKLabel.Parent = SettingsPage

local AntiAFKButton = Instance.new("TextButton")
AntiAFKButton.Size = UDim2.fromOffset(62, 27)
AntiAFKButton.Position = UDim2.new(1, -67, 0, 135)
AntiAFKButton.BackgroundColor3 = Color3.fromRGB(45, 45, 53)
AntiAFKButton.Text = "OFF"
AntiAFKButton.TextColor3 = Color3.fromRGB(220, 220, 225)
AntiAFKButton.TextSize = RAPSkripFunctions.textSize(10)
AntiAFKButton.Font = Enum.Font.GothamBold
AntiAFKButton.AutoButtonColor = false
AntiAFKButton.Active = true
AntiAFKButton.Selectable = true
AntiAFKButton.Parent = SettingsPage

local AntiAFKCorner = Instance.new("UICorner")
AntiAFKCorner.CornerRadius = UDim.new(0, 6)
AntiAFKCorner.Parent = AntiAFKButton

RAPSkripFunctions.updateAntiAFKButton = function()
    RAPSkripFunctions.styleToggle(AntiAFKButton, isAntiAFKEnabled())
end

AntiAFKButton.MouseButton1Click:Connect(function()
    setAntiAFKEnabled(not isAntiAFKEnabled())
    RAPSkripFunctions.updateAntiAFKButton()
    RAPSkripFunctions.AddDebug(
        isAntiAFKEnabled()
        and "[ANTI AFK] Enabled"
        or "[ANTI AFK] Disabled"
    )
end)

ConfigSaveButton.MouseButton1Click:Connect(function()
    RAPSkripFunctions.saveConfig()
    ConfigSaveButton.Text = "SAVED"
    ConfigSaveButton.BackgroundColor3 =
        Color3.fromRGB(55, 120, 75)
    task.delay(1.5, function()
        if ConfigSaveButton then
            ConfigSaveButton.Text = "SAVE"
            ConfigSaveButton.BackgroundColor3 =
                Color3.fromRGB(45, 45, 53)
        end
    end)
end)

AutoExecuteButton.MouseButton1Click:Connect(function()
    local content =
        'loadstring(game:HttpGet("https://raw.githubusercontent.com/mnbvcxz24/0xMoldyDeltaScripts/refs/heads/main/rap-skrip"))()'
    local success, err =
        pcall(function()
            if makefolder
                and isfolder
                and not isfolder(
                    "RAPSkrip"
                ) then
                makefolder(
                    "RAPSkrip"
                )
            end
            writefile(
                "RAPSkrip/rap_skrip_test.txt",
                content
            )
        end)
    if success then
        AutoExecuteStatus.Text =
            "Created: rap_skrip_test.txt"
        RAPSkripFunctions.AddDebug(
            "[AUTOEXEC] rap_skrip_test.txt created"
        )
    else
        AutoExecuteStatus.Text =
            "Failed: " ..
            tostring(err)
        RAPSkripFunctions.AddDebug(
            "[AUTOEXEC ERROR] " ..
            tostring(err)
        )
    end
end)

RAPSkripFunctions.updateAntiAFKButton()
player.Idled:Connect(function()
    if not isAntiAFKEnabled() then
        return
    end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
    RAPSkripFunctions.AddDebug("[ANTI AFK] Idle activity sent")
end)

RAPSkripFunctions.setAntiAFK = function(enabled)
    setAntiAFKEnabled(enabled)
    RAPSkripFunctions.updateAntiAFKButton()
    RAPSkripFunctions.AddDebug(
        isAntiAFKEnabled() and "[ANTI AFK] Enabled" or "[ANTI AFK] Disabled"
    )
end

end
