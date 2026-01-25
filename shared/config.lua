Config = {}

--  ██████╗ ███████╗███╗   ██╗███████╗██████╗  █████╗ ██╗          ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗
-- ██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔══██╗██╔══██╗██║         ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝
-- ██║  ███╗█████╗  ██╔██╗ ██║█████╗  ██████╔╝███████║██║         ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
-- ██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║██║         ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
-- ╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║██║  ██║███████╗    ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
--  ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝     ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝

Config.Locale = "en"
Config.Framework = "esx" -- options qb, qbox, esx, standalone
Config.Glob = true       -- Globally visible marker on zone if war is active
Config.InfluenceTick = 2000
Config.InfluenceGain = 1
Config.InfluenceLoss = 1


--  ██████╗  █████╗ ███╗   ██╗ ██████╗      ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗
-- ██╔════╝ ██╔══██╗████╗  ██║██╔════╝     ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝
-- ██║  ███╗███████║██╔██╗ ██║██║  ███╗    ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
-- ██║   ██║██╔══██║██║╚██╗██║██║   ██║    ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
-- ╚██████╔╝██║  ██║██║ ╚████║╚██████╔╝    ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
--  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝      ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝

Config.BlipColorIDs = {
    white0            = 0,  -- White
    red               = 1,  -- Red
    green             = 2,  -- Green
    blue              = 3,  -- Blue
    white             = 4,  -- White
    yellow            = 5,  -- Yellow

    light_red         = 6,  -- Light Red
    violet            = 7,  -- Violet
    pink              = 8,  -- Pink
    light_orange      = 9,  -- Light Orange
    light_brown       = 10, -- Light Brown
    light_green       = 11, -- Light Green
    light_blue        = 12, -- Light Blue
    light_purple      = 13, -- Light Purple
    dark_purple       = 14, -- Dark Purple
    cyan              = 15, -- Cyan
    light_yellow      = 16, -- Light Yellow
    orange            = 17, -- Orange
    light_blue2       = 18, -- Light Blue
    dark_pink         = 19, -- Dark Pink
    dark_yellow       = 20, -- Dark Yellow
    dark_orange       = 21, -- Dark Orange
    light_gray        = 22, -- Light Gray
    light_pink        = 23, -- Light Pink
    lemon_green       = 24, -- Lemon Green
    forest_green      = 25, -- Forest Green
    electric_blue     = 26, -- Electric Blue
    bright_purple     = 27, -- Bright Purple
    dark_yellow2      = 28, -- Dark Yellow
    dark_blue         = 29, -- Dark Blue
    dark_cyan         = 30, -- Dark Cyan
    light_brown2      = 31, -- Light Brown
    light_blue3       = 32, -- Light Blue
    light_yellow2     = 33, -- Light Yellow
    light_pink2       = 34, -- Light Pink
    light_red2        = 35, -- Light Red
    beige             = 36, -- Beige
    white2            = 37, -- White
    blue2             = 38, -- Blue
    light_gray2       = 39, -- Light Gray
    dark_gray         = 40, -- Dark Gray
    pink_red          = 41, -- Pink Red
    blue3             = 42, -- Blue
    light_green2      = 43, -- Light Green
    light_orange2     = 44, -- Light Orange
    white3            = 45, -- White
    gold              = 46, -- Gold
    orange2           = 47, -- Orange
    brilliant_rose    = 48, -- Brilliant Rose
    red2              = 49, -- Red
    medium_purple     = 50, -- Medium Purple
    salmon            = 51, -- Salmon
    dark_green        = 52, -- Dark Green
    blizzard_blue     = 53, -- Blizzard Blue
    oracle_blue       = 54, -- Oracle Blue
    silver            = 55, -- Silver
    brown             = 56, -- Brown
    blue4             = 57, -- Blue
    east_bay          = 58, -- East Bay
    red3              = 59, -- Red
    yellow_orange     = 60, -- Yellow Orange
    mulberry_pink     = 61, -- Mulberry Pink
    alto_gray         = 62, -- Alto Gray
    jelly_bean_blue   = 63, -- Jelly Bean Blue
    dark_orange2      = 64, -- Dark Orange
    mamba             = 65, -- Mamba
    yellow_orange2    = 66, -- Yellow Orange
    blue5             = 67, -- Blue
    blue6             = 68, -- Blue
    green2            = 69, -- Green
    yellow_orange3    = 70, -- Yellow Orange
    yellow_orange4    = 71, -- Yellow Orange
    transparent_black = 72, -- Transparent Black
    yellow_orange5    = 73, -- Yellow Orange
    blue7             = 74, -- Blue
    red4              = 75, -- Red
    deep_red          = 76, -- Deep Red
    blue8             = 77, -- Blue
    oracle_blue2      = 78, -- Oracle Blue
    transparent_red   = 79, -- Transparent Red
    transparent_blue  = 80, -- Transparent Blue
    orange3           = 81, -- Orange
    light_green3      = 82, -- Light Green
    purple            = 83, -- Purple
    blue9             = 84, -- Blue
    white4            = 85, -- white-ish
}


Config.Gangs = {
    ["police"] = {
        color = "blue",
        label = "Police",
    },
    ["tva"] = {
        color = "red",
        label = "TVA",
    },
    ["kva"] = {
        color = "green",
        label = "KVA",
    },
    ["tga"] = {
        color = "yellow",
        label = "TGA",
    },
    ["srra"] = {
        color = "yellow",
        label = "SRRA",
    },
}

-- ████████╗███████╗██████╗ ██████╗ ██╗████████╗ ██████╗ ██████╗ ██╗███████╗███████╗
-- ╚══██╔══╝██╔════╝██╔══██╗██╔══██╗██║╚══██╔══╝██╔═══██╗██╔══██╗██║██╔════╝██╔════╝
--    ██║   █████╗  ██████╔╝██████╔╝██║   ██║   ██║   ██║██████╔╝██║█████╗  ███████╗
--    ██║   ██╔══╝  ██╔══██╗██╔══██╗██║   ██║   ██║   ██║██╔══██╗██║██╔══╝  ╚════██║
--    ██║   ███████╗██║  ██║██║  ██║██║   ██║   ╚██████╔╝██║  ██║██║███████╗███████║
--    ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝

Config.Territories = {
    ["eastv"] = {
        label = "East V",
        defaultGang = "police",
        influence = 100.0,
        areas = {
            { coords = vector3(908.8499755859376, -142.14999389648438, 76.37000274658203), radius = 170.0 }
        }
    },

    ["davis"] = {
        label = "Davis",
        defaultGang = "police",
        influence = 100.0,
        areas = {
            { coords = vector3(77.4000015258789, -1837.1700439453127, 25.52000045776367), radius = 170.0 }
        }
    },

    ["chamberlainhills"] = {
        label = "CHAMBERLAINHILLS",
        defaultGang = "police",
        influence = 100.0,
        areas = {
            { coords = vector3(-172.7100067138672, -1586.8199462890625, 34.83000183105469), radius = 170.0 }
        }
    },

    ["rancho"] = {
        label = "Rancho",
        defaultGang = "police",
        influence = 100.0,
        areas = {
            { coords = vector3(444.9200134277344, -1911.9100341796875, 24.6299991607666), radius = 170.0 }
        }
    },
}
