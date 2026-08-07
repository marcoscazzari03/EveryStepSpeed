local SpeedConfig = {}

SpeedConfig.Levels = {
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

function SpeedConfig.getLevelFromSteps(steps)
	local currentLevel = 1

	for level, levelData in ipairs(SpeedConfig.Levels) do
		if steps >= levelData.stepsRequired then
			currentLevel = level
		else
			break
		end
	end

	return currentLevel
end

return SpeedConfig