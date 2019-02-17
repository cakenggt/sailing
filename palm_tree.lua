local sides = {
  {x = -1, z = 0},
  {x = 1, z = 0},
  {x = 0, z = -1},
  {x = 0, z = 1},
}

minetest.register_node("sailing:palm_trunk", {
  description = "Palm tree trunk",
  tiles = {"sailing_palm_trunk_top.png", "sailing_palm_trunk_top.png", "sailing_palm_trunk.png"},
  is_ground_content = false,
  groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
  sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("sailing:coconut_spawn", {
  description = "Coconut spawn",
  tiles = {"sailing_coconut_spawn.png"},
  is_ground_content = false,
  groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
  sounds = default.node_sound_wood_defaults(),
  on_timer = function(pos, elapsed)
    -- Spawn a coconut on one of the four sides randomly
    local index = math.ceil(math.random() * 4)
    local side = sides[index]
    local newpos = {x = pos.x + side.x, y = pos.y, z = pos.z + side.z}
    if minetest.get_node(newpos).name == "air" then
      minetest.set_node(newpos, {name = "sailing:coconut_block"})
      return
    end
    minetest.get_node_timer(pos):start(30)
  end,
  drop = "sailing:palm_trunk",
})

minetest.register_node("sailing:coconut_block", {
  description = "Coconut block",
  drawtype = "nodebox",
  paramtype = "light",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
      {-0.3, -0.4, -0.3, 0.3, 0.4, 0.3},
      {-0.4, -0.3, -0.4, 0.4, 0.3, 0.4},
    }
  },
  tiles = {"sailing_coconut_spawn.png"},
  is_ground_content = false,
  groups = {tree = 1, choppy = 2, flammable = 2},
  drop = {
    max_items = 3,
    items = {
      {
        items = {"sailing:coconut_meat"},
        rarity = 1,
      },
    },
  },
  on_rightclick = function(pos)
    minetest.spawn_falling_node(pos)
    local near_spawn = minetest.find_node_near(pos, 1, {"sailing:coconut_spawn"})
    if near_spawn then
      minetest.get_node_timer(near_spawn):start(30)
    end
  end,
  on_construct = function(pos)
    minetest.get_node_timer(pos):start(30)
  end,
  on_timer = function(pos)
    if default.can_grow(pos) then
      minetest.set_node(pos, {name="air"})
      minetest.place_schematic(pos, palm_tree_schematic, "random", {}, false, {place_center_x = true})
    end
  end
})

minetest.register_node("sailing:palm_leaf", {
  description = "Palm leaf",
  drawtype = "allfaces_optional",
  waving = 1,
  tiles = {"default_leaves.png"},
  special_tiles = {"default_leaves_simple.png"},
  paramtype = "light",
  is_ground_content = false,
  groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
  drop = {
    max_items = 3,
    items = {
      {
        items = {"sailing:palm_fibers"},
        rarity = 1,
      },
    },
  },
  sounds = default.node_sound_leaves_defaults(),
  after_place_node = default.after_place_leaves,
})

default.register_leafdecay({
  trunks = {"sailing:coconut_spawn", "sailing:palm_trunk"},
  leaves = {"sailing:palm_leaf"},
  radius = 3,
})

local _ = {
  name = "air",
  prob = 0,
}

local T = {
  name = "sailing:palm_trunk",
  force_place = true,
}

local S = {
  name = "sailing:coconut_spawn",
  force_place = true,
}

local C = {
  name = "sailing:coconut_block",
  prob = 100,
}

local L = {
  name = "sailing:palm_leaf",
}

-- make schematic
palm_tree_schematic = {
  size = {x = 9, y = 9, z = 5},
  data = {
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, L, _, _,
    _, _, _, _, _, _, L, _, _,

    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, C, _, _,
    _, _, _, _, _, _, L, _, _,

    _, _, _, _, _, _, _, _, _,
    _, _, _, _, T, _, _, _, _,
    _, _, _, _, T, _, _, _, _,
    _, _, _, _, T, _, _, _, _,
    _, _, _, _, T, T, _, _, _,
    _, _, _, _, _, T, _, _, _,
    _, _, _, _, _, T, T, _, _,
    _, _, _, _, L, C, S, C, L,
    _, _, _, _, L, L, L, L, L,

    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, C, _, _,
    _, _, _, _, _, _, L, _, _,

    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, _, _, _,
    _, _, _, _, _, _, L, _, _,
    _, _, _, _, _, _, L, _, _,
  }
}

minetest.register_craftitem("sailing:coconut_meat", {
  description = "Coconut meat",
  inventory_image = "coconut_meat.png",
  on_use = minetest.item_eat(2),
})

minetest.register_craftitem("sailing:sail", {
  description = "Sail",
  inventory_image = "sailing_sail.png",
})

minetest.register_craftitem("sailing:palm_fibers", {
  description = "Palm Fibers",
  inventory_image = "sailing_palm_fibers.png",
})

minetest.register_craft({
  output = 'default:wood 4',
  recipe = {
    {'sailing:palm_trunk'},
  }
})

minetest.register_craft({
  output = 'sailing:sail',
  type = 'shapeless',
  recipe = {
    "sailing:palm_fibers",
    "sailing:palm_fibers",
    "sailing:palm_fibers",
    "sailing:palm_fibers",
    "sailing:palm_fibers",
    "sailing:palm_fibers",
    "sailing:palm_fibers",
    "sailing:palm_fibers",
    "sailing:palm_fibers",
  }
})

minetest.register_node("sailing:kapa_cloth", {
  description = "Kapa cloth",
  drawtype = "nodebox",
	inventory_image = "sailing_kapa_cloth_icon.png",
	wield_image = "sailing_kapa_cloth_icon.png",
  paramtype = "light",
	paramtype2 = "wallmounted",
  node_box = {
    type = "wallmounted",
    wall_top = {-0.5, 0.4, -0.5, 0.5, 0.5, 0.5},
    wall_bottom = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
    wall_side = {-0.5, -0.5, -0.5, -0.4, 0.5, 0.5},
  },
  sounds = default.node_sound_leaves_defaults(),
  tiles = {"sailing_kapa_cloth.png"},
  is_ground_content = false,
  groups = {flammable = 2, dig_immediate = 2},
})

minetest.register_craft({
  output = "sailing:kapa_cloth",
  recipe = {
    {"sailing:palm_fibers", "sailing:palm_fibers"},
    {"sailing:palm_fibers", "sailing:palm_fibers"},
  },
})
