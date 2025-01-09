
---@param created_waypoints CutsceneWaypoint[]
---@param player LuaPlayer
local function set_cutscene_controller(created_waypoints, player)
    local transfer_alt_mode = player.game_view_settings.show_entity_info
    player.set_controller {
        type = defines.controllers.cutscene,
        waypoints = created_waypoints,
        start_position = player.position,
        final_transition_time = player.mod_settings["cc-transition-time"].value --[[@as integer]]
    }
    player.game_view_settings.show_entity_info = transfer_alt_mode
    storage.cc_status = storage.cc_status or {}
    storage.cc_status[player.index] = "active"
    storage.number_of_waypoints = storage.number_of_waypoints or {}
    storage.number_of_waypoints[player.index] = #created_waypoints
end

---@param train_id integer
---@return LuaEntity?
local function get_train_target(train_id)
    local rolling_stock = game.get_entity_by_unit_number(train_id)
    local train = rolling_stock and rolling_stock.train
    if train then
        local front_stock = train.front_stock
        local back_stock = train.back_stock
        if train.speed >= 0 then
            return front_stock
        else
            return back_stock
        end
    end
end

---@param station_unit_number integer
---@return LuaEntity?
local function get_station_target(station_unit_number)
    local stations = game.train_manager.get_train_stops { unit_number = station_unit_number }
    for _, station in pairs(stations) do
        if station.unit_number == station_unit_number then
            return station
        end
    end
end

---@param parameter string
---@param player LuaPlayer
local function check_parameter_for_surface_mismatch(parameter, player)
    local surface_names = {}
    for _, surface in pairs(game.surfaces) do
        surface_names[surface.name] = true
    end
    local player_surface = player.surface.name
    for surface_name, _ in pairs(surface_names) do
        if (surface_name ~= player_surface) and string.find(parameter, surface_name) then
            player.print({ "cc-messages.surface-mismatch", surface_name })
            return
        end
    end
end

---@param parameter string
---@param player_index integer
---@return CutsceneWaypoint[]?
local function create_waypoints_from_string(parameter, player_index)
    -- local parameter = "[gps=51,37,nauvis][train=3841][train-stop=100][gps=53,38]"
    -- local parameter = "[gps=1,1][train=22]tt22 wt22 z.22[train-stop=333] tt300 wt333 z.333 [gps=4444,4444,nauvis][gps=55555,55555]   tt55555 wt55555 z0.55555"
    local waypoints = {}
    local player = game.get_player(player_index)
    if not (player and player.valid) then return end
    check_parameter_for_surface_mismatch(parameter, player)
    local mod_settings = player.mod_settings
    local tt = "transition_time=" .. mod_settings["cc-transition-time"].value
    local wt = "time_to_wait=" .. mod_settings["cc-time-wait"].value
    local z = "zoom=" .. mod_settings["cc-zoom"].value
    parameter = parameter:gsub("%s*", "")
    parameter = parameter:gsub("%[", "{"):gsub("%]", "}")
    parameter = parameter:gsub("gps=", "position={")
    parameter = parameter:gsub("train=", "target=get_train_target{")
    parameter = parameter:gsub("train%-stop=", "target=get_station_target{")
    parameter = parameter:gsub("tt", ",transition_time=")
    parameter = parameter:gsub("wt", ",time_to_wait=")
    parameter = parameter:gsub("z", ",zoom=")
    parameter = parameter:gsub("%{position", "},{position")
    parameter = parameter:gsub("%{target", "},{target")
    parameter = parameter:gsub("%}%,", "", 1)
    parameter = parameter:gsub("%}%{", "}}, {")
    parameter = parameter .. "}"
    parameter = parameter:gsub("%}%}", "}," .. tt .. "," .. wt .. "," .. z .. "}")
    parameter = parameter:gsub("%{(%d*)%}", "(%1)")
    local chunk = "local waypoints = { " .. parameter .. " } return waypoints"
    local proc, errmsg = load(chunk, "bad_waypoints", "t", { get_train_target = get_train_target, get_station_target = get_station_target })
    if proc then
        local status, result = pcall(proc)
        if status then
            waypoints = result
            return waypoints
        else
            -- game.print("pcall failed: "..result)
        end
    else
        -- game.print("load failed: "..errmsg)
    end
end

---@param waypoint CutsceneWaypoint
---@return boolean valid
---@return LocalisedString? error_message
local function validate_waypoint(waypoint)
    if not (waypoint.target or waypoint.position) then
        return false, { "cc-messages.invalid-no-target" }
    end
    local position = waypoint.position
    if position then
        if (position[1] < -1000000 or position[1] > 1000000 or position[2] < -1000000 or position[2] > 1000000) then
            return false, { "cc-messages.invalid-coordinates" }
        end
    end
    if not waypoint.transition_time then
        return false, { "cc-messages.invalid-no-transition-time" }
    end
    if not waypoint.time_to_wait then
        return false, { "cc-messages.invalid-no-wait-time" }
    end
    return true
end

---@param command CustomCommandData
local function play_cutscene(command)
    if not (command.name == "cutscene") then return end
    local player_index = command.player_index
    if not player_index then return end
    local player = game.get_player(player_index)
    if not (player and player.valid) then return end
    if player.controller_type == defines.controllers.cutscene then
        player.print({ "cc-messages.wait-thats-illegal" })
        return
    end
    local parameter = command.parameter
    if not parameter then
        player.print({ "cc-messages.invalid-no-waypoints" })
        return
    end
    local created_waypoints = create_waypoints_from_string(parameter, player_index)
    if created_waypoints then
        for _, waypoint in pairs(created_waypoints) do
            local valid, error_message = validate_waypoint(waypoint)
            if not valid then
                player.print(error_message)
                return
            end
        end
        local status, result = pcall(set_cutscene_controller, created_waypoints, player)
        if not status then
            player.print({ "cc-messages.invalid-waypoints-error-message", result })
        end
    else
        player.print({ "cc-messages.invalid-waypoints" })
    end
end

---@param command CustomCommandData
local function end_cutscene(command)
    local player = game.get_player(command.player_index)
    if not (player and player.valid) then return end
    if ((player.controller_type == defines.controllers.cutscene) and (storage.cc_status) and (storage.cc_status[command.player_index]) and (storage.cc_status[command.player_index] == "active")) then
        player.exit_cutscene()
        if storage.cc_status then
            storage.cc_status[player.index] = "inactive"
        end
        if storage.number_of_waypoints then
            storage.number_of_waypoints[player.index] = nil
        end
    else
        -- player.print("No cutscene currently playing")
    end
end

local function add_commands()
    commands.add_command("cutscene", { "cc-command-help.play-cutscene-help" }, play_cutscene)
    commands.add_command("end-cutscene", { "cc-command-help.end-cutscene-help" }, end_cutscene)
end

script.on_init(add_commands)
script.on_load(add_commands)

---@param event EventData.on_cutscene_waypoint_reached
local function on_cutscene_waypoint_reached(event)
    -- game.print("arrived at: waypoint " .. event.waypoint_index)
    if storage.cc_status and storage.cc_status[event.player_index] and (storage.cc_status[event.player_index] == "active") then
        -- game.print("cc_status is: " .. storage.cc_status[event.player_index])
        if storage.number_of_waypoints and storage.number_of_waypoints[event.player_index] and (storage.number_of_waypoints[event.player_index] == event.waypoint_index) then
            storage.cc_status[event.player_index] = "inactive"
            storage.number_of_waypoints[event.player_index] = nil
            -- game.print("cc_status set to: " .. storage.cc_status[event.player_index])
        end
    end
end

script.on_event(defines.events.on_cutscene_waypoint_reached, on_cutscene_waypoint_reached)

local interface_functions = {}
interface_functions.cc_status = function(player_index)
    if storage.cc_status and storage.cc_status[player_index] then
        return storage.cc_status[player_index]
    end
end

remote.add_interface("cc_check", interface_functions)
