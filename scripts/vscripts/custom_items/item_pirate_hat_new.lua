item_pirate_hat_new = item_pirate_hat_new or class({})
LinkLuaModifier("modifier_item_pirate_hat_new", "custom_items/item_pirate_hat_new", LUA_MODIFIER_MOTION_NONE)

function item_pirate_hat_new:GetIntrinsicModifierName() return "modifier_item_pirate_hat_new" end

modifier_item_pirate_hat_new = modifier_item_pirate_hat_new or class({})

function modifier_item_pirate_hat_new:IsHidden() return true end
function modifier_item_pirate_hat_new:IsDebuff() return false end
function modifier_item_pirate_hat_new:IsPurgable() return false end
function modifier_item_pirate_hat_new:RemoveOnDeath() return false end

function modifier_item_pirate_hat_new:OnCreated()
  	if self:GetAbility() then
    	self.attack_speed_bonus = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
    else
        self.attack_speed_bonus = 250
    end
end

function modifier_item_pirate_hat_new:OnIntervalThink()

end

function modifier_item_pirate_hat_new:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_item_pirate_hat_new:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed_bonus
end