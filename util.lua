function mult_vec(vec, m)
  return {x = vec.x * m, z = vec.z * m}
end

function normalize_vec(vec)
  local mag = math.sqrt(vec.x ^ 2 + vec.z ^ 2)
  return mult_vec(vec, 1 / mag)
end

function yaw_to_vec(yaw)
  return normalize_vec({x = -math.sin(yaw), z = math.cos(yaw)})
end

function dot_product(vec1, vec2)
  return (vec1.x * vec2.x) + (vec1.z * vec2.z)
end

function wind_to_vec()
  return mult_vec(yaw_to_vec(wind.current_wind.yaw), wind.current_wind.mag)
end

function calculate_wind(boat)
  if boat.sail then
    local total_sail_yaw = boat.sail_yaw + boat.object:getyaw()
    local first_dot = dot_product(wind_to_vec(), yaw_to_vec(total_sail_yaw))
    local second_dot = dot_product(
      yaw_to_vec(total_sail_yaw),
      yaw_to_vec(boat.object:getyaw())
    )
    local total_mult = first_dot * second_dot
    if boat.driver then
      local ctrl = boat.driver:get_player_control()
      if ctrl.sneak then
        --minetest.log('error', "yaw vec "..minetest.write_json(yaw_to_vec(total_sail_yaw)))
        --minetest.log('error', "sail_yaw "..boat.sail_yaw)
        --minetest.log('error', "sail_vec"..minetest.write_json(yaw_to_vec(boat.sail_yaw)))
        --minetest.log('error', "first_dot "..first_dot)
        --minetest.log('error', "second_dot "..second_dot)
        --minetest.log('error', "total_sail_yaw "..total_sail_yaw)
        --minetest.log('error', "total_sail_vec "..minetest.write_json(yaw_to_vec(total_sail_yaw)))
        --minetest.log('error', "total mult "..total_mult)
      end
    end
    return total_mult
  else
    return 0
  end
end
