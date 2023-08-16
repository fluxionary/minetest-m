local f = string.format

m = setmetatable({
	f = f,
}, {
	__index = function(t, k)
		if k == "cs" then
			return minetest.registered_craftitems
		elseif k == "ns" then
			return minetest.registered_nodes
		elseif k == "ts" then
			return minetest.registered_tools
		elseif k == "is" then
			return minetest.registered_items
		elseif k == "ps" then
			return m.iter(minetest.get_connected_players())
		elseif k == "es" then
			return m.iter_values(minetest.luaentities)
		elseif k == "os" then
			return m.iter_values(minetest.object_refs)
		end

		return minetest[k]
	end,
})

function m.iter(t)
	local i = 0
	return function()
		i = i + 1
		return t[i]
	end
end

function m.iter_values(t)
	local k
	return function()
		local v
		k, v = next(t, k)
		return v
	end
end

m.v = vector.new

m.F = minetest.formspec_escape
m.d = dump

if minetest.get_modpath("futil") then
	minetest.register_on_mods_loaded(function()
		if futil.dump then
			m.d = futil.dump
			dump = futil.dump
		end
	end)
end

m.p2s = minetest.pos_to_string
m.s2p = minetest.string_to_pos

m.sn = minetest.set_node
m.xn = minetest.swap_node
m.ae = minetest.add_entity

m.gn = minetest.get_node
m.gm = minetest.get_meta

m.x1 = m.v(1, 0, 0)
m.y1 = m.v(0, 1, 0)
m.z1 = m.v(0, 0, 1)

function m.s(key)
	return minetest.settings:get(key)
end

function m.tp(who, what, ...)
	if type(who) == "userdata" then
		who = who:get_player_name()
	end

	minetest.chat_send_player(who, f(what, ...))
end

function m.ta(what, ...)
	minetest.chat_send_all(f(what, ...))
end

function m.pd(o)
	print(dump(o))
end

m.p = setmetatable({}, {
	__index = function(t, n)
		return minetest.get_player_by_name(n)
	end,
})

m.c = setmetatable({}, {
	__index = function(t, n)
		return minetest.registered_craftitems[n]
	end,
})

m.n = setmetatable({}, {
	__index = function(t, n)
		return minetest.registered_nodes[n]
	end,
})

m.t = setmetatable({}, {
	__index = function(t, n)
		return minetest.registered_tools[n]
	end,
})

m.i = setmetatable({}, {
	__index = function(t, n)
		return minetest.registered_items[n]
	end,
})

m.e = setmetatable({}, {
	__index = function(t, n)
		return minetest.registered_entities[n]
	end,
})

m.has = setmetatable({}, {
	__index = function(t, n)
		return minetest.get_modpath(n)
	end,
})

function m.oia(...)
	return m.iter(minetest.get_objects_in_area(...))
end

function m.oir(...)
	return m.iter(minetest.get_objects_inside_radius(...))
end

function m.up(p, i)
	if not p or type(p) == "number" then
		return m.v(0, p or 1, 0)
	else
		return vector.add(p, m.v(0, i or 1, 0))
	end
end

function m.down(p, i)
	if not p or type(p) == "number" then
		return m.v(0, -(p or 1), 0)
	else
		return vector.add(p, m.v(0, -(i or 1), 0))
	end
end

if m.has.worldedit then
	m.p1 = setmetatable({}, {
		__index = function(t, n)
			return worldedit.pos1[n]
		end,
	})

	m.p2 = setmetatable({}, {
		__index = function(t, n)
			return worldedit.pos2[n]
		end,
	})

	m.ips = setmetatable({}, {
		__index = function(t, n)
			local minp, maxp = vector.sort(worldedit.pos1[n], worldedit.pos2[n])
			local va = VoxelArea:new({ MinEdge = minp, MaxEdge = maxp })
			local i = va:iterp(minp, maxp)
			return function()
				local next = i()
				if next then
					return va:position(next)
				end
			end
		end,
	})
end

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

dofile(modpath .. DIR_DELIM .. "we_2_book.lua")
dofile(modpath .. DIR_DELIM .. "book_2_world.lua")
