Gambling = Gambling or {
	bets = {},
	minimalBet = 0,
	minimalBetStep = 50,
	history = {},
	gold = {},
	startingGold = 800,
}

function Gambling:BetReset(event)
	local playerID = event.PlayerID

	if _G.FIGHT then return end

	self.bets[playerID] = nil
end

function Gambling:BetRequest(event)
	local playerID = event.PlayerID
	local gold = event.gold
	local team = event.team

	if _G.FIGHT then return end
	if team ~= "right" and team ~= "left" then return end

	if gold < self.minimalBet then
		gold = self.minimalBet
	end

	if gold > Gambling:GetGold(playerID) then
		gold = Gambling:GetGold(playerID)
	end

	if gold <= 0 then return end

	self.bets[playerID] = { 
		gold = gold, 
		team = team
	}

end

function Gambling:NewRound()
	self.bets = {}
	self.minimalBet = self.minimalBet + self.minimalBetStep
	CustomNetTables:SetTableValue("bets", "minimalBet", { minimalBet = self.minimalBet })

	for pID=0,23 do
		if PlayerResource:IsValidTeamPlayerID(pID) and self.gold[pID] and self.gold[pID] > 0 and PlayerResource:GetConnectionState(pID) == DOTA_CONNECTION_STATE_ABANDONED then
			Gambling:SetGold(pID, 0)
			CustomGameEventManager:Send_ServerToAllClients("player_abandoned", { playerID = pID })
		end
	end
end

function Gambling:RoundStart()
	-- make random bet for players that did not bet
	for pID=0,23 do
		if PlayerResource:IsValidTeamPlayerID(pID) and Gambling:GetGold(pID) > 0 and not self.bets[pID] then
			self.bets[pID] = {
				gold = Gambling:GetGold(pID) > self.minimalBet and self.minimalBet or Gambling:GetGold(pID),
				team = RollPercentage(50) and "left" or "right"
			}
		end
	end

	for pID,bet in pairs(self.bets) do 
		if bet.team == "left" then
			PlayerResource:SetCustomTeamAssignment(pID, DOTA_TEAM_GOODGUYS)
		elseif bet.team == "right" then
			PlayerResource:SetCustomTeamAssignment(pID, DOTA_TEAM_BADGUYS)
		end
	end

	CustomNetTables:SetTableValue("bets", "bets", self.bets)
end

function Gambling:RoundEnd(loserTeam)
	local winnerTeam = loserTeam == "left" and "right" or "left"
	local winnerBetSum = 0
	local loserBetSum = 0
	
	for _,bet in pairs(self.bets) do
		if bet.team == winnerTeam then
			winnerBetSum = winnerBetSum + bet.gold
		else
			loserBetSum = loserBetSum + bet.gold
		end
	end

	for pID,bet in pairs(self.bets) do
		local gold = Gambling:GetGold(pID)
		local profit = 0

		if bet.team == winnerTeam then
			--if IsSoloGame() then
			--	profit = bet.gold * 1.5
			--else
				profit = bet.gold * 2
				gold = gold - bet.gold
			--end
		elseif winnerBetSum > 0 then --if no winners losers dont lose money
			profit = -bet.gold
		end

		profit = math.floor(profit + 0.5)

		gold = gold + profit
		if gold <= 0 then 
			gold = 0 
			CustomGameEventManager:Send_ServerToAllClients("player_bankrupt", { playerID = pID })
		end
		Gambling:SetGold(pID, gold)
		
		bet.profit = profit
	end

	self.history[_G.ROUND] = self.bets
	CustomNetTables:SetTableValue("bets", "history", self.history)
end

function Gambling:GetGold(pID)
	return self.gold[pID] or 0
end

function Gambling:SetGold(pID, gold)
	self.gold[pID] = math.floor(gold + 0.5)
	CustomNetTables:SetTableValue("bets", "gold", self.gold)
end

function Gambling:Init()
	for pID=0,23 do
		if PlayerResource:IsValidTeamPlayerID(pID) then
			self.gold[pID] = self.startingGold
		end
	end
	CustomNetTables:SetTableValue("bets", "gold", self.gold)

	CustomGameEventManager:RegisterListener("player_bet", function(_,event) Gambling:BetRequest(event) end)
	CustomGameEventManager:RegisterListener("player_bet_reset", function(_,event) Gambling:BetReset(event) end)
end