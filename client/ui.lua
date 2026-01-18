-- Show War Status UI
function ShowUI(arg, data)
    SendNUIMessage({
        action = 'showInfluenceUi',
        data = arg,
    })
    SendNUIMessage({
        action = 'setWarStatVisible',
        data = {
            visible = arg,
        },
    })
    SendNUIMessage({
        action = 'setUiData',
        data = data
    })
end

-- Create War

lib.callback.register('SY_Territories:client:openCreateWarUi', function()
    local gangs = lib.callback.await('SY_Territories:server:getGangs', false)
    local Result = {}

    for territoryName, data in pairs(Config.Territories) do
        Result[#Result + 1] = {
            value = territoryName,
            label = data.label
        }
    end

    CreateWar(Result, gangs)
    return 'success'
end)



function CreateWar(zoneData, gangData)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'showCreateWarUi',
        data = {
            zones = zoneData,
            gangs = gangData
        }
    })
end

RegisterNUICallback('hide-create-war-ui', function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hideCreateWarUi' })
    cb({})
end)

RegisterNUICallback('createWar', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent("SY_Territories:createWar", data.zone, data.defenderGang, data.attackerGang,
        tonumber(data.warTime))
    SendNUIMessage({ action = 'hideCreateWarUi' })
    cb({})
end)
