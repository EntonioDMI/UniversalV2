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
    Ambient = Lighting.Ambient,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    FogColor = Lighting.FogColor
}

-- World Customization Functions
function UtilityModule:ToggleCustomTime(state)
    self.Settings.customTimeEnabled = state
    if state then
        Lighting.TimeOfDay = self.Settings.timeOfDay
    else
        Lighting.TimeOfDay = originalSettings.TimeOfDay
    end
end

function UtilityModule:SetTimeOfDay(time)
    self.Settings.timeOfDay = time
    if self.Settings.customTimeEnabled then
        Lighting.TimeOfDay = time
    end
end

function UtilityModule:ToggleCustomLighting(state)
    self.Settings.customLightingEnabled = state
    if state then
        Lighting.Ambient = self.Settings.ambientColor
    else
        Lighting.Ambient = originalSettings.Ambient
    end
end

function UtilityModule:SetAmbientColor(color)
    self.Settings.ambientColor = color
    if self.Settings.customLightingEnabled then
        Lighting.Ambient = color
    end
end

function UtilityModule:ToggleCustomFog(state)
    self.Settings.customFogEnabled = state
    if state then
        Lighting.FogStart = self.Settings.fogStart
        Lighting.FogEnd = self.Settings.fogEnd
        Lighting.FogColor = self.Settings.fogColor
    else
        Lighting.FogStart = originalSettings.FogStart
        Lighting.FogEnd = originalSettings.FogEnd
        Lighting.FogColor = originalSettings.FogColor
    end
end

function UtilityModule:SetFogStart(value)
    self.Settings.fogStart = value
    if self.Settings.customFogEnabled then
        Lighting.FogStart = value
    end
end

function UtilityModule:SetFogEnd(value)
    self.Settings.fogEnd = value
    if self.Settings.customFogEnabled then
        Lighting.FogEnd = value
    end
end

function UtilityModule:SetFogColor(color)
    self.Settings.fogColor = color
    if self.Settings.customFogEnabled then
        Lighting.FogColor = color
    end
end

function UtilityModule:Initialize()
    -- Store original settings when module is initialized
    originalSettings.TimeOfDay = Lighting.TimeOfDay
    originalSettings.Ambient = Lighting.Ambient
    originalSettings.FogStart = Lighting.FogStart
    originalSettings.FogEnd = Lighting.FogEnd
    originalSettings.FogColor = Lighting.FogColor
end

return UtilityModule
