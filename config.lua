Config = {}

Config.blip = true
Config.blipc = vector3(55.8971, 111.5285, 79.1973)
-- Config.blipName = '<font face="Fire Sans">~w~[~b~BRIGADA~w~] Pošták' NENÍ POTŘEBA, NEBOT JE TO V LUNAR_ROBBERY
-- Config.blipSprite = 569
-- Config.blipScale = 0.6


Config.carSpawnCords = vector3(56.5468, 100.4454, 78.9451)
Config.carSpawnCrodsh = 158.3360
Config.car = "boxville2"

Config.addItemStock = "package"


Config.Pay1 = 80
Config.Pay2 = 600

Config.npcs = {
    { 
        identifier = "stocko", 
        model = "cs_floyd", 
        coords = vector3(121.0079, 100.9974, 81.1101), 
        heading = 161.7648, 
        name = "Skladník",
        options = {
            { title = 'Naložit zásilku', icon = 'box', event = 'cargoLoad' },
        }
    },
    { 
        identifier = "npc1", 
        model = "a_m_o_genstreet_01", 
        coords = vector3(-1580.2913, 179.7800, 58.4825), 
        heading = 202.9033, 
        name = "Učitel",
        options = {
            { title = 'Dát zásilku', icon = 'box', event = 'giveD' }
        }
    },
    { 
        identifier = "npc2", 
        model = "a_m_y_busicas_01", 
        coords = vector3(1829.5696, 3731.3167, 33.1280), 
        heading = 216.0471, 
        name = "John"
    },
    { 
        identifier = "npc3", 
        model = "a_m_m_soucent_03", 
        coords = vector3(174.0665, -86.9254, 68.5199), 
        heading = 254.9188, 
        name = "Delaer"
    },
    { 
        identifier = "npc4", 
        model = "a_m_m_hillbilly_01", 
        coords = vector3(1681.5900, 6428.2046, 32.1711), 
        heading = 340.7416, 
        name = "Pumpař"
    },
    { 
        identifier = "npc5", 
        model = "cs_guadalope", 
        coords = vector3(-279.4285, 6351.8193, 32.4891), 
        heading = 45.5528, 
        name = "Babka kořenkářka"
    },
    { 
        identifier = "npc6", 
        model = "s_m_y_fireman_01", 
        coords = vector3(-377.7408, 6120.5015, 31.4796), 
        heading = 49.4982, 
        name = "Hasič"
    },
    { 
        identifier = "npc7", 
        model = "s_m_m_pilot_01", 
        coords = vector3(2158.8252, 4780.5918, 41.0385), 
        heading = 80.6791, 
        name = "Pilot"
    },
    { 
        identifier = "npc8", 
        model = "s_m_y_airworker", 
        coords = vector3(2682.8994, 3512.0410, 53.3040), 
        heading = 74.6912, 
        name = "Prodavač"
    },
    { 
        identifier = "npc9", 
        model = "a_f_y_hipster_01", 
        coords = vector3(2484.1702, 3445.5540, 51.0683), 
        heading = 320.0995, 
        name = "Štětka"
    },
    { 
        identifier = "npc10", 
        model = "s_m_y_factory_01", 
        coords = vector3(1396.7212, 3624.1550, 35.0122), 
        heading = 30.1838, 
        name = "Dealer"
    },
    { 
        identifier = "npc11", 
        model = "ig_car3guy2", 
        coords = vector3(-3202.0334, 1194.8745, 9.5455), 
        heading = 175.9065, 
        name = "William"
    },
    { 
        identifier = "npc12", 
        model = "ig_janet", 
        coords = vector3(-2993.9207, 681.1931, 25.0362), 
        heading = 109.8584, 
        name = "Janet"
    },
    { 
        identifier = "npc13", 
        model = "ig_marnie", 
        coords = vector3(-1534.1957, -327.8838, 47.9111), 
        heading = 42.0850, 
        name = "Marnie"
    },
    { 
        identifier = "npc14", 
        model = "mp_m_waremech_01", 
        coords = vector3(844.9635, -901.7639, 25.2515), 
        heading = 268.5984, 
        name = "Mechanik"
    }
}


