if DDW == nil then DDW = class({}) end

require 'shared'
require 'ai_bot'
require 'ai_hero'
require 'ai_unit'
require 'wearable'
require 'hero_ability'
require 'custom_abilities/hero_modifier'
require 'custom_items/item_custom_list'
require 'projectiles'

function Precache(context)
    PrecacheUnitByNameSync("npc_dota_hero_elf", context)

    for _, v in pairs(GameRules.DW.RandomDraftHeros) do
        if(v.valid == 1) then
            PrecacheUnitByNameSync(HeroNamePrefix .. v.name, context)
        end
    end
    
    for _, v in pairs(PreloadSounds) do
        PrecacheResource("soundfile", v, context)
    end
    
    for _, v in pairs(PreloadParticles) do
        PrecacheResource("particle", v, context)
    end
    
    for _, v in pairs(PreloadModels) do
        PrecacheResource("model", v, context)
    end
end

function Activate()
    GameRules.AddonTemplate = DDW()
    GameRules.AddonTemplate:InitGameMode()
end

function DDW:InitGameMode()
    GameRules.DW.SVR_KEY = GetDedicatedServerKeyV2("DDW")
    GameRules.DW.SVR = bSvrDecode2(GameRules.DW.SVR_KEY)
    GameRules.DW.MapName = GetMapName()
    SetTeamCustomHealthbarColor(DOTA_TEAM_GOODGUYS, 130, 250, 30)
    SetTeamCustomHealthbarColor(DOTA_TEAM_BADGUYS, 250, 70, 0)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 0)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)

    if(GameRules.DW.MapName == "dawn_war_coop") then
        for i, v in pairs(AllTeamIdxCoop) do
            GameRules:SetCustomGameTeamMaxPlayers(v, 2)
        end
    else
        for i, v in pairs(AllTeamIdx) do
            GameRules:SetCustomGameTeamMaxPlayers(v, 1)
        end
    end
    
    GameRules:SetStartingGold(500)
    GameRules:SetGoldPerTick(0)
    GameRules:SetGoldTickTime(0.6)
    GameRules:SetCustomGameEndDelay(0)
    GameRules:SetCustomVictoryMessageDuration(4)
    GameRules:SetPreGameTime(6)
    GameRules:SetPostGameTime(180)
    GameRules:SetStrategyTime(0.5)
    GameRules:SetShowcaseTime(0.0)
    GameRules:SetHeroRespawnEnabled(false)
    GameRules:SetUseUniversalShopMode(true)
    GameRules:SetHeroMinimapIconScale(0.64)
    GameRules:SetSameHeroSelectionEnabled(true)
    GameRules:SetCustomGameSetupAutoLaunchDelay(10)
    GameRules:SetHideKillMessageHeaders(false)
    GameRules:SetFirstBloodActive(false)
    GameRules:SetUseBaseGoldBountyOnHeroes(true)
    GameRules:SetRuneSpawnTime(-1)
    
    ListenToGameEvent("player_connect_full", Dynamic_Wrap(DDW, "OnConnectFull"), self)
    ListenToGameEvent("player_disconnect", Dynamic_Wrap(DDW, "OnDisconnect"), self)
    ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap(DDW, "OnPickHero"), self)
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(DDW, "OnGameRulesStateChange"), self)
    ListenToGameEvent("dota_player_gained_level", Dynamic_Wrap(DDW, "OnPlayerGainedLevel"), self)
    ListenToGameEvent("entity_killed", Dynamic_Wrap(DDW, "OnEntityKilled"), self)
    ListenToGameEvent("npc_spawned", Dynamic_Wrap(DDW, "OnNpcSpawned"), self)
    ListenToGameEvent("entity_hurt", Dynamic_Wrap(DDW, "OnEntityHurt"), self)
    ListenToGameEvent("dota_player_learned_ability", Dynamic_Wrap(DDW, "OnLearnedAbility"), self)
    
    CustomGameEventManager:RegisterListener("ADD_BOT", Dynamic_Wrap(DDW, "OnAddBot"))
    CustomGameEventManager:RegisterListener("BUY_HERO_REQUEST", Dynamic_Wrap(DDW, "OnBuyHeroRequest"))
    CustomGameEventManager:RegisterListener("DELETE_HERO_REQUEST", Dynamic_Wrap(DDW, "OnDeleteHeroRequest"))
    CustomGameEventManager:RegisterListener("SET_LOCK_ROLL", Dynamic_Wrap(DDW, "OnSetLockRoll"))
    CustomGameEventManager:RegisterListener("SET_READY_FOR_FIGHT", Dynamic_Wrap(DDW, "OnSetReadyForFight"))
    CustomGameEventManager:RegisterListener("GET_RANKING", Dynamic_Wrap(DDW, "OnGetRanking"))
    CustomGameEventManager:RegisterListener("CHANGE_HERO_POOL_REQUEST", Dynamic_Wrap(DDW, "OnChangeHeroPool"))
    CustomGameEventManager:RegisterListener("COUPON_REDEEM_REQUEST", Dynamic_Wrap(DDW, "OnCouponRedeem"))
    CustomGameEventManager:RegisterListener("COIN_INFO_REQUEST", Dynamic_Wrap(DDW, "OnCoinInfoRequest"))
    CustomGameEventManager:RegisterListener("BUY_ARCANA_REQUEST", Dynamic_Wrap(DDW, "OnBuyArcana"))
    CustomGameEventManager:RegisterListener("BUY_VIP_REQUEST", Dynamic_Wrap(DDW, "OnBuyVip"))
    CustomGameEventManager:RegisterListener("CHANGE_SKIN_REQUEST", Dynamic_Wrap(DDW, "OnChangeSkin"))
    CustomGameEventManager:RegisterListener("TOGGLE_SKIN_REQUEST", Dynamic_Wrap(DDW, "OnToggleSkin"))
    CustomGameEventManager:RegisterListener("SELL_HERO_CONFIRM_RESP", Dynamic_Wrap(DDW, "OnSellHeroConfirmResp"))
    CustomGameEventManager:RegisterListener("SHOW_DAMAGE_STAT_REQUEST", Dynamic_Wrap(DDW, "OnShowDamageStatRequest"))
    CustomGameEventManager:RegisterListener("ALERT_HERO_REQUEST", Dynamic_Wrap(DDW, "OnAlertHeroRequest"))
    CustomGameEventManager:RegisterListener("RELOAD_RECURIT_PANEL", Dynamic_Wrap(DDW, "OnReloadRecuritPanel"))
    CustomGameEventManager:RegisterListener("MARK_HERO", Dynamic_Wrap(DDW, "OnMarkHero"))
    CustomGameEventManager:RegisterListener("SELL_NEUTRAL_CONFIRM_RESP", Dynamic_Wrap(DDW, "OnSellNeutralConfrimResp"))
    CustomGameEventManager:RegisterListener("TOGGLE_ABILITY_STATUS", Dynamic_Wrap(DDW, "OnToggleAbilityStatus"))

    GameMode = GameRules:GetGameModeEntity()
    GameMode:SetPauseEnabled(true)
    GameMode:SetFogOfWarDisabled(true)
    GameMode:SetBuybackEnabled(false)
    GameMode:SetStashPurchasingDisabled(true)
    GameMode:SetTowerBackdoorProtectionEnabled(false)
    GameMode:SetRecommendedItemsDisabled(true)
    GameMode:SetStickyItemDisabled(true)
    GameMode:SetLoseGoldOnDeath(false)
    GameMode:SetAnnouncerDisabled(false)
    GameMode:SetAlwaysShowPlayerNames(false)
    GameMode:SetDeathOverlayDisabled(false)
    GameMode:SetHudCombatEventsDisabled(true)
    GameMode:SetUseCustomHeroLevels(true)
    GameMode:SetCustomXPRequiredToReachNextLevel(XpPerLevelTable)
    GameMode:SetCustomHeroMaxLevel(30)
    GameMode:SetCustomGameForceHero("npc_dota_hero_elf")
    GameMode:SetExecuteOrderFilter(Dynamic_Wrap(DDW, "ExecuteOrderFilter"), DDW)
    GameMode:SetModifyGoldFilter(Dynamic_Wrap(DDW, "ModifyGoldFilter"), DDW)
    GameMode:SetBountyRunePickupFilter(Dynamic_Wrap(DDW, "BountyRunePickupFilter"), DDW)
    GameMode:SetItemAddedToInventoryFilter(Dynamic_Wrap(DDW, "ItemAddedToInventoryFilter"), DDW)
    GameMode:SetFountainPercentageHealthRegen(20)
    GameMode:SetFountainPercentageManaRegen(50)
    GameMode:SetBotThinkingEnabled(false)
    GameMode:SetCustomBackpackSwapCooldown(0)
    
    SendToServerConsole("dota_max_physical_items_purchase_limit 9999")
    SendToServerConsole("dota_pause_count 1")
    SendToServerConsole("dota_reconnect_idle_buffer_time 360")
    SendToServerConsole("dota_idle_acquire 0")
    SendToServerConsole("dota_idle_time 3600")
    SendToServerConsole("dota_max_disconnected_time 3600")
    SendToServerConsole("dota_lenient_idle_time 4800")
    SendToServerConsole("dota_camera_distance 1300")
end

function DDW:ModifyGoldFilter(params)
    local reason = params.reason_const
    if(reason == DOTA_ModifyGold_SharedGold or reason == DOTA_ModifyGold_AbandonedRedistribute or reason == DOTA_ModifyGold_HeroKill) then
        return false
    end
    
    return true
end

function DDW:BountyRunePickupFilter(params)
    params["gold_bounty"] = 25
    params["xp_bounty"] = 0

    return true
end

function DDW:ItemAddedToInventoryFilter(params)
    local item = EntIndexToHScript(params.item_entindex_const)
    if(item == nil or item:IsNull()) then
        return false
    end

    local itemName = item:GetName()

    if(itemName == "item_ai_delay" or itemName == "item_phase_teleporter" or itemName == "item_no_attack" or itemName == "item_assassin_medal") then
        local hero = EntIndexToHScript(params.inventory_parent_entindex_const)
        if(hero ~= nil and hero:IsNull() == false) then
            local heroName = hero:GetUnitName()
            if(heroName ~= "npc_dota_hero_elf") then
                local suggestSlot = -1
                for slotIndex = 6, 8 do
                    local item = hero:GetItemInSlot(slotIndex)
                    if item == nil then
                        suggestSlot = slotIndex
                        break
                    end
                end
                params.suggested_slot = suggestSlot
            end
        end
    end

    return true
end

function DDW:ExecuteOrderFilter(params)
    local orderType = params.order_type

    if params.units == nil or params.units["0"] == nil then
        return false
    end

    if(table.count(params.units) > 1) then
        local checkPlayerId = nil

        for _, v in pairs(params.units) do
            local ca = EntIndexToHScript(v)
            if(ca ~= nil and ca:IsNull() == false and ca.GetPlayerID ~= nil) then
                checkPlayerId = ca:GetPlayerID()
                break
            end    
        end

        if(checkPlayerId ~= nil) then
            local player = PlayerResource:GetPlayer(checkPlayerId)
            if(player ~= nil and player:IsNull() == false) then
                local checkPlayerInfo = GameRules.DW.PlayerList[checkPlayerId]
                if(checkPlayerInfo ~= nil and checkPlayerInfo.ControlledHero ~= nil) then
                    CustomGameEventManager:Send_ServerToPlayer(player, "FOCUS_CONTROLLED_HERO", {})
                else
                    CustomGameEventManager:Send_ServerToPlayer(player, "RESET_FOCUSED_HERO", {})
                end
            end
        end

        return false
    end

    if orderType == DOTA_UNIT_ORDER_TRAIN_ABILITY then
        return true
    end

    local caster = EntIndexToHScript(params.units["0"])

    if(caster == nil or caster:IsNull()) then
        return false
    end

    if(caster.GetPlayerID == nil) then
        return false
    end

    local playerId = caster:GetPlayerID()
    local playerInfo = GameRules.DW.PlayerList[playerId]

    if(playerInfo == nil or playerInfo.Life <= 0) then
        return false
    end

    if(caster:HasModifier("modifier_hero_waitting")) then
        if(orderType == DOTA_UNIT_ORDER_STOP) then
            return true
        else
            if(orderType == DOTA_UNIT_ORDER_MOVE_TO_POSITION) then
                local player = PlayerResource:GetPlayer(playerId)
                if(player ~= nil and player:IsNull() == false) then
                    CustomGameEventManager:Send_ServerToPlayer(player, "RESET_FOCUSED_HERO", {})
                end
            end
            return false
        end
    end

    if(caster:GetUnitName() == "npc_dota_hero_elf") then
        if(orderType == DOTA_UNIT_ORDER_MOVE_ITEM and params.entindex_target ~= nil and GameRules.DW.MapName == "dawn_war_coop") then
            if(params.entindex_target == 9 or params.entindex_target == 10 or params.entindex_target == 11 or params.entindex_target == 12 or params.entindex_target == 13 or params.entindex_target == 14) then
                local item = EntIndexToHScript(params.entindex_ability)
                if(item ~= nil and item:IsNull() == false) then
                    local shareResult = GameRules.DW.ShareItem(caster, item)
                    if(shareResult == true) then
                        return false
                    else
                        return true
                    end
                end
            end
        end

        if(orderType == DOTA_UNIT_ORDER_CAST_POSITION or orderType == DOTA_UNIT_ORDER_CAST_NO_TARGET) then
            local ab = EntIndexToHScript(params.entindex_ability)
            if(ab ~= nil and ab:IsNull() == false) then
                if(ab:IsItem() and ab.GetItemSlot ~= nil and (ab:GetItemSlot() < 6 or ab:GetItemSlot() == 16)) then
                    local itemName = ab:GetName()
                    if(itemName == "item_scroll_of_time") then
                        return true
                    end
                    if(itemName == "item_smoke_of_deceit") then
                        if(GameRules.DW.StageName[GameRules.DW.Stage] == "PREPARE" and playerInfo.ReadyState > 0) then
                            for x = 1, 8 do
                                for y = 1, 8 do
                                    local hero = GameRules.DW.GetGridInfo(playerId, x, y)
                                    if hero ~= nil and hero:IsNull() == false then
                                        hero:AddNewModifier(hero, ab, "modifier_smoke_of_deceit", {})
                                    end
                                end
                            end
                            return true
                        else
                            return false
                        end
                    else
                        return false
                    end
                end
            end
        end

        if(orderType == 37 and params.entindex_target ~= nil ) then
            local neutralItem = EntIndexToHScript(params.entindex_ability)
            if(neutralItem ~= nil and neutralItem:IsNull() == false) then
                local leftTimes = 0
                if(playerInfo.NeutralItemSwapCount ~= nil) then
                    leftTimes = GameRules.DW.MaxNeutralItemSwapTimes - playerInfo.NeutralItemSwapCount
                end

                if(leftTimes < 0) then
                    leftTimes = 0
                end

                SendMessageToPlayer(playerId, "SELL_NEUTRAL_CONFIRM", { entindex = params.entindex_ability, leftTimes = leftTimes})
            end
            return false
        end
    end

    if(playerInfo.ControlledHero ~= nil and playerInfo.ControlledHero == caster) then
        if(orderType == DOTA_UNIT_ORDER_DROP_ITEM or orderType == DOTA_UNIT_ORDER_GIVE_ITEM or orderType == DOTA_UNIT_ORDER_DISASSEMBLE_ITEM or orderType == 32) then
            return false
        end

        if(orderType == DOTA_UNIT_ORDER_CAST_NO_TARGET) then
            local ab = EntIndexToHScript(params.entindex_ability)
            if(ab ~= nil and ab:IsNull() == false) then
                local abName = ab:GetName()
                if(abName == "spectre_haunt" or abName == "item_smoke_of_deceit") then
                    return false
                end
                if(abName == "item_refresher") then
                    if(caster:HasAbility("arc_warden_tempest_double")) then
                        return false
                    end
                end
            end
        end

        return true
    end

    if(caster:HasModifier("modifier_hero_command_restricted")) then
        if(params.issuer_player_id_const >= 0) then
            return false
        end
    end

    return true
end

function DDW:OnEntityHurt(data)
    if data.entindex_attacker ~= nil and data.entindex_killed ~= nil and data.damage ~= nil then
        local entCause = EntIndexToHScript(data.entindex_attacker)
        local entTaker = EntIndexToHScript(data.entindex_killed)
        if(entCause ~= nil and entCause:IsNull() == false) then
            if(entCause.IsRealHero ~= nil and entCause:IsRealHero()) then
                if(entCause.damage == nil) then entCause.damage = 0 end
                entCause.damage = entCause.damage + data.damage
            else
                local owner = nil
                if(entCause.GetOwner ~= nil) then
                    owner = entCause:GetOwner()
                end

                if(entCause.IsIllusion ~= nil and entCause:IsIllusion()) then
                    if(entCause.RealOwner ~= nil) then
                        if(entCause.RealOwner.damage == nil) then entCause.RealOwner.damage = 0 end
                        entCause.RealOwner.damage = entCause.RealOwner.damage + data.damage
                    end
                else
                    if(owner ~= nil and owner:IsNull() == false and owner.IsRealHero ~= nil and owner:IsRealHero()) then
                        if(owner.damage == nil) then owner.damage = 0 end
                        owner.damage = owner.damage + data.damage
                    end    
                end
            end
        end

        if(entTaker ~= nil and entTaker:IsNull() == false) then
            if(entTaker.IsRealHero ~= nil and entTaker:IsRealHero()) then
                if(entTaker.damageTake == nil) then entTaker.damageTake = 0 end
                entTaker.damageTake = entTaker.damageTake + data.damage
            end
        end
    end
end

function DDW:OnLearnedAbility(data)
    local playerId = data.PlayerID
    local playerInfo = GameRules.DW.PlayerList[playerId]

    if(playerInfo ~= nil) then
        if(GameRules.DW.MapName == "dawn_war_coop") then
            if(data.abilityname == "special_bonus_elf_10_1" or data.abilityName == "special_bonus_elf_10_2") then
                GameRules.DW.SyncTalentWithPartner(playerId, "special_bonus_elf_10_1", "special_bonus_elf_10_2", 10, false)
            end

            if(data.abilityname == "special_bonus_elf_20_1" or data.abilityName == "special_bonus_elf_20_2") then
                GameRules.DW.SyncTalentWithPartner(playerId, "special_bonus_elf_20_1", "special_bonus_elf_20_2", 20, true)
            end
        end

        if(data.abilityname == "special_bonus_elf_10_1") then
            playerInfo.SelectedBattlePosition = 1
        end

        if(data.abilityname == "special_bonus_elf_10_2") then
            playerInfo.SelectedBattlePosition = 2
        end

        if(data.abilityname == "special_bonus_elf_25_1") then
            GameRules.DW.DropNeutralItemForPlayer(playerInfo.Hero, -1)
        end

        if(data.abilityname == "special_bonus_elf_25_2") then
            GameRules.DW.DropItemForPlayer(playerInfo.Hero, "item_tome_of_upgrade")
        end
    end
end

function DDW:UpdateHeroPoolDisplay()
    local heroPoolTable = {}
    for _, v in pairs(GameRules.DW.RandomDraftHeros) do
        local heroPoolInfo = {}
        heroPoolInfo.name = v.name
        heroPoolInfo.valid = v.valid
        heroPoolInfo.markedPlayer = {}
        
        for playerId, playerInfo in pairs(GameRules.DW.PlayerList) do
            if(table.exist(playerInfo.MarkedHeroes, v.name)) then
                table.insert(heroPoolInfo.markedPlayer, playerId)
            end
        end

        table.insert(heroPoolTable, heroPoolInfo)
    end

    CustomNetTables:SetTableValue("hero_pool_table", "hero_pool", heroPoolTable)
end

function DDW:OnGameRulesStateChange()
    local state = GameRules:State_Get()
    
    if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        CreateTimer(function() DDW:KeepUpdateGameSetting() end, 1)
    end
    
    if state == DOTA_GAMERULES_STATE_PRE_GAME then
        DDW:UpdateHeroPoolDisplay()
        
        local playerCount = 0
        local postData = {}
        for playerId, info in pairs(GameRules.DW.PlayerList) do
            local teamId = PlayerResource:GetTeam(playerId)

            if(table.containsKey(GameRules.DW.TeamColor, teamId)) then
                info.TeamId = teamId

                if(GameRules.DW.MapName == "dawn_war_coop") then
                    local teamPosInfo = GameRules.DW.TeamPositionInfo[teamId]
                    if(teamPosInfo ~= nil) then
                        if(teamPosInfo[1] == -1) then
                            info.TeamPosition = 1
                            teamPosInfo[1] = playerId
                        else
                            info.TeamPosition = 2
                            teamPosInfo[2] = playerId
                        end
                    end
                else
                    info.TeamPosition = 1
                end

                local color = GameRules.DW.TeamColor[teamId]
                SetTeamCustomHealthbarColor(teamId, color[1], color[2], color[3])
                PlayerResource:SetCustomPlayerColor(playerId, color[1], color[2], color[3])
                
                if(info.IsEmpty ~= true) then
                    playerCount = playerCount + 1
                    info.MaxSupply = GameRules.DW.GetMaxSupply(playerId)
                    info.CurrentSupply = GameRules.DW.GetCurrentSupply(playerId)
                else
                    info.Life = 0
                    info.IsAlive = false
                end

                if(info.IsBot) then
                    local selectedHero = PlayerResource:GetSelectedHeroEntity(playerId)
                    if(selectedHero == nil) then
                        local player = PlayerResource:GetPlayer(playerId)
                        if player ~= nil then
                            local new_hero = CreateHeroForPlayer("npc_dota_hero_elf", player)
                            new_hero:SetControllableByPlayer(playerId, true)
                            local playerOrigin = GameRules.DW.GetPlayerOrigin(playerId)
                            if(playerOrigin ~= nil) then
                                local centerPosition = playerOrigin + Vector(560, 480)
                                FindClearSpaceForUnit(new_hero, centerPosition, true)
                            end
                            player:SetAssignedHeroEntity(new_hero)
                        end
                    end
                end
                
                table.insert(postData, {PlayerId = playerId, SteamId = info.SteamId,
                SteamAccountId = info.SteamAccountId, SteamName = info.PlayerName, IsBot = info.IsBot})
            else
                info.IsEmpty = true
                info.IsOnline = false
                info.IsBot = false
                info.Life = 0
            end
        end

        HttpPost("api/Member/GetPlayersInfo", postData, function(result)
            if(result.isSuccess and result.tag ~= nil) then
                -- ShowGolbalMessage("Ranking data has been loaded.")
                for _, v in pairs(result.tag) do
                    local playerInfo = GameRules.DW.PlayerList[v.PlayerId]
                    if(playerInfo ~= nil) then
                        playerInfo.Grade = v.Grade
                        playerInfo.IsVip = v.IsVip
                        if(v.Status == 0) then
                            playerInfo.Life = 0
                        end
                        playerInfo.HasArcana = v.HasArcana
                        playerInfo.SkinId = v.SkinId
                        playerInfo.IsFly = v.SkinParam == "fly"

                        DDW:InitSkin(playerInfo)
                    end
                end
            else
                ShowGolbalMessage(result.message)
            end
        end)
        
        GameRules.DW.LastRank = playerCount

        if(GameRules.DW.MapName == "dawn_war_coop") then
            if playerCount < 4 or playerCount % 2 ~= 0 then
                CreateTimer(function() ShowGolbalMessage('SORRY THE NUMBER OF PLAYERS DOES NOT MATCH THIS MODE.') end, 3)
                GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
            end
        end
    end
end

function DDW:FindEmptyTeamForPlayer(playerId)
    local assignTeam = PlayerResource:GetCustomTeamAssignment(playerId)
    if(table.containsKey(GameRules.DW.TeamColor, assignTeam)) then
        return assignTeam
    end
    
    local teamAssignedTable = {}
    for playerId, info in pairs(GameRules.DW.PlayerList) do
        local player = PlayerResource:GetPlayer(playerId)
        
        if(player ~= nil and player:IsNull() == false) then
            local teamId = player:GetTeam()
            if(table.containsKey(GameRules.DW.TeamColor, teamId)) then
                table.insert(teamAssignedTable, teamId)
            end
        end
    end
    
    for teamId = 6, 13 do
        if(table.contains(teamAssignedTable, teamId) == false) then
            return teamId
        end
    end
    
    return DOTA_TEAM_NOTEAM
end

function DDW:KeepUpdateGameSetting()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        local hostPlayer = nil
        for playerId, playerInfo in pairs(GameRules.DW.PlayerList) do
            local checkPlayer = PlayerResource:GetPlayer(playerId)
            if(checkPlayer ~= nil and checkPlayer:IsNull() == false and playerInfo.IsOnline == true) then
                if(GameRules.DW.MapName ~= "dawn_war_coop") then
                    if(table.containsKey(GameRules.DW.TeamColor, checkPlayer:GetTeam()) == false) then
                        local teamId = DDW:FindEmptyTeamForPlayer(playerId)
                        PlayerResource:SetCustomTeamAssignment(playerId, teamId)
                    end
                end
                
                playerInfo.TeamId = checkPlayer:GetTeam()
                
                if(GameRules:PlayerHasCustomGameHostPrivileges(checkPlayer)) then
                    hostPlayer = checkPlayer
                end
            end
        end
        
        local botCount = 0
        if(hostPlayer ~= nil) then
            for _, playerInfo in pairs(GameRules.DW.PlayerList) do
                if(playerInfo.IsBot == true) then
                    botCount = botCount + 1
                end
            end
            
            CustomGameEventManager:Send_ServerToPlayer(hostPlayer, "UPDATE_BOT_COUNT", {count = botCount})
        end
        
        if PlayerResource:GetPlayerCount() - botCount > 1 and GameRules:IsCheatMode() == true then
            CreateTimer(function() ShowGolbalMessage('SORRY DO NOT SUPPORTED CHEAT MODE FOR MUTIPLAYERS.') end, 3)
            GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
            return
        end
        
        CreateTimer(function() DDW:KeepUpdateGameSetting() end, 0.5)
    end
end

function DDW:OnAddBot(data)
    local hostPlayerId = data.PlayerID
    if GameRules:PlayerHasCustomGameHostPrivileges(PlayerResource:GetPlayer(hostPlayerId)) then
        GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 1)
        GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 1)
        local playerCount = PlayerResource:GetPlayerCount()
        if(playerCount >= 8) then
            return
        end
        
        local botPlayerId = playerCount
        
        local addSuccess = Tutorial:AddBot("", "", "", false)
        
        if(addSuccess ~= true) then
            return
        end
        
        local player = PlayerResource:GetPlayer(botPlayerId)
        if player ~= nil then
            if(GameRules.DW.MapName == "dawn_war_coop") then
                for i = 1, #AllTeamIdxCoop do
                    if(PlayerResource:GetPlayerCountForTeam(AllTeamIdx[i]) < 2) then
                        PlayerResource:SetCustomTeamAssignment(botPlayerId, AllTeamIdx[i])
                        
                        GameRules.DW.PlayerList[botPlayerId].IsEmpty = false
                        GameRules.DW.PlayerList[botPlayerId].PlayerName = tostring(PlayerResource:GetPlayerName(botPlayerId))
                        GameRules.DW.PlayerList[botPlayerId].IsOnline = true
                        GameRules.DW.PlayerList[botPlayerId].IsBot = true
                        GameRules.DW.PlayerList[botPlayerId].MaxSupply = GameRules.DW.GetMaxSupply(botPlayerId)
                        GameRules.DW.PlayerList[botPlayerId].CurrentSupply = GameRules.DW.GetCurrentSupply(botPlayerId)
                        
                        -- ShowPlayerMessage(GameRules.DW.PlayerList[botPlayerId].PlayerName .. " HAS JOINED THE GAME", player)
                        break
                    end
                end
            else
                for i = 1, #AllTeamIdx do
                    if(PlayerResource:GetPlayerCountForTeam(AllTeamIdx[i]) == 0) then
                        PlayerResource:SetCustomTeamAssignment(botPlayerId, AllTeamIdx[i])
                        
                        GameRules.DW.PlayerList[botPlayerId].IsEmpty = false
                        GameRules.DW.PlayerList[botPlayerId].PlayerName = tostring(PlayerResource:GetPlayerName(botPlayerId))
                        GameRules.DW.PlayerList[botPlayerId].IsOnline = true
                        GameRules.DW.PlayerList[botPlayerId].IsBot = true
                        GameRules.DW.PlayerList[botPlayerId].MaxSupply = GameRules.DW.GetMaxSupply(botPlayerId)
                        GameRules.DW.PlayerList[botPlayerId].CurrentSupply = GameRules.DW.GetCurrentSupply(botPlayerId)
                        
                        -- ShowPlayerMessage(GameRules.DW.PlayerList[botPlayerId].PlayerName .. " HAS JOINED THE GAME", player)
                        break
                    end
                end
            end
        end
        GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 0)
        GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
    end
end

function DDW:OnConnectFull(data)
    local playerId = data.PlayerID
    
    if PlayerResource:IsValidPlayer(playerId) then
        local playerInfo = GameRules.DW.PlayerList[playerId]
        if(playerInfo ~= nil) then
            playerInfo.SteamId = tostring(PlayerResource:GetSteamID(playerId))
            playerInfo.SteamAccountId = tostring(PlayerResource:GetSteamAccountID(playerId))
            playerInfo.PlayerName = tostring(PlayerResource:GetPlayerName(playerId))
            playerInfo.IsOnline = true
            playerInfo.DisconnectedRoundCount = 0
            playerInfo.IsBot = false
            playerInfo.IsEmpty = false
            
            if(playerInfo.TeamId ~= DOTA_TEAM_NOTEAM) then
                local isInBattle = false
                if(#GameRules.DW.Battles > 0 and GameRules.DW.StageName[GameRules.DW.Stage] == "FIGHTING") then
                    for battleSide = 1, 4 do
                        if(GameRules.DW.Battles[#GameRules.DW.Battles].Players[battleSide] == playerId) then
                            isInBattle = true
                            break
                        end
                    end
                end
                
                if(isInBattle == false) then
                    PlayerResource:SetCustomTeamAssignment(playerId, DOTA_TEAM_NOTEAM)
                    PlayerResource:SetCustomTeamAssignment(playerId, playerInfo.TeamId)

                    local currentGold = PlayerResource:GetGold(playerId)
                    if(currentGold ~= nil and currentGold < playerInfo.GoldBackup) then
                        PlayerResource:SetGold(playerId, playerInfo.GoldBackup, true)
                        PlayerResource:SetGold(playerId, 0, false)
                    end
                    
                    local panelHeros = GameRules.DW.RollPanelHero[playerId]
                    if(panelHeros ~= nil and #panelHeros > 0 and GameRules.DW.PlayerList[playerId].TeamId ~= DOTA_TEAM_NOTEAM) then
                        SendMessageToPlayer(playerId, "SHOW_ROLL_PANEL", {items = panelHeros, recycles = GameRules.DW.RecycleHero[playerId], isUpdate = false})
                    end
                end
            end
        end
    end
end

function DDW:OnDisconnect(data)
    local playerId = data.PlayerID
    if(playerId >= 0 and GameRules.DW.PlayerList[playerId] ~= nil) then
        GameRules.DW.PlayerList[playerId].IsOnline = false
    end
end

function DDW:InitSkin(playerInfo)
    if(playerInfo == nil or playerInfo.Hero == nil or playerInfo.Hero:IsNull()) then
        return
    end

    if(playerInfo.SkinInit == 1) then
        return
    end

    if(playerInfo.HasArcana == 1) then
        if(playerInfo.SkinId == "-1") then
            GameRules.Wearable:WearSkin(playerInfo.Hero, GameRules.DW.DefaultSkinId, playerInfo.IsFly)
        else
            GameRules.Wearable:WearSkin(playerInfo.Hero, playerInfo.SkinId, playerInfo.IsFly)
        end
    else
        GameRules.Wearable:WearSkin(playerInfo.Hero, GameRules.DW.DefaultSkinId, false)
    end
    playerInfo.SkinInit = 1
end

function DDW:OnThink()
    if IsClient() or GameRules.DW.IsGameOver then return nil end

    if GameRules.DW.Stage > 0 then
        local stageElapsed = GameRules:GetGameTime() - GameRules.DW.StageStartTime
        local stageCountdown = math.floor(GameRules.DW.StageTime[GameRules.DW.Stage] - stageElapsed)

        if(GameRules.DW.Stage == 1) then
            if(GameRules.DW.RoundNo == 1) then
                stageCountdown = stageCountdown + 10
            end
            if(GameRules.DW.EnterDuelRoundNo == GameRules.DW.RoundNo) then
                stageCountdown = stageCountdown + 20
            end
            if(GameRules.DW.ExtraCountdown > 0) then
                stageCountdown = stageCountdown + GameRules.DW.ExtraCountdown
            end
        end

        if(stageCountdown > 0 and stageCountdown < 4 and GameRules.LastTick ~= stageCountdown) then
            GameRules.LastTick = stageCountdown
            if(GameRules.DW.Stage == 1 or GameRules.DW.Stage == 4) then
                EmitGlobalSound(SoundRes.TIME_TICK)
            end
        end
        
        if(stageCountdown <= 0) then
            GameRules.DW.Stage = GameRules.DW.Stage + 1
            if(GameRules.DW.Stage > #GameRules.DW.StageTime) then GameRules.DW.Stage = 1 end
            GameRules.DW.StageStartTime = GameRules:GetGameTime()
            xpcall(function() DDW:OnStageChanged() collectgarbage("collect") end, ShowGolbalMessage)
        end
        
        local roundNoDisplay = GameRules.DW.RoundNo
        if(roundNoDisplay < 1) then roundNoDisplay = 1 end
        
        local stageInfo = {
            name = GameRules.DW.StageName[GameRules.DW.Stage],
            countdown = stageCountdown,
            roundNo = roundNoDisplay,
            leftHeroSupply = GameRules.DW.GetHeroListSupply(GameRules.DW.GoodGuys),
            rightHeroSupply = GameRules.DW.GetHeroListSupply(GameRules.DW.BadGuys)}
        
        CustomNetTables:SetTableValue("stage_table", "stage_info", stageInfo)
        
        local playerInfoTable = {}
        for playerId, playerInfo in pairs(GameRules.DW.PlayerList) do
            if(playerInfo.Hero ~= nil and playerInfo.Hero:IsNull() == false) then
                if(PlayerResource:GetConnectionState(playerId) == DOTA_CONNECTION_STATE_ABANDONED) then
                    PlayerResource:SetGold(playerId, 0, true)
                    PlayerResource:SetGold(playerId, 0, false)
                end

                if(GameRules:IsGamePaused() == false) then
                    if(PlayerResource:GetConnectionState(playerId) ~= DOTA_CONNECTION_STATE_ABANDONED) then
                        PlayerResource:ModifyGold(playerId, 2, false, DOTA_ModifyGold_GameTick)
                    end
                end

                if(playerInfo.SkinInit ~= 1) then
                    DDW:InitSkin(playerInfo)
                end

                local playerOrigin = GameRules.DW.GetPlayerOrigin(playerId)
                if(playerOrigin ~= nil) then
                    local heroPosition = playerInfo.Hero:GetAbsOrigin()
                    local centerPosition = playerOrigin + Vector(560, 480)
                    local areaSize = 1000
                    if(heroPosition.x > centerPosition.x + areaSize or heroPosition.x < centerPosition.x - areaSize or heroPosition.y > centerPosition.y + areaSize or heroPosition.y < centerPosition.y - areaSize) then
                        FindClearSpaceForUnit(playerInfo.Hero, centerPosition, true)
                        SendMessageToPlayer(playerId, "CAMERA_FOLLOW", {location = centerPosition})
                    end
                end
            end

            local battleBeginTime = GameRules:GetGameTime() - GameRules.DW.StageStartTime
            local isBattleBegin = GameRules.DW.Stage == 3 and battleBeginTime > 3 and battleBeginTime < 5
            local standFor = ""
            if(#GameRules.DW.Battles > 0) then
                for battleSide = 1, 4 do
                    if(GameRules.DW.Battles[#GameRules.DW.Battles].Players[battleSide] == playerId) then
                        if(battleSide == 1 or battleSide == 2) then
                            standFor = "radiant"
                            if(playerInfo.BattleSupplyDiff < 0 and isBattleBegin) then
                                if(stageInfo.leftHeroSupply > stageInfo.rightHeroSupply) then
                                    playerInfo.BattleSupplyDiff = stageInfo.leftHeroSupply - stageInfo.rightHeroSupply
                                else
                                    playerInfo.BattleSupplyDiff = 0
                                end
                            end
                        else
                            standFor = "dire"
                            if(playerInfo.BattleSupplyDiff < 0 and isBattleBegin) then
                                if(stageInfo.leftHeroSupply < stageInfo.rightHeroSupply) then
                                    playerInfo.BattleSupplyDiff = stageInfo.rightHeroSupply - stageInfo.leftHeroSupply
                                else
                                    playerInfo.BattleSupplyDiff = 0
                                end
                            end
                        end
                    end
                end
            end

            if(standFor ~= "" and playerInfo.Hero ~= nil and playerInfo.Hero:IsNull() == false) then
                for slotIndex = 0, 16 do
                    local item = playerInfo.Hero:GetItemInSlot(slotIndex)
                    if item ~= nil then
                        local itemName = item:GetName()
                        if(itemName == "item_bloodstone") then
                            if(item.SavedCharges == nil) then
                                item.SavedCharges = item:GetCurrentCharges()
                            end
                            if(item:GetCurrentCharges() > item.SavedCharges) then
                                item:SetCurrentCharges(item.SavedCharges)
                            end
                        end
                    end
                end
            end
            
            local currentGold = PlayerResource:GetGold(playerId)
            if(currentGold ~= nil and currentGold > 500) then
                if(playerInfo.IsOnline == true) then
                    playerInfo.GoldBackup = currentGold
                else
                    if(playerInfo.GoldBackup < currentGold) then
                        playerInfo.GoldBackup = currentGold
                    end
                end
            end

            if(currentGold == nil) then
                currentGold = playerInfo.GoldBackup
            end

            local controlledHeroId = -1
            if(playerInfo.ControlledHero ~= nil and playerInfo.ControlledHero:IsNull() == false) then
                controlledHeroId = playerInfo.ControlledHero:GetEntityIndex()
            else
                playerInfo.ControlledHero = nil
            end

            local hasDieProtect = 0
            if(playerInfo.UsedDieProtect == false) then
                if(GameRules.DW.CheckHasTalent(playerInfo.Hero, "special_bonus_elf_20_1") == true) then
                    hasDieProtect = 1
                end
            end

            local originPosition = GameRules.DW.GetPlayerOrigin(playerId)
            if(originPosition ~= nil) then
                originPosition = originPosition + Vector(560, 480)
            end

            local kills = PlayerResource:GetKills(playerId)
            local assists = PlayerResource:GetAssists(playerId)
            if(kills ~= nil) then playerInfo.Kills = kills end
            if(assists ~= nil) then playerInfo.Assists = assists end

            local tableData = {
                playerId = playerId,
                playerName = playerInfo.PlayerName,
                steamId = playerInfo.SteamId,
                teamId = playerInfo.TeamId,
                originPosition = originPosition,
                color = GameRules.DW.TeamColor[playerInfo.TeamId],
                maxSupply = playerInfo.MaxSupply,
                currentSupply = playerInfo.CurrentSupply,
                isOnline = playerInfo.IsOnline,
                isBot = playerInfo.IsBot,
                gold = currentGold,
                life = playerInfo.Life,
                rank = playerInfo.Rank,
                standFor = standFor,
                isEmpty = playerInfo.IsEmpty,
                conDefeatCount = playerInfo.ConDefeatCount,
                grade = playerInfo.Grade,
                isVip = playerInfo.IsVip,
                readyState = playerInfo.ReadyState,
                controlledHeroId = controlledHeroId,
                hasDieProtect = hasDieProtect,
                kills = playerInfo.Kills,
                assists = playerInfo.Assists,
                battleCount = playerInfo.BattleCount,
                selectedBattlePosition = playerInfo.SelectedBattlePosition
            }
            table.insert(playerInfoTable, tableData)
        end
        
        if(GameRules.DW.MapName == "dawn_war_coop") then
            table.sort(playerInfoTable, function(a, b) 
                return (8 - a.rank) * 2000 + a.life * 10 + a.teamId > (8 - b.rank) * 2000 + b.life * 10 + b.teamId 
            end)
        else
            table.sort(playerInfoTable, function(a, b)
                if a.rank ~= b.rank then
                    return 8 - a.rank > 8 - b.rank
                end
                if a.life ~= b.life then
                    return a.life > b.life
                end
                if a.kills ~= b.kills then
                    return a.kills > b.kills
                end
                if a.assists ~= b.assists then
                    return a.assists > b.assists
                end
                return a.playerId < b.playerId
            end)
        end
        
        CustomNetTables:SetTableValue("player_info_table", "playerInfo", playerInfoTable)
        
        if(GameRules:IsGamePaused()) then
            return 1
        end

        local heroes = HeroList:GetAllHeroes()
        for _, hero in pairs (heroes) do
            if hero ~= nil and hero:IsNull() == false then
                if hero:IsIllusion() then
                    if(GameRules.DW.StageName[GameRules.DW.Stage] == "FIGHTING") then
                        if(hero:HasModifier("modifier_hero_command_restricted") == false) then
                            hero:AddNewModifier(hero, nil, "modifier_hero_command_restricted", {})
                        end
                        if(hero:IsIdle() and hero:AttackReady() and hero:IsAttacking() == false) then
                            local closestEnemy = HeroAI:ClosestEnemyAll(hero, hero:GetTeamNumber())
                            if(closestEnemy ~= nil) then
                                hero:MoveToPositionAggressive(closestEnemy:GetAbsOrigin())
                            end
                        end
                    else
                        hero:ForceKill(false)
                    end
                else
                    local playerInfo = GameRules.DW.PlayerList[hero:GetPlayerOwnerID()]
                    if(playerInfo ~= nil and GameRules.DW.StageName[GameRules.DW.Stage] == "FIGHTING") then
                        if(hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS or hero:GetTeamNumber() == DOTA_TEAM_BADGUYS) then
                            if(playerInfo.ControlledHero == hero) then
                                hero.IsManuallyControlled = true
                                local currentPos = hero:GetAbsOrigin()
                                local newPos = Vector(currentPos.x, currentPos.y, currentPos.z)
                                if(currentPos.x > 5600) then
                                    newPos.x = 5600
                                end

                                if(currentPos.x < -5600) then
                                    newPos.x = -5600
                                end

                                if(currentPos.y > 3600) then
                                    newPos.y = 3600
                                end

                                if(currentPos.y < 2050) then
                                    newPos.y = 2050
                                end

                                if(currentPos ~= newPos) then
                                    FindClearSpaceForUnit(hero, newPos, true)
                                end
                            else
                                if(GameRules.DW.StageTime[GameRules.DW.Stage] - GameRules:GetGameTime() + GameRules.DW.StageStartTime > 5) then
                                    if(hero.HasModifier ~= nil and hero:HasModifier("modifier_hero_waitting") == false) then
                                        if(hero:IsAlive() and hero.LastThinkTime ~= nil and hero.LastThinkTime < GameRules:GetGameTime() - 2) then
                                            hero.LastThinkTime = GameRules:GetGameTime()
                                            hero:SetContextThink("OnHeroThink", function() return HeroAI:OnHeroThink(hero) end, 1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    if(hero:HasModifier("modifier_hero_waitting") and hero:GetAbilityPoints() <= 0 and hero:IsControllableByAnyPlayer()) then
                        hero:SetControllableByPlayer(-1, true)
                    end

                    if hero:GetAbsOrigin().y > 1400 and hero.sourcePos ~= nil then
                        if(GameRules.DW.StageName[GameRules.DW.Stage] == "PREPARE") then
                            if(hero:HasModifier("modifier_hero_waitting") == false) then
                                local waittingModifier = hero:AddNewModifier(hero, nil, "modifier_hero_waitting", {})
                                if(waittingModifier ~= nil and hero.price ~= nil) then
                                    waittingModifier:SetStackCount(hero.price)
                                end
                            end

                            hero:Hold()
                            hero:SetHealth(hero:GetMaxHealth())
                            hero:SetMana(hero:GetMaxMana())
                            hero:Purge(true, true, false, true, true)
                            hero:SetForwardVector(Vector(0, 1, 0))
                            FindClearSpaceForUnit(hero, hero.sourcePos, true)
                        end
                    end

                    if(hero.HasScepter ~= nil and hero:HasScepter()) then
                        if(hero:HasModifier("modifier_monkey_king_tree_dance_activity") or hero:HasModifier("modifier_monkey_king_tree_dance_hidden")) then
                            hero:SetHealth(hero:GetMaxHealth())
                            hero:SetMana(hero:GetMaxMana())
                            hero:Purge(false, true, false, true, true)
                        end

                        if(hero:GetName() == "npc_dota_hero_slark" and hero:HasModifier("modifier_slark_shadow_dance")) then
                            local shadowDanceModifer = hero:FindModifierByName("modifier_slark_shadow_dance")
                            if(shadowDanceModifer ~= nil) then
                                local castTarget = HeroAI:GetShadowDanceTarget(hero)
                                if(castTarget ~= nil and castTarget:HasModifier("modifier_slark_shadow_dance") == false) then
                                    castTarget:AddNewModifier(hero, nil, "modifier_slark_shadow_dance", {duration = 3.0})
                                end
                            end
                        end
                    end

                    if(hero:HasModifier("modifier_meepo_earthbind") and hero:HasModifier("modifier_silence") == false) then
                        local earthbindModifier = hero:FindModifierByName("modifier_meepo_earthbind")
                        if(earthbindModifier ~= nil) then
                            if(GameRules.DW.CheckHasTalent(earthbindModifier:GetCaster(), "special_bonus_meepo_earthbind_upgrade")) then
                                hero:AddNewModifier(hero, nil, "modifier_silence", {duration = 2.0})
                            end
                        end 
                    end
                end
            end
        end
        
        for _, unit in pairs(GameRules.DW.BattleUnitList) do
            if(unit ~= nil and unit:IsNull() == false and unit:IsAlive() and unit:AttackReady() and unit:IsAttacking() == false and unit:IsDisarmed() == false) then
                local closestEnemy = UnitAI:ClosestEnemyAll(unit, unit:GetTeamNumber())
                if(closestEnemy ~= nil) then
                    unit:MoveToPositionAggressive(closestEnemy:GetAbsOrigin())
                end
            end
        end
    end
    
    return 1
end

function DDW:OnPickHero(data)
    if not IsServer() then return end

    if(data.player == nil or data.heroindex == nil) then
        return
    end

    local player = EntIndexToHScript(data.player)
    if(player == nil or player.GetPlayerID == nil) then
        return
    end
    
    local playerId = player:GetPlayerID()
    local hero = EntIndexToHScript(data.heroindex)
    if(hero == nil or hero:IsNull()) then
        return
    end

    if(hero.GetItemInSlot ~= nil) then
        local tpItem = hero:GetItemInSlot(15)
        if tpItem ~= nil and tpItem:IsNull() == false then
            hero:RemoveItem(tpItem)
        end
    end
    
    hero:SetForwardVector(Vector(0, 1, 0))
    hero:SetDeathXP(0)

    if hero:GetUnitName() == "npc_dota_hero_elf" then
        hero:SetAbilityPoints(0)
        local playerInfo = GameRules.DW.PlayerList[playerId]
        if(playerInfo ~= nil) then
            if(playerInfo.Life <= 0) then
                hero:ForceKill(false)
            end
            
            playerInfo.Hero = hero

            local loadedPlayerCount = 0
            for _, v in pairs(GameRules.DW.PlayerList) do
                if v.Hero ~= nil then
                    loadedPlayerCount = loadedPlayerCount + 1
                end
            end

            if(loadedPlayerCount == PlayerResource:GetPlayerCount()) then
                CreateTimer(function() DDW:InitGameStart() end, 1)
            end
        end
    else
        if(hero:HasModifier("modifier_hero_command_restricted") == false) then
            hero:AddNewModifier(hero, nil, "modifier_hero_command_restricted", {})
        end

        local waittingModifier = hero:FindModifierByName("modifier_hero_waitting")
        if(waittingModifier == nil) then
            waittingModifier = hero:AddNewModifier(hero, nil, "modifier_hero_waitting", {})
        end

        if(waittingModifier ~= nil and hero.price ~= nil) then
            waittingModifier:SetStackCount(hero.price)
        end

        if(hero:GetName() == "npc_dota_hero_spectre" or hero:GetName() == "npc_dota_hero_alchemist") then
            if(hero:HasModifier("modifier_item_ultimate_scepter_consumed") == false) then
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
            end
        end
        GameRules.DW.InitHeroTalent(hero)
    end
end

function DDW:InitGameStart()
    for playerId, info in pairs(GameRules.DW.PlayerList) do
        local hero = info.Hero
        if (hero ~= nil and hero:IsNull() == false and GameRules.DW.PlayerList[playerId].Life > 0) then
            SetAbility(hero, "ability_hero_move", false)
            SetAbility(hero, "ability_item_retrieve", false)
            SetAbility(hero, "ability_hero_sell", false)
            SetAbility(hero, "ability_hero_roll", false)
            SetAbility(hero, "ability_level_up", false)
            SetAbility(hero, "ability_hero_ability_refresh", false)
            SetAbility(hero, "ability_operator")
            hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})

            if(info.SkinInit ~= 1) then
                DDW:InitSkin(info)
            end

            if(info.IsBot) then
                hero:SetContextThink("OnBotThink", function() return BotAI:OnBotThink(hero) end, 1)
            else
                local dummyUnit = CreateUnitByName("npc_dummy_unit", hero:GetAbsOrigin(), false, hero, hero, info.TeamId)
                dummyUnit:AddItemByName("item_gem")    
            end
        end
    end

    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 2)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 2)
    
    local playerCount = 0
    local botCount = 0
    local totalGrade = 0
    for playerId, info in pairs(GameRules.DW.PlayerList) do
        if(info.IsEmpty == false) then
            if(info.IsBot) then
                botCount = botCount + 1
            else
                totalGrade = totalGrade + info.Grade
                playerCount = playerCount + 1
            end
        end
    end
    
    local averageGrade = math.floor(totalGrade / playerCount)
    if(averageGrade < 1) then averageGrade = 1 end
    
    local postData = {PlayerCount = playerCount, BotCount = botCount, AverageGrade = averageGrade, MapName = GameRules.DW.MapName}
    HttpPost("api/Game/GameStart", postData, function(result)
        if(result.isSuccess) then
            -- ShowGolbalMessage("Game data uploaded.")
            GameRules.DW.GameId = result.tag
        else
            ShowGolbalMessage(result.message)
        end
    end)
    
    GameRules.DW.Stage = #GameRules.DW.StageTime
    GameRules.DW.StageStartTime = GameRules:GetGameTime()
    GameRules.DW.GameStartTime = GameRules:GetGameTime()
    
    GameRules.LastTick = 0
    GameRules:GetGameModeEntity():SetThink("OnThink", self, 0)
end

function DDW:OnPlayerGainedLevel(event)
    local playerId = event.player_id
    local playerInfo = GameRules.DW.PlayerList[playerId]
    if(playerInfo ~= nil) then
        if(playerInfo.Hero ~= nil and playerInfo.Hero:IsNull() == false) then
            local abLvlUp = playerInfo.Hero:FindAbilityByName("ability_level_up")
            if(abLvlUp ~= nil and abLvlUp:IsHidden() == false) then
                SetAbility(playerInfo.Hero, "ability_level_up", true, playerInfo.Hero:GetLevel())
            end

            if(GameRules.DW.MapName == "dawn_war_coop") then
                local partnerId = GameRules.DW.GetCoopPartnerId(playerId)
                if(partnerId ~= nil) then
                    if(playerInfo.Hero:GetLevel() == 20) then
                        GameRules.DW.SyncTalentWithPartner(partnerId, "special_bonus_elf_20_1", "special_bonus_elf_20_2", 20, true)
                    end

                    if(playerInfo.Hero:GetLevel() == 10) then
                        GameRules.DW.SyncTalentWithPartner(partnerId, "special_bonus_elf_10_1", "special_bonus_elf_10_2", 10, false)
                    end
                end
            end
        end
    end
end

function DDW:OnBuyHeroRequest(data)
    local playerId = data.PlayerID
    local index = tonumber(data.index)
    local fromRecycle = data.fromRecycle

    if(GameRules:IsGamePaused()) then
        SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "GAME_PAUSED"})
        return
    end

    GameRules.DW.BuyHeroRequest(playerId, index, fromRecycle)
end

function DDW:OnDeleteHeroRequest(data)
    local playerId = data.PlayerID
    local index = tonumber(data.index)

    if(GameRules:IsGamePaused()) then
        SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "GAME_PAUSED"})
        return
    end

    GameRules.DW.DeleteHeroFromRecycleBin(playerId, index)
end

function DDW:OnChangeHeroPool(data)
    local playerId = data.PlayerID
    local heroName = data.hero_name
    local language = data.language
    local actionType = data.action
    
    local playerInfo = GameRules.DW.PlayerList[playerId]
    if(playerInfo == nil) then
        return
    end

    local dotaTime = GameRules:GetDOTATime(false, false)
    if(dotaTime < 0 or dotaTime > 90) then
        SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
        return
    end
    
    if(actionType == "disable_hero") then
        local selectedHero = table.find(GameRules.DW.RandomDraftHeros, "name", heroName)
        if(selectedHero == nil) then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "NOT_EXIST_IN_HERO_POOL"})
            return
        end
        
        if(table.findcount(GameRules.DW.RandomDraftHeros, "valid", 1) <= 28) then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "TOO_MANY_BAN_HEROS"})
            return
        end
        
        if(selectedHero.valid == 0) then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "THIS_HERO_HAS_ALREADY_BANNED"})
            return
        end
        
        if(selectedHero.price > 10) then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "TOO_LATE_TO_BAN_THIS_HERO"})
            return
        end
        
        local postData = {ActionType = "DisableHero", SteamAccountId = playerInfo.SteamAccountId, HeroName = selectedHero.name, GameId = GameRules.DW.GameId}
        HttpPost("api/Game/ChangeHeroPool", postData, function(result)
            if(result.isSuccess) then
                selectedHero.valid = 0
                DDW:UpdateHeroPoolDisplay()

                local localizedHeroName = LocalizeHero(heroName, language)
                if(language ~= nil and string.lower(language) == "schinese") then
                    ShowGolbalMessage(localizedHeroName .. " 已禁用.")
                else
                    ShowGolbalMessage(localizedHeroName .. " has been disabled.")
                end

                ShowHeroMessage(playerInfo.SteamId, HeroNamePrefix .. heroName, "HERO_MESSAGE_BANNED_HERO")
            else
                SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = result.message})
            end
        end)
    end
    
    if(actionType == "enable_hero") then
        local selectedHero = table.find(GameRules.DW.RandomDraftHeros, "name", heroName)
        if(selectedHero == nil) then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "NOT_EXIST_IN_HERO_POOL"})
            return
        end
        
        if(selectedHero.valid == 1) then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "THIS_HERO_HAS_ALREADY_ENABLED"})
            return
        end
        
        local postData = {ActionType = "EnableHero", SteamAccountId = playerInfo.SteamAccountId, HeroName = selectedHero.name, GameId = GameRules.DW.GameId}
        HttpPost("api/Game/ChangeHeroPool", postData, function(result)
            if(result.isSuccess) then
                PrecacheUnitByNameAsync(HeroNamePrefix .. heroName, function(...) end)
                selectedHero.valid = 1
                DDW:UpdateHeroPoolDisplay()

                local localizedHeroName = LocalizeHero(heroName, language)
                if(language ~= nil and string.lower(language) == "schinese") then
                    ShowGolbalMessage(localizedHeroName .. " 已启用.")
                else
                    ShowGolbalMessage(localizedHeroName .. " has been enabled.")
                end

                ShowHeroMessage(playerInfo.SteamId, HeroNamePrefix .. heroName, "HERO_MESSAGE_ENABLED_HERO")
            else
                SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = result.message})
            end
        end)
    end
end

function DDW:OnMarkHero(data)
    local playerId = data.PlayerID
    local heroName = data.hero_name
  
    local playerInfo = GameRules.DW.PlayerList[playerId]
    if(playerInfo == nil) then
        return
    end

    if(playerInfo.IsVip ~= 1) then
        SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "VIP_ONLY"})
        return
    end
    
    local selectedHero = table.find(GameRules.DW.RandomDraftHeros, "name", heroName)
    if(selectedHero == nil) then
        SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "NOT_EXIST_IN_HERO_POOL"})
        return
    end

    if(table.exist(playerInfo.MarkedHeroes, heroName)) then
        table.remove_value(playerInfo.MarkedHeroes, heroName)
    else
        table.insert(playerInfo.MarkedHeroes, heroName)
    end

    DDW:UpdateHeroPoolDisplay()
end

function DDW:OnCouponRedeem(data)
    local cardNo = data.card_no
    local playerInfo = GameRules.DW.PlayerList[data.PlayerID]
    if(playerInfo ~= nil) then
        if(#cardNo ~= 19) then
            SendMessageToPlayer(data.PlayerID, "SHOW_PROMPT", {message = "CARD_NO_INCORRECT"})
        end
        local postData = {SteamAccountId = playerInfo.SteamAccountId, CardNo = cardNo}
        HttpPost("api/Member/CouponRedeem", postData, function(result)
            if(result.isSuccess) then
                if(result.tag.amount > 100) then
                    playerInfo.IsVip = 1
                end
                SendMessageToPlayer(data.PlayerID, "COUPON_REDEEM_RESPONSE", {data = result.tag})
            else
                SendMessageToPlayer(data.PlayerID, "SHOW_PROMPT", {message = result.message})
            end
        end)
    end
end

function DDW:OnCoinInfoRequest(data)
    local playerInfo = GameRules.DW.PlayerList[data.PlayerID]
    if(playerInfo ~= nil and GameRules.DW.GameId ~= "") then
        local postData = {SteamAccountId = playerInfo.SteamAccountId, GameId = GameRules.DW.GameId}
        HttpPost("api/Member/GetCoinInfo", postData, function(result)
            if(result.isSuccess) then
                result.tag.skinId = playerInfo.SkinId
                if(playerInfo.IsFly) then
                    result.tag.isFly = 1
                else
                    result.tag.isFly = 0    
                end
                if(result.tag.vipTime ~= "Expired") then
                    playerInfo.IsVip = 1
                else
                    playerInfo.IsVip = 0
                end
                SendMessageToPlayer(data.PlayerID, "COIN_INFO_RESPONSE", {data = result.tag})
            else
                SendMessageToPlayer(data.PlayerID, "SHOW_PROMPT", {message = result.message})
            end
        end)
    end
end

function DDW:OnBuyArcana(data)
    local playerInfo = GameRules.DW.PlayerList[data.PlayerID]
    if(playerInfo ~= nil and GameRules.DW.GameId ~= "") then
        if(playerInfo.HasArcana == 1) then
            SendMessageToPlayer(data.PlayerID, "SHOW_PROMPT", {message = "ALREADY_HAVE_THIS_ARCANA"})
            return
        end

        if(playerInfo.Hero == nil or playerInfo.Hero:IsNull()) then
            return
        end

        local postData = {SteamAccountId = playerInfo.SteamAccountId, GameId = GameRules.DW.GameId}
        HttpPost("api/Member/BuyArcana", postData, function(result)
            if(result.isSuccess) then
                SendMessageToPlayer(data.PlayerID, "COIN_INFO_RESPONSE", {data = result.tag})
                playerInfo.HasArcana = 1
                playerInfo.SkinId = DDW:GetSafeSkinId(result.tag.skinId)
                playerInfo.IsFly = result.tag.isFly == 1
                playerInfo.SkinInit = 0
            else
                SendMessageToPlayer(data.PlayerID, "SHOW_PROMPT", {message = result.message})
            end
        end)
    end
end

function DDW:OnBuyVip(data)
    local playerInfo = GameRules.DW.PlayerList[data.PlayerID]
    if(playerInfo ~= nil and GameRules.DW.GameId ~= "") then
        if(playerInfo.Hero == nil or playerInfo.Hero:IsNull()) then
            return
        end

        local postData = {SteamAccountId = playerInfo.SteamAccountId, GameId = GameRules.DW.GameId}
        HttpPost("api/Member/BuyVip", postData, function(result)
            if(result.isSuccess) then
                result.tag.skinId = playerInfo.SkinId
                if(playerInfo.IsFly) then
                    result.tag.isFly = 1
                else
                    result.tag.isFly = 0    
                end
                if(result.tag.vipTime ~= "Expired") then
                    playerInfo.IsVip = 1
                else
                    playerInfo.IsVip = 0
                end
                SendMessageToPlayer(data.PlayerID, "COIN_INFO_RESPONSE", {data = result.tag})
            else
                SendMessageToPlayer(data.PlayerID, "SHOW_PROMPT", {message = result.message})
            end
        end)
    end
end

SkinIdList = {
    [1] = "12147",
    [2] = "10167",
    [3] = "10314",
    [4] = "11522",
    [5] = "10758",
    [6] = "13481",
    [7] = "11140",
    [8] = "10837",
    [9] = "10833",
    [10] = "10374",
    [11] = "11368",
    [12] = "10347",
    [13] = "13680",
    [14] = "11997",
    [15] = "12451",
    [16] = "12007",
    [17] = "7385",
}

function DDW:GetSafeSkinId(requestSkinId)
    requestSkinId = tostring(requestSkinId)
    if(table.contains(SkinIdList, requestSkinId) == false) then
        requestSkinId = "-1"
    end
    return requestSkinId
end

function DDW:OnChangeSkin(data)
    local playerInfo = GameRules.DW.PlayerList[data.PlayerID]
    if(playerInfo ~= nil and GameRules.DW.GameId ~= "") then
        if(playerInfo.HasArcana ~= 1) then
            SendMessageToPlayer(data.PlayerID, "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
            return
        end

        if(playerInfo.Hero == nil or playerInfo.Hero:IsNull()) then
            return
        end

        local safeSkinId = DDW:GetSafeSkinId(data.skinId)

        local postData = {SteamAccountId = playerInfo.SteamAccountId, GameId = GameRules.DW.GameId, IsFly = 0, SkinId = safeSkinId}
        HttpPost("api/Member/SaveSkinSetting", postData, function(result)
            if(result.isSuccess) then
                GameRules.Wearable:RemoveSkin(playerInfo.Hero)
                playerInfo.SkinId = safeSkinId
                playerInfo.IsFly = false
                playerInfo.SkinInit = 0
            else
                GameRules.Wearable:RemoveSkin(playerInfo.Hero)
                SendMessageToPlayer(data.PlayerID, "SHOW_PROMPT", {message = result.message})
            end
        end)
    end
end

function DDW:OnToggleSkin(data)
    local playerInfo = GameRules.DW.PlayerList[data.PlayerID]
    if(playerInfo ~= nil and GameRules.DW.GameId ~= "") then
        if(playerInfo.HasArcana ~= 1) then
            SendMessageToPlayer(data.PlayerID, "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
            return
        end

        if(playerInfo.Hero == nil or playerInfo.Hero:IsNull()) then
            return
        end

        local safeSkinId = DDW:GetSafeSkinId(data.skinId)
        local isFly = 0

        if(playerInfo.Hero:HasModifier("modifier_hero_fly")) then
            isFly = 0
        else
            isFly = 1
        end

        local postData = {SteamAccountId = playerInfo.SteamAccountId, GameId = GameRules.DW.GameId, IsFly = isFly, SkinId = safeSkinId}
        HttpPost("api/Member/SaveSkinSetting", postData, function(result)
            if(result.isSuccess) then
                GameRules.Wearable:RemoveSkin(playerInfo.Hero)
                playerInfo.SkinId = safeSkinId
                playerInfo.IsFly = isFly == 1
                playerInfo.SkinInit = 0
            else
                SendMessageToPlayer(data.PlayerID, "SHOW_PROMPT", {message = result.message})
            end
        end)
    end
end

function DDW:OnSetLockRoll(data)
    local playerId = data.PlayerID
    local lock = data.lock
    
    if(GameRules.DW.PlayerList[playerId] ~= nil) then
        GameRules.DW.PlayerList[playerId].LockRoll = lock
    end
end

function DDW:OnSetReadyForFight(data)
    if(GameRules.DW.StageName[GameRules.DW.Stage] ~= "PREPARE") then
        return
    end

    local stageTime = GameRules.DW.StageTime[GameRules.DW.Stage]

    if(GameRules.DW.Stage == 1) then
        if(GameRules.DW.RoundNo == 1) then
            stageTime = stageTime + 10
        end
        if(GameRules.DW.EnterDuelRoundNo == GameRules.DW.RoundNo) then
            stageTime = stageTime + 20
        end
        if(GameRules.DW.ExtraCountdown > 0) then
            stageTime = stageTime + GameRules.DW.ExtraCountdown
        end
    end
    
    if(GameRules:GetGameTime() - GameRules.DW.StageStartTime + 1 > stageTime) then
        return
    end
    
    local playerId = data.PlayerID

    if(GameRules:IsGamePaused()) then
        SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "GAME_PAUSED"})
        return
    end
    
    local ready = data.ready
    local playerInfo = GameRules.DW.PlayerList[playerId]
    if(ready == 1 and playerInfo ~= nil) then
        if(playerInfo.ReadyState ~= 1) then
            SendMessageToPlayer(data.PlayerID, "SHOW_PROMPT", {message = "ALREADY_SET_READY"})
            return
        end
        
        local readyCount = 0
        local fightPlayerCount = 0
        playerInfo.ReadyState = 2
        
        for _, p in pairs(GameRules.DW.PlayerList) do
            if(p.ReadyState == 2) then
                readyCount = readyCount + 1
            end
            if(p.ReadyState > 0) then
                fightPlayerCount = fightPlayerCount + 1
            end
            
            if(p.IsBot == true and p.ReadyState == 1) then
                p.ReadyState = 2
                readyCount = readyCount + 1
            end
        end
        
        if(readyCount == fightPlayerCount and GameRules:GetGameTime() - stageTime + 4 < GameRules.DW.StageStartTime) then
            GameRules.DW.StageStartTime = GameRules:GetGameTime() - stageTime + 4
        end

        local addGold = 50 * (5 - readyCount)
        PlayerResource:ModifyGold(playerId, addGold, false, DOTA_ModifyGold_Unspecified)
        
        if(playerInfo.Hero ~= nil and playerInfo.Hero:IsNull() == false) then
            EmitSoundOn(SoundRes.READY_FOR_FIGHT, playerInfo.Hero)
            local player = playerInfo.Hero:GetPlayerOwner()
            if(player ~= nil and player:IsNull() == false) then
                SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, playerInfo.Hero, addGold, nil)
            end
        end
    end
end

function DDW:OnGetRanking(data)
    local playerId = data.PlayerID
    if(playerId ~= nil) then
        local postData = {SteamId = tostring(PlayerResource:GetSteamID(playerId))}
        HttpPost("api/Member/GetTopPlayers", postData, function(result)
            if(result.isSuccess) then
                SendMessageToPlayer(data.PlayerID, "SHOW_RANKING", result.tag)
            end
        end)
    end
end

function DDW:SetOperatorEnabled(hero, enabled)
    if(hero ~= nil and hero:IsNull() == false and hero:FindAbilityByName("ability_hero_move") ~= nil) then
        hero:FindAbilityByName("ability_hero_move"):SetActivated(enabled)
        if(enabled) then
            hero:FindAbilityByName("ability_item_retrieve"):SetActivated(enabled)
        end
        hero:FindAbilityByName("ability_hero_sell"):SetActivated(enabled)
        hero:FindAbilityByName("ability_hero_roll"):SetActivated(enabled)

        local abLvlUp = hero:FindAbilityByName("ability_level_up")
        if(abLvlUp ~= nil) then
            hero:FindAbilityByName("ability_level_up"):SetActivated(enabled)
        end

        hero:FindAbilityByName("ability_hero_ability_refresh"):SetActivated(enabled)

        local abControl = hero:FindAbilityByName("ability_hero_control")
        if(abControl ~= nil) then
            hero:FindAbilityByName("ability_hero_control"):SetActivated(enabled)
        end
    end
end

function DDW:OnStageChanged()
    if(GameRules.DW.StageName[GameRules.DW.Stage] == "PREPARE") then
        GameRules.DW.ExtraCountdown = 0
        GameRules.DW.RoundNo = GameRules.DW.RoundNo + 1
        
        if(#GameRules.DW.Battles > 0) then
            for battleSide = 1, 4 do
                GameRules.DW.Battles[#GameRules.DW.Battles].Players[battleSide] = nil
            end
        end
        
        EmitGlobalSound(SoundRes.STAGE_PREPARE)
        
        CreateTimer(function() EmitGlobalSound(SoundRes.COIN_BIG) end, 0.3)
        
        local playerAliveAcount = 0
        for playerId, playerInfo in pairs(GameRules.DW.PlayerList) do
            playerInfo.ReadyState = 0
            if(playerInfo.Hero ~= nil and playerInfo.Hero:IsNull() == false and playerInfo.Life > 0) then
                playerAliveAcount = playerAliveAcount + 1
            end
        end

        if(playerAliveAcount <= 4 and GameRules.DW.IsDuelStage ~= true) then
            GameRules.DW.EnterDuelRoundNo = GameRules.DW.RoundNo
            GameRules.DW.IsDuelStage = true
        end
        
        table.clear(GameRules.DW.BattlePlayers)

        if(GameRules.DW.MapName == "dawn_war_coop") then
            GameRules.DW.BattlePlayers = GameRules.DW.GetNextBattlePlayerListCoop()
        else
            GameRules.DW.BattlePlayers = GameRules.DW.GetNextBattlePlayerList()
        end
        
        for i = #GameRules.DW.BattlePlayers, 1, -1 do
            local playerId = GameRules.DW.BattlePlayers[i]
            local playerInfo = GameRules.DW.PlayerList[playerId]
            if(playerInfo ~= nil) then
                playerInfo.ReadyState = 1
                if(playerAliveAcount > 7 and GameRules.DW.RoundNo % 2 == 0) then
                    DDW:OnSetReadyForFight({PlayerID = playerId, ready = 1})
                end
            end
        end
        
        for playerId, playerInfo in pairs(GameRules.DW.PlayerList) do
            if(playerInfo.Hero ~= nil and playerInfo.Hero:IsNull() == false and playerInfo.Life > 0) then
                GameRules.DW.UpdatePlayerSupply(playerId)

                if(playerInfo.ReadyState ~= 2) then
                    GameRules.DW.ShowRollPanel(playerInfo.Hero)
                end
                
                DDW:SetOperatorEnabled(playerInfo.Hero, true)

                if(GameRules.DW.RoundNo == 27 or GameRules.DW.RoundNo == 29 or GameRules.DW.RoundNo == 31 or GameRules.DW.RoundNo == 33 or GameRules.DW.RoundNo == 35 or GameRules.DW.RoundNo == 37) then
                    GameRules.DW.DropItemForPlayer(playerInfo.Hero, "item_tome_of_upgrade")
                end

                if(GameRules.DW.RoundNo == 21 or GameRules.DW.RoundNo == 25 or GameRules.DW.RoundNo == 29 or GameRules.DW.RoundNo == 33 or GameRules.DW.RoundNo == 37) then
                    GameRules.DW.DropNeutralItemForPlayer(playerInfo.Hero, -1)
                end

                local roundGold = 50 * GameRules.DW.RoundNo
                if(roundGold > 2000) then
                    roundGold = 2000
                end

                if(roundGold < 300) then
                    roundGold = 300
                end

                if(GameRules.DW.MapName == "dawn_war_coop") then
                    if(roundGold < 500) then
                        roundGold = 500
                    end
                end

                PlayerResource:ModifyGold(playerId, roundGold, false, DOTA_ModifyGold_Unspecified)
                
                local diffSupply = GameRules.DW.GetCurrentSupply(playerId) - GameRules.DW.GetMaxSupply(playerId)

                if(GameRules.DW.CheckHasTalent(playerInfo.Hero, "special_bonus_elf_20_2")) then
                    diffSupply = diffSupply - 5
                end
                
                if(diffSupply > 0) then
                    PlayerResource:SpendGold(playerId, diffSupply * 100, DOTA_ModifyGold_Unspecified)
                end
            end
        end
    end
    
    if(GameRules.DW.StageName[GameRules.DW.Stage] == "PREFIGHT") then
        EmitGlobalSound(SoundRes.STAGE_PREFIGHT)
        
        for playerId, playerInfo in pairs(GameRules.DW.PlayerList) do
            if(playerInfo.Hero ~= nil and playerInfo.Hero:IsNull() == false and playerInfo.ReadyState ~= 0) then
                DDW:SetOperatorEnabled(playerInfo.Hero, false)
            end
        end
    end
    
    if(GameRules.DW.StageName[GameRules.DW.Stage] == "FIGHTING") then
        LogClearParticleStartIndex()
        
        GameRules.DW.HasAnnounceBattleResult = false
        
        table.clear(GameRules.DW.BattleUnitList)
        
        local previousBattle = GameRules.DW.Battles[#GameRules.DW.Battles]
        
        local thisBattle = {
            RoundNo = GameRules.DW.RoundNo,
            Players = {},
            Result = ""
        }
        
        table.insert(GameRules.DW.Battles, thisBattle)
        
        GameRules.DW.InterchangeBattlePosition()
        
        for i = 1, #GameRules.DW.BattlePlayers do
            GameRules.DW.PlayerList[GameRules.DW.BattlePlayers[i]].BattleCount = GameRules.DW.PlayerList[GameRules.DW.BattlePlayers[i]].BattleCount + 1
            DDW:MoveHerosToBattleField(GameRules.DW.BattlePlayers[i], i % 2)
        end
        
        for playerId, playerInfo in pairs(GameRules.DW.PlayerList) do
            playerInfo.ReadyState = 0
            playerInfo.BattleSupplyDiff = -1
            if(playerInfo.IsEmpty == false and table.exist(GameRules.DW.BattlePlayers, playerId) == false and playerInfo.Life > 0) then
                local noBattleHero = GameRules.DW.PlayerList[playerId].Hero
                if(noBattleHero ~= nil and noBattleHero:IsNull() == false) then
                    DDW:SetOperatorEnabled(noBattleHero, true)
                    GameRules.DW.DropRandomItemForPlayer(noBattleHero)
                end
            end
        end
        
        CreateTimer(function() DDW:CheckBattleOver() end, 5)
    end
    
    if(GameRules.DW.StageName[GameRules.DW.Stage] == "NEWROUND") then
        if(#GameRules.DW.Battles > 0) then
            local battleResult
            local goodGuysSupply = GameRules.DW.GetHeroListSupply(GameRules.DW.GoodGuys)
            local badGuysSupply = GameRules.DW.GetHeroListSupply(GameRules.DW.BadGuys)
            if(goodGuysSupply > 0 and badGuysSupply > 0) then
                EmitGlobalSound(SoundRes.BATTLE_DRAW)
            end
            
            local lostLife = goodGuysSupply - badGuysSupply
            local playerCount = DDW:GetCurrentBattlePlayerCount()
            if(lostLife == 0) then
                battleResult = "Draw"
                DDW:UpdateConDefeatCount(1, false)
                DDW:UpdateConDefeatCount(2, false)
                DDW:UpdateConDefeatCount(3, false)
                DDW:UpdateConDefeatCount(4, false)
            elseif (lostLife > 0) then
                battleResult = "RadWin"
                DDW:UpdateConDefeatCount(1, false)
                DDW:UpdateConDefeatCount(2, false)
                DDW:UpdateConDefeatCount(3, true)
                DDW:UpdateConDefeatCount(4, true)
                DDW:UpdateBattlePlayerLife(3, lostLife, playerCount)
                DDW:UpdateBattlePlayerLife(4, lostLife, playerCount)
            else
                battleResult = "DireWin"
                DDW:UpdateConDefeatCount(1, true)
                DDW:UpdateConDefeatCount(2, true)
                DDW:UpdateConDefeatCount(3, false)
                DDW:UpdateConDefeatCount(4, false)
                DDW:UpdateBattlePlayerLife(1, lostLife, playerCount)
                DDW:UpdateBattlePlayerLife(2, lostLife, playerCount)
            end
            
            GameRules.DW.Battles[#GameRules.DW.Battles].Result = battleResult
            
            for i, v in pairs(GameRules.DW.Battles[#GameRules.DW.Battles].Players) do
                DDW:MoveHerosBackToGrid(v)
            end

            local entireEntities = Entities:FindAllInSphere(Vector(0, 0, 0), 6500)
            
            for i, v in pairs(GameRules.DW.ToBeRemovedUnits) do
                if(v ~= nil and v:IsNull() == false) then
                    if(v:GetName() ~= "npc_dota_base_additive") then
                        SafeRemoveUnit(v, entireEntities)
                    else
                        local unitOwner = v:GetOwner()
                        if(unitOwner == nil or unitOwner:IsNull() or v.GetUnitName == nil) then
                            SafeRemoveUnit(v, entireEntities)
                        else
                            if(v:GetUnitName() ~= "npc_dota_phoenix_sun") then
                                SafeRemoveUnit(v, entireEntities)
                            end
                        end
                    end
                end
            end
            table.clear(GameRules.DW.ToBeRemovedUnits)
            
            local remainingTeamCount = 0
            local winnerTeam = nil
            for playerId, playerInfo in pairs(GameRules.DW.PlayerList) do
                if(playerInfo.IsEmpty == false) then
                    if(GameRules.DW.MapName ~= "dawn_war_coop" and GameRules.DW.IsDuelStage == false) then
                        if(playerInfo.IsOnline == false and playerInfo.IsAlive) then
                            playerInfo.DisconnectedRoundCount = playerInfo.DisconnectedRoundCount + 1
                            if(playerInfo.DisconnectedRoundCount > 2) then
                                playerInfo.Life = playerInfo.Life - 25
                                if(playerInfo.Life < 0) then
                                    playerInfo.Life = 0
                                end
                            end
                        end
                    end

                    if(playerInfo.Life > 0) then
                        remainingTeamCount = remainingTeamCount + 1
                        winnerTeam = playerInfo.TeamId
                    elseif playerInfo.IsAlive then
                        playerInfo.IsAlive = false
                        if(playerInfo.Hero ~= nil and playerInfo.Hero:IsNull() == false) then
                            for slotIndex = 0, 16 do
                                local item = playerInfo.Hero:GetItemInSlot(slotIndex)
                                if item ~= nil then
                                    playerInfo.Hero:RemoveItem(item)
                                end
                            end
                        end
                        DDW:SaveEndGameInfo(playerId)
                        GameRules.DW.StageTime[1] = GameRules.DW.StageTime[1] + 2
                        
                        local operatorToBeKilled = GameRules.DW.PlayerList[playerId].Hero
                        if(operatorToBeKilled ~= nil and operatorToBeKilled:IsNull() == false) then
                            operatorToBeKilled:ForceKill(false)
                        end
                        
                        CreateTimer(function()
                            local entireEntities = Entities:FindAllInSphere(Vector(0, 0, 0), 6500)
                            local herosToBeKilled = GameRules.DW.GetHerosByPlayerId(playerId)
                            if(herosToBeKilled ~= nil) then
                                for _, hero in pairs(herosToBeKilled) do
                                    SafeRemoveUnit(hero, entireEntities)
                                end
                            end
                        end, 8)
                    end

                    if(playerInfo.IsAlive == false) then
                        PlayerResource:SetGold(playerId, 0, true)
                        PlayerResource:SetGold(playerId, 0, false)
                    end
                end
            end

            DDW:AdjustRanks()
            
            GameRules.DW.RemainingTeamCount = remainingTeamCount

            local checkRemainingCount = 1
            if(GameRules.DW.MapName == "dawn_war_coop") then
                checkRemainingCount = 2
                for playerId, playerInfo in pairs(GameRules.DW.PlayerList) do
                    if(winnerTeam ~= nil and playerInfo.IsEmpty == false and playerInfo.Life > 0) then
                        if(playerInfo.TeamId ~= winnerTeam) then
                            checkRemainingCount = 1
                        end
                    end
                end
            end

            if(remainingTeamCount <= checkRemainingCount and winnerTeam ~= nil) then
                for playerId, playerInfo in pairs(GameRules.DW.PlayerList) do
                    if(playerInfo.IsEmpty == false and playerInfo.Life > 0) then
                        DDW:SaveEndGameInfo(playerId)        
                    end
                end
                
                local endTable = {}
                for playerId, playerInfo in pairs(GameRules.DW.PlayerList) do
                    table.insert(endTable, {
                        playerId = playerId,
                        teamId = playerInfo.TeamId,
                        steamId = playerInfo.SteamId,
                        playerName = playerInfo.PlayerName,
                        isBot = playerInfo.IsBot,
                        battleCount = playerInfo.BattleCount,
                        lastTime = playerInfo.LastTime,
                        heros = playerInfo.Heros,
                        rank = playerInfo.Rank,
                        life = playerInfo.Life,
                        kills = playerInfo.Kills,
                        assists = playerInfo.Assists,
                        goldTotal = playerInfo.GoldTotal
                    })
                end

                table.sort(endTable, function(a, b)
                    if a.rank ~= b.rank then
                        return 8 - a.rank > 8 - b.rank
                    end
                    if a.life ~= b.life then
                        return a.life > b.life
                    end
                    if a.kills ~= b.kills then
                        return a.kills > b.kills
                    end
                    if a.assists ~= b.assists then
                        return a.assists > b.assists
                    end
                    return a.playerId < b.playerId
                end)
                
                CustomNetTables:SetTableValue("end_game_table", "end_info", endTable)
                
                local postData = {GameId = GameRules.DW.GameId, EndTable = endTable}
                HttpPost("api/Game/GameEnd", postData, function(result)
                    if(result.isSuccess) then
                        -- ShowGolbalMessage("Game result uploaded.")
                        CustomNetTables:SetTableValue("end_game_table", "score_info", result.tag)
                    else
                        ShowGolbalMessage(result.message)
                    end
                end)
                
                CreateTimer(function()
                    EmitGlobalSound(SoundRes.GAME_OVER)
                    GameRules.DW.IsGameOver = true
                    GameRules:SetGameWinner(winnerTeam)
                end, 3)
            end
        end
        
        CreateTimer(function()
            table.clear(GameRules.DW.GoodGuys)
            table.clear(GameRules.DW.BadGuys)
            ClearParticles()
        end, 1.5)
    end
end

function DDW:SaveEndGameInfo(playerId)
    if(playerId == nil) then return end
    local playerInfo = GameRules.DW.PlayerList[playerId]
    
    local t = GameRules:GetGameTime() - GameRules.DW.GameStartTime
    local h = math.floor(t / 3600)
    local m = math.floor((t - 3600 * h) / 60)
    local s = math.floor(t - 3600 * h - 60 * m)
    
    playerInfo.LastTime = string.format("%02d:%02d:%02d", h, m, s)
    playerInfo.Rank = GameRules.DW.LastRank
    GameRules.DW.LastRank = GameRules.DW.LastRank - 1
    
    local heros = GameRules.DW.GetHerosByPlayerId(playerId)
    for i, hero in pairs(heros) do
        if(hero.IsRealHero ~= nil and hero:IsRealHero()) then
            table.insert(playerInfo.Heros, {
                name = hero:GetName(),
            level = hero:GetLevel()})
        end
    end
end

function DDW:AdjustRanks()
    local playerInfoToBeAdjusted = {}
    local currentRank = 8
    for playerId, playerInfo in pairs(GameRules.DW.PlayerList) do
        if(playerInfo.IsAlive == false and playerInfo.IsRankAdjusted == false) then
            if(playerInfo.Rank < currentRank) then
                currentRank = playerInfo.Rank
            end
            playerInfo.IsRankAdjusted = true
            table.insert(playerInfoToBeAdjusted, playerInfo)
        end
    end

    if(#playerInfoToBeAdjusted > 0) then
        table.sort(playerInfoToBeAdjusted, function(a, b)
            if a.Life ~= b.Life then
                return a.Life > b.Life
            end
            if a.Kills ~= b.Kills then
                return a.Kills > b.Kills
            end
            if a.Assists ~= b.Assists then
                return a.Assists > b.Assists
            end
            return false
        end)

        for _, v in pairs(playerInfoToBeAdjusted) do
            v.Rank = currentRank
            currentRank = currentRank + 1
        end
    end
end

function DDW:GetCurrentBattlePlayerCount()
    local playerCount = 0
    for i = 1, 4 do
        if(GameRules.DW.Battles[#GameRules.DW.Battles].Players[i] ~= nil) then
            playerCount = playerCount + 1
        end
    end
    return playerCount
end

function DDW:UpdateBattlePlayerLife(battlePosition, lostLife, playerCount)
    local currentBattle = GameRules.DW.Battles[#GameRules.DW.Battles]
    local playerId = currentBattle.Players[battlePosition]
    if(playerId ~= nil and PlayerResource:IsValidTeamPlayerID(playerId)) then
        local loseLifeActually = math.abs(lostLife)
        if(playerCount == 4) then
            loseLifeActually = math.floor(loseLifeActually / 2)
        end
        
        local playerInfo = GameRules.DW.PlayerList[playerId]
        if(playerInfo ~= nil) then
            local lostLifeLimit = 25
            if(GameRules.DW.MapName == "dawn_war_coop") then
                lostLifeLimit = 20
            end
            if(playerInfo.ConDefeatCount > 0) then
                lostLifeLimit = lostLifeLimit - 2 * playerInfo.ConDefeatCount
                if(lostLifeLimit < 10) then
                    lostLifeLimit = 10
                end
            end

            if(loseLifeActually > lostLifeLimit) then
                loseLifeActually = lostLifeLimit
            end

            if(loseLifeActually > 0) then
                playerInfo.Life = playerInfo.Life - loseLifeActually
                local loseLifeGold = loseLifeActually * (120 + playerInfo.ConDefeatCount * 25)
                PlayerResource:ModifyGold(playerId, loseLifeGold, false, DOTA_ModifyGold_Unspecified)

                if(playerInfo.BattleSupplyDiff > 0) then
                    PlayerResource:ModifyGold(playerId, playerInfo.BattleSupplyDiff * 100, false, DOTA_ModifyGold_Unspecified)
                end
            end
            
            if(playerInfo.Life <= 0) then
                if(GameRules.DW.MapName == "dawn_war_coop") then
                    local hasDieProtect = GameRules.DW.CheckHasTalent(playerInfo.Hero, "special_bonus_elf_20_1")
                    if(hasDieProtect) then
                        local partnerHasDieProtect = false
                        local partnerId = GameRules.DW.GetCoopPartnerId(playerId)
                        local partnerPlayerInfo = GameRules.DW.PlayerList[partnerId]
                        if(partnerPlayerInfo ~= nil) then
                            partnerHasDieProtect = GameRules.DW.CheckHasTalent(partnerPlayerInfo.Hero, "special_bonus_elf_20_1")
                        end

                        if(hasDieProtect and playerInfo.UsedDieProtect == false and partnerHasDieProtect) then
                            playerInfo.UsedDieProtect = true
                            playerInfo.Life = 1
                        else
                            playerInfo.Life = 0
                        end
                    else
                        playerInfo.Life = 0
                    end
                else
                    local hasDieProtect = GameRules.DW.CheckHasTalent(playerInfo.Hero, "special_bonus_elf_20_1")
                    if(hasDieProtect and playerInfo.UsedDieProtect == false) then
                        playerInfo.UsedDieProtect = true
                        playerInfo.Life = 1
                    else
                        playerInfo.Life = 0
                    end
                end
            end
        end
    end
end

function DDW:UpdateConDefeatCount(battlePosition, isLost)
    if(#GameRules.DW.Battles <= 0) then return end
    local currentBattle = GameRules.DW.Battles[#GameRules.DW.Battles]
    local playerId = currentBattle.Players[battlePosition]
    if(playerId ~= nil and PlayerResource:IsValidTeamPlayerID(playerId)) then
        local playerInfo = GameRules.DW.PlayerList[playerId]
        if(playerInfo == nil) then return end
        if(isLost == false) then
            playerInfo.ConDefeatCount = 0
            playerInfo.LastBattleResult = "win"
            PlayerResource:ModifyGold(playerId, 200, false, DOTA_ModifyGold_Unspecified)
            return
        else
            if(playerInfo.LastBattleResult ~= "lose") then
                playerInfo.LastBattleResult = "lose"
                return
            end
            playerInfo.ConDefeatCount = playerInfo.ConDefeatCount + 1
            playerInfo.LastBattleResult = "lose"
        end

        if(GameRules.DW.IsDuelStage) then
            playerInfo.ConDefeatCount = 0
        end
    end
end

function DDW:OnNpcSpawned(data)
    local spawnedUnit = EntIndexToHScript(data.entindex)
    if(spawnedUnit == nil or spawnedUnit:IsNull()) then
        return
    end

    if spawnedUnit:GetUnitName() == "npc_dota_companion" then
        UTIL_Remove(spawnedUnit)
        return
    end

    spawnedUnit:SetDeathXP(0)
    
    local owner = spawnedUnit:GetOwner()
    if(owner == nil or owner:IsNull()) then return end

    if(spawnedUnit.IsIllusion ~= nil and spawnedUnit:IsIllusion()) then
        local ownerPlayerId = owner:GetPlayerID()
        local realOwner = GameRules.DW.FindSameHeroFullname(ownerPlayerId, spawnedUnit:GetName())
        if(realOwner ~= nil) then
            spawnedUnit.RealOwner = realOwner
            if(spawnedUnit:GetName() ~= "npc_dota_hero_terrorblade") then
                spawnedUnit:SetPlayerID(-1)
            end
        end
    end

    if(spawnedUnit:GetName() == "npc_dota_elder_titan_ancestral_spirit") then
        owner.spirit = spawnedUnit
    end

    if(string.find(spawnedUnit:GetName(), "npc_dota_visage_familiar")) then
        if(owner.familiarCount == nil) then
            owner.familiarCount = 0
        end
        owner.familiarCount = owner.familiarCount + 1
    end
    
    if(string.find(spawnedUnit:GetName(), "npc_dota_lone_druid_bear")) then
        local ownerPlayerId = owner:GetPlayerID()
        if(GameRules.DW.PlayerList[ownerPlayerId] ~= nil) then
            if(spawnedUnit ~= nil and spawnedUnit:IsNull() == false) then
                if(spawnedUnit:HasModifier("modifier_hero_command_restricted") == false) then
                    spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_hero_command_restricted", {})
                end
                local bearVector = GameRules.DW.FindGridInfo(ownerPlayerId, owner.bear)
                if(bearVector == nil) then
                    local gridVector = GameRules.DW.FindGridInfo(ownerPlayerId, owner)
                    if(gridVector == nil) then
                        spawnedUnit:ForceKill(false)
                        UTIL_Remove(spawnedUnit)
                        return
                    end
                    bearVector = GameRules.DW.FindEmptyVectorNearBy(gridVector, ownerPlayerId)
                end
                
                if(bearVector == nil) then
                    spawnedUnit:ForceKill(false)
                    UTIL_Remove(spawnedUnit)
                    return
                end
                
                if(owner.bear ~= nil and owner.bear:IsNull() == false and owner.bear ~= spawnedUnit) then
                    GameRules.DW.CleanNoOwnerBear(ownerPlayerId, owner.bear)
                end

                owner.bear = spawnedUnit
                spawnedUnit.sourcePos = GameRules.DW.GetPositionByGridVector(bearVector, ownerPlayerId)
                GameRules.DW.SetGridInfo(ownerPlayerId, bearVector.x, bearVector.y, spawnedUnit)
                
                local teamId = spawnedUnit:GetTeamNumber()
                if(teamId == DOTA_TEAM_GOODGUYS or teamId == DOTA_TEAM_BADGUYS) then
                    spawnedUnit:SetContextThink("OnUnitThink", function() return UnitAI:OnUnitThink(spawnedUnit) end, 1)
                end
            end
        end
        return
    end

    if(spawnedUnit.IsTempestDouble ~= nil and spawnedUnit:IsTempestDouble()) then
        if(spawnedUnit:HasModifier("modifier_hero_command_restricted") == false) then
            spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_hero_command_restricted", {})
        end
        spawnedUnit:SetContextThink("OnHeroThink", function() return HeroAI:OnHeroThink(spawnedUnit) end, 1)
        table.insert(GameRules.DW.ToBeRemovedUnits, spawnedUnit)
        return
    end
    
    if(owner:GetTeam() == DOTA_TEAM_GOODGUYS or owner:GetTeam() == DOTA_TEAM_BADGUYS) then
        local unitName = spawnedUnit:GetName()

        if(spawnedUnit:GetUnitName() == "npc_dota_grimstroke_ink_creature") then
            spawnedUnit:SetContextThink("OnUnitThink", function() return UnitAI:OnUnitThink(spawnedUnit) end, 1)
        end
        
        if(unitName == "npc_dota_brewmaster_fire" or unitName == "npc_dota_brewmaster_storm" or unitName == "npc_dota_brewmaster_earth") then
            spawnedUnit:SetContextThink("OnUnitThink", function() return UnitAI:OnUnitThink(spawnedUnit) end, 1)
        end

        if(spawnedUnit:GetUnitName() == "npc_dota_necronomicon_archer_3") then
            spawnedUnit:SetContextThink("OnUnitThink", function() return UnitAI:OnUnitThink(spawnedUnit) end, 1)
        end

        if(spawnedUnit:GetUnitName() == "npc_dota_hero_vengefulspirit" and spawnedUnit:IsIllusion()) then
            if(GameRules.DW.CheckHasTalent(spawnedUnit.RealOwner, "special_bonus_unique_vengeful_spirit_7") == true) then
                spawnedUnit:SetContextThink("OnUnitThink", function() return UnitAI:OnUnitThink(spawnedUnit) end, 1)
            end
        end
        
        local checkName = string.gsub(unitName, HeroNamePrefix, "")
        if(table.contains(AllHeroNames, checkName) == false or spawnedUnit:IsIllusion() == true) then
            table.insert(GameRules.DW.ToBeRemovedUnits, spawnedUnit)
            
            CreateTimer(function()
                if spawnedUnit ~= nil and spawnedUnit:IsNull() == false then
                    local unitName = spawnedUnit:GetName()
                    if(unitName == "npc_dota_beastmaster_hawk") then
                        SetAbility(spawnedUnit, "necronomicon_warrior_sight", true)
                        local trueSightAb = spawnedUnit:FindAbilityByName("necronomicon_warrior_sight")
                        spawnedUnit:AddNewModifier(spawnedUnit, trueSightAb, "modifier_item_gem_of_true_sight", {radius=1200})
                    end

                    if(unitName == "npc_dota_broodmother_spiderling" or unitName == "npc_dota_broodmother_spiderite") then
                        if(owner.HasScepter ~= nil and owner:HasScepter()) then
                            spawnedUnit:AddNewModifier(spawnedUnit, trueSightAb, "modifier_special_bonus_unique_warlock_1", {})
                        end
                    end

                    if(spawnedUnit:HasModifier("modifier_hero_command_restricted") == false) then
                        spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_hero_command_restricted", {})
                    end

                    local useUnitAI = false

                    if(unitName == "npc_dota_visage_familiar") then
                        useUnitAI = true
                    else
                        local unitName2 = spawnedUnit:GetUnitName()
                        if(unitName2 == "npc_dota_juggernaut_healing_ward" or unitName2 == "npc_dota_templar_assassin_psionic_trap") then
                            useUnitAI = true
                        end

                        if(unitName2 == "npc_dota_techies_remote_mine" or unitName2 == "npc_dota_techies_stasis_trap" or unitName2 == "npc_dota_techies_land_mine") then
                            useUnitAI = true
                        end
                    end

                    if(useUnitAI) then
                        spawnedUnit:SetContextThink("OnUnitThink", function() return UnitAI:OnUnitThink(spawnedUnit) end, 1)
                    else
                        if(spawnedUnit:GetAttackDamage() > 1) then
                            table.insert(GameRules.DW.BattleUnitList, spawnedUnit)
                        end
                    end
                end
            end, 0.5)
        end
    end
end

function DDW:OnEntityKilled(data)
    if(data.entindex_killed == nil) then
        return
    end

    local hero = EntIndexToHScript(data.entindex_killed)
    if hero == nil or hero:IsNull() then
        return
    end

    if(string.find(hero:GetName(), "npc_dota_visage_familiar")) then
        local owner = hero:GetOwner()
        if(owner ~= nil and owner:IsNull() == false) then
            if(owner.familiarCount == nil) then
                owner.familiarCount = 0
            else
                owner.familiarCount = owner.familiarCount - 1
            end
        end
    end
    
    if(hero.IsRealHero ~= nil and hero:IsRealHero() and GameRules.DW.StageName[GameRules.DW.Stage] == "FIGHTING") then
        local playerId = hero:GetPlayerOwnerID()
        if GameRules.DW.PlayerList[playerId] ~= nil and GameRules.DW.PlayerList[playerId].IsAlive and hero:IsReincarnating() == false then
            if(data.entindex_attacker ~= nil) then
                local attackerUnit = EntIndexToHScript(data.entindex_attacker)
                if attackerUnit ~= nil and attackerUnit:IsNull() == false then
                    GameRules.DW.GiveHeroGoldBounty(attackerUnit, hero)
                end
            end

            local teamId = hero:GetTeam()
            if(teamId == DOTA_TEAM_GOODGUYS) then
                table.remove_value(GameRules.DW.GoodGuys, hero)
            end
            
            if(teamId == DOTA_TEAM_BADGUYS) then
                table.remove_value(GameRules.DW.BadGuys, hero)
            end
            
            DDW:CheckBattleOver()

            if(hero ~= nil and hero:IsNull() == false) then
                CreateTimer(function()
                    if(hero ~= nil and hero:IsNull() == false and hero:IsAlive() == false and hero:IsReincarnating() == false) then
                        local currentPos = hero:GetAbsOrigin()
                        if(currentPos ~= GameRules.DW.FountainGood and currentPos ~= GameRules.DW.FountainBad) then
                            if(hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS) then
                                hero:SetAbsOrigin(GameRules.DW.FountainGood)
                            else
                                hero:SetAbsOrigin(GameRules.DW.FountainBad)
                            end
                        end
                    end
                end, 2.5)
            end
        end
    elseif (GameRules.DW.StageName[GameRules.DW.Stage] == "PREPARE" or GameRules.DW.StageName[GameRules.DW.Stage] == "NEWROUND") then
        if(hero ~= nil and hero:IsNull() == false and hero.sourcePos ~= nil and hero.IsRealHero ~= nil and hero:IsRealHero()) then
            local playerInfo = GameRules.DW.PlayerList[hero:GetPlayerID()]
            if(playerInfo ~= nil and playerInfo.Life > 0) then
                hero:SetRespawnPosition(hero.sourcePos)
                hero:RespawnHero(false, false)
                if(hero:HasModifier("modifier_hero_waitting") == false) then
                    local waittingModifier = hero:AddNewModifier(hero, nil, "modifier_hero_waitting", {})
                    if(waittingModifier ~= nil and hero.price ~= nil) then
                        waittingModifier:SetStackCount(hero.price)
                    end
                end
            end
        end
    end
end

function DDW:FillNevermoreStackCount(hero)
    if(hero == nil or hero:IsNull()) then
        return
    end
    
    local stackModifier = hero:FindModifierByName("modifier_nevermore_necromastery")
    local ability = hero:FindAbilityByName("nevermore_necromastery")
    
    if(ability == nil or ability:GetLevel() < 1) then
        if(stackModifier ~= nil) then
            stackModifier:SetStackCount(0)
        end
        return
    end
    
    local maxSoulsCount = ability:GetSpecialValueFor("necromastery_max_souls")
    
    if(hero:HasScepter()) then
        maxSoulsCount = ability:GetSpecialValueFor("necromastery_max_souls_scepter")
    end
    
    if(maxSoulsCount ~= nil) then
        if(stackModifier ~= nil) then
            stackModifier:SetStackCount(maxSoulsCount)
        end
    end
end

function DDW:CheckBattleOver()
    local goodGuysSupply = GameRules.DW.GetHeroListSupply(GameRules.DW.GoodGuys)
    local badGuysSupply = GameRules.DW.GetHeroListSupply(GameRules.DW.BadGuys)
    
    if(goodGuysSupply == 0 or badGuysSupply == 0) then
        GameRules.DW.StageStartTime = GameRules:GetGameTime() - GameRules.DW.StageTime[GameRules.DW.Stage] + 3
        
        if(GameRules.DW.HasAnnounceBattleResult == false) then
            GameRules.DW.HasAnnounceBattleResult = true
            if(goodGuysSupply == 0 and badGuysSupply > 0) then
                CreateTimer(function() EmitGlobalSound(SoundRes.DIRE_VICTORY) end, 1.5)
            end
            
            if(badGuysSupply == 0 and goodGuysSupply > 0) then
                CreateTimer(function() EmitGlobalSound(SoundRes.RAD_VICTORY) end, 1.5)
            end
        end
    end
end

function DDW:MoveHerosToBattleField(playerId, battleSide)
    local playerHero = GameRules.DW.PlayerList[playerId].Hero
    if(playerHero == nil or playerHero:IsNull()) then
        return
    end

    playerHero:ClearStreak()

    local playerInfo = GameRules.DW.PlayerList[playerId]
    if(playerInfo == nil) then
        return
    end

    playerInfo.TeleportSoundCount = 0
    
    local chooseTeamNo
    
    local currentBattle = GameRules.DW.Battles[#GameRules.DW.Battles]
    
    if(battleSide == 0) then
        if(currentBattle.Players[1] == nil) then chooseTeamNo = 1 else chooseTeamNo = 2 end
    else
        if(currentBattle.Players[3] == nil) then chooseTeamNo = 3 else chooseTeamNo = 4 end
    end
    
    currentBattle.Players[chooseTeamNo] = playerId

    CreateTimer(function()
        local gold1 = PlayerResource:GetReliableGold(playerId)
        if(gold1 == nil) then gold1 = 0 end
        local gold2 = PlayerResource:GetUnreliableGold(playerId)
        if(gold2 == nil) then gold2 = 0 end
        
        local totalEarnedGold = PlayerResource:GetTotalEarnedGold(playerId)
        if(totalEarnedGold ~= nil) then
            playerInfo.GoldTotal = playerInfo.GoldTotal + totalEarnedGold
        end
        PlayerResource:ResetTotalEarnedGold(playerId)
        PlayerResource:SetGold(playerId, 0, true)
        PlayerResource:SetGold(playerId, 0, false)
        PlayerResource:SetCustomTeamAssignment(playerId, battleSide + 2)
        PlayerResource:SetGold(playerId, gold1, true)
        PlayerResource:SetGold(playerId, gold2, false)
        PlayerResource:ResetTotalEarnedGold(playerId)
    end, 3)

    for x = 1, 8 do
        for y = 1, 8 do
            local hero = GameRules.DW.GetGridInfo(playerId, x, y)
            if hero ~= nil and hero:IsNull() == false then
                local offsetVector
                if(battleSide == 0) then offsetVector = Vector(y - 1, 1 - x) * 160 end
                if(battleSide == 1) then offsetVector = Vector(1 - y, x - 1) * 160 end
                
                local startPosition = hero:GetAbsOrigin()
                local targetPosition = GameRules.DW.BattlePosition[chooseTeamNo] + offsetVector

                if(hero.HasItemInInventory ~= nil and hero:HasItemInInventory("item_phase_teleporter")) then
                    if(chooseTeamNo == 1 or chooseTeamNo == 2) then
                        targetPosition = GameRules.DW.BattlePosition[3 - chooseTeamNo] + offsetVector
                    else
                        targetPosition = GameRules.DW.BattlePosition[7 - chooseTeamNo] + offsetVector
                    end 
                end

                local forwardVector
                
                if(battleSide == 0) then forwardVector = Vector(1, 0, 0) else forwardVector = Vector(-1, 0, 0) end
                
                if(hero.toggleOffList == nil) then
                    hero.toggleOffList = {}
                end
                
                table.clear(hero.toggleOffList)
                
                hero.sourcePos = hero:GetAbsOrigin()
                if(hero.IsRealHero ~= nil and hero:IsRealHero()) then
                    hero.baseIntellect = hero:GetBaseIntellect()
                end

                if(hero:HasModifier("modifier_hero_waitting")) then
                    hero:RemoveModifierByName("modifier_hero_waitting")
                end

                if(hero:HasModifier("modifier_smoke_of_deceit")) then
                    hero:RemoveModifierByName("modifier_smoke_of_deceit")
                end
                
                if(hero:IsAlive() == false) then
                    if(hero.IsRealHero ~= nil and hero:IsRealHero()) then
                        hero:SetRespawnPosition(hero:GetAbsOrigin())
                        hero:RespawnHero(false, false)
                    else
                        hero:RespawnUnit()
                    end
                end

                if(hero:GetName() == "npc_dota_hero_nevermore") then
                    DDW:FillNevermoreStackCount(hero)
                end

                if(hero:GetName() == "npc_dota_hero_visage") then
                    hero.familiarCount = 0
                end

                if(hero:GetName() == "npc_dota_hero_morphling") then
                    hero.needRefreshMorphAblilites = true
                end
                
                GameRules.DW.DoTeleporting(playerHero, hero, startPosition, targetPosition, forwardVector, 3, 
                function()
                    if hero ~= nil and hero:IsNull() == false then
                        if(hero:HasAbility("arc_warden_tempest_double")) then
                            for slotIndex = 0, 16 do
                                local item = hero:GetItemInSlot(slotIndex)
                                if item ~= nil then
                                    local itemName = item:GetName()
                                    if(itemName == "item_refresher") then
                                        GameRules.DW.DropItem(hero, item)
                                    end
                                end
                            end
                        end
                        GameRules.DW.EndAbilitiesCooldown(hero)
                        GameRules.DW.EndItemsCooldown(hero)
                    end
                end,
                function()
                    if hero ~= nil and hero:IsNull() == false then
                        local battleTeamId = battleSide + 2
                        if(hero ~= playerInfo.ControlledHero) then
                            hero.IsManuallyControlled = false
                            if(battleTeamId == DOTA_TEAM_GOODGUYS) then
                                table.insert(GameRules.DW.GoodGuys, hero)
                            end
                            
                            if(battleTeamId == DOTA_TEAM_BADGUYS) then
                                table.insert(GameRules.DW.BadGuys, hero)
                            end
                        else
                            hero.IsManuallyControlled = true
                        end
                        
                        hero:SetControllableByPlayer(playerId, true)
                        hero:SetHealth(hero:GetMaxHealth())
                        hero:SetMana(hero:GetMaxMana())
                        hero:SetTeam(battleTeamId)
                        if(hero.spirit ~= nil and hero.spirit:IsNull() == false) then
                            hero.spirit:SetTeam(battleTeamId)
                        end
                        hero:Interrupt()
                        hero:InterruptChannel()
                        hero.damage = 0
                        hero.damageTake = 0
                        hero.LastSpellAbilityName = nil
                        
                        if(hero:IsAlive()) then
                            ExecuteOrderFromTable({
                                UnitIndex = hero:entindex(),
                                OrderType = DOTA_UNIT_ORDER_STOP
                            })
                        end

                        if(hero ~= playerInfo.ControlledHero) then
                            if(hero.IsRealHero ~= nil and hero:IsRealHero()) then
                                hero.LastThinkTime = GameRules:GetGameTime()
                                hero:SetContextThink("OnHeroThink", function() return HeroAI:OnHeroThink(hero) end, 1)
                            else
                                hero:SetContextThink("OnUnitThink", function() return UnitAI:OnUnitThink(hero) end, 1)
                            end
                        end
                    end
                end)
            end
        end
    end
    
    CreateTimer(function()
        local cameraLocation = GameRules.DW.BattlePosition[chooseTeamNo]
        if(battleSide == 0) then cameraLocation = cameraLocation + Vector(640, -680) end
        if(battleSide == 1) then cameraLocation = cameraLocation + Vector(-640, 480) end
        SendMessageToPlayer(playerId, "CAMERA_FOLLOW", {location = cameraLocation})
        SendMessageToPlayer(playerId, "DAMAGE_TABLE", {})
    end, 1.5)
end

function DDW:MoveHerosBackToGrid(playerId)
    local playerInfo = GameRules.DW.PlayerList[playerId]
    if(playerInfo ~= nil) then
        local gold1 = PlayerResource:GetReliableGold(playerId)
        if(gold1 == nil) then gold1 = 0 end
        local gold2 = PlayerResource:GetUnreliableGold(playerId)
        if(gold2 == nil) then gold2 = 0 end

        local totalEarnedGold = PlayerResource:GetTotalEarnedGold(playerId)
        if(totalEarnedGold ~= nil) then
            playerInfo.GoldTotal = playerInfo.GoldTotal + totalEarnedGold
        end
        PlayerResource:ResetTotalEarnedGold(playerId)
        PlayerResource:SetGold(playerId, 0, true)
        PlayerResource:SetGold(playerId, 0, false)
        PlayerResource:SetCustomTeamAssignment(playerId, playerInfo.TeamId)
        PlayerResource:SetGold(playerId, gold1, true)
        PlayerResource:SetGold(playerId, gold2, false)
        PlayerResource:ResetTotalEarnedGold(playerId)

        playerInfo.ControlledHero = nil
        playerInfo.TeleportSoundCount = 0
    else
        return
    end
    
    local playerHero = GameRules.DW.PlayerList[playerId].Hero
    if(playerHero == nil or playerHero:IsNull()) then
        return
    end
    
    local damageTable = {}
    for x = 1, 8 do
        for y = 1, 8 do
            local hero = GameRules.DW.GetGridInfo(playerId, x, y)
            if hero ~= nil and hero:IsNull() == false then
                local offsetVector = Vector(x - 1, y - 1) * 160
                local startPosition = hero:GetAbsOrigin()
                local targetPosition = GameRules.DW.GetPlayerOrigin(playerId)

                if(targetPosition ~= nil) then
                    targetPosition = targetPosition + offsetVector
                end

                local forwardVector = Vector(0, 1, 0)
                
                if(hero:HasModifier("modifier_hero_waitting") == false) then
                    local waittingModifier = hero:AddNewModifier(hero, nil, "modifier_hero_waitting", {})
                    if(waittingModifier ~= nil and hero.price ~= nil) then
                        waittingModifier:SetStackCount(hero.price)
                    end
                end

                GameRules.DW.StopAbilities(hero)
                
                if (GameRules.DW.Battles[#GameRules.DW.Battles].Result == "RadWin" and hero:GetTeam() == DOTA_TEAM_GOODGUYS)
                    or (GameRules.DW.Battles[#GameRules.DW.Battles].Result == "DireWin" and hero:GetTeam() == DOTA_TEAM_BADGUYS) then
                    hero:StartGesture(ACT_DOTA_VICTORY)
                else
                    hero:StartGesture(ACT_DOTA_DEFEAT)
                end
                
                local heroName = hero:GetName()
                
                if(hero:GetName() == "npc_dota_hero_silencer") then
                    DDW:RestrictSilencerStackCount(hero)
                end
                
                if(hero:GetName() == "npc_dota_hero_clinkz") then
                    DDW:RestrictClinkzStackCount(hero)
                end

                if(hero.tetherTarget ~= nil) then
                    hero.tetherTarget = nil
                end

                if(hero.infestHost ~= nil) then
                    hero.infestHost = nil
                end

                if(hero.replicateHost ~= nil) then
                    hero.replicateHost = nil
                end
                
                if(hero.toggleOffList ~= nil) then
                    for _, v in pairs(hero.toggleOffList) do
                        if(v ~= nil and v:IsNull() == false and v:GetToggleState() == true) then
                            v:ToggleAbility()
                        end
                    end
                end
                
                if(hero.IsRealHero ~= nil and hero:IsRealHero()) then
                    if(hero:GetName() ~= "npc_dota_hero_silencer" and hero.baseIntellect ~= nil and hero:GetBaseIntellect() < hero.baseIntellect) then
                        hero:SetBaseIntellect(hero.baseIntellect)
                    end
                end
                
                GameRules.DW.DoTeleporting(playerHero, hero, startPosition, targetPosition, forwardVector, 3, nil, function()
                    if hero ~= nil and hero:IsNull() == false then
                        if(hero:IsAlive() == false and GameRules.DW.PlayerList[playerId].Life > 0) then
                            if(hero.IsRealHero ~= nil and hero:IsRealHero()) then
                                hero:SetRespawnPosition(hero.sourcePos)
                                hero:RespawnHero(false, false)
                            else
                                hero:RespawnUnit()
                            end
                            CreateParticle(ParticleRes.HERO_RESPAWN, PATTACH_ABSORIGIN_FOLLOW, hero, 2)
                        end
                        
                        if(hero ~= nil and hero:IsNull() == false) then
                            hero:RemoveGesture(ACT_DOTA_VICTORY)
                            hero:RemoveGesture(ACT_DOTA_DEFEAT)
                            
                            hero:SetControllableByPlayer(-1, true)
                            hero:SetTeam(playerInfo.TeamId)
                            hero:Hold()
                            hero:SetHealth(hero:GetMaxHealth())
                            hero:SetMana(hero:GetMaxMana())
                            hero:Purge(true, true, false, true, true)
                            hero:SetForwardVector(Vector(0, 1, 0))

                            if(hero:IsAlive()) then
                                ExecuteOrderFromTable({
                                    UnitIndex = hero:entindex(),
                                    OrderType = DOTA_UNIT_ORDER_STOP
                                })
                            end

                            GameRules.DW.RemoveMeepoItems(hero)
                            GameRules.DW.CheckLostTalent(hero)

                            if(hero.CalculateStatBonus ~= nil) then
                                hero:CalculateStatBonus()
                            end

                            if(hero:HasModifier("modifier_hero_waitting") == false) then
                                local waittingModifier = hero:AddNewModifier(hero, nil, "modifier_hero_waitting", {})
                                if(waittingModifier ~= nil and hero.price ~= nil) then
                                    waittingModifier:SetStackCount(hero.price)
                                end
                            end

                            if(hero.damage == nil) then
                                hero.damage = 0
                            end

                            if(hero.damageTake == nil) then
                                hero.damageTake = 0
                            end
                            
                            if(hero.IsRealHero ~= nil and hero:IsRealHero()) then
                                table.insert(damageTable, {heroName = hero:GetName(), heroLevel = hero:GetLevel(), damage = string.format("%.2f", hero.damage), damageTake = string.format("%.2f", hero.damageTake)})
                            end

                            if(hero:GetName() ~= "npc_dota_hero_lone_druid" and hero.bear ~= nil and hero.bear:IsNull() == false) then
                                GameRules.DW.CleanNoOwnerBear(playerId, hero.bear)
                                hero.bear = nil
                            end
                        end
                    end
                end)
            end
        end
    end
    
    CreateTimer(function()
        table.sort(damageTable, function(a, b) return tonumber(a.damage) > tonumber(b.damage) end)
        SendMessageToPlayer(playerId, "DAMAGE_TABLE", damageTable)
    end, 6.5)
    
    CreateTimer(function()
        local camaraPos = GameRules.DW.GetPlayerOrigin(playerId)
        if(camaraPos ~= nil) then
            SendMessageToPlayer(playerId, "CAMERA_FOLLOW", {location = camaraPos + Vector(560, 480)})
        end
    end, 1.5)
end

function DDW:RestrictSilencerStackCount(hero)
    if(hero == nil or hero:IsNull()) then
        return
    end
    
    local stackModifier = hero:FindModifierByName("modifier_silencer_glaives_of_wisdom")
    
    if(stackModifier == nil) then
        return
    end
    
    local stackCount = stackModifier:GetStackCount()
    local maxStackCount = 200
    
    if(stackCount > maxStackCount) then
        local overstepInt = stackCount - maxStackCount
        hero:SetBaseIntellect(hero:GetBaseIntellect() - overstepInt)
        stackModifier:SetStackCount(maxStackCount)
    end
end

function DDW:RestrictClinkzStackCount(hero)
    if(hero == nil or hero:IsNull()) then
        return
    end
    
    local allModifiers = hero:FindAllModifiers()
    
    local stackModifier = hero:FindModifierByName("modifier_clinkz_death_pact_permanent_buff")
    
    if(stackModifier == nil) then
        return
    end
    
    local stackCount = stackModifier:GetStackCount()
    local maxStackCount = 400
    
    if(stackCount > maxStackCount) then
        local overstepDamage = stackCount - maxStackCount
        stackModifier:SetStackCount(maxStackCount)
    end
end

function DDW:OnSellHeroConfirmResp(data)
    local playerId = data.PlayerID
    local entindex = data.entindex
    local moveToRecycleBin = data.moveToRecycleBin == 1
    local hero = EntIndexToHScript(entindex)

    local playerInfo = GameRules.DW.PlayerList[playerId]
    if(playerInfo ~= nil and hero ~= nil and hero:IsNull() == false) then
        local playerHero = playerInfo.Hero
        if(playerHero == nil or playerHero:IsNull() or playerHero:IsAlive() == false) then
            SendMessageToPlayer(data.PlayerID, "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
            return
        end

        local sellHeroAbility = playerHero:FindAbilityByName("ability_hero_sell")
        if(sellHeroAbility == nil or sellHeroAbility:IsActivated() == false) then
            SendMessageToPlayer(data.PlayerID, "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
            return
        end

        local gridVector = GameRules.DW.FindGridInfo(playerId, hero)
        if(gridVector ~= nil) then
            GameRules.DW.SellHero(gridVector, playerHero, moveToRecycleBin)
        end
    end
end

function DDW:OnShowDamageStatRequest(data)
    local playerInfo = GameRules.DW.PlayerList[data.PlayerID]
    if(playerInfo == nil) then
        return
    end

    if(playerInfo.IsVip == false) then
        return
    end

    local statPlayerId = data.statPlayerId
    local playerInfoStat = GameRules.DW.PlayerList[statPlayerId]
    if(playerInfoStat == nil) then
        return
    end

    local damageTable = {}
    for x = 1, 8 do
        for y = 1, 8 do
            local hero = GameRules.DW.GetGridInfo(statPlayerId, x, y)
            if hero ~= nil and hero:IsNull() == false then
                if(hero.damage == nil) then
                    hero.damage = 0
                end

                if(hero.damageTake == nil) then
                    hero.damageTake = 0
                end
                
                if(hero.IsRealHero ~= nil and hero:IsRealHero()) then
                    table.insert(damageTable, {heroName = hero:GetName(), heroLevel = hero:GetLevel(), damage = string.format("%.2f", hero.damage), damageTake = string.format("%.2f", hero.damageTake)})
                end
            end
        end
    end
    
    if(#damageTable > 0) then
        table.sort(damageTable, function(a, b) return tonumber(a.damage) > tonumber(b.damage) end)
        SendMessageToPlayer(data.PlayerID, "DAMAGE_TABLE", damageTable)
    end
end

function DDW:OnAlertHeroRequest(data)
    local playerId = data.PlayerID
    local index = tonumber(data.index)
    local fromRecycle = data.fromRecycle
    local language = data.language

    local playerInfo = GameRules.DW.PlayerList[playerId]
    if(playerInfo == nil) then
        return
    end

    local targetHero = nil

    if(fromRecycle == 1) then
        if GameRules.DW.RecycleHero[playerId] == nil or table.count(GameRules.DW.RecycleHero[playerId]) < index then
            return
        end
        targetHero = GameRules.DW.RecycleHero[playerId][index]
    else
        if GameRules.DW.RollPanelHero[playerId] == nil or table.count(GameRules.DW.RollPanelHero[playerId]) < index then
            return
        end
        targetHero = GameRules.DW.RollPanelHero[playerId][index]
    end
    
    if(targetHero == nil) then return end

    local localizedHeroName = LocalizeHero(targetHero.name, language)
    local sayMsg = localizedHeroName .. " Lv" .. targetHero.level .. " $" .. targetHero.price

    if(fromRecycle == 1) then
        sayMsg = "[REC] " .. sayMsg
    else
        sayMsg = "[BUY] " .. sayMsg
    end

    if(GameRules.DW.MapName == "dawn_war_coop") then
        PlayerSay(sayMsg, data.PlayerID, true)
    else
        PlayerSay(sayMsg, data.PlayerID, false)
    end
end

function DDW:OnReloadRecuritPanel(data)
    local playerId = data.PlayerID

    local playerInfo = GameRules.DW.PlayerList[playerId]
    if(playerInfo == nil) then
        return
    end

    SendMessageToPlayer(playerId, "SHOW_ROLL_PANEL", {items = GameRules.DW.RollPanelHero[playerId], recycles = GameRules.DW.RecycleHero[playerId], isUpdate = false})
end

function DDW:OnSellNeutralConfrimResp(data)
    local playerId = data.PlayerID
    local entindex = data.entindex
    local confirmSell = data.confirmSell == 1
    local neutralItem = EntIndexToHScript(entindex)

    local playerInfo = GameRules.DW.PlayerList[playerId]
    if(playerInfo ~= nil and neutralItem ~= nil and neutralItem:IsNull() == false) then
        local playerHero = playerInfo.Hero
        if(playerHero == nil or playerHero:IsNull() or playerHero:IsAlive() == false) then
            SendMessageToPlayer(data.PlayerID, "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
            return
        end

        if(confirmSell == false) then
            if(playerInfo.NeutralItemSwapCount == nil or playerInfo.NeutralItemSwapCount >= GameRules.DW.MaxNeutralItemSwapTimes) then
                SendMessageToPlayer(data.PlayerID, "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
                return
            end
        end

        local parent = neutralItem:GetParent()
        if(parent == nil or parent.GetUnitName == nil or parent:GetUnitName() ~= "npc_dota_hero_elf") then
            SendMessageToPlayer(data.PlayerID, "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
            return
        end

        local neutralName = neutralItem:GetName()
        playerHero:RemoveItem(neutralItem)

        if(confirmSell) then
            local player = playerHero:GetPlayerOwner()
            if(player ~= nil and player:IsNull() == false) then
                SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, playerHero, 2500, nil)
                PlayerResource:ModifyGold(playerId, 2500, false, DOTA_ModifyGold_Unspecified)
            end
        else
            local neutralLevel = -1
            for i, v in pairs(GameRules.DW.NeutralItems) do
                if(table.contains(v, neutralName)) then
                    neutralLevel = i
                    break
                end
            end
            GameRules.DW.DropNeutralItemForPlayer(playerInfo.Hero, neutralLevel)
            playerInfo.NeutralItemSwapCount = playerInfo.NeutralItemSwapCount + 1
        end
    end
end

function DDW:OnToggleAbilityStatus(data)
    local playerId = data.PlayerID
    local entindex = data.entindex
    local abilityIndex = data.abilityIndex

    if(playerId == nil or entindex == nil or abilityIndex == nil) then
        return
    end

    local hero = EntIndexToHScript(data.entindex)
    if(hero == nil or hero:IsNull()) then
        return
    end

    if(hero.GetPlayerOwnerID == nil or hero.IsRealHero == nil or hero:IsRealHero() == false) then
        return
    end

    if(hero:GetPlayerOwnerID() ~= playerId) then
        return
    end

    local unitName = hero:GetUnitName()
    if(unitName == "npc_dota_hero_elf" or unitName == "npc_dota_hero_invoker") then
        return
    end

    if(hero:HasModifier("modifier_hero_waitting") == false) then
        return
    end

    local ability = EntIndexToHScript(data.abilityIndex)
    if(ability ~= nil and ability:IsNull() == false and ability:GetLevel() > 0) then
        if(ability:IsPassive()) then
            return
        end

        if(ability:IsActivated() == false) then
            ability:SetActivated(true)
            ability:EndCooldown()
            ability.IsInactiveByPlayer = false
        else
            ability:SetActivated(false)
            ability:EndCooldown()
            ability.IsInactiveByPlayer = true
        end
    end
end