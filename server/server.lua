local Territories = {}
local ZonePlayers = {}
local ZoneFights = {}

local Config = Config
local pairs = pairs
local math_floor = math.floor
local math_min = math.min
local math_max = math.max
local Wait = Wait
local CreateThread = CreateThread
local TriggerClientEvent = TriggerClientEvent
local AddEventHandler = AddEventHandler
local GetCurrentResourceName = GetCurrentResourceName

local oxmysql = exports.oxmysql

local function fetch(query, params, cb)
    return oxmysql:fetch(query, params, cb)
end

local function insert(query, params, cb)
    return oxmysql:insert(query, params, cb)
end

local function execute(query, params, cb)
    return oxmysql:execute(query, params, cb)
end


function GetZoneLabel(zone)
    return Config.Territories[zone].label
end

function GetGangLabel(gang)
    if not gang then return gang end
    return Config.Gangs[gang].label
end

-- =============================
-- LOAD TERRITORIES
-- =============================
CreateThread(function()
    for name, data in pairs(Config.Territories) do
        fetch(
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

                    insert(
                        "INSERT INTO territories (name, gang, influence) VALUES (?, ?, ?)",
                        { name, data.defaultGang, data.influence }
                    )
                end

                ZonePlayers[name] = ZonePlayers[name] or {}
            end
        )
    end
end)

-- =============================
-- PLAYER ENTER / EXIT ZONE
-- =============================
RegisterNetEvent("SY_Territories:enterZone", function(zone)
    local src = source
    local gang = GetCorePlayerGang(src)

    ZonePlayers[zone] = ZonePlayers[zone] or {}
    ZonePlayers[zone][src] = gang

    local fight = ZoneFights[zone]
    if fight and (gang == fight.attackerGang or gang == fight.defenderGang) then
        fight.alive[src] = gang
        fight.dead[src] = nil

        if gang == fight.attackerGang then
            fight.attackerCount = fight.attackerCount + 1
        elseif gang == fight.defenderGang then
            fight.defenderCount = fight.defenderCount + 1
        end
    end
end)

RegisterNetEvent("SY_Territories:leaveZone", function(zone)
    local src = source
    local zoneTable = ZonePlayers[zone]
    if zoneTable then
        zoneTable[src] = nil
    end

    local fight = ZoneFights[zone]
    if fight then
        local gang = fight.alive[src]
        if gang then
            fight.alive[src] = nil
            if gang == fight.attackerGang then
                fight.attackerCount = math_max(0, fight.attackerCount - 1)
            elseif gang == fight.defenderGang then
                fight.defenderCount = math_max(0, fight.defenderCount - 1)
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


            local dominantGang, maxCount = nil, 0
            for gang, count in pairs(gangCount) do
                if count > maxCount then
                    dominantGang = gang
                    maxCount = count
                end
            end


            if dominantGang and Config.Gangs[dominantGang] then
                local terr = Territories[zone]
                if terr then
                    if terr.gang == dominantGang then
                        terr.influence = math.min(100, (terr.influence or 0) + (Config.InfluenceGain or 1))
                    else
                        terr.influence = (terr.influence or 0) - (Config.InfluenceLoss or 1)
                        if terr.influence <= 0 then
                            terr.gang = dominantGang
                            terr.influence = 1
                        end
                    end


                    exports.oxmysql:execute(
                        "UPDATE territories SET gang = ?, influence = ? WHERE name = ?",
                        { terr.gang, terr.influence, zone }
                    )
                end
            end
        end


        TriggerClientEvent("SY_Territories:sync", -1, Territories)
    end
end)


-- =============================
-- START / END FIGHTS
-- =============================
local function SendZoneFightData(zone)
    local fight = ZoneFights[zone]
    if not fight then return end

    local minutes = math_floor(fight.timeLeft / 60)
    local seconds = fight.timeLeft % 60
    local defenderGangLabel = Config.Gangs[fight.defenderGang].label
    local attackerGangLabel = Config.Gangs[fight.attackerGang].label

    local gangsData = {
        {
            code = "defender",
            gang = defenderGangLabel,
            value = fight.defenderCount,
            max = fight.maxDefender
        },
        {
            code = "attacker",
            gang = attackerGangLabel,
            value = fight.attackerCount,
            max = fight.maxAttacker
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

function StartZoneFight(zone, defenderGang, attackerGang, warTime)
    if ZoneFights[zone] then return end
    SY:ServerNotification('success', locale('msg_WarStarted', GetZoneLabel(zone)))
    TriggerClientEvent("SY_Territories:Client:CreateZoneGlob", -1, zone)

    local initialDuration = warTime or Config.FightTime or 720
    local attackerCount, defenderCount = 0, 0

    local zoneTable = ZonePlayers[zone] or {}
    for _, gang in pairs(zoneTable) do
        if gang == attackerGang then attackerCount = attackerCount + 1 end
        if gang == defenderGang then defenderCount = defenderCount + 1 end
    end

    local fight = {
        timeLeft = initialDuration,
        maxTime = initialDuration,
        attackerGang = attackerGang,
        defenderGang = defenderGang,
        attackerCount = attackerCount,
        defenderCount = defenderCount,
        maxAttacker = attackerCount,
        maxDefender = defenderCount,
        alive = {},
        dead = {}
    }


    for playerId, gang in pairs(zoneTable) do
        if gang == attackerGang or gang == defenderGang then
            fight.alive[playerId] = gang
        end
    end

    ZoneFights[zone] = fight


    CreateThread(function()
        while ZoneFights[zone] and ZoneFights[zone].timeLeft > 0 do
            Wait(1000)
            local f = ZoneFights[zone]
            if not f then break end
            f.timeLeft = f.timeLeft - 1
            SendZoneFightData(zone)
        end

        if ZoneFights[zone] then
            EndZoneFight(zone)
        end
    end)
end

function EndZoneFight(zone)
    SY:ServerNotification('info', locale('msg_WarEnded', GetZoneLabel(zone)))
    TriggerClientEvent("SY_Territories:zoneFightEnd", -1, zone)
    TriggerClientEvent("SY_Territories:Client:RemoveZoneGlob", -1)
    ZoneFights[zone] = nil
end

-- =============================
-- PLAYER DEATH IN ZONE (generic)
-- =============================
local function HandlePlayerDeathInZone(zone, src)
    local fight = ZoneFights[zone]
    if not fight then return end
    if not fight.alive[src] then return end

    local gang = fight.alive[src]
    fight.alive[src] = nil
    fight.dead[src] = gang

    if gang == fight.attackerGang then
        fight.attackerCount = math_max(0, fight.attackerCount - 1)
    elseif gang == fight.defenderGang then
        fight.defenderCount = math_max(0, fight.defenderCount - 1)
    end

    SendZoneFightData(zone)
end


RegisterNetEvent("SY_Territories:playerDied", function(zone, src)
    HandlePlayerDeathInZone(zone, src)
end)

RegisterNetEvent("SY_Territories:Server:OnPlayerDead", function(src)
    local zone = nil
    for z, players in pairs(ZonePlayers) do
        if players[src] then
            zone = z
            break
        end
    end

    if not zone then return end
    HandlePlayerDeathInZone(zone, src)
end)

-- =============================
-- CREATE WAR EVENT
-- =============================
RegisterNetEvent("SY_Territories:createWar", function(zone, defenderGang, attackerGang, warTime)
    if ZoneFights[zone] then
        SY:ServerNotification('error', locale('msg_WarAlreadyActive', GetZoneLabel(zone)))
        return
    end
    if not Config.Territories[zone] then
        SY:ServerNotification('error', locale('msg_InvalidZone', GetZoneLabel(zone)))
        return
    end

    if not Config.Gangs[defenderGang] or not Config.Gangs[attackerGang] then
        SY:ServerNotification('error', locale('msg_InvalidGang', GetGangLabel(defenderGang), GetGangLabel(attackerGang)))
        return
    end

    StartZoneFight(zone, defenderGang, attackerGang, (warTime or 0) * 60)
end)

-- =============================
-- CALLBACKS
-- =============================
lib.callback.register('SY_Territories:server:getGangs', function()
    return GetCoreGangs()
end)

-- =============================
-- COMMANDS
-- =============================
lib.addCommand('createwar', {
    help = 'Create a war in a territory zone',
    restricted = 'group.admin'
}, function(source)
    local result = lib.callback.await(
        'SY_Territories:client:openCreateWarUi',
        source
    )
    return result
end)

lib.addCommand('setterritory', {
    help = 'Set influence and gang of a specific zone',
    params = {
        {
            name = 'zone',
            type = 'string',
            help = 'The name of the zone to set',
        },
        {
            name = 'gang',
            type = 'string',
            help = 'The name of the gang to set',
        },
        {
            name = 'influence',
            type = 'number',
            help = 'The influence to set',
        },
    },
    restricted = 'group.admin'
}, function(source, args)
    local zoneName = args.zone
    local gangName = args.gang
    local influence = args.influence

    local terr = Territories[zoneName]
    if terr then
        terr.gang = gangName
        terr.influence = influence or 50

        execute(
            "UPDATE territories SET gang = ?, influence = ? WHERE name = ?",
            { gangName, terr.influence, zoneName }
        )
        TriggerClientEvent("SY_Territories:sync", -1, Territories)
        return true
    end
    return false
end)

lib.addCommand('stopwar', {
    help = 'Forcefully end a war in a specific zone',
    params = {
        {
            name = 'zone',
            type = 'string',
            help = 'The name of the zone to stop the war in',
        },
    },
    restricted = 'group.admin'
}, function(source, args)
    local zone = args.zone
    if ZoneFights[zone] then
        EndZoneFight(zone)
    else
        SY:ServerNotification('error', locale('msg_NoActiveWar', GetZoneLabel(zone)))
    end
end)

lib.addCommand('setinfuipos', {
    help = 'Set the influence UI position',
}, function(source)
    TriggerClientEvent('SY_Territories:client:setInfluenceUiPosition', source)
end)

lib.addCommand('setwaruipos', {
    help = 'Set the war UI position',
}, function(source)
    TriggerClientEvent('SY_Territories:client:setWarUiPosition', source)
end)


lib.addCommand('setwarglob', {
    help = 'Set the war Glob for zone',
    params = {
        {
            name = 'zone',
            type = 'string',
            help = 'The name of the zone to set',
        }
    },
    restricted = 'group.admin'
}, function(source, args)
    print(args.zone)
    TriggerClientEvent("SY_Territories:Client:CreateZoneGlob", -1, args.zone)
end)
lib.addCommand('removewarglob', {
    help = 'Remove the war Glob for zone',
    params = {
        {
            name = 'zone',
            type = 'string',
            help = 'The name of the zone to set',
        }
    },
    restricted = 'group.admin'
}, function(source, args)
    TriggerClientEvent("SY_Territories:Client:RemoveZoneGlob", -1, args.zone)
end)
-- =============================
-- GANG JOB UPDATE
-- =============================
function UpdateGangJob(source)
    TriggerClientEvent("SY_Territories:syncOnPlayerGangChange", -1)
end

-- =============================
-- RESOURCE STOP HANDLER
-- =============================
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for zone, _ in pairs(ZoneFights) do
            EndZoneFight(zone)
        end
    end
end)

-- =============================
-- EXPORTS
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
--- @return table|nil  -- { gang: string, influence: number }
exports('GetZoneData', function(zoneName)
    return Territories[zoneName]
end)

--- Returns table of all zones and their data
--- @return table<string, { gang: string, influence: number }>
exports('GetAllZones', function()
    return Territories
end)

--- Returns table of zones owned by a given gang
--- @param gangName string
--- @return table<string, { gang: string, influence: number }>
exports('GetZonesByGang', function(gangName)
    local result = {}
    for zoneName, data in pairs(Territories) do
        if data.gang == gangName then
            result[zoneName] = data
        end
    end
    return result
end)

--- Check if a gang currently owns a zone
--- @param zoneName string
--- @param gangName string
--- @return boolean
exports('IsGangZoneOwner', function(zoneName, gangName)
    local terr = Territories[zoneName]
    return terr and terr.gang == gangName or false
end)

-- =============================
-- SERVER EXPORTS: FIGHT / WAR ACCESS
-- =============================

--- Returns table of all active fights
--- @return table<string, table>
exports('GetActiveFights', function()
    return ZoneFights
end)

--- Returns fight data for a single zone
--- @param zoneName string
--- @return table|nil
exports('GetZoneFight', function(zoneName)
    return ZoneFights[zoneName]
end)

--- Programmatically start a war (same as command/event)
--- @param zoneName string
--- @param defenderGang string
--- @param attackerGang string
--- @param warTimeMinutes number
--- @return boolean
exports('StartZoneWar', function(zoneName, defenderGang, attackerGang, warTimeMinutes)
    if not Config.Territories[zoneName] then
        return false
    end
    if not Config.Gangs[defenderGang] or not Config.Gangs[attackerGang] then
        return false
    end
    if ZoneFights[zoneName] then
        return false
    end

    StartZoneFight(zoneName, defenderGang, attackerGang, (warTimeMinutes or 0) * 60)
    return true
end)

--- Programmatically stop a war
--- @param zoneName string
--- @return boolean
exports('StopZoneWar', function(zoneName)
    if not ZoneFights[zoneName] then
        return false
    end
    EndZoneFight(zoneName)
    return true
end)

-- =============================
-- SERVER EXPORTS: ADMIN / OVERRIDES
-- =============================

--- Manually set a zone's owner & influence
--- @param zoneName string
--- @param gangName string
--- @param influence number|nil
--- @return boolean
exports('SetZoneOwner', function(zoneName, gangName, influence)
    local terr = Territories[zoneName]
    if terr then
        terr.gang = gangName
        terr.influence = influence or 50

        exports.oxmysql:execute(
            "UPDATE territories SET gang = ?, influence = ? WHERE name = ?",
            { gangName, terr.influence, zoneName }
        )
        TriggerClientEvent("SY_Territories:sync", -1, Territories)
        return true
    end
    return false
end)

--- Add or remove influence of a zone for a given gang.
--- If the gang doesn't match current owner and influence hits <= 0, ownership flips.
--- @param zoneName string
--- @param gangName string
--- @param amount number (can be negative)
--- @return boolean
exports('AddZoneInfluence', function(zoneName, gangName, amount)
    local terr = Territories[zoneName]
    if not terr then return false end

    amount = amount or 0
    if amount == 0 then return true end

    if terr.gang == gangName then
        terr.influence = math.max(1, math.min(100, (terr.influence or 0) + amount))
    else
        terr.influence = (terr.influence or 0) + amount
        if terr.influence <= 0 then
            terr.gang = gangName
            terr.influence = 1
        end
    end

    exports.oxmysql:execute(
        "UPDATE territories SET gang = ?, influence = ? WHERE name = ?",
        { terr.gang, terr.influence, zoneName }
    )
    TriggerClientEvent("SY_Territories:sync", -1, Territories)

    return true
end)
