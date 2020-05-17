"use strict";

function CreateAbilityButton(ability, parent, id) {
	let panel = $.CreatePanel("DOTAAbilityPanel", parent, id)
	panel.AddClass("AbilityButton")  
	panel.overrideentityindex = ability

	panel.style.width = "40px"
	panel.style.height = "40px"
	panel.style.verticalAlign = "top"

	panel.FindChildTraverse("ManaCost").style.fontSize = "10px"

	return panel
}

function CreateUnitPanel(id, parent) {
	let panel = $.CreatePanel("Panel", parent, id)
	panel.AddClass("UnitPanel")
	panel.BLoadLayoutSnippet("UnitInfo")
	
	let stats = panel.FindChildTraverse("stats")
	stats.BLoadLayoutSnippet("Stats")

	let heroStats = panel.FindChildTraverse("stragiint")
	heroStats.BLoadLayoutSnippet("StrAgiInt")

	let abiCont = panel.FindChildTraverse("AbilityContainer")
	abiCont.RemoveAndDeleteChildren()
	
	CreateAbilityButton(-1, abiCont, "0")
	CreateAbilityButton(-1, abiCont, "1")
	CreateAbilityButton(-1, abiCont, "2")
	CreateAbilityButton(-1, abiCont, "3")
	CreateAbilityButton(-1, abiCont, "4")
	CreateAbilityButton(-1, abiCont, "5")
	//CreateAbilityButton(-1, abiCont, "6")
	//CreateAbilityButton(-1, abiCont, "7")

	return panel
}

function AssignUnit(panel, unitID) {
	panel.unitID = unitID

	const unitName = Entities.GetUnitName(unitID)

	panel.SetHasClass("Death", false)

	panel.FindChildTraverse("UnitNameLabel").text = $.Localize(unitName)
	panel.FindChildTraverse("UnitPortrait").SetUnit(unitName, "default", true)

	let abiCont = panel.FindChildTraverse("AbilityContainer")
	for (let i = 0; i < 6; i++) {
		const abiID = Entities.GetAbility( unitID, i )
		if (abiID != -1 && Abilities.IsDisplayedAbility(abiID))
			abiCont.FindChild(i).overrideentityindex = abiID
		else
			abiCont.FindChild(i).visible = false

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

	let damage = Entities.GetDamageMax(unitID)+Entities.GetDamageMin(unitID)
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
	}



	let hpmana = panel.FindChildTraverse("health_mana")
	hpmana.FindChildTraverse("HealthLabel").text = Entities.GetHealth(unitID)+"/"+Entities.GetMaxHealth(unitID)
	
//$.Msg(Entities.GetHealthThinkRegen(unitID))
	const hpRegen = Entities.GetHealthThinkRegen(unitID)
	if (hpRegen == 0)
		hpmana.SetDialogVariable("health_regen", "")
	else
		hpmana.SetDialogVariable("health_regen", "+"+hpRegen)
	
	panel.FindChildTraverse("HealthProgress").value = Entities.GetHealthPercent(unitID)/100

	if (Entities.GetMaxMana(unitID) > 0) {
		hpmana.SetHasClass("ShowMana", true)

		hpmana.FindChildTraverse("ManaLabel").text = Entities.GetMana(unitID)+"/"+Entities.GetMaxMana(unitID)
		panel.FindChildTraverse("ManaProgress").value = Entities.GetMana(unitID)/Entities.GetMaxMana(unitID)

		const manaRegen = Entities.GetManaThinkRegen(unitID).toFixed(1)
		if (manaRegen == 0 )
			hpmana.SetDialogVariable("mana_regen", "")
		else
			hpmana.SetDialogVariable("mana_regen", "+"+manaRegen)
	}
	else {
		hpmana.SetHasClass("ShowMana", false)
	}

	panel.SetHasClass("Death", !Entities.IsAlive(unitID))
	


}

function Update() {
	$.Schedule(0.1, Update)

	let leftUnits = $("#LeftUnits")
	leftUnits.Children().forEach(panel => UpdatePanel(panel))

	let rightUnits = $("#RightUnits")
	rightUnits.Children().forEach(panel => UpdatePanel(panel))
}

function NewRound(data) {
	$.Msg("!")
	const leftUnitsID = data.indexes["left"]
	const rightUnitsID = data.indexes["right"]
	let leftUnits = $("#LeftUnits")
	let rightUnits = $("#RightUnits")

	leftUnits.RemoveClass("Appear")
	leftUnits.AddClass("Hidden")
	rightUnits.RemoveClass("Appear")
	rightUnits.AddClass("Hidden")

	$.Schedule(1, function() {

		leftUnits.Children().forEach(panel => {
			const id = Number(panel.id) + 1

			if (leftUnitsID[id]) 
				AssignUnit(panel, leftUnitsID[id])
			else
				panel.unitID = undefined
		})

		rightUnits.Children().forEach(panel => {
			const id = Number(panel.id) + 1

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
	
	CreateUnitPanel("0", leftUnits)
	CreateUnitPanel("1", leftUnits)
	CreateUnitPanel("2", leftUnits)
	CreateUnitPanel("3", leftUnits)
	CreateUnitPanel("4", leftUnits)
	CreateUnitPanel("5", leftUnits)
	CreateUnitPanel("6", leftUnits)
	CreateUnitPanel("7", leftUnits)
	CreateUnitPanel("8", leftUnits)
	CreateUnitPanel("9", leftUnits)
	CreateUnitPanel("10", leftUnits)
	CreateUnitPanel("11", leftUnits)
	CreateUnitPanel("12", leftUnits)
	CreateUnitPanel("13", leftUnits)

	CreateUnitPanel("0", rightUnits)
	CreateUnitPanel("1", rightUnits)
	CreateUnitPanel("2", rightUnits)
	CreateUnitPanel("3", rightUnits)
	CreateUnitPanel("4", rightUnits)
	CreateUnitPanel("5", rightUnits)
	CreateUnitPanel("6", rightUnits)
	CreateUnitPanel("7", rightUnits)
	CreateUnitPanel("8", rightUnits)
	CreateUnitPanel("9", rightUnits)
	CreateUnitPanel("10", rightUnits)
	CreateUnitPanel("11", rightUnits)
	CreateUnitPanel("12", rightUnits)
	CreateUnitPanel("13", rightUnits)


	GameEvents.Subscribe("new_round", NewRound);
	GameEvents.Subscribe("start_fight", StartFight);

	Update()



 
})()