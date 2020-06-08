--英雄构建逻辑
if HeroBuilder == nil then HeroBuilder = class({}) end
LinkLuaModifier( "modifier_aegis", "heroes/modifier_aegis", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aegis_buff", "heroes/modifier_aegis_buff", LUA_MODIFIER_MOTION_NONE )


HeroBuilder.totalAbilityNumber={}

for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS do
  HeroBuilder.totalAbilityNumber[nPlayerID] = 2
end

--互斥技能，保证玩家不会同时选到
abilityExclusion={}

abilityExclusion["dazzle_bad_juju"]= {"puck_phase_shift","dark_willow_shadow_realm","tusk_walrus_punch"}
abilityExclusion["puck_phase_shift"]= {"dazzle_bad_juju"}
abilityExclusion["dark_willow_shadow_realm"]= {"dazzle_bad_juju"}
abilityExclusion["tusk_walrus_punch"]= {"dazzle_bad_juju"}

abilityExclusion["faceless_void_time_lock"]= {"drow_ranger_marksmanship"}
abilityExclusion["drow_ranger_marksmanship"]= {"faceless_void_time_lock"}
abilityExclusion["lone_druid_true_form"]= {"lone_druid_spirit_bear"}
abilityExclusion["lone_druid_spirit_bear"]= {"lone_druid_true_form"}



--模型互斥技能
heroExclusion={}
heroExclusion["npc_dota_hero_drow_ranger"]={"puck_phase_shift","dark_willow_shadow_realm"}
heroExclusion["npc_dota_hero_nevermore"]={"puck_phase_shift","dark_willow_shadow_realm"}
heroExclusion["npc_dota_hero_razor"]={"monkey_king_wukongs_command"}
heroExclusion["npc_dota_hero_silencer"]={"monkey_king_wukongs_command"}


--专属技能表
abilityPersonal={}
abilityPersonal["zuus_static_field"]="npc_dota_hero_zuus"

--不可遗忘的技能表
unremovableAbilities={}
unremovableAbilities["shredder_chakram"]=true
unremovableAbilities["monkey_king_wukongs_command"]=true
unremovableAbilities["void_spirit_aether_remnant"]=true

--A杖技能表
scepterAbilities = {}
scepterAbilities["npc_dota_hero_kunkka"]={"kunkka_torrent_storm"}
scepterAbilities["npc_dota_hero_rattletrap"]={"rattletrap_overclocking"}
scepterAbilities["npc_dota_hero_enchantress"]={"enchantress_bunny_hop"}
scepterAbilities["npc_dota_hero_treant"]={"treant_eyes_in_the_forest"}
scepterAbilities["npc_dota_hero_ogre_magi"]={"ogre_magi_unrefined_fireblast"}
scepterAbilities["npc_dota_hero_earth_spirit"]={"earth_spirit_petrify"}
scepterAbilities["npc_dota_hero_juggernaut"]={"juggernaut_swift_slash"}
scepterAbilities["npc_dota_hero_snapfire"]={"snapfire_gobble_up","snapfire_spit_creep"}
scepterAbilities["npc_dota_hero_nyx_assassin"]={"nyx_assassin_burrow","nyx_assassin_unburrow"}
scepterAbilities["npc_dota_hero_shredder"]={"shredder_chakram_2","shredder_return_chakram_2"}
scepterAbilities["npc_dota_hero_tusk"]={"tusk_walrus_kick"}
scepterAbilities["npc_dota_hero_grimstroke"]={"grimstroke_scepter"}
scepterAbilities["npc_dota_hero_zuus"]={"zuus_cloud"}
scepterAbilities["npc_dota_hero_spectre"]={"spectre_haunt_single"}
scepterAbilities["npc_dota_hero_arc_warden"]={"arc_warden_scepter"}
scepterAbilities["npc_dota_hero_tiny"]={"tiny_tree_channel"}


--召唤技能表
HeroBuilder.summonAbilities = {"beastmaster_call_of_the_wild_boar","shadow_shaman_mass_serpent_ward","brewmaster_primal_split",
"furion_force_of_nature","lone_druid_spirit_bear","venomancer_plague_ward","witch_doctor_death_ward",
"warlock_rain_of_chaos","lycan_summon_wolves","broodmother_spawn_spiderlings","invoker_forge_spirit_lua","visage_summon_familiars",
"enigma_demonic_conversion","undying_tombstone_lua"
}


--需要修复攻击方式的技能列表
HeroBuilder.attackCapabilityModifiers={}
HeroBuilder.attackCapabilityModifiers["modifier_troll_warlord_berserkers_rage"]=true
HeroBuilder.attackCapabilityModifiers["modifier_lone_druid_true_form"]=true
HeroBuilder.attackCapabilityModifiers["modifier_terrorblade_metamorphosis"]=true
HeroBuilder.attackCapabilityModifiers["modifier_dragon_knight_dragon_form"]=true


function HeroBuilder:Init()

    CustomGameEventManager:RegisterListener("HeroSelected",function(_, keys)
        self:HeroSelected(keys)
    end)

    CustomGameEventManager:RegisterListener("AbilitySelected",function(_, keys)
        self:AbilitySelected(keys)
    end)

    CustomGameEventManager:RegisterListener("SpellBookAbilitySelected",function(_, keys)
        self:SpellBookAbilitySelected(keys)
    end)
    
    CustomGameEventManager:RegisterListener("RelearnBookAbilitySelected",function(_, keys)
        self:RelearnBookAbilitySelected(keys)
    end)

    CustomGameEventManager:RegisterListener("SwapAbility",function(_, keys)
        self:SwapAbility(keys)
    end)

    CustomGameEventManager:RegisterListener("ProposeTeammateSwap", function (_, keys)
      self:ProposeTeammateSwap(keys)
    end)

    CustomGameEventManager:RegisterListener("AcceptTeammateSwap", function (_, keys)
      self:AcceptTeammateSwap(keys)
    end)

    CustomGameEventManager:RegisterListener("DeclineTeammateSwap", function (_, keys)
      self:DeclineTeammateSwap(keys)
    end)

    CustomGameEventManager:RegisterListener("ReorderComplete",function(_, keys)
        self:ReorderComplete(keys)
    end)

    --英雄列表
    HeroBuilder.allHeroeNames=table.deepcopy(GameRules.heroesPoolList)
    
    --处理技能列表
    HeroBuilder.heroAbilityPool={}
    --技能所对应的英雄 的映射表
    HeroBuilder.abilityHeroMap={}
    --Link技能Map 学习主技能的时候赋予其子技能
    HeroBuilder.linkedAbilities={}
    
    --Link技能初始等级
    HeroBuilder.linkedAbilitiesLevel={}

    --暂存交换技能的校验码
    HeroBuilder.pendingSwaps={}

    --次要技能列表
    HeroBuilder.subsidiaryAbilitiesList={}

    HeroBuilder.attackCapabilityChanged={}

    local allAbilityNames={}
    local abilityListKV = LoadKeyValues("scripts/npc/npc_abilities_list.txt")
    for szHeroName, data in pairs(abilityListKV) do
        HeroBuilder.heroAbilityPool["npc_dota_hero_"..szHeroName]={}
        local netTableData = {}
        if data and type(data) == "table" then 
             for key, value in pairs(data) do
                 --技能定义
                 if type(value) ~= "table" then
                     table.insert(allAbilityNames, value)
                     table.insert(HeroBuilder.heroAbilityPool["npc_dota_hero_"..szHeroName], value)
                     HeroBuilder.abilityHeroMap[value] =szHeroName
                     table.insert(netTableData, value)
                 --附赠技能
                 else
                     HeroBuilder.linkedAbilities[key]={}
                     for k,v in pairs(value) do
                         --将附赠技能加入队列
                         table.insert(HeroBuilder.linkedAbilities[key],k)                        
                         table.insert(HeroBuilder.subsidiaryAbilitiesList,k)
                         HeroBuilder.linkedAbilitiesLevel[k] = tonumber(v)
                     end
                 end
             end
        end
        CustomNetTables:SetTableValue("hero_info","Abilities_"..szHeroName,netTableData)
    end

    --次要技能推送至前台
    for _,abilityName in pairs(HeroBuilder.subsidiaryAbilitiesList) do
        CustomNetTables:SetTableValue("subsidiary_list", abilityName, {abilityName=abilityName})
    end

    -- A杖技能也是次要技能
    for _,abilityList in pairs(scepterAbilities) do
        for _,sAbilityName in ipairs(abilityList) do
          CustomNetTables:SetTableValue("subsidiary_list", sAbilityName, {abilityName=sAbilityName})
        end
    end

    HeroBuilder.allAbilityNames=allAbilityNames
end

function HeroBuilder:ShowRandomHeroSelection(nPlayerID)
   
    local hPlayer = PlayerResource:GetPlayer(nPlayerID)
    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)

    if hHero  and (true~=hHero.bSelected) and (true~=hHero.bSettled) then
        
        -- 2x6地图为了少加载几个英雄，跳过此步
        if GetMapName()== "1x8" then
          table.remove_item(HeroBuilder.allHeroeNames,PlayerResource:GetSelectedHeroName(nPlayerID))
        end

        if hHero.randomHeroNames ==nil then
            -- 随机选三个
            local randomHeroNames = table.random_some(HeroBuilder.allHeroeNames, 3)
            --记录到英雄上，防止作弊
            hHero.randomHeroNames=randomHeroNames
            --从英雄池移除 不重复出现英雄
            for _,v in ipairs(hHero.randomHeroNames) do
               table.remove_item(HeroBuilder.allHeroeNames,v)
            end
        end
        if hPlayer then
             CustomGameEventManager:Send_ServerToPlayer(hPlayer,"ShowRandomHeroSelection",{data=hHero.randomHeroNames,security_key=Security:GetSecurityKey(nPlayerID)})
        end
    end
    
    -- 5v5 模式上调冠军盾数量
    HeroBuilder.nInitAegisNumber = 2
    if GetMapName()=="5v5" then
       HeroBuilder.nInitAegisNumber = 5
    end

end

function HeroBuilder:ShowRandomAbiliySelection(nPlayerID)

    local hPlayer = PlayerResource:GetPlayer(nPlayerID)
    
    if not hPlayer then
       return
    end

    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)

    if not hHero then
       return
    end
    
    --如果被正在选删除技能却被顶掉，把重修书回退回来
    if true==hHero.bRemovingAbility then
        local hItem = CreateItem("item_relearn_book_lua", hHero, hHero)
        hHero:AddItem(hItem)
    end

    hHero.bRemovingAbility = false

    --如果正在使用卷轴被顶掉，把卷轴回退回来
    if true==hHero.bSelectingSpellBook then
        local hItem = CreateItem("item_spell_book_empty_lua", hHero, hHero)
        hHero:AddItem(hItem)
    end
    hHero.bSelectingSpellBook = false

    if hHero.randomAbilityNames == nil then
        
        --总随机池
        local tempList = table.deepcopy(HeroBuilder.allAbilityNames)
        --本英雄技能
        local ownList = table.deepcopy(HeroBuilder.heroAbilityPool[hHero:GetUnitName()])


        --正在使用的移除随机池技能
        if hHero.abilitiesList == nil then
           hHero.abilitiesList = {}
        end

        for _, sAbilityName in ipairs(hHero.abilitiesList) do
          table.remove_item(tempList,sAbilityName)
          table.remove_item(ownList,sAbilityName)
           -- 移除互斥技能
          if abilityExclusion[sAbilityName] then
             for _,sExclusion in ipairs(abilityExclusion[sAbilityName]) do
                print("sExclusion"..sExclusion)
                table.remove_item(tempList,sExclusion)
                table.remove_item(ownList,sExclusion)
             end
          end
        end
        
        -- 移除本模型禁用技能
        if heroExclusion[hHero:GetUnitName()] then
            for _,sAbilityName in ipairs(heroExclusion[hHero:GetUnitName()]) do
              table.remove_item(tempList,sAbilityName)
            end
        end

        -- 非专属技能移除随机池
        for sAbilityName,sHeroName in pairs(abilityPersonal) do         
            if hHero:GetUnitName()~=sHeroName then
                table.remove_item(tempList,sAbilityName)
                table.remove_item(ownList,sAbilityName)          
            end
        end

        local randomAbilityNames ={}

        -- 概率一个技能给 本英雄技能
        if  RandomInt(1, 100)<65 and #ownList>0 then
            local randomOwnAbilities=table.random_some(ownList, 1)
            -- 不会重复技能
            if randomOwnAbilities[1] then
               table.remove_item(tempList,randomOwnAbilities[1])
            end
            local randomAbilities=table.random_some(tempList, 7)
            randomAbilityNames=table.join(randomOwnAbilities,randomAbilities)
        else
            randomAbilityNames=table.random_some(tempList, 8)
        end
        
        --防止js作弊,将备选技能保存到英雄上
        hHero.randomAbilityNames=randomAbilityNames
        hHero.bSelectingAbility = true
    end


    local dataList = {}
    for _,randomAbilityName in pairs(hHero.randomAbilityNames) do
        local data={}
        data.ability_name = randomAbilityName
        if HeroBuilder.linkedAbilities[randomAbilityName] then
            data.linked_abilities=HeroBuilder.linkedAbilities[randomAbilityName]
        end
        table.insert(dataList,data)
    end

    hHero.sUISecret = CreateSecretKey()

    CustomGameEventManager:Send_ServerToPlayer(hPlayer,"ShowRandomAbilitySelection",{data_list=dataList,ability_number=hHero.nAbilityNumber+1,ui_secret=hHero.sUISecret,security_key=Security:GetSecurityKey(nPlayerID)})

end



-- 初始化玩家英雄
---------------------------------------------------------------------------------
function HeroBuilder:InitPlayerHero( hHero )

    -- 移除除了天赋树技能之外的全部技能
    hHero.bInited = true

    --防止开局互殴
    hHero:AddNewModifier(hHero, nil, "modifier_hero_refreshing", {})

    for i = 0, 23 do
        local hAbility = hHero:GetAbilityByIndex(i)
        if hAbility then
            local szAbilityName = hAbility:GetAbilityName()
            if not string.find(szAbilityName, "special_bonus") then
               hHero:RemoveAbility(szAbilityName)
            end
        end
    end

    -- 移除默认送的TP
    local hTp = hHero:FindItemInInventory('item_tpscroll')
    if hTp then
        hTp:RemoveSelf()
    end
    -- 冠军盾等选择确定再送
end



function HeroBuilder:HeroSelected(keys)

    local szHeroName=keys.hero_name
    local nPlayerID=keys.player_id
    local hPlayer = PlayerResource:GetPlayer(nPlayerID)
    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
    
    if not hPlayer then
        print("HeroSelected, but hPlayer is null")
       return
    end

    --对前台数据进行校验，防止作弊
    if  not (table.contains(hHero.randomHeroNames, szHeroName) or szHeroName==PlayerResource:GetSelectedHeroName(nPlayerID)) then
		  print("not hero that selected by server")
		  return
	  end

    if hHero and hHero.bSelected then
       print("Hero already selected")
       return
    end
    
    --标记为已经选择
    hHero.bSelected = true

    PrecacheUnitByNameAsync(szHeroName, function() end)
    --给预载入留足时间，但是此处不能写回调函数 否则卡死
    local nPrecacheCount = 4
    
    if IsInToolsMode() then
       nPrecacheCount = 2
    end

    Timers:CreateTimer(1, function()
        nPrecacheCount = nPrecacheCount - 1
        local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
        local hPlayer = PlayerResource:GetPlayer(nPlayerID)
        if hPlayer and nPrecacheCount>0 then
          CustomGameEventManager:Send_ServerToPlayer(hPlayer,"ShowHeroPrecacheCountDown",{countDown=nPrecacheCount})
        end
        if hHero and nPrecacheCount<=0 then
          --此处必须等玩家重连回来再替换
          if hPlayer then
              CustomGameEventManager:Send_ServerToPlayer(hPlayer,"HideHeroPrecacheCountDown",{})
              if true~=hHero.bSettled then

                local hOldHero = hHero
                local itemDataList = {}
                
                for i = 0, 16 do
                  local hItem = hOldHero:GetItemInSlot(i);
                  if hItem ~= nil and hItem:GetPurchaser():GetPlayerID()==hOldHero:GetPlayerID() then
                      local itemData = {}
                      itemData.sItemName = hItem:GetName()
                      itemData.nPurchaserID=hItem:GetPurchaser():GetPlayerID()
                      itemData.nCharges=hItem:GetCurrentCharges()
                      table.insert(itemDataList, itemData)
                  end
                end

                hHero = PlayerResource:ReplaceHeroWith(nPlayerID,szHeroName,hHero:GetGold(),0)
                
                --还原物品
                for _,itemData in ipairs(itemDataList) do
                  local hItem = CreateItem(itemData.sItemName,hHero,hHero)
                  hItem:SetCurrentCharges(itemData.nCharges)
                  hHero:AddItem(hItem)
                end
                
                Timers:CreateTimer(0.5, function()
                   hOldHero:ForceKill(false)
                   UTIL_Remove(hOldHero)
                end)
                
                HeroBuilder:InitPlayerHero(hHero)
                --冠军盾
                local hModifierAegis = hHero:AddNewModifier(hHero, nil, "modifier_aegis", {})
                hModifierAegis:SetStackCount(HeroBuilder.nInitAegisNumber)
                
                --英雄已经完成替换的标志
                hHero.bSettled=true
                
                --记录下原始攻击方式
                hHero.nOriginalAttackCapability = hHero:GetAttackCapability()

                --开始技能选择
                hHero.nAbilityNumber=0
                -- 英雄的技能队列
                hHero.abilitiesList = {}
                HeroBuilder:ShowRandomAbiliySelection(nPlayerID)
              end
              return nil
          end
        end
        return 1
    end)

end



function HeroBuilder:AbilitySelected(keys)
     
    local sAbilityName=keys.ability_name
    local nPlayerID=keys.player_id
    local bSpellBookSelected=keys.spell_book_selected

    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
    if not hHero then
       print("hHero is null in AbilitySelected")
       return
    end
    
    if not hHero.bSelectingAbility then
       return
    end
    
    --前台请求怎么校验都不过分
    if hHero.sUISecret~=keys.ui_secret then
       return
    end

    hHero.bSelectingAbility = false

    --玩家放弃选择
    if sAbilityName == nil then
        print("Player cancel ability selection")
        sAbilityName=HeroBuilder:ChooseRandomOneAbility(nPlayerID)
    else
        --对前台数据进行校验，防止作弊
        if hHero.randomAbilityNames then
          if not table.contains(hHero.randomAbilityNames, sAbilityName) then
              print("not ability that selected by server")
              return
          end
        end
    end
    
    --校验结束后清空
    hHero.randomAbilityNames =nil
    
     --如果技能数已经到达上线，不再处理
    if hHero.nAbilityNumber>=HeroBuilder.totalAbilityNumber[nPlayerID] then
        print("ability number reach total")
        return
    end
    RemoveAllGenericHiddenAbilities(hHero)

    hHero.nAbilityNumber = hHero.nAbilityNumber+1
    table.insert(hHero.abilitiesList, sAbilityName)
    
    if 1 == bSpellBookSelected and PlayerResource:GetGold(nPlayerID)>=150 then
       hHero:SpendGold(150,DOTA_ModifyGold_Unspecified)
       hHero:EmitSound("Item.TomeOfKnowledge")
       HeroBuilder:RecordAbility(nPlayerID,sAbilityName)
    else
       HeroBuilder:AddAbility(nPlayerID, sAbilityName)
    end
    
    -- 给出提示
    if hHero.nAbilityNumber==HeroBuilder.totalAbilityNumber[nPlayerID] and PlayerResource:GetPlayer(nPlayerID)  then
       local hPlayer = PlayerResource:GetPlayer(nPlayerID)
       if hHero.nAbilityNumber == 2 then
         Notifications:Bottom(hPlayer,{ text = "#next_ability_round_3", duration = 5, style = { color = "Red" }} )
       end
       if hHero.nAbilityNumber == 3 then
         Notifications:Bottom(hPlayer,{ text = "#next_ability_round_6", duration = 5, style = { color = "Red" }} )
       end
       if hHero.nAbilityNumber == 4 then
         Notifications:Bottom(hPlayer,{ text = "#next_ability_round_9", duration = 5, style = { color = "Red" }} )
       end
    end

     --再次选择 直到技能上限
    if hHero.nAbilityNumber<HeroBuilder.totalAbilityNumber[nPlayerID] then
        HeroBuilder:ShowRandomAbiliySelection(nPlayerID)
    end
    
end



--技能纪录在书上
function HeroBuilder:RecordAbility(nPlayerID,sAbilityName)

    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
    if hHero:IsNull() then
       return
    end
    
    --数据纪录在书上
    local hItem = CreateItem("item_spell_book_lua", hHero, hHero)
    hItem.sAbilityName = sAbilityName
    hHero:AddItem(hItem)

end


--选择技能纪录
function HeroBuilder:SpellBookAbilitySelected(keys)

    local sAbilityName=keys.ability_name
    local nPlayerID=keys.player_id
    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)

    if hHero:IsNull() then
       return
    end

    if true ~= hHero.bSelectingSpellBook then
       return
    end

    if hHero.sUISecret~=keys.ui_secret then
       return
    end

    hHero.bSelectingSpellBook= false

    --玩家放弃选择,还给玩家一本空书
    if sAbilityName == nil then
        print("Player cancel spell book ability selection")
        local hItem = CreateItem("item_spell_book_empty_lua", hHero, hHero)
        hHero:AddItem(hItem)
    end

    --校验不可移除技能
    if unremovableAbilities[sAbilityName] then
       return
    end
    
    local hAbility = hHero:FindAbilityByName(sAbilityName)
    if hAbility then
         local nAbilityLevel = hAbility:GetLevel()
         local flAbilityCoolDown = hAbility:GetCooldownTimeRemaining()
         
         --移除配对技能
        if HeroBuilder.linkedAbilities[sAbilityName] then
          for _,sLinkedAbilityName in ipairs(HeroBuilder.linkedAbilities[sAbilityName]) do
             if hHero:HasAbility(sLinkedAbilityName) then
               hHero:RemoveAbility(sLinkedAbilityName)
               --hHero:AddAbility("generic_hidden")
             end
          end
        end
        --摧毁Modifier
        for _, hModifier in pairs(hHero:FindAllModifiers()) do
            if hModifier:GetAbility() == hAbility then
                hModifier:Destroy()
            end
        end
        -- 删除技能
        hHero:RemoveAbility(sAbilityName)
        
        --清理蛛网等
        Util:RemoveAbilityClean(hHero,sAbilityName)

        hHero:AddAbility("generic_hidden")
        
        --数据纪录在书上
        local hItem = CreateItem("item_spell_book_lua", hHero, hHero)
        hItem.sAbilityName = sAbilityName
        hItem.nAbilityLevel = nAbilityLevel
        hItem.flAbilityCoolDown = flAbilityCoolDown
        hHero:AddItem(hItem)

        --书纪录在英雄上
        if hHero.spellBooks==nil then
           hHero.spellBooks = {}
        end

        hHero.spellBooks[sAbilityName] = hItem
       
        HeroBuilder:RefreshAbilityOrder(nPlayerID)

    end
end


--选择技能纪录
function HeroBuilder:RelearnBookAbilitySelected(keys)

    local sAbilityName=keys.ability_name
    local nPlayerID=keys.player_id
    --统御之书标志位
    local bSummonBook = keys.summon_book

    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)

    if hHero:IsNull() then
       return
    end
    
    --防止js作弊
    if true~=hHero.bRemovingAbility then
       return
    end

    if hHero.sUISecret ~= keys.ui_secret then
       return
    end

    hHero.bRemovingAbility = false

    --玩家放弃选择
    if sAbilityName == nil then
        print("Player cancel relearn book ability selection")
        local hItem = CreateItem("item_relearn_book_lua", hHero, hHero)
        hHero:AddItem(hItem)
        return 
    end
    
    --校验不可移除技能
    if unremovableAbilities[sAbilityName] then
       return
    end
    
    local hAbility = hHero:FindAbilityByName(sAbilityName)
    if hAbility then
         local nAbilityLevel = hAbility:GetLevel()
         --移除配对技能
        if HeroBuilder.linkedAbilities[sAbilityName] then
          for _,sLinkedAbilityName in ipairs(HeroBuilder.linkedAbilities[sAbilityName]) do
             if hHero:HasAbility(sLinkedAbilityName) then
               hHero:RemoveAbility(sLinkedAbilityName)
               --hHero:AddAbility("generic_hidden")
             end
          end
        end
        --摧毁Modifier
        for _, hModifier in pairs(hHero:FindAllModifiers()) do
            if hModifier:GetAbility() == hAbility then
                hModifier:Destroy()
            end
        end
        --技能数量减一
        hHero.nAbilityNumber = hHero.nAbilityNumber -1
        table.remove_item(hHero.abilitiesList,sAbilityName)
        
        -- 删除技能
        hHero:RemoveAbility(sAbilityName)


        --清理蛛网等     
        Util:RemoveAbilityClean(hHero,sAbilityName)
        hHero:AddAbility("generic_hidden")
        
        --给玩家返还技能点
        local nAbilityPoints = hHero:GetAbilityPoints()
        nAbilityPoints = nAbilityPoints + nAbilityLevel
        hHero:SetAbilityPoints(nAbilityPoints)
        
        if bSummonBook==nil then
            --重新展示选技能页面
            HeroBuilder:ShowRandomAbiliySelection(nPlayerID)
          else
            --随机挑选一个召唤类技能
            local sSummonAbilityName = HeroBuilder:ChooseRandomSummonAbility(nPlayerID)
            hHero.bSelectingAbility = true
            hHero.sUISecret= CreateSecretKey()
            HeroBuilder:AbilitySelected({ability_name=sSummonAbilityName,player_id=nPlayerID,ui_secret=hHero.sUISecret})
        end
        
    --如果需要删除的技能在技能书里
    elseif hHero.spellBooks and hHero.spellBooks[sAbilityName] then
        local hItem = hHero.spellBooks[sAbilityName]
        --技能数量减一
        hHero.nAbilityNumber = hHero.nAbilityNumber -1
        table.remove_item(hHero.abilitiesList,sAbilityName)
        --给玩家返还技能点
        local nAbilityPoints = hHero:GetAbilityPoints()
        nAbilityPoints = nAbilityPoints + hItem.nAbilityLevel
        hHero:SetAbilityPoints(nAbilityPoints)

        -- 摧毁技能书
        local hContainner = hItem:GetContainer()
        UTIL_Remove(hItem)
        if hContainner then
            UTIL_Remove(hContainner)
        end
    
        if bSummonBook==nil then
            --重新展示选技能页面
            HeroBuilder:ShowRandomAbiliySelection(nPlayerID)
          else
            --随机挑选一个召唤类技能
            local sSummonAbilityName = HeroBuilder:ChooseRandomSummonAbility(nPlayerID)
            hHero.bSelectingAbility = true
            hHero.sUISecret= CreateSecretKey()
            HeroBuilder:AbilitySelected({ability_name=sSummonAbilityName,player_id=nPlayerID,ui_secret=hHero.sUISecret})
        end

    end
    HeroBuilder:RefreshAbilityOrder(nPlayerID)
end



function HeroBuilder:AddSpellBookAbility(hHero, sAbilityName, nLevel, flCoolDown)

    if  hHero then

        local bHasInvulnerable = false
        RemoveAllGenericHiddenAbilities(hHero)
        
        --暂时移除无敌效果，再添加技能，否则有的技能无效（蚂蚁大）
        if hHero:HasModifier("modifier_hero_refreshing") then
           bHasInvulnerable = true
           hHero:RemoveModifierByName("modifier_hero_refreshing")
        end

        local hNewAbility=hHero:AddAbility(sAbilityName)

        if bHasInvulnerable then
           hHero:AddNewModifier(hHero, nil, "modifier_hero_refreshing", {})
        end        
        

        --设置等级
        if nLevel and nLevel>0 then
           hNewAbility:SetLevel(nLevel)
        else
           --部分BUG技能 赠送一级
           if sAbilityName=="slardar_bash" then
               hNewAbility:SetLevel(1)
           end
           --没等级的移除一下Modifier
           hHero:RemoveModifierByName('modifier_'..sAbilityName)
           hHero:RemoveModifierByName('modifier_'..sAbilityName..'_aura')
        end

        --添加配对技能
        if HeroBuilder.linkedAbilities[sAbilityName] then
          for _,sLinkedAbilityName in ipairs(HeroBuilder.linkedAbilities[sAbilityName]) do
             if not hHero:HasAbility(sLinkedAbilityName) then
               local hNewLinkedAbility = hHero:AddAbility(sLinkedAbilityName)
               if sLinkedAbilityName=="lone_druid_true_form_druid" or  sLinkedAbilityName=="lone_druid_true_form_battle_cry" then
                  hNewLinkedAbility:SetHidden(false)
               end
               if HeroBuilder.linkedAbilitiesLevel[sLinkedAbilityName]>0 then
                  hNewLinkedAbility:SetLevel(HeroBuilder.linkedAbilitiesLevel[sLinkedAbilityName])
               else
                 -- 配对技能应与主技能等级相同       
                 if nLevel and nLevel>0 then
                    hNewLinkedAbility:SetLevel(nLevel)
                 end
               end
             end
          end
        end

        --设置冷却时间
        if flCoolDown and flCoolDown>0 then
           hNewAbility:StartCooldown(flCoolDown)
        end
        HeroBuilder:RefreshAbilityOrder(hHero:GetPlayerOwnerID())
    end
end




function HeroBuilder:AddAbility(nPlayerID, szAbilityName)

    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)

    if  hHero then

        PrecacheUnitByNameAsync("npc_precache_npc_dota_hero_"..HeroBuilder.abilityHeroMap[szAbilityName], function() end)
                
        local bHasInvulnerable = false
        
        --暂时移除无敌效果，再添加技能，否则有的技能无效（蚂蚁大）
        if hHero:HasModifier("modifier_hero_refreshing") then
           bHasInvulnerable = true
           hHero:RemoveModifierByName("modifier_hero_refreshing")
        end
        
        local hNewAbility=hHero:AddAbility(szAbilityName)
        
        if bHasInvulnerable then
           hHero:AddNewModifier(hHero, nil, "modifier_hero_refreshing", {})
        end        
        
        --部分BUG技能 赠送一级
        if szAbilityName=="slardar_bash" then
           hNewAbility:SetLevel(1)
        end

        --移除不正常modifier
        hHero:RemoveModifierByName('modifier_'..szAbilityName)
        hHero:RemoveModifierByName('modifier_'..szAbilityName..'_aura')
        
        --添加配对技能
        if HeroBuilder.linkedAbilities[szAbilityName] then
          for _,szLinkedAbilityName in ipairs(HeroBuilder.linkedAbilities[szAbilityName]) do
             if not hHero:HasAbility(szLinkedAbilityName) then
               local hNewLinkedAbility = hHero:AddAbility(szLinkedAbilityName)
               if szLinkedAbilityName=="lone_druid_true_form_druid" or  szLinkedAbilityName=="lone_druid_true_form_battle_cry" then
                  hNewLinkedAbility:SetHidden(false)
               end
               if HeroBuilder.linkedAbilitiesLevel[szLinkedAbilityName]>0 then
                  hNewLinkedAbility:SetLevel(HeroBuilder.linkedAbilitiesLevel[szLinkedAbilityName])
               end
             end
          end
        end
    end

    HeroBuilder:RefreshAbilityOrder(nPlayerID)
end


function HeroBuilder:ForceFinishHeroBuild()
    for nTeamNumber,bAlive in pairs(GameMode.vAliveTeam) do
        for _,nPlayerID in ipairs(GameMode.vTeamPlayerMap[nTeamNumber]) do

            local hPlayer = PlayerResource:GetPlayer(nPlayerID)
            local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)   

            if hHero then
              --如果英雄还没定，强制启用当前英雄
              if  true~=hHero.bSettled  then
                  
                  if not IsInToolsMode() then
                    local hModifierAegis = hHero:AddNewModifier(hHero, nil, "modifier_aegis", {})
                    hModifierAegis:SetStackCount(HeroBuilder.nInitAegisNumber)
                  end
                  hHero.bSelected=true
                  hHero.bSettled=true

                  --记录下原始攻击方式
                  hHero.nOriginalAttackCapability = hHero:GetAttackCapability()


                  hHero.nAbilityNumber=0
                  hHero.abilitiesList={}
                  --关闭选英雄页面
                  if hPlayer then
                    CustomGameEventManager:Send_ServerToPlayer(hPlayer,"HideHeroSelection",{security_key=Security:GetSecurityKey(nPlayerID)})
                  end
              end
            end
            if hHero.nAbilityNumber< HeroBuilder.totalAbilityNumber[nPlayerID] then
               if not hHero.bSelectingAbility then
                  HeroBuilder:ShowRandomAbiliySelection(nPlayerID)
               end
            end
        end
    end    
end



function HeroBuilder:ChooseRandomOneAbility(nPlayerID)

    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
    
    --总随机池
    local tempList = table.deepcopy(HeroBuilder.allAbilityNames)
    
    --正在使用的移除随机池技能
    for _, sAbilityName in ipairs(hHero.abilitiesList) do
      table.remove_item(tempList,sAbilityName)
      if abilityExclusion[sAbilityName] then
        for _,sExclusion in ipairs(abilityExclusion[sAbilityName]) do
           table.remove_item(tempList,sExclusion)
        end
      end
    end

    -- 移除本模型禁用技能
    if heroExclusion[hHero:GetUnitName()] then
        for _,sAbilityName in ipairs(heroExclusion[hHero:GetUnitName()]) do
          table.remove_item(tempList,sAbilityName)
        end
    end

    -- 非专属技能移除随机池
    for sAbilityName,sHeroName in pairs(abilityPersonal) do         
        if hHero:GetUnitName()~=sHeroName then
            table.remove_item(tempList,sAbilityName)
        end
    end

    -- 不可移除的技能，不随机出现
    for sAbilityName,v in pairs(unremovableAbilities) do         
        table.remove_item(tempList,sAbilityName)
    end
    
    return table.random(tempList)
end


function HeroBuilder:RefreshAbilityOrder(nPlayerID)

    local hPlayer = PlayerResource:GetPlayer(nPlayerID)
    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
    if hPlayer and hHero then
        hHero.sSwapUISecret=CreateSecretKey()
        CustomGameEventManager:Send_ServerToPlayer(hPlayer,"RefreshAbilityOrder",{swap_ui_secret=hHero.sSwapUISecret})
        --刷新换技能页面
        CustomGameEventManager:Send_ServerToTeam(hHero:GetTeamNumber(),"UpdateTeamPlayers",{})
    end
   
end

function HeroBuilder:SwapAbility(keys)
   
     local nPlayerID=keys.player_id
     local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)

     if hHero.sSwapUISecret~=keys.swap_ui_secret then
        return
     end

     local sSwap_1=keys.swap_1
     local sSwap_2=keys.swap_2
     
     if hHero then
        local hAbility1 = hHero:FindAbilityByName(sSwap_1)
        local hAbility2 = hHero:FindAbilityByName(sSwap_2)
        if hAbility1 and hAbility2 then
           hHero:SwapAbilities(sSwap_1, sSwap_2, true, true)
        end
     end

     HeroBuilder:RefreshAbilityOrder(nPlayerID)

end


function HeroBuilder:AddScepterAbility(nHeroIndex)
    
    local hHero = EntIndexToHScript(nHeroIndex)

    if hHero and  hHero:IsRealHero() and hHero:GetUnitName() and scepterAbilities[hHero:GetUnitName()]  then
        
        local abilityList = scepterAbilities[hHero:GetUnitName()]
        for _,sAbilityName in ipairs(abilityList) do
          local hAbility = hHero:FindAbilityByName(sAbilityName)
          if not hAbility then
             local hScepterAbility= hHero:AddAbility(sAbilityName)
             hScepterAbility:SetLevel(1)
          end
        end

        if  hHero.GetPlayerID and hHero:GetPlayerID() then
            Timers:CreateTimer(FrameTime(), function()
               HeroBuilder:RefreshAbilityOrder(hHero:GetPlayerID())
            end)
        end

    end
end



function HeroBuilder:ChooseRandomSummonAbility(nPlayerID)

    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
    
    --总随机池
    local tempList = table.deepcopy(HeroBuilder.summonAbilities)
    
    --正在使用的移除随机池技能
    for _, sAbilityName in ipairs(hHero.abilitiesList) do
      table.remove_item(tempList,sAbilityName)
      if abilityExclusion[sAbilityName] then
          for _,sExclusion in ipairs(abilityExclusion[sAbilityName]) do
           table.remove_item(tempList,sExclusion)
          end
      end
    end

    return table.random(tempList)
end

--在Modifier Filter里面监听
function HeroBuilder:RegisterAttackCapabilityChanged(hHero)
  if not hHero or  hHero:IsTempestDouble() then 
    return 
  end
  HeroBuilder.attackCapabilityChanged[hHero:GetEntityIndex()] = hHero
end


function HeroBuilder:HasAttackCapabilityModifiers(hHero)
  for _, hModifier in ipairs(hHero:FindAllModifiers()) do
    if HeroBuilder.attackCapabilityModifiers[hModifier:GetName()] then
      return true
    end
  end
  return false
end


-- 定时任务， 修复英雄的原始攻击方式
function HeroBuilder:FixAttackCapability()
   for _, hHero in pairs(HeroBuilder.attackCapabilityChanged) do
     if  hHero and hHero.nOriginalAttackCapability and not HeroBuilder:HasAttackCapabilityModifiers(hHero) then
          hHero:SetAttackCapability(hHero.nOriginalAttackCapability)
      end
   end
end


function HeroBuilder:ProposeTeammateSwap( event )
  
  if not event.own or not event.other then return end
  local hProposeHero =   PlayerResource:GetSelectedHeroEntity(event.PlayerID)
   
  --校验数据
  if not hProposeHero then 
    print("hProposeHero is nil")
    return 
  end

  if hProposeHero.sTeamSwapUISecret~=event.ui_secret then
    print("event.ui_secret"..event.ui_secret.."is wrong")
    return 
  end

  if not hProposeHero.nSwappingItemIndex then 
    print("hProposeHero.nSwappingItemIndex is false")
    return 
  end

  local hFirstAbility = EntIndexToHScript(event.own)

  if not hFirstAbility then return end
  if not hFirstAbility:GetCaster() then return end

  if event.PlayerID ~=hFirstAbility:GetCaster():GetPlayerID() then 
    print("event.PlayerID is wrong")
    return 
  end

  event.team_nubmer = PlayerResource:GetTeam(event.PlayerID)
  event.proposer_id = event.PlayerID

  local hSecondAbility = EntIndexToHScript(event.other)
  if not hSecondAbility then 
    print("hSecondAbility is nil")
    return 
  end


  local hSecondPlayer = hSecondAbility:GetCaster():GetPlayerOwner()

  local sVerification = tostring(event.own) .. "_" .. tostring(event.other)
  HeroBuilder.pendingSwaps[sVerification] = event

  --测试账户自动接收
  if PlayerResource:IsFakeClient(hSecondPlayer:GetPlayerID()) then
    HeroBuilder:AcceptTeammateSwap(event)
  else
    CustomGameEventManager:Send_ServerToTeam(hSecondAbility:GetCaster():GetTeamNumber(), "LockAbilities", event)
    Timers:CreateTimer(1/15, function() 
      CustomGameEventManager:Send_ServerToPlayer(hSecondPlayer, "SwapProposed", event)
    end)

    --自动拒绝
    Timers:CreateTimer(sVerification, {
      useGameTime = false,
      endTime = 19.8,
      callback = function()
        HeroBuilder:ResetSwapStatus(event,false)
      end 
    })
  end
end


function HeroBuilder:ReplaceAbilityList(hHero, sPreName, sNewName)
  if not hHero.abilitiesList then return end
  for i, x in pairs(hHero.abilitiesList) do
    if x == sPreName then
      table.remove(hHero.abilitiesList, i)
      break
    end
  end
  table.insert(hHero.abilitiesList, sNewName)
end




function HeroBuilder:AcceptTeammateSwap( event )
  if not event.own or not event.other then return end

  --校验数据
  local sVerification = tostring(event.own) .. "_" .. tostring(event.other)
  if not HeroBuilder.pendingSwaps[sVerification] then return end
  local swapData = HeroBuilder.pendingSwaps[sVerification]
  if swapData.own ~= event.own or swapData.other ~= event.other then return end

  Timers:RemoveTimer(sVerification)
  

  local hFirstAbility = EntIndexToHScript(event.own)
  local hSecondAbility = EntIndexToHScript(event.other)

  if not hFirstAbility or not hSecondAbility then 
    print("hFirstAbility or hSecondAbility not there")
    event.team_nubmer = PlayerResource:GetTeam(event.PlayerID)
    HeroBuilder:ResetSwapStatus(event, false)
    return 
  end
  
  local hSwapItem = EntIndexToHScript(event.item_index)
  if not hSwapItem then
    print("hSwapItem not there")
    HeroBuilder:ResetSwapStatus(event, false)
    return 
  end


  local hFirstHero = hFirstAbility:GetCaster()
  local hSecondHero = hSecondAbility:GetCaster()

  local sFirstName = hFirstAbility:GetAbilityName()
  local sSecondName = hSecondAbility:GetAbilityName()
  
  --校验数据
  local nSecondPlayerID = hSecondHero:GetPlayerOwnerID()
  if event.PlayerID ~= nSecondPlayerID and not PlayerResource:IsFakeClient(nSecondPlayerID) then
    return
  end
  
  --补充数据
  event.team_nubmer = PlayerResource:GetTeam(event.PlayerID)
  event.proposer_id = hFirstHero:GetPlayerOwnerID()

  RemoveAllGenericHiddenAbilities(hFirstHero)
  RemoveAllGenericHiddenAbilities(hSecondHero)

  local flFirstCooldown = hFirstAbility:GetCooldownTimeRemaining()
  local flSecondCooldown = hSecondAbility:GetCooldownTimeRemaining()


  --回退技能点
  hFirstHero:SetAbilityPoints(hFirstHero:GetAbilityPoints() + hFirstAbility:GetLevel())
  hSecondHero:SetAbilityPoints(hSecondHero:GetAbilityPoints() + hSecondAbility:GetLevel())


  hFirstHero:RemoveAbility(sFirstName)
  hSecondHero:RemoveAbility(sSecondName)
  Util:RemoveAbilityClean(hFirstHero, sFirstName)
  Util:RemoveAbilityClean(hSecondHero, sSecondName)


  local hNewFirstAbility = hFirstHero:AddAbility(sSecondName)
  local hNewSecondAbility = hSecondHero:AddAbility(sFirstName)
  
  --移除一下新技能的Modifier
  hFirstHero:RemoveModifierByName('modifier_'..sSecondName)
  hFirstHero:RemoveModifierByName('modifier_'..sSecondName..'_aura')
  hSecondHero:RemoveModifierByName('modifier_'..sFirstName)
  hSecondHero:RemoveModifierByName('modifier_'..sFirstName..'_aura')
  
  --刷新两个英雄的技能列表
  HeroBuilder:ReplaceAbilityList(hFirstHero, sFirstName, sSecondName)
  HeroBuilder:ReplaceAbilityList(hSecondHero, sSecondName, sFirstName)
  
  -- 交换附属技能
  HeroBuilder:SwapLinkedAbilities(hFirstHero, hSecondHero, sFirstName, sSecondName)

  --重置冷却时间
  if flFirstCooldown then
    hNewSecondAbility:StartCooldown(flFirstCooldown)
  end

  if flSecondCooldown then
    hNewFirstAbility:StartCooldown(flSecondCooldown)
  end

  Timers:CreateTimer(0.02, function()
    HeroBuilder:RefreshAbilityOrder(hFirstHero:GetPlayerOwnerID())
    HeroBuilder:RefreshAbilityOrder(hSecondHero:GetPlayerOwnerID())
  end)

  --结束交换
  Timers:CreateTimer(0.2, function()
    HeroBuilder:ResetSwapStatus(event, true)
  end)
end

--交换附属技能
function HeroBuilder:SwapLinkedAbilities(hFirstHero, hSecondHero, sFirstAbilityName, sSecondAbilityName)
  
  local firstLinked = HeroBuilder.linkedAbilities[sFirstAbilityName]
  local secondLinked = HeroBuilder.linkedAbilities[sSecondAbilityName]

  if firstLinked then
    for _, sAbilityName in ipairs(firstLinked) do
      hFirstHero:RemoveAbility(sAbilityName)
      local hNewAbility = hSecondHero:AddAbility(sAbilityName)
      if sAbilityName=="lone_druid_true_form_druid" or  sAbilityName=="lone_druid_true_form_battle_cry" then
        hNewAbility:SetHidden(false)
      end
      local nLevel = HeroBuilder.linkedAbilitiesLevel[sAbilityName] 
      if nLevel > 0 then
        hNewAbility:SetLevel(nLevel)
      end
    end
  end

  if secondLinked then
    for _, sAbilityName in ipairs(secondLinked) do
      hSecondHero:RemoveAbility(sAbilityName)
      local hNewAbility = hFirstHero:AddAbility(sAbilityName)
      if sAbilityName=="lone_druid_true_form_druid" or  sAbilityName=="lone_druid_true_form_battle_cry" then
        hNewAbility:SetHidden(false)
      end
      local nLevel = HeroBuilder.linkedAbilitiesLevel[sAbilityName] 
      if nLevel > 0 then
        hNewAbility:SetLevel(nLevel)
      end
    end
  end

end

function HeroBuilder:DeclineTeammateSwap(keys)
    local nPlayerID =  keys.PlayerID
    keys.team_nubmer = PlayerResource:GetTeam(nPlayerID)
    HeroBuilder:ResetSwapStatus(keys, false)
end


function HeroBuilder:ResetSwapStatus(event, bAccept)

  if not event.own or not event.other then return end
  local sVerification = tostring(event.own) .. "_" .. tostring(event.other)
  if not HeroBuilder.pendingSwaps[sVerification] then return end
  
  --释放英雄状态
  if event.proposer_id then
     local hProposeHero = PlayerResource:GetSelectedHeroEntity(event.proposer_id)
     hProposeHero.nSwappingItemIndex = nil
  end

  -- 交换成功销毁道具
  if event.item_index and  bAccept then
     local hSwapItem = EntIndexToHScript(event.item_index)
     if hSwapItem then
        hSwapItem:SpendCharge()
     end
  end

  event.accepted = bAccept
  HeroBuilder.pendingSwaps[sVerification] = nil
  CustomGameEventManager:Send_ServerToTeam(event.team_nubmer, "UnlockAbilities", event)
end



function HeroBuilder:ReorderComplete(keys)
   
     local nPlayerID=keys.PlayerID
     local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)

     if hHero.sSwapUISecret~=keys.swap_ui_secret then
        return
     end

     local sSwap_1=keys.moved_ability
     local sSwap_2=keys.ref_ability
     
     if hHero then
        local hAbility1 = hHero:FindAbilityByName(sSwap_1)
        local hAbility2 = hHero:FindAbilityByName(sSwap_2)
        if hAbility1 and hAbility2 then
           hHero:SwapAbilities(sSwap_1, sSwap_2, true, true)
        end
     end

     HeroBuilder:RefreshAbilityOrder(nPlayerID)

end
