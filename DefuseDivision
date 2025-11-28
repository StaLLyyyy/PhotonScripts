local pairs = pairs
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format
local get_tickcount = get_tickcount
local world_to_screen = world_to_screen
local in_screen = in_screen
local color = color
local vector2 = vector2
local vector3 = vector3
local math_floor = math.floor
local math_max = math.max
local math_min = math.min

local menu = gui.create("Defuse Division", false)
menu:set_size(300, 550)

local opt_enable = menu:add_checkbox("Dropped Weapons ESP", false)
local opt_color = menu:add_color("ESP Color", color(1, 1, 1, 1))
local opt_size = menu:add_slider("Text Size", 8, 30, 14)

local opt_grenades = menu:add_checkbox("Grenade ESP", false)

local opt_smoke = menu:add_checkbox("Smoke ESP", false)
local opt_smoke_col = menu:add_color("Smoke Stroke Color", color(0.4, 0.5, 0.9, 1))
local opt_fill_col = menu:add_color("Smoke Fill Color", color(0.4, 0.5, 0.9, 1))
local opt_fill_alpha = menu:add_slider("Fill Opacity", 0, 100, 35)

local opt_c4timer = menu:add_checkbox("C4 Timer", false)

local opt_weapon_esp = menu:add_checkbox("Player Weapon ESP", false)
local opt_teamcheck = menu:add_checkbox("Team Check", false)

local workspace = game:get_service("Workspace")
local players_service = game:get_service("Players")
local rep_storage = game:get_service("ReplicatedStorage")

local folder = nil
local smoke_folder = nil
local expl_folder = nil

local col_c4 = color(1, 0, 0, 1)
local col_white = color(1, 1, 1, 1)
local col_molotov = color(1, 0.3, 0.3, 1)
local col_flash = color(1, 1, 0.8, 1)
local col_he = color(0.3, 1, 0.3, 1)
local col_smoke_g = color(0.8, 0.8, 0.8, 1)
local col_bg = color(0.1, 0.1, 0.1, 0.6)
local col_border = color(0, 0, 0, 0.8)

local c4_obj = nil
local c4_plant_time = nil
local smoke_timers = {}
local grenade_spawn_times = {}
local grenade_stop_times = {}

local ESP_BOTTOM_ID = 1
if ESP_BOTTOM then
    ESP_BOTTOM_ID = ESP_BOTTOM
end

local team_cache = {}
local my_team_cache = nil
local last_cache_update = 0
local CACHE_DURATION = 1000

local function update_team_cache()
    local current_time = get_tickcount()
    if current_time - last_cache_update < CACHE_DURATION then return end
    
    last_cache_update = current_time
    
    if not rep_storage or not rep_storage:isvalid() then
        rep_storage = game:get_service("ReplicatedStorage")
        return
    end

    local teams = rep_storage:find_first_child("Teams")
    if not teams or not teams:isvalid() then return end

    local new_cache = {}

    local t_folder = teams:find_first_child("T")
    if t_folder and t_folder:isvalid() then
        for _, child in pairs(t_folder:get_children()) do
            if child and child:isvalid() then
                new_cache[child.name] = "T"
            end
        end
    end

    local ct_folder = teams:find_first_child("CT")
    if ct_folder and ct_folder:isvalid() then
        for _, child in pairs(ct_folder:get_children()) do
            if child and child:isvalid() then
                new_cache[child.name] = "CT"
            end
        end
    end
    
    team_cache = new_cache

    local lp = players_service.local_player
    if lp and lp:isvalid() then
        my_team_cache = team_cache[lp.name]
    else
        my_team_cache = nil
    end
end

local function get_hull(points)
    if #points < 3 then return points end
    
    table_sort(points, function(a, b)
        return a.x < b.x or (a.x == b.x and a.y < b.y)
    end)

    local function cross(o, a, b)
        return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)
    end

    local lower = {}
    for i = 1, #points do
        while #lower >= 2 and cross(lower[#lower-1], lower[#lower], points[i]) <= 0 do
            table.remove(lower)
        end
        table_insert(lower, points[i])
    end

    local upper = {}
    for i = #points, 1, -1 do
        while #upper >= 2 and cross(upper[#upper-1], upper[#upper], points[i]) <= 0 do
            table.remove(upper)
        end
        table_insert(upper, points[i])
    end

    for i = 2, #upper - 1 do
        table_insert(lower, upper[i])
    end
    
    table_insert(lower, lower[1])
    
    return lower
end

local function draw_timer_circle(wts, remaining, max_dur, name, color_main, dist)
    if not in_screen(wts) then return end
    
    local scale = 1
    if dist > 0 then scale = 35 / dist end
    if scale > 1.8 then scale = 1.8 end
    if scale < 0.8 then scale = 0.8 end
    
    local radius_outer = 26 * scale
    local radius_arc = 25 * scale 
    local thickness = 2.5 * scale
    local text_size = 14 * scale
    
    local fraction = remaining / max_dur
    if fraction < 0 then fraction = 0 end
    if fraction > 1 then fraction = 1 end
    
    local r, g, b = 1, 1, 0
    if fraction > 0.5 then
        r = (1 - fraction) * 2
        g = 1
        b = 0
    else
        r = 1
        g = fraction * 2
        b = 0
    end
    local arc_color = color(r, g, b, 1)
    
    render.add_circle_filled(wts, radius_outer, col_bg)
    render.add_circle(wts, radius_outer, col_border)
    
    render.add_arc(wts, radius_arc, -90, -90 + (360 * fraction), arc_color, thickness, 32)
    
    local time_str = string_format("%.1f", remaining)
    local t_size_base = render.get_text_size(time_str)
    local n_size_base = render.get_text_size(name)
    
    local base_font_size = 16 
    
    local t_scale = text_size / base_font_size
    local n_text_size = text_size * 0.7
    local n_scale = n_text_size / base_font_size
    
    local t_w = t_size_base.x * t_scale
    local t_h = t_size_base.y * t_scale
    local n_w = n_size_base.x * n_scale
    local n_h = n_size_base.y * n_scale
    
    if name == "SMOKE" then
        render.add_text(vector2(math_floor(wts.x - t_w/2), math_floor(wts.y - t_h/2)), time_str, col_white, text_size, true)
    else
        local spacing = -3 * scale
        local total_h = t_h + n_h + spacing
        local start_y = wts.y - (total_h / 2)
        
        render.add_text(vector2(math_floor(wts.x - t_w/2), math_floor(start_y)), time_str, col_white, text_size, true)
        render.add_text(vector2(math_floor(wts.x - n_w/2), math_floor(start_y + t_h + spacing)), name, color_main, n_text_size, true)
    end
end

local function safe_render()
    update_team_cache()

    local current_time = get_tickcount()
    local text_sz = opt_size:get_value()
    local cam = workspace.Camera
    local cam_pos = vector3(0,0,0)
    local cam_valid = false
    if cam and cam:isvalid() then
        cam_pos = cam.camera_position
        cam_valid = true
    end

    if opt_grenades:get_value() then
        local children = workspace:get_children()
        if children then
            for _, child in pairs(children) do
                if child and child:isvalid() then
                    local name = child.name
                    if name == "SmokeGrenade" or name == "Molotov" or name == "Incendiary" or name == "Flashbang" or name == "HEGrenade" then
                        local handle = child:find_first_child("Handle")
                        if handle and handle:isvalid() then
                            local identity = handle.identity
                            if not grenade_spawn_times[identity] then
                                grenade_spawn_times[identity] = current_time
                            end
                            
                            if (current_time - grenade_spawn_times[identity]) / 1000 <= 25 then
                                local should_draw_timer = false
                                local remaining = 0
                                local max_duration = 0
                                local display_name = name
                                local name_col = col_white
                                
                                if name == "Molotov" or name == "Incendiary" then
                                    display_name = (name == "Molotov") and "MOLOTOV" or "INCENDIARY"
                                    name_col = col_molotov
                                    
                                    local vel = handle.velocity
                                    local speed_sq = vel.x*vel.x + vel.y*vel.y + vel.z*vel.z
                                    
                                    if speed_sq < 0.1 then
                                        if not grenade_stop_times[identity] then
                                            grenade_stop_times[identity] = current_time
                                        end
                                        max_duration = 7
                                        local elapsed = (current_time - grenade_stop_times[identity]) / 1000
                                        remaining = max_duration - elapsed
                                        
                                        if remaining > 0 then
                                            should_draw_timer = true
                                        end
                                    else
                                        grenade_stop_times[identity] = nil
                                        should_draw_timer = false 
                                    end
                                else
                                    local duration = 0
                                    
                                    if name == "Flashbang" then
                                        display_name = "FLASH"
                                        name_col = col_flash
                                        duration = 1.5
                                    elseif name == "HEGrenade" then
                                        display_name = "HE"
                                        name_col = col_he
                                        duration = 2
                                    elseif name == "SmokeGrenade" then
                                        display_name = "SMOKE"
                                        name_col = col_smoke_g
                                    end

                                    if duration > 0 then
                                        max_duration = duration
                                        local elapsed = (current_time - grenade_spawn_times[identity]) / 1000
                                        remaining = max_duration - elapsed
                                        
                                        if remaining > 0 then
                                            should_draw_timer = true
                                        end
                                    end
                                end

                                if should_draw_timer then
                                    local wts = world_to_screen(handle.position)
                                    if in_screen(wts) then
                                        local dist = 100
                                        if cam_valid then
                                            dist = handle.position:subtract(cam_pos):length()
                                        end
                                        draw_timer_circle(wts, remaining, max_duration, display_name, name_col, dist)
                                    end
                                elseif name ~= "Molotov" and name ~= "Incendiary" then
                                    local wts = world_to_screen(handle.position)
                                    if in_screen(wts) then
                                        if name == "SmokeGrenade" then
                                            local t_size = render.get_text_size(display_name)
                                            local scale = text_sz / 14
                                            local t_pos = vector2(math_floor(wts.x - (t_size.x * scale / 2)), math_floor(wts.y - (t_size.y * scale / 2)))
                                            render.add_text(t_pos, display_name, name_col, text_sz, true)
                                        else
                                            local dist = 100
                                            if cam_valid then
                                                dist = handle.position:subtract(cam_pos):length()
                                            end
                                            draw_timer_circle(wts, 1, 1, display_name, name_col, dist)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if opt_enable:get_value() then
        if not folder or not folder:isvalid() then
            folder = workspace:find_first_child("DroppedWeapons")
        else
            local esp_col = opt_color:get_color()

            local children = folder:get_children()
            if children then
                for _, weapon in pairs(children) do
                    if weapon and weapon:isvalid() then
                        local handle = weapon:find_first_child("Handle")
                        if handle and handle:isvalid() then
                            local wts = world_to_screen(handle.position)
                            if wts and in_screen(wts) then
                                local final_col = esp_col
                                if weapon.name == "C4" then
                                    final_col = col_c4
                                end
                                
                                local t_size = render.get_text_size(weapon.name)
                                local scale = text_sz / 16
                                local t_pos = vector2(math_floor(wts.x - (t_size.x * scale / 2)), math_floor(wts.y - (t_size.y * scale / 2)))
                                
                                render.add_text(t_pos, weapon.name, final_col, text_sz, true)
                            end
                        end
                    end
                end
            end
        end
    end

    if opt_c4timer:get_value() then
        if not c4_obj or not c4_obj:isvalid() then
            c4_obj = workspace:find_first_child("C4")
            if c4_obj and c4_obj:isvalid() then
                c4_plant_time = get_tickcount()
            end
        else
            local handle = c4_obj:find_first_child("Handle")
            if handle and handle:isvalid() then
                local wts = world_to_screen(handle.position)
                if wts and in_screen(wts) then
                    local elapsed = (get_tickcount() - c4_plant_time) / 1000
                    local remaining = 40 - elapsed
                    
                    local r_col = 1
                    local g_col = 1
                    
                    if remaining > 20 then
                        r_col = 1 - ((remaining - 20) / 20)
                        g_col = 1
                    elseif remaining > 0 then
                        r_col = 1
                        g_col = remaining / 20
                    else
                        r_col = 1
                        g_col = 0
                    end
                    
                    local timer_col = color(r_col, g_col, 0, 1)
                    local text = ""
                    if remaining > 0 then
                        text = string_format("%.1fs", remaining)
                    else
                        text = "Boom!!!"
                    end
                    
                    local c4_sz_base = render.get_text_size("C4")
                    local timer_sz_base = render.get_text_size(text)
                    
                    local scale = text_sz / 14
                    local c4_w = c4_sz_base.x * scale
                    local timer_w = timer_sz_base.x * scale
                    
                    render.add_text(vector2(math_floor(wts.x - c4_w/2), math_floor(wts.y)), "C4", col_white, text_sz, true)
                    render.add_text(vector2(math_floor(wts.x - timer_w/2), math_floor(wts.y + (c4_sz_base.y * scale))), text, timer_col, text_sz, true)
                end
            end
        end
    end

    if opt_smoke:get_value() then
        if not smoke_folder or not smoke_folder:isvalid() then
            smoke_folder = workspace:find_first_child("SmokeDebugParts")
        else
            local smk_col = opt_smoke_col:get_color()
            
            local fill_base = opt_fill_col:get_color()
            local fill_alpha = opt_fill_alpha:get_value() / 100
            
            local fr, fg, fb = 1, 1, 1
            if fill_base.r then
                fr, fg, fb = fill_base.r, fill_base.g, fill_base.b
            elseif fill_base.unpack then
                local r, g, b = fill_base:unpack()
                if r then fr, fg, fb = r, g, b end
            end
            
            local sr, sg, sb, sa = 1, 1, 1, 1
            if smk_col.r then
                sr, sg, sb, sa = smk_col.r, smk_col.g, smk_col.b, smk_col.a
            elseif smk_col.unpack then
                local r, g, b, a = smk_col:unpack()
                if r then sr, sg, sb, sa = r, g, b, a end
            end
            
            local children = smoke_folder:get_children()
            if children then
                for _, model in pairs(children) do
                    if model and model:isvalid() then
                        local identity = model.identity
                        if not smoke_timers[identity] then
                            smoke_timers[identity] = current_time
                        end

                        local elapsed = (current_time - smoke_timers[identity]) / 1000
                        local smoke_duration = 18.5
                        local fade_duration = 2.0
                        
                        local alpha_mult = 1
                        if elapsed > smoke_duration then
                            alpha_mult = 1 - ((elapsed - smoke_duration) / fade_duration)
                        end
                        
                        if alpha_mult > 0 then
                            local points = {} 
                            local center_pos = vector3(0,0,0)
                            local point_count = 0
                            
                            local model_children = model:get_children()
                            if model_children then
                                for _, part in pairs(model_children) do
                                    if part and part:isvalid() and part.class_name == "Part" then
                                        local wts = world_to_screen(part.position)
                                        if wts and in_screen(wts) then
                                            table_insert(points, wts)
                                        end
                                        center_pos = center_pos:add(part.position)
                                        point_count = point_count + 1
                                    end
                                end
                            end

                            if #points > 2 then
                                local final_fill = color(fr, fg, fb, fill_alpha * alpha_mult)
                                local final_smk = color(sr, sg, sb, sa * alpha_mult)
                                
                                local hull = get_hull(points)
                                for i = 2, #hull - 1 do
                                    render.add_triangle_filled(hull[1], hull[i], hull[i+1], final_fill)
                                end
                                render.add_polyline(hull, final_smk, 2)
                            end
                            
                            if elapsed < smoke_duration and alpha_mult > 0 then
                                local remaining = smoke_duration - elapsed
                                local timer_world_pos = nil
                                
                                local handle = model:find_first_child("Handle")
                                if handle and handle:isvalid() then
                                    timer_world_pos = handle.position
                                else
                                    if model.class_name == "Part" then
                                        timer_world_pos = model.position
                                    end
                                end

                                if not timer_world_pos and point_count > 0 then
                                    timer_world_pos = vector3(center_pos.x / point_count, center_pos.y / point_count, center_pos.z / point_count)
                                end

                                if timer_world_pos then
                                    local wts_center = world_to_screen(timer_world_pos)
                                 
                                    if in_screen(wts_center) then
                                         local dist = 100
                                         if cam_valid then
                                             dist = timer_world_pos:subtract(cam_pos):length()
                                         end
                                         
                                         draw_timer_circle(wts_center, remaining, 18.5, "SMOKE", col_smoke_g, dist)
                                     end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

hook.add("render", "dd_main_esp", function()
    local success, err = pcall(safe_render)
    if not success then
    end
end)

local function global_team_check(plr)
    if not opt_teamcheck:get_value() then return false end
    if not plr or not plr:isvalid() then return false end

    local plr_team = team_cache[plr.name]
    
    if not my_team_cache then return false end
    
    if plr_team and plr_team == my_team_cache then
        return true
    end
    
    return false
end

hook.add("aimbot_ignore", "dd_aim_ignore", global_team_check)
hook.add("triggerbot_ignore", "dd_trig_ignore", global_team_check)
hook.add("silent_ignore", "dd_silent_ignore", global_team_check)
hook.add("esp_ignore", "dd_esp_ignore", global_team_check)

hook.add("esp_drawextra", "dd_weapon_esp", function(plr)
    if opt_weapon_esp:get_value() then
        if plr and plr:isvalid() then
             local gun_val = plr:find_first_child("Gun")
             if gun_val and gun_val:isvalid() then
                 local name = gun_val:get_value_string()
                 render.add_extra(name, ESP_BOTTOM_ID, col_white)
             end
        end
    end
end)
