"use strict"

function GetHeroFirstTalentID(heroID) {
	for (let i = 0; i < 24; i++) {
		const abilityName = Abilities.GetAbilityName(Entities.GetAbility(heroID, i))

		if (abilityName.includes("special_bonus"))
			return i
	}

	return -1
}

function LuaTableToArrayDec(nt) {
	var result = []
	for (var i in nt) {
		result[i-1] = nt[i]
	}
	return result
}

function LuaTableToArray(nt) {
	var result = []
	for (var i in nt) {
		result[i] = nt[i]
	}
	return result
}

function GroupUnits(originalArray) {
	let count = {}
	let unitIDs = {}
	originalArray.forEach(function(unitID, index) {
		const unitName = Entities.GetUnitName(unitID)
		count[unitName] = count[unitName] ? count[unitName] + 1 : 1 

		const arr = unitIDs[unitName]
		if (arr) {
			arr.push(unitID)
		}
		else {
			unitIDs[unitName] = [unitID]
		}
		
	})

	let newArray = []
	originalArray.forEach(function(unitID) {
		const unitName = Entities.GetUnitName(unitID)
		const isHero = unitName.includes("npc_dota_hero")

		if (count[unitName] >= 2 && !isHero) {
			if (unitIDs[unitName]) {
				const ids = unitIDs[unitName]
				delete unitIDs[unitName]
				newArray.push(ids)
			}
		}
		else {
			newArray.push(unitID)
		}
	})

	return newArray
}

function FormatTime(seconds) {
	seconds = Math.ceil(seconds)
	const minuts = Math.floor(seconds/60) 
	const sec = seconds % 60
	return (minuts > 9 ? ""+minuts : "0"+minuts) + ":" + (sec > 9 ? ""+sec : "0"+sec)
}

function GetPlayerColor(pID) {
	var color = Players.GetPlayerColor( pID ).toString(16);
	color = color.substring(6, 8) + color.substring(4, 6) + color.substring(2, 4) + color.substring(0, 2);
	return "#" + color;
}

GameEvents.Subscribe("server_print", (event) => $.Msg(`[Server] ${event.message}`));
