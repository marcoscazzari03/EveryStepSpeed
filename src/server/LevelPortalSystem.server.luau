local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PORTAL_TAG = "LevelPortal"
local TOUCH_COOLDOWN = 1
local REMOTE_EVENT_NAME = "PortalFeedback"

local playerCooldowns = {}

-- RemoteEvent usato per comunicare con la UI del giocatore
local portalFeedbackEvent =
	ReplicatedStorage:FindFirstChild(REMOTE_EVENT_NAME)

if not portalFeedbackEvent then
	portalFeedbackEvent = Instance.new("RemoteEvent")
	portalFeedbackEvent.Name = REMOTE_EVENT_NAME
	portalFeedbackEvent.Parent = ReplicatedStorage
end

local function getPlayerFromHit(hit)
	local character = hit.Parent

	if not character then
		return nil
	end

	return Players:GetPlayerFromCharacter(character)
end

local function getPlayerLevel(player)
	local leaderstats = player:FindFirstChild("leaderstats")

	if not leaderstats then
		return nil
	end

	local speed = leaderstats:FindFirstChild("Speed")

	if not speed then
		return nil
	end

	return speed.Value
end

local function teleportPlayer(player, destination)
	local character = player.Character

	if not character then
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if not rootPart then
		return
	end

	rootPart.CFrame =
		destination.CFrame + Vector3.new(0, 4, 0)
end

local function connectPortal(portal)
	if not portal:IsA("BasePart") then
		warn(
			"LevelPortal deve essere applicato a una BasePart: "
				.. portal:GetFullName()
		)

		return
	end

	portal.Touched:Connect(function(hit)
		local player = getPlayerFromHit(hit)

		if not player then
			return
		end

		if playerCooldowns[player] then
			return
		end

		local requiredLevel =
			portal:GetAttribute("RequiredLevel")

		if type(requiredLevel) ~= "number" then
			warn(
				"RequiredLevel mancante su "
					.. portal:GetFullName()
			)

			return
		end

		local destinationName =
			portal:GetAttribute("Destination")

		if type(destinationName) ~= "string" then
			warn(
				"Destination mancante su "
					.. portal:GetFullName()
			)

			return
		end

		local destination =
			workspace:FindFirstChild(destinationName, true)

		if not destination or not destination:IsA("BasePart") then
			warn(
				"Destinazione non trovata: "
					.. destinationName
			)

			return
		end

		local playerLevel = getPlayerLevel(player)

		if not playerLevel then
			return
		end

		playerCooldowns[player] = true

		if playerLevel >= requiredLevel then
			teleportPlayer(player, destination)
		else
			portalFeedbackEvent:FireClient(
				player,
				requiredLevel
			)
		end

		task.delay(TOUCH_COOLDOWN, function()
			playerCooldowns[player] = nil
		end)
	end)
end

for _, portal in CollectionService:GetTagged(PORTAL_TAG) do
	connectPortal(portal)
end

CollectionService:GetInstanceAddedSignal(PORTAL_TAG)
	:Connect(connectPortal)

Players.PlayerRemoving:Connect(function(player)
	playerCooldowns[player] = nil
end)