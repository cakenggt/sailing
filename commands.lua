minetest.register_privilege("wind", {
  description = "Can change wind position",
})

minetest.register_chatcommand("wind", {
  params = "[<speed> [<direction>]]",
  description = "Sets the wind speed and direction",
  privs = {wind = true},
  func = function(name, param)
    local player = minetest.get_player_by_name(name)
    if not player then
      return
    end
    local speed, direction = string.match(param, "(%d+) ([^ ]+)?")
    if speed then
      speed = tonumber(speed)
    else
      speed = 15
    end
    if direction then
      direction = tonumber(direction)
    else
      direction = player:get_look_horizontal()
    end
    local new_wind = {
      mag = speed,
      yaw = direction,
    }
    wind.current_wind = new_wind
    wind.next_wind = new_wind
    return true, "Wind set to "..speed.."in direction "..direction
  end
})
