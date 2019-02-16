-- Load files
local default_path = minetest.get_modpath("sailing")
mod_storage = minetest.get_mod_storage()

wind = {}

dofile(default_path.."/util.lua")
dofile(default_path.."/wind.lua")
dofile(default_path.."/commands.lua")
dofile(default_path.."/canoe.lua")
dofile(default_path.."/palm_tree.lua")
dofile(default_path.."/shallow_water.lua")
dofile(default_path.."/mapgen.lua")
dofile(default_path.."/birds.lua")
