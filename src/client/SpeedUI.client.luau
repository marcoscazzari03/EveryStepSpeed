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

local previousSteps = steps.Value

-- =========================================================
-- BARRA PRINCIPALE IN BASSO
-- =========================================================

local root = Instance.new("Frame")
root.Name = "Root"
root.AnchorPoint = Vector2.new(0.5, 1)

-- 0.96 = quasi in fondo allo schermo
root.Position = UDim2.fromScale(0.5, 0.96)

root.Size = UDim2.fromOffset(860, 100)
root.BackgroundTransparency = 1
root.Parent = screenGui

-- Box bianco
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

-- =========================================================
-- SCARPA A SINISTRA
-- =========================================================

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

-- =========================================================
-- LIVELLO
-- =========================================================

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

-- =========================================================
-- EXP
-- =========================================================

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

-- =========================================================
-- AREA INVISIBILE DEI +1
-- =========================================================

local popupArea = Instance.new("Frame")
popupArea.Name = "PopupArea"
popupArea.AnchorPoint = Vector2.new(0.5, 1)

-- Subito sopra la barra principale
popupArea.Position = UDim2.fromScale(0.5, 0.84)

popupArea.Size = UDim2.fromOffset(900, 140)
popupArea.BackgroundTransparency = 1
popupArea.BorderSizePixel = 0
popupArea.Parent = screenGui

-- =========================================================
-- TESTO EXP
-- =========================================================

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

-- =========================================================
-- AGGIORNAMENTO UI
-- =========================================================

local function updateMainUI()
	levelLabel.Text =
		"Livello: " .. tostring(speed.Value)

	expLabel.Text =
		getCurrentExpText()
end

-- =========================================================
-- POPUP 👟 +1
-- =========================================================

local function createStepPopup()
	local popup = Instance.new("TextLabel")
	popup.Name = "StepPopup"

	popup.AnchorPoint = Vector2.new(0.5, 0.5)

	-- Posizione casuale nell'area sopra la barra
	local randomX = math.random(80, 820)
	local randomY = math.random(45, 115)

	popup.Position =
		UDim2.fromOffset(randomX, randomY)

	popup.Size =
		UDim2.fromOffset(110, 40)

	popup.BackgroundTransparency = 1

	popup.Font = Enum.Font.Cartoon

	popup.Text = "👟 +1"

	popup.TextScaled = true

	popup.TextColor3 =
		Color3.fromRGB(100, 200, 255)

	popup.TextStrokeColor3 =
		Color3.fromRGB(0, 0, 0)

	popup.TextStrokeTransparency = 0

	popup.Parent = popupArea

	-- Ogni popup sale di una quantità leggermente diversa
	local moveUp =
		math.random(25, 45)

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

-- Se il server assegna più passi nello stesso frame,
-- mostriamo comunque un +1 per ogni passo.
local function showStepPopups(amount)
	for i = 1, amount do
		task.delay(
			(i - 1) * 0.035,

			function()
				createStepPopup()
			end
		)
	end
end

-- =========================================================
-- CAMBIO STEPS
-- =========================================================

local function onStepsChanged()
	local currentSteps = steps.Value

	local gained =
		currentSteps - previousSteps

	updateMainUI()

	if gained > 0 then
		showStepPopups(gained)
	end

	previousSteps = currentSteps
end

-- =========================================================
-- CAMBIO LIVELLO
-- =========================================================

local function onSpeedChanged()
	updateMainUI()
end

-- Prima inizializzazione
updateMainUI()

steps:GetPropertyChangedSignal("Value")
	:Connect(onStepsChanged)

speed:GetPropertyChangedSignal("Value")
	:Connect(onSpeedChanged)