function new_round(t) {
	$("#leftTeam").text = t.left[1]
	$("#rightTeam").text = t.right[1]
	$("#makeBetPanel").style.visibility = "visible"
	$("#leftTeamG").RemoveAndDeleteChildren()
	$("#rightTeamG").RemoveAndDeleteChildren()
	for(let k in t.left){
		if(k != 1){
			$.CreatePanel("Label", $("#leftTeamG"), "lb").text = $.Localize(t.left[k])
		}
	}
	for(let k in t.right){
		if(k != 1){
			$.CreatePanel("Label", $("#rightTeamG"), "lb").text = $.Localize(t.right[k])
		}
	}
	$("#leftPct").text = "0%"
	$("#rightPct").text = "0%"
	$("#leftBar").style.width = "50%"
	$("#rightBar").style.width = "50%"
}
function change(t) {
	let pct = Math.round(t.left / (t.left+t.right))* 100
	$("#leftPct").text = `${pct}%`
	$("#rightPct").text = `${100-pct}%`
	$("#leftBar").style.width = `${pct}%`
	$("#rightBar").style.width = `${100-pct}%`

}
function Pick(v) {
	GameEvents.SendCustomGameEventToServer("Pick",{v:v})
	$("#makeBetPanel").style.visibility = "collapse"
}
GameEvents.Subscribe("new_round",new_round);
GameEvents.Subscribe("change_top",change);
