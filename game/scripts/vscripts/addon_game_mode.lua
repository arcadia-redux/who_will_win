if BAW == nil then
	BAW = class({})
end
require('timers')
function Precache( context )
end
function Activate()
	BAW:InitGameMode()
end
_G.UnitsKV = LoadKeyValues("scripts/npc/npc_units.txt")
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
}
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
  	mode:SetCameraDistanceOverride(1800)
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
 --    print('"DOTAUnits"')
 --    print("{")
 --    for k,v in pairs(UnitsKV) do
 --    	if not bannedUnits[k] then
 --    		print('	"'..k..'"')
	-- 	    print("	{")
	-- 	    print('		"UseNeutralCreepBehavior"	"0"')
	-- 	    print('		"vscripts"					"ai.lua"')
	-- 	    print('		"AttackAcquisitionRange"	"5000"')
	-- 		print('	}')
 --    	end
 --    end
	-- print('}')
    for k,v in pairs(UnitsKV) do
    	if not bannedUnits[k] and type(v) == "table" and v['AttackCapabilities'] ~= "DOTA_UNIT_CAP_NO_ATTACK" and ((v["AttackDamageMin"] or 0) ~= 0 or (v["AttackDamageMax"] or 0) ~= 0) then
    		UNIT2POINT[k] = ((v["AttackDamageMax"] or 0) - (((v["AttackDamageMax"] or 0) - (v["AttackDamageMin"] or 0)) * 0.5)) + (1.7/(v["AttackRate"] or 1.7)*100) + (v['AttackRange'] or 100) - 100 + (v['StatusHealth'] or 0) + (v['StatusMana'] or 0)* 0.75 + (v['StatusHealthRegen'] or 0) * 20 + (v['StatusManaRegen'] or 0) * 10
    		if v['AttackCapabilities'] == "DOTA_UNIT_CAP_RANGED_ATTACK" then
    			UNIT2POINT[k] = UNIT2POINT[k] + 20
    		end
    		UNIT2POINT[k] = math.floor(UNIT2POINT[k])
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
UNIT2POINT = {

}
_G.FIGHT = false
VOTED_ID = {}
function BAW:speedup(t)
	local pid = t.PlayerID
	if _G.FIGHT and not table.contains(VOTED_ID,pid) then
		table.insert(VOTED_ID, pid)
		if #VOTED_ID >= PLAYERS then
			Convars:SetFloat("host_timescale", 3)
		end
	end
end
function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
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
PICKED_ID = {}
PLAYERS_ID = {}
PLAYERS = 0
function BAW:OnHeroPicked(t)
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
		self:StartGame()
	end
end
function table.copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end
PICKED = {}
ALIVES = {}
function removeFromTable(t,val)
	for k,v in pairs(t) do
		if v == val then
			table.remove(t, k)
		end
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
	Timers:CreateTimer(function()
		for d,e in pairs(ALIVES) do
			if #e > 0 then
				for k,v in pairs(e) do
					if not v:IsAlive() then
						removeFromTable(ALIVES[d],v)
					end
				end
			else
				for n,p in pairs(PICKED[d]) do
					p:SetHealth(p:GetHealth()-1)
				end
				BAW:StartGame()
				return nil
			end
		end
		return 1
	end)
end
ROUND = 0
POINTS = 1000
function BAW:StartGame()
	PICKED_ID = {}
	VOTED_ID = {}
	Convars:SetFloat("host_timescale", 1)
	for i,v in ipairs(PLAYERS_ID) do
		PlayerResource:GetPlayer(v):SetTeam(DOTA_TEAM_GOODGUYS)
	end

	-- Convars:SetFloat("host_timescale", 5)
	local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                              Vector(0, 0, 0),
                              nil,
                              FIND_UNITS_EVERYWHERE,
                              DOTA_UNIT_TARGET_TEAM_BOTH,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
	for i,v in ipairs(units) do
		if not v:IsControllableByAnyPlayer() then
			v:ForceKill(false)
		end
	end
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


    local cachepoints
    local cache = {}
    local teams = {left = {},right = {}}
    local cheapest = {POINTS,''}
    local cacheteams
    local check
    local rand
	-- cache = {}
	-- cheapest = {POINTS,''}
	-- teams = {left = {},right = {}}
	for k,v in pairs(UNIT2POINT) do
		if v <= POINTS then
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
	-- DeepPrintTable(teams)
	-- local sum = 0
	-- for k,v in pairs(teams) do
	-- 	sum = 0
	-- 	for i,p in ipairs(v) do
	-- 		sum = sum + p[1]
	-- 	end
	-- 	print(k..": "..sum)
	-- end
	POINTS = POINTS + 500
	DeepPrintTable(teams)
	local left = teams['left']
	local right = teams['right']


	PICKED = {left = {},right = {}}
	ALIVES = {left = {},right = {}}
	local leftpw = 0
	local lrightpw = 0
	for k,v in ipairs(left) do
		local unit = CreateUnitByName( v, Vector(-1280,-1088,128), true, nil, nil, DOTA_TEAM_GOODGUYS)
		if unit then
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
			unit.targetPoint = Vector(1280,1088,128)
			table.insert(ALIVES['left'],unit)
			leftpw = leftpw + UNIT2POINT[v]
		else
			error("UNIT NOT FOUND: "..v)
		end
	end
	for k,v in ipairs(right) do
		local unit = CreateUnitByName( v, Vector(1280,1088,128), true, nil, nil, DOTA_TEAM_GOODGUYS)
		if unit then
			for i=0,5 do
				local ab = unit:GetAbilityByIndex(i)
				if ab then
					ab:SetLevel(1)
					ab:SetActivated(true)
					ab:ToggleAutoCast()
				end
			end
			unit.targetPoint = Vector(-1280,-1088,128)
			table.insert(ALIVES['right'],unit)
			lrightpw = lrightpw + UNIT2POINT[v]
		else
			error("UNIT NOT FOUND: "..v)
		end
	end
	local ar = {left = {},right = {}}
	for k,v in pairs(ALIVES) do
		for e,u in pairs(v) do
			if k == "left" then
				table.insert(ar['left'],u:entindex())
			else
				table.insert(ar['right'],u:entindex())
			end
		end
	end
	ROUND = ROUND + 1
	CustomGameEventManager:Send_ServerToAllClients('new_round',{
		left=leftpw,
		right=lrightpw,
		indexes=ar
	})
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 10)
end
TEAMS = {
	{
		{
			"Kobolds",
			"npc_dota_neutral_kobold",
			"npc_dota_neutral_kobold",
			"npc_dota_neutral_kobold",
			"npc_dota_neutral_kobold_taskmaster",
			"npc_dota_neutral_kobold_tunneler",
		},
		{
			"Hill Trolls",
			"npc_dota_neutral_forest_troll_high_priest",
			"npc_dota_neutral_forest_troll_berserker",
			"npc_dota_neutral_forest_troll_berserker",
		},
		{
			"Hill Trolls and Kobold",
			"npc_dota_neutral_kobold_taskmaster",
			"npc_dota_neutral_forest_troll_berserker",
			"npc_dota_neutral_forest_troll_berserker",
		},
		{
			"Vhouls Assassins",
			"npc_dota_neutral_gnoll_assassin",
			"npc_dota_neutral_gnoll_assassin",
			"npc_dota_neutral_gnoll_assassin",
		},
		{
			"Ghosts",
			"npc_dota_neutral_gnoll_assassin",
			"npc_dota_neutral_gnoll_assassin",
			"npc_dota_neutral_gnoll_assassin",
		}
	},
	{
		{
			"Wolves",
			"npc_dota_neutral_alpha_wolf",
			"npc_dota_neutral_giant_wolf",
			"npc_dota_neutral_giant_wolf",
		},
		{
			"Centaurs",
			"npc_dota_neutral_centaur_khan",
			"npc_dota_neutral_centaur_outrunner",
		},
		{
			"Ogres",
			"npc_dota_neutral_ogre_magi",
			"npc_dota_neutral_ogre_mauler",
			"npc_dota_neutral_ogre_mauler",
		},
		-- {
		-- 	"Golems",
		-- 	"npc_dota_neutral_mud_golem",
		-- 	"npc_dota_neutral_mud_golem",
		-- },
	},
	{
		{
			"Centaurs",
			"npc_dota_neutral_centaur_khan",
			"npc_dota_neutral_centaur_outrunner",
			"npc_dota_neutral_centaur_outrunner",
		},
		{
			"Chickens",
			"npc_dota_neutral_enraged_wildkin",
			"npc_dota_neutral_wildkin",
			"npc_dota_neutral_wildkin",
		},
		{
			"Dark Trolls",
			"npc_dota_neutral_dark_troll",
			"npc_dota_neutral_dark_troll",
			"npc_dota_neutral_dark_troll_warlord",
		},
	},
	{
		{
			"Drakes",
			"npc_dota_neutral_black_drake",
			"npc_dota_neutral_black_dragon",
			"npc_dota_neutral_black_drake",
		},
		{
			"Golems",
			"npc_dota_neutral_granite_golem",
			"npc_dota_neutral_rock_golem",
			"npc_dota_neutral_rock_golem",
		},
		{
			"bLizards",
			"npc_dota_neutral_big_thunder_lizard",
			"npc_dota_neutral_small_thunder_lizard",
			"npc_dota_neutral_small_thunder_lizard",
		},
	}
}