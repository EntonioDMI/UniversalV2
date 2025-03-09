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
    rainbowSpeed = 1,
    autoRemover = false
}

local highlights = {}
local espObjects = {}
local rainbowHue = 0

-- Helper Functions
local function isTeammate(player)
    if not VisualsModule.Settings.teamCheck then return false end
    return player.Team and LocalPlayer.Team and player.Team.TeamColor == LocalPlayer.Team.TeamColor
end

local function getTeamColor(player)
    if not player.Team or player.Team.TeamColor == BrickColor.new("White") then
        return Color3.fromRGB(128, 128, 128) -- Default gray for players without team or in default team
    end
    return player.Team.TeamColor.Color
end

local function createHighlight(player)
    if not player.Character then return nil end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = VisualsModule.Settings.highlightFillColor
    highlight.FillTransparency = VisualsModule.Settings.highlightFillTransparency
    highlight.OutlineColor = VisualsModule.Settings.highlightOutlineColor
    highlight.OutlineTransparency = VisualsModule.Settings.highlightOutlineTransparency
    highlight.Parent = player.Character
    
    -- Set up character removal handling
    player.Character:WaitForChild("Humanoid").HealthChanged:Connect(function(health)
        if VisualsModule.Settings.autoRemover and health <= 0 and highlight then
            highlight:Destroy()
            highlights[player] = nil
        end
    end)
    
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
            if highlight then highlight:Destroy() end
        end
        table.clear(highlights)
    else
        -- Create highlights for existing players
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                highlights[player] = createHighlight(player)
            end
        end
    end
end

function VisualsModule:SetHighlightFillColor(color)
    self.Settings.highlightFillColor = color
    for player, highlight in pairs(highlights) do
        if highlight and not self.Settings.autoTeamColor then
            highlight.FillColor = color
        end
    end
end

function VisualsModule:SetHighlightFillTransparency(transparency)
    self.Settings.highlightFillTransparency = transparency
    for _, highlight in pairs(highlights) do
        if highlight then highlight.FillTransparency = transparency end
    end
end

function VisualsModule:SetHighlightOutlineColor(color)
    self.Settings.highlightOutlineColor = color
    for player, highlight in pairs(highlights) do
        if highlight and not self.Settings.autoTeamColor then
            highlight.OutlineColor = color
        end
    end
end

function VisualsModule:SetHighlightOutlineTransparency(transparency)
    self.Settings.highlightOutlineTransparency = transparency
    for _, highlight in pairs(highlights) do
        if highlight then highlight.OutlineTransparency = transparency end
    end
end

function VisualsModule:ToggleTeamCheck(state)
    self.Settings.teamCheck = state
    for player, highlight in pairs(highlights) do
        if highlight then
            highlight.Enabled = not (state and isTeammate(player))
        end
    end
end

function VisualsModule:ToggleAutoTeamColor(state)
    self.Settings.autoTeamColor = state
    if state then
        for player, highlight in pairs(highlights) do
            if highlight then
                local teamColor = getTeamColor(player)
                highlight.FillColor = teamColor
                highlight.OutlineColor = teamColor
            end
        end
    else
        for _, highlight in pairs(highlights) do
            if highlight then
                highlight.FillColor = self.Settings.highlightFillColor
                highlight.OutlineColor = self.Settings.highlightOutlineColor
            end
        end
    end
end

function VisualsModule:ToggleAutoRemover(state)
    self.Settings.autoRemover = state
end

function VisualsModule:ToggleRainbowMode(state)
    self.Settings.rainbowMode = state
    rainbowHue = 0 -- Reset hue when toggling
end

function VisualsModule:SetRainbowSpeed(speed)
    self.Settings.rainbowSpeed = speed
end

-- Update Loop
local lastRainbowUpdate = 0
RunService.RenderStepped:Connect(function(deltaTime)
    if VisualsModule.Settings.highlightEnabled then
        if VisualsModule.Settings.rainbowMode then
            -- Update rainbow color every 0.1 seconds
            lastRainbowUpdate = lastRainbowUpdate + deltaTime
            if lastRainbowUpdate >= 0.1 then
                lastRainbowUpdate = 0
                rainbowHue = (rainbowHue + 0.01 * VisualsModule.Settings.rainbowSpeed) % 1
                local rainbowColor = Color3.fromHSV(rainbowHue, 1, 1)
                
                for player, highlight in pairs(highlights) do
                    if highlight and not isTeammate(player) then
                        highlight.FillColor = rainbowColor
                        highlight.OutlineColor = rainbowColor
                    end
                end
            end
        end
    end
end)

-- Player Added/Removed Handlers
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        -- Wait for character to load
        player.CharacterAdded:Connect(function(character)
            if VisualsModule.Settings.highlightEnabled then
                if highlights[player] then
                    highlights[player]:Destroy()
                end
                highlights[player] = createHighlight(player)
                
                -- Apply current settings
                if highlights[player] then
                    local highlight = highlights[player]
                    if VisualsModule.Settings.autoTeamColor then
                        local teamColor = getTeamColor(player)
                        highlight.FillColor = teamColor
                        highlight.OutlineColor = teamColor
                    end
                    highlight.Enabled = not (VisualsModule.Settings.teamCheck and isTeammate(player))
                end
            end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
end)

return VisualsModule
