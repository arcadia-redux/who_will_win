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
  PvpModule.singlePlayerPvpPairs={}

  -- PVP 间隔
  PvpModule.nInterval = 1
  
  PvpModule.currentPair = {}
  PvpModule.currentSinglePair = {}

  --- 进行过PVP活动的关卡编号
  --- 从第2关开始PVP 活动
  PvpModule.nLastPvpRound = 1

  --ToolMode 提早开始PVP
  if IsInToolsMode() then
    PvpModule.nLastPvpRound = 5
  end

  --统计玩家的下注金额的总量
  PvpModule.betValueSum ={}

  for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
      PvpModule.betValueSum[nPlayerID] = 0
  end

  PvpModule.nBetBonus = 150

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
       nBonusRatio = 1.4
    end

    PvpModule.nBetBonus = (nBaseBonus + 142 * nAliveTeamNumber*nBonusRatio) * math.pow(1.024, (nRoundNumber-1))

    --key 被下注的玩家id    value下注玩家的数据list 
    PvpModule.betMap = {}

    PvpModule.nLastPvpRound = nRoundNumber

    PvpModule:CalculatePvpInterval()
    
    -- 如果是5v5 不是整数轮次
    if GetMapName()=="5v5" and nRoundNumber%6~=0 then
        PvpModule:PrepareSinglePvp() 
    else
       PvpModule:PrepareTeamPvp()
    end
end



--进行队伍PVP
function PvpModule:PrepareTeamPvp()

     --如果PVP配对已经用完 重新计算
    if #PvpModule.pvpPairs == 0 then
        PvpModule:PairPvp()
        table.insert(PvpModule.allPairLog,"Pair Pvp")
    end

    if #PvpModule.pvpPairs > 0 then
        local pair = PvpModule:ChooseOnePair()
        --校验数据
        if pair and pair.nFirstTeamId~=nil and pair.nSecondeTeamId~=nil then
            
            --PVP是否结束(确认进行PVP)
            PvpModule.bEnd=false
            --是否已买定离手
            PvpModule.bLeaveHand = false

            --设置两个队列
            PvpModule.betMap[pair.nFirstTeamId]={}
            PvpModule.betMap[pair.nSecondeTeamId]={} 
                        
            PvpModule.currentPair = {}
            table.insert(PvpModule.currentPair, pair.nFirstTeamId)
            table.insert(PvpModule.currentPair, pair.nSecondeTeamId)
            
            if PvpModule.lastPair then
               PvpModule.secondLastPair = PvpModule.lastPair
            end

            --纪录最近一次PVP玩家
            PvpModule.lastPair = {}
            PvpModule.lastPair.nFirstTeamId = pair.nFirstTeamId
            PvpModule.lastPair.nSecondeTeamId = pair.nSecondeTeamId

            table.insert(PvpModule.allPairLog,PvpModule.currentPair)
            print("-------------------------------")
            PrintTable(PvpModule.allPairLog)
            
            local nRandomIndex = RandomInt(1,2)

            if nRandomIndex==1 then
               PvpModule.nHomeTeamID = pair.nFirstTeamId
            end
            if nRandomIndex==2 then
               PvpModule.nHomeTeamID = pair.nSecondeTeamId
            end

            -- 主场玩家位置 
            PvpModule.vHomeCenter = GameMode.vTeamLocationMap[PvpModule.nHomeTeamID]

            --延迟5秒，击杀PVP主场区域附近的召唤物
            Summon:KillSummonedCreatureAsyn(PvpModule.vHomeCenter)
            
            local dataList={}
            for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
              if PlayerResource:GetTeam( nPlayerID ) == pair.nFirstTeamId or PlayerResource:GetTeam( nPlayerID )==pair.nSecondeTeamId then
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
                      CustomGameEventManager:Send_ServerToPlayer(hPlayer,"ShowPvpBet",{players=dataList,firstTeamId=pair.nFirstTeamId,secondTeamId=pair.nSecondeTeamId,bet_ui_secret=hHero.sBetUISecret,security_key=Security:GetSecurityKey(nPlayerID)} )   
                    end
                end
              end
            end
        end
    end
end





--进行单个玩家PVP
function PvpModule:PrepareSinglePvp()

    if #PvpModule.singlePlayerPvpPairs == 0 then
        PvpModule:PairSinglePlayer()
    end

    if #PvpModule.singlePlayerPvpPairs > 0 then
        local pair = PvpModule:ChooseOneSinglePair()
        --校验数据
        if pair and pair.nFirstPlayerId~=nil and pair.nSecondePlayerId~=nil then
            
            --PVP是否结束(确认进行PVP)
            PvpModule.bEnd=false

             --5v5不允许自由下注
            PvpModule.bLeaveHand = true

            --设置两个下注队列
            PvpModule.betMap[PlayerResource:GetTeam(pair.nFirstPlayerId)]={}
            PvpModule.betMap[PlayerResource:GetTeam(pair.nSecondePlayerId)]={} 

            PvpModule.currentSinglePair = {}
            table.insert(PvpModule.currentSinglePair, pair.nFirstPlayerId)
            table.insert(PvpModule.currentSinglePair, pair.nSecondePlayerId)
            
            if PvpModule.lastSinglePair then
               PvpModule.secondLastSinglePair = PvpModule.lastSinglePair
            end

            --纪录最近一次PVP玩家
            PvpModule.lastSinglePair = {}
            PvpModule.lastSinglePair.nFirstPlayerId = pair.nFirstPlayerId
            PvpModule.lastSinglePair.nSecondePlayerId = pair.nSecondePlayerId
         
            local wayPoint = Entities:FindByName(nil, "center_single_pvp")
            Summon:KillSummonedCreatureAsyn(wayPoint:GetOrigin())
          
            local dataList={}

            local firstData = {}
            firstData.playerID = pair.nFirstPlayerId
            firstData.teamID = PlayerResource:GetTeam( pair.nFirstPlayerId )
            table.insert(dataList, firstData)
            
            local secondData = {}
            secondData.playerID = pair.nSecondePlayerId
            secondData.teamID = PlayerResource:GetTeam( pair.nSecondePlayerId )
            table.insert(dataList, secondData)

            --为玩家弹出PVP下注框
            for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
              if PlayerResource:IsValidPlayer(nPlayerID) and ( IsInToolsMode() or PlayerResource:GetConnectionState(nPlayerID) == DOTA_CONNECTION_STATE_CONNECTED)  then                      
                if GameMode.vAliveTeam[PlayerResource:GetTeam( nPlayerID )] then
                    local hPlayer = PlayerResource:GetPlayer(nPlayerID)
                    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
                    if hPlayer and hHero then
                      hHero.sBetUISecret = CreateSecretKey()
                      CustomGameEventManager:Send_ServerToPlayer(hPlayer,"ShowPvpBet",{players=dataList,firstTeamId=PlayerResource:GetTeam(pair.nFirstPlayerId) ,secondTeamId=PlayerResource:GetTeam(pair.nSecondePlayerId),bet_ui_secret=hHero.sBetUISecret,security_key=Security:GetSecurityKey(nPlayerID)} )   
                    end
                end
              end
            end
        end
    end
end




--计算PVP间隔
function PvpModule:CalculatePvpInterval()

  -- 5v5每轮PK
  if GetMapName()=="5v5" then
     PvpModule.nInterval = 1
     return 
  end
  
   -- 有效队伍列表(剔除断线玩家)
  local pvpValideTeamMap = {}
  local nValideTeam = 0
  local pvpValideTeamList ={}

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

  if nValideTeam==3 or nValideTeam==4 or nValideTeam==5  then
      PvpModule.nInterval = 2
  end

  if nValideTeam==2 then
      PvpModule.nInterval = 3
  end
  
  --[[
  if nValideTeam>2 and IsInToolsMode() then
      PvpModule.nInterval = 1
  end
   ]]
end




--计算PVP配对

function PvpModule:PairPvp()

	 PvpModule.pvpPairs={}

    -- 有效队伍列表(剔除断线玩家)
    local pvpValideTeamMap = {}
    local nValideTeam = 0
    local pvpValideTeamList ={}

    --整理有效队伍
    for nTeamNumber,bAlive in pairs(GameMode.vAliveTeam) do
      if bAlive then
          for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
            --放弃比赛的玩家不参与PVP
            if PlayerResource:IsValidPlayer(nPlayerID) and ( IsInToolsMode() or PlayerResource:GetConnectionState(nPlayerID) ~= DOTA_CONNECTION_STATE_ABANDONED)  then
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
    
    --2x6 模式 1队剩余
    if nValideTeam==1 then
        print("Only One PVP team, return...")
        return 
    end

    --配对
    for _,nTeamNumber in ipairs(pvpValideTeamList) do
      for _,nEnemyTeamNumber in ipairs(pvpValideTeamList) do
         if nEnemyTeamNumber<nTeamNumber then
           local pair = {}
           pair.nFirstTeamId = nTeamNumber
           pair.nSecondeTeamId = nEnemyTeamNumber
           --这pair中的队伍参与PVP的总次数
           pair.nTeamJoinTimes = 0
           table.insert(PvpModule.pvpPairs,pair)
         end 
      end
    end

end

-- 从队列里面挑选一个配对
function PvpModule:ChooseOnePair()
    
    --先洗牌
    PvpModule.pvpPairs=table.shuffle(PvpModule.pvpPairs)

    --计算分数
    for _,pair in ipairs(PvpModule.pvpPairs) do
        pair.nScore =pair.nTeamJoinTimes
        
        -- 如果上轮打过了，分数加1 
        if PvpModule.lastPair then
          if pair.nFirstTeamId == PvpModule.lastPair.nFirstTeamId or
             pair.nFirstTeamId == PvpModule.lastPair.nSecondeTeamId then
             pair.nScore = pair.nScore + 1
          end
          if pair.nSecondeTeamId == PvpModule.lastPair.nFirstTeamId or
             pair.nSecondeTeamId == PvpModule.lastPair.nSecondeTeamId then
             pair.nScore = pair.nScore + 1
          end
        end

        -- 如果上上轮打过了，分数加0.1
        if PvpModule.secondLastPair then
          if pair.nFirstTeamId == PvpModule.secondLastPair.nFirstTeamId or
             pair.nFirstTeamId == PvpModule.secondLastPair.nSecondeTeamId then
             pair.nScore = pair.nScore + 0.1
          end
          if pair.nSecondeTeamId == PvpModule.secondLastPair.nFirstTeamId or
             pair.nSecondeTeamId == PvpModule.secondLastPair.nSecondeTeamId then
             pair.nScore = pair.nScore + 0.1
          end
        end
    end
    
    --挑选分数最低的配对
    table.sort(PvpModule.pvpPairs,function(a, b) return a.nScore < b.nScore end)
    
    local result = PvpModule.pvpPairs[1]
    table.remove(PvpModule.pvpPairs, 1)
    
    --计数
    for i=1,#PvpModule.pvpPairs do
       if PvpModule.pvpPairs[i] then
          if PvpModule.pvpPairs[i].nFirstTeamId==result.nFirstTeamId or PvpModule.pvpPairs[i].nSecondeTeamId==result.nFirstTeamId then
             PvpModule.pvpPairs[i].nTeamJoinTimes = PvpModule.pvpPairs[i].nTeamJoinTimes + 1              
          end
          if PvpModule.pvpPairs[i].nFirstTeamId==result.nSecondeTeamId or PvpModule.pvpPairs[i].nSecondeTeamId==result.nSecondeTeamId then
             PvpModule.pvpPairs[i].nTeamJoinTimes = PvpModule.pvpPairs[i].nTeamJoinTimes + 1            
          end
       end
    end

    return result
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

    if GetMapName()=="5v5" then
       print("5v5 Can't Bet")
       return
    end

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

    --不能给自己下注
    if keys.wish_team_id == PlayerResource:GetTeam(nPlayerId) then
       print("Can't bet on self")
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
       
       --处理免费下注
       --5v5只有免费下注
       for _,nPlayerID in ipairs(GameMode.vTeamPlayerMap[nTeamID]) do
           local data = {}
           local flPvpBetRatio = 0.05
           -- 2人模式减半
           if GetMapName()=="2x6" then
              flPvpBetRatio = 0.02
           end

           -- 5v5只有免费下注
           if GetMapName()=="5v5" then
              flPvpBetRatio = 0.08
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
      local  nKilledPlayerID = hKilledUnit:GetPlayerOwnerID();
      local  nKilledTeamID = PlayerResource:GetTeam(nKilledPlayerID);

      --如果是5v5中 单玩家决斗战败
      for i,nPlayerID in ipairs(PvpModule.currentSinglePair) do
          if nKilledPlayerID == nPlayerID then
              local nLoserId = nKilledPlayerID
              local nWinnerId =  PvpModule.currentSinglePair[3-i]
              PvpModule:EndSinglePvp(nWinnerId,nLoserId);
          end
      end
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
     PvpModule:RefreshTeamHero(nWinnerTeamID)
     PvpModule:RefreshTeamHero(nLoserTeamID)

     if PvpModule.bEnd then
       return
     end
     
     --延迟5秒，击杀召唤生物
     Summon:KillSummonedCreatureAsyn(PvpModule.vHomeCenter)

     PvpModule:CompensateTeamExp(nWinnerTeamID)
     PvpModule:CompensateTeamExp(nLoserTeamID)

     PvpModule.bEnd = true


     PvpModule:PlayWinnerTeamEffect(nWinnerTeamID)

     Timers:CreateTimer({ endTime = 1, 
        callback = function()
            --如果开局5人以上,目前场上人数小于三人, 对失败者进行处罚
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
            -- 5v5团战惩罚
            if GetMapName()=="5v5" then           
               PvpModule:PunishLoser(nWinnerTeamID,nLoserTeamID)
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


--结束PVP对战
function PvpModule:EndSinglePvp(nWinnerID,nLoserID)
     
     if PvpModule.bEnd then
       return
     end

     PvpModule:RefreshSingleHero(nWinnerID)
     PvpModule:RefreshSingleHero(nLoserID)
     
     local nWinnerTeamID= PlayerResource:GetTeam(nWinnerID)
     local nLoserTeamID= PlayerResource:GetTeam(nLoserID)

     PvpModule:CompensatePlayerExp(nWinnerID)
     PvpModule:CompensatePlayerExp(nLoserID)

     PvpModule.bEnd = true

     PvpModule:PlayWinnerHeroEffect(nWinnerID)
 
     --发奖励
     --5v5只有免费下注
     for _,data in ipairs(PvpModule.betMap[nWinnerTeamID]) do
        
        if data and data.nPlayerId  and data.flRatio then
            local nPlayerId = data.nPlayerId
            local flRatio = data.flRatio

            local nBonusGold = math.floor(PvpModule.nBetBonus * flRatio)

            local barrageData={}
            barrageData.type = "pvp_win"
            barrageData.gold_value = nBonusGold
            barrageData.playerId = nPlayerId
            Barrage:FireBullet(barrageData)

            PvpModule:RewardWinnerBonus(nPlayerId,nBonusGold)
            
            --统计玩家的通过下注获得总金币数量
            PvpModule:SumBetReward(nPlayerId,nBonusGold)

        end
     end

     --获胜消息告知前台
     CustomGameEventManager:Send_ServerToAllClients("TeamWin",{winnerTeamID=nWinnerTeamID,loserTeamID=nLoserTeamID} );
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
function PvpModule:RefreshTeamHero(nTeamID)
   
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
               --胜利者提前加上无敌 防止飞尸
               hHero:AddNewModifier(hHero, nil, "modifier_hero_refreshing", {})
               Timers:CreateTimer({ endTime = 0.6, 
                  callback = function()
                    Util:MoveHeroToCenter(nPlayerID)
                    --hHero:AddNewModifier(hHero, nil, "modifier_hero_refreshing", {})
                    --解除参与PVP状态
                    hHero.bJoiningPvp = false
                  end
               })
          end
      end
    end
end

--重置单个英雄
function PvpModule:RefreshSingleHero(nPlayerID)
    
    local hHero =  PlayerResource:GetSelectedHeroEntity(nPlayerID)
    if hHero and (not hHero:IsNull()) then
        if not hHero:IsAlive() then
             --阵亡
             Timers:CreateTimer({ endTime = 0.3, 
                callback = function()
                  hHero:RespawnHero(false, false)
                  Util:RefreshAbilityAndItem( hHero )
                  
                  local nTeamNumber = hHero:GetTeam()
                  --如果PVE没结束，传送过去参加PVE
                  if nTeamNumber and GameMode.currentRound and  GameMode.currentRound.spanwers and GameMode.currentRound.spanwers[nTeamNumber] and GameMode.currentRound.spanwers[nTeamNumber].bProgressFinished==false then                   
                    local wayPoint = Entities:FindByName(nil, "center_"..nTeamNumber)
                    Util:MoveHeroToLocation( nPlayerID,wayPoint:GetOrigin() )
                  else
                     hHero:AddNewModifier(hHero, nil, "modifier_hero_refreshing", {})
                     Util:MoveHeroToCenter( nPlayerID )
                  end  
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
                  --如果PVE没结束，传送过去参加PVE
                  local nTeamNumber = hHero:GetTeam()
                  if nTeamNumber and GameMode.currentRound and  GameMode.currentRound.spanwers and GameMode.currentRound.spanwers[nTeamNumber] and GameMode.currentRound.spanwers[nTeamNumber].bProgressFinished==false then                    
                    local wayPoint = Entities:FindByName(nil, "center_"..nTeamNumber)
                    Util:MoveHeroToLocation( nPlayerID,wayPoint:GetOrigin() )
                  else
                    hHero:AddNewModifier(hHero, nil, "modifier_hero_refreshing", {})
                    Util:MoveHeroToCenter( nPlayerID )
                  end

                  hHero.bJoiningPvp = false
                end
             })
        end
    end
end




--补偿PVP玩家经验
function PvpModule:CompensateTeamExp(nTeamID)
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


function PvpModule:CompensatePlayerExp(nPlayerID)
    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
    if hHero then
      local nRoundNumber = PvpModule.nLastPvpRound
      if nRoundNumber and GameRules.xpTable[nRoundNumber+1] and GameRules.xpTable[nRoundNumber] then
        local nExp = math.floor( (GameRules.xpTable[nRoundNumber+1] -GameRules.xpTable[nRoundNumber]) *0.7)
        hHero:AddExperience(nExp, 0, false, false)
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


--为胜利队伍播放特效
function PvpModule:PlayWinnerHeroEffect(nWinnerPlayerID)
    
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



--5v5模式中计算单个玩家的配对
function PvpModule:PairSinglePlayer()

    PvpModule.singlePlayerPvpPairs={}

    local nValidePlayer = 0
    local pvpValidePlayerList ={}

    --整理有效队伍
    for nTeamNumber,bAlive in pairs(GameMode.vAliveTeam) do
      if bAlive then
          for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
            --放弃比赛的玩家不参与
            if PlayerResource:IsValidPlayer(nPlayerID) and ( IsInToolsMode() or PlayerResource:GetConnectionState(nPlayerID) ~= DOTA_CONNECTION_STATE_ABANDONED)  then
                if PlayerResource:GetTeam( nPlayerID ) == nTeamNumber then                  
                    table.insert(pvpValidePlayerList, nPlayerID)
                    nValidePlayer = nValidePlayer + 1
                end
            end
          end
       end
    end

    --配对
    for _,nPlayerID in ipairs(pvpValidePlayerList) do
      for _,nEnemyPlayerID in ipairs(pvpValidePlayerList) do
         if nEnemyPlayerID<nPlayerID  and PlayerResource:GetTeam(nEnemyPlayerID)~=PlayerResource:GetTeam(nPlayerID) then
           local pair = {}
           pair.nFirstPlayerId = nPlayerID
           pair.nSecondePlayerId = nEnemyPlayerID
           --这pair中的玩家参与PVP的总次数
           pair.nJoinTimes = 0
           table.insert(PvpModule.singlePlayerPvpPairs,pair)
         end 
      end
    end

end


-- 从队列里面挑选一个配对
function PvpModule:ChooseOneSinglePair()
    
    --先洗牌
    PvpModule.singlePlayerPvpPairs=table.shuffle(PvpModule.singlePlayerPvpPairs)

    --计算分数
    for _,pair in ipairs(PvpModule.singlePlayerPvpPairs) do
        pair.nScore =pair.nJoinTimes
        
        -- 如果上轮打过了，分数加1 
        if PvpModule.lastSinglePair then
          if pair.nFirstPlayerId == PvpModule.lastSinglePair.nFirstPlayerId or
             pair.nFirstPlayerId == PvpModule.lastSinglePair.nSecondePlayerId then
             pair.nScore = pair.nScore + 1
          end
          if pair.nSecondePlayerId == PvpModule.lastSinglePair.nFirstPlayerId or
             pair.nSecondePlayerId == PvpModule.lastSinglePair.nSecondePlayerId then
             pair.nScore = pair.nScore + 1
          end
        end

        -- 如果上上轮打过了，分数加0.1
        if PvpModule.secondLastSinglePair then
          if pair.nFirstPlayerId == PvpModule.secondLastSinglePair.nFirstPlayerId or
             pair.nFirstPlayerId == PvpModule.secondLastSinglePair.nSecondePlayerId then
             pair.nScore = pair.nScore + 0.1
          end
          if pair.nSecondePlayerId == PvpModule.secondLastSinglePair.nFirstPlayerId or
             pair.nSecondePlayerId == PvpModule.secondLastSinglePair.nSecondePlayerId then
             pair.nScore = pair.nScore + 0.1
          end
        end
    end
    
    --挑选分数最低的配对
    table.sort(PvpModule.singlePlayerPvpPairs,function(a, b) return a.nScore < b.nScore end)
    
    local result = PvpModule.singlePlayerPvpPairs[1]
    table.remove(PvpModule.singlePlayerPvpPairs, 1)
    
    --计数
    for i=1,#PvpModule.singlePlayerPvpPairs do
       if PvpModule.singlePlayerPvpPairs[i] then
          if PvpModule.singlePlayerPvpPairs[i].nFirstPlayerId==result.nFirstPlayerId or PvpModule.singlePlayerPvpPairs[i].nSecondePlayerId==result.nFirstPlayerId then
             PvpModule.singlePlayerPvpPairs[i].nJoinTimes = PvpModule.singlePlayerPvpPairs[i].nJoinTimes + 1              
          end
          if PvpModule.singlePlayerPvpPairs[i].nFirstPlayerId==result.nSecondePlayerId or PvpModule.singlePlayerPvpPairs[i].nSecondePlayerId==result.nSecondePlayerId then
             PvpModule.singlePlayerPvpPairs[i].nJoinTimes = PvpModule.singlePlayerPvpPairs[i].nJoinTimes + 1            
          end
       end
    end

    return result
end
