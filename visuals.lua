local VisualsModule = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Module Configuration
VisualsModule.Settings = {
    espEnabled = false,
    espShowDistance = true,
    espShowHealth = true,
    espShowNames = true,
    espShowBoxes = true,
    espShowTracers = false,
    highlightEnabled = false,
    highlightFillColor = Color3.fromRGB(255, 0, 0),
    highlightFillTransparency = 0.5,
    highlightOutlineColor = Color3.fromRGB(255, 255, 255),
    highlightOutlineTransparency = 0,
    teamCheck = false,
    autoTeamColor = false,
    rainbowMode = false,
    rainbowSpeed = 1
}

local highlights = {}
local espObjects = {}
local rainbowHue = 0

-- Helper Functions
local function isTeammate(player)
    if not VisualsModule.Settings.teamCheck then return false end
    return player.Team and player.Team == LocalPlayer.Team
end

local function getTeamColor(player)
    return player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 0, 0)
end

local function createHighlight(character)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = VisualsModule.Settings.highlightFillColor
    highlight.FillTransparency = VisualsModule.Settings.highlightFillTransparency
    highlight.OutlineColor = VisualsModule.Settings.highlightOutlineColor
    highlight.OutlineTransparency = VisualsModule.Settings.highlightOutlineTransparency
    highlight.Parent = character
    return highlight
end

-- ESP Functions
function VisualsModule:ToggleESP(state)
    self.Settings.espEnabled = state
    if not state then
        for _, obj in pairs(espObjects) do
            obj:Destroy()
        end
        table.clear(espObjects)
    end
end

function VisualsModule:ToggleHealthDisplay(state)
    self.Settings.espShowHealth = state
end

function VisualsModule:ToggleDistanceDisplay(state)
    self.Settings.espShowDistance = state
end

function VisualsModule:ToggleNameDisplay(state)
    self.Settings.espShowNames = state
end

function VisualsModule:ToggleBoxDisplay(state)
    self.Settings.espShowBoxes = state
end

function VisualsModule:ToggleTracerDisplay(state)
    self.Settings.espShowTracers = state
end

-- Highlight Functions
function VisualsModule:ToggleHighlight(state)
    self.Settings.highlightEnabled = state
    if not state then
        for _, highlight in pairs(highlights) do
            highlight:Destroy()
        end
        table.clear(highlights)
    end
end

function VisualsModule:SetHighlightFillColor(color)
    self.Settings.highlightFillColor = color
    for _, highlight in pairs(highlights) do
        if not self.Settings.autoTeamColor then
            highlight.FillColor = color
        end
    end
end

function VisualsModule:SetHighlightFillTransparency(transparency)
    self.Settings.highlightFillTransparency = transparency
    for _, highlight in pairs(highlights) do
        highlight.FillTransparency = transparency
    end
end

function VisualsModule:SetHighlightOutlineColor(color)
    self.Settings.highlightOutlineColor = color
    for _, highlight in pairs(highlights) do
        if not self.Settings.autoTeamColor then
            highlight.OutlineColor = color
        end
    end
end

function VisualsModule:SetHighlightOutlineTransparency(transparency)
    self.Settings.highlightOutlineTransparency = transparency
    for _, highlight in pairs(highlights) do
        highlight.OutlineTransparency = transparency
    end
end

function VisualsModule:ToggleTeamCheck(state)
    self.Settings.teamCheck = state
end

function VisualsModule:ToggleAutoTeamColor(state)
    self.Settings.autoTeamColor = state
    if state then
        for player, highlight in pairs(highlights) do
            highlight.FillColor = getTeamColor(player)
            highlight.OutlineColor = getTeamColor(player)
        end
    else
        for _, highlight in pairs(highlights) do
            highlight.FillColor = self.Settings.highlightFillColor
            highlight.OutlineColor = self.Settings.highlightOutlineColor
        end
    end
end

function VisualsModule:ToggleRainbowMode(state)
    self.Settings.rainbowMode = state
end

function VisualsModule:SetRainbowSpeed(speed)
    self.Settings.rainbowSpeed = speed
end

-- Update Loop
RunService.RenderStepped:Connect(function(deltaTime)
    if VisualsModule.Settings.highlightEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if not highlights[player] then
                    highlights[player] = createHighlight(player.Character)
                end
                
                if VisualsModule.Settings.teamCheck and isTeammate(player) then
                    highlights[player].Enabled = false
                else
                    highlights[player].Enabled = true
                    
                    if VisualsModule.Settings.rainbowMode then
                        rainbowHue = (rainbowHue + deltaTime * VisualsModule.Settings.rainbowSpeed) % 1
                        local rainbowColor = Color3.fromHSV(rainbowHue, 1, 1)
                        highlights[player].FillColor = rainbowColor
                        highlights[player].OutlineColor = rainbowColor
                    elseif VisualsModule.Settings.autoTeamColor then
                        local teamColor = getTeamColor(player)
                        highlights[player].FillColor = teamColor
                        highlights[player].OutlineColor = teamColor
                    end
                end
            end
        end
    end
end)

-- Player Added/Removed Handlers
Players.PlayerAdded:Connect(function(player)
    if player.Character then
        if VisualsModule.Settings.highlightEnabled then
            highlights[player] = createHighlight(player.Character)
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
end)

return VisualsModule
