function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function table.copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function removeFromTable(t,val)
	for k,v in pairs(t) do
		if v == val then
			table.remove(t, k)
		end
	end
end


local precachedUnits = precachedUnits or {}
function PrecacheUnitList(unitList, idx)
  local idx = idx or 1
  local unit = unitList[idx]

  if precachedUnits[unit] then
    --print("Already precached", unit)
    PrecacheUnitList(unitList, idx + 1)
  else
    --print("Precache start", unit)
    PrecacheUnitByNameAsync(unit, function(...)
      --print("Precache end", unit, ...)
      precachedUnits[unit] = true
      if idx < #unitList then
        PrecacheUnitList(unitList, idx + 1)
      end
    end)
  end
end

function IsFlagSet(num, flag)
  return bit.band(num, flag) == flag
end

function GetHeroFirstTalentID(hero) 
  for i=0,23 do
    local ability = hero:GetAbilityByIndex(i)
    if ability and not ability:IsNull() and string.find(ability:GetAbilityName(), "special_bonus") then
      return i
    end
  end

  return -1
end

function TrainTalent(unit, talent)
  ExecuteOrderFromTable({
    UnitIndex = unit:entindex(),
    OrderType = DOTA_UNIT_ORDER_TRAIN_ABILITY,
    AbilityIndex = talent:entindex(),
  })
end


function CountPlayers()
  local count = 0
  for pID=0,23 do
    if PlayerResource:IsValidTeamPlayerID(pID) then
      count = count + 1
    end
  end
  return count
end

function CountActivePlayers()
  local count = 0
  for pID=0,23 do
    if PlayerResource:IsValidTeamPlayerID(pID) and Gambling:GetGold(pID) > 0 and PlayerResource:GetConnectionState(pID) ~= DOTA_CONNECTION_STATE_ABANDONED then
      count = count + 1
    end
  end
  return count
end

function IsSoloGame() 
  return CountPlayers() == 1
end

function splitString(line, separator)
    local list = {}
    for token in string.gmatch(line, "[^"..separator.."]+") do
      table.insert(list, token)
    end
    return list
end