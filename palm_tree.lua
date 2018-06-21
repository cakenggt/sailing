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
	on_rightclick = (function(pos)
		local node = minetest.get_node(pos)
		while node.name == "sailing:palm_trunk" do
			pos.y = pos.y + 1
			node = minetest.get_node(pos)
		end
		if node.name == "sailing:coconut_spawn" then
			minetest.get_node_timer(pos):start(30)
		end
		for i=1,4 do
			local side = sides[i]
			local newpos = {x = pos.x + side.x, y = pos.y, z = pos.z + side.z}
			if minetest.get_node(newpos).name == "sailing:coconut_block" then
				minetest.spawn_falling_node(newpos)
				return
			end
		end
	end),
})

minetest.register_node("sailing:coconut_spawn", {
	description = "Coconut spawn",
	tiles = {"sailing_coconut_spawn.png"},
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	on_timer = (function(pos, elapsed)
		-- Spawn a coconut on one of the four sides randomly
		local index = math.ceil(math.random() * 4)
		local side = sides[index]
		local newpos = {x = pos.x + side.x, y = pos.y, z = pos.z + side.z}
		if minetest.get_node(newpos).name == "air" then
			minetest.set_node(newpos, {name = "sailing:coconut_block"})
			return
		end
		minetest.get_node_timer(pos).start()
	end),
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
	drop = "sailing:coconut_meat",
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

-- make schematic
palm_tree_schematic = {
	size = {x = 5, y = 5, z = 5},
	data = {
		_, _, _, _, _,
		_, _, _, _, _,
		_, _, _, _, _,
		_, _, _, _, _,
		_, _, _, _, _,

		_, _, _, _, _,
		_, _, _, _, _,
		_, _, _, _, _,
		_, _, _, _, _,
		_, _, C, _, _,

		_, _, T, _, _,
		_, _, T, _, _,
		_, _, T, _, _,
		_, _, T, _, _,
		_, C, S, C, _,

		_, _, _, _, _,
		_, _, _, _, _,
		_, _, _, _, _,
		_, _, _, _, _,
		_, _, C, _, _,

		_, _, _, _, _,
		_, _, _, _, _,
		_, _, _, _, _,
		_, _, _, _, _,
		_, _, _, _, _,
	}
}

-- minetest.register_craftitem() for coconut meat
-- register craftitem for coconut fiber
-- recipe for fiber -> wool
-- meat is food
-- coconut tree sapling recipe
