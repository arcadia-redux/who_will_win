Payments = Payments or {}

RegisterCustomEventListener("payments:create", function(event)
	local payerId = event.PlayerID
	local steamId = tostring(PlayerResource:GetSteamID(payerId))
	local matchId = tonumber(tostring(GameRules:GetMatchID()))

	WebApi:Send(
		"payment/create",
		{ steamId = steamId, matchId = matchId, method = event.method, paymentKind = event.paymentKind },
		function(response)
			local player = PlayerResource:GetPlayer(payerId)
			if not player then return end

			CustomGameEventManager:Send_ServerToPlayer(player, "payments:create", {
				id = event.id,
				url = response.url,
			})
		end,
		function(error)
			local player = PlayerResource:GetPlayer(payerId)
			if not player then return end

			CustomGameEventManager:Send_ServerToPlayer(player, "payments:create", {
				id = event.id,
				error = error.message,
			})
		end
	)
end)

Payments.openPaymentWindows = Payments.openPaymentWindows or {}
local function onPaymentWindowOpenStatusChange(args)
	local playerId = args.PlayerID
	if args.visible == 1 then
		Payments.openPaymentWindows[playerId] = true
		MatchEvents.RequestDelay = 5
	else
		Payments.openPaymentWindows[playerId] = nil
		if not next(Payments.openPaymentWindows) then
			MatchEvents.RequestDelay = MatchEvents.DEFAULT_REQUEST_DELAY
		end
	end
end

RegisterCustomEventListener("payments:window", onPaymentWindowOpenStatusChange)
RegisterGameEventListener("player_disconnect", function(args)
	onPaymentWindowOpenStatusChange({ PlayerID = args.PlayerID, visible = 0 })
end)

MatchEvents.ResponseHandlers.paymentUpdate = function(response)
	local steamId = response.steamId
	local playerId = GetPlayerIdBySteamId(steamId)

	if playerId == -1 then return end

	local player = PlayerResource:GetPlayer(playerId)
	if player then
		CustomGameEventManager:Send_ServerToPlayer(player, "payments:update", response)
	end

	if not response.error then
		if response.supporterState then
			Supporters:SetPlayerState(playerId, response.supporterState)
			BP_Inventory:UpdateLocalItems(Battlepass.steamid_map[playerId])
			BP_Inventory:UpdateAvailableItems(playerId)
			BP_PlayerProgress:UpdatePlayerInfo(playerId, true)
		end

		if response.purchasedItem then
			print("PLAYER PURCHASED ITEM")
			table.print(response.purchasedItem)
		end
	end
end
