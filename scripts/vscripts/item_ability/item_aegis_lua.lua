item_aegis_lua = class({})


function item_aegis_lua:OnSpellStart()
	if IsServer() then
		local hCaster = self:GetCaster()
		local hPlayer =  hCaster:GetPlayerOwner()
		if hCaster and hCaster:IsRealHero() and not hCaster:IsTempestDouble() then 
		    if hCaster:HasModifier("modifier_aegis") then
               local hModifierAegis = hCaster:FindModifierByName("modifier_aegis")
               local nCurrentStack = hModifierAegis:GetStackCount()
               hModifierAegis:SetStackCount(nCurrentStack+1)
		    else
                local hModifierAegis = hCaster:AddNewModifier(hCaster, nil, "modifier_aegis", {})
                hModifierAegis:SetStackCount(1)
		    end
		    self:SpendCharge()
		    EmitSoundOn("DOTA_Item.Refresher.Activate", hCaster)
		    local nParticle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn_timer.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
			ParticleManager:ReleaseParticleIndex( nParticle );
		end
	end
end

