-- Load files
local default_path = minetest.get_modpath("sailing")
mod_storage = minetest.get_mod_storage()

dofile(default_path.."/wind.lua")
dofile(default_path.."/canoe.lua")
dofile(default_path.."/mapgen.lua")
