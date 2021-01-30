
script.on_init(function()
  add_commands()
end)

script.on_load(function()
  add_commands()
end)

function add_commands()
  commands.add_command("cutscene", "[gps=0,0][train=210][train-stop=140] - Shift-click on map, trains, or stations to create waypoints. Additional options in Mod Settings. See mod portal page for documentation of advanced features", play_cutscene)
  commands.add_command("end-cutscene","- Ends the currently playing cutscene and immediately returns control to the player", end_cutscene)
end

function end_cutscene(command)
  local player = game.get_player(command.player_index)
  if ((player.controller_type == defines.controllers.cutscene) and (global.cc_status) and (global.cc_status[command.player_index]) and (global.cc_status[command.player_index] == "active")) then
    player.exit_cutscene()
    if global.cc_status then
      global.cc_status[player.index] = "inactive"
    end
    if global.number_of_waypoints then
      global.number_of_waypoints[player.index] = nil
    end
  else
    -- player.print("No cutscene currently playing")
  end
end

script.on_event(defines.events.on_cutscene_waypoint_reached, function(event)
  -- game.print("arrived at: waypoint " .. event.waypoint_index)
  if global.cc_status and global.cc_status[event.player_index] and (global.cc_status[event.player_index] == "active") then
    -- game.print("cc_status is: " .. global.cc_status[event.player_index])
    if global.number_of_waypoints and global.number_of_waypoints[event.player_index] and (global.number_of_waypoints[event.player_index] == event.waypoint_index) then
      global.cc_status[event.player_index] = "inactive"
      global.number_of_waypoints[event.player_index] = nil
      -- game.print("cc_status set to: " .. global.cc_status[event.player_index])
    end
  end
end)

function play_cutscene(command)
  local player_index = command.player_index
  local player = game.get_player(player_index)
  local parameter = command.parameter
  local name = command.name
  if player.controller_type == defines.controllers.cutscene then
    player.print("[color=blue]Wait. That's illegal.[/color]")
    return
  end
  if (parameter == nil) then
    player.print("Invalid waypoints: cutscene must have at least one waypoint or target. Shift-click on the map or a train to add a waypoint when constructing the command.")
    return
  end
  if ((name == "cutscene") and player.valid) then
    local created_waypoints = create_waypoints_combo(parameter, player_index)
    if created_waypoints then
      for a,b in pairs(created_waypoints) do
        if not ( b.target or b.position ) then
          player.print("Invalid waypoints: train or station does not exist")
          return
        end
        if b.position then
          if ( b.position[1]<-1000000 or b.position[1]>1000000 or b.position[2]<-1000000 or b.position[2]>1000000 ) then
            player.print("Error 404: coordinates not found")
            return
          end
        end
        if not b.transition_time then
          player.print("Invalid waypoints: one or more waypoints is missing transition time")
          return
        end
        if not b.time_to_wait then
          player.print("Invalid waypoints: one or more waypoints is missing waiting time")
          return
        end
      end
      -- sync_color(player_index)
      -- create_cutscene(created_waypoints, player)
      local status, result = pcall(create_cutscene, created_waypoints, player)
      if not status then
        player.print("Invalid waypoints: "..result)
      end
    else
      player.print("Invalid waypoints")
    end
  end
end
--
-- function sync_color(player_index)
--   local player = game.get_player(player_index)
--   player.character.color = player.color
-- end

function create_cutscene(created_waypoints, player)
  -- local player = game.get_player(player_index)
  player.set_controller{
    type = defines.controllers.cutscene,
    waypoints = created_waypoints,
    start_position = player.position,
    final_transition_time = player.mod_settings["cc-transition-time"].value
  }
  if not global.cc_status then
    global.cc_status = {}
    global.cc_status[player.index] = "active"
  else
    global.cc_status[player.index] = "active"
  end
  if not global.number_of_waypoints then
    global.number_of_waypoints = {}
    global.number_of_waypoints[player.index] = #created_waypoints
  else
    global.number_of_waypoints[player.index] = #created_waypoints
  end
end

function get_train_entity(train_unit_number, player_index)
  local table_of_trains = game.get_player(player_index).surface.get_trains()
  for a,b in pairs(table_of_trains) do
    local fronts = b.locomotives.front_movers
    local backs = b.locomotives.back_movers
    for c,d in pairs(fronts) do
      if d.unit_number == train_unit_number then
        return d
      else
        -- game.print("no front movers")
      end
    end
    for e,f in pairs(backs) do
      if f.unit_number == train_unit_number then
        return f
      else
        -- game.print("no back movers")
      end
    end
  end
end

function get_station_entity(station_unit_number, player_index)
  local table_of_stations = game.get_train_stops({surface=game.get_player(player_index).surface})
  for a,b in pairs(table_of_stations) do
    if b.unit_number == station_unit_number then
      return b
    else
      -- game.print("no such station")
    end
  end
end

function create_waypoints_combo(parameter, player_index)
-- local parameter = "[gps=51,37,nauvis][train=3841][train-stop=100][gps=53,38,nauvis]"
-- local parameter = "[gps=1,1][train=22]tt22 wt22 z.22[train-stop=333] tt300 wt333 z.333 [gps=4444,4444,nauvis][gps=55555,55555]   tt55555 wt55555 z0.55555"
  local waypoints = {}
  local player = game.get_player(player_index)
  local tt = "transition_time="..player.mod_settings["cc-transition-time"].value
  local wt = "time_to_wait="..player.mod_settings["cc-time-wait"].value
  local z = "zoom="..player.mod_settings["cc-zoom"].value
  parameter = parameter:gsub("%s*",""):gsub("%[","{"):gsub("%]","}")
  parameter = parameter:gsub("gps=","position={")
  parameter = parameter:gsub("train=","target=get_train_entity{")
  parameter = parameter:gsub("train%-stop=","target=get_station_entity{")
  parameter = parameter:gsub("tt",",transition_time=")
  parameter = parameter:gsub("wt",",time_to_wait=")
  parameter = parameter:gsub("z",",zoom=")
  parameter = parameter:gsub("%{position","},{position")
  parameter = parameter:gsub("%{target","},{target")
  parameter = parameter:gsub("%}%,","",1)
  parameter = parameter:gsub("%}%{","}}, {")
  parameter = parameter.."}"
  parameter = parameter:gsub("%}%}","},"..tt..","..wt..","..z.."}")
  parameter = parameter:gsub("%{(%d*)%}","(%1,player_index)")
  local proc, errmsg = load('local waypoints={'..parameter..'} return waypoints',"bad_waypoints","t",{get_train_entity=get_train_entity,player_index=player_index,get_station_entity=get_station_entity})
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

local interface_functions = {}
interface_functions.cc_status = function(player_index)
  if global.cc_status and global.cc_status[player_index] then
    return global.cc_status[player_index]
  end
end

remote.add_interface("cc_check",interface_functions)
