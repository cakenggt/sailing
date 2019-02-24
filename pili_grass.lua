minetest.register_craftitem("sailing:pili_grass", {
  description = "Pili Grass",
  inventory_image = "sailing_pili_grass.png",
})

minetest.register_node("sailing:pili_grass_growing", {
  description = "Pili Grass Growing",
  drawtype = "plantlike",
  waving = 1,
  tiles = {"sailing_pili_grass_growing.png"},
  inventory_image = "sailing_pili_grass_growing.png",
  wield_image = "sailing_pili_grass_growing.png",
  paramtype = "light",
  sunlight_propagates = true,
  walkable = false,
  buildable_to = true,
  -- flora makes it spread over time
  groups = {snappy = 3, flora = 1, attached_node = 1, grass = 1, flammable = 1},
  sounds = default.node_sound_leaves_defaults(),
  selection_box = {
    type = "fixed",
    fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, -3 / 16, 6 / 16},
  },
  drop = "sailing:pili_grass 3"
})

minetest.register_node("sailing:pili_grass_block", {
  description = "Pili Grass Block",
  tiles = {"sailing_pili_grass_block.png"},
  is_ground_content = false,
  groups = {oddly_breakable_by_hand = 2, flammable = 2},
  sounds = default.node_sound_leaves_defaults(),
  drop = "sailing:pili_grass 9",
})

minetest.register_craft({
  output = "sailing:pili_grass_block",
  type = "shapeless",
  recipe = {
    "sailing:pili_grass", "sailing:pili_grass", "sailing:pili_grass",
    "sailing:pili_grass", "sailing:pili_grass", "sailing:pili_grass",
    "sailing:pili_grass", "sailing:pili_grass", "sailing:pili_grass",
  },
})

stairs.register_stair_and_slab(
  "pili_grass",
  "sailing:pili_grass",
  {oddly_breakable_by_hand = 2, flammable = 2},
  {"sailing_pili_grass_block.png"},
  "Pili Grass Stair",
  "Pili Grass Slab",
  default.node_sound_leaves_defaults()
)