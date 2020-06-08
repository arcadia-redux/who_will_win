if Pass == nil then Pass = class({}) end

function Pass:Init()

    CustomGameEventManager:RegisterListener("BanAbility",function(_, keys)
        self:BanAbility(keys)
    end)

    CustomGameEventManager:RegisterListener("SubscribePassByCoins",function(_, keys)
        self:SubscribePassByCoins(keys)
    end)

    CustomGameEventManager:RegisterListener("GetPayPalLink",Dynamic_Wrap(GameMode, 'GetPayPalLink'))
    
    --key:nPlayerID value:boolean
    Pass.passInfo = {}
    
   --key:sSteamID value:boolean
    Pass.steamPassInfo = {}

    --key:nPlayerID value:禁用技能的剩余次数
    Pass.banAbilityTime = {}
    
    Pass.banAbilityList = {}
end




function Pass:BanAbility(keys)
    
    if Pass.passInfo[keys.PlayerID] then
       if Pass.banAbilityTime[keys.PlayerID] and Pass.banAbilityTime[keys.PlayerID]>0 then
         
          print("Ban Hero:"..keys.heroName.." Ability: "..keys.abilityName)
          
          if table.contains(HeroBuilder.allAbilityNames,keys.abilityName) then
            table.remove_item(HeroBuilder.allAbilityNames,keys.abilityName)
          end

          if HeroBuilder.heroAbilityPool[keys.heroName] then
            if table.contains(HeroBuilder.heroAbilityPool[keys.heroName],keys.abilityName) then
               table.remove_item(HeroBuilder.heroAbilityPool[keys.heroName],keys.abilityName)
            end
          end

          if table.contains(HeroBuilder.summonAbilities,keys.abilityName) then
             table.remove_item(HeroBuilder.summonAbilities,keys.abilityName)
          end

          Pass.banAbilityTime[keys.PlayerID] = Pass.banAbilityTime[keys.PlayerID]-1
          if not table.contains(Pass.banAbilityList,keys.abilityName) then
            table.insert(Pass.banAbilityList, keys.abilityName)
            --更新NetTable推送给前台
            CustomNetTables:SetTableValue("hero_info", "ban_abilities", Pass.banAbilityList)
          end
       end
    end

end


function Pass:InitPassData(passData)

    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS do
        local hPlayer = PlayerResource:GetPlayer(nPlayerID)
        if hPlayer and PlayerResource:GetSteamAccountID(nPlayerID) then
            local sSteamID = tostring(PlayerResource:GetSteamAccountID(nPlayerID))

            if passData[sSteamID] and  passData[sSteamID].player_steam_id then

                Pass.passInfo[nPlayerID] = true
                Pass.steamPassInfo[sSteamID] = true

                --Pass玩家报告两次演员
                GameMode.reportActorTime[nPlayerID]=3
                --Pass玩家可以禁用两个技能
                Pass.banAbilityTime[nPlayerID] = 2

                CustomNetTables:SetTableValue("player_info", "pass_data_"..nPlayerID, passData[sSteamID])
            else       
                --其他玩家报告一次演员
                GameMode.reportActorTime[nPlayerID]=1
                Pass.passInfo[nPlayerID] = false
            end
        end
    end
    
    local nRetryTime=1

    Timers:CreateTimer(0.0, function()
      for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS do
          local hPlayer = PlayerResource:GetPlayer(nPlayerID)
          if hPlayer then
             CustomGameEventManager:Send_ServerToPlayer(hPlayer,"UpdatePassData",{pass_valid=Pass.passInfo[nPlayerID]})
          end
      end
      nRetryTime = nRetryTime+1
      if nRetryTime>300 then
         return nil
      else
         return 0.05
      end
    end)
    
end


function Pass:SubscribePassByCoins(keys)
     Server:SubscribePassByCoins(keys.PlayerID)
end


function Pass:AddDemoCosmetics(data,nRequestPlayerID)
    
    local econRarity = CustomNetTables:GetTableValue("econ_rarity", "econ_rarity");
    local econType = CustomNetTables:GetTableValue("econ_type", "econ_type");
    local availableCosmetics ={}

    for key,value in pairs(econRarity) do
        if value=="1" or value=="2" or value=="3" then
          table.insert(availableCosmetics, key)
        end
    end

    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS do
        local hPlayer = PlayerResource:GetPlayer(nPlayerID)
        if hPlayer and (nRequestPlayerID==nil or nPlayerID==nRequestPlayerID) then
            local sSteamID = tostring(PlayerResource:GetSteamAccountID(nPlayerID))
            --如果是Pass玩家，给他增加20个试用饰品
            if Pass.steamPassInfo[sSteamID] then

                local nNumber = 0;

                availableCosmetics=table.shuffle(availableCosmetics)

                local ownCosmetics={}
                
                --如果是中途激活的PASS，重新构造一份数据
                if not data then
                  data = {}
                  data["econ_info"] = {}
                  data["econ_info"][sSteamID] = CustomNetTables:GetTableValue("econ_data", "econ_info_"..sSteamID);
                  data["money"] = {}
                  data["money"][sSteamID] = CustomNetTables:GetTableValue("econ_data", "money_"..sSteamID).money;
                end

                for _,v in ipairs(data["econ_info"][sSteamID]) do
                    table.insert(ownCosmetics, v.name)
                end

                for _,cosmetic in ipairs(availableCosmetics) do
                   -- 试用饰品是玩家没有的
                   if not table.contains(ownCosmetics, cosmetic) then
                      local tempCosmetic ={}
                      tempCosmetic["player_steam_id"] = sSteamID
                      tempCosmetic["name"] = cosmetic
                      tempCosmetic["equip"] = "false"
                      tempCosmetic["type"] = econType[cosmetic]
                      tempCosmetic["demo"] = "true"
                      table.insert(data["econ_info"][sSteamID], tempCosmetic)         
                      nNumber = nNumber +1
                   end
                   if nNumber>15 then
                      break;
                   end
                end
            end
            CustomNetTables:SetTableValue("econ_data", "econ_info_"..sSteamID, data["econ_info"][sSteamID])
            CustomNetTables:SetTableValue("econ_data", "money_"..sSteamID, {money=data["money"][sSteamID]})
            
        end
    end
end
