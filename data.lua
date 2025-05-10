
local toggle_map_custom_input = {
    type = "custom-input",
    name = "toggle-map-cutscene-creator",
    key_sequence = "",
    linked_game_control = "toggle-map",
    enabled_while_in_cutscene = true,
    action = "lua",
}

data:extend({
    toggle_map_custom_input,
})
