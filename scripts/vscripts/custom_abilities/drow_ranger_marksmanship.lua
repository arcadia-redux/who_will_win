ddw_drow_ranger_marksmanship = class({})
LinkLuaModifier("modifier_ddw_marksmanship", "custom_abilities/drow_ranger_marksmanship", LUA_MODIFIER_MOTION_NONE)

function GetReductionFromArmor(armor)
	return ( 0.052 * armor ) / ( 0.9 + 0.048 * armor)
end

function CalculateReductionFromArmor_Percentage(armorOffset, armor)
	return -GetReductionFromArmor(armor) + GetReductionFromArmor(armorOffset)
end

function ddw_drow_ranger_marksmanship:GetIntrinsicModifierName()
	return "modifier_ddw_marksmanship"
end

function ddw_drow_ranger_marksmanship:OnUpgrade()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self
		local modifier_markx = "modifier_ddw_marksmanship"

		if caster:HasModifier(modifier_markx) then
			caster:RemoveModifierByName(modifier_markx)
			caster:AddNewModifier(caster, ability, modifier_markx, {})
		end
	end
end

modifier_ddw_marksmanship = class({})

function modifier_ddw_marksmanship:OnCreated()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.particle_start = "particles/units/heroes/hero_drow/drow_marksmanship_start.vpcf"
	self.particle_marksmanship = "particles/units/heroes/hero_drow/drow_marksmanship.vpcf"

	self.disable_range = 400
	self.splinter_radius_scepter = 375
	self.proc_chance = 50
	self.bonus_damage = 100

	if(self.ability ~= nil) then
		self.disable_range = self.ability:GetSpecialValueFor("disable_range")
		self.splinter_radius_scepter = self.ability:GetSpecialValueFor("splinter_radius_scepter")
		self.proc_chance = self.ability:GetSpecialValueFor("proc_chance")
		self.bonus_damage = self.ability:GetSpecialValueFor("bonus_damage")
	end

	if IsServer() then
		self.marksmanship_enabled = false
		self:StartIntervalThink(0.25)
	end
end

function modifier_ddw_marksmanship:OnIntervalThink()
	if IsServer() then
		local enemies = FindUnitsInRadius(
			self.caster:GetTeamNumber(),
			self.caster:GetAbsOrigin(),
			self.caster,
			self.disable_range,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,
			0,
			true
		)

		local hasUltimateTalent = false
	    local checkTalent = self.caster:FindAbilityByName("special_bonus_drow_ranger_marksmanship_upgrade")
	    if(checkTalent ~= nil and checkTalent:GetLevel() > 0) then
	        hasUltimateTalent = true
	    end

		if hasUltimateTalent == false then
			if #enemies > 0 and self.marksmanship_enabled then
				ParticleManager:DestroyParticle(self.particle_marksmanship_fx, false)
				ParticleManager:ReleaseParticleIndex(self.particle_marksmanship_fx)

				self.marksmanship_enabled = false
			end
		end

		if not self.marksmanship_enabled and (#enemies == 0 or hasUltimateTalent) then
			self.particle_start_fx = ParticleManager:CreateParticle(self.particle_start, PATTACH_ABSORIGIN, self.caster)
			ParticleManager:SetParticleControl(self.particle_start_fx, 0, self.caster:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(self.particle_start_fx)

			self.particle_marksmanship_fx = ParticleManager:CreateParticle(self.particle_marksmanship, PATTACH_ABSORIGIN_FOLLOW, self.caster)
			ParticleManager:SetParticleControl(self.particle_marksmanship_fx, 0, self.caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.particle_marksmanship_fx, 2, Vector(2,0,0))
			ParticleManager:SetParticleControl(self.particle_marksmanship_fx, 3, self.caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.particle_marksmanship_fx, 5, self.caster:GetAbsOrigin())

			self.marksmanship_enabled = true
		end

		self.caster:CalculateStatBonus()
	end
end

function modifier_ddw_marksmanship:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PROJECTILE_NAME
	}
end

function modifier_ddw_marksmanship:GetModifierProjectileName()
	if self:GetStackCount() == 1 then
		return self:GetParent().marksmanship_arrow_pfx
	end
end

function modifier_ddw_marksmanship:OnAttackStart(keys)
	if IsServer() then
		local target = keys.target
		local attacker = keys.attacker

		if(target == nil or target:IsNull() or attacker == nil or attacker:IsNull()) then
			return
		end

		if self.caster == attacker then
			if not self.caster:IsIllusion() and RollPercentage(self.proc_chance) and self.marksmanship_enabled and not self.caster:PassivesDisabled() and (not target:IsBuilding() and not target:IsOther() and attacker:GetTeamNumber() ~= target:GetTeamNumber()) then
				self:SetStackCount(1)
			end
		end
	end
end

function modifier_ddw_marksmanship:GetModifierTotalDamageOutgoing_Percentage( params )
	if IsServer() then
		if not self.caster:IsIllusion() and params.target and not params.inflictor and self:GetStackCount() == 1 then
			if params.target:IsBuilding() or params.target:IsOther() or params.attacker:GetTeamNumber() == params.target:GetTeamNumber() then
			elseif params.target:IsConsideredHero() then
				local armor = params.target:GetPhysicalArmorValue(false)
				local real_damage = 0

				if armor > 0 then
					real_damage = CalculateReductionFromArmor_Percentage((armor - armor), armor)
				end

				if(real_damage == nil) then
					real_damage = 0
				end

				self:SetStackCount(0)

				local damageTable = {
					victim 			= params.target,
					damage 			= self.bonus_damage,
					damage_type		= DAMAGE_TYPE_PHYSICAL,
					damage_flags 	= DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL,
					attacker 		= self.caster,
					ability 		= self.ability
				}
									
				ApplyDamage(damageTable)
				
				return (100 / math.max((1 + real_damage), 0.001)) - 100
			else
				params.target:Kill(self.ability, params.attacker)
			end

			self:SetStackCount(0)
			params.target:EmitSound("Hero_DrowRanger.Marksmanship.Target")
		end

		return 0
	end
end

function modifier_ddw_marksmanship:OnAttackLanded(keys)
	if IsServer() then
		if self.caster:IsNull() then return end
	
		local scepter = self.caster:HasScepter()
		local target = keys.target
		local attacker = keys.attacker

		if self.caster == attacker then
			if scepter then
				local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(),
					target:GetAbsOrigin(),
					nil,
					self.splinter_radius_scepter,
					DOTA_UNIT_TARGET_TEAM_ENEMY,
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
					FIND_ANY_ORDER,
					false)

				if #enemies > 0 then
					for _,enemy in pairs(enemies) do
						if enemy ~= target then
							local arrow_projectile

							arrow_projectile = {hTarget = enemy,
								hCaster = target,
								hAbility = self.ability,
								iMoveSpeed = self.caster:GetProjectileSpeed(),
								EffectName = self.caster:GetRangedProjectileName(),
								SoundName = "",
								flRadius = 1,
								bDodgeable = true,
								bDestroyOnDodge = true,
								iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
								OnProjectileHitUnit = function(params, projectileID)
									SplinterArrowHit(params, projectileID, self)
								end
							}

							TrackingProjectiles:Projectile(arrow_projectile)
						end
					end
				end
			end
		end
	end
end

function SplinterArrowHit(keys, projectileID, modifier)
	local caster = modifier.caster
	local target = keys.hTarget

	if(caster ~= nil and caster:IsNull() == false and target ~= nil and target:IsNull() == false) then
		caster:PerformAttack(target, false, false, true, true, false, false, false)
	end
end

function modifier_ddw_marksmanship:IsPurgable()
	return false
end

function modifier_ddw_marksmanship:IsHidden()
	return true
end

function modifier_ddw_marksmanship:IsDebuff()
	return false
end

function modifier_ddw_marksmanship:OnDestroy()
	if self.particle_marksmanship_fx then
		ParticleManager:DestroyParticle(self.particle_marksmanship_fx, false)
		ParticleManager:ReleaseParticleIndex(self.particle_marksmanship_fx)
	end
end