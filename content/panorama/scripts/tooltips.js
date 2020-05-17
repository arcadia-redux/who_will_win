var alt=false,unit
const tooltipPanel = $.GetContextPanel()
function SetupTooltip() {
	unit = tooltipPanel.GetAttributeInt("unit",-1)
	if(unit && unit!=-1){
		SetupUnit()
	}
}
function SetupUnit() {
	tooltipPanel.RemoveAndDeleteChildren()
	tooltipPanel.style.padding = '0 0 0 0'
	tooltipPanel.style.boxShadow = 'none'
	tooltipPanel.style.border = '0px solid #111111FF;'
    var tooltip = $.CreatePanel( "Panel", tooltipPanel, "UnitTooltip" )
		tooltip.BLoadLayoutSnippet('UnitTooltip'),
		at = Entities.GetBaseAttackTime(unit) / Entities.GetAttackSpeed(unit),
		bd = Math.round(Entities.GetDamageBonus(unit)),
		ua = Entities.GetPhysicalArmorValue(unit),
		ba = Entities.GetBonusPhysicalArmor(unit)
		// hpLabel = $.Localize("#DOTA_Health").toLowerCase()+':'
	tooltipPanel.FindChildTraverse('AttackSpeed').text = Math.round(1.7/at* 100)
	tooltipPanel.FindChildTraverse('AttacksPerSecond').text = "("+at.toFixed(2)+"s)";
	tooltipPanel.FindChildTraverse('Damage').text = Math.round(Entities.GetDamageMin(unit)) + "-" + Math.round(Entities.GetDamageMax(unit));
	tooltipPanel.FindChildTraverse('DamageBonus').text = bd?"+"+bd:'';
	tooltipPanel.FindChildTraverse('Range').text = Entities.GetAttackRange(unit);
	tooltipPanel.FindChildTraverse('Armor').text = ua.toFixed(1);
	tooltipPanel.FindChildTraverse('ArmorBonus').text = ba?"+"+ba.toFixed(1):'';
	tooltipPanel.FindChildTraverse('PhysicalResist').text = (((0.06 * ua) / (1 + 0.06 * ua)) * 100).toFixed(2) + "%";
	tooltipPanel.FindChildTraverse('MagicResist').text = (Entities.GetMagicalArmorValue(unit)*100).toFixed(2) + "%";
	// tooltipPanel.FindChildTraverse('HealthRegen').text = Entities.GetHealthThinkRegen(unit).toFixed(2);
	// tooltipPanel.FindChildTraverse('HealthLabel').text = hpLabel[0].toUpperCase() + hpLabel.substring(1)
	// tooltipPanel.FindChildTraverse('Health').text = Entities.GetMaxHealth(unit)
}
(function() {
})()