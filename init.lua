local f = string.format

m = setmetatable({
	f = f,
}, {
	__index = function(t, k)
		return minetest[k]
	end
})

m.F = minetest.formspec_escape
m.s = tostring

function m.t(who, what, ...)
	if type(who) == "userdata" then
		who = who:get_player_name()
	end

	minetest.chat_send_player(who, f(what, ...))
end

function m.ta(what, ...)
	minetest.chat_send_all(f(what, ...))
end

m.p = setmetatable({}, {
	__index = function(t, n)
		return minetest.get_player_by_name(n)
	end
})

m.n = setmetatable({}, {
	__index = function(t, n)
		return minetest.registered_nodes[n]
	end
})

m.i = setmetatable({}, {
	__index = function(t, n)
		return minetest.registered_items[n]
	end
})

m.os = minetest.get_objects_in_area

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

if minetest.get_modpath("worldedit") then
	m.p1 = setmetatable({}, {
		__index = function(t, n)
			return worldedit.pos1[n]
		end
	})

	m.p2 = setmetatable({}, {
		__index = function(t, n)
			return worldedit.pos2[n]
		end
	})
end
