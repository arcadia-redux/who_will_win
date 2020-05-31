meepo_item_duplication = class({})

function meepo_item_duplication:IsHiddenWhenStolen()
	return false
end

function meepo_item_duplication:CastFilterResultTarget(target)
	if not IsServer() then return end

	if target == self:GetCaster() then
		return UF_FAIL_OTHER
	else
		return UF_SUCCESS
	end
end

function meepo_item_duplication:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local ability = self

		if(caster == nil or caster:IsNull()) then
			return
		end

		if(target == nil or target:IsNull()) then
			return
		end

		local hasScepter = caster:HasScepter()

		local normalItemCount = 0
        for slotIndex = 0, 5 do
            local item = caster:GetItemInSlot(slotIndex)
            if(item ~= nil) then
                normalItemCount = normalItemCount + 1
            end
        end

		local duplicateCountLimit = ability:GetSpecialValueFor("item_count")

		if(hasScepter) then
			duplicateCountLimit = duplicateCountLimit + 1
		end

        if(normalItemCount < 6) then
			local duplicateMax = 6 - normalItemCount
			if(duplicateMax > duplicateCountLimit) then
				duplicateMax = duplicateCountLimit
			end

			local duplicatedCount = 0
	        for slotIndex = 0, 5 do
	            local item = target:GetItemInSlot(slotIndex)
	            if(item ~= nil) then
	            	local itemName = item:GetName()
	            	if(itemName ~= "item_refresher" and itemName ~= "item_clarity" and itemName ~= "item_flask" and itemName ~= "item_dust" and itemName ~= "item_ward_sentry") then
		                local newItem = CreateItem(itemName, nil, nil)
		                if(newItem ~= nil and newItem:IsNull() == false) then
			                newItem:SetPurchaseTime(item:GetPurchaseTime())
			                newItem:SetCurrentCharges(item:GetCurrentCharges())
			                newItem.IsMeepoCopyItem = true
			                caster:AddItem(newItem)
			                if(newItem ~= nil and newItem:IsNull() == false) then
			                	newItem:EndCooldown()
				                ExecuteOrderFromTable({
				                	UnitIndex = caster:entindex(),
				                	AbilityIndex = newItem:entindex(),
			                        OrderType = 32
			                    })
				            end
			                duplicatedCount = duplicatedCount + 1
			                if(duplicatedCount >= duplicateMax) then
			                	break
			                end
			            end
			        end
	            end
	        end
	    end
	end
end