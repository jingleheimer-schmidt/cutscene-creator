
script.on_load(function()
  commands.add_command("cutscene", "/cutscene <shift-click on map to create waypoints>", play_cutscene)
  commands.add_command("cc", "/cc tt<transition time (ticks)> wt<waiting time (ticks)> z<zoom at position>", play_cutscene)
end)

function play_cutscene(command)
  local player_index = command.player_index
  local parameter = command.parameter
  local name = command.name
  if name == "cutscene" then
    local created_waypoints = create_waypoints_simple(parameter, player_index)
    if created_waypoints then
      sync_color(player_index)
      create_cutscene(created_waypoints, player_index)
    else
      game.print("Invalid waypoints")
    end
  end
  if name == "cc" then
    local created_waypoints = create_waypoints_custom(parameter)
    if created_waypoints then
      sync_color(player_index)
      create_cutscene_custom(created_waypoints, player_index)
    else
      game.print("Invalid waypoints")
    end
  end
end

-- create the waypoints, save to variable, then create cutscene if the variable is present
-- parse and validate whatever user input you're taking, and then once you're sure it's reasonable use it to do whatever with

function sync_color(player_index)
  game.players[player_index].character.color = game.players[player_index].color
end

function create_cutscene(created_waypoints, player_index)
  game.players[player_index].set_controller{
    type = defines.controllers.cutscene,
    waypoints = created_waypoints,
    start_position = game.players[player_index].position,
    final_transition_time = game.players[player_index].mod_settings["cc-transition-time"].value
  }
end

function create_cutscene_custom(created_waypoints, player_index)
  game.players[player_index].set_controller{
    type = defines.controllers.cutscene,
    waypoints = created_waypoints,
    start_position = game.players[player_index].position
    -- final_transition_time = game.players[player_index].mod_settings["cc-transition-time"].value
  }
end

function create_waypoints_simple(parameter, player_index)
--   local parameter = "[gps=51,37,nauvis][gps=51,38,nauvis][gps=53,38,nauvis]"
  local waypoints = {}
  local tt = "transition_time="..game.players[player_index].mod_settings["cc-transition-time"].value
  local wt = "time_to_wait="..game.players[player_index].mod_settings["cc-time-wait"].value
  local z = "zoom="..game.players[player_index].mod_settings["cc-zoom"].value
  parameter = parameter:gsub("%s*",""):gsub("%[","{"):gsub("%]","}"):gsub("gps=","position={"):gsub("%}%{","}}, {")
  parameter = parameter.."}"
  parameter = parameter:gsub("%}%}","},"..tt..","..wt..","..z.."}")
  local proc, errmsg = load('local waypoints={'..parameter..'} return waypoints')
  if proc then
  local status, result = pcall(proc)
    if status then
      waypoints = result
      return waypoints
    -- else
    --   game.print(result)
    end
  -- else
  --   game.print(errmsg)
  end
end

function create_waypoints_custom(parameter)
--   local parameter = "[gps=51,37,nauvis]   tt300 wt30 z3 [gps=51,38,nauvis]tt300 wt30 z3    [gps=53,38,nauvis]   tt300 wt30 z3"
  local waypoints = {}
  parameter = parameter:gsub("%s*",""):gsub("%[","{"):gsub("%]","}"):gsub("gps=","position={"):gsub("tt",",transition_time="):gsub("wt",",time_to_wait="):gsub("z",",zoom="):gsub("%{position","},{position"):gsub("%}%,","",1)
  parameter = parameter.."}"
  -- game.print(parameter)
  local proc, errmsg = load('local waypoints={'..parameter..'} return waypoints')
  if proc then
  local status, result = pcall(proc)
    if status then
      waypoints = result
      return waypoints
    -- else
    --   game.print(result)
    end
  -- else
  --   game.print(errmsg)
  end
end
