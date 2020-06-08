item_spell_book_lua = class({})
	


function item_spell_book_lua:OnSpellStart()
	if IsServer() then
		local hCaster = self:GetCaster()
		if hCaster and hCaster:IsRealHero() and not hCaster:IsTempestDouble() then
		   hCaster:EmitSound("Item.TomeOfKnowledge")
		   local sAbilityName=self.sAbilityName
		   local nAbilityLevel=self.nAbilityLevel
		   local flAbilityCoolDown=self.flAbilityCoolDown
		   self:SpendCharge()
           HeroBuilder:AddSpellBookAbility(hCaster, sAbilityName, nAbilityLevel, flAbilityCoolDown)

           local hPlayer =  hCaster:GetPlayerOwner()
           if hPlayer then
             EmitSoundOnClient("Item.TomeOfKnowledge",hPlayer)
           end
		end
	end
end

