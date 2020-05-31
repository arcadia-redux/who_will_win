require 'utils'
require 'shared'

if UnitAI == nil then UnitAI = class({}) end

UNIT_CMD_LIST = {"ATTACK_TARGET", "USE_ITEM", "USE_ABILITY"}
UNIT_FILTER = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS
MAX_BATTLE_Y = 2048

UnitDontCastItems = {
    [1] = "item_moon_shard",
    [2] = "item_bfury",
    [3] = "item_sphere",
    [4] = "item_shadow_amulet",
    [5] = "item_aegis",
    [6] = "item_smoke_of_deceit",
    [7] = "item_tome_of_upgrade",
    [8] = "item_scroll_of_time",
    [9] = "item_power_treads",
    [10] = "item_bloodstone",
    [11] = "item_ultimate_scepter",
    [12] = "item_tpscroll",
    [13] = "item_refresher",
    [14] = "item_manta",
    [15] = "item_ward_sentry",
}

function UnitAI:HasTargetTrueSight(unit, target)
    if(target:HasModifier("modifier_truesight")) then
        local modifiers = target:FindAllModifiersByName("modifier_truesight")
        for i, v in pairs(modifiers) do
            local caster = v:GetCaster()
            if(caster ~= nil and caster:IsNull() == false) then
                if(caster:GetTeamNumber() == unit:GetTeamNumber()) then
                    return true
                end
            end
        end
    end
    return false
end

function UnitAI:OnUnitThink(unit)
    if IsClient() or GameRules.DW.IsGameOver then return nil end

    local highestScoreCommand = 1
    local highestScore = 0
    local highestData = nil
    
    if(unit == nil or unit:IsNull() or unit:IsAlive() == false) then
        return nil
    end
    
    if(unit:HasModifier("modifier_hero_waitting")) then
        return nil
    end
    
    if(GameRules.DW.Stage == 3 and GameRules.DW.StageTime[GameRules.DW.Stage] - GameRules:GetGameTime() + GameRules.DW.StageStartTime < 3) then
        return nil
    end

    if(GameRules:IsGamePaused()) then
        return 0.2
    end
    
    if(GameRules:GetGameTime() - GameRules.DW.StageStartTime > 5) then
        local unitPosition = unit:GetAbsOrigin()
        if(unitPosition.y < 2050 or unitPosition.y > 3600 or unitPosition.x < -5600 or unitPosition.x > 5600) then
            local newPos = Vector(unitPosition.x, unitPosition.y, unitPosition.z)
            if(unitPosition.x > 5600) then
                newPos.x = 5600
            end

            if(unitPosition.x < -5600) then
                newPos.x = -5600
            end

            if(unitPosition.y > 3600) then
                newPos.y = 3600
            end

            if(unitPosition.y < 2050) then
                newPos.y = 2050
            end

            if(unitPosition ~= newPos) then
                FindClearSpaceForUnit(unit, newPos, true)
            end
        end
    end
    
    local team = unit:GetTeamNumber()
    if(team ~= DOTA_TEAM_GOODGUYS and team ~= DOTA_TEAM_BADGUYS) then
        return nil
    end

    if(unit.SpawnTime == nil) then
        unit.SpawnTime = GameRules:GetGameTime()
    end

    if(unit.IsCommandRestricted ~= nil and unit:IsCommandRestricted()) then 
        return 0.25
    end
    
    for i, v in pairs(UNIT_CMD_LIST) do
        local score, cmdData = UnitAI:EvaluateCommand(unit, v)
        if(score > highestScore or (score == highestScore and RollPercentage(50))) then
            highestScore = score
            highestScoreCommand = i
            highestData = cmdData
        end
    end
    
    if(highestData ~= nil) then
        return UnitAI:ExecuteCommand(unit, UNIT_CMD_LIST[highestScoreCommand], highestData)
    else
        return 0.25
    end
end

function UnitAI:EvaluateCommand(unit, cmdName)
    local location = unit:GetAbsOrigin()
    local teamId = unit:GetTeamNumber()
    local score = 0
    
    if(cmdName == "ATTACK_TARGET") then
        if(unit:IsChanneling() or unit:IsStunned()) then
            return 0, nil
        end
        
        if(unit:IsIdle() == false) then
            if(unit:AttackReady() == false or unit:IsAttacking()) then
                return 0, nil
            end
        end

        if(unit:IsAttackImmune() or unit:IsRooted()) then
            return 0, nil
        end

        local unitName = unit:GetUnitName()
        if(unitName == "npc_dota_juggernaut_healing_ward") then
            local hTarget = UnitAI:GetNearestWeekestFriendlyTarget(unit)
            if(hTarget ~= nil) then
                return 4, hTarget
            end
        end

        if(unitName == "npc_dota_techies_stasis_trap" or unitName == "npc_dota_techies_land_mine" or unitName == "npc_dota_techies_remote_mine" or unitName == "npc_dota_grimstroke_ink_creature") then
            local hTarget = UnitAI:ClosestHeroEnemy(unit, teamId)
            if(hTarget ~= nil) then
                return 3, hTarget
            end
        end
        
        local attackTarget = unit:GetAttackTarget()
        
        if(attackTarget == nil or attackTarget:IsAlive() == false) then
            local nearestEnemy = UnitAI:ClosestEnemyAll(unit, teamId)
            if(nearestEnemy == nil or nearestEnemy:IsAlive() == false) then
                return 0, nil
            end
            return 3, nearestEnemy
        end
        
        return 0, nil
    end
    
    if(cmdName == "USE_ITEM") then
        if(unit.IsIllusion ~= nil and unit:IsIllusion()) then
            return 0, nil
        end

        if(UnitAI:IsInBattleFightArea(unit) == false) then
            return 0, nil
        end
        
        if(unit:IsChanneling() or unit:IsStunned()) then
            return 0, nil
        end

        if(unit:IsMuted()) then
            return 0, nil
        end
        
        if(GameRules:GetGameTime() - GameRules.DW.StageStartTime < 7) then
            return 0, nil
        end
        
        if(unit:HasInventory() == false) then
            return 0, nil
        end

        local canCastItems = {}
        
        for slotIndex = 0, 16 do
            if(slotIndex <= 5 or slotIndex == 16) then
                local item = unit:GetItemInSlot(slotIndex)
                if(item ~= nil) then
                    local itemName = item:GetName()
                    local canCast = true
                    
                    if(itemName == "item_armlet") then
                        if item:GetToggleState() == false then
                            item:ToggleAbility()
                        end
                    end
                    
                    if(item:IsMuted() or item:IsPassive() or item:IsToggle()) then
                        canCast = false
                    elseif(item:RequiresCharges() and item:GetCurrentCharges() <= 0) then
                        canCast = false
                    elseif(item:IsFullyCastable() == false or item:IsCooldownReady() == false) then
                        canCast = false
                    elseif(item:IsInAbilityPhase()) then
                        canCast = false
                    elseif((itemName == "item_mekansm" or itemName == "item_guardian_greaves") and unit:GetHealth() == unit:GetMaxHealth()) then
                        canCast = false
                    elseif(itemName == "item_mekansm" and unit:GetHealth() == unit:GetMaxHealth()) then
                        canCast = false
                    elseif(itemName == "item_blade_mail" and unit:GetHealth() > unit:GetMaxHealth() * 0.6) then
                        canCast = false
                    elseif(table.contains(UnitDontCastItems, itemName)) then
                        canCast = false
                    end
                    
                    if canCast then
                        table.insert(canCastItems, item)
                    end
                end
            end
        end
        
        local selectedItem = nil
        
        if(#canCastItems > 0) then
            selectedItem = canCastItems[RandomInt(1, #canCastItems)]
        end
        
        if(selectedItem ~= nil) then
            local spellData = UnitAI:GetSpellData(selectedItem)
            if(spellData == nil) then
                return 0, nil
            end
            
            return 4, spellData
        end
        
        return 0, nil
    end
    
    if(cmdName == "USE_ABILITY") then
        if(unit:IsSilenced() or unit:IsStunned()) then
            return 0, nil
        end
        
        if(unit:IsChanneling()) then
            return 0, nil
        end
        
        if(GameRules:GetGameTime() - GameRules.DW.StageStartTime < 6) then
            return 0, nil
        end
        
        local canCastAbilities = {}
        
        for i = 0, unit:GetAbilityCount() - 1 do
            local ability = unit:GetAbilityByIndex(i)
            local canCast = true
            
            if(ability == nil or ability:GetLevel() <= 0) then
                canCast = false
            elseif(ability:IsHidden() or ability:IsPassive() or ability:IsActivated() == false) then
                canCast = false
            elseif(string.find(ability:GetName(), "_bonus") ~= nil) then
                canCast = false
            elseif(ability:IsFullyCastable() == false or ability:IsCooldownReady() == false) then
                canCast = false
            elseif(ability:IsInAbilityPhase()) then
                canCast = false
            elseif(bitContains(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_AUTOCAST)) then
                canCast = false
            end
            
            if canCast and ability:GetName() ~= "lone_druid_spirit_bear_return" then
                table.insert(canCastAbilities, ability)
            end
        end
        
        local selectedAbility = nil
        
        if(#canCastAbilities > 0) then
            selectedAbility = canCastAbilities[RandomInt(1, #canCastAbilities)]
        end
        
        if(selectedAbility ~= nil) then
            local spellData = UnitAI:GetSpellData(selectedAbility)
            if(spellData == nil) then
                return 0, nil
            end

            if(selectedAbility:GetName() == "templar_assassin_self_trap") then
                if(unit.SpawnTime ~= nil and GameRules:GetGameTime() - unit.SpawnTime < 0.5) then
                    return 0, nil
                end
            end
            
            return 4, spellData
        end
        
        return 0, nil
    end
end

function UnitAI:IsInBattleFightArea(hero)
    local units = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(),
    hero, 800, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    return #units > 0
end

function UnitAI:ExecuteCommand(unit, cmdName, cmdData)
    if(cmdName == "ATTACK_TARGET") then
        if(cmdData == nil) then
            unit:MoveToPositionAggressive(GameRules.DW.BattleFightPosition)
            return 1
        end
        
        local targetPosition = cmdData:GetAbsOrigin()
        if(GameRules:GetGameTime() - GameRules.DW.StageStartTime < 10) then
            local unitPosition = unit:GetAbsOrigin()
            if(unitPosition.x < -1000 or unitPosition.x > 1000) then
                targetPosition.y = unitPosition.y
            end
        end

        local unitName = unit:GetUnitName()
        if(unit:GetAttackDamage() > 1 or unitName == "npc_dota_techies_stasis_trap" or unitName == "npc_dota_techies_land_mine" or unitName == "npc_dota_techies_remote_mine" or unitName == "npc_dota_grimstroke_ink_creature") then
            local isAssassin = false
            if(unit.HasItemInInventory ~= nil and unit:HasItemInInventory("item_assassin_medal")) then
                isAssassin = true
            end
            if(isAssassin) then
                unit:MoveToTargetToAttack(cmdData)
            else
                unit:MoveToPositionAggressive(targetPosition)
            end
        else
            local targetPos = cmdData:GetAbsOrigin()
            local team = unit:GetTeamNumber()
            local moveVector = (GameRules.DW.FountainGood - targetPos):Normalized()
            if(team == DOTA_TEAM_BADGUYS) then
                moveVector = (GameRules.DW.FountainBad - targetPos):Normalized()
            end

            local movePos = targetPos + moveVector * 450
            unit:MoveToPosition(movePos)
        end

        local delay = 0.5
        if(unit.GetDisplayAttackSpeed ~= nil and unit:GetDisplayAttackSpeed() > 0) then
            delay = 170 / unit:GetDisplayAttackSpeed()
        end
        
        return delay
    end
    
    if(cmdName == "USE_ITEM") then
        if(cmdData == nil) then
            unit:MoveToPositionAggressive(GameRules.DW.BattleFightPosition)
            return 1
        end
        
        local loopTime = UnitAI:CastSpell(cmdData)
        
        return loopTime
    end
    
    if(cmdName == "USE_ABILITY") then
        if(cmdData == nil) then
            unit:MoveToPositionAggressive(GameRules.DW.BattleFightPosition)
            return 1
        end
        
        local loopTime = UnitAI:CastSpell(cmdData)
        
        return loopTime
    end
    
    return 1
end

function UnitAI:CastSpell(spellData)
    local hSpell = spellData.ability
    
    if hSpell == nil or hSpell:IsFullyCastable() == false or hSpell:IsActivated() == false then
        return 0.1
    end
    
    if(hSpell:GetCaster():HasModifier("modifier_hero_waitting")) then
        return 0.1
    end
    
    if(spellData.type == "toggle") then
        if hSpell:GetToggleState() == false then
            hSpell:ToggleAbility()
            table.insert(hSpell:GetCaster().toggleOffList, hSpell)
        end
        return 0.1
    end
    
    if(spellData.type == "unit_target") then
        return UnitAI:CastSpellUnitTarget(hSpell, spellData.target)
    end
    
    if(spellData.type == "point_target") then
        return UnitAI:CastSpellPointTarget(hSpell, spellData.target)
    end
    
    if(spellData.type == "no_target") then
        return UnitAI:CastSpellNoTarget(hSpell)
    end
    
    if(spellData.type == "tree_target") then
        return UnitAI:CastSpellTreeTarget(hSpell, spellData.target)
    end
    
    return 0.1
end

function UnitAI:ClosestEnemyAll(unit, teamId)
    local enemies = FindUnitsInRadius(teamId, unit:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL,
    UNIT_FILTER, FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    local firstEnemy = nil
    local bestEnemy = nil
    local isAssassin = false
    if(unit.HasItemInInventory ~= nil and unit:HasItemInInventory("item_assassin_medal")) then
        isAssassin = true
    end
    
    for index = 1, #enemies do
        if(enemies[index]:GetAbsOrigin().y > MAX_BATTLE_Y and enemies[index]:IsAlive() and enemies[index]:IsInvulnerable() == false and enemies[index]:IsAttackImmune() == false) then
            if(enemies[index]:IsInvisible() == false or UnitAI:HasTargetTrueSight(unit, enemies[index])) then
                if(isAssassin == false) then
                    firstEnemy = enemies[index]
                    break
                else
                    if(firstEnemy == nil) then
                        firstEnemy = enemies[index]
                    end
                    if(enemies[index].IsRealHero ~= nil and enemies[index]:IsRealHero()) then
                        if(enemies[index].IsRangedAttacker ~= nil and enemies[index].GetPrimaryAttribute ~= nil and enemies[index]:IsRangedAttacker() and enemies[index]:GetPrimaryAttribute() ~= 0) then
                            bestEnemy = enemies[index]
                            break
                        end
                    end
                end
            end
        end
    end

    if(bestEnemy ~= nil) then
        return bestEnemy
    end
    
    return firstEnemy
end

function UnitAI:ClosestHeroEnemy(unit, teamId)
    local enemies = FindUnitsInRadius(teamId, unit:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,
    UNIT_FILTER, FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    local firstEnemy = nil
    
    for index = 1, #enemies do
        if(enemies[index]:GetAbsOrigin().y > MAX_BATTLE_Y and enemies[index]:IsAlive() and enemies[index]:IsInvulnerable() == false) then
            if(enemies[index]:IsInvisible() == false or UnitAI:HasTargetTrueSight(unit, enemies[index])) then
                firstEnemy = enemies[index]
                break
            end
        end
    end
    
    return firstEnemy
end

function UnitAI:GetSpellData(hSpell)
    if hSpell == nil or hSpell:IsActivated() == false then
        return nil
    end
    
    local nBehavior = hSpell:GetBehavior()
    local nTargetTeam = hSpell:GetAbilityTargetTeam()
    local nTargetType = hSpell:GetAbilityTargetType()
    local nTargetFlags = hSpell:GetAbilityTargetFlags()

    local abilityName = hSpell:GetName()
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull()) then
        return nil
    end

    if(abilityName == "visage_summon_familiars_stone_form") then
        if(caster:GetHealthPercent() <= 50) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "brewmaster_storm_cyclone") then
        local hTarget = UnitAI:GetBestHeroTargetInRange(hSpell)
        if hTarget ~= nil and hTarget:IsAlive() then
            if(hTarget:GetHealthPercent() > 50) then
                return {ability = hSpell, type = "unit_target", target = hTarget}     
            end
        end

        return nil
    end
    
    if bitContains(nTargetType, DOTA_UNIT_TARGET_TREE) then
        local treeTarget = UnitAI:FindTreeTarget(hSpell)
        if treeTarget ~= nil then
            return {ability = hSpell, type = "tree_target", target = treeTarget}
        end
    elseif bitContains(nTargetTeam, DOTA_UNIT_TARGET_TEAM_CUSTOM) then
        if bitContains(nTargetFlags, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO) then
            local hTarget = UnitAI:GetBestCreepTarget(hSpell)
            if hTarget ~= nil and hTarget:IsAlive() then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        else
            local hTarget = UnitAI:GetBestHeroTargetInRange(hSpell)
            if hTarget ~= nil and hTarget:IsAlive() then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        end
    elseif bitContains(nTargetTeam, DOTA_UNIT_TARGET_TEAM_ENEMY) then
        if bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
            if UnitAI:IsNoTargetSpellCastValid(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY) then
                return {ability = hSpell, type = "no_target", target = nil}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_DIRECTIONAL) then
            local vTargetLoc = UnitAI:GetBestDirectionalPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY)
            if vTargetLoc ~= nil then
                return {ability = hSpell, type = "point_target", target = vTargetLoc}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_POINT) then
            local vTargetLoc = UnitAI:GetBestAOEPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY)
            if vTargetLoc ~= nil then
                return {ability = hSpell, type = "point_target", target = vTargetLoc}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then
            if bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_AOE) then
                local hTarget = UnitAI:GetBestHeroTargetInRange(hSpell)
                if hTarget ~= nil then
                    return {ability = hSpell, type = "unit_target", target = hTarget}
                end
            else
                if bitContains(nTargetType, DOTA_UNIT_TARGET_HERO) then
                    local hTarget = UnitAI:GetBestHeroTargetInRange(hSpell)
                    if hTarget ~= nil and hTarget:IsAlive() then
                        return {ability = hSpell, type = "unit_target", target = hTarget}
                    end
                else
                    local hTarget = UnitAI:GetBestCreepTarget(hSpell)
                    if hTarget ~= nil and hTarget:IsAlive() then
                        return {ability = hSpell, type = "unit_target", target = hTarget}
                    end
                end
            end
        end
    elseif bitContains(nTargetTeam, DOTA_UNIT_TARGET_TEAM_FRIENDLY) then
        if(UnitAI:IsInBattleFightArea(hSpell:GetCaster()) == false) then
            return nil
        end
        if bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
            if UnitAI:IsNoTargetSpellCastValid(hSpell, DOTA_UNIT_TARGET_TEAM_FRIENDLY) then
                return {ability = hSpell, type = "no_target", target = nil}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_POINT) then
            local vTargetLoc = UnitAI:GetBestAOEPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_FRIENDLY)
            if vTargetLoc ~= nil then
                return {ability = hSpell, type = "point_target", target = vTargetLoc}
            end
        else
            local hTarget = UnitAI:GetBestFriendlyTarget(hSpell)
            if hTarget ~= nil then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            elseif hSpell:GetCaster():GetHealth() < hSpell:GetCaster():GetMaxHealth() then
                return {ability = hSpell, type = "unit_target", target = hSpell:GetCaster()}
            end
        end
    else
        if bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
            if UnitAI:IsNoTargetSpellCastValid(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY) then
                return {ability = hSpell, type = "no_target", target = nil}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_POINT) then
            local vTargetLoc = UnitAI:GetBestAOEPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY)
            if vTargetLoc ~= nil then
                return {ability = hSpell, type = "point_target", target = vTargetLoc}
            end
        else
            local hTarget = UnitAI:GetBestHeroTargetInRange(hSpell)
            if hTarget ~= nil then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            else
                return {ability = hSpell, type = "unit_target", target = hSpell:GetCaster()}
            end
        end
    end
    
    return nil
end

function UnitAI:GetSpellRange(hSpell)
    if(hSpell == nil) then
        return 250
    end
    
    local baseCastRange = hSpell:GetCastRange(vec3_invalid, nil)
    if(baseCastRange == nil or baseCastRange < 250) then
        baseCastRange = 250
    end
    
    local abilityName = hSpell:GetName()
    if(abilityName == "item_blink") then
        return 1200
    end
    
    if(abilityName == "item_hurricane_pike") then
        return 400
    end
    
    return baseCastRange + 100
end

function UnitAI:GetBestHeroTargetInRange(hSpell)
    local abilityKeyValues = hSpell:GetAbilityKeyValues()
    local castMagicImmuneTarget = false
    if(abilityKeyValues ~= nil and abilityKeyValues.SpellImmunityType == "SPELL_IMMUNITY_ENEMIES_YES") then
        castMagicImmuneTarget = true
    end
    
    local unit = hSpell:GetCaster()
    local teamId = unit:GetTeamNumber()
    local radius = UnitAI:GetSpellRange(hSpell)
    
    local enemies = FindUnitsInRadius(teamId, unit:GetAbsOrigin(), unit, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,
    UNIT_FILTER, FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    local firstEnemy = nil
    local rangedEnemy = nil
    local isAssassin = false
    if(unit.HasItemInInventory ~= nil and unit:HasItemInInventory("item_assassin_medal")) then
        isAssassin = true
    end
    
    for index = 1, #enemies do
        if(enemies[index]:GetAbsOrigin().y > MAX_BATTLE_Y and enemies[index]:IsAlive() and enemies[index]:IsInvulnerable() == false) then
            if(enemies[index]:IsMagicImmune() == false or castMagicImmuneTarget) then
                if(enemies[index]:IsInvisible() == false or UnitAI:HasTargetTrueSight(unit, enemies[index])) then
                    if(isAssassin == false) then
                        firstEnemy = enemies[index]
                        break
                    else
                        if(firstEnemy == nil) then
                            firstEnemy = enemies[index]
                        end
                        if(enemies[index].IsRangedAttacker ~= nil and enemies[index].GetPrimaryAttribute ~= nil and enemies[index]:IsRangedAttacker() and enemies[index]:GetPrimaryAttribute() ~= 0) then
                            rangedEnemy = enemies[index]
                            break
                        end
                    end
                end
            end
        end
    end

    if(isAssassin and rangedEnemy ~= nil) then
        return rangedEnemy
    end
    
    return firstEnemy
end

function UnitAI:GetBestCreepTarget(hSpell)
    local enemies = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    UnitAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP, UNIT_FILTER, FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    for i = 1, #enemies do
        if enemies[i]:IsAlive() then
            return enemies[i]
        end
    end
    
    return nil
end

function UnitAI:GetBestFriendlyTarget(hSpell)
    local friends = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    UnitAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    if #friends == 0 then
        return nil
    end
    
    local minHP = nil
    local target = nil
    
    for i = 1, #friends do
        local HP = friends[i]:GetHealth() / friends[i]:GetMaxHealth()
        if(HP < 1.0) then
            if friends[i]:IsAlive() and (minHP == nil or HP < minHP) then
                minHP = friends[i]:GetHealth() / friends[i]:GetMaxHealth()
                target = friends[i]
            end
        end
    end
    
    return target
end

function UnitAI:GetNearestWeekestFriendlyTarget(unit)
    local friends = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), unit,
    1500, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    if #friends == 0 then
        return nil
    end
    
    local minHP = nil
    local target = nil
    
    for i = 1, #friends do
        local HP = friends[i]:GetHealthPercent()
        if friends[i]:IsAlive() and (minHP == nil or HP < minHP) then
            minHP = HP
            target = friends[i]
        end
    end
    
    return target
end

function UnitAI:GetSpellCastTime(hSpell)
    if(hSpell ~= nil and hSpell:IsNull() == false) then
        local flCastPoint = math.max(0.25, hSpell:GetCastPoint() + hSpell:GetChannelTime() + hSpell:GetBackswingTime())
        if(flCastPoint < 0.2) then
            flCastPoint = 0.2
        end
        
        return flCastPoint
    end
    return 0.2
end

function UnitAI:FindTreeTarget(hSpell)
    local Trees = GridNav:GetAllTreesAroundPoint(hSpell:GetCaster():GetAbsOrigin(), UnitAI:GetSpellRange(hSpell), false)
    if #Trees == 0 then
        return nil
    end
    
    local nearestTree = nil
    local nearestLength = nil
    
    for i, v in pairs(Trees) do
        if(v ~= nil and v:IsNull() == false) then
            local len = (hSpell:GetCaster():GetAbsOrigin() - v:GetAbsOrigin()):Length2D()
            
            if (nearestLength == nil or len < nearestLength) then
                nearestLength = len
                nearestTree = v
            end
        end
    end
    
    return nearestTree
end

function UnitAI:GetPlayerId(unit)
    local owner = unit:GetOwner()
    if(owner == nil or owner:IsNull()) then
        return -1
    end
    
    if(owner.IsRealHero ~= nil and owner:IsRealHero()) then
        return owner:GetPlayerID()
    end
    
    return -1
end

function UnitAI:CastSpellNoTarget(hSpell)
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull() or caster:IsAlive() == false) then
        return 0.1
    end
    
    caster:CastAbilityNoTarget(hSpell, UnitAI:GetPlayerId(caster))
    
    return UnitAI:GetSpellCastTime(hSpell)
end

function UnitAI:CastSpellUnitTarget(hSpell, hTarget)
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull() or caster:IsAlive() == false) then
        return 0.1
    end
    
    if(hTarget == nil or hTarget:IsNull() or hTarget:IsAlive() == false) then
        return 0.1
    end
    
    caster:CastAbilityOnTarget(hTarget, hSpell, UnitAI:GetPlayerId(caster))
    
    return UnitAI:GetSpellCastTime(hSpell)
end

function UnitAI:CastSpellTreeTarget(hSpell, treeTarget)
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull() or caster:IsAlive() == false) then
        return 0.1
    end
    
    if(treeTarget == nil or treeTarget:IsNull()) then
        return 0.1
    end
    
    caster:CastAbilityOnTarget(treeTarget, hSpell, UnitAI:GetPlayerId(caster))
    
    return UnitAI:GetSpellCastTime(hSpell)
end

function UnitAI:CastSpellPointTarget(hSpell, vLocation)
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull() or caster:IsAlive() == false) then
        return 0.1
    end
    
    if(hSpell:GetName() == "shredder_timber_chain") then
        if(GridNav:CanFindPath(caster:GetAbsOrigin(), vLocation)) then
            CreateTempTree(vLocation, 2)
            caster:CastAbilityOnPosition(vLocation, hSpell, UnitAI:GetPlayerId(caster))
        end
    else
        caster:CastAbilityOnPosition(vLocation, hSpell, UnitAI:GetPlayerId(caster))
    end
    
    return UnitAI:GetSpellCastTime(hSpell)
end

function UnitAI:IsNoTargetSpellCastValid(hSpell, targetTeamType)
    local nUnitsRequired = 1
    if hSpell:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
        nUnitsRequired = 3
    end
    
    local nAbilityRadius = hSpell:GetAOERadius()
    if nAbilityRadius == 0 then
        nAbilityRadius = 600
    end

    if(hSpell:GetName() == "techies_remote_mines_self_detonate") then
        nAbilityRadius = 350
    end
    
    local units = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(),
    hSpell:GetCaster(), nAbilityRadius, targetTeamType, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    if #units < nUnitsRequired then
        return false
    end
    
    return true
end

function UnitAI:GetBestAOEPointTarget(hSpell, targetTeamType)
    
    local nUnitsRequired = 1
    if hSpell:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
        nUnitsRequired = 2
    end
    
    local nAbilityRadius = hSpell:GetAOERadius()
    if nAbilityRadius == 0 then
        nAbilityRadius = UnitAI:GetSpellRange(Spell)
    end
    
    if nAbilityRadius == 0 then
        nAbilityRadius = 250
    end
    
    local vLocation = GetTargetAOELocation(hSpell:GetCaster():GetTeamNumber(),
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
        targetTeamType,
        hSpell:GetCaster():GetAbsOrigin(),
        UnitAI:GetSpellRange(hSpell),
        nAbilityRadius,
    nUnitsRequired)
    if vLocation == vec3_invalid then
        return nil
    end
    
    return vLocation
end

function UnitAI:GetBestDirectionalPointTarget(hSpell, targetTeamType)
    local nUnitsRequired = 1
    if hSpell:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
        nUnitsRequired = 2
    end
    
    local nAbilityRadius = hSpell:GetAOERadius()
    if nAbilityRadius == 0 then
        nAbilityRadius = 250
    end
    
    local vLocation = GetTargetLinearLocation(hSpell:GetCaster():GetTeamNumber(),
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
        targetTeamType,
        hSpell:GetCaster():GetAbsOrigin(),
        UnitAI:GetSpellRange(hSpell),
        nAbilityRadius,
    nUnitsRequired)
    
    if vLocation == vec3_invalid then
        return nil
    end
    
    return vLocation
end

function UnitAI:FindClearSpaceToMove(hero)
    local checkRadius = 160
    
    local units = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(),
    hero, checkRadius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    if #units < 3 then
        return nil
    end
    
    local heroLocation = hero:GetAbsOrigin()
    
    local vLocation = heroLocation + Vector(RandomInt(-160, 160), RandomInt(-320, 320), 0)
    
    if(GridNav:CanFindPath(heroLocation, vLocation) == false) then
        return nil
    end
    
    local newLocationUnits = FindUnitsInRadius(hero:GetTeamNumber(), vLocation,
    hero, checkRadius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    if(#newLocationUnits < 3) then
        return vLocation
    end
    
    return nil
end
