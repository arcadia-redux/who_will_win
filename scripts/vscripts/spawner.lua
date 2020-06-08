if Spawner == nil then Spawner = class({}) end
LinkLuaModifier( "modifier_creature_true_sight", "creature_ability/modifier_creature_true_sight", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creature_spell_amplify", "creature_ability/modifier_creature_spell_amplify", LUA_MODIFIER_MOTION_NONE )


function Spawner:Init(nTeamNumber,round)
      
    self.round=round
    self.nTeamNumber =nTeamNumber
    self.vCurrentCreeps={}
    self.nEntityKilledEvent = ListenToGameEvent( "entity_killed", Dynamic_Wrap( Spawner, 'OnEntityKilled' ), self )
    self.nKillProgress = 0
    self.bProgressFinished = false
    --强制停止刷怪的标识符
    self.bForceStop = false

    CustomGameEventManager:Send_ServerToTeam(nTeamNumber,"CreateQuest", { name = "RoundProgress", text = "#round_progress", svalue = 0, evalue = self.round.nCreatureNumber })
    
    
    --从第15关开始，每15关为一个怪物添加反隐
    local nTotalTrueSightNumber = math.floor(round.nRoundNumber/15)
    
    self.nLootLevel = math.ceil(round.nRoundNumber/10)

    --初始化掉落数量
    if self.nLootLevel<=5 and ItemLoot.lootNumber[self.nLootLevel][nTeamNumber]==nil then
        ItemLoot.lootNumber[self.nLootLevel][nTeamNumber] = 0
        ItemLoot.lootChance[self.nLootLevel][nTeamNumber] = 0
    end

    local nTrueSightNumber = 0

    --启动定时器刷怪
    for k,vData in pairs(GameMode.vRoundData[round.sRoundName]) do
       local sUnitName = vData.UnitName
       local nUnitNumber = tonumber(vData.UnitNumber)
       local flSpawnInterval = tonumber(vData.SpawnInterval)
      
       --多人模式上调怪物刷新速度
       if GetMapName()=="2x6" then
          flSpawnInterval = flSpawnInterval/1.2
       end

       if GetMapName()=="5v5" then
          flSpawnInterval = flSpawnInterval/3
       end

       local nTrueSight

       local nCurrentNumber = 0
       Timers:CreateTimer(function()

         nCurrentNumber = nCurrentNumber+1

         local nRandomRange = RandomInt(450, 550)
         

         -- 大地图上调刷新范围
         if GetMapName()=="2x6" then
            nRandomRange = RandomInt(400, 600)
         end

         if GetMapName()=="5v5" then
            nRandomRange = RandomInt(700, 1300)
         end

         local vRandomPos=GameMode.vTeamLocationMap[nTeamNumber]+RandomVector(nRandomRange)

         local hUnit = CreateUnitByName(sUnitName, vRandomPos, true, nil, nil, DOTA_TEAM_NEUTRALS)
         self:CreaturePowerUp(hUnit,round.nRoundNumber-1)

         if nTrueSightNumber< nTotalTrueSightNumber then
             self:AddTrueSightForUnit(hUnit)
             nTrueSightNumber = nTrueSightNumber+1
         end

         --记录下是几号刷怪点刷的它
         hUnit.nSpawnerTeamNumber = nTeamNumber
         --添加到追踪表
         table.insert(self.vCurrentCreeps, hUnit)

         if (nCurrentNumber==nUnitNumber) or (self.bForceStop)  then
            return nil
         else
            return flSpawnInterval
         end
       end)
    end
end


--击杀监听
function Spawner:OnEntityKilled(keys)
    local hKilledUnit = EntIndexToHScript( keys.entindex_killed )
    if not hKilledUnit:IsHero() then
       --被击杀怪物是从本刷怪点刷的
       if hKilledUnit.nSpawnerTeamNumber == self.nTeamNumber then

         --60轮以上不再掉落
         if (self.nLootLevel<=5) and (ItemLoot.lootNumber[self.nLootLevel][self.nTeamNumber]<ItemLoot.lootPerLevel) then
            --先调高概率                                                                                                   
            ItemLoot.lootChance[self.nLootLevel][self.nTeamNumber] = ItemLoot.lootChance[self.nLootLevel][self.nTeamNumber]+ItemLoot.flChanceStack
            local flRandom = RandomFloat(0, 1)

            if flRandom<ItemLoot.lootChance[self.nLootLevel][self.nTeamNumber] then
               ItemLoot:DropItem(hKilledUnit,self.nLootLevel,self.nTeamNumber)
            end
         end

         --将从生物从列表移除
         for i, hCreep in ipairs( self.vCurrentCreeps ) do
            if hKilledUnit == hCreep then
              table.remove( self.vCurrentCreeps, i )
              --刷新本队击杀进度
              self.nKillProgress = self.nKillProgress +1 
              CustomGameEventManager:Send_ServerToTeam(self.nTeamNumber, "RefreshQuest", { name = "RoundProgress", text = "#round_progress", svalue =self.nKillProgress, evalue = self.round.nCreatureNumber })
              -- 如果击杀进度已满
              if self.nKillProgress == self.round.nCreatureNumber then
                  self:Finish()
              end
            end
         end 
       end
    end
end



--回合结束，给予奖励，玩家移动到中间
function Spawner:Finish()
   
   --队伍排个名(从0开始)
   self.round.nPlayerRank = self.round.nPlayerRank + 1


   self.bProgressFinished = true
   StopListeningToGameEvent( self.nEntityKilledEvent )

   --计算赏金

   local flReducePerRank = 0
   if  self.round.nAliveTeamNumber >= 1 then
     flReducePerRank = 1 / self.round.nAliveTeamNumber
   end
   
   if GetMapName()=="5v5" then
      flReducePerRank = 0.2
   end

   local nBonusGold = math.ceil(self.round.flBonus * (1-(self.round.nPlayerRank-1) *flReducePerRank))
   
   --统计离线玩家金币总和 平分给在线玩家
   local nAbandonedTotalBonus = 0
   local nConnectedPlayerCount = 0
   local nAbandonedLegacy = 0
   
   for _,nPlayerID in ipairs(GameMode.vTeamPlayerMap[self.nTeamNumber]) do
      if PlayerResource:GetConnectionState(nPlayerID) == DOTA_CONNECTION_STATE_ABANDONED then
        nAbandonedTotalBonus = nAbandonedTotalBonus + nBonusGold
      else
        nConnectedPlayerCount = nConnectedPlayerCount + 1
      end
   end
   
   --将掉线玩家的金币分给在线玩家
   if nConnectedPlayerCount>0 and nAbandonedTotalBonus>0 then
      nAbandonedLegacy =  math.floor(nAbandonedTotalBonus/nConnectedPlayerCount)
   end

   for _,nPlayerID in ipairs(GameMode.vTeamPlayerMap[self.nTeamNumber]) do

       local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)  
       
       --断线玩家不发奖励
       if PlayerResource:GetConnectionState(nPlayerID) ~= DOTA_CONNECTION_STATE_ABANDONED then
           --弹幕数据
           local vBulletData = {}
           vBulletData.type = "round_finish"
           vBulletData.gold_value =tostring(nBonusGold+nAbandonedLegacy)
           vBulletData.playerId = nPlayerID
           Barrage:FireBullet(vBulletData)

           --奖励金币
           SendOverheadEventMessage(hHero, OVERHEAD_ALERT_GOLD, hHero, nBonusGold+nAbandonedLegacy, nil)
           PlayerResource:ModifyGold(nPlayerID,nBonusGold+nAbandonedLegacy, true, DOTA_ModifyGold_GameTick)
       end

       --5V5中参与PVP的英雄 暂留在角斗场中 
       if not (GetMapName()=="5v5" and hHero.bJoiningPvp) then         
            --如果跟怪同归于尽 先复活起来
           if not hHero:IsAlive() then
              hHero:RespawnHero(false, false)
           end

           --移动英雄 并且添加BUFF
           Timers:CreateTimer({ endTime = 0.5, 
              callback = function()
                Util:MoveHeroToCenter(nPlayerID)
                hHero:AddNewModifier(hHero, nil, "modifier_hero_refreshing", {})
              end
           })
       end

   end

   --移除队伍的击杀进度条
   CustomGameEventManager:Send_ServerToTeam(self.nTeamNumber, "RemoveQuest", {name = "RoundProgress"})
  
end





--提高生物强度
function Spawner:CreaturePowerUp(hUnit,nlevel)
     
     local flMultiple= 1

     if nlevel<=10 then
        flMultiple= math.pow(1.196, nlevel)
     elseif nlevel>10 and nlevel<=20 then
        flMultiple= math.pow(1.196, 10) * math.pow(1.145, nlevel-10)
     elseif nlevel>20 and nlevel<=30 then
        flMultiple= math.pow(1.196, 10) *math.pow(1.145, 10)*math.pow(1.125, nlevel-20)
     elseif nlevel>30 then
        flMultiple= math.pow(1.196, 10) *math.pow(1.145, 10)*math.pow(1.125, 10)*math.pow(1.12, nlevel-30)
     end
     

     local flMaxHealth = hUnit:GetMaxHealth()*flMultiple
     
     --最大怪物血量18个亿，后续不再提高了
     if flMaxHealth>1800000000 then
         flMaxHealth = 1800000000
     end

     hUnit:SetAcquisitionRange(1500)
     hUnit:SetBaseMaxHealth(flMaxHealth)
     hUnit:SetMaxHealth(flMaxHealth)
     hUnit:SetHealth(flMaxHealth)

     local flGoldBountyMultiple = 0.5
     hUnit:SetMinimumGoldBounty(math.floor(hUnit:GetMinimumGoldBounty()* flGoldBountyMultiple ))
     hUnit:SetMaximumGoldBounty(math.floor(hUnit:GetMaximumGoldBounty()* flGoldBountyMultiple ))

     local flDamageMultiple=1
     
     if nlevel<=10 then
        flDamageMultiple= math.pow(1.165, nlevel)
     elseif nlevel>10 and nlevel<=20 then
        flDamageMultiple= math.pow(1.165, 10) * math.pow(1.124, nlevel-10)
     elseif nlevel>20 and nlevel<=30 then
        flDamageMultiple= math.pow(1.165, 10) *math.pow(1.124, 10)*math.pow(1.113, nlevel-20)
     elseif nlevel>30 then
        flDamageMultiple= math.pow(1.165, 10) *math.pow(1.124, 10)*math.pow(1.113, 10)*math.pow(1.11, nlevel-30)
     end

     local flDamageMin = hUnit:GetBaseDamageMin()*flDamageMultiple
     if flDamageMin>1800000000 then
         flDamageMin = 1800000000
     end
     hUnit:SetBaseDamageMin(flDamageMin)

     local flDamageMax = hUnit:GetBaseDamageMax()*flDamageMultiple
     if flDamageMax>1800000000 then
         flDamageMax = 1800000000
     end
     hUnit:SetBaseDamageMax(flDamageMax)

     --调整击杀经验
     if self.round and self.round.nCreatureNumber then
       hUnit:SetDeathXP( math.floor( (GameRules.xpTable[nlevel+1] -GameRules.xpTable[nlevel]) / self.round.nCreatureNumber * self.round.flExpMulti ))
     end

     -- 攻速提高
     local flSpeedMultiple = math.pow(1.05, nlevel)
     hUnit:SetBaseAttackTime(hUnit:GetBaseAttackTime()/flSpeedMultiple)
     
     --开始提高魔抗，每轮提高1%
     if nlevel>80 then
        hUnit:SetBaseMagicalResistanceValue(hUnit:GetBaseMagicalResistanceValue()+(nlevel-80)*1)
     end
     -- 开始撕裂护甲
     if nlevel>100 then
        local hAbility = hUnit:AddAbility("creature_tear_armor")
        local nAbilityLevel = math.floor(nlevel/100)
        if nAbilityLevel>10 then
           nAbilityLevel = 10
        end
        hAbility:SetLevel(nAbilityLevel)
     end
     --调整护甲
     if nlevel>60 then
        hUnit:SetPhysicalArmorBaseValue(hUnit:GetPhysicalArmorBaseValue()+math.floor((nlevel-60)*0.5))
     end

     --调高魔法伤害
     if nlevel>1 then
       local hMagicModifier = hUnit:AddNewModifier(hUnit, nil, "modifier_creature_spell_amplify", {})
       hMagicModifier:SetStackCount(nlevel)
     end

end


--为生物添加反隐
function Spawner:AddTrueSightForUnit(hUnit)
    
     hUnit:AddNewModifier(hUnit, nil, "modifier_creature_true_sight", {})

end
