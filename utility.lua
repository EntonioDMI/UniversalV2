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
local originalSettings = {}

-- Safe set function for lighting properties
local function safeSetLighting(property, value)
    local success, err = pcall(function()
        Lighting[property] = value
    end)
    if not success then
        warn("Failed to set Lighting." .. property .. ": " .. err)
    end
end

-- Settings observer
local function updateSettings(setting, value)
    UtilityModule.Settings[setting] = value
    
    if setting == "customTimeEnabled" then
        safeSetLighting("TimeOfDay", value and UtilityModule.Settings.timeOfDay or originalSettings.TimeOfDay)
    elseif setting == "timeOfDay" and UtilityModule.Settings.customTimeEnabled then
        safeSetLighting("TimeOfDay", value)
    elseif setting == "customLightingEnabled" then
        if value then
            safeSetLighting("Ambient", UtilityModule.Settings.ambientColor)
            safeSetLighting("OutdoorAmbient", UtilityModule.Settings.ambientColor)
        else
            safeSetLighting("Ambient", originalSettings.Ambient)
            safeSetLighting("OutdoorAmbient", originalSettings.OutdoorAmbient)
        end
    elseif setting == "ambientColor" and UtilityModule.Settings.customLightingEnabled then
        safeSetLighting("Ambient", value)
        safeSetLighting("OutdoorAmbient", value)
    elseif setting == "customFogEnabled" then
        if value then
            safeSetLighting("FogStart", UtilityModule.Settings.fogStart)
            safeSetLighting("FogEnd", UtilityModule.Settings.fogEnd)
            safeSetLighting("FogColor", UtilityModule.Settings.fogColor)
        else
            safeSetLighting("FogStart", originalSettings.FogStart)
            safeSetLighting("FogEnd", originalSettings.FogEnd)
            safeSetLighting("FogColor", originalSettings.FogColor)
        end
    elseif setting == "fogStart" and UtilityModule.Settings.customFogEnabled then
        safeSetLighting("FogStart", value)
    elseif setting == "fogEnd" and UtilityModule.Settings.customFogEnabled then
        safeSetLighting("FogEnd", value)
    elseif setting == "fogColor" and UtilityModule.Settings.customFogEnabled then
        safeSetLighting("FogColor", value)
    end
end

-- Public method for updating settings
function UtilityModule:UpdateSetting(setting, value)
    updateSettings(setting, value)
end

-- Initialize with settings from MainScript
function UtilityModule:SetInitialSettings(settings)
    originalSettings = settings
end

return UtilityModule
