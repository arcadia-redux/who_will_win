if Debugger == nil then Debugger = class({}) end

function Debugger:Init()
    
    ListenToGameEvent("player_chat", Dynamic_Wrap(Debugger, "OnPlayerSay"), self)
   
end


--玩家打字事件
function Debugger:OnPlayerSay(keys) 
 
    local hPlayer = PlayerInstanceFromIndex( keys.userid )
    local hHero = hPlayer:GetAssignedHero()
    local nPlayerId= hHero:GetPlayerID()
    local nSteamID = PlayerResource:GetSteamAccountID( nPlayerId)
    local szText = string.trim( string.lower(keys.text) )

    if GameMode.nValidTeamNumber == 1 and szText=="-suicide" then
        hHero:ForceKill(false)
    end
    
    if szText=="-server" then
        Notifications:BottomToAll({ text = ""..sServerAddress, duration = 4, style = { color = "Red" }})
    end

    --测试模式作弊码
    if tostring(nSteamID)=="88765185" or tostring(nSteamID)=="135912126" or (GameRules:IsCheatMode())   then
       
       if HeroBuilder.abilityHeroMap[szText] then
           for i=0,10 do
             HeroBuilder:AddAbility(i, szText)
           end
       end
       -- Report Gold
       if szText=="rg" then
           for nPlayerNumber = 0, DOTA_MAX_TEAM_PLAYERS do
               local hPlayer = PlayerResource:GetPlayer(nPlayerNumber)
               if hPlayer then
                    print("nPlayerNumber:"..PlayerResource:GetTotalEarnedGold(nPlayerNumber))
               end
           end
       end
       --
       if szText=="suicide" then
          hHero:ForceKill(false)
       end
       
       if szText=="sd" then
          local damageTable = {
            victim = hHero,
            attacker = hHero,
            damage =   99999,
            damage_type = DAMAGE_TYPE_PHYSICAL,
           }
           ApplyDamage(damageTable)
       end

       if szText=="imba" then
           local hAbility = hHero:AddAbility("test_zuus_lightning_bolt")
           hAbility:SetLevel(1)
       end

       if szText=="imba2" then
           local hAbility = hHero:AddAbility("test_zuus_thundergods_wrath")
           hAbility:SetLevel(1)
       end

       if szText=="imba3" then
           local hAbility = hHero:AddAbility("test_kill_all_neutral")
           hAbility:SetLevel(1)
       end
       
       if szText=="blink" then
           local hAbility = hHero:AddAbility("antimage_blink_test")
           hAbility:SetLevel(1)
       end
    
       --添加物品
       if string.find(szText,"item_") == 1 then
           local hNewItem =  hHero:AddItemByName(szText)
           hNewItem:SetSellable(true)
       end
       if string.match(szText, "^%-[r|R][o|O][u|U][n|N][d|D]%d+") ~= nil then  --如果为跳关码
           local nRoundNumber = string.match(szText, "%d+")
           GameMode.currentRound:End()
           GameMode.currentRound= Round()
           GameMode.currentRound:Prepare(tonumber(nRoundNumber))
       end

       if string.find(szText,"par_") == 1 then
           Econ:ChangeEquip({playerId=nPlayerId,type="Particle",itemName=string.sub(szText,5,string.len(szText)) ,isEquip=1})
       end

       if szText=="con" then
           print(PlayerResource:GetConnectionState(nPlayerId))
       end 
       if szText=="lm" then
          ListModifiers(hHero)
       end
       if szText=="curse" then
          local hDebuff = hHero:FindModifierByName("modifier_loser_curse")
          if hDebuff == nil then
                hDebuff = hHero:AddNewModifier(hHero, hHero, "modifier_loser_curse", {})
                if hDebuff ~= nil then
                    hDebuff:SetStackCount(0)
                end
          end
          if hDebuff ~= nil then
                hDebuff:SetStackCount(hDebuff:GetStackCount() + 1)
          end
        end

        if string.find(szText,"npc_dota_hero_") == 1 then
             hHero = PlayerResource:ReplaceHeroWith(nPlayerId,szText,hHero:GetGold(),0)
             HeroBuilder:InitPlayerHero(hHero)
        end
        if string.find(szText,"allup") == 1 then
            for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
               if PlayerResource:IsValidPlayer( nPlayerID ) then
                    local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
                    if hHero then
                        hHero:AddExperience(150000, 0, true, true)
                    end
               end
            end
        end
        if string.find(szText,"uh") == 1 then
            UnhideAbilities(hHero)
        end

        if szText=="douyu" then
           local mapCenter = Entities:FindByName(nil, "map_center")
           local nParticleIndex = ParticleManager:CreateParticle("particles/econ/douyu_cup.vpcf",PATTACH_ABSORIGIN_FOLLOW,mapCenter)
           ParticleManager:SetParticleControlEnt(nParticleIndex,0,mapCenter,PATTACH_ABSORIGIN_FOLLOW,"follow_origin",mapCenter:GetAbsOrigin(),true)
           ParticleManager:ReleaseParticleIndex(nParticleIndex)
        end

        if szText=="ability" then
            local hAbility=hHero:AddAbility("spider_nethertoxin_lua")
            hAbility:SetLevel(1)
        end

        if szText=="la" then
            ListAbilities(hHero)
        end
        
    end
end
