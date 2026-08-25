-- One pack holding every custom Pokemon. Each one lives in its own file in
-- the mons folder, and this just loads all of them. To add another, drop a
-- file in mons and its picture in assets/sprites. Nothing here changes.
return function(mod)

  local function include(rel)
    local source = mod:read(rel)
    if not source then error("glm_pokepack: cannot read " .. rel, 0) end
    local chunk, err = load(source, "@" .. rel)
    if not chunk then error("glm_pokepack: " .. tostring(err), 0) end
    return chunk()
  end

  local shared = include("lib/shared.lua")

  for _, name in ipairs(mod:list("mons")) do
    if name:sub(-4) == ".lua" then
      include("mons/" .. name)(mod, shared)
    end
  end
end
