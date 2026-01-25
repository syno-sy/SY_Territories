local Territories = {}
local currentZone = nil
local lastZone = nil
local lastInfluence = nil
local lastGang = nil
local currentFight = nil
local lastState = nil
local TerritoryBlips = {}
local warZoneCoords = nil
local warZoneRadius = nil
local warZoneVisible = false
isInsideZone = false


local Config = Config
local TerritoriesConfig = Config.Territories
local GangsConfig = Config.Gangs
local BlipColorIDs = Config.BlipColorIDs


local Wait = Wait
local CreateThread = CreateThread
local DrawMarker = DrawMarker
local AddBlipForRadius = AddBlipForRadius
local SetBlipColour = SetBlipColour
local SetBlipAlpha = SetBlipAlpha
local SetBlipHighDetail = SetBlipHighDetail
local DoesBlipExist = DoesBlipExist
local RemoveBlip = RemoveBlip

local floor = math.floor
local string_format = string.format

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
-- GLOBAL WAR ZONE DRAWING
-- =============================
local function drawWarZone()
    if not warZoneVisible or not warZoneCoords or not warZoneRadius then return end

    DrawMarker(
        28,
        warZoneCoords.x, warZoneCoords.y, warZoneCoords.z,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        warZoneRadius, warZoneRadius, warZoneRadius,
        0, 120, 255, 60,
        false, false, 2, nil, nil, false
    )
end

CreateThread(function()
    while true do
        if warZoneVisible then
            drawWarZone()
            Wait(0)
        else
            Wait(500)
        end
    end
end)

RegisterNetEvent("SY_Territories:Client:CreateZoneGlob", function(zone)
    if Config.Glob == false then return end
    local terrConfig = TerritoriesConfig[zone]
    if not terrConfig or not terrConfig.areas or not terrConfig.areas[1] then return end

    local area = terrConfig.areas[1]
    warZoneCoords = area.coords
    warZoneRadius = area.radius
    warZoneVisible = true
end)

RegisterNetEvent("SY_Territories:Client:RemoveZoneGlob", function()
    warZoneVisible = false
    warZoneCoords = nil
    warZoneRadius = nil
end)

-- =============================
-- ZONES
-- =============================
for zone, data in pairs(TerritoriesConfig) do
    local areas = data.areas
    if areas then
        for _, area in ipairs(areas) do
            lib.zones.sphere({
                coords = area.coords,
                radius = area.radius,
                debug = Config.Debug,
                onEnter = function()
                    currentZone = zone
                    isInsideZone = true
                    TriggerServerEvent("SY_Territories:enterZone", zone)
                end,
                onExit = function()
                    currentZone = nil
                    isInsideZone = false
                    TriggerServerEvent("SY_Territories:leaveZone", zone)
                    currentFight = nil
                end
            })
        end
    end
end

-- =============================
-- HUD LOOP
-- =============================
CreateThread(function()
    while true do
        local waitTime = 1000

        local zone = currentZone
        if zone then
            local terr = Territories[zone]
            if terr then
                local terrConfig = TerritoriesConfig[zone]
                if terrConfig then
                    local zoneLabel = terrConfig.label
                    local gangData = GangsConfig[terr.gang]
                    local gangLabel = gangData and gangData.label or "Unknown"

                    if currentFight then
                        -- War UI
                        HideInfluenceUi()

                        if lastZone ~= zone or lastGang ~= terr.gang or lastInfluence ~= terr.influence or lastState ~= "war" then
                            local gangColorCode = GetGangColorCode(terr.gang)
                            ShowWarUI(true, {
                                zone = zoneLabel,
                                gang = gangLabel,
                                influence = terr.influence,
                                gangColor = gangColorCode
                            })

                            lastZone = zone
                            lastGang = terr.gang
                            lastInfluence = terr.influence
                            lastState = "war"
                        end

                        waitTime = 250
                    else
                        ShowWarUI(false, nil)

                        if lastZone ~= zone or lastGang ~= terr.gang or lastInfluence ~= terr.influence or lastState ~= "influence" then
                            ShowInfluenceUi({
                                zone = zoneLabel,
                                gang = gangLabel,
                                influence = terr.influence,
                                gangColor = GetGangColorCode(terr.gang)
                            })

                            lastZone = zone
                            lastGang = terr.gang
                            lastInfluence = terr.influence
                            lastState = "influence"
                        end

                        waitTime = 500
                    end
                end
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
    local gangConfig = GangsConfig[gang]
    if gangConfig and gangConfig.color then
        local r, g, b = colorsRGB.RGB(gangConfig.color)
        return string_format("%d, %d, %d", r, g, b)
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

    if data.timer then
        SendNUIMessage({
            action = 'setTimerData',
            data = data.timer
        })
    end

    if data.gangs then
        SendNUIMessage({
            action = 'setGangStatus',
            data = data.gangs
        })
    end
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
    for i = 1, #TerritoryBlips do
        local handle = TerritoryBlips[i]
        if handle and DoesBlipExist(handle) then
            RemoveBlip(handle)
        end
    end
    TerritoryBlips = {}

    for zoneName, terrData in pairs(Territories) do
        local config = TerritoriesConfig[zoneName]
        if config and config.areas then
            local gangData = GangsConfig[terrData.gang]
            local colorName = gangData and gangData.color or "red"
            local gangColorID = BlipColorIDs[colorName] or 1

            local influence = terrData.influence or 0
            if influence < 0 then influence = 0 end
            if influence > 255 then influence = 255 end
            local blipAlpha = floor(influence)

            for _, area in ipairs(config.areas) do
                local handle = AddBlipForRadius(
                    area.coords.x,
                    area.coords.y,
                    area.coords.z,
                    area.radius
                )

                if handle ~= 0 then
                    SetBlipColour(handle, gangColorID)
                    SetBlipAlpha(handle, blipAlpha)
                    SetBlipHighDetail(handle, true)
                    TerritoryBlips[#TerritoryBlips + 1] = handle
                end
            end
        end
    end
end

-- =============================
-- CLIENT EXPORTS
-- =============================

--- Returns the gang name owning the zone
--- @param zoneName string
--- @return string|nil
exports('GetZoneOwner', function(zoneName)
    local terr = Territories[zoneName]
    return terr and terr.gang or nil
end)

--- Returns the influence of a zone
--- @param zoneName string
--- @return number
exports('GetZoneInfluence', function(zoneName)
    local terr = Territories[zoneName]
    return terr and terr.influence or 0
end)

--- Returns full data for a zone
--- @param zoneName string
--- @return table|nil
exports('GetZoneData', function(zoneName)
    return Territories[zoneName]
end)

--- Returns table of all zones and their data
exports('GetAllZones', function()
    return Territories
end)
