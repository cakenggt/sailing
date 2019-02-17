local smoke_key = 'sailing:smoke'
local fire_key = 'sailing:fire'

function destroy_particles(pos)
  local meta = minetest.get_meta(pos)
  local particle_id = meta:get_int(smoke_key)
  if particle_id then
    minetest.delete_particlespawner(particle_id)
  end
  particle_id = meta:get_int(fire_key)
  if particle_id then
    minetest.delete_particlespawner(particle_id)
  end
end

function create_particles(pos)
  local min_vel = wind_to_vec()
  min_vel.x = min_vel.x - 0.5
  min_vel.y = 2
  min_vel.y = min_vel.y - 0.5
  local max_vel = table.copy(min_vel)
  max_vel.x = max_vel.x + 1
  max_vel.y = 3
  max_vel.x = max_vel.x + 1
  local smoke_pos = table.copy(pos)
  smoke_pos.y = smoke_pos.y + 0.2
  local meta = minetest.get_meta(pos)
  local particle_id = minetest.add_particlespawner({
    amount = 10,
    time = 0,
    collisiondetection = true,
    texture = "kukui_torch_smoke.png",
    minsize = 3,
    maxsize = 6,
    minexptime = 5,
    maxexptime = 10,
    minpos = smoke_pos,
    maxpos = smoke_pos,
    minvel = min_vel,
    maxvel = max_vel,
    animation = {
      type = "vertical_frames",
      aspect_w = 16,
      aspect_h = 16,
      length = 1.0,
    }
  })
  meta:set_int(smoke_key, particle_id)

  particle_id = minetest.add_particlespawner({
    amount = 10,
    time = 0,
    collisiondetection = true,
    texture = "kukui_torch_fire.png",
    minsize = 3,
    maxsize = 6,
    minexptime = 0.1,
    maxexptime = 0.2,
    minpos = smoke_pos,
    maxpos = smoke_pos,
    minvel = min_vel,
    maxvel = max_vel,
    glow = 14,
  })
  meta:set_int(fire_key, particle_id)

  local timer = minetest.get_node_timer(pos)
  timer:start(5)

end

minetest.register_node("sailing:kukui_torch", {
  description = "Kukui torch",
  drawtype = "plantlike",
  tiles ={"kukui_torch.png"},
  inventory_image = "kukui_torch.png",
  wield_image = "kukui_torch.png",
  paramtype = "light",
  sunlight_propagates = true,
  is_ground_content = false,
  walkable = false,
  light_source = LIGHT_MAX-1,
  selection_box = {
    type = "fixed",
    fixed = {-0.1, -0.5, -0.1, 0.1, -0.5+0.9, 0.1},
  },
  groups = {choppy=2,dig_immediate=3},
  sounds = default.node_sound_defaults(),
  on_construct = function(pos)
    create_particles(pos)
  end,
  on_timer = function(pos)
    destroy_particles(pos)
    create_particles(pos)
  end,
  on_destruct = function(pos)
    destroy_particles(pos)
  end
})

minetest.register_craft({
  output = "sailing:kukui_torch",
  recipe = {
    {"sailing:kukui_nut"},
    {"default:stick"},
  },
})
