--Roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--Folders
local WaveSystemFolder = ServerScriptService.Modules.WaveSystem
local Enemigos = workspace:WaitForChild("Enemigos")
--My services
local EnemyService = require(WaveSystemFolder.MS_E_SpawnService)
local WaveService = require(WaveSystemFolder.MS_WaveService)
local ProceduralService = require(WaveSystemFolder.MS_ProceduralService)
local LevelState = require(WaveSystemFolder.MS_LevelState)

--Values
local Values = ReplicatedStorage:WaitForChild("Valores")
local State = Values:WaitForChild("Estado")
local CurrentWave = Values:WaitForChild("WaveActual")
local TotalWaves = Values:WaitForChild("WavesTotales")

CurrentWave.Changed:Connect(function()
	
	if State.Value ~= "playing" or CurrentWave.Value < 1 then return end
	local Wave = CurrentWave.Value
	local WaveConfig = ProceduralService:GenerateWave(Wave)
	
	for _, Entry in WaveConfig do
		if State.Value ~= "playing" then break end
		EnemyService:SpawnEnemy(Entry.model, Entry.amount)
	end

	if Wave == TotalWaves.Value then
		repeat
			task.wait(0.1)
		until State.Value ~= "playing" or #Enemigos:GetChildren() == 0
		
		if State.Value == "playing" then LevelState:WinLevel() end
	end
	
end)

local function Iniciar()
	if State.Value == "playing" then
		task.spawn(function() WaveService:StartWaves(TotalWaves.Value) end)
	end
end
State.Changed:Connect(Iniciar)
Iniciar()
