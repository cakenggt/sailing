local weathervane = {
	physical = true,
	collisionbox = {-0.5, 0, -0.5, 0.5, 3, 0.5},
	visual = "mesh",
	mesh = "sailing_weathervane.obj",
	textures = {"wool_white.png"},
  yaw = 0
}

function weathervane.on_punch(self, puncher)
	if not puncher or not puncher:is_player() or self.removed then
		return
	end
	local inv = puncher:get_inventory()
	if not (creative and creative.is_enabled_for
			and creative.is_enabled_for(puncher:get_player_name()))
			or not inv:contains_item("main", "sailing:weathervane") then
		local leftover = inv:add_item("main", "sailing:weathervane")
		if not leftover:is_empty() then
			minetest.add_item(self.object:getpos(), leftover)
		end
	end
	self.object:remove()
end

function weathervane.on_step(self, dtime)
  if self.yaw == 0 then
    self.yaw = wind.yaw
  end
  local wind_yaw = wind.yaw + ((math.random() * 0.2) - 0.1)
  local new_yaw = self.yaw + (wind_yaw - self.yaw) / 4
  self.yaw = new_yaw
  self.object:set_yaw(new_yaw)
end

minetest.register_craftitem("sailing:weathervane", {
	description = "Weathervane",
	inventory_image = "weathervane_inventory.png",
	wield_image = "weathervane_inventory.png",
	wield_scale = {x = 2, y = 2, z = 1},
	liquids_pointable = false,
	groups = {flammable = 2},

	on_place = function(itemstack, placer, pointed_thing)
    loc = {
      x = pointed_thing.above.x,
      y = pointed_thing.above.y - 0.5,
      z = pointed_thing.above.z,
    }
		entity = minetest.add_entity(loc, "sailing:weathervane")
    entity:set_yaw(wind.yaw)
		if entity then
			local player_name = placer and placer:get_player_name() or ""
			if not (creative and creative.is_enabled_for and
					creative.is_enabled_for(player_name)) then
				itemstack:take_item()
			end
		end
		return itemstack
	end,
})

minetest.register_entity("sailing:weathervane", weathervane)

minetest.register_craft({
	output = "sailing:weathervane",
	recipe = {
		{"", "default:stick", "wool:white"},
		{"", "default:stick", ""          },
		{"", "default:stick", ""          },
	},
})

minetest.register_craft({
	type = "fuel",
	recipe = "sailing:weathervane",
	burntime = 20,
})
