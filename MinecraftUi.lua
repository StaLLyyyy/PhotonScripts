local GUI_WIDTH = 180
local HEADER_H = 26
local MOD_H = 24
local SET_H = 22
local PALETTE_H = 100
local HUE_H = 10
local ALPHA_H = 10

local gui_state = {
    dragging_panel = nil,
    drag_offset = vector2(0, 0),
    dragging_slider = nil,
    dragging_color_sv = nil,
    dragging_color_hue = nil,
    dragging_color_alpha = nil,
    binding_element = nil,
    binding_wait_release = false
}

local colors = {
    bg_dark = color(0.1, 0.1, 0.1, 0.8),
    text = color(1, 1, 1, 1),
    active_text = color(1, 1, 1, 1),
    slider_bg = color(0.2, 0.2, 0.2, 0.8),
    white = color(1, 1, 1, 1),
    shadow = color(0, 0, 0, 0.5),
    outline = color(0, 0, 0, 1),
    tooltip_bg = color(0.1, 0.1, 0.1, 0.9),
    cat_combat = color(0.8, 0.2, 0.2, 1),
    cat_render = color(0.9, 0.5, 0.1, 1),
    cat_player = color(0.2, 0.7, 0.2, 1),
    cat_move = color(0.6, 0.2, 0.8, 1),
    checker_1 = color(0.4, 0.4, 0.4, 1),
    checker_2 = color(0.2, 0.2, 0.2, 1),
    mode_text = color(0.7, 0.7, 0.7, 1)
}

if not panels then panels = {} end

local key_names = {
    [1] = "M1", [2] = "M2", [3] = "M3", [4] = "M3", [5] = "M4", [6] = "M5",
    [8] = "Back", [9] = "Tab", [13] = "Enter", [16] = "Shift", [17] = "Ctrl", [18] = "Alt", [19] = "Pause",
    [20] = "Caps", [27] = "Esc", [32] = "Space", [33] = "PgUp", [34] = "PgDn", [35] = "End",
    [36] = "Home", [37] = "Left", [38] = "Up", [39] = "Right", [40] = "Down", [45] = "Ins", [46] = "Del",
    [91] = "LWin", [92] = "RWin", [93] = "Apps",
    [96] = "Num0", [97] = "Num1", [98] = "Num2", [99] = "Num3", [100] = "Num4",
    [101] = "Num5", [102] = "Num6", [103] = "Num7", [104] = "Num8", [105] = "Num9",
    [106] = "Num*", [107] = "Num+", [109] = "Num-", [110] = "Num.", [111] = "Num/",
    [144] = "NumLk", [145] = "ScrLk",
    [186] = ";", [187] = "=", [188] = ",", [189] = "-", [190] = ".", [191] = "/", [192] = "`",
    [219] = "[", [220] = "\\", [221] = "]", [222] = "'"
}

local function get_key_name(k)
    if not k or k == 0 then return "None" end
    if key_names[k] then return key_names[k] end
    if k >= 65 and k <= 90 then return string.char(k) end
    if k >= 48 and k <= 57 then return string.char(k) end
    if k >= 112 and k <= 123 then return "F" .. (k - 111) end
    return "Key " .. k
end

local function hsv_to_rgb(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    return r, g, b
end

local function is_mouse_over(mx, my, x, y, w, h)
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

local function draw_checkerboard(x, y, w, h, size)
    for i = 0, w, size do
        for j = 0, h, size do
            local c = ((i / size) + (j / size)) % 2 == 0 and colors.checker_1 or colors.checker_2
            local rw = math.min(size, w - i)
            local rh = math.min(size, h - j)
            render.add_rect_filled(vector2(x + i, y + j), vector2(x + i + rw, y + j + rh), c, 0)
        end
    end
end

local function draw_color_picker(setting, panel_x, y_offset, panel_w, m, lmb_click)
    local p_x = panel_x + 6
    local p_w = panel_w - 12
    local current_y = y_offset + 4
    
    if lmb_click and is_mouse_over(m.x, m.y, p_x, current_y, p_w, PALETTE_H) then
        gui_state.dragging_color_sv = setting
    end

    if gui_state.dragging_color_sv == setting then
        local s = (m.x - p_x) / p_w
        local v = 1 - ((m.y - current_y) / PALETTE_H)
        if s < 0 then s = 0 end if s > 1 then s = 1 end
        if v < 0 then v = 0 end if v > 1 then v = 1 end
        setting.s = s
        setting.v = v
    end
    
    local step_sv = 2 
    for i = 0, p_w, step_sv do
        for j = 0, PALETTE_H, step_sv do
            local cur_s = i / p_w
            local cur_v = 1 - (j / PALETTE_H)
            local pr, pg, pb = hsv_to_rgb(setting.h, cur_s, cur_v)
            local rw = math.min(step_sv, p_w - i)
            local rh = math.min(step_sv, PALETTE_H - j)
            render.add_rect_filled(vector2(p_x + i, current_y + j), vector2(p_x + i + rw, current_y + j + rh), color(pr, pg, pb, 1), 0)
        end
    end
    
    local ind_x = p_x + (setting.s * p_w)
    local ind_y = current_y + ((1 - setting.v) * PALETTE_H)
    render.add_circle(vector2(ind_x, ind_y), 3, colors.white)
    
    current_y = current_y + PALETTE_H + 6
    
    if lmb_click and is_mouse_over(m.x, m.y, p_x, current_y, p_w, HUE_H) then
        gui_state.dragging_color_hue = setting
    end

    if gui_state.dragging_color_hue == setting then
        local h = (m.x - p_x) / p_w
        if h < 0 then h = 0 end if h > 1 then h = 1 end
        setting.h = h
    end
    
    local step_hue = 1
    for i = 0, p_w, step_hue do
        local h_val = i / p_w
        local hr, hg, hb = hsv_to_rgb(h_val, 1, 1)
        local rw = math.min(step_hue, p_w - i)
        render.add_rect_filled(vector2(p_x + i, current_y), vector2(p_x + i + rw, current_y + HUE_H), color(hr, hg, hb, 1), 0)
    end
    
    local h_ind_x = p_x + (setting.h * p_w)
    render.add_rect(vector2(h_ind_x - 1, current_y), vector2(h_ind_x + 1, current_y + HUE_H), colors.white, 0, 1)

    current_y = current_y + HUE_H + 6

    if lmb_click and is_mouse_over(m.x, m.y, p_x, current_y, p_w, ALPHA_H) then
        gui_state.dragging_color_alpha = setting
    end

    if gui_state.dragging_color_alpha == setting then
        local a = (m.x - p_x) / p_w
        if a < 0 then a = 0 end if a > 1 then a = 1 end
        setting.a = a
    end

    draw_checkerboard(p_x, current_y, p_w, ALPHA_H, 4)
    
    local r, g, b = hsv_to_rgb(setting.h, setting.s, setting.v)
    for i = 0, p_w, 2 do
        local a_val = i / p_w
        local rw = math.min(2, p_w - i)
        render.add_rect_filled(vector2(p_x + i, current_y), vector2(p_x + i + rw, current_y + ALPHA_H), color(r, g, b, a_val), 0)
    end

    local a_ind_x = p_x + ((setting.a or 1) * p_w)
    render.add_rect(vector2(a_ind_x - 1, current_y), vector2(a_ind_x + 1, current_y + ALPHA_H), colors.white, 0, 1)
end

local function draw_arrow(x, y, size, color, progress)
    local angle = math.rad(progress * 90)
    local cx, cy = x, y
    
    local function rotate(px, py)
        return px * math.cos(angle) - py * math.sin(angle),
               px * math.sin(angle) + py * math.cos(angle)
    end
    
    local p1x, p1y = rotate(-3, -4)
    local p2x, p2y = rotate(2, 0)
    local p3x, p3y = rotate(-3, 4)
    
    render.add_polyline({
        vector2(cx + p1x, cy + p1y),
        vector2(cx + p2x, cy + p2y),
        vector2(cx + p3x, cy + p3y)
    }, color, 1.5)
end

local last_lmb = false
local last_rmb = false

local function draw_gui()
    if not menu_active() then return end
    
    local m = input.get_mouse_position()
    local lmb = input.key_down(1)
    local rmb = input.key_down(2)
    local lmb_click = lmb and not last_lmb
    local rmb_click = rmb and not last_rmb
    local current_tooltip = nil
    local consumed = false
    
    if gui_state.binding_element then
        if gui_state.binding_wait_release then
            if not lmb then
                gui_state.binding_wait_release = false
            end
        else
            for i = 1, 255 do
                if input.key_down(i) then
                    if i == 27 or i == 46 then
                        gui_state.binding_element.value = 0
                    else
                        gui_state.binding_element.value = i
                    end
                    gui_state.binding_element = nil
                    gui_state.binding_wait_release = false
                    break
                end
            end
        end
    end

    if not lmb then
        gui_state.dragging_panel = nil
        gui_state.dragging_slider = nil
        gui_state.dragging_color_sv = nil
        gui_state.dragging_color_hue = nil
        gui_state.dragging_color_alpha = nil
    end
    
    if gui_state.dragging_panel then
        gui_state.dragging_panel.x = m.x - gui_state.drag_offset.x
        gui_state.dragging_panel.y = m.y - gui_state.drag_offset.y
    end
    
    for _, panel in ipairs(panels) do
        if not consumed and lmb_click and is_mouse_over(m.x, m.y, panel.x, panel.y, panel.w, HEADER_H) then
            gui_state.dragging_panel = panel
            gui_state.drag_offset = vector2(m.x - panel.x, m.y - panel.y)
            consumed = true
        end
        
        if not consumed and rmb_click and is_mouse_over(m.x, m.y, panel.x, panel.y, panel.w, HEADER_H) then
            panel.expanded = not panel.expanded
            consumed = true
        end

        render.add_rect_filled(vector2(panel.x, panel.y), vector2(panel.x + panel.w, panel.y + HEADER_H), panel.color, 0)
        render.add_text(vector2(panel.x + 6, panel.y + 6), panel.name, colors.text, 16, true)
        
        if not panel.anim then panel.anim = 1 end
        local target = panel.expanded and 1 or 0
        panel.anim = panel.anim + (target - panel.anim) * 0.2
        draw_arrow(panel.x + panel.w - 12, panel.y + 13, 10, colors.text, panel.anim)
        
        if panel.expanded then
            local y_offset = panel.y + HEADER_H
            
            for _, mod in ipairs(panel.modules) do
                if not consumed and is_mouse_over(m.x, m.y, panel.x, y_offset, panel.w, MOD_H) then
                    if lmb_click then 
                        mod.value = not mod.value 
                        consumed = true
                    end
                    if mod.tooltip then current_tooltip = mod.tooltip end
                end
                
                if not consumed and rmb_click and is_mouse_over(m.x, m.y, panel.x, y_offset, panel.w, MOD_H) then
                    if mod.settings then
                        mod.settings_open = not mod.settings_open
                        consumed = true
                    end
                end

                render.add_rect_filled(vector2(panel.x, y_offset), vector2(panel.x + panel.w, y_offset + MOD_H), colors.bg_dark, 0)
                
                if mod.value then
                    render.add_rect_filled(vector2(panel.x, y_offset), vector2(panel.x + panel.w, y_offset + MOD_H), color(panel.color.r, panel.color.g, panel.color.b, 0.2), 0)
                end

                render.add_text(vector2(panel.x + 6, y_offset + 5), mod.name, mod.value and colors.active_text or colors.text, 14, true)
                
                if mod.settings then
                    if not mod.anim then mod.anim = 0 end
                    local target = mod.settings_open and 1 or 0
                    mod.anim = mod.anim + (target - mod.anim) * 0.2
                    
                    draw_arrow(panel.x + panel.w - 10, y_offset + 12, 10, colors.text, mod.anim)
                end
                
                y_offset = y_offset + MOD_H
                
                if mod.settings_open and mod.settings then
                    for _, setting in ipairs(mod.settings) do
                        if setting.type == "slider" then
                            if not consumed and is_mouse_over(m.x, m.y, panel.x, y_offset, panel.w, SET_H) then
                                if lmb_click then 
                                    gui_state.dragging_slider = setting 
                                    consumed = true
                                end
                                if setting.tooltip then current_tooltip = setting.tooltip end
                            end
                            
                            render.add_rect_filled(vector2(panel.x, y_offset), vector2(panel.x + panel.w, y_offset + SET_H), colors.bg_dark, 0)
                            
                            if gui_state.dragging_slider == setting then
                                local val = (m.x - panel.x) / panel.w
                                if val < 0 then val = 0 end
                                if val > 1 then val = 1 end
                                setting.value = setting.min + (val * (setting.max - setting.min))
                            end
                            
                            local slider_w = ((setting.value - setting.min) / (setting.max - setting.min)) * panel.w
                            local slider_col = color(panel.color.r, panel.color.g, panel.color.b, 0.8)
                            render.add_rect_filled(vector2(panel.x, y_offset), vector2(panel.x + slider_w, y_offset + SET_H), slider_col, 0)
                            
                            local val_str = string.format("%.1f", setting.value)
                            render.add_text(vector2(panel.x + 8, y_offset + 4), setting.name .. " " .. val_str, colors.text, 13, true)
                            y_offset = y_offset + SET_H
                            
                        elseif setting.type == "color" then
                            if not consumed and is_mouse_over(m.x, m.y, panel.x, y_offset, panel.w, SET_H) then
                                if lmb_click then 
                                    setting.open = not setting.open 
                                    consumed = true
                                end
                                if setting.tooltip then current_tooltip = setting.tooltip end
                            end

                            render.add_rect_filled(vector2(panel.x, y_offset), vector2(panel.x + panel.w, y_offset + SET_H), colors.bg_dark, 0)
                            render.add_text(vector2(panel.x + 8, y_offset + 4), setting.name, colors.text, 13, true)
                            
                            local r, g, b = hsv_to_rgb(setting.h, setting.s, setting.v)
                            local prev_x = panel.x + panel.w - 22
                            local prev_y = y_offset + 4
                            
                            draw_checkerboard(prev_x, prev_y, 16, 12, 4)
                            render.add_rect_filled(vector2(prev_x, prev_y), vector2(prev_x + 16, prev_y + 12), color(r, g, b, setting.a or 1), 0)
                            render.add_rect(vector2(prev_x, prev_y), vector2(prev_x + 16, prev_y + 12), colors.outline, 0, 1)
                            y_offset = y_offset + SET_H
                            
                            if setting.open then
                                local picker_height = 4 + PALETTE_H + 6 + HUE_H + 6 + ALPHA_H + 6
                                render.add_rect_filled(vector2(panel.x, y_offset), vector2(panel.x + panel.w, y_offset + picker_height), color(0.1, 0.1, 0.1, 0.9), 0)
                                if not consumed and is_mouse_over(m.x, m.y, panel.x, y_offset, panel.w, picker_height) and lmb_click then
                                     consumed = true
                                end
                                draw_color_picker(setting, panel.x, y_offset, panel.w, m, lmb_click)
                                y_offset = y_offset + picker_height
                            end

                        elseif setting.type == "bool" then
                             if not consumed and is_mouse_over(m.x, m.y, panel.x, y_offset, panel.w, SET_H) then
                                if lmb_click then 
                                    setting.value = not setting.value 
                                    consumed = true
                                end
                                if setting.tooltip then current_tooltip = setting.tooltip end
                             end
                             render.add_rect_filled(vector2(panel.x, y_offset), vector2(panel.x + panel.w, y_offset + SET_H), colors.bg_dark, 0)
                             local s_col = setting.value and panel.color or colors.text
                             render.add_text(vector2(panel.x + 8, y_offset + 4), setting.name, s_col, 13, true)
                             y_offset = y_offset + SET_H

                        elseif setting.type == "label" then
                            render.add_rect_filled(vector2(panel.x, y_offset), vector2(panel.x + panel.w, y_offset + SET_H), colors.bg_dark, 0)
                            render.add_text(vector2(panel.x + 8, y_offset + 4), setting.name .. ": " .. setting.value, color(0.7, 0.7, 0.7, 1), 13, true)
                            y_offset = y_offset + SET_H

                        elseif setting.type == "keybind" then
                            if not consumed and is_mouse_over(m.x, m.y, panel.x, y_offset, panel.w, SET_H) then
                                if lmb_click then 
                                    gui_state.binding_element = setting 
                                    gui_state.binding_wait_release = true
                                    consumed = true
                                end
                                if rmb_click then
                                    if not setting.mode then setting.mode = "Toggle" end
                                    if setting.mode == "Toggle" then setting.mode = "Hold"
                                    elseif setting.mode == "Hold" then setting.mode = "Always"
                                    else setting.mode = "Toggle" end
                                    consumed = true
                                end
                                if setting.tooltip then current_tooltip = setting.tooltip end
                            end
                            render.add_rect_filled(vector2(panel.x, y_offset), vector2(panel.x + panel.w, y_offset + SET_H), colors.bg_dark, 0)
                            
                            render.add_text(vector2(panel.x + 8, y_offset + 4), setting.name, colors.text, 13, true)
                            
                            local bind_str = (gui_state.binding_element == setting) and "[...]" or ("[" .. get_key_name(setting.value) .. "]")
                            local mode_str = setting.mode or "Toggle"
                            local full_str = bind_str .. " " .. mode_str
                            
                            local t_size = render.get_text_size(full_str)
                            local x_pos = panel.x + panel.w - t_size.x - 8
                            local bind_col = (gui_state.binding_element == setting) and colors.active_text or colors.text
                            
                            render.add_text(vector2(x_pos, y_offset + 4), full_str, bind_col, 13, true)
                            y_offset = y_offset + SET_H
                        end
                    end
                end
            end
        end
    end
    
    if current_tooltip then
        local t_size = render.get_text_size(current_tooltip)
        local t_x, t_y = m.x + 12, m.y + 12
        render.add_rect_filled(vector2(t_x, t_y), vector2(t_x + t_size.x + 8, t_y + t_size.y + 4), colors.tooltip_bg, 0)
        render.add_rect(vector2(t_x, t_y), vector2(t_x + t_size.x + 8, t_y + t_size.y + 4), colors.outline, 0, 1)
        render.add_text(vector2(t_x + 4, t_y + 2), current_tooltip, colors.text, 13, true)
    end
    
    last_lmb = lmb
    last_rmb = rmb
end

hook.add("render", "cheat_render", function()
    draw_gui()
end)
