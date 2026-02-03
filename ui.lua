---@type color
local color = require("common/color")
---@type vec2
local vec2 = require("common/geometry/vector_2")
local enums = require("common/enums")
local menu = require("menu")

local UI = {}

local window_size = vec2.new(210, 80) -- Fixed size to fit buttons
local button_size = vec2.new(60, 60)
local spacing = 5
local padding = 10

-- Create window
local win = nil

-- Colors
local color_enabled = color.new(201, 156, 86, 200)   -- Custom Gold
local color_disabled = color.new(100, 100, 100, 200) -- Grey
local color_text = color.new(255, 255, 255, 255)     -- White
local color_bg = color.new(0, 0, 0, 200)             -- Background
local color_border = color.new(255, 255, 255, 50)    -- Border (Visible)

function UI.draw()
    if not win then
        win = core.menu.window("Augment Hotbar v2")
        win:set_initial_size(window_size)
        win:set_initial_position(vec2.new(500, 500))
    end

    -- Window render
    -- flags: 0 (default resizing), true (show cross), bg_color, border_color, cross_style (0)
    -- We use enums for flags generally, but 0 is safe default if we don't need specific flags
    -- resizing_flag, is_adding_cross, bg_color, border_color, cross_style_flag, flag_1, flag_2, flag_3, callback

    if win and menu.SHOW_HOTBAR then
        win:set_visibility(menu.SHOW_HOTBAR:get_state())
    end


    local tooltip_to_draw = nil -- Declared outside callback

    win:set_next_window_padding(vec2.new(0, 0))
    win:set_next_window_items_spacing(vec2.new(0, 0))

    win:begin(enums.window_enums.window_resizing_flags.NO_RESIZE, false, color_bg, color_border,
        enums.window_enums.window_cross_visuals.BLUE_THEME, function()
            -- Button layout logic
            local current_x = padding
            local current_y = padding
            local p_min = vec2.new(current_x, current_y)
            local p_max = vec2.new(current_x + button_size.x, current_y + button_size.y)

            -- Helper to draw button
            local function draw_btn(text, menu_item, p_min, p_max, tooltip_text)
                local is_on = menu_item:get_state()
                local bg_color = is_on and color_enabled or color_disabled

                -- Draw background
                win:render_rect_filled(p_min, p_max, bg_color, 5)

                -- Check click
                if win:is_rect_clicked(p_min, p_max) then
                    menu_item:set(not is_on)
                end

                -- Check hover for tooltip
                if win:is_mouse_hovering_rect(p_min, p_max) and tooltip_text then
                    tooltip_to_draw = tooltip_text -- Update outer local
                end

                -- Draw text centered
                local text_size = win:get_text_size(text)
                local txt_offset = vec2.new(
                    p_min.x + (button_size.x - text_size.x) / 2,
                    p_min.y + (button_size.y - text_size.y) / 2
                )
                win:render_text(0, txt_offset, color_text, text)
            end

            -- Draw Button 1
            draw_btn("Toggle", menu.ROTATION_ENABLED, p_min, p_max, "Enable and disable rotation")

            -- Move X
            current_x = current_x + button_size.x + spacing
            p_min = vec2.new(current_x, current_y)
            p_max = vec2.new(current_x + button_size.x, current_y + button_size.y)

            -- Draw Button 2
            draw_btn("OoC", menu.OOC_PRESCIENCE, p_min, p_max, "Toggle Prescience Out of Combat")

            -- Move X
            current_x = current_x + button_size.x + spacing
            p_min = vec2.new(current_x, current_y)
            p_max = vec2.new(current_x + button_size.x, current_y + button_size.y)


            -- Draw Button 3
            draw_btn("CDs", menu.USE_COOLDOWNS, p_min, p_max, "Toggle Use Cooldowns")

            -- Render Tooltip using Popup API
            if tooltip_to_draw then
                -- Anchor to top of main window (Relative Position)
                local t_text = tooltip_to_draw
                local t_width = string.len(t_text) * 7 + 10

                -- Position relative to the window (X=10 to match padding, Y=-35 to be above)
                local popup_pos = vec2.new(10, -35)

                -- begin_popup(bg_color, border_color, size, pos, is_close_on_release, is_triggering_from_button, callback)
                win:begin_popup(color_bg, color_border, vec2.new(t_width, 24), popup_pos, false, false, function()
                    -- Render text inside popup
                    win:render_text(0, vec2.new(5, 5), color_text, t_text)
                end)
            end
        end)
end

return UI
