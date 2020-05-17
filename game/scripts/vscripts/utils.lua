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