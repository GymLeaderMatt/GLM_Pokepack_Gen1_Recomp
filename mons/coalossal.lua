-- Coalossal (#196). Its nine moves live in moves/coalossal.lua; what is left
-- here is the mon itself and the ability that belongs to it.
--
-- STEAM ENGINE makes it extremely fast the moment a fire or water move hits.
local MoveEffects = require("src.battle.MoveEffects")

return function(mod, shared)

  local who = shared.who

  mod.events:on("battle.damage_dealt", function(ev)
    local battle, move, target = ev.battle, ev.move, ev.target
    if not move then return end
    if target.def and target.def.ability == "STEAM_ENGINE"
      and (move.type == "FIRE" or move.type == "WATER")
      and target.mon.hp > 0 and not target.substituteHP
      and (target.stages.speed or 0) < 6 then
      battle:sayNext(who(target) .. "'s\nSTEAM ENGINE!")
      for _, m in ipairs(MoveEffects.changeStage(battle, target, "speed", 6, false)) do
        battle:sayNext(m)
      end
    end
  end)

  mod.content.palettes:register("COALMON", {
    { 255, 255, 255 },
    { 121, 118, 111 },
    { 72, 72, 66 },
    { 0, 0, 0 },
  })

  shared.species(mod, {
    id = "COALOSSAL", name = "COALOSSAL", dex = 196,
    types = { "ROCK", "FIRE" },
    baseStats = { hp = 110, attack = 80, defense = 120,
                  speed = 30, special = 90 },
    catchRate = 45, baseExp = 255,
    growthRate = "MEDIUM_SLOW",
    ability = "STEAM_ENGINE",
    level1Moves = { "FLAME_CHARGE", "SMACK_DOWN", "TAR_SHOT", "RAPID_SPIN" },
    learnset = {
      { level = 15, move = "ROCK_POLISH" },
      { level = 20, move = "ANCIENT_POWER" },
      { level = 37, move = "STEALTH_ROCK" },
      { level = 54, move = "ROCK_BLAST" },
      { level = 63, move = "STONE_EDGE" },
    },
    tmhm = {
      "MEGA_PUNCH", "RAZOR_WIND", "MEGA_KICK", "TOXIC", "BODY_SLAM",
      "TAKE_DOWN", "DOUBLE_EDGE", "HYPER_BEAM", "COUNTER", "SEISMIC_TOSS",
      "RAGE", "SOLARBEAM", "EARTHQUAKE", "DIG", "DOUBLE_TEAM",
      "REFLECT", "BIDE", "METRONOME", "SELFDESTRUCT", "FIRE_BLAST",
      "SWIFT", "SKULL_BASH", "REST", "EXPLOSION", "ROCK_SLIDE",
      "TRI_ATTACK", "SUBSTITUTE", "STRENGTH", "FLASH",
    },
    frontSize = 7,
    palette = "COALMON",
    dexEntry = {
      kind = "COAL", heightFt = 9, heightIn = 2, weight = 684.5,
      text = "A GENTLE GIANT of\ncoal. Harm its mine\nand you will burn.",
    },
  })
end
