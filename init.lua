local f = string.format

m = setmetatable({
	f = f,
}, {
	__index = function(t, k)
		if t == "cs" then
			return ipairs(minetest.registered_craftitems)
		elseif t == "ns" then
			return ipairs(minetest.registered_nodes)
		elseif t == "ts" then
			return ipairs(minetest.registered_tools)
		elseif t == "is" then
			return ipairs(minetest.registered_items)
		elseif t == "ps" then
			return ipairs(minetest.get_connected_players())
		elseif t == "es" then
			return pairs(minetest.luaentities)
		elseif t == "os" then
			return pairs(minetest.object_refs)
		end

		return minetest[k]
	end,
})

m.F = minetest.formspec_escape
m.d = dump

function m.s(key)
	return minetest.settings:get(key)
end

function m.t(who, what, ...)
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

m.has = setmetatable({}, {
	__index = function(t, n)
		return minetest.get_modpath(n)
	end,
})

function m.oia(...)
	return ipairs(minetest.get_objects_in_area(...))
end

function m.oir(...)
	return ipairs(minetest.get_objects_inside_radius(...))
end

m.p2s = minetest.pos_to_string
m.s2p = minetest.string_to_pos

m.v = vector.new

m.x1 = m.v(1, 0, 0)
m.y1 = m.v(0, 1, 0)
m.z1 = m.v(0, 0, 1)

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

function m.gn(pos)
	return minetest.get_node(pos)
end
function m.sn(pos, node)
	return minetest.set_node(pos, node)
end
function m.xn(pos, node)
	return minetest.swap_node(pos, node)
end

function m.ae(pos, name)
	return minetest.add_entity(pos, name)
end
