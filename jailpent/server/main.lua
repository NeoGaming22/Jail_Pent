RegisterCommand('pent', function(source, args, rawCommand)
    local _source = source

    TriggerEvent("vorp:getCharacter", _source, function(user)
        if user.job == 'police' then
            local target_id = args[1]
            local time = tonumber(args[2])
            TriggerClientEvent('poke_adminjail:request', _source, target_id, time)
        end
    end)
end, false)

RegisterCommand('removepent', function(source, args, rawCommand)
    local _source = source

    TriggerEvent("vorp:getCharacter", _source, function(user)
        if user.job == 'police' then
            local target_id = args[1]
            local steam_id = GetPlayerIdentifiers(target_id)[1]

            exports.ghmattimysql:execute("DELETE FROM user_jail WHERE identifier = @identifier", {["@identifier"] = steam_id}, function(result)
                if result ~= nil then
                    TriggerClientEvent("poke_adminjail:unjail_player", target_id)
                else
                    TriggerClientEvent("vorp:TipBottom", _source, 'On tapahtunut virhe', 5000)
                end
            end)
        end
    end)
end, false)

RegisterServerEvent("poke_adminjail:jail")
AddEventHandler("poke_adminjail:jail", function(target_id, time)
    local _source = source
    -- USER INFO
    local steam_id = GetPlayerIdentifiers(target_id)[1]
    -- ADMIN INFO
    local admin_steam = GetPlayerIdentifiers(_source)[1]

    -- TIME
    local time_m = tostring(time)
    local time = time * 60
    local timestamp = getTime() + time

    exports.ghmattimysql:execute("INSERT INTO user_jail (identifier, admin_identifier, time, time_s) VALUES (@identifier, @admin_identifier, @timestamp, @time)", {["@identifier"] = steam_id, ["@admin_identifier"] = admin_steam, ["@timestamp"] = timestamp, ["@time"] = time}, function(result)
        if result ~= nil then
            TriggerClientEvent("poke_adminjail:jail_player", target_id, time)
        else
            TriggerClientEvent("vorp:TipBottom", _source, 'On tapahtunut virhe', 5000)
        end
    end)
end)

RegisterServerEvent("poke_adminjail:unjail")
AddEventHandler("poke_adminjail:unjail", function(target_id)
    local _source = source
    local steam_id = GetPlayerIdentifiers(target_id)[1]

    exports.ghmattimysql:execute("DELETE FROM user_jail WHERE identifier = @identifier", {["@identifier"] = steam_id}, function(result)
        if result ~= nil then
            TriggerClientEvent("poke_adminjail:unjail_player", target_id)
        else
            TriggerClientEvent("vorp:TipBottom", _source, 'On tapahtunut virhe', 5000)
        end
    end)
end)

RegisterServerEvent("poke_adminjail:check_jail")
AddEventHandler("poke_adminjail:check_jail", function()
    local _source = source

    Citizen.Wait(2000)

    local steam_id = GetPlayerIdentifiers(_source)[1]

    exports.ghmattimysql:execute("SELECT * FROM user_jail WHERE identifier = @identifier", {["@identifier"] = steam_id}, function(result)

        if result[1] ~= nil then
            local time = result[1]["time_s"]
            local id = result[1]["id"]
            exports.ghmattimysql:execute("UPDATE user_jail SET time = @time WHERE id = @id", {["@time"] = getTime() + time, ["@id"] = id})
            time = tonumber(time)
            TriggerClientEvent("poke_adminjail:jail_player", _source, time)
        end
    end)
end)

RegisterServerEvent("poke_adminjail:increasetime")
AddEventHandler("poke_adminjail:increasetime", function(target_id, time, newtime)
    local _source = source
    local steam_id = GetPlayerIdentifiers(target_id)[1]
    exports.ghmattimysql:execute("SELECT * FROM user_jail WHERE identifier = @identifier", {["@identifier"] = steam_id}, function(result)
        if result[1] ~= nil then
            local time = result[1]["time_s"]
            local id = result[1]["id"]
            exports.ghmattimysql:execute("UPDATE user_jail SET time_s = @time_s WHERE id = @id", {["@time_s"] = time + newtime, ["@id"] = id})
            exports.ghmattimysql:execute("UPDATE user_jail SET time = @time WHERE id = @id", {["@time"] = getTime() + time + newtime, ["@id"] = id})
            TriggerClientEvent("vorp:TipBottom", _source, 'Se ha aumentado '..newtime..' segundos tu condena, no intentes escapar', 5000)
        end
    end)
end)

function getTime ()
    return os.time(os.date("!*t"))
end