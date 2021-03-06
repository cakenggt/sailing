--
-- Helper functions
--

local function is_water(pos)
  local nn = minetest.get_node(pos).name
  return minetest.get_item_group(nn, "water") ~= 0
end


local function get_sign(i)
  if i == 0 then
    return 0
  else
    return i / math.abs(i)
  end
end


local function get_velocity(v, yaw, y)
  local x = -math.sin(yaw) * v
  local z =  math.cos(yaw) * v
  return {x = x, y = y, z = z}
end


local function get_v(v)
  return math.sqrt(v.x ^ 2 + v.z ^ 2)
end

local sail_attach_pos = {x = 0.5, y = 5, z = 17}

--
-- Boat entity
--

local canoe = {
  physical = true,
  -- Warning: Do not change the position of the collisionbox top surface,
  -- lowering it causes the boat to fall through the world if underwater
  collisionbox = {-0.5, -0.35, -0.5, 0.5, 0.3, 0.5},
  visual = "mesh",
  mesh = "sailing_canoe.obj",
  textures = {"default_wood.png"},

  driver = nil,
  v = 0,
  removed = false,
  sail = nil,
  sail_yaw = 0,
  jumping = false
}

local sail = {
  physical = false,
  visual = "mesh",
  mesh = "sailing_sail.obj",
  textures = {"sail_cloth.png"}
}


function canoe.on_rightclick(self, clicker)
  if not clicker or not clicker:is_player() then
    return
  end
  local name = clicker:get_player_name()
  if self.driver and clicker == self.driver then
    self.driver = nil
    clicker:set_detach()
    default.player_attached[name] = false
    default.player_set_animation(clicker, "stand" , 30)
    local pos = clicker:getpos()
    pos = {x = pos.x, y = pos.y + 0.2, z = pos.z}
    minetest.after(0.1, function()
      clicker:setpos(pos)
    end)
  elseif not self.driver then
    local attach = clicker:get_attach()
    if attach and attach:get_luaentity() then
      local luaentity = attach:get_luaentity()
      if luaentity.driver then
        luaentity.driver = nil
      end
      clicker:set_detach()
    end
    self.driver = clicker
    clicker:set_attach(self.object, "",
      {x = 0, y = 11, z = -3}, {x = 0, y = 0, z = 0})
    default.player_attached[name] = true
    minetest.after(0.2, function()
      default.player_set_animation(clicker, "sit" , 30)
    end)
    clicker:set_look_horizontal(self.object:getyaw())
  end
end


function canoe.on_activate(self, staticdata, dtime_s)
  self.object:set_armor_groups({immortal = 1})
  if staticdata then
    self.v = tonumber(staticdata)
  end
end


function canoe.get_staticdata(self)
  return tostring(self.v)
end


function canoe.on_punch(self, puncher)
  if not puncher or not puncher:is_player() or self.removed then
    return
  end
  if self.driver and puncher == self.driver then
    self.driver = nil
    puncher:set_detach()
    default.player_attached[puncher:get_player_name()] = false
  end
  if not self.driver then
    self.removed = true
    local inv = puncher:get_inventory()
    if not (creative and creative.is_enabled_for
        and creative.is_enabled_for(puncher:get_player_name()))
        or not inv:contains_item("main", "sailing:canoe") then
      local leftover = inv:add_item("main", "sailing:canoe")
      -- if no room in inventory add a replacement boat to the world
      if not leftover:is_empty() then
        minetest.add_item(self.object:getpos(), leftover)
      end
    end
    -- delay remove to ensure player is detached
    minetest.after(0.1, function()
      self.object:remove()
    end)
  end
end


function canoe.toggle_sail(self)
  if self.sail then
    self.sail:remove()
    self.sail = nil
  else
    self:update_sail()
  end
end


function canoe.update_sail(self)
  local sail = self.sail
  if not sail then
    sail = minetest.add_entity(self.object:getpos(), "sailing:sail")
    self.sail = sail
  end
  sail:set_attach(self.object, "",
    sail_attach_pos, {x = 0, y = -math.deg(self.sail_yaw), z = 0})
end


function canoe.on_step(self, dtime)
  local wind_v = calculate_wind(self)
  if self.driver then
    show_wind(self.driver:get_pos(), 0.1, self.driver:get_player_name())
    local ctrl = self.driver:get_player_control()
    local yaw = self.object:getyaw()
    if ctrl.jump and not self.jumping then
      self.jumping = true
      if self.sail then
        -- slow down slowly after removing sail
        self.v = self.v + wind_v
      end
      self:toggle_sail()
    elseif not ctrl.jump and self.jumping then
      self.jumping = false
    end
    if not self.sail then
      if ctrl.up then
        self.v = self.v + 0.1
      elseif ctrl.down then
        self.v = self.v - 0.1
      end
    end
    if ctrl.sneak then
      if self.sail then
        if ctrl.left then
          self.sail_yaw = self.sail_yaw + (1 + dtime) * 0.03
        elseif ctrl.right then
          self.sail_yaw = self.sail_yaw - (1 + dtime) * 0.03
        end
        self:update_sail()
      end
    else
      if ctrl.left then
        self.object:setyaw(yaw + (1 + dtime) * 0.03)
      elseif ctrl.right then
        self.object:setyaw(yaw - (1 + dtime) * 0.03)
      end
    end
  end
  local velo = self.object:getvelocity()
  local s = get_sign(self.v)
  self.v = self.v - 0.02 * s
  if s ~= get_sign(self.v) then
    self.object:setvelocity({x = 0, y = 0, z = 0})
    self.v = 0
    return
  end
  if math.abs(self.v) > 2 then
    self.v = 2 * get_sign(self.v)
  end

  local p = self.object:getpos()
  p.y = p.y - 0.5
  local new_velo
  local new_acce = {x = 0, y = 0, z = 0}
  if not is_water(p) then
    local nodedef = minetest.registered_nodes[minetest.get_node(p).name]
    if (not nodedef) or nodedef.walkable then
      self.v = 0
      new_acce = {x = 0, y = 1, z = 0}
    else
      new_acce = {x = 0, y = -9.8, z = 0}
    end
    new_velo = get_velocity(self.v, self.object:getyaw(),
      self.object:getvelocity().y)
    self.object:setpos(self.object:getpos())
  else
    p.y = p.y + 1
    if is_water(p) then
      local y = self.object:getvelocity().y
      if y >= 5 then
        y = 5
      elseif y < 0 then
        new_acce = {x = 0, y = 20, z = 0}
      else
        new_acce = {x = 0, y = 5, z = 0}
      end
      new_velo = get_velocity(self.v + wind_v, self.object:getyaw(), y)
      self.object:setpos(self.object:getpos())
    else
      new_acce = {x = 0, y = 0, z = 0}
      if math.abs(self.object:getvelocity().y) < 1 then
        local pos = self.object:getpos()
        pos.y = math.floor(pos.y) + 0.5
        self.object:setpos(pos)
        new_velo = get_velocity(self.v + wind_v, self.object:getyaw(), 0)
      else
        new_velo = get_velocity(self.v + wind_v, self.object:getyaw(),
          self.object:getvelocity().y)
        self.object:setpos(self.object:getpos())
      end
    end
  end
  self.object:setvelocity(new_velo)
  self.object:setacceleration(new_acce)
end


minetest.register_entity("sailing:canoe", canoe)
minetest.register_entity("sailing:sail", sail)


minetest.register_craftitem("sailing:canoe", {
  description = "Canoe",
  inventory_image = "canoe_inventory.png",
  wield_image = "canoe_wield.png",
  wield_scale = {x = 2, y = 2, z = 1},
  liquids_pointable = true,
  groups = {flammable = 2},

  on_place = function(itemstack, placer, pointed_thing)
    local under = pointed_thing.under
    local node = minetest.get_node(under)
    local udef = minetest.registered_nodes[node.name]
    if udef and udef.on_rightclick and
        not (placer and placer:is_player() and
        placer:get_player_control().sneak) then
      return udef.on_rightclick(under, node, placer, itemstack,
        pointed_thing) or itemstack
    end

    if pointed_thing.type ~= "node" then
      return itemstack
    end
    if not is_water(pointed_thing.under) then
      return itemstack
    end
    pointed_thing.under.y = pointed_thing.under.y + 0.5
    canoe = minetest.add_entity(pointed_thing.under, "sailing:canoe")
    if canoe then
      if placer then
        canoe:setyaw(placer:get_look_horizontal())
      end
      local player_name = placer and placer:get_player_name() or ""
      if not (creative and creative.is_enabled_for and
          creative.is_enabled_for(player_name)) then
        itemstack:take_item()
      end
    end
    return itemstack
  end,
})

function sail.on_activate(self, staticdata, dtime_s)
  if dtime_s > 0 then
    -- remove sail if the boat was ever unloaded
    self.object:remove()
  end
end


minetest.register_craft({
  output = "sailing:canoe",
  recipe = {
    {"",           "sailing:sail", ""        },
    {"group:wood", "",           "group:wood"},
    {"group:wood", "group:wood", "group:wood"},
  },
})

minetest.register_craft({
  type = "fuel",
  recipe = "sailing:canoe",
  burntime = 20,
})
