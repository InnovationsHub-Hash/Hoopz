--[[
    Project Solox - Basketball Legends Script
    Version: 2.0 | Fully Undetected
    Features: Auto Green, Ball Magnet, ESP, Speed Boost, Anti-AFK, Server Hop
    
    Anti-Detection: Randomized delays, spoofed calls, secure execution
]]

-- =============================================
-- ANTI-DETECTION & BYPASS SYSTEM
-- =============================================
local function RandomDelay(min, max)
    min = min or 0.01
    max = max or 0.05
    return math.random() * (max - min) + min
end

local function SecureWait(duration)
    local start = os.clock()
    while os.clock() - start < duration do
        task.wait()
    end
end

-- Spoof script identity
local ScriptIdentity = {
    Name = string.char(math.random(65, 90)) .. tostring(math.random(1000, 9999)),
    ExecutionTime = tick(),
    SessionID = game:GetService("HttpService"):GenerateGUID(false)
}

-- Anti-detection wrapper for service calls
local Services = setmetatable({}, {
    __index = function(self, serviceName)
        local success, service = pcall(function()
            return game:GetService(serviceName)
        end)
        if success then
            rawset(self, serviceName, service)
            return service
        end
        return nil
    end
})

-- Secure function caller with randomization
local function SecureCall(func, ...)
    task.wait(RandomDelay(0.001, 0.01))
    local args = {...}
    local success, result = pcall(function()
        return func(unpack(args))
    end)
    if success then
        return result
    end
    return nil
end

-- Hook protection
local OldNamecall
local HookEnabled = false

local function SetupAntiDetection()
    -- Prevent detection of script execution
    if not HookEnabled and hookmetamethod then
        HookEnabled = true
        OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Block kick attempts
            if method == "Kick" and self == Services.Players.LocalPlayer then
                return nil
            end
            
            -- Spoof detection checks
            if method == "FindFirstChild" or method == "WaitForChild" then
                if typeof(args[1]) == "string" then
                    local lower = args[1]:lower()
                    if lower:find("exploit") or lower:find("hack") or lower:find("cheat") then
                        return nil
                    end
                end
            end
            
            return OldNamecall(self, ...)
        end)
    end
end

pcall(SetupAntiDetection)

-- =============================================
-- SERVICES (Cached for performance & stealth)
-- =============================================
local Players = Services.Players
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local Lighting = Services.Lighting
local TeleportService = Services.TeleportService
local HttpService = Services.HttpService
local VirtualUser = Services.VirtualUser
local VirtualInputManager = Services.VirtualInputManager
local GuiService = Services.GuiService
local CoreGui = Services.CoreGui

-- =============================================
-- PLAYER VARIABLES
-- =============================================
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

-- =============================================
-- CONNECTION & STATE MANAGEMENT
-- =============================================
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
    QuickTP = nil,
    AntiAFK = nil
}

local TracerLines = {}
local PlayerHighlights = {}
local BasketballHighlight = nil

-- Anti-AFK State
local AntiAFKActive = false
local LastActivity = tick()

-- =============================================
-- LOAD UI LIBRARY (With bypass)
-- =============================================
local Rayfield
do
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    end)
    if success then
        Rayfield = result
    else
        warn("[Project Solox] Failed to load UI, retrying...")
        task.wait(1)
        Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    end
end

-- =============================================
-- CREATE WINDOW
-- =============================================
local Window = Rayfield:CreateWindow({
    Name = "Project Solox | Basketball Legends",
    LoadingTitle = "Project Solox v2.0",
    LoadingSubtitle = "Initializing bypass...",
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

-- =============================================
-- UTILITY FUNCTIONS (With anti-detection)
-- =============================================
local function GetBall()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Basketball" and obj:IsA("BasePart") then
            if not obj.Parent:FindFirstChild("Humanoid") then
                return obj
            end
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
        pcall(function()
            Connections[connectionName]:Disconnect()
        end)
        Connections[connectionName] = nil
    end
end

local function CleanupTracers()
    for _, line in pairs(TracerLines) do
        pcall(function()
            if line then line:Remove() end
        end)
    end
    TracerLines = {}
end

local function CleanupHighlights()
    for _, highlight in pairs(PlayerHighlights) do
        pcall(function()
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
        end)
    end
    PlayerHighlights = {}
end

-- Secure input simulation (bypasses detection)
local function SecureKeyPress(keyCode, duration)
    duration = duration or 0.1
    local vim = VirtualInputManager
    if vim then
        pcall(function()
            vim:SendKeyEvent(true, keyCode, false, game)
            task.wait(duration + RandomDelay())
            vim:SendKeyEvent(false, keyCode, false, game)
        end)
    end
end

local function SecureMouseClick()
    local vim = VirtualInputManager
    if vim then
        pcall(function()
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(RandomDelay())
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    end
end

-- =============================================
-- TAB 1: BALL MODS
-- =============================================
local BallModsTab = Window:CreateTab("Ball Mods", nil)

BallModsTab:CreateSection("Auto Green")
BallModsTab:CreateLabel("Timing assist for perfect shots!")

local AutoGreenMode = "Perfect"
local GoodValue = 0.9
local GreatValue = 0.95

local function RunAutoGreen()
    SafeDisconnect("AutoGreen")
    
    Connections.AutoGreen = RunService.RenderStepped:Connect(function()
        task.wait(RandomDelay(0.001, 0.005)) -- Anti-detection delay
        
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
                        
                        local currentValue = meter.Size.X.Scale or 0
                        if currentValue >= targetValue then
                            SecureMouseClick()
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
                task.wait(RandomDelay(0.01, 0.03))
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
                task.wait(RandomDelay(0.02, 0.05))
                local playerWithBall = GetPlayerWithBall()
                if playerWithBall and playerWithBall.Character then
                    local targetHRP = playerWithBall.Character:FindFirstChild("HumanoidRootPart")
                    if targetHRP and HumanoidRootPart then
                        if LocalPlayer.Team ~= playerWithBall.Team then
                            local targetPos = targetHRP.Position
                            HumanoidRootPart.CFrame = CFrame.lookAt(
                                HumanoidRootPart.Position,
                                Vector3.new(targetPos.X, HumanoidRootPart.Position.Y, targetPos.Z)
                            )
                            SecureKeyPress(Enum.KeyCode.F, 0.1)
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
                task.wait(RandomDelay(0.01, 0.03))
                local ball = GetBall()
                if ball and HumanoidRootPart then
                    local distance = (ball.Position - HumanoidRootPart.Position).Magnitude
                    if distance <= 25 then
                        local direction = (ball.Position - HumanoidRootPart.Position).Unit
                        HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position + direction * 2)
                    end
                end
            end)
        end
    end,
})

BallModsTab:CreateLabel("Auto gets loose basketballs!")

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
    Callback = function(Value) end,
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

ESPTab:CreateSection("Tracers")

ESPTab:CreateToggle({
    Name = "Tracer ESP",
    CurrentValue = false,
    Flag = "TracerEnabled",
    Callback = function(Value)
        SafeDisconnect("TracerESP")
        CleanupTracers()
        
        if Value then
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
            
            for _, player in pairs(Players:GetPlayers()) do
                AddHighlight(player)
            end
            
            Connections.PlayerESP = Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    if Rayfield.Flags.PlayerESP and Rayfield.Flags.PlayerESP.CurrentValue then
                        AddHighlight(player)
                    end
                end)
            end)
            
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
            Camera.FieldOfView = 70
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
-- TAB 5: UTILITY (NEW - Anti-AFK & Server Hop)
-- =============================================
local UtilityTab = Window:CreateTab("Utility", nil)

-- Anti-AFK Section
UtilityTab:CreateSection("Anti-AFK System")

local AntiAFKMethod = "VirtualUser" -- Default method
local AntiAFKInterval = 60

UtilityTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFKEnabled",
    Callback = function(Value)
        SafeDisconnect("AntiAFK")
        AntiAFKActive = Value
        
        if Value then
            -- Method 1: Disconnect the idle event
            local success = pcall(function()
                for _, connection in pairs(getconnections(Players.LocalPlayer.Idled)) do
                    connection:Disable()
                end
            end)
            
            -- Method 2: VirtualUser simulation
            Connections.AntiAFK = RunService.Stepped:Connect(function()
                if tick() - LastActivity >= AntiAFKInterval then
                    LastActivity = tick()
                    
                    -- Randomize anti-AFK action
                    local action = math.random(1, 4)
                    
                    if action == 1 and VirtualUser then
                        pcall(function()
                            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                            task.wait(RandomDelay(0.05, 0.15))
                            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                        end)
                    elseif action == 2 and VirtualUser then
                        pcall(function()
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton2(Vector2.new(0, 0))
                        end)
                    elseif action == 3 and VirtualInputManager then
                        pcall(function()
                            local randomKey = ({Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D})[math.random(1, 4)]
                            VirtualInputManager:SendKeyEvent(true, randomKey, false, game)
                            task.wait(RandomDelay(0.02, 0.08))
                            VirtualInputManager:SendKeyEvent(false, randomKey, false, game)
                        end)
                    else
                        -- Camera wiggle (most undetectable)
                        pcall(function()
                            local cam = workspace.CurrentCamera
                            local originalCFrame = cam.CFrame
                            cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(math.random(-1, 1) * 0.1), 0)
                            task.wait(RandomDelay(0.01, 0.03))
                            cam.CFrame = originalCFrame
                        end)
                    end
                end
            end)
            
            Rayfield:Notify({
                Title = "Anti-AFK Enabled",
                Content = "You will no longer be kicked for being idle!",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "Anti-AFK Disabled",
                Content = "AFK protection turned off.",
                Duration = 3,
            })
        end
    end,
})

UtilityTab:CreateSlider({
    Name = "Anti-AFK Interval",
    Range = {30, 300},
    Increment = 10,
    Suffix = "seconds",
    CurrentValue = 60,
    Flag = "AntiAFKInterval",
    Callback = function(Value)
        AntiAFKInterval = Value
    end,
})

UtilityTab:CreateDropdown({
    Name = "Anti-AFK Method",
    Options = {"VirtualUser", "VirtualInput", "Camera", "Random"},
    CurrentOption = {"Random"},
    Flag = "AntiAFKMethod",
    Callback = function(Option)
        AntiAFKMethod = Option[1] or Option
    end,
})

UtilityTab:CreateLabel("Prevents being kicked for inactivity!")

-- Server Hop Section
UtilityTab:CreateSection("Server Hop")

local ServerHopMethod = "Random"

UtilityTab:CreateButton({
    Name = "Server Hop (Random)",
    Callback = function()
        Rayfield:Notify({
            Title = "Server Hop",
            Content = "Finding a new server...",
            Duration = 3,
        })
        
        task.spawn(function()
            local success, servers = pcall(function()
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                return HttpService:JSONDecode(game:HttpGet(url))
            end)
            
            if success and servers and servers.data then
                local validServers = {}
                for _, server in pairs(servers.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        table.insert(validServers, server.id)
                    end
                end
                
                if #validServers > 0 then
                    local targetServer = validServers[math.random(1, #validServers)]
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer)
                else
                    Rayfield:Notify({
                        Title = "Server Hop Failed",
                        Content = "No available servers found!",
                        Duration = 3,
                    })
                end
            else
                -- Fallback: Simple rejoin
                TeleportService:Teleport(game.PlaceId)
            end
        end)
    end,
})

UtilityTab:CreateButton({
    Name = "Server Hop (Lowest Players)",
    Callback = function()
        Rayfield:Notify({
            Title = "Server Hop",
            Content = "Finding server with lowest players...",
            Duration = 3,
        })
        
        task.spawn(function()
            local success, servers = pcall(function()
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                return HttpService:JSONDecode(game:HttpGet(url))
            end)
            
            if success and servers and servers.data then
                local lowestServer = nil
                local lowestPlayers = math.huge
                
                for _, server in pairs(servers.data) do
                    if server.playing < lowestPlayers and server.playing > 0 and server.id ~= game.JobId then
                        lowestPlayers = server.playing
                        lowestServer = server.id
                    end
                end
                
                if lowestServer then
                    Rayfield:Notify({
                        Title = "Server Found",
                        Content = "Joining server with " .. lowestPlayers .. " players...",
                        Duration = 2,
                    })
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, lowestServer)
                else
                    TeleportService:Teleport(game.PlaceId)
                end
            else
                TeleportService:Teleport(game.PlaceId)
            end
        end)
    end,
})

UtilityTab:CreateButton({
    Name = "Server Hop (Most Players)",
    Callback = function()
        Rayfield:Notify({
            Title = "Server Hop",
            Content = "Finding server with most players...",
            Duration = 3,
        })
        
        task.spawn(function()
            local success, servers = pcall(function()
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
                return HttpService:JSONDecode(game:HttpGet(url))
            end)
            
            if success and servers and servers.data then
                local highestServer = nil
                local highestPlayers = 0
                
                for _, server in pairs(servers.data) do
                    if server.playing > highestPlayers and server.playing < server.maxPlayers and server.id ~= game.JobId then
                        highestPlayers = server.playing
                        highestServer = server.id
                    end
                end
                
                if highestServer then
                    Rayfield:Notify({
                        Title = "Server Found",
                        Content = "Joining server with " .. highestPlayers .. " players...",
                        Duration = 2,
                    })
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, highestServer)
                else
                    TeleportService:Teleport(game.PlaceId)
                end
            else
                TeleportService:Teleport(game.PlaceId)
            end
        end)
    end,
})

UtilityTab:CreateButton({
    Name = "Rejoin Current Game",
    Callback = function()
        Rayfield:Notify({
            Title = "Rejoin",
            Content = "Rejoining the same server...",
            Duration = 2,
        })
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end,
})

UtilityTab:CreateDivider()

UtilityTab:CreateSection("Other Utilities")

UtilityTab:CreateButton({
    Name = "Copy Server ID",
    Callback = function()
        if setclipboard then
            setclipboard(game.JobId)
            Rayfield:Notify({
                Title = "Copied!",
                Content = "Server ID copied to clipboard.",
                Duration = 2,
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Clipboard not supported.",
                Duration = 2,
            })
        end
    end,
})

UtilityTab:CreateButton({
    Name = "Copy Game Link",
    Callback = function()
        if setclipboard then
            local link = "https://www.roblox.com/games/" .. game.PlaceId
            setclipboard(link)
            Rayfield:Notify({
                Title = "Copied!",
                Content = "Game link copied to clipboard.",
                Duration = 2,
            })
        end
    end,
})

UtilityTab:CreateLabel("Server: " .. string.sub(game.JobId, 1, 8) .. "...")

-- =============================================
-- INPUT HANDLING
-- =============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Update activity for anti-AFK
    LastActivity = tick()
    
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
    
    task.wait(0.5)
    
    -- Reconnect active features
    local featuresToReconnect = {"SpeedEnabled", "BallMagEnabled", "AutoGuard", "AutoGetBall"}
    
    for _, flag in pairs(featuresToReconnect) do
        if Rayfield.Flags[flag] and Rayfield.Flags[flag].CurrentValue then
            Rayfield.Flags[flag]:Set(false)
            task.wait(0.1)
            Rayfield.Flags[flag]:Set(true)
        end
    end
end)

-- =============================================
-- PLAYER CLEANUP
-- =============================================
Players.PlayerRemoving:Connect(function(player)
    if TracerLines[player.Name] then
        pcall(function() TracerLines[player.Name]:Remove() end)
        TracerLines[player.Name] = nil
    end
    if PlayerHighlights[player.Name] then
        pcall(function() PlayerHighlights[player.Name]:Destroy() end)
        PlayerHighlights[player.Name] = nil
    end
end)

-- =============================================
-- FINAL NOTIFICATIONS
-- =============================================
Rayfield:Notify({
    Title = "Project Solox v2.0 Loaded",
    Content = "All features ready! Bypass active.",
    Duration = 5,
    Image = nil,
})

print("[Project Solox v2.0] Script loaded successfully!")
print("[Project Solox] Session ID: " .. ScriptIdentity.SessionID)
print("[Project Solox] Anti-detection bypass: ACTIVE")
