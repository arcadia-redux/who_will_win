"use strict";

const UNIT_COUNT = 18;

function CreateAbilityButton(ability, parent, id) {
	let panel = $.CreatePanel("Panel", parent, id)
	panel.AddClass("AbilityPanel")
	panel.BLoadLayoutSnippet("AbilityPanel")
	panel.abilityID = ability

	panel.style.width = "41px"
	panel.style.height = "41px"
	//panel.style.verticalAlign = "top"

	//panel.FindChildTraverse("HotkeyContainer").visible = false
	//panel.FindChildTraverse("LevelUpTab").visible = false
	//panel.FindChildTraverse("LevelUpLight").visible = false
	panel.FindChildTraverse("AbilityImage").style.margin = "1px"
	panel.FindChildTraverse("AbilityBevel").style.margin = "1px"
	panel.FindChildTraverse("ShineContainer").style.margin = "1px"
	panel.FindChildTraverse("Cooldown").style.margin = "1px"
	panel.FindChildTraverse("CooldownTimer").style.fontSize = "24px"
	panel.FindChildTraverse("PassiveAbilityBorder").style.margin = "2px"
	panel.FindChildTraverse("ManaCost").style.marginRight = "0px"
	panel.FindChildTraverse("ManaCost").style.marginBottom = "0px"
	panel.FindChildTraverse("ManaCost").style.fontSize = "12px"
	panel.FindChildTraverse("ManaCostBG").style.width = "27px"
	panel.FindChildTraverse("ManaCostBG").style.height = "15px"

	return panel
}

function CreateItemButton(item, parent, id) {
	let panel = CreateAbilityButton(item, parent, id)
	panel.SetHasClass("InventoryItem", true)
	panel.SetHasClass("no_level", true)

	panel.FindChildTraverse("ButtonSize").style.width = "41px"
	panel.FindChildTraverse("ButtonSize").style.height = "27px"
	panel.FindChildTraverse("CooldownTimer").style.fontSize = "20px"
	panel.style.height = "27px"
	return panel
}

function AssignAbility(panel, abilityID) {
	panel.abilityID = abilityID

	// Implemented only features that needed for that CG

	const abilityName = Abilities.GetAbilityName(abilityID)

	if (Abilities.IsItem(abilityID)) {
		panel.FindChildTraverse("ItemImage").itemname = abilityName
		panel.FindChildTraverse("ItemImage").contextEntityIndex = abilityID
	}
	else {
		panel.FindChildTraverse("AbilityImage").abilityname = abilityName
		panel.FindChildTraverse("AbilityImage").contextEntityIndex = abilityID
	}

	panel.AddClass("no_gold_cost")
	panel.AddClass("no_hotkey")
	panel.RemoveClass("insufficient_mana")
	panel.RemoveClass("muted")
	panel.RemoveClass("silenced")

	panel.SetHasClass("is_passive", Abilities.IsPassive(abilityID))

	const manaCost = Abilities.GetManaCost(abilityID)
	panel.SetHasClass("no_mana_cost", manaCost == 0)
	panel.SetDialogVariableInt("mana_cost", manaCost)

	panel.SetPanelEvent("onmouseover", function() {
		//$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", panel, abilityName, Abilities.GetCaster(abilityID))
		$.DispatchEvent("DOTAShowAbilityTooltipForLevel", panel, abilityName, Abilities.GetLevel(abilityID))
	})

	panel.SetPanelEvent("onmouseout", function() {
		$.DispatchEvent("DOTAHideAbilityTooltip", panel)
	})

}

function UpdateAbilityButton(panel) {
	if (!panel.visible) return

	const abilityID = panel.abilityID

	if (!abilityID || !Entities.IsValidEntity(abilityID)) return 

	if (Abilities.IsPassive(abilityID)) return

	panel.SetHasClass("muted", Abilities.IsMuted(abilityID))
	panel.SetHasClass("insufficient_mana", !Abilities.IsOwnersManaEnough(abilityID))

	const cooldownReady = Abilities.IsCooldownReady(abilityID)
	panel.SetHasClass("cooldown_ready",	cooldownReady)
	panel.SetHasClass("in_cooldown",   !cooldownReady)
	panel.SetHasClass("ability_phase",	Abilities.IsInAbilityPhase(abilityID))

	if (!cooldownReady) {
		/*$.Msg("GetCooldown "+Abilities.GetCooldown(abilityID))
		$.Msg("GetCooldownTimeRemaining "+Abilities.GetCooldownTimeRemaining(abilityID))
		$.Msg("GetCooldownTime "+Abilities.GetCooldownTime(abilityID))
		$.Msg("GetCooldownLength "+Abilities.GetCooldownLength(abilityID))*/

		const cooldownRemaining = Abilities.GetCooldownTimeRemaining(abilityID)
		const deg = -(cooldownRemaining/Abilities.GetCooldown(abilityID)*360)
		panel.FindChildTraverse("CooldownOverlay").style.clip = `radial( 50% 50%, 0deg, ${deg}deg )` //radial( 50.0% 50.0%, 0.0deg, -261.451202deg)
		panel.SetDialogVariableInt("cooldown_timer", cooldownRemaining)
	}

	const caster = Abilities.GetCaster(abilityID)
	if (Entities.IsValidEntity(caster)) {
		panel.SetHasClass("silenced", Entities.IsSilenced(caster))
	}
}

function CreateUnitPanel(id, parent) {
	let panel = $.CreatePanel("Panel", parent, id)
	panel.AddClass("UnitPanel")
	panel.BLoadLayoutSnippet("UnitInfo")
	
	/*let stats = panel.FindChildTraverse("stats")
	stats.BLoadLayoutSnippet("Stats")

	let heroStats = panel.FindChildTraverse("stragiint")
	heroStats.BLoadLayoutSnippet("StrAgiInt")*/

	let abiCont = panel.FindChildTraverse("AbilityContainer")
	abiCont.RemoveAndDeleteChildren()
	
	CreateAbilityButton(-1, abiCont, "0")
	CreateAbilityButton(-1, abiCont, "1")
	CreateAbilityButton(-1, abiCont, "2")
	CreateAbilityButton(-1, abiCont, "3")
	CreateAbilityButton(-1, abiCont, "4")
	CreateAbilityButton(-1, abiCont, "5")

	let itemCont = panel.FindChildTraverse("ItemsContainer")
	itemCont.RemoveAndDeleteChildren()

	CreateItemButton(-1, itemCont, "0")
	CreateItemButton(-1, itemCont, "1")
	CreateItemButton(-1, itemCont, "2")
	CreateItemButton(-1, itemCont, "3")
	CreateItemButton(-1, itemCont, "4")
	CreateItemButton(-1, itemCont, "5")

	/*panel.SetPanelEvent("onactivate", function() {
		if (panel.unitID && Entities.IsValidEntity(panel.unitID)) {
			GameUI.SelectUnit(panel.unitID, true)
		}
	})*/

	return panel
}

function AssignUnit(panel, unitID) {
	panel.unitID = unitID

	const unitName = Entities.GetUnitName(unitID)

	panel.SetHasClass("Death", false)

	//panel.FindChildTraverse("UnitNameLabel").text = $.Localize(unitName)
	panel.FindChildTraverse("UnitPortrait").SetUnit(unitName, "default", true)

	let abiCont = panel.FindChildTraverse("AbilityContainer")
	for (let i = 0; i < 6; i++) {
		const abiID = Entities.GetAbility( unitID, i )
		abiCont.FindChild(i).visible = true
		if (abiID != -1 && Abilities.IsDisplayedAbility(abiID)) {
			AssignAbility(abiCont.FindChild(i), abiID)
		}
		else
			abiCont.FindChild(i).visible = false
	}

	let itemCont = panel.FindChildTraverse("ItemsContainer")
	for (let i = 0; i < 6; i++) {
		const abiID = Entities.GetItemInSlot(unitID, i)
		itemCont.FindChild(i).visible = true
		if (abiID != -1) {
			AssignAbility(itemCont.FindChild(i), abiID)
		}
		else
			itemCont.FindChild(i).visible = false
	}


}

function UpdatePanel(panel) {
	if (!panel.unitID) {
		panel.visible = false
		return
	}

	panel.visible = true

	const unitID = panel.unitID

	if (panel.BHasClass("Death")) {
		return
	}

	panel.FindChildTraverse("AbilityContainer").Children().forEach(panel => UpdateAbilityButton(panel))
	panel.FindChildTraverse("ItemsContainer").Children().forEach(panel => UpdateAbilityButton(panel))

	panel.SetHasClass("EnemyUnit", Entities.IsEnemy(unitID))
	panel.SetHasClass("Death", !Entities.IsAlive(unitID))

	/*let damage = Entities.GetDamageMax(unitID)+Entities.GetDamageMin(unitID)
	damage /= 2
	let stats = panel.FindChildTraverse("stats")
	stats.SetDialogVariableInt("damage", damage)
	const bonusDamage = Entities.GetDamageBonus(unitID)
	if (bonusDamage != 0) {
		if (bonusDamage > 0) {
			stats.SetDialogVariable("bonus_damage", "+"+bonusDamage)
			stats.FindChildTraverse("DamageLabelModifier").SetHasClass("StatPositive", true)
			stats.FindChildTraverse("DamageLabelModifier").SetHasClass("StatNegative", false)
		}
		else {
			stats.SetDialogVariable("bonus_damage", bonusDamage)
			stats.FindChildTraverse("DamageLabelModifier").SetHasClass("StatPositive", false)
			stats.FindChildTraverse("DamageLabelModifier").SetHasClass("StatNegative", true)
		}
		
	}
	else
		stats.SetDialogVariable("bonus_damage", "")

	const armor = Entities.GetPhysicalArmorValue(unitID)
	const bonusArmor = Entities.GetBonusPhysicalArmor(unitID)
	stats.SetDialogVariable("armor", armor)
	if (bonusArmor != 0)
		if (bonusArmor > 0) {
			stats.SetDialogVariable("bonus_armor", "+"+bonusArmor)
			stats.FindChildTraverse("ArmorModifierLabel").SetHasClass("StatPositive", true)
			stats.FindChildTraverse("ArmorModifierLabel").SetHasClass("StatNegative", false)
		}
		else {
			stats.SetDialogVariable("bonus_armor", bonusArmor)
			stats.FindChildTraverse("ArmorModifierLabel").SetHasClass("StatPositive", false)
			stats.FindChildTraverse("ArmorModifierLabel").SetHasClass("StatNegative", true)
		}
	else
		stats.SetDialogVariable("bonus_armor", "")

	const ms = Entities.GetBaseMoveSpeed(unitID)
	const bonusMS = 0  //Entities.GetMoveSpeedModifier( unitID, ms )
	stats.SetDialogVariableInt("base_move_speed", ms)
	if (bonusMS != 0)
		stats.SetDialogVariable("bonus_move_speed", "+"+bonusMS)
	else
		stats.SetDialogVariable("bonus_move_speed", "")

	let heroStats = panel.FindChildTraverse("stragiint")
	if (Entities.IsHero(unitID)) {
		heroStats.visible = true
	}
	else {
		heroStats.visible = false
	}*/



	let hpmana = panel.FindChildTraverse("health_mana")
	/*hpmana.FindChildTraverse("HealthLabel").text = Entities.GetHealth(unitID)+"/"+Entities.GetMaxHealth(unitID)
	
//$.Msg(Entities.GetHealthThinkRegen(unitID))
	const hpRegen = Entities.GetHealthThinkRegen(unitID)
	if (hpRegen == 0)
		hpmana.SetDialogVariable("health_regen", "")
	else
		hpmana.SetDialogVariable("health_regen", "+"+hpRegen)*/
	
	panel.FindChildTraverse("HealthProgress").value = Entities.GetHealthPercent(unitID)/100

	if (Entities.GetMaxMana(unitID) > 0) {
		hpmana.SetHasClass("ShowMana", true)

		//hpmana.FindChildTraverse("ManaLabel").text = Entities.GetMana(unitID)+"/"+Entities.GetMaxMana(unitID)
		panel.FindChildTraverse("ManaProgress").value = Entities.GetMana(unitID)/Entities.GetMaxMana(unitID)

		/*const manaRegen = Entities.GetManaThinkRegen(unitID).toFixed(1)
		if (manaRegen == 0 )
			hpmana.SetDialogVariable("mana_regen", "")
		else
			hpmana.SetDialogVariable("mana_regen", "+"+manaRegen)*/
	}
	else {
		hpmana.SetHasClass("ShowMana", false)
	}
}

function Update() {
	$.Schedule(0.05, Update)

	let leftUnits = $("#LeftUnits")
	leftUnits.Children().forEach(panel => UpdatePanel(panel))

	let rightUnits = $("#RightUnits")
	rightUnits.Children().forEach(panel => UpdatePanel(panel))
}

function NewRound(data) {
	const leftUnitsID = LuaTableToArray(data.indexes["left"])
	const rightUnitsID = LuaTableToArray(data.indexes["right"])
	let leftUnits = $("#LeftUnits")
	let rightUnits = $("#RightUnits")

	leftUnitsID.sort(function(a,b) {
		return Entities.GetMaxHealth(b) - Entities.GetMaxHealth(a)
	})

	rightUnitsID.sort(function(a,b) {
		return Entities.GetMaxHealth(b) - Entities.GetMaxHealth(a)
	})

	leftUnits.RemoveClass("Appear")
	leftUnits.AddClass("Hidden")
	rightUnits.RemoveClass("Appear")
	rightUnits.AddClass("Hidden")

	$.Schedule(1, function() {

		leftUnits.Children().forEach(panel => {
			const id = Number(panel.id)

			if (leftUnitsID[id]) 
				AssignUnit(panel, leftUnitsID[id])
			else
				panel.unitID = undefined
		})

		rightUnits.Children().forEach(panel => {
			const id = Number(panel.id)

			if (rightUnitsID[id]) 
				AssignUnit(panel, rightUnitsID[id])
			else
				panel.unitID = undefined
		})

	})
}

function StartFight() {
	let leftUnits = $("#LeftUnits")
	let rightUnits = $("#RightUnits")
	leftUnits.RemoveClass("Hidden")
	leftUnits.AddClass("Appear")
	rightUnits.RemoveClass("Hidden")
	rightUnits.AddClass("Appear")
}

(function() {

	let leftUnits = $("#LeftUnits")
	let rightUnits = $("#RightUnits")
	
	
	leftUnits.RemoveAndDeleteChildren()
	rightUnits.RemoveAndDeleteChildren()

	for (let i = 0; i < UNIT_COUNT; i++) {
		CreateUnitPanel(String(i), leftUnits)
		CreateUnitPanel(String(i), rightUnits)
	}

	GameEvents.Subscribe("new_round", NewRound);
	GameEvents.Subscribe("start_fight", StartFight);

	Update()
 
})()

function LuaTableToArray(nt) {
	var result = []
	for (var i in nt) {
		result[i-1] = nt[i]
	}
	return result
}