-- =============================
-- Local cache of globals (perf)
-- =============================
local SendNUIMessage       = SendNUIMessage
local SetNuiFocus          = SetNuiFocus
local SetResourceKvp       = SetResourceKvp
local GetResourceKvpString = GetResourceKvpString
local json_encode          = json.encode
local json_decode          = json.decode

-- KVP keys
local KVP_INFLUENCE_POS    = 'territory_influence_ui_pos'
local KVP_WAR_POS          = 'territory_war_ui_pos'

-- =============================
-- Generic helpers
-- =============================
local function saveUiPosition(kvpKey, x, y)
    SetResourceKvp(kvpKey, json_encode({ x = x, y = y }))
end

local function loadUiPosition(kvpKey)
    local posStr = GetResourceKvpString(kvpKey)
    if not posStr then return nil end

    local pos = json_decode(posStr)
    if not pos or not pos.x or not pos.y then return nil end

    return pos
end

local function notifyInfo(msg)
    SY:ClientNotification("info", msg)
end

-- =============================
-- Show Influence Ui
-- =============================
function ShowInfluenceUi(data)
    SendNUIMessage({
        action = 'showInfluenceUi',
        data = data,
    })
end

function HideInfluenceUi()
    SendNUIMessage({ action = 'hideInfluenceUi' })
end

-- =============================
-- Show War Status
-- =============================
function ShowWarUI(isVisible, data)
    SendNUIMessage({
        action = 'setWarStatVisible',
        data = { visible = isVisible },
    })
    if data then
        SendNUIMessage({
            action = 'setUiData',
            data = data
        })
    end
end

-- =============================
-- Create War UI
-- =============================
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
    TriggerServerEvent(
        "SY_Territories:createWar",
        data.zone,
        data.defenderGang,
        data.attackerGang,
        tonumber(data.warTime)
    )
    SendNUIMessage({ action = 'hideCreateWarUi' })
    cb({})
end)

-- =============================
-- Influence UI Position
-- =============================
RegisterNetEvent('SY_Territories:client:setInfluenceUiPosition', function()
    SetInfluenceUIPosition()
end)

function SetInfluenceUIPosition(l)
    if isInsideZone then
        notifyInfo(locale('msg_isInZone'))
        return
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'setInfluenceUiPosition',
        data = {
            zone      = "Zone",
            gang      = "Gang",
            influence = 70,
            gangColor = "255, 255, 255"
        }
    })
end

RegisterNUICallback('setInfluenceUiPositionData', function(data, cb)
    SetNuiFocus(false, false)
    saveUiPosition(KVP_INFLUENCE_POS, data.x, data.y)
    cb('ok')
end)

RegisterNUICallback('getInfluenceUiPosition', function(_, cb)
    cb(1)

    local pos = loadUiPosition(KVP_INFLUENCE_POS)
    if not pos then return end

    SendNUIMessage({
        action = 'getInfluenceUiPosition',
        data = {
            x = pos.x,
            y = pos.y
        }
    })
end)

-- =============================
-- War UI Position
-- =============================
RegisterNetEvent('SY_Territories:client:setWarUiPosition', function()
    SetWarUIPosition()
end)

function SetWarUIPosition()
    if isInsideZone then
        notifyInfo(locale('msg_isInZone'))
        return
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'setWarStatUiPosition',
        data = {
            zone      = "Zone",
            gang      = "Gang",
            influence = 70,
            gangColor = "255, 255, 255"
        }
    })
end

RegisterNUICallback('setWarStatUiPositionData', function(data, cb)
    SetNuiFocus(false, false)
    saveUiPosition(KVP_WAR_POS, data.x, data.y)
    cb('ok')
end)

RegisterNUICallback('getWarStatUiPosition', function(_, cb)
    cb(1)
    local pos = loadUiPosition(KVP_WAR_POS)
    if not pos then return end


    SendNUIMessage({
        action = 'getWarStatUiPosition',
        data = {
            x = pos.x,
            y = pos.y
        }
    })
end)
