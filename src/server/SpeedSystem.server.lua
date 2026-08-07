local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local STUDS_PER_STEP = 2
local STARTING_WALK_SPEED = 16

local playerData = {}

local function setupPlayer(player)
	-- Statistiche visibili
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local speed = Instance.new("IntValue")
	speed.Name = "Speed"
	speed.Value = 0
	speed.Parent = leaderstats

	playerData[player] = {
		lastPosition = nil,
		distanceBuffer = 0
	}

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		local rootPart = character:WaitForChild("HumanoidRootPart")

		humanoid.WalkSpeed = STARTING_WALK_SPEED + speed.Value

		playerData[player].lastPosition = rootPart.Position
		playerData[player].distanceBuffer = 0
	end)
end

local function removePlayer(player)
	playerData[player] = nil
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(removePlayer)

RunService.Heartbeat:Connect(function()
	for player, data in pairs(playerData) do
		local character = player.Character

		if not character then
			continue
		end

		local humanoid = character:FindFirstChild("Humanoid")
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local leaderstats = player:FindFirstChild("leaderstats")

		if not humanoid or not rootPart or not leaderstats then
			continue
		end

		local speed = leaderstats:FindFirstChild("Speed")

		if not speed then
			continue
		end

		if data.lastPosition then
			-- Contiamo solo lo spostamento orizzontale
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

			local distance = (newPosition - oldPosition).Magnitude

			-- Evita di contare teletrasporti/spostamenti assurdi
			if distance < 10 then
				data.distanceBuffer += distance

				while data.distanceBuffer >= STUDS_PER_STEP do
					data.distanceBuffer -= STUDS_PER_STEP

					speed.Value += 1
					humanoid.WalkSpeed = STARTING_WALK_SPEED + speed.Value
				end
			end
		end

		data.lastPosition = rootPart.Position
	end
end)