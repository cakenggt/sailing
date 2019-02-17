minetest.register_privilege("wind", {
  description = "Can change wind position",
})

minetest.register_chatcommand("wind", {
  params = "[<speed>]",
  description = "Sets the wind speed and direction to player's direction",
  privs = {wind = true},
  func = function(name, param)
    local player = minetest.get_player_by_name(name)
    if not player then
      return
    end
    local speed = string.match(param, "(%d+)")
    if speed then
      speed = tonumber(speed)
    else
      speed = 15
    end
    local direction = player:get_look_horizontal()
    local new_wind = {
      mag = speed,
      yaw = direction,
    }
    wind.current_wind = new_wind
    wind.next_wind = new_wind
    return true, "Wind set to "..speed.."in direction "..direction
  end
})
