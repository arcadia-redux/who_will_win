--[[
	Author: kritth
	Date: 7.1.2015.
	Put modifier to override animation on cast
]]
function rearm_start( keys )
	local caster = keys.caster
	local ability = keys.ability
	local abilityLevel = ability:GetLevel()
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_rearm_level_" .. abilityLevel .. "_datadriven", {} )
end

--[[
	Author: kritth
	Date: 7.1.2015.
	Refresh cooldown
]]
function rearm_refresh_cooldown( keys )
	local caster = keys.caster
	
	-- Reset cooldown for abilities that is not rearm
	local ability_exempt_table = {}
    ability_exempt_table["phoenix_supernova"]=true
    ability_exempt_table["skeleton_king_reincarnation"]=true
    ability_exempt_table["arc_warden_tempest_double"]=true

    --全球流的大招不能刷新
    ability_exempt_table["zuus_thundergods_wrath"]=true
    ability_exempt_table["furion_wrath_of_nature"]=true
    ability_exempt_table["ancient_apparition_ice_blast"]=true
    ability_exempt_table["spectre_haunt"]=true
    ability_exempt_table["silencer_global_silence"]=true
    
    --强保命技能不能刷新
    ability_exempt_table["abaddon_borrowed_time"]=true
    ability_exempt_table["oracle_false_promise"]=true
    ability_exempt_table["dazzle_shallow_grave"]=true
    ability_exempt_table["slark_shadow_dance"]=true
    ability_exempt_table["dark_willow_shadow_realm"]=true

    --召唤类大招不能刷新
    ability_exempt_table["undying_tombstone_lua"]=true
    ability_exempt_table["shadow_shaman_mass_serpent_ward"]=true
    ability_exempt_table["warlock_rain_of_chaos"]=true

    --致命链接太卡不能刷新
    ability_exempt_table["warlock_fatal_bonds"]=true
    --发条刷新不能刷新
    ability_exempt_table["rattletrap_overclocking"]=true
    
    --全球流召唤飞弹也不能刷新
    --泉水阶段不能刷新风暴之眼
	for i = 0, caster:GetAbilityCount() - 1 do
		local ability = caster:GetAbilityByIndex( i )
		if ability and ability ~= keys.ability 
		and not ability_exempt_table[ability:GetAbilityName()] 
		and not (caster:FindAbilityByName("special_bonus_unique_gyrocopter_5") and caster:FindAbilityByName("special_bonus_unique_gyrocopter_5"):GetLevel() > 0 and "gyrocopter_call_down"==ability:GetAbilityName())  
		and not (caster:HasModifier("modifier_hero_refreshing") and "razor_eye_of_the_storm"==ability:GetAbilityName())   then
			ability:EndCooldown()
		end
	end
	
	-- Put item exemption in here
	local exempt_table = {}
	exempt_table["item_hand_of_midas"]=true
    exempt_table["item_refresher"]=true
    exempt_table["item_black_king_bar"]=true
    exempt_table["item_arcane_boots"]=true
    exempt_table["item_guardian_greaves"]=true
    exempt_table["item_sphere"]=true
    exempt_table["item_aeon_disk"]=true
    exempt_table["item_demonicon"]=true

	-- Reset cooldown for items
	for i = 0, 5 do
		local item = caster:GetItemInSlot( i )
		if item and not exempt_table[item:GetAbilityName()] then
			item:EndCooldown()
		end
	end
end
