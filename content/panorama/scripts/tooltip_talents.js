
function SetupTooltip() {
	const heroID = $.GetContextPanel().GetAttributeInt("heroID", -1)
	const firstTalent = GetHeroFirstTalentID(heroID)

	if (firstTalent != -1) {
		for (let i = 1; i <= 8; i++) {
			const ability = Entities.GetAbility(heroID, firstTalent+(i-1))
			const text = "DOTA_Tooltip_ability_" + Abilities.GetAbilityName(ability)

			const panel = $.GetContextPanel().FindChildTraverse("Upgrade"+i)
			panel.SetHasClass("BranchChosen", Abilities.GetLevel(ability) > 0)
			
			const label = panel.FindChildTraverse("UpgradeName"+i)
			label.SetDialogVariable("value", +Abilities.GetLevelSpecialValueFor(ability, "value", 1).toFixed(2))
			label.text = $.Localize(text, label)	
		}
	}

}

(function() {
})()

function GetHeroFirstTalentID(heroID) {
	for (let i = 0; i < 24; i++) {
		const abilityName = Abilities.GetAbilityName(Entities.GetAbility(heroID, i))

		if (abilityName.includes("special_bonus"))
			return i
	}

	return -1
}
