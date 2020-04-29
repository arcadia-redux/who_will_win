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
	$("#round").text = ++round
	$.Schedule(1,function() {
		let ids = Game.GetAllPlayerIDs()
		ids.forEach(function(id,_) {
			let hero = Players.GetSelectedEntities(id)[0],
				panel = $("#player_"+id)
				$.Msg(Entities.GetHealth(hero))
			panel.FindChildTraverse("hp").style.height = Math.round(Entities.GetHealth(hero)/5*100)+"%"
			panel.FindChildTraverse("hpt").text = Entities.GetHealth(hero)
		})
	})
}
let round = 0
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
function Start() {	
	let ids = Game.GetAllPlayerIDs()
	ids.forEach(function(id,_) {
		let plysteamid = Game.GetPlayerInfo(id).player_steamid,
			hero = Players.GetSelectedEntities(id)[0],
			panel = $.CreatePanel("Panel", $("#topbar"), "player_"+id)
		panel.BLoadLayoutSnippet("topBarPlayer")
		panel.FindChildTraverse("image").steamid = plysteamid
		panel.FindChildTraverse("hp").style.height = (Math.round(Entities.GetHealth(hero)/5*100))+"%"
		panel.FindChildTraverse("hpt").text = Entities.GetHealth(hero)
	})
}
	$.Schedule(1,function() {
Start()
})
GameEvents.Subscribe("new_round",new_round);
GameEvents.Subscribe("change_top",change);
