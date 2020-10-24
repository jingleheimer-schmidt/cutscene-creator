
script.on_load()
  commands.add_command("cutscene", "shift-click on map to create waypoints", play_cutscene(name, tick, player_index, parameter))
  commands.add_command("cc", "/c cc tt<transition time (ticks)> wt<waiting time (ticks)> z<zoom>", play_cutscene(name, tick, player_index, parameter))
end

function play_cutscene(name, tick, player_index, parameter)
  if name == "cutscene" then
    game.players[player_index].set_controller{
      type = defines.controllers.cutscene,
      waypoints = create_waypoints_simple(parameter, player_index)
      -- final_transition_time = final_transition_time(parameter)
    }
  end
  if name == "cc" then
    game.players[player_index].set_controller{
      type = defines.controllers.cutscene,
      waypoints = create_waypoints_custom(parameter)
      -- final_transition_time = final_transition_time(parameter)
    }
  end
end

function create_waypoints_simple(parameter, player_index)
--   local parameter = "[gps=51,37,nauvis][gps=51,38,nauvis][gps=53,38,nauvis]"
  local waypoints = {}
  local tt, tw, z = "transition_time="..game.players[player_index].mod_settings["cc-transition-time"], "time_to_wait="..game.players[player_index].mod_settings["cc-time-wait"], "zoom="..game.players[player_index].mod_settings["cc-zoom"]
  parameter = parameter:gsub("%s*",""):gsub("%[","{"):gsub("%]","}"):gsub("gps=","position={"):gsub("%}%{","}}, {")
  parameter = parameter.."}"
  parameter = parameter:gsub("%}%}","},"..tt..","..tw..","..z.."}")
  local proc, errmsg = load('local waypoints={'..parameter..'} return waypoints')
  if proc then
  local status, result = pcall(proc)
      if status then
        waypoints = result
        return waypoints
      else
          game.print("pcall failed: "..result)
      end
  else
      game.print("load failed: "..errmsg)
  end
end

function create_waypoints_custom(parameter)
--   local parameter = "[gps=51,37,nauvis]   tt300 wt30 z3 [gps=51,38,nauvis]tt300 wt30 z3    [gps=53,38,nauvis]   tt300 wt30 z3"
  local waypoints = {}
  parameter = parameter:gsub("%s*",""):gsub("%[","{"):gsub("%]","}"):gsub("gps=","position={"):gsub("tt",",transition_time="):gsub("wt",",time_to_wait="):gsub("z",",zoom="):gsub("%{position","},{position"):gsub("%}%,","",1)
  parameter = parameter.."}"
  print(parameter)
  local proc, errmsg = load('local waypoints={'..parameter..'} return waypoints')
  if proc then
  local status, result = pcall(proc)
      if status then
        waypoints = result
        return waypoints
      else
          game.print("pcall failed: "..result)
      end
  else
      game.print("load failed: "..errmsg)
  end

