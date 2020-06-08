--fl 浮点数
--n 整数
--s 字符串
--h 句柄,指针
--v 向量


if GameMode == nil then
	_G.GameMode = class({}) 
end


require( "utils/utility_functions" )
require( "utils/timers" )
require( "utils/bit" )
require( "utils/json" )
require( "utils/table" )
require( "utils/notifications" )
require( "security" )
require( "hero_builder" )
require( "debugger" )
require( "round" )
require( "spawner" )
require( "barrage" )
require( "pvp_module" )
require( "util" )
require( "server" )
require( "econ" )
require( "item_loot" )
require( "summon" )
require( "pass" )
require( "illusion" )
require( "filter/damage_filter" )
require( "filter/order_filter" )
require( "filter/modifier_filter" )
require( "utils/sha" )


--抢预载入之前把英雄池挑选好
GameRules.allHeroesKV = LoadKeyValues("scripts/npc/herolist.txt")
GameRules.heroesPoolList = {}

-- 挑选英雄进行预载入
for k,_ in pairs(GameRules.allHeroesKV) do
   table.insert(GameRules.heroesPoolList,k)
   if GetMapName()== "1x8" then
      GameRules.heroesPoolList = table.random_some(GameRules.heroesPoolList,4*8)
   end
   if GetMapName()== "2x6" then
      GameRules.heroesPoolList = table.random_some(GameRules.heroesPoolList,3*12)
   end
   if GetMapName()== "5v5" then
      GameRules.heroesPoolList = table.random_some(GameRules.heroesPoolList,3*10)
   end
end

Timers:start()
--为生成前台的安全码
Security:Init()


Precache = require "Precache"

function Activate()
    GameMode:InitGameMode()
end

function GameMode:InitGameMode()
    
    GameRules:GetGameModeEntity().GameMode = self
    GameRules:GetGameModeEntity().GameMode.sVersion="4.20"
    GameRules:GetGameModeEntity().GameMode.sPasswordLobby="false"
    --Timers:start()
    HeroBuilder:Init()
    Debugger:Init()
    Barrage:Init()
    PvpModule:Init()
    Econ:Init()
    ItemLoot:Init()
    Summon:Init()
    Pass:Init()
    Illusion:Init()
    
    GameRules:SetSameHeroSelectionEnabled(true)
    GameRules:SetHeroSelectionTime(5)
    GameRules:SetStrategyTime(7)
    GameRules:SetShowcaseTime(0)
    --GameRules:SetSafeToLeave(true)

    if IsInToolsMode() then
       GameRules:SetPreGameTime(8)
       GameRules:SetStartingGold(600)
    else
       GameRules:SetPreGameTime(40)
       GameRules:SetStartingGold(600)
    end
    GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
    GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(999)
    
    --伤害统计表 key nPlayerID value 伤害值
    GameMode.damageCount={}
    
    --标记演员的次数
    GameMode.reportActorTime = {}

    --Key为ParytyID, Value为PartyNumber
    GameMode.partyListMap={}

    -- 有多少个组队队伍参与游戏
    GameMode.nPartyNumber=0

    --玩家组队情况的Map表，key nPlayerID value为PartyNumber（编号）
    GameMode.partyNumberMap={}

    --GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_wisp")
    
    local xpTable = {}

    xpTable[0] = 0
    xpTable[1] = 230
    xpTable[2] = 600
    xpTable[3] = 1080
    xpTable[4] = 1660
    xpTable[5] = 2260
    xpTable[6] = 2980
    xpTable[7] = 3730
    xpTable[8] = 4510
    xpTable[9] = 5320
    xpTable[10] = 6160
    xpTable[11] = 7030
    xpTable[12] = 7930
    xpTable[13] = 9155
    xpTable[14] = 10405
    xpTable[15] = 11680
    xpTable[16] = 12980
    xpTable[17] = 14305
    xpTable[18] = 15805
    xpTable[19] = 17395
    xpTable[20] = 18995
    xpTable[21] = 20845
    xpTable[22] = 22945
    xpTable[23] = 25295
    xpTable[24] = 27895
    for i = 25, 1000 do
        xpTable[i] = xpTable[i-1]+(i-24)*1000+2500
    end

    GameRules.xpTable = xpTable

    GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(xpTable)

    GameMode:AssembleHeroesData()
    --根据出生点 设置队伍玩家数量
    GameMode:SetTeam()

    --读取Round KV
    GameMode:ReadRoundConfigurations()
    
    --禁止复活
    GameRules:SetHeroRespawnEnabled( false )

    --商店
    GameRules:SetUseUniversalShopMode( true )
    
    --开全图
    GameRules:GetGameModeEntity():SetFogOfWarDisabled(true) 
    
    -- 锁定以后迅速进入游戏
    if IsInToolsMode() then
      GameRules:SetCustomGameSetupAutoLaunchDelay(10)
    else
      GameRules:SetCustomGameSetupAutoLaunchDelay(10)
    end

    SendToServerConsole("dota_max_physical_items_purchase_limit 9999")
   
    ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( GameMode, 'OnGameRulesStateChange' ), self )
    ListenToGameEvent("dota_item_purchased", Dynamic_Wrap(GameMode, "OnItemPurchased"), self)
    ListenToGameEvent("dota_player_gained_level", Dynamic_Wrap(GameMode, "OnHeroLevelUp"), self)
    ListenToGameEvent("player_reconnected", Dynamic_Wrap(GameMode, "OnPlayerReconnected"), self)
    ListenToGameEvent("dota_player_used_ability", Dynamic_Wrap(GameMode, "OnPlayerUsedAbility"), self)
    ListenToGameEvent("dota_player_learned_ability", Dynamic_Wrap(GameMode, "OnHeroLearnAbility"), self)


    CustomGameEventManager:RegisterListener("GetPayPalLink",Dynamic_Wrap(GameMode, 'GetPayPalLink'))
    CustomGameEventManager:RegisterListener("HeroIconClicked", Dynamic_Wrap(GameMode, 'HeroIconClicked'))
    CustomGameEventManager:RegisterListener("ToggleAutoDuel", Dynamic_Wrap(GameMode, 'ToggleAutoDuel'))
    CustomGameEventManager:RegisterListener("ToggleAutoCreep", Dynamic_Wrap(GameMode, 'ToggleAutoCreep'))
    CustomGameEventManager:RegisterListener("ClientReconnected", Dynamic_Wrap(GameMode, 'ClientReconnected'))


    GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(GameMode, "DamageFilter"), self)
    GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(GameMode, "OrderFilter"), self)
    GameRules:GetGameModeEntity():SetModifierGainedFilter(Dynamic_Wrap(GameMode, "ModifierGainedFilter"), self)


    GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(GameMode, "ModifyGoldFilter"), self)
    GameRules:GetGameModeEntity():SetBuybackEnabled(false)

    --队伍颜色
    local vTeamColors = {}
    vTeamColors[DOTA_TEAM_GOODGUYS] = { 61, 210, 150 }  --    Teal
    vTeamColors[DOTA_TEAM_BADGUYS]  = { 243, 201, 9 }   --    Yellow
    vTeamColors[DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }  --    Pink
    vTeamColors[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }   --    Orange
    vTeamColors[DOTA_TEAM_CUSTOM_3] = { 52, 85, 255 }   --    Blue
    vTeamColors[DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }  --    Green
    vTeamColors[DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }   --    Brown
    vTeamColors[DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }  --    Cyan
    vTeamColors[DOTA_TEAM_CUSTOM_7] = { 199, 228, 13 }  --    Olive
    vTeamColors[DOTA_TEAM_CUSTOM_8] = { 140, 42, 244 }  --    Purple
    
    -- 设置队伍颜色
    for nTeamNumber = 0, (DOTA_TEAM_COUNT-1) do
      local color = vTeamColors[ nTeamNumber ]
      if color then
        SetTeamCustomHealthbarColor( nTeamNumber, color[1], color[2], color[3] )
      end
    end

end

--读取英雄KV，组装数据
function GameMode:AssembleHeroesData()
   
   local heroKV =LoadKeyValues("scripts/npc/npc_heroes.txt")
   local abilityKV = LoadKeyValues("scripts/npc/npc_abilities.txt")

   for szHeroName, data in pairs(heroKV) do
      if data and type(data) == "table" then
         local heroInfo={}
         heroInfo.szHeroName = szHeroName
         heroInfo.szAttributePrimary = data.AttributePrimary
         heroInfo.talentNames={}
         heroInfo.talentValues={}
         for i=1,20 do
            if data["Ability"..i] and string.find(data["Ability"..i], "special_bonus_") then
               local sTalentName = data["Ability"..i]
               table.insert(heroInfo.talentNames, sTalentName) 
               table.insert(heroInfo.talentValues, FindTalentValue(abilityKV,sTalentName)  ) 
            end
         end
        CustomNetTables:SetTableValue( "hero_info",szHeroName,heroInfo)
      end
   end
   
end


--读取天赋 value 值传给前台，做国际化用
function FindTalentValue(abilityKV,sTalentName)
    local specialVal = abilityKV[sTalentName]["AbilitySpecial"]
    for l, m in pairs(specialVal) do
        if m["value"] then
            return m["value"]
        end
    end
    return nil
end




--读取Round数据
function GameMode:ReadRoundConfigurations()
   
   GameMode.vRoundData={}
   
   --原始
   GameMode.vRoundListRaw = {}
   --最终
   GameMode.vRoundList = {}
   --最全
   GameMode.vRoundListFull = {}
   
   --定义Phase1 ---> Phase50 定义，后面就重复了
   for i=1,50 do
     GameMode.vRoundListRaw[i]={}
     GameMode.vRoundList[i]={}
   end

   local roundsKV =LoadKeyValues("scripts/kv/rounds.txt")
   

   if IsInToolsMode() then
      --roundsKV =LoadKeyValues("scripts/kv/rounds_test.txt")
   end

   for sPhase, phaseData in pairs(roundsKV) do
      if phaseData and type(phaseData) == "table" then
         for sRoundName,roundData in pairs(phaseData) do
            if roundData and type(roundData) == "table" then
               table.insert(GameMode.vRoundListRaw[tonumber(sPhase)], sRoundName)
               table.insert(GameMode.vRoundList[tonumber(sPhase)], sRoundName)
               
               --两人模式怪物x2
               if GetMapName()=="2x6" then
                  for k,vData in pairs(roundData) do
                      vData.UnitNumber = math.ceil(tonumber(vData.UnitNumber)*2)
                  end
               end

               -- 五人模式怪物x5
               if GetMapName()=="5v5" then
                  for k,vData in pairs(roundData) do
                      --肉山轮三只 其他轮五倍
                      if sRoundName=="Round_Roshan" then
                         vData.UnitNumber = math.ceil(tonumber(vData.UnitNumber)*3)
                      else
                         vData.UnitNumber = math.ceil(tonumber(vData.UnitNumber)*5)
                      end
                  end
               end

               GameMode.vRoundData[sRoundName] = roundData
            end
         end
      end
      
   end
   
   -- 数量不足 补足数量
   for i=2,50 do
      if #GameMode.vRoundList[i]<10 then
         local randomPool = {}
         for j=1,i-1 do
            randomPool=table.join(randomPool,GameMode.vRoundListRaw[j])
         end
         -- 缺少的数量
         local nToSupplement = 10 - #GameMode.vRoundList[i]
         local supplementList = table.random_some(randomPool, nToSupplement)
         GameMode.vRoundList[i] = table.join(GameMode.vRoundList[i], supplementList)
      end
   end
   -- 深拷贝一份，如果主关卡用光从这里面随机选
   GameMode.vRoundListFull = table.deepcopy(GameMode.vRoundList)
   
   --PrintTable(GameMode.vRoundList)
end

function GameMode:OnHeroLevelUp(keys)
    
    local hHero = PlayerResource:GetSelectedHeroEntity(keys.player_id)
    local nLevel = hHero:GetLevel()
    if keys.level == nLevel then
        if nLevel > 25 then
            --为25级以上补足技能点数
            local nAbilityPoints = hHero:GetAbilityPoints()
            nAbilityPoints = nAbilityPoints + 1
            hHero:SetAbilityPoints(nAbilityPoints)
        end
    end
end

function GameMode:OnPlayerReconnected(keys)
   --为重连玩家重新展示选技能页面
   local retryTimes = 0
   local nPlayerID = keys.PlayerID
   
   --表示重连成功的表示
   if GameMode.reconnectedConfirm == nil then
      GameMode.reconnectedConfirm ={}
   end
   
   --刚重连的玩家
   GameMode.reconnectedConfirm[nPlayerID] = false
   
   Timers:CreateTimer({
        endTime = 5,
        callback = function()
            local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)

            --如果客户端确认已经重连，或者重复次数过多 结束本次定时任务
            if true==GameMode.reconnectedConfirm[nPlayerID] or retryTimes>50 then
               return nil
            end

            if true~=hHero.bSettled then
               return nil
            end

            if hHero and hHero.nAbilityNumber then
               if hHero.nAbilityNumber< HeroBuilder.totalAbilityNumber[nPlayerID] then
                   --必须是英雄已经确定的情况下重发请求
                  HeroBuilder:ShowRandomAbiliySelection(nPlayerID)
               end
            end

            retryTimes = retryTimes + 1
            return 1

        end
    })
end


function GameMode:OnGameRulesStateChange()
    
  local nNewState = GameRules:State_Get()
  if nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        
        GameRules.vPlayerSteamIdMap={}
        
        for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
           if PlayerResource:IsValidPlayer( nPlayerID ) then
              local nPlayerSteamId = PlayerResource:GetSteamAccountID(nPlayerID)
              GameRules.sValidePlayerSteamIds=GameRules.sValidePlayerSteamIds..nPlayerSteamId..","
              GameMode.nValidPlayerNumber = GameMode.nValidPlayerNumber + 1
              GameRules.vPlayerSteamIdMap[nPlayerSteamId]=nPlayerID
              if Econ.vPlayerData[nPlayerID] == nil then
                 Econ.vPlayerData[nPlayerID]={}
              end
           end
        end
        
        if string.sub(GameRules.sValidePlayerSteamIds,string.len(GameRules.sValidePlayerSteamIds))=="," then   --去掉最后一个逗号
            GameRules.sValidePlayerSteamIds=string.sub(GameRules.sValidePlayerSteamIds,0,string.len(GameRules.sValidePlayerSteamIds)-1)
        end

        print("GameRules.sValidePlayerSteamIds"..GameRules.sValidePlayerSteamIds)

        Server:GetRankData()
        Server:GetEconRarity()
  end
  
  if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
        Timers:CreateTimer(1, function()
          Server:GetPlayerEconData()
        end)
        
        --多人模式不允许暂停
        if GameMode.nValidPlayerNumber>1  and (not IsInToolsMode()) then
           GameRules:GetGameModeEntity():SetPauseEnabled(false)
        end

        Timers:CreateTimer(0.1, function()
            for nPlayerNumber = 0, DOTA_MAX_TEAM_PLAYERS do
                Timers:CreateTimer(0,function()
                    local hPlayer = PlayerResource:GetPlayer(nPlayerNumber)
                    if hPlayer then
                        --单机模式 并且是通行证玩家 可以自选英雄
                        if not (1==GameMode.nValidPlayerNumber and Pass.passInfo[nPlayerNumber]) then
                           hPlayer:MakeRandomHeroSelection()
                        end
                        Timers:CreateTimer(1, function()

                            if GameRules:IsGamePaused() then
                              return 0.03 
                            end

                            local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerNumber)

                            if not hHero then
                              return 0.03
                            end

                            Timers:CreateTimer(function()
                                if not IsValidAlive(hHero) then
                                  hHero:RespawnHero(false, false)
                                end
                            end)

                            -- 自动观战决斗的选择
                            if GameMode.autoDuelMap==nil then
                               GameMode.autoDuelMap = {}
                            end
                            GameMode.autoDuelMap[nPlayerNumber]=true

                            -- 自动观战PVE的选择
                            if GameMode.autoCreepMap==nil then
                               GameMode.autoCreepMap = {}
                            end
                            GameMode.autoCreepMap[nPlayerNumber]=false
                            
                            --初始化伤害统计
                            GameMode.damageCount[nPlayerNumber] = 0

                            --玩家加入队伍表                            
                            table.insert(GameMode.vTeamPlayerMap[hHero:GetTeamNumber()], nPlayerNumber)


                            --激活有效队伍，统计的时候只统计一次
                            if true~=GameMode.vAliveTeam[hHero:GetTeamNumber()] then
                                GameMode.vAliveTeam[hHero:GetTeamNumber()] =true
                                GameMode.nRank = GameMode.nRank + 1
                                GameMode.nValidTeamNumber = GameMode.nValidTeamNumber + 1
                                CustomNetTables:SetTableValue("team_rank", tostring(hHero:GetTeamNumber()), {rank=0})
                            end
                            
                            --PVP 战绩
                            CustomNetTables:SetTableValue("pvp_record", tostring(nPlayerNumber), {win=0,lose=0,total_bet_reward=0})
                            
                            --玩家组队
                            if PlayerResource:GetPartyID(nPlayerNumber) and tostring(PlayerResource:GetPartyID(nPlayerNumber))~="0" then
                              local sPartyID = tostring(PlayerResource:GetPartyID(nPlayerNumber))
                              if GameMode.partyListMap[sPartyID]==nil then
                                 GameMode.nPartyNumber = GameMode.nPartyNumber + 1
                                 GameMode.partyListMap[sPartyID] = GameMode.nPartyNumber
                              end     
                              GameMode.partyNumberMap[nPlayerNumber] = GameMode.partyListMap[sPartyID]
                              --print("nPlayerID:"..nPlayerNumber.."  sPartyID:"..sPartyID)
                            end
                            
                            CustomNetTables:SetTableValue("hero_info", "party_map", GameMode.partyNumberMap)
                            
                            Timers:CreateTimer(RandomFloat(0, 0.2), function()
                                if not hHero.bInited then
                                    HeroBuilder:InitPlayerHero(hHero)
                                end                               
                            end)

                        end)
                        return nil
                    end
                    return 0.1
                end)
            end
        end)
   end

  if  nNewState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
      for nPlayerNumber = 0, DOTA_MAX_TEAM_PLAYERS do
         local hPlayer = PlayerResource:GetPlayer(nPlayerNumber)
         if hPlayer then
           if  PlayerResource:GetSelectedHeroName(nPlayerNumber)==nil or PlayerResource:GetSelectedHeroName(nPlayerNumber)=="" then
              hPlayer:MakeRandomHeroSelection()
           end
         end
      end
  end

  if  nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
                
         --展示被禁用的技能
         if #Pass.banAbilityList>0 then
           Timers:CreateTimer(2.0, function()
            for _,abilityName in ipairs(Pass.banAbilityList) do
              Notifications:BottomToAll({ continue=true, text = "#DOTA_Tooltip_ability_"..abilityName, duration = 10, style = { color = "Red" ,["margin-right"]="30px;" }})
            end
            Notifications:BottomToAll({ continue=true, text = "#banned_in_game", duration = 10, style = { color = "Red" }})
           end)
         end

         -- 斗鱼活动地铺
         --GameMode:AddDouyuBanner()
         --为玩家 显示随机英雄面板 此处多次尝试 避免前台接受不到
         local retryTimes = 0;
         Timers:CreateTimer(0.5, function()
            if retryTimes<55 then
               for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS do
                    local hPlayer = PlayerResource:GetPlayer(nPlayerID)
                    if hPlayer then
                        HeroBuilder:ShowRandomHeroSelection(nPlayerID)
                        --PrintTable(Security.matchKeys)
                        if Security.matchKeys and Security.matchKeys[tostring(PlayerResource:GetSteamAccountID(nPlayerID))] then
                           CustomGameEventManager:Send_ServerToPlayer(hPlayer,"UpdatePlayerMatchKey",{security_key=Security:GetSecurityKey(nPlayerID),match_key=Security.matchKeys[tostring(PlayerResource:GetSteamAccountID(nPlayerID))],map_name=GetMapName()})
                        end
                    end
               end
               retryTimes = retryTimes +1
               return 1.0
            else
                return nil
                end
         end)
   end
   if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
         
       if GameMode.nValidTeamNumber==1 then
          --单队伍的提示
          if GetMapName()=="1x8" then
             Notifications:BottomToAll({ text = "#suicide_note", duration = 10, style = { color = "Red" }})
          end
          if GetMapName()=="2x6" or GetMapName()=="5v5"  then
             Notifications:BottomToAll({ text = "#one_team_in_multi_map_no_record", duration = 10, style = { color = "Red" }})
          end
       else
         if GameMode.sPasswordLobby=="true" then
            Notifications:BottomToAll({ text = "#password_lobby_note", duration = 15, style = { color = "Red" }})
         else
            --if GameMode.nValidTeamNumber>=5 then
              --Notifications:BottomToAll({ text = "#marked_actor_note", duration = 15, style = { color = "Red" }})
            --end
         end
       end

       GameRules.nGameStartTime=GameRules:GetGameTime()
       GameMode.currentRound= Round()
       --第一回合开始
       GameMode.currentRound:Prepare(1)
      
       --此处是一个全局计时器，不需要太频繁的逻辑都丢进去
       Timers:CreateTimer(1, function()
         --修复攻击范围
         HeroBuilder:FixAttackCapability()
         --更新伤害计时器
         local flMaxDamage = 0 
         for nPlayerID,flDamage in pairs(GameMode.damageCount) do
             if flDamage>flMaxDamage then
                 flMaxDamage = flDamage
             end
         end

         CustomNetTables:SetTableValue("hero_info", "damage_count", GameMode.damageCount)
         CustomNetTables:SetTableValue("hero_info", "max_damage", {max_damage=flMaxDamage})
         return 1
       end)

       for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
           if PlayerResource:IsValidPlayer( nPlayerID ) then
              local sPlayerSteamId = PlayerResource:GetSteamAccountID(nPlayerID)
              --重发一下数据，保证前台数据完整
              local playerData = CustomNetTables:GetTableValue("econ_data", "econ_info_"..sPlayerSteamId)          
              if playerData then
                 CustomNetTables:SetTableValue("econ_data", "econ_info_"..sPlayerSteamId,playerData)
                 --给玩家装备饰品
                 for nIndex,v in pairs(playerData) do
                    if v.type=="Particle" and v.equip=="true" then
                        Econ:EquipParticleEcon(v.name,nPlayerID)
                    end
                    if v.type=="KillEffect" and v.equip=="true" then
                        Econ:EquipKillEffectEcon(v.name,nPlayerID)
                    end
                    if v.type=="KillSound" and v.equip=="true" then
                        Econ:EquipKillSoundEcon(v.name,nPlayerID)
                    end
                    if v.type=="Barrage" and v.equip=="true" then
                        Econ:EquipBarrageEcon(v.name,nPlayerID)
                    end
                 end
              end

              local moneyData = CustomNetTables:GetTableValue("econ_data", "money_"..sPlayerSteamId)
              if moneyData then
                CustomNetTables:SetTableValue("econ_data", "money_"..sPlayerSteamId,moneyData)
              end
           end
        end
   end
end


function GameMode:FinishRound()

   local nRoundNumber = GameMode.currentRound.nRoundNumber
   --关卡完成 清空定时任务
   GameMode.currentRound:End()

   nRoundNumber = nRoundNumber +1 
   GameMode.currentRound= Round()
   GameMode.currentRound:Prepare(nRoundNumber)
end                             



function GameMode:SetTeam()
    
    --汇总玩家的steamID
    GameRules.sValidePlayerSteamIds=""

    --汇总秒退玩家的steamID
    GameRules.sEarlyLeavePlayerSteamIds=""

    GameMode.vTeamList = {}
    -- key为team, value 为玩家ID队列  
    GameMode.vTeamPlayerMap={}

    --纪录队伍是否存活
    GameMode.vAliveTeam = {}

    --排名
    GameMode.nRank = 0
    
    --排名表  key为名次 value为teamNumber
    GameMode.rankMap = {}

    --有效队伍总数
    GameMode.nValidTeamNumber = 0

    --有效玩家总数
    GameMode.nValidPlayerNumber = 0
    
    --纪录Team的刷怪中心点
    GameMode.vTeamLocationMap = {}

    --纪录Team的出生点
    GameMode.vTeamStartLocationMap = {}

    --根据地图出生点，设置队伍
    for _, hPlayerStart in pairs( Entities:FindAllByClassname( "info_player_start_dota" ) ) do
        table.insert(GameMode.vTeamList, hPlayerStart:GetTeam())
         GameMode.vTeamStartLocationMap[hPlayerStart:GetTeam()] = hPlayerStart:GetOrigin()
    end
    
    local nTeamMaxPlayers = 1
    if GetMapName() == "1x8" then 
       nTeamMaxPlayers = 1
    end

    if GetMapName() == "2x6"  then 
       nTeamMaxPlayers = 2
    end
    
    if GetMapName() == "5v5"  then 
       nTeamMaxPlayers = 5
    end

    for i=1,#GameMode.vTeamList do
          local nTeamNumber = GameMode.vTeamList[i]
          GameRules:SetCustomGameTeamMaxPlayers(nTeamNumber, nTeamMaxPlayers )
          GameMode.vAliveTeam[nTeamNumber] =false
          GameMode.vTeamPlayerMap[nTeamNumber] = {}
          local wayPoint = Entities:FindByName(nil, "center_"..nTeamNumber)
          GameMode.vTeamLocationMap[nTeamNumber] = wayPoint:GetOrigin()
    end

end

--玩家金币变化
function GameMode:ModifyGoldFilter(keys)

    Timers:CreateTimer( GameRules:GetGameFrameTime(),
     function()
        GameMode:UpdatePlayerGold(keys.player_id_const)
     end
     )
    return true
end

--向前台更新玩家金币信息
function GameMode:UpdatePlayerGold(nPlayerID)
    local hPlayer = PlayerResource:GetPlayer(nPlayerID)
    if hPlayer then
     CustomGameEventManager:Send_ServerToPlayer(hPlayer, "UpdateBetInput", {})
     --local nGold = PlayerResource:GetGold(nPlayerID)+PlayerResource:GetGoldSpentOnItems(nPlayerID)+PlayerResource:GetGoldSpentOnConsumables(nPlayerID)
     local nGold =math.ceil(PlayerResource:GetGoldPerMin(nPlayerID) * (GameRules:GetGameTime() - GameRules.nGameStartTime)/60)+600-PvpModule.betValueSum[nPlayerID]
     CustomNetTables:SetTableValue("player_info", tostring(nPlayerID), {gold=nGold})
    end
end


--玩家购买物品
function GameMode:OnItemPurchased(keys)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.PlayerID), "UpdateBetInput", {})
end

function GameMode:HeroIconClicked(keys) 
    local nPlayerID = keys.playerId
    local nTargetPlayerID = keys.targetPlayerId
    local nDoubleClick = keys.doubleClick
    local nControldown = keys.controldown
    local nAltDown = keys.altdown
    
    local hTargetHero =  PlayerResource:GetSelectedHeroEntity(nTargetPlayerID)  
    if hTargetHero then                 
        --如果按住ctrl 或者双击，定位到目标位置              
        if nDoubleClick==1  or nControldown==1 then
          PlayerResource:SetCameraTarget(nPlayerID,hTargetHero)
          Timers:CreateTimer({ endTime = 0.1, 
             callback = function()
                PlayerResource:SetCameraTarget(nPlayerID,nil) 
             end
          })
        end
    end
    if hTargetHero and nAltDown==1 then
      if PlayerResource:GetPlayer(nPlayerID) then
        local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
        if hHero then
          if nPlayerID~=nTargetPlayerID then
           hHero.sActorUISecret = CreateSecretKey()
           CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"ShowActorPanel",{target_player_id=nTargetPlayerID, time=GameMode.reportActorTime[nPlayerID], actor_ui_secret=hHero.sActorUISecret, security_key=Security:GetSecurityKey(nPlayerID)} );
          end
        end
      end
    end
end



function GameMode:ToggleAutoDuel(keys)
    local nPlayerID = keys.PlayerID
    local bSelected = (1==keys.selected)
    if GameMode.autoDuelMap then
       GameMode.autoDuelMap[nPlayerID]=bSelected
    end
end


function GameMode:ToggleAutoCreep(keys)
    local nPlayerID = keys.PlayerID
    local bSelected = (1==keys.selected)
    if GameMode.autoCreepMap then
       GameMode.autoCreepMap[nPlayerID]=bSelected
    end
end


function GameMode:GetPayPalLink(keys) 
    local nPlayerID = keys.playerId
    Server:GetPayPalLink(nPlayerID)
end


--队伍失败
function GameMode:TeamLose(nTeamNumber)

     GameMode.vAliveTeam[nTeamNumber] = false
     local data={}
     data.type = "team_lose"
     data.nTeamNumber = nTeamNumber
     Barrage:FireBullet(data)
     
     --淘汰玩家清空金币
     for _,nPlayerID in ipairs(GameMode.vTeamPlayerMap[nTeamNumber]) do
          local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)  
          hHero:SetGold(0, true)
          --判断玩家是否秒退
          if GameMode.currentRound and  GameMode.currentRound.nRoundNumber and GameMode.currentRound.nRoundNumber<=5 then
             if DOTA_CONNECTION_STATE_ABANDONED == PlayerResource:GetConnectionState(nPlayerID)  then
                local nPlayerSteamId = PlayerResource:GetSteamAccountID(nPlayerID)
                if nPlayerSteamId then
                  GameRules.sEarlyLeavePlayerSteamIds=GameRules.sEarlyLeavePlayerSteamIds..nPlayerSteamId..","
                end
             end
          end
     end

     if GameMode.currentRound.spanwers[nTeamNumber]  then
        --强制停机
        GameMode.currentRound.spanwers[nTeamNumber].bForceStop = true
        
        for i, hCreep in ipairs( GameMode.currentRound.spanwers[nTeamNumber].vCurrentCreeps ) do
            if  hCreep and (not hCreep:IsNull()) and  hCreep:IsAlive() then
               --不会被击杀监听到
               hCreep.nSpawnerTeamNumber =nil
               hCreep:ForceKill(false)
            end
        end            
     end

     --清理数据
     Util:CleanPvpPair(nTeamNumber)
     
     --单人模式 游戏结束
     if GameMode.nValidTeamNumber == 1 and GameMode.nRank == 1 then 
        if GetMapName()=="1x8" then
          -- 获取玩家SteamId
          local nPlayerID = GameMode.vTeamPlayerMap[nTeamNumber][1]
          local nPlayerSteamId = PlayerResource:GetSteamAccountID(nPlayerID)
          if not GameRules:IsCheatMode() or (IsInToolsMode()) then
             Server:EndPveGame(nTeamNumber,GameMode.currentRound.nRoundNumber,nPlayerSteamId)
          else
              Notifications:BottomToAll({ text = "#cheat_no_record", duration = 4, style = { color = "Red" }})
                 Timers:CreateTimer(4, function()
                    GameRules:SetGameWinner(nTeamNumber)
              end)
          end
        end
        if GetMapName()=="2x6" or GetMapName()=="5v5" then
           Notifications:BottomToAll({ text = "#one_team_in_multi_map_no_record", duration = 4, style = { color = "Red" }})
              Timers:CreateTimer(4, function()
                    GameRules:SetGameWinner(nTeamNumber)
           end)
        end
     else
         -- 多人模式 第二名已经淘汰，结束游戏
         if GameMode.nValidTeamNumber >= 2 and  GameMode.nRank == 2 then
            local nWinnerTeam 
            for nAliveTeamNumber,bAlive in pairs(GameMode.vAliveTeam) do
                 if bAlive then
                     nWinnerTeam = nAliveTeamNumber
                 end
            end
            --前两名 名次已出
            GameMode.rankMap[2] = nTeamNumber
            CustomNetTables:SetTableValue("team_rank", tostring(nTeamNumber), {rank=2})
            GameMode.rankMap[1] = nWinnerTeam
            CustomNetTables:SetTableValue("team_rank", tostring(nWinnerTeam), {rank=1})
            
            --5v5 地图不记录天梯
            if (not GameRules:IsCheatMode() or IsInToolsMode()) then
               if GetMapName()=="5v5" then
                  Notifications:BottomToAll({ text = "#5v5_no_record", duration = 4, style = { color = "Red" } })
                  Timers:CreateTimer(4, function()
                    GameRules:SetGameWinner(nWinnerTeam)
                  end)
               else
                  Server:EndPvpGame(nWinnerTeam)
               end
            else
               Notifications:BottomToAll({ text = "#cheat_no_record", duration = 4, style = { color = "Red" } })
               Timers:CreateTimer(4, function()
                  GameRules:SetGameWinner(nWinnerTeam)
               end)
            end
            GameMode.nRank = GameMode.nRank-1
         else
            -- 以上都不是 淘汰玩家 游戏继续
            -- 遍历败者队伍 玩家弹出结算页面
            for _,nPlayerID in ipairs(GameMode.vTeamPlayerMap[nTeamNumber]) do
               local hPlayer = PlayerResource:GetPlayer(nPlayerID)
               if hPlayer then
                 CustomGameEventManager:Send_ServerToPlayer(hPlayer,"ShowPlayerLose",{game_rank= GameMode.nRank,valid_team=GameMode.nValidTeamNumber,security_key=Security:GetSecurityKey(nPlayerID)})
               end
            end
            -- 纪录名次
            GameMode.rankMap[GameMode.nRank] = nTeamNumber
            CustomNetTables:SetTableValue("team_rank", tostring(nTeamNumber), {rank=GameMode.nRank})
            GameMode.nRank = GameMode.nRank -1
         end
      end

end


--添加活动地铺
function GameMode:AddDouyuBanner()
      
      local mapCenter = Entities:FindByName(nil, "map_center")
      if mapCenter then
        local nParticleIndex = ParticleManager:CreateParticle("particles/econ/douyu_cup.vpcf",PATTACH_ABSORIGIN_FOLLOW,mapCenter)
        ParticleManager:SetParticleControlEnt(nParticleIndex,0,mapCenter,PATTACH_ABSORIGIN_FOLLOW,"follow_origin",mapCenter:GetAbsOrigin(),true)
        ParticleManager:ReleaseParticleIndex(nParticleIndex)
      end
end

--监听使用技能,禁止长距离位移连招
function GameMode:OnPlayerUsedAbility(keys)
   
   if ("phoenix_icarus_dive"==keys.abilityname or "morphling_waveform"==keys.abilityname or "slark_pounce"==keys.abilityname or "earth_spirit_rolling_boulder"==keys.abilityname) and keys.PlayerID then
      local hHero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
      if hHero then
          for i = 0, 11 do --遍历物品
             local hItem = hHero:GetItemInSlot(i)
             if hItem and hItem.GetAbilityName  and "item_blink"==hItem:GetAbilityName() then
                if hItem:GetCooldownTimeRemaining() <2 then
                   hItem:StartCooldown(2) 
                end
             end
             if hHero:FindItemInInventory("item_fallen_sky") then
                local hFallenSky = hHero:FindItemInInventory("item_fallen_sky")
                if hFallenSky:GetCooldownTimeRemaining() <2 then
                   hFallenSky:StartCooldown(2) 
                end
             end
          end
          for i = 0, 20 do --遍历技能
             local hAbility = hHero:GetAbilityByIndex(i)
             if hAbility and hAbility.GetAbilityName then                 
                if "antimage_blink"==hAbility:GetAbilityName()  or "queenofpain_blink"==hAbility:GetAbilityName() or
                   "ember_spirit_fire_remnant"==hAbility:GetAbilityName()  or "puck_illusory_orb"==hAbility:GetAbilityName() or
                   "morphling_waveform" ==hAbility:GetAbilityName()  or "slark_pounce" ==hAbility:GetAbilityName() or 
                   "faceless_void_time_walk" ==hAbility:GetAbilityName() or "magnataur_skewer" ==hAbility:GetAbilityName() or 
                   "phoenix_icarus_dive" ==hAbility:GetAbilityName() or "void_spirit_astral_step" ==hAbility:GetAbilityName() or
                   "earth_spirit_rolling_boulder" == hAbility:GetAbilityName() or "techies_suicide" == hAbility:GetAbilityName() or "sandking_burrowstrike" == hAbility:GetAbilityName()  then
                   if hAbility:GetCooldownTimeRemaining() <2 then
                     hAbility:StartCooldown(2) 
                   end
                end
                if hHero.HasScepter and hHero:HasScepter() and "earthshaker_enchant_totem" == hAbility:GetAbilityName() then
                  if hAbility:GetCooldownTimeRemaining() <2 then
                     hAbility:StartCooldown(2) 
                  end
                end
             end
          end
      end
   end

end



function GameMode:ClientReconnected(keys)
   local nPlayerID = keys.PlayerID
   if GameMode.reconnectedConfirm then
      GameMode.reconnectedConfirm[nPlayerID] = true
   end
end


--学习真熊形态附赠技能
function GameMode:OnHeroLearnAbility(keys)
   local hHero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
   if "lone_druid_true_form" ==  keys.abilityname and hHero and hHero:IsRealHero() and not hHero:IsTempestDouble() then
       local hAbility1 = hHero:FindAbilityByName("lone_druid_true_form_druid") 
       if hAbility1 then
           hAbility1:SetLevel(hAbility1:GetLevel()+1)
       end
       local hAbility2 = hHero:FindAbilityByName("lone_druid_true_form_battle_cry") 
       if hAbility2 then
           hAbility2:SetLevel(hAbility2:GetLevel()+1)
       end
   end
   if "lone_druid_true_form_druid" ==  keys.abilityname and hHero and hHero:IsRealHero() and not hHero:IsTempestDouble() then
       local hAbility1 = hHero:FindAbilityByName("lone_druid_true_form_battle_cry") 
       if hAbility1 then
           hAbility1:SetLevel(hAbility1:GetLevel()+1)
       end
   end
end
