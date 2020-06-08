
if Util == nil then Util = class({}) end

LinkLuaModifier( "modifier_hero_refreshing", "heroes/modifier_hero_refreshing", LUA_MODIFIER_MOTION_NONE )

--将英雄 移动到地图中间的方块
function Util:MoveHeroToCenter( nPlayerID )

   local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
   if  hHero then
       --清理一下妨碍传送的Modifier
       --ListModifiers(hHero)
       Util:RemoveMovemenModifier(hHero)

       local nTeamNumber =  hHero:GetTeamNumber()
       local vTargetLocation = GameMode.vTeamStartLocationMap[nTeamNumber]

       ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, hHero)
       
       FindClearSpaceForUnit(hHero, vTargetLocation, false)
       
       --循环移动大法
       Timers:CreateTimer({ endTime = 0.1, 
          callback = function()
              local flDistance = (hHero:GetOrigin() - vTargetLocation):Length()
              if flDistance<1500 then
                  return nil
              else
                  FindClearSpaceForUnit(hHero, vTargetLocation, false)
                  return 0.1
              end
          end
       })


       ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, hHero)
       hHero:EmitSound("DOTA_Item.BlinkDagger.Activate")
       
       local hTargetHero = Util:ChooseObservingTarget(nPlayerID)

       PlayerResource:SetCameraTarget(nPlayerID,hTargetHero)
       Timers:CreateTimer({ endTime = 0.3, 
          callback = function()
            PlayerResource:SetCameraTarget(nPlayerID,nil) 
          end
       })

   end

end

function Util:ChooseObservingTarget(nPlayerID)

   -- 如果5v5并且 单人PVP未结束
   if GetMapName()=="5v5" and GameMode.autoDuelMap[nPlayerID] and (not PvpModule.bEnd) then
      for _,nPvpPlayerID in ipairs(PvpModule.currentSinglePair) do
         --观战本队玩家
         if PlayerResource:GetTeam(nPvpPlayerID) == PlayerResource:GetTeam(nPlayerID) then
            local hTempTargetHero =  PlayerResource:GetSelectedHeroEntity(nPvpPlayerID)
            if hTempTargetHero and (hTempTargetHero:IsAlive() or hTempTargetHero:IsReincarnating()) then
               return hTempTargetHero
            end
         end
      end
   end


   --观战PVP区域
   if PvpModule.nHomeTeamID and GameMode.autoDuelMap[nPlayerID] and (not PvpModule.bEnd)  then          
      for i=1,PlayerResource:GetPlayerCountForTeam(PvpModule.nHomeTeamID) do
         local nTempPlayerID = PlayerResource:GetNthPlayerIDOnTeam(PvpModule.nHomeTeamID, i)
         local hTempTargetHero =  PlayerResource:GetSelectedHeroEntity(nTempPlayerID)
         if hTempTargetHero and (hTempTargetHero:IsAlive() or hTempTargetHero:IsReincarnating()) then
             return hTempTargetHero
         end
      end
   end
   
   --观看PVE区域
   if GameMode.autoCreepMap[nPlayerID] and GameMode.currentRound and (not GameMode.currentRound.bEnd)  then
     
      local nKillProgress = 100
      local nTargetTeamNumber
      
      --挑选一个进度最慢的队伍
      for nTeamNumber,bAlive in pairs(GameMode.vAliveTeam) do
          if bAlive  and GameMode.currentRound.spanwers[nTeamNumber] and false == GameMode.currentRound.spanwers[nTeamNumber].bProgressFinished then          
             if nKillProgress > GameMode.currentRound.spanwers[nTeamNumber].nKillProgress then
                nTargetTeamNumber = nTeamNumber
             end 
          end
       end
       if nTargetTeamNumber then
          for i=1,PlayerResource:GetPlayerCountForTeam(nTargetTeamNumber) do
              local nPlayerID = PlayerResource:GetNthPlayerIDOnTeam(nTargetTeamNumber, i)
              local hTempTargetHero =  PlayerResource:GetSelectedHeroEntity(nPlayerID)
              if hTempTargetHero and (hTempTargetHero:IsAlive() or hTempTargetHero:IsReincarnating()) then
                 return hTempTargetHero
              end
          end
       end
       
   end

   -- 没得可看就看自己
   return PlayerResource:GetSelectedHeroEntity(nPlayerID)

end


--将英雄 移动到指定地点
function Util:MoveHeroToLocation( nPlayerID,vLocation )

   local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
   if  hHero then 

     local vTargetLocation = vLocation

     --清理一下妨碍传送的Modifier
     --ListModifiers(hHero)
     Util:RemoveMovemenModifier(hHero)
      
     ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, hHero)    
     FindClearSpaceForUnit(hHero, vTargetLocation, false)

      --循环移动大法
      Timers:CreateTimer({ endTime = 0.1, 
        callback = function()
            local flDistance = (hHero:GetOrigin() - vTargetLocation):Length()
            if flDistance<1500 then
                return nil
            else
                FindClearSpaceForUnit(hHero, vTargetLocation, false)
                return 0.1
            end
        end
      })

      ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, hHero)
      hHero:EmitSound("DOTA_Item.BlinkDagger.Activate") 
      --定位镜头给英雄
      PlayerResource:SetCameraTarget(nPlayerID,hHero)
      Timers:CreateTimer({ endTime = 0.3, 
        callback = function()
          PlayerResource:SetCameraTarget(nPlayerID,nil) 
        end
      })
   end

end






--刷新技能与物品
function Util:RefreshAbilityAndItem( hHero,exceptions)
    
    if exceptions==nil then
       exceptions={}
    end

    for i = 0, hHero:GetAbilityCount() - 1 do
        local hAbility = hHero:GetAbilityByIndex(i)
        if hAbility and hAbility:GetAbilityType() ~= DOTA_ABILITY_TYPE_ATTRIBUTES then
            if exceptions[hAbility:GetAbilityName()]==nil then
              hAbility:RefreshCharges()
              hAbility:EndCooldown()
            end
        end
    end

    for i = 0, 9 do
        local hItem = hHero:GetItemInSlot(i)
        if hItem then
            if hItem:GetPurchaser() == hHero  then
                hItem:EndCooldown()
            end
        end
    end
end


-- 清理数据
function Util:CleanPvpPair(nTeamNumber)
    local i,max=1,#PvpModule.pvpPairs
    while i<=max do
        local pair = PvpModule.pvpPairs[i]
        if  nTeamNumber==pair.nFirstTeamId or nTeamNumber==pair.nSecondeTeamId  then
            table.remove(PvpModule.pvpPairs,i)
            i = i-1
            max = max-1
        end
        i= i+1
    end
    return PvpModule.pvpPairs
end


-- 清理影响传送的Modifier
function Util:RemoveMovemenModifier(hHero)
    
    --爆破起飞
    hHero:Stop()
    hHero:RemoveModifierByName("modifier_magnataur_skewer_movement")
    hHero:RemoveModifierByName("modifier_phoenix_icarus_dive")
    hHero:RemoveModifierByName("modifier_mirana_leap")
    hHero:RemoveModifierByName("modifier_kunkka_x_marks_the_spot")
    hHero:RemoveModifierByName("modifier_kunkka_x_marks_the_spot_thinker")
    hHero:RemoveModifierByName("modifier_riki_tricks_of_the_trade_phase")
    hHero:RemoveModifierByName("modifier_monkey_king_bounce_perch")
    hHero:RemoveModifierByName("modifier_void_spirit_dissimilate_phase")
    hHero:RemoveModifierByName("modifier_monkey_king_bounce_leap")
    hHero:RemoveModifierByName("modifier_monkey_king_tree_dance_activity")
    hHero:RemoveModifierByName("modifier_sandking_burrowstrike")
    hHero:RemoveModifierByName("modifier_phantomlancer_dopplewalk_phase")

    --虚妄之诺 回泉水不回血的问题
    if hHero:HasModifier("modifier_oracle_false_promise") then
       --略微延迟一下再移除，防止飞尸
       Timers:CreateTimer(1,
        function()
            hHero:RemoveModifierByName("modifier_oracle_false_promise")
        end
       )
    end

    hHero:RemoveModifierByName("modifier_brewmaster_primal_split")
    hHero:RemoveModifierByName("modifier_invoker_tornado_lua")


    if hHero:HasAbility("puck_ethereal_jaunt") then
       hHero:FindAbilityByName("puck_ethereal_jaunt"):SetActivated(false)
        --三秒后放开
       Timers:CreateTimer({ endTime = 3, 
            callback = function()
               if  hHero:HasAbility("puck_ethereal_jaunt") then
                   hHero:FindAbilityByName("puck_ethereal_jaunt"):SetActivated(true)
               end
            end
       })
    end

    if hHero:HasModifier("modifier_ember_spirit_fire_remnant_remnant_tracker") then
        hHero:RemoveModifierByName("modifier_ember_spirit_fire_remnant_timer")
        hHero:RemoveModifierByName("modifier_ember_spirit_fire_remnant_remnant_tracker")
        hHero:AddNewModifier(hHero, hHero:FindAbilityByName("ember_spirit_fire_remnant"), "modifier_ember_spirit_fire_remnant_remnant_tracker", {})
    end

    if hHero:HasModifier("modifier_weaver_timelapse") then
        hHero:RemoveModifierByName("modifier_weaver_timelapse")
        hHero:AddNewModifier(hHero, hHero:FindAbilityByName("weaver_time_lapse"), "modifier_weaver_timelapse", {})
    end

end

function Util:RemoveAbilityClean(hHero,sAbilityName)
    

    if sAbilityName=="broodmother_spin_web" then
        Util:CleanWeb(hHero)
    end

    if sAbilityName=="witch_doctor_death_ward" then
        Util:CleanDeathWard(hHero)
    end

    if sAbilityName=="visage_summon_familiars" then
        Util:CleanFamiliar(hHero)
    end
  
end




--清理蜘蛛网
function Util:CleanWeb(hHero)
    -- 清理蜘蛛网
    local vWebs = Entities:FindAllByName("npc_dota_broodmother_web")
    for _, hWeb in pairs(vWebs) do
      if hWeb:GetOwner() == hHero then
        UTIL_Remove(hWeb)
      end
    end
end


--清理死亡守卫
function Util:CleanDeathWard(hHero)
    local vWards = Entities:FindAllByName("npc_dota_witch_doctor_death_ward")
    for _, vWard in pairs(vWards) do
      if vWard:GetOwner() == hHero then
        UTIL_Remove(vWard)
      end
    end
end

--清理佣兽
function Util:CleanFamiliar(hHero)
    local vFamiliars = Entities:FindAllByName("npc_dota_visage_familiar")
    for _, hFamiliar in pairs(vFamiliars) do
      if hFamiliar:GetOwner() == hHero then
        hFamiliar:ForceKill(false)
      end
    end
end


--判断是否触发重生
function Util:IsReincarnationWork(hHero)

    local bSkeletonKingReincarnationWork = false
    if hHero:HasAbility("skeleton_king_reincarnation") then
         local hAbility = hHero:FindAbilityByName("skeleton_king_reincarnation")
         if hAbility:GetLevel() > 0 then
           --刚刚触发
           if hAbility:GetCooldownTimeRemaining() == hAbility:GetEffectiveCooldown(hAbility:GetLevel()-1) then
              bSkeletonKingReincarnationWork = true 
           end
       end
    end
      
    local bUndyingReincarnationWork = false
    if hHero:HasModifier("modifier_special_bonus_reincarnation") then
        local hModifier = hHero:FindModifierByName("modifier_special_bonus_reincarnation")
        if hModifier:GetElapsedTime()<FrameTime() then
              bUndyingReincarnationWork=true
        end
    end

    return bSkeletonKingReincarnationWork or bUndyingReincarnationWork

end

--统计英雄数据

function Util:GenerateHeroInfo(nPlayerID)
   
   local heroInfo ={}
   local hHero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
   
   if hHero then

     local sAbilities = ""
     if hHero.abilitiesList then
       for _,sAbilityName in ipairs(hHero.abilitiesList) do
         sAbilities = sAbilities .. sAbilityName ..","
       end
     end

     if string.sub(sAbilities,string.len(sAbilities))=="," then   --去掉最后一个逗号
         sAbilities=string.sub(sAbilities,0,string.len(sAbilities)-1)
     end

     local sItems = ""
     for i=0,20 do --遍历物品
       local hItem = hHero:GetItemInSlot(i)
       if hItem then
        sItems = sItems..hItem:GetName()..","
       end
     end

     if string.sub(sItems,string.len(sItems))=="," then   --去掉最后一个逗号
         sItems=string.sub(sItems,0,string.len(sItems)-1)
     end

     heroInfo.hero_name=hHero:GetUnitName()
     heroInfo.abilities=sAbilities
     heroInfo.items=sItems

   end


   return heroInfo

end


function CDOTA_BaseNPC:AddEndChannelListener(listener)
  local endChannelListeners = self.EndChannelListeners or {}
  self.EndChannelListeners = endChannelListeners
  local index = #endChannelListeners + 1
  endChannelListeners[index] = listener
end

--杀死全地图的猴子猴孙
function Util:CleanFurArmySoldier()

    Timers:CreateTimer({ endTime = 2,
      callback = function()
         local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, Vector(0,0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_CLOSEST, false)
         for _,hUnit in ipairs(units) do
           if hUnit and not hUnit:IsNull() and hUnit:HasModifier("modifier_monkey_king_fur_army_soldier") then
              hUnit:ForceKill(false)
              UTIL_Remove(hUnit)
           end
         end
     end})

end