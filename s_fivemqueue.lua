local SQLinit = false

AddEventHandler("RevoSQLReady", function()
    SQLinit = true
end)

AddEventHandler("ResendRevoSQLReady", function()
    SQLinit = true
end)



local function GeneratePrioList(source, steam_id)

    local steam_hex = string.format("%x", steam_id)
    Citizen.CreateThread(function()
        Citizen.Wait(5)
        MySQL.Async.fetchAll("SELECT * FROM users WHERE steamid=@steam", {['@steam'] = steam_id}, 
        function(rows)
            local prio = false
            local whitelist = false

            if #rows >= 1 then
                if rows[1].whitelist ~= 0 then
                    whitelist = true
                end
                if rows[1].priority ~= 0 then
                    TriggerEvent("q_addpriority", steam_hex, rows[1].priority)
                end
            else
                TriggerEvent("q_removepriority", steam_hex)
            end

        end)
    end)

end

local function getSteamID(player)
    local ids = GetPlayerIdentifiers(player)

    for _,id in pairs(ids) do

        if string.sub(id, 1, 5) == "steam" then

            return tostring(tonumber(string.gsub(tostring(id), "steam:", ""), 16))

        end

    end

    return false
end

local function playerConnectingStart(playerName, kickReason, defer)

    local steam_id = getSteamID(source)
    if not SQLinit or GetResourceStatus("mysql-async") == "missing" then

        kickReason("SQL is not ready Give it a minute")
        CancelEvent()
        return

    end

    if not source or not steam_id then

        kickReason("Could not retrieve your steamID, make sure steam is running, restart FiveM and try again.")
        CancelEvent()
        return

    end

    GeneratePrioList(source, steam_id)

end

AddEventHandler("playerConnecting", playerConnectingStart)