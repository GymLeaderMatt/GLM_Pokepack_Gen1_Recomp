-- Mega Rayquaza (#152). Its four moves live in moves/rayquaza_m.lua; what is
-- left here is the mon itself.
return function(mod, shared)

  mod.content.palettes:register("MRAYMON", {
    { 255, 239, 255 },
    { 237, 151, 105 },
    { 99, 166, 141 },
    { 25, 16, 16 },
  })

  shared.species(mod, {
    id = "RAYQUAZA_M", name = "RAYQUAZA M", dex = 152,
    types = { "DRAGON", "FLYING" },
    baseStats = { hp = 105, attack = 180, defense = 100,
                  speed = 115, special = 180 },
    catchRate = 3, baseExp = 255,
    growthRate = "SLOW",
    level1Moves = { "DRAGON_ASCENT", "TWISTER", "AIR_SLASH" },
    learnset = {
      { level = 18, move = "DRAGON_DANCE" },
      { level = 27, move = "BODY_SLAM" },
      { level = 54, move = "REST" },
      { level = 63, move = "FLY" },
    },
    tmhm = shared.ALL_TMHM,
    palette = "MRAYMON",
    dexEntry = {
      kind = "CUSTOM", heightFt = 23, heightIn = 0, weight = 455.3,
      text = "A SURGE OF POWER\ntwisted its form,\nfar beyond RAYQUAZA.",
    },
  })
end
