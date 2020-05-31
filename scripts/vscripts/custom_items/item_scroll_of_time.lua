function OnAddRoundTime(params)
	local caster = params.caster
	if(caster == nil or caster:IsNull()) then
		return
	end

	if(caster:GetUnitName() ~= "npc_dota_hero_elf") then
		return
	end

	if(GameRules.DW == nil) then
		return
	end

	if(GameRules.DW.StageName == nil or GameRules.DW.ExtraCountdown == nil) then
		return
	end

	if(GameRules.DW.StageName[GameRules.DW.Stage] ~= "PREPARE") then
		return
	end

	if(GameRules.DW.ExtraCountdown >= 60) then
		return
	end

	GameRules.DW.ExtraCountdown = GameRules.DW.ExtraCountdown + 30

	EmitGlobalSound("DDW.AddTime")

	UTIL_Remove(params.ability)
end