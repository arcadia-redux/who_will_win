if not modifier_speedup then
	modifier_speedup = class({})
end

function modifier_speedup:IsHidden()
  	return true
end

function modifier_speedup:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_speedup:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
end

function modifier_speedup:GetModifierMoveSpeedBonus_Constant()
	return 999
end

