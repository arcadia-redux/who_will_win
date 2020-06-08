item_extra_creature_centaur_khan = class({})


function item_extra_creature_centaur_khan:OnSpellStart()
	if IsServer() then
		local hCaster = self:GetCaster()
		local hPlayer =  hCaster:GetPlayerOwner()
		if hCaster and hCaster:IsRealHero() and not hCaster:IsTempestDouble() and not hCaster:HasModifier("modifier_morphling_replicate")  then          
	       if hPlayer then
	       	   ExtraCreature:AddExtraCreature(hPlayer:GetPlayerID(),"npc_dota_centaur_khan")
	       	   self:SpendCharge()
	       end
		end
	end
end

