if BAW == nil then
	BAW = class({})
end
require('timers')
function Precache( context )
end
function Activate()
	BAW:InitGameMode()
end
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

end
FIGHT = false
function BAW:Pick(t)
	local pid = t.PlayerID
	local pick = t.v
	local ply = PlayerResource:GetPlayer(pid)
	if not FIGHT then
		local hero = ply:GetAssignedHero()
		if pick == "right" then
			ply:SetTeam(DOTA_TEAM_BADGUYS)
			hero:SetTeam(DOTA_TEAM_BADGUYS)
		else
			ply:SetTeam(DOTA_TEAM_GOODGUYS)
			hero:SetTeam(DOTA_TEAM_GOODGUYS)
		end
		table.insert(PICKED[pick], hero)
		table.insert(PLAYERS_ID, pid)
		CustomGameEventManager:Send_ServerToAllClients('change_top',{
			left=#PICKED["left"],
			right=#PICKED["right"],
		})
		if #PLAYERS_ID >= PLAYERS then
			BAW:StartFight()
		end
	end
end
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
	FIGHT = true
	for k,v in pairs(ALIVES) do
		for e,u in pairs(v) do
			if k == "left" then
				u:MoveToPositionAggressive(Vector(1280,1088,128))
			else
				u:MoveToPositionAggressive(Vector(-1280,-1088,128))
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
function BAW:StartGame()
	for d,e in pairs(ALIVES) do
		for k,v in pairs(e) do
			if v:IsAlive() then
				v:ForceKill(false)
			end
		end
	end
	FIGHT = false
	local first = table.copy(TEAMS[RandomInt(1,#TEAMS)])
	local leftN = RandomInt(1,#first)
	local left = table.copy(first[leftN])
	table.remove(first, leftN)
	local rightN = RandomInt(1,#first)
	local right = table.copy(first[rightN])
	PICKED = {left = {},right = {}}
	ALIVES = {left = {},right = {}}
	for k,v in ipairs(left) do
		if k ~= 1 then
			local unit = CreateUnitByName( v, Vector(-1280,-1088,128), true, nil, nil, DOTA_TEAM_GOODGUYS)
			table.insert(ALIVES['left'],unit)
		end
	end
	for k,v in ipairs(right) do
		if k ~= 1 then
			local unit = CreateUnitByName( v, Vector(1280,1088,128), true, nil, nil, DOTA_TEAM_BADGUYS)
			table.insert(ALIVES['right'],unit)
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
	CustomGameEventManager:Send_ServerToAllClients('new_round',{
		left=left[1],
		right=right[1],
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