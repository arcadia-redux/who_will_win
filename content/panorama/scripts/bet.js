"use strict";

function BetReset() {
	$("#BetSlider").SetValueNoEvents(0.5)
	$("#RightBetGold").text = 0
	$("#LeftBetGold").text = 0
	GameEvents.SendCustomGameEventToServer("player_bet_reset",{})
}

function BetMax(value) {
	$("#BetSlider").value = value
}

function Bet(team, x) {
	const playerGold = GetGold(Game.GetLocalPlayerID())

	const table = CustomNetTables.GetTableValue("bets", "minimalBet") 
	const minBet = table ? (table.minimalBet || 50) : 50

	let bet = 0

	bet = Math.round(playerGold * x)

	if (bet < minBet) 
		bet = playerGold < minBet ? playerGold : minBet

	if (bet <= 0) return

	if (team == "left") {
		$("#LeftBetGold").text = bet
		$("#RightBetGold").text = 0
	}
	else {
		$("#LeftBetGold").text = 0
		$("#RightBetGold").text = bet
	}

	GameEvents.SendCustomGameEventToServer("player_bet", { team: team, gold: bet } )

	let newValue = bet/playerGold / 2
	if (team == "right") 
		newValue += 0.5
	else 
		newValue = 0.5 - newValue
	$("#BetSlider").SetValueNoEvents(newValue)
}

function BetChanged() {
	const slider = $("#BetSlider")

	const value = (slider.value - 0.5) * 2 
	const playerGold = GetGold(Game.GetLocalPlayerID())
	let gold =  Math.abs(value * playerGold)

	const table = CustomNetTables.GetTableValue("bets", "minimalBet") 
	const minBet = table ? (table.minimalBet || 50) : 50

	if (gold < minBet) {
		gold = minBet
	}

	if (gold > playerGold) {
		gold = playerGold
	}

	gold = Math.round(gold)

	let team = "left"
	if (value < 0) {
		$("#LeftBetGold").text = gold
		$("#RightBetGold").text = 0
	}
	else {
		$("#LeftBetGold").text = 0
		$("#RightBetGold").text = gold
		team = "right"
	}

	GameEvents.SendCustomGameEventToServer("player_bet",{ team: team, gold: gold})

	/*let newValue = gold/playerGold / 2
	if (team == "right") {
		newValue += 0.5
	}
	else {
		newValue = 0.5 - newValue
	}

	slider.SetValueNoEvents(newValue)*/
}




function GetGold(pID) {
	const table = CustomNetTables.GetTableValue("bets", "gold") 
	return table ? (table[pID] || 0) : 0
}

(function() {
	let table = CustomNetTables.GetTableValue("bets", "minimalBet") 
	$("#MinimalBet").SetDialogVariableInt("minimal_bet", table ? (table.minimalBet || 50) : 50)
	
	Players.GetGamblingGold = GetGold
})()