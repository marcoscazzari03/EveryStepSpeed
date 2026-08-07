local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SpeedConfig = require(
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SpeedConfig")
)

local SPEED_LEVELS = SpeedConfig.Levels
local MAX_LEVEL = #SPEED_LEVELS

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local leaderstats = player:WaitForChild("leaderstats")
local speed = leaderstats:WaitForChild("Speed")
local steps = leaderstats:WaitForChild("Steps")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local previousSteps = steps.Value

-- BARRA PRINCIPALE IN BASSO

local root = Instance.new("Frame")
root.Name = "Root"
root.AnchorPoint = Vector2.new(0.5, 1)
root.Position = UDim2.fromScale(0.5, 0.96)
root.Size = UDim2.fromOffset(860, 100)
root.BackgroundTransparency = 1
root.Parent = screenGui

local topBox = Instance.new("Frame")
topBox.Name = "TopBox"
topBox.Position = UDim2.fromOffset(40, 0)
topBox.Size = UDim2.fromOffset(800, 72)
topBox.BackgroundColor3 = Color3.fromRGB(244, 244, 255)
topBox.BorderSizePixel = 0
topBox.Parent = root

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 18)
topCorner.Parent = topBox

local topStroke = Instance.new("UIStroke")
topStroke.Thickness = 5
topStroke.Color = Color3.fromRGB(0, 0, 0)
topStroke.Parent = topBox

-- SCARPA

local iconHolder = Instance.new("Frame")
iconHolder.Name = "IconHolder"
iconHolder.AnchorPoint = Vector2.new(0, 0.5)
iconHolder.Position = UDim2.fromOffset(-8, 36)
iconHolder.Size = UDim2.fromOffset(92, 92)
iconHolder.BackgroundTransparency = 1
iconHolder.Parent = root

local shoeIcon = Instance.new("TextLabel")
shoeIcon.Name = "ShoeIcon"
shoeIcon.BackgroundTransparency = 1
shoeIcon.Size = UDim2.fromScale(1, 1)
shoeIcon.Font = Enum.Font.Cartoon
shoeIcon.Text = "👟"
shoeIcon.TextScaled = true
shoeIcon.TextColor3 = Color3.fromRGB(70, 150, 255)
shoeIcon.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
shoeIcon.TextStrokeTransparency = 0
shoeIcon.Parent = iconHolder

-- LIVELLO

local levelLabel = Instance.new("TextLabel")
levelLabel.Name = "LevelLabel"
levelLabel.BackgroundTransparency = 1
levelLabel.Position = UDim2.fromOffset(92, 11)
levelLabel.Size = UDim2.fromOffset(320, 50)
levelLabel.Font = Enum.Font.Cartoon
levelLabel.TextXAlignment = Enum.TextXAlignment.Left
levelLabel.TextYAlignment = Enum.TextYAlignment.Center
levelLabel.TextScaled = true
levelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
levelLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
levelLabel.TextStrokeTransparency = 0
levelLabel.Parent = topBox

-- EXP

local expLabel = Instance.new("TextLabel")
expLabel.Name = "ExpLabel"
expLabel.BackgroundTransparency = 1
expLabel.AnchorPoint = Vector2.new(1, 0)
expLabel.Position = UDim2.fromOffset(780, 11)
expLabel.Size = UDim2.fromOffset(300, 50)
expLabel.Font = Enum.Font.Cartoon
expLabel.TextXAlignment = Enum.TextXAlignment.Right
expLabel.TextYAlignment = Enum.TextYAlignment.Center
expLabel.TextScaled = true
expLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
expLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
expLabel.TextStrokeTransparency = 0
expLabel.Parent = topBox

-- AREA POPUP +1

local popupArea = Instance.new("Frame")
popupArea.Name = "PopupArea"
popupArea.AnchorPoint = Vector2.new(0.5, 1)
popupArea.Position = UDim2.fromScale(0.5, 0.84)
popupArea.Size = UDim2.fromOffset(900, 140)
popupArea.BackgroundTransparency = 1
popupArea.BorderSizePixel = 0
popupArea.Parent = screenGui

local function getCurrentExpText()
	local currentLevel = speed.Value
	local currentSteps = steps.Value

	if currentLevel >= MAX_LEVEL then
		return "EXP: MAX"
	end

	local currentLevelSteps =
		SPEED_LEVELS[currentLevel].stepsRequired

	local nextLevelSteps =
		SPEED_LEVELS[currentLevel + 1].stepsRequired

	local stepsIntoLevel =
		currentSteps - currentLevelSteps

	local stepsNeeded =
		nextLevelSteps - currentLevelSteps

	return "EXP: "
		.. tostring(stepsIntoLevel)
		.. " / "
		.. tostring(stepsNeeded)
end

local function updateMainUI()
	levelLabel.Text =
		"Livello: " .. tostring(speed.Value)

	expLabel.Text =
		getCurrentExpText()
end

local function createStepPopup()
	local popup = Instance.new("TextLabel")
	popup.Name = "StepPopup"
	popup.AnchorPoint = Vector2.new(0.5, 0.5)

	local randomX = math.random(80, 820)
	local randomY = math.random(45, 115)

	popup.Position = UDim2.fromOffset(randomX, randomY)
	popup.Size = UDim2.fromOffset(110, 40)
	popup.BackgroundTransparency = 1
	popup.Font = Enum.Font.Cartoon
	popup.Text = "👟 +1"
	popup.TextScaled = true
	popup.TextColor3 = Color3.fromRGB(100, 200, 255)
	popup.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	popup.TextStrokeTransparency = 0
	popup.Parent = popupArea

	local moveUp = math.random(25, 45)

	local tween = TweenService:Create(
		popup,
		TweenInfo.new(
			0.6,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Position = UDim2.fromOffset(
				randomX,
				randomY - moveUp
			),
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		}
	)

	tween:Play()

	tween.Completed:Connect(function()
		popup:Destroy()
	end)
end

local function showStepPopups(amount)
	for i = 1, amount do
		task.delay((i - 1) * 0.035, function()
			createStepPopup()
		end)
	end
end

local function onStepsChanged()
	local currentSteps = steps.Value
	local gained = currentSteps - previousSteps

	updateMainUI()

	if gained > 0 then
		showStepPopups(gained)
	end

	previousSteps = currentSteps
end

local function onSpeedChanged()
	updateMainUI()
end

updateMainUI()

steps:GetPropertyChangedSignal("Value")
	:Connect(onStepsChanged)

speed:GetPropertyChangedSignal("Value")
	:Connect(onSpeedChanged)