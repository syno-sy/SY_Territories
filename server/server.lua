local QBCore = exports['qb-core']:GetCoreObject()
local Territories = {}
local ZonePlayers = {}
local ZoneFights = {}

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
-- HELPER: GET PLAYER GANG
-- =============================
function GetCorePlayerGang(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and Player.PlayerData.gang then
        return Player.PlayerData.gang.name
    end
    return "none"
end

-- =============================
-- PLAYER ENTER / EXIT ZONE
-- =============================
RegisterNetEvent("SY_Territories:enterZone", function(zone)
    local src = source
    local gang = GetCorePlayerGang(src)
    ZonePlayers[zone][src] = gang

    local fight = ZoneFights[zone]
    if fight and (gang == fight.attackerGang or gang == fight.defenderGang) then
        fight.alive[src] = gang
        fight.dead[src] = nil


        if gang == fight.attackerGang then
            fight.attackerCount += 1
        elseif gang == fight.defenderGang then
            fight.defenderCount += 1
        end
    end
end)

RegisterNetEvent("SY_Territories:leaveZone", function(zone)
    local src = source
    ZonePlayers[zone][src] = nil

    local fight = ZoneFights[zone]
    if fight then
        local gang = fight.alive[src]
        if gang then
            fight.alive[src] = nil
            if gang == fight.attackerGang then
                fight.attackerCount -= 1
            elseif gang == fight.defenderGang then
                fight.defenderCount -= 1
            end
        end
        fight.dead[src] = nil
    end
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

-- =============================
-- START / END FIGHTS
-- =============================
function StartZoneFight(zone, defenderGang, attackerGang, warTime)
    if ZoneFights[zone] then return end
    local initialDuration = warTime or Config.FightTime or 720
    local attackerCount, defenderCount = 0, 0
    for src, gang in pairs(ZonePlayers[zone] or {}) do
        if gang == attackerGang then attackerCount += 1 end
        if gang == defenderGang then defenderCount += 1 end
    end

    ZoneFights[zone] = {
        timeLeft = initialDuration,
        maxTime = initialDuration,
        attackerGang = attackerGang,
        defenderGang = defenderGang,
        attackerCount = attackerCount,
        defenderCount = defenderCount,
        alive = {},
        dead = {}
    }

    -- Populate alive table
    for src, gang in pairs(ZonePlayers[zone] or {}) do
        if gang == attackerGang or gang == defenderGang then
            ZoneFights[zone].alive[src] = gang
        end
    end

    -- Fight countdown
    CreateThread(function()
        while ZoneFights[zone] and ZoneFights[zone].timeLeft > 0 do
            Wait(1000)
            ZoneFights[zone].timeLeft -= 1
            SendZoneFightData(zone)
        end

        EndZoneFight(zone)
    end)
end

function EndZoneFight(zone)
    TriggerClientEvent("SY_Territories:zoneFightEnd", -1, zone)
    ZoneFights[zone] = nil
end

-- =============================
-- PLAYER DEATH IN ZONE
-- =============================
RegisterNetEvent("SY_Territories:playerDied", function(zone, src)
    local fight = ZoneFights[zone]
    if not fight then return end
    if not fight.alive[src] then return end

    local gang = fight.alive[src]
    fight.alive[src] = nil
    fight.dead[src] = gang

    if gang == fight.attackerGang then
        fight.attackerCount -= 1
    elseif gang == fight.defenderGang then
        fight.defenderCount -= 1
    end

    SendZoneFightData(zone)
end)

-- =============================
-- GET GANG STATUS
-- =============================
function GetGangStatus(zone)
    local fight = ZoneFights[zone]
    if not fight then return {} end

    return {
        [fight.attackerGang] = {
            alive = fight.attackerCount,
            dead = #fight.dead
        },
        [fight.defenderGang] = {
            alive = fight.defenderCount,
            dead = #fight.dead
        }
    }
end

-- =============================
-- SEND FIGHT DATA TO CLIENT
-- =============================
function SendZoneFightData(zone)
    local fight = ZoneFights[zone]
    if not fight then return end

    local minutes = math.floor(fight.timeLeft / 60)
    local seconds = fight.timeLeft % 60

    local gangsData = {
        {
            code = "defender",
            gang = fight.defenderGang,
            value = fight.defenderCount
        },
        {
            code = "attacker",
            gang = fight.attackerGang,
            value = fight.attackerCount
        }
    }

    TriggerClientEvent("SY_Territories:zoneFightUpdate", -1, zone, {
        timer = {
            minutes = minutes,
            seconds = seconds,
            total = fight.maxTime
        },
        gangs = gangsData
    })
end

-- =============================
-- CREATE WAR EVENT
-- =============================
RegisterNetEvent("SY_Territories:createWar", function(zone, defenderGang, attackerGang, warTime)
    if ZoneFights[zone] then
        print("War already active in zone: " .. zone)
        return
    end
    if not Config.Territories[zone] then
        print("Invalid zone:", zone)
        return
    end

    if not Config.Gangs[defenderGang] or not Config.Gangs[attackerGang] then
        print("Invalid gangs:", defenderGang, attackerGang)
        return
    end

    StartZoneFight(zone, defenderGang, attackerGang, warTime)
end)

-- =============================
-- CALLBACKS
-- =============================
lib.callback.register('SY_Territories:server:getGangs', function()
    return GetCoreGangs()
end)


-- =============================
-- COMMAND FOR TESTING
-- =============================
lib.addCommand('createwar', {
    help = 'Create a war in a territory zone',
}, function(source)
    local result = lib.callback.await(
        'SY_Territories:client:openCreateWarUi',
        source
    )

    print('Callback result:', result)
    return result
end)


-- =============================
-- Deat Handler
-- =============================
-- Listen to QBCore death event


RegisterNetEvent("SY_Territories:Server:OnPlayerDead", function(src)
    PlayerDeadHandler(src)
end)

function PlayerDeadHandler(src)
    print("Player death Functions received")
    -- Find player's zone
    local zone = nil
    for z, players in pairs(ZonePlayers) do
        if players[src] then
            zone = z
            break
        end
    end

    if not zone then return end

    local fight = ZoneFights[zone]
    if not fight then return end
    if not fight.alive[src] then return end

    local gang = fight.alive[src]

    -- Move to dead list
    fight.alive[src] = nil
    fight.dead[src] = gang

    -- Reduce count
    if gang == fight.attackerGang then
        fight.attackerCount = math.max(0, fight.attackerCount - 1)
    elseif gang == fight.defenderGang then
        fight.defenderCount = math.max(0, fight.defenderCount - 1)
    end

    -- Send update to clients
    SendZoneFightData(zone)
end
