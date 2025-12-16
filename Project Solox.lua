--[[
    Project Solox - Basketball Legends Script
    Fully debugged and optimized version
    Features: Auto Green, Ball Magnet, ESP, Speed Boost, and more
]]

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- Player Variables
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

-- Connection Storage (for proper cleanup)
local Connections = {
    AutoGreen = nil,
    SpeedBoost = nil,
    BallMagnet = nil,
    AutoGuard = nil,
    AutoRebound = nil,
    TracerESP = nil,
    BasketballESP = nil,
    PlayerESP = nil,
    FOVMod = nil,
    CameraRes = nil,
    QuickTP = nil
}

-- ESP Storage
local TracerLines = {}
local PlayerHighlights = {}
local BasketballHighlight = nil

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Project Solox | Basketball Legends",
    LoadingTitle = "Project Solox",
    LoadingSubtitle = "Loading...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ProjectSolox",
        FileName = "Config"
    },
    Theme = {
        Shadow = Color3.fromRGB(5, 10, 20),
        SliderProgress = Color3.fromRGB(100, 150, 255),
        PlaceholderColor = Color3.fromRGB(140, 180, 255),
        InputStroke = Color3.fromRGB(70, 110, 190),
        ToggleDisabledStroke = Color3.fromRGB(60, 60, 60),
        InputBackground = Color3.fromRGB(15, 25, 45),
        ElementBackgroundHover = Color3.fromRGB(30, 45, 80),
        DropdownUnselected = Color3.fromRGB(20, 30, 55),
        SelectedTabTextColor = Color3.fromRGB(120, 170, 255),
        NotificationBackground = Color3.fromRGB(20, 30, 55),
        DropdownSelected = Color3.fromRGB(30, 45, 80),
        SecondaryElementStroke = Color3.fromRGB(50, 90, 160),
        Background = Color3.fromRGB(10, 15, 30),
        ToggleDisabledOuterStroke = Color3.fromRGB(40, 40, 40),
        TabStroke = Color3.fromRGB(50, 70, 120),
        ElementBackground = Color3.fromRGB(20, 30, 55),
        ToggleEnabledOuterStroke = Color3.fromRGB(50, 90, 160),
        ToggleEnabled = Color3.fromRGB(100, 150, 255),
        ToggleEnabledStroke = Color3.fromRGB(70, 120, 200),
        ToggleDisabled = Color3.fromRGB(90, 90, 90),
        SecondaryElementBackground = Color3.fromRGB(15, 25, 45),
        ToggleBackground = Color3.fromRGB(20, 25, 45),
        TabTextColor = Color3.fromRGB(170, 200, 255),
        ElementStroke = Color3.fromRGB(70, 110, 180),
        SliderBackground = Color3.fromRGB(40, 70, 120),
        SliderStroke = Color3.fromRGB(70, 120, 200),
        NotificationActionsBackground = Color3.fromRGB(35, 50, 80),
        Topbar = Color3.fromRGB(15, 25, 45),
        TabBackground = Color3.fromRGB(40, 60, 100),
        TabBackgroundSelected = Color3.fromRGB(25, 40, 80),
        TextColor = Color3.fromRGB(170, 200, 255),
    },
})

-- Utility Functions
local function GetBall()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Basketball" and obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid") then
            return obj
        end
    end
    return nil
end

local function GetPlayerWithBall()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if player.Character:FindFirstChild("Basketball") then
                return player
            end
        end
    end
    return nil
end

local function SafeDisconnect(connectionName)
    if Connections[connectionName] then
        Connections[connectionName]:Disconnect()
        Connections[connectionName] = nil
    end
end

local function CleanupTracers()
    for _, line in pairs(TracerLines) do
        if line then
            line:Remove()
        end
    end
    TracerLines = {}
end

local function CleanupHighlights()
    for _, highlight in pairs(PlayerHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    PlayerHighlights = {}
end

-- =============================================
-- TAB 1: BALL MODS
-- =============================================
local BallModsTab = Window:CreateTab("Ball Mods", nil)

-- Auto Green Section
BallModsTab:CreateSection("Auto Green")
BallModsTab:CreateLabel("Timing assist for perfect shots!")

local AutoGreenMode = "Perfect" -- Default mode
local GoodValue = 0.9
local GreatValue = 0.95

local function RunAutoGreen()
    SafeDisconnect("AutoGreen")
    
    Connections.AutoGreen = RunService.RenderStepped:Connect(function()
        local shootingGui = LocalPlayer:FindFirstChild("PlayerGui")
        if shootingGui then
            local visual = shootingGui:FindFirstChild("Visual")
            if visual then
                local shooting = visual:FindFirstChild("Shooting")
                if shooting and shooting.Visible then
                    local meter = shooting:FindFirstChild("Meter") or shooting:FindFirstChild("Bar")
                    if meter then
                        local targetValue
                        if AutoGreenMode == "Perfect" then
                            targetValue = 1
                        elseif AutoGreenMode == "Great" then
                            targetValue = GreatValue
                        elseif AutoGreenMode == "Good" then
                            targetValue = GoodValue
                        elseif AutoGreenMode == "Random" then
                            targetValue = math.random(70, 100) / 100
                        end
                        
                        -- Simulate release at target timing
                        local currentValue = meter.Size.X.Scale or 0
                        if currentValue >= targetValue then
                            game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        end
                    end
                end
            end
        end
    end)
end

BallModsTab:CreateToggle({
    Name = "Auto Perfect",
    CurrentValue = false,
    Flag = "AutoPerfect",
    Callback = function(Value)
        if Value then
            AutoGreenMode = "Perfect"
            Rayfield.Flags.AutoGood:Set(false)
            Rayfield.Flags.AutoGreat:Set(false)
            Rayfield.Flags.Randomizer:Set(false)
            RunAutoGreen()
        else
            if AutoGreenMode == "Perfect" then
                SafeDisconnect("AutoGreen")
            end
        end
    end,
})

BallModsTab:CreateToggle({
    Name = "Auto Good",
    CurrentValue = false,
    Flag = "AutoGood",
    Callback = function(Value)
        if Value then
            AutoGreenMode = "Good"
            Rayfield.Flags.AutoPerfect:Set(false)
            Rayfield.Flags.AutoGreat:Set(false)
            Rayfield.Flags.Randomizer:Set(false)
            RunAutoGreen()
        else
            if AutoGreenMode == "Good" then
                SafeDisconnect("AutoGreen")
            end
        end
    end,
})

BallModsTab:CreateToggle({
    Name = "Auto Great",
    CurrentValue = false,
    Flag = "AutoGreat",
    Callback = function(Value)
        if Value then
            AutoGreenMode = "Great"
            Rayfield.Flags.AutoPerfect:Set(false)
            Rayfield.Flags.AutoGood:Set(false)
            Rayfield.Flags.Randomizer:Set(false)
            RunAutoGreen()
        else
            if AutoGreenMode == "Great" then
                SafeDisconnect("AutoGreen")
            end
        end
    end,
})

BallModsTab:CreateToggle({
    Name = "Randomizer",
    CurrentValue = false,
    Flag = "Randomizer",
    Callback = function(Value)
        if Value then
            AutoGreenMode = "Random"
            Rayfield.Flags.AutoPerfect:Set(false)
            Rayfield.Flags.AutoGood:Set(false)
            Rayfield.Flags.AutoGreat:Set(false)
            RunAutoGreen()
        else
            if AutoGreenMode == "Random" then
                SafeDisconnect("AutoGreen")
            end
        end
    end,
})

BallModsTab:CreateSlider({
    Name = "Good Value",
    Range = {0.1, 1},
    Increment = 0.01,
    Suffix = "value",
    CurrentValue = 0.9,
    Flag = "GoodValue",
    Callback = function(Value)
        GoodValue = Value
    end,
})

BallModsTab:CreateSlider({
    Name = "Great Value",
    Range = {0.1, 1},
    Increment = 0.01,
    Suffix = "value",
    CurrentValue = 0.95,
    Flag = "GreatValue",
    Callback = function(Value)
        GreatValue = Value
    end,
})

-- Ball Magnet Section
BallModsTab:CreateSection("Ball Magnet")

local BallMagnetRange = 10

BallModsTab:CreateToggle({
    Name = "Ball Magnet",
    CurrentValue = false,
    Flag = "BallMagEnabled",
    Callback = function(Value)
        SafeDisconnect("BallMagnet")
        
        if Value then
            Connections.BallMagnet = RunService.Heartbeat:Connect(function()
                local ball = GetBall()
                if ball and HumanoidRootPart then
                    local distance = (ball.Position - HumanoidRootPart.Position).Magnitude
                    if distance <= BallMagnetRange then
                        ball.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                    end
                end
            end)
        end
    end,
})

BallModsTab:CreateSlider({
    Name = "Ball Magnet Range",
    Range = {1, 20},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 10,
    Flag = "BallMagRange",
    Callback = function(Value)
        BallMagnetRange = Value
    end,
})

BallModsTab:CreateButton({
    Name = "Ball Magnet Script (External)",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/kcYYUzPg"))()
    end,
})

-- Auto Guard Section
BallModsTab:CreateSection("Auto Guard")

BallModsTab:CreateToggle({
    Name = "Auto Guard",
    CurrentValue = false,
    Flag = "AutoGuard",
    Callback = function(Value)
        SafeDisconnect("AutoGuard")
        
        if Value then
            Connections.AutoGuard = RunService.Heartbeat:Connect(function()
                local playerWithBall = GetPlayerWithBall()
                if playerWithBall and playerWithBall.Character then
                    local targetHRP = playerWithBall.Character:FindFirstChild("HumanoidRootPart")
                    if targetHRP and HumanoidRootPart then
                        -- Check if enemy team
                        if LocalPlayer.Team ~= playerWithBall.Team then
                            local targetPos = targetHRP.Position
                            HumanoidRootPart.CFrame = CFrame.lookAt(
                                HumanoidRootPart.Position,
                                Vector3.new(targetPos.X, HumanoidRootPart.Position.Y, targetPos.Z)
                            )
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
                            task.wait(0.1)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.F, false, game)
                        end
                    end
                end
            end)
        end
    end,
})

BallModsTab:CreateLabel("Auto faces the ball holder and guards!")

BallModsTab:CreateDivider()

-- Auto Rebound Section
BallModsTab:CreateSection("Auto Get Rebound")

BallModsTab:CreateToggle({
    Name = "Auto Get Rebound",
    CurrentValue = false,
    Flag = "AutoGetBall",
    Callback = function(Value)
        SafeDisconnect("AutoRebound")
        
        if Value then
            Connections.AutoRebound = RunService.Heartbeat:Connect(function()
                local ball = GetBall()
                if ball and HumanoidRootPart then
                    local distance = (ball.Position - HumanoidRootPart.Position).Magnitude
                    if distance <= 25 then
                        -- Move towards the ball
                        local direction = (ball.Position - HumanoidRootPart.Position).Unit
                        HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position + direction * 2)
                    end
                end
            end)
        end
    end,
})

BallModsTab:CreateLabel("Auto gets loose basketballs!")

-- Auto Steal Section
BallModsTab:CreateSection("Auto Steal")

BallModsTab:CreateButton({
    Name = "Auto Steal Script (External)",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/xISFifA3/raw"))()
    end,
})

-- =============================================
-- TAB 2: PLAYER CONFIGURATION
-- =============================================
local PlayerTab = Window:CreateTab("Player Configuration", nil)

-- Speed Boost Section
PlayerTab:CreateSection("Speed Boost")

local SpeedValue = 1

PlayerTab:CreateToggle({
    Name = "Speed Boost",
    CurrentValue = false,
    Flag = "SpeedEnabled",
    Callback = function(Value)
        SafeDisconnect("SpeedBoost")
        
        if Value then
            Connections.SpeedBoost = RunService.RenderStepped:Connect(function()
                if Character and Humanoid then
                    if Humanoid.MoveDirection.Magnitude > 0 and HumanoidRootPart then
                        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + (Humanoid.MoveDirection * SpeedValue)
                    end
                end
            end)
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Speed Value",
    Range = {0.1, 3},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "SpeedValue",
    Callback = function(Value)
        SpeedValue = Value
    end,
})

-- Mobile Teleports Section
PlayerTab:CreateSection("Mobile Teleports")

local QuickTpDist = 2.5
local QuickTpDelay = 0.3
local TpButton = nil

PlayerTab:CreateToggle({
    Name = "Quick TP Button",
    CurrentValue = false,
    Flag = "QuickTpEnabled",
    Callback = function(Value)
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        
        -- Remove existing button
        local existing = playerGui:FindFirstChild("TpButton")
        if existing then
            existing:Destroy()
        end
        
        if Value then
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "TpButton"
            screenGui.ResetOnSpawn = false
            screenGui.Parent = playerGui
            
            local button = Instance.new("TextButton")
            button.Name = "Btn"
            button.Size = UDim2.new(0, 200, 0, 50)
            button.Position = UDim2.new(0.5, -100, 0.9, -25)
            button.AnchorPoint = Vector2.new(0.5, 0.5)
            button.BackgroundTransparency = 1
            button.Text = ""
            button.Parent = screenGui
            
            local bg = Instance.new("Frame")
            bg.Name = "Bg"
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundColor3 = Color3.new(1, 1, 1)
            bg.Parent = button
            
            local gradient = Instance.new("UIGradient")
            gradient.Rotation = 90
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 100, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255)),
            })
            gradient.Parent = bg
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 12)
            corner.Parent = bg
            
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(60, 60, 60)
            stroke.Thickness = 2
            stroke.Parent = bg
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "Quick TP"
            label.Font = Enum.Font.GothamBold
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextSize = 20
            label.Parent = button
            
            local labelStroke = Instance.new("UIStroke")
            labelStroke.Color = Color3.new(0, 0, 0)
            labelStroke.Thickness = 1.5
            labelStroke.Parent = label
            
            -- Hover effects
            button.MouseEnter:Connect(function()
                TweenService:Create(gradient, TweenInfo.new(0.2), {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 150, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 50, 255)),
                    })
                }):Play()
                TweenService:Create(stroke, TweenInfo.new(0.2), {Thickness = 3}):Play()
            end)
            
            button.MouseLeave:Connect(function()
                TweenService:Create(gradient, TweenInfo.new(0.3), {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 100, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 255)),
                    })
                }):Play()
                TweenService:Create(stroke, TweenInfo.new(0.3), {Thickness = 2}):Play()
            end)
            
            -- TP Functionality
            local lastTp = 0
            button.MouseButton1Click:Connect(function()
                if tick() - lastTp >= QuickTpDelay then
                    lastTp = tick()
                    local char = LocalPlayer.Character
                    if char then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * QuickTpDist)
                        end
                    end
                end
            end)
            
            TpButton = screenGui
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Quick TP Distance",
    Range = {0.1, 10},
    Increment = 0.1,
    Suffix = "studs",
    CurrentValue = 2.5,
    Flag = "QuickTpDist",
    Callback = function(Value)
        QuickTpDist = Value
    end,
})

PlayerTab:CreateSlider({
    Name = "Quick TP Delay",
    Range = {0.1, 1},
    Increment = 0.1,
    Suffix = "seconds",
    CurrentValue = 0.3,
    Flag = "QuickTpDelay",
    Callback = function(Value)
        QuickTpDelay = Value
    end,
})

-- Computer Teleports Section
PlayerTab:CreateSection("Computer Teleports")

local RToTpDist = 2.5
local RToTpDelay = 0.3
local lastRTp = 0

PlayerTab:CreateToggle({
    Name = "R to TP",
    CurrentValue = false,
    Flag = "RToTpEnabled",
    Callback = function(Value)
        -- Connection handled in InputBegan
    end,
})

PlayerTab:CreateSlider({
    Name = "R TP Distance",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = "studs",
    CurrentValue = 2.5,
    Flag = "RToTpDist",
    Callback = function(Value)
        RToTpDist = Value
    end,
})

PlayerTab:CreateSlider({
    Name = "R TP Delay",
    Range = {0.1, 1},
    Increment = 0.1,
    Suffix = "seconds",
    CurrentValue = 0.3,
    Flag = "RToTpDelay",
    Callback = function(Value)
        RToTpDelay = Value
    end,
})

PlayerTab:CreateLabel("Press R to teleport forward!")

-- =============================================
-- TAB 3: ESP FEATURES
-- =============================================
local ESPTab = Window:CreateTab("ESP Features", nil)

-- Tracers Section
ESPTab:CreateSection("Tracers")

ESPTab:CreateToggle({
    Name = "Tracer ESP",
    CurrentValue = false,
    Flag = "TracerEnabled",
    Callback = function(Value)
        SafeDisconnect("TracerESP")
        CleanupTracers()
        
        if Value then
            -- Create tracer lines for all players
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local line = Drawing.new("Line")
                    line.Visible = false
                    line.Color = Color3.new(1, 0, 0)
                    line.Thickness = 2
                    line.ZIndex = 1
                    TracerLines[player.Name] = line
                end
            end
            
            Connections.TracerESP = RunService.RenderStepped:Connect(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local line = TracerLines[player.Name]
                        if not line then
                            line = Drawing.new("Line")
                            line.Color = Color3.new(1, 0, 0)
                            line.Thickness = 2
                            line.ZIndex = 1
                            TracerLines[player.Name] = line
                        end
                        
                        local char = player.Character
                        if char then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                                if onScreen then
                                    line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                    line.To = Vector2.new(pos.X, pos.Y)
                                    line.Visible = true
                                    
                                    -- Color based on team
                                    if player.Team == LocalPlayer.Team then
                                        line.Color = Color3.new(0, 1, 0)
                                    else
                                        line.Color = Color3.new(1, 0, 0)
                                    end
                                else
                                    line.Visible = false
                                end
                            else
                                line.Visible = false
                            end
                        else
                            line.Visible = false
                        end
                    end
                end
            end)
        end
    end,
})

-- Basketball ESP Section
ESPTab:CreateSection("Basketball ESP")

ESPTab:CreateToggle({
    Name = "Basketball Highlight",
    CurrentValue = false,
    Flag = "BasketballHighlight",
    Callback = function(Value)
        SafeDisconnect("BasketballESP")
        
        if BasketballHighlight then
            BasketballHighlight:Destroy()
            BasketballHighlight = nil
        end
        
        if Value then
            Connections.BasketballESP = RunService.RenderStepped:Connect(function()
                local ball = GetBall()
                if ball then
                    if not BasketballHighlight or BasketballHighlight.Parent ~= ball then
                        if BasketballHighlight then
                            BasketballHighlight:Destroy()
                        end
                        BasketballHighlight = Instance.new("Highlight")
                        BasketballHighlight.Name = "BallESP"
                        BasketballHighlight.FillColor = Color3.new(1, 0.5, 0)
                        BasketballHighlight.OutlineColor = Color3.new(1, 1, 0)
                        BasketballHighlight.FillTransparency = 0.5
                        BasketballHighlight.OutlineTransparency = 0
                        BasketballHighlight.Parent = ball
                    end
                else
                    if BasketballHighlight then
                        BasketballHighlight:Destroy()
                        BasketballHighlight = nil
                    end
                end
            end)
        end
    end,
})

-- Player ESP Section
ESPTab:CreateSection("Player ESP")

ESPTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(Value)
        SafeDisconnect("PlayerESP")
        CleanupHighlights()
        
        if Value then
            local function AddHighlight(player)
                if player ~= LocalPlayer and player.Character then
                    local existingHighlight = player.Character:FindFirstChild("PlayerESP")
                    if existingHighlight then
                        existingHighlight:Destroy()
                    end
                    
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "PlayerESP"
                    highlight.FillTransparency = 0.7
                    highlight.OutlineTransparency = 0
                    
                    if player.Team == LocalPlayer.Team then
                        highlight.FillColor = Color3.new(0, 1, 0)
                        highlight.OutlineColor = Color3.new(0, 0.5, 0)
                    else
                        highlight.FillColor = Color3.new(1, 0, 0)
                        highlight.OutlineColor = Color3.new(0.5, 0, 0)
                    end
                    
                    highlight.Parent = player.Character
                    PlayerHighlights[player.Name] = highlight
                end
            end
            
            -- Add highlights to current players
            for _, player in pairs(Players:GetPlayers()) do
                AddHighlight(player)
            end
            
            -- Watch for new players and character respawns
            Connections.PlayerESP = Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    if Rayfield.Flags.PlayerESP and Rayfield.Flags.PlayerESP.CurrentValue then
                        AddHighlight(player)
                    end
                end)
            end)
            
            -- Handle respawns for existing players
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    player.CharacterAdded:Connect(function()
                        task.wait(0.5)
                        if Rayfield.Flags.PlayerESP and Rayfield.Flags.PlayerESP.CurrentValue then
                            AddHighlight(player)
                        end
                    end)
                end
            end
        end
    end,
})

-- =============================================
-- TAB 4: WORLD CHANGER
-- =============================================
local WorldTab = Window:CreateTab("World Changer", nil)

-- FOV Section
WorldTab:CreateSection("FOV Modifier")

local FOVValue = 90

WorldTab:CreateToggle({
    Name = "FOV Modifier",
    CurrentValue = false,
    Flag = "FOVEnabled",
    Callback = function(Value)
        SafeDisconnect("FOVMod")
        
        if Value then
            Camera.FieldOfView = FOVValue
            Connections.FOVMod = RunService.RenderStepped:Connect(function()
                Camera.FieldOfView = FOVValue
            end)
        else
            Camera.FieldOfView = 70 -- Default FOV
        end
    end,
})

WorldTab:CreateSlider({
    Name = "FOV Value",
    Range = {60, 120},
    Increment = 1,
    Suffix = "FOV",
    CurrentValue = 90,
    Flag = "FOVValue",
    Callback = function(Value)
        FOVValue = Value
        if Rayfield.Flags.FOVEnabled and Rayfield.Flags.FOVEnabled.CurrentValue then
            Camera.FieldOfView = Value
        end
    end,
})

-- Extra Visual Settings
WorldTab:CreateSection("Extra Stuff")

WorldTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(Value)
        if Value then
            Lighting.Ambient = Color3.new(0.8, 0.8, 0.8)
            Lighting.Brightness = 1.5
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.new(0.8, 0.8, 0.8)
        else
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        end
    end,
})

WorldTab:CreateToggle({
    Name = "No Fog",
    CurrentValue = false,
    Flag = "NoFog",
    Callback = function(Value)
        if Value then
            Lighting.FogEnd = 1000000
            Lighting.FogStart = 1000000
        else
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
        end
    end,
})

WorldTab:CreateToggle({
    Name = "NVIDIA Style Shaders",
    CurrentValue = false,
    Flag = "Shaders",
    Callback = function(Value)
        -- Remove existing NVIDIA effects
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect.Name:find("NVIDIA") then
                effect:Destroy()
            end
        end
        
        if Value then
            local bloom = Instance.new("BloomEffect")
            bloom.Name = "NVIDIABloom"
            bloom.Intensity = 0.2
            bloom.Size = 16
            bloom.Threshold = 0.9
            bloom.Parent = Lighting
            
            local color = Instance.new("ColorCorrectionEffect")
            color.Name = "NVIDIAColor"
            color.Brightness = 0.02
            color.Contrast = 0.1
            color.Saturation = 0.1
            color.TintColor = Color3.new(1.01, 1.005, 0.995)
            color.Parent = Lighting
            
            local dof = Instance.new("DepthOfFieldEffect")
            dof.Name = "NVIDIADepth"
            dof.FarIntensity = 0.02
            dof.FocusDistance = 25
            dof.InFocusRadius = 40
            dof.NearIntensity = 0.1
            dof.Parent = Lighting
            
            local sunrays = Instance.new("SunRaysEffect")
            sunrays.Name = "NVIDIASunRays"
            sunrays.Intensity = 0.1
            sunrays.Spread = 0.4
            sunrays.Parent = Lighting
            
            local blur = Instance.new("BlurEffect")
            blur.Name = "NVIDIABlur"
            blur.Size = 0.2
            blur.Parent = Lighting
            
            Lighting.GlobalShadows = true
            Lighting.ShadowSoftness = 0.4
            Lighting.Brightness = 1.05
            Lighting.OutdoorAmbient = Color3.new(0.6, 0.7, 0.9)
            Lighting.Ambient = Color3.new(0.45, 0.45, 0.55)
            Lighting.FogColor = Color3.new(0.4, 0.5, 0.7)
            Lighting.FogStart = 100
            Lighting.FogEnd = 500
        end
    end,
})

-- =============================================
-- INPUT HANDLING
-- =============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- R to TP
    if input.KeyCode == Enum.KeyCode.R then
        if Rayfield.Flags.RToTpEnabled and Rayfield.Flags.RToTpEnabled.CurrentValue then
            if tick() - lastRTp >= RToTpDelay then
                lastRTp = tick()
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * RToTpDist)
                    end
                end
            end
        end
    end
end)

-- =============================================
-- CHARACTER RESPAWN HANDLING
-- =============================================
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    
    -- Reconnect active features
    task.wait(0.5)
    
    if Rayfield.Flags.SpeedEnabled and Rayfield.Flags.SpeedEnabled.CurrentValue then
        Rayfield.Flags.SpeedEnabled:Set(false)
        task.wait(0.1)
        Rayfield.Flags.SpeedEnabled:Set(true)
    end
    
    if Rayfield.Flags.BallMagEnabled and Rayfield.Flags.BallMagEnabled.CurrentValue then
        Rayfield.Flags.BallMagEnabled:Set(false)
        task.wait(0.1)
        Rayfield.Flags.BallMagEnabled:Set(true)
    end
    
    if Rayfield.Flags.AutoGuard and Rayfield.Flags.AutoGuard.CurrentValue then
        Rayfield.Flags.AutoGuard:Set(false)
        task.wait(0.1)
        Rayfield.Flags.AutoGuard:Set(true)
    end
end)

-- =============================================
-- PLAYER CLEANUP
-- =============================================
Players.PlayerRemoving:Connect(function(player)
    if TracerLines[player.Name] then
        TracerLines[player.Name]:Remove()
        TracerLines[player.Name] = nil
    end
    if PlayerHighlights[player.Name] then
        PlayerHighlights[player.Name]:Destroy()
        PlayerHighlights[player.Name] = nil
    end
end)

-- Notification
Rayfield:Notify({
    Title = "Project Solox Loaded",
    Content = "Basketball Legends script is ready!",
    Duration = 5,
    Image = nil,
})

print("[Project Solox] Script loaded successfully!")
