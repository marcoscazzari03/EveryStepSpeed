local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SpeedConfig = require(
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SpeedConfig")
)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local leaderstats = player:WaitForChild("leaderstats")
local speed = leaderstats:WaitForChild("Speed")

local previousLevel = speed.Value

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LevelUpUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local function showLevelUp(level)
	local levelData = SpeedConfig.Levels[level]

	if not levelData then
		return
	end

	-- Container centrale
	local container = Instance.new("Frame")
	container.Name = "LevelUpPopup"
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.fromScale(0.5, 0.42)
	container.Size = UDim2.fromOffset(430, 150)
	container.BackgroundTransparency = 1
	container.Parent = screenGui

	-- LEVEL UP!
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.Position = UDim2.fromScale(0.5, 0.35)
	title.Size = UDim2.fromOffset(400, 75)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.Cartoon
	title.Text = "LEVEL UP!"
	title.TextColor3 = Color3.fromRGB(255, 220, 70)
	title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	title.TextStrokeTransparency = 0
	title.TextScaled = true
	title.Parent = container

	-- Livello + nuova velocità
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
	subtitle.Position = UDim2.fromScale(0.5, 0.76)
	subtitle.Size = UDim2.fromOffset(360, 45)
	subtitle.BackgroundTransparency = 1
	subtitle.Font = Enum.Font.Cartoon
	subtitle.Text =
		"LV. "
		.. tostring(level)
		.. "   👟   SPEED "
		.. tostring(levelData.walkSpeed)

	subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	subtitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	subtitle.TextStrokeTransparency = 0
	subtitle.TextScaled = true
	subtitle.Parent = container

	-- Parte leggermente più piccola
	container.Size = UDim2.fromOffset(300, 105)

	local appearTween = TweenService:Create(
		container,
		TweenInfo.new(
			0.25,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Size = UDim2.fromOffset(430, 150),
		}
	)

	appearTween:Play()

	-- Rimane visibile per un momento
	task.wait(1.15)

	local titleFade = TweenService:Create(
		title,
		TweenInfo.new(0.35),
		{
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		}
	)

	local subtitleFade = TweenService:Create(
		subtitle,
		TweenInfo.new(0.35),
		{
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		}
	)

	local moveTween = TweenService:Create(
		container,
		TweenInfo.new(
			0.35,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		),
		{
			Position = UDim2.fromScale(0.5, 0.38),
		}
	)

	titleFade:Play()
	subtitleFade:Play()
	moveTween:Play()

	moveTween.Completed:Wait()

	container:Destroy()
end

speed:GetPropertyChangedSignal("Value"):Connect(function()
	local currentLevel = speed.Value

	if currentLevel > previousLevel then
		task.spawn(showLevelUp, currentLevel)
	end

	previousLevel = currentLevel
end)