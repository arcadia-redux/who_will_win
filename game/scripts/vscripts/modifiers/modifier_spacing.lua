if not modifier_spacing then
	modifier_spacing = class({})
end

function modifier_spacing:IsHidden()
  	return true
end

function modifier_spacing:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

if IsServer() then

	function modifier_spacing:OnCreated(kv)
		self:StartIntervalThink(0)
	end

	function modifier_spacing:OnIntervalThink()
		local hullSize = 45
		local speed = 45

		local parent = self:GetParent()

		if parent:IsMoving() then return end

		local origin = parent:GetAbsOrigin()
		local unitType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING
		local unitFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
		local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, origin, nil, hullSize, DOTA_UNIT_TARGET_TEAM_BOTH, unitType, unitFlags, FIND_ANY_ORDER, false)

		local random = false
		local center = Vector(0,0,0)
		if #units > 1 then
			for _,unit in pairs(units) do
				--print(unit:GetUnitName(), parent:GetUnitName())

				if unit:GetAbsOrigin() == origin and unit ~= parent then
					random = true
					break
				end

				center = center + unit:GetAbsOrigin()
			end
		else
			return 0
		end

		center = center / #units

		local vel = (origin-center):Normalized()

		if rand then
			vel = RandomVector(1)
		end

		vel = vel*speed*GameRules:GetGameFrameTime()

		local oldOrigin = parent:GetAbsOrigin()
		local newOrigin = origin + vel
		FindClearSpaceForUnit(parent, newOrigin, true)

		--try to avoid teleports 
		if parent:GetAbsOrigin() ~= newOrigin then
			parent:SetAbsOrigin(oldOrigin)
		end

		return 0
	end

end




