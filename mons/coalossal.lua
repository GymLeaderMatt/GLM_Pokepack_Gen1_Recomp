-- Adds Coalossal (#196) and 9 new moves.
--
-- Its ability, STEAM ENGINE, makes it extremely fast the moment a fire or
-- water move hits it. Two of its moves leave something behind on the other
-- side: TAR SHOT makes the target burn easier, and STEALTH ROCK hurts
-- whatever the opponent sends out next.
local MoveEffects = require("src.battle.MoveEffects")
local TypeChart = require("src.battle.TypeChart")
local BattleState = require("src.battle.BattleState")

return function(mod, shared)

  local who = shared.who

  mod.content.type_chart:register("TAR", { name = "TAR", category = "physical" })
  mod.content.type_chart:register("FIRE>TAR", { multiplier = 20 })

  local function applyTar(b)
    if b.tarred then return false end
    b.tarred = true
    local types = {}
    for i, t in ipairs(b.curTypes) do types[i] = t end
    types[#types + 1] = "TAR"
    b.curTypes = types
    return true
  end

  local function applyHazard(battle, b)
    if not b.hazardPending then return end
    b.hazardPending = nil
    if b.mon.hp <= 0 or battle.result then return end
    local mult = TypeChart.effectiveness("ROCK", b.curTypes)
    if mult == 0 then return end
    local damage = math.max(1, math.floor(b.mon.stats.hp * mult / 80))
    battle:sayNext("Pointed stones dug\ninto " .. who(b) .. "!")
    battle:applyDamage(b, damage)
    if b.mon.hp <= 0 then battle:onFaint(b) end
  end

  local growIn = BattleState.startGrowIn
  BattleState.startGrowIn = function(self, battler)
    growIn(self, battler)
    if battler and battler.hazardPending then
      self:actNext(function() applyHazard(self, battler) end)
    end
  end

  mod.events:on("battle.battler_switched", function(ev)
    local side = ev.battle:sideOf(ev.battler)
    if side and side.hazards and side.hazards.stealthRock then
      ev.battler.hazardPending = true
    end
  end)

  mod.events:on("battle.turn_ended", function(ev)
    applyHazard(ev.battle, ev.battle.player)
    applyHazard(ev.battle, ev.battle.enemy)
  end)

  mod.content.move_effects:register("ROCK_POLISH_EFFECT", {
    kind = "primary",
    run = function(ctx)
      return ctx.changeStage(ctx.user, "speed", 2)
    end,
  })

  mod.content.move_effects:register("TAR_SHOT_EFFECT", {
    kind = "primary",
    accuracyChecked = true,
    run = function(ctx)
      local out = ctx.changeStage(ctx.target, "speed", -1, true)
      if not ctx.target.substituteHP and applyTar(ctx.target) then
        out[#out + 1] = who(ctx.target) .. "\nwas covered in\nsticky tar!"
      end
      return out
    end,
  })

  mod.content.move_effects:register("STEALTH_ROCK_EFFECT", {
    kind = "primary",
    run = function(ctx)
      local side = ctx.side(ctx.target)
      side.hazards = side.hazards or {}
      if side.hazards.stealthRock then
        return { "But, it failed!" }
      end
      side.hazards.stealthRock = true
      return { "Pointed stones float\nin the air around\n" .. who(ctx.target) .. "!" }
    end,
  })

  mod.content.move_effects:register("SMACK_DOWN_EFFECT", {
    kind = "full",
    neverMiss = true,
    afterDamage = function(ctx)
      local target = ctx.target
      target.invulnerable, target.charging, target.chargeReady = nil, nil, nil
      if target.mon.hp <= 0 or target.substituteHP or target.landed then return end
      local flying = false
      for _, t in ipairs(target.curTypes) do
        if t == "FLYING" then flying = true end
      end
      if not flying then return end
      target.landed = true
      ctx.say(who(target) .. "\nfell straight down!")
    end,
  })

  mod.content.moves:register("FLAME_CHARGE", {
    id = "FLAME_CHARGE", name = "FLAME CHARGE",
    type = "FIRE", power = 50, accuracy = 100, pp = 20,
    effect = "NO_ADDITIONAL_EFFECT",
  })

  mod.content.moves:register("SMACK_DOWN", {
    id = "SMACK_DOWN", name = "SMACK DOWN",
    type = "ROCK", power = 50, accuracy = 100, pp = 15,
    effect = "SMACK_DOWN_EFFECT",
  })

  mod.content.moves:register("TAR_SHOT", {
    id = "TAR_SHOT", name = "TAR SHOT",
    type = "ROCK", category = "status",
    power = 0, accuracy = 100, pp = 15,
    effect = "TAR_SHOT_EFFECT",
  })

  mod.content.moves:register("RAPID_SPIN", {
    id = "RAPID_SPIN", name = "RAPID SPIN",
    type = "NORMAL", power = 50, accuracy = 100, pp = 40,
    effect = "NO_ADDITIONAL_EFFECT",
  })

  mod.content.moves:register("ROCK_POLISH", {
    id = "ROCK_POLISH", name = "ROCK POLISH",
    type = "ROCK", category = "status",
    power = 0, accuracy = 100, pp = 20,
    effect = "ROCK_POLISH_EFFECT",
  })

  mod.content.moves:register("ANCIENT_POWER", {
    id = "ANCIENT_POWER", name = "ANCIENTPOWER",
    type = "ROCK", power = 60, accuracy = 100, pp = 5,
    effect = "NO_ADDITIONAL_EFFECT",
  })

  mod.content.moves:register("STEALTH_ROCK", {
    id = "STEALTH_ROCK", name = "STEALTH ROCK",
    type = "ROCK", category = "status",
    power = 0, accuracy = 100, pp = 20,
    effect = "STEALTH_ROCK_EFFECT",
  })

  mod.content.moves:register("ROCK_BLAST", {
    id = "ROCK_BLAST", name = "ROCK BLAST",
    type = "ROCK", power = 25, accuracy = 90, pp = 10,
    effect = "TWO_TO_FIVE_ATTACKS_EFFECT",
  })

  mod.content.moves:register("STONE_EDGE", {
    id = "STONE_EDGE", name = "STONE EDGE",
    type = "ROCK", power = 100, accuracy = 80, pp = 5,
    effect = "NO_ADDITIONAL_EFFECT",
    highCrit = true,
  })

  local ANCIENT_POWER_STATS = { "attack", "defense", "special", "speed" }

  mod.events:on("battle.damage_dealt", function(ev)
    local battle, move, user, target = ev.battle, ev.move, ev.user, ev.target
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

    if move.id == "FLAME_CHARGE" or move.id == "RAPID_SPIN" then
      for _, m in ipairs(MoveEffects.changeStage(battle, user, "speed", 1, false)) do
        battle:sayNext(m)
      end
    end

    if move.id == "ANCIENT_POWER" and battle.rng(0, 255) < 26 then
      for _, stat in ipairs(ANCIENT_POWER_STATS) do
        for _, m in ipairs(MoveEffects.changeStage(battle, user, stat, 1, false)) do
          battle:sayNext(m)
        end
      end
    end
  end)

  mod.hooks:wrap("battle.damage", function(next, ctx)
    local target = ctx.target
    if not (ctx.move and target and target.landed and ctx.move.type == "GROUND") then
      return next(ctx)
    end
    local saved = target.curTypes
    local grounded = {}
    for _, t in ipairs(saved) do
      if t ~= "FLYING" then grounded[#grounded + 1] = t end
    end
    target.curTypes = grounded
    local damage, info = next(ctx)
    target.curTypes = saved
    return damage, info
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
