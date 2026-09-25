--Roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--Folders
local Enemies = workspace:WaitForChild("Enemigos")
local Valores = ReplicatedStorage:WaitForChild("Valores")
--Values
local CurrentState = Valores:WaitForChild("Estado")
local CurrentWave = Valores:WaitForChild("WaveActual")
local AutoSkip = Valores:WaitForChild("AutoSkip")


local WaveService = {}
local started = false

function WaveService:StartWaves(waves_amount)
	
	if started or CurrentState.Value ~= "playing" then return end
	started = true
	waves_amount = waves_amount or math.huge
	CurrentWave.Value = 0

	while CurrentState.Value == "playing" and CurrentWave.Value < waves_amount do
		repeat
			task.wait(0.1)
		until CurrentState.Value ~= "playing" or AutoSkip.Value or #Enemies:GetChildren() == 0
		if CurrentState.Value ~= "playing" then break end

		task.wait(3)
		if CurrentState.Value ~= "playing" then break end
		CurrentWave.Value += 1
	end
	
end

return WaveService
