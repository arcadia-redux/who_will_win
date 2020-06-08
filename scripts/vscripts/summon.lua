if Summon == nil then Summon = class({}) end
LinkLuaModifier( "modifier_clinkz_skeletons", "heroes/hero_clinkz/modifier_clinkz_skeletons", LUA_MODIFIER_MOTION_NONE )


function Summon:Init()
  ListenToGameEvent("npc_spawned", Dynamic_Wrap(Summon, "OnNPCSpawned"), self)
  
  Summon.efficiency = {}
  Summon.efficiency["npc_dota_lone_druid_bear1"] = 1.0
  Summon.efficiency["npc_dota_lone_druid_bear2"] = 1.0
  Summon.efficiency["npc_dota_lone_druid_bear3"] = 1.0
  Summon.efficiency["npc_dota_lone_druid_bear4"] = 1.0
  Summon.efficiency["npc_dota_venomancer_plague_ward_1"] = 1.0
  Summon.efficiency["npc_dota_venomancer_plague_ward_2"] = 1.0
  Summon.efficiency["npc_dota_venomancer_plague_ward_3"] = 1.0
  Summon.efficiency["npc_dota_venomancer_plague_ward_4"] = 1.0
  Summon.efficiency["npc_dota_shadow_shaman_ward_1"] = 1.0
  Summon.efficiency["npc_dota_shadow_shaman_ward_2"] = 1.0
  Summon.efficiency["npc_dota_shadow_shaman_ward_3"] = 1.0
  Summon.efficiency["npc_dota_brewmaster_storm_1"] = 1.0
  Summon.efficiency["npc_dota_brewmaster_storm_2"] = 1.0
  Summon.efficiency["npc_dota_brewmaster_storm_3"] = 1.0
  Summon.efficiency["npc_dota_brewmaster_fire_1"] = 1.0
  Summon.efficiency["npc_dota_brewmaster_fire_2"] = 1.0
  Summon.efficiency["npc_dota_brewmaster_fire_3"] = 1.0
  Summon.efficiency["npc_dota_brewmaster_earth_1"] = 1.0
  Summon.efficiency["npc_dota_brewmaster_earth_2"] = 1.0
  Summon.efficiency["npc_dota_brewmaster_earth_3"] = 1.0
  Summon.efficiency["npc_dota_witch_doctor_death_ward"] = 0.7
  Summon.efficiency["npc_dota_shadow_shaman_ward_1"] = 0.35
  Summon.efficiency["npc_dota_shadow_shaman_ward_2"] = 0.35
  Summon.efficiency["npc_dota_shadow_shaman_ward_3"] = 0.35
  
  Summon.efficiency["npc_dota_warlock_golem_1"] = 0.3
  Summon.efficiency["npc_dota_warlock_golem_2"] = 0.3
  Summon.efficiency["npc_dota_warlock_golem_3"] = 0.3
  Summon.efficiency["npc_dota_warlock_golem_scepter_1"] = 0.3
  Summon.efficiency["npc_dota_warlock_golem_scepter_2"] = 0.3
  Summon.efficiency["npc_dota_warlock_golem_scepter_3"] = 0.3

  Summon.efficiency["npc_dota_clinkz_skeleton_archer"] = 0.5
end


--调整召唤物属性
function Summon:OnNPCSpawned(event)

    local hSpawnedUnit = EntIndexToHScript(event.entindex)
    if not hSpawnedUnit:IsNull() and hSpawnedUnit.GetUnitName and  hSpawnedUnit:GetUnitName() and not hSpawnedUnit:IsIllusion() and not hSpawnedUnit:IsTempestDouble() then
        if hSpawnedUnit:IsSummoned() or Summon.efficiency[hSpawnedUnit:GetUnitName()] then
           
           --延迟若干时间，调整召唤生物属性
           local flWaitTime = 0
           -- 燃烧之军可以攻击野怪
           if "npc_dota_clinkz_skeleton_archer" == hSpawnedUnit:GetUnitName() then
               hSpawnedUnit:AddNewModifier(hSpawnedUnit, nil, "modifier_clinkz_skeletons", {})
               flWaitTime=0.1  
           end

           Timers:CreateTimer(flWaitTime, function()
               local hOwner = hSpawnedUnit:GetOwner()

               if hOwner and hOwner:IsRealHero() and hOwner:HasModifier("modifier_item_summoner_crown") then
                  local flEfficiency = Summon.efficiency[hSpawnedUnit:GetUnitName()] or 1.0
                  local hSourceItem = hOwner:FindItemInInventory("item_summoner_crown_3") or hOwner:FindItemInInventory("item_summoner_crown_2") or hOwner:FindItemInInventory("item_summoner_crown_1")

                  hSpawnedUnit:AddNewModifier(hOwner, hSourceItem, "modifier_item_summoner_crown_buff_agi", {}):SetStackCount(hOwner:GetAgility() * flEfficiency)
                  hSpawnedUnit:AddNewModifier(hOwner, hSourceItem, "modifier_item_summoner_crown_buff_int", {}):SetStackCount(hOwner:GetIntellect() * flEfficiency)
                  hSpawnedUnit:AddNewModifier(hOwner, hSourceItem, "modifier_item_summoner_crown_model_size", {})
                    
                  Timers:CreateTimer(FrameTime(), function()
                      --获得单位当前血量
                      local nCurrentHealth = hSpawnedUnit:GetMaxHealth()
                      if hSpawnedUnit:GetName() == "npc_dota_lone_druid_bear" then
                        nCurrentHealth = 2000 + 75 * hSpawnedUnit:GetLevel()
                      end
                      local nNewHealth = math.floor(nCurrentHealth * (1 + 0.01 * hOwner:GetStrength() * flEfficiency * hSourceItem:GetSpecialValueFor("hp_bonus_per_str") ))
                      hSpawnedUnit:SetBaseMaxHealth(nNewHealth)
                      hSpawnedUnit:SetMaxHealth(nNewHealth)
                      hSpawnedUnit:SetHealth(nNewHealth)
                  end)
               end
           end)
        end
    end

end








--杀死PVP 区域内的召唤生物
function Summon:KillSummonedCreatureAsyn(vLocation)
    
    if vLocation then
      local vCleanLocation = Vector(vLocation.x,vLocation.y,vLocation.z)
      Timers:CreateTimer({ endTime = 5,
        callback = function()
           local summonedCreature = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, vCleanLocation, nil, 2500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_CLOSEST, false)
           for _,hUnit in ipairs(summonedCreature) do
             if hUnit and not hUnit:IsNull() and hUnit.GetUnitName and hUnit:GetUnitName() and (hUnit:IsSummoned() or Summon.efficiency[hUnit:GetUnitName()]) and not hUnit:IsIllusion() and not hUnit:IsTempestDouble() then
               if hUnit:IsAlive() then
                  hUnit:ForceKill(false)
               end
             end
           end
       end})
    end
end

