local VisualsModule = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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

-- ESP Drawing Objects
local espDrawings = {}

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

-- ESP Drawing Functions
local function createESPDrawings(player)
    if espDrawings[player] then
        for _, drawing in pairs(espDrawings[player]) do
            drawing:Remove()
        end
    end

    espDrawings[player] = {
        box = {
            outline = Drawing.new("Square"),
            main = Drawing.new("Square")
        },
        healthBar = {
            outline = Drawing.new("Square"),
            main = Drawing.new("Square")
        },
        name = Drawing.new("Text"),
        distance = Drawing.new("Text"),
        tracer = Drawing.new("Line")
    }

    -- Box settings
    local box = espDrawings[player].box
    box.outline.Thickness = 3
    box.outline.Color = Color3.new(0, 0, 0)
    box.main.Thickness = 1
    box.main.Color = Color3.new(1, 1, 1)

    -- Health bar settings
    local healthBar = espDrawings[player].healthBar
    healthBar.outline.Thickness = 3
    healthBar.outline.Color = Color3.new(0, 0, 0)
    healthBar.main.Thickness = 1
    healthBar.main.Color = Color3.new(0, 1, 0)

    -- Name settings
    local name = espDrawings[player].name
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.Color = Color3.new(1, 1, 1)

    -- Distance settings
    local distance = espDrawings[player].distance
    distance.Size = 12
    distance.Center = true
    distance.Outline = true
    distance.Color = Color3.new(1, 1, 1)

    -- Tracer settings
    local tracer = espDrawings[player].tracer
    tracer.Thickness = 1
    tracer.Color = Color3.new(1, 1, 1)
end

local function updateESPDrawings(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not espDrawings[player] then return end

    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoidRootPart or not humanoid then return end

    local pos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
    if not onScreen then
        for _, category in pairs(espDrawings[player]) do
            if type(category) == "table" then
                category.outline.Visible = false
                category.main.Visible = false
            else
                category.Visible = false
            end
        end
        return
    end

    -- Calculate box dimensions
    local size = (Camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(3,7,0)).Y - Camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(-3,-3,0)).Y) / 2
    local boxSize = Vector2.new(size * 1.5, size * 2)
    local boxPosition = Vector2.new(pos.X - size * 1.5 / 2, pos.Y - size)

    -- Update box
    local box = espDrawings[player].box
    box.outline.Size = boxSize
    box.outline.Position = boxPosition
    box.outline.Visible = VisualsModule.Settings.espShowBoxes
    box.main.Size = boxSize
    box.main.Position = boxPosition
    box.main.Visible = VisualsModule.Settings.espShowBoxes

    -- Update health bar
    local healthBar = espDrawings[player].healthBar
    local healthBarSize = Vector2.new(2, boxSize.Y * (humanoid.Health / humanoid.MaxHealth))
    local healthBarPosition = Vector2.new(boxPosition.X - 5, boxPosition.Y + (boxSize.Y - healthBarSize.Y))
    
    healthBar.outline.Size = Vector2.new(4, boxSize.Y)
    healthBar.outline.Position = Vector2.new(healthBarPosition.X - 1, boxPosition.Y)
    healthBar.outline.Visible = VisualsModule.Settings.espShowHealth
    
    healthBar.main.Size = healthBarSize
    healthBar.main.Position = healthBarPosition
    healthBar.main.Visible = VisualsModule.Settings.espShowHealth
    healthBar.main.Color = Color3.fromHSV(humanoid.Health / humanoid.MaxHealth * 0.3, 1, 1)

    -- Update name
    local name = espDrawings[player].name
    name.Text = player.Name
    name.Position = Vector2.new(boxPosition.X + boxSize.X/2, boxPosition.Y - 20)
    name.Visible = VisualsModule.Settings.espShowNames

    -- Update distance
    local distance = espDrawings[player].distance
    local playerDistance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude)
    distance.Text = tostring(playerDistance) .. "m"
    distance.Position = Vector2.new(boxPosition.X + boxSize.X/2, boxPosition.Y + boxSize.Y)
    distance.Visible = VisualsModule.Settings.espShowDistance

    -- Update tracer
    local tracer = espDrawings[player].tracer
    tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
    tracer.To = Vector2.new(pos.X, pos.Y)
    tracer.Visible = VisualsModule.Settings.espShowTracers
end

-- ESP Functions
function VisualsModule:ToggleESP(state)
    self.Settings.espEnabled = state
    if not state then
        for _, playerDrawings in pairs(espDrawings) do
            for _, category in pairs(playerDrawings) do
                if type(category) == "table" then
                    category.outline:Remove()
                    category.main:Remove()
                else
                    category:Remove()
                end
            end
        end
        table.clear(espDrawings)
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESPDrawings(player)
            end
        end
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
    -- Update ESP
    if VisualsModule.Settings.espEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                updateESPDrawings(player)
            end
        end
    end

    -- Update Highlights
    if VisualsModule.Settings.highlightEnabled and VisualsModule.Settings.rainbowMode then
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
end)

-- Player Added/Removed Handlers
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        if VisualsModule.Settings.espEnabled then
            createESPDrawings(player)
        end
        
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
    
    if espDrawings[player] then
        for _, category in pairs(espDrawings[player]) do
            if type(category) == "table" then
                category.outline:Remove()
                category.main:Remove()
            else
                category:Remove()
            end
        end
        espDrawings[player] = nil
    end
end)

return VisualsModule
