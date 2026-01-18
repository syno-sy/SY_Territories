local Territories = {}
local currentZone = nil
local lastZone = nil
local lastInfluence = nil
local lastGang = nil
local currentFight = nil
local lastState = nil
local TerritoryBlips = {}
local BlipColorIDs = {
    ["red"] = 1,
    ["green"] = 2,
    ["blue"] = 3,
    ["white"] = 4,
    ["yellow"] = 5,
}

-- =============================
-- SYNC TERRITORIES FROM SERVER
-- =============================
RegisterNetEvent("SY_Territories:sync", function(data)
    Territories = data
    RefreshTerritoryBlips()
end)

RegisterNetEvent("SY_Territories:syncOnPlayerGangChange", function()
    if currentZone then
        TriggerServerEvent("SY_Territories:enterZone", currentZone)
        lastGang = nil
    end
end)

-- =============================
-- ZONES
-- =============================
for zone, data in pairs(Config.Territories) do
    for _, area in ipairs(data.areas) do
        lib.zones.sphere({
            coords = area.coords,
            radius = area.radius,
            debug = Config.Debug,
            onEnter = function()
                currentZone = zone
                TriggerServerEvent("SY_Territories:enterZone", zone)
            end,
            onExit = function()
                currentZone = nil
                TriggerServerEvent("SY_Territories:leaveZone", zone)
                currentFight = nil
            end
        })
    end
end

-- =============================
-- HUD LOOP
-- =============================
CreateThread(function()
    while true do
        local waitTime = 1000

        if currentZone and Territories[currentZone] then
            local terr = Territories[currentZone]
            local zoneLabel = Config.Territories[currentZone].label
            local gangLabel = Config.Gangs[terr.gang].label


            if currentFight then
                HideInfluenceUi()

                if lastZone ~= currentZone or lastGang ~= terr.gang or lastInfluence ~= terr.influence or lastState ~= "war" then
                    local GangColorCode = GetGangColorCode(terr.gang) or "255, 255, 255"
                    ShowWarUI(true, {
                        zone = zoneLabel,
                        gang = gangLabel,
                        influence = terr.influence,
                        gangColor = GangColorCode
                    })

                    lastZone = currentZone
                    lastGang = terr.gang
                    lastInfluence = terr.influence
                    lastState = "war"
                end
                waitTime = 250
            else
                ShowWarUI(false, nil)

                if lastZone ~= currentZone or lastGang ~= terr.gang or lastInfluence ~= terr.influence or lastState ~= "influence" then
                    ShowInfluenceUi({
                        zone = zoneLabel,
                        gang = gangLabel,
                        influence = terr.influence,
                        gangColor = GetGangColorCode(terr.gang)
                    })

                    lastZone = currentZone
                    lastGang = terr.gang
                    lastInfluence = terr.influence
                    lastState = "influence"
                end
                waitTime = 500
            end
        else
            if lastZone ~= nil then
                ShowWarUI(false, nil)
                HideInfluenceUi()
                lastZone = nil
                lastGang = nil
                lastInfluence = nil
                lastState = nil
            end
        end

        Wait(waitTime)
    end
end)

-- =============================
-- GANG COLOR HELPER
-- =============================
function GetGangColorCode(gang)
    if Config.Gangs[gang] and Config.Gangs[gang].color then
        local r, g, b = colorsRGB.RGB(Config.Gangs[gang].color)
        return string.format("%d, %d, %d", r, g, b)
    end
    return "255, 255, 255"
end

-- =============================
-- ZONE FIGHT UPDATE EVENT
-- =============================
RegisterNetEvent("SY_Territories:zoneFightUpdate", function(zone, data)
    if currentZone ~= zone then
        currentFight = nil
        return
    end


    currentFight = data
    SendNUIMessage({
        action = 'setTimerData',
        data = data.timer
    })


    SendNUIMessage({
        action = 'setGangStatus',
        data = data.gangs
    })
end)

-- =============================
-- ZONE FIGHT END EVENT
-- =============================
RegisterNetEvent("SY_Territories:zoneFightEnd", function(zone)
    if currentZone == zone then
        currentFight = nil
        ShowWarUI(false, nil)
    end
end)


-- =============================
-- REFRESH BLIPS FUNCTION
-- =============================
function RefreshTerritoryBlips()
    for _, handle in ipairs(TerritoryBlips) do
        if handle and DoesBlipExist(handle) then
            RemoveBlip(handle)
        end
    end

    TerritoryBlips = {}

    for zoneName, data in pairs(Territories) do
        local config = Config.Territories[zoneName]

        if config and config.areas then
            local colorName = Config.Gangs[data.gang] and Config.Gangs[data.gang].color or "red"
            local gangColorID = BlipColorIDs[colorName] or 1
            local blipAlpha = math.floor(data.influence)

            for _, area in ipairs(config.areas) do
                local handle = AddBlipForRadius(
                    area.coords.x,
                    area.coords.y,
                    area.coords.z,
                    area.radius
                )

                SetBlipColour(handle, gangColorID)
                SetBlipAlpha(handle, blipAlpha)
                SetBlipHighDetail(handle, true)

                if handle ~= 0 then
                    table.insert(TerritoryBlips, handle)
                end
            end
        end
    end
end
