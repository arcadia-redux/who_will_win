require 'res_def'
require 'color_helper'

function printf(...)
    print(string.format(...))
end

function ShowGolbalMessage(message)
    if(message ~= nil and string.len(message) > 0) then
        GameRules:SendCustomMessage(message, 0, 0)
    end
end

function ShowHeroMessage(steamId, heroName, message)
    CustomGameEventManager:Send_ServerToAllClients("SHOW_HERO_MESSAGE",
    {steamid = steamId, hero = heroName, message = message})
end

function LocalizeHero(heroName, language)
    for _, v in pairs(HeroNameLocalize) do
        if(v.name == heroName) then
            if(language == "schinese") then
                return v.schinese
            else
                return v.english
            end
        end
    end

    return heroName
end

function PlayerSay(message, playerId, teamOnly)
    local player = PlayerResource:GetPlayer(playerId)
    if(player == nil or player:IsNull()) then return end
    Say(player, message, teamOnly)
end

function ShowPlayerMessage(message, player)
    if(player == nil) then return end
    local teamColor = GameRules.DW.TeamColor[player:GetTeam()]
    if(teamColor == nil) then return end
    local cssColor = ColorHelper.TableToCssColor(teamColor)
    local colorMessage = "<font color='" .. cssColor .. "'>" .. message .. "</font>"
    
    GameRules:SendCustomMessage(colorMessage, player:GetTeam(), player:GetPlayerID())
end

function SendMessageToPlayer(playerId, messageType, messageData)
    local player = PlayerResource:GetPlayer(playerId)
    if(player ~= nil and player:IsNull() == false) then
        CustomGameEventManager:Send_ServerToPlayer(player, messageType, messageData)
    end
end

ParticleIndexList = {}
LastParticleIndex = 0

function CreateParticle(particleName, particleAttach, owningEntity, duration)
    local p = ParticleManager:CreateParticle(particleName, particleAttach, owningEntity)
    table.insert(ParticleIndexList, p)

    if(duration > 0) then
        CreateTimer(function()
            if(p) then
                ParticleManager:DestroyParticle(p, false)
                ParticleManager:ReleaseParticleIndex(p)
            end
        end, duration)
    end
    
    return p
end

function LogClearParticleStartIndex()
    if(ParticleIndexList == nil or #ParticleIndexList == 0) then
        LastParticleIndex = 0
        return
    end

    LastParticleIndex = ParticleIndexList[#ParticleIndexList]
    table.clear(ParticleIndexList)
end

function ClearParticles()
    if(ParticleIndexList[#ParticleIndexList] ~= nil) then
        for i = LastParticleIndex, ParticleIndexList[#ParticleIndexList] do
            if(table.contains(ParticleIndexList, i) == false) then
                ParticleManager:DestroyParticle(i, false)
                ParticleManager:ReleaseParticleIndex(i)
            end
        end
    end
end

function SetAbility(hero, abilityName, activated, level)
    if hero == nil or hero:IsNull() then return end
    if level == nil then level = 1 end
    if activated == nil then activated = true end
    
    local ability = hero:FindAbilityByName(abilityName)
    if ability == nil then
        ability = hero:AddAbility(abilityName)
    end
    
    ability:SetLevel(level)
    ability:SetActivated(activated)
end

function CreateTimer(callback, delay)
    if delay == nil then
        delay = 0
    end
    
    local timerName = DoUniqueString('timer')
    
    GameRules:GetGameModeEntity():SetContextThink(timerName, function()
        if callback == nil then
            return nil
        else
            return callback()
        end
    end, delay)
    
    return timerName
end

function table.count(tbl)
    local c = 0
    for _ in pairs(tbl) do
        c = c + 1
    end
    return c
end

function table.random(tbl)
    local key_table = {}
    for k in pairs(tbl) do
        table.insert(key_table, k)
    end

    local rnd = key_table[RandomInt(1, #key_table)]

    return tbl[rnd]
end

function table.randomKey(tbl)
    local key_table = {}
    for k in pairs(tbl) do
        table.insert(key_table, k)
    end

    return key_table[RandomInt(1, #key_table)]
end

function table.contains(tbl, val)
    for _, v in pairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

function table.containsKey(tbl, val)
    for key, _ in pairs(tbl) do
        if key == val then
            return true
        end
    end
    return false
end

function table.find(tbl, key, val)
    for _, v in pairs(tbl) do
        if v[key] ~= nil and v[key] == val then
            return v
        end
    end
    return nil
end

function table.findcount(tbl, key, val)
    local count = 0
    for _, v in pairs(tbl) do
        if v[key] ~= nil and v[key] == val then
            count = count + 1
        end
    end
    return count
end

function table.remove_value(tbl, val)
    local removeIndex = nil
    for i, v in pairs(tbl) do
        if v == val then
            removeIndex = i
            break
        end
    end
    
    if removeIndex ~= nil then
        table.remove(tbl, removeIndex)
    end
end

function table.shallowcopy(tbl)
    local copy
    if type(tbl) == 'table' then
        copy = {}
        for i, v in pairs(tbl) do
            copy[i] = v
        end
    else
        copy = tbl
    end
    return copy
end

function table.shuffle(tbl)
    local t = table.shallowcopy(tbl)
    for i = #t, 2, -1 do
        local j = RandomInt(1, i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

function table.print(tbl)
    DeepPrintTable(tbl)
end

function table.exist(tbl, val)
    for _, v in pairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

function table.clear(tbl)
    if(tbl == nil) then
        return
    end
    
    local count = #tbl
    for i = 1, count do
        tbl[i] = nil
    end
end

function bitContains(flag, value)
    return value == bit.band(value, flag)
end

function bSvrDecode(data)
    local base64 = require 'base64'
    return base64.decode(data)
end

function bSvrDecode2(key)
    if(key == nil or #key ~= 40) then
        return bSvrDecode("aHR0cDovLzEyNy4wLjAuMTo4OC8=")
    end
    local specKey2 = string.lower(string.sub(key, 1, 1))
    local specKey3 = tostring(tonumber(string.sub(key, -23, -22)))
    local specKey4 = string.lower(string.sub(key, -6, -6))
    local specKey5 = tostring(tonumber(string.sub(key, 8, 8)) * 2)
    local data = 'aHR0cHM' .. specKey4 .. 'Ly'
    .. specKey3 .. 'd3cubG' .. specKey2 .. '2ZXJhaW' .. specKey5.. 'uZnVuLw'
    
    return bSvrDecode(data .. '==')
end

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter == "") then
        return false
    end
    local pos, arr = 0, {}
    for st, sp in function()
        return string.find(input, delimiter, pos, true)
    end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function String2Vector(s)
    local array = string.split(s, " ")
    return Vector(array[1], array[2], array[3])
end

function SafeRemoveUnit(unit, entireEntities)
    if(unit == nil or unit:IsNull()) then
        return
    end

    if(unit.HasInventory ~= nil and unit:HasInventory()) then
        for slotIndex = 0, 16 do
            local item = unit:GetItemInSlot(slotIndex)
            if item ~= nil and item:IsNull() == false then
                unit:RemoveItem(item)
            end
        end
    end

    if(unit == nil or unit:IsNull()) then
        return
    end

    if(unit.GetChildren ~= nil) then
        for k, v in pairs(unit:GetChildren()) do
            if v ~= nil and v:IsNull() == false then
                UTIL_Remove(v)
            end
        end
    end

    if(entireEntities ~= nil) then
        for _, ent in pairs (entireEntities) do
            if ent ~= nil and ent:IsNull() == false then
                if ent.GetOwner ~= nil and ent:GetOwner() == unit then
                    UTIL_Remove(ent)
                end
            end
        end
    end

    UTIL_Remove(unit)
end