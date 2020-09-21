"use strict";

const loseMessages = $.GetContextPanel().FindChildTraverse("LoseMessages")

function UpdateBets(event) {

	let bets = event.bets
	const winner = event.winnerTeam

	const rows = $("#TableRows")
	rows.RemoveAndDeleteChildren()

	bets = LuaTableToArray(bets)


	let leftSum = 0
	let rightSum = 0

	bets.forEach((bet,pID) => {
		if (bet.team == "left") 
			leftSum += bet.gold
		else 
			rightSum += bet.gold
		bet.pID = pID
	})

	bets.sort(function(a,b) {
		if (a.team != winner && b.team == winner)
			return 1
		else if(a.team == winner && b.team != winner)
			return -1

		return b.gold - a.gold
	})

	loseMessages.RemoveAndDeleteChildren()
	
	let count = 0
	bets.forEach(bet => {
		const panel = $.CreatePanel("Panel", rows, bet.pID)
		panel.BLoadLayoutSnippet("PlayerRow")
		panel.SetHasClass("Even", (count % 2) == 0)


		panel.FindChildTraverse("PlayerName").text = Players.GetPlayerName(bet.pID)
		panel.FindChildTraverse("PlayerName").style.color = GetPlayerColor(bet.pID)
		if (bet.team == "left") {
			panel.FindChildTraverse("TeamIcon").SetImage("file://{images}/custom_game/team_icons/team_icon_horse_01.png")
			panel.FindChildTraverse("ShieldColor").style.washColor = "#1E90FF"
		}
		else {
			panel.FindChildTraverse("TeamIcon").SetImage("file://{images}/custom_game/team_icons/team_icon_tiger_01.png")
			panel.FindChildTraverse("ShieldColor").style.washColor = "#f01a1a"
		}

		let profit = bet.profit

		panel.FindChildTraverse("Profit").text = profit.toFixed(0)
		panel.FindChildTraverse("Profit").SetHasClass("Red", profit < 0)

		panel.FindChildTraverse("Total").text = Players.GetGamblingGold(bet.pID)

		if (bet.pID == Game.GetLocalPlayerID()) {
			panel.AddClass("LocalPlayer")
			if (profit > 0) {
				if (profit <= bet.gold)
					$.Schedule(1, function() { Game.EmitSound("General.Coins") } )
				else
					$.Schedule(1, function() { Game.EmitSound("General.CoinsBig") } )
			}
		}

		if (Players.GetGamblingGold(bet.pID) <= 0) {
			AddLoseMessage(bet.pID)
		}

		count++
	})

	$.GetContextPanel().visible = true
}

function AddLoseMessage(pID) {
	const label = $.CreatePanel("Label", loseMessages, "")
	const playerColor = GetPlayerColor(pID)
	const text = `<font color='${playerColor}'>` + Players.GetPlayerName(pID) + "</font>"
	label.SetDialogVariable("player_name", text)

	label.html = true
	label.text = $.Localize("round_end_player_lose", label)
}

function OnBetsChanged(table_name, key, data) {
	if (key == "bets") {
		UpdateBets(data)
	}
}

function NewRound() {
	$.GetContextPanel().visible = false
}

(function() {
	//CustomNetTables.SubscribeNetTableListener("bets", OnBetsChanged)
	//GameEvents.Subscribe("new_round", NewRound);
	//GameEvents.Subscribe("start_fight", StartFight);
})()

