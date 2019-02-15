local function generate_offset(mult)
  return (math.random() - 0.5) * mult
end

local function generate_next_wind()
  return {
    yaw = math.random() * 2 * math.pi,
    mag = math.random() * 15
  }
end

wind = generate_next_wind()

local wind_interval = 60 * 20
local wind_counter = 0
local wind_change_factor = 4
local prev_wind = wind
local next_wind = generate_next_wind()

local function modify_wind()
  if wind_counter > wind_interval then
    prev_wind = next_wind
    next_wind = generate_next_wind()
    wind_counter = 0
  end
  wind.yaw = wind.yaw + ((next_wind.yaw - wind.yaw) / wind_change_factor)
  wind.mag = wind.mag + ((next_wind.mag - wind.mag) / wind_change_factor)
  --minetest.log('error', "wind "..minetest.write_json(wind))
  --minetest.log('error', "next wind "..minetest.write_json(next_wind))
  wind_counter = wind_counter + 1
  minetest.after(1, modify_wind)
end

modify_wind()

function show_wind(pos, rand, player_name)
  if math.random() < rand then
    local random_pos = {
      x = pos.x + generate_offset(5),
      y = pos.y + generate_offset(5),
      z = pos.z + generate_offset(5)
    }
    local wind_vec = wind_to_vec()
    minetest.add_particle({
          pos = random_pos,
          velocity = {x=wind_vec.x, y=0, z=wind_vec.z},
          expirationtime = 3,
          size = 1,
          texture = "wind.png",
          playername = player_name,
          glow = 5
      })
    end
end
