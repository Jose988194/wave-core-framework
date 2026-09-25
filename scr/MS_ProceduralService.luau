--Roblox services
local ServerScriptService = game:GetService("ServerScriptService")
--My services
local EnemyCatalog = require(ServerScriptService.Modules.Shared.MS_EnemyCatalog)

local ProceduralService = {}

local CONFIG = {
	BaseBudget = 90,
	BudgetPerWave = 15,
}

local function CalculateBudget(wave)
	-- Lineal progression
	local Budget = CONFIG.BaseBudget + (wave * CONFIG.BudgetPerWave)
    return Budget
end

local function GetEnemiesForWave(wave)
	
	local enemies = EnemyCatalog:GetMetadata()
	-- Apply Unlock wave filters
	local unlocked = {}
	
	for name, enemy in pairs(enemies) do
		if enemy.unlockWave <= wave then
			unlocked[name] = enemy	
		end
	end
	return unlocked
	
end

function ProceduralService:ChooseByWeight(options)
	
	--Roulette Wheel Selection 
	local totalWeight = 0
	
	for _, selection in pairs(options) do
		totalWeight = totalWeight + selection.weight
	end
	
	local choice = math.random() * totalWeight
	local accumulatedWeight = 0
	
	for name, selection in pairs(options) do
		accumulatedWeight += selection.weight
		if choice <= accumulatedWeight then
			return name, selection
		end
	end
	
end

local function GenerateFromBudget(budget, disponibles)
	
	local composition = {}
	local total_expense = 0
	
	-- Generate until we can't afford more enemies
	while true do
		
		local affordable_enemies = {}
		
		for name, enemy in pairs(disponibles) do
			if enemy.cost <= (budget - total_expense) then
				affordable_enemies[name] = enemy
			end
		end
		
		if not next(affordable_enemies) then break end
		
		local name, enemy = ProceduralService:ChooseByWeight(affordable_enemies)
		composition[name] = (composition[name] or 0) + 1
		total_expense += enemy.cost
		
	end

	return composition
	
end

-- Main function (this is the one you'll call)
function ProceduralService:GenerateWave(wave)
	
	local WaveConfig = {}
	
	local budget = CalculateBudget(wave)
	local enemies = GetEnemiesForWave(wave)
	local composition = GenerateFromBudget(budget, enemies)

	for name, amount in pairs(composition) do
		table.insert(WaveConfig, {model = enemies[name].modelo, amount = amount})
	end
	
	return WaveConfig
	
end

return ProceduralService