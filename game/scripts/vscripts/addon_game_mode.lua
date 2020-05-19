if BAW == nil then
	BAW = class({})

	_G.FIGHT = false
	UNIT2POINT = {}
	VOTED_ID = {}
	PICKED_ID = {}
	PLAYERS_ID = {}
	PLAYERS = 0
	PICKED = {}
	ALIVES = {}
	ROUND = 0
	POINTS = 1000
end

require('timers')
require('utils')
require('ai')

function Precache( context )
end

function Activate()
	BAW:InitGameMode()
end

_G.UnitsKV = LoadKeyValues("scripts/npc/npc_units.txt")
_G.HeroesKV = LoadKeyValues("scripts/npc/npc_heroes.txt")
_G.Items = LoadKeyValues("scripts/npc/items.txt")
_G.AbilityPowers = LoadKeyValues("scripts/kv/ability_power.txt")

bannedUnits = {
	npc_dota_units_base = true,
	npc_dota_thinker = true,
	npc_dota_companion = true,
	npc_dota_loadout_generic = true,
	npc_dota_clinkz_skeleton_archer = true,
	npc_dota_greevil = true,
	npc_dota_loot_greevil = true,
	npc_dota_greevil_miniboss_black = true,
	npc_dota_greevil_miniboss_blue = true,
	npc_dota_greevil_miniboss_red = true,
	npc_dota_greevil_miniboss_yellow = true,
	npc_dota_greevil_miniboss_white = true,
	npc_dota_greevil_minion_white = true,
	npc_dota_greevil_minion_black = true,
	npc_dota_greevil_minion_red = true,
	npc_dota_greevil_minion_blue = true,
	npc_dota_greevil_minion_yellow = true,
	npc_dota_greevil_miniboss_green = true,
	npc_dota_greevil_miniboss_orange = true,
	npc_dota_greevil_miniboss_purple = true,
	npc_dota_greevil_minion_orange = true,
	npc_dota_greevil_minion_purple = true,
	npc_dota_greevil_minion_green = true,
	npc_dota_aether_remnant = true,
	npc_dota_goodguys_cny_beast = true,
	npc_dota_badguys_cny_beast = true,
	npc_dota_goodguys_tower1_top = true,
	npc_dota_goodguys_tower2_top = true,
	npc_dota_goodguys_tower3_top = true,
	npc_dota_goodguys_tower1_mid = true,
	npc_dota_goodguys_tower2_mid = true,
	npc_dota_goodguys_tower3_mid = true,
	npc_dota_goodguys_tower1_bot = true,
	npc_dota_goodguys_tower2_bot = true,
	npc_dota_goodguys_tower3_bot = true,
	npc_dota_goodguys_tower4 = true,
	npc_dota_badguys_tower1_top = true,
	npc_dota_badguys_tower2_top = true,
	npc_dota_badguys_tower3_top = true,
	npc_dota_badguys_tower1_mid = true,
	npc_dota_badguys_tower2_mid = true,
	npc_dota_badguys_tower3_mid = true,
	npc_dota_badguys_tower1_bot = true,
	npc_dota_badguys_tower2_bot = true,
	npc_dota_badguys_tower3_bot = true,
	npc_dota_badguys_tower4 = true,
	dota_fountain = true,
	npc_dota_goodguys_siege_diretide = true,
	npc_dota_badguys_siege_diretide = true,
	npc_dota_roshan_halloween = true,
	npc_dota_shadow_shaman_ward_1 = true,
	npc_dota_shadow_shaman_ward_2 = true,
	npc_dota_shadow_shaman_ward_3 = true,
	npc_dota_venomancer_plague_ward_1 = true,
	npc_dota_venomancer_plague_ward_2 = true,
	npc_dota_venomancer_plague_ward_3 = true,
	npc_dota_venomancer_plague_ward_4 = true,
	npc_dota_hero_chen = true,
	npc_dota_hero_lone_druid = true,
	npc_dota_hero_invoker = true
}
-- bannedItems = {
-- 	item_gem
-- }
function BAW:InitGameMode()
	GameRules:SetStartingGold(322)
	GameRules:SetGoldPerTick(0)
	GameRules:SetGoldTickTime(0)
	GameRules:SetRuneSpawnTime(0)
	GameRules:SetUseBaseGoldBountyOnHeroes(false)
	GameRules:SetTreeRegrowTime(60)
	GameRules:SetSameHeroSelectionEnabled(true)
	GameRules:SetHeroSelectionTime(0)
	GameRules:SetPreGameTime(5)
	GameRules:SetFirstBloodActive(false)
	GameRules:SetHideKillMessageHeaders(true)
    GameRules:SetCustomGameSetupAutoLaunchDelay(0)
    GameRules:LockCustomGameSetupTeamAssignment(true)
    GameRules:EnableCustomGameSetupAutoLaunch(true)
	GameRules:SetHeroRespawnEnabled(false)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 10)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)

    local mode = GameRules:GetGameModeEntity()
    mode:SetDaynightCycleDisabled(true)
    mode:SetKillingSpreeAnnouncerDisabled(true)
    mode:SetStickyItemDisabled(true)
    mode:SetLoseGoldOnDeath(false)
    mode:SetStashPurchasingDisabled(true)
    mode:SetAlwaysShowPlayerInventory(false)
    mode:SetAnnouncerDisabled(true)
    mode:SetGoldSoundDisabled(true)
    mode:SetRemoveIllusionsOnDeath(false)
    mode:SetBotThinkingEnabled(false)
    mode:SetTowerBackdoorProtectionEnabled(false)
  	mode:SetCameraDistanceOverride(1500)
  	mode:SetFogOfWarDisabled(true)
  	-- mode:SetMinimumAttackSpeed(0)
  	-- mode:SetMaximumAttackSpeed(999999)
    mode:SetRecommendedItemsDisabled(true)
    mode:SetCustomBuybackCostEnabled(false)
    mode:SetCustomBuybackCooldownEnabled(false)
    mode:SetBuybackEnabled(false)
    mode:SetTopBarTeamValuesOverride(true)
    mode:SetTopBarTeamValuesVisible(true)
    mode:SetCustomGameForceHero("npc_dota_hero_wisp")

	self:linkmodifiers()

    ListenToGameEvent("dota_player_pick_hero",Dynamic_Wrap(self,"OnHeroPicked"),self)
	ListenToGameEvent("game_rules_state_change",Dynamic_Wrap(self,'OnGameRulesStateChange'),self)
    CustomGameEventManager:RegisterListener("Pick", Dynamic_Wrap(self, 'Pick'))
    CustomGameEventManager:RegisterListener("speedup", Dynamic_Wrap(self, 'speedup'))
    -- print('"DOTAUnits"')
    -- print("{")
   --  for k,v in pairs(HeroesKV) do
   --  	if not bannedUnits[k] then
   --  		print('	"'..k..'"')
		 --    print("	{")
		 --    print('		"vscripts"					"ai.lua"')
		 --    print('		"AttackAcquisitionRange"	"5000"')
			-- print('	}')
   --  	end
   --  end
	-- print('}')
    for k,v in pairs(UnitsKV) do
    	if not bannedUnits[k] and type(v) == "table" and v['AttackCapabilities'] ~= "DOTA_UNIT_CAP_NO_ATTACK" and ((v["AttackDamageMin"] or 0) ~= 0 or (v["AttackDamageMax"] or 0) ~= 0) then
    		UNIT2POINT[k] = CalculateUnitPoints(k,v)
    	end
    end
    local itemsc = _G.Items
    _G.items = {}
    for k,v in pairs(itemsc) do
    	if type(v) == "table" and v['ItemCost'] and (not v['ItemRecipe'] or v['ItemRecipe'] == 0) and v['ItemCost'] > 0 then
	    	_G.items[k] = v['ItemCost']
	    end
    end
    _G.AllHeroes = {}
    for k,v in pairs(HeroesKV) do
    	if not bannedUnits[k] then
    		table.insert(_G.AllHeroes,k)
    	end
    end
    --[[
    local points = 1000
    local cachepoints
    local cache
    local teams
    local cheapest
    local cacheteams
    local check
    local rand
    for i=1,10 do
    	cache = {}
    	cheapest = {points,''}
    	teams = {left = {},right = {}}
    	for k,v in pairs(UNIT2POINT) do
    		if v <= points then
    			table.insert(cache, {v,k})
    			if cheapest[1] > v then
    				cheapest = {v,k}
    			end
    		end
    	end
    	cacheteams = {left = cache,right = cache}
    	for j=1,2 do
    		if j == 1 then
    			check = 'left'
    		else
    			check = 'right'
    		end
	    	cachepoints = points
	    	while cachepoints > cheapest[1] do 
	    		rand = RandomInt(1, #cacheteams[check])
	    		table.insert(teams[check],cacheteams[check][rand][2])
	    		cachepoints = cachepoints - cacheteams[check][rand][1]
	    		cache = {}
		    	for k,v in ipairs(cacheteams[check]) do
		    		if v[1] <= cachepoints then
		    			table.insert(cache, v)
		    		end
		    	end
		    	cacheteams[check] = cache
	    	end
    	end
    	-- DeepPrintTable(teams)
    	-- local sum = 0
    	-- for k,v in pairs(teams) do
    	-- 	sum = 0
    	-- 	for i,p in ipairs(v) do
    	-- 		sum = sum + p[1]
    	-- 	end
    	-- 	print(k..": "..sum)
    	-- end
    	points = points + 500
    end
    ]]
end

function CalculateUnitPoints(unitName, kv)
	local points = 0

	local damage = ((kv["AttackDamageMax"] or 0) + (kv["AttackDamageMin"] or 0)) / 2
	local attackRate = kv["AttackRate"] or 1.7
	local damageBased = damage/attackRate
	
	local attackRange = (kv["AttackRange"] or 100) - 100
	
	local health = kv["StatusHealth"] or 0
	local armor = kv["ArmorPhysical"] or 0

	local damageMult = 1 - ((0.052 * armor) / (0.9 + 0.048 * math.abs(armor)))
	local effectiveHP = health / damageMult

	local mana = (kv["StatusMana"] or 0) * 0.75
	local healthRegen = (kv["StatusHealthRegen"] or 0) * 20
	local manaRegen = (kv['StatusManaRegen'] or 0) * 10

	if kv['AttackCapabilities'] == "DOTA_UNIT_CAP_RANGED_ATTACK" then
    	damageBased = damageBased * 1.1
    end


	points = damageBased + attackRange + effectiveHP + mana + healthRegen + manaRegen


	return math.floor(points)
end

function BAW:speedup(t)
	local pid = t.PlayerID
	if _G.FIGHT and not table.contains(VOTED_ID,pid) then
		table.insert(VOTED_ID, pid)
		if #VOTED_ID >= PLAYERS then
			Convars:SetFloat("host_timescale", 3)
		end
	end
end

function BAW:Pick(t)
	local pid = t.PlayerID
	local pick = t.v
	local ply = PlayerResource:GetPlayer(pid)
	if not _G.FIGHT and not table.contains(PICKED_ID,pid) then
		local hero = ply:GetAssignedHero()
		if pick == "right" then
			ply:SetTeam(DOTA_TEAM_BADGUYS)
			hero:SetTeam(DOTA_TEAM_BADGUYS)
		else
			ply:SetTeam(DOTA_TEAM_GOODGUYS)
			hero:SetTeam(DOTA_TEAM_GOODGUYS)
		end
		table.insert(PICKED[pick], hero)
		table.insert(PICKED_ID, pid)
		CustomGameEventManager:Send_ServerToAllClients('change_top',{
			left=#PICKED["left"],
			right=#PICKED["right"],
		})
		if #PICKED_ID >= PLAYERS then
			BAW:StartFight()
		end
	end
end

function BAW:OnHeroPicked(t)
	if t.player == -1 then
		return
	end
    local hero = EntIndexToHScript(t.heroindex)
    local playerowner = hero:GetPlayerOwner()
    local playerownerid = hero:GetPlayerOwnerID()
    --local steam_id = PlayerResource:GetSteamAccountID(playerownerid)
    local team = hero:GetTeam()

    for i=0,6 do
    	local ab = hero:GetAbilityByIndex(i)
    	if ab then 
    		hero:RemoveAbility(ab:GetName())
    	end
    end
	PLAYERS = PLAYERS + 1
	hero:AddNewModifier(hero,nil,'modifier_removed_hero',{})
	table.insert(PLAYERS_ID, playerownerid)
end

function BAW:linkmod(string,motion)
    LinkLuaModifier(string, "modifiers/"..string, motion or LUA_MODIFIER_MOTION_NONE)
end

function BAW:linkmodifiers()
    local modTable = {
        'modifier_removed_hero',
    }  
    for k,v in pairs(modTable) do
        if type(v) == "number" then
            BAW:linkmod(k,v)
        else
            BAW:linkmod(v)
        end
    end
end

function BAW:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
	elseif nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
	elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 10)
		self:StartGame()
	end
end

function BAW:StartFight()
	_G.FIGHT = true
	for k,v in pairs(ALIVES) do
		for e,u in pairs(v) do
			if k == "left" then
				u:SetTeam(DOTA_TEAM_GOODGUYS)
			else
				u:SetTeam(DOTA_TEAM_BADGUYS)
			end
		end
	end
	CustomGameEventManager:Send_ServerToAllClients('hide_versus',{})
	local time = 120
	CustomGameEventManager:Send_ServerToAllClients('new_timer',{time=time})
	Timers:CreateTimer(function()
		ALIVES = {left = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
          Vector(0, 0, 0),
          nil,
          10000,
          DOTA_UNIT_TARGET_TEAM_FRIENDLY,
          DOTA_UNIT_TARGET_ALL,
          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE+DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD,
          FIND_ANY_ORDER,
          false),
		right = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
          Vector(0, 0, 0),
          nil,
          10000,
          DOTA_UNIT_TARGET_TEAM_FRIENDLY,
          DOTA_UNIT_TARGET_ALL,
          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE+DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD,
          FIND_ANY_ORDER,
          false)}
		for d,e in pairs(ALIVES) do
			local count = 0
			for i,v in ipairs(e) do
				if not v:IsControllableByAnyPlayer() then
					count = count + 1
					if not v.bInitialized then
						v.targetPoint = Vector(0,0,0)
						v:StartAI()
					end
				end
			end
			if count <= 0 then
				for n,p in pairs(PICKED[d]) do
					p:SetHealth(p:GetHealth()-1)
				end
				BAW:StartGame()
				CustomGameEventManager:Send_ServerToAllClients('new_timer',{time=45})
				return nil
			end
		end
		CustomGameEventManager:Send_ServerToAllClients('new_timer',{time=time})
		time = time - 1
		if time <= 0 then
			BAW:StartGame()
			CustomGameEventManager:Send_ServerToAllClients('new_timer',{time=45})
			return nil
		end
		return 1
	end)
	CustomGameEventManager:Send_ServerToAllClients('start_fight', nil)
end

function BAW:StartGame()
	PICKED_ID = {}
	VOTED_ID = {}
	Convars:SetFloat("host_timescale", 1)
	for i,v in ipairs(PLAYERS_ID) do
		PlayerResource:GetPlayer(v):SetTeam(DOTA_TEAM_GOODGUYS)
	end

	-- Convars:SetFloat("host_timescale", 5)
	local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
          Vector(0, 0, 0),
          nil,
          10000,
          DOTA_UNIT_TARGET_TEAM_BOTH,
          DOTA_UNIT_TARGET_ALL,
          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE+DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD,
          FIND_ANY_ORDER,
          false)
	for i,v in ipairs(units) do
		if not v:IsControllableByAnyPlayer() then
			v:RemoveSelf()
		end
	end
	local ent = Entities:First()
	while ent do
		if ent and not ent:IsNull() then
		    if ent and not ent:IsNull() and ((ent.IsItem and ent:IsItem()) or ent.bawcreep or ent:GetClassname() == "dota_item_drop" or ent:GetClassname() == "dota_temp_tree") then
		    	ent:RemoveSelf()
		    end
		end
	    ent = Entities:Next(ent)
	end
	-- for i,v in ipairs(units) do
	-- 	if not v:IsControllableByAnyPlayer() then
	-- 		v:ForceKill(false)
	-- 	end
	-- end
	-- for d,e in pairs(ALIVES) do
	-- 	for k,v in pairs(e) do
	-- 		if v:IsAlive() then
	-- 			v:ForceKill(false)
	-- 		end
	-- 	end
	-- end
	_G.FIGHT = false
	-- local first = table.copy(TEAMS[RandomInt(1,#TEAMS)])
	-- local leftN = RandomInt(1,#first)
	-- local left = table.copy(first[leftN])
	-- table.remove(first, leftN)
	-- local rightN = RandomInt(1,#first)
	-- local right = table.copy(first[rightN])


	local heroes = RollPercentage(25)
    local teams = {left = {},right = {}}
    local level
	local minPoints = POINTS * 0.05
	if not heroes then
	    local cachepoints
	    local cache = {}
	    local cheapest = {POINTS,''}
	    local cacheteams
	    local check
	    local rand
		-- cache = {}
		-- cheapest = {POINTS,''}
		-- teams = {left = {},right = {}}
		for k,v in pairs(UNIT2POINT) do
			if v <= POINTS and v >= minPoints then
				table.insert(cache, {v,k})
				if cheapest[1] > v then
					cheapest = {v,k}
				end
			end
		end
		cacheteams = {left = cache,right = cache}
		for j=1,2 do
			if j == 1 then
				check = 'left'
			else
				check = 'right'
			end
	    	cachepoints = POINTS
	    	while cachepoints > cheapest[1] do 
	    		rand = RandomInt(1, #cacheteams[check])
	    		table.insert(teams[check],cacheteams[check][rand][2])
	    		cachepoints = cachepoints - cacheteams[check][rand][1]
	    		cache = {}
		    	for k,v in ipairs(cacheteams[check]) do
		    		if v[1] <= cachepoints then
		    			table.insert(cache, v)
		    		end
		    	end
		    	cacheteams[check] = cache
	    	end
		end
	else
		local howmany = RandomInt(1, 5)
		local lefthero = AllHeroes[RandomInt(1, #AllHeroes)]
		local righthero = AllHeroes[RandomInt(1, #AllHeroes)]
		level = RandomInt(1, 5)
		if level == 1 then
			level = 1
		elseif level == 2 then
			level = 6
		elseif level == 3 then
			level = 16
		elseif level == 4 then
			level = 30
		end
		for i=1,howmany do
			table.insert(teams['left'], lefthero)
			table.insert(teams['right'], righthero)
		end
	end
	-- DeepPrintTable(teams)
	-- local sum = 0
	-- for k,v in pairs(teams) do
	-- 	sum = 0
	-- 	for i,p in ipairs(v) do
	-- 		sum = sum + p[1]
	-- 	end
	-- 	print(k..": "..sum)
	-- end
	-- DeepPrintTable(teams)
	local left = teams['left']
	local right = teams['right']
	local itemsg = false
	if RollPercentage(50) then
		itemsg = true
	end
	local itemsAr = {}
	if itemsg then
		cache = {}
		cheapest = {POINTS,''}
		for k,v in pairs(items) do
			if v <= POINTS and v >= minPoints then
				table.insert(cache, {v,k})
				if cheapest[1] > v then
					cheapest = {v,k}
				end
			end
		end
		cachepoints = POINTS
		cacheteams = cache
		while cachepoints > cheapest[1] do 
			rand = RandomInt(1, #cacheteams)
			table.insert(itemsAr,cacheteams[rand][2])
			cachepoints = cachepoints - cacheteams[rand][1]
			cache = {}
	    	for k,v in ipairs(cacheteams) do
	    		if v[1] <= cachepoints then
	    			table.insert(cache, v)
	    		end
	    	end
	    	cacheteams = cache
		end
	end
	POINTS = POINTS + 500
	PICKED = {left = {},right = {}}
	ALIVES = {left = {},right = {}}
	local leftpw = 0
	local rightpw = 0
	for k,v in ipairs(left) do
		leftpw,unit = BAW:SpawnUnits(v,"left",Vector(-1280,-1088,128),Vector(0,0,0),leftpw)
		if unit and heroes and unit:IsRealHero() then
			for i=1,level do
				unit:HeroLevelUp(false)
			end
			if level == 1 then
				unit:GetAbilityByIndex(RandomInt(0, 2)):SetLevel(1)
			elseif level == 6 then
				local ab = RandomInt(0, 2)
				unit:GetAbilityByIndex(ab):SetLevel(3)
				for i=0,2 do
					if i ~= ab then
						unit:GetAbilityByIndex(i):SetLevel(1)
					end
				end
				unit:GetAbilityByIndex(6):SetLevel(1)
			elseif level == 16 then
				unit:GetAbilityByIndex(0):SetLevel(4)
				unit:GetAbilityByIndex(1):SetLevel(4)
				unit:GetAbilityByIndex(2):SetLevel(4)
				unit:GetAbilityByIndex(6):SetLevel(3)
			elseif level == 30 then
				for i=0,15 do
					local ab = unit:GetAbilityByIndex(i)
					if ab then
						ab:SetLevel(ab:GetMaxLevel())
					end
				end
			end
		end
		for i,v in ipairs(itemsAr) do
			unit:AddItemByName(v)
		end
	end
	for k,v in ipairs(right) do
		rightpw,unit = BAW:SpawnUnits(v,"right",Vector(1280,1088,128),Vector(0,0,0),rightpw)
		if heroes and unit:IsRealHero() then
			for i=1,level do
				unit:HeroLevelUp(false)
			end
			if level == 1 then
				unit:GetAbilityByIndex(RandomInt(0, 2)):SetLevel(1)
			elseif level == 6 then
				local ab = RandomInt(0, 2)
				unit:GetAbilityByIndex(ab):SetLevel(3)
				for i=0,2 do
					if i ~= ab then
						unit:GetAbilityByIndex(i):SetLevel(1)
					end
				end
				unit:GetAbilityByIndex(6):SetLevel(1)
			elseif level == 16 then
				unit:GetAbilityByIndex(0):SetLevel(4)
				unit:GetAbilityByIndex(1):SetLevel(4)
				unit:GetAbilityByIndex(2):SetLevel(4)
				unit:GetAbilityByIndex(6):SetLevel(3)
			elseif level == 30 then
				for i=0,15 do
					local ab = unit:GetAbilityByIndex(i)
					if ab then
						ab:SetLevel(ab:GetMaxLevel())
					end
				end
			end
		end
		for i,v in ipairs(itemsAr) do
			unit:AddItemByName(v)
		end
	end
	local ar = {left = {},right = {},regens = {}}
	local index
	for k,v in pairs(ALIVES) do
		for e,u in pairs(v) do
			index = u:entindex()
			ar['regens'][index] = {u:GetHealthRegen(),u:GetManaRegen(),(u:GetBaseDamageMax()+u:GetBaseDamageMin())*0.5,u:GetPhysicalArmorValue(false),u:GetSecondsPerAttack(),u:Script_GetAttackRange()}
			if k == "left" then
				table.insert(ar['left'],index)
			else
				table.insert(ar['right'],index)
			end
		end
	end
	ROUND = ROUND + 1
	CustomGameEventManager:Send_ServerToAllClients('new_round',{
		left=leftpw,
		right=rightpw,
		indexes=ar
	})
	local timer = 15
	Timers:CreateTimer(function()
		if timer <= 0 then
			for k,pid in pairs(PLAYERS_ID) do
				if not table.contains(PICKED_ID,pid) then
					local pick = RollPercentage(50)
					if pick then
						pick = "right"
					else
						pick = "left"
					end
					local ply = PlayerResource:GetPlayer(pid)
					local hero = ply:GetAssignedHero()
					if pick == "right" then
						ply:SetTeam(DOTA_TEAM_BADGUYS)
						hero:SetTeam(DOTA_TEAM_BADGUYS)
					else
						ply:SetTeam(DOTA_TEAM_GOODGUYS)
						hero:SetTeam(DOTA_TEAM_GOODGUYS)
					end
					table.insert(PICKED[pick], hero)
					table.insert(PICKED_ID, pid)
					CustomGameEventManager:Send_ServerToAllClients('change_top',{
						left=#PICKED["left"],
						right=#PICKED["right"],
					})
					if #PICKED_ID >= PLAYERS then
						BAW:StartFight()
					end
				end
			end
			return nil
		end
		if not _G.FIGHT then
			timer = timer - 1
			CustomGameEventManager:Send_ServerToAllClients('new_timer',{time=timer})
			return 1
		else
			return nil
		end
	end)
end

function BAW:SpawnUnits(v,team,vec,target,points)
	local unit = CreateUnitByName( v, vec, true, nil, nil, DOTA_TEAM_GOODGUYS)
	if unit then
		unit.bawcreep = true
		if not unit:HasGroundMovementCapability() and not unit:HasFlyMovementCapability() then
			FindClearSpaceForUnit(unit, Vector(0,0)+RandomVector(RandomInt(0, 200)), true)
		end
		for i=0,5 do
			local ab = unit:GetAbilityByIndex(i)
			if ab then
				ab:SetLevel(1)
				ab:SetActivated(true)
				ab:ToggleAutoCast()
			end
		end
		unit.targetPoint = target
		table.insert(ALIVES[team],unit)
		points = points + (UNIT2POINT[v] or 0)
		unit:StartAI()
	else
		error("UNIT NOT FOUND: "..v)
	end
	return points,unit
end