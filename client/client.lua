local Territories = {}
local currentZone = nil
local lastZone = nil
local lastInfluence = nil
local lastGang = nil
local currentFight = nil

-- =============================
-- SYNC TERRITORIES FROM SERVER
-- =============================
RegisterNetEvent("SY_Territories:sync", function(data)
    Territories = data
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
-- HUD LOOP (active only during fight)
-- =============================
CreateThread(function()
    while true do
        local waitTime = 1000

        if currentZone and Territories[currentZone] and currentFight then
            local terr = Territories[currentZone]
            if lastZone ~= currentZone or lastGang ~= terr.gang or lastInfluence ~= terr.influence then
                local GangColorCode = GetGangColorCode(terr.gang) or "255, 255, 255"
                ShowUI(true, {
                    zone = currentZone,
                    gang = terr.gang,
                    influence = terr.influence,
                    gangColor = GangColorCode
                })

                lastZone = currentZone
                lastGang = terr.gang
                lastInfluence = terr.influence
            end

            waitTime = 250 -- update faster during fight
        else
            if lastZone ~= nil then
                ShowUI(false, nil)
                lastZone = nil
                lastGang = nil
                lastInfluence = nil
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

    print(json.encode(data.timer))
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
        ShowUI(false, nil)
    end
end)

-- =============================
-- CREATE WAR KEYBIND
-- =============================
lib.addKeybind({
    name = 'Create War',
    description = 'press J to create a war',
    defaultKey = 'J',
    onPressed = function(self)
        CreateWar()
        print(('pressed %s (%s)'):format(self.currentKey, self.name))
    end,
})
