item_swap_essence = class({})


function item_swap_essence:OnSpellStart()
	if IsServer() then
		local hCaster = self:GetCaster()
		local hPlayer =  hCaster:GetPlayerOwner()
		if hCaster and hCaster:IsRealHero() and not hCaster:IsTempestDouble() and not hCaster:HasModifier("modifier_morphling_replicate")  then          
	       if hPlayer then
	       	   --如果正在选技能 不起作用
	           if hCaster.bSelectingAbility or hCaster.bRemovingAbility or hCaster.bSelectingSpellBook then
	           	   return
	           end
               
               if GetMapName()=="1x8" then
               	   CustomGameEventManager:Send_ServerToPlayer(hPlayer,"OnlyMutiPlayerWarn",{})
	           	   return
	           end

		       hCaster.sTeamSwapUISecret= CreateSecretKey()
		       local nPlayerID = hPlayer:GetPlayerID()
               
               -- hCaster.nSwappingItemIndex 正在调换技能的标志位
		       if not hCaster.nSwappingItemIndex then
                  hCaster.nSwappingItemIndex = self:GetEntityIndex()
                  CustomGameEventManager:Send_ServerToPlayer(hPlayer,"ShowSwap",{ui_secret=hCaster.sTeamSwapUISecret,security_key=Security:GetSecurityKey(nPlayerID),item_index=hCaster.nSwappingItemIndex})
		       else
		       	  CustomGameEventManager:Send_ServerToPlayer(hPlayer,"ShowSwap",{ui_secret=hCaster.sTeamSwapUISecret,security_key=Security:GetSecurityKey(nPlayerID)})
		       end
	       end
		end
	end
end

