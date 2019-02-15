local function is_atoll(pos)
  local atoll_noise = minetest.get_perlin(wind.np_atoll)
  local new_pos = {x = pos.x, y = pos.z}
  --minetest.log('error', "noise at "..atoll_noise:get2d(new_pos))
  return atoll_noise:get2d(new_pos) > wind.ATOLL_START
end

local function get_grid(center, layers, spacing)
  local middle = layers + 1
  local result = {}
  for x = 1, (layers * 2) + 1 do
    local x_offset = (x - middle) * spacing
    for z = 1, (layers * 2) + 1 do
      local z_offset = (z - middle) * spacing
      local is_middle = x_offset == 0 and z_offset == 0
      if not is_middle then
        local pos = {x = center.x + x_offset, y = center.y, z = center.z + z_offset}
        result[#result + 1] = pos
      end
    end
  end
  return result
end

local function get_vectors_to_atolls(from)
  local result = {}
  for i, point in ipairs(get_grid(from, 1, 1000)) do
    --minetest.log('error', "for point "..minetest.write_json(point))
    if is_atoll(point) then
      result[#result + 1] = vector.direction(from, point)
      --minetest.log('error', "atoll at "..minetest.write_json(point))
    end
  end
  return result
end

local BIRD_CHANCE = 0.1

local function show_birds()
  for i, obj in ipairs(minetest.get_connected_players()) do
    local player_name = obj:get_player_name()
    --minetest.log('error', "trying to show birds for "..player_name)
    local pos = obj:get_pos()
    -- minetest.log('error', "is atoll at player pos "..minetest.write_json(is_atoll(pos)))
    for i, vec in ipairs(get_vectors_to_atolls(pos)) do
      if math.random() < BIRD_CHANCE then
        local new_x = math.random(pos.x - 10, pos.x + 10)
        local new_z = math.random(pos.z - 10, pos.z + 10)
        minetest.add_particle({
              pos = {x = new_x, y = pos.y + 20, z = new_z},
              velocity = vec,
              expirationtime = 30,
              size = 4,
              texture = "bird.png",
              playername = player_name
          })
      end
    end
  end
  minetest.after(1, show_birds)
end

-- Must run after world initializes
minetest.after(0, show_birds)
