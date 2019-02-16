local POST_EFFECT_COLOR = "#8DF5FF60"

minetest.register_node("sailing:shallow_water_source", {
  description = "Shallow water",
  drawtype = "liquid",
  tiles = {"sailing_water.png"},
  special_tiles = {
    -- New-style water source material (mostly unused)
    {name = "sailing_water.png", backface_culling = false},
  },
  -- alpha = 160,
  use_texture_alpha = true,
  paramtype = "light",
  walkable = false,
  pointable = false,
  diggable = false,
  buildable_to = true,
  is_ground_content = false,
  drop = "",
  drowning = 1,
  liquidtype = "source",
  liquid_alternative_flowing = "sailing:shallow_water_flowing",
  liquid_alternative_source = "sailing:shallow_water_source",
  liquid_viscosity = 1,
  post_effect_color = POST_EFFECT_COLOR,
  groups = {water = 3, liquid = 3},
})

minetest.register_node("sailing:shallow_water_flowing", {
  description = "Shallow water (flowing)",
  drawtype = "flowingliquid",
  tiles = {"sailing_water.png"},
  special_tiles = {
    {name = "sailing_water.png", backface_culling = false},
    {name = "sailing_water.png", backface_culling = true},
  },
  -- alpha = 160,
  use_texture_alpha = true,
  paramtype = "light",
  paramtype2 = "flowingliquid",
  walkable = false,
  pointable = false,
  diggable = false,
  buildable_to = true,
  is_ground_content = false,
  drop = "",
  drowning = 1,
  liquidtype = "flowing",
  liquid_alternative_flowing = "sailing:shallow_water_flowing",
  liquid_alternative_source = "sailing:shallow_water_source",
  liquid_viscosity = 1,
  post_effect_color = POST_EFFECT_COLOR,
  groups = {water = 3, liquid = 3},
})
