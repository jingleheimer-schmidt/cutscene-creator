
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

function create_waypoints(parameter)
  local waypoints = game.json_to_table(parameter)
  
