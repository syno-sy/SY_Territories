local Territories = {}
local currentZone = nil

RegisterNetEvent("SY_Territories:sync", function(data)
    Territories = data
end)

local playerGang = "none"

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local data = exports.qbx_core:GetPlayerData()
    if data.gang then
        playerGang = data.gang.name
    end
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gang)
    playerGang = gang.name
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
            end
        })
    end
end

-- =============================
-- DRAW HUD
-- =============================
CreateThread(function()
    while true do
        if currentZone and Territories[currentZone] then
            local terr = Territories[currentZone]
            ShowUI(true, {
                zone = currentZone,
                gang = terr.gang,
                influence = terr.influence,
            })

            -- DrawTxt(
            --     ("Zone: ~b~%s\n~s~Gang: ~r~%s\n~s~Influence: ~g~%d%%")
            --     :format(currentZone, terr.gang, terr.influence),
            --     0.015, 0.02
            -- )
        else
            ShowUI(false, nil)
        end
        Wait(0)
    end
end)

-- function DrawTxt(text, x, y)
--     SetTextFont(4)
--     SetTextScale(0.45, 0.45)
--     SetTextOutline()
--     BeginTextCommandDisplayText("STRING")
--     AddTextComponentSubstringPlayerName(text)
--     EndTextCommandDisplayText(x, y)
-- end
