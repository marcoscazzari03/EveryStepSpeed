local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SpeedConfig = require(
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SpeedConfig")
)

local SPEED_LEVELS = SpeedConfig.Levels

local STUDS_PER_STEP = 2

local playerData = {}

local function applySpeed(player)
	local leaderstats = player:FindFirstChild("leaderstats")

	if not leaderstats then
		return
	end

	local speed = leaderstats:FindFirstChild("Speed")

	if not speed then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local levelData = SPEED_LEVELS[speed.Value]

	if not levelData then
		return
	end

	humanoid.WalkSpeed = levelData.walkSpeed
end

local function updateSpeedLevel(player)
	local leaderstats = player:FindFirstChild("leaderstats")

	if not leaderstats then
		return
	end

	local steps = leaderstats:FindFirstChild("Steps")
	local speed = leaderstats:FindFirstChild("Speed")

	if not steps or not speed then
		return
	end

	local newLevel =
		SpeedConfig.getLevelFromSteps(steps.Value)

	if speed.Value ~= newLevel then
		speed.Value = newLevel
		applySpeed(player)
	end
end

local function setupCharacter(player, character)
	local humanoid =
		character:WaitForChild("Humanoid")

	local rootPart =
		character:WaitForChild("HumanoidRootPart")

	local leaderstats =
		player:WaitForChild("leaderstats")

	local speed =
		leaderstats:WaitForChild("Speed")

	local levelData =
		SPEED_LEVELS[speed.Value]

	if levelData then
		humanoid.WalkSpeed = levelData.walkSpeed
	end

	local data = playerData[player]

	if not data then
		return
	end

	data.lastPosition = rootPart.Position
	data.distanceBuffer = 0
end

local function setupPlayer(player)
	local leaderstats =
		player:WaitForChild("leaderstats")

	local steps =
		leaderstats:WaitForChild("Steps")

	local speed =
		leaderstats:FindFirstChild("Speed")

	if not speed then
		speed = Instance.new("IntValue")
		speed.Name = "Speed"
		speed.Parent = leaderstats
	end

	speed.Value =
		SpeedConfig.getLevelFromSteps(steps.Value)

	playerData[player] = {
		lastPosition = nil,
		distanceBuffer = 0,
	}

	player.CharacterAdded:Connect(function(character)
		setupCharacter(player, character)
	end)

	if player.Character then
		task.spawn(
			setupCharacter,
			player,
			player.Character
		)
	end
end

local function removePlayer(player)
	playerData[player] = nil
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(removePlayer)

for _, player in Players:GetPlayers() do
	task.spawn(setupPlayer, player)
end

RunService.Heartbeat:Connect(function()
	for player, data in pairs(playerData) do
		local character = player.Character

		if not character then
			continue
		end

		local humanoid =
			character:FindFirstChild("Humanoid")

		local rootPart =
			character:FindFirstChild("HumanoidRootPart")

		local leaderstats =
			player:FindFirstChild("leaderstats")

		if not humanoid or not rootPart or not leaderstats then
			continue
		end

		local steps =
			leaderstats:FindFirstChild("Steps")

		if not steps then
			continue
		end

		if data.lastPosition then
			local oldPosition = Vector3.new(
				data.lastPosition.X,
				0,
				data.lastPosition.Z
			)

			local newPosition = Vector3.new(
				rootPart.Position.X,
				0,
				rootPart.Position.Z
			)

			local distance =
				(newPosition - oldPosition).Magnitude

			if distance < 10 then
				data.distanceBuffer += distance

				local stepsGained = math.floor(
					data.distanceBuffer / STUDS_PER_STEP
				)

				if stepsGained > 0 then
					data.distanceBuffer -=
						stepsGained * STUDS_PER_STEP

					steps.Value += stepsGained

					updateSpeedLevel(player)
				end
			end
		end

		data.lastPosition = rootPart.Position
	end
end)