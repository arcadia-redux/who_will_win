
--重要逻辑不能写在这里面 因为会被恶意伪造
function GameMode:OrderFilter(orderTable)
     
    local nPlayerID = orderTable.issuer_player_id_const
    -- 玩家不能捡起或攻击 其他队伍的中立物品
    if (orderTable.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM or orderTable.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET ) and orderTable.queue == 0 then
        local hTarget = EntIndexToHScript(orderTable.entindex_target)
        if nPlayerID and hTarget and hTarget.GetContainedItem and hTarget:GetContainedItem()  then
            local hItem = hTarget:GetContainedItem()
            if hItem.nTeamNumber then
               if hItem.nTeamNumber~= PlayerResource:GetTeam(nPlayerID) then
                  return false
               end
            end
        end
    end

    --不能扔出储物篮
    if (orderTable.order_type == DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH) and orderTable.queue == 0 then     
        return false
    end

    --不能扔圣剑
    if (orderTable.order_type == DOTA_UNIT_ORDER_DROP_ITEM) and orderTable.queue == 0 then     
        local hAbility = EntIndexToHScript(orderTable.entindex_ability)
        if hAbility and hAbility:IsItem() then
           if hAbility:GetName() and "item_rapier" == hAbility:GetName() then
              return false
           end
        end
    end

    --传送中立物品，改为出售
    if orderTable.order_type == 37  and orderTable.queue == 0 then
        local hAbility = EntIndexToHScript(orderTable.entindex_ability)
        -- 先限制只能是中立物品
        if hAbility and hAbility:IsItem() and not hAbility:IsPurchasable() and orderTable.units and orderTable.units["0"] then
           local hSeller =  EntIndexToHScript(orderTable.units["0"])
           if (hSeller:IsNull() or hSeller:IsTempestDouble() or hSeller:IsIllusion() or (not hSeller:IsRealHero())) then
               return false
           end
           --必须是自己的指令
           if hSeller.GetPlayerID and hSeller:GetPlayerID() == nPlayerID  and  hAbility.nTeamNumber== PlayerResource:GetTeam(nPlayerID)  then
              local nGold = math.floor(hAbility:GetCost()/2)
              local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
              if hHero then
               SendOverheadEventMessage(hHero, OVERHEAD_ALERT_GOLD, hHero, nGold, nil)
              end
              PlayerResource:ModifyGold(nPlayerID,nGold, true, DOTA_ModifyGold_Unspecified)
              UTIL_Remove(hAbility)
              return false
           else
              return false
           end
        end
    end
    
     --打断技能拖拽换位
    if orderTable.queue == 0 then
       if nPlayerID then
           local hPlayer = PlayerResource:GetPlayer(nPlayerID)
           if hPlayer then
               CustomGameEventManager:Send_ServerToPlayer(hPlayer,"ReorderInterrupt",{state=false} )   
           end
       end
    end
    return true
end