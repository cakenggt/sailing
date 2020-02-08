local base_table = {
  description = "Lava Rock",
  drawtype = "nodebox",
  paramtype = "light",
  node_box = {
    type = "fixed",
    fixed = {}
  },
  tiles = {"sailing_lava_rock.png"},
  is_ground_content = true,
  groups = {cracky = 1}
}

math.randomseed(24523)

function generate_lava_rock(i)
  local copy = table.copy(base_table)
  local name = "sailing:lava_rock_"..i
  copy["drop"] = {name}
  for j = 1, 3 do
    copy["node_box"]["fixed"][j] = {}
    for k = 1, 3 do
      copy["node_box"]["fixed"][j][k] = -0.25-(math.random()/4)
    end
    for k = 4, 6 do
      copy["node_box"]["fixed"][j][k] = 0.25+(math.random()/4)
    end
  end
  minetest.register_node(name, copy)
end

for i = 1, 4 do generate_lava_rock(i) end

math.randomseed(os.time())
