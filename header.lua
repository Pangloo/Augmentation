local plugin = {}

plugin.name = "Augment Reality"
plugin.version = "0.9.0"
plugin.author = "Panglo"
plugin.load = true

-- Check if local player exists
local local_player = core.object_manager.get_local_player()
if not local_player then
    plugin.load = false
    return plugin
end

---@type enums
local enums = require("common/enums")
local player_class = local_player:get_class()

-- Validate player is an Evoker
local is_valid_class = player_class == enums.class_id.EVOKER

if not is_valid_class then
    plugin.load = false
    return plugin
end

-- Validate specialization is Augmentation (spec_id = 3)
local player_spec_id = core.spell_book.get_specialization_id()
local is_valid_spec_id = player_spec_id == 3

if not is_valid_spec_id then
    plugin.load = false
    return plugin
end

return plugin
