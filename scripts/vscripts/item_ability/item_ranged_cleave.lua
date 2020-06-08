
item_ranged_cleave = class({})

LinkLuaModifier("modifier_item_ranged_cleave", "item_ability/item_ranged_cleave", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_ranged_cleave_reduced_damage", "item_ability/item_ranged_cleave", LUA_MODIFIER_MOTION_NONE)


function item_ranged_cleave:GetIntrinsicModifierName()
	return "modifier_item_ranged_cleave"
end



modifier_item_ranged_cleave = class({})

function modifier_item_ranged_cleave:IsDebuff() return false end
function modifier_item_ranged_cleave:IsHidden() return true end
function modifier_item_ranged_cleave:IsPurgable() return false end
function modifier_item_ranged_cleave:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_item_ranged_cleave:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS_UNIQUE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}
	return funcs
end

function modifier_item_ranged_cleave:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_item_ranged_cleave:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_agi")
end

function modifier_item_ranged_cleave:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_dmg")
end

function modifier_item_ranged_cleave:GetModifierAttackRangeBonusUnique()
	if self:GetParent():IsRangedAttacker() then
		return self:GetAbility():GetSpecialValueFor("bonus_range")
	else
		return 0
	end
end

function modifier_item_ranged_cleave:GetModifierDamageOutgoing_Percentage()
	if not IsServer() then return end
	
	if self.bSplitShot then
		return self:GetAbility():GetSpecialValueFor("split_shot_damage")
	else
		return 0
	end
end


function modifier_item_ranged_cleave:OnAttack(keys)
	if not IsServer() then return end

	-- not keys.no_attack_cooldown 排除物品本身，排除其他各种分裂效果
    if keys.attacker == self:GetParent() then
       --PrintTable(keys)
    end
	if keys.attacker == self:GetParent() and self:GetParent():IsRangedAttacker() and keys.target and keys.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and not keys.no_attack_cooldown then	
		
		if not self:GetParent():HasFlyMovementCapability() and  not self:GetParent():IsIllusion() then
			local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), keys.target:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)		
			local nTargetNumber = 0		
			for _, hEnemy in pairs(enemies) do
				if hEnemy ~= keys.target then

					self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_ranged_cleave_reduced_damage", {})				
					self:GetParent():PerformAttack(hEnemy, false, false, true, true, true, false, false)		
					self:GetParent():RemoveModifierByName("modifier_item_ranged_cleave_reduced_damage")
					
					nTargetNumber = nTargetNumber + 1
					
					if nTargetNumber >= self:GetAbility():GetSpecialValueFor("max_target") then
						break
					end
				end
			end
		end
	end
end


modifier_item_ranged_cleave_reduced_damage = class({})

function modifier_item_ranged_cleave_reduced_damage:IsDebuff() return false end
function modifier_item_ranged_cleave_reduced_damage:IsHidden() return true end
function modifier_item_ranged_cleave_reduced_damage:IsPurgable() return false end
function modifier_item_ranged_cleave_reduced_damage:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end


function modifier_item_ranged_cleave_reduced_damage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
	}
	return funcs
end


function modifier_item_ranged_cleave_reduced_damage:GetModifierDamageOutgoing_Percentage()

	return -1*(100-self:GetAbility():GetSpecialValueFor("split_shot_damage"))

end
