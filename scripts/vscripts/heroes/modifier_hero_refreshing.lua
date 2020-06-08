modifier_hero_refreshing = class({})


function modifier_hero_refreshing:GetTexture()
	return "rune_regen"
end


function modifier_hero_refreshing:IsHidden()
	return false
end

function modifier_hero_refreshing:IsDebuff()
	return false
end

function modifier_hero_refreshing:IsPurgable()
	return false
end

function modifier_hero_refreshing:OnCreated( kv )
	if IsServer() then
		self.flInterval=0.1
		self.nParticleIndex = ParticleManager:CreateParticle("particles/items_fx/bottle.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:StartIntervalThink( self.flInterval )
		--禁用技能表
		self.disableAbilityList={"phoenix_supernova","shredder_timber_chain","ancient_apparition_ice_blast","brewmaster_primal_split"}
	    --先执行一次把技能禁用
	    self:OnIntervalThink()
	end
end

function modifier_hero_refreshing:OnDestroy( kv )
	if IsServer() then
		for _,sAbilityName in ipairs(self.disableAbilityList) do
		   if self:GetParent():HasAbility(sAbilityName) then
		      self:GetParent():FindAbilityByName(sAbilityName):SetActivated(true)
		   end
		end
		ParticleManager:DestroyParticle(self.nParticleIndex, false)
		ParticleManager:ReleaseParticleIndex(self.nParticleIndex)
	end
end


--遍历全部的技能 加速其CD
function modifier_hero_refreshing:OnIntervalThink()
	if IsServer() then

       for _,sAbilityName in ipairs(self.disableAbilityList) do
		   if self:GetParent():HasAbility(sAbilityName) then
		      self:GetParent():FindAbilityByName(sAbilityName):SetActivated(false)
		   end
	   end
	   
	   if self:GetParent():HasModifier("modifier_ice_blast") then
		  self:GetParent():RemoveModifierByName("modifier_ice_blast")
	   end
	   if self:GetParent():HasModifier("modifier_dazzle_weave_armor") then
		  self:GetParent():RemoveModifierByName("modifier_dazzle_weave_armor")
	   end
	   for i = 1, 20 do
            local hAbility = self:GetParent():GetAbilityByIndex(i - 1)
            if hAbility and hAbility.GetCooldownTimeRemaining then
            	local flRemaining = hAbility:GetCooldownTimeRemaining()
            	if self.flInterval <  flRemaining then
            	   --加快冷却速度 --先结束 再设置 这样UI上比较平滑
            	   hAbility:EndCooldown()
                   hAbility:StartCooldown(flRemaining-self.flInterval)
            	end
            end
        end
	end
end

function modifier_hero_refreshing:CheckState()
	local state =
	{
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
	return state
end


function modifier_hero_refreshing:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
	}
	return funcs
end

function modifier_hero_refreshing:GetModifierHealthRegenPercentage(params)
	return 4
end

function modifier_hero_refreshing:GetModifierTotalPercentageManaRegen(params)
	return 4
end

