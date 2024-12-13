local ns = _G[LOOTAMELO_NAME];
ns.Database = ns.Database or {};

ns.Database.raids = {
    -- "MC",  -- Molten Core
    -- "OL",  -- Onyxia's Lair
    -- "BWL", -- Blackwing Lair
    -- "ZG",  -- Zul'Gurub
    -- "AQ20",-- Ruins of Ahn'Qiraj
    -- "AQ40",-- Temple of Ahn'Qiraj
    -- "Naxx Vanilla", -- Naxxramas
    -- "Kara", -- Karazhan
    -- "Gruul",-- Gruul's Lair
    -- "Mag",  -- Magtheridon's Lair
    -- "SSC",  -- Serpentshrine Cavern
    -- "TK",   -- The Eye
    "The Battle for Mount Hyjal",   -- Mount Hyjal
    "Black Temple",   -- Black Temple
    -- "ZA",   -- Zul'Aman
    -- "SWP",  -- Sunwell Plateau
    -- "Naxx 10", -- Naxxramas
    -- "Naxx 25", -- Naxxramas
    -- "OS 10",   -- The Obsidian Sanctum
    -- "OS 25",   -- The Obsidian Sanctum
    -- "EoE 10",  -- The Eye of Eternity
    -- "EoE 25",  -- The Eye of Eternity
    -- "Ulduar 10", -- Ulduar
    -- "Ulduar 25", -- Ulduar
    -- "ToC 10",   -- Trial of the Crusader
    -- "ToC 25",   -- Trial of the Crusader
    -- "ICC 10",   -- Icecrown Citadel
    -- "ICC 25",   -- Icecrown Citadel
    -- "RS 10",    -- Ruby Sanctum
    -- "RS 25"     -- Ruby Sanctum
}

ns.Database.items = {
    ["The Battle for Mount Hyjal"] = {
        ["Rage Winterchill"] = {
            [30871] = {name = "Bracers of Martyrdom", icon = "INV_bracer_13", dropRate = "17%"},
            [30870] = {name = "Cuffs of Devastation", icon = "INV_bracer_12", dropRate = "16%"},
            [30863] = {name = "Deadly Cuffs", icon = "INV_bracer_09", dropRate = "15%"},
            [30868] = {name = "Rejuvenating Bracers", icon = "", dropRate = "16%"},
            [30864] = {name = "Bracers of the Pathfinder", icon = "", dropRate = "15%"},
            [30869] = {name = "Howling Wind Bracers", icon = "", dropRate = "12%"},
            [30873] = {name = "Stillwater Boots", icon = "", dropRate = "14%"},
            [30866] = {name = "Blood-stained Pauldrons", icon = "", dropRate = "15%"},
            [30862] = {name = "Blessed Adamantite Bracers", icon = "", dropRate = "15%"},
            [30861] = {name = "Furious Shackles", icon = "", dropRate = "15%"},
            [30865] = {name = "Tracker's Blade", icon = "", dropRate = "15%"},
            [30872] = {name = "Chronicle of Dark Secrets", icon = "", dropRate = "16%"},
            [32459] = {name = "Time-Phased Phylactery", icon = "", dropRate = "8%"}
        },
        ["Anetheron"] = {
            [30884] = {name = "Hatefury Mantle", icon = "", dropRate = "16%"},
            [30888] = {name = "Anetheron's Noose", icon = "", dropRate = "16%"},
            [30885] = {name = "Archbishop's Slippers", icon = "", dropRate = "17%"},
            [30879] = {name = "Don Alejandro's Money Belt", icon = "", dropRate = "16%"},
            [30886] = {name = "Enchanted Leather Sandals", icon = "", dropRate = "15%"},
            [30887] = {name = "Golden Links of Restoration", icon = "", dropRate = "16%"},
            [30880] = {name = "Quickstrider Moccasins", icon = "", dropRate = "16%"},
            [30878] = {name = "Glimmering Steel Mantle", icon = "", dropRate = "16%"},
            [30874] = {name = "The Unbreakable Will", icon = "", dropRate = "16%"},
            [30881] = {name = "Blade of Infamy", icon = "", dropRate = "15%"},
            [30883] = {name = "Pillar of Ferocity", icon = "", dropRate = "16%"},
            [30882] = {name = "Bastion of Light", icon = "", dropRate = "15%"},   
        },
        ["Kaz'rogal"] = {
            [30895] = {name = "Angelista's Sash", icon = "", dropRate = "16%"},
            [30916] = {name = "Leggings of Channeled Elements", icon = "", dropRate = "17%"},
            [30894] = {name = "Blue Suede Shoes", icon = "", dropRate = "16%"},
            [30917] = {name = "Razorfury Mantle", icon = "", dropRate = "17%"},
            [30914] = {name = "Belt of the Crescent Moon", icon = "", dropRate = "9%"},
            [30891] = {name = "Black Featherlight Boots", icon = "", dropRate = "14%"},
            [30892] = {name = "Beast-tamer's Shoulders", icon = "", dropRate = "15%"},
            [30919] = {name = "Valestalker Girdle", icon = "", dropRate = "15%"},
            [30893] = {name = "Sun-touched Chain Leggings", icon = "", dropRate = "15%"},
            [30915] = {name = "Belt of Seething Fury", icon = "", dropRate = "17%"},
            [30918] = {name = "Hammer of Atonement", icon = "", dropRate = "17%"},
            [30889] = {name = "Kaz'rogal's Hardened Heart", icon = "", dropRate = "16%"},
        },
        ["Azgalor"] = {
            [30899] = {name = "Don Rodrigo's Poncho", icon = "", dropRate = "15%"},
            [30898] = {name = "Shady Dealer's Pantaloons", icon = "", dropRate = "16%"},
            [30900] = {name = "Bow-stitched Leggings", icon = "", dropRate = "15%"},
            [30896] = {name = "Glory of the Defender", icon = "", dropRate = "15%"},
            [30897] = {name = "Girdle of Hope", icon = "", dropRate = "15%"},
            [30901] = {name = "Boundless Agony", icon = "", dropRate = "16%"},
            [31092] = {name = "Gloves of the Forgotten Conqueror", icon = "", dropRate = "74%"},
            [31094] = {name = "Gloves of the Forgotten Protector", icon = "", dropRate = "73%"},
            [31093] = {name = "Gloves of the Forgotten Vanquisher", icon = "", dropRate = "73%"},
        },
        ["Archimonde"] = {
            [30913] = {name = "Robes of Rhonin", icon = "", dropRate = "15%"},
            [30912] = {name = "Leggings of Eternity", icon = "", dropRate = "15%"},
            [30905] = {name = "Midnight Chestguard", icon = "", dropRate = "14%"},
            [30907] = {name = "Mail of Fevered Pursuit", icon = "", dropRate = "15%"},
            [30904] = {name = "Savior's Grasp", icon = "", dropRate = "14%"},
            [30903] = {name = "Legguards of Endless Rage", icon = "", dropRate = "15%"},
            [30911] = {name = "Scepter of Purification", icon = "", dropRate = "15%"},
            [30910] = {name = "Tempest of Chaos", icon = "", dropRate = "14%"},
            [30902] = {name = "Cataclysm's Edge", icon = "", dropRate = "15%"},
            [30908] = {name = "Apostle of Argus", icon = "", dropRate = "15%"},
            [30909] = {name = "Antonidas's Aegis of Rapt Concentration", icon = "", dropRate = "15%"},
            [30906] = {name = "Bristleblitz Striker", icon = "", dropRate = "15%"},
            [30914] = {name = "Deadeye", icon = "", dropRate = "14%"},
        },
        ["Trash"] = {
            [32590] = { name = "Nethervoid Cloak", icon = "", dropRate = "1%" },
            [34010] = { name = "Pepe's Shroud of Pacification", icon = "", dropRate = "1%" },
            [32609] = { name = "Boots of the Divine Light", icon = "", dropRate = "1%" },
            [32592] = { name = "Chestguard of Relentless Storms", icon = "", dropRate = "1%" },
            [32591] = { name = "Choker of Serrated Blades", icon = "", dropRate = "1%" },
            [32589] = { name = "Hellfire-Encased Pendant", icon = "", dropRate = "1%" },
            [34009] = { name = "Hammer of Judgement", icon = "", dropRate = "1%" },
            [32946] = { name = "Claw of Molten Fury", icon = "", dropRate = "0.46%" },
            [32945] = { name = "Fist of Molten Fury", icon = "", dropRate = "0.42%" },
            [32428] = { name = "Heart of Darkness", icon = "", dropRate = "16%" },
            [32897] = { name = "Mark of the Illidari", icon = "", dropRate = "27%" },
            [32285] = { name = "Design: Flashing Crimson Spinel", icon = "", dropRate = "4%" },
            [32296] = { name = "Design: Great Lionseye", icon = "", dropRate = "3%" },
            [32303] = { name = "Design: Inscribed Pyrestone", icon = "", dropRate = "3%" },
            [32295] = { name = "Design: Mystic Lionseye", icon = "", dropRate = "4%" },
            [32298] = { name = "Design: Shifting Shadowsong Amethyst", icon = "", dropRate = "4%" },
            [32297] = { name = "Design: Sovereign Shadowsong Amethyst", icon = "", dropRate = "4%" },
            [32289] = { name = "Design: Stormy Empyrean Sapphire", icon = "", dropRate = "4%" },
            [32307] = { name = "Design: Veiled Pyrestone", icon = "", dropRate = "3%" }
        }
    },
    ["Black Temple"] = {
        ["High Warlord Naj'entus"] = {
            [32239] = { name = "Slippers of the Seacaller", icon = "inv_boots_cloth_16", dropRate = "15%" },
            [32240] = { name = "Guise of the Tidal Lurker", icon = "inv_helmet_94", dropRate = "16%" },
            [32377] = { name = "Mantle of Darkness", icon = "inv_shoulder_67", dropRate = "15%" },
            [32241] = { name = "Helm of Soothing Currents", icon = "inv_helmet_97", dropRate = "10%" },
            [32234] = { name = "Fists of Mukoa", icon = "inv_gauntlets_59", dropRate = "16%" },
            [32242] = { name = "Boots of Oceanic Fury", icon = "inv_boots_chain_12", dropRate = "6%" },
            [32232] = { name = "Eternium Shell Bracers", icon = "inv_bracer_14", dropRate = "16%" },
            [32243] = { name = "Pearl Inlaid Boots", icon = "inv_boots_chain_08", dropRate = "10%" },
            [32245] = { name = "Tide-stomper's Greaves", icon = "inv_boots_plate_04", dropRate = "7%" },
            [32238] = { name = "Ring of Calming Waves", icon = "inv_jewelry_ring_57", dropRate = "16%" },
            [32247] = { name = "Ring of Captured Storms", icon = "inv_jewelry_ring_60", dropRate = "16%" },
            [32237] = { name = "The Maelstrom's Fury", icon = "inv_weapon_shortblade_58", dropRate = "15%" },
            [32236] = { name = "Rising Tide", icon = "inv_axe_56", dropRate = "16%" },
            [32248] = { name = "Halberd of Desolation", icon = "inv_weapon_halberd_20", dropRate = "16%" },
        },
        ["Supremus"] = {
            [32256] = { name = "Waistwrap of Infinity", icon = "inv_belt_03", dropRate = "16%" },
            [32252] = { name = "Nether Shadow Tunic", icon = "inv_chest_leather_03", dropRate = "14%" },
            [32259] = { name = "Bands of the Coming Storm", icon = "inv_bracer_02", dropRate = "6%" },
            [32251] = { name = "Wraps of Precise Flight", icon = "inv_bracer_06", dropRate = "15%" },
            [32258] = { name = "Naturalist's Preserving Cinch", icon = "inv_belt_22", dropRate = "9%" },
            [32250] = { name = "Pauldrons of Abyssal Fury", icon = "inv_shoulder_haremmatron_d_01", dropRate = "16%" },
            [32260] = { name = "Choker of Endless Nightmares", icon = "inv_jewelry_necklace_35", dropRate = "17%" },
            [32261] = { name = "Band of the Abyssal Lord", icon = "inv_jewelry_ring_70", dropRate = "14%" },
            [32257] = { name = "Idol of the White Stag", icon = "inv_qirajidol_alabaster", dropRate = "15%" },
            [32254] = { name = "The Brutalizer", icon = "inv_axe_59", dropRate = "15%" },
            [32262] = { name = "Syphon of the Nathrezim", icon = "inv_mace_44", dropRate = "16%" },
            [32255] = { name = "Felstone Bulwark", icon = "inv_shield_38", dropRate = "15%" },
            [32253] = { name = "Legionkiller", icon = "inv_weapon_crossbow_20", dropRate = "16%" }
        },
        ["Shade of Akama"] = {
            [32273] = { name = "Amice of Brilliant Light", icon = "", dropRate = "16%" },
            [32270] = { name = "Focused Mana Bindings", icon = "", dropRate = "15%" },
            [32513] = { name = "Wristbands of Divine Influence", icon = "", dropRate = "16%" },
            [32265] = { name = "Shadow-walker's Cord", icon = "", dropRate = "16%" },
            [32271] = { name = "Kilt of Immortal Nature", icon = "", dropRate = "14%" },
            [32264] = { name = "Shoulders of the Hidden Predator", icon = "", dropRate = "16%" },
            [32275] = { name = "Spiritwalker Gauntlets", icon = "", dropRate = "9%" },
            [32276] = { name = "Flashfire Girdle", icon = "", dropRate = "5%" },
            [32279] = { name = "The Seeker's Wristguards", icon = "", dropRate = "8%" },
            [32278] = { name = "Grips of Silent Justice", icon = "", dropRate = "15%" },
            [32263] = { name = "Praetorian's Legguards", icon = "", dropRate = "14%" },
            [32268] = { name = "Myrmidon's Treads", icon = "", dropRate = "16%" },
            [32266] = { name = "Ring of Deceitful Intent", icon = "", dropRate = "16%" },
            [32361] = { name = "Blind-Seer's Icon", icon = "", dropRate = "15%" },
        },
        ["Teron Gorefiend"] = {
            [32323] = { name = "Shadowmoon Destroyer's Drape", icon = "", dropRate = "17%" },
            [32329] = { name = "Cowl of Benevolence", icon = "", dropRate = "17%" },
            [32327] = { name = "Robe of the Shadow Council", icon = "", dropRate = "15%" },
            [32324] = { name = "Insidious Bands", icon = "", dropRate = "17%" },
            [32328] = { name = "Botanist's Gloves of Growth", icon = "", dropRate = "17%" },
            [32510] = { name = "Softstep Boots of Tracking", icon = "", dropRate = "15%" },
            [32280] = { name = "Gauntlets of Enforcement", icon = "", dropRate = "15%" },
            [32512] = { name = "Girdle of Lordaeron's Fallen", icon = "", dropRate = "19%" },
            [32330] = { name = "Totem of Ancestral Guidance", icon = "", dropRate = "13%" },
            [32348] = { name = "Soul Cleaver", icon = "", dropRate = "19%" },
            [32326] = { name = "Twisted Blades of Zarak", icon = "", dropRate = "11%" },
            [32325] = { name = "Rifle of the Stoic Guardian", icon = "", dropRate = "14%" },
        },
        ["Gurtogg Bloodboil"] = {
            [32337] = { name = "Shroud of Forgiveness", icon = "", dropRate = "16%" },
            [32338] = { name = "Blood-cursed Shoulderpads", icon = "", dropRate = "15%" },
            [32340] = { name = "Garments of Temperance", icon = "", dropRate = "15%" },
            [32339] = { name = "Belt of Primal Majesty", icon = "", dropRate = "14%" },
            [32334] = { name = "Vest of Mounting Assault", icon = "", dropRate = "15%" },
            [32342] = { name = "Girdle of Mighty Resolve", icon = "", dropRate = "8%" },
            [32333] = { name = "Girdle of Stability", icon = "", dropRate = "16%" },
            [32341] = { name = "Leggings of Divine Retribution", icon = "", dropRate = "14%" },
            [32335] = { name = "Unstoppable Aggressor's Ring", icon = "", dropRate = "16%" },
            [32501] = { name = "Shadowmoon Insignia", icon = "", dropRate = "15%" },
            [32269] = { name = "Messenger of Fate", icon = "", dropRate = "16%" },
            [32344] = { name = "Staff of Immaculate Recovery", icon = "", dropRate = "15%" },
            [32343] = { name = "Wand of Prismatic Focus", icon = "", dropRate = "14%" },
        },
        ["Reliquary of Souls"] = {
            [32353] = { name = "Gloves of Unfailing Faith", icon = "", dropRate = "17%" },
            [32351] = { name = "Elunite Empowered Bracers", icon = "", dropRate = "8%" },
            [32347] = { name = "Grips of Damnation", icon = "", dropRate = "16%" },
            [32352] = { name = "Naturewarden's Treads", icon = "", dropRate = "9%" },
            [32517] = { name = "The Wavemender's Mantle", icon = "", dropRate = "17%" },
            [32346] = { name = "Boneweave Girdle", icon = "", dropRate = "16%" },
            [32354] = { name = "Crown of Empowered Fate", icon = "", dropRate = "16%" },
            [32345] = { name = "Dreadboots of the Legion", icon = "", dropRate = "15%" },
            [32349] = { name = "Translucent Spellthread Necklace", icon = "", dropRate = "16%" },
            [32362] = { name = "Pendant of Titans", icon = "", dropRate = "15%" },
            [32350] = { name = "Touch of Inspiration", icon = "", dropRate = "16%" },
            [32332] = { name = "Torch of the Damned", icon = "", dropRate = "17%" },
            [32363] = { name = "Naaru-Blessed Life Rod", icon = "", dropRate = "14%" },
        },
        ["Mother Shahraz"] = {
            [32367] = { name = "Leggings of Devastation", icon = "", dropRate = "16%" },
            [32366] = { name = "Shadowmaster's Boots", icon = "", dropRate = "15%" },
            [32365] = { name = "Heartshatter Breastplate", icon = "", dropRate = "15%" },
            [32370] = { name = "Nadina's Pendant of Purity", icon = "", dropRate = "15%" },
            [32368] = { name = "Tome of the Lightbringer", icon = "", dropRate = "15%" },
            [32369] = { name = "Blade of Savagery", icon = "INV_Sword_87", dropRate = "15%" },
            [31101] = { name = "Pauldrons of the Forgotten Conqueror", icon = "", dropRate = "76%" },
            [31103] = { name = "Pauldrons of the Forgotten Protector", icon = "", dropRate = "80%" },
            [31102] = { name = "Pauldrons of the Forgotten Vanquisher", icon = "", dropRate = "77%" },
        },
        ["The Illidari Council"] = {
            [32331] = { name = "Cloak of the Illidari Council", icon = "", dropRate = "16%" },
            [32519] = { name = "Belt of Divine Guidance", icon = "", dropRate = "16%" },
            [32518] = { name = "Veil of Turning Leaves", icon = "", dropRate = "12%" },
            [32376] = { name = "Forest Prowler's Helm", icon = "", dropRate = "17%" },
            [32373] = { name = "Helm of the Illidari Shatterer", icon = "", dropRate = "17%" },
            [32505] = { name = "Madness of the Betrayer", icon = "", dropRate = "16%" },
            [31098] = { name = "Leggings of the Forgotten Conqueror", icon = "", dropRate = "34%" },
            [31100] = { name = "Leggings of the Forgotten Protector", icon = "", dropRate = "33%" },
            [31099] = { name = "Leggings of the Forgotten Vanquisher", icon = "", dropRate = "34%" },
        },
        ["Illidan Stormrage"] = {
            [32524] = { name = "Shroud of the Highborne", icon = "", dropRate = "16%" },
            [32525] = { name = "Cowl of the Illidari High Lord", icon = "", dropRate = "15%" },
            [32235] = { name = "Cursed Vision of Sargeras", icon = "", dropRate = "16%" },
            [32521] = { name = "Faceplate of the Impenetrable", icon = "", dropRate = "14%" },
            [32497] = { name = "Stormrage Signet Ring", icon = "", dropRate = "15%" },
            [32483] = { name = "The Skull of Gul'dan", icon = "", dropRate = "16%" },
            [32496] = { name = "Memento of Tyrande", icon = "", dropRate = "15%" },
            [32837] = { name = "Warglaive of Azzinoth", icon = "", dropRate = "4%" },
            [32838] = { name = "Warglaive of Azzinoth", icon = "", dropRate = "4%" },
            [31089] = { name = "Chestguard of the Forgotten Conqueror", icon = "", dropRate = "78%" },
            [31091] = { name = "Chestguard of the Forgotten Protector", icon = "", dropRate = "79%" },
            [31090] = { name = "Chestguard of the Forgotten Vanquisher", icon = "", dropRate = "78%" },
            [32471] = { name = "Shard of Azzinoth", icon = "", dropRate = "16%" },
            [32500] = { name = "Crystal Spire of Karabor", icon = "", dropRate = "15%" },
            [32374] = { name = "Zhar'doom, Greatstaff of the Devourer", icon = "", dropRate = "14%" },
            [32375] = { name = "Bulwark of Azzinoth", icon = "", dropRate = "14%" },
            [32336] = { name = "Black Bow of the Betrayer", icon = "", dropRate = "16%" }
        }
        
    }
}