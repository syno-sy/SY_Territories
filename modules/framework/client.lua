SY = SY or {}
lib.locale()
local Framework = Config and Config.Framework or 'qb'

local QBCore, QboxCore, ESX

if Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Framework == 'qbox' then
    QboxCore = exports['qbx-core'] and exports['qbx-core']:GetCoreObject()
elseif Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
end

--- Client-side notification wrapper
--- @param type      string|nil  -- 'success', 'error', 'primary', 'info', etc.
--- @param message   string
--- @param time      number|nil  -- ms
--- @param title     string|nil
--- @param position  string|nil
function SY:ClientNotification(type, message, time, title, position)
    if not message or message == '' then return end

    local nType     = type or 'info'
    local nTime     = time or 5000
    local nTitle    = title or locale("msg_Title")
    local nPosition = position or 'middle-right'

    if Framework == 'qb' then
        -- QB-Core notify
        -- nType: 'primary', 'success', 'error', etc.
        if QBCore and QBCore.Functions and QBCore.Functions.Notify then
            QBCore.Functions.Notify(message, nType, nTime)
        else
            print(("[SY_Territories][QB][%s] %s"):format(nType, message))
        end
    elseif Framework == 'qbox' then
        if lib and lib.notify then
            lib.notify({
                description = message,
                type        = nType, -- 'inform', 'success', 'error', etc.
                duration    = nTime,
                title       = nTitle,
            })
        else
            print(("[SY_Territories][QBOX][%s] %s"):format(nType, message))
        end
    elseif Framework == 'esx' then
        if exports['esx_notify'] then
            exports["esx_notify"]:Notify(nType, nTime, message, nTitle, nPosition)
        elseif ESX and ESX.ShowNotification then
            ESX.ShowNotification(message)
        else
            print(("[SY_Territories][ESX][%s] %s"):format(nType, message))
        end
    else
        print(("[SY_Territories][%s] %s"):format(nType, message))
    end
end

RegisterNetEvent('SY_Territories:client:notify', function(type, message, time, title, position)
    SY:ClientNotification(type, message, time, title, position)
end)
