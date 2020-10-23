
local transitionTimeSetting = {
  type = "int-setting",
  name = "cc-transition-time",
  setting_type = "runtime-per-user",
  minimum_value = 1,
  default_value = 300
}

local timeWaitSetting = {
  type = "int-setting",
  name = "cc-time-wait",
  setting_type = "runtime-per-user",
  minimum_value = 1,
  default_value = 120
}

local zoomSetting = {
  type = "int-setting",
  name = "cc-zoom",
  setting_type = "runtime-per-user",
  minimum_value = 1,
  default_value = 1
}
  
data:extend({
  transitionTimeSetting,
  timeWaitSetting,
  zoomSetting
})
