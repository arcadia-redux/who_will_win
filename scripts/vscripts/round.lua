if Round == nil then Round = class({}) end
LinkLuaModifier( "modifier_creature_berserk", "creature_ability/modifier_creature_berserk", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creature_berserk_debuff", "creature_ability/modifier_creature_berserk_debuff", LUA_MODIFIER_MOTION_NONE )


--基本准备时间
nBasePrepareTotalTime=15
if IsInToolsMode() then
    nBasePrepareTotalTime=8
end

nRoundLimitTime=50
if IsInToolsMode() then
    --nRoundLimitTime=50
end
nRoundBaseBonus=300


--补偿技能书的关卡
compensateRoundNumber = {}
compensateRoundNumber[10]=true
compensateRoundNumber[20]=true
compensateRoundNumber[30]=true

if IsInToolsMode() then
 --compensateRoundNumber[1]=true
 --compensateRoundNumber[2]=true
 --compensateRoundNumber[3]=true
end


--选择技能的关卡
abilitySelectionRoundNumber = {}
abilitySelectionRoundNumber[3]=true
abilitySelectionRoundNumber[6]=true
abilitySelectionRoundNumber[9]=true


if IsInToolsMode() then
  abilitySelectionRoundNumber = {}
  abilitySelectionRoundNumber[2]=true
  abilitySelectionRoundNumber[3]=true
  abilitySelectionRoundNumber[4]=true
end

function Round:Prepare(nRoundNumber)
    
    self.spanwers={}
    self.bEnd = false
    --怪物数量
    self.nCreatureNumber = 0
    self.nRoundNumber=nRoundNumber
    
    if nRoundNumber>=1 then
       GameRules:SetSafeToLeave(true)
    end

    --玩家关卡排名
    self.nPlayerRank = 0
        
    self.nPrepareTotalTime = nBasePrepareTotalTime

    self.readyPlayers = {}

    --整理有效队伍
    for nTeamNumber,bAlive in pairs(GameMode.vAliveTeam) do
      if bAlive then
          for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
            if PlayerResource:IsValidPlayer(nPlayerID) and  PlayerResource:GetConnectionState(nPlayerID) == DOTA_CONNECTION_STATE_CONNECTED  then
                self.readyPlayers[nPlayerID] = false
            end
          end
       end
    end


    -- 如果本关需要选择技能
    if abilitySelectionRoundNumber[nRoundNumber] then

       for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS do
          HeroBuilder.totalAbilityNumber[nPlayerID] = HeroBuilder.totalAbilityNumber[nPlayerID]+1
       end
       
       --延长准备时间
       if IsInToolsMode() then
         self.nPrepareTotalTime = nBasePrepareTotalTime + 1
       else
         self.nPrepareTotalTime = nBasePrepareTotalTime + 15
       end
    end
    
    --统计存活玩家数量
    self.nAliveTeamNumber = 0 
    for nTeamNumber,bAlive in pairs(GameMode.vAliveTeam) do
      if bAlive then
        self.nAliveTeamNumber = self.nAliveTeamNumber+1
        --为玩家弹出选择技能
        if abilitySelectionRoundNumber[nRoundNumber] then
          for _,nPlayerID in ipairs(GameMode.vTeamPlayerMap[nTeamNumber]) do
              HeroBuilder:ShowRandomAbiliySelection(nPlayerID)
          end
        end
      end
    end

    if GetMapName()=="2x6" then
       nRoundBaseBonus = 320
    end

    if GetMapName()=="5v5" then
       nRoundBaseBonus = 350
    end

    --过关奖励第一名100% 第二名递减 ,65轮以上不再提高
    if tonumber(nRoundNumber)<65 then
       self.flBonus = nRoundBaseBonus * math.pow(1.031, (tonumber(nRoundNumber)-1))
    else
       self.flBonus = nRoundBaseBonus * math.pow(1.031, 65)
    end
    

    --1-10 Phase1  11-20 Phase2 21-30 Phase3.....
    local nPhase = math.ceil(nRoundNumber/10)

    -- 50 阶段以上未定义，从5-49轮里面随机抽取
    if GameMode.vRoundList[nPhase] ==nil then
       local nRandomPhase = RandomInt(5, 49)
       --随机取一份
       GameMode.vRoundList[nPhase] = table.deepcopy(GameMode.vRoundListFull[nRandomPhase])
    end

    self.sRoundName = table.random(GameMode.vRoundList[nPhase])
    for i,v in ipairs(GameMode.vRoundList[nPhase]) do
        if v == self.sRoundName then
            table.remove(GameMode.vRoundList[nPhase], i)
        end
    end
    
    --统计怪物数量
    for k,vData in pairs(GameMode.vRoundData[self.sRoundName]) do
       self.nCreatureNumber = tonumber(vData.UnitNumber) +self.nCreatureNumber
    end
    
    --经验倍率
    self.flExpMulti = 1 
    
    if GetMapName()=="2x6" then
       self.flExpMulti = 2
    end

    if GetMapName()=="5v5" then
       self.flExpMulti = 5
    end

    --本轮进行PVP 进行PVP相关准备
    if self.nRoundNumber - PvpModule.nLastPvpRound >= PvpModule.nInterval then
       --肉山轮不进行PVP
       if self.sRoundName~="Round_Roshan" then

          --PVP轮延长准备时间
          if GetMapName()=="1x8" then
             self.nPrepareTotalTime = self.nPrepareTotalTime + 2
          end

          if GetMapName()=="2x6" then
             self.nPrepareTotalTime = self.nPrepareTotalTime + 5
          end

          PvpModule:RoundPrepare(self.nRoundNumber)
       end
    end
    
    --准备时间
    self.nPrepareTime = 0

    CustomGameEventManager:Send_ServerToAllClients("CreateQuest", { name = "RoundPrepare", text = "#round_prepare", svalue = 0, evalue = self.nPrepareTotalTime, text_value=self.nRoundNumber, text_value_2="#"..self.sRoundName })
    CustomGameEventManager:Send_ServerToAllClients("UpdateReadyButton", {visible=true})
    CustomGameEventManager:RegisterListener("PlayerReady",function(_, keys) self:PlayerReady(keys) end)


    Timers:CreateTimer(1, function()
           self.nPrepareTime = self.nPrepareTime+1
           CustomGameEventManager:Send_ServerToAllClients("RefreshQuest", { name = "RoundPrepare", text = "#round_prepare", svalue =self.nPrepareTime, evalue = self.nPrepareTotalTime, text_value=self.nRoundNumber,text_value_2="#"..self.sRoundName })
           CustomGameEventManager:Send_ServerToAllClients("UpdateConfirmButton", { currentTime =self.nPrepareTime, totalTime = self.nPrepareTotalTime })
           --如果关卡被强制结束
           if self.bEnd then
              CustomGameEventManager:Send_ServerToAllClients("RemoveQuest", { name = "RoundPrepare" })
              return nil
           end

           local bAllReady = true
           --遍历玩家是否准备成功
           for nTeamNumber,bAlive in pairs(GameMode.vAliveTeam) do
             if bAlive then
                for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
                  if PlayerResource:IsValidPlayer(nPlayerID) and  PlayerResource:GetConnectionState(nPlayerID) == DOTA_CONNECTION_STATE_CONNECTED  then
                     if false==self.readyPlayers[nPlayerID] then
                         bAllReady = false
                     end
                  end
                end
             end
           end

           if bAllReady or (self.nPrepareTime >= self.nPrepareTotalTime) then
              self:Begin()
              return nil
           else
              return 1
           end
    end)
end




function Round:Begin()

    --第一关强制选择英雄
    if self.nRoundNumber==1 then
       HeroBuilder:ForceFinishHeroBuild()
    end

    self.nTimeLimit = nRoundLimitTime

    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
      --断线玩家不参与PVP
      if PlayerResource:IsValidPlayer(nPlayerID)  then
         local hPlayer = PlayerResource:GetPlayer(nPlayerID)
         if hPlayer then
            CustomGameEventManager:Send_ServerToPlayer(hPlayer, "HidePvpBet", {security_key=Security:GetSecurityKey(nPlayerID)})
         end
      end
    end

    CustomGameEventManager:Send_ServerToAllClients("ResetPlayerReadyList", {})

    --总结PVP信息
    PvpModule:SummarizeBetInfo()
    
    CustomGameEventManager:Send_ServerToAllClients("UpdateReadyButton", {visible=false})
    CustomGameEventManager:Send_ServerToAllClients("RemoveQuest", { name = "RoundPrepare" })

    --遍历存活队伍 开始刷怪
    for nTeamNumber,bAlive in pairs(GameMode.vAliveTeam) do
       if bAlive==true then
          
          --本队是否有人参加PVP
          local bTeamPvpFlag = false 

          --移动英雄到各自方块
          for nPlayerIndex,nPlayerID in ipairs(GameMode.vTeamPlayerMap[nTeamNumber]) do

            local bPlayerPvpFlag = false
            local vCenter = GameMode.vTeamLocationMap[nTeamNumber]
            local hPlayer = PlayerResource:GetPlayer(nPlayerID)
            local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)  

             -- 如果队伍参与PVP
             for i,pvpTeamID in ipairs(PvpModule.currentPair) do
                if pvpTeamID == nTeamNumber then
                   -- 两个PVP英雄拆开距离
                   vCenter = PvpModule.vHomeCenter - Vector( (3-i*2)*550,0,0)

                   --2x6 两个英雄 上下站位
                   if GetMapName()=="2x6" then
                        vCenter = vCenter + Vector(0,(3-nPlayerIndex*2)*350,0)
                   end

                   --5v5 5个英雄 散点站位
                   if GetMapName()=="5v5" then
                      local wayPoint = Entities:FindByName(nil, "center_pvp_"..nTeamNumber)
                      vCenter = wayPoint:GetOrigin()+RandomVector(300)
                   end

                   bTeamPvpFlag =true
                   bPlayerPvpFlag= true
                   
                   local nPvpParticle = ParticleManager:CreateParticle("particles/econ/items/legion/legion_weapon_voth_domosh/legion_duel_start_ring_arcana.vpcf", PATTACH_CUSTOMORIGIN, nil)
                   ParticleManager:SetParticleControl(nPvpParticle, 0, vCenter)  --ring position
                   ParticleManager:SetParticleControl(nPvpParticle, 7, vCenter)  --flag's position
                   Timers:CreateTimer({ endTime = 1, 
                      callback = function()
                          ParticleManager:DestroyParticle(nPvpParticle, false)
                          ParticleManager:ReleaseParticleIndex(nPvpParticle)
                      end
                   })
                   -- 参与PVP的标志位
                   hHero.bJoiningPvp = true
                   EmitSoundOn("Hero_LegionCommander.Duel",hHero)
                   Timers:CreateTimer({ endTime = 1.5, 
                      callback = function()
                        StopSoundOn("Hero_LegionCommander.Duel",hHero)
                      end
                   })
                end
             end


             -- 如果参与单人PVP中
             for i,nPvpPlayerID in ipairs(PvpModule.currentSinglePair) do
                if nPvpPlayerID == nPlayerID then

                   -- 5v5中单人PVP 传送到中间
                   local nTeamNumber = PlayerResource:GetTeam(nPvpPlayerID)
                   local wayPoint = Entities:FindByName(nil, "center_single_pvp")
                  vCenter = wayPoint:GetOrigin() - Vector( (5-nTeamNumber*2)*550,0,0)

                   bPlayerPvpFlag= true      
                               
                   local nPvpParticle = ParticleManager:CreateParticle("particles/econ/items/legion/legion_weapon_voth_domosh/legion_duel_start_ring_arcana.vpcf", PATTACH_CUSTOMORIGIN, nil)
                   ParticleManager:SetParticleControl(nPvpParticle, 0, vCenter)  --ring position
                   ParticleManager:SetParticleControl(nPvpParticle, 7, vCenter)  --flag's position
                   Timers:CreateTimer({ endTime = 1, 
                      callback = function()
                          ParticleManager:DestroyParticle(nPvpParticle, false)
                          ParticleManager:ReleaseParticleIndex(nPvpParticle)
                      end
                   })
                   -- 参与PVP的标志位
                   hHero.bJoiningPvp = true
                   EmitSoundOn("Hero_LegionCommander.Duel",hHero)
                   Timers:CreateTimer({ endTime = 1.5, 
                      callback = function()
                        StopSoundOn("Hero_LegionCommander.Duel",hHero)
                      end
                   })
                end
             end
             
             --不参加PVP的玩家，显示PVP简报
             if hPlayer and (not bPlayerPvpFlag) and (not PvpModule.bEnd) then
                -- 参与PVP的标志位false
                hHero.bJoiningPvp = false
                
                local dataList={}
                local firstTeamId
                local secondTeamId

                --队伍决斗
                for nTempPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
                  if PlayerResource:IsValidPlayer(nTempPlayerID) and (PlayerResource:GetTeam( nTempPlayerID ) == PvpModule.currentPair[1] or PlayerResource:GetTeam( nTempPlayerID )==PvpModule.currentPair[2]) then
                     local data = {}
                     data.playerID = nTempPlayerID
                     data.teamID = PlayerResource:GetTeam( nTempPlayerID )
                     table.insert(dataList, data)
                     firstTeamId = PvpModule.currentPair[1]
                     secondTeamId = PvpModule.currentPair[2]
                  end
                end

                --单个玩家决斗
                for nTempPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
                  if PlayerResource:IsValidPlayer(nTempPlayerID) and (nTempPlayerID == PvpModule.currentSinglePair[1] or nTempPlayerID ==PvpModule.currentSinglePair[2]) then
                     local data = {}
                     data.playerID = nTempPlayerID
                     data.teamID = PlayerResource:GetTeam( nTempPlayerID )
                     table.insert(dataList, data)
                     firstTeamId = PlayerResource:GetTeam(PvpModule.currentSinglePair[1])
                     secondTeamId = PlayerResource:GetTeam(PvpModule.currentSinglePair[2])
                  end
                end

                CustomGameEventManager:Send_ServerToPlayer(hPlayer,"ShowPvpBrief", {players=dataList,firstTeamId=firstTeamId,secondTeamId=secondTeamId, betMap=PvpModule.betMap, bonusPool=math.floor(PvpModule.nBetBonus) })
              
             end

             --删除无敌
             hHero:RemoveModifierByName("modifier_hero_refreshing")
             Util:MoveHeroToLocation( nPlayerID,vCenter )

          end
          -- 不参与PVP的队伍开始刷怪
          if not bTeamPvpFlag then
            self.spanwers[nTeamNumber] = Spawner()
            self.spanwers[nTeamNumber]:Init(nTeamNumber,self)
            CustomNetTables:SetTableValue( "spawner_info",tostring(nTeamNumber),{})
          end
       end
       --给阵亡玩家 显示PVP简报
       if false==bAlive then

           local dataList={}
           for nTempPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
              if PlayerResource:IsValidPlayer(nTempPlayerID) and (PlayerResource:GetTeam( nTempPlayerID ) == PvpModule.currentPair[1] or PlayerResource:GetTeam( nTempPlayerID )==PvpModule.currentPair[2]) then
                 local data = {}
                 data.playerID = nTempPlayerID
                 data.teamID = PlayerResource:GetTeam( nTempPlayerID )
                 table.insert(dataList, data)
              end
           end
           for _,nPlayerID in ipairs(GameMode.vTeamPlayerMap[nTeamNumber]) do
             local hPlayer = PlayerResource:GetPlayer(nPlayerID)
             if hPlayer and PlayerResource:IsValidPlayer(nPlayerID) then
                CustomGameEventManager:Send_ServerToPlayer(hPlayer,"ShowPvpBrief", {players=dataList,firstTeamId=PvpModule.currentPair[1],secondTeamId=PvpModule.currentPair[2], betMap=PvpModule.betMap, bonusPool=math.floor(PvpModule.nBetBonus) })
             end
           end

       end
    end
    
    --RoundProgress 在 Spanwer 里面处理
    CustomGameEventManager:Send_ServerToAllClients("CreateQuest", { name = "RoundTimeLimit", text = "#round_time_limit", svalue = nRoundLimitTime, evalue = nRoundLimitTime, text_value=self.nRoundNumber })
    
    --回合定时器
    Timers:CreateTimer(1, function()
            
          if true == self.bEnd then
             return nil
          end 

          --debug top
          local bResult,nResult=xpcall(
            function()
          --debug top

           --检查是否有队伍失败
           for nTeamNumber,bAlive in pairs(GameMode.vAliveTeam) do
              if bAlive then
                  local bTeamAlive = false
                  for _,nPlayerID in ipairs(GameMode.vTeamPlayerMap[nTeamNumber]) do
                     --英雄存活，或者复活时间不超过限制
                     local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
                     --存活或者在复生
                     if hHero:IsAlive() or hHero:IsReincarnating() then
                         hHero.nDeathTime =0
                         bTeamAlive=true
                     else
                         if hHero.nDeathTime == nil then
                            hHero.nDeathTime =0 
                         end
                         hHero.nDeathTime = hHero.nDeathTime+1
                     end
                     --死亡确认7秒以上
                     if hHero.nDeathTime<=6 then
                        bTeamAlive=true
                     end
                  end
                  --失败逻辑（发弹幕）
                  if bTeamAlive==false then
                     GameMode:TeamLose(nTeamNumber)
                  end
              end
           end
           --检查是够击杀结束
           local bAllTeamFinish =  true
           --已经没有存活队伍了
           local bNoAliveTeam = true

           for nTeamNumber,bAlive in pairs(GameMode.vAliveTeam) do
              if bAlive then
                  bNoAliveTeam = false
                  --如果有任意队伍 PVE未结束
                  if self.spanwers[nTeamNumber] and self.spanwers[nTeamNumber].bProgressFinished==false then
                     bAllTeamFinish=false
                  end
                  -- 如果PVP未结束
                  if PvpModule.bEnd==false then
                     bAllTeamFinish=false
                  end
              end
           end
           
           --没有存活队伍了
           if GameMode.nValidTeamNumber >= 3 and bNoAliveTeam  and  (GameMode.bRetry==nil) then
              -- 有可能网络问题 导致第一次结算不成功  尝试再次结束游戏
              GameMode.bRetry = true
              if  DOTA_GAMERULES_STATE_GAME_IN_PROGRESS == GameRules:State_Get() then  
                  --再次尝试结束游戏
                  if GameMode.rankMap[1] then
                       Server:EndPvpGame(GameMode.rankMap[1])
                  else
                       Server:EndPvpGame(DOTA_TEAM_NEUTRALS)
                  end
              end
           end

           --所有队伍都结束
           if bAllTeamFinish then
             GameMode:FinishRound()
             CustomGameEventManager:Send_ServerToAllClients("RemoveQuest", {name = "RoundTimeLimit"})
             return nil
           end

          self.nTimeLimit = self.nTimeLimit - 1
          if self.nTimeLimit > 0 then
              CustomGameEventManager:Send_ServerToAllClients("RefreshQuest", { name = "RoundTimeLimit", text = "#round_time_limit", svalue =self.nTimeLimit, evalue = nRoundLimitTime,text_value=self.nRoundNumber })
          end

          -- 超时逻辑
          if self.nTimeLimit==0 then
              self:RoundTimeOver()
          end

          if self.nTimeLimit<0 then
              self:RoundTimeExceeded()
          end

          return 1

          --debug down

          end,
            function(e)
                print("-------------Error-------------")
                print(e)
                Server:UploadErrorLog(e)
          end)         
          --debug down

          --不出错使用正常 逻辑如果出错，1秒后再次计算
          if bResult then
             return nResult
          else
             return 1
          end

    end)
    
end



--关卡时间耗尽
function Round:RoundTimeOver()
   -- 生物加BUFF
   for nTeamNumber,bAlive in pairs(GameMode.vAliveTeam) do
       if bAlive==true then
          if  self.spanwers[nTeamNumber] and self.spanwers[nTeamNumber].bProgressFinished==false then
              for i, hCreep in ipairs( self.spanwers[nTeamNumber].vCurrentCreeps ) do
                  if hCreep and (not hCreep:IsNull()) and hCreep:IsAlive() then
                     hCreep:AddNewModifier(hCreep, nil, "modifier_creature_berserk", {})
                  end
              end            
          end
       end
   end
   CustomGameEventManager:Send_ServerToAllClients("RefreshQuest", { name = "RoundTimeLimit", text = "#round_time_expire", svalue = 0, evalue = nRoundLimitTime })
end


--关卡超时的每秒逻辑
function Round:RoundTimeExceeded()

   --通过比较血量 强制结束PVP
   if PvpModule.bEnd == false and PvpModule.currentPair[1] and PvpModule.currentPair[2]  then
      local nTeamID1 = PvpModule.currentPair[1]
      local nTeamID2 = PvpModule.currentPair[2]
      
      local flPercentage1 = 0
      local flTotalHeath1 = 0
      for i=1,PlayerResource:GetPlayerCountForTeam(nTeamID1) do
        local nPlayerID = PlayerResource:GetNthPlayerIDOnTeam(nTeamID1, i)
        local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
        if hHero then
          flPercentage1 =  flPercentage1 + hHero:GetHealthPercent()
          flTotalHeath1 =  flTotalHeath1 + hHero:GetHealth()
        end
      end

      local flPercentage2 = 0
      local flTotalHeath2 = 0
      for i=1,PlayerResource:GetPlayerCountForTeam(nTeamID2) do
        local nPlayerID = PlayerResource:GetNthPlayerIDOnTeam(nTeamID2, i)
        local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
        if hHero then
          flPercentage2 =  flPercentage2 + hHero:GetHealthPercent()
          flTotalHeath2 =  flTotalHeath2 + hHero:GetHealth()
        end
      end
    
      --按血量百分比比较， 同百分比比较绝对血量
      if flPercentage1==flPercentage2 then
         if flTotalHeath1>flTotalHeath2 then
            PvpModule:EndPvp(nTeamID1,nTeamID2)
         else
            PvpModule:EndPvp(nTeamID2,nTeamID1)
         end
      else
         if flPercentage1>flPercentage2 then
            PvpModule:EndPvp(nTeamID1,nTeamID2)
         else
            PvpModule:EndPvp(nTeamID2,nTeamID1)
         end
      end
   end


   --通过比较血量 强制结束单人决斗
   if PvpModule.bEnd == false and PvpModule.currentSinglePair[1] and PvpModule.currentSinglePair[2]  then
      local nPlayerID1 = PvpModule.currentSinglePair[1]
      local nPlayerID2 = PvpModule.currentSinglePair[2]
      
      local flPercentage1 = 0
      local flHeath1 = 0

      local hHero1 = PlayerResource:GetSelectedHeroEntity(nPlayerID1)
      if hHero1 then
          flPercentage1 =   hHero1:GetHealthPercent()
          flHeath1 =   hHero1:GetHealth()
      end


      local flPercentage2 = 0
      local flHeath2 = 0

      local hHero2 = PlayerResource:GetSelectedHeroEntity(nPlayerID2)
      if hHero2 then
          flPercentage2 =   hHero2:GetHealthPercent()
          flHeath2 =   hHero2:GetHealth()
      end

      --按血量百分比比较， 同百分比比较绝对血量
      if flPercentage1==flPercentage2 then
         if flHeath1>flHeath2 then
            PvpModule:EndSinglePvp(nPlayerID1,nPlayerID2)
         else
            PvpModule:EndSinglePvp(nPlayerID2,nPlayerID1)
         end
      else
         if flPercentage1>flPercentage2 then
            PvpModule:EndSinglePvp(nPlayerID1,nPlayerID2)
         else
            PvpModule:EndSinglePvp(nPlayerID2,nPlayerID1)
         end
      end
   end

end



--关卡结束
function Round:End()
  self.bEnd = true
  PvpModule.currentPair ={}
  PvpModule.currentSinglePair ={}
  if self.nRoundNumber and compensateRoundNumber[self.nRoundNumber] then
     Round:CompensateRelearnBook(self.nRoundNumber)
  end
  --击杀全地图猴子猴孙
  Util:CleanFurArmySoldier()
end


function Round:CompensateRelearnBook(nRoundNumber) 

    local dataList= {}
    for nTeamNumber,bAlive in pairs(GameMode.vAliveTeam) do
      if bAlive then
         for _,nPlayerID in ipairs(GameMode.vTeamPlayerMap[nTeamNumber]) do          
            --英雄存活，或者复活时间不超过限制
            local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
            --整理数据
            if hHero  and  PlayerResource:GetConnectionState(nPlayerID) ~= DOTA_CONNECTION_STATE_ABANDONED   then
                local data = {}
                local nGold =math.ceil(PlayerResource:GetGoldPerMin(nPlayerID) * (GameRules:GetGameTime() - GameRules.nGameStartTime)/60)+600-PvpModule.betValueSum[nPlayerID]
                data.nGold = nGold
                data.nPlayerID = nPlayerID
                table.insert(dataList, data)
            end
         end
      end
    end

    if #dataList>=2 then
      table.sort(dataList, function(a, b) return a.nGold < b.nGold end)
      if dataList[1] and dataList[1].nPlayerID then
         local hHero = PlayerResource:GetSelectedHeroEntity(dataList[1].nPlayerID)
         if hHero then
            hHero:AddItemByName("item_relearn_book_lua")
            local hTornPage = hHero:AddItemByName("item_relearn_torn_page_lua")
            --出售打折
            if hTornPage and hTornPage.SetPurchaseTime then
              hTornPage:SetPurchaseTime(0)
            end
            local vData={}
            vData.type = "compensate_relearn_book"
            vData.round_number = tostring(nRoundNumber)
            vData.playerId = dataList[1].nPlayerID
            vData.book_type = 3
            Barrage:FireBullet(vData)
         end
      end
      --三人及以上奖励倒数第二名
      if #dataList>2 and dataList[2] and dataList[2].nPlayerID then
         local hHero = PlayerResource:GetSelectedHeroEntity(dataList[2].nPlayerID)
         if hHero then
            hHero:AddItemByName("item_relearn_book_lua")
            local vData={}
            vData.type = "compensate_relearn_book"
            vData.round_number = tostring(nRoundNumber)
            vData.playerId = dataList[2].nPlayerID
            vData.book_type = 2
            Barrage:FireBullet(vData)
         end
      end
      --四人及以上奖励倒数第三名
      if #dataList>3 and dataList[3] and dataList[3].nPlayerID then
         local hHero = PlayerResource:GetSelectedHeroEntity(dataList[3].nPlayerID)
         if hHero then
            local hTornPage = hHero:AddItemByName("item_relearn_torn_page_lua")
            --出售打折
            if hTornPage and hTornPage.SetPurchaseTime then
              hTornPage:SetPurchaseTime(0)
            end
            local vData={}
            vData.type = "compensate_relearn_book"
            vData.round_number = tostring(nRoundNumber)
            vData.playerId = dataList[3].nPlayerID
            vData.book_type = 1
            Barrage:FireBullet(vData)
         end
      end
    end

end



function Round:PlayerReady(keys)

   local nPlayerID = keys.PlayerID
   if not nPlayerID then 
     return 
   end
   local hPlayer = PlayerResource:GetPlayer(nPlayerID)

   if hPlayer then

     self.readyPlayers[nPlayerID] = true
     CustomGameEventManager:Send_ServerToAllClients("UpdatePlayerReadyList", { readyPlayers = self.readyPlayers })
     CustomGameEventManager:Send_ServerToPlayer(hPlayer, "UpdateReadyButton", { visible = false })

   end

end