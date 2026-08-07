local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")

local playerDataStore = DataStoreService:GetDataStore("PlayerData_v3")

local STUDS_PER_STEP = 2
local AUTOSAVE_INTERVAL = 60

local SPEED_LEVELS = {
	{
		stepsRequired = 0,
		walkSpeed = 16,
	},
	{
		stepsRequired = 100,
		walkSpeed = 18,
	},
	{
		stepsRequired = 300,
		walkSpeed = 21,
	},
	{
		stepsRequired = 700,
		walkSpeed = 24,
	},
	{
		stepsRequired = 1500,
		walkSpeed = 28,
	},
	{
		stepsRequired = 3000,
		walkSpeed = 33,
	},
	{
		stepsRequired = 6000,
		walkSpeed = 39,
	},
	{
		stepsRequired = 12000,
		walkSpeed = 46,
	},
	{
		stepsRequired = 25000,
		walkSpeed = 54,
	},
	{
		stepsRequired = 50000,
		walkSpeed = 64,
	},
}

local playerData = {}

local function getSpeedLevel(steps)
	local currentLevel = 1

	for level, levelData in ipairs(SPEED_LEVELS) do
		if steps >= levelData.stepsRequired then
			currentLevel = level
		else
			break
		end
	end

	return currentLevel
end

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

	local newLevel = getSpeedLevel(steps.Value)

	if speed.Value ~= newLevel then
		speed.Value = newLevel
		applySpeed(player)
	end
end

local function loadData(player)
	local success, savedData = pcall(function()
		return playerDataStore:GetAsync(player.UserId)
	end)

	if success and type(savedData) == "table" then
		return {
			steps = savedData.steps or 0,
		}
	end

	if not success then
		warn("Errore caricamento dati per " .. player.Name)
	end

	return {
		steps = 0,
	}
end

local function saveData(player)
	local leaderstats = player:FindFirstChild("leaderstats")

	if not leaderstats then
		return
	end

	local steps = leaderstats:FindFirstChild("Steps")

	if not steps then
		return
	end

	local dataToSave = {
		steps = steps.Value,
	}

	local success, errorMessage = pcall(function()
		playerDataStore:UpdateAsync(player.UserId, function()
			return dataToSave
		end)
	end)

	if not success then
		warn(
			"Errore salvataggio dati per "
				.. player.Name
				.. ": "
				.. tostring(errorMessage)
		)
	end
end

local function setupPlayer(player)
	local savedData = loadData(player)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local steps = Instance.new("IntValue")
	steps.Name = "Steps"
	steps.Value = savedData.steps
	steps.Parent = leaderstats

	local speed = Instance.new("IntValue")
	speed.Name = "Speed"
	speed.Value = getSpeedLevel(steps.Value)
	speed.Parent = leaderstats

	playerData[player] = {
		lastPosition = nil,
		distanceBuffer = 0,
	}

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		local rootPart = character:WaitForChild("HumanoidRootPart")

		local levelData = SPEED_LEVELS[speed.Value]

		humanoid.WalkSpeed = levelData.walkSpeed

		playerData[player].lastPosition = rootPart.Position
		playerData[player].distanceBuffer = 0
	end)
end

local function removePlayer(player)
	saveData(player)
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

		local steps = leaderstats:FindFirstChild("Steps")

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

			local distance = (newPosition - oldPosition).Magnitude

			if distance < 10 then
				data.distanceBuffer += distance

				local stepsGained = math.floor(
					data.distanceBuffer / STUDS_PER_STEP
				)

				if stepsGained > 0 then
					data.distanceBuffer -= stepsGained * STUDS_PER_STEP

					steps.Value += stepsGained

					updateSpeedLevel(player)
				end
			end
		end

		data.lastPosition = rootPart.Position
	end
end)

task.spawn(function()
	while true do
		task.wait(AUTOSAVE_INTERVAL)

		for _, player in Players:GetPlayers() do
			saveData(player)
		end
	end
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		saveData(player)
	end
end)