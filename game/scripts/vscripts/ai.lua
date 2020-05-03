function Spawn( entityKeyValues )
    if not IsServer() then
        return
    end

    if thisEntity == nil then
        return
    end
  
    thisEntity:SetContextThink( "AutoCasterThink", AutoCasterThink, 1 )
end

function AutoCasterThink()
    if ( not thisEntity:IsAlive() ) then
        return -1 
    end
  
    if GameRules:IsGamePaused() or thisEntity:IsChanneling() then
        return 1 
    end
  
    if thisEntity:IsControllableByAnyPlayer() then
        return -1
    end
    -- if thisEntity:IsAttacking() then
    --     return 1
    -- end
  
    local npc = thisEntity

    if not thisEntity.bInitialized then
        npc.fMaxDist = npc:GetAcquisitionRange()
        npc.bInitialized = true
      
        npc.ability0 = FindAbility(npc, 0)
        npc.ability1 = FindAbility(npc, 1)
        npc.ability2 = FindAbility(npc, 2)
        npc.ability3 = FindAbility(npc, 3)
        npc.ability4 = FindAbility(npc, 4)
        npc.ability5 = FindAbility(npc, 5)
      
    end

    local search_radius = npc.fMaxDist
  
    local enemies = FindUnitsInRadius(
                        npc:GetTeamNumber(),
                        npc:GetAbsOrigin() ,
                        nil,
                        search_radius + 50,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
                        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 
                        FIND_CLOSEST,
                        false )

    local enemy = enemies[1]
  
    TryCastAbility(npc.ability0, npc, enemy)
    TryCastAbility(npc.ability1, npc, enemy)
    TryCastAbility(npc.ability2, npc, enemy)
    TryCastAbility(npc.ability3, npc, enemy)
    TryCastAbility(npc.ability4, npc, enemy)
    TryCastAbility(npc.ability5, npc, enemy)
    -- DeepPrintTable(thisEntity)
    if _G.FIGHT and thisEntity.targetPoint and not thisEntity:IsAttacking() then
        thisEntity:MoveToPositionAggressive(thisEntity.targetPoint)
    end

    return 1
  
end

function FindAbility(unit, index)
    local ability = unit:GetAbilityByIndex(index)
    if ability then
        local ability_behavior = ability:GetBehavior()
        if bit.band( ability_behavior, DOTA_ABILITY_BEHAVIOR_PASSIVE ) == DOTA_ABILITY_BEHAVIOR_PASSIVE then
            ability.behavior = "passive"
        elseif bit.band( ability_behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET ) == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then
            ability.behavior = "target"
        elseif bit.band( ability_behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET ) == DOTA_ABILITY_BEHAVIOR_NO_TARGET then
            ability.behavior = "no_target"
        elseif bit.band( ability_behavior, DOTA_ABILITY_BEHAVIOR_POINT ) == DOTA_ABILITY_BEHAVIOR_POINT then
            ability.behavior = "point"
        end
        return ability
    else
        return nil
    end
  
end

function TryCastAbility(ability, caster, enemy)
  
    if not ability
    or not ability:IsFullyCastable()
    or ability.behavior == "passive"
    or not enemy
    or  enemy:IsMagicImmune()  then
        return
    end
  
    local order_type
    if ability.behavior == "target" then
        order_type = DOTA_UNIT_ORDER_CAST_TARGET
    elseif ability.behavior == "no_target" then
        order_type = DOTA_UNIT_ORDER_CAST_NO_TARGET
    elseif ability.behavior == "point" then
        order_type = DOTA_UNIT_ORDER_CAST_POSITION
    elseif ability.behavior == "passive" then
        return
    end
    ExecuteOrderFromTable({
        UnitIndex = caster:entindex(),
        OrderType = order_type,
        AbilityIndex = ability:entindex(),
        TargetIndex = enemy:entindex(),
        Position = enemy:GetOrigin(),
        Queue = false,
    })
    -- caster:SetContextThink( "AutoCasterThink", AutoCasterThink, 1 )
end