
script.on_load()
  commands.add_command("cutscene-creator", help, play_cutscene(name, tick, player_index, parameter))
end

function play_cutscene(name, tick, player_index, parameter)
  if name == "cutscene-creator" then
    game.players[player_index].set_controller{
      type = defines.controllers.cutscene,
      -- character = game.players[player_index],
      waypoints = create_waypoints(parameter),
      -- final_transition_time = final_transition_time(parameter)
    }
  end
end

-- example parameter = "[gps=0,0] tt300 wt30 z3 [gps=0,0] tt300 wt30 z3 [gps=0,0] tt300 wt30 z3 [gps=0,0] tt300 wt30 z3"
function create_waypoints(parameter)
  local waypoints = {}
  local parameter = parameter:gsub("%[","{")
  local parameter = parameter:gsub("%]","}")
  local parameter = parameter:gsub("gps=","position={")
  local parameter = parameter:gsub("%stt",", transition_time=")
  local parameter = parameter:gsub("%swt",", time_to_wait=")
  local parameter = parameter:gsub("%sz",", zoom=")
  local parameter = parameter:gsub("%s%{","}, {")
end

function create_waypoints_simple(parameter)
  local waypoints = {}
  local tt = "transition_time=300"
  local tw = "time_to_wait=30"
  local z = "zoom=3"
  local parameter = parameter:gsub("%[","{")
  local parameter = parameter:gsub("%]","}")
  local parameter = parameter:gsub("gps=","position={")
  local parameter = parameter:gsub("%}%{","}} {")
  local parameter = parameter.."}"
  local parameter = parameter:gsub("%}%}","},"..tt..","..tw..","..z.."}")
  for i in parameter:gmatch("%S+") do
   table.insert(waypoints, i)
  end
  return waypoints
end

function create_waypoints_simple(parameter)
  local waypoints = {}
  local tt = "transition_time=300"
  local tw = "time_to_wait=30"
  local z = "zoom=3"
  local parameter = parameter:gsub("%s*",""):gsub("%[","{"):gsub("%]","}"):gsub("gps=","position={"):gsub("%}%{","}} {")
  local parameter = parameter.."}"
  local parameter = parameter:gsub("%}%}","},"..tt..","..tw..","..z.."}")
  for i in parameter:gmatch("%S+") do
   table.insert(waypoints, i)
  end
  return waypoints
end
