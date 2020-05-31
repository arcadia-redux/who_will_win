require 'utils'

KV_DROP_ITEMS = LoadKeyValues("scripts/kv/drop_items.txt")
KV_NEUTRAL_ITEMS = LoadKeyValues("scripts/npc/neutral_items.txt")
KV_CUSTOM_ABILITIES = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
KV_BAN_ABILITIES = LoadKeyValues("scripts/kv/ban_abilities.txt")
KV_PRIORITY_STUDY_ABILITIES = LoadKeyValues("scripts/kv/priority_study_abilities.txt")
KV_SPELL_IMMUNITY_ABILITIES = LoadKeyValues("scripts/kv/spell_immunity_abilities.txt")

AllTeamIdx = {DOTA_TEAM_CUSTOM_1, DOTA_TEAM_CUSTOM_2, DOTA_TEAM_CUSTOM_3, DOTA_TEAM_CUSTOM_4,
DOTA_TEAM_CUSTOM_5, DOTA_TEAM_CUSTOM_6, DOTA_TEAM_CUSTOM_7, DOTA_TEAM_CUSTOM_8}

AllTeamIdxCoop = {DOTA_TEAM_CUSTOM_1, DOTA_TEAM_CUSTOM_2, DOTA_TEAM_CUSTOM_3, DOTA_TEAM_CUSTOM_4}

if GameRules.DW == nil then
    GameRules.DW = {}
    GameRules.DW.GameId = ""
    GameRules.DW.SVR = ""
    GameRules.DW.SVR_KEY = ""
    GameRules.DW.MapName = "dawn_war"
    GameRules.DW.RandomDraftHeros = {}
    GameRules.DW.RollPanelHero = {}
    GameRules.DW.RecycleHero = {}
    GameRules.DW.DefaultSkinId = "11461"
    GameRules.DW.TeamGridOrigin = {
        [DOTA_TEAM_CUSTOM_1] = Vector(-5130, -660, 256),
        [DOTA_TEAM_CUSTOM_2] = Vector(-2080, -660, 256),
        [DOTA_TEAM_CUSTOM_3] = Vector(990, -660, 256),
        [DOTA_TEAM_CUSTOM_4] = Vector(4100, -660, 256),
        [DOTA_TEAM_CUSTOM_5] = Vector(-5130, -3180, 256),
        [DOTA_TEAM_CUSTOM_6] = Vector(-2080, -3180, 256),
        [DOTA_TEAM_CUSTOM_7] = Vector(990, -3180, 256),
        [DOTA_TEAM_CUSTOM_8] = Vector(4100, -3180, 256)
    }

    GameRules.DW.TeamGridOriginCoop = {
        [DOTA_TEAM_CUSTOM_1] = {[1] = Vector(-5130, -660, 256), [2] = Vector(-2080, -660, 256)},
        [DOTA_TEAM_CUSTOM_2] = {[1] = Vector(990, -660, 256), [2] = Vector(4100, -660, 256)},
        [DOTA_TEAM_CUSTOM_3] = {[1] = Vector(-5130, -3180, 256), [2] = Vector(-2080, -3180, 256)},
        [DOTA_TEAM_CUSTOM_4] = {[1] = Vector(990, -3180, 256), [2] = Vector(4100, -3180, 256)}
    }

    GameRules.DW.TeamPositionInfo = {
        [DOTA_TEAM_CUSTOM_1] = {[1] = -1, [2] = -1},
        [DOTA_TEAM_CUSTOM_2] = {[1] = -1, [2] = -1},
        [DOTA_TEAM_CUSTOM_3] = {[1] = -1, [2] = -1},
        [DOTA_TEAM_CUSTOM_4] = {[1] = -1, [2] = -1}
    }
    
    GameRules.DW.TeamColor = {
        [DOTA_TEAM_CUSTOM_1] = {0, 120, 60},
        [DOTA_TEAM_CUSTOM_2] = {220, 220, 50},
        [DOTA_TEAM_CUSTOM_3] = {110, 70, 180},
        [DOTA_TEAM_CUSTOM_4] = {0, 110, 210},
        [DOTA_TEAM_CUSTOM_5] = {245, 143, 152},
        [DOTA_TEAM_CUSTOM_6] = {101, 212, 19},
        [DOTA_TEAM_CUSTOM_7] = {27, 192, 216},
        [DOTA_TEAM_CUSTOM_8] = {141, 208, 243}
    }
    
    GameRules.DW.GoodGuys = {}
    GameRules.DW.BadGuys = {}
    GameRules.DW.HasAnnounceBattleResult = false
    
    GameRules.DW.GridInfo = {}
    GameRules.DW.BattlePosition = {
        Vector(-2700, 3460, 128),
        Vector(-5000, 3460, 128),
        Vector(2700, 2270, 128),
        Vector(5000, 2270, 128)
    }

    GameRules.DW.NeutralItems = {
        [1] = {"item_horizon", "item_timeless_relic", "item_princes_knife", "item_vampire_fangs", "item_mind_breaker", "item_ring_of_aquila"},
        [2] = {"item_panic_button", "item_ocean_heart", "item_witless_shako", "item_titan_sliver", "item_pupils_gift", "item_vambrace"},
        [3] = {"item_spell_prism", "item_orb_of_destruction", "item_illusionsts_cape", "item_nether_shawl", "item_havoc_hammer", "item_demonicon"},
        [4] = {"item_dragon_scale", "item_mirror_shield", "item_broom_handle", "item_grove_bow", "item_imp_claw", "item_seer_stone_new"},
        [5] = {"item_helm_of_the_undying", "item_ballista", "item_ex_machina", "item_paladin_sword", "item_minotaur_horn", "item_spy_gadget"},
    }

    GameRules.DW.MaxNeutralItemSwapTimes = 5
    
    repeat
        local rndHeroName = table.random(AllHeroNames)
        if (table.find(GameRules.DW.RandomDraftHeros, "name", rndHeroName) == nil) then
            if(#GameRules.DW.RandomDraftHeros >= 32) then
                table.insert(GameRules.DW.RandomDraftHeros, {name = rndHeroName, price = 10, level = 1, valid = 0})
            else
                table.insert(GameRules.DW.RandomDraftHeros, {name = rndHeroName, price = 2, level = 1, valid = 1})
            end
        end
    until(#GameRules.DW.RandomDraftHeros >= 40)
    
    GameRules.DW.RoundNo = 0
    GameRules.DW.Stage = 0
    GameRules.DW.StageStartTime = 0
    GameRules.DW.StageName = {"PREPARE", "PREFIGHT", "FIGHTING", "NEWROUND"}
    GameRules.DW.StageTime = {35, 4, 75, 6}
    GameRules.DW.ExtraCountdown = 0
    GameRules.DW.Battles = {}
    GameRules.DW.IsGameOver = false
    GameRules.DW.IsDuelStage = false
    GameRules.DW.EnterDuelRoundNo = 0
    GameRules.DW.LastRank = 8
    GameRules.DW.GameStartTime = nil
    GameRules.DW.BattleFightPosition = Vector(0, 2800, 24)
    GameRules.DW.FountainGood = Vector(-5300, 2900, 128)
    GameRules.DW.FountainBad = Vector(5300, 2900, 128)
    GameRules.DW.RemainingTeamCount = 8
    GameRules.DW.ToBeRemovedUnits = {}
    GameRules.DW.PlayerList = {}
    GameRules.DW.BattleUnitList = {}
    GameRules.DW.BattlePlayers = {}
    for playerId = 0, 7 do
        local playerInfo = {}
        playerInfo.Hero = nil
        playerInfo.DropItems = {}
        playerInfo.NeutralItems = {}
        playerInfo.NeutralLevel = 1
        playerInfo.NeutralItemDropCount = 0
        playerInfo.NeutralItemSwapCount = 0
        playerInfo.IsEmpty = true
        playerInfo.IsOnline = false
        playerInfo.DisconnectedRoundCount = 0
        playerInfo.SteamId = ""
        playerInfo.SteamAccountId = ""
        playerInfo.PlayerName = ""
        playerInfo.IsBot = false
        playerInfo.BattleCount = 0
        playerInfo.Life = 100
        playerInfo.IsAlive = true
        playerInfo.Heros = {}
        playerInfo.LastTime = "00:00:00"
        playerInfo.Rank = 0
        playerInfo.IsRankAdjusted = false
        playerInfo.Kills = 0
        playerInfo.Assists = 0
        playerInfo.LockRoll = 0
        playerInfo.TeamId = DOTA_TEAM_NOTEAM
        playerInfo.TeamPosition = 0
        playerInfo.MaxSupply = 0
        playerInfo.CurrentSupply = 0
        playerInfo.BattleSupplyDiff = -1
        playerInfo.ConDefeatCount = 0
        playerInfo.LastBattleResult = ""
        playerInfo.LastAgainstTeam = DOTA_TEAM_NOTEAM
        playerInfo.Grade = 0
        playerInfo.IsVip = 0
        playerInfo.HasArcana = 0
        playerInfo.SkinInit = 0
        playerInfo.SkinId = 12147
        playerInfo.IsFly = false
        playerInfo.ReadyState = 0
        playerInfo.GoldBackup = 0
        playerInfo.GoldTotal = 500
        playerInfo.ControlledHero = nil
        playerInfo.TeleportSoundCount = 0
        playerInfo.UsedDieProtect = false
        playerInfo.SelectedBattlePosition = 0
        playerInfo.MarkedHeroes = {}
        GameRules.DW.PlayerList[playerId] = playerInfo
        GameRules.DW.RollPanelHero[playerId] = {}
        GameRules.DW.RecycleHero[playerId] = {}
    end
end

function GameRules.DW.GiveHeroGoldBounty(attackerUnit, killedHero)
    if(killedHero == nil or killedHero:IsNull() or killedHero.GetTeamNumber == nil) then
        return
    end

    if(attackerUnit == nil or attackerUnit:IsNull() or attackerUnit.GetTeamNumber == nil) then
        return
    end

    local attackerTeamId = attackerUnit:GetTeamNumber()
    if(attackerTeamId ~= DOTA_TEAM_GOODGUYS and attackerTeamId ~= DOTA_TEAM_BADGUYS) then
        return
    end

    local killedTeamId = killedHero:GetTeamNumber()
    if(killedTeamId ~= DOTA_TEAM_GOODGUYS and killedTeamId ~= DOTA_TEAM_BADGUYS) then
        return
    end

    if(killedHero.IsRealHero ~= nil and killedHero:IsRealHero() == false) then
        return
    end

    if(attackerTeamId == killedTeamId) then
        return
    end

    local goldBountyTotal = 250 + killedHero:GetLevel() * 15

    local attackerPlayerId = -1
    if(attackerUnit.GetPlayerID ~= nil) then
        attackerPlayerId = attackerUnit:GetPlayerID()
    end

    for i = 1, #GameRules.DW.BattlePlayers do
        local battleTeam = i % 2 + 2
        local playerId = GameRules.DW.BattlePlayers[i]
        local playerInfo = GameRules.DW.PlayerList[playerId]
        if(playerInfo ~= nil) then
            if(battleTeam == attackerTeamId) then
                local goldBounty = goldBountyTotal
                if(GameRules.DW.IsDuelStage == false or GameRules.DW.MapName == "dawn_war_coop") then
                    goldBounty = math.floor(goldBounty * 0.5)
                end

                if(attackerUnit.HasItemInInventory ~= nil and attackerUnit:HasItemInInventory("item_pirate_hat_new")) then
                    if(playerInfo.SelectedBattlePosition == 1) then
                        goldBounty = goldBounty + 150
                    else
                        goldBounty = goldBounty + 100
                    end
                end

                PlayerResource:ModifyGold(playerId, goldBounty, true, DOTA_ModifyGold_Unspecified)

                if(playerInfo.Hero ~= nil and playerInfo.Hero:IsNull() == false and playerInfo.Hero.GetPlayerOwner ~= nil) then
                    local player = playerInfo.Hero:GetPlayerOwner()
                    if(player ~= nil and player:IsNull() == false) then
                        SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, killedHero, goldBounty, nil)
                    end
                end
            end
        end
    end
end

function GameRules.DW.SetUnitOnClearGround(unit)
    CreateTimer(function()
        if(unit ~= nil and unit:IsNull() == false) then
            unit:SetAbsOrigin(Vector(unit:GetAbsOrigin().x, unit:GetAbsOrigin().y, GetGroundPosition(unit:GetAbsOrigin(), unit).z))
            FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
            ResolveNPCPositions(unit:GetAbsOrigin(), 64)
        end
    end, FrameTime())
end

function GameRules.DW.SetGridInfo(playerId, x, y, hero)
    if GameRules.DW.GridInfo[playerId] == nil then
        GameRules.DW.GridInfo[playerId] = {}
    end
    
    if GameRules.DW.GridInfo[playerId][x] == nil then
        GameRules.DW.GridInfo[playerId][x] = {}
    end
    
    GameRules.DW.GridInfo[playerId][x][y] = hero
end

function GameRules.DW.MoveToGrid(playerId, x, y, hero)
    local existGridInfo = GameRules.DW.FindGridInfo(playerId, hero)
    if(existGridInfo ~= nil) then
        GameRules.DW.SetGridInfo(playerId, existGridInfo.x, existGridInfo.y, nil)
    end
    
    GameRules.DW.SetGridInfo(playerId, x, y, hero)
end

function GameRules.DW.GetGridInfo(playerId, x, y)
    if GameRules.DW.GridInfo[playerId] == nil or GameRules.DW.GridInfo[playerId][x] == nil then
        return nil
    end
    
    return GameRules.DW.GridInfo[playerId][x][y]
end

function GameRules.DW.FindSameHero(playerId, heroName, level, comparingUnit)
    for x = 1, 8 do
        for y = 1, 8 do
            local hero = GameRules.DW.GetGridInfo(playerId, x, y)
            if hero ~= nil and hero:IsNull() == false and hero ~= comparingUnit then
                if(hero:GetUnitName() == HeroNamePrefix .. heroName and hero:GetLevel() == level) then
                    return hero
                end
            end
        end
    end
    
    return nil
end

function GameRules.DW.FindSameHeroWithoutLevel(playerId, heroName)
    for x = 1, 8 do
        for y = 1, 8 do
            local hero = GameRules.DW.GetGridInfo(playerId, x, y)
            if hero ~= nil and hero:IsNull() == false then
                if(hero:GetUnitName() == HeroNamePrefix .. heroName) then
                    return hero
                end
            end
        end
    end
    
    return nil
end

function GameRules.DW.FindSameHeroFullname(playerId, heroFullName)
    for x = 1, 8 do
        for y = 1, 8 do
            local hero = GameRules.DW.GetGridInfo(playerId, x, y)
            if hero ~= nil and hero:IsNull() == false then
                if(hero:GetUnitName() == heroFullName) then
                    return hero
                end
            end
        end
    end
    
    return nil
end

function GameRules.DW.FindGridInfo(playerId, heroEntity)
    for x = 1, 8 do
        for y = 1, 8 do
            local hero = GameRules.DW.GetGridInfo(playerId, x, y)
            if hero ~= nil and hero:IsNull() == false and hero == heroEntity then
                return Vector(x, y)
            end
        end
    end
    return nil
end

function GameRules.DW.CleanNoOwnerBear(playerId, bearEntity)
    for x = 1, 8 do
        for y = 1, 8 do
            local hero = GameRules.DW.GetGridInfo(playerId, x, y)
            if hero ~= nil and hero:IsNull() == false and hero:GetName() == "npc_dota_lone_druid_bear" then
                if(hero == bearEntity) then
                    GameRules.DW.GridInfo[playerId][x][y] = nil
                    for slotIndex = 0, 16 do
                        local item = hero:GetItemInSlot(slotIndex)
                        if item ~= nil then
                            GameRules.DW.DropItem(hero, item)
                        end
                    end
                    UTIL_Remove(hero)
                end
            end
        end
    end
end

function GameRules.DW.RemoveHeroFromGrid(playerHero, gridVector, itemInheritor)
    if(playerHero == nil or playerHero:IsNull()) then
        return
    end
    
    local playerId = playerHero:GetPlayerID()
    local unit = GameRules.DW.GetGridInfo(playerId, gridVector.x, gridVector.y)
    
    if (unit ~= nil and unit:IsNull() == false) then
        CreateParticle(ParticleRes.HERO_REMOVE, PATTACH_ABSORIGIN_FOLLOW, unit, 5)
        EmitSoundOn(SoundRes.HERO_REMOVE, playerHero)
        
        for slotIndex = 0, 16 do
            local item = unit:GetItemInSlot(slotIndex)
            if item ~= nil then
                local itemName = item:GetName()
                if (itemInheritor ~= nil and itemInheritor:IsNull() == false) then
                    if(itemInheritor:HasRoomForItem(itemName, true, true) <= 2) then
                        local newItem = itemInheritor:AddItemByName(itemName)
                        newItem:SetPurchaseTime(item:GetPurchaseTime())
                        newItem:SetCurrentCharges(item:GetCurrentCharges())
                    else
                        GameRules.DW.DropItem(unit, item)
                    end
                else
                    GameRules.DW.DropItem(unit, item)
                end
            end
        end

        if(unit.bear ~= nil and unit.bear:IsNull() == false) then
            GameRules.DW.CleanNoOwnerBear(playerId, unit.bear)
        end

        local entireEntities = Entities:FindAllInSphere(Vector(0, 0, 0), 6500)

        SafeRemoveUnit(unit, entireEntities)

        GameRules.DW.SetGridInfo(playerId, gridVector.x, gridVector.y, nil)
        GameRules.DW.UpdatePlayerSupply(playerId)
    end
end

function GameRules.DW.DropItem(unit, item)
    if(unit ~= nil and unit:IsNull() == false and item ~= nil and item:IsNull() == false) then
        local itemName = item:GetName()
        if(itemName == nil) then
            return
        end

        local newItem = CreateItem(itemName, unit, unit)

        if(newItem ~= nil and newItem:IsNull() == false) then
            if(unit.GetPlayerID ~= nil) then
                newItem.ownerPlayerId = unit:GetPlayerID()
            end

            newItem:SetPurchaseTime(item:GetPurchaseTime())
            newItem:SetCurrentCharges(item:GetCurrentCharges())

            if(itemName == "item_bloodstone") then
                newItem.SavedCharges = item:GetCurrentCharges()
            end

            unit:RemoveItem(item)

            CreateItemOnPositionForLaunch(unit:GetAbsOrigin(), newItem)

            local dropPosition = GameRules.DW.FindSafeLaunchLootPosition(unit)
            if(dropPosition ~= nil) then
                newItem:LaunchLoot(false, 250, 0.5, dropPosition)
            else
                newItem:LaunchLoot(false, 250, 0.5, unit:GetAbsOrigin())
            end
        end
    end
end

function GameRules.DW.ShareItem(playerHero, item)
    if(playerHero ~= nil and playerHero:IsNull() == false and playerHero.GetPlayerID ~= nil and item ~= nil and item:IsNull() == false) then
        local itemName = item:GetName()
        local partnerId = GameRules.DW.GetCoopPartnerId(playerHero:GetPlayerID())
        local partnerPlayerInfo = nil
        if(partnerId ~= nil) then
            partnerPlayerInfo = GameRules.DW.PlayerList[partnerId]
        end

        if(partnerPlayerInfo == nil) then
            return false
        end

        if(partnerPlayerInfo.Life <= 0 or partnerPlayerInfo.IsEmpty) then
            return false
        end

        local owner = partnerPlayerInfo.Hero
        if(owner == nil or owner:IsNull() or owner:IsAlive() == false) then
            return false
        end

        if(itemName == nil) then
            return false
        end

        local newItem = CreateItem(itemName, owner, owner)

        if(newItem ~= nil and newItem:IsNull() == false) then
            if(owner.GetPlayerID ~= nil) then
                newItem.ownerPlayerId = owner:GetPlayerID()
            end
            newItem:SetPurchaseTime(item:GetPurchaseTime())
            newItem:SetCurrentCharges(item:GetCurrentCharges())

            if(itemName == "item_bloodstone") then
                newItem.SavedCharges = item:GetCurrentCharges()
            end

            playerHero:RemoveItem(item)

            CreateItemOnPositionForLaunch(partnerPlayerInfo.Hero:GetAbsOrigin(), newItem)

            local dropPosition = GameRules.DW.FindSafeLaunchLootPosition(partnerPlayerInfo.Hero)
            if(dropPosition ~= nil) then
                newItem:LaunchLoot(false, 250, 0.5, dropPosition)
            else
                newItem:LaunchLoot(false, 250, 0.5, partnerPlayerInfo.Hero:GetAbsOrigin())
            end

            return true
        end

        return false
    end
end

function GameRules.DW.GetHeroSupply(hero)
    if hero ~= nil and hero:IsNull() == false then
        if(hero.IsRealHero == nil or hero:IsRealHero() == false) then
            return 0
        end
        local level = hero:GetLevel()
        if(level >= 20) then
            return 5
        elseif(level >= 15) then
            return 4
        elseif(level >= 10) then
            return 3
        elseif(level >= 5) then
            return 2
        else
            return 1
        end
    end
    
    return 0
end

function GameRules.DW.GetHeroListSupply(heros)
    local totalSupply = 0
    for _, hero in pairs(heros) do
        totalSupply = totalSupply + GameRules.DW.GetHeroSupply(hero)
    end
    return totalSupply
end

function GameRules.DW.GetMaxSupply(playerId)
    local level = PlayerResource:GetLevel(playerId)
    if(level == nil or level < 1) then level = 1 end
    local supply = level + math.floor(level / 5)

    if(GameRules.DW.IsDuelStage) then
        if(level > 20) then
            supply = supply + (level - 20) * 1
        end
    end

    return supply
end

function GameRules.DW.GetCurrentSupply(playerId)
    local currentSupply = 0
    for x = 1, 8 do
        for y = 1, 8 do
            local hero = GameRules.DW.GetGridInfo(playerId, x, y)
            currentSupply = currentSupply + GameRules.DW.GetHeroSupply(hero)
        end
    end
    return currentSupply
end

function GameRules.DW.GetRollHeroGoldCost(playerId)
    local level = PlayerResource:GetLevel(playerId)
    if(level == nil or level < 1) then
        level = 1
    end
    return level * 10
end

function GameRules.DW.GetUpgradeLevelGoldCost(playerId)
    local level = PlayerResource:GetLevel(playerId)
    if(level == nil or level < 1) then
        level = 1
    end
    return level * 100
end

function GameRules.DW.UpdatePlayerSupply(playerId)
    if(GameRules.DW.PlayerList[playerId] ~= nil) then
        GameRules.DW.PlayerList[playerId].MaxSupply = GameRules.DW.GetMaxSupply(playerId)
        GameRules.DW.PlayerList[playerId].CurrentSupply = GameRules.DW.GetCurrentSupply(playerId)
    end
end

function GameRules.DW.GetHeroCountList(playerId, heroName)
    local level25Count = 0
    local level20Count = 0
    local level15Count = 0
    local level10Count = 0
    local level5Count = 0
    local level1Count = 0
    local recycleHeroes = GameRules.DW.RecycleHero[playerId]

    if(recycleHeroes ~= nil) then
        for i,v in pairs(recycleHeroes) do
            if(v.name == heroName) then
                if(v.level == 25 or v.level == 30) then
                    level25Count = level25Count + 1
                end
                if(v.level == 20) then
                    level20Count = level20Count + 1
                end
                if(v.level == 15) then
                    level15Count = level15Count + 1
                end
                if(v.level == 10) then
                    level10Count = level10Count + 1
                end
                if(v.level == 5) then
                    level5Count = level5Count + 1
                end
                if(v.level == 1) then
                    level1Count = level1Count + 1
                end
            end
        end
    end

    for x = 1, 8 do
        for y = 1, 8 do
            local hero = GameRules.DW.GetGridInfo(playerId, x, y)
            if hero ~= nil and hero:IsNull() == false then
                if(hero:GetUnitName() == HeroNamePrefix .. heroName) then
                    local level = hero:GetLevel()
                    if(level == 25 or level == 30) then
                        level25Count = level25Count + 1
                    end
                    if(level == 20) then
                        level20Count = level20Count + 1
                    end
                    if(level == 15) then
                        level15Count = level15Count + 1
                    end
                    if(level == 10) then
                        level10Count = level10Count + 1
                    end
                    if(level == 5) then
                        level5Count = level5Count + 1
                    end
                    if(level == 1) then
                        level1Count = level1Count + 1
                    end
                end
            end
        end
    end

    return level1Count, level5Count, level10Count, level15Count, level20Count, level25Count
end

function GameRules.DW.CheckRollHeroEnabled(playerId, heroName)
    local level1Count, level5Count, level10Count, level15Count, level20Count, level25Count = GameRules.DW.GetHeroCountList(playerId, heroName)

    local maxLevel25Count = 1
    if(heroName == "meepo") then
        maxLevel25Count = 4
    end

    if(level25Count >= maxLevel25Count) then
        return false
    end

    if(level20Count >= 2) then
        return false
    end

    if(level20Count >= 1 and level15Count >= 2) then
        return false
    end

    if(level20Count >= 1 and level15Count >= 1 and level10Count >= 2) then
        return false
    end

    if(level20Count >= 1 and level15Count >= 1 and level10Count >= 1 and level5Count >= 2) then
        return false
    end

    if(level20Count >= 1 and level15Count >= 1 and level10Count >= 1 and level5Count >= 1 and level1Count >= 2) then
        return false
    end

    return true
end

function GameRules.DW.ShowRollPanel(playerHero)
    if(table.count(GameRules.DW.RandomDraftHeros) == 0) then return end
    if(playerHero == nil or playerHero:IsNull()) then return end
    local playerId = playerHero:GetPlayerID()
    local playerInfo = GameRules.DW.PlayerList[playerId]
    if(playerInfo == nil) then return end
    
    local canPickedHero = {}
    for _, v in pairs(GameRules.DW.RandomDraftHeros) do
        local rollEnabled = GameRules.DW.CheckRollHeroEnabled(playerId, v.name)
        if(v.valid == 1 and rollEnabled) then
            table.insert(canPickedHero, v)
        end
    end

    local hasDiscountTalent = GameRules.DW.CheckHasTalent(playerInfo.Hero, "special_bonus_elf_15_2")

    local panelHeros = GameRules.DW.RollPanelHero[playerId]
    local playerLevel = playerHero:GetLevel()
    if(GameRules.DW.PlayerList[playerId].LockRoll == 0) then
        table.clear(panelHeros)
        
        for i = 1, 5 do
            local one = table.random(canPickedHero)
            if(one ~= nil) then
                table.remove_value(canPickedHero, one)
                local sellPrice = one.price
                local sellLevel = 1

                local level1Count, level5Count, level10Count, level15Count, level20Count = GameRules.DW.GetHeroCountList(playerId, one.name)

                if(level20Count >= 1 or level15Count >= 2 or (level15Count >= 1 and level10Count >= 2) or (level15Count >= 1 and level10Count >= 1 and level5Count >= 2) or (level15Count >= 1 and level10Count >= 1 and level5Count >= 1 and level1Count >= 2)) then
                    sellLevel = 15
                elseif(level15Count >= 1 or level10Count >= 2 or (level10Count >= 1 and level5Count >= 2) or (level10Count >= 1 and level5Count >= 1 and level1Count >= 2)) then
                    sellLevel = 10
                elseif(level10Count >= 1 or level5Count >= 1 or level1Count >= 2) then
                    sellLevel = 5
                else
                    sellLevel = 1
                end

                if(GameRules.DW.IsDuelStage and sellLevel < 10) then
                    sellLevel = 10
                end
                
                if(playerInfo.IsBot) then
                    if playerLevel >= 5 and sellLevel < 5 then
                        sellLevel = 5
                    end

                    if playerLevel >= 10 and sellLevel < 10 then
                        sellLevel = 10
                    end

                    if playerLevel >= 15 and sellLevel < 15 then
                        sellLevel = 15
                    end

                    if playerLevel >= 20 then
                        sellLevel = 20
                    end

                    if playerLevel >= 25 then
                        sellLevel = 25
                    end
                end

                if(hasDiscountTalent) then
                    sellPrice = math.floor(sellPrice * 0.75)
                end

                local isMarked = false
                if(table.exist(playerInfo.MarkedHeroes, one.name)) then
                    isMarked = true
                end

                local insertData = {name = one.name, price = sellPrice, level = sellLevel, sold = false, isMarked = isMarked}
                table.insert(panelHeros, insertData)
            end
        end
        
        GameRules.DW.RollPanelHero[playerId] = panelHeros
    end
    
    if(PlayerResource:IsFakeClient(playerId) == false) then
        SendMessageToPlayer(playerId, "SHOW_ROLL_PANEL", {items = panelHeros, recycles = GameRules.DW.RecycleHero[playerId], isUpdate = false})
    end
end

function GameRules.DW.GetPlayerOrigin(playerId)
    local playerInfo = GameRules.DW.PlayerList[playerId]
    if(playerInfo == nil) then
        return nil
    end

    local playerOrigin = nil

    if(GameRules.DW.MapName == "dawn_war_coop") then
        local teamPosInfo = GameRules.DW.TeamGridOriginCoop[playerInfo.TeamId]
        if(teamPosInfo ~= nil) then
            playerOrigin = teamPosInfo[playerInfo.TeamPosition]
        end
    else
        playerOrigin = GameRules.DW.TeamGridOrigin[playerInfo.TeamId]
    end

    return playerOrigin
end

function GameRules.DW.GetCoopPartnerId(playerId)
    for _, v in pairs(GameRules.DW.TeamPositionInfo) do
        if v[1] == playerId then
            return v[2]
        elseif v[2] == playerId then
            return v[1]
        end
    end
end

function GameRules.DW.GetGridVectorByPosition(position, playerId)
    local playerOrigin = GameRules.DW.GetPlayerOrigin(playerId)
    if(playerOrigin == nil) then
        return nil
    end

    local diff = position - playerOrigin + Vector(80, 80)
    local x = math.floor(diff.x / 160) + 1
    local y = math.floor(diff.y / 160) + 1
    if x < 1 then x = 1 end
    if y < 1 then y = 1 end
    if x > 8 then x = 8 end
    if y > 8 then y = 8 end
    return Vector(x, y)
end

function GameRules.DW.GetPositionByGridVector(gridVector, playerId)
    local playerOrigin = GameRules.DW.GetPlayerOrigin(playerId)
    if(playerOrigin == nil) then
        return nil
    end

    return Vector(playerOrigin.x + (gridVector.x - 1) * 160, playerOrigin.y + (gridVector.y - 1) * 160, 256)
end

function GameRules.DW.FindEmptyVector(playerId)
    for y = 1, 8 do
        for x = 1, 8 do
            if GameRules.DW.GetGridInfo(playerId, x, y) == nil then
                return Vector(x, y)
            end
        end
    end
    return nil
end

function GameRules.DW.FindEmptyVectorNearBy(gridVector, playerId)
    local nearestGrid = Vector(1, 1, 0)
    local nearestDistance = 100
    for y = 1, 8 do
        for x = 1, 8 do
            local checkVec = Vector(x, y, 0)
            local distance = math.abs((checkVec - gridVector):Length2D())
            if distance < nearestDistance and GameRules.DW.GetGridInfo(playerId, checkVec.x, checkVec.y) == nil then
                nearestGrid = checkVec
                nearestDistance = distance
            end
        end
    end
    
    if nearestDistance == 100 then
        return nil
    end
    
    return nearestGrid
end

function GameRules.DW.GetHerosByPlayerId(playerId)
    local heros = {}
    local count = 0
    for y = 1, 8 do
        for x = 1, 8 do
            local hero = GameRules.DW.GetGridInfo(playerId, x, y)
            if(hero ~= nil and hero:IsNull() == false) then
                table.insert(heros, hero)
            end
        end
    end
    return heros
end

function GameRules.DW.GetHeroCount(playerId)
    return #GameRules.DW.GetHerosByPlayerId(playerId)
end

function GameRules.DW.FindRandomInUseVector(playerId)
    local inUseCount = GameRules.DW.GetHeroCount(playerId)
    if(inUseCount == 0) then
        return nil
    end
    
    local pickIndex = RandomInt(1, inUseCount)
    
    local currentIndex = 1
    for y = 1, 8 do
        for x = 1, 8 do
            local hero = GameRules.DW.GetGridInfo(playerId, x, y)
            if(hero ~= nil and hero:IsNull() == false) then
                if(pickIndex == currentIndex) then
                    return Vector(x, y)
                end
                currentIndex = currentIndex + 1
            end
        end
    end
    
    return nil
end

function GameRules.DW.FindSafeLaunchLootPosition(unit)
    if(unit == nil or unit:IsNull() or unit.GetAbsOrigin == nil) then
        return nil
    end

    local dropPosition = nil
    local findTimes = 0
    local unitPos = unit:GetAbsOrigin()
    repeat
        dropPosition = unitPos + RandomVector(RandomInt(50, 200))
        findTimes = findTimes + 1
    until(GridNav:CanFindPath(unitPos, dropPosition) or findTimes > 5)
    
    if(findTimes > 5) then
        dropPosition = unitPos
    end

    return dropPosition
end

function GameRules.DW.DropItemForPlayer(playerHero, itemName)
    if(playerHero == nil or playerHero:IsNull()) then
        return nil
    end

    if(itemName == nil or itemName == '') then
        return nil
    end

    local newItem = CreateItem(itemName, playerHero, playerHero)

    if(newItem ~= nil and newItem:IsNull() == false) then
        newItem.ownerPlayerId = playerHero:GetPlayerID()
        newItem:SetPurchaseTime(0)
        CreateItemOnPositionForLaunch(playerHero:GetAbsOrigin(), newItem)
        
        local dropPosition = GameRules.DW.FindSafeLaunchLootPosition(playerHero)
        if(dropPosition ~= nil) then
            newItem:LaunchLoot(false, 250, 0.5, dropPosition)
        else
            newItem:LaunchLoot(false, 250, 0.5, playerHero:GetAbsOrigin())
        end
        return newItem
    end

    return nil
end

function GameRules.DW.DropRandomItemForPlayer(playerHero)
    if(playerHero == nil or playerHero:IsNull()) then
        return nil
    end

    local playerInfo = GameRules.DW.PlayerList[playerHero:GetPlayerID()]
    if(playerInfo == nil) then
        return nil
    end

    local itemLevel = math.floor(GameRules.DW.RoundNo / 5) + 1
    if(itemLevel < 1) then
        itemLevel = 1
    end

    if(itemLevel > 5) then
        itemLevel = 5
    end

    if(itemLevel == 5) then
        if(RollPercentage(50)) then
            itemLevel = 4
        end
    end

    local itemName = ""
    local items = KV_DROP_ITEMS[tostring(itemLevel)]
    if(items ~= nil) then
        local findTimes = 0
        repeat
            itemName = table.random(items)
            findTimes = findTimes + 1
        until(table.contains(playerInfo.DropItems, itemName) == false or findTimes > 20)
    end

    if(itemName ~= nil and itemName ~= "") then
        GameRules.DW.DropItemForPlayer(playerHero, itemName)
        table.insert(playerInfo.DropItems, itemName)
    end
end

function GameRules.DW.DropNeutralItemForPlayer(playerHero, replacingLevel)
    if(playerHero == nil or playerHero:IsNull()) then
        return nil
    end

    local playerInfo = GameRules.DW.PlayerList[playerHero:GetPlayerID()]
    if(playerInfo == nil) then
        return nil
    end

    local neutralLevel = playerInfo.NeutralLevel
    if(neutralLevel > 5) then
        neutralLevel = RandomInt(1, 5)
    end

    if(replacingLevel > 0) then
        neutralLevel = replacingLevel
    end

    local itemName = ""
    local items = GameRules.DW.NeutralItems[neutralLevel]
    if(items ~= nil) then
        local findTimes = 0
        repeat
            itemName = table.random(items)
            findTimes = findTimes + 1
        until(table.contains(playerInfo.NeutralItems, itemName) == false or findTimes > 20)
    end

    if(itemName ~= nil and itemName ~= "") then
        GameRules.DW.DropItemForPlayer(playerHero, itemName)
        table.insert(playerInfo.NeutralItems, itemName)
        if(replacingLevel <= 0) then
            playerInfo.NeutralLevel = playerInfo.NeutralLevel + 1
            playerInfo.NeutralItemDropCount = playerInfo.NeutralItemDropCount + 1
        end
    end
end

function GameRules.DW.BuyHeroRequest(playerId, index, fromRecycle)
    local playerHero = GameRules.DW.PlayerList[playerId].Hero
    
    if(playerHero == nil or playerHero:IsNull()) then
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

    local rollAbility = playerHero:FindAbilityByName("ability_hero_roll")
    if(rollAbility == nil) then return end
    
    if(GameRules.DW.GetHeroCount(playerId) > 15 or GameRules.DW.GetCurrentSupply(playerId) > 45) then
        SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "HERO_COUNT_LIMIT"})
        return
    end
    
    if(PlayerResource:IsFakeClient(playerId) == false) then
        if(GameRules.DW.PlayerList[playerId].ReadyState == 2) then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
            return
        end
        
        if(rollAbility:IsActivated() == false) then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
            return
        end
        
        if(targetHero.sold) then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "SOLD_OUT"})
            return
        end

        local playerGold = PlayerResource:GetGold(playerId)
        if(playerGold == nil or playerGold < targetHero.price) then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "NOT_ENOUGH_GOLD"})
            return
        end
        
        if GameRules.DW.FindSameHero(playerId, targetHero.name, targetHero.level) == nil and
            GameRules.DW.GetCurrentSupply(playerId) > GameRules.DW.GetMaxSupply(playerId) then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "NOT_ENOUGH_SUPPLY"})
            return
        end
    end

    if GameRules.DW.CombineSameHero(playerHero, targetHero.name, targetHero.level, nil, targetHero.price) or
        GameRules.DW.CreateFightHero(playerHero, targetHero.name, targetHero.price, targetHero.level, targetHero.talent) then
        local playerInfo = GameRules.DW.PlayerList[playerId]
        GameRules.DW.UpdatePlayerSupply(playerId)
        targetHero.sold = true

        for i, recycleHero in pairs(GameRules.DW.RecycleHero[playerId]) do
            if(recycleHero.sold == true) then
                table.remove(GameRules.DW.RecycleHero[playerId], i)
                break
            end
        end

        PlayerResource:SpendGold(playerId, targetHero.price, DOTA_ModifyGold_AbilityCost)
        if(PlayerResource:IsFakeClient(playerId) == false) then
            SendMessageToPlayer(playerId, "SHOW_ROLL_PANEL",
            {items = GameRules.DW.RollPanelHero[playerId], recycles = GameRules.DW.RecycleHero[playerId], isUpdate = true})
        end
    end
end

function GameRules.DW.DeleteHeroFromRecycleBin(playerId, index)
    local playerHero = GameRules.DW.PlayerList[playerId].Hero
    
    if(playerHero == nil or playerHero:IsNull()) then
        return
    end

    local targetHero = GameRules.DW.RecycleHero[playerId][index]
    
    if(targetHero == nil) then return end

    table.remove(GameRules.DW.RecycleHero[playerId], index)
    
    SendMessageToPlayer(playerId, "SHOW_ROLL_PANEL", {items = GameRules.DW.RollPanelHero[playerId], recycles = GameRules.DW.RecycleHero[playerId], isUpdate = true})
end

function GameRules.DW.GetTalent(hero, abilityIndex)
    if(hero == nil or hero:IsNull() or hero.talent == nil) then
        return nil
    end
    
    for _, v in pairs(hero.talent) do
        if(v.id == abilityIndex) then
            return v
        end
    end
    
    return nil
end

function GameRules.DW.GetTalentLearnedCount(hero)
    if(hero == nil or hero:IsNull() or hero.talent == nil) then
        return 0
    end
    
    local count = 0
    
    for _, v in pairs(hero.talent) do
        if(v.status == 1) then
            count = count + 1
        end
    end
    
    return count
end

function GameRules.DW.GetCanLevelUpAbility(hero, isForLevelUp, includeTalent)
    if hero == nil or hero:IsNull() == true or hero:GetAbilityCount() == 0 then
        return nil
    end
    local canLevelUpAbilities = {}
    local heroLevel = hero:GetLevel()
    for i = 0, hero:GetAbilityCount() - 1 do
        local ability = hero:GetAbilityByIndex(i)
        if ability ~= nil then
            local nBehaviorFlags = ability:GetBehavior()
            local abilityName = ability:GetName()
            
            if(ability:IsHidden() == false) and
                bitContains(nBehaviorFlags, DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE) == false and
                abilityName ~= "invoker_invoke" and abilityName ~= "ogre_magi_unrefined_fireblast" and abilityName ~= "techies_minefield_sign" and
                GameRules.DW.CheckAbilityEnabled(ability) == true then
                local isTalent = string.find(ability:GetName(), "special_bonus_") ~= nil
                if(isForLevelUp) then
                    if(isTalent) then
                        if(includeTalent) then
                            local talent = GameRules.DW.GetTalent(hero, ability:GetAbilityIndex() + 1)
                            if(talent ~= nil and talent.status == 0 and heroLevel >= talent.reqLvl) then
                                table.insert(canLevelUpAbilities, ability)
                            end
                        end
                    elseif(ability:GetMaxLevel() > ability:GetLevel() and ability:GetHeroLevelRequiredToUpgrade() <= heroLevel and ability:IsStolen() == false) then
                        table.insert(canLevelUpAbilities, ability)
                    end
                else
                    if(isTalent == false) then
                        table.insert(canLevelUpAbilities, ability)
                    end
                end
            end
        end
    end

    return canLevelUpAbilities
end

function GameRules.DW.AutoUpgradeAbility(hero, addTalent)
    local canLevelUpAbilities = GameRules.DW.GetCanLevelUpAbility(hero, true, addTalent)
    if(canLevelUpAbilities == nil or #canLevelUpAbilities == 0) then
        return
    end
    
    if(#canLevelUpAbilities > 0) then
        local ability = nil
        for i, v in pairs(canLevelUpAbilities) do
            if(v:GetAbilityType() == ABILITY_TYPE_ULTIMATE or string.find(v:GetName(), "special_bonus_")) then
                ability = v
                break
            end
        end
        
        if(ability == nil) then
            for i, v in pairs(canLevelUpAbilities) do
                if(table.contains(KV_PRIORITY_STUDY_ABILITIES, v:GetName())) then
                    ability = v
                    break
                end
            end
        end

        if(ability == nil) then
            ability = canLevelUpAbilities[RandomInt(1, #canLevelUpAbilities)]
        end
        
        if(ability == nil) then
            return
        end
        
        hero:UpgradeAbility(ability)
        
        if(string.find(ability:GetName(), "special_bonus_") ~= nil) then
            local talent = GameRules.DW.GetTalent(hero, ability:GetAbilityIndex() + 1)
            if(talent ~= nil) then
                talent.status = 1
            end
        end
        
        if(bitContains(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_AUTOCAST)) then
            if ability:GetAutoCastState() == false then
                ability:ToggleAutoCast()
            end
        end
        
        GameRules.DW.CheckAbilityEnabled(ability)
    end
end

function GameRules.DW.CheckAbilityEnabled(ability)
    for _, v in pairs(KV_BAN_ABILITIES) do
        if v == ability:GetName() then
            ability:SetActivated(false)
            ability:SetHidden(true)
            return false
        end
    end
    return true
end

function GameRules.DW.CombineSameHero(playerHero, heroName, level, comparingUnit, price)
    if(playerHero == nil or playerHero:IsNull()) then
        return false
    end

    if(level >= 25) then
        return false
    end
    
    local teamId = playerHero:GetTeamNumber()
    local playerId = playerHero:GetPlayerID()
    
    local checkExsitHero = GameRules.DW.FindSameHero(playerId, heroName, level, comparingUnit)
    
    if(checkExsitHero ~= nil and checkExsitHero:IsNull() == false and checkExsitHero ~= comparingUnit and checkExsitHero.price ~= nil) then
        local level = checkExsitHero:GetLevel()
        local newLevel = level
        if(level == 1) then newLevel = 5 else newLevel = level + 5 end
        if(newLevel > 25) then newLevel = 25 end
        
        for i = 1, newLevel - level do
            checkExsitHero:HeroLevelUp(true)
            checkExsitHero:SetAbilityPoints(1)
            GameRules.DW.AutoUpgradeAbility(checkExsitHero, true)
        end
        
        if(newLevel ~= level) then
            checkExsitHero.price = checkExsitHero.price + price
        end

        local waittingModifier = checkExsitHero:FindModifierByName("modifier_hero_waitting")
        if(waittingModifier ~= nil and checkExsitHero.price ~= nil) then
            waittingModifier:SetStackCount(checkExsitHero.price)
        end
        
        if(newLevel ~= level and comparingUnit ~= nil and comparingUnit:IsNull() == false) then
            local gridVector = GameRules.DW.FindGridInfo(playerId, comparingUnit)
            if(gridVector ~= nil) then
                GameRules.DW.RemoveHeroFromGrid(playerHero, gridVector, checkExsitHero)
            end
        end

        local draftHero = table.find(GameRules.DW.RandomDraftHeros, "name", heroName)
        if(draftHero ~= nil) then
            draftHero.price = draftHero.price + GameRules.DW.GetHeroPriceIncresement(playerHero, newLevel)
        end
        
        if(newLevel < 25) then
            CreateTimer(function()
                if(playerHero ~= nil and playerHero:IsNull() == false and checkExsitHero ~= nil and checkExsitHero:IsNull() == false) then
                    GameRules.DW.CombineSameHero(playerHero, heroName, newLevel, checkExsitHero, checkExsitHero.price)
                end
            end, 0.5)
        else
            local playerInfo = GameRules.DW.PlayerList[playerId]
            if(playerInfo ~= nil) then
                ShowHeroMessage(playerInfo.SteamId, HeroNamePrefix .. heroName, "HERO_MESSAGE_COMBINED_25")
            end
        end
        
        return true
    end
    
    return false
end

function GameRules.DW.CreateFightHero(playerHero, heroName, price, level, talent)
    if(playerHero == nil or playerHero:IsNull()) then
        return false
    end
    
    local teamId = playerHero:GetTeamNumber()
    local playerId = playerHero:GetPlayerID()
    
    local vec2 = GameRules.DW.FindEmptyVector(playerId)
    if(vec2 == nil) then
        SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "NOT_ENOUGH_SPACE"})
        return false
    end
    
    local loc = GameRules.DW.GetPositionByGridVector(vec2, playerId)
    local heroUnit = CreateUnitByName(HeroNamePrefix .. heroName, loc, true, playerHero, playerHero, teamId)
    if(heroUnit == nil or heroUnit:IsNull()) then
        return false
    end
    heroUnit.price = price

    if(talent ~= nil) then
        for _, t in pairs(talent) do
            t.status = 0
        end
        heroUnit.talent = talent
    end

    local waittingModifier = heroUnit:FindModifierByName("modifier_hero_waitting")
    if(waittingModifier ~= nil and heroUnit.price ~= nil) then
        waittingModifier:SetStackCount(heroUnit.price)
    end
    
    heroUnit:Hold()
    
    if(level > 1) then
        GameRules.DW.AutoUpgradeAbility(heroUnit, true)
        for i = 1, level - 1 do
            heroUnit:HeroLevelUp(false)
            GameRules.DW.AutoUpgradeAbility(heroUnit, true)
        end
    else
        GameRules.DW.AutoUpgradeAbility(heroUnit, false)
    end
    
    local gridVector = GameRules.DW.GetGridVectorByPosition(loc, playerId)
    if(gridVector == nil) then
        return false
    end
    
    GameRules.DW.SetGridInfo(playerId, gridVector.x, gridVector.y, heroUnit)
    
    if(PlayerResource:IsFakeClient(playerId) == false) then
        CreateParticle(ParticleRes.HERO_CREATE, PATTACH_ABSORIGIN_FOLLOW, heroUnit, 5)
    end
    
    return true
end

function GameRules.DW.HasSameHeroToBuy(playerId)
    if(GameRules.DW.RollPanelHero == nil or GameRules.DW.RollPanelHero[playerId] == nil or table.count(GameRules.DW.RollPanelHero[playerId]) == 0) then
        return 0
    end
    
    local currentGold = PlayerResource:GetGold(playerId)

    if(currentGold == nil) then
        return 0
    end
    
    for i, sellHero in pairs(GameRules.DW.RollPanelHero[playerId]) do
        if sellHero.sold == false and sellHero.price <= currentGold then
            if(GameRules.DW.FindSameHeroWithoutLevel(playerId, sellHero.name) ~= nil) then
                return i
            end
        end
    end
    
    return 0
end

function GameRules.DW.GetRandomBuyIndex(playerId)
    if(GameRules.DW.RollPanelHero == nil or table.count(GameRules.DW.RollPanelHero[playerId]) == 0) then
        return 0
    end
    
    local currentGold = PlayerResource:GetGold(playerId)

    if(currentGold == nil) then
        return 0
    end
    
    local buyIndexTbl = {}
    
    for i, sellHero in pairs(GameRules.DW.RollPanelHero[playerId]) do
        if sellHero.sold == false and sellHero.price <= currentGold then
            table.insert(buyIndexTbl, {heroIndex = i, level = sellHero.level})
        end
    end
    
    table.sort(buyIndexTbl, function(a, b) return a.level > b.level end)
    
    if(#buyIndexTbl > 0) then
        return buyIndexTbl[1].heroIndex
    end
    
    return 0
end

function GameRules.DW.GetLowestLevelGrid(playerId)
    local lowestHero = nil
    local minLevel = 25
    local lowestGridVector = Vector(0, 0)
    
    for y = 1, 8 do
        for x = 1, 8 do
            local hero = GameRules.DW.GetGridInfo(playerId, x, y)
            if hero ~= nil and hero:IsNull() == false then
                local heroLevel = hero:GetLevel()
                if(heroLevel < minLevel and heroLevel <= 20) then
                    lowestHero = hero
                    minLevel = hero:GetLevel()
                    lowestGridVector = Vector(x, y)
                end
            end
        end
    end
    
    return lowestGridVector
end

function GameRules.DW.SellHero(gridVector, playerHero, moveToRecycleBin)
    if(playerHero == nil or playerHero:IsNull()) then
        return
    end

    local playerId = playerHero:GetPlayerID()
    if(moveToRecycleBin == nil or PlayerResource:IsFakeClient(playerId)) then
        moveToRecycleBin = false
    end

    local toBeSold = GameRules.DW.GetGridInfo(playerId, gridVector.x, gridVector.y)
    if(toBeSold ~= nil and toBeSold:IsNull() == false) then
        if(toBeSold.IsRealHero == nil or toBeSold:IsRealHero() == false) then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
            return
        end

        local talentTable = GameRules.DW.GetTalentTable(toBeSold)
        if(talentTable ~= nil) then
            toBeSold.talent = talentTable
        end

        local heroName = string.gsub(toBeSold:GetName(), HeroNamePrefix, "")

        if(toBeSold.price ~= nil) then
            local sellPrice = math.floor(toBeSold.price / 2)

            if(GameRules.DW.CheckHasTalent(playerHero, "special_bonus_elf_15_1")) then
                sellPrice = toBeSold.price
            end

            PlayerResource:ModifyGold(playerId, sellPrice, false, DOTA_ModifyGold_Unspecified)
            local player = playerHero:GetPlayerOwner()
            if(player ~= nil and player:IsNull() == false) then
                SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, toBeSold, sellPrice, nil)
            end
            local midas_particle = CreateParticle(ParticleRes.SELL_HERO, PATTACH_ABSORIGIN_FOLLOW, toBeSold, 3)
            ParticleManager:SetParticleControlEnt(midas_particle, 1, playerHero, PATTACH_POINT_FOLLOW, "attach_hitloc", toBeSold:GetAbsOrigin(), false)
        else
            toBeSold.price = 0
        end

        local playerInfo = GameRules.DW.PlayerList[playerId]
        if(playerInfo ~= nil) then
            local recycleHeroLevel = toBeSold:GetLevel()
            if(recycleHeroLevel > 25) then
                recycleHeroLevel = 25
                GameRules.DW.DropItemForPlayer(playerInfo.Hero, "item_tome_of_upgrade")
            end

            if(moveToRecycleBin == true and GameRules.DW.RecycleHero[playerId] ~= nil) then
                table.insert(GameRules.DW.RecycleHero[playerId], {name = heroName, price = toBeSold.price, level = recycleHeroLevel, sold = false, talent = toBeSold.talent})

                local checkLevel = toBeSold:GetLevel()
                while(GameRules.DW.HasSameHeroInRecycleBin(playerId, heroName, checkLevel) == true) do
                    local removeCount = 0
                    local totalPrice = 0
                    local remainTalent = nil
                    for i = #GameRules.DW.RecycleHero[playerId], 1, -1 do
                        local checkHero = GameRules.DW.RecycleHero[playerId][i]
                        if(checkHero ~= nil and checkHero.name == heroName and checkHero.level == checkLevel) then
                            table.remove(GameRules.DW.RecycleHero[playerId], i)
                            removeCount = removeCount + 1
                            totalPrice = totalPrice + checkHero.price
                            remainTalent = checkHero.talent
                        end
                    end

                    if(removeCount == 2) then
                        local level = checkLevel
                        if(level == 1) then
                            level = 5
                        else
                            level = level + 5
                        end
                        table.insert(GameRules.DW.RecycleHero[playerId], {name = heroName, price = totalPrice, level = level, sold = false, talent = remainTalent})
                        checkLevel = level

                        local draftHero = table.find(GameRules.DW.RandomDraftHeros, "name", heroName)
                        if(draftHero ~= nil) then
                            draftHero.price = draftHero.price + GameRules.DW.GetHeroPriceIncresement(playerHero, level)
                        end

                        if(level == 25) then
                            ShowHeroMessage(playerInfo.SteamId, HeroNamePrefix .. heroName, "HERO_MESSAGE_COMBINED_25")
                        end
                    end
                end

                if(#GameRules.DW.RecycleHero[playerId] > 5) then
                    table.remove(GameRules.DW.RecycleHero[playerId], 1)
                end
            end
        end

        if(PlayerResource:IsFakeClient(playerId) == false) then
            SendMessageToPlayer(playerId, "SHOW_ROLL_PANEL",
            {items = GameRules.DW.RollPanelHero[playerId], recycles = GameRules.DW.RecycleHero[playerId], isUpdate = true})
        end

        if(toBeSold ~= nil and toBeSold:IsNull() == false) then
            if(toBeSold:HasModifier("modifier_item_moon_shard_consumed")) then
                GameRules.DW.DropItemForPlayer(playerHero, "item_moon_shard")
            end
        end
        
        GameRules.DW.RemoveHeroFromGrid(playerHero, gridVector, nil)
    end
end

function GameRules.DW.GetHeroPriceIncresement(playerHero, heroLevel)
    if(heroLevel == nil or heroLevel <= 0) then
        return 0
    end

    if(playerHero == nil or playerHero:IsNull()) then
        return 0
    end

    if(heroLevel > 0 and heroLevel <= 5) then
        return 2
    elseif(heroLevel > 5 and heroLevel <= 10) then
        return 4
    elseif(heroLevel > 10 and heroLevel <= 15) then
        return 8
    elseif(heroLevel > 15 and heroLevel <= 20) then
        return 16
    elseif(heroLevel > 20) then
        return 32
    end

    return 0
end

function GameRules.DW.GetHeroCountInRecycleBin(playerId, heroName, level)
    if(GameRules.DW.RecycleHero[playerId] == nil) then
        return 0
    end

    local count = 0
    for _, v in pairs(GameRules.DW.RecycleHero[playerId]) do
        if(v.name == heroName and v.level == level and v.level < 25) then
            count = count + 1
        end
    end

    return count
end

function GameRules.DW.HasSameHeroInRecycleBin(playerId, heroName, level)
    if(level >= 25) then
        return false
    end

    if(GameRules.DW.RecycleHero[playerId] == nil) then
        return false
    end

    local count = GameRules.DW.GetHeroCountInRecycleBin(playerId, heroName, level)
    if(count > 1) then
        return true
    end

    return false
end

function GameRules.DW.ManualControl(gridVector, playerHero)
    if(playerHero == nil or playerHero:IsNull()) then
        return
    end
    
    local playerId = playerHero:GetPlayerID()
    local toBeControlled = GameRules.DW.GetGridInfo(playerId, gridVector.x, gridVector.y)
    if(toBeControlled ~= nil and toBeControlled:IsNull() == false) then
        if(toBeControlled.IsRealHero == nil or toBeControlled:IsRealHero() == false) then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
            return
        end

        if(PlayerResource:IsFakeClient(playerId)) then
            return
        end

        if(GameRules.DW.IsDuelStage == false) then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "ONLY_IN_DUEL_STAGE"})
            return
        end

        local heroName = toBeControlled:GetName()
        if(heroName == "npc_dota_hero_rubick" or heroName == "npc_dota_hero_morphling" or heroName == "npc_dota_hero_storm_spirit") then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
            return
        end

        if(PlayerResource:GetGold(playerId) < 3000) then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "NOT_ENOUGH_GOLD"})
            return
        end

        local playerInfo = GameRules.DW.PlayerList[playerId]
        if(playerInfo == nil or playerInfo.ControlledHero ~= nil) then
            if(playerInfo.ControlledHero:IsNull() == false) then
                SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "ALREADY_CONTROLLED_OTHER_HERO"})
                return
            end
        end

        local midas_particle = CreateParticle(ParticleRes.CONTROL_HERO, PATTACH_ABSORIGIN_FOLLOW, toBeControlled, 3)
        ParticleManager:SetParticleControlEnt(midas_particle, 1, playerHero, PATTACH_POINT_FOLLOW, "attach_hitloc", toBeControlled:GetAbsOrigin(), false)

        EmitSoundOn(SoundRes.CONTROL_HERO, toBeControlled)

        PlayerResource:SpendGold(playerId, 3000, DOTA_ModifyGold_AbilityCost)

        playerInfo.ControlledHero = toBeControlled
    end
end

function GameRules.DW.RefreshHero(gridVector, playerHero)
    if(playerHero == nil or playerHero:IsNull()) then
        return
    end
    
    local thisAbility = playerHero:FindAbilityByName("ability_hero_ability_refresh")

    local playerId = playerHero:GetPlayerID()
    local toBeRefresh = GameRules.DW.GetGridInfo(playerId, gridVector.x, gridVector.y)
    if(toBeRefresh ~= nil and toBeRefresh:IsNull() == false) then
        if(toBeRefresh.IsRealHero == nil or toBeRefresh:IsRealHero() == false) then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
            if(thisAbility ~= nil) then
                thisAbility:EndCooldown()
            end
            return
        end
        
        if(toBeRefresh:GetLevel() <= 5) then
            local heroName = toBeRefresh:GetName()
            if(heroName == "npc_dota_hero_invoker") then
                SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
                if(thisAbility ~= nil) then
                    thisAbility:EndCooldown()
                end
                return
            end
        end
        
        if(toBeRefresh:GetLevel() < 25) then
            SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "NOT_REACH_LEVEL_25"})
            if(thisAbility ~= nil) then
                thisAbility:EndCooldown()
            end
            return
        else
            if(toBeRefresh:GetName() == "npc_dota_hero_pudge") then
                SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
                if(thisAbility ~= nil) then
                    thisAbility:EndCooldown()
                end
                return
            end
            
            if(PlayerResource:GetGold(playerId) == nil or PlayerResource:GetGold(playerId) < 600) then
                SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "NOT_ENOUGH_GOLD"})
                if(thisAbility ~= nil) then
                    thisAbility:EndCooldown()
                end
                return
            end
            
            PlayerResource:SpendGold(playerId, 600, DOTA_ModifyGold_AbilityCost)
            
            local newHero = GameRules.DW.ReplaceHeroWithNewOne(gridVector, playerHero)
            if(newHero ~= nil and newHero:IsNull() == false) then
                GameRules.DW.UpdatePlayerSupply(playerId)
                CreateParticle(ParticleRes.REFRESH_HERO, PATTACH_ABSORIGIN_FOLLOW, newHero, 3)
                EmitSoundOn(SoundRes.HERO_REFRESH, newHero)
            end
        end
    end
end

function GameRules.DW.GetTalentIndexTable(heroName)
    local tIdx = {10, 11, 12, 13, 14, 15, 16, 17}
    local reqLvlDiff = 0
    if(heroName == "npc_dota_hero_morphling") then
        tIdx = {15, 16, 17, 18, 19, 20, 21, 22}
        reqLvlDiff = 5
    end
    if(heroName == "npc_dota_hero_invoker") then
        tIdx = {17, 18, 19, 20, 21, 22, 23, 24}
        reqLvlDiff = 7
    end
    if(heroName == "npc_dota_hero_rubick") then
        tIdx = {11, 12, 13, 14, 15, 16, 17, 18}
        reqLvlDiff = 1
    end
    return tIdx, reqLvlDiff
end

function GameRules.DW.InitHeroTalent(hero)
    if(hero ~= nil and hero:IsNull() == false) then
        hero.talent = {}
        local heroName = hero:GetName()
        local tIdx, reqLvlDiff = GameRules.DW.GetTalentIndexTable(heroName)
        if(RollPercentage(50)) then table.insert(hero.talent, {id = tIdx[1], status = 0, reqLvl = 10}) else table.insert(hero.talent, {id = tIdx[2], status = 0, reqLvl = 10}) end
        if(heroName == "npc_dota_hero_pudge") then
            table.insert(hero.talent, {id = tIdx[3], status = 0, reqLvl = 15})
        else
            if(RollPercentage(50)) then table.insert(hero.talent, {id = tIdx[3], status = 0, reqLvl = 15}) else table.insert(hero.talent, {id = tIdx[4], status = 0, reqLvl = 15}) end
        end        
        if(RollPercentage(50)) then table.insert(hero.talent, {id = tIdx[5], status = 0, reqLvl = 20}) else table.insert(hero.talent, {id = tIdx[6], status = 0, reqLvl = 20}) end
        if(heroName == "npc_dota_hero_pudge") then
            table.insert(hero.talent, {id = tIdx[8], status = 0, reqLvl = 25})
        else
            if(RollPercentage(50)) then table.insert(hero.talent, {id = tIdx[7], status = 0, reqLvl = 25}) else table.insert(hero.talent, {id = tIdx[8], status = 0, reqLvl = 25}) end
        end
    end
end

function GameRules.DW.GetTalentTable(hero)
    if(hero ~= nil and hero:IsNull() == false) then
        local heroLevel = hero:GetLevel()
        if(heroLevel >= 30 or heroLevel < 25) then
            return hero.talent
        end

        local heroName = hero:GetName()
        local tIdx, reqLvlDiff = GameRules.DW.GetTalentIndexTable(heroName)
        local talentTable = {}
        for i = 0, hero:GetAbilityCount() - 1 do
            local ability = hero:GetAbilityByIndex(i)
            if ability ~= nil and ability:GetLevel() > 0 then
                local abilityName = ability:GetName()
                if(string.find(ability:GetName(), "special_bonus_") ~= nil) then
                    for _, id in pairs(tIdx) do
                        if(id == ability:GetAbilityIndex() + 1) then
                            local reqLvl = 10
                            if(id >= 12 + reqLvlDiff) then
                                reqLvl = 15
                            end

                            if(id >= 14 + reqLvlDiff) then
                                reqLvl = 20
                            end

                            if(id >= 16 + reqLvlDiff) then
                                reqLvl = 25
                            end
                            table.insert(talentTable, {id = id, status = 0, reqLvl = reqLvl})
                            break
                        end
                    end
                end
            end
        end

        return talentTable
    end

    return nil
end

function GameRules.DW.ReplaceHeroWithNewOne(gridVector, playerHero)
    if(playerHero == nil or playerHero:IsNull()) then
        return nil
    end
    
    local playerId = playerHero:GetPlayerID()
    local oldHero = GameRules.DW.GetGridInfo(playerId, gridVector.x, gridVector.y)
    
    if(oldHero ~= nil and oldHero:IsNull() == false) then
        local newHero = CreateUnitByName(oldHero:GetName(), oldHero:GetAbsOrigin(), false, playerHero, playerHero, playerHero:GetTeamNumber())
        newHero.price = oldHero.price
        newHero:Hold()
        newHero.sourcePos = oldHero.sourcePos
        newHero.damage = oldHero.damage
        newHero.damageTake = oldHero.damageTake

        local waittingModifier = newHero:FindModifierByName("modifier_hero_waitting")
        if(waittingModifier == nil) then
            waittingModifier = newHero:AddNewModifier(newHero, nil, "modifier_hero_waitting", {})
        end
        if(waittingModifier ~= nil and newHero.price ~= nil) then
            waittingModifier:SetStackCount(newHero.price)
        end

        local level = oldHero:GetLevel()
        for i = 1, level - 1 do
            newHero:HeroLevelUp(false)
        end

        local canLevelUpAbilities = GameRules.DW.GetCanLevelUpAbility(newHero, true, false)

        local heroName = newHero:GetName()
        if(heroName == "npc_dota_hero_invoker") then
            for i = 1, level do
                GameRules.DW.AutoUpgradeAbility(newHero, false)
            end
        end

        newHero:SetControllableByPlayer(playerId, true)        
        newHero:SetBaseIntellect(oldHero:GetBaseIntellect())
        newHero:SetBaseStrength(oldHero:GetBaseStrength())
        newHero:SetBaseAgility(oldHero:GetBaseAgility())

        local playerInfo = GameRules.DW.PlayerList[playerId]
        if(playerInfo ~= nil) then
            if(playerInfo.ControlledHero == oldHero) then
                playerInfo.ControlledHero = newHero
            end
        end
        
        local modifers = oldHero:FindAllModifiers()
        for i, v in pairs(modifers) do
            local modiferName = v:GetName()
            
            local hAbility = nil
            local stackCount = v:GetStackCount()
            
            if(modiferName == "modifier_pudge_flesh_heap") then
                hAbility = newHero:FindAbilityByName("pudge_flesh_heap")
            end
            
            if(modiferName == "modifier_silencer_glaives_of_wisdom") then
                hAbility = newHero:FindAbilityByName("silencer_glaives_of_wisdom")
            end
            
            if(modiferName == "modifier_lion_finger_of_death_kill_counter") then
                hAbility = newHero:FindAbilityByName("lion_finger_of_death")
            end
            
            if(modiferName == "modifier_legion_commander_duel_damage_boost") then
                hAbility = newHero:FindAbilityByName("legion_commander_duel")
            end

            if(modiferName == "modifier_abyssal_underlord_atrophy_aura_hero_permanent_buff") then
                hAbility = newHero:FindAbilityByName("abyssal_underlord_atrophy_aura")
            end

            if(modiferName == "modifier_clinkz_death_pact_permanent_buff") then
                hAbility = newHero:FindAbilityByName("clinkz_death_pact")
            end
            
            if(hAbility ~= nil) then
                newHero:AddNewModifier(newHero, hAbility, modiferName, {})
                local modifer = newHero:FindModifierByName(modiferName)
                if(modifer ~= nil and stackCount > 0) then
                    modifer:SetStackCount(stackCount)
                end
            end
            
            if(modiferName == "modifier_item_ultimate_scepter_consumed") then
                newHero:AddNewModifier(newHero, nil, modiferName, {})
            end
            
            if(modiferName == "modifier_item_moon_shard_consumed") then
                newHero:AddItemByName("item_moon_shard")
            end
        end
        
        GameRules.DW.RemoveHeroFromGrid(playerHero, gridVector, newHero)
        GameRules.DW.SetGridInfo(playerId, gridVector.x, gridVector.y, newHero)
        
        return newHero
    end
    
    return nil
end

function GameRules.DW.SyncTalentWithPartner(learnedPlayerId, ab1Name, ab2Name, herolevel, isSame)
    local playerInfo = GameRules.DW.PlayerList[learnedPlayerId]
    local learnedAbilityName = nil
    if(playerInfo ~= nil and playerInfo.Hero ~= nil and playerInfo.Hero:IsNull() == false) then
        local specialAbility1 = playerInfo.Hero:FindAbilityByName(ab1Name)
        local specialAbility2 = playerInfo.Hero:FindAbilityByName(ab2Name)
        if(specialAbility1 ~= nil and specialAbility1:GetLevel() > 0) then
            learnedAbilityName = specialAbility1:GetName()
        elseif(specialAbility2 ~= nil and specialAbility2:GetLevel() > 0) then
            learnedAbilityName = specialAbility2:GetName()
        end
    end

    if(learnedAbilityName ~= nil) then
        local partnerId = GameRules.DW.GetCoopPartnerId(learnedPlayerId)
        local partnerPlayerInfo = nil
        if(partnerId ~= nil) then
            partnerPlayerInfo = GameRules.DW.PlayerList[partnerId]
        end

        if(partnerPlayerInfo ~= nil and partnerPlayerInfo.Hero ~= nil and partnerPlayerInfo.Hero:IsNull() == false) then
            if(partnerPlayerInfo.Hero:GetLevel() >= herolevel) then
                local specialAbility1 = partnerPlayerInfo.Hero:FindAbilityByName(ab1Name)
                local specialAbility2 = partnerPlayerInfo.Hero:FindAbilityByName(ab2Name)
                local hasLearnedTalent = false
                if(specialAbility1 ~= nil and specialAbility1:GetLevel() > 0) then
                    hasLearnedTalent = true
                end
                if(specialAbility2 ~= nil and specialAbility2:GetLevel() > 0) then
                    hasLearnedTalent = true
                end

                if(hasLearnedTalent == false) then
                    local specialAbility = partnerPlayerInfo.Hero:FindAbilityByName(learnedAbilityName)
                    if(isSame == false) then
                        if(learnedAbilityName == ab1Name) then
                            specialAbility = partnerPlayerInfo.Hero:FindAbilityByName(ab2Name)
                        else
                            specialAbility = partnerPlayerInfo.Hero:FindAbilityByName(ab1Name)
                        end
                    end
                    if(specialAbility ~= nil and specialAbility:GetLevel() == 0) then
                        partnerPlayerInfo.Hero:UpgradeAbility(specialAbility)
                    end
                end
            end
        end
    end
end

function GameRules.DW.UpgradePlayer(playerHero)
    if(playerHero == nil or playerHero:IsNull() or playerHero:GetUnitName() ~= "npc_dota_hero_elf") then
        return
    end

    if(playerHero:GetLevel() < 25) then
        playerHero:HeroLevelUp(true)
    end

    if(playerHero:GetLevel() >= 25) then
        local abLvlUp = playerHero:FindAbilityByName("ability_level_up")
        local abControl = playerHero:FindAbilityByName("ability_hero_control")
        if(abLvlUp ~= nil) then
            playerHero:RemoveAbility("ability_level_up")
            SetAbility(playerHero, "ability_hero_control", true, 1)
        end
    end
    
    CreateTimer(function()
        if(playerHero ~= nil and playerHero:IsNull() == false) then
            GameRules.DW.UpdatePlayerSupply(playerHero:GetPlayerID())
        end
    end, 0.5)
    
    if(PlayerResource:IsFakeClient(playerHero:GetPlayerID()) == false) then
        CreateParticle(ParticleRes.LEVEL_UP, PATTACH_ABSORIGIN_FOLLOW, playerHero, 5)
        EmitSoundOn(SoundRes.LEVEL_UP, playerHero)
    else
        local itemId = GameRules.DW.DropRandomItemForPlayer(playerHero)
        if itemId ~= nil then
            playerHero:PickupDroppedItem(itemId)
        end
    end
end

function GameRules.DW.DoTeleporting(playerHero, hero, startPosition, targetPosition, forwardVector, duration, beforeMoveCallback, afterMoveCallback)
    if(startPosition == nil or targetPosition == nil) then
        return
    end

    if(hero ~= nil and hero:IsNull() == false and hero:IsAlive()) then
        local start_pfx = CreateParticle(ParticleRes.TP_START, PATTACH_WORLDORIGIN, hero, duration)
        ParticleManager:SetParticleControl(start_pfx, 0, startPosition)
        ParticleManager:SetParticleControl(start_pfx, 2, Vector(255, 255, 0))
        ParticleManager:SetParticleControl(start_pfx, 3, startPosition)
        ParticleManager:SetParticleControl(start_pfx, 4, startPosition)
        ParticleManager:SetParticleControl(start_pfx, 5, Vector(3, 0, 0))
        ParticleManager:SetParticleControl(start_pfx, 6, startPosition)
    end
    
    local end_pfx = CreateParticle(ParticleRes.TP_END, PATTACH_CUSTOMORIGIN, hero, duration)
    ParticleManager:SetParticleControl(end_pfx, 0, targetPosition)
    ParticleManager:SetParticleControl(end_pfx, 1, targetPosition)
    ParticleManager:SetParticleControl(end_pfx, 5, targetPosition)
    ParticleManager:SetParticleControl(end_pfx, 4, Vector(0, 0, 0))
    ParticleManager:SetParticleControlEnt(end_pfx, 3, hero, PATTACH_CUSTOMORIGIN, "attach_hitloc", targetPosition, true)
    
    if(playerHero ~= nil and playerHero:IsNull() == false) then
        local playerInfo = GameRules.DW.PlayerList[playerHero:GetPlayerID()]
        if(playerInfo ~= nil and playerInfo.TeleportSoundCount < 3) then
            if(hero ~= nil and hero:IsNull() == false and hero:IsAlive()) then
                playerInfo.TeleportSoundCount = playerInfo.TeleportSoundCount + 1
                EmitSoundOn(SoundRes.TP_START_LOOP, hero)
            end
        end
    end

    -- local dummyUnit = CreateUnitByName("npc_dummy_unit", targetPosition, false, playerHero, playerHero, playerHero:GetTeamNumber())
    -- EmitSoundOn(SoundRes.TP_END_LOOP, dummyUnit)
    
    hero:Hold()
    hero:Interrupt()
    hero:InterruptChannel()
    
    CreateTimer(function()
        if(hero == nil or hero:IsNull()) then
            return
        end

        StopSoundOn(SoundRes.TP_START_LOOP, hero)
        -- StopSoundOn(SoundRes.TP_END_LOOP, dummyUnit)
        -- UTIL_Remove(dummyUnit)

        EmitSoundOnLocationWithCaster(startPosition, SoundRes.TP_START, hero)
        EmitSoundOnLocationWithCaster(targetPosition, SoundRes.TP_END, hero)

        if(beforeMoveCallback ~= nil) then
            beforeMoveCallback()
        end

        if(hero == nil or hero:IsNull()) then
            return
        end

        FindClearSpaceForUnit(hero, targetPosition, true)
        hero:SetForwardVector(forwardVector)
        
        if(afterMoveCallback ~= nil) then
            afterMoveCallback()
        end
    end, duration)
end

function GameRules.DW.GetNextBattlePlayerList()
    local playerIdList = {}
    for playerId, playerInfo in pairs(GameRules.DW.PlayerList) do
        if(playerInfo.IsEmpty == false and playerInfo.Life > 0) then
            table.insert(playerIdList, {
                playerId = playerId, 
                sortFactor = playerInfo.BattleCount * 1000 + RandomInt(1, 100), 
                life = playerInfo.Life, 
                rank = playerInfo.Rank, 
                kills = playerInfo.Kills, 
                assists = playerInfo.Assists 
            })
        end
    end
    
    table.sort(playerIdList, function(a, b) return a.sortFactor < b.sortFactor end)
    
    local battlePlayers = {}
    local battlePlayerCount = 4
    
    if(#playerIdList < 5) then
        battlePlayerCount = 2
    end
    
    for _, v in pairs(playerIdList) do
        table.insert(battlePlayers, {playerId = v.playerId, life = v.life, rank = v.rank, kills = v.kills, assists = v.assists})
        if(#battlePlayers >= battlePlayerCount) then
            break
        end
    end
    
    battlePlayers = table.shuffle(battlePlayers)
    
    if(#battlePlayers == 4) then
        table.sort(battlePlayers, function(a, b)
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

        battlePlayers[3], battlePlayers[4] = battlePlayers[4], battlePlayers[3]
        if(RollPercentage(50)) then
            battlePlayers[1], battlePlayers[2] = battlePlayers[2], battlePlayers[1]
            battlePlayers[3], battlePlayers[4] = battlePlayers[4], battlePlayers[3]
        end
    end
    
    local selectedPlayers = {}
    for _, v in pairs(battlePlayers) do
        table.insert(selectedPlayers, v.playerId)
    end
    
    return selectedPlayers
end

function GameRules.DW.GetNextBattlePlayerListCoop()
    local playerIdList = {}
    for playerId, playerInfo in pairs(GameRules.DW.PlayerList) do
        if(playerInfo.IsEmpty == false and playerInfo.Life > 0 and playerInfo.TeamPosition == 1) then
            table.insert(playerIdList, {PlayerId = playerId, SortFactor = playerInfo.BattleCount * 1000 + RandomInt(1, 100), TeamId = playerInfo.TeamId})
        end
    end
    
    table.sort(playerIdList, function(a, b) return a.SortFactor < b.SortFactor end)

    if(#playerIdList < 2) then
        return {}
    end
    
    local battlePlayers = {}
    local team1RepresentInfo = nil
    local team2RepresentInfo = nil
    for _, v in pairs(playerIdList) do
        if(team1RepresentInfo == nil) then
            team1RepresentInfo = GameRules.DW.PlayerList[v.PlayerId]
            table.insert(battlePlayers, {PlayerId = v.PlayerId, TeamId = v.TeamId})
        elseif(team2RepresentInfo == nil) then
            local shouldMatchThisTeam = false
            if(#playerIdList <= 3) then
                shouldMatchThisTeam = true
            elseif(team1RepresentInfo.LastAgainstTeam ~= v.TeamId) then
                shouldMatchThisTeam = true
            end

            if(shouldMatchThisTeam) then
                team2RepresentInfo = GameRules.DW.PlayerList[v.PlayerId]
                table.insert(battlePlayers, {PlayerId = v.PlayerId, TeamId = v.TeamId})
            end
        end
        if(#battlePlayers >= 2) then
            break
        end
    end

    if(team1RepresentInfo == nil or team2RepresentInfo == nil) then
        return {}
    end

    for playerId, playerInfo in pairs(GameRules.DW.PlayerList) do
        if(playerInfo.IsEmpty == false and playerInfo.Life > 0) then
            if(playerInfo.TeamId == team1RepresentInfo.TeamId) then
                playerInfo.LastAgainstTeam = team2RepresentInfo.TeamId
                if(playerInfo.TeamPosition == 2) then
                    table.insert(battlePlayers, {PlayerId = playerId, TeamId = playerInfo.TeamId})
                end
            end

            if(playerInfo.TeamId == team2RepresentInfo.TeamId) then
                playerInfo.LastAgainstTeam = team1RepresentInfo.TeamId
                if(playerInfo.TeamPosition == 2) then
                    table.insert(battlePlayers, {PlayerId = playerId, TeamId = playerInfo.TeamId})
                end
            end
        end
    end
    
    if(#battlePlayers == 4) then
        table.sort(battlePlayers, function(a, b) return a.TeamId > b.TeamId end)
        battlePlayers[2], battlePlayers[3] = battlePlayers[3], battlePlayers[2]
        if(RollPercentage(50)) then
            battlePlayers[1], battlePlayers[2] = battlePlayers[2], battlePlayers[1]
            battlePlayers[3], battlePlayers[4] = battlePlayers[4], battlePlayers[3]
        end
    end
    
    local selectedPlayers = {}
    for _, v in pairs(battlePlayers) do
        table.insert(selectedPlayers, v.PlayerId)
    end
    
    return selectedPlayers
end

function GameRules.DW.InterchangeBattlePosition()
    if(#GameRules.DW.BattlePlayers ~= 4) then
        return
    end

    local playerHero1 = GameRules.DW.PlayerList[GameRules.DW.BattlePlayers[1]].Hero
    local playerHero2 = GameRules.DW.PlayerList[GameRules.DW.BattlePlayers[2]].Hero
    local playerHero3 = GameRules.DW.PlayerList[GameRules.DW.BattlePlayers[3]].Hero
    local playerHero4 = GameRules.DW.PlayerList[GameRules.DW.BattlePlayers[4]].Hero

    if(GameRules.DW.CheckNeedInterchangeBattlePosition(playerHero1, playerHero3)) then
        GameRules.DW.BattlePlayers[1], GameRules.DW.BattlePlayers[3] = GameRules.DW.BattlePlayers[3], GameRules.DW.BattlePlayers[1]
    end

    if(GameRules.DW.CheckNeedInterchangeBattlePosition(playerHero2, playerHero4)) then
        GameRules.DW.BattlePlayers[2], GameRules.DW.BattlePlayers[4] = GameRules.DW.BattlePlayers[4], GameRules.DW.BattlePlayers[2]
    end
end

function GameRules.DW.CheckNeedInterchangeBattlePosition(hero1, hero2)
    local hasFrontRowTalent1 = GameRules.DW.CheckHasTalent(hero1, "special_bonus_elf_10_1")
    local hasRearRowTalent1 = GameRules.DW.CheckHasTalent(hero1, "special_bonus_elf_10_2")
    local hasFrontRowTalent2 = GameRules.DW.CheckHasTalent(hero2, "special_bonus_elf_10_1")
    local hasRearRowTalent2 = GameRules.DW.CheckHasTalent(hero2, "special_bonus_elf_10_2")

    if(hasFrontRowTalent1 == false and hasRearRowTalent1 == false) then
        if(hasFrontRowTalent2 == true) then
            return true
        else
            return false
        end
    end

    if(hasFrontRowTalent2 == false and hasRearRowTalent2 == false) then
        if(hasRearRowTalent1 == true) then
            return true
        else
            return false
        end
    end

    if(hasFrontRowTalent2 == true and hasRearRowTalent1 == true) then
        return true
    end

    return false
end

ToBeRemovedModifiers = {
    [1] = "modifier_oracle_false_promise_timer",
    [2] = "modifier_oracle_false_promise",
    [3] = "modifier_tiny_craggy_exterior",
    [4] = "modifier_dragon_knight_dragon_form",
    [5] = "modifier_lycan_shapeshift",
    [6] = "modifier_lycan_shapeshift_aura",
    [7] = "modifier_lycan_shapeshift_speed",
    [8] = "modifier_dragon_knight_corrosive_breath",
    [9] = "modifier_dragon_knight_splash_attack",
    [10] = "modifier_dragon_knight_frost_breath",
    [11] = "modifier_dark_willow_shadow_realm_buff",
    [12] = "modifier_dark_willow_shadow_realm_buff_attack_logic",
    [13] = "modifier_dark_willow_cursed_crown",
    [14] = "modifier_dark_willow_bedlam",
    [15] = "modifier_dark_willow_terrorize_thinker",
    [16] = "modifier_dark_willow_debuff_fear",
    [17] = "modifier_dark_willow_bramble_maze",
    [18] = "modifier_undying_decay_debuff",
    [19] = "modifier_undying_decay_debuff_counter",
    [20] = "modifier_snapfire_mortimer_kisses",
    [21] = "modifier_lone_druid_true_form",
    [22] = "modifier_nyx_assassin_burrow",
    [23] = "modifier_life_stealer_infest",
    [24] = "modifier_wisp_tether",
    [25] = "modifier_tusk_snowball_movement",
    [26] = "modifier_tusk_snowball_visible",
    [27] = "modifier_tusk_snowball_target",
    [28] = "modifier_rubick_spell_steal",
    [29] = "modifier_morphling_replicate_manager",
    [30] = "modifier_snapfire_gobble_up_creep",
}

ToBeStopAbilities = {
    [1] = "phoenix_sun_ray_stop",
    [2] = "phoenix_icarus_dive_stop",
    [3] = "tusk_ice_shards_stop",
    [4] = "pangolier_gyroshell_stop",
    [5] = "shredder_return_chakram",
    [6] = "shredder_return_chakram_2",
    [7] = "nyx_assassin_unburrow",
    [8] = "keeper_of_the_light_illuminate_end",
    [9] = "keeper_of_the_light_spirit_form_illuminate_end",
}

function GameRules.DW.StopAbilities(hero)
    if(hero == nil or hero:IsNull()) then
        return
    end

    for i, abilityName in pairs(ToBeStopAbilities) do
        local ability = hero:FindAbilityByName(abilityName)
        if(ability ~= nil and ability:GetLevel() > 0) then
            ability:CastAbility()
        end
    end

    for _,v in pairs(ToBeRemovedModifiers) do
        if(hero:HasModifier(v)) then
            hero:RemoveModifierByName(v)
        end
    end

    if(hero:HasModifier("modifier_morphling_morph_str")) then
        local morph_str = hero:FindAbilityByName("morphling_morph_str")
        if(morph_str ~= nil and morph_str:GetToggleState() == true) then
            morph_str:ToggleAbility()
        end
    end

    if(hero:HasModifier("modifier_morphling_morph_agi")) then
        local morph_agi = hero:FindAbilityByName("morphling_morph_agi")
        if(morph_agi ~= nil and morph_agi:GetToggleState() == true) then
            morph_agi:ToggleAbility()
        end
    end
end

function GameRules.DW.EndAbilitiesCooldown(hero)
    if(hero == nil or hero:IsNull()) then
        return
    end
    for i = 0, hero:GetAbilityCount() - 1 do
        local ability = hero:GetAbilityByIndex(i)
        
        if(ability ~= nil and ability:GetLevel() > 0) then
            if(ability:IsCooldownReady() == false) then
                ability:EndCooldown()
            end
        end
    end
end

function GameRules.DW.EndItemsCooldown(hero)
    if(hero == nil or hero:IsNull()) then
        return
    end

    for slotIndex = 0, 16 do
        local item = hero:GetItemInSlot(slotIndex)
        if(item ~= nil and item:IsNull() == false) then
            item:SetItemState(1)
            item:EndCooldown()
        end
    end
end

function GameRules.DW.RemoveMeepoItems(hero)
    if(hero == nil or hero:IsNull()) then
        return
    end

    for slotIndex = 0, 16 do
        local item = hero:GetItemInSlot(slotIndex)
        if(item ~= nil and item:IsNull() == false) then
            if(item.IsMeepoCopyItem == true) then
                hero:RemoveItem(item)
            end
        end
    end
end

function GameRules.DW.CheckHasTalent(hero, talentName)
    if(hero == nil or hero:IsNull() or hero.FindAbilityByName == nil) then
        return false
    end

    local checkTalent = hero:FindAbilityByName(talentName)
    if(checkTalent ~= nil and checkTalent:GetLevel() > 0) then
        return true
    end

    return false
end

function HttpPost(url, data, callback)
    local req = CreateHTTPRequestScriptVM("POST", GameRules.DW.SVR .. url)
    req:SetHTTPRequestHeaderValue("Content-Type", "application/json")
    req:SetHTTPRequestHeaderValue("Server-Key", GameRules.DW.SVR_KEY)
    req:SetHTTPRequestGetOrPostParameter('data', json.encode(data))
    req:Send(function(res)
        if res.StatusCode ~= 200 or not res.Body then
            -- print(url, " code:", res.StatusCode, res.Body)
            return
        end
        
        if callback then
            local result = json.decode(res.Body)
            if(result ~= nil) then
                callback(result)
            end
        end
    end)
end

CheckTalentList = {
    ["modifier_special_bonus_attack_damage"] = {
        [1] = "special_bonus_attack_damage_10",
        [2] = "special_bonus_attack_damage_12",
        [3] = "special_bonus_attack_damage_15",
        [4] = "special_bonus_attack_damage_20",
        [5] = "special_bonus_attack_damage_25",
        [6] = "special_bonus_attack_damage_30",
        [7] = "special_bonus_attack_damage_35",
        [8] = "special_bonus_attack_damage_40",
        [9] = "special_bonus_attack_damage_45",
        [10] = "special_bonus_attack_damage_50",
        [11] = "special_bonus_attack_damage_55",
        [12] = "special_bonus_attack_damage_60",
        [13] = "special_bonus_attack_damage_65",
        [14] = "special_bonus_attack_damage_75",
        [15] = "special_bonus_attack_damage_90",
        [16] = "special_bonus_attack_damage_100",
        [17] = "special_bonus_attack_damage_120",
        [18] = "special_bonus_attack_damage_150",
        [19] = "special_bonus_attack_damage_160",
        [20] = "special_bonus_attack_damage_250",
        [21] = "special_bonus_attack_damage_251",
        [22] = "special_bonus_attack_damage_400",
    },
    ["modifier_special_bonus_attack_range"] = {
        [1] = "special_bonus_attack_range_50",
        [2] = "special_bonus_attack_range_75",
        [3] = "special_bonus_attack_range_100",
        [4] = "special_bonus_attack_range_125",
        [5] = "special_bonus_attack_range_150",
        [6] = "special_bonus_attack_range_175",
        [7] = "special_bonus_attack_range_200",
        [8] = "special_bonus_attack_range_250",
        [9] = "special_bonus_attack_range_300",
        [10] = "special_bonus_attack_range_400",
    },
    ["modifier_special_bonus_cast_range"] = {
        [1] = "special_bonus_cast_range_50",
        [2] = "special_bonus_cast_range_60",
        [3] = "special_bonus_cast_range_75",
        [4] = "special_bonus_cast_range_100",
        [5] = "special_bonus_cast_range_125",
        [6] = "special_bonus_cast_range_150",
        [7] = "special_bonus_cast_range_175",
        [8] = "special_bonus_cast_range_200",
        [9] = "special_bonus_cast_range_250",
        [10] = "special_bonus_cast_range_275",
        [11] = "special_bonus_cast_range_300",
        [12] = "special_bonus_cast_range_350",
        [13] = "special_bonus_cast_range_400",

    },
    ["modifier_special_bonus_armor"] = {
        [1] = "special_bonus_armor_2",
        [2] = "special_bonus_armor_3",
        [3] = "special_bonus_armor_4",
        [4] = "special_bonus_armor_5",
        [5] = "special_bonus_armor_6",
        [6] = "special_bonus_armor_7",
        [7] = "special_bonus_armor_8",
        [8] = "special_bonus_armor_9",
        [9] = "special_bonus_armor_10",
        [10] = "special_bonus_armor_12",
        [11] = "special_bonus_armor_15",
        [12] = "special_bonus_armor_20",
        [13] = "special_bonus_armor_30",
    },
    ["modifier_special_bonus_attack_speed"] = {
        [1] = "special_bonus_attack_speed_10",
        [2] = "special_bonus_attack_speed_15",
        [3] = "special_bonus_attack_speed_20",
        [4] = "special_bonus_attack_speed_25",
        [5] = "special_bonus_attack_speed_30",
        [6] = "special_bonus_attack_speed_35",
        [7] = "special_bonus_attack_speed_40",
        [8] = "special_bonus_attack_speed_45",
        [9] = "special_bonus_attack_speed_50",
        [10] = "special_bonus_attack_speed_55",
        [11] = "special_bonus_attack_speed_60",
        [12] = "special_bonus_attack_speed_70",
        [13] = "special_bonus_attack_speed_55",
        [14] = "special_bonus_attack_speed_60",
        [15] = "special_bonus_attack_speed_70",
        [16] = "special_bonus_attack_speed_80",
        [17] = "special_bonus_attack_speed_100",
        [18] = "special_bonus_attack_speed_120",
        [19] = "special_bonus_attack_speed_140",
        [20] = "special_bonus_attack_speed_160",
        [21] = "special_bonus_attack_speed_175",
        [22] = "special_bonus_attack_speed_200",
        [23] = "special_bonus_attack_speed_250",
    }
}

function GameRules.DW.CheckLostTalent(hero)
    if(hero == nil or hero:IsNull() or hero.FindAbilityByName == nil) then
        return
    end

    for modifierName, talents in pairs(CheckTalentList) do
        for _, talentName in pairs(talents) do
            local checkTalent = hero:FindAbilityByName(talentName)
            if(checkTalent ~= nil and checkTalent:GetLevel() > 0) then
                if(hero:HasModifier(modifierName) == false) then
                    hero:AddNewModifier(hero, checkTalent, modifierName, {})
                end
            end
        end
    end
end