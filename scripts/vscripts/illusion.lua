--幻象修复器

if Illusion == nil then Illusion = class({}) end

function Illusion:Init()
  ListenToGameEvent("npc_spawned", Dynamic_Wrap(Illusion, "OnNPCSpawned"), self)
  Illusion.abilityException = {}
  Illusion.abilityException["arc_warden_tempest_double"] = true
  Illusion.abilityException["meepo_divided_we_stand"] = true
  Illusion.abilityException["morphling_replicate"] = true
  Illusion.abilityException["morphling_morph_replicate"] = true
  Illusion.abilityException["naga_siren_mirror_image"] = true
  Illusion.abilityException["monkey_king_wukongs_command"] = true
  
  --部分大型特效 幻象不继承
  Illusion.particleException = {}
  Illusion.particleException["league_dog_ring"] = true
  Illusion.particleException["galaxy_core"] = true
  Illusion.particleException["blood_dance"] = true
  Illusion.particleException["legion_wings"] = true
  Illusion.particleException["legion_wings_vip"] = true
  Illusion.particleException["legion_wings_pink"] = true

  --并列不能继承的技能
  Illusion.juxtaposeException = {}
  Illusion.juxtaposeException["drow_ranger_marksmanship"] = true
  Illusion.juxtaposeException["medusa_split_shot"] = true
end


function Illusion:InitIllusion(hIllusion)

  if not hIllusion or hIllusion:IsNull() then return end
  local hIllustionModifier = hIllusion:FindModifierByName("modifier_illusion") or hIllusion:FindModifierByName("modifier_arc_warden_tempest_double")
  if not hIllustionModifier then return end

  local hOriginalHero = hIllustionModifier:GetCaster()
  
  if not hOriginalHero then return end
    
   --先移除技能
  for i=0, 24 do
     local hAbility = hIllusion:GetAbilityByIndex(i)
     if hAbility and not string.find(hAbility:GetAbilityName(), "special_bonus") then
       hIllusion:RemoveAbility(hAbility:GetAbilityName())
     end
  end

   --将技能添加回来
  for i=0, 24 do
     local hOriginalHeroAbility = hOriginalHero:GetAbilityByIndex(i)
     if hOriginalHeroAbility and not string.find(hOriginalHeroAbility:GetAbilityName(), "special_bonus") then
        if not Illusion.abilityException[hOriginalHeroAbility:GetAbilityName()] then
           if not (hIllusion:HasModifier("modifier_phantom_lancer_juxtapose_illusion") and Illusion.juxtaposeException[hOriginalHeroAbility:GetAbilityName()]) then
             local hNewAbility=hIllusion:AddAbility(hOriginalHeroAbility:GetAbilityName())
             local nLevel = hOriginalHeroAbility:GetLevel()     
             hNewAbility:SetHidden(hOriginalHeroAbility:IsHidden())
             if nLevel>0 then
                hNewAbility:SetLevel(nLevel)
             else
              --没等级的移除一下Modifier
              hIllusion:RemoveModifierByName('modifier_'..hNewAbility:GetAbilityName())
              hIllusion:RemoveModifierByName('modifier_'..hNewAbility:GetAbilityName()..'_aura')
             end
           end
        end
     end
  end
  local nPlayerID = hOriginalHero:GetPlayerID()
  if Econ.vPlayerData[nPlayerID] and Econ.vPlayerData[nPlayerID].sCurrentParticleEconItemName then
      if not Illusion.particleException[Econ.vPlayerData[nPlayerID].sCurrentParticleEconItemName] then
        Econ:EquipIllusionParticle(Econ.vPlayerData[nPlayerID].sCurrentParticleEconItemName,hIllusion)
      end
  end
  if hIllusion.IsTempestDouble and  hIllusion:IsTempestDouble() then
     for i=1,6 do
       if hIllusion:FindItemInInventory("item_manta") then
          local hItem = hIllusion:FindItemInInventory("item_manta")
          if hItem  and  (not hItem:IsNull())   then
              hIllusion:RemoveItem(hItem)
          end 
       end
     end
  end
end



function Illusion:OnNPCSpawned(keys)

  local hIllusion = EntIndexToHScript(keys.entindex)
  
  Timers:CreateTimer(1/30, function()
     Illusion:InitIllusion(hIllusion)
  end)

end