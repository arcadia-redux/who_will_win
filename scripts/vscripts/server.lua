--持久化服务器 交互Service
if Server == nil then Server = class({}) end

nServerRandom = RandomInt(1, 2)


--低端负载均衡
if nServerRandom == 1 then
    sServerAddress="http://106.13.79.105:9000/"
end

if nServerRandom == 2 then
   sServerAddress="http://106.13.79.105:9100/"
end


sPayPalServerAddress="http://104.243.18.16:8890/"

--测试环境走测试类
if IsInToolsMode()  then
   sServerAddress="http://106.13.79.105:8081/"
   sPayPalServerAddress="http://106.13.79.105:8081/"
end



local function stringTable(t)
    local s = {}
    for k,v in pairs(t) do
        if type(v) == 'table' then
            s[k] = stringTable(v)
        else s[k] = tostring(v)
        end
    end
    return s
end


function Server:EndPveGame(nWinnerTeam,nRoundNumber,nPlayerSteamId)
    local nTimeCost=GameRules:GetGameTime() - GameRules.nGameStartTime
    local request = CreateHTTPRequestScriptVM("GET", sServerAddress .. "endpvegame")
    request:SetHTTPRequestHeaderValue("dedicated_server_key",GetDedicatedServerKey(GetDedicatedServerKeyV2("1"))..GetDedicatedServerKeyV2(GetDedicatedServerKey("2"))..GetDedicatedServerKey("3"));
    request:SetHTTPRequestGetOrPostParameter("player_steam_id",tostring(nPlayerSteamId));
    request:SetHTTPRequestGetOrPostParameter("time_cost",tostring(math.floor(nTimeCost)));
    request:SetHTTPRequestGetOrPostParameter("round_number",tostring(nRoundNumber));
    --对Match ID进行加密 后台再校验
    request:SetHTTPRequestGetOrPostParameter("match_id",tostring(GameRules:GetMatchID()));
    request:SetHTTPRequestGetOrPostParameter("match_id_encrypted",sha1.hmac(GetDedicatedServerKeyV2("fgnb"),tostring(GameRules:GetMatchID())));

    request:Send(function(result)
        print("End Pve Game Finish"..result.StatusCode)
        if result.StatusCode == 200 and result.Body~=nil then
            local body = JSON:decode(result.Body)
            PrintTable(body)
            if body ~= nil then
                CustomNetTables:SetTableValue("end_game_data", "end_game_data", stringTable(body))
                GameRules:SetGameWinner(nWinnerTeam)
            end
        end
    end)
end



function Server:EndPvpGame(nWinnerTeam)

    local request = CreateHTTPRequestScriptVM("POST", sServerAddress .. "endpvpgame")
    request:SetHTTPRequestHeaderValue("dedicated_server_key",GetDedicatedServerKey(GetDedicatedServerKeyV2("1"))..GetDedicatedServerKeyV2(GetDedicatedServerKey("2"))..GetDedicatedServerKey("3"));
    
    --整理表单数据
    local winnerPlayerIDList = {}
    local vFormData = {}
    for k,nTeamNumber in pairs(GameMode.rankMap) do
      for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
        if PlayerResource:IsValidPlayer( nPlayerID ) and PlayerResource:GetSelectedHeroEntity (nPlayerID) and PlayerResource:GetSelectedHeroEntity(nPlayerID):GetTeamNumber()==nTeamNumber then
           local nPlayerSteamId = tostring(PlayerResource:GetSteamAccountID(nPlayerID))
           -- 测试默认下，为玩家添加随机ID
           if nPlayerSteamId == "0" then
              nPlayerSteamId = tostring(RandomInt(88765185, 88865185))
           end
           vFormData[""..nPlayerSteamId]=""..k
           -- 纪录获胜者的ID
           if k == 1 then
             table.insert(winnerPlayerIDList, nPlayerID)
           end
        end
      end
    end

    request:SetHTTPRequestGetOrPostParameter("form_data",tostring(JSON:encode(vFormData)));
    request:SetHTTPRequestGetOrPostParameter("form_data_encrypted", sha1.hmac(GetDedicatedServerKeyV2("fgnb"),  tostring(JSON:encode(vFormData))) );

    request:SetHTTPRequestGetOrPostParameter("early_leave_list",GameRules.sEarlyLeavePlayerSteamIds);

    local nRoundNumber = 1
    if GameMode.currentRound and GameMode.currentRound.nRoundNumber then
       nRoundNumber = GameMode.currentRound.nRoundNumber
    end
    --上传轮数
    request:SetHTTPRequestGetOrPostParameter("round_number",tostring(nRoundNumber));
    --是否密码房
    request:SetHTTPRequestGetOrPostParameter("password_lobby", GameMode.sPasswordLobby);
    --对Match ID进行加密 后台再校验 这样通信时候可以不带着 DedicatedServerKey，防止通信被监听暴露 DedicatedServerKey
    request:SetHTTPRequestGetOrPostParameter("match_id",tostring(GameRules:GetMatchID()));
    request:SetHTTPRequestGetOrPostParameter("match_id_encrypted",sha1.hmac(GetDedicatedServerKeyV2("fgnb"),tostring(GameRules:GetMatchID())));
    

    request:SetHTTPRequestGetOrPostParameter("game_duration",tostring(GameRules:GetGameTime()));
    request:SetHTTPRequestGetOrPostParameter("player_steam_ids",GameRules.sValidePlayerSteamIds);

    --5人局以上，抽取1/10的比赛纪录日志
    if (RandomInt(1, 10)==1 or IsInToolsMode()) and GameMode.nValidTeamNumber>=5 then
        if winnerPlayerIDList and #winnerPlayerIDList>0 then
          local winner_infos = {}
          for _,nWinnerPlayerID in ipairs(winnerPlayerIDList) do
             table.insert(winner_infos, Util:GenerateHeroInfo(nWinnerPlayerID))
          end
          request:SetHTTPRequestGetOrPostParameter("winner_infos",  tostring(JSON:encode(winner_infos)) )
        end
    end

    if GetMapName() == "1x8" then
        request:SetHTTPRequestGetOrPostParameter("type","solo"); 
    end
    if GetMapName() == "2x6" then
        request:SetHTTPRequestGetOrPostParameter("type","duos"); 
    end

    request:Send(function(result)
        print("End Pvp Game Finish"..result.StatusCode)
        if result.StatusCode == 200 and result.Body~=nil then
            local body = JSON:decode(result.Body)
            if body ~= nil then
                CustomNetTables:SetTableValue("end_game_data", "end_game_data", stringTable(body))
                GameRules:SetGameWinner(nWinnerTeam)
            end
        end
    end)
end


function Server:GetRankData()
    local request = CreateHTTPRequestScriptVM("GET", sServerAddress .. "getrankdata")
    request:SetHTTPRequestHeaderValue("dedicated_server_key",GetDedicatedServerKey(GetDedicatedServerKeyV2("1"))..GetDedicatedServerKeyV2(GetDedicatedServerKey("2"))..GetDedicatedServerKey("3"));
    request:SetHTTPRequestGetOrPostParameter("player_steam_ids",GameRules.sValidePlayerSteamIds);

    if GetMapName() == "1x8" then
        request:SetHTTPRequestGetOrPostParameter("type","solo"); 
    end
    if GetMapName() == "2x6" then
        request:SetHTTPRequestGetOrPostParameter("type","duos"); 
    end

    request:Send(function(result)
        print("Rank Data Arrive")
        if result.StatusCode == 200 and result.Body~=nil then
            local body = JSON:decode(result.Body)
            --PrintTable(body)
            if body ~= nil then
                CustomNetTables:SetTableValue("rank_data", "pve", stringTable(body)['pve'])
                CustomNetTables:SetTableValue("rank_data", "solo", stringTable(body)['solo'])
                CustomNetTables:SetTableValue("rank_data", "duos", stringTable(body)['duos'])
                CustomNetTables:SetTableValue("rank_data", "limited", stringTable(body)['limited'])
                CustomNetTables:SetTableValue("rank_data", "rank_info", stringTable(body)['rank_info'])                
                Security.matchKeys=stringTable(body)['match_key']
                GameMode.sPasswordLobby = stringTable(body)['password_lobby']
                Pass:InitPassData(stringTable(body)['pass'])
            end
        end
    end)
end

--从服务器获取玩家饰品信息
function Server:GetPlayerEconData()
    local request = CreateHTTPRequestScriptVM("GET", sServerAddress .. "getecondata")
    request:SetHTTPRequestHeaderValue("dedicated_server_key",GetDedicatedServerKey(GetDedicatedServerKeyV2("1"))..GetDedicatedServerKeyV2(GetDedicatedServerKey("2"))..GetDedicatedServerKey("3"));
    request:SetHTTPRequestGetOrPostParameter("player_steam_ids",GameRules.sValidePlayerSteamIds);

    request:Send(function(result)
        print("Econ Data Arrive")
        if result.StatusCode == 200 then
            print(result.Body)
            local body = JSON:decode(result.Body)
            if body ~= nil then
                Pass:AddDemoCosmetics(stringTable(body))
            end
        end
    end)
end


--更新装备信息
function Server:UpdatePlayerEquip(nPlayerID,sItemName,sType,nEquip)

    local request = CreateHTTPRequestScriptVM("GET", sServerAddress .. "updateplayerequip")
    request:SetHTTPRequestHeaderValue("dedicated_server_key",GetDedicatedServerKey(GetDedicatedServerKeyV2("1"))..GetDedicatedServerKeyV2(GetDedicatedServerKey("2"))..GetDedicatedServerKey("3"));

    local nPlayerSteamId = PlayerResource:GetSteamAccountID(nPlayerID)
    
    request:SetHTTPRequestGetOrPostParameter("player_steam_id",tostring(nPlayerSteamId));
    request:SetHTTPRequestGetOrPostParameter("item_name",sItemName);
    request:SetHTTPRequestGetOrPostParameter("item_type",sType);
    request:SetHTTPRequestGetOrPostParameter("equip",tostring(nEquip));

    request:Send(function(result)
        print("Update Player Equip")
        if result.StatusCode == 200 and result.Body~=nil then
            print(result.Body)
        end
    end)
end




function Server:GetEconRarity()
    local request = CreateHTTPRequestScriptVM("GET", sServerAddress .. "geteconrarity")
    request:SetHTTPRequestHeaderValue("dedicated_server_key",GetDedicatedServerKey(GetDedicatedServerKeyV2("1"))..GetDedicatedServerKeyV2(GetDedicatedServerKey("2"))..GetDedicatedServerKey("3"));

    request:Send(function(result)
        print("Rarity Data Arrive")
        if result.StatusCode == 200 and result.Body~=nil then
            local body = JSON:decode(result.Body)
            if body ~= nil then
                print(result.Body)
                CustomNetTables:SetTableValue("econ_rarity", "econ_rarity", stringTable(body.econ_rarity))
                CustomNetTables:SetTableValue("econ_type", "econ_type", stringTable(body.econ_type))
            end
        end
    end)
end

function Server:DrawLottery(nPlayerID)

    local request = CreateHTTPRequestScriptVM("GET", sServerAddress .. "drawlottery")
    request:SetHTTPRequestHeaderValue("dedicated_server_key",GetDedicatedServerKey(GetDedicatedServerKeyV2("1"))..GetDedicatedServerKeyV2(GetDedicatedServerKey("2"))..GetDedicatedServerKey("3"));

    local nPlayerSteamId = PlayerResource:GetSteamAccountID(nPlayerID)
    request:SetHTTPRequestGetOrPostParameter("player_steam_id",tostring(nPlayerSteamId));
    --对Match ID进行加密 后台再校验 这样通信时候可以不带着 DedicatedServerKey，防止通信被监听暴露 DedicatedServerKey
    request:SetHTTPRequestGetOrPostParameter("match_id",tostring(GameRules:GetMatchID()));
    request:SetHTTPRequestGetOrPostParameter("match_id_encrypted",sha1.hmac(GetDedicatedServerKeyV2("fgnb"),tostring(GameRules:GetMatchID())));


    request:Send(function(result)
        if result.StatusCode == 200 and result.Body~=nil then
            local body = JSON:decode(result.Body)
            if body ~= nil then
               CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"DrawLotteryResultArrive",body)
            end
        end
    end)
end

function Server:SubmitTaobaoCode(keys)
    
    local sCode = tostring(keys.code)

    local sRealServerAddress = sServerAddress
    
    --如果是Paypal支付，走专属服务器
    if sCode and string.find(sCode,"PAYID") == 1 then
       sRealServerAddress = sPayPalServerAddress
    end

    local request = CreateHTTPRequestScriptVM("GET", sRealServerAddress .. "submittaobaocode")
    request:SetHTTPRequestHeaderValue("dedicated_server_key",GetDedicatedServerKey(GetDedicatedServerKeyV2("1"))..GetDedicatedServerKeyV2(GetDedicatedServerKey("2"))..GetDedicatedServerKey("3"));


    local nPlayerSteamId = PlayerResource:GetSteamAccountID(keys.playerId)

    request:SetHTTPRequestGetOrPostParameter("player_steam_id",tostring(nPlayerSteamId));
    request:SetHTTPRequestGetOrPostParameter("code",tostring(keys.code));
    --对Match ID进行加密 后台再校验 这样通信时候可以不带着 DedicatedServerKey，防止通信被监听暴露 DedicatedServerKey
    request:SetHTTPRequestGetOrPostParameter("match_id",tostring(GameRules:GetMatchID()));
    request:SetHTTPRequestGetOrPostParameter("match_id_encrypted",sha1.hmac(GetDedicatedServerKeyV2("fgnb"),tostring(GameRules:GetMatchID())));


    request:Send(function(result)
        if result.StatusCode == 200 and result.Body~=nil then
            local body = JSON:decode(result.Body)
            if body ~= nil then
                --如果成功
                if body.type=='1' then
                    CustomNetTables:SetTableValue("econ_data", "money_"..nPlayerSteamId,{money=body.money})
                end
                --如果是使用淘宝购买的PASS
                if body.type=='0' then
                    
                    Pass.passInfo[tonumber(keys.playerId)] =true
                    Pass.steamPassInfo[tostring(nPlayerSteamId)] =true

                    local passData={}
                    passData.player_steam_id = tostring(nPlayerSteamId)
                    passData.validate_date = tostring(body.validate_date)
                    CustomNetTables:SetTableValue("player_info", "pass_data_"..keys.playerId, passData)
                    --给指定玩家试用饰品
                    Pass:AddDemoCosmetics(nil,tonumber(keys.playerId))
                    --演员次数
                    GameMode.reportActorTime[keys.playerId]=3
                end
                CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId),"TaobaoCodeResult",{type=body.type,money_bonus=body.money_bonus,validate_date=body.validate_date})
            end
        else
            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId),"TaobaoCodeResult",{type=5})
        end
    end)
end


function Server:UploadErrorLog(sMessage)

    local request = CreateHTTPRequestScriptVM("POST", sServerAddress .. "uploaderrorlog")
    request:SetHTTPRequestHeaderValue("dedicated_server_key",GetDedicatedServerKey(GetDedicatedServerKeyV2("1"))..GetDedicatedServerKeyV2(GetDedicatedServerKey("2"))..GetDedicatedServerKey("3"));
    
    local sValidePlayerSteamIds =""

    for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
        if PlayerResource:IsValidPlayer( nPlayerID )  and PlayerResource:GetSteamAccountID(nPlayerID) then
           local nPlayerSteamId = tostring(PlayerResource:GetSteamAccountID(nPlayerID))
           sValidePlayerSteamIds = sValidePlayerSteamIds.. nPlayerSteamId
        end
    end

    request:SetHTTPRequestGetOrPostParameter("player_steam_ids",GameRules.sValidePlayerSteamIds);
    request:SetHTTPRequestGetOrPostParameter("log_message",sMessage);

    request:Send(function(result)
        if result.StatusCode == 200 and result.Body~=nil then
            print("UploadErrorLog :"..result.Body)       
        else
            print("UploadErrorLog, Fail:"..result.Body)       
        end
    end)
end

--上传快照日志
function Server:UploadSnapLog(vSanpInfo,sType)
    
    local request = CreateHTTPRequestScriptVM("POST", sServerAddress .. "uploadsnap")
    request:SetHTTPRequestHeaderValue("dedicated_server_key",GetDedicatedServerKey(GetDedicatedServerKeyV2("1"))..GetDedicatedServerKeyV2(GetDedicatedServerKey("2"))..GetDedicatedServerKey("3"));
    request:SetHTTPRequestGetOrPostParameter("snap_type",sType);
    request:SetHTTPRequestGetOrPostParameter("player_steam_ids",GameRules.sValidePlayerSteamIds);
    request:SetHTTPRequestGetOrPostParameter("snap_player_steam_id",vSanpInfo.sSteamID);
    request:SetHTTPRequestGetOrPostParameter("items",vSanpInfo.sItems);
    request:SetHTTPRequestGetOrPostParameter("abilities",vSanpInfo.sAbilities);
    request:SetHTTPRequestGetOrPostParameter("perk_detail",vSanpInfo.sPerks);
    request:SetHTTPRequestGetOrPostParameter("perk_sum",vSanpInfo.sPerkSum);
    request:SetHTTPRequestGetOrPostParameter("unit_name",vSanpInfo.sUnitName);
    request:SetHTTPRequestGetOrPostParameter("game_time",vSanpInfo.sGameTime);
    request:SetHTTPRequestGetOrPostParameter("average_level",vSanpInfo.sAverageLevel);
    request:SetHTTPRequestGetOrPostParameter("match_id",GameRules.sMatchId);


    request:Send(function(result)
        if result.StatusCode == 200 and result.Body~=nil then
            print("UploadLog, Success"..result.Body)       
        else
            print("UploadLog, Fail:"..result.Body)       
        end
    end)
end


function Server:GetPayPalLink(nPlayerID)
    
    --PayPal专属服务器
    local request = CreateHTTPRequestScriptVM("GET", sPayPalServerAddress .. "getpaypallink")
    request:SetHTTPRequestHeaderValue("dedicated_server_key",GetDedicatedServerKey(GetDedicatedServerKeyV2("1"))..GetDedicatedServerKeyV2(GetDedicatedServerKey("2"))..GetDedicatedServerKey("3"));

    local nPlayerSteamId = PlayerResource:GetSteamAccountID(nPlayerID)
    request:SetHTTPRequestGetOrPostParameter("player_steam_id",tostring(nPlayerSteamId));

    request:Send(function(result)
        if result.StatusCode == 200 and result.Body~=nil then
            local body = JSON:decode(result.Body)
            if body ~= nil then
                PrintTable(body)
                CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"PayPalQRCodeReturn",{url=body.url,code=body.paymentId})
            end
        else
            print("GetPayPalLink, Fail:"..result.Body)       
        end
    end)
end


function Server:ReportActor(nTargetPlayerID)

    local request = CreateHTTPRequestScriptVM("GET", sServerAddress .. "reportactor")
    request:SetHTTPRequestHeaderValue("dedicated_server_key",GetDedicatedServerKey(GetDedicatedServerKeyV2("1"))..GetDedicatedServerKeyV2(GetDedicatedServerKey("2"))..GetDedicatedServerKey("3"));

    local nPlayerSteamId = PlayerResource:GetSteamAccountID(nTargetPlayerID)
    request:SetHTTPRequestGetOrPostParameter("player_steam_id",tostring(nPlayerSteamId));
    --对Match ID进行加密 后台再校验
    request:SetHTTPRequestGetOrPostParameter("match_id",tostring(GameRules:GetMatchID()));
    request:SetHTTPRequestGetOrPostParameter("match_id_encrypted",sha1.hmac(GetDedicatedServerKeyV2("fgnb"),tostring(GameRules:GetMatchID())));

    
    if GetMapName() == "1x8" then
        request:SetHTTPRequestGetOrPostParameter("type","solo"); 
    end
    if GetMapName() == "2x6" then
        request:SetHTTPRequestGetOrPostParameter("type","duos"); 
    end


    request:Send(function(result)
        if result.StatusCode == 200 and result.Body~=nil then
             print("ReportActor, Success"..result.StatusCode)
        else
            print("ReportActor, Fail:"..result.StatusCode)       
        end
    end)
end



function Server:SubscribePassByCoins(nPlayerID)

    local request = CreateHTTPRequestScriptVM("GET", sServerAddress .. "subscribepassbycoins")
    request:SetHTTPRequestHeaderValue("dedicated_server_key",GetDedicatedServerKey(GetDedicatedServerKeyV2("1"))..GetDedicatedServerKeyV2(GetDedicatedServerKey("2"))..GetDedicatedServerKey("3"));

    local nPlayerSteamId = PlayerResource:GetSteamAccountID(nPlayerID)
    request:SetHTTPRequestGetOrPostParameter("player_steam_id",tostring(nPlayerSteamId));
    --对Match ID进行加密 后台再校验
    request:SetHTTPRequestGetOrPostParameter("match_id",tostring(GameRules:GetMatchID()));
    request:SetHTTPRequestGetOrPostParameter("match_id_encrypted",sha1.hmac(GetDedicatedServerKeyV2("fgnb"),tostring(GameRules:GetMatchID())));

    
    request:Send(function(result)
        if result.StatusCode == 200 and result.Body~=nil then   
            local body = JSON:decode(result.Body)
            if body ~= nil then
                PrintTable(body)
                --如果成功
                if body.type=="1" then
                    
                    Pass.passInfo[nPlayerID] =true
                    Pass.steamPassInfo[tostring(nPlayerSteamId)] =true

                    --刷新钱
                    CustomNetTables:SetTableValue("econ_data", "money_"..nPlayerSteamId,{money=body.money})

                    --刷新时间
                    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"SubscribePassByCoinsResult",{type=body.type,validate_date=body.validate_date})
                    local passData={}
                    passData.player_steam_id = tostring(nPlayerSteamId)
                    passData.validate_date = tostring(body.validate_date)
                    CustomNetTables:SetTableValue("player_info", "pass_data_"..nPlayerID, passData)
                    --给玩家试用饰品
                    Pass:AddDemoCosmetics(nil,nPlayerID)
                    --演员次数
                    GameMode.reportActorTime[nPlayerID]=3
                end
                if body.type=="2" then
                    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"SubscribePassByCoinsResult",{type=body.type})
                end
            end
        else
            print("SubscribePassByCoins, Fail:"..result.StatusCode)       
        end
    end)
end
