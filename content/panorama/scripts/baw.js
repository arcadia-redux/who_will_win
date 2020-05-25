let cur_units = {}
function new_round(t) {
	// $("#leftTeam").text = t.left
	// $("#rightTeam").text = t.right
	$("#pwleft").text = "Power: "+t.left
	$("#pwright").text = "Power: "+t.right
	$("#makeBetPanel").style.visibility = "visible"
	$("#leftTeamG").RemoveAndDeleteChildren()
	$("#rightTeamG").RemoveAndDeleteChildren()
	cur_units = t.indexes
	for(let k in t.indexes){
		for(let i in t.indexes[k]){
			if(k == "left"){
				// $.CreatePanel("Label", $("#leftTeamG"), "lb").text = $.Localize(Entities.GetUnitName(t.indexes[k][i]))
				// let pan = $.CreatePanel("Panel", $("#leftTeamG"), "lb"),
				createSceneVersus(t,k,i,$("#leftTeamG"))
			}else if(k == "right"){
				// $.CreatePanel("Label", $("#rightTeamG"), "lb").text = $.Localize(Entities.GetUnitName(t.indexes[k][i]))
				// let pan = $.CreatePanel("Panel", $("#rightTeamG"), "lb"),
				createSceneVersus(t,k,i,$("#rightTeamG"))
			}
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
			if(panel){
				panel.FindChildTraverse("hp").style.height = Math.round(Entities.GetHealth(hero)/5*100)+"%"
				panel.FindChildTraverse("hpt").text = Entities.GetHealth(hero)
			}
		})
	})
}
function checkHp() {
	if(Object.keys(cur_units).length){
		let hps = {"left":0,"right":0,"leftmax":0,"rightmax":0}
		for(let k in cur_units){
			if(k != "regens"){
				for(let i in cur_units[k]){
					hps[k] += Entities.GetHealth(cur_units[k][i])
					hps[k+"max"] += Entities.GetMaxHealth(cur_units[k][i])
				}
			}
		}
		$("#leftHpPct").text = hps.left
		$("#rightHpPct").text = hps.right
		$("#lefthp").style.width = Math.round(hps.left/hps.leftmax*100)+"%"
		$("#righthp").style.width = Math.round(hps.right/hps.rightmax*100)+"%"
	}
	$.Schedule(0.33, checkHp)
}
function createSceneVersus(t,k,i,parent) {
	let pan = $.CreatePanel("Panel", parent, "lb"),
	name = Entities.GetUnitName(t.indexes[k][i]),
	ab,abpan,abname
	pan.BLoadLayoutSnippet("teamScene")
	pan.BCreateChildren('<DOTAScenePanel id="unit" class="teamScene" light="global_light" environment="default" particleonly="false" renderwaterreflections="true" antialias="true" drawbackground="0" renderdeferred="false" unit="'+name+'"/>')
	AddUnitTooltip(pan.FindChildTraverse("unit"),t.indexes[k][i])
	pan.FindChildTraverse("name").text = $.Localize(name)
	pan.FindChildTraverse("unithptext").text = Entities.GetMaxHealth(t.indexes[k][i])
	pan.FindChildTraverse("unitmptext").text = Entities.GetMaxMana(t.indexes[k][i])
 // $.Msg(t.indexes['regens'][t.indexes[k][i]])
	pan.FindChildTraverse("unitdamage").text = t.indexes['regens'][t.indexes[k][i]]["3"]
	pan.FindChildTraverse("unitarmor").text = t.indexes['regens'][t.indexes[k][i]]["4"].toFixed(1)
	pan.FindChildTraverse("unitatkspd").text = t.indexes['regens'][t.indexes[k][i]]["5"].toFixed(2)+"s"
	pan.FindChildTraverse("unitatkrng").text = t.indexes['regens'][t.indexes[k][i]]["6"]

	// $.Msg([t.indexes[k][i],Entities.GetHealthThinkRegen(t.indexes[k][i]),Entities.GetManaThinkRegen(t.indexes[k][i])])
	pan.FindChildTraverse("unithpplus").text = FormatRegen(t.indexes['regens'][t.indexes[k][i]]["1"])
	pan.FindChildTraverse("unitmpplus").text = FormatRegen(t.indexes['regens'][t.indexes[k][i]]["2"])
	let abs = pan.FindChildTraverse("abils")
	for (let d = 0; d < 6; d++) {
		ab = Entities.GetAbility(t.indexes[k][i],d)
		let abpan = $.CreatePanel("DOTAAbilityImage", abs, "ab")
		abname = Abilities.GetAbilityName(ab)
		// abpan.abilityname = abname
		if (Abilities.IsHidden(ab)) continue;
		abpan.contextEntityIndex = ab
		if(ab != -1){
			abpan.SetPanelEvent('onmouseover',ShowAbTooltip(abpan,t.indexes[k][i],abname))
			abpan.SetPanelEvent('onmouseout',function() {
				$.DispatchEvent('DOTAHideAbilityTooltip',abpan);
			})
		}
	}
	let items = pan.FindChildTraverse("items"),itm,item 
	for (let d = 0; d < 6; d++) {
		item = Entities.GetItemInSlot(t.indexes[k][i],d)
		if(item != -1){
			itm = items.GetChild(d)
			itm.contextEntityIndex = item
		}
		// let abpan = $.CreatePanel("DOTAAbilityImage", abs, "ab")
		// abname = Abilities.GetAbilityName(ab)
		// // abpan.abilityname = abname
		// abpan.contextEntityIndex = ab
	}
}
function FormatRegen( regen )
{
	return (regen >= 0 ? "+" : "" ) + regen.toFixed(1);
}
function AddUnitTooltip( panel, unit )
{
	panel.SetPanelEvent("onmouseover", function(){
		$.DispatchEvent( 'UIShowCustomLayoutParametersTooltip', panel, panel.id, "file://{resources}/layout/custom_game/tooltips.xml", "unit="+unit);
	})
	panel.SetPanelEvent("onmouseout", function() {
		$.DispatchEvent("UIHideCustomLayoutTooltip", panel, panel.id)
	})
}
function ShowAbTooltip(panel,ent,abname) {
	return function() {
		$.DispatchEvent('DOTAShowAbilityTooltipForEntityIndex',panel,abname,ent);
	}
}
let round = 0
function change(t) {
	let all = t.left + t.right,
		left = Math.round(t.left/all)* 100,
		right = 100-left
	$("#leftPct").text = `${left}%`
	$("#leftBar").style.width = `${left}%`
	$("#rightPct").text = `${right}%`
	$("#rightBar").style.width = `${right}%`
}
function Pick(v) {
	GameEvents.SendCustomGameEventToServer("Pick",{v:v})
	$("#makeBetPanel").style.visibility = "collapse"
}
function hide_versus() {
	$("#makeBetPanel").style.visibility = "collapse"
}
function Start() {	
	let ids = Game.GetAllPlayerIDs()
	$("#topbar").RemoveAndDeleteChildren()
	ids.forEach(function(id,_) {
		let plysteamid = Game.GetPlayerInfo(id).player_steamid,
			hero = Players.GetSelectedEntities(id)[0],
			panel = $.CreatePanel("Panel", $("#topbar"), "player_"+id)
		panel.BLoadLayoutSnippet("topBarPlayer")
		panel.FindChildTraverse("image").steamid = plysteamid
		panel.FindChildTraverse("hp").style.height = Math.round(Entities.GetHealth(hero)/5*100)+"%"
		panel.FindChildTraverse("hpt").text = Entities.GetHealth(hero)
	})
}
const timerEl = $("#time")
function timer(t) {
	timerEl.text = t.time
}
GameEvents.Subscribe("new_round",new_round);
GameEvents.Subscribe("change_top",change);
GameEvents.Subscribe("new_timer",timer);
GameEvents.Subscribe("hide_versus",hide_versus);

function UpdateSelectedUnit() {
	let selectedEntity = Players.GetLocalPlayerPortraitUnit(),
		sel = Players.GetSelectedEntities(Players.GetLocalPlayer())[0]
	if(selectedEntity == sel){
		GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL, false );
	}else{
		GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL, true );
	}
}
function vote() {
	GameEvents.SendCustomGameEventToServer("speedup",{})
}
function GRSChange() {
	if(Game.GetState() == DOTA_GameState.DOTA_GAMERULES_STATE_GAME_IN_PROGRESS){
		Start()
	}
}
GRSChange()
GameEvents.Subscribe("dota_player_update_query_unit",UpdateSelectedUnit)
GameEvents.Subscribe('dota_player_update_hero_selection', UpdateSelectedUnit);
GameEvents.Subscribe('dota_player_update_selected_unit', UpdateSelectedUnit);
GameEvents.Subscribe('game_rules_state_change', GRSChange);

checkHp()





// [GCClient] Recv msg 26 (k_ESOMsg_UpdateMultiple), 390 bytes
// [PanoramaScript] [0,1]
// [PanoramaScript] !! (panorama\scripts\baw.js, line:116, col:68) - V8ParamToPanoramaType expected Number type to convert, but got something else (undefined)
// [PanoramaScript] !! (panorama\scripts\baw.js, line:116, col:45) - Failed to set property value (property=height)(value=NaN%)
// C:Gamerules: entering state 'DOTA_GAMERULES_STATE_GAME_IN_PROGRESS'
// [Client] CDOTA_Hud_Main::EventGameRulesStateChanged DOTA_GAMERULES_STATE_GAME_IN_PROGRESS
// [PanoramaScript] [0,1]
// [PanoramaScript] !! (panorama\scripts\baw.js, line:35, col:8) - TypeError: Cannot read property 'FindChildTraverse' of null
// [GCClient] Recv msg 7273 (k_EMsgGCChatMessage), 221 bytes
// [GCClient] Recv msg 26 (k_ESOMsg_UpdateMultiple), 394 bytes
// [PanoramaScript] {"right":0,"left":1}
// Set target panel parameter "unit" to the value "248"
// Set target panel parameter "unit" to the value "251"
// [PanoramaScript] {"right":1,"left":1}
