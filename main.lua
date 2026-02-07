--[[
    Augment Reality
    Author: Panglo
    Version: 1.0.0
]]

--------------------------------------------------------------------------------
-- IMPORTS
--------------------------------------------------------------------------------
---@type izi_api
local izi = require("common/izi_sdk")
---@type enums
local enums = require("common/enums")
---@type health_prediction
local health_pred = require("common/modules/health_prediction")
---@type unit_helper
local unit_helper = require("common/utility/unit_helper")


-- Local modules
local plugin = require("header")
if not plugin.load then return end

local spells = require("spells")
local lists = require("lists")
local funcs = require("functions")
local menu = require("menu")
local ui = require("ui")


--------------------------------------------------------------------------------
-- SPELL CALLBACKS
--------------------------------------------------------------------------------
local callback = {}

callback.prescience = function()
    if not menu.AUTO_PRESCIENCE:get_state() then return false end
    if not spells.PRESCIENCE:is_learned() or not spells.PRESCIENCE:cooldown_up() then return false end

    local me = izi.me()
    -- Check OoC setting
    if not me:affecting_combat() and not menu.OOC_PRESCIENCE:get_state() then
        return false
    end

    -- Only cast if we have less than 3 prescience buffs out
    if funcs.count_prescience_buffed(25) >= 3 then return false end

    local target = funcs.get_ally_without_prescience(25)
    if target and target:is_valid() and target:distance() <= 25 then
        return spells.PRESCIENCE:cast(target, "Prescience", { skip_facing = true })
    end
    return false
end

callback.ebonmight = function()
    if not menu.AUTO_EBON_MIGHT:get_state() then return false end
    if not spells.EBON_MIGHT:cooldown_up() then return false end
    if not funcs.can_cast_moving() then return false end

    local me = izi.me()
    if not me:affecting_combat() then return false end

    local has_buff, remains = funcs.has_ebon_might()

    -- Cast if we don't have it, or if it's about to expire (<5.5 seconds) and we have at least 2 prescience buffs
    if not has_buff or remains < 10 then
        return spells.EBON_MIGHT:cast(me, "Ebon Might", { skip_facing = true, skip_moving = true })
    end

    return false
end

callback.blisteringscales = function()
    if not menu.AUTO_BLISTERING_SCALES:get_state() then return false end
    if not spells.BLISTERING_SCALES:is_learned() or not spells.BLISTERING_SCALES:cooldown_up() then return false end
    if funcs.count_blistering_scales(25) >= 1 then return false end
    local tank = funcs.get_tank_without_blistering(25)
    if tank and tank:is_valid() and tank:distance() <= 25 then
        return spells.BLISTERING_SCALES:cast_safe(tank, "Blistering Scales", { skip_facing = true })
    end
    return false
end

callback.breathofeons = function()
    if not menu.USE_COOLDOWNS:get_state() then return false end
    if not menu.USE_BREATH_OF_EONS:get_state() then return false end
    if not spells.BREATH_OF_EONS:cooldown_up() then return false end

    -- Enable manual-only mode if bound to a key
    local boe_mode = menu.KEYBIND_MODES.BREATH_OF_EONS
    if menu.SHIFT_MODE:get() == boe_mode or
        menu.CTRL_MODE:get() == boe_mode or
        menu.ALT_MODE:get() == boe_mode then
        return false
    end

    local me = izi.me()
    return spells.BREATH_OF_EONS:cast(me, "Breath of Eons", { skip_facing = true })
end

callback.tipthescales = function()
    if not menu.USE_COOLDOWNS:get_state() then return false end
    if not menu.USE_TIP_THE_SCALES:get_state() then return false end
    if not spells.TIP_THE_SCALES:is_learned() or not spells.TIP_THE_SCALES:cooldown_up() then return false end

    local has_buff, remains = funcs.has_ebon_might()
    -- Use Tip the Scales before Fire Breath if Ebon Might has at least 2 seconds remaining
    if has_buff and remains >= 2 and spells.FIRE_BREATH:cooldown_up() then
        local me = izi.me()
        return spells.TIP_THE_SCALES:cast(me, "Tip the Scales", { skip_facing = true })
    end
    return false
end

callback.firebreath = function()
    if not spells.FIRE_BREATH:is_learned() or not spells.FIRE_BREATH:cooldown_up() then return false end
    local me = izi.me()
    if me:is_moving() and not me:has_buff(lists.BUFFS.TIP_THE_SCALES) then return false end

    -- Use relaxed logic for empowered spells
    if not funcs.should_cast_empowered() then return false end

    -- Use empowered version logic if needed, but izi.cast_charge_spell handles rank
    return izi.cast_charge_spell(spells.FIRE_BREATH, 1, me, "Fire Breath")
end

callback.upheaval = function()
    if not spells.UPHEAVAL:is_learned() or not spells.UPHEAVAL:cooldown_up() then return false end
    local me = izi.me()
    if me:is_moving() and not me:has_buff(lists.BUFFS.TIP_THE_SCALES) then return false end

    if not funcs.should_cast_empowered() then return false end

    -- Upheaval is AoE - use cluster targeting
    local cluster_target = funcs.get_biggest_cluster(10)
    if cluster_target and cluster_target:is_valid() and cluster_target:distance() <= 25 then
        return izi.cast_charge_spell(spells.UPHEAVAL, 1, cluster_target, "Upheaval")
    end
    --fallback to target if valid enemy
    local target = funcs.get_valid_enemy(spells.UPHEAVAL, nil, true, nil, lists.DPS_DUMMIES)
    if target and target:is_valid() and target:distance() <= 100 then
        return izi.cast_charge_spell(spells.UPHEAVAL, 1, target, "Upheaval")
    end
    return false
end

callback.eruption = function()
    if not spells.ERUPTION:is_learned() or not spells.ERUPTION:cooldown_up() then return false end
    if not funcs.can_cast_moving() then return false end

    if not funcs.should_cast_spender() then return false end

    local cluster_target = funcs.get_biggest_cluster(10)
    if cluster_target and cluster_target:is_valid() and cluster_target:distance() <= 25 then
        return spells.ERUPTION:cast(cluster_target, "Eruption", { skip_moving = true })
    end
    --fallback to target if valid enemy
    local target = funcs.get_valid_enemy(spells.ERUPTION, nil, true, nil, lists.DPS_DUMMIES)
    if target and target:is_valid() and target:distance() <= 100 then
        return spells.ERUPTION:cast(target, "Eruption", { skip_moving = true })
    end
    return false
end

callback.livingflame = function()
    if not spells.LIVING_FLAME:is_learned() then return false end
    if not funcs.can_cast_moving() then return false end

    local target = funcs.get_valid_enemy(spells.LIVING_FLAME, nil, true, nil, lists.DPS_DUMMIES)
    if target then
        return spells.LIVING_FLAME:cast_safe(target, "Living Flame", { skip_moving = true })
    end
    return false
end

callback.azurestrike = function()
    if not spells.AZURE_STRIKE:is_learned() then return false end

    local target = funcs.get_valid_enemy(spells.AZURE_STRIKE, nil, true, nil, lists.DPS_DUMMIES)
    if target then
        return spells.AZURE_STRIKE:cast_safe(target, "Azure Strike")
    end
    return false
end

callback.obsidianscales = function()
    if not menu.USE_DEFENSIVES:get_state() then return false end
    if not spells.OBSIDIAN_SCALES:is_learned() or not spells.OBSIDIAN_SCALES:cooldown_up() then return false end
    local local_player = core.object_manager.get_local_player()
    local local_player_hp = local_player:get_health()
    local local_player_max_hp = local_player:get_max_health()

    local incoming_damage = health_pred:get_incoming_damage(local_player, 5)
    local predicted_hp = local_player_hp - incoming_damage
    local predicted_hp_pct = (predicted_hp / local_player_max_hp) * 100 -- Convert to percentage
    local min_inc_dmg_hp_pct_slider_value = menu.OBSIDIAN_SCALES_HP:get()

    local should_cast_defensive = predicted_hp_pct <= min_inc_dmg_hp_pct_slider_value

    if should_cast_defensive then
        return spells.OBSIDIAN_SCALES:cast_safe(me, "Obsidian Scales", { skip_facing = true })
    end
    return false
end

callback.zephyr = function()
    if not menu.USE_DEFENSIVES:get_state() then return false end
    if not spells.ZEPHYR:is_learned() or not spells.ZEPHYR:cooldown_up() then return false end

    -- Check party average prediction
    local allies = izi.party(40, true) -- Include self
    if #allies == 0 then return false end

    local total_predicted_pct = 0
    local count = 0

    for _, ally in ipairs(allies) do
        if ally and ally:is_valid() and not ally:is_dead() then
            local hp = ally:get_health()
            local max_hp = ally:get_max_health()
            local incoming = health_pred:get_incoming_damage(ally, 5)

            local predicted = hp - incoming
            local pct = (predicted / max_hp) * 100

            total_predicted_pct = total_predicted_pct + pct
            count = count + 1
        end
    end

    if count == 0 then return false end

    local avg_predicted_pct = total_predicted_pct / count
    local threshold = menu.ZEPHYR_HP:get()

    if avg_predicted_pct <= threshold then
        local me = izi.me()
        return spells.ZEPHYR:cast_safe(me, "Zephyr (Party Avg)", { skip_facing = true })
    end
    return false
end

callback.verdantembrace = function()
    if not menu.USE_DEFENSIVES:get_state() then return false end
    if not spells.VERDANT_EMBRACE:is_learned() or not spells.VERDANT_EMBRACE:cooldown_up() then return false end

    local me = izi.me()
    if me:get_health_percentage() <= menu.VERDANT_EMBRACE_HP:get() then
        return spells.VERDANT_EMBRACE:cast_safe(me, "Verdant Embrace", { skip_facing = true })
    end
    return false
end

callback.emeraldblossom = function()
    if not menu.USE_DEFENSIVES:get_state() then return false end
    if not spells.EMERALD_BLOSSOM:is_learned() or not spells.EMERALD_BLOSSOM:cooldown_up() then return false end

    local me = izi.me()
    if me:get_health_percentage() <= menu.EMERALD_BLOSSOM_HP:get() then
        return spells.EMERALD_BLOSSOM:cast_safe(me, "Emerald Blossom", { skip_facing = true })
    end
    return false
end

callback.sourceofmagic = function()
    if not menu.AUTO_SOURCE_OF_MAGIC:get_state() then return false end
    if not spells.SOURCE_OF_MAGIC:is_learned() or not spells.SOURCE_OF_MAGIC:cooldown_up() then return false end

    if funcs.count_source_of_magic(25) < 1 then
        local healer = funcs.get_healer_without_som(25)
        if healer and healer:is_valid() and healer:distance() <= 25 then
            return spells.SOURCE_OF_MAGIC:cast_safe(healer, "Source of Magic", { skip_facing = true })
        end
    end
    return false
end

callback.blackattunement = function()
    if not spells.BLACK_ATTUNEMENT:is_learned() or not spells.BLACK_ATTUNEMENT:cooldown_up() then return false end

    local me = izi.me()
    if not me:has_buff(lists.BUFFS.BLACK_ATTUNEMENT) and not me:has_buff(lists.BUFFS.BLACK_ATTUNEMENT2) then
        return spells.BLACK_ATTUNEMENT:cast_safe(me, "Black Attunement", { skip_facing = true })
    end
    return false
end

callback.bronzeattunement = function()
    if not spells.BRONZE_ATTUNEMENT:is_learned() or not spells.BRONZE_ATTUNEMENT:cooldown_up() then return false end

    local me = izi.me()
    if not me:has_buff(lists.BUFFS.BRONZE_ATTUNEMENT) then
        return spells.BRONZE_ATTUNEMENT:cast_safe(me, "Bronze Attunement", { skip_facing = true })
    end
    return false
end

callback.blessingofthebronze = function()
    if not spells.BLESSING_OF_THE_BRONZE:is_learned() or not spells.BLESSING_OF_THE_BRONZE:cooldown_up() then return false end

    local me = izi.me()
    local has_blessing = false
    -- Check simple buff check on self first
    for _, buff_id in ipairs(lists.BUFFS.BLESSING_OF_THE_BRONZE) do
        if me:has_buff(buff_id) then
            has_blessing = true
            break
        end
    end

    if not has_blessing then
        return spells.BLESSING_OF_THE_BRONZE:cast_safe(me, "Blessing of the Bronze", { skip_facing = true })
    end
    return false
end

--------------------------------------------------------------------------------
-- ACTION LISTS
--------------------------------------------------------------------------------
local actionList = {}

actionList.buffs = function()
    if callback.blackattunement() then return true end
    if callback.prescience() then return true end
    if callback.ebonmight() then return true end
    if callback.sourceofmagic() then return true end
    if callback.blisteringscales() then return true end
    if callback.blessingofthebronze() then return true end
    if callback.bronzeattunement() then return true end
    return false
end

actionList.cooldowns = function()
    if callback.breathofeons() then return true end
    if callback.tipthescales() then return true end
    return false
end

actionList.defensives = function()
    if callback.obsidianscales() then return true end
    if callback.zephyr() then return true end
    if callback.verdantembrace() then return true end
    if callback.emeraldblossom() then return true end
    return false
end

actionList.dps = function()
    -- Priority 1: Use Fire Breath
    if callback.firebreath() then return true end
    -- Priority 2: Use AoE abilities
    if callback.upheaval() then return true end
    if callback.eruption() then return true end
    -- Then filler
    if callback.livingflame() then return true end
    if callback.azurestrike() then return true end
    return false
end

--------------------------------------------------------------------------------
-- MAIN UPDATE
--------------------------------------------------------------------------------
local function on_update()
    local me = izi.me()
    if not me or not me:is_valid() or me:is_mounted() or me:is_dead_or_ghost() then return end

    if not menu.is_enabled() then return end
    if not menu.is_rotation_enabled() then return end

    -- Keybind checks
    local action_shift, action_ctrl, action_alt
    local hold_cds = false

    local function handle_keybind(mode, is_pressed)
        if not is_pressed then return nil end
        if mode == menu.KEYBIND_MODES.PAUSE then
            return "PAUSE"
        elseif mode == menu.KEYBIND_MODES.BREATH_OF_EONS then
            if spells.BREATH_OF_EONS:cooldown_up() then
                spells.BREATH_OF_EONS:cast(me, "Breath of Eons (Keybind)", { skip_facing = true })
                return "CASTING"
            end
        elseif mode == menu.KEYBIND_MODES.HOLD_CDS then
            return "HOLD_CDS"
        end
        return nil
    end

    local res
    res = handle_keybind(menu.SHIFT_MODE:get(), funcs.is_shift_pressed())
    if res == "PAUSE" then return end
    if res == "CASTING" then return end
    if res == "HOLD_CDS" then hold_cds = true end

    res = handle_keybind(menu.CTRL_MODE:get(), funcs.is_ctrl_pressed())
    if res == "PAUSE" then return end
    if res == "CASTING" then return end
    if res == "HOLD_CDS" then hold_cds = true end

    res = handle_keybind(menu.ALT_MODE:get(), funcs.is_alt_pressed())
    if res == "PAUSE" then return end
    if res == "CASTING" then return end
    if res == "HOLD_CDS" then hold_cds = true end

    if me:is_casting() or me:is_channeling() then return false end

    if me:affecting_combat() then
        funcs.autotarget()

        if actionList.buffs() then return end
        if not hold_cds and actionList.cooldowns() then return end
        if actionList.defensives() then return end
        if actionList.dps() then return end
    else
        -- Out of combat: maintain buffs
        if actionList.buffs() then return end
    end
end

local function on_render()
    menu.draw()
end

core.register_on_update_callback(on_update)
core.register_on_render_menu_callback(on_render)
core.register_on_render_window_callback(ui.draw)

core.log("[Augment Reality] " .. plugin.version .. " Loaded successfully!")
