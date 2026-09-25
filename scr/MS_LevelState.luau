-- Roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Folders
local PlayersFolder = workspace:WaitForChild("Jugadores")
local Values = ReplicatedStorage:WaitForChild("Valores")
-- Values
local MatchState = Values:WaitForChild("Estado")
local Victory = Values:WaitForChild("Victoria")
local ReadyPlayers = Values:WaitForChild("ReadyPlayers")
local ExpectedPlayers = Values:WaitForChild("ExpectedPlayers")


local LevelState = {}
local Records = {}
local Expected = {}
local Disconnected = {}

MatchState.Value = "waiting"
Victory.Value = false

function LevelState:CheckReady()
	if MatchState.Value ~= "waiting" then return end
	local TotalCount, ReadyCount = 0, 0

	for UserId in Expected do
		TotalCount += 1
		local Record = Records[UserId]
		if Record and Record.Ready and Record.Alive and Record.Player:GetAttribute("DataLoaded") then
			ReadyCount += 1
		end
	end

	ExpectedPlayers.Value = TotalCount
	ReadyPlayers.Value = ReadyCount

	if TotalCount > 0 and ReadyCount == TotalCount then
		MatchState.Value = "playing"
	end
end

function LevelState:AddPlayer(Player)
	if Records[Player.UserId] then return end

	local IsParticipant = MatchState.Value == "waiting"
	Records[Player.UserId] = {Player = Player, Ready = false, Alive = false, IsParticipant = IsParticipant}

	Player:SetAttribute("MatchReady", false)
	Player:SetAttribute("MatchAlive", false)
	Player:SetAttribute("MatchParticipant", IsParticipant)

	if IsParticipant then
		Expected[Player.UserId] = true
		local JoinData = Player:GetJoinData()

		if JoinData.SourceGameId == game.GameId and type(JoinData.TeleportData) == "table" then
			for Key, Data in JoinData.TeleportData do
				local UserId = tonumber(Key)
				if UserId and type(Data) == "table" and not Disconnected[UserId] then
					Expected[UserId] = true
				end
			end
		end
	end
	self:CheckReady()
end

function LevelState:SetAlive(Player, Alive)
	local Record = Records[Player.UserId]
	if not Record or not Record.IsParticipant then return end

	Record.Alive = Alive
	Player:SetAttribute("MatchAlive", Alive)

	if not Alive and MatchState.Value == "waiting" then
		Record.Ready = false
		Player:SetAttribute("MatchReady", false)
	end

	self:CheckReady()
	self:CheckFinished()
end

function LevelState:SetReady(Player)
	local Record = Records[Player.UserId]
	if MatchState.Value ~= "waiting" or not Record or not Record.IsParticipant
		or not Record.Alive or not Player:GetAttribute("DataLoaded") then return end

	Record.Ready = true
	Player:SetAttribute("MatchReady", true)
	self:CheckReady()
end

function LevelState:CheckFinished()
	if MatchState.Value ~= "playing" then return end
	if #PlayersFolder:GetChildren() > 0 then return end

	Victory.Value = false
	MatchState.Value = "finished"
end

function LevelState:RemovePlayer(Player)
	Records[Player.UserId] = nil
	Expected[Player.UserId] = nil
	Disconnected[Player.UserId] = true

	self:CheckReady()
	self:CheckFinished()
end

function LevelState:WinLevel()
	if MatchState.Value ~= "playing" then return end

	Victory.Value = true
	MatchState.Value = "finished"
end

return LevelState