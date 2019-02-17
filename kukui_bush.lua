minetest.register_node("sailing:kukui_bush_full", {
  description = "Kukui bush (full)",
  tiles = {"kukui_bush.png"},
  overlay_tiles = {"kukui_nut_overlay.png"},
  drawtype = "allfaces_optional",
  use_texture_alpha = true,
  is_ground_content = false,
  groups = {tree = 1, oddly_breakable_by_hand = 1, flammable = 2, leafy = 1},
  sounds = default.node_sound_wood_defaults(),
  on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
    minetest.set_node(pos, {name = "sailing:kukui_bush_empty"})
    minetest.item_drop(ItemStack("sailing:kukui_nut 2"), clicker, pos)
    minetest.get_node_timer(pos):start(math.random(30, 60))
  end,
  on_timer = function(pos, elapsed)

  end,
  drop = "sailing:kukui_bush_empty",
})

minetest.register_node("sailing:kukui_bush_empty", {
  description = "Kukui bush (empty)",
  tiles = {"kukui_bush.png"},
  drawtype = "allfaces_optional",
  use_texture_alpha = true,
  is_ground_content = false,
  groups = {tree = 1, oddly_breakable_by_hand = 1, flammable = 2, leafy = 1},
  sounds = default.node_sound_wood_defaults(),
  on_timer = function(pos, elapsed)
    minetest.set_node(pos, {name = "sailing:kukui_bush_full"})
  end,
  on_construct = function(pos)
    minetest.get_node_timer(pos):start(math.random(30, 60))
  end,
  drop = "sailing:kukui_bush_empty",
})

minetest.register_craftitem("sailing:kukui_nut", {
  description = "Kukui nut",
  inventory_image = "kukui_nut.png",
  on_use = minetest.item_eat(1),
})
