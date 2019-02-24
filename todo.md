* Fishing
  * Fishing nets that hang in the water (gill nets) and have a chance every second to gain a fish, but also a chance to break and lose all fish. You have to repair if it breaks.
* pili grass generation, growing (abm), and construction of hale
  * Make pili grass like stairs, and have it be 4 possible ways full (one long block in a direction, half block, 3 long blocks in a direction, full block) using paramtype2 = facedir. Look at how stairs does it https://github.com/minetest/minetest/blob/b298b0339c79db7f5b3873e73ff9ea0130f05a8a/games/minimal/mods/stairs/init.lua . Or just have pili grass blocks come in two varieties, stair form and full block (9 grass) form.
* central volcano as source of lava rock of different shapes?
* Lava rocks in different shapes laying around the island as decorations?
  * Lava rocks that fall down when stacked not well. Use either custom falling logic or the `group:falling_node`
* Somehow make the ability to weave fibers into kapa
* Ideas that I would like to do in a relaxing island life game?
* Add `group:attached_node` to torches
* Add tall torches by making a bottom stick block and making a tall torch item and have the top and bottom of the torch check for the opposite on destruction.
* Make pili grass or kapa act as beds. Maybe two in a row can act as a bed? use `beds.on_rightclick` here https://github.com/minetest/minetest_game/blob/master/mods/beds/functions.lua#L140
* Fix trees by rotating the schematic?
* Make kapa crafting make a blank sheet (of the sail texture) and then use dyes to get the various kapa designs
* Make large persistent maps using formspecs and box components for colors. Map blocks are 100x100 and the boxes have fractional sizes and positions to fit them all onto the map.