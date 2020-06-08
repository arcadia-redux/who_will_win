
creature_tear_armor = class({})
LinkLuaModifier( "modifier_creature_tear_armor", "creature_ability/modifier_creature_tear_armor", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creature_berserk_debuff", "creature_ability/modifier_creature_berserk_debuff", LUA_MODIFIER_MOTION_NONE )


function creature_tear_armor:GetIntrinsicModifierName()
   return "modifier_creature_tear_armor"
end


