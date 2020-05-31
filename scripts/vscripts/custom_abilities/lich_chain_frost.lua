ddw_lich_chain_frost = class({})
LinkLuaModifier("modifier_ddw_chain_frost_slow", "custom_abilities/lich_chain_frost", LUA_MODIFIER_MOTION_NONE)

function ddw_lich_chain_frost:GetAbilityTextureName()
	return "lich_chain_frost"
end

function ddw_lich_chain_frost:IsHiddenWhenStolen()
	return false
end

function ddw_lich_chain_frost:CastFilterResultTarget(target)
	if IsServer() then
		local nResult = UnitFilter(target, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), self:GetCaster():GetTeamNumber())
		return nResult
	end
end

function ddw_lich_chain_frost:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()

	self:LaunchProjectile(caster, target)
end

function ddw_lich_chain_frost:LaunchProjectile(source, target)
	local caster = self:GetCaster()
	local ability = self
	local sound_cast = "Hero_Lich.ChainFrost"
	local particle_projectile = "particles/units/heroes/hero_lich/lich_chain_frost.vpcf"
	local scepter = caster:HasScepter()

	local projectile_speed = ability:GetSpecialValueFor("projectile_speed")
	local vision_radius = ability:GetSpecialValueFor("vision_radius")
	local jumps = ability:GetSpecialValueFor("jumps")

	EmitSoundOn(sound_cast, caster)

	if scepter then
		jumps = jumps + 15
	end

	local chain_frost_projectile
	chain_frost_projectile = {Target = target,
		Source = source,
		Ability = ability,
		EffectName = particle_projectile,
		iMoveSpeed = projectile_speed,
		bDodgeable = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		bProvidesVision = true,
		iVisionRadius = vision_radius,
		iVisionTeamNumber = caster:GetTeamNumber(),
		ExtraData = {bounces_left = jumps, projectile_speed = projectile_speed}
	}

	ProjectileManager:CreateTrackingProjectile(chain_frost_projectile)
end

function ddw_lich_chain_frost:OnProjectileHit_ExtraData(target, location, extradata)
	local caster = self:GetCaster()
	local ability = self
	local sound_hit = "Hero_Lich.ChainFrostImpact.Creep"
	local particle_projectile = "particles/units/heroes/hero_lich/lich_chain_frost.vpcf"
	local modifier_slow = "modifier_ddw_chain_frost_slow"

	local slow_duration = ability:GetSpecialValueFor("slow_duration")
	local jump_range = ability:GetSpecialValueFor("jump_range")
	local damage = ability:GetSpecialValueFor("damage")
	local projectile_delay = ability:GetSpecialValueFor("projectile_delay")
	local vision_radius = ability:GetSpecialValueFor("vision_radius")
	local bonus_projectiles = ability:GetSpecialValueFor("bonus_projectiles")
	local projectiles_damage_pct = ability:GetSpecialValueFor("projectiles_damage_pct")

	if not target then return nil end

	EmitSoundOn("Hero_Lich.ChainFrostImpact.Hero", target)

	CreateTimer(function() 
		if extradata.bounces_left <= 0 then
			return nil
		end

		if(caster == nil or caster:IsNull() or target == nil or target:IsNull()) then
			return nil
		end

		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
			target:GetAbsOrigin(),
			nil,
			jump_range,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			FIND_ANY_ORDER,
			false)

		for i = #enemies, 1, -1 do
			if enemies[i] ~= nil and (target == enemies[i] or enemies[i]:GetName() == "npc_dota_unit_undying_zombie") then
				table.remove(enemies, i)
			end
		end

		if #enemies <= 0 then
			return nil
		end

		local bounces_left = extradata.bounces_left - 1

		local bounce_target = enemies[1]
		
		local chain_frost_projectile
		chain_frost_projectile = {Target = bounce_target,
			Source = target,
			Ability = ability,
			EffectName = particle_projectile,
			iMoveSpeed = extradata.projectile_speed,
			bDodgeable = false,
			bVisibleToEnemies = true,
			bReplaceExisting = false,
			bProvidesVision = true,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber(),
			ExtraData = {bounces_left = bounces_left, projectile_speed = extradata.projectile_speed}
		}

		ProjectileManager:CreateTrackingProjectile(chain_frost_projectile)

	end, projectile_delay)

	if target:GetTeam() ~= caster:GetTeam() then
	    if ((not self:GetCaster():HasScepter() and extradata.bounces_left == self:GetSpecialValueFor("jumps"))
		or (self:GetCaster():HasScepter() and extradata.bounces_left == self:GetSpecialValueFor("jumps") + 15))
		and target:TriggerSpellAbsorb(ability) then
			return nil
		end
	end

	if target:IsMagicImmune() then
		return nil
	end

	local damageTable = {victim = target,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		attacker = caster,
		ability = ability
	}

	ApplyDamage(damageTable)

	if(target ~= nil and target:IsNull() == false and caster ~= nil and caster:IsNull() == false) then
		target:AddNewModifier(caster, ability, modifier_slow, {duration = slow_duration})
	end
end

modifier_ddw_chain_frost_slow = class({})

function modifier_ddw_chain_frost_slow:OnCreated()
	self.caster = self:GetCaster()
	
	self.slow_movement_speed = 65
	self.slow_attack_speed = 65

	self.ability = self:GetAbility()
	if(self.ability ~= nil) then
		self.slow_movement_speed = self.ability:GetSpecialValueFor("slow_movement_speed")
		self.slow_attack_speed = self.ability:GetSpecialValueFor("slow_attack_speed")
	end
end

function modifier_ddw_chain_frost_slow:IsHidden() return false end
function modifier_ddw_chain_frost_slow:IsPurgable() return true end
function modifier_ddw_chain_frost_slow:IsDebuff() return true end

function modifier_ddw_chain_frost_slow:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}

	return decFuncs
end

function modifier_ddw_chain_frost_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow_movement_speed * (-1)
end

function modifier_ddw_chain_frost_slow:GetModifierAttackSpeedBonus_Constant()
	return self.slow_attack_speed * (-1)
end