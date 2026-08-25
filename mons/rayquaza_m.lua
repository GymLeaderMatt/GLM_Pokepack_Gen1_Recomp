-- Adds Mega Rayquaza (#152) and 4 new moves. Two of the moves change your OWN
-- stats instead of the opponent's, and Dragon Ascent's drop still happens even
-- when the hit knocks the opponent out.
local MoveEffects = require("src.battle.MoveEffects")

return function(mod, shared)

  mod.content.move_effects:register("DRAGON_DANCE_EFFECT", {
    kind = "primary",
    run = function(ctx)
      local m1 = ctx.changeStage(ctx.user, "speed", 1)
      local m2 = ctx.changeStage(ctx.user, "attack", 1)
      return { m1[1], m2[1] }
    end,
  })

  mod.content.moves:register("DRAGON_ASCENT", {
    id = "DRAGON_ASCENT", name = "DRAGON ASCENT",
    type = "FLYING", category = "physical",
    power = 120, accuracy = 100, pp = 5,
    effect = "NO_ADDITIONAL_EFFECT",
  })

  mod.content.moves:register("DRAGON_DANCE", {
    id = "DRAGON_DANCE", name = "DRAGON DANCE",
    type = "DRAGON", category = "status",
    power = 0, accuracy = 100, pp = 20,
    effect = "DRAGON_DANCE_EFFECT",
  })

  mod.content.moves:register("TWISTER", {
    id = "TWISTER", name = "TWISTER",
    type = "DRAGON", category = "special",
    power = 40, accuracy = 100, pp = 20,
    effect = "FLINCH_SIDE_EFFECT1",
  })

  mod.content.moves:register("AIR_SLASH", {
    id = "AIR_SLASH", name = "AIR SLASH",
    type = "FLYING", category = "physical",
    power = 75, accuracy = 95, pp = 15,
    effect = "FLINCH_SIDE_EFFECT1",
  })

  mod.events:on("battle.damage_dealt", function(ev)
    if ev.move and ev.move.id == "DRAGON_ASCENT" then
      for _, m in ipairs(MoveEffects.changeStage(ev.battle, ev.user, "defense", -1, false)) do
        ev.battle:sayNext(m)
      end
      for _, m in ipairs(MoveEffects.changeStage(ev.battle, ev.user, "special", -1, false)) do
        ev.battle:sayNext(m)
      end
    end
  end)

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
