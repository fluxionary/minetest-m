local f = string.format

local v_new = vector.new
local v_sort = vector.sort

local function iterate_area(pmin, pmax)
	local area = VoxelArea:new({ MinEdge = pmin, MaxEdge = pmax })
	local i = area:iterp(pmin, pmax)
	return function()
		local j = i()
		if j then
			return area:position(j)
		end
	end
end

function m.get_written_book(pname)
	local pmin, pmax = v_sort(m.p1[pname], m.p2[pname])
	local dims = v_new(pmax.x - pmin.x + 1, pmax.y - pmin.y + 1, pmax.z - pmin.z + 1)

	local nn_by_id = {}
	local id_by_nn = {}
	local function get_id(nn)
		local id = id_by_nn[nn]
		if not id then
			id = #nn_by_id + 1
			nn_by_id[id] = nn
			id_by_nn[nn] = id
		end
		return id
	end

	local world = {}
	local gn = m.get_node

	for p in iterate_area(pmin, pmax) do
		local n = gn(p)
		local id = get_id(n.name)
		world[#world + 1] = n.param1 + 256 * (n.param2 + 256 * id)
	end

	local description = f("%s's build %s", pname, m.p2s(dims))

	local text = m.encode_base64(m.compress(m.serialize({
		dims,
		nn_by_id,
		world,
	})))

	local book = ItemStack("default:book_written")
	local book_meta = book:get_meta()
	book_meta:from_table({
		fields = {
			owner = pname,
			page = 1,
			page_max = 1,
			text = text,
			title = description,
			description = description,
		},
	})

	return book
end

--m.p.flux:set_wielded_item(get_written_book("flux"))
