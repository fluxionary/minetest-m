# m

shortcuts for ad-hoc scripting (e.g. `//lua` or `/snippets`).

please do *not* create other mods which depend on this mod.

```lua
for _, obj in ipairs(minetest.get_objects_in_area(worldedit.pos1.flux, worldedit.pos2.flux)) do
    obj:remove()
end
```

vs.

```lua
for _, obj in ipairs(m.os(m.p1.flux, m.p2.flux)) do
    obj:remove()
end
```
