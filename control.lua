
script.on_init(function()
  commands.add_command("cutscene", "[gps=0,0][train=210][train-stop=140] - Shift-click on map, trains, or stations to create waypoints. Additional options in Mod Settings", play_cutscene)
  -- commands.add_command("cc", "tt<transition time (ticks)> wt<waiting time (ticks)> z<zoom at position>", play_cutscene)
  commands.add_command("end-cutscene","- Ends the currently playing cutscene and immediately returns control to the player", end_cutscene)
end)

script.on_load(function()
  commands.add_command("cutscene", "[gps=0,0][train=210][train-stop=140] - Shift-click on map, trains, or stations to create waypoints. Additional options in Mod Settings", play_cutscene)
  -- commands.add_command("cc", "tt<transition time (ticks)> wt<waiting time (ticks)> z<zoom at position>", play_cutscene)
  commands.add_command("end-cutscene","- Ends the currently playing cutscene and immediately returns control to the player", end_cutscene)
end)

function end_cutscene(command)
  local player = game.get_player(command.player_index)
  if player.controller_type == defines.controllers.cutscene then
    player.exit_cutscene()
  else
    player.print("No cutscene currently playing")
  end
end

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
    player.print("Invalid waypoints: cutscene must have at least one waypoint or target")
    return
  end
  if ((name == "cutscene") and player.valid) then
    local created_waypoints = create_waypoints_simple(parameter, player_index)
    if created_waypoints then
      for a,b in pairs(created_waypoints) do
        if not ( b.target or b.position ) then
          player.print("Invalid waypoints: train or station does not exist")
          return
        end
      end
      for c,d in pairs(created_waypoints) do
        if d.position then
          if ( d.position[1]<-1000000 or d.position[1]>1000000 or d.position[2]<-1000000 or d.position[2]>1000000 ) then
            player.print("Error 404: Coordinates not found")
            return
          end
        end
      end
      sync_color(player_index)
      create_cutscene(created_waypoints, player_index)
    else
      player.print("Invalid waypoints")
    end
  end
  -- if name == "cc" then
  --   local created_waypoints = create_waypoints_custom(parameter)
  --   if created_waypoints then
  --     sync_color(player_index)
  --     create_cutscene_custom(created_waypoints, player_index)
  --   else
  --     game.print("Invalid waypoints")
  --   end
  -- end
end

function sync_color(player_index)
  local player = game.get_player(player_index)
  player.character.color = player.color
end

function create_cutscene(created_waypoints, player_index)
  local player = game.get_player(player_index)
  player.set_controller{
    type = defines.controllers.cutscene,
    waypoints = created_waypoints,
    start_position = player.position,
    final_transition_time = player.mod_settings["cc-transition-time"].value
  }
end

-- function create_cutscene_custom(created_waypoints, player_index)
--   game.players[player_index].set_controller{
--     type = defines.controllers.cutscene,
--     waypoints = created_waypoints,
--     start_position = game.players[player_index].position
--     -- final_transition_time = game.players[player_index].mod_settings["cc-transition-time"].value
--   }
-- end

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

function create_waypoints_simple(parameter, player_index)
--   local parameter = "[gps=51,37,nauvis][train=3841][train-stop=100][gps=53,38,nauvis]"
  local waypoints = {}
  local player = game.get_player(player_index)
  local tt = "transition_time="..player.mod_settings["cc-transition-time"].value
  local wt = "time_to_wait="..player.mod_settings["cc-time-wait"].value
  local z = "zoom="..player.mod_settings["cc-zoom"].value
  parameter = parameter:gsub("%s*",""):gsub("%[","{"):gsub("%]","}"):gsub("gps=","position={"):gsub("train=","target=get_train_entity{"):gsub("train%-stop=","target=get_station_entity{"):gsub("%}%{","}}, {")
  parameter = parameter.."}"
  parameter = parameter:gsub("%}%}","},"..tt..","..wt..","..z.."}"):gsub("%{(%d*)%}","(%1,player_index)")
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

-- function create_waypoints_custom(parameter)
-- --   local parameter = "[gps=51,37,nauvis]   tt300 wt30 z3 [gps=51,38,nauvis]tt300 wt30 z3    [gps=53,38,nauvis]   tt300 wt30 z3"
--   local waypoints = {}
--   parameter = parameter:gsub("%s*",""):gsub("%[","{"):gsub("%]","}"):gsub("gps=","position={"):gsub("tt",",transition_time="):gsub("wt",",time_to_wait="):gsub("z",",zoom="):gsub("%{position","},{position"):gsub("%}%,","",1)
--   parameter = parameter.."}"
--   -- game.print(parameter)
--   local proc, errmsg = load('local waypoints={'..parameter..'} return waypoints')
--   if proc then
--   local status, result = pcall(proc)
--     if status then
--       waypoints = result
--       return waypoints
--     -- else
--     --   game.print(result)
--     end
--   -- else
--   --   game.print(errmsg)
--   end
-- end
