-- // Initialising the UI
local Venyx = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Venyx-UI-Library/main/source2.lua"))()
local UI = Venyx.new({
    title = "Sealient Cove"
})

-- // Themes
local Themes = {
    Background = Color3.fromRGB(24, 24, 24),
    Glow = Color3.fromRGB(255, 0, 255),
    Accent = Color3.fromRGB(10, 10, 10),
    LightContrast = Color3.fromRGB(20, 20, 20),
    DarkContrast = Color3.fromRGB(14, 14, 14),  
    TextColor = Color3.fromRGB(255, 0, 255)
}

-- // General Tab
local GeneralTab = UI:addPage({
    title = "General",
    icon = 5012544693
})

-- Adding sections inside the General tab
local PerformanceSection = GeneralTab:addSection({
    title = "Performance"
})

-- FPS Display Variables
local fpsDisplay
local textLabel
local fpsEnabled = false  -- Track if FPS display is enabled
local frameTimes = {}  -- Store the frame times to calculate average FPS

-- Function to create the FPS Display on screen
local function CreateFPSDisplay()
    -- Create a ScreenGui to hold the FPS display
    fpsDisplay = Instance.new("ScreenGui")
    fpsDisplay.Name = "FPSDisplay"
    fpsDisplay.Parent = game.Players.LocalPlayer.PlayerGui

    -- Create a TextLabel for displaying FPS
    textLabel = Instance.new("TextLabel")
    textLabel.Parent = fpsDisplay
    textLabel.AnchorPoint = Vector2.new(1, 0)  -- Anchor to the top-right corner
    textLabel.Position = UDim2.new(1, -10, 0, 10)  -- 10px from the top-right edge
    textLabel.Size = UDim2.new(0, 100, 0, 25)  -- Smaller size
    textLabel.BackgroundTransparency = 1  -- Make the background transparent
    textLabel.TextColor3 = Color3.fromRGB(255, 105, 180)  -- Hot pink color
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 14  -- Smaller text size
    textLabel.Text = "FPS: 0"
end

-- Function to update FPS
local function UpdateFPS()
    while fpsEnabled do
        local startTime = tick()  -- Get current time
        game:GetService("RunService").Heartbeat:Wait()  -- Wait for next frame
        local frameTime = tick() - startTime  -- Calculate frame time
        
        -- Store the frame time and calculate the average FPS
        table.insert(frameTimes, frameTime)
        if #frameTimes > 60 then  -- Limit the frame history to 60 frames (for smoothness)
            table.remove(frameTimes, 1)
        end

        -- Calculate average FPS (1 / average frame time)
        local avgFrameTime = 0
        for _, time in ipairs(frameTimes) do
            avgFrameTime = avgFrameTime + time
        end
        local avgFPS = math.floor(1 / (avgFrameTime / #frameTimes))  -- Calculate average FPS

        textLabel.Text = "FPS: " .. avgFPS  -- Update the label text
    end
end

-- Function to toggle FPS Display
local function ToggleFPSDisplay(state)
    fpsEnabled = state
    if fpsEnabled then
        CreateFPSDisplay()  -- Create the FPS display
        -- Start updating the FPS in real-time
        coroutine.wrap(UpdateFPS)()
    else
        if fpsDisplay then
            fpsDisplay:Destroy()  -- Remove FPS display from the screen
        end
    end
end

-- Add Toggle to Performance section in the UI
PerformanceSection:addToggle({
    title = "FPS Display",
    default = false,
    callback = function(value)
        ToggleFPSDisplay(value)  -- Enable/disable the FPS display based on the toggle
    end
})

local AccessibilitySection = GeneralTab:addSection({
    title = "Accessibility"
})

-- UI Blur Effect Variables
local blurEffect
local blurEnabled = false  -- Track if UI Blur is enabled

-- Function to create or remove the UI Blur effect
local function ToggleUIBlur(state)
    if state then
        -- Create a UIBlurEffect and apply it to the ScreenGui
        blurEffect = Instance.new("BlurEffect")
        blurEffect.Parent = game:GetService("Lighting")
        blurEffect.Size = 10  -- Adjust the blur intensity
    else
        -- Remove the blur effect from Lighting
        if blurEffect then
            blurEffect:Destroy()
        end
    end
end

-- Add Toggle to Accessibility section in the UI
AccessibilitySection:addToggle({
    title = "Enable/Disable UI Blur",
    default = false,
    callback = function(value)
        ToggleUIBlur(value)  -- Enable/disable the UI blur effect based on the toggle
    end
})

local RecoverySection = GeneralTab:addSection({
    title = "Recovery"
})

-- Save and Load Theme Settings Functions
local function SaveSettings()
    -- Save UI settings to LocalPlayer's data (PlayerData)
    local player = game.Players.LocalPlayer
    local settings = {
        ["FPSDisplay"] = fpsEnabled,
        ["UIBlur"] = blurEnabled,
        -- Add any other settings you want to save here (e.g., toggle states)
    }

    -- Save the theme settings
    for theme, color in pairs(Themes) do
        settings[theme] = color
    end

    -- Saving the settings using the SetAsync method (this could be a DataStore if necessary)
    for setting, value in pairs(settings) do
        player:SetAttribute(setting, value)  -- Save each setting as an attribute
    end
    print("Settings saved successfully.")
end

local function LoadSettings()
    -- Load UI settings from LocalPlayer's saved data
    local player = game.Players.LocalPlayer
    local settings = {
        ["FPSDisplay"] = player:GetAttribute("FPSDisplay"),
        ["UIBlur"] = player:GetAttribute("UIBlur"),
        -- Load other settings as needed
    }

    -- Load the theme settings and apply them
    for theme, _ in pairs(Themes) do
        local savedColor = player:GetAttribute(theme)
        if savedColor then
            Themes[theme] = savedColor  -- Apply the saved color
        end
    end

    -- Apply the settings to the UI elements
    fpsEnabled = settings["FPSDisplay"] or false
    blurEnabled = settings["UIBlur"] or false
    
    -- Apply the settings by toggling the appropriate UI elements
    ToggleFPSDisplay(fpsEnabled)
    ToggleUIBlur(blurEnabled)
    
    -- Apply the theme settings
    for theme, color in pairs(Themes) do
        UI:setTheme({
            theme = theme,
            color3 = color
        })
    end

    print("Settings loaded successfully.")
end

-- Add Save Settings Button to Recovery section in the UI
RecoverySection:addButton({
    title = "Save Settings",
    callback = function()
        SaveSettings()  -- Save the current settings when clicked
    end
})

-- Add Load Settings Button to Recovery section in the UI (for loading settings manually)
RecoverySection:addButton({
    title = "Load Settings",
    callback = function()
        LoadSettings()  -- Load the saved settings when clicked
    end
})

RecoverySection:addKeybind({
    title = "Toggle UI",
    key = Enum.KeyCode.RightControl, -- Default keybind (changeable)
    callback = function()
        UI:toggle() -- Toggles the UI on/off
    end,
    changedCallback = function(key)
        print("UI toggle key changed to:", key)
    end
})

local function RemoveBOM(str)
    -- Remove the BOM character (U+FEFF) if it's present at the beginning of the string
    return str:gsub("^\239\187\191", "")
end

local TweenService = game:GetService("TweenService")

-- Create a ScreenGui and a TextLabel for displaying the version
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local versionLabel = Instance.new("TextLabel")
versionLabel.Parent = screenGui
versionLabel.Size = UDim2.new(0, 200, 0, 30)  -- Adjust the size of the label
versionLabel.Position = UDim2.new(0.05, 0, 0, 0)  -- Position it at top left corner
versionLabel.BackgroundTransparency = 1  -- Make background transparent
versionLabel.TextColor3 = Color3.fromRGB(255, 0, 255)  -- Set the text color (hot pink)
versionLabel.TextSize = 14  -- Smaller text size
versionLabel.Text = "Sealient Hub - Version: 1.1"  -- Initial version text
versionLabel.TextXAlignment = Enum.TextXAlignment.Right  -- Align text to the right

-- Function to create a temporary message on the screen
local function showUpdateMessage(message)
    -- Create a TextLabel to show the update message
    local updateLabel = Instance.new("TextLabel")
    updateLabel.Text = message
    updateLabel.Font = Enum.Font.GothamBold
    updateLabel.TextSize = 18
    updateLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    updateLabel.BackgroundTransparency = 1
    updateLabel.Size = UDim2.new(0, 400, 0, 50)
    updateLabel.Position = UDim2.new(0.5, -200, 0.1, 0)  -- Position it at the top-center of the screen
    updateLabel.Parent = screenGui

    -- Create a Tween for the transparency
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = {TextTransparency = 1}  -- Target transparency
    local tween = TweenService:Create(updateLabel, tweenInfo, goal)

    -- Wait for 5 seconds before starting the fade
    wait(5)

    -- Start the fade out tween
    tween:Play()

    -- Remove the label after it fades out
    tween.Completed:Connect(function()
        updateLabel:Destroy()
    end)
end


local function CheckForUpdates()
    local versionUrl = "https://raw.githubusercontent.com/Sealient/Updates/refs/heads/main/version.txt"
    local scriptUrl = "https://raw.githubusercontent.com/Sealient/Updates/refs/heads/main/script.lua"

    -- Get the latest version from the version file
    local latestVersionSuccess, latestVersion = pcall(function()
        return game:HttpGet(versionUrl)
    end)

    if not latestVersionSuccess then
        showUpdateMessage("Failed to fetch the version file!")
        return false, nil, nil
    end

    -- Trim leading and trailing whitespaces from the version
    latestVersion = latestVersion:match("^%s*(.-)%s*$")

    -- Your current version
    local currentVersion = versionLabel.Text:match("Version: (%d+%.%d+)")  -- Extract the current version from the label

    if latestVersion ~= currentVersion then
        showUpdateMessage("🛠️ New version available: " .. latestVersion)

        -- Get the script content from the new script file
        local scriptSuccess, newScript = pcall(function()
            return game:HttpGet(scriptUrl)
        end)

        if not scriptSuccess then
            showUpdateMessage("Failed to fetch the script content!")
            return false, latestVersion, nil
        end

        -- Remove BOM if present
        newScript = RemoveBOM(newScript)

        -- Check if script content is valid
        if not newScript or newScript == "" then
            showUpdateMessage("Script content is empty or invalid!")
            return false, latestVersion, nil
        end

        -- Compile and execute the new script
        local func, loadError = loadstring(newScript)
        if func then
            local success, errorMsg = pcall(function()
                func()  -- Run the fetched Lua code
            end)

            if not success then
                showUpdateMessage("Error executing the update script: " .. errorMsg)
            else
                showUpdateMessage("Successfully updated to version " .. latestVersion)
                -- Update the version text on the label after successful update
                versionLabel.Text = "Sealient Hub - Version: " .. latestVersion
                -- Toggle the UI after the script update and remove version label
                UI:toggle()
                versionLabel:Destroy()  -- Remove the version text label after UI toggle
            end
        else
            showUpdateMessage("Failed to compile the script: " .. (loadError or "Unknown error"))
        end
    else
        showUpdateMessage("You're on the latest version (" .. latestVersion .. ").")
        return false, currentVersion, nil
    end
end

RecoverySection:addButton({
    title = "Check for Script Update",
    callback = function()
        CheckForUpdates()
    end
})


-- Automatically load settings when the UI is initialized
LoadSettings()




























-- // Visual Tab
local Visual = UI:addPage({
    title = "Visual",
    icon = 5012544693
})

local Visibility = Visual:addSection({
    title = "Visibility"
})
local Camera = Visual:addSection({
    title = "Camera"
})
local Object = Visual:addSection({
    title = "Object"
})
local Effects = Visual:addSection({
    title = "Effects"
})
local UISection = Visual:addSection({
    title = "UI"
})
local Rendering = Visual:addSection({
    title = "Rendering"
})
local MiscVisuals = Visual:addSection({
    title = "Misc Visuals"
})

-- // ESP Toggle
local espEnabled = false
local espBoxes = {}

-- Base ESP Box Size
local BASE_WIDTH = 100  -- Default width
local BASE_HEIGHT = 200 -- Default height
local MIN_DISTANCE = 5  -- Distance where box is at max size
local MAX_DISTANCE = 100 -- Distance where box is at min size
local MIN_SCALE = 0.3   -- Minimum scale size when far away

-- Function to create ESP box
local function createESPBox(player)
    local boxOutline = Drawing.new("Square")
    boxOutline.Color = Color3.fromRGB(255, 0, 0) -- Red border
    boxOutline.Thickness = 2
    boxOutline.Filled = false
    boxOutline.Transparency = 1
    boxOutline.Visible = false

    local boxInner = Drawing.new("Square")
    boxInner.Color = Color3.fromRGB(0, 0, 0) -- Black inner box (border effect)
    boxInner.Thickness = 0
    boxInner.Filled = false
    boxInner.Transparency = 0
    boxInner.Visible = false

    espBoxes[player] = { outline = boxOutline, inner = boxInner }
end

-- Function to update ESP box
local function updateESPBox(player, boxOutline, boxInner)
    local character = player.Character
    local localPlayer = game:GetService("Players").LocalPlayer

    if character and character:FindFirstChild("HumanoidRootPart") and localPlayer.Character then
        local camera = game:GetService("Workspace").CurrentCamera
        local humanoidRootPart = character.HumanoidRootPart
        local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")

        if not localRoot then return end

        -- Calculate distance between player and ESP target
        local distance = (localRoot.Position - humanoidRootPart.Position).Magnitude
        local screenPosition, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)

        if onScreen then
            -- Scale box based on distance
            local scale = math.clamp(1 - ((distance - MIN_DISTANCE) / (MAX_DISTANCE - MIN_DISTANCE)), MIN_SCALE, 1)

            -- Compute final box size
            local finalWidth = BASE_WIDTH * scale
            local finalHeight = BASE_HEIGHT * scale

            -- Center the box on the player
            local boxPosition = Vector2.new(screenPosition.X - (finalWidth / 2), screenPosition.Y - (finalHeight / 2))

            -- Set box positions & visibility
            boxOutline.Position = boxPosition
            boxOutline.Size = Vector2.new(finalWidth, finalHeight)
            boxOutline.Visible = true

            -- Slightly larger inner box for border effect
            boxInner.Position = boxOutline.Position - Vector2.new(1, 1)
            boxInner.Size = boxOutline.Size + Vector2.new(2, 2)
            boxInner.Visible = true
        else
            boxOutline.Visible = false
            boxInner.Visible = false
        end
    else
        boxOutline.Visible = false
        boxInner.Visible = false
    end
end

-- Toggle ESP for all players
Visibility:addToggle({
    title = "ESP",
    callback = function(value)
        espEnabled = value
        if espEnabled then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if not espBoxes[player] then
                    createESPBox(player)
                end
            end
        else
            for _, esp in pairs(espBoxes) do
                esp.outline.Visible = false
                esp.inner.Visible = false
            end
            espBoxes = {}
        end
    end
})

-- Update ESP boxes every frame
game:GetService("RunService").RenderStepped:Connect(function()
    if espEnabled then
        for player, esp in pairs(espBoxes) do
            updateESPBox(player, esp.outline, esp.inner)
        end
    end
end)

local FullbrightEnabled = false

local function SetFullbright(state)
    FullbrightEnabled = state
    if state then
        game.Lighting.Ambient = Color3.new(1, 1, 1) -- Makes everything fully bright
        game.Lighting.Brightness = 5 -- Increases brightness
        game.Lighting.GlobalShadows = false -- Disables shadows
    else
        game.Lighting.Ambient = Color3.new(0.5, 0.5, 0.5) -- Default ambient lighting
        game.Lighting.Brightness = 1 -- Default brightness
        game.Lighting.GlobalShadows = true -- Re-enable shadows
    end
end

-- // Add Fullbright Toggle to Visibility Section
Visibility:addToggle({
    title = "Fullbright",
    callback = function(state)
        print("Fullbright:", state)
        SetFullbright(state)
    end
})

-- FOV Slider
local defaultFOV = 70 -- Default Roblox FOV
local minFOV = 30      -- Minimum FOV
local maxFOV = 120     -- Maximum FOV

Camera:addSlider({
    title = "Field of View",
    default = defaultFOV,
    min = minFOV,
    max = maxFOV,
    callback = function(value)
        game.Workspace.CurrentCamera.FieldOfView = value
    end
})

local CameraUnlocked = false

-- Function to toggle Camera Unlock
local function UnlockCamera(state)
    CameraUnlocked = state

    if CameraUnlocked then
        game.Players.LocalPlayer.CameraMaxZoomDistance = math.huge -- No zoom limit
        game.Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic -- Free camera movement
        game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom -- Normal camera behavior
    else
        game.Players.LocalPlayer.CameraMaxZoomDistance = 10 -- Default Roblox zoom limit
        game.Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic
        game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
end

-- Third-Person Camera Unlocker Toggle
Camera:addToggle({
    title = "Third-Person Camera Unlocker",
    default = false,
    callback = function(value)
        UnlockCamera(value)
    end
})

local hudHidden = false

-- Function to Hide/Show HUD
local function ToggleHUD(state)
    hudHidden = state
    local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")

    if playerGui then
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") or gui:IsA("BillboardGui") then
                gui.Enabled = not hudHidden
            end
        end
    end
end

-- No HUD Toggle
UISection:addToggle({
    title = "No HUD (Hide UI)",
    default = false,
    callback = function(value)
        ToggleHUD(value)
    end
})

local healthBarsEnabled = false
local healthBars = {}

-- Function to Create a Health Bar
local function CreateHealthBar(character)
    if not healthBarsEnabled then return end -- Prevent creation when disabled

    if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("Head") then
        local humanoid = character:FindFirstChild("Humanoid")
        local head = character:FindFirstChild("Head")

        -- Check if already exists
        if healthBars[character] then return end 

        -- Billboard GUI
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "HealthBar"
        billboard.Adornee = head
        billboard.Size = UDim2.new(4, 0, 0.5, 0)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true

        -- Background Bar
        local bgBar = Instance.new("Frame", billboard)
        bgBar.Size = UDim2.new(1, 0, 1, 0)
        bgBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        bgBar.BorderSizePixel = 0

        -- Health Bar
        local healthBar = Instance.new("Frame", bgBar)
        healthBar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthBar.BorderSizePixel = 0

        -- Updating Health Bar
        local function UpdateHealth()
            if humanoid and humanoid.Parent then
                healthBar.Size = UDim2.new(math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1), 0, 1, 0)
                healthBar.BackgroundColor3 = Color3.fromRGB(255 - (humanoid.Health / humanoid.MaxHealth) * 255, (humanoid.Health / humanoid.MaxHealth) * 255, 0)
            end
        end

        humanoid.HealthChanged:Connect(UpdateHealth)

        billboard.Parent = game.CoreGui
        healthBars[character] = billboard
    end
end

-- Function to Remove All Health Bars
local function RemoveAllHealthBars()
    for character, billboard in pairs(healthBars) do
        if billboard then billboard:Destroy() end
    end
    healthBars = {} -- Clear table
end

-- Function to Toggle Health Bars
local function ToggleHealthBars(state)
    healthBarsEnabled = state

    if healthBarsEnabled then
        -- Apply health bars to all current players
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character then
                CreateHealthBar(player.Character)
            end
        end

        -- Apply health bars to NPCs (if applicable)
        for _, npc in pairs(game.Workspace:GetDescendants()) do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("Head") then
                CreateHealthBar(npc)
            end
        end

        -- Listen for new characters
        game.Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                CreateHealthBar(character)
            end)
        end)

    else
        -- Remove all health bars when toggled off
        RemoveAllHealthBars()
    end
end

-- Toggle for Health Bar ESP
UISection:addToggle({
    title = "Health Bar ESP",
    default = false,
    callback = function(value)
        ToggleHealthBars(value)
    end
})

local killfeedEnabled = false
local killfeedGUI = nil

-- Function to Create Killfeed UI
local function CreateKillfeed()
    if killfeedGUI then return end -- Prevent duplicates

    killfeedGUI = Instance.new("ScreenGui")
    killfeedGUI.Name = "KillfeedEnhancer"
    killfeedGUI.Parent = game.CoreGui

    local frame = Instance.new("Frame", killfeedGUI)
    frame.Size = UDim2.new(0.3, 0, 0.5, 0)
    frame.Position = UDim2.new(0.7, 0, 0.2, 0)
    frame.BackgroundTransparency = 1
    frame.ClipsDescendants = true

    return frame
end

-- Function to Add Kill Message
local function AddKillMessage(killer, victim)
    if not killfeedEnabled then return end

    local frame = killfeedGUI:FindFirstChild("Frame")
    if not frame then return end

    local textLabel = Instance.new("TextLabel", frame)
    textLabel.Size = UDim2.new(1, 0, 0, 30)
    textLabel.Position = UDim2.new(0, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = killer .. " → " .. victim
    textLabel.TextColor3 = Color3.fromRGB(math.random(100, 255), math.random(100, 255), math.random(100, 255)) -- Random color
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0.5

    -- Animate message (fade-out)
    game:GetService("TweenService"):Create(textLabel, TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
    game:GetService("TweenService"):Create(textLabel, TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextStrokeTransparency = 1}):Play()

    -- Remove message after fade-out
    task.spawn(function()
        wait(5)
        textLabel:Destroy()
    end)
end

-- Function to Listen for Kills
local function MonitorKills(state)
    killfeedEnabled = state

    if killfeedEnabled then
        local killfeedFrame = CreateKillfeed()

        -- Listen for player deaths
        game.Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.Died:Connect(function()
                        local killer = humanoid:FindFirstChild("creator")
                        local killerName = killer and killer.Value and killer.Value.Name or "Unknown"
                        AddKillMessage(killerName, player.Name)
                    end)
                end
            end)
        end)
    else
        -- Remove killfeed UI when disabled
        if killfeedGUI then
            killfeedGUI:Destroy()
            killfeedGUI = nil
        end
    end
end

-- Toggle for Killfeed Enhancer
UISection:addToggle({
    title = "Killfeed Enhancer",
    default = false,
    callback = function(value)
        MonitorKills(value)
    end
})

local fpsBoosterEnabled = false

-- Function to Disable Performance-Heavy Features
local function SetFPSBooster(state)
    fpsBoosterEnabled = state

    if fpsBoosterEnabled then
        -- Reduce lighting effects
        game.Lighting.GlobalShadows = false
        game.Lighting.FogEnd = 1000000
        game.Lighting.Brightness = 1

        -- Disable all particle effects
        for _, obj in pairs(game.Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end
        end

        -- Remove decals/textures to reduce rendering
        for _, obj in pairs(game.Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
        end

        -- Reduce terrain details
        if game.Workspace:FindFirstChildOfClass("Terrain") then
            game.Workspace.Terrain.WaterWaveSize = 0
            game.Workspace.Terrain.WaterWaveSpeed = 0
            game.Workspace.Terrain.WaterReflectance = 0
            game.Workspace.Terrain.WaterTransparency = 1
        end

        -- Lower graphics settings
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level1

    else
        -- Restore default settings when disabled
        game.Lighting.GlobalShadows = true
        game.Lighting.FogEnd = 1000
        game.Lighting.Brightness = 2

        -- Re-enable particle effects
        for _, obj in pairs(game.Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = true
            end
        end

        -- Restore decals/textures
        for _, obj in pairs(game.Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 0
            end
        end

        -- Restore terrain details
        if game.Workspace:FindFirstChildOfClass("Terrain") then
            game.Workspace.Terrain.WaterWaveSize = 1
            game.Workspace.Terrain.WaterWaveSpeed = 1
            game.Workspace.Terrain.WaterReflectance = 1
            game.Workspace.Terrain.WaterTransparency = 0.5
        end

        -- Restore graphics settings
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    end
end

-- Toggle for FPS Booster
Rendering:addToggle({
    title = "FPS Booster",
    default = false,
    callback = function(value)
        SetFPSBooster(value)
    end
})

local screenEffectsEnabled = true

-- Function to Remove Screen Effects
local function SetScreenEffects(state)
    screenEffectsEnabled = state

    for _, effect in pairs(game.Lighting:GetChildren()) do
        if effect:IsA("BlurEffect") or 
           effect:IsA("DepthOfFieldEffect") or 
           effect:IsA("SunRaysEffect") or 
           effect:IsA("ColorCorrectionEffect") or 
           effect:IsA("BloomEffect") then
            effect.Enabled = screenEffectsEnabled
        end
    end
end

-- Toggle for Disabling Screen Effects
Effects:addToggle({
    title = "Disable Screen Effects",
    default = false,
    callback = function(value)
        SetScreenEffects(not value)
    end
})

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local glowEffect = Instance.new("Highlight")
glowEffect.Parent = character
glowEffect.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Ensures glow is always visible
glowEffect.FillTransparency = 0.5 -- Controls glow transparency
glowEffect.OutlineTransparency = 0 -- Ensures a visible outline
glowEffect.Enabled = false -- Initially disabled

-- Function to Enable/Disable Glow
local function SetPlayerGlow(state)
    glowEffect.Enabled = state
end

-- Toggle for Player Glow
MiscVisuals:addToggle({
    title = "Custom Player Glow",
    default = false,
    callback = function(value)
        SetPlayerGlow(value)
    end
})

-- Color Picker for Custom Glow Color
MiscVisuals:addColorPicker({
    title = "Glow Color",
    default = Color3.fromRGB(0, 255, 255),
    callback = function(color)
        glowEffect.FillColor = color
        glowEffect.OutlineColor = color
    end
})

-- Transparency Slider for Glow
MiscVisuals:addSlider({
    title = "Glow Transparency",
    default = 0.5,
    min = 0,
    max = 1,
    callback = function(value)
        glowEffect.FillTransparency = value
    end
})

-- // Player Tab
local Player = UI:addPage({
    title = "Player",
    icon = 5012544693
})

-- Player Sections
local Movement = Player:addSection({ title = "Movement" })
local Character = Player:addSection({ title = "Character" })
local Combat = Player:addSection({ title = "Combat" })

-- // Movement Features
Movement:addSlider({
    title = "WalkSpeed",
    default = 16,
    min = 10,
    max = 100,
    callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

Movement:addToggle({
    title = "Noclip",
    default = false,
    callback = function(state)
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not state
            end
        end
    end
})

-- Infinite Jump Toggle
local InfiniteJumpEnabled = false

-- Function to Enable/Disable Infinite Jump
local function EnableInfiniteJump(state)
    InfiniteJumpEnabled = state
end

-- Toggle for Infinite Jump
Movement:addToggle({
    title = "Infinite Jump",
    default = false,
    callback = function(value)
        EnableInfiniteJump(value)
    end
})

-- Infinite Jump Logic
game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
    end
end)

-- Variables for Click TP
local isCtrlPressed = false

-- Detect when the user presses Ctrl
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftControl then
        isCtrlPressed = true
    end
end)

-- Detect when the user releases Ctrl
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.LeftControl then
        isCtrlPressed = false
    end
end)

-- Function to Teleport Player on Ctrl + Click
local function onMouseClick()
    if isCtrlPressed then
        local mouse = game.Players.LocalPlayer:GetMouse()
        local pos = mouse.Hit + Vector3.new(0, 2.5, 0)  -- Position slightly above the clicked location
        local newCFrame = CFrame.new(pos.X, pos.Y, pos.Z)

        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = newCFrame
    end
end

-- Connect Mouse Click to Teleport Logic
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        onMouseClick()
    end
end)

local SpinbotEnabled = false  -- Boolean to control Spinbot state
local spinSpeed = 5  -- Default spin speed (degrees per frame)

-- Function to enable or disable Spinbot
local function ToggleSpinbot(state)
    SpinbotEnabled = state
    local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    
    if SpinbotEnabled then
        -- Start spinning
        while SpinbotEnabled and humanoid do
            humanoid.RootPart.CFrame = humanoid.RootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)  -- Rotate the character continuously
            wait(0.05)  -- Adjust the wait time for smoother or faster spinning
        end
    end
end

-- Add Spinbot Toggle to UI
Character:addToggle({
    title = "Spinbot",
    default = false,
    callback = function(value)
        ToggleSpinbot(value)  -- Enable or disable Spinbot based on the toggle state
    end
})

-- Add Slider for Spin Speed Control
Character:addSlider({
    title = "Spin Speed",
    min = 1,
    max = 500,
    default = 5,
    callback = function(value)
        spinSpeed = value  -- Adjust spin speed based on slider value
    end
})

local AimbotEnabled = false
local TargetHead = nil
local Smoothness = 0.1  -- How smoothly the camera moves towards the target

-- Function to find the closest player's head
local function GetClosestPlayer()
    local closestDistance = math.huge
    local closestPlayer = nil
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    if closestPlayer then
        return closestPlayer.Character.Head
    end
    return nil
end

-- Function to enable or disable Aimbot
local function ToggleAimbot(state)
    AimbotEnabled = state
    if AimbotEnabled then
        while AimbotEnabled do
            if TargetHead then
                local camera = game.Workspace.CurrentCamera
                local cameraPosition = camera.CFrame.Position
                local targetPosition = TargetHead.Position
                local direction = (targetPosition - cameraPosition).unit  -- Get the direction towards the target

                -- Smoothly interpolate the camera's CFrame towards the target's head
                local newCFrame = CFrame.new(cameraPosition + direction * 50, targetPosition)
                camera.CFrame = camera.CFrame:Lerp(newCFrame, Smoothness)  -- Lerp for smooth rotation
            end
            wait(0.03)  -- Adjust the frequency of the aiming update
        end
    end
end

-- Function to handle Right-Click (Aim at Head)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Right-click
        if AimbotEnabled then
            TargetHead = GetClosestPlayer()  -- Get the closest player's head
        end
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Right-click released
        TargetHead = nil  -- Stop aiming when right-click is released
    end
end)

-- Aimbot Toggle in the UI
Combat:addToggle({
    title = "Aimbot (Right-Click)",
    default = false,
    callback = function(value)
        ToggleAimbot(value)  -- Enable or disable Aimbot based on the toggle state
    end
})

-- Smoothness Slider in the UI for Aimbot sensitivity
Combat:addSlider({
    title = "Aimbot Smoothness",
    min = 0.01,
    max = 1,
    default = 0.1,
    callback = function(value)
        Smoothness = value  -- Adjust how smoothly the camera follows the target
    end
})

local TeleportEnabled = false
local TargetHead = nil

-- Function to find the closest enemy player (excluding teammates)
local function GetClosestEnemy()
    local closestDistance = math.huge
    local closestPlayer = nil
    
    for _, player in pairs(game.Players:GetPlayers()) do
        -- Ensure that the player is not the local player and is not on the same team
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            -- Check if player is on a different team
            if player.Team ~= game.Players.LocalPlayer.Team then
                local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    if closestPlayer then
        return closestPlayer.Character.HumanoidRootPart.Position  -- Return position of the closest enemy player
    end
    return nil
end

-- Function to enable or disable Teleport
local function ToggleTeleport(state)
    TeleportEnabled = state
    if TeleportEnabled then
        -- When teleport is enabled, find the closest enemy player's position and teleport the player there
        local targetPosition = GetClosestEnemy()
        if targetPosition then
            -- Teleport player to the target's position
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        end
    end
end

-- Teleport Toggle in the UI
Combat:addToggle({
    title = "Teleport to Closest Enemy",
    default = false,
    callback = function(value)
        ToggleTeleport(value)  -- Enable or disable Teleport based on the toggle state
    end
})

-- You can also create a keybind to teleport to an enemy, for example, pressing "T":
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.T then  -- Use "T" key to trigger teleport
        if TeleportEnabled then
            local targetPosition = GetClosestEnemy()
            if targetPosition then
                -- Teleport player to the target's position
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
            end
        end
    end
end)

local AimAuraEnabled = false
local Player = game.Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local function GetNearestEnemy()
    local closestDistance = math.huge
    local nearestPlayer = nil
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= Player and player.Team ~= Player.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (Player.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                nearestPlayer = player
            end
        end
    end
    
    return nearestPlayer
end

local function AimTowardsEnemy()
    if not AimAuraEnabled or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local enemy = GetNearestEnemy()
    
    if enemy and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
        local enemyPos = enemy.Character.HumanoidRootPart.Position
        local cameraPos = Camera.CFrame.Position
        local lookAt = CFrame.lookAt(cameraPos, enemyPos)

        -- Smooth aim effect
        Camera.CFrame = Camera.CFrame:Lerp(lookAt, 0.2)
    end
end

local function StartAimAura()
    AimAuraEnabled = true
    while AimAuraEnabled do
        AimTowardsEnemy()
        RunService.RenderStepped:Wait()
    end
end

local function StopAimAura()
    AimAuraEnabled = false
end

local function OnCharacterAdded(character)
    StopAimAura() -- Stop Aim Aura when dead
    local rootPart = character:WaitForChild("HumanoidRootPart", 5)
    if rootPart then
        wait(1) -- Small delay to ensure smooth transition
        StartAimAura() -- Restart Aim Aura when respawning
    end
end

-- Detect respawn
Player.CharacterAdded:Connect(OnCharacterAdded)

Combat:addToggle({
    title = "Enable Aim Aura",
    default = false,
    callback = function(value)
        if value then
            StartAimAura()
        else
            StopAimAura()
        end
    end
})

-- Right-click activation (Optional)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        StartAimAura()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        StopAimAura()
    end
end)

Combat:addToggle({
    title = "Enable Weapon Mods (Press once to apply forever)",
    default = false,
    callback = function(state)
        local replicationStorage = game.ReplicatedStorage

        if state then
            -- Loop through weapons and modify properties
            for _, v in pairs(replicationStorage.Weapons:GetDescendants()) do
                if v:IsA("ValueBase") then
                    if v.Name == "Auto" then
                        v.Value = true
                    elseif v.Name == "RecoilControl" then
                        v.Value = 0
                    elseif v.Name == "MaxSpread" then
                        v.Value = 0
                    elseif v.Name == "ReloadTime" then
                        v.Value = 0
                    elseif v.Name == "FireRate" then
                        v.Value = 0.05
                    elseif v.Name == "DMG" then
                        v.Value = 100
                    end
                end
            end
            print("✅ Weapon modifications applied permanently.")
        else
            print("❌ Weapon modifications disabled (but they persist).")
        end
    end
})






-- // Color Theme Customisation Page
local Theme = UI:addPage({
    title = "Theme",
    icon = 5012544693
})

local Colors = Theme:addSection({
    title = "Colors"
})

-- // Adding a color picker for each theme color
for theme, color in pairs(Themes) do
    Colors:addColorPicker({
        title = theme,
        default = color,
        callback = function(color3)
            UI:setTheme({
                theme = theme, 
                color3 = color3
            })
        end
    })
end

-- // Load
UI:SelectPage({
    page = UI.pages[1], 
    toggle = true
})
