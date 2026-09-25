--Roblox Services
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Collections = game:GetService("CollectionService")
--My services
local EnemyAI = require(ServerScriptService.Modules.EnemySystem.MS_EnemyIA)
local Values = game:GetService("ReplicatedStorage"):WaitForChild("Valores")
--SpawnPoints
local SpawnEnemies = ServerStorage:WaitForChild("SpawnsFolder")
local SpawnPoints = SpawnEnemies:GetChildren()

local EnemyService = {}

function EnemyService:SpawnEnemy(enemy_type, amount)

	for i = 1, amount do		
		
		if Values.Estado.Value ~= "playing" then return end

		local randomSpawn = SpawnPoints[math.random(1, #SpawnPoints)]
		
		local newEnemy = enemy_type:Clone()
		Collections:AddTag(newEnemy, "Enemy")
		
		newEnemy:PivotTo(randomSpawn.CFrame)
		newEnemy.Parent = workspace.Enemigos
		
		task.spawn(function()
			EnemyAI:BasicIA(newEnemy)
		end)
		
		task.wait(0.5)
	end
	
end

return EnemyService
