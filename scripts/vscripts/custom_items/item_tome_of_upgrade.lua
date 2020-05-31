item_tome_of_upgrade = item_tome_of_upgrade or class({})

function item_tome_of_upgrade:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if(caster == nil or caster:IsNull()) then
		return
	end

	if(caster:GetUnitName() ~= "npc_dota_hero_elf") then
		return
	end

	if(target == nil or target:IsNull()) then
		return
	end

	if(target:GetUnitName() == "npc_dota_hero_elf") then
		return
	end

	if(target.IsRealHero == nil or target:IsRealHero() == false) then
		return
	end

	if(target.GetLevel == nil or target:GetLevel() ~= 25) then
		return
	end

	target:HeroLevelUp(false)
	target:HeroLevelUp(false)
	target:HeroLevelUp(false)
	target:HeroLevelUp(false)
	target:HeroLevelUp(false)

	local particleID = ParticleManager:CreateParticle("particles/generic_hero_status/hero_levelup.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)

	ParticleManager:ReleaseParticleIndex(particleID)

	if(caster.GetPlayerOwner ~= nil) then
		local player = caster:GetPlayerOwner()
		if(player ~= nil and player:IsNull() == false) then
			EmitSoundOnClient("General.LevelUp.Bonus", player)
		end
	end

	UTIL_Remove(self)
end