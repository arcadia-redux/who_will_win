if Barrage == nil then Barrage = class({}) end

function Barrage:Init()
    ListenToGameEvent("player_chat", Dynamic_Wrap(Barrage, "OnPlayerSay"), self)   
end



--监听玩家打字 弹幕
function Barrage:OnPlayerSay(keys) 
 
    local hPlayer = PlayerInstanceFromIndex( keys.userid )
    local hHero = hPlayer:GetAssignedHero()
    local nPlayerId= hHero:GetPlayerID()
    local szText = string.trim(keys.text)

    --多人模式内 队友频道不发弹幕
    if GetMapName()=="2x6" and  1==keys.teamonly then
        return
    end

    local vData={}
    vData.type = "player_say"
    vData.playerId = nPlayerId
    vData.content =szText
    self:FireBullet(vData)
end


--发送弹幕
function Barrage:FireBullet(vData)
     CustomGameEventManager:Send_ServerToAllClients("FireBullet",vData);
end
