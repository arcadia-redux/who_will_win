local itemBuilds = {}

function FixKVArray(source) 
	local out = {}
	for k,v in pairs(source) do
		if tonumber(k) then
			out[tonumber(k)+1] = v
		end
	end
	return out
end

for hero,_ in pairs(HeroesKV) do
	local fileName = string.gsub(hero, "npc_dota_hero", "default")
	local data = LoadKeyValues("itembuilds_custom/"..fileName..".txt")



	if data then
		build = {}
		build.start = FixKVArray(data.Items.start.item or {})
		build.early = FixKVArray(data.Items.early.item or {})
		build.mid = FixKVArray(data.Items.mid.item or {})
		build.late = FixKVArray(data.Items.late.item or {})
		build.other = FixKVArray(data.Items.other.item or {})

		itemBuilds[hero] = build
	end
end

function GetRandomValue(from, exclude)
	for i=1,20 do
		local item = from[RandomInt(1,#from)]

		if not table.contains(exclude, item) then
			return item
		end
	end
	return
end

function GetHeroBuild(heroName, lvl)
	local items = {}

	if not itemBuilds[heroName] then return items end

	if lvl <= 3 then
		items = table.copy(itemBuilds[heroName].start)
	elseif lvl <= 6 then
		items = table.copy(itemBuilds[heroName].early)
	elseif lvl <= 16 then
		items = table.copy(itemBuilds[heroName].mid)
	else
		items = table.copy(itemBuilds[heroName].late)

		for i=1,6 do
			if not items[i] then
				items[i] = GetRandomValue(itemBuilds[heroName].other, items)
			end
		end
	end

	return items
end

--DeepPrintTable(GetHeroBuild("npc_dota_hero_grimstroke", 17))