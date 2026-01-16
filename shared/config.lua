Config = {}

-- UI Config
Config.PrimaryColor = 0
Config.PrimaryShade = 0

-- General Config
Config.Locale = "en"
Config.Debug = false
Config.InfluenceTick = 2000
Config.InfluenceGain = 1
Config.InfluenceLoss = 1


-- Gang Config

Config.Gangs = {
    ["ballas"] = {
        color = { 148, 0, 211 },
        name = "Ballas",
    },
    ["vagos"] = {
        color = { 255, 165, 0 },
        name = "Vagos",
    },
    ["marabunta"] = {
        color = { 0, 100, 0 },
        name = "Marabunta",
    },
    ["lostmc"] = {
        color = { 105, 105, 105 },
        name = "Lost MC",
    },
}

-- Territories Config
Config.Territories = {
    ["East V"] = {
        defaultGang = "ballas",
        influence = 100.0,
        areas = {
            { coords = vector3(908.85, -142.15, 76.37), radius = 170.0 }
        }
    },

    ["Davis"] = {
        defaultGang = "ballas",
        influence = 100.0,
        areas = {
            { coords = vector3(77.40, -1837.17, 25.52), radius = 170.0 }
        }
    }
}
