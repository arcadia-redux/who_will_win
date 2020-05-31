require 'utils'
require 'shared'

if BotAI == nil then BotAI = class({}) end

BOT_CMD_LIST = {"MOVE_RANDOMLY", "BUY_HERO_REFRESH", "BUY_HERO", "UPGRADE_HERO",
"MOVE_HERO", "SELL_HERO", "PICKUP_ITEM", "GIVE_ITEM"}

function BotAI:OnBotThink(hero)
    if IsClient() or GameRules.DW.IsGameOver then return nil end
    
    local highestScoreCommand = 1
    local highestScore = 0
    local highestData = nil
    
    if(GameRules.DW.PlayerList[hero:GetPlayerID()].Life <= 0) then
        return nil
    end

    if(GameRules:IsGamePaused()) then
        return 1
    end
    
    for i, v in pairs(BOT_CMD_LIST) do
        local score, cmdData = BotAI:EvaluateCommand(hero, v)
        if(score == nil) then
            score = 0
        end
        if(score > highestScore or (score == highestScore and RollPercentage(50))) then
            highestScore = score
            highestScoreCommand = i
            highestData = cmdData
        end
    end

    return BotAI:ExecuteCommand(hero, BOT_CMD_LIST[highestScoreCommand], highestData)
end

function BotAI:HasRoomForPickupItem(hero)
    local itemCount = 0
    for slotIndex = 0, 5 do
        local item = hero:GetItemInSlot(slotIndex)
        if item ~= nil then
            itemCount = itemCount + 1
        end
    end
    return itemCount < 6
end

function BotAI:EvaluateCommand(hero, cmdName)
    local playerId = hero:GetPlayerID()
    local location = hero:GetAbsOrigin()
    local teamId = hero:GetTeam()
    local score = 0
    
    if(cmdName == "MOVE_RANDOMLY") then
        return RandomInt(1, 5), nil
    end
    
    if(cmdName == "BUY_HERO_REFRESH") then
        if(GameRules.DW.StageName[GameRules.DW.Stage] ~= "PREPARE") then
            return 0, nil
        end
        
        if GameRules.DW.RollPanelHero[playerId] == nil or table.count(GameRules.DW.RollPanelHero[playerId]) == 0 then
            return 10, nil
        end
        
        score = 1
        
        local goldCost = GameRules.DW.GetRollHeroGoldCost(playerId)
        local currentGold = PlayerResource:GetGold(playerId)
        if(currentGold >= goldCost) then
            score = score + 1
        end
        
        local leftHeroCount = 0
        for _, sellHero in pairs(GameRules.DW.RollPanelHero[playerId]) do
            if sellHero.sold == false then
                leftHeroCount = leftHeroCount + 1
            end
        end
        
        if leftHeroCount == 0 then
            score = score + 1
        end
        
        return score, nil
    end
    
    if(cmdName == "BUY_HERO") then
        if(GameRules.DW.StageName[GameRules.DW.Stage] ~= "PREPARE") then
            return 0, nil
        end
        
        if GameRules.DW.RollPanelHero[playerId] == nil then
            return 0, nil
        end

        if(GameRules.DW.PlayerList[playerId].CurrentSupply - 3 > GameRules.DW.PlayerList[playerId].MaxSupply) then
            return 0, nil
        end
        
        if(GameRules.DW.PlayerList[playerId].MaxSupply > GameRules.DW.PlayerList[playerId].CurrentSupply) then
            score = score + RandomInt(2, 5)
        end
        
        local buyIndex = GameRules.DW.HasSameHeroToBuy(playerId)
        
        if buyIndex > 0 then
            score = score + RandomInt(3, 5)
        end
        
        return score, buyIndex
    end
    
    if(cmdName == "UPGRADE_HERO") then
        if(GameRules.DW.StageName[GameRules.DW.Stage] ~= "PREPARE") then
            return 0, nil
        end
        
        if(GameRules.DW.HasSameHeroToBuy(playerId) == 0 and GameRules.DW.PlayerList[playerId].MaxSupply <= GameRules.DW.PlayerList[playerId].CurrentSupply) then
            score = score + RandomInt(3, 5)
        end
        
        local goldCost = GameRules.DW.GetUpgradeLevelGoldCost(playerId)
        local currentGold = PlayerResource:GetGold(playerId)
        if(currentGold >= goldCost) then
            score = score + RandomInt(2, 4)
        end
        
        return score, nil
    end
    
    if(cmdName == "MOVE_HERO") then
        if(GameRules.DW.StageName[GameRules.DW.Stage] ~= "PREPARE") then
            return 0, nil
        end
        
        return RandomInt(0, 4), nil
    end
    
    if(cmdName == "SELL_HERO") then
        if(GameRules.DW.StageName[GameRules.DW.Stage] ~= "PREPARE") then
            return 0, nil
        end
        
        local stageTimeLeft = GameRules.DW.StageTime[GameRules.DW.Stage] - (GameRules:GetGameTime() - GameRules.DW.StageStartTime)
        if(stageTimeLeft < 10) then
            return 0, nil
        end
        
        if(GameRules.DW.GetHeroCount(playerId) <= 1) then
            return 0, nil
        end
        
        if(GameRules.DW.HasSameHeroToBuy(playerId) == 0 and GameRules.DW.PlayerList[playerId].MaxSupply <= GameRules.DW.PlayerList[playerId].CurrentSupply) then
            score = score + RandomInt(1, 3)
        end
        
        local lowestGridVector = GameRules.DW.GetLowestLevelGrid(playerId)
        if(score > 0) then
            if(lowestGridVector.x > 0) then
                score = score + RandomInt(3, 4)
            end
        end
        
        return score, lowestGridVector
    end
    
    if(cmdName == "PICKUP_ITEM") then
        if(BotAI:HasRoomForPickupItem(hero) == false) then
            return 0, nil
        end

        local vItemDrops = Entities:FindAllByClassname("dota_item_drop")
        for _, drop in pairs(vItemDrops) do
            repeat
                local item = drop:GetContainedItem()
                if(item == nil or item:IsNull() or item.ownerPlayerId == nil) then
                    break
                end
                
                if(item.ownerPlayerId == playerId) then
                    return 10, drop
                end
                
                break
            until true
        end
        return 0, nil
    end
    
    if(cmdName == "GIVE_ITEM") then
        if(GameRules.DW.StageName[GameRules.DW.Stage] ~= "PREPARE") then
            return 0, nil
        end
        
        local itemCount = hero:GetNumItemsInInventory()
        
        if(itemCount == 0) then
            return 0, nil
        end
        
        local heroCount = GameRules.DW.GetHeroCount(playerId)
        if(heroCount == 0) then
            return 0, nil
        end
        
        local giveSlotIndex = 0
        
        for slotIndex = 0, 16 do
            local item = hero:GetItemInSlot(slotIndex)
            if item ~= nil then
                giveSlotIndex = slotIndex
            end
        end
        
        local giveItem = hero:GetItemInSlot(giveSlotIndex)
        
        if(giveItem == nil or giveItem:IsNull()) then
            return 0, nil
        end
        
        return RandomInt(3, 6), giveItem
    end
end

function BotAI:ExecuteCommand(hero, cmdName, cmdData)
    local playerId = hero:GetPlayerID()
    local playerInfo = GameRules.DW.PlayerList[playerId]
    if(playerInfo == nil) then
        return 2
    end

    local playerHero = playerInfo.Hero

    if(playerHero == nil or playerHero:IsNull()) then
        return 2
    end

    local teamId = playerInfo.TeamId
    
    if(cmdName == "MOVE_RANDOMLY") then
        local startPos = hero:GetAbsOrigin()
        local leftBottomMax = GameRules.DW.GetPlayerOrigin(playerId)

        if(leftBottomMax ~= nil) then
            local rightTopMax = leftBottomMax + Vector(1280, 1280)
            local targetPos = Vector(RandomInt(leftBottomMax.x, rightTopMax.x),
            RandomInt(leftBottomMax.y, rightTopMax.y), startPos.z)
            hero:MoveToPosition(targetPos)
            return 0.2 + (targetPos - startPos):Length2D() / hero:GetBaseMoveSpeed()
        else
            return 1
        end
    end
    
    if(cmdName == "BUY_HERO_REFRESH") then
        local goldCost = GameRules.DW.GetRollHeroGoldCost(playerId)
        local currentGold = PlayerResource:GetGold(playerId)
        if(currentGold >= goldCost) then
            PlayerResource:SpendGold(playerId, goldCost, DOTA_ModifyGold_AbilityCost)
            GameRules.DW.ShowRollPanel(hero)
        end
        return 2
    end
    
    if(cmdName == "BUY_HERO") then
        if(cmdData ~= nil and cmdData ~= 0) then
            GameRules.DW.BuyHeroRequest(playerId, cmdData, 0)
            return 1
        end
        
        local buyIndex = GameRules.DW.GetRandomBuyIndex(playerId)
        
        if(buyIndex > 0) then
            GameRules.DW.BuyHeroRequest(playerId, buyIndex, 0)
            return 1
        end
    end
    
    if(cmdName == "UPGRADE_HERO") then
        local goldCost = GameRules.DW.GetUpgradeLevelGoldCost(playerId)
        local currentGold = PlayerResource:GetGold(playerId)
        if(currentGold >= goldCost) then
            PlayerResource:SpendGold(playerId, goldCost, DOTA_ModifyGold_AbilityCost)
            GameRules.DW.UpgradePlayer(playerHero)
            return 2
        end
    end
    
    if(cmdName == "MOVE_HERO") then
        local pickedVector = GameRules.DW.FindRandomInUseVector(playerId)
        if(pickedVector == nil) then
            return 0.5
        end
        
        local pickedHero = GameRules.DW.GetGridInfo(playerId, pickedVector.x, pickedVector.y)
        if(pickedHero == nil or pickedHero:IsNull()) then
            return 0.5
        end
        
        local moveAbility = playerHero:FindAbilityByName("ability_hero_move")
        if(moveAbility == nil) then
            return 0.5
        end
        
        local putX = RandomInt(1, 8)
        local putY = RandomInt(1, 8)
        local putVector = GameRules.DW.FindEmptyVectorNearBy(Vector(RandomInt(1, 8), RandomInt(1, 8)), playerId)
        
        playerHero:CastAbilityOnTarget(pickedHero, moveAbility, playerId)
        
        local worldPos = GameRules.DW.GetPositionByGridVector(putVector, playerId)
        
        CreateTimer(function()
            if(playerHero ~= nil and playerHero:IsNull() == false) then
                playerHero:CastAbilityOnPosition(worldPos, moveAbility, playerId)
            end
        end, 1)
        
        return 2
    end
    
    if(cmdName == "SELL_HERO") then
        if(cmdData == nil) then
            return 1
        end
        
        GameRules.DW.SellHero(cmdData, hero, false)
        return 2
    end
    
    if(cmdName == "PICKUP_ITEM") then
        if(cmdData == nil or cmdData:IsNull()) then
            return 1
        end
        
        local item = cmdData
        hero:PickupDroppedItem(item)
        
        local startPos = hero:GetAbsOrigin()
        local endPos = item:GetAbsOrigin()
        local moveLenth = (endPos - startPos):Length2D()
        
        return 0.5 + moveLenth / hero:GetBaseMoveSpeed()
    end
    
    if(cmdName == "GIVE_ITEM") then
        if(GameRules.DW.StageName[GameRules.DW.Stage] ~= "PREPARE") then
            return 1
        end
        
        if(cmdData == nil or cmdData:IsNull()) then
            return 1
        end
        
        local item = cmdData

        if(table.contains(KV_DROP_ITEMS["1"], item:GetName()) or table.contains(KV_DROP_ITEMS["2"], item:GetName()) or table.contains(KV_DROP_ITEMS["3"], item:GetName())) then
            hero:SellItem(item)
            return 1
        end
        
        local pickedVector = GameRules.DW.FindRandomInUseVector(playerId)
        
        if(pickedVector == nil) then
            return 0.5
        end
        
        local pickedHero = GameRules.DW.GetGridInfo(playerId, pickedVector.x, pickedVector.y)
        
        if(pickedHero == nil or pickedHero:IsNull()) then
            return 0.5
        end

        if(BotAI:HasRoomForPickupItem(pickedHero) == false) then
            return 0.5
        end
        
        hero:MoveToNPCToGiveItem(pickedHero, item)
        
        local startPos = hero:GetAbsOrigin()
        local endPos = pickedHero:GetAbsOrigin()
        local moveLenth = (endPos - startPos):Length2D()
        
        return 0.5 + moveLenth / hero:GetBaseMoveSpeed()
    end
    
    return 2
end
