local Territories = {}
local ZonePlayers = {}

-- =============================
-- LOAD TERRITORIES
-- =============================
CreateThread(function()
    for name, data in pairs(Config.Territories) do
        exports.oxmysql:fetch(
            "SELECT * FROM territories WHERE name = ?",
            { name },
            function(result)
                if result and result[1] then
                    Territories[name] = {
                        gang = result[1].gang,
                        influence = result[1].influence
                    }
                else
                    Territories[name] = {
                        gang = data.defaultGang,
                        influence = data.influence
                    }

                    exports.oxmysql:insert(
                        "INSERT INTO territories (name, gang, influence) VALUES (?, ?, ?)",
                        { name, data.defaultGang, data.influence }
                    )
                end

                ZonePlayers[name] = {}
            end
        )
    end
end)

-- =============================
-- PLAYER ENTER / EXIT
-- =============================
RegisterNetEvent("SY_Territories:enterZone", function(zone)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player or not Player.PlayerData.gang then return end

    local gang = Player.PlayerData.gang.name or "none"
    ZonePlayers[zone][src] = gang
end)

RegisterNetEvent("SY_Territories:leaveZone", function(zone)
    ZonePlayers[zone][source] = nil
end)

-- =============================
-- INFLUENCE TICK
-- =============================
CreateThread(function()
    while true do
        Wait(Config.InfluenceTick)

        for zone, players in pairs(ZonePlayers) do
            local gangCount = {}

            for _, gang in pairs(players) do
                gangCount[gang] = (gangCount[gang] or 0) + 1
            end

            local dominantGang, max = nil, 0
            for gang, count in pairs(gangCount) do
                if count > max then
                    dominantGang = gang
                    max = count
                end
            end

            if dominantGang then
                local terr = Territories[zone]

                if terr.gang == dominantGang then
                    terr.influence = math.min(100, terr.influence + (Config.InfluenceGain or 1))
                else
                    terr.influence = terr.influence - (Config.InfluenceLoss or 1)
                    if terr.influence <= 0 then
                        terr.gang = dominantGang
                        terr.influence = 50
                    end
                end

                exports.oxmysql:execute(
                    "UPDATE territories SET gang = ?, influence = ? WHERE name = ?",
                    { terr.gang, terr.influence, zone }
                )
            end
        end

        TriggerClientEvent("SY_Territories:sync", -1, Territories)
    end
end)
