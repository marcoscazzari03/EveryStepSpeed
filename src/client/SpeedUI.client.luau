local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local leaderstats = player:WaitForChild("leaderstats")
local speed = leaderstats:WaitForChild("Speed")
local steps = leaderstats:WaitForChild("Steps")

local SPEED_LEVELS = {
	{ stepsRequired = 0 },
	{ stepsRequired = 100 },
	{ stepsRequired = 300 },
	{ stepsRequired = 700 },
	{ stepsRequired = 1500 },
	{ stepsRequired = 3000 },
	{ stepsRequired = 6000 },
	{ stepsRequired = 12000 },
	{ stepsRequired = 25000 },
	{ stepsRequired = 50000 },
}

local MAX_LEVEL = #SPEED_LEVELS

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Container principale
local container = Instance.new("Frame")
container.Name = "SpeedContainer"
container.AnchorPoint = Vector2.new(0.5, 0)
container.Position = UDim2.fromScale(0.5, 0.04)
container.Size = UDim2.fromOffset(300, 120)
container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
container.BackgroundTransparency = 0.15
container.BorderSizePixel = 0
container.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = container

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Transparency = 0.45
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Parent = container

-- Titolo
local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(0, 8)
title.Size = UDim2.new(1, 0, 0, 18)
title.Font = Enum.Font.GothamMedium
title.Text = "SPEED"
title.TextColor3 = Color3.fromRGB(180, 180, 180)
title.TextSize = 13
title.Parent = container

-- Livello
local levelLabel = Instance.new("TextLabel")
levelLabel.Name = "Level"
levelLabel.BackgroundTransparency = 1
levelLabel.Position = UDim2.fromOffset(0, 26)
levelLabel.Size = UDim2.new(1, 0, 0, 32)
levelLabel.Font = Enum.Font.GothamBold
levelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
levelLabel.TextSize = 27
levelLabel.Parent = container

-- Sfondo barra
local progressBackground = Instance.new("Frame")
progressBackground.Name = "ProgressBackground"
progressBackground.Position = UDim2.fromOffset(20, 69)
progressBackground.Size = UDim2.new(1, -40, 0, 14)
progressBackground.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
progressBackground.BorderSizePixel = 0
progressBackground.ClipsDescendants = true
progressBackground.Parent = container

local progressBackgroundCorner = Instance.new("UICorner")
progressBackgroundCorner.CornerRadius = UDim.new(1, 0)
progressBackgroundCorner.Parent = progressBackground

-- Riempimento barra
local progressFill = Instance.new("Frame")
progressFill.Name = "ProgressFill"
progressFill.Size = UDim2.fromScale(0, 1)
progressFill.BackgroundColor3 = Color3.fromRGB(100, 255, 130)
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBackground

local progressFillCorner = Instance.new("UICorner")
progressFillCorner.CornerRadius = UDim.new(1, 0)
progressFillCorner.Parent = progressFill

-- Testo progresso
local progressLabel = Instance.new("TextLabel")
progressLabel.Name = "ProgressText"
progressLabel.BackgroundTransparency = 1
progressLabel.Position = UDim2.fromOffset(20, 88)
progressLabel.Size = UDim2.new(1, -40, 0, 20)
progressLabel.Font = Enum.Font.GothamMedium
progressLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
progressLabel.TextSize = 13
progressLabel.Parent = container

local previousSpeed = speed.Value

local progressTween

local function showSpeedGain()
	local gainLabel = Instance.new("TextLabel")
	gainLabel.Name = "SpeedGain"
	gainLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	gainLabel.Position = UDim2.fromScale(0.5, 0.21)
	gainLabel.Size = UDim2.fromOffset(120, 40)
	gainLabel.BackgroundTransparency = 1
	gainLabel.Font = Enum.Font.GothamBold
	gainLabel.Text = "+1"
	gainLabel.TextColor3 = Color3.fromRGB(100, 255, 130)
	gainLabel.TextSize = 24
	gainLabel.TextTransparency = 0
	gainLabel.Parent = screenGui

	local tween = TweenService:Create(
		gainLabel,
		TweenInfo.new(
			0.6,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Position = UDim2.fromScale(0.5, 0.16),
			TextTransparency = 1,
		}
	)

	tween:Play()

	tween.Completed:Connect(function()
		gainLabel:Destroy()
	end)
end

local function updateUI()
	local currentLevel = speed.Value
	local currentSteps = steps.Value

	levelLabel.Text = "LV. " .. tostring(currentLevel)

	-- Livello massimo
	if currentLevel >= MAX_LEVEL then
		progressLabel.Text = "MAX LEVEL"

		if progressTween then
			progressTween:Cancel()
		end

		progressTween = TweenService:Create(
			progressFill,
			TweenInfo.new(0.2),
			{
				Size = UDim2.fromScale(1, 1),
			}
		)

		progressTween:Play()

		return
	end

	local currentLevelSteps = SPEED_LEVELS[currentLevel].stepsRequired
	local nextLevelSteps = SPEED_LEVELS[currentLevel + 1].stepsRequired

	local stepsIntoLevel = currentSteps - currentLevelSteps
	local stepsNeeded = nextLevelSteps - currentLevelSteps

	local progress = stepsIntoLevel / stepsNeeded
	progress = math.clamp(progress, 0, 1)

	progressLabel.Text =
		tostring(stepsIntoLevel)
		.. " / "
		.. tostring(stepsNeeded)
		.. " STEPS"

	if progressTween then
		progressTween:Cancel()
	end

	progressTween = TweenService:Create(
		progressFill,
		TweenInfo.new(
			0.15,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Size = UDim2.fromScale(progress, 1),
		}
	)

	progressTween:Play()

	-- Mostriamo +1 soltanto quando cambia realmente livello Speed
	if currentLevel > previousSpeed then
		showSpeedGain()
	end

	previousSpeed = currentLevel
end

updateUI()

steps:GetPropertyChangedSignal("Value"):Connect(updateUI)
speed:GetPropertyChangedSignal("Value"):Connect(updateUI)