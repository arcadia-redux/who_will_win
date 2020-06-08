item_paragon_book = class({})


function item_paragon_book:OnSpellStart()
	if IsServer() then
		local hCaster = self:GetCaster()
		local hPlayer =  hCaster:GetPlayerOwner()
		if hCaster and hCaster:IsRealHero() and not hCaster:IsTempestDouble() and not hCaster:HasModifier("modifier_morphling_replicate")  then          
	       if hPlayer then
	       	   --如果正在选技能 不起作用
	           if hCaster.bSelectingAbility or hCaster.bRemovingAbility or hCaster.bSelectingSpellBook then
	           	   return
	           end
	           if hCaster.bUsedParagon then
               	   CustomGameEventManager:Send_ServerToPlayer(hPlayer,"OnlyUseOneTime",{})
	           	   return
	           end
               hCaster.bUsedParagon = true
               
		       hCaster:EmitSound("Item.TomeOfKnowledge")
		       self:SpendCharge()
		       HeroBuilder.totalAbilityNumber[hPlayer:GetPlayerID()] = HeroBuilder.totalAbilityNumber[hPlayer:GetPlayerID()]+1
               HeroBuilder:ShowRandomAbiliySelection(hPlayer:GetPlayerID())
	       end
		end
	end
end

