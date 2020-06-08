if Security == nil then Security = class({}) end

--反外挂
--目前能找到的最佳的 校验前后台通讯的安全方式
--黑客可以伪造任意玩家向服务器的请求， 可以伪造服务器向任意玩家的请求，NetTables是否可以伪造未知
--抢在游戏开始的时候，利用NetTables与Request的双重保险方式向各个客户端发送秘钥
--后台向前台推送的 所有重要请求都应该带着秘钥，在前台进行校验，防止被伪造


--监听前台的更新请求
function Security:Init()
	
	--内存中的Security表
    Security.securityKeysList={}
	  Security.securityKeys={}
    Security.matchKeys={}
    
    --前台确认安全吗
    CustomGameEventManager:RegisterListener("SecurityKeyConfirmed",function(_, keys)
        self:SecurityKeyConfirmed(keys)
    end)

    Security:LoopUpdateSecurityKeys()
end


function Security:GetSecurityKey(nPlayerID)
    return Security.securityKeys[nPlayerID]
end


--更新玩家的Security Key
function Security:LoopUpdateSecurityKeys()
    Timers:CreateTimer(0.5, function()
        for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
          if PlayerResource:IsValidPlayer(nPlayerID) then
            
            if Security.securityKeysList[nPlayerID]==nil then
               Security.securityKeysList[nPlayerID] = {}
            end
            --限制队列长度
            if (#(Security.securityKeysList[nPlayerID])) > 50 then
               table.remove(Security.securityKeysList[nPlayerID], 1)
            end

            if Security.securityKeys[nPlayerID]==nil then
              local hPlayer = PlayerResource:GetPlayer(nPlayerID)
              if hPlayer then
                 local sSecurityKey = CreateSecretKey()
                 table.insert(Security.securityKeysList[nPlayerID], sSecurityKey)
                 local sNetTableSecurityKey = GetDedicatedServerKey(sSecurityKey)
                 CustomNetTables:SetTableValue("player_info", "net_table_security_key_"..nPlayerID, {net_table_security_key=sNetTableSecurityKey})
                 CustomGameEventManager:Send_ServerToPlayer(hPlayer,"SetSecurityKey",{security_key=sSecurityKey,net_table_security_key=sNetTableSecurityKey} )   
              end
            end
          end
        end
        return 0.5
    end)
end


function Security:SecurityKeyConfirmed(keys)
    local nPlayerID = keys.player_id
    if table.contains(Security.securityKeysList[nPlayerID], keys.security_key) then
       Security.securityKeys[nPlayerID] = keys.security_key
    end
end

