ddw_dark_seer_wall_of_replica						= class({})
modifier_ddw_dark_seer_wall_of_replica				= class({})
modifier_ddw_dark_seer_wall_of_replica_slow		= class({})
LinkLuaModifier("modifier_ddw_dark_seer_wall_of_replica", "custom_abilities/dark_seer_wall_of_replica", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ddw_dark_seer_wall_of_replica_slow", "custom_abilities/dark_seer_wall_of_replica", LUA_MODIFIER_MOTION_NONE)

function ddw_dark_seer_wall_of_replica:OnSpellStart()
	if not IsServer() then return end
	
	local duration = self:GetSpecialValueFor("duration")
	
	EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "Hero_Dark_Seer.Wall_of_Replica_Start", self:GetCaster())
	
	CreateModifierThinker(self:GetCaster(), self, "modifier_ddw_dark_seer_wall_of_replica", {
		duration		= duration,
		x				= self:GetCursorPosition().x,
		y				= self:GetCursorPosition().y,
		rotation		= 90
	}, 
	self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
end

function modifier_ddw_dark_seer_wall_of_replica:OnCreated(params)
	self.width					= 1000
	self.slow_duration			= 1.0
	self.movement_slow			= 50

	self.ability = self:GetAbility()
	if(self.ability ~= nil) then
		self.width					= self.ability:GetSpecialValueFor("width")
		self.slow_duration			= self.ability:GetSpecialValueFor("slow_duration")
		self.movement_slow			= self.ability:GetSpecialValueFor("movement_slow")
	end
	
	if not IsServer() then return end
	
	self:GetParent():EmitSound("Hero_Dark_Seer.Wall_of_Replica_lp")
	
	self.rotation		= params.rotation
	
	self.cursor_position	= GetGroundPosition(Vector(params.x, params.y, 0), nil)
	
	self.distance_vector	= self.cursor_position - self:GetCaster():GetAbsOrigin()

	self.wall_vector		= RotatePosition(Vector(0, 0, 0), QAngle(0, params.rotation, 0), self.distance_vector:Normalized())
	
	self.wall_start 		= self.cursor_position + self.wall_vector * self.width * 0.5
	self.wall_end			= self.cursor_position - self.wall_vector * self.width * 0.5
	
	self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_wall_of_replica.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(self.particle, 0, self.wall_start)
	ParticleManager:SetParticleControl(self.particle, 1, self.wall_end)
	ParticleManager:SetParticleControl(self.particle, 61, Vector(0, 0, 0))
	
	self:AddParticle(self.particle, false, false, -1, false, false)
	
	self:StartIntervalThink(0.1)
end

function modifier_ddw_dark_seer_wall_of_replica:OnIntervalThink()
	if not IsServer() then return end

	local enemies = FindUnitsInLine(self:GetCaster():GetTeamNumber(), self.wall_start, self.wall_end, nil, 80, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)
	
	for _, enemy in pairs(enemies) do
		local wall_slow_modifier = enemy:FindModifierByNameAndCaster("modifier_ddw_dark_seer_wall_of_replica_slow", self:GetParent())
		
		if wall_slow_modifier then
			wall_slow_modifier:SetDuration(self.slow_duration * (1 - enemy:GetStatusResistance()), true)
		else
			enemy:AddNewModifier(self:GetParent(), self.ability, "modifier_ddw_dark_seer_wall_of_replica_slow", {duration = self.slow_duration, movement_slow = self.movement_slow}):SetDuration(self.slow_duration * (1 - enemy:GetStatusResistance()), true)
		end
	end
end

function modifier_ddw_dark_seer_wall_of_replica:OnDestroy()
	if not IsServer() then return end

	self:GetParent():StopSound("Hero_Dark_Seer.Wall_of_Replica_lp")
end

function modifier_ddw_dark_seer_wall_of_replica_slow:GetStatusEffectName()
	return "particles/status_fx/status_effect_dark_seer_illusion.vpcf"
end

function modifier_ddw_dark_seer_wall_of_replica_slow:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_ddw_dark_seer_wall_of_replica_slow:OnCreated(params)
	if not IsServer() then return end

	self.scepter_damage = 100
	self.ability = self:GetAbility()

	if(self.ability ~= nil) then
		self.scepter_damage = self.ability:GetSpecialValueFor("scepter_damage")
	end
	self:SetStackCount(params.movement_slow)
	self:StartIntervalThink(0.5)
end

function modifier_ddw_dark_seer_wall_of_replica_slow:OnIntervalThink()
	if not IsServer() then return end

	if(self.ability == nil) then return end

	local victim = self:GetParent()
	if(victim == nil or victim:IsNull()) then return end

	local attacker = self.ability:GetCaster()

	if(attacker == nil or attacker:IsNull() or attacker.FindAbilityByName == nil) then
        return
    end

    local hasUltimateTalent = false
    local checkTalent = attacker:FindAbilityByName("special_bonus_dark_seer_wall_of_replica_upgrade")
    if(checkTalent ~= nil and checkTalent:GetLevel() > 0) then
        hasUltimateTalent = true
    end

    if victim:IsMagicImmune() == true and hasUltimateTalent == false then
		return
	end

	victim:Purge(true, false, false, false, false)

	if not victim:IsInvulnerable() then
		if(attacker ~= nil and attacker:IsNull() == false) then
			if(attacker.HasScepter ~= nil and attacker:HasScepter()) then
				local damageTable = {
					victim = victim,
					damage = self.scepter_damage * 0.5,
					damage_type = DAMAGE_TYPE_PURE,
					attacker = attacker,
					ability = self.ability
				}
				ApplyDamage(damageTable)
			end
		end
	end
	
	self:StartIntervalThink(0.5)
end

function modifier_ddw_dark_seer_wall_of_replica_slow:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
    }

    return decFuncs
end

function modifier_ddw_dark_seer_wall_of_replica_slow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetStackCount() * (-1)
end