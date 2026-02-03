---@type key_helper
local key_helper = require("common/utility/key_helper")

---@type control_panel_helper
local control_panel_utility = require("common/utility/control_panel_helper")

local Menu = {}

-- Create unique id prefixes
local ID = "augment_reality_"

-- Tree Nodes
local main_tree = core.menu.tree_node()
local tree_general = core.menu.tree_node()
local tree_buffs = core.menu.tree_node()
local tree_cooldowns = core.menu.tree_node()
local tree_defensives = core.menu.tree_node()

-- General Settings
Menu.ENABLED = core.menu.checkbox(true, ID .. "enabled")
Menu.ROTATION_ENABLED = core.menu.checkbox(true, ID .. "rot_enabled")
Menu.SHOW_HOTBAR = core.menu.checkbox(true, ID .. "show_hotbar")

-- Buffs
Menu.AUTO_PRESCIENCE = core.menu.checkbox(true, ID .. "auto_prescience")
Menu.OOC_PRESCIENCE = core.menu.checkbox(true, ID .. "ooc_prescience")
Menu.AUTO_EBON_MIGHT = core.menu.checkbox(true, ID .. "auto_ebon_might")
Menu.AUTO_BLISTERING_SCALES = core.menu.checkbox(true, ID .. "auto_blistering")
Menu.AUTO_SOURCE_OF_MAGIC = core.menu.checkbox(true, ID .. "auto_som")

-- Cooldowns
Menu.USE_COOLDOWNS = core.menu.checkbox(true, ID .. "use_cooldowns")
Menu.USE_BREATH_OF_EONS = core.menu.checkbox(false, ID .. "use_breath")
Menu.USE_TIP_THE_SCALES = core.menu.checkbox(true, ID .. "use_tip")

-- Defensives
Menu.USE_DEFENSIVES = core.menu.checkbox(true, ID .. "use_defensives")
Menu.OBSIDIAN_SCALES_HP = core.menu.slider_int(0, 100, 40, ID .. "obsidian_hp")
Menu.VERDANT_EMBRACE_HP = core.menu.slider_int(0, 100, 55, ID .. "verdant_hp")
Menu.ZEPHYR_HP = core.menu.slider_int(0, 100, 30, ID .. "zephyr_hp")
Menu.EMERALD_BLOSSOM_HP = core.menu.slider_int(0, 100, 75, ID .. "emerald_hp")

-- Keybinds
Menu.KEYBIND_MODES = {
    NOTHING = 1,
    PAUSE = 2,
    BREATH_OF_EONS = 3,
    HOLD_CDS = 4
}

local keybind_options = {
    "Nothing",
    "Pause",
    "Breath of Eons",
    "Hold CDs"
}

Menu.SHIFT_MODE = core.menu.combobox(Menu.KEYBIND_MODES.NOTHING, ID .. "shift_mode")
Menu.CTRL_MODE = core.menu.combobox(Menu.KEYBIND_MODES.NOTHING, ID .. "ctrl_mode")
Menu.ALT_MODE = core.menu.combobox(Menu.KEYBIND_MODES.NOTHING, ID .. "alt_mode")

-- Draw Function
function Menu.draw()
    main_tree:render("Augment Reality", function()
        tree_general:render("General", function()
            Menu.ENABLED:render("Enable Plugin")
            Menu.ROTATION_ENABLED:render("Enable Rotation")
            Menu.SHOW_HOTBAR:render("Show Hotbar")
            Menu.SHIFT_MODE:render("Shift Keybind", keybind_options)
            Menu.CTRL_MODE:render("Ctrl Keybind", keybind_options)
            Menu.ALT_MODE:render("Alt Keybind", keybind_options)
        end)

        tree_buffs:render("Buffs", function()
            Menu.AUTO_PRESCIENCE:render("Auto Prescience")
            Menu.OOC_PRESCIENCE:render("Prescience Out of Combat")
            Menu.AUTO_EBON_MIGHT:render("Auto Ebon Might")
            Menu.AUTO_BLISTERING_SCALES:render("Auto Blistering Scales")
            Menu.AUTO_SOURCE_OF_MAGIC:render("Auto Source of Magic")
        end)

        tree_cooldowns:render("Cooldowns", function()
            Menu.USE_COOLDOWNS:render("Use Cooldowns")
            if Menu.USE_COOLDOWNS:get_state() then
                Menu.USE_BREATH_OF_EONS:render("Use Breath of Eons")
                Menu.USE_TIP_THE_SCALES:render("Use Tip the Scales")
            end
        end)

        tree_defensives:render("Defensives", function()
            Menu.USE_DEFENSIVES:render("Use Defensives")
            if Menu.USE_DEFENSIVES:get_state() then
                Menu.OBSIDIAN_SCALES_HP:render("Obsidian Scales HP")
                Menu.VERDANT_EMBRACE_HP:render("Verdant Embrace HP")
                Menu.ZEPHYR_HP:render("Zephyr HP")
                Menu.EMERALD_BLOSSOM_HP:render("Emerald Blossom HP")
            end
        end)
    end)
end

-- Helper methods
function Menu.is_enabled() return Menu.ENABLED:get_state() end

function Menu.is_rotation_enabled() return Menu.ROTATION_ENABLED:get_state() end

return Menu
