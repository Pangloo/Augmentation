local Lists = {}

--------------------------------------------------------------------------------
-- BUFFS & DEBUFFS (From Nova_Library/spellbooks.lua)
--------------------------------------------------------------------------------
Lists.BUFFS = {
    EBON_MIGHT = 395152,
    EBON_MIGHT_BUFF = 395296, -- Actual buff ID
    PRESCIENCE = 409311,
    PRESCIENCE_BUFF = 410089, -- Actual buff ID
    BLISTERING_SCALES = 360827,
    ESSENCE_BURST = 392268,
    HOVER = 358267,
    OBSIDIAN_SCALES = 363916,
    RENEWING_BLAZE = 374349,
    BREATH_BUFF = 390386,
    FONT_OF_MAGIC = 408083, -- Talent check
    TIP_THE_SCALES = 370553,
    SOURCE_OF_MAGIC = 369459,

    -- Attunements
    BLACK_ATTUNEMENT = 403264,
    BLACK_ATTUNEMENT2 = 403295,
    BRONZE_ATTUNEMENT = 403265,

    -- Other
    BLESSING_OF_THE_BRONZE = { 381732, 381741, 381746, 381748, 381749, 381750, 381751, 381752, 381753, 381754, 381756, 381757, 381758, 432652, 432658 },
}

Lists.DEBUFFS = {
    FIRE_BREATH = 357209,
    SHATTERING_STAR = 370452,
}

--------------------------------------------------------------------------------
-- DPS DUMMIES
--------------------------------------------------------------------------------
Lists.DPS_DUMMIES = {
    [194649] = true, -- Training Dummy (Dornogal)
    [194644] = true, -- Training Dummy (Dornogal)
    [194648] = true, -- Dungeoneer's Training Dummy (Dornogal)
    [113966] = true, -- Raid Training Dummy (Orgrimmar)
    [113964] = true, -- Raid Training Dummy (Stormwind)
    [79987] = true,  -- Training Dummy (Garrison)
    [198594] = true, -- Cleave Dummy
    [219250] = true, -- Tank Dummy
    [225984] = true, -- Dummy
    [199852] = true, -- PvP Dummy
    [233824] = true, -- dimensius

}

--------------------------------------------------------------------------------
-- INTERRUPT WHITELIST (Common M+ / Raid casts)
--------------------------------------------------------------------------------
Lists.INTERRUPT_WHITELIST = {
    -- High priority general
    [322450] = true, -- Consumption
    [328667] = true, -- Frostbolt Volley
    [452162] = true, -- Mending Web
    [430097] = true, -- Molten Metal
    [323057] = true, -- Spirit Bolt
    [340544] = true, -- Stimulate Regeneration
    [326046] = true, -- Stimulate Resistance
    [431333] = true, -- Tormenting Beam
    [207167] = true, -- Blinding Sleet
    [217832] = true, -- Imprison

    -- Add more from Nova_Library/lists.lua if needed
}

--------------------------------------------------------------------------------
-- DISPEL LOGIC
--------------------------------------------------------------------------------
Lists.DISPEL_LOGIC = {
    [320788] = { type = "debuffRange", stacks = 0, range = 16, buff = nil },   -- Frozen Binds
    [331399] = { type = "debuffStacks", stacks = 4, range = nil, buff = nil }, -- Infectious Rain
    [360687] = { type = "buff", stacks = nil, range = nil, buff = 361067 },
    [373509] = { type = "debuffStacks", stacks = 4, range = nil, buff = nil },
    [374273] = { type = "debuffStacks", stacks = 4, range = nil, buff = nil },
}

return Lists
