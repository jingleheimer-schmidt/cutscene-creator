
script.on_init(function()
  commands.add_command("cutscene", "shift-click on map to create waypoints", play_cutscene)
  commands.add_command("cc", "/c cc tt<transition time (ticks)> wt<waiting time (ticks)> z<zoom>", play_cutscene)
end)

function play_cutscene(command)
  local player_index = command.player_index
  local parameter = command.parameter
  local name = command.name
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
  local cc_transition_time = game.players[player_index].mod_settings["cc-transition-time"].value
  local tt = "transition_time="..cc_transition_time
  local cc_time_wait = game.players[player_index].mod_settings["cc-time-wait"].value
  local wt = "time_to_wait="..cc_time_wait
  local zoom = game.players[player_index].mod_settings["cc-zoom"].value
  local z = "zoom="..zoom
  parameter = parameter:gsub("%s*",""):gsub("%[","{"):gsub("%]","}"):gsub("gps=","position={"):gsub("%}%{","}}, {")
  parameter = parameter.."}"
  parameter = parameter:gsub("%}%}","},"..tt..","..wt..","..z.."}")
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
end
