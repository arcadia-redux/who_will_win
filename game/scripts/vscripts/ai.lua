REJECTABILITIES = {
    lone_druid_spirit_bear_return = true,
    item_power_treads = true,
    mars_bulwark = true,
    shadow_demon_shadow_poison_release = true,
    lion_mana_drain = true,
    monkey_king_mischief = true,
}


SPECIAL_CONDITIONS = {
    visage_summon_familiars_stone_form = {
        CasterHealthPercentLower = 30
    },
    item_bottle = {
        CasterHealthPercentLower = 50
    },

    item_magic_stick = {
        CasterHealthPercentLower = 50
    },

    item_magic_wand = {
        CasterHealthPercentLower = 50
    },

    item_mekansm  = {
        CasterHealthPercentLower = 50
    },

    abaddon_death_coil = {
        CasterHealthPercentHigher = 70
    },

    abaddon_borrowed_time = {
        CasterHealthPercentLower = 30
    },

    razor_plasma_field = {
        EnemyInRadius = 600
    },

    huskar_inner_vitality = {
        EnemyInRadius = 425
    },

    nevermore_shadowraze1 = {
        EnemyInRadius = 300
    },

    nevermore_shadowraze2 = {
        EnemyInRadius = 550
    },

    nevermore_shadowraze3 = {
        EnemyInRadius = 800
    },

    rattletrap_power_cogs = {
        EnemyInRadius = 215
    },

    leshrac_pulse_nova = {
        EnemyInRadius = 400
    },

    leshrac_diabolic_edict = {
        EnemyInRadius = 450
    },

    mars_spear = {
        EnemyInRadius = 850
    },

    juggernaut_blade_fury = {
         EnemyInRadius = 250
    }

}

function CBaseEntity:StartAI()
    
    if not self.bInitialized then
        self.fMaxDist = self:GetAcquisitionRange()
        self.bInitialized = true
    end

    self:SetContextThink( "AIThink", function()
        if not self:IsAlive() then
            return -1 
        end
      
        if GameRules:IsGamePaused() or self:IsChanneling() then
            return 1 
        end
    
        if self:IsControllableByAnyPlayer() then
            return -1
        end

        if not _G.FIGHT then
            return 1 
        end

        local npc = self


        local search_radius = 1200

        local enemies = FindEnemyInRadius(npc, search_radius)
        local friends = FindFriendlyInRadius(npc, search_radius)

        local target = enemies[1]
        local targetFriend = friends[1]

        if target then
            for i=0,6 do
                local ability = npc:GetAbilityByIndex(i)
                if ability and not REJECTABILITIES[ability:GetAbilityName()] and not ability:IsPassive() and not ability:IsHidden() and ability:IsFullyCastable() and ability:IsCooldownReady()  then
                    local res = TryCastAbility(ability, npc, target, targetFriend)
                    if res then return res end
                end
            end

            for i=0,5 do
                local ability = npc:GetItemInSlot(i)
                if ability and not REJECTABILITIES[ability:GetAbilityName()] and not ability:IsPassive() and ability:IsFullyCastable() and ability:IsCooldownReady() then
                    if not ability:RequiresCharges() or ability:GetCurrentCharges() > 0 then
                        local res = TryCastAbility(ability, npc, target, targetFriend)
                        if res then return res end
                    end
                end
            end


        end

        table.sort(enemies, function (a, b) return (a:GetHealth() < b:GetHealth()) end)
        local enemy = enemies[1]

        --try to kill low hp enemy
        if enemy and enemy:GetHealthPercent() < 30 
        and (enemy.attacker == npc 
            or not IsValidEntity(enemy.attacker) 
            or (IsValidEntity(enemy.attacker) and not enemy.attacker:IsAlive())) then
            enemy.attacker = npc
            npc:MoveToTargetToAttack(enemy)
            return 1
        end

        -- DeepPrintTable(thisEntity)
        if _G.FIGHT and not npc:IsNull() and npc.targetPoint and not npc:IsAttacking() then
            npc:MoveToPositionAggressive(npc.targetPoint)
        end

        return 0.5
      
    end, 0.5 )
end

function TryCastAbility(ability, npc, target, targetFriend)
   
    local behavior = ability:GetBehavior()
    local targetTeam = ability:GetAbilityTargetTeam()
    local targetType = ability:GetAbilityTargetType()
    local targetFlags = ability:GetAbilityTargetFlags()

    if not SpecialConditions(ability, target) then return end

    if IsFlagSet(behavior, DOTA_ABILITY_BEHAVIOR_TOGGLE) then  
        if not ability:GetToggleState() then
            ExecuteOrderFromTable({
                UnitIndex = npc:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_TOGGLE,
                AbilityIndex = ability:entindex(),
             })
            local castPoint = ability:IsNull() and 1 or ability:GetCastPoint()
            return castPoint + RandomFloat(0.2,0.5)
        end
    end

    if IsFlagSet(behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then  
        if targetFriend and UnitFilter(targetFriend, targetTeam, targetType, targetFlags, ability:GetCaster():GetTeam()) == UF_SUCCESS then
            ExecuteOrderFromTable({
                UnitIndex = npc:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                AbilityIndex = ability:entindex(),
                TargetIndex = targetFriend:entindex()
            })
            local castPoint = ability:IsNull() and 1 or ability:GetCastPoint()
            return castPoint + RandomFloat(0.2,0.5)
        end
        if target and UnitFilter(target, targetTeam, targetType, targetFlags, ability:GetCaster():GetTeam()) == UF_SUCCESS then
            ExecuteOrderFromTable({
                UnitIndex = npc:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                AbilityIndex = ability:entindex(),
                TargetIndex = target:entindex()
            })
            local castPoint = ability:IsNull() and 1 or ability:GetCastPoint()
            return castPoint + RandomFloat(0.2,0.5)
        end
    end

    if IsFlagSet(behavior, DOTA_ABILITY_BEHAVIOR_POINT) then  
        if IsFlagSet(targetTeam, DOTA_UNIT_TARGET_TEAM_FRIENDLY) and targetFriend then
            ExecuteOrderFromTable({
                UnitIndex = npc:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                AbilityIndex = ability:entindex(),
                Position = targetFriend:GetAbsOrigin(),
            })
            local castPoint = ability:IsNull() and 1 or ability:GetCastPoint()
            return castPoint + RandomFloat(0.2,0.5)
        end
        if target then
            ExecuteOrderFromTable({
                UnitIndex = npc:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                AbilityIndex = ability:entindex(),
                Position = target:GetAbsOrigin(),
            })
            local castPoint = ability:IsNull() and 1 or ability:GetCastPoint()
            return castPoint + RandomFloat(0.2,0.5)
        end
    end

    if IsFlagSet(behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) and target then
        ExecuteOrderFromTable({
            UnitIndex = npc:entindex(),
            OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
            AbilityIndex = ability:entindex(),
        })
        local castPoint = ability:IsNull() and 1 or ability:GetCastPoint()
        return castPoint + RandomFloat(0.2,0.5)
    end
end

function SpecialConditions(ability, target)
    local caster = ability:GetCaster()
    local abilityName = ability:GetAbilityName()

    if SPECIAL_CONDITIONS[abilityName] then
        for cond, value in pairs(SPECIAL_CONDITIONS[abilityName]) do
            if cond == "CasterHealthPercentLower" then
                if caster:GetHealthPercent() > value then
                    return false
                end
            end

            if cond == "CasterHealthPercentHigher" then
                if caster:GetHealthPercent() < value then
                    return false
                end
            end

            if cond == "CasterManaPercentLower" then
                if caster:GetManaPercent() > value then
                    return false
                end
            end

            if cond == "EnemyInRadius" then
                local units = FindEnemyInRadius(caster, value)
                if #units == 0 then
                    return false
                end
            end
        end
    end

    if abilityName == "templar_assassin_trap" and not CheckTraps(caster) then
        return false
    end

    if abilityName == "broodmother_spin_web" and CheckWebs(caster, target) then
        return false
    end

    return true
end

function CheckTraps(caster) 
    for _,unit in pairs(Entities:FindAllByClassname("npc_dota_base_additive")) do
        if unit:GetUnitName() == "npc_dota_templar_assassin_psionic_trap" and unit:GetOwnerEntity() == caster then
            return true
        end
    end
end

function CheckWebs(caster, target)
    if target then
        local webs = Entities:FindAllByClassnameWithin("npc_dota_broodmother_web", target:GetAbsOrigin(), 500)
        return #webs > 0
    end
end

function FindFriendlyInRadius(npc, radius)
    return FindUnitsInRadius(
        npc:GetTeamNumber(),
        npc:GetAbsOrigin() ,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
        DOTA_UNIT_TARGET_FLAG_NONE, 
        FIND_ANY_ORDER,
        false )
end

function FindEnemyInRadius(npc, radius)
    return FindUnitsInRadius(
        npc:GetTeamNumber(),
        npc:GetAbsOrigin() ,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
        DOTA_UNIT_TARGET_FLAG_NONE, 
        FIND_CLOSEST,
        false )
end