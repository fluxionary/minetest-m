local f = string.format

local v_equals = vector.equals
local v_new = vector.new
local v_sort = vector.sort

local function table_is_empty(t)
	return next(t) == nil
end

local function iterate_area(pmin, pmax)
	local area = VoxelArea:new({ MinEdge = pmin, MaxEdge = pmax })
	local i = area:iterp(pmin, pmax)
	return function()
		return area:position(i())
	end
end

local xr = {
	["basic_materials:panel_brass_block"] = "technic:panel_brass_block",
	["basic_materials:stair_brass_block_alt"] = "technic:stair_brass_block_alt",
	["bridger:micro_block_steel_12"] = "bakedclay:micro_dark_grey_12",
	["bridger:panel_block_steel"] = "bakedclay:panel_dark_grey",
	["bridger:slab_block_steel"] = "bakedclay:slab_dark_grey",
	["bridger:suspension_cable_steel"] = "morelights_modern:streetpost_d",
	["building_blocks:hardwood"] = "ebony:wood",
	["building_blocks:panel_hardwood_1"] = "ebony:panel_wood_1",
	["building_blocks:slab_hardwood_1"] = "ebony:slab_wood_1",
	["building_blocks:stair_hardwood"] = "ebony:stair_wood",
	["moreores:micro_silver_block"] = "moreblocks:micro_silver",
	["moreores:panel_silver_block"] = "moreblocks:panel_silver",
	["moreores:slab_silver_block"] = "moreblocks:slab_silver",
	["moreores:stair_silver_block"] = "moreblocks:stair_silver",
	["moreores:stair_silver_block_half"] = "moreblocks:stair_silver_half",
	["moreores:stair_silver_block_inner"] = "moreblocks:stair_silver_inner",
	["moreores:stair_silver_block_outer"] = "moreblocks:stair_silver_outer",
	["quartz:block"] = "yl_nether:ivory",
	["xdecor:iron_lightbox"] = "morelights_vintage:block",
}

local function create_structure(contents, pname, safe)
	local dims, nn_by_id, world = unpack(m.deserialize(m.decompress(m.decode_base64(contents)), true))
	local pmin, pmax = v_sort(m.p1[pname], m.p2[pname])
	local our_dims = v_new(pmax.x - pmin.x + 1, pmax.y - pmin.y + 1, pmax.z - pmin.z + 1)
	if not v_equals(dims, our_dims) then
		if safe then
			error(f("dimensions don't match, must be %s, not %s", m.p2s(dims), m.p2s(our_dims)))
		else
			pmax = v_new(pmin.x + dims.x - 1, pmin.y + dims.y - 1, pmin.z + dims.z - 1)
		end
	end
	local cid_by_id = {}
	local missing = false
	for id, nn in ipairs(nn_by_id) do
		nn = xr[nn] or nn
		if m.n[nn] then
			cid_by_id[id] = minetest.get_content_id(nn)
		else
			missing = true
			cid_by_id[id] = minetest.CONTENT_AIR
			minetest.chat_send_player(pname, f("[m] [WARNING] %s does not exist, will be air", nn))
		end
	end
	if missing and safe then
		error("aborting: node names are missing")
	end

	if safe then
		for p in iterate_area(pmin, pmax) do
			local meta = m.gm(p)
			if not table_is_empty(meta:to_table().fields) then
				error(f("aborting: node @ %s has metadata", m.p2s(p)))
			end
			local inv = meta:get_inventory()
			if not table_is_empty(inv:get_lists()) then
				error(f("aborting: node @ %s has inventory", m.p2s(p)))
			end
		end
	end

	local m_floor = math.floor

	local vm = VoxelManip()
	local vmin, vmax = vm:read_from_map(pmin, pmax)
	local area = VoxelArea:new({ MinEdge = vmin, MaxEdge = vmax })
	local data = vm:get_data()
	local p1s = vm:get_light_data()
	local p2s = vm:get_param2_data()

	local j = 0
	for i in area:iterp(pmin, pmax) do
		j = j + 1
		local v = world[j]
		p1s[i] = v % 256
		v = m_floor(v / 256)
		p2s[i] = v % 256
		v = m_floor(v / 256)
		data[i] = cid_by_id[v]
	end

	vm:set_data(data)
	vm:set_light_data(p1s)
	vm:set_param2_data(p2s)
	vm:write_to_map()
	vm:update_map()
	vm:update_liquids()
end

local function check_call(func, rv_on_fail)
	-- wrap a function w/ logic to avoid crashing the game
	return function(...)
		local rvs = { xpcall(func, debug.traceback, ...) }

		if rvs[1] then
			table.remove(rvs, 1)
			return unpack(rvs)
		else
			futil.log("error", "(check_call): %s args: %s out: %s", dump(debug.getinfo(func)), dump({ ... }), rvs[2])
			return rv_on_fail
		end
	end
end

minetest.register_chatcommand("b2w", {
	func = function(name, param)
		if m.p1[name] == nil or m.p2[name] == nil then
			return false, "need to define a WE area"
		end
		local p = m.p[name]
		local book = p:get_wielded_item()
		if book:get_name() ~= "default:book_written" then
			return false, "must be holding a written book"
		end
		local book_meta = book:get_meta()
		local text = book_meta:get_string("text")
		local start = minetest.get_us_time()
		if check_call(create_structure, "error")(text, name, param ~= "unsafe") == "error" then
			return false, "something went wrong"
		else
			return true, f("area loaded in %ss", (minetest.get_us_time() - start) / 1e6)
		end
	end,
})
