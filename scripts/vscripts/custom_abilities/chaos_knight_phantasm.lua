ddw_chaos_knight_phantasm = class({})
LinkLuaModifier("modifier_chaos_knight_phantasm_cast", "custom_abilities/chaos_knight_phantasm", LUA_MODIFIER_MOTION_NONE)

function ddw_chaos_knight_phantasm:GetAbilityTextureName()
	return "chaos_knight_phantasm"
end

function ddw_chaos_knight_phantasm:IsHiddenWhenStolen()
	return false
end

function ddw_chaos_knight_phantasm:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end

	return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function ddw_chaos_knight_phantasm:GetCooldown(nLevel)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("cooldown_scepter") 
	end

	return self.BaseClass.GetCooldown(self, nLevel)
end

function ddw_chaos_knight_phantasm:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local ability = self

		local invulnerability_duration = ability:GetSpecialValueFor("invuln_duration")

		if caster ~= target then
			if caster:HasScepter() and target ~= nil and target:IsNull() == false then
				caster:AddNewModifier(target, ability, "modifier_chaos_knight_phantasm_cast", { duration = invulnerability_duration })
				EmitSoundOn("Hero_ChaosKnight.Phantasm", target)
			else
				caster:AddNewModifier(caster, ability, "modifier_chaos_knight_phantasm_cast", { duration = invulnerability_duration })
				EmitSoundOn("Hero_ChaosKnight.Phantasm", caster)
			end
		else
			caster:AddNewModifier(caster, ability, "modifier_chaos_knight_phantasm_cast", { duration = invulnerability_duration })
			EmitSoundOn("Hero_ChaosKnight.Phantasm", caster)
		end
	end
end

modifier_chaos_knight_phantasm_cast = class({})

function modifier_chaos_knight_phantasm_cast:IsHidden()
	return true
end

function modifier_chaos_knight_phantasm_cast:CheckState()
	local state =
		{
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_OUT_OF_GAME] = true,
		}

	return state
end

function modifier_chaos_knight_phantasm_cast:OnCreated()
	if not IsServer() then
		return
	end

	self.phantasm_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_chaos_knight/chaos_knight_phantasm.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
end

function modifier_chaos_knight_phantasm_cast:OnDestroy()
	if not IsServer() then
		return
	end

	local ability = self:GetAbility()

	if(ability == nil or ability:IsNull()) then
		return
	end

	local images_count = ability:GetSpecialValueFor("images_count")
	local duration = ability:GetSpecialValueFor("illusion_duration")
	local outgoingDamage = ability:GetSpecialValueFor("outgoing_damage")
	local incomingDamage = ability:GetSpecialValueFor("incoming_damage")

	local castTarget = self:GetCaster()

	if(castTarget == nil or castTarget:IsNull()) then
		return
	end

	castTarget:Purge(false, true, false, false, false)

	if castTarget.phantasm_illusions ~= nil then
		for k,v in pairs(castTarget.phantasm_illusions) do
			if v and v:IsNull() == false and IsValidEntity(v) then
				v:ForceKill(false)
			end
		end
	end

	EmitSoundOn("Hero_ChaosKnight.Phantasm.Plus", castTarget)

	castTarget.phantasm_illusions = CreateIllusions(castTarget, castTarget, 
		{
				outgoing_damage = outgoingDamage,
				incoming_damage	= incomingDamage,
				bounty_base		= 0,
				bounty_growth	= nil,
				outgoing_damage_structure	= nil,
				outgoing_damage_roshan		= nil,
				duration		= duration
		}, images_count, castTarget:GetHullRadius(), true, true)

	if(self.phantasm_particle ~= nil) then
		ParticleManager:DestroyParticle(self.phantasm_particle, true)
		ParticleManager:ReleaseParticleIndex(self.phantasm_particle)
		self.phantasm_particle = nil
	end
end