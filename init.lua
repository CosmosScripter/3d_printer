plastic_printer_data={}
blueprint_items = {
price={},
result={}
}

--local storage = minetest.get_mod_storage()

--Functions
local function can_dig(pos, player)--Prevent a loss of items by accident
	local meta = minetest.get_meta(pos);
	local inv = meta:get_inventory()
	if inv:is_empty("main") and inv:is_empty("material") and inv:is_empty("battery") and inv:is_empty("result") then
        return true
    else
        return false
    end
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)--I would actually only let you put the allowed stuff, but it was lagging and crashing the game
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "main" then
		return stack:get_count()
	elseif listname == "material" then
		return stack:get_count()
	elseif listname == "battery" then
        return stack:get_count()
    elseif listname == "result" then
        return 0
	end
end

--Nodebox
local printer_box = {-0.5, -0.5, -0.5, 0.5, -0.42, 0.5}
local printer_box2 = {-0.45, -0.5, -0.45, -0.4, -0.4, -0.4}
local printer_box3 = {0.4, -0.5, -0.45, 0.45, -0.4, -0.4}
local printer_box4 = {-0.45, -0.5, 0.4, -0.4, -0.4, 0.45}
local printer_box5 = {0.4, -0.5, 0.4, 0.45, -0.4, 0.45}
local printer_bar1 = {-0.43, -0.5, 0.4, -0.4, 0.5, 0.43}
local printer_bar2 = {0.4, -0.5, 0.4, 0.43, 0.5, 0.43}
local printer_bar3 = {-0.43, -0.5, -0.43, -0.4, 0.5, -0.4}
local printer_bar4 = {0.4, -0.5, -0.43, 0.43, 0.5, -0.4}
local printer_box_plate = {-0.2, -0.5, -0.2, 0.2, -0.4, 0.2}
local printer_top_box = {-0.5, 0.37, -0.5, 0.5, 0.5, 0.5}
local printer_top_plate = {-0.4, 0.32, -0.4, 0.4, 0.37, 0.4}
local printer_pen = {-0.05, 0.27, -0.05, 0.05, 0.37, 0.05}
--End of nodebox

function plastic_printer_data:register_blueprint(item, description, cost, drawing_image)--If you want to add a drawing image, I recommend using the color #C7CDD2
    if drawing_image ~= nil then
        minetest.register_craftitem(":"..item.."_blueprint", {
	        inventory_image = "printer_blueprint.png^"..drawing_image,
	        description = description.." blueprint\n".."Requires "..cost.." plastic sheet to be printed",--Added this info about plastic cost so people can know how much they need
            stack_max = 1,
            groups = {printer_blueprint=1},
        })
    else
        minetest.register_craftitem(":"..item.."_blueprint", {
	        inventory_image = "printer_blueprint.png",
	        description = description.." blueprint\n".."Requires "..cost.." plastic sheet to be printed",--Fun fact: it took me a while to notice people can't guess the cost
            stack_max = 1,
            groups = {printer_blueprint=1},
        })
    end
    --storage:set_string(item.."_blueprint cost", "basic_materials:plastic_sheet "..cost)
    --storage:set_string(item.."_blueprint item", item)
    blueprint_items.price[item.."_blueprint"] = "basic_materials:plastic_sheet "..cost
    blueprint_items.result[item.."_blueprint"] = item
    minetest.register_craft( {
	    type = "shapeless",
	    output = ":"..item.."_blueprint",
	    recipe = {"3d_printer:blueprint", item},
    })
end

--Items
minetest.register_craftitem(":3d_printer:blueprint", {
	inventory_image = "printer_blueprint.png",
	description = "Blank blueprint",
    stack_max = 1,
    groups = {printer_blueprint=1},
})
minetest.register_tool(":3d_printer:battery", {
	inventory_image = "printer_battery.png",
	description = "Battery",
    stack_max = 1,
    groups = {printer_battery=1},
})

--Crafting
minetest.register_craft( {
	output = "3d_printer:printer",
	recipe = {
		{"basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet"},
		{"default:steel_ingot", "default:mese_crystal_fragment", "default:steel_ingot"},
		{"basic_materials:gear_steel", "basic_materials:plastic_sheet", "basic_materials:gear_steel"}
	}
})
minetest.register_craft( {
	output = "3d_printer:blueprint",
	recipe = {
		{"default:paper", "default:paper", "default:paper"},
		{"default:paper", "dye:blue", "default:paper"},
		{"default:paper", "default:paper", "default:paper"}
	}
})
minetest.register_craft( {
    type = "shapeless",
    output = "3d_printer:battery",
    recipe = {"default:copper_ingot", "default:mese_crystal_fragment"},
})
minetest.register_craft( {
    type = "shapeless",
    output = "default:mese_crystal_fragment",
    recipe = {"3d_printer:battery"},
})

--The printer
minetest.register_node(":3d_printer:printer", {
	description = "3D Printer",
	tiles = {"3d_printer_top.png","3d_printer_bottom.png","3d_printer_side.png","3d_printer_side.png","3d_printer_side.png","3d_printer_side.png"},
	groups = {oddly_breakable_by_hand=1, snappy=1, cracky=1},
	sounds = default_stone_sounds,
	paramtype = "light",
    paramtype2 = "facedir",
	drawtype = "nodebox",
    is_ground_content = false,
	node_box = {
		type = "fixed",--Fun fact: I didn't use any kind of nodebox editor to build this, so it took me about an hour
		fixed = {
                printer_box,
                printer_box2,
                printer_box3,
                printer_box4,
                printer_box5,
                printer_bar1,
                printer_bar2,
                printer_bar3,
                printer_bar4,
                printer_box_plate,
                printer_top_box,
                printer_top_plate,
                printer_pen,
			},
		},
    allow_metadata_inventory_put = allow_metadata_inventory_put,
    can_dig = can_dig,
    on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", "size[8,9]"
			.. default.gui_bg
			.. default.gui_bg_img
			.. default.gui_slots
			.. "label[2.75,0;Blueprint]"
			.. "list[current_name;main;2.5,0.5;1,1;]"
			.. "label[2.75,2;Plastic]"
			.. "list[current_name;material;2.5,2.5;1,1;]"
			.. "image[3.5,0.5;1,1;gui_printer_arrow.png^[transformr270]"
			.. "label[4.75,2;Battery]"
			.. "list[current_name;battery;4.5,2.5;1,1;]"
			.. "label[4.75,0;Output]"
			.. "list[current_name;result;4.5,0.5;1,1;]"
			.. "list[current_player;main;0,5;8,1;]"
			.. "list[current_player;main;0,6.2;8,3;8]")

			local inventory = meta:get_inventory()
			inventory:set_size("main", 1)
			inventory:set_size("material", 1)
			inventory:set_size("battery", 1)
			inventory:set_size("result", 1)
    end,
    on_punch = function(pos, node, puncher)--The original plan was to use a kind of furnance thing, but I don't have experience with formspec and the mod was causing lag
	    local meta = minetest.get_meta(pos)
	    local inv = meta:get_inventory()
        local blueprint_used = inv:get_stack("main", 1):to_table()
        local plastic_used = inv:get_stack("material", 1):to_table()
        local battery = inv:get_stack("battery", 1):to_table()
        if not plastic_used then return end
        local plastic_count = plastic_used.count
        if not inv:is_empty("result") then
            minetest.chat_send_player(puncher:get_player_name(), "Output slot already contains an item")--Avoiding a loss of items 
            return
        end
        --minetest.chat_send_player(puncher:get_player_name(), "working")
        if not battery then return end
        if battery.wear >= 58981.5 then
            minetest.chat_send_player(puncher:get_player_name(), "Battery low")--Batteries wear out when the printer works
            minetest.chat_send_player(puncher:get_player_name(), "Battery replacement needed")
            return
        end
        if not (inv:is_empty("main") or inv:is_empty("material") or inv:is_empty("battery")) then
            --[[local plastic_cost = storage:get_string(blueprint_used.name.." cost")
            local item_result = storage:get_string(blueprint_used.name.." item")
            if not plastic_cost or not item_result then
                minetest.chat_send_player(puncher:get_player_name(), "Blueprint data not found")
                return
            end]]
            --[[if plastic_used.name.." "..plastic_count == plastic_cost then
                 --minetest.chat_send_player(puncher:get_player_name(), "second check")
                if battery.name == "3d_printer:battery" then
                    --minetest.chat_send_player(puncher:get_player_name(), "third check")
                    inv:set_stack("material", 1, "")
                    inv:set_stack("result", 1, item_result)
                    battery.wear = battery.wear + (65535/10)
                    inv:set_stack("battery", 1, battery)
                end
            else
                minetest.chat_send_player(puncher:get_player_name(), plastic_used.name.." "..plastic_count)
                minetest.chat_send_player(puncher:get_player_name(), plastic_cost)--Needs fixing
                minetest.chat_send_player(puncher:get_player_name(), "Lack of plastic/Excessive plastic")
            end]]
            --minetest.chat_send_player(puncher:get_player_name(), "first check")
            --minetest.chat_send_player(puncher:get_player_name(), plastic_used.name)
            if plastic_used.name.." "..plastic_count == blueprint_items.price[blueprint_used.name] then
                 --minetest.chat_send_player(puncher:get_player_name(), "second check")
                if battery.name == "3d_printer:battery" then
                    --minetest.chat_send_player(puncher:get_player_name(), "third check")
                    inv:set_stack("material", 1, "")
                    inv:set_stack("result", 1, blueprint_items.result[blueprint_used.name])
                    battery.wear = battery.wear + (65535/10)
                    inv:set_stack("battery", 1, battery)
                end
            else
                minetest.chat_send_player(puncher:get_player_name(), "Lack of plastic/Excessive plastic")
            end
        end
    end,
})

--Battery blueprint used for testing
--plastic_printer_data:register_blueprint("3d_printer:battery", "Test", "5", nil)
