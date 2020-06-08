--额外生物记录器
if ExtraCreature == nil then ExtraCreature = class({}) end


function ExtraCreature:Init()
   --key为TeamID, value为生物名称的队列
   ExtraCreature.teamCreatureMap={}
   ExtraCreature.soundMap={}
end


function ExtraCreature:AddExtraCreature(nPlayerID,sCreatureName)
	
  local nTeamNumber = PlayerResource:GetTeam(nPlayerID)
  
  if  nTeamNumber then

    	if ExtraCreature.teamCreatureMap and  ExtraCreature.teamCreatureMap[nTeamNumber] then
           table.insert(ExtraCreature.teamCreatureMap[nTeamNumber],sCreatureName)
      end
      --为所有玩家播放特效
    	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
    	    if PlayerResource:IsValidPlayer(nPlayerID) then
               local hPlayer = PlayerResource:GetPlayer(nPlayerID)
               if hPlayer then
                  CustomGameEventManager:Send_ServerToPlayer(hPlayer,"ExtraCreatureAdded",{creatureName=sCreatureName})
    	       end
    	    end
    	end

      local vData={}
      vData.type = "add_extra_creature"
      vData.playerId = nPlayerID
      vData.creatureName = sCreatureName
      Barrage:FireBullet(vData)
      
      -- 记录使用物品
      Util:RecordConsumableItem(nPlayerID,sCreatureName)
      
  end

end