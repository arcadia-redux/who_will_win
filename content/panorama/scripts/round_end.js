"use strict"

function RoundEnd(event) {
	const context = $.GetContextPanel()

	context.AddClass("ShowVictory")

	context.RemoveClass("DireWin")
	context.RemoveClass("RadiantWin")

	if (event.winnerTeam == "left") {
		context.SetDialogVariable("victory_title", $.Localize("#round_win_left"))
		context.AddClass("RadiantWin")
	}
	else {
		context.SetDialogVariable("victory_title",  $.Localize("#round_win_right"))
		context.AddClass("DireWin")
	}

	UpdateBets(event)

}

function NewRound(event) {
	$.GetContextPanel().RemoveClass("ShowVictory")
}

(function() {
	GameEvents.Subscribe("new_round", NewRound);
	GameEvents.Subscribe("round_end", RoundEnd);
})()