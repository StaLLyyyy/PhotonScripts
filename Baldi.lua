local menu = gui.create("Baldi Script", false)
menu:set_size(300, 1050)

local notebook_esp_check = menu:add_checkbox("Notebook ESP", false)
local phone_esp_check = menu:add_checkbox("Phone ESP", false)
local vending_esp_check = menu:add_checkbox("Vending Machines ESP", false)
local baldi_spawn_check = menu:add_checkbox("Baldi Spawn ESP", false)
local item_esp_check = menu:add_checkbox("Items ESP", false)
local team_esp_check = menu:add_checkbox("Team ESP", false)

local draw_box_check = menu:add_checkbox("Draw Convex Chams", true)
local draw_name_check = menu:add_checkbox("Draw Name", true)

local auto_collect_toggle = menu:add_checkbox("Auto Collect Toggle", false)
local auto_collect_bind = menu:add_keybind("Auto Collect Key", 0)
local auto_collect_delay = menu:add_slider("Collect Delay (s)", 0, 10, 2.5)

local text_size_slider = menu:add_slider("Text Size", 8, 32, 16)

local speed_slider = menu:add_slider("Player Speed", 10, 150, 20)
local stamina_slider = menu:add_slider("Player Stamina", 0, 150, 100)

local antifreeze_check = menu:add_checkbox("Anti-Freeze", false)
local wormhole_check = menu:add_checkbox("Instant Wormhole", false)
local no_fog_check = menu:add_checkbox("No Black Screen", false)

local crouch_check = menu:add_checkbox("Infinite Crouch", false)
local antiragdoll_check = menu:add_checkbox("Anti-Ragdoll", false)
local forceragdoll_check = menu:add_checkbox("Force Ragdoll", false)
local hoverdoor_check = menu:add_checkbox("Hover Is Door", false)
local nonhostile_check = menu:add_checkbox("Non-Hostile", false)
local nocorrupt_check = menu:add_checkbox("No Corrupt Screen", false)

local opacity_slider = menu:add_slider("Opacity", 0, 1, 1)
local boost_slider = menu:add_slider("Boostometer", 0, 100, 0)
local ammo_slider = menu:add_slider("Ammo", 0, 10, 0)

local col_notebook = menu:add_color("Notebook Color", color(1, 1, 0, 1))
local col_phone = menu:add_color("Phone Color", color(0, 0.5, 1, 1))
local col_vending = menu:add_color("Vending Color", color(1, 0.5, 0, 1))
local col_spawn = menu:add_color("Spawn Color", color(1, 0, 0, 1))
local col_default_item = menu:add_color("Default Item Color", color(1, 1, 1, 1))
local col_log = menu:add_color("Log Color", color(0.6, 0.3, 0, 1))
local col_coal = menu:add_color("Coal Color", color(0.1, 0.1, 0.1, 1))

local MOUSE1 = 1
local MOUSE2 = 2

local tp_lobby_btn = menu:add_button("TP to Lobby", function()
    pcall(function()
        local workspace = game:get_service("Workspace")
        local lp = game:get_service("Players").local_player
        if lp:isvalid() and lp.character:isvalid() then
            local root = lp.character:find_first_child("HumanoidRootPart")
            if root:isvalid() then
                 local game_folder = workspace:find_first_child("Game")
                 if game_folder:isvalid() then
                     local lobby = game_folder:find_first_child("Lobby")
                     if lobby:isvalid() then
                         local spawns = lobby:find_first_child("Spawns")
                         if spawns:isvalid() then
                             local loc = spawns:find_first_child("SpawnLocation")
                             if loc:isvalid() then
                                 root:set_cframe_position(loc.position:add(vector3(0, 5, 0)))
                             end
                         end
                     end
                 end
            end
        end
    end)
end)

local tp_map_btn = menu:add_button("TP on Map", function()
    pcall(function()
        local workspace = game:get_service("Workspace")
        local lp = game:get_service("Players").local_player
        if lp:isvalid() and lp.character:isvalid() then
            local root = lp.character:find_first_child("HumanoidRootPart")
            if root:isvalid() then
                 local game_folder = workspace:find_first_child("Game")
                 if game_folder:isvalid() then
                     local map_folder = game_folder:find_first_child("Map")
                     if map_folder:isvalid() then
                         local spawns = map_folder:find_first_child("Spawns")
                         if spawns:isvalid() then
                             local player_folder = spawns:find_first_child("Player")
                             if player_folder:isvalid() then
                                 local loc = player_folder:find_first_child("SpawnLocation")
                                 if loc:isvalid() then
                                     root:set_cframe_position(loc.position:add(vector3(0, 5, 0)))
                                 end
                             end
                         end
                     end
                 end
            end
        end
    end)
end)

local tp_prev_btn = menu:add_button("TP Last Pos", function()
    pcall(function()
        local workspace = game:get_service("Workspace")
        local lp = game:get_service("Players").local_player
        if lp:isvalid() and lp.character:isvalid() then
            local root = lp.character:find_first_child("HumanoidRootPart")
            if root:isvalid() then
                local char = lp.character
                local vals = nil
                if char:isvalid() then vals = char:find_first_child("Values") end
                
                if not (vals and vals:isvalid()) then
                    local game_f = workspace:find_first_child("Game")
                    if game_f:isvalid() then
                        local players_f = game_f:find_first_child("Players")
                        if players_f:isvalid() then
                            local my_node = players_f:find_first_child(lp.name)
                            if my_node:isvalid() then
                                vals = my_node:find_first_child("Values")
                            end
                        end
                    end
                end

                if vals and vals:isvalid() then
                    local prev_pos = vals:find_first_child("PreviousPosition")
                    if prev_pos:isvalid() then
                        local vec = prev_pos:get_value_vector()
                        if vec.x ~= 0 or vec.y ~= 0 or vec.z ~= 0 then
                            root:set_cframe_position(vec)
                        end
                    end
                end
            end
        end
    end)
end)

spawn(function()
    while true do
        pcall(function()
            if no_fog_check:get_value() then
                local lighting = game:get_service("Lighting")
                if lighting:isvalid() then
                    lighting:set_fog(100000)
                end
            end

            local players_service = game:get_service("Players")
            local lp = players_service.local_player
            
            if lp:isvalid() then
                local vals = nil
                if lp.character:isvalid() then
                    vals = lp.character:find_first_child("Values")
                end

                if not (vals and vals:isvalid()) then
                    local workspace = game:get_service("Workspace")
                    local game_f = workspace:find_first_child("Game")
                    if game_f:isvalid() then
                        local players_f = game_f:find_first_child("Players")
                        if players_f:isvalid() then
                            local my_node = players_f:find_first_child(lp.name)
                            if my_node:isvalid() then
                                vals = my_node:find_first_child("Values")
                            end
                        end
                    end
                end

                if vals and vals:isvalid() then
                    local spd = vals:find_first_child("Speed")
                    if spd:isvalid() then spd:set_value_float(speed_slider:get_value()) end
                    
                    local sta = vals:find_first_child("Stamina")
                    if sta:isvalid() then sta:set_value_float(stamina_slider:get_value()) end
                    
                    if antifreeze_check:get_value() then
                        local frz = vals:find_first_child("Frozen")
                        if frz:isvalid() then frz:set_value_bool(false) end
                    end
                    
                    if wormhole_check:get_value() then
                        local worm = vals:find_first_child("WormholeCD")
                        if worm:isvalid() then worm:set_value_float(0) end
                    end

                    if crouch_check:get_value() then
                        local cr = vals:find_first_child("Crouch")
                        if cr:isvalid() then cr:set_value_bool(true) end
                    end

                    if antiragdoll_check:get_value() then
                        local rag = vals:find_first_child("Ragdoll")
                        if rag:isvalid() then rag:set_value_bool(false) end
                    end

                    if forceragdoll_check:get_value() then
                        local rag = vals:find_first_child("Ragdoll")
                        if rag:isvalid() then rag:set_value_bool(true) end
                    end

                    if hoverdoor_check:get_value() then
                        local hov = vals:find_first_child("HoverIsDoor")
                        if hov:isvalid() then hov:set_value_bool(true) end
                    end

                    if nonhostile_check:get_value() then
                        local hos = vals:find_first_child("Hostile")
                        if hos:isvalid() then hos:set_value_bool(false) end
                    end

                    if nocorrupt_check:get_value() then
                        local cor = vals:find_first_child("CorruptScreen")
                        if cor:isvalid() then cor:set_value_bool(false) end
                    end

                    local op = vals:find_first_child("Opacity")
                    if op:isvalid() then op:set_value_float(opacity_slider:get_value()) end

                    local boost = vals:find_first_child("Boostometer")
                    if boost:isvalid() then boost:set_value_float(boost_slider:get_value()) end

                    local ammo = vals:find_first_child("Ammo")
                    if ammo:isvalid() then 
                        if ammo.class_name == "IntValue" then
                            ammo:set_value_int(ammo_slider:get_value()) 
                        else
                            ammo:set_value_float(ammo_slider:get_value())
                        end
                    end
                end
            end

            local active = auto_collect_toggle:get_value() or auto_collect_bind:get_state()
            
            if active then
                if lp:isvalid() and lp.character:isvalid() then
                    local root = lp.character:find_first_child("HumanoidRootPart")
                    
                    if root:isvalid() then
                        local origin = root.position
                        
                        local workspace = game:get_service("Workspace")
                        local game_folder = workspace:find_first_child("Game")
                        if game_folder:isvalid() then
                            local map = game_folder:find_first_child("Map")
                            if map:isvalid() then
                                local notebooks = map:find_first_child("Notebooks")
                                if notebooks:isvalid() then
                                    for _, nb in pairs(notebooks:get_children()) do
                                        if not (auto_collect_toggle:get_value() or auto_collect_bind:get_state()) then break end
                                        
                                        local hitbox = nb:find_first_child("InteractionHitbox")
                                        
                                        if hitbox:isvalid() then
                                            local target_pos = hitbox.position
                                            local stand_pos = target_pos:add(vector3(3, 3, 0))
                                            
                                            root:set_cframe_position(stand_pos)
                                            
                                            local delay_ms = auto_collect_delay:get_value() * 1000
                                            wait(delay_ms)
                                        end
                                    end
                                end
                            end
                        end
                        
                        root:set_cframe_position(origin)
                    end
                end
            end
        end)
        wait(200)
    end
end)

local function get_part_corners_3d(part)
    if not part or not part:isvalid() then return {} end
    local size = part.size
    local pos = part.cframe_position
    local look_vector = part.cframe_lookvector:unit()
    local up_vector
    local right_vector

    if math.abs(look_vector.y) > 0.99 then
        right_vector = look_vector:cross_product(vector3(1, 0, 0)):unit()
        up_vector = right_vector:cross_product(look_vector):unit()
    else
        right_vector = look_vector:cross_product(vector3(0, 1, 0)):unit()
        up_vector = right_vector:cross_product(look_vector):unit()
    end

    local sx = size.x * 0.5
    local sy = size.y * 0.5
    local sz = size.z * 0.5
    
    local corners = {}
    for i = -1, 1, 2 do
        for j = -1, 1, 2 do
            for k = -1, 1, 2 do
                local offset = right_vector:multiply_scalar(i * sx):add(up_vector:multiply_scalar(j * sy)):add(look_vector:multiply_scalar(k * sz))
                table.insert(corners, pos:add(offset))
            end
        end
    end
    return corners
end

local function cross_product_2d(p1, p2, p3)
    return (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x)
end

local function calculate_convex_hull(points)
    if #points <= 2 then return points end
    table.sort(points, function(a, b) if a.x == b.x then return a.y < b.y end return a.x < b.x end)
    local lower_hull, upper_hull = {}, {}
    for i = 1, #points do
        local p = points[i]
        while #lower_hull >= 2 and cross_product_2d(lower_hull[#lower_hull-1], lower_hull[#lower_hull], p) <= 0 do
            table.remove(lower_hull)
        end
        table.insert(lower_hull, p)
    end
    for i = #points, 1, -1 do
        local p = points[i]
        while #upper_hull >= 2 and cross_product_2d(upper_hull[#upper_hull-1], upper_hull[#upper_hull], p) <= 0 do
            table.remove(upper_hull)
        end
        table.insert(upper_hull, p)
    end
    table.remove(lower_hull)
    table.remove(upper_hull)
    for i = 1, #upper_hull do
        table.insert(lower_hull, upper_hull[i])
    end
    return lower_hull
end

local function draw_convex_chams(part, text, col, font_size)
    if not part:isvalid() then return end

    local points3d = get_part_corners_3d(part)
    local points2d = {}
    local min_y = 100000
    local min_x = 100000
    local max_x = -100000

    for _, p3d in pairs(points3d) do
        local p2d = world_to_screen(p3d)
        if p2d then
            table.insert(points2d, p2d)
            if p2d.y < min_y then min_y = p2d.y end
            if p2d.x < min_x then min_x = p2d.x end
            if p2d.x > max_x then max_x = p2d.x end
        end
    end

    if #points2d == 0 then return end
    
    local center = world_to_screen(part.cframe_position)
    if not in_screen(center) then return end

    if draw_box_check:get_value() then
        if #points2d > 2 then
            local hull = calculate_convex_hull(points2d)
            if #hull > 1 then
                for i = 1, #hull do
                    local p1 = hull[i]
                    local p2 = hull[(i % #hull) + 1]
                    
                    render.add_line(p1, p2, color(0, 0, 0, 1), 3.0)
                    render.add_line(p1, p2, col, 1.5)
                end
            end
        end
    end

    if draw_name_check:get_value() then
        local txt_size = render.get_text_size(text)
        local mid_x = (min_x + max_x) / 2
        local txt_pos = vector2(mid_x - (txt_size.x / 2), min_y - txt_size.y - 4)
        render.add_text(txt_pos, text, col, font_size, true)
    end
end

local function get_item_color(name)
    if name == "Quarter" then return color(0.8, 0.8, 0.8, 1) end
    if name == "BSODA" then return color(0, 0, 1, 1) end
    if name == "Diet BSODA" then return color(1, 0.4, 0.7, 1) end
    if name == "Zesty Bar" then return color(0.6, 0.3, 0, 1) end
    if name == "An Apple For Baldi" then return color(1, 0, 0, 1) end
    if name == "Dangerous Teleporter" then return color(0.5, 0, 0.5, 1) end
    if string.find(name, "YTP") then return color(0, 1, 0, 1) end
    if name == "Invisibility Elixir" then return color(0.8, 1, 0.8, 1) end
    if name == "Circle Key" then return color(1, 0.8, 0, 1) end
    if name == "Super Stretchy Glove" then return color(1, 0.2, 0.2, 1) end
    if name == "Baldi's Least Favorite Tape" then return color(0.3, 0.3, 0.3, 1) end
    if name == "Techno Boots" then return color(0, 1, 1, 1) end
    if name == "Alarm Clock" then return color(0.9, 0.9, 0.9, 1) end
    if name == "Safety Scissors" then return color(1, 0, 0.5, 1) end
    if name == "WD-NoSquee" then return color(0, 0, 0.5, 1) end
    if name == "Principal's Keys" then return color(0.8, 0.8, 0.2, 1) end
    if name == "Log" then return col_log:get_color() end
    if name == "Coal" then return col_coal:get_color() end
    
    return col_default_item:get_color()
end

hook.add("render", "baldi_esp", function()
    pcall(function()
        local workspace = game:get_service("Workspace")
        local game_folder = workspace:find_first_child("Game")
        if not game_folder:isvalid() then return end
        
        local map_folder = game_folder:find_first_child("Map")
        if not map_folder:isvalid() then return end
        
        local txt_sz = text_size_slider:get_value()

        local active = auto_collect_toggle:get_value() or auto_collect_bind:get_state()
        if active then
            local screen_size = get_screen_size()
            render.add_text(vector2(screen_size.x / 2 - 70, 80), "AUTO COLLECTING...", color(0, 1, 0, 1), 20, true)
        end

        if notebook_esp_check:get_value() then
            local notebooks_folder = map_folder:find_first_child("Notebooks")
            if notebooks_folder:isvalid() then
                for _, notebook in pairs(notebooks_folder:get_children()) do
                    local hitbox = notebook:find_first_child("InteractionHitbox")
                    if hitbox:isvalid() then
                        draw_convex_chams(hitbox, "Notebook", col_notebook:get_color(), txt_sz)
                    end
                end
            end
        end

        if phone_esp_check:get_value() or vending_esp_check:get_value() then
            local vendings_folder = map_folder:find_first_child("Vendings")
            if vendings_folder:isvalid() then
                if phone_esp_check:get_value() then
                    local phone = vendings_folder:find_first_child("Phone")
                    if phone:isvalid() then
                        draw_convex_chams(phone, "Phone", col_phone:get_color(), txt_sz)
                    end
                end

                if vending_esp_check:get_value() then
                    for _, vending in pairs(vendings_folder:get_children()) do
                        if vending.name ~= "Phone" then
                            local hitbox = vending:find_first_child("InteractionHitbox")
                            if hitbox:isvalid() then
                                draw_convex_chams(hitbox, vending.name, col_vending:get_color(), txt_sz)
                            end
                        end
                    end
                end
            end
        end

        if baldi_spawn_check:get_value() then
            local spawns_folder = map_folder:find_first_child("Spawns")
            if spawns_folder:isvalid() then
                local baldi_folder = spawns_folder:find_first_child("Baldi")
                if baldi_folder:isvalid() then
                    local spawn_loc = baldi_folder:find_first_child("SpawnLocation")
                    if spawn_loc:isvalid() then
                        draw_convex_chams(spawn_loc, "Baldi Spawn", col_spawn:get_color(), txt_sz)
                    end
                end
            end
        end

        if item_esp_check:get_value() then
            local item_folder = map_folder:find_first_child("Item")
            if item_folder:isvalid() then
                for _, item in pairs(item_folder:get_children()) do
                    local hitbox = item:find_first_child("InteractionHitbox")
                    if hitbox:isvalid() then
                        local c = get_item_color(item.name)
                        draw_convex_chams(hitbox, item.name, c, txt_sz)
                    end
                end
            end
        end
    end)
end)

hook.add("esp_drawextra", "baldi_team_esp", function(player)
    pcall(function()
        if not team_esp_check:get_value() then return end
        if not player:isvalid() then return end
        local team = player:get_team()
        if team:isvalid() then
            if team.name == "Baldi" then
                render.add_extra("Baldi", ESP_TOP, color(1, 0, 0, 1))
            elseif team.name == "Players" then
                render.add_extra("Survivor", ESP_TOP, color(0, 0, 1, 1))
            end
        end
    end)
end)
