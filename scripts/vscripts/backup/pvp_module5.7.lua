--PVP 模块 
if PvpModule == nil then PvpModule = class({}) end
LinkLuaModifier( "modifier_loser_curse", "heroes/modifier_loser_curse", LUA_MODIFIER_MOTION_NONE )


--胜利者音效
PvpModule.winnerSoundMap = {
        npc_dota_hero_abaddon=                 "abaddon_abad_win_03",
        npc_dota_hero_abyssal_underlord=       "abyssal_underlord_abys_win_05",
        npc_dota_hero_alchemist=               "alchemist_alch_win_03",
        npc_dota_hero_ancient_apparition=      "ancient_apparition_appa_win_03",
        npc_dota_hero_antimage=                "antimage_anti_win_03",
        npc_dota_hero_arc_warden=              "arc_warden_arcwar_win_05",
        npc_dota_hero_axe=                     "axe_axe_win_02",
        npc_dota_hero_bane=                    "bane_bane_win_02",
        npc_dota_hero_batrider=                "batrider_bat_win_04",
        npc_dota_hero_beastmaster=             "beastmaster_beas_win_02",
        npc_dota_hero_bloodseeker=            "bloodseeker_blod_win_03",
        npc_dota_hero_bounty_hunter=           "bounty_hunter_bount_win_05",
        npc_dota_hero_brewmaster=              "brewmaster_brew_win_03",
        npc_dota_hero_bristleback=             "bristleback_bristle_win_04",
        npc_dota_hero_broodmother=             "broodmother_broo_win_04",
        npc_dota_hero_centaur=                 "centaur_cent_win_04",
        npc_dota_hero_chaos_knight=            "chaos_knight_chaknight_win_04",
        npc_dota_hero_chen=                    "chen_chen_win_02",
        npc_dota_hero_clinkz=                  "clinkz_clinkz_win_03",
        npc_dota_hero_crystal_maiden=          "crystalmaiden_cm_win_04",
        npc_dota_hero_dark_seer=               "dark_seer_dkseer_win_05",
        npc_dota_hero_dark_willow=             "dark_willow_sylph_win_05",
        npc_dota_hero_dazzle=                  "dazzle_dazz_win_03",
        npc_dota_hero_death_prophet=           "death_prophet_dpro_win_03",
        npc_dota_hero_disruptor=               "disruptor_dis_win_05",
        npc_dota_hero_doom_bringer=            "doom_bringer_doom_win_03",
        npc_dota_hero_dragon_knight=           "dragon_knight_drag_win_03",
        npc_dota_hero_drow_ranger=             "drowranger_dro_win_05",
        npc_dota_hero_earth_spirit=            "earth_spirit_earthspi_win_03",
        npc_dota_hero_earthshaker=             "earthshaker_erth_win_03",
        npc_dota_hero_elder_titan=             "elder_titan_elder_win_03",
        npc_dota_hero_ember_spirit=            "ember_spirit_embr_win_03",
        npc_dota_hero_enchantress=             "enchantress_ench_rare_02",
        npc_dota_hero_enigma=                  "enigma_enig_rare_01",
        npc_dota_hero_faceless_void=           "faceless_void_face_win_03",
        npc_dota_hero_furion=                  "furion_furi_view_victory_03",
        npc_dota_hero_grimstroke=               "grimstroke_grimstroke_win_04",
        npc_dota_hero_gyrocopter=              "gyrocopter_gyro_kill_04",
        npc_dota_hero_huskar=                  "huskar_husk_win_03",
        npc_dota_hero_invoker=                 "invoker_invo_win_01",
        npc_dota_hero_jakiro=                  "jakiro_jak_win_02",
        npc_dota_hero_juggernaut=              "juggernaut_jug_rare_06",
        npc_dota_hero_keeper_of_the_light=     "keeper_of_the_light_keep_win_02",
        npc_dota_hero_kunkka=                  "kunkka_kunk_win_03",
        npc_dota_hero_legion_commander=        "legion_commander_legcom_win_03",
        npc_dota_hero_leshrac=                 "leshrac_lesh_rare_01",
        npc_dota_hero_lich=                    "lich_lich_rare_01",
        npc_dota_hero_life_stealer=            "life_stealer_lifest_win_03",
        npc_dota_hero_lina=                    "lina_lina_win_03",
        npc_dota_hero_lion=                    "lion_lion_kill_06",
        npc_dota_hero_lone_druid=              "lone_druid_lone_druid_win_03",
        npc_dota_hero_luna=                    "luna_luna_win_03",
        npc_dota_hero_lycan=                   "lycan_lycan_respawn_06",
        npc_dota_hero_magnataur=               "magnataur_magn_win_01",
        npc_dota_hero_mars=                    "mars_mars_win_02 ",
        npc_dota_hero_medusa=                  "medusa_medus_win_05",
        npc_dota_hero_meepo=                   "meepo_meepo_win_04",
        npc_dota_hero_mirana=                  "mirana_mir_rare_09",
        npc_dota_hero_monkey_king=             "monkey_king_monkey_win_01",
        npc_dota_hero_morphling=               "morphling_mrph_win_03",
        npc_dota_hero_naga_siren=              "naga_siren_naga_win_03",
        npc_dota_hero_necrolyte=               "necrolyte_necr_respawn_13",
        npc_dota_hero_nevermore=               "nevermore_nev_win_03",
        npc_dota_hero_night_stalker=           "night_stalker_nstalk_win_01",
        npc_dota_hero_nyx_assassin=            "nyx_assassin_nyx_win_04",
        npc_dota_hero_obsidian_destroyer=      "outworld_destroyer_odest_win_04",
        npc_dota_hero_ogre_magi=               "ogre_magi_ogmag_win_03",
        npc_dota_hero_omniknight=              "omniknight_omni_win_03",
        npc_dota_hero_oracle=                  "oracle_orac_win_01",
        npc_dota_hero_pangolier=               "pangolin_pangolin_win_02",
        npc_dota_hero_phantom_assassin=        "phantom_assassin_phass_win_02",
        npc_dota_hero_phantom_lancer=          "phantom_lancer_plance_kill_10",
        npc_dota_hero_phoenix=                 "phoenix_phoenix_bird_victory",
        npc_dota_hero_puck=                    "puck_puck_win_04",
        npc_dota_hero_pudge=                   "pudge_pud_rare_05",
        npc_dota_hero_pugna=                   "pugna_pugna_win_03",
        npc_dota_hero_queenofpain=             "queenofpain_pain_win_03",
        npc_dota_hero_rattletrap=              "rattletrap_ratt_win_04",
        npc_dota_hero_razor=                   "razor_raz_level_04",
        npc_dota_hero_riki=                    "riki_riki_level_05",
        npc_dota_hero_rubick=                  "rubick_rubick_win_03",
        npc_dota_hero_sand_king=               "sandking_skg_level_02",
        npc_dota_hero_shadow_demon=            "shadow_demon_shadow_demon_win_03",
        npc_dota_hero_shadow_shaman=           "shadowshaman_shad_win_03",
        npc_dota_hero_snapfire=                "snapfire_snapfire_win_01 ",
        npc_dota_hero_shredder=                "shredder_timb_levelup_07",
        npc_dota_hero_silencer=                "silencer_silen_win_03",
        npc_dota_hero_skeleton_king=           "skeleton_king_wraith_level_07",
        npc_dota_hero_skywrath_mage=           "skywrath_mage_drag_levelup_02",
        npc_dota_hero_slardar=                 "slardar_slar_win_05",
        npc_dota_hero_slark=                   "slark_slark_win_03",
        npc_dota_hero_sniper=                  "sniper_snip_rare_01",
        npc_dota_hero_spectre=                 "spectre_spec_win_01",
        npc_dota_hero_spirit_breaker=          "spirit_breaker_spir_win_03",
        npc_dota_hero_storm_spirit=            "stormspirit_ss_win_03",
        npc_dota_hero_sven=                    "sven_sven_win_05",
        npc_dota_hero_techies=                 "techies_tech_move_52",
        npc_dota_hero_templar_assassin=        "templar_assassin_temp_win_03",
        npc_dota_hero_terrorblade=             "terrorblade_terr_shards_win_03",
        npc_dota_hero_tidehunter=              "tidehunter_tide_rare_01",
        npc_dota_hero_tinker=                  "tinker_tink_win_03",
        npc_dota_hero_tiny=                    "tiny_tiny_win_02",
        npc_dota_hero_treant=                  "treant_treant_win_04",
        npc_dota_hero_troll_warlord=           "troll_warlord_troll_win_03",
        npc_dota_hero_tusk=                    "tusk_tusk_win_01",
        npc_dota_hero_undying=                 "undying_undying_win_05",
        npc_dota_hero_ursa=                    "ursa_ursa_win_02",
        npc_dota_hero_vengefulspirit=          "vengefulspirit_vng_win_02",
        npc_dota_hero_venomancer=              "venomancer_venm_win_03",
        npc_dota_hero_viper=                   "viper_vipe_win_02",
        npc_dota_hero_visage=                  "visage_visa_win_03",
        npc_dota_hero_void_spirit=             "void_spirit_voidspir_win_01",
        npc_dota_hero_warlock=                 "warlock_warl_win_04",
        npc_dota_hero_weaver=                  "weaver_weav_win_03",
        npc_dota_hero_windrunner=              "windrunner_wind_win_04",
        npc_dota_hero_winter_wyvern=           "winter_wyvern_winwyv_win_02",
        npc_dota_hero_wisp=                    "wisp_win",
        npc_dota_hero_witch_doctor=            "witchdoctor_wdoc_win_04",
        npc_dota_hero_zuus=                    "zuus_zuus_rare_03",
}




function PvpModule:Init()

  --PVP是否结束
  PvpModule.bEnd=true
  --是否已买定离手
  PvpModule.bLeaveHand = true

  PvpModule.pvpPairs={}
  -- PVP 间隔
  PvpModule.nInterval = 1
  
  if GetMapName()=="2x6" then
    PvpModule.nInterval = 2
  end

  --- 进行过PVP活动的关卡编号
  --- 从第2关开始PVP 活动
  PvpModule.nLastPvpRound = 1

  --ToolMode 提早开始PVP
  if IsInToolsMode() then
    PvpModule.nLastPvpRound = 0
  end

  --统计玩家的下注金额的总量
  PvpModule.betValueSum ={}

  for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
      PvpModule.betValueSum[nPlayerID] = 0
  end

  PvpModule.currentPair ={}

  --所有PVP配对的 日志记录
  PvpModule.allPairLog ={}

  CustomGameEventManager:RegisterListener("ConfirmBet",function(_, keys)
        PvpModule:ConfirmBet(keys)
  end)
  CustomGameEventManager:RegisterListener("ConfirmActor",function(_, keys)
        PvpModule:ConfirmActor(keys)
  end)


  --监听英雄阵亡消息 处理PVP结果
  ListenToGameEvent("entity_killed", Dynamic_Wrap(PvpModule, "OnEntityKilled"), self)
end

function PvpModule:ShuffleCondition1() 
    
    local bCondition_1 = false

    if PvpModule.lastPair then
      local firstPair = PvpModule.pvpPairs[1]
      bCondition_1 = (firstPair[1]==PvpModule.lastPair[1] or firstPair[2]==PvpModule.lastPair[2] or firstPair[2]==PvpModule.lastPair[1] or firstPair[1]==PvpModule.lastPair[2])
    end

    return bCondition_1
end

function PvpModule:ShuffleCondition2() 
    
    local bCondition_2 = false

    if #PvpModule.pvpPairs>=3 then
       for i=2,#PvpModule.pvpPairs do
         if (PvpModule.pvpPairs[i][1]==PvpModule.pvpPairs[i-1][1] or PvpModule.pvpPairs[i][2]==PvpModule.pvpPairs[i-1][2] or PvpModule.pvpPairs[i][1]==PvpModule.pvpPairs[i-1][2] or PvpModule.pvpPairs[i][2]==PvpModule.pvpPairs[i-1][1]) then
           bCondition_2 = true
         end
       end
    end
    
    return bCondition_2
end



function PvpModule:RoundPrepare(nRoundNumber)
    
    --统计存活玩家数量
    local nAliveTeamNumber = 0 
    for _,bAlive in pairs(GameMode.vAliveTeam) do
      if bAlive then
         nAliveTeamNumber = nAliveTeamNumber+1
      end
    end
    
    --菠菜奖金池
    local nBaseBonus = 152
    local nBonusRatio = 1

    if GetMapName()=="2x6" then
       --多人模式 调高奖励
       nBaseBonus = 152 + 142*2
       nBonusRatio = 1.5
    end

    PvpModule.nBetBonus = (nBaseBonus + 142 * nAliveTeamNumber*nBonusRatio) * math.pow(1.024, (nRoundNumber-1))

    --key 被下注的玩家id    value下注玩家的数据list 
    PvpModule.betMap = {}

    PvpModule.nLastPvpRound = nRoundNumber

     --如果PVP配对已经用完 重新计算
    if #PvpModule.pvpPairs == 0 then

         --洗牌不能解决的标志位
        local bShuffleFailed = true
         -- 重新配对的尝试次数
        local nRepairTimes = 0 

        while bShuffleFailed and nRepairTimes<5 do

            PvpModule:PairPvp()
            nRepairTimes = nRepairTimes + 1

            -- 查看是否需要洗牌
            if #PvpModule.pvpPairs > 0 and  PvpModule.pvpPairs[1] then
                 local nShuffleRetryTimes = 0
                 -- 如果与上轮相同           
                 local bCondition_1 = false
                 local bCondition_2 = false

                 bCondition_1 = PvpModule:ShuffleCondition1()
                 bCondition_2 = PvpModule:ShuffleCondition2()
                 
                 --大于等于5人才洗牌
                 while nShuffleRetryTimes<7 and PvpModule.nValideTeam>=5 and (bCondition_1 or bCondition_2)  do               
                     nShuffleRetryTimes = nShuffleRetryTimes+1
                     PvpModule.pvpPairs=table.shuffle(PvpModule.pvpPairs)
                     bCondition_1 = PvpModule:ShuffleCondition1()
                     bCondition_2 = PvpModule:ShuffleCondition2()
                 end
                 if nShuffleRetryTimes==7 then
                    --只有7人/8人下面 才尝试重新配对（5人，6人容易相同组合反复打）
                    if PvpModule.nValideTeam>=7 then
                       bShuffleFailed = true
                    end
                 else
                    bShuffleFailed = false
                 end
            else
                bShuffleFailed = false
            end
        end

        --加入日志
        table.insert(PvpModule.allPairLog, table.deepcopy(PvpModule.pvpPairs))

        PrintTable(PvpModule.allPairLog)
        
        --特殊情况 将日志发给服务器
        --[[
        if nRepairTimes==5 and RandomInt(1, 6)==1 then
            local sMessage = ""
            if nRepairTimes then
              sMessage = "nRepairTimes:" ..nRepairTimes.."\n"
            end

            local sAllPairMessage=PrintTableToString(PvpModule.allPairLog)
            if sAllPairMessage then
                sMessage = sMessage.."Same allPairLog\n"..sAllPairMessage
            end
            print(sMessage)
            Server:UploadErrorLog(sMessage)
        end
        ]]
    end
    
    if #PvpModule.pvpPairs > 0 then

        local pair = PvpModule.pvpPairs[1]
        --校验数据
        if pair[1]~=nil and pair[2]~=nil and pair[3]==nil then
          
            --PVP是否结束(确认进行PVP)
            PvpModule.bEnd=false
            --是否已买定离手
            PvpModule.bLeaveHand = false

            --设置两个队列
            PvpModule.betMap[pair[1]]={}
            PvpModule.betMap[pair[2]]={} 
                        
            PvpModule.currentPair =  pair
            --记录一个最近的pair
            PvpModule.lastPair =  pair
            
            local nRandomIndex = RandomInt(1,2)
            -- 主场玩家ID
            local nHomeTeamID = PvpModule.currentPair[nRandomIndex] 
            
            PvpModule.nHomeTeamID = nHomeTeamID

            -- 主场玩家位置 
            PvpModule.vHomeCenter = GameMode.vTeamLocationMap[nHomeTeamID]

            --延迟5秒，击杀PVP主场区域附近的召唤物
            Summon:KillSummonedCreatureAsyn(PvpModule.vHomeCenter)
            
            local dataList={}
            for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
              if PlayerResource:GetTeam( nPlayerID ) == pair[1] or PlayerResource:GetTeam( nPlayerID )==pair[2] then
                 local data = {}
                 data.playerID = nPlayerID
                 data.teamID = PlayerResource:GetTeam( nPlayerID )
                 table.insert(dataList, data)
              end
            end

            --为玩家弹出PVP下注框
            for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
              if PlayerResource:IsValidPlayer(nPlayerID) and ( IsInToolsMode() or PlayerResource:GetConnectionState(nPlayerID) == DOTA_CONNECTION_STATE_CONNECTED)  then                      
                if GameMode.vAliveTeam[PlayerResource:GetTeam( nPlayerID )] then
                    local hPlayer = PlayerResource:GetPlayer(nPlayerID)
                    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
                    if hPlayer and hHero then
                      hHero.sBetUISecret = CreateSecretKey()
                      CustomGameEventManager:Send_ServerToPlayer(hPlayer,"ShowPvpBet",{players=dataList,firstTeamId=pair[1],secondTeamId=pair[2],bet_ui_secret=hHero.sBetUISecret,security_key=Security:GetSecurityKey(nPlayerID)} )   
                    end
                end
              end
            end
        end

        table.remove(PvpModule.pvpPairs, 1)
    end

end



--计算PVP配对

function PvpModule:PairPvp()

	 PvpModule.pvpPairs={}

    -- 有效队伍列表(剔除断线玩家)
    local pvpValideTeamMap = {}
    local nValideTeam = 0
    local pvpValideTeamList ={}
    local enemyTeams = {}

    --整理有效队伍
    for nTeamNumber,bAlive in pairs(GameMode.vAliveTeam) do
      if bAlive then
          for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
            --断线玩家不参与PVP
            if PlayerResource:IsValidPlayer(nPlayerID) and ( IsInToolsMode() or PlayerResource:GetConnectionState(nPlayerID) == DOTA_CONNECTION_STATE_CONNECTED)  then
                if PlayerResource:GetTeam( nPlayerID ) == nTeamNumber then
                   if pvpValideTeamMap[nTeamNumber] ==nil then
                      nValideTeam = nValideTeam +1
                      pvpValideTeamMap[nTeamNumber] = true
                      table.insert(pvpValideTeamList, nTeamNumber)
                   end
                end
            end
          end
       end
    end
    
    --整理队伍
    for nTeamNumber,bValid in pairs(pvpValideTeamMap) do
      enemyTeams[nTeamNumber]={}
      for nEnemyTeamNumber,bValid in pairs(pvpValideTeamMap) do
         if nEnemyTeamNumber~=nTeamNumber then
            table.insert(enemyTeams[nTeamNumber],nEnemyTeamNumber)
         end 
      end
    end


    --记录
    PvpModule.nValideTeam = nValideTeam

    

    if nValideTeam==3 or nValideTeam==4 or nValideTeam==5  then
       PvpModule.nInterval = 2
    end

    if nValideTeam==2 then
       PvpModule.nInterval = 3
    end

    if nValideTeam>2 and IsInToolsMode() then
       PvpModule.nInterval = 1
    end

    --3队剩余
    if nValideTeam==3 then
        for nTeamNumber,data in pairs(enemyTeams) do
           local pair = {}
           for _,nTeamNumber in ipairs(data) do
             table.insert(pair,nTeamNumber)
           end
           table.insert(PvpModule.pvpPairs,pair)
        end
        PrintTable(PvpModule.pvpPairs)
        return
    end


    --2队剩余
    if nValideTeam==2 then
        for nTeamNumber,data in pairs(enemyTeams) do
           local pair = {}
           table.insert(pair,nTeamNumber)
           table.insert(pair,data[1])
           table.insert(PvpModule.pvpPairs,pair)
        end
        PrintTable(PvpModule.pvpPairs)
        return 
    end

    --2x6 模式 1队剩余
    if nValideTeam==1 then
        print("Only One PVP team, return...")
        return 
    end

    local tempEnemyTeams= table.deepcopy(enemyTeams)
    pvpValideTeamList=table.shuffle(pvpValideTeamList)

    for _,nTeamNumber in ipairs(pvpValideTeamList) do
        local list = tempEnemyTeams[nTeamNumber]
        if list then
          if #list>0 then
                local nEnenmyTeamNumber=table.random(list)
                local pair = {}
                table.insert(pair,nEnenmyTeamNumber)
                table.insert(pair,nTeamNumber)
                table.insert(PvpModule.pvpPairs,pair)
                tempEnemyTeams[nTeamNumber] = nil
                tempEnemyTeams[nEnenmyTeamNumber] = nil
                for _,EnemyList in pairs(tempEnemyTeams) do
                   table.remove_item(EnemyList,nTeamNumber)
                end
                for _,EnemyList in pairs(tempEnemyTeams) do
                   table.remove_item(EnemyList,nEnenmyTeamNumber)
                end
          else
            --没有配对队伍，随机选一个
                local nEnenmyTeamNumber=table.random(enemyTeams[nTeamNumber])
                local pair = {}
                table.insert(pair,nEnenmyTeamNumber)
                table.insert(pair,nTeamNumber)
                table.insert(PvpModule.pvpPairs,pair)
                tempEnemyTeams[nTeamNumber] = nil
                tempEnemyTeams[nEnenmyTeamNumber] = nil
                for _,EnemyList in pairs(tempEnemyTeams) do
                   table.remove_item(EnemyList,nTeamNumber)
                end
                for _,EnemyList in pairs(tempEnemyTeams) do
                   table.remove_item(EnemyList,nEnenmyTeamNumber)
                end
          end
        end
    end
    

    --PrintTable(PvpModule.pvpPairs)
    --打乱顺序
    if not IsInToolsMode() then
      PvpModule.pvpPairs=table.shuffle(PvpModule.pvpPairs)
    end

end


function CleanTempData(tempTable,nId)
    for nTeamNumber,bAlive in pairs(GameMode.vAliveTeam) do
        if bAlive and tempTable[nTeamNumber] then
          table.remove_item(tempTable[nTeamNumber],nId)
        end
    end
end


--玩家押注事件
function PvpModule:ConfirmBet(keys)

    local nPlayerId = keys.PlayerID;
    local nMaxGold=math.floor(PlayerResource:GetGold(nPlayerId)/2)

    --必须为数字
    if type(keys.value) ~= "number" then
        print("Bet value is not number")
        return
    end
    
    --已经买定离手，新的下注无效
    if PvpModule.bLeaveHand then
        print("Bet already end")
        return
    end
    
    --队伍已经失败 下注无效
    if not GameMode.vAliveTeam[PlayerResource:GetTeam(nPlayerId)] then
        print("Team Already Lose")
        return
    end
    
    local bAlreadyBet =false
    
    --遍历押注表
    for _,dataList in pairs(PvpModule.betMap) do
        for _,data in ipairs(dataList) do
            if data.nPlayerId == nPlayerId then
                bAlreadyBet=true
            end
        end
    end

    if bAlreadyBet then
        print("Already Bet")
        return
    end

    local nValue = math.floor(keys.value)

    if nValue<=0 then
       return
    end
    
    if nValue>nMaxGold then
       nValue = nMaxGold
    end
    
    --被下注的玩家id 违规
    if PvpModule.betMap[keys.wish_team_id] == nil then
       print("Bet wish team Id:"..keys.wish_team_id.."is null")
       return 
    end

    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerId)
    if hHero==nil or hHero:IsNull() then
       return
    end
    
    --校验数据
    if hHero.sBetUISecret~=keys.bet_ui_secret then
       return
    end

    --将押注的玩家 ID 加入队列
    local data = {}
    data.nPlayerId = nPlayerId
    data.nValue = nValue
    --将押注的玩家 信息 加入队列
    table.insert(PvpModule.betMap[keys.wish_team_id], data)

    PvpModule.nBetBonus = PvpModule.nBetBonus + nValue;
    
    if  PvpModule.betValueSum[nPlayerId] then
       PvpModule.betValueSum[nPlayerId] = PvpModule.betValueSum[nPlayerId] + nValue
    end

    --扣款
    hHero:SpendGold(nValue, DOTA_ModifyGold_Unspecified)
    hHero:EmitSound("DOTA_Item.Hand_Of_Midas")
    --扣款特效
    ParticleManager:CreateParticle("particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_midas_coinshower.vpcf", PATTACH_ABSORIGIN, hHero)
    
end

--总结押注信息 发弹幕
function PvpModule:SummarizeBetInfo()

   --买定离手
   PvpModule.bLeaveHand = true

   if PvpModule.bEnd then
     return
   end

   --PVP参与者的免费投注
   local nPvpFreeBet = 0
   
   for nTeamID,list in pairs(PvpModule.betMap) do
       
       --排序
       --table.sort(list, function(a, b) return a.nValue > b.nValue end)

       local nSumBet = 0  

       for _,data in ipairs(list) do
          nSumBet= nSumBet+ data.nValue
       end
       --先发弹幕
       if GetMapName() =="1x8" then
         local data={}
         data.type = "bet_summary_solo"
         data.playerId = PlayerResource:GetNthPlayerIDOnTeam(nTeamID, 1)
         data.gold_value = nSumBet
         Barrage:FireBullet(data)
       end

       if GetMapName() =="2x6" then
         local data={}
         data.type = "bet_summary"
         data.teamId = nTeamID
         data.gold_value = nSumBet
         Barrage:FireBullet(data)
       end
       
       for _,nPlayerID in ipairs(GameMode.vTeamPlayerMap[nTeamID]) do
           local data = {}
           local flPvpBetRatio = 0.05
           -- 2人模式减半
           if GetMapName()=="2x6" then
              flPvpBetRatio = 0.02
           end

           --PVP玩家的免费下注
           data.nValue = math.floor(PvpModule.nBetBonus*flPvpBetRatio)
           data.nPlayerId = nPlayerID
           data.sType = "pvp_free"

           nSumBet = nSumBet + data.nValue
           nPvpFreeBet = nPvpFreeBet + data.nValue

           table.insert(list, data)
       end

       -- 统计押注比率
       for _,data in ipairs(list) do
          local flRatio= data.nValue/nSumBet
          data.flRatio = flRatio
       end
       
   end

   PvpModule.nBetBonus = PvpModule.nBetBonus + nPvpFreeBet

end



--玩家阵亡
function PvpModule:OnEntityKilled(keys)
    
   --debug top
   xpcall(
    function()
  --debug top

    local hKilledUnit = EntIndexToHScript(keys.entindex_killed)

    if hKilledUnit == nil then
        return
    end
    
    --如果重生起作用了，忽略本次击杀
    if Util:IsReincarnationWork(hKilledUnit) then
       return
    end
    
    --关卡准备阶段的击杀 不触发
    if GameMode.currentRound and GameMode.currentRound.nTimeLimit ==nil then
       return
    end

    if hKilledUnit:IsRealHero() then
      local  nKilledTeamID = PlayerResource:GetTeam(hKilledUnit:GetPlayerOwnerID());
      for i,nTeamID in ipairs(PvpModule.currentPair) do
          if nKilledTeamID==nTeamID and PvpModule:CheckTeamAllDead(nTeamID) then
              local nLoserTeamId = nKilledTeamID
              local nWinnerTeamId =  PvpModule.currentPair[3-i];
              PvpModule:EndPvp(nWinnerTeamId,nLoserTeamId);
          end
      end
    end

    --debug down
    end,
      function(e)
        print("-------------Error-------------")
        print(e)
        Server:UploadErrorLog(e)
    end)        
    --debug down

end


function PvpModule:CheckTeamAllDead(nTeamID)
    
    local bResult= true;

    for i=1,PlayerResource:GetPlayerCountForTeam(nTeamID) do
      local nPlayerID = PlayerResource:GetNthPlayerIDOnTeam(nTeamID, i)
      local hHero =  PlayerResource:GetSelectedHeroEntity(nPlayerID)
      if hHero and (hHero:IsAlive() or hHero:IsReincarnating()) then
         bResult= false
      end
    end

    return bResult

end


--结束PVP对战
function PvpModule:EndPvp(nWinnerTeamID,nLoserTeamID)
     
     --PVP只结算一次 但是先把英雄拉起来 否则英雄有可能会暴毙
     PvpModule:RefreshHero(nWinnerTeamID)
     PvpModule:RefreshHero(nLoserTeamID)

     if PvpModule.bEnd then
       return
     end
     
     --延迟5秒，击杀召唤生物
     Summon:KillSummonedCreatureAsyn(PvpModule.vHomeCenter)

     PvpModule:CompensatePlayerExp(nWinnerTeamID)
     PvpModule:CompensatePlayerExp(nLoserTeamID)

     PvpModule.bEnd = true


     PvpModule:PlayWinnerTeamEffect(nWinnerTeamID)

     --如果开局5人以上,目前场上人数小于三人, 对失败者进行处罚
     Timers:CreateTimer({ endTime = 1, 
        callback = function()
            if GetMapName()=="1x8" then
              if  GameMode.nRank and GameMode.nRank <= 3 and ( GameMode.nValidTeamNumber >=5 or IsInToolsMode() ) then
                PvpModule:PunishLoser(nWinnerTeamID,nLoserTeamID)
              end
            end

            if GetMapName()=="2x6" then
              if  GameMode.nRank and GameMode.nRank <= 2 and ( GameMode.nValidTeamNumber >=4 or IsInToolsMode() ) then
                PvpModule:PunishLoser(nWinnerTeamID,nLoserTeamID)
              end
            end
        end
     })

     -- 发押注奖励
     for _,data in ipairs(PvpModule.betMap[nWinnerTeamID]) do
        
        if data and data.nPlayerId  and data.flRatio then
            local nPlayerId = data.nPlayerId
            local flRatio = data.flRatio

            local nBonusGold = math.floor(PvpModule.nBetBonus * flRatio)

            local barrageData={}
            barrageData.type = "bet_win"
            
            --如果是PVP的免费押注
            if data.sType and "pvp_free"==data.sType then
               if flRatio>=0.99 then 
                  barrageData.type = "bet_jackpot"
               else
                  --胜者奖励与押注奖励一起发
                  barrageData.type = "pvp_win"
                  nBonusGold = nBonusGold + math.floor(PvpModule.nBetBonus*0.15)
               end
               PvpModule:RewardWinnerBonus(nPlayerId,nBonusGold)
            else
               PvpModule:RewardBetBonus(nPlayerId,nBonusGold)
            end

            barrageData.playerId = nPlayerId
            barrageData.gold_value = nBonusGold
            Barrage:FireBullet(barrageData)

            --统计玩家的通过下注获得总金币数量
            PvpModule:SumBetReward(nPlayerId,nBonusGold)

        end
     end

     --获胜消息告知前台
     CustomGameEventManager:Send_ServerToAllClients("TeamWin",{winnerTeamID=nWinnerTeamID,loserTeamID=nLoserTeamID} );

     PvpModule:RecordWinner(nWinnerTeamID)
     PvpModule:RecordLoser(nLoserTeamID)

end


-- 游戏后期惩罚败者
function PvpModule:PunishLoser(nWinnerTeamID,nLoserTeamID)
    
    local nWinnerPlayerID = PlayerResource:GetNthPlayerIDOnTeam(nWinnerTeamID, RandomInt(1, PlayerResource:GetPlayerCountForTeam(nWinnerTeamID)))
    --随机选一个胜利英雄
    local hWinnerHero = PlayerResource:GetSelectedHeroEntity(nWinnerPlayerID)
    --遍历败者队伍
    for i=1,PlayerResource:GetPlayerCountForTeam(nLoserTeamID) do

        local nLoserPlayerID = PlayerResource:GetNthPlayerIDOnTeam(nLoserTeamID, i)
        local hLoserHero = PlayerResource:GetSelectedHeroEntity(nLoserPlayerID)
        if hLoserHero  then
        
           if hWinnerHero then
            local nParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, hLoserHero)
            ParticleManager:SetParticleControlEnt(nParticle, 0, hWinnerHero, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", hWinnerHero:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(nParticle, 1, hLoserHero, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", hLoserHero:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(nParticle)
           end

           local hAegis = hLoserHero:FindModifierByName("modifier_aegis")
           if hAegis then
              local data={}
              data.type = "pvp_lose_aegis"
              data.playerId = nLoserPlayerID
              Barrage:FireBullet(data)
              local nCount = hAegis:GetStackCount()
              if nCount >= 2 then
                 hAegis:SetStackCount(nCount-1)
              else
                 hAegis:Destroy()
              end
           else
              local data={}
              data.type = "pvp_stack_curse"
              data.playerId = nLoserPlayerID
              Barrage:FireBullet(data)
              local hDebuff = hLoserHero:FindModifierByName("modifier_loser_curse")
              if hDebuff == nil then
                    hDebuff = hLoserHero:AddNewModifier(hLoserHero, hLoserHero, "modifier_loser_curse", {})
                    if hDebuff ~= nil then
                        hDebuff:SetStackCount(0)
                    end
              end
              if hDebuff ~= nil then
                 hDebuff:SetStackCount(hDebuff:GetStackCount() + 1)
              end
           end
        end 
    end
end



--重置参加PVP活动的英雄
function PvpModule:RefreshHero(nTeamID)
   
    for i=1,PlayerResource:GetPlayerCountForTeam(nTeamID) do
      local nPlayerID = PlayerResource:GetNthPlayerIDOnTeam(nTeamID, i)
      local hHero =  PlayerResource:GetSelectedHeroEntity(nPlayerID)
      if hHero and (not hHero:IsNull()) then
          if not hHero:IsAlive() then
               --阵亡
               Timers:CreateTimer({ endTime = 0.3, 
                  callback = function()
                    hHero:RespawnHero(false, false)
                    Util:RefreshAbilityAndItem( hHero )
                    Util:MoveHeroToCenter( nPlayerID )
                    hHero:AddNewModifier(hHero, nil, "modifier_hero_refreshing", {})
                    --解除参与PVP状态
                    hHero.bJoiningPvp = false
                  end
               })
          else
               Util:RefreshAbilityAndItem( hHero )
               hHero:SetHealth(hHero:GetMaxHealth())
               hHero:SetMana(hHero:GetMaxMana())
               Timers:CreateTimer({ endTime = 0.6, 
                  callback = function()
                    Util:MoveHeroToCenter(nPlayerID)
                    hHero:AddNewModifier(hHero, nil, "modifier_hero_refreshing", {})
                    --解除参与PVP状态
                    hHero.bJoiningPvp = false
                  end
               })
          end
      end
    end
end


--补偿PVP玩家经验
function PvpModule:CompensatePlayerExp(nTeamID)
    for i=1,PlayerResource:GetPlayerCountForTeam(nTeamID) do
      local nPlayerID = PlayerResource:GetNthPlayerIDOnTeam(nTeamID, i)
      local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
      if hHero then
        local nRoundNumber = PvpModule.nLastPvpRound
        if nRoundNumber and GameRules.xpTable[nRoundNumber+1] and GameRules.xpTable[nRoundNumber] then
          local nExp = math.floor( (GameRules.xpTable[nRoundNumber+1] -GameRules.xpTable[nRoundNumber]) *0.7)
          hHero:AddExperience(nExp, 0, false, false)
        end
      end
    end
end


-- 发获胜奖励
function PvpModule:RewardWinnerBonus(nPlayerId,nBonusGold)

     local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerId)
     local nTotalWave = math.ceil(nBonusGold/66)
     local nGoldPerWave = math.ceil(nBonusGold/nTotalWave)

     local nParticle1 = ParticleManager:CreateParticle("particles/econ/events/ti6/teleport_start_ti6.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, hHero)
     ParticleManager:SetParticleControlEnt(nParticle1, 0, hHero, PATTACH_POINT_FOLLOW, "attach_hitloc", hHero:GetOrigin(), true)
     local nParticle2 = ParticleManager:CreateParticle("particles/econ/events/ti6/teleport_start_ti6_lvl3_rays.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, hHero)
     ParticleManager:SetParticleControlEnt(nParticle2, 0, hHero, PATTACH_POINT_FOLLOW, "attach_hitloc", hHero:GetOrigin(), true)
     local nWave=0

     Timers:CreateTimer(function()
         SendOverheadEventMessage(hHero, OVERHEAD_ALERT_GOLD, hHero, nGoldPerWave, nil)
         PlayerResource:ModifyGold(nPlayerId,nGoldPerWave, true, DOTA_ModifyGold_GameTick)
         GameMode:UpdatePlayerGold(nPlayerId)
         nWave = nWave + 1
         if nWave == nTotalWave then
             ParticleManager:DestroyParticle(nParticle1, false)
             ParticleManager:DestroyParticle(nParticle2, false)
             ParticleManager:ReleaseParticleIndex(nParticle1)
             ParticleManager:ReleaseParticleIndex(nParticle2)
            return nil
         else
            return 0.15
         end
     end)

end



-- 发菠菜奖励
function PvpModule:RewardBetBonus(nPlayerId,nBonusGold)

     local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerId)
     local nTotalWave = math.ceil(nBonusGold/66)
     local nGoldPerWave = math.ceil(nBonusGold/nTotalWave)


     local nWave=0

     Timers:CreateTimer(function()
         SendOverheadEventMessage(hHero, OVERHEAD_ALERT_GOLD, hHero, nGoldPerWave, nil)
         PlayerResource:ModifyGold(nPlayerId,nGoldPerWave, true, DOTA_ModifyGold_GameTick)
         GameMode:UpdatePlayerGold(nPlayerId)
         --每15轮 展示一次特效
         if math.mod(nWave,15)==0 then
            local nParticle = ParticleManager:CreateParticle("particles/econ/items/ogre_magi/ogre_magi_jackpot/ogre_magi_jackpot_spindle_rig.vpcf", PATTACH_OVERHEAD_FOLLOW, hHero)
            ParticleManager:ReleaseParticleIndex(nParticle)
         end
         nWave=nWave+1
         if nWave == nTotalWave then
            return nil
         else
            return 0.15
         end
     end)

end

--确认演员
function PvpModule:ConfirmActor(keys)

    --校验数据
    local nPlayerID = keys.player_id;
    local nTargetPlayerID = keys.target_player_id
    --[[
    if nPlayerID == nTargetPlayerID then
       print("Can't make self, return..")
       return 
    end
    ]]
    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)

    if hHero:IsNull() then
        return
    end

    if hHero.sActorUISecret~=keys.actor_ui_secret then
        return
    end

    if GameMode.reportActorTime[tonumber(nPlayerID)] and GameMode.reportActorTime[tonumber(nPlayerID)]>0 then
        
        --弹幕
        local data={}
        data.type = "report_actor"
        data.playerId = nTargetPlayerID
        Barrage:FireBullet(data)

        Server:ReportActor(nTargetPlayerID)
        GameMode.reportActorTime[tonumber(nPlayerID)] = GameMode.reportActorTime[tonumber(nPlayerID)] -1
    else
        print("No actor report time left, return..")
        return
    end
end


--为胜利队伍播放特效
function PvpModule:PlayWinnerTeamEffect(nWinnerTeamId)
    
  for i=1,PlayerResource:GetPlayerCountForTeam(nWinnerTeamId) do

     local nWinnerPlayerID = PlayerResource:GetNthPlayerIDOnTeam(nWinnerTeamId, i)
     local hWinnerHero = PlayerResource:GetSelectedHeroEntity(nWinnerPlayerID)
     if hWinnerHero then
         local nWinnerParticleIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, hWinnerHero)
         ParticleManager:ReleaseParticleIndex(nWinnerParticleIndex)
         
         --如果有饰品用饰品声音 没有的话用军团的胜利声音
         Econ:PlayKillSound(hWinnerHero)
         Econ:PlayKillEffect(hWinnerHero)
         
         Timers:CreateTimer({ endTime = 2, 
            callback = function()
                if PvpModule.winnerSoundMap[hWinnerHero:GetUnitName()]~=nil then
                  EmitGlobalSound(PvpModule.winnerSoundMap[hWinnerHero:GetUnitName()])
               end
            end
         })
     end
  end
end


 -- 更新PVP 胜负纪录
function PvpModule:RecordWinner(nWinnerTeamID)
    
  for i=1,PlayerResource:GetPlayerCountForTeam(nWinnerTeamID) do
     local nWinnerPlayerID = PlayerResource:GetNthPlayerIDOnTeam(nWinnerTeamID, i)
     local winnerRecord = CustomNetTables:GetTableValue("pvp_record", tostring(nWinnerPlayerID))
     if winnerRecord and winnerRecord.win then
       winnerRecord.win = winnerRecord.win +1
       CustomNetTables:SetTableValue("pvp_record", tostring(nWinnerPlayerID),winnerRecord)
     end
  end

end

function PvpModule:RecordLoser(nLoserTeamID)
    
  for i=1,PlayerResource:GetPlayerCountForTeam(nLoserTeamID) do
     local nLoserPlayerID = PlayerResource:GetNthPlayerIDOnTeam(nLoserTeamID, i)
     local loserRecord = CustomNetTables:GetTableValue("pvp_record", tostring(nLoserPlayerID))
     if loserRecord and loserRecord.lose then
       loserRecord.lose = loserRecord.lose +1
       CustomNetTables:SetTableValue("pvp_record", tostring(nLoserPlayerID),loserRecord)
     end
  end

end


function PvpModule:SumBetReward(nPlayerID,nValue)
     
     local record = CustomNetTables:GetTableValue("pvp_record", tostring(nPlayerID))
     if record and record.total_bet_reward then
       record.total_bet_reward = record.total_bet_reward +nValue
       CustomNetTables:SetTableValue("pvp_record", tostring(nPlayerID),record)
     end

end
