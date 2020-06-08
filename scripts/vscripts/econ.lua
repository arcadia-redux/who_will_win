if Econ == nil then Econ = class({}) end

Econ.vParticleMap ={

    green={"particles/econ/courier/courier_greevil_green/courier_greevil_green_ambient_3.vpcf"},
    lava_trail={"particles/econ/courier/courier_trail_lava/courier_trail_lava.vpcf"},
    paltinum_baby_roshan={"particles/econ/paltinum_baby_roshan/paltinum_baby_roshan.vpcf"},
    legion_wings={"particles/econ/legion_wings/legion_wings.vpcf"},
    legion_wings_vip={"particles/econ/legion_wings/legion_wings_vip.vpcf"},
    legion_wings_pink={"particles/econ/legion_wings/legion_wings_pink.vpcf"},
    darkmoon={"particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon.vpcf"},
    ethereal_flame_white={"particles/econ/ethereal_flame.vpcf"},
    ethereal_flame_golden={"particles/econ/ethereal_flame.vpcf"},
    ethereal_flame_pink={"particles/econ/ethereal_flame.vpcf"},
    sakura_trail={"particles/econ/courier/courier_axolotl_ambient/courier_axolotl_ambient.vpcf","particles/econ/sakura_trail.vpcf"},
    golden_ti7={"particles/econ/golden_ti7.vpcf"},
    rich={"particles/econ/rich.vpcf"},
    water_curtain={"particles/econ/items/necrolyte/necro_ti9_immortal/necro_ti9_immortal_ambient.vpcf"},
    --替换成戴泽金色薄葬
    rainbow_tail={"particles/econ/items/dazzle/dazzle_ti6_gold/dazzle_ti6_shallow_grave_gold_ground_ray.vpcf","particles/econ/items/dazzle/dazzle_ti6_gold/dazzle_ti6_shallow_grave_gold_ground_ring.vpcf","particles/econ/items/dazzle/dazzle_ti6_gold/dazzle_ti6_shallow_grave_gold_ground_steam.vpcf","particles/econ/items/dazzle/dazzle_ti6_gold/dazzle_ti6_shallow_grave_gold_glyph.vpcf"},
    golden_lotus={"particles/econ/events/golden_lotus_effect.vpcf"},
    sand={"particles/econ/courier/courier_roshan_desert_sands/baby_roshan_desert_sands_ambient_flying.vpcf"},
    frost={"particles/econ/courier/courier_roshan_frost/courier_roshan_frost_ambient.vpcf"},
    orbit={"particles/econ/courier/courier_trail_orbit/courier_trail_orbit.vpcf"},
    spark_ti6={"particles/econ/events/ti6/radiance_owner_ti6.vpcf"},
    douyu_1={"particles/econ/douyu_1.vpcf"},
    douyu_2={"particles/econ/douyu_2.vpcf"},
    douyu_3={"particles/econ/douyu_3.vpcf"},
    
    season_2020_3={"effect/ti7_shengwu/ti7.vpcf"},
    legend_three_star_chess={"effect/arrow/5/star3.vpcf"},
    epic_three_star_chess={"effect/arrow/4/star3.vpcf"},
    rare_three_star_chess={"effect/arrow/3/star3.vpcf"},
    nightmare={"effect/emengchanrao/1.vpcf"},
    blood_dance={"effect/xuehuan/xuehuanecon/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_ground_eztzhok.vpcf"},
    radiance={"effect/xiexiaowo_guanjundun/1.vpcf"},
    music={"effect/music/1.vpcf"},
    league_dog_wing={"effect/liansai_dog/1.vpcf"},
    league_dog_ring={"effect/liansai_dog2/1.vpcf"},
    star_fire={"effect/yuhuofenshen/1_2.vpcf"},
    purple_cloud={"effect/zisexingyun_2/ti7secondary.vpcf"},
    jade={"particles/econ/courier/courier_roshan_ti8/courier_roshan_ti8.vpcf"},
    butterfly={"particles/econ/items/natures_prophet/natures_prophet_ti9_immortal/natures_prophet_ti9_wrath_butterflies_start.vpcf"},
    firefly={"particles/econ/items/pangolier/pangolier_ti9_cache/pangolier_ti9_cache_shoulder_ambient.vpcf"},
    shadow_word={"particles/econ/items/warlock/warlock_ti9/warlock_ti9_shadow_word_debuff.vpcf"},
    last_word={"particles/units/heroes/hero_silencer/silencer_last_word_status.vpcf"},  
    repel_buff={"particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8_flash.vpcf","particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8_glyph.vpcf","particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8_swoosh.vpcf","particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8_swoosh_b.vpcf","particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8_rings.vpcf"},  
    out_world={"particles/econ/items/outworld_devourer/od_ti8/od_ti8_ambient.vpcf"},  
    galaxy_core={"particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5_flare_c.vpcf","particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5_ring_spiral.vpcf","particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5_nebula.vpcf","particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5_ember_streak.vpcf","particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5_ember.vpcf","particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5_core_glow.vpcf"},  
    
    douyu_new_1={"particles/econ/dy_new_1.vpcf"},
    douyu_new_2={"particles/econ/dy_new_2.vpcf"},
    douyu_new_3={"particles/econ/dy_new_3.vpcf"},
    season_2020_4={"particles/econ/events/ti8/ti8_hero_effect.vpcf"},
    season_2020_5={"effect/arrow/ssr/star1.vpcf"},
}


Econ.vKillEffectMap ={
    sf_wings="particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_wings.vpcf",
    huaji="particles/econ/kill_mark/huaji.vpcf",
    jibururen_mark="particles/econ/kill_mark/jibururen_mark.vpcf",
    question_mark="particles/econ/kill_mark/question_mark.vpcf",
    --替换成鱼翔拳
    rainbow="particles/econ/items/tuskarr/tusk_ti9_immortal/tusk_ti9_walruspunch_txt_ult.vpcf",
    wudizhansha="particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_counter.vpcf",
    miedi="particles/econ/items/techies/techies_arcana/techies_suicide_kills_arcana.vpcf",
    purple_fireworks="effect/winaround/1/shovel_baby_roshan_spawn.vpcf",
}


Econ.vKillSoundMap ={
    bai_tuo_shei_qu="soundboard.bai_tuo_shei_qu",
    duiyou_ne="soundboard.duiyou_ne",
    ni_qi_bu_qi="soundboard.ni_qi_bu_qi",
    liu_liu_liu="soundboard.liu_liu_liu",
    ta_daaaa="soundboard.ta_daaaa",
    zou_hao_bu_song="soundboard.zou_hao_bu_song",
    zai_jian_le_bao_bei="soundboard.zai_jian_le_bao_bei",
    gan_ma_ne_xiong_di="soundboard.gan_ma_ne_xiong_di",
    lian_dou_xiu_wai_la="soundboard.lian_dou_xiu_wai_la",
    wan_bu_liao_la="soundboard.wan_bu_liao_la",
    gao_fu_shuai="soundboard.gao_fu_shuai",
    piao_liang="soundboard.piao_liang",
    oyoy="soundboard.oy_oy_oy",
    next_level_play="soundboard.next_level",
    ceb="soundboard.ceb.start",
    ding_ding_ding="soundboard.ding_ding",
}

function Econ:Init()

    CustomGameEventManager:RegisterListener("ChangeEquip",function(_, keys)
        self:ChangeEquip(keys)
    end)
    
    CustomGameEventManager:RegisterListener("DrawLottery",function(_, keys)
        self:DrawLottery(keys)
    end)

    CustomGameEventManager:RegisterListener("EconDataRefresh",function(_, keys)
        self:EconDataRefresh(keys)
    end)

    CustomGameEventManager:RegisterListener("SubmitTaobaoCode",function(_, keys)
        self:SubmitTaobaoCode(keys)
    end)

    CustomGameEventManager:RegisterListener("ActiveChatWheel",function(_, keys)
        self:ActiveChatWheel(keys)
    end)

    CustomGameEventManager:RegisterListener("ActiveTaunt",function(_, keys)
        self:ActiveTaunt(keys)
    end)

    Econ.vPlayerData={}

end

function Econ:DrawLottery(keys)

    local nPlayerID = keys.playerId

    Server:DrawLottery(nPlayerID)


end



function Econ:SubmitTaobaoCode(keys)

    Server:SubmitTaobaoCode(keys)

end


function Econ:EconDataRefresh(keys)
    
    PrintTable(keys)
    local nPlayerID = keys.playerId
    local nPlayerSteamId = PlayerResource:GetSteamAccountID(nPlayerID)

    CustomNetTables:SetTableValue("econ_data", "money_"..nPlayerSteamId,{money=keys.moneyValue})
    CustomNetTables:SetTableValue("econ_data", "econ_info_"..nPlayerSteamId,keys)
end




function Econ:ChangeEquip(keys)

    local nPlayerID = keys.playerId

    if Econ.vPlayerData[nPlayerID] ==nil then
       Econ.vPlayerData[nPlayerID] = {}
    end
    
    -- 如果是特效
    if keys.type=="Particle" then

        local vCurrentEconParticleIndexs=Econ.vPlayerData[nPlayerID].vCurrentEconParticleIndexs
        
        if vCurrentEconParticleIndexs then
            for _,nParticleIndex in pairs(vCurrentEconParticleIndexs) do
                ParticleManager:DestroyParticle(nParticleIndex, true)
                ParticleManager:ReleaseParticleIndex(nParticleIndex)
            end
        end

        Econ.vPlayerData[nPlayerID].vCurrentEconParticleIndexs=nil
        Econ.vPlayerData[nPlayerID].sCurrentParticleEconItemName=nil

        if keys.isEquip==1 then           
            self:EquipParticleEcon(keys.itemName,nPlayerID)
        end

    end
    
    --如果是击杀特效
    if keys.type=="KillEffect" then
        Econ.vPlayerData[nPlayerID].sCurrentKillEffect = nil
        Econ.vPlayerData[nPlayerID].sCurrentKillEffectItem = nil
        if keys.isEquip==1 then
           Econ:EquipKillEffectEcon(keys.itemName,nPlayerID)
        end
    end

    --如果是击杀音效
    if keys.type=="KillSound" then
        Econ.vPlayerData[nPlayerID].sCurrentKillSound = nil
        Econ.vPlayerData[nPlayerID].sCurrentKillSoundItem = nil
        if keys.isEquip==1 then
           Econ:EquipKillSoundEcon(keys.itemName,nPlayerID)
        end
    end

    --如果是弹幕特效
    if keys.type=="Barrage" then
        CustomNetTables:SetTableValue("econ_data", tostring(nPlayerID), {})
        if keys.isEquip==1 then
            Econ:EquipBarrageEcon(keys.itemName,nPlayerID)
        end
    end
    
    Server:UpdatePlayerEquip(nPlayerID,keys.itemName,keys.type,keys.isEquip)

end


function Econ:EquipParticleEcon(sItemName,nPlayerID)

    if PlayerResource:GetPlayer(nPlayerID) then

        local hHero = PlayerResource:GetPlayer(nPlayerID):GetAssignedHero()
        local vCurrentEconParticleIndexs={}

        for _,sParticle in pairs(self.vParticleMap[sItemName]) do
            if hHero then

                local nParticleAttach = Econ:ChooseParticleAttach(sItemName)
                local nParticleIndex = ParticleManager:CreateParticle(sParticle,nParticleAttach,hHero)
                ParticleManager:SetParticleControlEnt(nParticleIndex,0,hHero,nParticleAttach,"follow_origin",hHero:GetAbsOrigin(),true)
                Econ:SetControllPoints(nParticleIndex,sItemName)
                table.insert(vCurrentEconParticleIndexs,nParticleIndex)
            end
        end
        -- 有的特效需要循环播放
        Econ:RepeatPlay(sItemName,nPlayerID)

        Econ.vPlayerData[nPlayerID].sCurrentParticleEconItemName=sItemName
        Econ.vPlayerData[nPlayerID].vCurrentEconParticleIndexs=vCurrentEconParticleIndexs
    end

end


function Econ:EquipIllusionParticle(sItemName,hIllusion)

    if hIllusion then
        for _,sParticle in pairs(self.vParticleMap[sItemName]) do
            if hIllusion then
                local nParticleAttach = Econ:ChooseParticleAttach(sItemName)
                local nParticleIndex = ParticleManager:CreateParticle(sParticle,nParticleAttach,hIllusion)
                ParticleManager:SetParticleControlEnt(nParticleIndex,0,hIllusion,nParticleAttach,"follow_origin",hIllusion:GetAbsOrigin(),true)
                Econ:SetControllPoints(nParticleIndex,sItemName)
            end
        end
        -- 有的特效需要循环播放
        Econ:RepeatPlayIllusion(sItemName,hIllusion)
    end

end


function Econ:RepeatPlayIllusion(sItemName,hIllusion)
        
        local flInterval
        
        --只有少数特效需要循环播放
        if sItemName=="rainbow_tail" then
            flInterval = 5
        end

        if sItemName=="butterfly" then
            flInterval = 2
        end
        
        if flInterval==nil then
            return
        end


        Timers:CreateTimer(flInterval, function()
          --如果饰品已经更换，则直接取消定时器
          if (not hIllusion) or (not hIllusion:IsAlive()) then
              return nil
          end

          for _,sParticle in pairs(self.vParticleMap[sItemName]) do
             if hIllusion then
                local nParticleAttach = Econ:ChooseParticleAttach(sItemName)
                local nParticleIndex = ParticleManager:CreateParticle(sParticle,nParticleAttach,hIllusion)
                ParticleManager:SetParticleControlEnt(nParticleIndex,0,hIllusion,nParticleAttach,"follow_origin",hIllusion:GetAbsOrigin(),true)
                Econ:SetControllPoints(nParticleIndex,sItemName)
             end
          end
          return flInterval
        end)

end






function Econ:RepeatPlay(sItemName,nPlayerID)
        
        local flInterval
        
        --只有少数特效需要循环播放
        if sItemName=="rainbow_tail" then
            flInterval = 5
        end

        if sItemName=="butterfly" then
            flInterval = 2
        end
        
        if flInterval==nil then
            return
        end


        Timers:CreateTimer(flInterval, function()
          local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
          
          --如果饰品已经更换，则直接取消定时器
          if Econ.vPlayerData[nPlayerID].sCurrentParticleEconItemName~=sItemName then
              return nil
          end

          for _,nOldParticleIndex in ipairs(Econ.vPlayerData[nPlayerID].vCurrentEconParticleIndexs) do
              ParticleManager:DestroyParticle(nOldParticleIndex, false)
              ParticleManager:ReleaseParticleIndex(nOldParticleIndex)
          end

          local vCurrentEconParticleIndexs={}
          for _,sParticle in pairs(self.vParticleMap[sItemName]) do
             if hHero then
                local nParticleAttach = Econ:ChooseParticleAttach(sItemName)
                local nParticleIndex = ParticleManager:CreateParticle(sParticle,nParticleAttach,hHero)
                ParticleManager:SetParticleControlEnt(nParticleIndex,0,hHero,nParticleAttach,"follow_origin",hHero:GetAbsOrigin(),true)
                Econ:SetControllPoints(nParticleIndex,sItemName)
                table.insert(vCurrentEconParticleIndexs,nParticleIndex)
             end
          end
          Econ.vPlayerData[nPlayerID].vCurrentEconParticleIndexs=vCurrentEconParticleIndexs
          return flInterval
        end)

end





--根据类型微调附着点
function Econ:ChooseParticleAttach(sItemName)
    if  sItemName == "rich" then
        return PATTACH_OVERHEAD_FOLLOW
    end
    if  sItemName == "wudizhansha" then
        return PATTACH_OVERHEAD_FOLLOW
    end
    if  sItemName == "miedi" then
        return PATTACH_OVERHEAD_FOLLOW
    end
    if  sItemName == "douyu_1" then
        return PATTACH_OVERHEAD_FOLLOW
    end
    if  sItemName == "douyu_2" then
        return PATTACH_OVERHEAD_FOLLOW
    end
    if  sItemName == "douyu_3" then
        return PATTACH_OVERHEAD_FOLLOW
    end
    if  sItemName == "rainbow" then
        return PATTACH_ABSORIGIN
    end
    if  sItemName == "legend_three_star_chess" then
        return PATTACH_OVERHEAD_FOLLOW
    end
    if  sItemName == "epic_three_star_chess" then
        return PATTACH_OVERHEAD_FOLLOW
    end
    if  sItemName == "rare_three_star_chess" then
        return PATTACH_OVERHEAD_FOLLOW
    end

    if  sItemName == "douyu_new_1" then
        return PATTACH_OVERHEAD_FOLLOW
    end
    if  sItemName == "douyu_new_2" then
        return PATTACH_OVERHEAD_FOLLOW
    end
    if  sItemName == "douyu_new_3" then
        return PATTACH_OVERHEAD_FOLLOW
    end
    if  sItemName == "season_2020_5" then
        return PATTACH_OVERHEAD_FOLLOW
    end

    return PATTACH_ABSORIGIN_FOLLOW
end


--根据类型微调控制点
function Econ:SetControllPoints(nParticleIndex,sItemName,hHero)
    if  sItemName == "ethereal_flame_white" then
        ParticleManager:SetParticleControl(nParticleIndex, 15, Vector(200, 200, 200))
        ParticleManager:SetParticleControl(nParticleIndex, 2, Vector(255, 255, 255))
        ParticleManager:SetParticleControl(nParticleIndex, 16, Vector(1, 0, 0))
    end
    if  sItemName == "ethereal_flame_golden" then
        ParticleManager:SetParticleControl(nParticleIndex, 15, Vector(217, 191, 89))
        ParticleManager:SetParticleControl(nParticleIndex, 2, Vector(255, 255, 255))
        ParticleManager:SetParticleControl(nParticleIndex, 16, Vector(1, 0, 0))
    end
    if  sItemName == "ethereal_flame_pink" then
        ParticleManager:SetParticleControl(nParticleIndex, 15, Vector(210, 0, 210))
        ParticleManager:SetParticleControl(nParticleIndex, 2, Vector(255, 255, 255))
        ParticleManager:SetParticleControl(nParticleIndex, 16, Vector(1, 0, 0))
    end
    if  sItemName == "rainbow" then
        if hHero then
           ParticleManager:SetParticleControl(nParticleIndex, 2, hHero:GetAbsOrigin()+Vector(0,0,175))
        end
    end
end

--根据类型微调控制点
function Econ:StopLoopingSound(sItemName)
    if sItemName == "ceb" then
       Timers:CreateTimer(3, function()
         StopGlobalSound("soundboard.ceb.start")
         EmitGlobalSound("soundboard.ceb.stop")
         end
       )
    end
end




function Econ:EquipKillEffectEcon(sItemName,nPlayerID)
    Econ.vPlayerData[nPlayerID].sCurrentKillEffect=Econ.vKillEffectMap[sItemName]
    Econ.vPlayerData[nPlayerID].sCurrentKillEffectItem=sItemName
end

function Econ:PlayKillEffect(hHero)
    
    local nPlayerID = hHero:GetPlayerID()
    if Econ.vPlayerData[nPlayerID] and Econ.vPlayerData[nPlayerID].sCurrentKillEffect and Econ.vPlayerData[nPlayerID].sCurrentKillEffectItem then
        local sParticle = Econ.vPlayerData[nPlayerID].sCurrentKillEffect
        local nParticleAttach = Econ:ChooseParticleAttach(Econ.vPlayerData[nPlayerID].sCurrentKillEffectItem)
        local nParticleIndex = ParticleManager:CreateParticle(sParticle,nParticleAttach,hHero)

        Econ:SetControllPoints(nParticleIndex,Econ.vPlayerData[nPlayerID].sCurrentKillEffectItem,hHero)
        ParticleManager:SetParticleControlEnt(nParticleIndex,0,hHero,nParticleAttach,"follow_origin",hHero:GetAbsOrigin(),true)
        ParticleManager:ReleaseParticleIndex(nParticleIndex)
    end
    
end


function Econ:EquipKillSoundEcon(sItemName,nPlayerID)
    
    Econ.vPlayerData[nPlayerID].sCurrentKillSound=Econ.vKillSoundMap[sItemName]
    Econ.vPlayerData[nPlayerID].sCurrentKillSoundItem=sItemName

end

function Econ:EquipBarrageEcon(sItemName,nPlayerID)
    CustomNetTables:SetTableValue("econ_data", tostring(nPlayerID), {itemName=sItemName})
end


function Econ:PlayKillSound(hHero)
    
    local nPlayerID = hHero:GetPlayerID()
    if Econ.vPlayerData[nPlayerID] and Econ.vPlayerData[nPlayerID].sCurrentKillSound and Econ.vPlayerData[nPlayerID].sCurrentKillSoundItem then
        local sSound = Econ.vPlayerData[nPlayerID].sCurrentKillSound
        local vData={}
        vData.type = "chat_wheel"
        vData.playerId = nPlayerID
        vData.itemName =Econ.vPlayerData[nPlayerID].sCurrentKillSoundItem
        Barrage:FireBullet(vData)
        EmitGlobalSound(sSound)
        Econ:StopLoopingSound(Econ.vPlayerData[nPlayerID].sCurrentKillSoundItem)
    else
        EmitSoundOn("Hero_LegionCommander.Duel.Victory", hHero)
    end

end


function Econ:ActiveChatWheel(keys)
    
    local nPlayerID = keys.playerId
    local sItemName = keys.itemName
    local sSound = Econ.vKillSoundMap[sItemName]
    EmitGlobalSound(sSound)
    Econ:StopLoopingSound(sItemName)

    local vData={}
    vData.type = "chat_wheel"
    vData.playerId = nPlayerID
    vData.itemName =sItemName
    Barrage:FireBullet(vData)
end

function Econ:ActiveTaunt(keys)
    
    local nPlayerID = keys.playerId
    local sItemName = keys.itemName
    local sParticle = Econ.vKillEffectMap[sItemName]
    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
    if hHero then
       local nParticleAttach = Econ:ChooseParticleAttach(sItemName)
       local nParticleIndex = ParticleManager:CreateParticle(sParticle,nParticleAttach,hHero)
       ParticleManager:SetParticleControlEnt(nParticleIndex,0,hHero,nParticleAttach,"follow_origin",hHero:GetAbsOrigin(),true)
       Econ:SetControllPoints(nParticleIndex,sItemName,hHero)
       ParticleManager:ReleaseParticleIndex(nParticleIndex)
    end
end