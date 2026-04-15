--> services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--> librarys
local esp_library = loadstring(game:HttpGet("https://raw.githubusercontent.com/UniversalPlug/merged.wtf/refs/heads/main/esp.lua"))()
local ui_library = loadstring(game:HttpGet("https://raw.githubusercontent.com/UniversalPlug/merged.wtf/refs/heads/main/library.lua"))()

--> tables
local features = {
    ["Combat"] = {
        ["Enable"] = false,

        ["Recoil"] = false,
        ["RecoilY"] = 0,
        ["RecoilX"] = 0,

        ["Spread"] = false,
        ["SpreadValue"] = 0,
    },
    ["Visuals"] = {
        ["CustomFOV"] = false,
        ["FOV"] = 70,
        ["Players"] = {}
    },
    ["World"] = {
        ["QuickLoot"] = false,
        ["PerfectFarm"] = false,
        ["SkinUnlocker"] = false,
    },
    ["Misc"] = {
        ["MenuKey"] = Enum.KeyCode.Insert,
        ["PanicKey"] = Enum.KeyCode.Delete,
        ["MenuVisible"] = true,
        ["Panic"] = false,
    }
}

--> menu
Window = ui_library:CreateWindow("merged", ".wtf")

local CombatTab = Window:CreateTab("Combat")
local VisualsTab = Window:CreateTab("Visuals")
local WorldTab = Window:CreateTab("World")
local MiscTab = Window:CreateTab("Misc")

do
    local GunModSection = CombatTab:CreateSection("Weapon Mods", "Left")
    GunModSection:Render(function()
        GunModSection:CreateToggle("Enable", features.Combat.Enable, function(v) 
            features.Combat.Enable = v
        end)

        GunModSection:CreateToggle("Recoil", features.Combat.Recoil, function(v) 
            features.Combat.Recoil = v
        end)

        if features.Combat.Recoil then
            GunModSection:CreateSlider("Recoil Y", 0, 100, features.Combat.RecoilY, function(v) 
                features.Combat.RecoilY = v
            end)
            GunModSection:CreateSlider("Recoil X", 0, 100, features.Combat.RecoilX, function(v) 
                features.Combat.RecoilX = v
            end)
        end

        GunModSection:CreateToggle("Spread", features.Combat.Spread, function(v) 
            features.Combat.Spread = v
        end)

        if features.Combat.Spread then
            GunModSection:CreateSlider("Spread Value", 0, 100, features.Combat.SpreadValue, function(v) 
                features.Combat.SpreadValue = v
            end)
        end
    end)
end

do
    --> left
    local WorldSection = WorldTab:CreateSection("Localplayer", "Left")
    WorldSection:Render(function()
        WorldSection:CreateToggle("Quick Loot", features.World.QuickLoot, function(v) 
            features.World.QuickLoot = v
        end)
        WorldSection:CreateToggle("Perfect Farm", features.World.PerfectFarm, function(v) 
            features.World.PerfectFarm = v
        end)
        WorldSection:CreateToggle("Skin Unlocker", features.World.SkinUnlocker, function(v) 
            features.World.SkinUnlocker = v
        end)
    end)

    --> right
    local CameraSection = WorldTab:CreateSection("Camera", "Right")
    CameraSection:Render(function()
        CameraSection:CreateToggle("Custom FOV", features.Visuals.CustomFOV, function(v) 
            features.Visuals.CustomFOV = v
        end)

        if features.Visuals.CustomFOV then
            CameraSection:CreateSlider("FOV", 0, 180, features.Visuals.FOV, false, function(v) 
                features.Visuals.FOV = v
            end)
        end
    end)
    
    local LightingSection = WorldTab:CreateSection("Lighting", "Right")
    LightingSection:Render(function()

    end)
end

do
    --> left
    local PlayerSection = VisualsTab:CreateSection("Player ESP", "Left")
    PlayerSection:Render(function()
        PlayerSection:CreateToggle("Enable ESP", esp_library.Enabled, function(v)
            esp_library.Enabled = v
        end)

        if esp_library.Enabled then
            PlayerSection:CreateToggle("Boxes", esp_library.Boxes, function(v)
                esp_library.Boxes = v
            end):AddColorPicker(esp_library.BoxColor, function(c)
                esp_library.BoxColor = c
            end)

            PlayerSection:CreateToggle("Box Fill", esp_library.BoxFill, function(v)
                esp_library.BoxFill = v
            end):AddColorPicker(esp_library.BoxFillColor or Color3.new(1,1,1), function(c)
                esp_library.BoxFillColor = c
            end)

            PlayerSection:CreateToggle("Skeletons", esp_library.Skeletons, function(v)
                esp_library.Skeletons = v
            end):AddColorPicker(esp_library.SkeletonColor, function(c)
                esp_library.SkeletonColor = c
            end)

            PlayerSection:CreateToggle("Health Bar", esp_library.HealthBar, function(v)
                esp_library.HealthBar = v
            end)

            PlayerSection:CreateToggle("Health Text", esp_library.HealthText, function(v)
                esp_library.HealthText = v
            end)

            PlayerSection:CreateToggle("Names", esp_library.Names, function(v)
                esp_library.Names = v
            end):AddColorPicker(esp_library.NameColor, function(c)
                esp_library.NameColor = c
            end)

            PlayerSection:CreateToggle("Distance", esp_library.Distance, function(v)
                esp_library.Distance = v
            end)

            PlayerSection:CreateToggle("Weapon", esp_library.Weapon, function(v)
                esp_library.Weapon = v
            end)

            PlayerSection:CreateToggle("OOF Arrows", esp_library.OOFArrows, function(v)
                esp_library.OOFArrows = v
            end):AddSlider("Arrow Size", 6, 24, esp_library.OOFSize, function(v)
                esp_library.OOFSize = v
            end):AddSlider("Arrow Radius", 50, 400, esp_library.OOFRadius, function(v)
                esp_library.OOFRadius = v
            end)

            PlayerSection:CreateToggle("Max Distance", esp_library.MaxDistanceEnabled or false, function(v)
                esp_library.MaxDistanceEnabled = v
                if not v then esp_library.MaxDistance = 9999 end
            end):AddSlider("Distance", 0, 2000, esp_library.MaxDistance or 1000, function(v)
                esp_library.MaxDistance = v
            end)

            PlayerSection:CreateToggle("Team Check", esp_library.TeamCheck, function(v)
                esp_library.TeamCheck = v
            end)
        end
    end)

    --> right
    local StyleSection = VisualsTab:CreateSection("ESP Style", "Right")
    StyleSection:Render(function()
        StyleSection:CreateSlider("Skeleton Thickness", 1, 4, esp_library.SkeletonThickness, function(v)
            esp_library.SkeletonThickness = v
        end)
    end)
end

do
    local WorldSection = WorldTab:CreateSection("World Visuals")
    WorldSection:Render(function()
        WorldSection:CreateButton("Coming soon...", function() end)
    end)
end

do
    local ConfigSection = MiscTab:CreateSection("Configuration")
    ConfigSection:Render(function()
        ConfigSection:CreateToggle("Toggle Menu", features.Misc.MenuVisible, function(v) 
            features.Misc.MenuVisible = v
            Window.Main.Visible = v
        end):AddKeybind(features.Misc.MenuKey, function(k)
            features.Misc.MenuKey = k
        end)

        ConfigSection:CreateToggle("Panic Key", features.Misc.Panic, function(v) 
            features.Misc.Panic = v
            if v then
                Panic()
            end
        end):AddKeybind(features.Misc.PanicKey, function(k)
            features.Misc.PanicKey = k
        end)
    end)
end

