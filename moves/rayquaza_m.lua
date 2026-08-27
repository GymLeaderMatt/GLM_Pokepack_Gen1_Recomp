-- The four moves Mega Rayquaza brought with it: DRAGON ASCENT, DRAGON DANCE,
-- TWISTER and AIR SLASH.
--
-- These live apart from the mon so a second Dragon can learn Dragon Dance
-- without registering it twice, and so switching Rayquaza off does not take
-- four perfectly good moves with it. Nothing here is reachable in game until
-- something learns one, so an unused move costs nothing.
--
-- Dragon Dance changes the USER's stats rather than the target's, and Dragon
-- Ascent's own stat drop still happens when the hit knocks the target out.
local MoveEffects = require("src.battle.MoveEffects")

return function(mod)

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

  -- The drop rides on damage_dealt rather than the move's own effect so it
  -- still lands when the hit was a knockout.
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
end
