if not modifier_removed_hero then
	modifier_removed_hero = class({})
end
function modifier_removed_hero:IsHidden()
  	return true
end
function modifier_removed_hero:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_removed_hero:CheckState()
  	return {
	    [MODIFIER_STATE_OUT_OF_GAME] = true,
	   	[MODIFIER_STATE_STUNNED] = true,
	    [MODIFIER_STATE_INVISIBLE] = true,
	    [MODIFIER_STATE_INVULNERABLE] = true,
	    [MODIFIER_STATE_UNTARGETABLE ] = true,
	    [MODIFIER_STATE_UNSELECTABLE] = true,
	    [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	    [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
	    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	    [MODIFIER_STATE_NO_TEAM_MOVE_TO] = true,
	    [MODIFIER_STATE_NO_TEAM_SELECT] = true,
	    [MODIFIER_STATE_ATTACK_IMMUNE] = true,
	    [MODIFIER_STATE_BLIND] = true,
  	}
end
if IsServer() then
function modifier_removed_hero:OnCreated(table)
	self:GetParent():AddNoDraw()
end
function modifier_removed_hero:OnRemoved()
	self:GetParent():RemoveNoDraw()
end
end