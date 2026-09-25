--Roblox Services
local ServerStorage = game:GetService("ServerStorage")
--Folders
local EnemiesRoot = ServerStorage:WaitForChild("Enemies")


local EnemyCatalog = {}

local _metadataCache = nil -- Cache to avoid repeated parsing

local config = {
	defaultCost = 10,
	defaultWeight = 5
}

local function analyzeFolder(name)
	
	local rules = {
		unlockWave = 1,
		cost       = config.defaultCost,
		weight     = config.defaultWeight,
		CoinReward      = 10,
	}
	
	-- Search the folder and capture all the values
	local CoinReward = name:WaitForChild("CoinReward")
	if CoinReward and CoinReward:IsA("IntValue") then rules.CoinReward = CoinReward.Value end
	
	local Cost = name:WaitForChild("Cost")
	if Cost and Cost:IsA("IntValue") then rules.cost = Cost.Value end

	local UnlockWave = name:WaitForChild("UnlockWave")
	if UnlockWave and UnlockWave:IsA("IntValue") then rules.unlockWave = UnlockWave.Value end

	local Weight = name:WaitForChild("Weight")
	if Weight and Weight:IsA("IntValue") then rules.weight = Weight.Value end
	
	if rules.cost <= 0 then
		error("Cost must be greater than 0 " .. name.Name)
	end
	
	return rules
	
end

local function BuildMetadata()
	
	if _metadataCache then return _metadataCache end
	
	local metadata = {}
	
	-- Loop through each folder in EnemiesRoot to build the metadata
	for _, folder in ipairs(EnemiesRoot:GetChildren()) do
		if folder:IsA("Folder") then
			local reglas = analyzeFolder(folder)

			-- Only one model by each folder
			local model = folder:FindFirstChildWhichIsA("Model")

			if model then
				metadata[model.Name] = {
					modelo     = model,
					cost       = reglas.cost,
					unlockWave = reglas.unlockWave,
					weight     = reglas.weight,
					CoinReward = reglas.CoinReward
				}
			else
				warn("[ProceduralGenerator] Carpeta sin modelo: " .. folder.Name)
			end
		end
	end
	_metadataCache = metadata -- Save in cache
	return metadata
end	

-- Main function (this is the one you will call)
function EnemyCatalog:GetMetadata()
	
	return BuildMetadata()
	
end


return EnemyCatalog

