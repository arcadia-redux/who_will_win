modifier_item_custom_aegis = class({})

function modifier_item_custom_aegis:IsHidden()
	return true
end

function modifier_item_custom_aegis:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_REINCARNATION,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}

	return funcs
end

function modifier_item_custom_aegis:OnCreated()
	if IsServer() then
       self.reincarnate_time = self:GetAbility():GetSpecialValueFor( "reincarnate_time" )
       self.reincarnate_buff_time = self:GetAbility():GetSpecialValueFor( "reincarnate_buff_time" )
    end
end

--PVP无效 断线玩家无效
function modifier_item_custom_aegis:ReincarnateTime()
	
	local nPlayerID
    if self:GetParent().GetPlayerOwnerID then
       nPlayerID = self:GetParent():GetPlayerOwnerID()
    end

    if  nPlayerID  and PlayerResource:GetConnectionState(nPlayerID) == DOTA_CONNECTION_STATE_ABANDONED then
        return nil
    end

	if true~=self:GetParent().bJoiningPvp then
	   return self.reincarnate_time
	else
	   return nil
	end
end

-- 断线玩家收到伤害增加
function modifier_item_custom_aegis:GetModifierIncomingDamage_Percentage(params)
    
    local nPlayerID
    if self:GetParent().GetPlayerOwnerID then
       nPlayerID = self:GetParent():GetPlayerOwnerID()
    end

	if nPlayerID  and PlayerResource:GetConnectionState(nPlayerID) == DOTA_CONNECTION_STATE_ABANDONED then
       return 5000
    else
       return 0
    end
end




function modifier_item_custom_aegis:OnDeath(keys)
	if IsServer() then
	   if keys.unit == self:GetParent() then
	      local bSkeletonKingReincarnationWork = false
	      if self:GetParent():HasAbility("skeleton_king_reincarnation") then
             local hAbility = self:GetParent():FindAbilityByName("skeleton_king_reincarnation")
             if hAbility:GetLevel() > 0 then
             	 --刚刚触发
	             if hAbility:GetCooldownTimeRemaining() == hAbility:GetEffectiveCooldown(hAbility:GetLevel()-1) then
	                bSkeletonKingReincarnationWork = true 
	             end
	         end
	      end
	      --没有触发重生技能，并且不参与PVP才消耗层数
          if not bSkeletonKingReincarnationWork and true~=self:GetParent().bJoiningPvp then
          	  local hCaster = self:GetParent()
          	  local hAbility = self:GetAbility()
          	  local flReincarnateTime = self.reincarnate_time
          	  local flReincarnateBuffTime = self.reincarnate_buff_time

		      Timers:CreateTimer({ endTime = flReincarnateTime, 
				        callback = function()
				          local nParticle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn_timer.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
						  ParticleManager:SetParticleControl(nParticle, 1, Vector(0, 0, 0))
						  ParticleManager:SetParticleControl(nParticle, 3, hCaster:GetAbsOrigin())
						  ParticleManager:ReleaseParticleIndex(nParticle)
				    end
			  })
			  Timers:CreateTimer({ endTime = flReincarnateTime+0.3, 
				        callback = function()
						  Util:RefreshAbilityAndItem( hCaster,{skeleton_king_reincarnation=true} )
						  hCaster:AddNewModifier(hCaster, hAbility, "modifier_item_custom_aegis_buff", {duration=flReincarnateBuffTime})
				    end
			  })
			  self:GetAbility():SpendCharge()
		  end
	   end
	end
end

