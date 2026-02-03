---@type izi_api
local izi = require("common/izi_sdk")

local Spells = {
    -- Core Rotation
    LIVING_FLAME = izi.spell(361469),
    AZURE_STRIKE = izi.spell(362969),
    FIRE_BREATH = izi.spell(357208),
    FIRE_BREATH_EMPOWERED = izi.spell(382266), -- Font of Magic empowered version
    UPHEAVAL = izi.spell(396286),
    ERUPTION = izi.spell(395160),
    PRESCIENCE = izi.spell(409311),
    BLISTERING_SCALES = izi.spell(360827),
    EBON_MIGHT = izi.spell(395152),
    BREATH_OF_EONS = izi.spell(442204),
    TIME_SKIP = izi.spell(404977),
    MOLTEN_EMBERS = izi.spell(452725),

    -- Defensive
    OBSIDIAN_SCALES = izi.spell(363916),
    RENEWING_BLAZE = izi.spell(374348),
    VERDANT_EMBRACE = izi.spell(360995),
    EMERALD_BLOSSOM = izi.spell(355913),
    ZEPHYR = izi.spell(374227),

    -- Utility
    QUELL = izi.spell(351338),
    RESCUE = izi.spell(370665),
    BLESSING_OF_THE_BRONZE = izi.spell(364342),
    CAUTERIZING_FLAME = izi.spell(374251),
    EXPUNGE = izi.spell(365585),
    LANDSLIDE = izi.spell(358385),
    OPPRESSING_ROAR = izi.spell(372048),
    HOVER = izi.spell(358267),
    TIME_SPIRAL = izi.spell(374968),
    SPATIAL_PARADOX = izi.spell(406732),
    SLEEP_WALK = izi.spell(360806),
    SOURCE_OF_MAGIC = izi.spell(369459),
    UNRAVEL = izi.spell(368432),
    TIP_THE_SCALES = izi.spell(370553),

    -- Attunements
    BLACK_ATTUNEMENT = izi.spell(403264),
    BLACK_ATTUNEMENT2 = izi.spell(403295),
    BRONZE_ATTUNEMENT = izi.spell(403265),

    -- Other
    DISINTEGRATE = izi.spell(356995),
    DEEP_BREATH = izi.spell(357210),
    RETURN_SPELL = izi.spell(361227),
}

return Spells
