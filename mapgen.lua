-- https://github.com/paramat/noise23/blob/master/init.lua

local Y_WATER = 1

local ATOLL_WIDTH = 0.2
local ATOLL_START = 0.65

local LAND_MAX = 100
local BIG_ISLAND = 100

function in_atoll_circle(num)
  return num > ATOLL_START
end

-- Number from 0 to 1 which increases linearly as one goes from ATOLL_START or
-- ATOLL_START + ATOLL_WIDTH towards ATOLL_START + (ATOLL_WIDTH/2)
function get_atoll_factor_linear(num)
  if num < ATOLL_START or num > ATOLL_START + ATOLL_WIDTH then
    return 0
  end
  return 1 - math.abs((num - (ATOLL_START + (ATOLL_WIDTH / 2))) / (ATOLL_WIDTH / 2))
end

-- Number from 0 to 1 which increases parabolically as one goes from ATOLL_START or
-- ATOLL_START + ATOLL_WIDTH towards ATOLL_START + (ATOLL_WIDTH/2)
function get_atoll_factor_parabolic(num)
  if num < ATOLL_START or num > ATOLL_START + ATOLL_WIDTH then
    return 0
  end
  return 1 - math.abs((num - (ATOLL_START + (ATOLL_WIDTH / 2))) / (ATOLL_WIDTH / 2))^2
end

minetest.register_on_mapgen_init(function(mgparams)
  minetest.set_mapgen_params({mgname="singlenode", flags="nolight"})
end)

minetest.clear_registered_decorations()
minetest.clear_registered_biomes()
minetest.clear_registered_schematics()

-- between 0 and 1
local np_atoll = {
  offset = 0.5,
  scale = 1/2,
  seed = -188900,
  -- spread = {x=768, y=768, z=768},
  spread = {x=1000, y=1000, z=1000},
  octaves = 1,
  persist = 0.4,
  lacunarity = 2.0,
}

wind.np_atoll = np_atoll
wind.ATOLL_START = ATOLL_START

-- between 0 and 1
local np_island = {
  offset = 0.5,
  scale = 1/4,
  seed = -324588,
  -- spread = {x=768, y=768, z=768},
  spread = {x=50, y=50, z=50},
  octaves = 3,
  persist = 0.4,
  lacunarity = 2.0,
}

local np_atoll_map = nil
local np_island_map = nil

minetest.register_decoration({
  deco_type = "schematic",
  place_on = "default:dirt_with_grass",
  sidelen = 5,
  fill_ratio = 0.01,
  schematic = palm_tree_schematic,
  rotation = 'random',
  flags = {place_center_z = true, place_center_x = true},
})

minetest.register_decoration({
  deco_type = "simple",
  place_on = "default:dirt_with_grass",
  sidelen = 5,
  fill_ratio = 0.01,
  decoration = "sailing:kukui_bush_full",
  flags = {place_center_z = true, place_center_x = true},
})

minetest.register_on_generated(function(minp, maxp, seed)
  local x1 = maxp.x
  local y1 = maxp.y
  local z1 = maxp.z
  local x0 = minp.x
  local y0 = minp.y
  local z0 = minp.z

  local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
  local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
  local data = vm:get_data()

  local c_water = minetest.get_content_id("default:water_source")
  local c_lava = minetest.get_content_id("default:lava_source")
  local c_grass = minetest.get_content_id("default:dirt_with_grass")
  local c_dirt = minetest.get_content_id("default:dirt")
  local c_sand = minetest.get_content_id("default:sand")
  local c_stone = minetest.get_content_id("default:stone")
  local c_shallow_water = minetest.get_content_id("sailing:shallow_water_source")

  local sidelen = x1 - x0 + 1
  local chulens2d = {x=sidelen, y=sidelen}
  local minpos2d = {x=x0, y=z0}

  np_atoll_map = np_atoll_map or minetest.get_perlin_map(np_atoll, chulens2d)
  local nvals_atoll = np_atoll_map:get2dMap_flat(minpos2d)
  np_island_map = np_island_map or minetest.get_perlin_map(np_island, chulens2d)
  local nvals_island = np_island_map:get2dMap_flat(minpos2d)

  local n_index = 1

  for z = z0, z1 do
    for x = x0, x1 do
      local n_atoll = nvals_atoll[n_index]
      local n_island = nvals_island[n_index]
      local atoll_factor = get_atoll_factor_parabolic(n_atoll)
      local in_atoll = in_atoll_circle(n_atoll)
      local solid_level = (n_island * LAND_MAX - LAND_MAX) + (atoll_factor * (LAND_MAX / 2))
      -- central island
      if x < BIG_ISLAND and x > -BIG_ISLAND and z < BIG_ISLAND and z > -BIG_ISLAND then
        solid_level = (n_island * LAND_MAX / 2) * (0.5 - math.abs((math.sqrt(x ^ 2 + z ^ 2) / BIG_ISLAND) - 0.5))
      end

      for y = y0, y1 do
        local block_type = nil
        -- land
        if y < solid_level then
          if y >= Y_WATER then
            -- is not underwater
            if math.abs(y - Y_WATER) < 3 and math.abs(solid_level - Y_WATER) < 3 then
              block_type = c_sand
            elseif (y + 1) >= solid_level then
              -- very top solid block
              block_type = c_grass
            elseif atoll_factor > 0 then
              -- stone only spawns in atolls
              block_type = c_stone
            else
              block_type = c_dirt
            end
          else
            -- is underwater
            if atoll_factor > 0 then
              -- stone only spawns in atolls
              if (y + 1) >= solid_level then
                -- very top solid block
                block_type = c_sand
              else
                block_type = c_stone
              end
            else
              block_type = c_sand
            end
          end
        elseif y < Y_WATER then
          if in_atoll then
            block_type = c_shallow_water
          else
            --water
            block_type = c_water
          end
        end
        if block_type then
          local vi = area:index(x, y, z)
          data[vi] = block_type
        end
      end
      n_index = n_index + 1
    end
  end

  vm:set_data(data)
  minetest.generate_ores(vm)
  minetest.generate_decorations(vm)
  vm:calc_lighting()
  vm:write_to_map(data)
  vm:update_liquids()
end)
