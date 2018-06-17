local function generate_offset(mult)
  return (math.random() - 0.5) * mult
end

local function generate_next_wind()
  return {
    x = generate_offset(30),
    z = generate_offset(30)
  }
end

wind = generate_next_wind()

local wind_interval = 120
local prev_wind = wind
local next_wind = generate_next_wind()

local function modify_wind()
  local current_time = minetest.get_gametime()
  if current_time then
    if not next_wind_time then
      next_wind_time = current_time + wind_interval
    end
    if next_wind_time <= current_time then
      prev_wind = next_wind
      next_wind = generate_next_wind()
      next_wind_time = current_time + wind_interval
    end
    local progress = (current_time - (next_wind_time - wind_interval)) / wind_interval
    wind = {
      x = prev_wind.x + ((next_wind.x - prev_wind.x) * progress),
      z = prev_wind.z + ((next_wind.z - prev_wind.z) * progress)
    }
    minetest.log('error', "wind "..minetest.write_json(wind))
    minetest.log('error', "progress "..progress)
    minetest.log('error', "next wind "..minetest.write_json(next_wind))
  end
  minetest.after(1, modify_wind)
end

modify_wind()

function show_wind(pos, rand, player)
  if math.random() < rand then
    local random_pos = {
      x = pos.x + generate_offset(5),
      y = pos.y + generate_offset(5),
      z = pos.z + generate_offset(5)
    }
    minetest.add_particle({
          pos = random_pos,
          velocity = {x=wind.x, y=0, z=wind.z},
          expirationtime = 3,
          size = 1,
          texture = "wind.png",
          playername = player,
          glow = 5
      })
    end
end
