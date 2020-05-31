item_seer_stone_new = item_seer_stone_new or class({})
LinkLuaModifier("modifier_item_seer_stone_new", "custom_items/item_seer_stone_new", LUA_MODIFIER_MOTION_NONE)

function item_seer_stone_new:GetIntrinsicModifierName() return "modifier_item_seer_stone_new" end

modifier_item_seer_stone_new = modifier_item_seer_stone_new or class({})

function modifier_item_seer_stone_new:IsHidden() return true end
function modifier_item_seer_stone_new:IsDebuff() return false end
function modifier_item_seer_stone_new:IsPurgable() return false end
function modifier_item_seer_stone_new:RemoveOnDeath() return false end

function modifier_item_seer_stone_new:OnCreated()
  	if self:GetAbility() then
    	self.cast_range_bonus = self:GetAbility():GetSpecialValueFor("cast_range_bonus")
    	self.mana_regen = self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
    	self.spell_amp = self:GetAbility():GetSpecialValueFor("bonus_spell_amp")
    else
        self.cast_range_bonus = 300
        self.mana_regen = 20
        self.spell_amp = 30
    end
end

function modifier_item_seer_stone_new:OnIntervalThink()

end

function modifier_item_seer_stone_new:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
end

function modifier_item_seer_stone_new:GetModifierCastRangeBonusStacking()
	return self.cast_range_bonus
end

function modifier_item_seer_stone_new:GetModifierConstantManaRegen()
	return self.mana_regen
end

function modifier_item_seer_stone_new:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end