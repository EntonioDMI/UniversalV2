local UtilityModule = {}
local Lighting = game:GetService("Lighting")

-- Module Configuration
UtilityModule.Settings = {
    customTimeEnabled = false,
    timeOfDay = 14,
    customLightingEnabled = false,
    ambientColor = Color3.fromRGB(127, 127, 127),
    customFogEnabled = false,
    fogStart = 0,
    fogEnd = 1000,
    fogColor = Color3.fromRGB(192, 192, 192)
}

-- Store original lighting settings
local originalSettings = {
    TimeOfDay = Lighting.TimeOfDay,
    AmbientColor = Lighting.AmbientColor,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    FogColor = Lighting.FogColor
}

-- Settings observer
local function updateSettings(setting, value)
    UtilityModule.Settings[setting] = value
    
    if setting == "customTimeEnabled" then
        Lighting.TimeOfDay = value and UtilityModule.Settings.timeOfDay or originalSettings.TimeOfDay
    elseif setting == "timeOfDay" and UtilityModule.Settings.customTimeEnabled then
        Lighting.TimeOfDay = value
    elseif setting == "customLightingEnabled" then
        Lighting.AmbientColor = value and UtilityModule.Settings.ambientColor or originalSettings.AmbientColor
    elseif setting == "ambientColor" and UtilityModule.Settings.customLightingEnabled then
        Lighting.AmbientColor = value
    elseif setting == "customFogEnabled" then
        if value then
            Lighting.FogStart = UtilityModule.Settings.fogStart
            Lighting.FogEnd = UtilityModule.Settings.fogEnd
            Lighting.FogColor = UtilityModule.Settings.fogColor
        else
            Lighting.FogStart = originalSettings.FogStart
            Lighting.FogEnd = originalSettings.FogEnd
            Lighting.FogColor = originalSettings.FogColor
        end
    elseif setting == "fogStart" and UtilityModule.Settings.customFogEnabled then
        Lighting.FogStart = value
    elseif setting == "fogEnd" and UtilityModule.Settings.customFogEnabled then
        Lighting.FogEnd = value
    elseif setting == "fogColor" and UtilityModule.Settings.customFogEnabled then
        Lighting.FogColor = value
    end
end

-- Public method for updating settings
function UtilityModule:UpdateSetting(setting, value)
    updateSettings(setting, value)
end

function UtilityModule:Initialize()
    originalSettings.TimeOfDay = Lighting.TimeOfDay
    originalSettings.AmbientColor = Lighting.AmbientColor
    originalSettings.FogStart = Lighting.FogStart
    originalSettings.FogEnd = Lighting.FogEnd
    originalSettings.FogColor = Lighting.FogColor
end

return UtilityModule
