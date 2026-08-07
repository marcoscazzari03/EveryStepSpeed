local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RaceConfig = require(
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RaceConfig")
)

local CHECKPOINT_TAG = "RaceCheckpoint"
local REMOTE_EVENT_NAME = "RaceFeedback"

local TELEPORT_DELAY = 2.5

local claimingCheckpoint = {}

local raceFeedbackEvent =
	ReplicatedStorage:FindFirstChild(REMOTE_EVENT_NAME)

if not raceFeedbackEvent then
	raceFeedbackEvent = Instance.new("RemoteEvent")
	raceFeedbackEvent.Name = REMOTE_EVENT_NAME
	raceFeedbackEvent.Parent = ReplicatedStorage
end

local function getPlayerFromHit(hit)
	local character =
		hit:FindFirstAncestorOfClass("Model")

	if not character then
		return nil
	end

	return Players:GetPlayerFromCharacter(character)
end

local function getRaceData(player)
	local dataFolder =
		player:FindFirstChild("PlayerData")

	if not dataFolder then
		return nil
	end

	local wins =
		dataFolder:FindFirstChild("Wins")

	local currentCheckpoint =
		dataFolder:FindFirstChild("CurrentCheckpoint")

	if not wins or not currentCheckpoint then
		return nil
	end

	return wins, currentCheckpoint
end

local function getRaceStart()
	local raceStart =
		workspace:FindFirstChild(
			RaceConfig.RACE_START_NAME,
			true
		)

	if not raceStart or not raceStart:IsA("BasePart") then
		return nil
	end

	return raceStart
end

local function teleportToRaceStart(player)
	local character = player.Character

	if not character then
		return
	end

	local rootPart =
		character:FindFirstChild("HumanoidRootPart")

	if not rootPart then
		return
	end

	local raceStart = getRaceStart()

	if not raceStart then
		warn(
			"RaceStart non trovato nel Workspace."
		)

		return
	end

	rootPart.CFrame =
		raceStart.CFrame + Vector3.new(0, 4, 0)
end

local function completeRun(
	player,
	finalCheckpointData,
	wins,
	currentCheckpoint
)
	local runReward =
		RaceConfig.getRunReward(
			RaceConfig.FINISH_CHECKPOINT
		)

	-- Resettiamo subito lo stato della run.
	-- Steps, Speed e Wins NON vengono toccati.
	currentCheckpoint.Value = 0

	raceFeedbackEvent:FireClient(
		player,
		"completed",
		finalCheckpointData.distanceMeters,
		finalCheckpointData.winsReward,
		wins.Value,
		runReward
	)

	task.delay(TELEPORT_DELAY, function()
		if not player.Parent then
			return
		end

		teleportToRaceStart(player)
	end)
end

local function claimCheckpoint(player, checkpointId)
	if claimingCheckpoint[player] then
		return
	end

	claimingCheckpoint[player] = true

	local success, errorMessage = pcall(function()
		local checkpointData =
			RaceConfig.getCheckpoint(checkpointId)

		if not checkpointData then
			return
		end

		local wins, currentCheckpoint =
			getRaceData(player)

		if not wins or not currentCheckpoint then
			return
		end

		-- Già ottenuto durante questa run
		if checkpointId <= currentCheckpoint.Value then
			return
		end

		-- Devi attraversare i checkpoint in ordine.
		local nextCheckpoint =
			currentCheckpoint.Value + 1

		if checkpointId ~= nextCheckpoint then
			return
		end

		-- Assegna il premio
		wins.Value += checkpointData.winsReward
		currentCheckpoint.Value = checkpointId

		-- TRAGUARDO
		if checkpointId == RaceConfig.FINISH_CHECKPOINT then
			completeRun(
				player,
				checkpointData,
				wins,
				currentCheckpoint
			)

			return
		end

		-- Checkpoint normale
		raceFeedbackEvent:FireClient(
			player,
			"checkpoint",
			checkpointId,
			checkpointData.distanceMeters,
			checkpointData.winsReward,
			wins.Value
		)
	end)

	claimingCheckpoint[player] = nil

	if not success then
		warn(
			"Errore checkpoint per "
				.. player.Name
				.. ": "
				.. tostring(errorMessage)
		)
	end
end

local function connectCheckpoint(checkpoint)
	if not checkpoint:IsA("BasePart") then
		warn(
			"RaceCheckpoint deve essere una BasePart: "
				.. checkpoint:GetFullName()
		)

		return
	end

	checkpoint.Touched:Connect(function(hit)
		local player = getPlayerFromHit(hit)

		if not player then
			return
		end

		local checkpointId =
			checkpoint:GetAttribute("CheckpointId")

		if type(checkpointId) ~= "number" then
			warn(
				"CheckpointId mancante su "
					.. checkpoint:GetFullName()
			)

			return
		end

		checkpointId = math.floor(checkpointId)

		claimCheckpoint(
			player,
			checkpointId
		)
	end)
end

for _, checkpoint in
	CollectionService:GetTagged(CHECKPOINT_TAG)
do
	connectCheckpoint(checkpoint)
end

CollectionService:GetInstanceAddedSignal(CHECKPOINT_TAG)
	:Connect(connectCheckpoint)

Players.PlayerRemoving:Connect(function(player)
	claimingCheckpoint[player] = nil
end)