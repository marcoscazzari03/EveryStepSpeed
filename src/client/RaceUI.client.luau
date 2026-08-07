local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local raceFeedbackEvent =
	ReplicatedStorage:WaitForChild("RaceFeedback")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RaceUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 30
screenGui.Parent = playerGui

local currentPopup = nil

local function destroyCurrentPopup()
	if currentPopup then
		currentPopup:Destroy()
		currentPopup = nil
	end
end

local function fadeAndDestroy(
	container,
	labels,
	delayTime
)
	task.wait(delayTime)

	if not container.Parent then
		return
	end

	for _, label in labels do
		TweenService:Create(
			label,
			TweenInfo.new(0.35),
			{
				TextTransparency = 1,
				TextStrokeTransparency = 1,
			}
		):Play()
	end

	local moveTween = TweenService:Create(
		container,
		TweenInfo.new(
			0.35,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		),
		{
			Position =
				container.Position
				- UDim2.fromScale(0, 0.05),
		}
	)

	moveTween:Play()
	moveTween.Completed:Wait()

	if currentPopup == container then
		currentPopup = nil
	end

	container:Destroy()
end

local function showCheckpointReward(
	distanceMeters,
	winsReward,
	totalWins
)
	destroyCurrentPopup()

	local container = Instance.new("Frame")
	container.Name = "CheckpointReward"
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.fromScale(0.5, 0.38)
	container.Size = UDim2.fromOffset(420, 120)
	container.BackgroundTransparency = 1
	container.Parent = screenGui

	currentPopup = container

	local rewardLabel = Instance.new("TextLabel")
	rewardLabel.BackgroundTransparency = 1
	rewardLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	rewardLabel.Position = UDim2.fromScale(0.5, 0.35)
	rewardLabel.Size = UDim2.fromOffset(390, 65)
	rewardLabel.Font = Enum.Font.Cartoon

	if winsReward == 1 then
		rewardLabel.Text = "🏆 +1 WIN"
	else
		rewardLabel.Text =
			"🏆 +" .. tostring(winsReward) .. " WINS"
	end

	rewardLabel.TextColor3 =
		Color3.fromRGB(255, 215, 70)

	rewardLabel.TextStrokeColor3 =
		Color3.fromRGB(0, 0, 0)

	rewardLabel.TextStrokeTransparency = 0
	rewardLabel.TextScaled = true
	rewardLabel.Parent = container

	local checkpointLabel = Instance.new("TextLabel")
	checkpointLabel.BackgroundTransparency = 1
	checkpointLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	checkpointLabel.Position = UDim2.fromScale(0.5, 0.78)
	checkpointLabel.Size = UDim2.fromOffset(360, 38)
	checkpointLabel.Font = Enum.Font.Cartoon
	checkpointLabel.Text =
		tostring(distanceMeters)
		.. "m CHECKPOINT  •  "
		.. tostring(totalWins)
		.. " 🏆"

	checkpointLabel.TextColor3 =
		Color3.fromRGB(255, 255, 255)

	checkpointLabel.TextStrokeColor3 =
		Color3.fromRGB(0, 0, 0)

	checkpointLabel.TextStrokeTransparency = 0
	checkpointLabel.TextScaled = true
	checkpointLabel.Parent = container

	task.spawn(
		fadeAndDestroy,
		container,
		{
			rewardLabel,
			checkpointLabel,
		},
		1.1
	)
end

local function showRunCompleted(
	distanceMeters,
	winsReward,
	totalWins,
	runReward
)
	destroyCurrentPopup()

	local container = Instance.new("Frame")
	container.Name = "RunCompleted"
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.fromScale(0.5, 0.4)
	container.Size = UDim2.fromOffset(520, 190)
	container.BackgroundTransparency = 1
	container.Parent = screenGui

	currentPopup = container

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.Position = UDim2.fromScale(0.5, 0.22)
	title.Size = UDim2.fromOffset(500, 70)
	title.Font = Enum.Font.Cartoon
	title.Text = "🏁 RUN COMPLETATA!"
	title.TextColor3 =
		Color3.fromRGB(100, 255, 130)
	title.TextStrokeColor3 =
		Color3.fromRGB(0, 0, 0)
	title.TextStrokeTransparency = 0
	title.TextScaled = true
	title.Parent = container

	local reward = Instance.new("TextLabel")
	reward.BackgroundTransparency = 1
	reward.AnchorPoint = Vector2.new(0.5, 0.5)
	reward.Position = UDim2.fromScale(0.5, 0.55)
	reward.Size = UDim2.fromOffset(430, 55)
	reward.Font = Enum.Font.Cartoon

	reward.Text =
		"🏆 +"
		.. tostring(winsReward)
		.. " WINS"

	reward.TextColor3 =
		Color3.fromRGB(255, 215, 70)

	reward.TextStrokeColor3 =
		Color3.fromRGB(0, 0, 0)

	reward.TextStrokeTransparency = 0
	reward.TextScaled = true
	reward.Parent = container

	local info = Instance.new("TextLabel")
	info.BackgroundTransparency = 1
	info.AnchorPoint = Vector2.new(0.5, 0.5)
	info.Position = UDim2.fromScale(0.5, 0.82)
	info.Size = UDim2.fromOffset(470, 38)
	info.Font = Enum.Font.Cartoon

	info.Text =
		tostring(distanceMeters)
		.. "m  •  RUN TOTAL: "
		.. tostring(runReward)
		.. " 🏆  •  TOTAL: "
		.. tostring(totalWins)

	info.TextColor3 =
		Color3.fromRGB(255, 255, 255)

	info.TextStrokeColor3 =
		Color3.fromRGB(0, 0, 0)

	info.TextStrokeTransparency = 0
	info.TextScaled = true
	info.Parent = container

	container.Size =
		UDim2.fromOffset(380, 140)

	TweenService:Create(
		container,
		TweenInfo.new(
			0.3,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Size =
				UDim2.fromOffset(520, 190),
		}
	):Play()

	task.spawn(
		fadeAndDestroy,
		container,
		{
			title,
			reward,
			info,
		},
		2
	)
end

raceFeedbackEvent.OnClientEvent:Connect(
	function(eventType, ...)
		if eventType == "checkpoint" then
			local checkpointId,
				distanceMeters,
				winsReward,
				totalWins = ...

			showCheckpointReward(
				distanceMeters,
				winsReward,
				totalWins
			)

		elseif eventType == "completed" then
			local distanceMeters,
				winsReward,
				totalWins,
				runReward = ...

			showRunCompleted(
				distanceMeters,
				winsReward,
				totalWins,
				runReward
			)
		end
	end
)