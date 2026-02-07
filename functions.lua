---@type izi_api
local izi = require("common/izi_sdk")
---@type enums
local enums = require("common/enums")
local lists = require("lists")
local spells = require("spells")

local Functions = {}

-- Key Codes
local VK_SHIFT, VK_CONTROL, VK_MENU = 0x10, 0x11, 0x12
local VK_LSHIFT, VK_LCONTROL, VK_LMENU = 0xA0, 0xA2, 0xA4

function Functions.is_shift_pressed()
    return core.input.is_key_pressed(VK_SHIFT) or core.input.is_key_pressed(VK_LSHIFT)
end

function Functions.is_ctrl_pressed()
    return core.input.is_key_pressed(VK_CONTROL) or core.input.is_key_pressed(VK_LCONTROL)
end

function Functions.is_alt_pressed()
    return core.input.is_key_pressed(VK_MENU) or core.input.is_key_pressed(VK_LMENU)
end

function Functions.validate_ally(unit, range)
    if not unit or not unit:is_valid() or unit:is_dead() then return false end
    if range and unit:distance() > range then return false end
    return true
end

function Functions.count_allies_with_buff(buff_id, range)
    local count = 0
    local allies = izi.party(range or 40)
    for _, ally in ipairs(allies) do
        if Functions.validate_ally(ally, range) and ally:has_buff(buff_id) then
            count = count + 1
        end
    end
    return count
end

function Functions.count_prescience_buffed(range)
    range = range or 40
    local buff_id = lists.BUFFS.PRESCIENCE_BUFF or lists.BUFFS.PRESCIENCE
    return Functions.count_allies_with_buff(buff_id, range)
end

function Functions.get_ally_without_prescience(range)
    range = range or 40
    local best, priority = nil, -1
    local allies = izi.party(range)
    local me = izi.me()

    for _, ally in ipairs(allies) do
        if Functions.validate_ally(ally, range) then
            local buff_id = lists.BUFFS.PRESCIENCE_BUFF or lists.BUFFS.PRESCIENCE
            local has_prescience = ally:has_buff(buff_id)
            local prescience_remains = has_prescience and ally:buff_remains(buff_id) or 0

            -- Target if no prescience or if it's about to expire (<5 seconds)
            if not has_prescience or prescience_remains < 5 then
                local role = ally:get_group_role()
                local p = 0
                -- Role mapping: 0 = TANK, 1 = HEALER, 2 = DAMAGER
                -- Prioritize other DPS (role 2) before self
                if role == 2 and ally:get_guid() ~= me:get_guid() then
                    p = 4 -- Other DPS priority (highest)
                elseif ally:get_guid() == me:get_guid() then
                    p = 3 -- Self priority (after other DPS)
                elseif role == 1 then
                    p = 2 -- Healer
                elseif role == 0 then
                    p = 1 -- Tank
                end

                if p > priority then
                    best = ally
                    priority = p
                end
            end
        end
    end
    return best
end

function Functions.count_blistering_scales(range)
    range = range or 100
    return Functions.count_allies_with_buff(lists.BUFFS.BLISTERING_SCALES, range)
end

function Functions.get_tank_without_blistering(range)
    range = range or 40
    local allies = izi.party(range)
    for _, ally in ipairs(allies) do
        if Functions.validate_ally(ally, range) and ally:is_tank() and not ally:has_buff(lists.BUFFS.BLISTERING_SCALES) then
            return ally
        end
    end
    return nil
end

function Functions.count_source_of_magic(range)
    range = range or 100
    if not spells.SOURCE_OF_MAGIC:is_learned() then return 0 end
    local buff_id = lists.BUFFS.SOURCE_OF_MAGIC
    return Functions.count_allies_with_buff(buff_id, range)
end

function Functions.get_healer_without_som(range)
    range = range or 40
    if not spells.SOURCE_OF_MAGIC:is_learned() then return nil end
    local buff_id = lists.BUFFS.SOURCE_OF_MAGIC
    local allies = izi.party(range)
    for _, ally in ipairs(allies) do
        if Functions.validate_ally(ally, range) and ally:get_group_role() == 1 and not ally:has_buff(buff_id) then
            return ally
        end
    end
    return nil
end

function Functions.has_ebon_might()
    local me = izi.me()
    if not me then return false, 0 end
    local buff_id = lists.BUFFS.EBON_MIGHT_BUFF
    local has_buff = me:has_buff(buff_id)
    local remains = has_buff and me:buff_remains(buff_id) or 0
    return has_buff, remains
end

function Functions.should_cast_spender()
    local me = izi.me()
    if not me then return false end

    -- Check for Ebon Might
    local has_em = me:has_buff(lists.BUFFS.EBON_MIGHT_BUFF) or me:has_buff(lists.BUFFS.EBON_MIGHT)
    if has_em then return true end

    -- Check for Essence Burst
    if me:has_buff(lists.BUFFS.ESSENCE_BURST) then return true end

    -- Check for Essence Cap (Prevent overcapping)
    -- Essence is power type 5 (Enum.PowerType.Essence)
    local essence = core.object_manager.get_local_player():get_power(19)
    local max_essence = core.object_manager.get_local_player():get_max_power(19)

    -- Cast if we are close to capping (e.g. within 1 of max)
    if essence >= (max_essence - 1) then return true end

    return false
end

function Functions.should_cast_empowered(spell_cd)
    local me = izi.me()
    if not me then return false end

    -- Check for Ebon Might
    local has_em = me:has_buff(lists.BUFFS.EBON_MIGHT_BUFF) or me:has_buff(lists.BUFFS.EBON_MIGHT)
    if has_em then return true end

    return false
end

function Functions.can_cast_moving()
    local me = izi.me()
    if not me then return false end
    return not me:is_moving() or me:has_buff(lists.BUFFS.HOVER)
end

function Functions.get_biggest_cluster(cluster_range)
    cluster_range = cluster_range or 10
    local max_count = 0
    local best_enemy = nil

    local enemies = izi.enemies(25)
    for _, enemy in ipairs(enemies) do
        if enemy and enemy:is_valid() and not enemy:is_dead() then
            -- Count enemies around this enemy
            local count = 0
            local enemy_pos = enemy:get_position()
            if enemy_pos then
                for _, other_enemy in ipairs(enemies) do
                    if other_enemy and other_enemy:is_valid() and not other_enemy:is_dead() then
                        local other_pos = other_enemy:get_position()
                        if other_pos then
                            local dx = enemy_pos.x - other_pos.x
                            local dy = enemy_pos.y - other_pos.y
                            local dz = enemy_pos.z - other_pos.z
                            local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
                            if dist <= cluster_range then
                                count = count + 1
                            end
                        end
                    end
                end
            end

            if count > max_count then
                max_count = count
                best_enemy = enemy
            end
        end
    end
    return best_enemy
end

function Functions.autotarget()
    local me = izi.me()
    if not me or not me:affecting_combat() then return false end

    local target = me:get_target()
    if target and target:is_valid() and not target:is_dead() then return false end -- Already has target

    local best, min_dist = nil, math.huge
    local enemies = izi.enemies(25)
    for _, enemy in ipairs(enemies) do
        if enemy and enemy:is_valid() and not enemy:is_dead() and spells.AZURE_STRIKE:is_castable_to_unit(enemy) then
            local d = enemy:distance()
            if d < min_dist then
                best = enemy
                min_dist = d
            end
        end
    end
    if best then
        core.input.set_target(best)
        return true
    end
    return false
end

function Functions.get_lowest_hp_friend(range)
    local allies = izi.party(range or 40)
    local lowest, lowest_hp = nil, 100
    for _, ally in ipairs(allies) do
        if Functions.validate_ally(ally, range) then
            local hp = ally:get_health_percentage()
            if hp < lowest_hp then
                lowest = ally
                lowest_hp = hp
            end
        end
    end
    return lowest
end

function Functions.get_valid_enemy(spell, filter, range_chk, forced_range, valid_units)
    -- Simplified version for standalone
    local enemies = izi.enemies(forced_range or 40)
    for _, enemy in ipairs(enemies) do
        if enemy and enemy:is_valid() and not enemy:is_dead() then
            local is_valid_unit = valid_units and valid_units[enemy:get_npc_id()]

            if is_valid_unit or spell:is_castable_to_unit(enemy) then
                return enemy
            end
        end
    end
    return nil
end

function Functions.can_dispel(unit, debuff_type, range)
    -- Simplified check against DISPEL_LOGIC list
    -- In a full implementation we would check debuff types (Magic, Poison, etc.)
    -- For Evoker: Naturalize (Magic, Poison), Expunge (Poison), Cauterizing Flame (Bleed, Poison, Curse, Disease)
    -- Here we just return true if unit needs dispel based on DISPEL_LOGIC, assuming spell callback checks availability

    -- Check specific logic list
    for debuff_id, logic in pairs(lists.DISPEL_LOGIC) do
        if unit:has_debuff(debuff_id) then
            local stacks = unit:get_debuff_stacks(debuff_id) or 0
            local logic_stacks = logic.stacks or 0
            if stacks >= logic_stacks then
                return true
            end
        end
    end
    return false
end

function Functions.get_interrupt_target(range)
    local enemies = izi.enemies(range or 25)
    for _, enemy in ipairs(enemies) do
        if enemy and enemy:is_valid() and not enemy:is_dead() and (enemy:is_casting() or enemy:is_channeling()) then
            if enemy:is_active_spell_interruptable() then
                local spell_id = enemy:get_active_cast_or_channel_id()
                if lists.INTERRUPT_WHITELIST[spell_id] then
                    return enemy
                end
            end
        end
    end
    return nil
end

function Functions.is_in_dungeon()
    local instance_type = core.get_instance_type()
    return instance_type == "party" or instance_type == "raid" or instance_type == "scenario"
end

return Functions
