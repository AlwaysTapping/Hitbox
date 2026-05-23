local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Players = game:GetService('Players')
local RS = game:GetService('RunService')
local UIS = game:GetService('UserInputService')
local Client = Players.LocalPlayer

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "Hb exp",
    Footer = "Universal Hitbox Expander Made by cuo | @accepthelies",
    Icon = 121606554219499,
    NotifySide = "Right",
    ShowCustomCursor = true,
    Size = UDim2.fromOffset(520, 500)
})

local Tabs = {
    Main = Window:AddTab("Main", "user"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local hbEnabled = false
local hbSize = 50
local checksEnabled = false
local checkType = "Wall check"
local hbColor = Color3.fromRGB(0, 0, 255)
local outlineColor = Color3.fromRGB(0, 0, 0)
local legitHbEnabled = false
local transparencyEnabled = false
local transparencyValue = 0.5

local function resetHitbox(player)
    if player ~= Client and player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
        local HRP = player.Character.HumanoidRootPart
        HRP.Size = Vector3.new(2, 2, 1)
        HRP.Transparency = 1
        HRP.CanCollide = true
        local outline = HRP:FindFirstChild('SelectionBox')
        if outline then outline:Destroy() end
    end
end

local MainTab = Tabs.Main

local HbGroup = MainTab:AddLeftGroupbox("Hb")

local HbToggle = HbGroup:AddToggle("EnableHb", {
    Text = "Enable Hitbox",
    Default = false,
    Callback = function(v)
        hbEnabled = v
        if not v then
            for _, Player in pairs(Players:GetPlayers()) do
                resetHitbox(Player)
            end
        end
    end
})

HbToggle:AddKeyPicker("EnableHbKeybind", {
    Default = "H",
    Text = "Keybind",
    NoUI = false,
    Callback = function()
        HbToggle:SetValue(not hbEnabled)
    end
})

HbGroup:AddSlider("HbSize", {
    Text = "Hb Size",
    Default = 50,
    Min = 1,
    Max = 500,
    Rounding = 0,
    Callback = function(v)
        hbSize = v
    end
})

local TransparencyGroup = MainTab:AddLeftGroupbox("Transparency")

local TransparencyToggle = TransparencyGroup:AddToggle("EnableTransparency", {
    Text = "Enable Transparency",
    Default = false,
    Callback = function(v)
        transparencyEnabled = v
    end
})

TransparencyToggle:AddKeyPicker("EnableTransparencyKeybind", {
    Default = "T",
    Text = "Keybind",
    NoUI = false,
    Callback = function()
        TransparencyToggle:SetValue(not transparencyEnabled)
    end
})

TransparencyGroup:AddSlider("TransparencyValue", {
    Text = "Transparency",
    Default = 250,
    Min = 1,
    Max = 500,
    Rounding = 0,
    Callback = function(v)
        transparencyValue = (v - 1) / 499
    end
})

local LegitGroup = MainTab:AddLeftGroupbox("Legit")

local LegitToggle = LegitGroup:AddToggle("EnableLegitHb", {
    Text = "Enable Legit",
    Default = false,
    Callback = function(v)
        legitHbEnabled = v
    end
})

LegitToggle:AddKeyPicker("EnableLegitKeybind", {
    Default = "L",
    Text = "Keybind",
    NoUI = false,
    Callback = function()
        LegitToggle:SetValue(not legitHbEnabled)
    end
})

local ChecksGroup = MainTab:AddRightGroupbox("Checks")

local ChecksToggle = ChecksGroup:AddToggle("EnableChecks", {
    Text = "Enable Checks",
    Default = false,
    Callback = function(v)
        checksEnabled = v
    end
})

ChecksToggle:AddKeyPicker("EnableChecksKeybind", {
    Default = "C",
    Text = "Keybind",
    NoUI = false,
    Callback = function()
        ChecksToggle:SetValue(not checksEnabled)
    end
})

ChecksGroup:AddDropdown("CheckType", {
    Text = "Check Type",
    Values = {
        "Wall check",
        "Team check",
        "Friend check",
        "Car check",
        "All"
    },
    Default = "Wall check",
    Multi = true,
    Callback = function(v)
        checkType = v
    end
})

ChecksGroup:AddLabel("Hitbox Color"):AddColorPicker("HbColor", {
    Default = Color3.fromRGB(0, 0, 255),
    Title = "Hitbox Color",
    Callback = function(v)
        hbColor = v
    end
})

ChecksGroup:AddLabel("Outline Color"):AddColorPicker("OutlineColor", {
    Default = Color3.fromRGB(0, 0, 0),
    Title = "Outline Color",
    Callback = function(v)
        outlineColor = v
    end
})

local function isInCar(character)
    local seat = character:FindFirstChildWhichIsA("VehicleSeat")
    return seat ~= nil
end

local function isBehindWall(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local myHrp = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
    if hrp and myHrp then
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {Client.Character}
        
        local result = workspace:Raycast(myHrp.Position, hrp.Position - myHrp.Position, rayParams)
        if result and not result.Instance:IsDescendantOf(character) then
            return true
        end
    end
    return false
end

RS.RenderStepped:Connect(function()
    if not hbEnabled then return end

    for _, Player in pairs(Players:GetPlayers()) do
        if Player == Client then continue end

        if Player.Character and Player.Character:FindFirstChild('HumanoidRootPart') then
            local HRP = Player.Character.HumanoidRootPart
            local Humanoid = Player.Character:FindFirstChild('Humanoid')

            if Humanoid and Humanoid.Health > 0 then
                
                local shouldSkip = false
                
                if checksEnabled then
                    local activeChecks = typeof(checkType) == "table" and checkType or {checkType}
                    
                    for _, check in pairs(activeChecks) do
                        if check == "Wall check" and isBehindWall(Player.Character) then
                            shouldSkip = true; break
                        elseif check == "Team check" and Player.Team == Client.Team then
                            shouldSkip = true; break
                        elseif check == "Friend check" and Client:IsFriendsWith(Player.UserId) then
                            shouldSkip = true; break
                        elseif check == "Car check" and isInCar(Player.Character) then
                            shouldSkip = true; break
                        end
                    end
                end

                if not shouldSkip then
                    HRP.Size = Vector3.new(hbSize, hbSize, hbSize)
                    HRP.CanCollide = false
                    
                    if legitHbEnabled then
                        HRP.Transparency = 1
                        local outline = HRP:FindFirstChild('SelectionBox')
                        if outline then outline:Destroy() end
                    else
                        if transparencyEnabled then
                            HRP.Transparency = 1 - transparencyValue
                        else
                            HRP.Transparency = 0.5
                        end
                        HRP.Color = hbColor

                        if not HRP:FindFirstChild('SelectionBox') then
                            local outline = Instance.new('SelectionBox')
                            outline.Name = 'SelectionBox'
                            outline.Parent = HRP
                            outline.Adornee = HRP
                            outline.LineThickness = 0.05
                        end
                        
                        HRP.SelectionBox.Color3 = outlineColor
                    end
                else
                    resetHitbox(Player)
                end
                
            else
                resetHitbox(Player)
            end
        end
    end
end)

Library.OnUnload = function()
    for _, Player in pairs(Players:GetPlayers()) do
        resetHitbox(Player)
    end
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.U then
        Library:Unload()
    end
end)

local SettingsTab = Tabs["UI Settings"]

local MenuGroup = SettingsTab:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(v)
        Library.KeybindFrame.Visible = v
    end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = true,
    Callback = function(v)
        Library.ShowCustomCursor = v
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(v)
        Library:SetNotifySide(v)
    end,
})

MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%",
    Text = "DPI Scale",
    Callback = function(v)
        v = v:gsub("%%", "")
        Library:SetDPIScale(tonumber(v))
    end,
})

MenuGroup:AddSlider("UICornerSlider", {
    Text = "Corner Radius",
    Default = Library.CornerRadius,
    Min = 0,
    Max = 20,
    Rounding = 0,
    Callback = function(v)
        Window:SetCornerRadius(v)
    end
})

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("Hitbox Expander")
SaveManager:SetFolder("Hitbox Expander/Configs")
SaveManager:SetSubFolder("Main")

ThemeManager:ApplyToTab(SettingsTab)
ThemeManager:ApplyTheme("Quartz")

SaveManager:BuildConfigSection(SettingsTab)
SaveManager:LoadAutoloadConfig()

MenuGroup:AddDivider()

MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind"
})

MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind
