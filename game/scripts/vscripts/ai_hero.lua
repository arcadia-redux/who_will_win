require 'utils_dow'

if HeroAI == nil then HeroAI = class({}) end

HERO_CMD_LIST = {"ATTACK_TARGET", "USE_ABILITY", "USE_ITEM", "MOVE_TO_POSITION" --[[, "PICKUP_ITEM", "PICKUP_RUNE", "MOVE_ITEM"]]}
UNIT_FILTER = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS
KV_RUBICK_CASTS = LoadKeyValues("scripts/kv/rubick_casts.txt")
KV_RUBICK_STEALS = LoadKeyValues("scripts/kv/rubick_steals.txt")
MOBILITY_ABILITIES = LoadKeyValues("scripts/kv/mobility_abilities.txt")
KV_SPELL_IMMUNITY_ABILITIES = LoadKeyValues("scripts/kv/spell_immunity_abilities.txt")

SequentialAbility = {
    {checkSpell = "ember_spirit_fire_remnant", nextSpell = "ember_spirit_activate_fire_remnant", duration = 1.5, nextNoTarget = false},
    {checkSpell = "shredder_chakram", nextSpell = "shredder_return_chakram", duration = 3, nextNoTarget = true},
    {checkSpell = "shredder_chakram_2", nextSpell = "shredder_return_chakram_2", duration = 3, nextNoTarget = true},
    {checkSpell = "ancient_apparition_ice_blast", nextSpell = "ancient_apparition_ice_blast_release", duration = 1, nextNoTarget = true},
    {checkSpell = "puck_illusory_orb", nextSpell = "puck_ethereal_jaunt", duration = 1, nextNoTarget = true},
    {checkSpell = "batrider_flaming_lasso", nextSpell = "batrider_firefly", duration = 1, nextNoTarget = true},
    {checkSpell = "elder_titan_ancestral_spirit", nextSpell = "elder_titan_echo_stomp", duration = 1.5, nextNoTarget = true},
    {checkSpell = "rubick_telekinesis", nextSpell = "rubick_telekinesis_land", duration = 0.8, nextNoTarget = false}
}

ToggleOnAbility = {
    [1] = "medusa_mana_shield",
    [2] = "leshrac_pulse_nova",
    [3] = "witch_doctor_voodoo_restoration",
    [4] = "pudge_rot",
    [5] = "troll_warlord_berserkers_rage"
}

DontCastAbility = {
    [1] = "mars_bulwark",
    [2] = "phoenix_sun_ray_toggle_move",
    [3] = "invoker_quas",
    [4] = "invoker_wex",
    [5] = "invoker_exort",
    [6] = "spectre_haunt",
    [7] = "tiny_toss_tree",
    [8] = "puck_ethereal_jaunt",
    [9] = "ancient_apparition_ice_blast_release",
    [10] = "techies_focused_detonate",
    [11] = "tusk_ice_shards_stop",
    [12] = "morphling_morph_agi",
    [13] = "morphling_morph_str",
    [14] = "lone_druid_true_form_druid",
    [15] = "ember_spirit_activate_fire_remnant",
    [16] = "phoenix_icarus_dive_stop",
    [17] = "abyssal_underlord_cancel_dark_rift",
    [18] = "skeleton_king_vampiric_aura",
    [19] = "pangolier_gyroshell_stop",
    [21] = "templar_assassin_trap",
    [22] = "keeper_of_the_light_illuminate_end",
    [23] = "keeper_of_the_light_spirit_form_illuminate_end",
    [25] = "naga_siren_song_of_the_siren_cancel",
    [26] = "rubick_telekinesis_land",
    [27] = "monkey_king_untransform",
    [28] = "templar_assassin_self_trap",
    [29] = "visage_stone_form_self_cast",
    [30] = "monkey_king_primal_spring_early",
    [31] = "phantom_lancer_phantom_edge",
    [32] = "pudge_eject",
    [32] = "life_stealer_consume",
    [33] = "wisp_tether_break",
    [34] = "furion_teleportation",
    [35] = "abyssal_underlord_dark_rift",
    [36] = "wisp_relocate",
    [37] = "techies_minefield_sign",
}

DontCastItems = {
    [1] = "item_moon_shard",
    [2] = "item_bfury",
    [3] = "item_sphere",
    [4] = "item_shadow_amulet",
    [5] = "item_aegis",
    [6] = "item_smoke_of_deceit",
    [7] = "item_tome_of_upgrade",
    [8] = "item_scroll_of_time",
}

PriorityCastNoTargetAbility = {
    [1] = "dragon_knight_elder_dragon_form",
    [2] = "naga_siren_mirror_image",
    [3] = "night_stalker_darkness",
    [4] = "beastmaster_call_of_the_wild_boar",
    [8] = "clinkz_wind_walk",
    [9] = "terrorblade_metamorphosis",
    [10] = "lone_druid_spirit_bear",
    [11] = "lone_druid_true_form",
    [13] = "templar_assassin_refraction",
    [15] = "nyx_assassin_vendetta",
    [16] = "bounty_hunter_wind_walk",
    [20] = "ddw_chaos_knight_phantasm",
    [22] = "visage_summon_familiars",
    [23] = "ember_spirit_flame_guard",
    [24] = "phantom_assassin_blur",
    [25] = "invoker_forge_spirit",
    [26] = "invoker_ghost_walk",
    [27] = "mirana_invis",
    [28] = "pangolier_gyroshell",
    [29] = "spirit_breaker_bulldoze",
    [30] = "pangolier_shield_crash",
    [31] = "undying_flesh_golem",
    [32] = "arc_warden_scepter",
    [33] = "winter_wyvern_arctic_burn",
    [34] = "windrunner_windrun",
    [35] = "obsidian_destroyer_equilibrium",
    [36] = "sniper_take_aim",
    [37] = "slardar_sprint",
    [38] = "wisp_spirits",
    [39] = "wisp_spirits_in",
}

AdjustRadiusAbility = {
    [1] = "zuus_thundergods_wrath",
    [2] = "tinker_heat_seeking_missile",
    [3] = "terrorblade_conjure_image",
    [4] = "necrolyte_death_pulse",
    [6] = "arc_warden_tempest_double",
    [7] = "chen_hand_of_god",
    [8] = "sven_gods_strength",
    [9] = "invoker_ghost_walk",
    [10] = "invoker_ice_wall",
    [11] = "invoker_forge_spirit",
    [13] = "windrunner_windrun",
    [14] = "gyrocopter_flak_cannon",
    [15] = "life_stealer_rage",
    [16] = "silencer_global_silence",
    [17] = "medusa_stone_gaze",
    [18] = "mirana_leap",
    [19] = "clinkz_strafe",
    [20] = "dark_willow_shadow_realm",
    [21] = "dark_willow_bedlam",
    [22] = "slark_shadow_dance",
    [25] = "weaver_shukuchi",
    [26] = "skywrath_mage_concussive_shot",
}

AdjustNoTargetAbility = {
    [1] = "ursa_enrage",
    [2] = "ursa_overpower",
    [3] = "life_stealer_rage",
    [5] = "tinker_heat_seeking_missile",
    [6] = "terrorblade_conjure_image",
    [7] = "necrolyte_death_pulse",
    [9] = "arc_warden_tempest_double",
    [10] = "invoker_ghost_walk",
    [11] = "brewmaster_primal_split",
    [12] = "chen_hand_of_god",
    [14] = "lone_druid_true_form_battle_cry",
    [15] = "sven_gods_strength",
    [16] = "invoker_ice_wall",
    [17] = "invoker_forge_spirit",
    [18] = "lone_druid_savage_roar",
    [20] = "gyrocopter_flak_cannon",
    [21] = "silencer_global_silence",
    [22] = "medusa_stone_gaze",
    [23] = "mirana_leap",
    [24] = "dark_willow_shadow_realm",
    [25] = "dark_willow_bedlam",
    [26] = "slark_shadow_dance",
    [27] = "obsidian_destroyer_equilibrium",
    [29] = "omniknight_guardian_angel",
}

AdjustPointAbility = {
    [2] = "invoker_tornado",
    [3] = "invoker_chaos_meteor",
    [4] = "invoker_deafening_blast",
    [5] = "mars_arena_of_blood",
    [7] = "grimstroke_dark_artistry",
    [8] = "keeper_of_the_light_blinding_light",
}

CastToNearestPointAbility = {
    [1] = "nyx_assassin_impale",
    [2] = "lion_impale",
    [3] = "zuus_lightning_bolt",
    [4] = "lina_light_strike_array",
    [5] = "shadow_demon_soul_catcher",
    [6] = "clinkz_burning_army",
    [7] = "techies_stasis_trap",
    [8] = "techies_land_mines",
    [9] = "techies_remote_mines",
    [11] = "mirana_arrow",
    [12] = "monkey_king_primal_spring",
    [13] = "meepo_earthbind",
    [14] = "faceless_void_time_walk",
    [15] = "undying_decay",
    [16] = "undying_tombstone",
    [17] = "faceless_void_chronosphere",
    [18] = "jakiro_dual_breath",
    [19] = "lina_dragon_slave",
    [20] = "mars_spear",
    [21] = "silencer_curse_of_the_silent",
    [22] = "phoenix_fire_spirits",
    [23] = "pangolier_swashbuckle",
    [24] = "furion_sprout",
    [25] = "riki_tricks_of_the_trade",
    [26] = "snapfire_mortimer_kisses",
    [27] = "treant_natures_grasp",
    [28] = "leshrac_split_earth",
    [29] = "furion_wrath_of_nature",
    [30] = "arc_warden_spark_wraith",
    [31] = "legion_commander_overwhelming_odds",
    [32] = "tusk_ice_shards",
    [33] = "mars_gods_rebuke",
    [34] = "dragon_knight_breathe_fire",
    [35] = "alchemist_acid_spray",
    [36] = "snapfire_scatterblast",
    [37] = "drow_ranger_wave_of_silence",
    [38] = "drow_ranger_multishot"
}

CastToLinearAbility = {
    [1] = "earthshaker_fissure",
    [2] = "elder_titan_earth_splitter",
    [3] = "jakiro_ice_path",
    [4] = "jakiro_macropyre",
    [5] = "monkey_king_boundless_strike",
    [6] = "vengefulspirit_wave_of_terror",
    [7] = "windrunner_powershot",
    [8] = "queenofpain_sonic_wave",
    [9] = "phoenix_sun_ray",
    [10] = "phoenix_icarus_dive",
    [11] = "earth_spirit_rolling_boulder",
    [12] = "tinker_march_of_the_machines",
    [13] = "venomancer_venomous_gale",
}

SuperNoTargetAbility = {
    [1] = "phoenix_supernova",
    [2] = "venomancer_poison_nova",
    [3] = "nevermore_requiem",
    [4] = "tidehunter_ravage",
}

CheckModifierPointTargetAbility = {
    [1] = "doom_bringer_doom",
    [2] = "bloodseeker_rupture",
    [3] = "oracle_false_promise",
    [4] = "dazzle_shallow_grave",
    [5] = "slardar_amplify_damage",
    [6] = "axe_battle_hunger",
    [7] = "bounty_hunter_track",
    [8] = "winter_wyvern_cold_embrace",
    [9] = "shadow_demon_demonic_purge",
}

CheckModifierNoTargetAbility = {
    [1] = "troll_warlord_battle_trance",
    [2] = "ursa_enrage",
    [3] = "death_prophet_exorcism",
    [4] = "centaur_stampede",
    [5] = "windrunner_windrun",
    [6] = "sven_gods_strength",
    [7] = "lycan_shapeshift",
    [8] = "slark_shadow_dance",
    [9] = "void_spirit_resonant_pulse",
}

NoNotCheckEnemyItems = {
    [1] = "item_bloodstone",
    [2] = "item_blink",
    [3] = "item_tpscroll",
    [5] = "item_refresher",
    [6] = "item_ward_sentry",
    [7] = "item_dust",
    [8] = "item_mekansm",
    [9] = "item_guardian_greaves",
    [10] = "item_soul_ring",
    [11] = "item_satanic",
    [12] = "item_magic_stick",
    [13] = "item_magic_wand",
    [14] = "item_enchanted_mango",
    [15] = "item_clarity",
    [16] = "item_faerie_fire",
    [17] = "item_flask",
    [18] = "item_arcane_boots",
    [19] = "item_ghost",
    [20] = "item_ex_machina",
    [21] = "item_manta",
    [22] = "item_flicker",
    [23] = "item_holy_locket",
    [24] = "item_glimmer_cape",
    [25] = "item_invis_sword",
    [26] = "item_silver_edge",
    [27] = "item_illusionsts_cape",
    [28] = "item_power_treads",
    [29] = "item_vambrace",
}

DoNotCheckRefresherHero = {
    [1] = "npc_dota_hero_pangolier",
    [2] = "npc_dota_hero_phoenix",
    [3] = "npc_dota_hero_undying",
    [4] = "npc_dota_hero_legion_commander",
    [5] = "npc_dota_hero_crystal_maiden",
    [6] = "npc_dota_hero_riki",
    [7] = "npc_dota_hero_enigma",
    [8] = "npc_dota_hero_bane",
    [9] = "npc_dota_hero_troll_warlord",
    [10] = "npc_dota_hero_life_stealer",
    [11] = "npc_dota_hero_lycan",
}

UseBkbAbilites = {
    [1] = "phantom_assassin_phantom_strike",
    [2] = "crystal_maiden_freezing_field",
    [3] = "witch_doctor_death_ward",
    [4] = "enigma_black_hole",
    [5] = "faceless_void_time_walk",
    [6] = "morphling_waveform",
    [7] = "sandking_burrowstrike",
    [8] = "void_spirit_astral_step",
    [9] = "item_blink",
    [10] = "antimage_blink",
    [11] = "legion_commander_duel",
    [12] = "item_ex_machina",
    [13] = "item_refresher",
    [14] = "troll_warlord_battle_trance",
    [15] = "item_fallen_sky",
    [16] = "item_horizon",
    [17] = "earthshaker_enchant_totem",
}

DoNotRefreshModifier = {
    [0] = "modifier_undying_flesh_golem",
}

InvokerAbilities = {
    [1] = {
        name = "invoker_emp",
        ab1 = "invoker_wex",
        ab2 = "invoker_wex",
        ab3 = "invoker_wex",
    },
    [2] = {
        name = "invoker_tornado",
        ab1 = "invoker_quas",
        ab2 = "invoker_wex",
        ab3 = "invoker_wex",
    },
    [3] = {
        name = "invoker_alacrity",
        ab1 = "invoker_wex",
        ab2 = "invoker_wex",
        ab3 = "invoker_exort",
    },
    [4] = {
        name = "invoker_ghost_walk",
        ab1 = "invoker_quas",
        ab2 = "invoker_quas",
        ab3 = "invoker_wex",
    },
    [5] = {
        name = "invoker_deafening_blast",
        ab1 = "invoker_quas",
        ab2 = "invoker_wex",
        ab3 = "invoker_exort",
    },
    [6] = {
        name = "invoker_chaos_meteor",
        ab1 = "invoker_wex",
        ab2 = "invoker_exort",
        ab3 = "invoker_exort",
    },
    [7] = {
        name = "invoker_cold_snap",
        ab1 = "invoker_quas",
        ab2 = "invoker_quas",
        ab3 = "invoker_quas",
    },
    [8] = {
        name = "invoker_ice_wall",
        ab1 = "invoker_quas",
        ab2 = "invoker_quas",
        ab3 = "invoker_exort",
    },
    [9] = {
        name = "invoker_forge_spirit",
        ab1 = "invoker_quas",
        ab2 = "invoker_exort",
        ab3 = "invoker_exort",
    },
    [10] = {
        name = "invoker_sun_strike",
        ab1 = "invoker_exort",
        ab2 = "invoker_exort",
        ab3 = "invoker_exort",
    }
}

function HeroAI:IsValidPosition(pos)
    if pos == nil or pos == vec3_invalid then
        return false
    end

    if pos.y == nil or pos.x == nil then
        return false
    end

    return true
end

function HeroAI:IsAlive(target)
    if(target == nil or target:IsNull()) then
        return false
    end
    
    if(target.IsAlive == nil or target:IsAlive() == false) then
        return false
    end
    
    return true
end

function HeroAI:IsValidHeroTargetToCast(target)
    if(target == nil or target:IsNull()) then
        return false
    end

    if(target.IsIllusion == nil or target:IsIllusion()) then
        return false
    end

    if(target.IsRealHero == nil or target:IsRealHero() == false) then
        return false
    end

    if(target.IsOutOfGame == nil or target:IsOutOfGame()) then
        return false
    end

    if(target.HasModifier == nil or target.GetAbsOrigin == nil or target.IsInvulnerable == nil) then
        return false
    end

    if(target:IsInvulnerable()) then
        return false
    end

    --if(HeroAI:IsValidPosition(target:GetAbsOrigin()) == false) then
    --    return false
    --end

    if(target:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")) then
        return false
    end

    if(target:HasModifier("modifier_item_helm_of_the_undying_active")) then
        return false
    end

    if(target:HasModifier("modifier_tusk_snowball_movement")) then
        return false
    end

    return true
end

function HeroAI:IsTaunt(hero)
    if(hero == nil or hero:IsNull()) then
        return false
    end

    if(hero.HasModifier == nil) then
        return false
    end

    if(hero:HasModifier("modifier_axe_berserkers_call") or hero:HasModifier("modifier_legion_commander_duel")) then
        return true
    end

    if(hero:HasModifier("modifier_winter_wyvern_winters_curse")) then
        return true
    end

    if(hero:HasModifier("modifier_huskar_life_break_taunt")) then
        return true
    end
    
    return false
end

function HeroAI:HasTargetTrueSight(hero, target)
    if(hero == nil or hero:IsNull() or target == nil or target:IsNull()) then
        return false
    end

    if(target:HasModifier("modifier_truesight")) then
        local modifiers = target:FindAllModifiersByName("modifier_truesight")
        for i, v in pairs(modifiers) do
            local caster = v:GetCaster()
            if(caster ~= nil and caster:IsNull() == false) then
                if(caster:GetTeamNumber() == hero:GetTeamNumber()) then
                    return true
                end
            end
        end
    end
    return false
end

function HeroAI:OnHeroThink(hero)
    if IsClient() then return nil end
    
    local highestScoreCommand = 1
    local highestScore = 0
    local highestData = nil
    
    if(hero == nil or hero:IsNull() or hero.IsRealHero == nil or hero:IsRealHero() == false) then
        return nil
    end
    
    if(HeroAI:IsAlive(hero) == false and hero:IsReincarnating() == false) then
        return nil
    end
    
    local team = hero:GetTeamNumber()
    if(team ~= DOTA_TEAM_GOODGUYS and team ~= DOTA_TEAM_BADGUYS) then
        return nil
    end

    if(GameRules:IsGamePaused()) then
        return 0.2
    end

    if(hero:HasModifier("modifier_life_stealer_infest")) then
        local doNotEJect = false
        if(hero.infestHost ~= nil) then
            if(HeroAI:IsAlive(hero.infestHost) and hero.infestHost:HasModifier("modifier_life_stealer_rage")) then
                doNotEJect = true
            end
        end

        if(doNotEJect == false and hero:GetHealthPercent() > 90) then
            local ejectAb = hero:FindAbilityByName("life_stealer_consume")
            if(ejectAb ~= nil) then
                hero:CastAbilityNoTarget(ejectAb, hero:GetPlayerID())
            end
        end
        return 0.2
    end

    -- if(hero:GetPlayerID() == 0) then
    --     for _, v in pairs(hero:FindAllModifiers()) do
    --         print(v:GetName())
    --     end
    -- end

    if(hero:HasModifier("modifier_snapfire_spit_creep_arcing_unit")) then
        local spitModi = hero:FindModifierByName("modifier_snapfire_spit_creep_arcing_unit")
        if(spitModi ~= nil) then
            HeroAI:CheckAndUseBKB(hero, true)
        end
    end

    if(hero.IsCommandRestricted ~= nil and hero:IsCommandRestricted()) then
        if(hero:HasModifier("modifier_troll_warlord_berserkers_rage") == false) then
            return 0.2
        end
    end

    if(hero:HasModifier("modifier_pudge_swallow_hide")) then
        if(hero:GetHealthPercent() > 90) then
            ExecuteOrderFromTable({
                UnitIndex = hero:entindex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                Position = hero:GetAbsOrigin(),
                TargetIndex = 0,
                AbilityIndex = 0,
                Queue = 0
            })
        end
        return 0.2
    end

    if(hero.IsOutOfGame ~= nil and hero:IsOutOfGame()) then
        if(hero:GetName() ~= "npc_dota_hero_phoenix") then
            return 0.2
        else
            if(hero:HasModifier("modifier_phoenix_supernova_hiding") == false or CheckHasTalent(hero, "special_bonus_unique_phoenix_7") == false) then
                return 0.2
            end
        end
    end

    if(hero.needRefreshMorphAblilites == true) then
        local morphAb = hero:FindAbilityByName("morphling_morph_replicate")
        if(morphAb ~= nil and morphAb:IsHidden() == false) then
            local hasNewAb = false
            for i = 0, hero:GetAbilityCount() - 1 do
                local ability = hero:GetAbilityByIndex(i)
                local canCast = true
                if(ability == nil or ability:GetLevel() <= 0) then
                    canCast = false
                elseif(ability:IsHidden() or ability:IsPassive() or ability:IsActivated() == false) then
                    canCast = false
                elseif(string.find(ability:GetName(), "_bonus") ~= nil) then
                    canCast = false
                end

                if(canCast and string.find(ability:GetName(), "morphling_") == nil) then
                    hasNewAb = true
                    break
                end
            end

            if(hasNewAb) then
                hero.needRefreshMorphAblilites = false
                --[[CreateTimer(function()
                   if(hero ~= nil) then
                        GameRules.DW.EndAbilitiesCooldown(hero)
                    end
                end, 0.5)]]
            end
        end
    end

    for i, v in pairs(HERO_CMD_LIST) do
        local score, cmdData = HeroAI:EvaluateCommand(hero, v)
        if(score > highestScore or (score == highestScore and RollPercentage(50))) then
            highestScore = score
            highestScoreCommand = i
            highestData = cmdData
        end
    end

    hero.LastThinkTime = GameRules:GetGameTime()

    if(highestData ~= nil and highestScore > 0) then
        local delay = HeroAI:ExecuteCommand(hero, HERO_CMD_LIST[highestScoreCommand], highestData)
        -- if(hero:GetPlayerID() == 0) then
        --     if(HERO_CMD_LIST[highestScoreCommand] == "USE_ABILITY") then
        --         print(HERO_CMD_LIST[highestScoreCommand], highestData.ability:GetName(), delay)
        --     else
        --         print(HERO_CMD_LIST[highestScoreCommand], delay)
        --     end
        -- end
        if(delay == nil or delay <= 0) then
            delay = 0.2
        end
        return delay
    else
        return 0.2
    end
end

function HeroAI:EvaluateCommand(hero, cmdName)
    if(hero == nil or hero:IsNull() or hero.GetPlayerID == nil) then
        return 0, nil
    end

    local playerId = hero:GetPlayerID()
    local location = hero:GetAbsOrigin()
    local teamId = hero:GetTeam()
    local score = 0
    
    if(cmdName == "ATTACK_TARGET") then
        if(hero:IsChanneling() or hero:IsStunned() or hero:IsFrozen()) then
            return 0, nil
        end
        
        if(hero:IsIdle() == false) then
            if(hero:AttackReady() == false or hero:IsAttacking()) then
                return 0, nil
            end
            
            if(hero:GetCurrentActiveAbility() ~= nil) then
                return 0, nil
            end
        end
        
        if(hero:IsAttackImmune()) then
            if(hero:HasModifier("modifier_void_spirit_dissimilate_phase") == false) then
                if(hero:HasModifier("modifier_dark_willow_shadow_realm_buff") == false or hero:HasScepter() == false) then
                    return 0, nil
                end
            end
        end

        if(hero:HasModifier("modifier_nyx_assassin_burrow") or hero:HasModifier("modifier_spirit_breaker_charge_of_darkness")) then
            return 0, nil
        end

        if(hero:GetName() == "npc_dota_hero_techies") then
            if(HeroAI:HasEnemyNearby(hero, 1000) == false) then
                local moveMineAbility = hero:FindAbilityByName("special_bonus_unique_techies_4")
                if(moveMineAbility ~= nil and moveMineAbility:GetLevel() > 0) then
                    return 0, nil
                end    
            end
        end

        if(hero:GetName() == "npc_dota_hero_rattletrap") then
            local hTarget = HeroAI:GetSpecialChildrenTarget(hero, 300, "npc_dota_rattletrap_cog")
            if(hTarget ~= nil and hTarget:IsNull() == false) then
                return 4, hTarget
            end
        end

        local attackTarget = hero:GetAttackTarget()
        
        if(attackTarget == nil or HeroAI:IsAlive(attackTarget) == false) then
            local nearestEnemy = nil

            if(nearestEnemy == nil) then
                nearestEnemy = HeroAI:ClosestEnemyAll(hero, teamId)
            end
            
            if(nearestEnemy == nil or HeroAI:IsAlive(nearestEnemy) == false) then
                return 0, nil
            end

            if(hero.tetherTarget ~= nil and HeroAI:IsAlive(hero.tetherTarget)) then
                if(hero:HasItemInInventory("item_no_attack") and hero.tetherTarget:HasModifier("modifier_wisp_tether_haste")) then
                    return 3, hero.tetherTarget
                end
            end
            
            if(hero:HasModifier("modifier_item_silver_edge_windwalk") or hero:HasModifier("modifier_item_invisibility_edge_windwalk") or hero:HasModifier("modifier_nyx_assassin_vendetta")) then
                if(hero:HasModifier("modifier_monkey_king_tree_dance_hidden") == false and hero:HasModifier("modifier_monkey_king_tree_dance_activity") == false) then
                    if(hero.HasItemInInventory ~= nil and hero:HasItemInInventory("item_no_attack") == false) then
                        if(nearestEnemy.IsRealHero == nil or nearestEnemy:IsRealHero() == false) then
                            nearestEnemy = HeroAI:GetClosestEnemyHero(hero, 6000)
                            if(nearestEnemy ~= nil) then
                                return 5, nearestEnemy
                            end
                        end
                    end
                end
            end
            
            return 3, nearestEnemy
        end
        
        return 0, nil
    end
    
    if(cmdName == "USE_ABILITY") then
        if(hero:IsSilenced()) then
            return 0, nil
        end

        if(hero:GetName() == "npc_dota_hero_ursa") then
            if(hero:HasScepter()) then
                if(hero:IsStunned() or hero:IsMovementImpaired() or hero:IsNightmared() or hero:IsBlockDisabled() or HeroAI:IsTaunt(hero) or hero:IsRooted()) then
                    if(hero:HasModifier("modifier_ursa_enrage") == false and hero:HasModifier("modifier_lycan_shapeshift_transform") == false) then
                        local ult = hero:FindAbilityByName("ursa_enrage")
                        if(ult ~= nil and ult:GetLevel() > 0 and ult:IsActivated() and ult:IsFullyCastable() and ult:IsCooldownReady()) then
                            return 5, {ability = ult, type = "no_target", target = nil}
                        end
                    end
                end
            end
        end

        if(hero:GetName() == "npc_dota_hero_troll_warlord") then
            if(hero:IsStunned() or hero:IsMovementImpaired() or hero:IsNightmared() or hero:IsBlockDisabled() or HeroAI:IsTaunt(hero) or hero:IsRooted()) then
                if(hero:HasModifier("modifier_lycan_shapeshift_transform") == false) then
                    local ult = hero:FindAbilityByName("troll_warlord_battle_trance")
                    if(ult ~= nil and ult:GetLevel() > 0 and ult:IsActivated() and ult:IsFullyCastable() and ult:IsCooldownReady()) then
                        local dispellTalent = hero:FindAbilityByName("special_bonus_unique_troll_warlord_4")
                        if(dispellTalent ~= nil and dispellTalent:GetLevel() > 0) then
                            if(hero:HasScepter()) then
                                return 5, {ability = ult, type = "unit_target", target = hero}
                            else
                                return 5, {ability = ult, type = "no_target", target = nil}
                            end
                        end
                    end
                end
            end
        end

        if(hero:IsStunned() or hero:IsFrozen()) then
            return 0, nil
        end
        
        if(hero:IsChanneling()) then
            return 0, nil
        end

        local delayTime = 6
        if(hero:GetName() == "npc_dota_hero_wisp") then
            delayTime = 4
        end

        if(HeroAI:IsTaunt(hero)) then
            return 0, nil
        end

        if(hero:HasModifier("modifier_riki_tricks_of_the_trade_phase") or hero:HasModifier("modifier_snapfire_mortimer_kisses")) then
            return 0, nil
        end

        if(hero:HasModifier("modifier_phantom_lancer_phantom_edge_boost") and hero:IsAttacking() == false and hero:IsDisarmed() == false) then
            return 0, nil
        end

        if(hero:HasModifier("modifier_item_silver_edge_windwalk") or hero:HasModifier("modifier_item_invisibility_edge_windwalk") or hero:HasModifier("modifier_nyx_assassin_vendetta")) then
            if(hero.HasItemInInventory ~= nil and hero:HasItemInInventory("item_no_attack") == false) then
                return 0, nil
            end
        end
        
        local canCastAbilities = {}
        
        for i = 0, hero:GetAbilityCount() - 1 do
            local ability = hero:GetAbilityByIndex(i)
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
                if ability:GetAutoCastState() == false then
                    ability:ToggleAutoCast()
                end
                
                canCast = false
            end
            
            if(canCast and ability:IsToggle() and ability:GetToggleState() == true) then
                canCast = false
            end

            if(canCast and ability.IsInactiveByPlayer == true) then
                ability:SetActivated(false)
                canCast = false
            end
            
            if canCast and table.contains(DontCastAbility, ability:GetName()) == false then
                table.insert(canCastAbilities, ability)
            end
        end
        
        if(hero:HasAbility("morphling_morph_agi")) then
            local morph_agi = hero:FindAbilityByName("morphling_morph_agi")
            local morph_str = hero:FindAbilityByName("morphling_morph_str")
            if(morph_agi ~= nil and morph_str ~= nil and morph_agi:GetLevel() > 0 and morph_str:GetLevel() > 0) then
                local currentHealth = hero:GetHealth()
                if(currentHealth > 3000 and hero:GetBaseStrength() > 1) then
                    if(morph_agi:GetToggleState() == false) then
                        morph_agi:ToggleAbility()
                    end
                elseif(currentHealth < 2500 and hero:GetBaseAgility() > 1) then
                    if(morph_str:GetToggleState() == false) then
                        morph_str:ToggleAbility()
                    end
                else
                    if(morph_agi:GetToggleState() == true) then
                        morph_agi:ToggleAbility()
                    elseif(morph_str:GetToggleState() == true) then
                        morph_str:ToggleAbility()
                    end
                end
            end
        end
        
        local toggleAbility = nil
        local priorityAbility = nil
        
        if(#canCastAbilities > 0) then
            for _, v in pairs(canCastAbilities) do
                if(v:IsToggle() and v:GetToggleState() == false and table.contains(ToggleOnAbility, v:GetName())) then
                    toggleAbility = v
                end
                if(table.contains(PriorityCastNoTargetAbility, v:GetName())) then
                    if(v:IsToggle() and v:GetToggleState() == false) then
                        v:ToggleAbility()
                        table.insert(hero.toggleOffList, v)
                    else
                        priorityAbility = v    
                    end
                end
            end
        end
        
        if(priorityAbility ~= nil) then
            if(priorityAbility:GetName() == "lone_druid_spirit_bear") then
                if(hero.bear == nil or hero.bear:IsNull() == true or hero.bear:GetHealth() < hero.bear:GetMaxHealth() * 0.25) then
                    return 4, {ability = priorityAbility, type = "no_target", target = nil}
                end
            elseif(priorityAbility:GetName() == "ddw_chaos_knight_phantasm" and hero:HasScepter()) then
                local hTarget = HeroAI:GetMostDamageFriendlyTarget(priorityAbility, false)
                if hTarget ~= nil and hTarget:IsNull() == false and HeroAI:IsAlive(hTarget) then
                    return 4, {ability = priorityAbility, type = "unit_target", target = hTarget}
                else
                    return 4, {ability = priorityAbility, type = "unit_target", target = hero}    
                end
            elseif(priorityAbility:GetName() == "pangolier_shield_crash") then
                if(hero:HasModifier("modifier_pangolier_gyroshell")) then
                    local jumpPos = hero:GetAbsOrigin() + hero:GetForwardVector() * 600
                    if(HeroAI:HasEnemyNearPosition(hero, jumpPos, 450)) then
                        return 5, {ability = priorityAbility, type = "no_target", target = nil}
                    end
                else
                    if(HeroAI:HasEnemyNearby(hero, 450)) then
                        return 5, {ability = priorityAbility, type = "no_target", target = nil}
                    end
                end
            elseif(priorityAbility:GetName() == "visage_summon_familiars") then
                if(hero.familiarCount == nil or hero.familiarCount == 0) then
                    return 4, {ability = priorityAbility, type = "no_target", target = nil}
                end
            elseif(priorityAbility:GetName() == "terrorblade_metamorphosis") then
                return 4, {ability = priorityAbility, type = "no_target", target = nil}
            else
                if(table.contains(CheckModifierNoTargetAbility, priorityAbility:GetName())) then
                    if(HeroAI:CheckTargetNoModifier(priorityAbility, priorityAbility:GetCaster()) == true) then
                        return 4, {ability = priorityAbility, type = "no_target", target = nil}
                    end
                else
                    return 4, {ability = priorityAbility, type = "no_target", target = nil}    
                end
            end
        end
        
        if(toggleAbility ~= nil) then
            if(abilityName == "leshrac_pulse_nova" and HeroAI:HasEnemyNearby(hero, 1200)) then
                return 4, {ability = toggleAbility, type = "toggle", target = nil}
            elseif (HeroAI:HasEnemyNearby(hero)) then
                return 4, {ability = toggleAbility, type = "toggle", target = nil}
            end
        end

        canCastAbilities = table.shuffle(canCastAbilities) 
        for _, v in pairs(canCastAbilities) do
            local abilityName = v:GetName()
            if(table.contains(PriorityCastNoTargetAbility, abilityName) == false) then
                local spellData = HeroAI:GetSpellData(v)
                if(spellData ~= nil) then
                    local score = 4
            
                    if(abilityName == "bounty_hunter_track" and hero:HasModifier("modifier_bounty_hunter_wind_walk")) then
                        score = 6
                    end

                    return score, spellData
                end
            end
        end
        
        return 0, nil
    end
    
    if(cmdName == "USE_ITEM") then 
        if(hero:IsChanneling()) then
            local item = HeroAI:GetHeroItemForCast(hero, "item_glimmer_cape")
            if(item ~= nil and item:IsNull() == false and item:IsCooldownReady()) then
                hero:CastAbilityOnTarget(hero, item, hero:GetPlayerID())
            end

            return 0, nil
        end
        
        if(hero:IsMuted() or hero:IsStunned() or hero:IsFrozen()) then
            return 0, nil
        end
        
        if(hero:HasInventory() == false) then
            return 0, nil
        end

        if(HeroAI:IsTaunt(hero)) then
            return 0, nil
        end

        if(hero:HasModifier("modifier_riki_tricks_of_the_trade_phase") or hero:HasModifier("modifier_snapfire_mortimer_kisses")) then
            return 0, nil
        end

        if(hero:HasModifier("modifier_phantom_lancer_phantom_edge_boost") and hero:IsAttacking() == false and hero:IsDisarmed() == false) then
            return 0, nil
        end
        
        local canCastItems = {}
        
        for slotIndex = 0, 16 do
            if(slotIndex <= 5 or slotIndex == 15 or slotIndex == 16) then
                local item = hero:GetItemInSlot(slotIndex)
                if(item ~= nil) then
                    local itemName = item:GetName()
                    local canCast = true
                    
                    if(itemName == "item_armlet") then
                        if item:GetToggleState() == false and HeroAI:HasEnemyNearby(hero) then
                            item:ToggleAbility()
                            if (hero.toggleOffList == nil) then
                                hero.toggleOffList = {}
                            end
                            table.insert(hero.toggleOffList, item)
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
                    elseif(table.contains(DontCastItems, itemName)) then
                        canCast = false
                    end

                    if canCast then
                        table.insert(canCastItems, item)
                    end
                end
            end
        end

        canCastItems = table.shuffle(canCastItems) 
        for _, v in pairs(canCastItems) do
            local itemName = v:GetName()

            if(itemName == "item_ultimate_scepter") then
                local hTarget = HeroAI:GetScepterGiveTarget(v)
                if(hTarget ~= nil and hTarget:IsNull() == false) then
                    return 5, {ability = v, type = "unit_target", target = hTarget}
                end
            end

            if(hero:GetHealthPercent() <= 80) then
                if(itemName == "item_black_king_bar" and hero:IsMagicImmune() == false) then
                    return 5, {ability = v, type = "no_target", target = nil}
                end

                if(itemName == "item_minotaur_horn" and hero:IsMagicImmune() == false) then
                    return 5, {ability = v, type = "no_target", target = nil}
                end

                if(itemName == "item_blade_mail" and hero:HasModifier("modifier_item_blade_mail_reflect") == false) then
                    return 5, {ability = v, type = "no_target", target = nil}
                end

                if(itemName == "item_cyclone" or itemName == "item_urn_of_shadows") then
                    return 4, {ability = v, type = "unit_target", target = hero}
                end                
            end
            
            if(itemName == "item_necronomicon_3" or itemName == "item_necronomicon_2" or itemName == "item_necronomicon" or itemName == "item_demonicon") then
                return 4, {ability = v, type = "no_target", target = nil}
            end
            
            if(itemName ~= "item_ultimate_scepter") then
                local isDoNotCheckItem = table.contains(NoNotCheckEnemyItems, itemName)
                if(HeroAI:HasEnemyNearby(hero, 1000) or isDoNotCheckItem) then
                    local spellData = HeroAI:GetSpellData(v)
                    if(spellData ~= nil) then
                        local score = 4
                        if(isDoNotCheckItem) then
                            score = 5
                        end
                        
                        return score, spellData    
                    end
                end
            end
        end
        
        return 0, nil
    end
    
    if(cmdName == "MOVE_TO_POSITION") then
        if(hero:HasModifier("modifier_pangolier_gyroshell")) then
            local enemy = HeroAI:GetFarestEnemyTarget(hero, 1800)
            if(enemy ~= nil) then
                local vTargetLoc = enemy:GetAbsOrigin()
                if HeroAI:IsValidPosition(vTargetLoc) and (hero:GetAbsOrigin() - vTargetLoc):Length2D() > 100 then
                    return 4, vTargetLoc
                end
            end
        end

        if(hero:IsChanneling() or hero:IsStunned() or hero:IsFrozen()) then
            return 0, nil
        end

        if(hero:HasModifier("modifier_monkey_king_transform") and HeroAI:HasEnemyNearby(hero, 300) == true) then
            local loc = HeroAI:FindGoBackPosition(hero, 200)
            if(loc ~= nil and HeroAI:IsValidPosition(loc)) then
                return 4, loc
            end
        end
        
        if(hero:IsRangedAttacker() == false) then
            return 0, nil
        end

        if(hero:HasModifier("modifier_weaver_shukuchi") and HeroAI:HasEnemyNearby(hero, 600) == true) then
            local loc = HeroAI:FindGoBackPosition(hero, 300)
            if(loc ~= nil and HeroAI:IsValidPosition(loc)) then
                return 4, loc
            end
        end

        --[[if(hero:GetName() == "npc_dota_hero_techies") then
            local moveMineAbility = hero:FindAbilityByName("special_bonus_unique_techies_4")
            if(moveMineAbility ~= nil and moveMineAbility:GetLevel() > 0) then
                local spawnLocation = GameRules.DW.BattleFightPosition
                local heroLocation = hero:GetAbsOrigin()
                if(hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS) then
                    spawnLocation = Vector(spawnLocation.x - 2000, heroLocation.y, heroLocation.z)
                else
                    spawnLocation = Vector(spawnLocation.x + 2000, heroLocation.y, heroLocation.z)
                end

                local wayFromCenter = (heroLocation - spawnLocation):Length2D()
                if(wayFromCenter > 250 and HeroAI:HasEnemyNearby(hero, 800) == false) then
                    return 3, spawnLocation
                end
            end
        end]]

        if(HeroAI:IsTaunt(hero)) then
            return 0, nil
        end
        
        if(hero:HasModifier("modifier_windrunner_focusfire") and HeroAI:HasEnemyNearby(hero, 450) == true) then
            local loc = HeroAI:FindGoBackPosition(hero, 100)
            if(loc ~= nil and HeroAI:IsValidPosition(loc)) then
                return 4, loc
            end
        end
        
        if(hero:GetName() == "npc_dota_hero_leshrac") then
            if(hero:HasModifier("modifier_leshrac_pulse_nova")) then
                local hSpell = hero:FindAbilityByName("leshrac_pulse_nova")
                if(hSpell ~= nil) then
                    HeroAI:CheckAndUseBKB(hero)
                    local vTargetLoc = HeroAI:GetBestAOEPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY)
                    if HeroAI:IsValidPosition(vTargetLoc) and (hero:GetAbsOrigin() - vTargetLoc):Length2D() > 100 then
                        return 4, vTargetLoc
                    end
                end
            end
        end
        
        if(hero:GetName() == "npc_dota_hero_batrider") then
            if(hero:HasModifier("modifier_batrider_flaming_lasso_self")) then
                local vTargetLoc = unit.targetPoint
                
                if vTargetLoc ~= nil and (hero:GetAbsOrigin() - vTargetLoc):Length2D() > 100 then
                    return 4, vTargetLoc
                end
            elseif(hero:HasModifier("modifier_batrider_firefly") and hero:GetLevel() < 25) then
                local enemy = HeroAI:GetFarestEnemyTarget(hero, 600)
                if(enemy ~= nil) then
                    local vTargetLoc = enemy:GetAbsOrigin()
                    if HeroAI:IsValidPosition(vTargetLoc) and (hero:GetAbsOrigin() - vTargetLoc):Length2D() > 100 then
                        return 4, vTargetLoc
                    end
                end
            end
        end

        --[[if(hero:GetName() == "npc_dota_hero_storm_spirit" and hero:GetManaPercent() < 50) then
            if(HeroAI:HasEnemyNearby(hero, 1000) == false) then
                local fountainLoc = GameRules.DW.FountainGood
                if(hero:GetTeamNumber() ~= DOTA_TEAM_GOODGUYS) then
                    fountainLoc = GameRules.DW.FountainBad
                end
                local castLength = (fountainLoc - hero:GetAbsOrigin()):Length2D()
                local maxMana = hero:GetMaxMana()
                local manaCostEstimate = maxMana * 0.08 + 180 + (castLength + 200) / 100 * (10 + 0.005 * maxMana)
                if(hero:GetMana() < manaCostEstimate) then
                    if(hero:HasModifier("modifier_fountain_aura_buff") == false) then
                        return 4, fountainLoc
                    end
                end
            end
        end]]

        return 0, nil
    end
    
    if(cmdName == "PICKUP_ITEM") then
        if(hero:GetLevel() < 25) then
            return 0, nil
        end

        if(hero.IsTempestDouble ~= nil and hero:IsTempestDouble()) then
            return 0, nil
        end
        
        if(hero:IsChanneling()) then
            return 0, nil
        end
        
        if(HeroAI:IsTaunt(hero)) then
            return 0, nil
        end
        
        local vItemDrops = Entities:FindAllByClassname("dota_item_drop")
        for _, drop in pairs(vItemDrops) do
            if(drop ~= nil and drop:IsNull() == false and HeroAI:IsValidPosition(drop:GetAbsOrigin())) then
                local item = drop:GetContainedItem()
                if(item ~= nil and item:IsNull() == false) then
                    if (item:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D() < 300 then
                        if(HeroAI:HasRoomForPickupItem(hero)) then
                            return 4, drop
                        end
                    end
                end
            end
        end

        return 0, nil
    end

    if(cmdName == "PICKUP_RUNE") then
        if(hero:GetLevel() < 25) then
            return 0, nil
        end

        if(hero.IsTempestDouble ~= nil and hero:IsTempestDouble()) then
            return 0, nil
        end
        
        if(hero:IsChanneling()) then
            return 0, nil
        end

        local runeDrops = Entities:FindAllByClassname("dota_item_rune")
        local thisRune = nil
        for _, rune in pairs(runeDrops) do
            if(rune ~= nil and rune:IsNull() == false and HeroAI:IsValidPosition(rune:GetAbsOrigin())) then
                local runePos = rune:GetAbsOrigin()
                if (runePos - hero:GetAbsOrigin()):Length2D() < 300 and runePos.z < 130  then
                    thisRune = rune
                    break
                end
            end
        end

        if(thisRune ~= nil) then
            if(HeroAI:HasEnemyNearPosition(hero, thisRune:GetAbsOrigin(), 300) == false) then
                return 4, thisRune
            end
        end

        return 0, nil
    end

    if(cmdName == "MOVE_ITEM") then
        if(hero:IsChanneling()) then
            return 0, nil
        end

        if(hero.IsTempestDouble ~= nil and hero:IsTempestDouble()) then
            return 0, nil
        end

        if(hero.GetItemInSlot == nil) then
            return 0, nil
        end

        local backpackItem = nil

        for slotIndex = 6, 8 do
            local checkItem = hero:GetItemInSlot(slotIndex)
            if(checkItem ~= nil and checkItem:IsNull() == false) then
                local itemName = checkItem:GetName()
                if(itemName ~= "item_no_attack" and itemName ~= "item_assassin_medal" and itemName ~= "item_ai_delay" and itemName ~= "item_phase_teleporter") then
                    backpackItem = checkItem
                    break
                end
            end
        end

        if(backpackItem == nil) then
            return 0, nil
        end

        local emptySlotIndex = -1
        for slotIndex = 0, 5 do
            local checkItem = hero:GetItemInSlot(slotIndex)
            if(checkItem == nil) then
                emptySlotIndex = slotIndex
                break
            end
        end

        if(backpackItem ~= nil and emptySlotIndex >= 0) then
            ExecuteOrderFromTable({
                UnitIndex = hero:entindex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_ITEM,
                TargetIndex = emptySlotIndex,
                AbilityIndex = backpackItem:entindex(),
                Queue = 0
            })
        end

        return 0, nil
    end
end

function HeroAI:HasRoomForPickupItem(hero)
    if(hero == nil or hero:IsNull() or hero.GetItemInSlot == nil) then
        return false
    end

    local itemCount = 0
    for slotIndex = 0, 5 do
        local item = hero:GetItemInSlot(slotIndex)
        if item ~= nil then
            itemCount = itemCount + 1
        end
    end
    return itemCount < 6
end

function HeroAI:CheckAndUseBKB(hero, ignoreState)
    if(hero == nil or hero:IsNull() or hero.GetItemInSlot == nil) then
        return false
    end

    if(ignoreState == nil) then
        if(hero:IsMuted() or hero:IsStunned() or hero:IsFrozen()) then
            return false
        end
    end

    if(hero:IsMagicImmune()) then
        return false
    end

    for slotIndex = 0, 16 do
        if(slotIndex <= 5 or slotIndex == 16) then
            local item = hero:GetItemInSlot(slotIndex)
            if item ~= nil then
                if(item:GetName() == "item_black_king_bar" and item:IsCooldownReady()) then
                    HeroAI:CastSpellNoTarget(item)
                    return true
                end
                if(item:GetName() == "item_minotaur_horn" and item:IsCooldownReady()) then
                    HeroAI:CastSpellNoTarget(item)
                    return true
                end
            end
        end
    end
    
    return false
end

function HeroAI:CheckAndUseSatanic(hero)
    if(hero == nil or hero:IsNull() or hero.GetItemInSlot == nil) then
        return false
    end

    if(hero:IsMuted() or hero:IsStunned() or hero:IsFrozen()) then
        return false
    end

    for slotIndex = 0, 5 do
        local item = hero:GetItemInSlot(slotIndex)
        if item ~= nil then
            if(item:GetName() == "item_satanic" and item:IsCooldownReady()) then
                HeroAI:CastSpellNoTarget(item)
                return true
            end
        end
    end
    
    return false
end

function HeroAI:GetHeroItemForCast(hero, itemName)
    if(hero == nil or hero:IsNull() or hero.GetItemInSlot == nil) then
        return nil
    end

    local maxIndex = 5

    for slotIndex = 0, maxIndex do
        local item = hero:GetItemInSlot(slotIndex)
        if item ~= nil then
            if(item:GetName() == itemName) then
                return item
            end
        end
    end
    
    return nil
end

function HeroAI:ExecuteCommand(hero, cmdName, cmdData)
    if(hero == nil or hero:IsNull()) then
        return 0.2
    end

    if(cmdName == "ATTACK_TARGET") then
        if(cmdData == nil or cmdData:IsNull()) then
            hero:MoveToPositionAggressive(hero.targetPoint)
            return 0.2
        end

        if(HeroAI:IsTaunt(hero)) then
            hero:MoveToPositionAggressive(hero:GetAbsOrigin())
            return 0.2
        end

        local isLandMine = false
        if(cmdData.GetUnitName ~= nil) then
            local unitName = cmdData:GetUnitName()
            if(unitName == "npc_dota_techies_stasis_trap" or unitName == "npc_dota_techies_land_mine" or unitName == "npc_dota_techies_remote_mine" or unitName == "npc_dota_rattletrap_cog") then
                isLandMine = true
            end
        end

        if(hero:HasModifier("modifier_void_spirit_dissimilate_phase")) then
            local castPosition = cmdData:GetAbsOrigin()
            local enemy = HeroAI:GetFarestEnemyTarget(hero, 1000)
            if(enemy ~= nil) then
                castPosition = enemy:GetAbsOrigin()
            end

            ExecuteOrderFromTable({
                UnitIndex = hero:entindex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                Position = castPosition,
                TargetIndex = 0,
                AbilityIndex = 0,
                Queue = 0
            })
            return 0.2
        end

        if(hero:HasModifier("modifier_snapfire_mortimer_kisses")) then
            local castPosition = cmdData:GetAbsOrigin()
            local enemy = HeroAI:GetFarestEnemyTarget(hero, 3000)
            if(enemy ~= nil) then
                castPosition = enemy:GetAbsOrigin()
            end
            
            ExecuteOrderFromTable({
                UnitIndex = hero:entindex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                Position = castPosition,
                TargetIndex = 0,
                AbilityIndex = 0,
                Queue = 0
            })
            return 0.2
        end

        if(hero:GetName() == "npc_dota_hero_phantom_lancer") then
            local phantomRush = hero:FindAbilityByName("phantom_lancer_phantom_edge")
            if(phantomRush ~= nil and phantomRush:GetLevel() > 0) then
                if(hero:IsDisarmed() == false) then
                    if(hero:HasScepter() or phantomRush:IsCooldownReady()) then
                        local rushDistance = 500 + phantomRush:GetLevel() * 100
                        if(CheckHasTalent(hero, "special_bonus_unique_phantom_lancer")) then
                            rushDistance = rushDistance + 500
                        end

                        local hTarget = HeroAI:GetClosestEnemyHero(hero, rushDistance)
                        if(hTarget ~= nil and hTarget:IsNull() == false) then
                            if(hTarget:IsInvulnerable() == false and hTarget:IsAttackImmune() == false) then
                                HeroAI:CheckAndUseBKB(hero)
                                ExecuteOrderFromTable({
                                    UnitIndex = hero:entindex(),
                                    OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                                    TargetIndex = hTarget:entindex()
                                })
                                return 0.2
                            end
                        end
                    end
                end
            end
        end

        --[[local heroPos = hero:GetAbsOrigin()
        if(heroPos.x > -4300 and heroPos.x < 4300) then
            if(hero:GetName() ~= "npc_dota_hero_meepo" or hero:GetHealthPercent() < 50) then
                if(hero.HasItemInInventory ~= nil and hero:HasItemInInventory("item_no_attack")) then
                    local targetPos = cmdData:GetAbsOrigin()
                    local team = hero:GetTeamNumber()
                    local moveVector = (GameRules.DW.FountainGood - targetPos):Normalized()
                    if(team == DOTA_TEAM_BADGUYS) then
                        moveVector = (GameRules.DW.FountainBad - targetPos):Normalized()
                    end

                    local movePos = targetPos + moveVector * 800 + RandomVector(150)

                    if(hero:HasModifier("modifier_wisp_tether")) then
                        movePos = targetPos + moveVector * 400
                        hero:MoveToPosition(movePos)
                        return 0.3
                    end

                    hero:MoveToPosition(movePos)
                    return 1.0
                end
            end
        end]]

        local isAssassin = false
        if(hero.HasItemInInventory ~= nil and hero:HasItemInInventory("item_assassin_medal")) then
            isAssassin = true
        end

        if(hero:HasModifier("modifier_item_silver_edge_windwalk") or hero:HasModifier("modifier_item_invisibility_edge_windwalk") or hero:HasModifier("modifier_nyx_assassin_vendetta")) then
            isAssassin = true
        end
        
        if(isAssassin and hero:GetHealthPercent() > 40) then
            hero:MoveToTargetToAttack(cmdData)
        elseif(isLandMine) then
            hero:MoveToTargetToAttack(cmdData)
        else
            local targetPosition = cmdData:GetAbsOrigin()

            if(HeroAI:IsValidPosition(targetPosition) == false) then
                targetPosition = hero.targetPoint
            end
            
            if(hero:IsDisarmed() and hero:IsRangedAttacker()) then
                if(hero.releaseMove == nil or hero.releaseMove == false) then
                    hero.releaseMove = true
                    ExecuteOrderFromTable({
                        UnitIndex = hero:entindex(),
                        OrderType = DOTA_UNIT_ORDER_STOP
                    })
                end
                return 0.2
            else
                hero.releaseMove = false
                hero:MoveToPositionAggressive(targetPosition)
            end
        end

        local delay = 0.5
        if(hero.GetDisplayAttackSpeed ~= nil and hero:GetDisplayAttackSpeed() > 0) then
            delay = 170 / hero:GetDisplayAttackSpeed()
        end

        return delay
    end
    
    if(cmdName == "USE_ABILITY") then
        if(cmdData == nil) then
            hero:MoveToPositionAggressive(hero.targetPoint)
            return 0.2
        end
        
        local loopTime = HeroAI:CastSpell(cmdData)
        
        HeroAI:CheckSequentialAbility(hero, cmdData)
        
        return loopTime
    end
    
    if(cmdName == "USE_ITEM") then
        if(cmdData == nil) then
            hero:MoveToPositionAggressive(hero.targetPoint)
            return 0.2
        end
        
        local loopTime = HeroAI:CastSpell(cmdData)
        
        return loopTime
    end
    
    if(cmdName == "MOVE_TO_POSITION") then
        if(HeroAI:IsValidPosition(cmdData) == false) then
            hero:MoveToPositionAggressive(hero.targetPoint)
            return 0.2
        end
        
        if(hero:GetName() == "npc_dota_hero_pangolier") then
            ExecuteOrderFromTable({
                UnitIndex = hero:entindex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                Position = cmdData,
                TargetIndex = 0,
                AbilityIndex = 0,
                Queue = 0
            })
            return 0.2
        end
        
        local startPos = hero:GetAbsOrigin()
        local targetPos = cmdData
        
        hero:MoveToPosition(cmdData)
        
        local spendTime = (targetPos - startPos):Length2D() / hero:GetIdealSpeed()
        if(spendTime < 0.1) then spendTime = 0.1 end

        if(hero:HasModifier("modifier_leshrac_pulse_nova")) then
            if(spendTime > 0.5) then spendTime = 0.5 end
        else
            if(spendTime > 2.0) then spendTime = 2.0 end
        end
        
        return spendTime
    end
    
    if(cmdName == "PICKUP_ITEM") then
        if(cmdData == nil or cmdData:IsNull()) then
            hero:MoveToPositionAggressive(hero.targetPoint)
            return 0.2
        end
        
        local item = cmdData

        if(item == nil or item:IsNull()) then
            return 0.2
        end
        
        hero:PickupDroppedItem(item)
        
        local startPos = hero:GetAbsOrigin()
        local endPos = item:GetAbsOrigin()
        local moveLength = (endPos - startPos):Length2D()

        local movespeed = hero:GetIdealSpeed()
        if(movespeed <= 0) then
            return 0.2
        end

        local spendTime = moveLength / movespeed

        if(spendTime == nil or spendTime < 0.2) then
            spendTime = 0.2
        end
        
        return spendTime
    end

    if(cmdName == "PICKUP_RUNE") then
        if(cmdData == nil or cmdData:IsNull()) then
            hero:MoveToPositionAggressive(hero.targetPoint)
            return 0.2
        end
        
        local rune = cmdData

        if(rune == nil or rune:IsNull()) then
            return 0.2
        end
        
        hero:PickupRune(rune)
        
        local startPos = hero:GetAbsOrigin()
        local endPos = rune:GetAbsOrigin()
        local moveLength = (endPos - startPos):Length2D()

        local movespeed = hero:GetIdealSpeed()
        if(movespeed <= 0) then
            return 0.2
        end

        local spendTime = moveLength / movespeed

        if(spendTime == nil or spendTime < 0.2) then
            spendTime = 0.2
        end
        
        return spendTime
    end
    
    return 0.2
end

function HeroAI:CastSpell(spellData)
    local hSpell = spellData.ability
    
    if hSpell == nil then
        return 0.2
    end
    
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull()) then
        return 0.2
    end
    
    if(HeroAI:IsAlive(caster) == false) then
        return 0.2
    end
    
    local abilityName = hSpell:GetName()
    
    if(abilityName == "invoker_sun_strike") then
        if(caster:HasScepter()) then
            return HeroAI:CastSpellOnSelf(hSpell)
        end
    end
    
    if(abilityName == "pangolier_swashbuckle" or abilityName == "void_spirit_aether_remnant") then
        local vLocation = spellData.target
        if HeroAI:IsValidPosition(vLocation) then
            return HeroAI:CastSpellOnVector(hSpell, vLocation)
        end
    end
    
    if(table.contains(AdjustPointAbility, abilityName)) then
        local vLocation = spellData.target
        if HeroAI:IsValidPosition(vLocation) then
            local castVector = (vLocation - caster:GetAbsOrigin()):Normalized()
            local castLength = (vLocation - caster:GetAbsOrigin()):Length2D()
            
            spellData.target = caster:GetAbsOrigin() + castVector * castLength / 2
        end
    end
    
    if(abilityName == "invoker_invoke") then
        local selectedAb = InvokerAbilities[RandomInt(1, 10)]
        if(selectedAb ~= nil) then
            local ability = caster:FindAbilityByName(selectedAb.name)
            if(ability == nil or ability:IsCooldownReady() == false) then
                return 0.2
            end

            local playerId = caster:GetPlayerID()

            local ab1 = caster:FindAbilityByName(selectedAb.ab1);
            if(ab1 ~= nil and ab1:GetLevel() >= 1) then
                caster:CastAbilityNoTarget(ab1, playerId)
            end

            local ab2 = caster:FindAbilityByName(selectedAb.ab2);
            if(ab2 ~= nil and ab2:GetLevel() >= 1) then
                caster:CastAbilityNoTarget(ab2, playerId)
            end

            local ab3 = caster:FindAbilityByName(selectedAb.ab3);
            if(ab3 ~= nil and ab3:GetLevel() >= 1) then
                caster:CastAbilityNoTarget(ab3, playerId)
            end

            local instanceCount = 0
            for _, v in pairs(caster:FindAllModifiers()) do
                if(v:GetName() == "modifier_invoker_quas_instance" or v:GetName() == "modifier_invoker_exort_instance" or v:GetName() == "modifier_invoker_wex_instance") then
                    instanceCount = instanceCount + 1
                end
            end
            
            if(instanceCount >= 3) then
                return HeroAI:CastSpellNoTarget(hSpell)
            end
        end
        
        return 0.5
    end
    
    if(spellData.type == "toggle") then
        if hSpell:GetToggleState() == false then
            hSpell:ToggleAbility()
            if(caster.toggleOffList == nil) then
                caster.toggleOffList = {}
            end
            table.insert(caster.toggleOffList, hSpell)
        end
        return 0.2
    end
    
    if(spellData.type == "unit_target") then
        return HeroAI:CastSpellUnitTarget(hSpell, spellData.target)
    end
    
    if(spellData.type == "point_target") then
        return HeroAI:CastSpellPointTarget(hSpell, spellData.target)
    end
    
    if(spellData.type == "no_target") then
        return HeroAI:CastSpellNoTarget(hSpell)
    end
    
    if(spellData.type == "tree_target") then
        return HeroAI:CastSpellTreeTarget(hSpell, spellData.target)
    end
    
    return 0.2
end

function HeroAI:HasEnemyNearby(hero, range)
    if(range == nil) then
        range = 850
    end
    local units = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(),
    hero, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    return #units > 0
end

function HeroAI:HasEnemyNearPosition(hero, pos, range)
    if(range == nil) then
        range = 850
    end
    local units = FindUnitsInRadius(hero:GetTeamNumber(), pos,
    hero, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    return #units > 0
end

function HeroAI:HasInvisibleEnemyNearby(hero, range)
    if(range == nil) then
        range = 850
    end
    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(),
    hero, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, 0, true)

    local count = 0
    for index = 1, #enemies do
        if(enemies[index]:IsInvisible() == true) then
            count = count + 1
        end
    end

    return count > 0
end

function HeroAI:HasUnitNearby(hero, range)
    if(range == nil) then
        range = 250
    end
    
    local units = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(),
    hero, range, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, UNIT_FILTER, 0, true)
    
    return #units > 1
end

function HeroAI:GetNearestUnit(hero, range)
    local units = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), 
    hero, range, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, FIND_CLOSEST, true)
    
    if #units == 0 then
        return nil
    end

    local target = nil
    for _, v in pairs(units) do
        if v ~= hero then
            target = v
            break
        end
    end
    
    return target
end

function HeroAI:CheckSequentialAbility(hero, cmdData)
    if(cmdData.ability == nil) then return end
    local spellName = cmdData.ability:GetName()
    for _, v in pairs(SequentialAbility) do
        if(spellName == v.checkSpell) then
            local duration = v.duration
            if(spellName == "ancient_apparition_ice_blast") then
                duration = (cmdData.target - cmdData.ability:GetCaster():GetAbsOrigin()):Length2D() / 1500
            end
            if(spellName == "puck_illusory_orb") then
                duration = (cmdData.target - cmdData.ability:GetCaster():GetAbsOrigin()):Length2D() / 651
            end

            if(duration < 0.25) then
                duration = 0.25
            end

            if(spellName == "rubick_telekinesis") then
                local vTargetLoc = hero.targetPoint

                local enemy = HeroAI:GetFarestEnemyTarget(hero, 1500)
                if(enemy ~= nil) then
                    vTargetLoc = enemy:GetAbsOrigin()
                end
                cmdData.type = "point_target"
                cmdData.target = vTargetLoc
            end

            CreateTimer(function()
                if(hero == nil or hero:IsNull()) then return end
                local nextAbility = hero:FindAbilityByName(v.nextSpell)
                if(nextAbility ~= nil and nextAbility:IsHidden() == false and nextAbility:GetLevel() > 0 and nextAbility:IsCooldownReady() == true) then
                    if(v.nextSpell == "batrider_firefly" or v.nextSpell == "elder_titan_echo_stomp") then
                        if(nextAbility:IsActivated() == false) then
                            return
                        end
                    end

                    cmdData.ability = nextAbility
                    if(v.nextNoTarget) then
                        cmdData.type = "no_target"
                        cmdData.target = nil
                    end
                    HeroAI:CastSpell(cmdData)
                end
            end, duration)
            return
        end
    end
end

function HeroAI:GetSpellData(hSpell)
    if hSpell == nil or hSpell:IsNull() or hSpell:IsActivated() == false then
        return nil
    end
    
    local nBehavior = hSpell:GetBehavior()
    local nTargetTeam = hSpell:GetAbilityTargetTeam()
    local nTargetType = hSpell:GetAbilityTargetType()
    local nTargetFlags = hSpell:GetAbilityTargetFlags()
    local abilityName = hSpell:GetName()
    local hero = hSpell:GetCaster()

    if(hero == nil or hero:IsNull()) then
        return nil
    end

    local isRooted = false
    if(hero.IsRooted ~= nil and hero:IsRooted()) then
        isRooted = true
    end

    if(isRooted == false) then
        if(hero:HasModifier("modifier_teleporting_root_logic") or hero:HasModifier("modifier_slark_pounce_leash") or 
            hero:HasModifier("modifier_grimstroke_soul_chain") or hero:HasModifier("modifier_puck_coiled")) then
            isRooted = true
        end
    end

    if(isRooted) then
        if(table.contains(MOBILITY_ABILITIES, abilityName)) then
            return nil
        end

        if(bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES)) then
            return nil
        end
    end

    if(abilityName == "item_power_treads" or abilityName == "item_vambrace") then
        if(hSpell.currentState == nil) then
            hSpell.currentState = 0
        end

        if(hero.GetPrimaryAttribute ~= nil and hero.GetPlayerID ~= nil) then
            local targetState = hero:GetPrimaryAttribute()
            if(hero:GetHealthPercent() < 30) then
                targetState = 0
            end

            if(hSpell.currentState ~= targetState) then
                local playerId = hero:GetPlayerID()
                if(hSpell.currentState == 0) then
                    if(targetState == 1) then
                        hero:CastAbilityNoTarget(hSpell, playerId)
                        hero:CastAbilityNoTarget(hSpell, playerId)
                    elseif (targetState == 2) then
                        hero:CastAbilityNoTarget(hSpell, playerId)
                    end
                elseif(hSpell.currentState == 1) then
                    if(targetState == 0) then
                        hero:CastAbilityNoTarget(hSpell, playerId)
                    elseif (targetState == 2) then
                        hero:CastAbilityNoTarget(hSpell, playerId)
                        hero:CastAbilityNoTarget(hSpell, playerId)
                    end
                else
                    if(targetState == 0) then
                        hero:CastAbilityNoTarget(hSpell, playerId)
                        hero:CastAbilityNoTarget(hSpell, playerId)
                    elseif (targetState == 1) then
                        hero:CastAbilityNoTarget(hSpell, playerId)
                    end
                end

                hSpell.currentState = targetState
            end
        end

        return nil
    end

    if(abilityName == "item_invis_sword") then
        if(hero:HasModifier("modifier_item_invisibility_edge_windwalk") == false) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "item_silver_edge") then
        if(hero:HasModifier("modifier_item_silver_edge_windwalk") == false) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(hero:GetName() == "npc_dota_hero_rubick" and hSpell:IsItem() == false) then
        if(table.contains(KV_RUBICK_CASTS, abilityName) == false) then
            return nil
        end
    end

    if(abilityName == "item_black_king_bar" or abilityName == "item_minotaur_horn") then
        if(hero:IsMagicImmune()) then
            return nil
        end
    end

    if(abilityName == "item_force_staff") then
        local hTarget = HeroAI:GetRangedEnemyTarget(hSpell, false)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end

    if(abilityName == "item_solar_crest") then
        if(HeroAI:HasEnemyNearby(hero, 1000) == false) then
            return nil
        end

        local hTarget = HeroAI:GetMostDamageFriendlyTarget(hSpell, true)
        if hTarget ~= nil and hTarget:IsNull() == false and HeroAI:IsAlive(hTarget) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end
    end

    if(abilityName == "item_blade_mail") then
        if(hero:HasModifier("modifier_item_blade_mail_reflect")) then
            return nil
        end
    end

    if(abilityName == "item_satanic") then
        if(hero:HasModifier("modifier_item_satanic_unholy")) then
            return nil
        end

        if(hero:GetHealthPercent() <= 80 and hero:IsAttacking()) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
        return nil
    end

    if(abilityName == "item_lotus_orb") then
        if(hero:HasModifier("modifier_item_lotus_orb_active") == false) then
            return {ability = hSpell, type = "unit_target", target = hero}
        end
        return nil
    end

    if(abilityName == "item_ex_machina") then
        if(HeroAI:IsNeedRefreshItems(hero) or hero:GetHealthPercent() <= 50) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "item_magic_stick" or abilityName == "item_magic_wand" or abilityName == "item_holy_locket") then
        if(hSpell:GetCurrentCharges() > 0) then
            if(hero:GetHealthPercent() <= 80 or hero:GetManaPercent() <= 80) then
                return {ability = hSpell, type = "no_target", target = nil}
            end
        end

        return nil
    end

    if(abilityName == "item_manta") then
        if(hero:IsSilenced() or hero:IsDisarmed() or hero:IsRooted() or hero:GetHealthPercent() < 40) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        if(hero.IsRangedAttacker ~= nil and hero.GetPrimaryAttribute ~= nil) then
            if(hero:IsRangedAttacker() and hero:GetPrimaryAttribute() ~= 2) then
                if(HeroAI:HasEnemyNearby(hero, 1500)) then
                    return {ability = hSpell, type = "no_target", target = nil}
                end
            end
        end

        return nil
    end

    if(abilityName == "item_illusionsts_cape") then
        if(HeroAI:HasEnemyNearby(hero, 1500)) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "item_havoc_hammer") then
        if(HeroAI:HasEnemyNearby(hero, 300)) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "item_flicker") then
        if(hero:IsSilenced() or hero:IsDisarmed() or hero:GetHealthPercent() < 80) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
        return nil
    end

    if(abilityName == "item_cyclone") then
        return nil
    end

    if(abilityName == "item_enchanted_mango") then
        if(hero:GetManaPercent() <= 50) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "item_faerie_fire") then
        if(hero:GetHealthPercent() <= 50) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "item_glimmer_cape") then
        if(hero:GetHealthPercent() <= 60) then
            return {ability = hSpell, type = "unit_target", target = hero}
        end

        return nil
    end

    if(abilityName == "item_clarity") then
        if(hero:GetManaPercent() <= 50 and HeroAI:HasEnemyNearby(hero, 400) == false and hero:HasModifier("modifier_clarity_potion") == false) then
            return {ability = hSpell, type = "unit_target", target = hero}
        end

        return nil
    end

    if(abilityName == "item_flask") then
        if(hero:GetHealthPercent() <= 80 and HeroAI:HasEnemyNearby(hero, 400) == false and hero:HasModifier("modifier_flask_healing") == false) then
            return {ability = hSpell, type = "unit_target", target = hero}
        end
        
        return nil
    end

    if(abilityName == "item_soul_ring") then
        if(hero:GetHealth() > 500 and hero:GetManaPercent() < 25) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "item_arcane_boots") then
        if(hero:GetManaPercent() <= 60) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "item_refresher" or abilityName == "rattletrap_overclocking") then
        if(hero:HasAbility("arc_warden_tempest_double")) then
            return nil
        end

        for _,v in pairs(DoNotRefreshModifier) do
            if(hero:HasModifier(v)) then
                return nil
            end
        end

        local ultimateUsed = HeroAI:IsUltimateSkillUsed(hero)

        if(ultimateUsed) then
            if(table.contains(DoNotCheckRefresherHero, hero:GetName()) == false) then
                if(hero.check_refresher_time == nil) then
                    hero.check_refresher_time = GameRules:GetGameTime()
                    return nil
                elseif(GameRules:GetGameTime() - hero.check_refresher_time < 2.5) then
                    return nil
                end

                hero.check_refresher_time = nil
            end

            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "item_mekansm" or abilityName == "item_bloodstone") then
        if(hero:GetHealthPercent() <= 80) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "item_guardian_greaves") then
        if(hero:GetHealthPercent() <= 80 or hero:IsSilenced() or hero:IsDisarmed() or hero:IsRooted()) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "item_ward_sentry" or abilityName == "beastmaster_call_of_the_wild_hawk") then
        if(HeroAI:HasInvisibleEnemyNearby(hero, 1200)) then
            return {ability = hSpell, type = "point_target", target = hero:GetAbsOrigin()}
        end
        return nil
    end

    if(abilityName == "item_dust") then
        if(HeroAI:HasInvisibleEnemyNearby(hero, 1000)) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
        return nil
    end

    if(abilityName == "item_ghost") then
        if(hero:GetHealthPercent() <= 40 and hero:IsMagicImmune() == false) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
        return nil
    end

    if(abilityName == "item_diffusal_blade_2" or abilityName == "enchantress_enchant") then
        local hTarget = HeroAI:GetDispelTarget(hSpell)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        if(abilityName == "enchantress_enchant") then
            hTarget = HeroAI:GetBestDominateTarget(hSpell)
            if(hTarget ~= nil and hTarget:IsNull() == false) then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        end
        return nil
    end

    --[[if(abilityName == "item_tpscroll") then
        if(hero:HasModifier("modifier_batrider_flaming_lasso_self") or hero:HasModifier("modifier_nyx_assassin_burrow")) then
            return nil
        end

        if(hero:GetHealthPercent() < 50 or hero:GetManaPercent() < 20) then
            if(hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS) then
                return {ability = hSpell, type = "point_target", target = GameRules.DW.FountainGood}
            end
            
            if(hero:GetTeamNumber() == DOTA_TEAM_BADGUYS) then
                return {ability = hSpell, type = "point_target", target = GameRules.DW.FountainBad}
            end
        end

        if(hero.HasItemInInventory ~= nil and hero:HasItemInInventory("item_travel_boots_2")) then
            if(GameRules:GetGameTime() - GameRules.DW.StageStartTime < 10) then
                return nil
            end

            local target = HeroAI:GetFarestFriend(hero)
            if(target ~= nil and target:IsNull() ~= nil and HeroAI:IsAlive(target)) then
                local selfLocation = hero:GetAbsOrigin()
                local targetLocation = target:GetAbsOrigin()
                if(HeroAI:IsValidPosition(targetLocation) and HeroAI:IsValidPosition(selfLocation)) then
                    if((targetLocation.x < selfLocation.x or targetLocation.x > 0) and hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS) then
                        return nil
                    end
                    
                    if((targetLocation.x > selfLocation.x or targetLocation.x < 0) and hero:GetTeamNumber() == DOTA_TEAM_BADGUYS) then
                        return nil
                    end
                    
                    return {ability = hSpell, type = "unit_target", target = target}
                end
            end
        end

        return nil
    end]]

    --[[if(abilityName == "item_hurricane_pike") then
        local hTarget = HeroAI:GetBestHeroTargetInRange(hSpell)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            local fountainLoc = GameRules.DW.FountainGood
            if(hero:GetTeamNumber() == DOTA_TEAM_BADGUYS) then
                fountainLoc = GameRules.DW.FountainBad
            end

            local distanceFountainMe = (hero:GetAbsOrigin() - fountainLoc):Length2D()
            local distanceFountainEnemy = (hTarget:GetAbsOrigin() - fountainLoc):Length2D()

            if(distanceFountainMe < distanceFountainEnemy) then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        end

        return nil
    end]]

    if(abilityName == "item_mjollnir") then
        if(HeroAI:HasEnemyNearby(hero, 2000) == false) then
            return nil
        end

        local hTarget = HeroAI:GetMeleeFriendlyTarget(hSpell, true, 900)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end

    if(abilityName == "grimstroke_spirit_walk") then
        if(HeroAI:HasEnemyNearby(hero, 2000) == false) then
            return nil
        end

        local hTarget = HeroAI:GetMeleeFriendlyTarget(hSpell, false, 400)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end
    
    if(abilityName == "drow_ranger_wave_of_silence" or abilityName == "drow_ranger_multishot" or abilityName == "invoker_tornado" or abilityName == "invoker_chaos_meteor" or abilityName == "invoker_deafening_blast") then
        if(HeroAI:HasEnemyNearby(hero, 900) == false) then
            return nil
        end
    end

    if(abilityName == "chen_holy_persuasion" or abilityName == "item_helm_of_the_dominator") then
        local hTarget = HeroAI:GetBestDominateTarget(hSpell)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end
        return nil
    end

    if(abilityName == "warlock_upheaval") then
        local ultiAb = hero:FindAbilityByName("warlock_rain_of_chaos")
        if(ultiAb ~= nil and ultiAb:GetLevel() > 0 and ultiAb:IsHidden() == false and ultiAb:IsCooldownReady() == true and ultiAb:IsInAbilityPhase() == false) then
            return nil
        end
    end

    if(abilityName == "treant_overgrowth") then
        local eyesAb = hero:FindAbilityByName("treant_eyes_in_the_forest")
        if(eyesAb ~= nil and eyesAb:GetLevel() > 0 and eyesAb:IsHidden() == false and eyesAb:IsCooldownReady() == true and eyesAb:IsInAbilityPhase() == false) then
            return nil
        end
    end

    if(abilityName == "wisp_tether") then
        if(hero.tetherTarget == nil or HeroAI:IsAlive(hero.tetherTarget) == false) then
            local hTarget = HeroAI:GetBestFriendlyTargetNotSelf(hSpell, 1.0)
            if(hTarget ~= nil and hTarget:IsNull() == false) then
                hero.tetherTarget = hTarget
            end
        end

        if(hero.tetherTarget ~= nil and HeroAI:IsAlive(hero.tetherTarget)) then
            return {ability = hSpell, type = "unit_target", target = hero.tetherTarget}
        end

        return nil
    end

    if(abilityName == "wisp_overcharge") then
        if(hero:GetHealthPercent() < 50 or hero:HasModifier("modifier_wisp_tether")) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "centaur_return") then
        local modifier = hero:FindModifierByName("modifier_centaur_return_counter")
        if(modifier ~= nil) then
            local stackCount = modifier:GetStackCount()
            if(stackCount >= 5) then
                return {ability = hSpell, type = "no_target", target = nil}
            end
        end

        return nil
    end

    if(abilityName == "abaddon_borrowed_time") then
        if(hero:PassivesDisabled() == false) then
            return nil
        end

        if(hero:GetHealthPercent() < 40) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "keeper_of_the_light_chakra_magic") then
        local hTarget = HeroAI:GetLowManaFriendlyTarget(hSpell)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end
        return nil
    end

    if(abilityName == "weaver_shukuchi") then
        local heroPos = hero:GetAbsOrigin()
        if(heroPos.x > -4300 and heroPos.x < 4300) then
            if(hero:GetHealthPercent() < 50 or HeroAI:HasEnemyNearby(hero, 550)) then
                return {ability = hSpell, type = "no_target", target = nil}
            end
        end
        return nil
    end

    if(abilityName == "weaver_time_lapse") then
        if(hero:HasScepter()) then
            local hTarget = HeroAI:GetBestFriendlyTarget(hSpell, 0.5)
            if(hTarget ~= nil and hTarget:IsNull() == false) then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        else
            if(hero:GetHealthPercent() <= 50) then
                return {ability = hSpell, type = "no_target", target = nil}
            end
        end

        return nil
    end
    
    if(abilityName == "lone_druid_spirit_bear") then
        return nil
    end

    if(abilityName == "luna_eclipse") then
        if(hero:HasScepter()) then
            local hTarget = HeroAI:GetBestHeroTargetInRange(hSpell)
            if(hTarget ~= nil and hTarget:IsNull() == false) then
                return {ability = hSpell, type = "point_target", target = hTarget:GetAbsOrigin()}
            end
        end

        if(HeroAI:HasEnemyNearby(hero, 675)) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "brewmaster_drunken_brawler") then
        if(HeroAI:HasEnemyNearby(hero, 1000) or hero:GetHealthPercent() < 80) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "ursa_earthshock") then
        local checkPoint = hero:GetAbsOrigin()
        checkPoint = checkPoint + hero:GetForwardVector() * 250
        if(HeroAI:HasEnemyNearPosition(hero, checkPoint, 300)) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
        return nil
    end

    if(abilityName == "slark_pounce") then
        local checkPoint1 = hero:GetAbsOrigin()
        local checkPoint2 = checkPoint1 + hero:GetForwardVector() * 500

        local enemies = FindUnitsInLine(hero:GetTeamNumber(), checkPoint1, checkPoint2, nil, 95, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER)

        if(#enemies > 0) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "nevermore_shadowraze1") then
        local checkPoint = hero:GetAbsOrigin()
        checkPoint = checkPoint + hero:GetForwardVector() * 200
        if(HeroAI:HasEnemyNearPosition(hero, checkPoint, 250)) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
        return nil
    end

    if(abilityName == "nevermore_shadowraze2") then
        local checkPoint = hero:GetAbsOrigin()
        checkPoint = checkPoint + hero:GetForwardVector() * 450
        if(HeroAI:HasEnemyNearPosition(hero, checkPoint, 250)) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
        return nil
    end

    if(abilityName == "nevermore_shadowraze3") then
        local checkPoint = hero:GetAbsOrigin()
        checkPoint = checkPoint + hero:GetForwardVector() * 700
        if(HeroAI:HasEnemyNearPosition(hero, checkPoint, 250)) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
        return nil
    end
    
    if(abilityName == "pangolier_swashbuckle") then
        if(hero:HasModifier("modifier_pangolier_gyroshell")) then
            return nil
        end
    end
    
    if(abilityName == "naga_siren_song_of_the_siren") then
        if(hero:GetHealthPercent() < 80) then
            return {ability = hSpell, type = "no_target", target = nil}
        else
            return nil
        end
    end

    if(abilityName == "enchantress_natures_attendants") then
        if(HeroAI:HasEnemyNearby(hero, 1000) == true) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "arc_warden_magnetic_field") then
        if(hero:HasModifier("modifier_arc_warden_magnetic_field_evasion")) then
            return nil
        end

        if(HeroAI:HasEnemyNearby(hero, 950) == true) then
            return {ability = hSpell, type = "point_target", target = hero:GetAbsOrigin()}
        end
        
        return nil
    end
    
    if(abilityName == "juggernaut_healing_ward") then
        if(HeroAI:HasEnemyNearby(hero, 950) == true) then
            return {ability = hSpell, type = "point_target", target = hero:GetAbsOrigin()}
        end
        
        return nil
    end

    if(abilityName == "pugna_nether_ward") then
        if(HeroAI:HasEnemyNearby(hero, 1400) == true) then
            return {ability = hSpell, type = "point_target", target = hero:GetAbsOrigin()}
        end
        
        return nil
    end

    if(abilityName == "void_spirit_dissimilate") then
        if(HeroAI:HasEnemyNearby(hero, 500) == true) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
        
        return nil
    end

    if(abilityName == "ancient_apparition_ice_blast") then
        if(HeroAI:HasEnemyNearby(hero, 950) == false) then
            return nil
        end
    end
    
    if(abilityName == "riki_tricks_of_the_trade") then
        if(hero:HasScepter() == false) then
            nTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
            nBehavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET
        else
            nTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY
            nBehavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
        end
    end

    if(abilityName == "phoenix_supernova") then
        nBehavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET
        nTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
    end
    
    if(abilityName == "mirana_leap") then
        if(HeroAI:HasEnemyNearby(hero, 500) == false) then
            return nil
        end

        local vTargetLoc = hero.targetPoint

        local faceVector = (vTargetLoc - hero:GetAbsOrigin()):Normalized()
        
        hero:SetForwardVector(faceVector)
        
        return {ability = hSpell, type = "no_target", target = nil}
    end

    if(abilityName == "enchantress_bunny_hop") then
        if(HeroAI:HasEnemyNearby(hero, 600) == false) then
            return nil
        end

        local heroPos = hero:GetAbsOrigin()

        local vTargetLoc = hero.targetPoint

        local faceVector = (vTargetLoc - heroPos):Normalized()
        hero:SetForwardVector(-faceVector)

        return {ability = hSpell, type = "no_target", target = nil}
    end
    
    if(abilityName == "bloodseeker_bloodrage") then
        if(HeroAI:HasEnemyNearby(hero) == false) then
            return nil
        end
        
        return {ability = hSpell, type = "unit_target", target = hero}
    end

    if(abilityName == "magnataur_empower" or abilityName == "ogre_magi_bloodlust" or abilityName == "treant_living_armor") then
        local hTarget = HeroAI:GetNearestFriendWithoutBuff(hSpell)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end

    if(abilityName == "razor_eye_of_the_storm" or abilityName == "alchemist_chemical_rage" or abilityName == "death_prophet_exorcism") then
        if(HeroAI:HasEnemyNearby(hero, 1500) == false) then
            return nil
        end

        return {ability = hSpell, type = "no_target", target = nil}
    end

    if(abilityName == "death_prophet_spirit_siphon") then
        if(hero:HasModifier("modifier_death_prophet_spirit_siphon")) then
            return nil
        end

        local targetUnit = HeroAI:GetHighesetMaxHealthEnemyHeroTargetInRange(hSpell)
        if(targetUnit ~= nil) then
            return {ability = hSpell, type = "unit_target", target = targetUnit}
        end

        return nil
    end

    if(abilityName == "lich_frost_shield") then
        if(HeroAI:HasEnemyNearby(hero, 1500) == false) then
            return nil
        end

        local hTarget = HeroAI:GetNearestFriendWithoutBuff(hSpell)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end
    
    if(abilityName == "nyx_assassin_burrow") then
        if(HeroAI:HasEnemyNearby(hero, 800) == false) then
            return nil
        end
        
        return {ability = hSpell, type = "no_target", target = nil}
    end
    
    if(abilityName == "nyx_assassin_unburrow") then
        if(hero:HasModifier("modifier_nyx_assassin_burrow") == false) then
            return nil
        end
        
        if(HeroAI:HasEnemyNearby(hero, 800) == true) then
            return nil
        end
        
        return {ability = hSpell, type = "no_target", target = nil}
    end

    if(abilityName == "nyx_assassin_spiked_carapace") then
        if(hero:HasModifier("modifier_nyx_assassin_burrow")) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
    end

    if(abilityName == "lycan_wolf_bite") then
        local hTarget = HeroAI:GetNearestFriendWithoutBuff(hSpell)
        if hTarget ~= nil and hTarget:IsNull() == false and HeroAI:IsAlive(hTarget) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end
        return nil
    end

    if(abilityName == "morphling_replicate") then
        if(hero:HasScepter()) then
            if(hero.replicateHost == nil) then
                hero.replicateHost = HeroAI:GetBestFriendlyTargetNotSelf(hSpell, 1.0)
            end

            if(HeroAI:HasEnemyNearby(hero, 2000) == false) then
                return nil
            end

            if(hero.replicateHost ~= nil and HeroAI:IsAlive(hero.replicateHost)) then
                if(HeroAI:IsValidHeroTargetToCast(hero.replicateHost) == false) then
                    return nil
                end
                return {ability = hSpell, type = "unit_target", target = hero.replicateHost}
            end

            local hTarget = HeroAI:GetBestFriendlyTargetNotSelf(hSpell, 1.0)
            if hTarget ~= nil and hTarget ~= hero and hTarget:IsNull() == false and HeroAI:IsAlive(hTarget) then
                if(hTarget:GetName() ~= "npc_dota_hero_invoker") then
                    hero.replicateHost = hTarget
                    return {ability = hSpell, type = "unit_target", target = hTarget}
                end
            end
        end

        return nil
    end

    if(abilityName == "morphling_morph_replicate") then
        -- if(hero:GetHealthPercent() < 50 and hero:HasAbility("morphling_morph") == false) then
        --     return {ability = hSpell, type = "no_target", target = nil}
        -- end
        -- if(hero:GetHealthPercent() > 50 and hero:HasAbility("morphling_morph")) then
        --     return {ability = hSpell, type = "no_target", target = nil}
        -- end
        return nil
    end

    if(abilityName == "spectre_reality") then
        local hTarget = HeroAI:GetSpectreRealityTarget(hSpell)
        if hTarget ~= nil and hTarget:IsNull() == false and HeroAI:IsAlive(hTarget) then
            return {ability = hSpell, type = "point_target", target = hTarget:GetAbsOrigin()}
        end
        return nil
    end

    if(abilityName == "snapfire_gobble_up") then
        if(HeroAI:HasEnemyNearby(hero, 3500)) then
            local hTarget = HeroAI:GetBestFriendlyTargetNotSelf(hSpell, 1.0)
            if(hTarget ~= nil and hTarget:IsNull() == false) then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end    
        end

        return nil
    end

    if(abilityName == "snapfire_mortimer_kisses") then
        if(hero:HasModifier("modifier_snapfire_gobble_up_belly_has_unit")) then
            return nil
        end

        local spitAb = hero:FindAbilityByName("snapfire_spit_creep")
        if(spitAb ~= nil and spitAb:IsActivated() == true and spitAb:GetLevel() > 0 and spitAb:IsHidden() == false) then
            if(spitAb:IsCooldownReady() == true) then
                return nil
            end
        end

        local gobbleUpAb = hero:FindAbilityByName("snapfire_gobble_up")
        if(gobbleUpAb ~= nil and gobbleUpAb:IsActivated() == true and gobbleUpAb:GetLevel() > 0 and gobbleUpAb:IsHidden() == false) then
            if(gobbleUpAb:IsCooldownReady() == true) then
                local hTarget = HeroAI:GetBestFriendlyTargetNotSelf(gobbleUpAb, 1.0)
                if(hTarget ~= nil and hTarget:IsNull() == false) then
                    return nil
                end
            end
        end
    end

    if(table.contains(CastToNearestPointAbility, abilityName)) then
        if(abilityName == "techies_stasis_trap" or abilityName == "techies_land_mines" or abilityName == "techies_remote_mines") then
            local moveMineAbility = hero:FindAbilityByName("special_bonus_unique_techies_4")
            if(moveMineAbility ~= nil and moveMineAbility:GetLevel() > 0) then
                return {ability = hSpell, type = "point_target", target = hero:GetAbsOrigin()}
            end
        end
        
        local hTarget = HeroAI:GetClosestEnemyHero(hero, HeroAI:GetSpellRange(hSpell))
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "point_target", target = hTarget:GetAbsOrigin()}
        end

        if(abilityName == "zuus_lightning_bolt") then
            if(HeroAI:HasInvisibleEnemyNearby(hero, 750)) then
                return {ability = hSpell, type = "point_target", target = hero:GetAbsOrigin()}
            end
        end
        
        return nil
    end

    if(table.contains(CastToLinearAbility, abilityName)) then
        local width = 300
        if(hSpell:GetAbilityType() == ABILITY_TYPE_ULTIMATE) then
            width = 500
        end

        if(abilityName == "monkey_king_boundless_strike" or abilityName == "jakiro_ice_path" or abilityName == "earth_spirit_rolling_boulder") then
            width = 150
        end

        if(abilityName == "earthshaker_fissure") then
            width = 225
        end

        if(abilityName == "windrunner_powershot") then
            width = 125
        end

        if(abilityName == "queenofpain_sonic_wave") then
            width = 450
        end

        if(abilityName == "phoenix_sun_ray") then
            width = 130
        end

        if(abilityName == "phoenix_icarus_dive") then
            width = 500
        end

        if(abilityName == "tinker_march_of_the_machines") then
            width = 450
        end

        if(abilityName == "venomancer_venomous_gale") then
            width = 125
        end

        local hTargetPos = HeroAI:GetBestLinearTarget(hSpell, width)
        if(hTargetPos ~= nil) then
            return {ability = hSpell, type = "point_target", target = hTargetPos}
        end
        
        return nil
    end

    if(abilityName == "void_spirit_aether_remnant") then
        if(HeroAI:HasInvisibleEnemyNearby(hero, 600)) then
            if(CheckHasTalent(hero, "special_bonus_unique_void_spirit_7")) then
                return {ability = hSpell, type = "point_target", target = hero:GetAbsOrigin()}
            end
        end

        local checkPoint = hero:GetAbsOrigin()
        checkPoint = checkPoint + hero:GetForwardVector() * 100
        if(HeroAI:HasEnemyNearPosition(hero, checkPoint, 300)) then
            return {ability = hSpell, type = "point_target", target = checkPoint}
        end

        return nil
    end

    if(abilityName == "morphling_waveform") then
        if(hero:HasModifier("modifier_morphling_waveform")) then
            return nil
        end
    end

    if(abilityName == "shredder_timber_chain" or abilityName == "morphling_waveform" or abilityName == "shredder_chakram" or abilityName == "shredder_chakram_2" or abilityName == "tusk_frozen_sigil"
        or abilityName == "sandking_burrowstrike" or abilityName == "void_spirit_astral_step" or abilityName == "beastmaster_wild_axes" or abilityName == "templar_assassin_psionic_trap" or abilityName == "earth_spirit_stone_caller") then
        if(abilityName == "templar_assassin_psionic_trap" and hero:HasModifier("modifier_templar_assassin_meld")) then
            return nil
        end

        local hTarget = HeroAI:GetFarestEnemyTarget(hero, (HeroAI:GetSpellRange(hSpell)) * 0.8)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            local castLength = (hTarget:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
            local castVector = (hTarget:GetAbsOrigin() - hero:GetAbsOrigin()):Normalized()
            local castLocation = hero:GetAbsOrigin() + castVector * castLength * 1.25

            if(HeroAI:IsValidPosition(castLocation)) then
                return {ability = hSpell, type = "point_target", target = castLocation}
            end
        end

        return nil
    end

    if(abilityName == "templar_assassin_trap_teleport") then

        local hTarget = HeroAI:GetSpecialChildrenTarget(hero, HeroAI:GetSpellRange(hSpell), "npc_dota_templar_assassin_psionic_trap")
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "point_target", target = hTarget:GetAbsOrigin()}
        end

        return nil
    end

    if(abilityName == "elder_titan_ancestral_spirit" or abilityName == "phantom_lancer_doppelwalk") then
        local hTarget = HeroAI:GetFarestEnemyTarget(hero, HeroAI:GetSpellRange(hSpell))
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "point_target", target = hTarget:GetAbsOrigin()}
        end

        return nil
    end

    if(abilityName == "spectre_haunt_single") then
        local hTarget = HeroAI:GetFarestEnemyTarget(hero, HeroAI:GetSpellRange(hSpell))
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end

    if(abilityName == "templar_assassin_meld") then
        if(hero:IsAttacking()) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end
    
    if(abilityName == "troll_warlord_battle_trance") then
        if(HeroAI:HasEnemyNearby(hero) == false) then
            return nil
        end

        if(hero:HasScepter()) then
            local hTarget = HeroAI:GetNearestFriendWithoutBuff(hSpell)
            if hTarget ~= nil and hTarget:IsNull() == false and HeroAI:IsAlive(hTarget) and hTarget:GetHealthPercent() < 30 then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            else
                if(HeroAI:CheckTargetNoModifier(hSpell, hero) == true) then
                    HeroAI:CheckAndUseSatanic(hero)
                    return {ability = hSpell, type = "unit_target", target = hero}
                end 
            end
        else
            if(HeroAI:CheckTargetNoModifier(hSpell, hero) == true) then
                HeroAI:CheckAndUseSatanic(hero)
                return {ability = hSpell, type = "no_target", target = nil}
            end
        end

        return nil
    end

    if(abilityName == "winter_wyvern_winters_curse" or abilityName == "lich_sinister_gaze" or abilityName == "chaos_knight_reality_rift" or abilityName == "sniper_assassinate" or abilityName == "oracle_fates_edict") then
        local enemy = HeroAI:GetBestHeroTargetInRange(hSpell, true)
        if(enemy ~= nil and HeroAI:IsAlive(enemy)) then
            return {ability = hSpell, type = "unit_target", target = enemy}
        end
        return nil
    end

    if(table.contains(CheckModifierNoTargetAbility, abilityName)) then
        if(HeroAI:HasEnemyNearby(hero) == false) then
            return nil
        end

        if(HeroAI:CheckTargetNoModifier(hSpell, hero) == true) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end
    
    if(abilityName == "invoker_alacrity") then
        return {ability = hSpell, type = "unit_target", target = hero}
    end
    
    if(abilityName == "terrorblade_sunder") then
        if(hero:GetHealthPercent() < 40) then
            local targetUnit = HeroAI:GetStrongestEnemyHeroTargetInRange(hSpell, 30)
            if(targetUnit ~= nil) then
                return {ability = hSpell, type = "unit_target", target = targetUnit}
            end
        end

        return nil
    end

    if(abilityName == "terrorblade_terror_wave") then
        if(HeroAI:HasEnemyNearby(hero, 1200)) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
        
        return nil
    end

    if(abilityName == "obsidian_destroyer_astral_imprisonment" or abilityName == "shadow_demon_disruption") then
        local targetUnit = HeroAI:GetStrongestEnemyHeroTargetInRange(hSpell, 40)
        if(targetUnit ~= nil) then
            return {ability = hSpell, type = "unit_target", target = targetUnit}
        end

        return nil
    end
    
    if(abilityName == "puck_phase_shift" or abilityName == "monkey_king_tree_dance") then
        if(hero:GetHealthPercent() > 60) then
            return nil
        end
    end

    if(abilityName == "necrolyte_sadist") then
        if(hero:HasScepter()) then
            if(HeroAI:HasEnemyNearby(hero, 800)) then
                return {ability = hSpell, type = "no_target", target = nil}
            end    
        end

        if(hero:GetHealthPercent() <= 75) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "monkey_king_mischief") then
        if(hero:GetHealthPercent() <= 50) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end
    
    if(abilityName == "storm_spirit_ball_lightning") then
        if(hero:HasModifier("modifier_storm_spirit_ball_lightning")) then
            return nil
        end

        local hTarget = HeroAI:GetFarestEnemyTarget(hero, 1800)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            local castLength = (hTarget:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
            local castVector = (hTarget:GetAbsOrigin() - hero:GetAbsOrigin()):Normalized()
            local castLocation = hero:GetAbsOrigin() + castVector * (castLength + 200)

            local maxMana = hero:GetMaxMana()
            local manaCostEstimate = maxMana * 0.08 + 180 + (castLength + 200) / 100 * (10 + 0.005 * maxMana)
            local manaEscape = maxMana * 0.08 + 180 + 10 * (10 + 0.005 * maxMana)

            if(HeroAI:IsValidPosition(castLocation)) then
                return {ability = hSpell, type = "point_target", target = castLocation}
            end
        end

        return nil
    end

    if(abilityName == "spirit_breaker_charge_of_darkness") then
        local enemy = HeroAI:GetBestHeroTargetInRange(hSpell)
        if(enemy ~= nil) then
            local vTargetLoc = enemy:GetAbsOrigin()
            if HeroAI:IsValidPosition(vTargetLoc) then
                return {ability = hSpell, type = "unit_target", target = enemy}
            else
                return nil
            end
        end
        return nil
    end

    if(abilityName == "spirit_breaker_nether_strike") then
        if(hero:HasModifier("modifier_spirit_breaker_charge_of_darkness")) then
            return nil
        end
    end

    if(abilityName == "antimage_mana_void") then
        local enemy = HeroAI:GetNoManaHeroTargetInRange(hSpell)
        if(enemy ~= nil) then
            return {ability = hSpell, type = "unit_target", target = enemy}
        end
        return nil
    end
    
    if(abilityName == "axe_culling_blade") then
        local maxHp = 400
        local abLevel = hSpell:GetLevel()
        if(abLevel >= 2)  then
            maxHp = 700
        end
        if(abLevel >= 3)  then
            maxHp = 1000
        end

        local enemy = HeroAI:GetWeakestHeroTargetInRange(hSpell, maxHp, false)
        if(enemy ~= nil) then
            return {ability = hSpell, type = "unit_target", target = enemy}
        end
        return nil
    end

    if(abilityName == "lion_mana_drain") then
        if(hero:GetManaPercent() >= 50) then
            return nil
        end
    end

    if(abilityName == "lion_finger_of_death" and hero:GetHealthPercent() > 50) then
        local damage = hSpell:GetAbilityDamage()
        local modi = hero:FindModifierByName("modifier_lion_finger_of_death_kill_counter")
        if(modi ~= nil) then
            damage = damage + modi:GetStackCount() * 40
        end

        local enemy = HeroAI:GetWeakestHeroTargetInRange(hSpell, damage, true)
        if(enemy ~= nil) then
            return {ability = hSpell, type = "unit_target", target = enemy}
        end

        return nil
    end

    if(abilityName == "broodmother_spawn_spiderlings" and hero:GetHealthPercent() > 45) then
        local level = hSpell:GetLevel()
        local damage = level * 200
        if(CheckHasTalent(hero, "special_bonus_unique_broodmother_3")) then
            damage = damage + 125
        end

        local enemy = HeroAI:GetWeakestHeroTargetInRange(hSpell, damage, true)
        if(enemy ~= nil) then
            return {ability = hSpell, type = "unit_target", target = enemy}
        end

        return nil
    end

    if(abilityName == "broodmother_spin_web") then
        if(hero:HasModifier("modifier_broodmother_spin_web_invisible_applier")) then
            return nil
        end

        local target = HeroAI:GetClosestEnemyHero(hero, 1600)
        if(target ~= nil) then
            local heroPosition = hero:GetAbsOrigin()
            local targetPosition = target:GetAbsOrigin()
            local castLength = (targetPosition - heroPosition):Length2D() * 0.5
            local castVector = (targetPosition - heroPosition):Normalized()
            local castPos = heroPosition + castVector * castLength

            if HeroAI:IsValidPosition(castPos) then
                return {ability = hSpell, type = "point_target", target = castPos}
            end
        end
        return nil
    end

    if(abilityName == "broodmother_insatiable_hunger") then
        if(HeroAI:HasEnemyNearby(hero, 1000)) then
            return {ability = hSpell, type = "no_target", target = nil}
        end
        return nil
    end

    if(abilityName == "witch_doctor_death_ward" or abilityName == "shadow_shaman_mass_serpent_ward" or abilityName == "venomancer_plague_ward") then
        local castRange = HeroAI:GetSpellRange(hSpell)
        local target = HeroAI:GetClosestEnemyHero(hero, castRange + 700)
        if(target ~= nil) then
            local heroPosition = hero:GetAbsOrigin()
            local targetPosition = target:GetAbsOrigin()
            local castVector = (targetPosition - heroPosition):Normalized()
            local castPos = heroPosition + castVector * castRange

            if HeroAI:IsValidPosition(castPos) then
                return {ability = hSpell, type = "point_target", target = castPos}
            end
        end
        return nil
    end

    if(abilityName == "necrolyte_reapers_scythe") then
        local enemy = HeroAI:GetLostMostHealthHeroTargetInRange(hSpell, 500)
        if(enemy ~= nil) then
            return {ability = hSpell, type = "unit_target", target = enemy}
        end
        return nil
    end
    
    if(abilityName == "ember_spirit_fire_remnant") then
        if(hero.last_fire_remnant_time ~= nil and GameRules:GetGameTime() - hero.last_fire_remnant_time < 1.5) then
            return nil
        end

        local enemy = HeroAI:GetFarestEnemyTarget(hero, 1500)
        if(enemy ~= nil) then
            local vTargetLoc = enemy:GetAbsOrigin()
            if HeroAI:IsValidPosition(vTargetLoc) then
                hero.last_fire_remnant_time = GameRules:GetGameTime()
                return {ability = hSpell, type = "point_target", target = vTargetLoc}
            else
                return nil
            end
        end
        return nil
    end

    if(abilityName == "queenofpain_blink") then
        local isUltiCd = false
        local ultAb = hero:FindAbilityByName("queenofpain_sonic_wave")
        if(ultAb ~= nil and ultAb:GetLevel() > 0 and (ultAb:IsCooldownReady() == false or ultAb:IsFullyCastable() == false)) then
            isUltiCd = true
        end

        if(HeroAI:HasEnemyNearby(hero, 500) and isUltiCd) then
            
        else
            local vLocation = HeroAI:GetBestAOEPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY)
            if HeroAI:IsValidPosition(vLocation) then
                local castVector = (vLocation - hero:GetAbsOrigin()):Normalized()
                local castLength = (vLocation - hero:GetAbsOrigin()):Length2D()
                local castPos = hero:GetAbsOrigin() + castVector * castLength * 0.6
                HeroAI:CheckAndUseBKB(hero)
                return {ability = hSpell, type = "point_target", target = castPos}
            end
        end

        return nil
    end
    
    if(abilityName == "item_blink") then
        if(hero:HasModifier("modifier_batrider_flaming_lasso_self") or hero:HasModifier("modifier_nyx_assassin_burrow")) then
            return nil
        end

        if(hero:IsRangedAttacker() == false) then
            local attackTarget = hero:GetAttackTarget()
            if(attackTarget ~= nil and attackTarget:IsNull() == false) then
                if(attackTarget.GetHealthPercent ~= nil and attackTarget:GetHealthPercent() < 50) then
                    return nil
                end
            end
        end

        local hTarget = HeroAI:GetFarestEnemyTarget(hero, 1200)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            local castVector = (hTarget:GetAbsOrigin() - hero:GetAbsOrigin()):Normalized()
            local castLength = (hTarget:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
            if(castLength > 300) then
                local castPos = hero:GetAbsOrigin() + castVector * (castLength - 100)
                return {ability = hSpell, type = "point_target", target = castPos}
            end
        end
        return nil
    end

    if(abilityName == "item_horizon") then
        if(hero:HasModifier("modifier_batrider_flaming_lasso_self") or hero:HasModifier("modifier_nyx_assassin_burrow")) then
            return nil
        end

        local hTarget = HeroAI:GetFarestEnemyTarget(hero, 1600)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end
        return nil
    end

    if(abilityName == "item_fallen_sky") then
        if(hero:HasModifier("modifier_batrider_flaming_lasso_self") or hero:HasModifier("modifier_nyx_assassin_burrow")) then
            return nil
        end
    end
    
    if(abilityName == "antimage_blink") then
        local hTarget = HeroAI:GetFarestEnemyTarget(hero, HeroAI:GetSpellRange(hSpell))
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            local jumpLength = (hTarget:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
            if(jumpLength > 300) then
                return {ability = hSpell, type = "point_target", target = hTarget:GetAbsOrigin()}
            else
                return nil
            end
        end

        return nil
    end
    
    if(abilityName == "shadow_demon_shadow_poison_release" or abilityName == "lycan_shapeshift") then
        if(HeroAI:HasEnemyNearby(hero, 1200) == false) then
            return nil
        end
        
        return {ability = hSpell, type = "no_target", target = nil}
    end

    if(abilityName == "lycan_summon_wolves") then
        if(HeroAI:HasEnemyNearby(hero, 2000) == false) then
            return nil
        end
        
        return {ability = hSpell, type = "no_target", target = nil}
    end
    
    if(abilityName == "earth_spirit_geomagnetic_grip" or abilityName == "earth_spirit_boulder_smash") then
        local hTarget = HeroAI:GetSpecialChildrenTarget(hero, HeroAI:GetSpellRange(hSpell), "npc_dota_earth_spirit_stone")
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "point_target", target = hTarget:GetAbsOrigin()}
        end
        return nil
    end
    
    if(abilityName == "vengefulspirit_nether_swap") then
        local hTarget = HeroAI:GetNetherSwapTarget(hSpell)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end
        return nil
    end

    if(abilityName == "undying_soul_rip") then
        if(hero:GetHealthPercent() < 80) then
            return {ability = hSpell, type = "unit_target", target = hero}
        end

        return nil
    end

    if(abilityName == "legion_commander_press_the_attack") then
        if(hero:GetHealthPercent() < 80 and hero:IsMagicImmune() == false) then
            return {ability = hSpell, type = "unit_target", target = hero}
        end

        return nil
    end
    
    if(abilityName == "oracle_false_promise" or abilityName == "winter_wyvern_cold_embrace" or abilityName == "dazzle_shallow_grave") then
        local hTarget = HeroAI:GetBestFriendlyTarget(hSpell, 0.6)
        if(hTarget ~= nil and hTarget:IsNull() == false and HeroAI:CheckTargetNoModifier(hSpell, hTarget) == true) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end

    if(abilityName == "warlock_shadow_word") then
        local hTarget = HeroAI:GetBestFriendlyTarget(hSpell, 0.8)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end

    if(abilityName == "chen_divine_favor") then
        local hTarget = HeroAI:GetBestFriendlyTarget(hSpell, 0.4)
        if(hTarget ~= nil and hTarget:IsNull() == false and hTarget ~= hero) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end

    if(abilityName == "snapfire_firesnap_cookie") then
        local hTarget = HeroAI:GetBestFriendlyTargetNotSelf(hSpell, 0.95)
        if(hTarget ~= nil and hTarget:IsNull() == false and hTarget ~= hero) then
            if(hTarget:IsRangedAttacker() == false) then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        end

        return nil
    end

    if(abilityName == "omniknight_purification") then
        local hTarget = HeroAI:GetBestFriendlyTarget(hSpell, 0.95)
        if(hTarget ~= nil and hTarget:IsNull() == false and HeroAI:CheckTargetNoModifier(hSpell, hTarget) == true) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end
    
    if(abilityName == "tiny_toss") then
        local nearestUnit = HeroAI:GetNearestUnit(hero, 375)
        if(nearestUnit ~= nil and nearestUnit:IsNull() == false and nearestUnit.GetTeamNumber ~= nil and nearestUnit:GetTeamNumber() ~= hero:GetTeamNumber()) then
            if(nearestUnit.IsMagicImmune ~= nil and nearestUnit:IsMagicImmune() == false and nearestUnit:HasModifier("modifier_tiny_toss") == false) then
                return {ability = hSpell, type = "point_target", target = nearestUnit:GetAbsOrigin()}
            end
        end

        return nil
    end
    
    if(abilityName == "invoker_invoke") then
        local ability4 = hero:GetAbilityByIndex(3)
        if(ability4 ~= nil and string.find(ability4:GetName(), "invoker_empty") == nil and ability4:IsCooldownReady() == true) then
            return nil
        end
        
        local ability5 = hero:GetAbilityByIndex(4)
        if(ability5 ~= nil and string.find(ability5:GetName(), "invoker_empty") == nil and ability5:IsCooldownReady() == true) then
            return nil
        end
        
        if(hero:GetLevel() < 5 and ability4 ~= nil and ability4:IsCooldownReady() == false) then
            return nil
        end
        
        return {ability = hSpell, type = "no_target", target = nil}
    end

    if(abilityName == "rubick_spell_steal") then
        local ability3 = hero:GetAbilityByIndex(3)
        local needSteal = true
        local currentAbilityName = nil

        if(ability3 ~= nil and string.find(ability3:GetName(), "rubick_empty") == nil) then
            currentAbilityName = ability3:GetName()
            if(ability3:IsCooldownReady() == true and ability3:IsActivated() == true) then
                if(table.contains(KV_RUBICK_CASTS, ability3:GetName()) == false) then
                    needSteal = true
                elseif(hero.lastSteal ~= nil and GameRules:GetGameTime() - hero.lastSteal < 4) then
                    needSteal = false
                end
            end
        end

        if(needSteal) then
            local enemy = HeroAI:GetRubickStealTarget(hSpell, currentAbilityName)
            if(enemy ~= nil and enemy:IsNull() == false) then
                hero.lastSteal = GameRules:GetGameTime()
                return {ability = hSpell, type = "unit_target", target = enemy}
            end
        end

        return nil
    end
    
    if(abilityName == "furion_force_of_nature") then
        local treeTarget = HeroAI:FindTreeTarget(hSpell)
        if (treeTarget ~= nil) then
            local targetPos = treeTarget:GetAbsOrigin()
            if(targetPos ~= nil and targetPos ~= vec3_invalid and targetPos.y > 1600) then
                return {ability = hSpell, type = "tree_target", target = treeTarget}
            end
        end
        
        return nil
    end

    if(abilityName == "treant_eyes_in_the_forest") then
        if(HeroAI:HasEnemyNearby(hero, 1600) == false) then
            return nil
        end

        local treeTarget = HeroAI:FindTreantTreeTarget(hSpell)
        if (treeTarget ~= nil) then
            local targetPos = treeTarget:GetAbsOrigin()
            if(targetPos ~= nil and targetPos ~= vec3_invalid and targetPos.y > 1600) then
                return {ability = hSpell, type = "tree_target", target = treeTarget}
            end
        end
        
        return nil
    end
    
    if(abilityName == "tinker_rearm") then
        if(hero:HasModifier("modifier_fountain_aura_buff")) then
            local tpItem = hero:GetItemInSlot(15)
            if(tpItem ~= nil) then
                if(tpItem:IsCooldownReady() == false and tpItem:IsInAbilityPhase() == false) then
                    return {ability = hSpell, type = "no_target", target = nil}
                end
            end
        end

        local abCount = 0

        local ab1 = hero:FindAbilityByName("tinker_laser")
        if(ab1 ~= nil and ab1:GetLevel() > 0 and ab1:IsActivated() == true) then
            if(ab1:IsCooldownReady() == true and ab1:IsInAbilityPhase() == false) then
                return nil
            end
            abCount = abCount + 1
        end

        local ab2 = hero:FindAbilityByName("tinker_heat_seeking_missile")
        if(ab2 ~= nil and ab2:GetLevel() > 0 and ab2:IsActivated() == true) then
            if(ab2:IsCooldownReady() == true and ab2:IsInAbilityPhase() == false) then
                return nil
            end
            abCount = abCount + 1
        end

        local ab3 = hero:FindAbilityByName("tinker_march_of_the_machines")
        if(ab3 ~= nil and ab3:GetLevel() > 0 and ab3:IsActivated() == true) then
            if(ab3:IsCooldownReady() == true and ab3:IsInAbilityPhase() == false) then
                return nil
            end
            abCount = abCount + 1
        end

        if(abCount > 0) then
            return {ability = hSpell, type = "no_target", target = nil}
        end

        return nil
    end

    if(abilityName == "dark_willow_shadow_realm") then
        if(hero:HasScepter() == false and hero:GetHealthPercent() > 50) then
            return nil
        end
    end
    
    if(abilityName == "pudge_meat_hook" or abilityName == "rattletrap_hookshot") then
        local hTarget = HeroAI:GetBestHeroTargetInRange(hSpell)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            local friends = FindUnitsInLine(hero:GetTeamNumber(), hero:GetAbsOrigin(), hTarget:GetAbsOrigin(), nil, 150, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, UNIT_FILTER)
            
            if(#friends > 1) then
                return nil
            else
                return {ability = hSpell, type = "point_target", target = hTarget:GetAbsOrigin()}
            end
        end
        
        return nil
    end

    if(abilityName == "pudge_dismember" and hero:HasScepter()) then
        local hTarget = HeroAI:GetBestFriendlyTargetNotSelf(hSpell, 0.4)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end
    end

    if(abilityName == "juggernaut_omni_slash") then
        if(hero:HasAbility("juggernaut_swift_slash")) then
            local swiftSlash = hero:FindAbilityByName("juggernaut_swift_slash")
            if(swiftSlash ~= nil and swiftSlash:GetLevel() > 0 and swiftSlash:IsActivated()) then
                if(swiftSlash:IsCooldownReady() == true) then
                    return nil
                end
            end
        end
    end

    if(abilityName == "juggernaut_omni_slash" or abilityName == "juggernaut_swift_slash") then
        if(hero:HasModifier("modifier_juggernaut_omnislash_invulnerability")) then
            return nil
        end

        local hTarget = HeroAI:GetBestHeroTargetInRange(hSpell)
        if hTarget ~= nil and hTarget:IsNull() == false and HeroAI:IsAlive(hTarget) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end

    if(abilityName == "gyrocopter_flak_cannon") then
        if(hero:HasModifier("modifier_gyrocopter_flak_cannon")) then
            return nil
        end
    end

    if(abilityName == "lich_chain_frost") then
        local hTarget = HeroAI:GetBestHeroTargetInRange(hSpell)
        if hTarget ~= nil and hTarget:IsNull() == false and HeroAI:IsAlive(hTarget) and hTarget:HasModifier("modifier_item_lotus_orb_active") == false then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end

    if(abilityName == "life_stealer_infest") then
        local hTarget = nil
        if(hero:HasScepter()) then
            if(hero.infestHost == nil) then
                hero.infestHost = HeroAI:GetBestFriendlyTargetNotSelf(hSpell, 1.0)
            end

            if(HeroAI:HasEnemyNearby(hero, 1000) == false) then
                return nil
            end

            if(hero.infestHost ~= nil and HeroAI:IsAlive(hero.infestHost)) then
                if(HeroAI:IsValidHeroTargetToCast(hero.infestHost) == false) then
                    return nil
                end
                return {ability = hSpell, type = "unit_target", target = hero.infestHost}
            end

            hTarget = HeroAI:GetMostDamageFriendlyTarget(hSpell, true)
        else
            if(hero:GetHealthPercent() > 50) then
                return nil
            end
            hTarget = HeroAI:GetStrongestFriendlyTarget(hSpell)
        end
        
        if hTarget ~= nil and hTarget ~= hero and hTarget:IsNull() == false and HeroAI:IsAlive(hTarget) then
            hero.infestHost = hTarget
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end

    if(abilityName == "dark_seer_ion_shell") then
        local hTarget = HeroAI:GetStrongestFriendlyTarget(hSpell)
        if hTarget ~= nil and hTarget:IsNull() == false and HeroAI:IsAlive(hTarget) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end

    if(abilityName == "clinkz_death_pact") then
        local hTarget = HeroAI:GetDeathPactTarget(hSpell)
        if hTarget ~= nil and hTarget:IsNull() == false and HeroAI:IsAlive(hTarget) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end

    if(abilityName == "meepo_poof") then
        --[[if(hero:GetHealthPercent() < 50) then
            local hTarget = HeroAI:GetClosestToFountainMeepo(hero)
            if hTarget ~= nil and hTarget:IsNull() == false and HeroAI:IsAlive(hTarget) then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        end]]

        if(HeroAI:HasEnemyNearby(hero, 375)) then
            return {ability = hSpell, type = "unit_target", target = hero}
        end

        return nil
    end

    if(abilityName == "meepo_item_duplication") then
        local hTarget = HeroAI:GetClosestEquippedHero(hSpell)
        if(hTarget ~= nil and hTarget:IsNull() == false) then
            return {ability = hSpell, type = "unit_target", target = hTarget}
        end

        return nil
    end
    
    if bitContains(nTargetType, DOTA_UNIT_TARGET_TREE) then
        local treeTarget = HeroAI:FindTreeTarget(hSpell)
        if treeTarget ~= nil then
            return {ability = hSpell, type = "tree_target", target = treeTarget}
        end
    elseif bitContains(nTargetTeam, DOTA_UNIT_TARGET_TEAM_CUSTOM) then
        if bitContains(nTargetFlags, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO) then
            local hTarget = HeroAI:GetBestCreepTarget(hSpell)
            if hTarget ~= nil and hTarget:IsNull() == false and HeroAI:IsAlive(hTarget) then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        else
            local hTarget = HeroAI:GetBestHeroTargetInRange(hSpell)
            if hTarget ~= nil and hTarget:IsNull() == false and HeroAI:IsAlive(hTarget) then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        end
    elseif bitContains(nTargetTeam, DOTA_UNIT_TARGET_TEAM_ENEMY) then
        if bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
            if HeroAI:IsNoTargetSpellCastValid(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY) then
                return {ability = hSpell, type = "no_target", target = nil}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_DIRECTIONAL) then
            local vTargetLoc = HeroAI:GetBestDirectionalPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY)
            if HeroAI:IsValidPosition(vTargetLoc) then
                return {ability = hSpell, type = "point_target", target = vTargetLoc}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_POINT) then
            local vTargetLoc = HeroAI:GetBestAOEPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY)
            if HeroAI:IsValidPosition(vTargetLoc) then
                return {ability = hSpell, type = "point_target", target = vTargetLoc}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then
            if bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_AOE) then
                local hTarget = HeroAI:GetBestHeroTargetInRange(hSpell)
                if hTarget ~= nil and hTarget:IsNull() == false then
                    return {ability = hSpell, type = "unit_target", target = hTarget}
                end
            else
                if bitContains(nTargetType, DOTA_UNIT_TARGET_HERO) then
                    local hTarget = HeroAI:GetBestHeroTargetInRange(hSpell)
                    if hTarget ~= nil and hTarget:IsNull() == false and HeroAI:IsAlive(hTarget) then
                        return {ability = hSpell, type = "unit_target", target = hTarget}
                    end
                else
                    local hTarget = HeroAI:GetBestCreepTarget(hSpell)
                    if hTarget ~= nil and hTarget:IsNull() == false and HeroAI:IsAlive(hTarget) then
                        return {ability = hSpell, type = "unit_target", target = hTarget}
                    end
                end
            end
        end
    elseif bitContains(nTargetTeam, DOTA_UNIT_TARGET_TEAM_FRIENDLY) then
        if(HeroAI:HasEnemyNearby(hero, 1500) == false) then
            return nil
        end
        if bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
            if HeroAI:IsNoTargetSpellCastValid(hSpell, DOTA_UNIT_TARGET_TEAM_FRIENDLY) then
                return {ability = hSpell, type = "no_target", target = nil}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_POINT) then
            local vTargetLoc = HeroAI:GetBestAOEPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_FRIENDLY)
            if HeroAI:IsValidPosition(vTargetLoc) then
                return {ability = hSpell, type = "point_target", target = vTargetLoc}
            end
        else
            local hTarget = HeroAI:GetBestFriendlyTarget(hSpell, 0.99)
            if hTarget ~= nil and hTarget:IsNull() == false then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        end
    else
        if bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
            if HeroAI:IsNoTargetSpellCastValid(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY) then
                return {ability = hSpell, type = "no_target", target = nil}
            end
        elseif bitContains(nBehavior, DOTA_ABILITY_BEHAVIOR_POINT) then
            local vTargetLoc = HeroAI:GetBestAOEPointTarget(hSpell, DOTA_UNIT_TARGET_TEAM_ENEMY)
            if HeroAI:IsValidPosition(vTargetLoc) then
                return {ability = hSpell, type = "point_target", target = vTargetLoc}
            end
        else
            local hTarget = HeroAI:GetBestHeroTargetInRange(hSpell)
            if hTarget ~= nil and hTarget:IsNull() == false then
                return {ability = hSpell, type = "unit_target", target = hTarget}
            end
        end
    end
    
    return nil
end

function HeroAI:ClosestEnemyAll(hero, teamId)
    if(teamId ~= DOTA_TEAM_GOODGUYS and teamId ~= DOTA_TEAM_BADGUYS) then
        return nil
    end

    if(hero == nil or hero:IsNull()) then
        return nil
    end

    local enemies = FindUnitsInRadius(teamId, hero:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, UNIT_FILTER, FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    local firstEnemy = nil
    local bestEnemy = nil
    local heroName = hero:GetName()
    local isAssassin = false
    
    for index = 1, #enemies do
        if(enemies[index]:IsInvisible() == false or HeroAI:HasTargetTrueSight(hero, enemies[index])) then
            if(HeroAI:IsValidPosition(enemies[index]:GetAbsOrigin()) and HeroAI:IsAlive(enemies[index]) and enemies[index]:IsInvulnerable() == false and enemies[index]:IsAttackImmune() == false) then
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

BonusCastRangeAbilities = {
    {modiferName = "modifier_special_bonus_cast_range", abilityName = "special_bonus_cast_range_50", range = 50},
    {modiferName = "modifier_special_bonus_cast_range", abilityName = "special_bonus_cast_range_60", range = 60},
    {modiferName = "modifier_special_bonus_cast_range", abilityName = "special_bonus_cast_range_75", range = 75},
    {modiferName = "modifier_special_bonus_cast_range", abilityName = "special_bonus_cast_range_100", range = 100},
    {modiferName = "modifier_special_bonus_cast_range", abilityName = "special_bonus_cast_range_125", range = 125},
    {modiferName = "modifier_special_bonus_cast_range", abilityName = "special_bonus_cast_range_150", range = 150},
    {modiferName = "modifier_special_bonus_cast_range", abilityName = "special_bonus_cast_range_175", range = 175},
    {modiferName = "modifier_special_bonus_cast_range", abilityName = "special_bonus_cast_range_200", range = 200},
    {modiferName = "modifier_special_bonus_cast_range", abilityName = "special_bonus_cast_range_250", range = 250},
    {modiferName = "modifier_special_bonus_cast_range", abilityName = "special_bonus_cast_range_275", range = 275},
    {modiferName = "modifier_special_bonus_cast_range", abilityName = "special_bonus_cast_range_300", range = 300},
    {modiferName = "modifier_special_bonus_cast_range", abilityName = "special_bonus_cast_range_350", range = 350},
    {modiferName = "modifier_special_bonus_cast_range", abilityName = "special_bonus_cast_range_400", range = 400},
}

function HeroAI:GetSpellRange(hSpell)
    if(hSpell == nil) then
        return 250
    end
    
    local baseCastRange = nil

    local ok = pcall(function()
        baseCastRange = hSpell:GetCastRange()
    end)

    if not ok then
        baseCastRange = hSpell:GetCastRange(vec3_invalid, nil)
    end

    if(baseCastRange == nil or baseCastRange < 250) then
        baseCastRange = 250
    end
    
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull()) then
        return baseCastRange
    end
    
    local abilityName = hSpell:GetName()
    if(abilityName == "antimage_blink") then
        return 1500
    end

    if(abilityName == "item_blink") then
        return 1200
    end
    
    if(abilityName == "item_hurricane_pike") then
        return 400
    end

    if(abilityName == "puck_illusory_orb") then
        return 1800
    end

    if(caster.GetCastRangeBonus ~= nil) then
        baseCastRange = baseCastRange + caster:GetCastRangeBonus()
    else
        if(caster:HasModifier("modifier_item_aether_lens")) then
            baseCastRange = baseCastRange + 250
        end

        for _, v in pairs(BonusCastRangeAbilities) do
            if(caster:HasModifier(v.modiferName) and caster:HasAbility(v.abilityName)) then
                baseCastRange = baseCastRange + v.range
                break
            end
        end
    end

    if(abilityName == "windrunner_focusfire") then
        baseCastRange = baseCastRange + 100
    end

    return baseCastRange
end

function HeroAI:GetBestHeroTargetInRange(hSpell, findFarthest)
    local findWay = FIND_CLOSEST
    if(findFarthest ~= nil) then
        findWay = FIND_FARTHEST
    end

    local abilityName = hSpell:GetName()
    
    local castMagicImmuneTarget = false
    if (table.contains(KV_SPELL_IMMUNITY_ABILITIES, hSpell:GetName()) == true) then
        castMagicImmuneTarget = true
    end

    local hero = hSpell:GetCaster()

    if(abilityName == "vengefulspirit_magic_missile") then
        local spellImmunity = hero:FindAbilityByName("special_bonus_unique_vengeful_spirit_3")
        if(spellImmunity ~= nil and spellImmunity:GetLevel() > 0) then
            castMagicImmuneTarget = true
        end
    end

    if(abilityName == "chaos_knight_reality_rift") then
        local spellImmunity = hero:FindAbilityByName("special_bonus_unique_chaos_knight")
        if(spellImmunity ~= nil and spellImmunity:GetLevel() > 0) then
            castMagicImmuneTarget = true
        end
    end

    if(abilityName == "bane_brain_sap" or abilityName == "lina_laguna_blade") then
        if(hero:HasScepter()) then
            castMagicImmuneTarget = true
        end
    end

    if(abilityName == "skywrath_mage_arcane_bolt") then
        local spellImmunity = hero:FindAbilityByName("special_bonus_unique_skywrath_6")
        if(spellImmunity ~= nil and spellImmunity:GetLevel() > 0) then
            castMagicImmuneTarget = true
        end
    end

    local teamId = hero:GetTeamNumber()
    local radius = HeroAI:GetSpellRange(hSpell)
    local needCheckModifier = table.contains(CheckModifierPointTargetAbility, abilityName)
    
    local enemies = FindUnitsInRadius(teamId, hero:GetAbsOrigin(), hero, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, findWay, true)
    
    if #enemies == 0 then
        return nil
    end
    
    local firstEnemy = nil
    local rangedEnemy = nil
    local isAssassin = false
    if(hero.HasItemInInventory ~= nil and hero:HasItemInInventory("item_assassin_medal")) then
        isAssassin = true
    end
    
    for index = 1, #enemies do
        if(enemies[index]:IsInvisible() == false or HeroAI:HasTargetTrueSight(hero, enemies[index])) then
            if(HeroAI:IsAlive(enemies[index]) and HeroAI:IsValidHeroTargetToCast(enemies[index])) then
                if(enemies[index]:IsMagicImmune() == false or castMagicImmuneTarget) then
                    if(needCheckModifier == false or HeroAI:CheckTargetNoModifier(hSpell, enemies[index]) == true) then
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
    end
    
    if(isAssassin and rangedEnemy ~= nil) then
        return rangedEnemy
    end
    
    return firstEnemy
end

function HeroAI:CheckTargetNoModifier(hSpell, targetHero)
    if(targetHero == nil or targetHero:IsNull()) then
        return false
    end

    local abilityName = hSpell:GetName()
    local modifierName = "modifier_" .. hSpell:GetName()

    if(abilityName == "shadow_demon_demonic_purge") then
        modifierName = "modifier_shadow_demon_purge_slow"
    end

    if(abilityName == "void_spirit_resonant_pulse") then
        modifierName = "modifier_void_spirit_resonant_pulse_physical_buff"
    end

    if(abilityName == "lycan_wolf_bite") then
        if(targetHero == hSpell:GetCaster() or targetHero:GetName() == "npc_dota_hero_lycan") then
            return false
        end

        modifierName = "modifier_lycan_wolf_bite_lifesteal"
    end

    if(targetHero:HasModifier(modifierName)) then
        return false
    end

    return true
end

function HeroAI:GetWeakestHeroTargetInRange(hSpell, maxHp, considerMagicImmune)
    local hero = hSpell:GetCaster()
    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    local target = nil
    
    if #enemies == 0 then
        return nil
    end

    if(considerMagicImmune == nil) then
        considerMagicImmune = true
    end
    
    for i = 1, #enemies do
        if(enemies[i]:IsInvisible() == false or HeroAI:HasTargetTrueSight(hero, enemies[i])) then
            if(HeroAI:IsAlive(enemies[i]) and HeroAI:IsValidHeroTargetToCast(enemies[i])) then
                if(considerMagicImmune == false or enemies[i]:IsMagicImmune() == false) then
                    local HP = enemies[i]:GetHealth()
                    if(HP <= maxHp) then
                        target = enemies[i]
                        break
                    end
                end
            end
        end
    end
    
    return target
end

function HeroAI:GetLostMostHealthHeroTargetInRange(hSpell, minLoseHp)
    local hero = hSpell:GetCaster()
    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    if(minLoseHp == nil) then
        minLoseHp = 500
    end

    local target = nil
    
    if #enemies == 0 then
        return nil
    end

    local maxLoseHp = minLoseHp
    
    for i = 1, #enemies do
        if(enemies[i]:IsInvisible() == false or HeroAI:HasTargetTrueSight(hero, enemies[i])) then
            if(HeroAI:IsAlive(enemies[i]) and HeroAI:IsValidHeroTargetToCast(enemies[i])) then
                if(enemies[i]:IsMagicImmune() == false) then
                    local loseHp = enemies[i]:GetMaxHealth() - enemies[i]:GetHealth()
                    if(loseHp >= maxLoseHp) then
                        maxLoseHp = loseHp
                        target = enemies[i]
                    end
                end
            end
        end
    end
    
    return target
end

function HeroAI:GetStrongestEnemyHeroTargetInRange(hSpell, minHpPercent)
    local hero = hSpell:GetCaster()
    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    local target = nil
    
    if #enemies == 0 then
        return nil
    end

    local castMagicImmuneTarget = false
    if (table.contains(KV_SPELL_IMMUNITY_ABILITIES, hSpell:GetName()) == true) then
        castMagicImmuneTarget = true
    end

    for i = 1, #enemies do
        if(enemies[i]:IsInvisible() == false or HeroAI:HasTargetTrueSight(hero, enemies[i])) then
            if(HeroAI:IsAlive(enemies[i]) and HeroAI:IsValidHeroTargetToCast(enemies[i])) then
                if(enemies[i]:IsMagicImmune() == false or castMagicImmuneTarget) then
                    local HP = enemies[i]:GetHealthPercent()
                    if(HP > minHpPercent) then
                        minHpPercent = HP
                        target = enemies[i]
                    end
                end
            end
        end
    end
    
    return target
end

function HeroAI:GetHighesetMaxHealthEnemyHeroTargetInRange(hSpell)
    local hero = hSpell:GetCaster()
    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    local target = nil
    
    if #enemies == 0 then
        return nil
    end

    local castMagicImmuneTarget = false
    if (table.contains(KV_SPELL_IMMUNITY_ABILITIES, hSpell:GetName()) == true) then
        castMagicImmuneTarget = true
    end

    local maxHealth = 0

    for i = 1, #enemies do
        if(enemies[i]:IsInvisible() == false or HeroAI:HasTargetTrueSight(hero, enemies[i])) then
            if(HeroAI:IsAlive(enemies[i]) and HeroAI:IsValidHeroTargetToCast(enemies[i])) then
                if(enemies[i]:IsMagicImmune() == false or castMagicImmuneTarget) then
                    local mh = enemies[i]:GetMaxHealth()
                    if(mh > maxHealth) then
                        maxHealth = mh
                        target = enemies[i]
                    end
                end
            end
        end
    end
    
    return target
end

function HeroAI:GetNoManaHeroTargetInRange(hSpell)
    local hero = hSpell:GetCaster()
    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    local minMana = 0.6
    local target = nil
    
    if #enemies == 0 then
        return nil
    end
    
    for i = 1, #enemies do
        if(enemies[i]:IsInvisible() == false or HeroAI:HasTargetTrueSight(hero, enemies[i])) then
            if(HeroAI:IsAlive(enemies[i]) and HeroAI:IsValidHeroTargetToCast(enemies[i])) then
                local mana = enemies[i]:GetMana() / enemies[i]:GetMaxMana()
                if(mana < 1.0) then
                    if enemies[i]:IsMagicImmune() == false and mana < minMana then
                        minMana = enemies[i]:GetMana() / enemies[i]:GetMaxMana()
                        target = enemies[i]
                    end
                end
            end
        end
    end
    
    return target
end

function HeroAI:GetRubickStealTarget(hSpell, currentAbilityName)
    local hero = hSpell:GetCaster()
    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, FIND_ANY_ORDER, true)

    local target = nil

    if #enemies == 0 then
        return nil
    end
    
    for i = 1, #enemies do
        if(enemies[i]:IsInvisible() == false or HeroAI:HasTargetTrueSight(hero, enemies[i])) then
            if(HeroAI:IsAlive(enemies[i]) and HeroAI:IsValidHeroTargetToCast(enemies[i])) then
                local heroName = enemies[i]:GetName()
                if(heroName ~= "npc_dota_hero_rubick" and heroName ~= "npc_dota_hero_arc_warden" and heroName ~= "npc_dota_hero_spectre" and heroName ~= "npc_dota_hero_wisp") then
                    if(enemies[i].LastSpellAbilityName ~= nil and currentAbilityName ~= enemies[i].LastSpellAbilityName) then
                        if(table.contains(KV_RUBICK_STEALS, enemies[i].LastSpellAbilityName)) then
                            target = enemies[i]
                            break
                        end
                    end
                end
            end
        end
    end

    if(target ~= nil and target:IsNull() == false) then
        return target
    end
    
    return nil
end

function HeroAI:GetClosestEnemyHero(hero, radius)
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    if(radius == nil) then
        radius = 1000
    end
    
    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    local target = nil
    for _, v in pairs(enemies) do
        if(v:IsInvisible() == false or HeroAI:HasTargetTrueSight(hero, v)) then
            if(HeroAI:IsAlive(v) and HeroAI:IsValidHeroTargetToCast(v)) then
                target = v
                break
            end
        end
    end
    
    return target
end

function HeroAI:GetFarestEnemyTarget(hero, radius)
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    if(radius == nil) then
        radius = 1000
    end
    
    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, FIND_FARTHEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    local farestLength = 0
    local target = nil
    for _, v in pairs(enemies) do
        if(v:IsInvisible() == false or HeroAI:HasTargetTrueSight(hero, v)) then
            if(HeroAI:IsAlive(v) and HeroAI:IsValidHeroTargetToCast(v)) then
                local length = (hero:GetAbsOrigin() - v:GetAbsOrigin()):Length2D()
                if(length > farestLength) then
                    farestLength = length
                    target = v
                end
            end
        end
    end
    
    return target
end

function HeroAI:GetDispelTarget(hSpell)
    local hero = hSpell:GetCaster()
    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    local target = nil
    for _, v in pairs(enemies) do
        if(v:IsInvisible() == false or HeroAI:HasTargetTrueSight(hero, v)) then
            if(HeroAI:IsAlive(v) and HeroAI:IsValidHeroTargetToCast(v) and v:IsMagicImmune() == false) then
                if(v:HasModifier("modifier_item_aeon_disk_buff") or v:HasModifier("modifier_omninight_guardian_angel")) then
                    target = v
                    break
                end
            end
        end
    end
    
    return target
end

function HeroAI:GetLowManaFriendlyTarget(hSpell)
    local friends = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    if #friends == 0 then
        return nil
    end
    
    local minMana = nil
    local target = nil
    for _, v in pairs(friends) do
        if(HeroAI:IsAlive(v) and HeroAI:IsValidHeroTargetToCast(v)) then
            local mana = v:GetManaPercent()
            if mana < 80 and (minMana == nil or mana < minMana) then
                minMana = mana
                target = v
            end
        end
    end
    
    return target
end

function HeroAI:GetBestFriendlyTarget(hSpell, minHpPercent)
    if(minHpPercent == nil) then
        minHpPercent = 1.0
    end

    local friends = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, hSpell:GetAbilityTargetFlags(), 0, true)
    
    if #friends == 0 then
        return nil
    end
    
    local minHP = nil
    local target = nil
    for _, v in pairs(friends) do
        if(HeroAI:IsAlive(v) and HeroAI:IsValidHeroTargetToCast(v)) then
            local HP = v:GetHealth() / v:GetMaxHealth()
            if(HP <= minHpPercent) then
                if minHP == nil or HP < minHP then
                    minHP = v:GetHealth() / v:GetMaxHealth()
                    target = v
                end
            end
        end
    end
    
    return target
end

function HeroAI:GetBestFriendlyTargetNotSelf(hSpell, minHpPercent)
    if(minHpPercent == nil) then
        minHpPercent = 1.0
    end
    
    local friends = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, hSpell:GetAbilityTargetFlags(), FIND_CLOSEST, true)
    
    if #friends == 0 then
        return nil
    end
    
    local minHP = nil
    local target = nil
    for _, v in pairs(friends) do
        if(HeroAI:IsAlive(v) and v ~= hSpell:GetCaster() and HeroAI:IsValidHeroTargetToCast(v)) then
            local HP = v:GetHealth() / v:GetMaxHealth()
            if(HP <= minHpPercent) then
                if minHP == nil or HP < minHP then
                    minHP = v:GetHealth() / v:GetMaxHealth()
                    target = v
                end
            end
        end
    end
    
    return target
end

function HeroAI:GetNetherSwapTarget(hSpell)
    local hero = hSpell:GetCaster()
    local team = hSpell:GetCaster():GetTeamNumber()
    local heroPos = hero:GetAbsOrigin()
    local swapEnemy = false
    local spellRange = HeroAI:GetSpellRange(hSpell)

    if(heroPos.x > 0 and team == DOTA_TEAM_BADGUYS or heroPos.x < 0 and team == DOTA_TEAM_GOODGUYS) then
        swapEnemy = true
    end

    if(swapEnemy) then
        local enemies = FindUnitsInRadius(team, heroPos, hero, spellRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, FIND_FARTHEST, true)
        
        if #enemies == 0 then
            return nil
        end

        for _, v in pairs(enemies) do
            if(v:IsInvisible() == false or HeroAI:HasTargetTrueSight(hero, v)) then
                if(HeroAI:IsAlive(v) and v ~= hero and HeroAI:IsValidHeroTargetToCast(v)) then
                    if(v:IsRangedAttacker() == true) then
                        local enemyPosition = v:GetAbsOrigin()
                        if(enemyPosition.x > 0 and team == DOTA_TEAM_GOODGUYS or enemyPosition.x < 0 and team == DOTA_TEAM_BADGUYS) then
                            return v
                        end
                    end
                end
            end
        end

        return nil
    else
        local friends = FindUnitsInRadius(team, heroPos, hero, spellRange, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, FIND_CLOSEST, true)
        
        if #friends == 0 then
            return nil
        end
        
        for _, v in pairs(friends) do
            if(HeroAI:IsAlive(v) and v ~= hero and HeroAI:IsValidHeroTargetToCast(v)) then
                if(v:IsRangedAttacker() == false) then
                    return v
                end
            end
        end
        
        return nil
    end
end

function HeroAI:GetStrongestFriendlyTarget(hSpell)
    local friends = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, hSpell:GetAbilityTargetFlags(), 0, true)
    
    if #friends == 0 then
        return nil
    end
    
    local maxHP = 0
    local target = nil
    for _, v in pairs(friends) do
        if(HeroAI:IsAlive(v) and HeroAI:IsValidHeroTargetToCast(v)) then
            if v:GetHealth() > maxHP then
                maxHP = v:GetHealth()
                target = v
            end
        end
    end
    
    return target
end

function HeroAI:GetMostDamageFriendlyTarget(hSpell, exceptSelf)
    local friends = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, hSpell:GetAbilityTargetFlags(), 0, true)
    
    if #friends == 0 then
        return nil
    end
    
    local maxDamage = 0
    local target = nil
    for _, v in pairs(friends) do
        if(HeroAI:IsAlive(v) and HeroAI:IsValidHeroTargetToCast(v)) then
            if(exceptSelf == false or v ~= hSpell:GetCaster()) then
                local trueDamage = v:GetAverageTrueAttackDamage(v)
                if trueDamage > maxDamage then
                    maxDamage = trueDamage
                    target = v
                end
            end
        end
    end
    
    return target
end

function HeroAI:GetFriendlyTargetByModifier(hero, range, modifierName, exceptSelf)
    if(HeroAI:IsAlive(hero) == false or range == nil) then
        return nil
    end

    local friends = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, FIND_CLOSEST, true)
    
    if #friends == 0 then
        return nil
    end
    
    local target = nil
    for _, v in pairs(friends) do
        if(HeroAI:IsAlive(v) and HeroAI:IsValidHeroTargetToCast(v)) then
            if(exceptSelf == false or v ~= hero) then
                if(v:HasModifier(modifierName)) then
                    target = v
                end
            end
        end
    end
    
    return target
end

function HeroAI:GetSpectreRealityTarget(hSpell)
    local friends = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    2000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, hSpell:GetAbilityTargetFlags(), 0, true)
    
    if #friends == 0 then
        return nil
    end
    
    local target = nil
    for _, v in pairs(friends) do
        if(HeroAI:IsValidPosition(v:GetAbsOrigin()) and HeroAI:IsAlive(v) and v:IsIllusion() == true) then
            if(v:GetName() == "npc_dota_hero_spectre" and v.RealOwner == hSpell:GetCaster()) then
                target = v
                break
            end
        end
    end
    
    return target
end

function HeroAI:GetScepterGiveTarget(hSpell)
    local friends = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, hSpell:GetAbilityTargetFlags(), FIND_CLOSEST, true)
    
    if #friends == 0 then
        return nil
    end
    
    local target = nil
    for _, v in pairs(friends) do
        if(HeroAI:IsAlive(v) and HeroAI:IsValidHeroTargetToCast(v)) then
            if v ~= hSpell:GetCaster() and v:HasScepter() == false then
                if(GameRules.DW.MapName == "dawn_war_coop") then
                    target = v
                    break
                elseif(v.GetPlayerID ~= nil and v:GetPlayerID() == hSpell:GetCaster():GetPlayerID()) then
                    target = v
                    break
                end
            end
        end
    end
    
    return target
end

function HeroAI:GetNearestFriendWithoutBuff(hSpell)
    local hero = hSpell:GetCaster()
    local friends = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, hSpell:GetAbilityTargetFlags(), FIND_CLOSEST, true)
    
    if #friends == 0 then
        return nil
    end
    
    local target = nil
    for _, v in pairs(friends) do
        if v ~= hero and HeroAI:IsAlive(v) and HeroAI:IsValidHeroTargetToCast(v) then
            if(HeroAI:CheckTargetNoModifier(hSpell, v) == true) then
                target = v
                break
            end
        end
    end
    
    if(target == nil) then
        if(HeroAI:CheckTargetNoModifier(hSpell, hero) == true) then
            return hero
        else
            return nil
        end
    else
        return target
    end
end

function HeroAI:GetFarestFriend(hero)
    local friends = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    8000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, FIND_CLOSEST, true)
    
    if #friends == 0 then
        return nil
    end
    
    for _, v in pairs(friends) do
        if(HeroAI:IsAlive(v) and HeroAI:IsValidHeroTargetToCast(v)) then
            if((hero:GetAbsOrigin() - v:GetAbsOrigin()):Length2D() > 2500) then
                return v
            end
        end
    end
    
    return nil
end

function HeroAI:GetBestCreepTarget(hSpell)
    local enemies = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP, hSpell:GetAbilityTargetFlags(), FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    for _, v in pairs(enemies) do
        if(v:IsInvisible() == false or HeroAI:HasTargetTrueSight(hSpell:GetCaster(), v)) then
            if(HeroAI:IsValidPosition(v:GetAbsOrigin()) and HeroAI:IsAlive(v)) then
                return v
            end
        end
    end
    
    return nil
end

function HeroAI:GetBestDominateTarget(hSpell)
    local enemies = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_ENEMY, 
    DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_NOT_DOMINATED, 
    UNIT_FILTER, FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    for _, v in pairs(enemies) do
        if(v:IsInvisible() == false or HeroAI:HasTargetTrueSight(hSpell:GetCaster(), v)) then
            if(HeroAI:IsValidPosition(v:GetAbsOrigin()) and HeroAI:IsAlive(v)) then
                local eName = v:GetName()
                local unitName = v:GetUnitName()
                local canBeDominated = true
                if(eName == "npc_dota_unit_undying_zombie") then
                    canBeDominated = false
                elseif(unitName == "npc_dota_necronomicon_warrior_1" or unitName == "npc_dota_necronomicon_warrior_2" or unitName == "npc_dota_necronomicon_warrior_3") then
                    canBeDominated = false
                elseif(unitName == "npc_dota_necronomicon_archer_1" or unitName == "npc_dota_necronomicon_archer_2" or unitName == "npc_dota_necronomicon_archer_3") then
                    canBeDominated = false
                elseif(v.IsAncient ~= nil and v:IsAncient()) then
                    canBeDominated = false
                end

                if(canBeDominated) then
                    return v
                end
            end
        end
    end
    
    return nil
end

function HeroAI:GetDeathPactTarget(hSpell)
    local hero = hSpell:GetCaster()
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    for _, v in pairs(enemies) do
        if(v:IsInvisible() == false or HeroAI:HasTargetTrueSight(hero, v)) then
            if(HeroAI:IsValidPosition(v:GetAbsOrigin()) and HeroAI:IsAlive(v)) then
                if(v.IsAncient ~= nil and v:IsAncient() == false) then
                    if(v:GetName() == "npc_dota_clinkz_skeleton_archer" and v:GetOwner() == hero) then
                        return v
                    end

                    if(v.IsCreep ~= nil and v:IsCreep()) then
                        if(v:GetOwner() == hero or v:GetTeamNumber() ~= hero:GetTeamNumber()) then
                            return v
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

function HeroAI:GetSpecialChildrenTarget(hero, radius, unitName)
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, FIND_CLOSEST, true)
    
    if #enemies == 0 then
        return nil
    end

    if(unitName == "npc_dota_rattletrap_cog") then
        local cogsCount = 0
        for _, v in pairs(enemies) do
            if(HeroAI:IsValidPosition(v:GetAbsOrigin())) then
                if(v:GetOwner() == hero and v:GetUnitName() == unitName) then
                    cogsCount = cogsCount + 1
                end
            end
        end

        if(cogsCount < 8) then
            return nil
        end
    end
    
    for _, v in pairs(enemies) do
        if(HeroAI:IsValidPosition(v:GetAbsOrigin())) then
            if(v:GetOwner() == hero and v:GetUnitName() == unitName) then
                return v
            end
        end
    end
    
    return nil
end

function HeroAI:GetSpellCastTime(hSpell)
    if(hSpell ~= nil and hSpell:IsNull() == false) then
        local flCastPoint = math.max(0.25, hSpell:GetCastPoint() + 0.25)
        
        return flCastPoint
    end
    return 0.25
end

function HeroAI:FindTreeTarget(hSpell)
    local Trees = GridNav:GetAllTreesAroundPoint(hSpell:GetCaster():GetAbsOrigin(), HeroAI:GetSpellRange(hSpell), false)
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

function HeroAI:FindTreantTreeTarget(hSpell)
    local hero = hSpell:GetCaster()
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    local fountainLoc = hero.targetPoint

    local Trees = GridNav:GetAllTreesAroundPoint(hSpell:GetCaster():GetAbsOrigin(), HeroAI:GetSpellRange(hSpell), false)
    if #Trees == 0 then
        return nil
    end
    
    local targetTree = nil
    local minDistance = 9999
    
    for i, v in pairs(Trees) do
        if(v ~= nil and v:IsNull() == false) then
            local targetPos = v:GetAbsOrigin()
            if(targetPos ~= nil and targetPos ~= vec3_invalid ) then
                local distance = (targetPos - fountainLoc):Length2D()
                if(distance <= minDistance) then
                    minDistance = distance
                    targetTree = v
                end
            end
        end
    end

    return targetTree
end

function HeroAI:CastSpellNoTarget(hSpell)
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull() or HeroAI:IsAlive(caster) == false) then
        return 0.2
    end

    if(hSpell == nil or hSpell:IsNull()) then
        return 0.2
    end

    local abilityName = hSpell:GetName()
    if(hSpell.IsItem ~= nil and hSpell:IsItem() == false) then
        caster.LastSpellAbilityName = abilityName
    end

    if table.contains(UseBkbAbilites, abilityName) then
        HeroAI:CheckAndUseBKB(caster)
    end

    caster:CastAbilityNoTarget(hSpell, caster:GetPlayerID())

    return HeroAI:GetSpellCastTime(hSpell)
end

function HeroAI:CastSpellUnitTarget(hSpell, hTarget)
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull() or HeroAI:IsAlive(caster) == false) then
        return 0.2
    end
    
    if(hTarget == nil or hTarget:IsNull() or HeroAI:IsAlive(hTarget) == false) then
        return 0.2
    end

    if(hSpell == nil or hSpell:IsNull()) then
        return 0.2
    end

    if(HeroAI:IsValidPosition(hTarget:GetAbsOrigin()) == false) then
        return 0.2
    end

    local abilityName = hSpell:GetName()
    if(hSpell.IsItem ~= nil and hSpell:IsItem() == false) then
        caster.LastSpellAbilityName = abilityName
    end

    if table.contains(UseBkbAbilites, abilityName) then
        HeroAI:CheckAndUseBKB(caster)
    end

    if(abilityName == "morphling_replicate") then
        caster.needRefreshMorphAblilites = true
    end

    caster:CastAbilityOnTarget(hTarget, hSpell, caster:GetPlayerID())
    
    return HeroAI:GetSpellCastTime(hSpell)
end

function HeroAI:CastSpellTreeTarget(hSpell, treeTarget)
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull() or HeroAI:IsAlive(caster) == false) then
        return 0.2
    end
    
    if(treeTarget == nil or treeTarget:IsNull()) then
        return 0.2
    end

    if(hSpell == nil or hSpell:IsNull()) then
        return 0.2
    end

    local abilityName = hSpell:GetName()
    if(hSpell.IsItem ~= nil and hSpell:IsItem() == false) then
        caster.LastSpellAbilityName = abilityName
    end
    
    caster:CastAbilityOnTarget(treeTarget, hSpell, caster:GetPlayerID())
    
    return HeroAI:GetSpellCastTime(hSpell)
end

function HeroAI:CastSpellPointTarget(hSpell, vLocation)
    local caster = hSpell:GetCaster()
    if(caster == nil or caster:IsNull() or HeroAI:IsAlive(caster) == false) then
        return 0.2
    end
    
    if(HeroAI:IsValidPosition(vLocation) == false) then
        return 0.2
    end

    if(hSpell == nil or hSpell:IsNull()) then
        return 0.2
    end
    
    local abilityName = hSpell:GetName()
    if(hSpell.IsItem ~= nil and hSpell:IsItem() == false) then
        caster.LastSpellAbilityName = abilityName
    end

    if(abilityName == "shredder_timber_chain") then
        if(GridNav:CanFindPath(caster:GetAbsOrigin(), vLocation)) then
            CreateTempTree(vLocation, 2)
            caster:CastAbilityOnPosition(vLocation, hSpell, caster:GetPlayerID())
        end
    elseif(abilityName == "tiny_tree_channel") then
        local selfLoc = caster:GetAbsOrigin()
        if((selfLoc - vLocation):Length2D() - 150 <= HeroAI:GetSpellRange(hSpell)) then
            for i = 1, 6 do
                CreateTempTree(selfLoc + RandomVector(400), 2)
            end
        end
        
        caster:CastAbilityOnPosition(vLocation, hSpell, caster:GetPlayerID())
    else
        caster:CastAbilityOnPosition(vLocation, hSpell, caster:GetPlayerID())
    end

    if table.contains(UseBkbAbilites, abilityName) then
        HeroAI:CheckAndUseBKB(caster)
    end
    
    return HeroAI:GetSpellCastTime(hSpell)
end

function HeroAI:IsNoTargetSpellCastValid(hSpell, targetTeamType)
    local nUnitsRequired = 1
    local abilityName = hSpell:GetName()
    local caster = hSpell:GetCaster()

    if hSpell:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
        nUnitsRequired = 2
        if(table.contains(SuperNoTargetAbility, abilityName)) then
            nUnitsRequired = 3
        end
        if(caster ~= nil and caster:IsNull() == false) then
            if(caster:GetHealthPercent() < 60) then
                nUnitsRequired = 1
            end
        end
    end

    if(abilityName == "item_black_king_bar" or abilityName == "item_minotaur_horn") then
        nUnitsRequired = 2
    end
    
    if(table.contains(AdjustNoTargetAbility, abilityName)) then
        nUnitsRequired = 1
    end
    
    local nAbilityRadius = hSpell:GetAOERadius()
    if nAbilityRadius == 0 then
        nAbilityRadius = 600
    end

    if(table.contains(AdjustRadiusAbility, abilityName)) then
        nAbilityRadius = nAbilityRadius * 2
    end

    if(abilityName == "nevermore_requiem" or abilityName == "phoenix_supernova" or abilityName == "lycan_howl") then
        nAbilityRadius = 1000
    end

    if(abilityName == "huskar_inner_fire") then
        nAbilityRadius = 500
    end

    if(abilityName == "phoenix_supernova" or abilityName == "zuus_thundergods_wrath") then
        nUnitsRequired = 1
    end

    if(table.contains(SuperNoTargetAbility, abilityName) and nAbilityRadius > 1000) then
        nAbilityRadius = 1000
    end

    if(abilityName == "venomancer_poison_nova") then
        if(CheckHasTalent(caster, "special_bonus_unique_venomancer_6")) then
            nAbilityRadius = 1500
        end
    end

    if(caster ~= nil and caster:IsNull() == false) then
        if(caster:GetName() == "npc_dota_hero_rubick" and hSpell.IsItem ~= nil and hSpell:IsItem() == false) then
            if(nAbilityRadius < 1200) then
                nAbilityRadius = 1200
            end
        end
    end
    
    local units = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(),
    hSpell:GetCaster(), nAbilityRadius, targetTeamType, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, 0, true)
    
    if #units < nUnitsRequired then
        return false
    end
    
    return true
end

function HeroAI:CastSpellOnSelf(hSpell)
    if(hSpell == nil or hSpell:IsNull()) then
        return 0.2
    end

    local hero = hSpell:GetCaster()
    if(hero ~= nil and hero:IsNull() == false) then
        hero.LastSpellAbilityName = hSpell:GetName()
        ExecuteOrderFromTable({
            UnitIndex = hero:entindex(),
            OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
            TargetIndex = hero:entindex(),
            AbilityIndex = hSpell:entindex(),
        })
    end

    return HeroAI:GetSpellCastTime(hSpell)
end

function HeroAI:CastSpellOnVector(hSpell, vLocation)
    local hero = hSpell:GetCaster()
    if(hero == nil or hero:IsNull()) then
        return 0.2
    end

    if(hSpell == nil or hSpell:IsNull()) then
        return 0.2
    end

    local abilityName = hSpell:GetName()
    
    local castLength = (vLocation - hero:GetAbsOrigin()):Length2D()
    local castVector = (vLocation - hero:GetAbsOrigin()):Normalized()
    local castLocation = hero:GetAbsOrigin() + castVector * castLength / 2
    
    ExecuteOrderFromTable({
        UnitIndex = hSpell:GetCaster():entindex(),
        OrderType = 30,
        Position = castLocation,
        TargetIndex = 0,
        AbilityIndex = hSpell:entindex(),
        Queue = 0
    })
    
    ExecuteOrderFromTable({
        UnitIndex = hSpell:GetCaster():entindex(),
        OrderType = 5,
        Position = vLocation,
        TargetIndex = 0,
        AbilityIndex = hSpell:entindex(),
        Queue = 0
    })

    hero.LastSpellAbilityName = abilityName
    
    return HeroAI:GetSpellCastTime(hSpell)
end

function HeroAI:GetBestAOEPointTarget(hSpell, targetTeamType)
    if(hSpell == nil) then
        return nil
    end
    
    local nUnitsRequired = 1
    if hSpell:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
        nUnitsRequired = 2

        local caster = hSpell:GetCaster()
        if(caster ~= nil and caster:IsNull() == false) then
            if(caster:GetHealthPercent() < 60) then
                nUnitsRequired = 1
            end
        end
    end
    
    local nAbilityRadius = hSpell:GetAOERadius()
    if nAbilityRadius == 0 then
        nAbilityRadius = HeroAI:GetSpellRange(hSpell)
    end
    
    if nAbilityRadius == 0 then
        nAbilityRadius = 250
    end

    local abilityName = hSpell:GetName()
    
    if(abilityName == "puck_illusory_orb" or abilityName == "dark_willow_terrorize") then
        nAbilityRadius = 400
    end

    if(abilityName == "ddw_dark_seer_wall_of_replica") then
        nAbilityRadius = 500
    end

    if(abilityName == "leshrac_pulse_nova") then
        nUnitsRequired = 1
    end
    
    if(nAbilityRadius > 1000) then
        nAbilityRadius = 1000
    end
    
    local vLocation = GetTargetAOELocation(hSpell:GetCaster():GetTeamNumber(),
        DOTA_UNIT_TARGET_HERO,
        targetTeamType,
        hSpell:GetCaster():GetAbsOrigin(),
        HeroAI:GetSpellRange(hSpell),
        nAbilityRadius,
    nUnitsRequired)
    if HeroAI:IsValidPosition(vLocation) == false then
        return nil
    end

    return vLocation
end

function HeroAI:GetBestDirectionalPointTarget(hSpell, targetTeamType)
    if(hSpell == nil) then
        return nil
    end
    
    local nUnitsRequired = 1
    if hSpell:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
        nUnitsRequired = 2

        local caster = hSpell:GetCaster()
        if(caster ~= nil and caster:IsNull() == false) then
            if(caster:GetHealthPercent() < 60) then
                nUnitsRequired = 1
            end
        end
    end
    
    local nAbilityRadius = hSpell:GetAOERadius()
    if nAbilityRadius == 0 then
        nAbilityRadius = 250
    end
    
    if(hSpell:GetName() == "kunkka_ghostship") then
        nAbilityRadius = 425
    end
    
    if(hSpell:GetName() == "invoker_chaos_meteor") then
        nAbilityRadius = 500
    end
    
    local vLocation = GetTargetLinearLocation(hSpell:GetCaster():GetTeamNumber(),
        DOTA_UNIT_TARGET_HERO,
        targetTeamType,
        hSpell:GetCaster():GetAbsOrigin(),
        HeroAI:GetSpellRange(hSpell),
        nAbilityRadius,
    nUnitsRequired)
    
    if HeroAI:IsValidPosition(vLocation) == false then
        return nil
    end
    
    return vLocation
end

function HeroAI:GetBestLinearTarget(hSpell, width)
    if(hSpell == nil or width == nil) then
        return nil
    end
    
    local nUnitsRequired = 1
    if hSpell:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
        nUnitsRequired = 2

        local caster = hSpell:GetCaster()
        if(caster ~= nil and caster:IsNull() == false) then
            if(caster:GetHealthPercent() < 60) then
                nUnitsRequired = 1
            end
        end
    end

    local vLocation = GetTargetLinearLocation(hSpell:GetCaster():GetTeamNumber(),
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        hSpell:GetCaster():GetAbsOrigin(),
        HeroAI:GetSpellRange(hSpell) * 0.75,
        width,
    nUnitsRequired)

    if HeroAI:IsValidPosition(vLocation) == false then
        return nil
    end
    
    return vLocation
end

function HeroAI:FindGoBackPosition(hero, moveLength)
    local heroLocation = hero:GetAbsOrigin()
    
    local vTargetLoc = _G.LEFT_SPAWN_POS
    if(hero:GetTeamNumber() ~= DOTA_TEAM_GOODGUYS) then
        vTargetLoc = _G.RIGHT_SPAWN_POS
    end

    local moveVector = (vTargetLoc - heroLocation):Normalized()
    local movePos = heroLocation + moveVector * moveLength

    if(HeroAI:IsValidPosition(movePos)) then
        return movePos
    else
        return nil
    end
end

function HeroAI:FindClearSpaceToMove(hero)
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

function HeroAI:IsUltimateSkillUsed(hero)
    if(hero == nil or hero:IsNull()) then
        return false
    end

    if(hero:GetName() == "npc_dota_hero_lone_druid") then
        if(hero:GetHealthPercent() <= 40) then
            return true
        end

        local bearAbility = hero:FindAbilityByName("lone_druid_spirit_bear")
        if(bearAbility ~= nil and bearAbility:GetLevel() > 0) then
            if(bearAbility:IsCooldownReady() == false and bearAbility:IsInAbilityPhase() == false) then
                return true
            end
        end

        return false
    end

    if(hero:HasAbility("juggernaut_omni_slash")) then
        local juggUlti = hero:FindAbilityByName("juggernaut_omni_slash")
        if(juggUlti ~= nil and juggUlti:GetLevel() > 0) then
            if(juggUlti:IsCooldownReady() == false) then
                return true
            else
                return false
            end
        end
    end
    
    local ultimateSkillUsed = false
    local hasUltimate = false
    local cooldownCount = 0
    local basicAbilityCount = 0
    
    for i = 0, hero:GetAbilityCount() - 1 do
        local ability = hero:GetAbilityByIndex(i)
        local canCast = true
        
        if(ability == nil or ability:GetLevel() <= 0) then
            canCast = false
        elseif(ability:IsHidden() or (ability:IsPassive() and ability:GetName() ~= "skeleton_king_reincarnation") or ability:IsActivated() == false) then
            canCast = false
        elseif(string.find(ability:GetName(), "_bonus") ~= nil) then
            canCast = false
        elseif(bitContains(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_AUTOCAST)) then
            canCast = false
        end

        if(canCast) then
            local abilityName = ability:GetName()
            if(ability:GetAbilityType() == ABILITY_TYPE_ULTIMATE) then
                hasUltimate = true
            else
                basicAbilityCount = basicAbilityCount + 1
            end

            local isInCooldown = false

            if(ability:IsFullyCastable() == false and ability:IsInAbilityPhase() == false and hero:GetMana() > ability:GetManaCost(ability:GetLevel())) then
                isInCooldown = true
            end

            if(isInCooldown) then
                if(abilityName ~= "morphling_adaptive_strike_str") then
                    cooldownCount = cooldownCount + 1
                end
            end

            if(ability:GetAbilityType() == ABILITY_TYPE_ULTIMATE or abilityName == "lycan_wolf_bite") then
                if((abilityName == "pugna_life_drain" and hero:HasScepter()) or abilityName == "axe_culling_blade" 
                    or abilityName == "morphling_replicate" or abilityName == "morphling_morph_replicate" or abilityName == "spectre_haunt") then
                    hasUltimate = false
                end

                if(isInCooldown) then
                    ultimateSkillUsed = true
                end
            end

            if(hasUltimate and ultimateSkillUsed == true) then
                break
            end
        end
    end

    if(hasUltimate == false and cooldownCount > 1) then
        return true
    end

    if(hasUltimate == false and basicAbilityCount <= 1) then
        return HeroAI:IsNeedRefreshItems(hero)
    end
    
    return ultimateSkillUsed
end

function HeroAI:GetShadowDanceTarget(hero)
    local friends = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    450, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, FIND_CLOSEST, true)
    
    if #friends == 0 then
        return nil
    end
    
    local target = nil
    local minHpPercent = 100

    for _, v in pairs(friends) do
        if(HeroAI:IsAlive(v) and v ~= hero and HeroAI:IsValidHeroTargetToCast(v)) then
            local HP = v:GetHealthPercent()
            if(HP <= minHpPercent) then
                minHpPercent = HP
                target = v
            end
        end
    end
    
    return target
end

function HeroAI:GetClosestToFountainMeepo(hero)
    local fountainLoc = GameRules.DW.FountainGood
    if(hero:GetTeamNumber() ~= DOTA_TEAM_GOODGUYS) then
        fountainLoc = GameRules.DW.FountainBad
    end

    local friends = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, FIND_FARTHEST, true)
    
    if #friends == 0 then
        return nil
    end
    
    local target = nil
    local minDistance = 9999

    for _, v in pairs(friends) do
        if(HeroAI:IsAlive(v) and v ~= hero and HeroAI:IsValidHeroTargetToCast(v)) then
            if(v:GetName() == "npc_dota_hero_meepo") then
                local distance = (v:GetAbsOrigin() - fountainLoc):Length2D()
                if(distance <= minDistance) then
                    minDistance = distance
                    target = v
                end
            end
        end
    end
    
    return target
end

function HeroAI:IsNeedRefreshItems(hero)
    if(hero == nil or hero:IsNull()) then
        return false
    end
    
    local itemCooldownCount = 0

    for slotIndex = 0, 5 do
        local item = hero:GetItemInSlot(slotIndex)
        if(item ~= nil) then
            local itemName = item:GetName()
            if(itemName ~= "item_refresher" and itemName ~= "item_heart") then
                if(item.IsCooldownReady ~= nil and item:IsCooldownReady() == false) then
                    itemCooldownCount = itemCooldownCount + 1
                end
            end
        end
    end

    if(itemCooldownCount >= 2) then
        return true
    end
    
    return false
end

function HeroAI:GetClosestEquippedHero(hSpell)
    if(minHpPercent == nil) then
        minHpPercent = 1.0
    end
    
    local friends = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, hSpell:GetAbilityTargetFlags(), FIND_CLOSEST, true)
    
    if #friends == 0 then
        return nil
    end
    
    local target = nil
    local bestTarget = nil

    for _, v in pairs(friends) do
        if(HeroAI:IsAlive(v) and v ~= hSpell:GetCaster() and HeroAI:IsValidHeroTargetToCast(v)) then
            local hasItem = false
            for slotIndex = 0, 5 do
                local item = v:GetItemInSlot(slotIndex)
                if(item ~= nil) then
                    hasItem = true
                    break
                end
            end

            if(hasItem) then
                if(target == nil) then
                    target = v
                end

                if(bestTarget == nil and v:GetName() ~= "npc_dota_hero_meepo") then
                    bestTarget = v
                end
            end

            if(target ~= nil and bestTarget ~= nil) then
                break
            end
        end
    end

    if(bestTarget ~= nil) then
        return bestTarget
    end
    
    return target
end

function HeroAI:GetMeleeFriendlyTarget(hSpell, ignoreMagicImmune, checkRadius)
    local friends = FindUnitsInRadius(hSpell:GetCaster():GetTeamNumber(), hSpell:GetCaster():GetAbsOrigin(), hSpell:GetCaster(),
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, hSpell:GetAbilityTargetFlags(), FIND_CLOSEST, true)
    
    if #friends == 0 then
        return nil
    end
    
    local target = nil
    local bestTarget = nil

    for _, v in pairs(friends) do
        if(HeroAI:IsAlive(v) and HeroAI:IsValidHeroTargetToCast(v)) then
            if(v:IsMagicImmune() == false or ignoreMagicImmune) then
                if(HeroAI:HasEnemyNearby(v, checkRadius)) then
                    if(target == nil) then
                        target = v
                    end

                    if(bestTarget == nil and v:IsRangedAttacker() == false) then
                        bestTarget = v
                    end

                    if(target ~= nil and bestTarget ~= nil) then
                        break
                    end
                end
            end
        end
    end

    if(bestTarget ~= nil) then
        return bestTarget
    end
    
    return target
end

function HeroAI:GetRangedEnemyTarget(hSpell, ignoreMagicImmune)
    local hero = hSpell:GetCaster()
    if(hero == nil or hero:IsNull()) then
        return nil
    end

    local enemies = FindUnitsInRadius(hero:GetTeamNumber(), hero:GetAbsOrigin(), hero,
    HeroAI:GetSpellRange(hSpell), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, UNIT_FILTER, FIND_FARTHEST, true)
    
    if #enemies == 0 then
        return nil
    end
    
    local target = nil

    for i = 1, #enemies do
        if(enemies[i]:IsInvisible() == false or HeroAI:HasTargetTrueSight(hero, enemies[i])) then
            if(HeroAI:IsAlive(enemies[i]) and HeroAI:IsValidHeroTargetToCast(enemies[i])) then
                if(enemies[i]:IsMagicImmune() == false or ignoreMagicImmune) then
                    if(enemies[i]:IsRangedAttacker()) then
                        target = enemies[i]
                        break
                    end
                end
            end
        end
    end

    return target
end