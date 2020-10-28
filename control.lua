
script.on_load(function()
  commands.add_command("cutscene", "/cutscene <shift-click on map or trains to create waypoints>", play_cutscene)
  -- commands.add_command("cc", "/cc tt<transition time (ticks)> wt<waiting time (ticks)> z<zoom at position>", play_cutscene)
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

-- TO DO: make sure all the trains and train stops are real before playing the cutscene, otherwise cancel and say invalid train or whatever. Right now user can input [train=3210] and if that doesn't exist the game crash, not caught by pcall (because error doesn't come until target=nil is loaded from waypoints).

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
        game.print("no front movers")
      end
    end
    for e,f in pairs(backs) do
      if f.unit_number == train_unit_number then
        return f
      else
        -- return "no_train"
        game.print("no back movers")
      end
    end
  end
end

function get_station_entity(station_unit_number, player_index)
  local table_of_stations = game.get_train_stops({surface=game.get_player(player_index).surface})
  for a,b in pairs(table_of_stations) do
    if b.unit_number == station_unit_number then
      station_entity = b
      if b then
        return b
      else
        game.print("no such station")
      end
    else
      -- game.print("no such station")
    end
  end
end

--[[
local parameter = "[gps=51,37,nauvis][gps=51,38,nauvis][train=98][gps=20,10][train=2453]"
local cc_transition_time = 200
local tt = "transition_time="..cc_transition_time
local cc_time_wait = 20
local wt = "time_to_wait="..cc_time_wait
local zoom = 2
local z = "zoom="..zoom
parameter = parameter:gsub("%s*","")
parameter = parameter:gsub("%[","{")
parameter = parameter:gsub("%]","}")
parameter = parameter:gsub("gps=","position={")
parameter = parameter:gsub("%}%{","}}, {")
parameter = parameter.."}"
parameter = parameter:gsub("%}%}","},"..tt..","..wt..","..z.."}")
]]

--[[
local parameter = "[gps=51,38,nauvis][train=98][gps=20,10][train=2453]"
local cc_transition_time = 200
local tt = "transition_time="..cc_transition_time
local cc_time_wait = 20
local wt = "time_to_wait="..cc_time_wait
local zoom = 2
local z = "zoom="..zoom
parameter = parameter:gsub("%s*","")
print(parameter)
parameter = parameter:gsub("%[","{")
print(parameter)
parameter = parameter:gsub("%]","}")
print(parameter)
parameter = parameter:gsub("gps=","position={")
print(parameter)
parameter = parameter:gsub("train=","target=get_train_entity{")
print(parameter)
parameter = parameter:gsub("%}%{","}}, {")
print(parameter)
parameter = parameter.."}"
print(parameter)
parameter = parameter:gsub("%}%}","},"..tt..","..wt..","..z.."}")
print(parameter)
parameter = parameter:gsub("%{(%d*)%}","(%1,player_index)")
print(parameter)
-- parameter = parameter:gsub("%(%{","(")
-- print(parameter)
-- parameter = parameter:gsub("%}%,player_index",",player_index")
-- print(parameter)

]]


function create_waypoints_simple(parameter, player_index)
--   local parameter = "[gps=51,37,nauvis][train=3841][train-stop=100][gps=53,38,nauvis]"
  local waypoints = {}
  local tt = "transition_time="..game.players[player_index].mod_settings["cc-transition-time"].value
  local wt = "time_to_wait="..game.players[player_index].mod_settings["cc-time-wait"].value
  local z = "zoom="..game.players[player_index].mod_settings["cc-zoom"].value
  parameter = parameter:gsub("%s*",""):gsub("%[","{"):gsub("%]","}"):gsub("gps=","position={"):gsub("train=","target=get_train_entity{"):gsub("train%-stop=","target=get_station_entity{"):gsub("%}%{","}}, {")
  parameter = parameter.."}"
  parameter = parameter:gsub("%}%}","},"..tt..","..wt..","..z.."}"):gsub("%{(%d*)%}","(%1,player_index)")
  -- local parameter = {position={51,38,nauvis},transition_time=200,time_to_wait=20,zoom=2}, {target=get_train_entity(98,player_index),transition_time=200,time_to_wait=20,zoom=2}, {position={20,10},transition_time=200,time_to_wait=20,zoom=2}, {target=get_train_entity(2453,player_index),transition_time=200,time_to_wait=20,zoom=2}
  local proc, errmsg = load('local waypoints={'..parameter..'} return waypoints',"bad_waypoints","t",{get_train_entity=get_train_entity,player_index=player_index,get_station_entity=get_station_entity})
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
--
-- local parameter = "[gps=51,37,nauvis]   tt300 wt30 z3 [train=9384]tt300 wt30 z3    [gps=53,38,nauvis]   tt300 wt30 z3"
-- parameter = parameter:gsub("%s*","")
-- parameter = parameter:gsub("%[","{")
-- parameter = parameter:gsub("%]","}")
-- print(parameter)
-- parameter = parameter:gsub("gps=","position={")
-- print(parameter)
-- parameter = parameter:gsub("tt",",transition_time=")
-- print(parameter)
-- parameter = parameter:gsub("wt",",time_to_wait=")
-- print(parameter)
-- parameter = parameter:gsub("z",",zoom=")
-- print(parameter)
-- parameter = parameter:gsub("%{position","},{position")
-- print(parameter)
-- parameter = parameter:gsub("%}%,","",1)
-- print(parameter)
-- parameter = parameter:gsub("train=","target=get_train_entity{")
-- print(parameter)
-- parameter = parameter:gsub("%{(%d*)%}","(%1,player_index)")
-- print(parameter)
-- parameter = parameter.."}"
-- print(parameter)

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
