if BAW == nil then
	BAW = class({})

	_G.FIGHT = false
	UNIT2POINT = {}
	VOTED_ID = {}
	PICKED_ID = {}
	PLAYERS_ID = {}
	PICKED = {}
	ALIVES = {}
	_G.ROUND = 0
	POINTS = 1000
	ROUND_DURATION = 120
	VOTE_DURATION = 25
	NEXT_ROUND = {}

	PLAYER_READY = {}

	_G.LEFT_SPAWN_POS = Vector(-3260,0,303)
	_G.RIGHT_SPAWN_POS = Vector(3300,0,306)
end

require('timers')
require('utils')
require('bet')

require('ai_unit')
require('ai_hero')

require('webapi/init')

LinkLuaModifier("modifier_removed_hero", "modifiers/modifier_removed_hero", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_speedup", "modifiers/modifier_speedup", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spacing", "modifiers/modifier_spacing", LUA_MODIFIER_MOTION_NONE)

function Precache( context )
	--[[
	for k,v in pairs(HeroesKV) do
    	if type(v) == "table" and not bannedUnits[k] then
    		PrecacheUnitByNameAsync(k, context)
    	end
    end
    ]]
    PrecacheUnitByNameAsync("npc_dota_hero_wisp", context)
end

function Activate()
	BAW:InitGameMode()
end

_G.UnitsKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
_G.HeroesKV = LoadKeyValues("scripts/npc/npc_heroes.txt")
_G.AbilitiesKV = LoadKeyValues("scripts/npc/npc_abilities.txt")
_G.Items = LoadKeyValues("scripts/npc/items.txt")
_G.AbilityPowers = LoadKeyValues("scripts/kv/ability_power.txt")

require('itembuild')

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
	--npc_dota_hero_invoker = true,
	npc_dota_hero_wisp = true,
	npc_dota_hero_target_dummy = true,
	npc_dota_hero_base = true,
	npc_dota_goodguys_siege = true,
	npc_dota_goodguys_siege_upgraded = true,
	npc_dota_goodguys_siege_upgraded_mega = true, 
	npc_dota_badguys_siege = true,
	npc_dota_badguys_siege_upgraded = true,
	npc_dota_badguys_siege_upgraded_mega = true,


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
    GameRules:SetCustomGameSetupAutoLaunchDelay(5)
    GameRules:LockCustomGameSetupTeamAssignment(true)
    GameRules:EnableCustomGameSetupAutoLaunch(true)
	GameRules:SetHeroRespawnEnabled(false)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 8)
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

    ListenToGameEvent("dota_player_pick_hero",Dynamic_Wrap(self,"OnHeroPicked"),self)
	ListenToGameEvent("game_rules_state_change",Dynamic_Wrap(self,'OnGameRulesStateChange'),self)
	ListenToGameEvent("player_chat", Dynamic_Wrap(self, 'OnPlayerChat'), self)	
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'OnNPCSpawned'), self)
    
    CustomGameEventManager:RegisterListener("speedup", Dynamic_Wrap(self, 'SpeedUpRequest'))
	CustomGameEventManager:RegisterListener("player_ready_to_round", Dynamic_Wrap(self, 'PlayerReady'))
	
	-- Handle Unit Colors to represent Blue & Red Team
	self.m_TeamColors = {}
	self.m_TeamColors[DOTA_TEAM_GOODGUYS] = {0, 112, 223} -- Blue
	self.m_TeamColors[DOTA_TEAM_BADGUYS] = {224, 10, 10} -- Red

	for team = 0, (DOTA_TEAM_COUNT-1) do
		color = self.m_TeamColors[ team ]
		if color then
			SetTeamCustomHealthbarColor(team, color[1], color[2], color[3])
		end
	end


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
    	if type(v) == "table" and not bannedUnits[k] then
    		table.insert(_G.AllHeroes,k)
    	end
    end
    self:NextRoundUnits() 
end

function BAW:OnPlayerChat(event)	  
    local playerID = event.playerid
    local text = event.text
	local command = splitString(text, " ")

    if IsInToolsMode() then
        if command[1] == "next" then
        	if command[2] and table.contains(AllHeroes, command[2]) and command[3] and table.contains(AllHeroes, command[2]) then
        		local count = command[4] or 1
        		local teams = {
        			left = {},
        			right = {},
        		}

        		for i=1,count do 
					table.insert(teams.left, command[2])
					table.insert(teams.right, command[3])
        		end

        		NEXT_ROUND = {
					teams = teams,
					lefthero = command[2],
					righthero = command[3],
					heroes = true,
				}
        	end 
        end

        if command[1] == "win" then
        	GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
        end
    end
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

function BAW:SpeedUpRequest(event)
	local pid = event.PlayerID
	if _G.FIGHT and not VOTED_ID[pid] then
		VOTED_ID[pid] = true

		local count = 0
		local allVoted = true
		for pID=0,23 do
			if PlayerResource:IsValidTeamPlayerID(pID) and Gambling:GetGold(pID) > 0 and PlayerResource:GetConnectionState(pID) == DOTA_CONNECTION_STATE_CONNECTED then
				count = count + 1
				if not VOTED_ID[pID] then
					allVoted = false
				end
			end
		end

		local state = { players_voted = VOTED_ID, total_count = count, all_voted = allVoted}
		CustomNetTables:SetTableValue("game", "speedup_state", state)

		if allVoted then
			Convars:SetFloat("host_timescale", 3)
		end
	end
end

function BAW:PlayerReady(event) 
	local playerID = event.PlayerID

	if _G.FIGHT then return end
	if Gambling:GetGold(playerID) <= 0 then return end

	PLAYER_READY[playerID] = event.isReady == 1

	local bAllReady = true
	for pID=0,23 do
		if PlayerResource:IsValidTeamPlayerID(pID) and Gambling:GetGold(pID) > 0 and PlayerResource:GetConnectionState(pID) == DOTA_CONNECTION_STATE_CONNECTED then
			if not PLAYER_READY[pID] then
				bAllReady = false
			end
		end
	end

	if bAllReady then
		BAW:StartFight()
	end

end

function BAW:OnNPCSpawned(event)
	local unit = EntIndexToHScript( event.entindex )

	Timers:CreateTimer(1, function() 
		if unit and IsValidEntity(unit) and unit:IsRealHero() and not unit:IsControllableByAnyPlayer() then
			unit:AddNewModifier(nil, nil, "modifier_spacing", nil)
		end
	end)

	if not _G.FIGHT then return end
	
	if unit and not unit.InitAI and unit:GetUnitName() ~= "npc_dota_thinker" then
		unit.InitAI = true
		unit.targetPoint = Vector(0,0,0)
		unit:SetContextThink("OnUnitThink", function() return UnitAI:OnUnitThink(unit) end, 1)
	end

end

function BAW:OnHeroPicked(event)
	if event.player == -1 then
		return
	end

    local hero = EntIndexToHScript(event.heroindex)
    local playerownerid = hero:GetPlayerOwnerID()
    
    for i=0,6 do
    	local ab = hero:GetAbilityByIndex(i)
    	if ab then 
    		hero:RemoveAbility(ab:GetName())
    	end
    end
	hero:AddNewModifier(hero,nil,'modifier_removed_hero',{})
	table.insert(PLAYERS_ID, playerownerid)
end

function BAW:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
	elseif nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
	elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		if IsSoloGame() then
			--SendToConsole("dota_bot_populate")
			GameRules:AddBotPlayerWithEntityScript("npc_dota_hero_wisp", "Tommy", DOTA_TEAM_GOODGUYS, "", false)
			CustomNetTables:SetTableValue("game", "solo", { solo = true } )
		end
	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 10)
		Gambling:Init()
		self:StartGame()

		PlayerResource:SetCustomPlayerColor(0, 51, 117, 255)
	    PlayerResource:SetCustomPlayerColor(1, 102, 255, 191)
	    PlayerResource:SetCustomPlayerColor(2, 191, 0, 191)
	    PlayerResource:SetCustomPlayerColor(3, 243, 240, 11)
	    PlayerResource:SetCustomPlayerColor(4, 255, 107, 0)
	    PlayerResource:SetCustomPlayerColor(5, 254, 134, 194)
	    PlayerResource:SetCustomPlayerColor(6, 161, 180, 71)
	    PlayerResource:SetCustomPlayerColor(7, 101, 217, 247)
	    PlayerResource:SetCustomPlayerColor(8, 0, 131, 33)
	    PlayerResource:SetCustomPlayerColor(9, 164, 105, 0)
	end
end

function BAW:GameEnd(winner)
	GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
	CustomGameEventManager:Send_ServerToAllClients("game_winner", { winnerID = winner } )
end

function BAW:RoundEnd(loserTeam)
	Convars:SetFloat("host_timescale", 1)
	Gambling:RoundEnd(loserTeam)

	local state = { players_voted = {}, total_count = 1, all_voted = false}
	CustomNetTables:SetTableValue("game", "speedup_state", state)

	if IsSoloGame() then
		if Gambling:GetGold(PLAYERS_ID[1]) <= 0 then
			BAW:GameEnd(-1)
			return
		end
	else
		local lastOne = -1
		local playerCount = 0
		for pID=0,23 do
			if Gambling:GetGold(pID) > 0 then
				lastOne = pID
				playerCount = playerCount + 1
			end
		end

		if playerCount <= 1 then
			BAW:GameEnd(lastOne)
			return
		end
	end

--
	CustomGameEventManager:Send_ServerToAllClients("round_end", { 
		winnerTeam = loserTeam == "left" and "right" or "left",
		bets = Gambling.history[#Gambling.history],
	})

	Timers:CreateTimer(5, function()
		BAW:StartGame()
	end)
end

function IsIgnored(unit)
	local ignoredUnitNames = {
		"npc_dota_thinker",
		"npc_dota_observer_wards",
		"npc_dota_elder_titan_ancestral_spirit",
	}

	if unit:IsIllusion() then
		return true
	end

	if unit:HasModifier("modifier_monkey_king_fur_army_soldier_hidden") then
		return true
	end

	local unitName = unit:GetUnitName()
	for _,name in pairs(ignoredUnitNames) do
		if name == unitName then
			return true
		end
	end

	return false
end

function BAW:FightThink()
	local unitType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING
	local unitFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE+DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD

	if not _G.FIGHT then return end

	ALIVES = {
		left = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0), nil, 10000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, unitType, unitFlags, FIND_UNITS_EVERYWHERE, false),
		right = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, 10000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, unitType, unitFlags, FIND_UNITS_EVERYWHERE, false)
	}

	for d,e in pairs(ALIVES) do
		local count = 0
		for i,v in ipairs(e) do
			if not v:IsControllableByAnyPlayer() and not IsIgnored(v) then
				count = count + 1
			end

			if not v:IsControllableByAnyPlayer() and not v.InitAI then
				v.InitAI = true
				v.targetPoint = Vector(0,0,0)
				if v:IsRealHero() then
					v:SetContextThink("OnHeroThink", function() return HeroAI:OnHeroThink(v) end, 1)
				else
					v:SetContextThink("OnUnitThink", function() return UnitAI:OnUnitThink(v) end, 1)
				end
			end
		end

		if count <= 0 then
			BAW:RoundEnd(d)
			return nil
		end
	end

	return 1
end

function BAW:StartFight()
	_G.FIGHT = true
	PLAYER_READY = {}
	Timers:RemoveTimer("VoteTime")
	Gambling:RoundStart()

	for team,v in pairs(ALIVES) do
		for e,unit in pairs(v) do
			if team == "left" then
				unit:SetTeam(DOTA_TEAM_GOODGUYS)
			else
				unit:SetTeam(DOTA_TEAM_BADGUYS)
			end

			unit:AddNewModifier(nil, nil, "modifier_speedup", {duration = 3})
		end
	end

	CustomGameEventManager:Send_ServerToAllClients("camera_position", { vector = Vector(0,0,0)} )
	CustomGameEventManager:Send_ServerToAllClients("hide_versus",{})
	CustomGameEventManager:Send_ServerToAllClients("new_timer", { time = ROUND_DURATION, start_time = GameRules:GetGameTime() } )
	CustomGameEventManager:Send_ServerToAllClients("start_fight", nil)

	Timers:CreateTimer( function() return BAW:FightThink() end)
	Timers:CreateTimer("RoundTime" , {
		endTime = ROUND_DURATION,
		callback = function() BAW:StartGame() end
	})
end

-- Predetermined Teams Table
predeterminedTeams = 
{
	-- Round tables are written as below:
	-- Don't remove this block, this is a placeholder for random hero rounds
	{
		left = {
			--lefthero1,
			--lefthero2,
			--lefthero3,
			--lefthero4,
			--lefthero5,
			--lefthero,
		},

		right = {
			--righthero1,
			--righthero2,
			--righthero3,
			--righthero4,
			--righthero5,
			--righthero,
		}
	},

	-- [PREDEFINED ROUND] OG vs Team Liquid - TI 9 Finals - Match 3
	{
		left = {
			AllHeroes[47] -- Faceless Void
			AllHeroes[10] -- Tiny
			AllHeroes[3] -- Pugna
			AllHeroes[50] -- Enchantress
			AllHeroes[25] -- Grimstroke
		},

		right = {
			AllHeroes[106] -- Juggernaut
			AllHeroes[22] -- Templar Assassin
			AllHeroes[6] -- Tidehunter
			AllHeroes[5] -- Ogre Magi
			AllHeroes[68] -- Rubick
		}
	},

	-- [PREDEFINED ROUND] OG vs Team Liquid - TI 9 Finals - Match 2
	{
		left = {
			AllHeroes[87] -- Zeus
			AllHeroes[113] -- Ember Spirit
			AllHeroes[10] -- Tiny
			AllHeroes[89] -- Omniknight
			AllHeroes[25] -- Grimstroke
		},

		right = {
			AllHeroes[46] -- Lifestealer
			AllHeroes[22] -- Templar Assassin
			AllHeroes[6] -- Tidehunter
			AllHeroes[99] -- Shadow Shaman
			AllHeroes[15] -- Enigma
		}
	},

	-- [PREDEFINED ROUND] OG vs PSG.LGD - TI 8 Finals - Match 5
	{
		left = {
			AllHeroes[113] -- Ember Spirit
			AllHeroes[87] -- Zeus
			AllHeroes[91] -- Nature's Prophet
			AllHeroes[26] -- Magnus
			AllHeroes[68] -- Rubick
		},

		right = {
			AllHeroes[70] -- Terrorblade
			AllHeroes[37] -- Kunkka
			AllHeroes[71] -- Batrider
			AllHeroes[49] -- Earthshaker
			AllHeroes[83] -- Silencer
		}
	},
	
	-- [PREDEFINED ROUND] OG vs PSG.LGD - TI 8 Finals - Match 1
	{
		left = {
			AllHeroes[84] -- Spectre
			AllHeroes[37] -- Kunkka
			AllHeroes[45] -- Treant Protector
			AllHeroes[49] -- Earthshaker
			AllHeroes[40] -- Winter Wyvern
		},

		right = {
			AllHeroes[104] -- Bloodseeker
			AllHeroes[100] -- Storm Spirit
			AllHeroes[63] -- Elder Titan
			AllHeroes[50] -- Enchantress
			AllHeroes[92] -- Crystal Maiden
		}
	},

	-- [PREDEFINED ROUND] Team Secret vs OG - OMEGA League: Immortal Division Finals - Match 2
	{
		left = {
			lefthero1 = AllHeroes[46] -- Lifestealer
			lefthero2 = AllHeroes[82] -- Outworld Devourer
			lefthero3 = AllHeroes[104] -- Bloodseeker
			lefthero4 = AllHeroes[50] -- Enchantress
			lefthero5 = AllHeroes[51] -- Earth Spirit
		},

		right = {
			AllHeroes[58] -- Troll Warlord
			AllHeroes[10] -- Tiny
			AllHeroes[55] -- Tusk
			AllHeroes[89] -- Omniknight
			AllHeroes[25] -- Grimstroke
		}
	},

	-- [PREDEFINED ROUND] Nigma vs OG - OMEGA League: Immortal Division LBF - Match 1
	{
		left = {
			AllHeroes[98] -- Sven
			AllHeroes[26] -- Magnus
			AllHeroes[104] -- Nature's Prophet
			AllHeroes[49] -- Earthshaker
			AllHeroes[9] -- Windranger
		},
	
		right = {
			AllHeroes[70] -- Terrorblade
			AllHeroes[116] -- Viper
			AllHeroes[44] -- Phoenix
			AllHeroes[31] -- Sand King
			AllHeroes[67] -- Disruptor
		}
	},

	-- PREDEFINED ROUND] Nigma vs OG - OMEGA League: Immortal Division LBF - Match 2
	{
		left = {
			AllHeroes[37] -- Kunkka
			AllHeroes[10] -- Tiny
			AllHeroes[44] -- Phoenix
			AllHeroes[45] -- Treant Protector
			AllHeroes[63] -- Elder Titan
		},
	
		right = {
			AllHeroes[28] -- Slark
			AllHeroes[26] -- Magnus
			AllHeroes[19] -- Timbersaw
			AllHeroes[68] -- Rubick
			AllHeroes[97] -- Vengeful Spirit
		}
	},

	-- [PREDEFINED ROUND] OG vs Secret - OMEGA League: Immortal Division UBF - Match 2
	{
		left = {
			AllHeroes[11] -- Morphling
			AllHeroes[85] -- Invoker
			AllHeroes[41] -- Underlord
			AllHeroes[54] -- Dark Willow
			AllHeroes[63] -- Elder Titan
		},
	
		right = {
			AllHeroes[22] -- Templar Assassin
			AllHeroes[91] -- Nature's Prophet
			AllHeroes[74] -- Mars
			AllHeroes[44] -- Phoenix
			AllHeroes[76] -- Shadow Demon
		}
	},
	
	-- [PREDEFINED ROUND] Evil Geniuses vs Alliance - OMEGA League: Immortal Division Lower Bracket Round 2 - Match 2
	{
		left = {
			AllHeroes[47] -- Faceless Void
			AllHeroes[85] -- Invoker
			AllHeroes[30] -- Abaddon
			AllHeroes[50] -- Enchantress
			AllHeroes[51] -- Earth Spirit
		},
	
		right = {
			AllHeroes[98] -- Sven
			AllHeroes[10] -- Tiny
			AllHeroes[80] -- Axe
			AllHeroes[44] -- Phoenix
			AllHeroes[8] -- Jakiro
		}
	},
	
	-- [PREDEFINED ROUND] Vici Gaming vs Team DK - The International 2013 - Match 1
	{
		left = {
			AllHeroes[52] -- Leshrac
			AllHeroes[18] -- Razor
			AllHeroes[91] -- Nature's Prophet
			AllHeroes[3] -- Pugna
			AllHeroes[76] -- Shadow Demon
		},
	
		right = {
			AllHeroes[33] -- Anti Mage
			AllHeroes[110] -- Tinker
			AllHeroes[79] -- Beastmaster
			AllHeroes[69] -- Undying
			AllHeroes[99] -- Shadow Shaman
		}
	},
}

predeterminedSingleHeroTeams =
{
	-- Different template, more direct:
	--[[
	{
		lefthero = AllHeroes[10] -- Left side composed entirely of this hero
		righthero = AllHeroes[10] -- Right side composed entirely of this hero
	},
	]]

	-- [PREDEFINED ROUND] Tiny vs Tiny
	{
		lefthero = AllHeroes[10] -- Tiny
		righthero = AllHeroes[10] -- Tiny
	},

	-- [PREDEFINED ROUND] Techies vs Techies
	{
		lefthero = AllHeroes[42] -- Techies
		righthero = AllHeroes[42] -- Techies
	},

	-- [PREDEFINED ROUND] Faceless Void vs Faceless Void 
	{
		lefthero = AllHeroes[47] -- Faceless Void 
		righthero = AllHeroes[47] -- Faceless Void 
	},

	-- [PREDEFINED ROUND] Zeus vs Mars
	{
		lefthero = AllHeroes[87] -- Zeus 
		righthero = AllHeroes[74] -- Mars
	},

	-- [PREDEFINED ROUND] Zeus vs Skywrath Mage
	{
		lefthero = AllHeroes[87] -- Zeus 
		righthero = AllHeroes[105] -- Skywrath Mage
	},

	-- [PREDEFINED ROUND] Vengeful Spirit vs Skywrath Mage
	{
		lefthero = AllHeroes[97] -- Vengeful Spirit 
		righthero = AllHeroes[105] -- Skywrath Mage
	},

	-- [PREDEFINED ROUND] Lina vs Crystal Maiden
	{
		lefthero = AllHeroes[23] -- Lina 
		righthero = AllHeroes[92] -- Crystal Maiden
	},

	-- [PREDEFINED ROUND] Rubick vs Invoker
	{
		lefthero = AllHeroes[68] -- Rubick 
		righthero = AllHeroes[85] -- Invoker
	},

	-- [PREDEFINED ROUND] Anti Mage vs Terrorblade
	{
		lefthero = AllHeroes[33] -- Anti Mage 
		righthero = AllHeroes[70] -- Terrorblade
	},

	-- [PREDEFINED ROUND] Chaos Knight vs Keeper of the Light
	{
		lefthero = AllHeroes[115] -- Chaos Knight
		righthero = AllHeroes[60] -- Keeper of the Light
	},

	-- [PREDEFINED ROUND] Shadow Fiend vs Doom
	{
		lefthero = AllHeroes[65] -- Shadow Fiend
		righthero = AllHeroes[94] -- Doom
	},

	-- [PREDEFINED ROUND] Tinker vs Tinker
	{
		lefthero = AllHeroes[110] -- Tinker
		righthero = AllHeroes[110] -- Tinker
	},

	-- [PREDEFINED ROUND] Storm Spirit vs Ember Spirit
	{
		lefthero = AllHeroes[100] -- Storm Spirit
		righthero = AllHeroes[113] -- Ember Spirit
	},
	
	-- [PREDEFINED ROUND] Huskar vs Dazzle
	{
		lefthero = AllHeroes[24] -- Huskar
		righthero = AllHeroes[66] -- Dazzle
	},

	-- [PREDEFINED ROUND] Naga Siren vs Slardar
	{
		lefthero = AllHeroes[4] -- Naga Siren
		righthero = AllHeroes[7] -- Slardar
	},

	-- [PREDEFINED ROUND] Omniknight vs Windranger (Slacks vs Windranger)
	{
		lefthero = AllHeroes[59] -- Omniknight
		righthero = AllHeroes[9] -- Windranger
	},

	-- [PREDEFINED ROUND] Nature's Prophet vs Timbersaw
	{
		lefthero = AllHeroes[91] -- Nature's Prophet
		righthero = AllHeroes[19] -- Timbersaw
	},

	-- [PREDEFINED ROUND] Treant vs Timbersaw
	{
		lefthero = AllHeroes[45] -- Treant
		righthero = AllHeroes[19] -- Timbersaw
	},

	-- [PREDEFINED ROUND] Anti-Mage vs Invoker
	{
		lefthero = AllHeroes[33] -- Anti-Mage
		righthero = AllHeroes[85] -- Invoker
	},

	-- [PREDEFINED ROUND] Phantom Lancer vs Phantom Assassin
	{
		lefthero = AllHeroes[61] -- Phantom Lancer
		righthero = AllHeroes[73] -- Phantom Assassin
	},

	-- [PREDEFINED ROUND] Windranger vs Drow Ranger
	{
		lefthero = AllHeroes[9] -- Windranger
		righthero = AllHeroes[2] -- Drow Ranger
	},
	
	-- [PREDEFINED ROUND] Enigma vs Enigma
	{
		lefthero = AllHeroes[15] -- Enigma
		righthero = AllHeroes[15] -- Enigma
	},

	-- [PREDEFINED ROUND] Axe vs Legion Commander
	{
		lefthero = AllHeroes[80] -- Axe
		righthero = AllHeroes[34] -- Legion Commander
	},

	-- [PREDEFINED ROUND] Centaur Warrunner vs Magnus
	{
		lefthero = AllHeroes[57] -- Centaur Warrunner
		righthero = AllHeroes[26] -- Magnus
	},
	
	-- [PREDEFINED ROUND] Pudge vs Pudge
	{
		lefthero = AllHeroes[39] -- Pudge
		righthero = AllHeroes[39] -- Pudge
	},

	-- [PREDEFINED ROUND] Juggernaut vs Juggernaut
	{
		lefthero = AllHeroes[106] -- Juggernaut
		righthero = AllHeroes[106] -- Juggernaut
	},
}

function BAW:NextRoundUnits() 
	local heroes = RollPercentage(75)
	if _G.ROUND == 0 then
		heroes = false
	end

	local minPoints = POINTS * 0.05
	local leftHero, rightHero
	local lefthero1
	local lefthero2
	local lefthero3
	local lefthero4
	local lefthero5
	local righthero1
	local righthero2
	local righthero3
	local righthero4
	local righthero5
	local teams = {left = {}, right = {}}
	
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
			if v <= POINTS --[[and v >= minPoints]] then
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
	end
	
	if heroes then -- If round uses a premade setup given in the tables
		local DetermineRound = RandomInt(1, #predeterminedTeams + #predeterminedSingleHeroTeams)
		print("Printing DetermineRound Random: " .. DetermineRound)
		local howmany = RandomInt(1, 5)

		-- Predetermined Teams Check
		if DetermineRound <= #predeterminedTeams then
			-- Random hero vs Random hero round
			if DetermineRound == 1 then
				print("Random Hero Function")
				predeterminedTeams[1] = {left = {}, right = {}}

				local leftsidehero = AllHeroes[RandomInt(1, #AllHeroes)]
				local rightsidehero = AllHeroes[RandomInt(1, #AllHeroes)]

				for i=1,howmany do
					table.insert(predeterminedTeams[1]['left'], leftsidehero)
					table.insert(predeterminedTeams[1]['right'], rightsidehero)
				end
			end

			-- Setting teams
			teams['left'] = predeterminedTeams[DetermineRound]['left']
			teams['right'] = predeterminedTeams[DetermineRound]['right']
			
			lefthero1 = teams['left'][1]
			lefthero2 = teams['left'][2]
			lefthero3 = teams['left'][3]
			lefthero4 = teams['left'][4]
			lefthero5 = teams['left'][5]

			righthero1 = teams['right'][1]
			righthero2 = teams['right'][2]
			righthero3 = teams['right'][3]
			righthero4 = teams['right'][4]
			righthero5 = teams['right'][5]
		else
			-- Shifting index for table accessibility
			DetermineRound = DetermineRound - #predeterminedTeams

			-- Setting teams
			lefthero = predeterminedSingleHeroTeams[DetermineRound]['lefthero']
			righthero = predeterminedSingleHeroTeams[DetermineRound]['righthero']

			for i=1,howmany do
				table.insert(teams['left'], lefthero)
				table.insert(teams['right'], righthero)
			end
		end
	end 	
	
	NEXT_ROUND = {
		teams = teams,
		lefthero = lefthero,
		righthero = righthero,
		lefthero1 = lefthero1,
		lefthero2 = lefthero2,
		lefthero3 = lefthero3,
		lefthero4 = lefthero4,
		lefthero5 = lefthero5,
		righthero1 = righthero1,
		righthero2 = righthero2,
		righthero3 = righthero3,
		righthero4 = righthero4,
		righthero5 = righthero5,
		heroes = heroes,
	}
	return teams, leftHero, rightHero, lefthero1, lefthero2, lefthero3, lefthero4, lefthero5, righthero1, righthero2, righthero3, righthero4, righthero5
end

function BAW:CleanMap()
	local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
          Vector(0, 0, 0),
          nil,
          10000,
          DOTA_UNIT_TARGET_TEAM_BOTH,
          DOTA_UNIT_TARGET_ALL,
          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE+DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD+DOTA_UNIT_TARGET_FLAG_DEAD,
          FIND_UNITS_EVERYWHERE,
          false)
	
	for i,v in ipairs(units) do
		if IsValidEntity(v) and not v:IsControllableByAnyPlayer() then
			v:ForceKill(false)
			if IsValidEntity(v) then
				v:RemoveSelf()
			end
		end
	end
	
	local ent = Entities:First()
	while ent do
		if ent and not ent:IsNull() then
		    if (ent.IsItem and ent:IsItem()) or ent.bawcreep or ent:GetClassname() == "dota_item_drop" or ent:GetClassname() == "dota_temp_tree" then
		    	ent:RemoveSelf()
		    end
		end
	    ent = Entities:Next(ent)
	end

	local thinkers = Entities:FindAllByClassname("npc_dota_thinker")
	for _,think in ipairs(thinkers) do
		think:ForceKill(false)
	end

	local lastParticleID = ParticleManager:CreateParticle( "particles/dev/library/base_ranged_attack.vpcf", PATTACH_ABSORIGIN, nil)
	for i = lastParticleID, lastParticleID-500, -1 do
		if i > 0 then
			--print(i)
			ParticleManager:DestroyParticle(i, true)
		else
			break
		end
	end

end


function GetHeroSkillBuild(heroName, level)
	local skillBuild = {}
	local abilityIndexes = {0,1,2}

	if heroName == "npc_dota_hero_nevermore" then
		abilityIndexes = {0,3,4}
	end

	if heroName == "npc_dota_hero_monkey_king" or heroName == "npc_dota_hero_troll_warlord" then
		abilityIndexes = {0,1,3}
	end

	local levels = {}

	for _,abi in pairs(abilityIndexes) do
		levels[abi] = 0
	end
	levels[5] = 0  --ultimate, always has abilityIndex 5

	local maxLevel = heroName == "npc_dota_hero_invoker" and 7 or 4

	--skill build is randomized 
	for i=1,level do
		if i > 5 and math.fmod(i,5) == 0 then --talents
			skillBuild[i] = RandomInt(0,1)+((math.floor(i/5)-2)*2)
		else
			if math.fmod(i,6) == 0 and heroName ~= "npc_dota_hero_invoker" and levels[5] < 3 then --ultimate
				levels[5] = levels[5] + 1
				skillBuild[i] = 5
			else --other abilities
				while #abilityIndexes > 0 do
					local rand = RandomInt(1, #abilityIndexes)
					local ability = abilityIndexes[rand]
					--local abilityName = _G.HeroesKV[heroName]["Ability"..ability+1]

					if skillBuild[i-1] ~= ability or i>=7 then
						levels[ability] = levels[ability] + 1
						skillBuild[i] = ability

						if levels[ability] >= maxLevel then
							table.remove(abilityIndexes, rand)
						end

						break
					end
				end
			end

		end
	end

	return skillBuild
end

--DeepPrintTable(GetHeroSkillBuild("npc_dota_hero_invoker",26))

function UpgradeHeroAbilities(unit, skillBuild)
	local abilityTalentStart = GetHeroFirstTalentID(unit)

	for i=1,30 do
		if skillBuild[i] then
			if i > 5 and math.fmod(i,5) == 0 then
				local talent = unit:GetAbilityByIndex(abilityTalentStart+skillBuild[i])

				if talent then
					TrainTalent(unit, talent)
				end
			else
				local ability = unit:GetAbilityByIndex(skillBuild[i])

				if ability then
					ability:UpgradeAbility(true)
				end
			end
		end
	end
end

function BAW:StartGame()
	PICKED_ID = {}
	VOTED_ID = {}
	Timers:RemoveTimer("RoundTime")

	_G.FIGHT = false

	for i,v in ipairs(PLAYERS_ID) do
		PlayerResource:GetPlayer(v):SetTeam(DOTA_TEAM_GOODGUYS)
	end

	BAW:CleanMap()

	Gambling:NewRound()

	local heroes = NEXT_ROUND.heroes
    local teams = NEXT_ROUND.teams
    local lefthero = NEXT_ROUND.lefthero
    local righthero = NEXT_ROUND.righthero
	local lefthero1 = NEXT_ROUND.lefthero1
	local lefthero2 = NEXT_ROUND.lefthero2
	local lefthero3 = NEXT_ROUND.lefthero3
	local lefthero4 = NEXT_ROUND.lefthero4
	local lefthero5 = NEXT_ROUND.lefthero5
	local righthero1 = NEXT_ROUND.righthero1
	local righthero2 = NEXT_ROUND.righthero2
	local righthero3 = NEXT_ROUND.righthero3
	local righthero4 = NEXT_ROUND.righthero4
	local righthero5 = NEXT_ROUND.righthero5
    local level
    local leftSkillBuild, rightSkillBuild
	local predefinedleftSkillBuild, predefinedrightSkillBuild

	if heroes then
		level = RandomInt(1, 4)
		if level == 1 then
			level = 1
		elseif level == 2 then
			level = 6
		elseif level == 3 then
			level = 16
		elseif level == 4 then
			level = 30
		end
		
		for i=1, 5 do
			predefinedleftSkillBuild = GetHeroSkillBuild("lefthero" .. i, level)
			predefinedrightSkillBuild = GetHeroSkillBuild("righthero" .. i, level)
		end

		leftSkillBuild = GetHeroSkillBuild(lefthero, level)
		rightSkillBuild = GetHeroSkillBuild(righthero, level)
	end
	
	local left = teams['left']
	local right = teams['right']
	local itemsg = false

	if RollPercentage(50) and heroes then
		itemsg = true
	end

	local itemsArRight = {}
	local itemsArLeft = {}
	local itemsArRightpredefined = {}
	local itemsArLeftpredefined = {}
	if itemsg then
		itemsArRight = GetHeroBuild(righthero, level)
		itemsArLeft = GetHeroBuild(lefthero, level)
		for i=1, 5 do
			itemsArRightpredefined = GetHeroBuild("righthero" .. i, level)
			itemsArLeftpredefined = GetHeroBuild("lefthero" .. i, level)
		end
	end
	POINTS = POINTS + 500
	PICKED = {left = {},right = {}}
	ALIVES = {left = {},right = {}}
	
	local leftpw = 0
	local rightpw = 0

	local yDist = 125
	local yDiff = - (math.floor(#left/2) * yDist)

	for k,v in ipairs(left) do
		local spawnPos = Vector_clone(LEFT_SPAWN_POS)

		if heroes then 
			spawnPos.y = spawnPos.y + yDiff
			spawnPos.x = spawnPos.x + RandomInt(-50, 50)
		end
		yDiff = yDiff + yDist

		leftpw, unit = BAW:SpawnUnits(v, "left", spawnPos, Vector(0,0,0), leftpw)

		if unit:GetHullRadius() < 45 and not unit:IsHero() then
			unit:SetHullRadius(45)
		end
		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		
		if unit and heroes and unit:IsRealHero() then
			for i=1,level-1 do
				unit:HeroLevelUp(false)
			end
			UpgradeHeroAbilities(unit, leftSkillBuild)
			UpgradeHeroAbilities(unit, predefinedleftSkillBuild)
			
		end

		for i,v in ipairs(itemsArLeft) do
			unit:AddItemByName(v)
		end
		for i,v in ipairs(itemsArLeftpredefined) do
			unit:AddItemByName(v)
		end
	end

	yDiff = - (math.floor(#right/2) * 100)

	for k,v in ipairs(right) do
		local spawnPos = Vector_clone(RIGHT_SPAWN_POS)

		if heroes then 
			spawnPos.y = spawnPos.y + yDiff
			spawnPos.x = spawnPos.x + RandomInt(-50, 50)
		end
		yDiff = yDiff + yDist

		rightpw, unit = BAW:SpawnUnits(v,"right", spawnPos, Vector(0,0,0), rightpw)

		if unit:GetHullRadius() < 45 and not unit:IsHero() then
			unit:SetHullRadius(45)
		end
		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)

		if heroes and unit:IsRealHero() then
			for i=1,level-1 do
				unit:HeroLevelUp(false)
			end
			UpgradeHeroAbilities(unit, rightSkillBuild)
			UpgradeHeroAbilities(unit, predefinedrightSkillBuild)
		end
		
		for i,v in ipairs(itemsArRight) do
			unit:AddItemByName(v)
		end
		for i,v in ipairs(itemsArRightpredefined) do
			unit:AddItemByName(v)
		end
	end

	local ar = {left = {},right = {},regens = {}}
	local index
	for team,v in pairs(ALIVES) do
		for e,unit in pairs(v) do
			index = unit:entindex()
			ar['regens'][index] = {unit:GetHealthRegen(), unit:GetManaRegen(), unit:GetSecondsPerAttack(), unit:Script_GetAttackRange(), unit:GetPhysicalArmorValue(false), unit:GetAverageTrueAttackDamage(nil)}
			if team == "left" then
				table.insert(ar['left'], index)
			else
				table.insert(ar['right'], index)
			end
		end
	end

	_G.ROUND = _G.ROUND + 1

	CustomGameEventManager:Send_ServerToAllClients('new_round', {
		left = leftpw,
		right = rightpw,
		indexes = ar
	})
	
	CustomGameEventManager:Send_ServerToAllClients('new_timer', { time = VOTE_DURATION, start_time = GameRules:GetGameTime() } )
	Timers:CreateTimer("VoteTime", {
		endTime = VOTE_DURATION,
		callback = function() BAW:StartFight() end
	})

	self:NextRoundUnits() 

	Timers:CreateTimer(2, function() 
		local unitList = vlua.clone(NEXT_ROUND.teams.left)
		vlua.extend(unitList, NEXT_ROUND.teams.right)
		PrecacheUnitList(unitList)
	end)
end

function BAW:SpawnUnits(v,team,vec,target,points)
	local unit = CreateUnitByName( v, vec, true, nil, nil, DOTA_TEAM_GOODGUYS)
	if unit then
		unit.bawcreep = true

		if not unit:IsRealHero() then
			for i=0,5 do
				local ab = unit:GetAbilityByIndex(i)
				if ab then
					ab:SetLevel(1)
					ab:SetActivated(true)
					--ab:ToggleAutoCast()
				end
			end
		end
		unit.targetPoint = target
		table.insert(ALIVES[team],unit)
		points = points + (UNIT2POINT[v] or 0)
	else
		error("UNIT NOT FOUND: "..v)
	end
	return points,unit
end