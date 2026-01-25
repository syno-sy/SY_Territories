SY = SY or {}

local Framework = Config and Config.Framework or 'qb'

local QBCore, QboxCore, ESX

if Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Framework == 'qbox' then
    QboxCore = exports['qbx-core'] and exports['qbx-core']:GetCoreObject()
elseif Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
end

-- =============================
-- CORE HELPERS
-- =============================

--- Get core player object (QBCore / Qbox Player or ESX xPlayer)
--- @param src number
--- @return table|nil
function GetCorePlayerData(src)
    if Framework == 'qb' then
        return QBCore and QBCore.Functions.GetPlayer(src)
    elseif Framework == 'qbox' then
        return QboxCore and QboxCore.Functions.GetPlayer(src)
    elseif Framework == 'esx' then
        return ESX.GetPlayerFromId(src)
    end
    return nil
end

--- Get player's gang name (or "none")
--- @param src number
--- @return string
function GetCorePlayerGang(src)
    if Framework == 'qb' then
        local Player = QBCore and QBCore.Functions.GetPlayer(src)
        if Player and Player.PlayerData and Player.PlayerData.gang then
            return Player.PlayerData.gang.name
        end
    elseif Framework == 'qbox' then
        local Player = QboxCore and QboxCore.Functions.GetPlayer(src)
        if Player and Player.PlayerData and Player.PlayerData.gang then
            return Player.PlayerData.gang.name
        end
    elseif Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer and xPlayer.job and xPlayer.job.name then
            return xPlayer.job.name
        end
    end

    return "none"
end

--- Get configured gangs for UI
--- Returns array: { { value = "gangName", label = "Label" }, ... }
function GetCoreGangs()
    local Result = {}

    if Framework == 'qb' and QBCore then
        local Gangs = QBCore.Shared and QBCore.Shared.Gangs or exports['qb-core']:GetSharedGangs()
        if Gangs then
            for gangName, gangData in pairs(Gangs) do
                Result[#Result + 1] = {
                    value = gangName,
                    label = gangData.label,
                }
            end
            return Result
        end
    elseif Framework == 'qbox' and QboxCore then
        local Gangs = QboxCore.Shared and QboxCore.Shared.Gangs
        if Gangs then
            for gangName, gangData in pairs(Gangs) do
                Result[#Result + 1] = {
                    value = gangName,
                    label = gangData.label,
                }
            end
            return Result
        end
    elseif Framework == 'esx' then
        local jobs = ESX.GetJobs()
        for jobName, jobData in pairs(jobs) do
            if jobData.type == "gang" then
                Result[#Result + 1] = {
                    value = jobName,
                    label = jobData.label,
                }
            end
        end
        return Result
    end


    if Config.Gangs then
        for gangName, gangData in pairs(Config.Gangs) do
            Result[#Result + 1] = {
                value = gangName,
                label = gangData.label,
            }
        end
    end

    return Result
end

--- Count online players in a given gang name
--- @param gangName string
--- @return number
function GetCoreGangPlayerCount(gangName)
    if not gangName or gangName == '' then return 0 end
    local count = 0

    if Framework == 'qb' and QBCore then
        local players = QBCore.Functions.GetPlayers()
        for _, playerId in pairs(players) do
            local Player = QBCore.Functions.GetPlayer(playerId)
            if Player and Player.PlayerData.gang and Player.PlayerData.gang.name == gangName then
                count = count + 1
            end
        end
    elseif Framework == 'qbox' and QboxCore then
        local players = QboxCore.Functions.GetPlayers()
        for _, playerId in pairs(players) do
            local Player = QboxCore.Functions.GetPlayer(playerId)
            if Player and Player.PlayerData.gang and Player.PlayerData.gang.name == gangName then
                count = count + 1
            end
        end
    elseif Framework == 'esx' and ESX then
        if ESX.GetExtendedPlayers then
            local players = ESX.GetExtendedPlayers()
            for _, xPlayer in pairs(players) do
                if xPlayer.job and xPlayer.job.name == gangName then
                    count = count + 1
                end
            end
        end
    end

    return count
end

--- Get core player name
--- @param src number
--- @return string|nil
function GetCorePlayerName(src)
    if Framework == 'qb' and QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        return Player and Player.PlayerData and Player.PlayerData.name or GetPlayerName(src)
    elseif Framework == 'qbox' and QboxCore then
        local Player = QboxCore.Functions.GetPlayer(src)
        return Player and Player.PlayerData and Player.PlayerData.name or GetPlayerName(src)
    elseif Framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer and xPlayer.getName then
            return xPlayer.getName()
        end
        return GetPlayerName(src)
    end

    return GetPlayerName(src)
end

-- =============================
-- GANG UPDATE HOOKS
-- =============================

if Framework == 'qb' then
    AddEventHandler('QBCore:Server:OnGangUpdate', function(source, gang, grade)
        if UpdateGangJob then
            UpdateGangJob(source)
        end
    end)
end
if Framework == 'qbox' then
    AddEventHandler('qbx_core:server:playerGangUpdated', function(source, newGang, oldGang)
        if UpdateGangJob then
            UpdateGangJob(source)
        end
    end)
end

if Framework == 'esx' then
    AddEventHandler('esx:setJob', function(src, job, lastJob)
        if UpdateGangJob then
            UpdateGangJob(src)
        end
    end)
    RegisterNetEvent('esx:onPlayerDeath', function(data)
        TriggerEvent("SY_Territories:Server:OnPlayerDead", source)
    end)
end

-- =============================
-- SERVER NOTIFICATION WRAPPER
-- =============================

--- Server-side notification helper
--- Sends a client event that uses the client-side SY:ClientNotification
--- @param type      string|nil
--- @param message   string
--- @param src       number|nil
--- @param time      number|nil
--- @param title     string|nil
--- @param position  string|nil
function SY:ServerNotification(type, message, src, time, title, position)
    if not message or message == '' then return end

    local nType     = type or 'info'
    local nTime     = time or 5000
    local nTitle    = title or 'SY_Territories'
    local nPosition = position or 'top-right'
    local target    = src or -1
    TriggerClientEvent('SY_Territories:client:notify', target, nType, message, nTime, nTitle, nPosition)
end
