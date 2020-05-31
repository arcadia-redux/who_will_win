item_diffusal_blade_2 = item_diffusal_blade_2 or class({})

function item_diffusal_blade_2:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()
	local sound_cast = "DOTA_Item.DiffusalBlade.Activate"
	local sound_target = "DOTA_Item.DiffusalBlade.Target"
	local particle_target = "particles/generic_gameplay/generic_manaburn.vpcf"
	local modifier_purge = "modifier_item_diffusal_blade_slow"

	local total_slow_duration = ability:GetSpecialValueFor("purge_slow_duration")

	EmitSoundOn(sound_cast, caster)

	local particle_target_fx = ParticleManager:CreateParticle(particle_target, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle_target_fx, 0, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_target_fx)

	if target:GetTeam() ~= caster:GetTeam() then
		if target:TriggerSpellAbsorb(ability) then
			return nil
		end
	end

	if target:IsMagicImmune() then
		return nil
	end

	EmitSoundOn(sound_target, target)

	target:Purge(true, false, false, false, false)

	target:AddNewModifier(caster, ability, modifier_purge, {duration = total_slow_duration})
end

function item_diffusal_blade_2:GetIntrinsicModifierName()
	return "modifier_item_diffusal_blade"
end