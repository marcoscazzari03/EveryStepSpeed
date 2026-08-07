local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local DATASTORE_NAME = "PlayerData_v4"
local AUTOSAVE_INTERVAL = 60
local MAX_RETRIES = 3

local playerDataStore = DataStoreService:GetDataStore(DATASTORE_NAME)

local DEFAULT_DATA = {
	steps = 0,
	wins = 0,
	currentCheckpoint = 0,
}

local function sanitizeNumber(value, defaultValue)
	if type(value) ~= "number" then
		return defaultValue
	end

	return math.max(0, math.floor(value))
end

local function loadData(player)
	for attempt = 1, MAX_RETRIES do
		local success, savedData = pcall(function()
			return playerDataStore:GetAsync(player.UserId)
		end)

		if success then
			if type(savedData) ~= "table" then
				savedData = {}
			end

			return {
				steps = sanitizeNumber(
					savedData.steps,
					DEFAULT_DATA.steps
				),

				wins = sanitizeNumber(
					savedData.wins,
					DEFAULT_DATA.wins
				),

				currentCheckpoint = sanitizeNumber(
					savedData.currentCheckpoint,
					DEFAULT_DATA.currentCheckpoint
				),
			}
		end

		warn(
			"Errore caricamento dati per "
				.. player.Name
				.. " (tentativo "
				.. tostring(attempt)
				.. "/"
				.. tostring(MAX_RETRIES)
				.. ")"
		)

		if attempt < MAX_RETRIES then
			task.wait(1)
		end
	end

	warn(
		"Impossibile caricare i dati di "
			.. player.Name
			.. ". Uso valori predefiniti."
	)

	return {
		steps = DEFAULT_DATA.steps,
		wins = DEFAULT_DATA.wins,
		currentCheckpoint = DEFAULT_DATA.currentCheckpoint,
	}
end

local function createIntValue(parent, name, value)
	local existing = parent:FindFirstChild(name)

	if existing and existing:IsA("IntValue") then
		existing.Value = value
		return existing
	end

	local intValue = Instance.new("IntValue")
	intValue.Name = name
	intValue.Value = value
	intValue.Parent = parent

	return intValue
end

local function setupPlayer(player)
	player:SetAttribute("DataLoaded", false)

	local savedData = loadData(player)

	-- Statistiche visibili nella leaderboard
	local leaderstats = player:FindFirstChild("leaderstats")

	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	createIntValue(
		leaderstats,
		"Steps",
		savedData.steps
	)

	-- Dati persistenti che non vogliamo ancora mostrare
	-- nella leaderboard.
	local dataFolder = player:FindFirstChild("PlayerData")

	if not dataFolder then
		dataFolder = Instance.new("Folder")
		dataFolder.Name = "PlayerData"
		dataFolder.Parent = player
	end

	createIntValue(
		dataFolder,
		"Wins",
		savedData.wins
	)

createIntValue(
	dataFolder,
	"CurrentCheckpoint",
	savedData.currentCheckpoint
)

	player:SetAttribute("DataLoaded", true)
end

local function savePlayer(player)
	if not player:GetAttribute("DataLoaded") then
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local dataFolder = player:FindFirstChild("PlayerData")

	if not leaderstats or not dataFolder then
		return
	end

	local steps = leaderstats:FindFirstChild("Steps")
	local wins = dataFolder:FindFirstChild("Wins")
	local currentCheckpoint =
		dataFolder:FindFirstChild("CurrentCheckpoint")

	if not steps or not wins or not currentCheckpoint then
		return
	end

	for attempt = 1, MAX_RETRIES do
		local success, errorMessage = pcall(function()
			playerDataStore:UpdateAsync(
				player.UserId,
				function(oldData)
					if type(oldData) ~= "table" then
						oldData = {}
					end

					oldData.steps = steps.Value
					oldData.wins = wins.Value
					oldData.currentCheckpoint =
						currentCheckpoint.Value

					return oldData
				end
			)
		end)

		if success then
			return
		end

		warn(
			"Errore salvataggio dati per "
				.. player.Name
				.. " (tentativo "
				.. tostring(attempt)
				.. "/"
				.. tostring(MAX_RETRIES)
				.. "): "
				.. tostring(errorMessage)
		)

		if attempt < MAX_RETRIES then
			task.wait(1)
		end
	end
end

Players.PlayerAdded:Connect(setupPlayer)

Players.PlayerRemoving:Connect(function(player)
	savePlayer(player)
end)

-- Utile nel caso lo script parta quando ci sono già giocatori.
for _, player in Players:GetPlayers() do
	task.spawn(setupPlayer, player)
end

-- Autosave
task.spawn(function()
	while true do
		task.wait(AUTOSAVE_INTERVAL)

		for _, player in Players:GetPlayers() do
			task.spawn(savePlayer, player)
		end
	end
end)

-- Salvataggio alla chiusura del server
game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		savePlayer(player)
	end
end)