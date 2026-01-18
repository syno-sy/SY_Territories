QBCore = nil
Framework = Config.Framework

if Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
end

function GetCorePlayerData(src)
    if Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(src)
        return Player
    end
end

function GetCorePlayerGang(src)
    if Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and Player.PlayerData.gang then
            return Player.PlayerData.gang.name
        end
    end
    return "none"
end

function GetCoreGangs()
    if Framework == "qb" then
        local Gangs = exports['qb-core']:GetSharedGangs()
        local Result = {}
        for gangNames, gangData in pairs(Gangs) do
            table.insert(Result, {
                value = gangNames,
                label = gangData.label,
                -- color = Config.Gangs[gangNames] and Config.Gangs[gangNames].color or "white"
            })
        end
        return Result
    end
end

function GetCoreGangPlayerCount(gangName)
    local count = 0
    if Framework ~= "qb" then
        local players = QBCore.Functions.GetPlayers()

        for _, playerId in pairs(players) do
            local Player = QBCore.Functions.GetPlayer(playerId)
            if Player and Player.PlayerData.gang and Player.PlayerData.gang.name == gangName then
                count = count + 1
            end
        end
        return count
    end
    return count
end

function GetCorePlayerName(src)
    if Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(src)
        return Player.PlayerData.name
    end
end

AddEventHandler('QBCore:Server:OnGangUpdate', function(source)
    UpdateGangJob(source)
end)
