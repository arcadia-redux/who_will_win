WebApi = WebApi or {}
WebApi.playerSettings = WebApi.playerSettings or {}
for playerId = 0, 23 do
	WebApi.playerSettings[playerId] = WebApi.playerSettings[playerId] or {}
end
WebApi.matchId = IsInToolsMode() and RandomInt(-10000000, -1) or tonumber(tostring(GameRules:GetMatchID()))

local serverHost = IsInToolsMode() and "https://whowillwin.animus.software" or "https://whowillwin.animus.software"
local dedicatedServerKey = GetDedicatedServerKeyV2("1")

function WebApi:Send(path, data, onSuccess, onError, retryWhile)
	local request = CreateHTTPRequestScriptVM("POST", serverHost .. "/api/lua/" .. path)

	request:SetHTTPRequestHeaderValue("Dedicated-Server-Key", dedicatedServerKey)
	if data ~= nil then
		request:SetHTTPRequestRawPostBody("application/json", json.encode(data))
	end

	request:Send(function(response)
		print("RESPONSE status code: ", response.StatusCode)
		if response.StatusCode >= 200 and response.StatusCode < 300 then
			local data = json.decode(response.Body)
			if onSuccess then
				onSuccess(data)
			end
		else
			local err = json.decode(response.Body)
			if type(err) ~= "table" then err = {} end

			local message = (response.StatusCode == 0 and "Could not establish connection to the server. Please try again later.") or err.title or "Unknown error."
			if err.traceId then
				message = message .. " Report it to the developer with this id: " .. err.traceId
			end
			err.message = message

			if retryWhile and retryWhile(err) then
				WebApi:Send(path, data, onSuccess, onError, retryWhile)
			elseif onError then
				onError(err)
			end
		end
	end)
end

local function retryTimes(times)
	return function()
		times = times - 1
		return times >= 0
	end
end

function WebApi:BeforeMatch()
	local players = {}
	for playerId = 0, 23 do
		if PlayerResource:IsValidPlayerID(playerId) then
			table.insert(players, tostring(PlayerResource:GetSteamID(playerId)))
		end
	end

	WebApi:Send("match/before", { mapName = GetMapName(), players = players }, function(data)
		print("BEFORE MATCH")
		table.print(data)
		CustomNetTables:SetTableValue("leaderboards", "rounds", data.leaderboards)

		WebApi.player_ratings = {}
		for _, player in ipairs(data.players) do
			local playerId = GetPlayerIdBySteamId(player.steamId)
			if player.settings then
				WebApi.playerSettings[playerId] = player.settings
				--ErrorTracking.Try(HeroBuilder.PlayerSettingsLoaded, HeroBuilder, playerId, player.settings)
			end
			CustomNetTables:SetTableValue("leaderboards", "player_stats", player)
		end
	end, 
	function(err)
		print(err.message)
	end
	, retryTimes(2))
end

WebApi.scheduledUpdateSettingsPlayers = WebApi.scheduledUpdateSettingsPlayers or {}
function WebApi:ScheduleUpdateSettings(playerId)
	WebApi.scheduledUpdateSettingsPlayers[playerId] = true

	if WebApi.updateSettingsTimer then Timers:RemoveTimer(WebApi.updateSettingsTimer) end
	WebApi.updateSettingsTimer = Timers:CreateTimer(10, function()
		WebApi.updateSettingsTimer = nil

		local players = {}
		for playerId = 0, 23 do
			if PlayerResource:IsValidPlayerID(playerId) and WebApi.scheduledUpdateSettingsPlayers[playerId] then
				local settings = WebApi.playerSettings[playerId]
				if next(settings) ~= nil then
					local steamId = tostring(PlayerResource:GetSteamID(playerId))
					table.insert(players, { steamId = steamId, settings = settings })
				end
			end
		end

		WebApi:Send("match/update-settings", { players = players })
		WebApi.scheduledUpdateSettingsPlayers = {}
	end)
end

function WebApi:AfterMatchPlayer(player_id)
	if not IsInToolsMode() then
		if GameRules:IsCheatMode() then return end
		if GameRules:GetDOTATime(false, true) < 60 then return end
	end

	local requestBody = {
		mapName = GetMapName(),
		matchId = WebApi.matchId,
		duration = GameRules:GetGameTime(),
		players = {},
	}

	for player_id = 0, 23 do
		if IsValidPlayerID(player_id) then
			table.insert(requestBody.players, {
				-- THIS NEEDS ACTUAL LOGIC, CURRENTLY THOSE NUMBERS ARE PLACEHOLDERS
				steamId = PlayerResource:GetSteamID(player_id),
				roundsWon = 0,
				roundsLost = 0,
				totalBets = 0,
				biggestProfit = 0,
				biggestLost = 0,
				isWinner = false,
			})
		end
	end
	table.print(requestBody.players)
	WebApi:Send(
		"match/after_match_player", 
		requestBody, 
		function(resp)
			print("After match success!")
			table.print(resp)
		end,
		function(err)
			print("Remote sending error: ", err)
			table.print(err)
		end
	)
end

RegisterGameEventListener("player_connect_full", function()
	print("LOADED WEBAPI")
	if WebApi.firstPlayerLoaded then return end
	WebApi.firstPlayerLoaded = true
	WebApi:BeforeMatch()
end)
