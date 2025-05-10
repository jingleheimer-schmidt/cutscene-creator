
---@class player_data
---@field position MapPosition
---@field physical_position MapPosition
---@field surface SurfaceIdentification
---@field physical_surface SurfaceIdentification
---@field zoom number
---@field controller_type defines.controllers
---@field character LuaEntity?
---@field waypoint_count integer

---@param waypoints CutsceneWaypoint[]
---@return string
local function get_intended_cutscene_surface(waypoints)
    local surface_names = {}
    for _, waypoint in pairs(waypoints) do
        if waypoint.surface then
            if waypoint.surface then
                surface_names[waypoint.surface] = (surface_names[waypoint.surface] or 0) + 1
            end
        end
    end
    local max_count, surface_name = 0, "nauvis"
    for name, count in pairs(surface_names) do
        if count > max_count then
            max_count = count
            surface_name = name
        end
    end
    return surface_name
end

---@param waypoints CutsceneWaypoint[]
---@param player LuaPlayer
local function set_cutscene_controller(waypoints, player)
    local player_index = player.index
    -- since cutscenes can't be created for players in remote view, stash their data in storage and temporarily set them to spectator
    ---@type table<integer, player_data>
    storage.player_data = storage.player_data or {}
    storage.player_data[player_index] = {
        position = player.position,
        physical_position = player.physical_position,
        surface = player.surface_index,
        physical_surface = player.physical_surface_index,
        zoom = player.zoom,
        controller_type = player.controller_type,
        character = player.character,
        waypoint_count = #waypoints
    }
    player.set_controller { type = defines.controllers.spectator }
    player.teleport(player.position, get_intended_cutscene_surface(waypoints), true)
    player.zoom = storage.player_data[player_index].zoom
    local transfer_alt_mode = player.game_view_settings.show_entity_info
    player.set_controller {
        type = defines.controllers.cutscene,
        waypoints = waypoints,
        start_position = player.position,
        start_zoom = storage.player_data[player_index].zoom,
        final_transition_time = player.mod_settings["cc-transition-time"].value --[[@as integer]] * 60,
        chart_mode_cutoff = 0.2,
    }
    player.game_view_settings.show_entity_info = transfer_alt_mode
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
---@param player_index integer
---@return CutsceneWaypoint[]?
local function create_waypoints_from_string(parameter, player_index)
    -- local parameter = "[gps=51,37,nauvis][train=3841][train-stop=100][gps=53,38]"
    -- local parameter = "[gps=1,1][train=22]t22 w22 z.22[train-stop=333] transition 300 wait 333 zoom 0.333 [gps=4444,4444,nauvis][gps=55555,55555]    z0.55555  wait55555 t55555  "
    local waypoints = {}
    local player = game.get_player(player_index)
    if not (player and player.valid) then return end
    local has_a_tag = parameter:find("%[.-]")
    if not has_a_tag then player.print({ "cc-messages.invalid-no-waypoints" }) return end
    local mod_settings = player.mod_settings
    parameter = parameter:gsub("%s*", "") -- remove all whitespace
    parameter = parameter .. "[" -- add a bracket to the end of the string for the final match
    for key, value, options in parameter:gmatch("%[([^=]+)=([^%]]+)%]([^[]*)") do
        key, value, options = tostring(key), tostring(value), tostring(options)
        local waypoint = {}
        if key == "gps" then
            local x, y, surface = value:match("([^,]+),([^,]+),?(.*)")
            if x and y then
                x, y = tonumber(x), tonumber(y)
                waypoint.position = { x = x, y = y }
                waypoint.surface = surface or "nauvis"
            end
        elseif key == "train" then
            local train_id = tonumber(value)
            if train_id then
                local train = get_train_target(train_id)
                if train then
                    waypoint.target = train
                    waypoint.surface = train.surface.name
                end
            end
        elseif key == "train-stop" then
            local station_unit_number = tonumber(value)
            if station_unit_number then
                local station = get_station_target(station_unit_number)
                if station then
                    waypoint.target = station
                    waypoint.surface = station.surface.name
                end
            end
        end
        if waypoint.position or waypoint.target then
            local transition = options:match("transition([%d%.]*)") or options:match("^t([%d%.]*)") or options:match("[^%a]t([%d%.]*)")
            local wait = options:match("wait([%d%.]*)") or options:match("^w([%d%.]*)") or options:match("[^%a]w([%d%.]*)")
            local zoom = options:match("zoom([%d%.]*)") or options:match("^z([%d%.]*)") or options:match("[^%a]z([%d%.]*)")
            waypoint.transition_time = (transition and tonumber(transition) or mod_settings["cc-transition-time"].value) * 60
            waypoint.time_to_wait = (wait and tonumber(wait) or mod_settings["cc-time-wait"].value) * 60
            waypoint.zoom = zoom and tonumber(zoom) or mod_settings["cc-zoom"].value
            table.insert(waypoints, waypoint)
        end
    end
    return waypoints
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
        if (position.x < -1000000 or position.x > 1000000 or position.y < -1000000 or position.y > 1000000) then
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

---@param event CustomCommandData | EventData.CustomInputEvent
local function end_cutscene(event)
    local player = game.get_player(event.player_index)
    if not (player and player.valid) then return end
    if (player.controller_type == defines.controllers.cutscene) then
        player.exit_cutscene()
    end
end

local function add_commands()
    commands.add_command("cutscene", { "cc-command-help.play-cutscene-help" }, play_cutscene)
    commands.add_command("end-cutscene", { "cc-command-help.end-cutscene-help" }, end_cutscene)
end

script.on_init(add_commands)
script.on_load(add_commands)

script.on_event("toggle-map-cutscene-creator", end_cutscene)

---@param event EventData.on_cutscene_finished | EventData.on_cutscene_cancelled
local function on_cutscene_ended(event)
    local player_index = event.player_index
    local player = game.get_player(player_index)
    if not (player and player.valid) then return end
    storage.player_data = storage.player_data or {}
    local player_data = storage.player_data[player_index]
    if player_data then
        player.teleport(player_data.physical_position, player_data.physical_surface, true)
        local character = player_data.character
        if character and character.valid then
            player.set_controller {
                type = defines.controllers.character,
                character = character,
            }
        else
            player.set_controller {
                type = defines.controllers.ghost,
            }
        end
        if not (player_data.controller_type == defines.controllers.character) then
            player.set_controller {
                type = player_data.controller_type,
                position = player_data.position,
                surface = player_data.surface,
            }
            player.zoom = player_data.zoom
        end
        storage.player_data[player_index] = nil
    end
end

script.on_event(defines.events.on_cutscene_finished, on_cutscene_ended)
script.on_event(defines.events.on_cutscene_cancelled, on_cutscene_ended)

local interface_functions = {}
interface_functions.cc_status = function(player_index)
    if storage.player_data and storage.player_data[player_index] then
        return "active"
    end
end

remote.add_interface("cc_check", interface_functions)
