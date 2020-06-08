function GameMode:ModifierGainedFilter(keys)
    if keys and keys.name_const and (keys.name_const == "modifier_item_ultimate_scepter" or keys.name_const == "modifier_item_ultimate_scepter_consumed") then
       HeroBuilder:AddScepterAbility(keys.entindex_parent_const)
    end
    --如果攻击方式改变，进行记录 通过一个定时器进行修复
    if keys.name_const and HeroBuilder.attackCapabilityModifiers[keys.name_const] and keys.entindex_parent_const then
    	local hParent = EntIndexToHScript(keys.entindex_parent_const)
    	if hParent then
    		HeroBuilder:RegisterAttackCapabilityChanged(hParent)
    	end
	end
    return true
end