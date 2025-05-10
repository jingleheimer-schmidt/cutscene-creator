
local transition_time = {
    type = "double-setting",
    name = "cc-transition-time",
    setting_type = "runtime-per-user",
    minimum_value = 0,
    default_value = 2,
    order = "cc-1"
}

local wait_time = {
    type = "double-setting",
    name = "cc-time-wait",
    setting_type = "runtime-per-user",
    minimum_value = 0,
    default_value = 1,
    order = "cc-2"
}

local zoom_level = {
    type = "double-setting",
    name = "cc-zoom",
    setting_type = "runtime-per-user",
    minimum_value = 0,
    default_value = .75,
    maximum_value = 100,
    order = "cc-3"
}

data:extend({
    transition_time,
    wait_time,
    zoom_level
})
