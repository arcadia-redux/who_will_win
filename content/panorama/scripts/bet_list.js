"use strict";

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

	
	let count = 0
	bets.forEach(bet => {
		const panel = $.CreatePanel("Panel", rows, bet.pID)
		panel.BLoadLayoutSnippet("PlayerRow")
		panel.SetHasClass("Even", (count % 2) == 0)


		panel.FindChildTraverse("PlayerName").text = Players.GetPlayerName(bet.pID)
		panel.FindChildTraverse("PlayerName").style.color = GetPlayerColor(bet.pID)
		if (bet.team == "left") {
			panel.FindChildTraverse("TeamIcon").SetImage("file://{images}/custom_game/team_icons/team_icon_horse_01.png")
			panel.FindChildTraverse("ShieldColor").style.washColor = "blue"
		}
		else {
			panel.FindChildTraverse("TeamIcon").SetImage("file://{images}/custom_game/team_icons/team_icon_tiger_01.png")
			panel.FindChildTraverse("ShieldColor").style.washColor = "red"
		}

		panel.FindChildTraverse("Bet").text = bet.gold

		let profit = 0
		if (bet.team == event.winnerTeam) {
			if (bet.team == "left") 
				profit =  bet.gold/leftSum * rightSum
			else 
				profit =  bet.gold/rightSum * leftSum
		}
		else {
			profit = -bet.gold
		}

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

		count++
	})

	$.GetContextPanel().visible = true
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

function LuaTableToArray(nt) {
	var result = []
	for (var i in nt) {
		result[i] = nt[i]
	}
	return result
}

function GetPlayerColor(pID) {
  var color = Players.GetPlayerColor( pID ).toString(16);
  color = color.substring(6, 8) + color.substring(4, 6) + color.substring(2, 4) + color.substring(0, 2);
  return "#" + color;
}