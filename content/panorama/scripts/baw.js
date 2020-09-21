"use strict"

let cur_units = {}
let maxHealthLeft = 1
let maxHealthRight = 1

let time = 0
let startTime = 0

function new_round(t) {
	// $("#leftTeam").text = t.left
	// $("#rightTeam").text = t.right
	$("#pwleft").text = "Power: "+t.left
	$("#pwright").text = "Power: "+t.right
	$("#pwleft").visible = t.left != 0
	$("#pwright").visible = t.right != 0
	$("#makeBetPanel").style.visibility = "visible"
	$("#leftTeamG").RemoveAndDeleteChildren()
	$("#rightTeamG").RemoveAndDeleteChildren()
	cur_units = t.indexes

	$("#leftPct").text = "0%"
	$("#rightPct").text = "0%"
	$("#leftBar").style.width = "50%"
	$("#rightBar").style.width = "50%"
	$("#round").text = "ROUND " + ++round

	BetReset()
	$("#BetSlider").SetValueNoEvents(0.5)
	$("#ReadyToRound").checked = false
	$("#ReadyToRound").visible = Players.GetGamblingGold(Game.GetLocalPlayerID()) > 0
	$("#BetContainer").visible = Players.GetGamblingGold(Game.GetLocalPlayerID()) > 0

	$("#topbar").Children().forEach(panel => {
		panel.FindChild("bet").visible = false
		panel.FindChild("profit").visible = false
		panel.RemoveClass("Left")
		panel.RemoveClass("Right")
		panel.SetHasClass("Loser", Players.GetGamblingGold(panel.playerID) <= 0)
	}) 

	const units = Object.values(t.indexes["left"]).concat(Object.values(t.indexes["right"]))

	const func = () => {
		if (units.some((unitID) => !Entities.IsValidEntity(unitID))) {
			$.Schedule(0, func)
		}
		else {
			PopulateSceneVersus(t)
		}
	}

	func()
}

function PopulateSceneVersus(t) {
	GameUI.NewRound(t)
	
	maxHealthLeft = 0
	maxHealthRight = 0

	for(let k in t.indexes){
		if (k != "left" && k != "right") continue;
		t.indexes[k] = LuaTableToArrayDec(t.indexes[k])

		$.Msg(t.indexes[k])

		t.indexes[k].sort(function(a,b) {
			return Entities.GetMaxHealth(b) - Entities.GetMaxHealth(a)
		})

		t.indexes[k].forEach((unit) => {
			$.Msg(unit, " ", Entities.GetUnitName(unit), " ", Entities.IsValidEntity(unit))
			if (k == "left")
				maxHealthLeft = maxHealthLeft + Entities.GetMaxHealth(unit)
			else
				maxHealthRight = maxHealthRight + Entities.GetMaxHealth(unit)
		})

		let teamUnits = GroupUnits(t.indexes[k])

		for(let i in teamUnits){
			if (k == "left") {
				createSceneVersus(t, teamUnits[i], $("#leftTeamG"))
			}
			else if (k == "right") {
				createSceneVersus(t, teamUnits[i], $("#rightTeamG"))
			}
		}
	}
}


function checkHp() {
	$.Schedule(0.1, checkHp)

	if(Object.keys(cur_units).length){
		let hps = {"left":0,"right":0}
		for(let k in cur_units){
			if(k != "regens"){
				for(let i in cur_units[k]){
					const health = Entities.GetHealth(cur_units[k][i])
					hps[k] += health == -1 ? 0 : health
				}
			}
		} 
		$("#leftHpPct").text = hps.left
		$("#rightHpPct").text = hps.right
		$("#lefthp").style.width = Math.round(hps.left/maxHealthLeft*100)+"%"
		$("#righthp").style.width = Math.round(hps.right/maxHealthRight*100)+"%"
	}

	const topBar = $("#topbar")
	topBar.Children().forEach(panel => {
		var childID = topBar.GetChildIndex(panel)

		panel.FindChild("gold").text = Players.GetGamblingGold(panel.playerID)

		if (childID > 0) {
			var upperPanel = topBar.GetChild(childID-1)
			
			if (upperPanel && Players.GetGamblingGold(upperPanel.playerID) < Players.GetGamblingGold(panel.playerID) ) {
				topBar.MoveChildAfter(upperPanel, panel)
			}
		}
	})	

	let counter = startTime + time - Game.GetGameTime()
	if (counter < 0) counter = 0
	$("#time").text = FormatTime(counter)
}

function createSceneVersus(t,unitID,parent) {

	let pan = $.CreatePanel("Panel", parent, "lb")
	pan.BLoadLayoutSnippet("teamScene")

	if (Array.isArray(unitID)) {
		pan.SetDialogVariableInt("unit_count", unitID.length)
		pan.FindChildTraverse("UnitCounter").visible = true

		unitID = unitID[0]
	}


	let name = Entities.GetUnitName(unitID),
	ab,abpan,abname

	const isHero = Entities.GetUnitName(unitID).includes("npc_dota_hero")

	
	pan.BCreateChildren('<DOTAScenePanel id="unit" class="teamScene" light="global_light" environment="default" particleonly="false" renderwaterreflections="true" antialias="true" drawbackground="0" renderdeferred="false" unit="'+name+'"/>')
	AddUnitTooltip(pan.FindChildTraverse("unit"),unitID)
	pan.FindChildTraverse("name").text = $.Localize(name)
	pan.FindChildTraverse("unithptext").text = Entities.GetMaxHealth(unitID)
	pan.FindChildTraverse("unitmptext").text = Entities.GetMaxMana(unitID)
 // $.Msg(t.indexes['regens'][t.indexes[k][i]])
	pan.FindChildTraverse("unitdamage").text = t.indexes['regens'][unitID]["6"].toFixed(0)
	pan.FindChildTraverse("unitarmor").text = t.indexes['regens'][unitID]["5"].toFixed(1)
	pan.FindChildTraverse("unitatkspd").text = t.indexes['regens'][unitID]["3"].toFixed(2)+"s"
	pan.FindChildTraverse("unitatkrng").text = t.indexes['regens'][unitID]["4"]

	pan.SetDialogVariableInt("level", Entities.GetLevel(unitID))

	// $.Msg([t.indexes[k][i],Entities.GetHealthThinkRegen(t.indexes[k][i]),Entities.GetManaThinkRegen(t.indexes[k][i])])
	pan.FindChildTraverse("unithpplus").text = FormatRegen(t.indexes['regens'][unitID]["1"])
	pan.FindChildTraverse("unitmpplus").text = FormatRegen(t.indexes['regens'][unitID]["2"])
	let abs = pan.FindChildTraverse("abils")
	for (let d = 0; d < 6; d++) {
		const abilityContainer = $.CreatePanel("Panel", abs, "ability"+d)
		abilityContainer.AddClass("AbilityContainer")
		ab = Entities.GetAbility(unitID,d)
		const abpan = $.CreatePanel("DOTAAbilityImage", abilityContainer, "ab")
		abname = Abilities.GetAbilityName(ab)
		// abpan.abilityname = abname
		if (Abilities.IsHidden(ab)) continue;
		abpan.contextEntityIndex = ab
		abpan.SetHasClass("no_level", Abilities.GetLevel(ab) < 1)
		if(ab != -1){
			abpan.SetPanelEvent('onmouseover',ShowAbTooltip(abpan,unitID,abname))
			abpan.SetPanelEvent('onmouseout',function() {
				$.DispatchEvent('DOTAHideAbilityTooltip',abpan);
			})

			if (isHero) {
				pan.AddClass("Hero")
				const levelContainer = $.CreatePanel("Panel", abilityContainer, "AbilityLevelContainer")
				const maxLevel = Abilities.GetMaxLevel(ab)
				const currentLevel = Abilities.GetLevel(ab)

				if (maxLevel > 1 || Abilities.IsOnLearnbar(ab)) {
					for (let i=1; i<=maxLevel; i++) {
						const levelPanel = $.CreatePanel("Panel", levelContainer, "level"+i)
						levelPanel.AddClass("LevelPanel")
						levelPanel.SetHasClass("active_level", i <= currentLevel)
					}
				}

			}
		}
	}
	let items = pan.FindChildTraverse("items"),itm,item 
	for (let d = 0; d < 6; d++) {
		let item = Entities.GetItemInSlot(unitID,d)

		if(item != -1){
			const itemName = Abilities.GetAbilityName(item) 
			itm = items.GetChild(d)
			itm.contextEntityIndex = item
			itm.SetPanelEvent('onmouseover',ShowAbTooltip(itm,unitID,itemName))
			itm.SetPanelEvent('onmouseout',function() {
				$.DispatchEvent('DOTAHideAbilityTooltip',itm);
			})
		}
		// let abpan = $.CreatePanel("DOTAAbilityImage", abs, "ab")
		// abname = Abilities.GetAbilityName(ab)
		// // abpan.abilityname = abname
		// abpan.contextEntityIndex = ab
		
	}

	if (isHero) {
			const talentPanel = $.CreatePanel("Panel", pan, "TalentsDisplay")
			talentPanel.BLoadLayoutSnippet("TalentDisplay")
			const firstTalent = GetHeroFirstTalentID(unitID)
			//$.Msg(firstTalent)

			talentPanel.FindChildTraverse("StatLevelProgressBar").value = Entities.GetLevel(unitID)
			talentPanel.FindChildTraverse("StatLevelProgressBarBlur").value = Entities.GetLevel(unitID)

			if (firstTalent != -1) {
				for (let i = 0; i < 8; i++) {
					if (Abilities.GetLevel(Entities.GetAbility(unitID, firstTalent+i)) > 0) {
						//$.Msg(Abilities.GetAbilityName(Entities.GetAbility(unitID, firstTalent+i)))
						switch (i) {
							case 0:
								talentPanel.FindChildTraverse("StatRow10").AddClass("RightBranchSelected")
								break
							case 1:
								talentPanel.FindChildTraverse("StatRow10").AddClass("LeftBranchSelected")
								break
							case 2:
								talentPanel.FindChildTraverse("StatRow15").AddClass("RightBranchSelected")
								break
							case 3:
								talentPanel.FindChildTraverse("StatRow15").AddClass("LeftBranchSelected")
								break
							case 4:
								talentPanel.FindChildTraverse("StatRow20").AddClass("RightBranchSelected")
								break
							case 5:
								talentPanel.FindChildTraverse("StatRow20").AddClass("LeftBranchSelected")
								break
							case 6:
								talentPanel.FindChildTraverse("StatRow25").AddClass("RightBranchSelected")
								break
							case 7:
								talentPanel.FindChildTraverse("StatRow25").AddClass("LeftBranchSelected")
								break
						}
					}
				}
			}

			talentPanel.SetPanelEvent("onmouseover", function() {
				$.DispatchEvent("UIShowCustomLayoutParametersTooltip", talentPanel, "TalentTooltip", 
					"file://{resources}/layout/custom_game/tooltip_talent.xml", "heroID="+unitID)
			})   

			talentPanel.SetPanelEvent("onmouseout", function() {
				$.DispatchEvent("UIHideCustomLayoutTooltip", talentPanel, "TalentTooltip")      
			})
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

function hide_versus() {
	$("#makeBetPanel").style.visibility = "collapse"
	$("#SpeedupButton").enabled = true
}

function Start() {	
	let ids = Game.GetAllPlayerIDs()
	$("#topbar").RemoveAndDeleteChildren()
	ids.forEach(function(id,_) {
		const playerInfo = Game.GetPlayerInfo(id)
		let plysteamid = playerInfo.player_steamid,
			hero = Players.GetSelectedEntities(id)[0],
			panel = $.CreatePanel("Panel", $("#topbar"), "player_"+id)
		panel.BLoadLayoutSnippet("topBarPlayer")
		panel.FindChild("gold").text = Players.GetGamblingGold(id)
		panel.playerID = id

		const avatar = panel.FindChildTraverse("image")
		const botIcon = panel.FindChildTraverse("BotIcon")

		
		botIcon.visible = playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_NOT_YET_CONNECTED
		botIcon.style.backgroundColor = "black"
		botIcon.style.washColor = GetPlayerColor(id)
		avatar.steamid = plysteamid
	})
}

function timer(t) {
	time = t.time
	startTime = t.start_time
}

function OnRoundEnd() {
	$("#SpeedupButton").RemoveClass("ready")
	$("#SpeedupButton").enabled = false
}


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

function ReadyToRound() {
	GameEvents.SendCustomGameEventToServer("player_ready_to_round", { isReady: $("#ReadyToRound").checked })
	Game.EmitSound("General.ButtonClick")
}

function GRSChange() {
	if(Game.GetState() == DOTA_GameState.DOTA_GAMERULES_STATE_GAME_IN_PROGRESS){
		Start()
	}
}

GRSChange()

function UpdateBets(data) {
	let leftGold = 0
	let rightGold = 0

	for (const bet in data) {
		if (data[bet].team == "left") {
			leftGold += +data[bet].gold
		}
		else if (data[bet].team == "right") {
			rightGold += +data[bet].gold
		}
	}

	const summ = rightGold + leftGold
	const left = Math.round(leftGold/summ * 100)
	const right = Math.round(rightGold/summ * 100)

	$("#leftPct").text = `(${left}%) ${leftGold}`
	$("#leftBar").style.width = `${left}%`
	$("#rightPct").text = `${rightGold} (${right}%)`
	$("#rightBar").style.width = `${right}%`

	let count = 0
	$("#topbar").Children().forEach(panel => {
		const bet = data[panel.playerID]
		panel.RemoveClass("Left")
		panel.RemoveClass("Right")
		panel.SetHasClass("Loser", Players.GetGamblingGold(panel.playerID) == 0)
		if (bet) {
			let gold = bet.gold
			let profit = 0
			if (bet.team == "left") {
				profit =  gold * 2
				panel.AddClass("Left")
				panel.FindChildTraverse("TeamIcon").SetImage("file://{images}/custom_game/team_icons/team_icon_horse_01.png")
			}
			else {
				profit =  gold * 2
				panel.AddClass("Right")
				panel.FindChildTraverse("TeamIcon").SetImage("file://{images}/custom_game/team_icons/team_icon_tiger_01.png")
			}

			profit = profit.toFixed(0)
			
			panel.FindChild("bet").text = `${gold}`
			panel.FindChild("profit").text = `${profit}`
			panel.FindChild("bet").visible = true
			panel.FindChild("profit").visible = true
		}
		else {
			panel.FindChild("bet").visible = false
			panel.FindChild("profit").visible = false

		}
	})
}

function UpdateGold(data) {
	const goldLabel = $("#LowerRight").FindChildTraverse("Gold")
	const gold = data[Game.GetLocalPlayerID()] || 0
	
	goldLabel.SetDialogVariableInt("gold", gold)
	$("#LowerRight").visible = gold > 0
}

function OnSpeedupStateChanged(data) {
	const voteButton = $("#SpeedupButton")
	const localVoted = data.players_voted[Game.GetLocalPlayerID()] == 1

	voteButton.SetHasClass("ready", localVoted)

	if (localVoted) {
		voteButton.SetDialogVariableInt("count", Object.values(data.players_voted).length)
		voteButton.SetDialogVariableInt("total_count", data.total_count)
		voteButton.FindChild("SpeedupText").text = $.Localize("speedup_state", voteButton)
	}
	else {
		voteButton.FindChild("SpeedupText").text = $.Localize("speedup_vote")
	}
}

function OnBetsChanged(table_name, key, data) {
	if (key == "minimalBet") {
		$("#MinimalBet").SetDialogVariableInt("minimal_bet", data.minimalBet || 0)
	}
	else if (key == "bets") {
		UpdateBets(data)
	}
	else if (key == "gold") {
		UpdateGold(data)
	}
}

function OnGameChanged(table_name, key, data) {
	if (key == "speedup_state") {
		OnSpeedupStateChanged(data)
	}
}

function OnCameraPosition(event) {
	GameUI.SetCameraTargetPosition(event.vector, 0.1)
}

(function() {
	CustomNetTables.SubscribeNetTableListener("bets", OnBetsChanged)
	CustomNetTables.SubscribeNetTableListener("game", OnGameChanged)

	GameEvents.Subscribe("new_round",new_round);
	GameEvents.Subscribe("change_top",change);
	GameEvents.Subscribe("new_timer",timer);
	GameEvents.Subscribe("hide_versus",hide_versus);
	GameEvents.Subscribe("round_end", OnRoundEnd);

	GameEvents.Subscribe("dota_player_update_query_unit",UpdateSelectedUnit)
	GameEvents.Subscribe('dota_player_update_hero_selection', UpdateSelectedUnit);
	GameEvents.Subscribe('dota_player_update_selected_unit', UpdateSelectedUnit);
	GameEvents.Subscribe('game_rules_state_change', GRSChange);
	GameEvents.Subscribe('camera_position', OnCameraPosition);

	checkHp()

	const goldTable = CustomNetTables.GetTableValue("bets", "gold")
	if (goldTable) UpdateGold(goldTable)

	const betTable = CustomNetTables.GetTableValue("bets", "bets")
	if (betTable) UpdateBets(betTable)

	const speedupTable = CustomNetTables.GetTableValue("game", "speedup_state")
	if (speedupTable) OnSpeedupStateChanged(speedupTable)

})()