local SQLinit             = false
local has_whitelist_queue = false
local only_whistlist      = false

AddEventHandler("RevoSQLReady", function()
    SQLinit = true
end)

AddEventHandler("ResendRevoSQLReady", function()
    SQLinit = true
end)


local function HandleWhitelistOnlyServer(whitelisted, kickReason)

    if only_whistlist and not whitelisted then

        kickReason("You must be whitelisted to play on this server.")
        CancelEvent()

    end

end

local function AddOrRemoveFromPrio(steam_hex, rows, kickReason)

    local whitelisted = false
    if #rows >= 1 then

        if rows[1].priority ~= 0 then
            TriggerEvent("q_addpriority", steam_hex, rows[1].priority)
        elseif rows[1].whitelist ~= 0 and has_whitelist_queue then
            whitelisted = true
            TriggerEvent("q_addpriority", steam_hex, 99)
        end

    else
        TriggerEvent("q_removepriority", steam_hex)
    end
    HandleWhitelistOnlyServer(whitelisted, kickReason)

end


local function GeneratePrioList(source, steam_id, kickReason)

    local steam_hex = string.format("%x", steam_id)
    Citizen.CreateThread(function()
        Citizen.Wait(5)
        MySQL.Async.fetchAll("SELECT * FROM users WHERE steamid=@steam", {['@steam'] = steam_id}, 
        function(rows)

            AddOrRemoveFromPrio(steam_hex, rows, kickReason)

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

    GeneratePrioList(source, steam_id, kickReason)

end

AddEventHandler("playerConnecting", playerConnectingStart)