spExemption = {}
spExemption["necrolyte_reapers_scythe_datadriven"] = true
spExemption["necrolyte_heartstopper_aura_lua"] = true
spExemption["huskar_life_break"] = true
spExemption["death_prophet_spirit_siphon"] = true
spExemption["elder_titan_earth_splitter"] = true
spExemption["winter_wyvern_arctic_burn"] = true
spExemption["doom_bringer_infernal_blade"] = true
spExemption["phoenix_sun_ray"] = true
spExemption["abyssal_underlord_firestorm"] = true
spExemption["zuus_static_field"] = true
spExemption["zuus_static_field_datadriven"] = true
spExemption["spectre_dispersion"] = true
spExemption["item_blade_mail"] = true
spExemption["item_iron_talon"] = true
spExemption["enigma_midnight_pulse"] = true






function DamageAmplify(hAttacker,hVictim,hAbility,nDamageType,flDamage)

    --仅限魔法与神圣伤害
    if nDamageType == DAMAGE_TYPE_MAGICAL or nDamageType == DAMAGE_TYPE_PURE then
        if hAttacker.flSP then
            --有明确的技能来源
            if hAbility and hAbility.GetAbilityName then
                -- A杖黑洞也不受加成
                if (not spExemption[hAbility:GetAbilityName()]) and (not(hAttacker:HasScepter() and "enigma_black_hole"==hAbility:GetAbilityName())) then      
                    --折扣
                    local flDiscount = 1 
                    --被动技能 效果减弱
                    if hAbility:IsToggle() or hAbility:IsPassive() then
                        flDiscount = flDiscount * 0.5
                    end
                    --对玩家效果减80%
                    if hVictim and hVictim.GetTeamNumber and DOTA_TEAM_NEUTRALS~=hVictim:GetTeamNumber() then
                       --折扣只对英雄有效
                       if hVictim.IsRealHero and hVictim:IsRealHero() and hVictim.GetUnitName and string.find(hVictim:GetUnitName(),"npc_dota_hero") == 1 then
                          flDiscount = flDiscount * 0.20
                       end
                    end
                    --print("flDiscount"..flDiscount)
                    return flDamage * (1 + hAttacker.flSP * flDiscount * hAttacker:GetIntellect() / 100)
                else
                    return flDamage
                end
            else
                -- 无明确技能来源
                return flDamage * (1 + hAttacker.flSP * hAttacker:GetIntellect() / 100)
            end
        end
    end
    return flDamage

end




function GameMode:DamageFilter(damageTable)
     
    if damageTable.entindex_attacker_const == nil then
        return true
    end

    local hAttacker = EntIndexToHScript(damageTable.entindex_attacker_const)
    local hVictim = EntIndexToHScript(damageTable.entindex_victim_const)
    if damageTable.entindex_inflictor_const ~= nil then
        local hAbility = EntIndexToHScript(damageTable.entindex_inflictor_const)

        --阻止虚妄之诺的对泉水玩家的伤害
        if hAbility and hAbility.GetAbilityName and "oracle_false_promise"==hAbility:GetAbilityName() then
          if hVictim:HasModifier("modifier_hero_refreshing") then
               return false
          end
        end

        if hAttacker and hAttacker:IsRealHero() then
            --print("Origin.damage: "..damageTable.damage)
            damageTable.damage = DamageAmplify(hAttacker,hVictim, hAbility, damageTable.damagetype_const, damageTable.damage)
            --print("Amp.damage: "..damageTable.damage)
        end
    end
    
    --统计伤害
    if hAttacker and hAttacker.GetPlayerOwnerID and hAttacker:GetPlayerOwnerID() then
       local nPlayerID = hAttacker:GetPlayerOwnerID()
       if nPlayerID and nil~=GameMode.damageCount[nPlayerID] then
          GameMode.damageCount[nPlayerID] = GameMode.damageCount[nPlayerID] +damageTable.damage
       end
    end

    return true
end