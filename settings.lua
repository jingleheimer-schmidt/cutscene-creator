
local transitionTimeSetting = {
  type = "int-setting",
  name = "cc-transition-time",
  setting_type = "runtime-per-user",
  minimum_value = 1,
  default_value = 120,
  order = "cc-1"
}

local timeWaitSetting = {
  type = "int-setting",
  name = "cc-time-wait",
  setting_type = "runtime-per-user",
  minimum_value = 1,
  default_value = 60,
  order = "cc-2"
}

local zoomSetting = {
  type = "double-setting",
  name = "cc-zoom",
  setting_type = "runtime-per-user",
  minimum_value = .1,
  default_value = .75,
  maximum_value = 100
  order = "cc-3"
}

data:extend({
  transitionTimeSetting,
  timeWaitSetting,
  zoomSetting
})
