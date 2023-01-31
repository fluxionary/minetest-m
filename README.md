# m

flux's personal shortcuts for ad-hoc scripting (e.g. via `//lua` or `/snippets`).

please do *not* create other mods which depend on this mod. i will break you.

but feel free to take inspiration to do your own similar thing.

## implementing e.g. `//clearobjects`

```lua
for _, obj in ipairs(minetest.get_objects_in_area(worldedit.pos1.flux, worldedit.pos2.flux)) do
    obj:remove()
end
```

vs.

```lua
for o in m.os(m.p1.flux, m.p2.flux) do
    o:remove()
end
```
