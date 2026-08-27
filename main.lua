-- Every custom Pokemon in one pack. New types load first, then the moves,
-- then the Pokemon themselves. Each type file and each Pokemon has its own
-- on/off switch in the mod manager; the moves are always on. Flip a switch
-- and restart the game to see the change.
return function(mod)

  local function include(rel)
    local source = mod:read(rel)
    if not source then error("glm_pokepack: cannot read " .. rel, 0) end
    local chunk, err = load(source, "@" .. rel)
    if not chunk then error("glm_pokepack: " .. tostring(err), 0) end
    return chunk()
  end

  local shared = include("lib/shared.lua")

  local LAYERS = {
    { dir = "types", toggle = true,  prefix = "types_" },
    { dir = "moves", toggle = false },
    { dir = "mons",  toggle = true,  prefix = "" },
  }

  local plan, rows = {}, {}
  for _, layer in ipairs(LAYERS) do
    for _, name in ipairs(mod:list(layer.dir)) do
      if name:sub(-4) == ".lua" then
        local slug = name:sub(1, -5)
        local key = layer.toggle and (layer.prefix .. slug) or nil
        plan[#plan + 1] = { rel = layer.dir .. "/" .. name, key = key }
        if key then
          rows[#rows + 1] = { key = key, type = "toggle", default = true,
                              label = (slug:upper():gsub("_", " ")) }
        end
      end
    end
  end
  mod.options:define(rows)

  for _, item in ipairs(plan) do
    if item.key == nil or mod.options:get(item.key) ~= false then
      include(item.rel)(mod, shared)
    end
  end

  mod.events:on("mod.options_changed", function(ev)
    if ev.mod == "glm_pokepack" then
      mod.log:info("%s %s -- restart to apply", tostring(ev.key),
        ev.value and "on" or "off")
    end
  end)
end
