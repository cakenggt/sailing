local function is_atoll(pos)
  local atoll_noise = minetest.get_perlin(wind.np_atoll)
  local new_pos = {x = pos.x, y = pos.z}
  --minetest.log('error', "noise at "..atoll_noise:get2d(new_pos))
  return atoll_noise:get2d(new_pos) > wind.ATOLL_START
end

-- Reimplement vector.direction because it is weird for some reason.
function direction(a, b)
    return vector.normalize(vector.subtract(b, a))
end

local GRID_LAYERS = 1
local TOTAL_GRID_POINTS = (((GRID_LAYERS * 2) + 1) ^ 2) - 1
local BIRD_PERSISTENCE_TIME = 30
local BIRD_PERIOD = 1
local DESIRED_BIRDS_ON_SCREEN = 10
local BIRD_CHANCE = DESIRED_BIRDS_ON_SCREEN / ((BIRD_PERSISTENCE_TIME / BIRD_PERIOD) * TOTAL_GRID_POINTS)

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
  for i, point in ipairs(get_grid(from, GRID_LAYERS, 1000)) do
    --minetest.log('error', "for point "..minetest.write_json(point))
    if is_atoll(point) then
      result[#result + 1] = direction(from, point)
      --minetest.log('error', "atoll at "..minetest.write_json(point))
    end
  end
  return result
end

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
              expirationtime = BIRD_PERSISTENCE_TIME,
              size = 4,
              texture = "bird.png"
          })
      end
    end
  end
  minetest.after(BIRD_PERIOD, show_birds)
end

-- Must run after world initializes
minetest.after(0, show_birds)
