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