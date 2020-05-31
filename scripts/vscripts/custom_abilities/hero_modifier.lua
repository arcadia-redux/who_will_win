LinkLuaModifier("modifier_hero_waitting", "custom_abilities/hero_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hero_command_restricted", "custom_abilities/hero_modifier", LUA_MODIFIER_MOTION_NONE)

modifier_hero_waitting = modifier_hero_waitting or class({})

function modifier_hero_waitting:IsHidden() return false end
function modifier_hero_waitting:IsDebuff() return false end
function modifier_hero_waitting:IsPurgable() return false end
function modifier_hero_waitting:RemoveOnDeath() return false end
function modifier_hero_waitting:GetTexture()
	return "alchemist_goblins_greed"
end

function modifier_hero_waitting:CheckState()
	return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true
	}
end

modifier_hero_command_restricted = modifier_hero_command_restricted or class({})

function modifier_hero_command_restricted:IsHidden() return true end
function modifier_hero_command_restricted:IsDebuff() return false end
function modifier_hero_command_restricted:IsPurgable() return false end
function modifier_hero_command_restricted:RemoveOnDeath() return false end