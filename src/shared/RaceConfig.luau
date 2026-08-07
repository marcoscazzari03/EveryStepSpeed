local RaceConfig = {}

RaceConfig.STUDS_PER_METER = 1

-- TEMPORANEO PER I TEST.
-- Quando costruiremo tutta la pista, diventerà 10.
RaceConfig.FINISH_CHECKPOINT = 3

RaceConfig.RACE_START_NAME = "RaceStart"

RaceConfig.Checkpoints = {
	{
		distanceMeters = 100,
		winsReward = 1,
	},
	{
		distanceMeters = 300,
		winsReward = 2,
	},
	{
		distanceMeters = 500,
		winsReward = 3,
	},
	{
		distanceMeters = 800,
		winsReward = 4,
	},
	{
		distanceMeters = 1200,
		winsReward = 5,
	},
	{
		distanceMeters = 1700,
		winsReward = 6,
	},
	{
		distanceMeters = 2300,
		winsReward = 7,
	},
	{
		distanceMeters = 3000,
		winsReward = 8,
	},
	{
		distanceMeters = 4000,
		winsReward = 9,
	},
	{
		distanceMeters = 5500,
		winsReward = 10,
	},
}

function RaceConfig.getCheckpoint(checkpointId)
	return RaceConfig.Checkpoints[checkpointId]
end

function RaceConfig.getCheckpointCount()
	return #RaceConfig.Checkpoints
end

function RaceConfig.getRunReward(finishCheckpoint)
	local totalReward = 0

	for checkpointId = 1, finishCheckpoint do
		local checkpointData = RaceConfig.Checkpoints[checkpointId]

		if checkpointData then
			totalReward += checkpointData.winsReward
		end
	end

	return totalReward
end

return RaceConfig