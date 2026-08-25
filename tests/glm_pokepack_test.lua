-- Checks the whole pack without needing to reach any of it in-game.
-- Run from the engine repo root:
--   lua5.4 mods/glm_pokepack/tests/glm_pokepack_test.lua
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Runtime = require("src.mods.Runtime")
local Data = require("src.core.Data")
Data:load()

local TypeChart = require("src.battle.TypeChart")
TypeChart.load(Data)

local run = T.sdk.loadMod("mods/glm_pokepack", { data = Data })
T.eq(#run.errors, 0, "loads clean (" .. tostring(run.errors[1]) .. ")")

local ray = Data.pokemon.RAYQUAZA_M
local mew = Data.pokemon.MEWTHREE
local coal = Data.pokemon.COALOSSAL

for _, pair in ipairs({ { "RAYQUAZA_M", ray }, { "MEWTHREE", mew },
                        { "COALOSSAL", coal } }) do
  T.check(pair[2] ~= nil, pair[1] .. " merged")
end

T.eq(ray.dex, 152, "Mega Rayquaza is 152")
T.eq(mew.dex, 153, "Mewthree is 153")
T.eq(coal.dex, 196, "Coalossal is 196")
T.check(ray.dex ~= mew.dex and mew.dex ~= coal.dex and ray.dex ~= coal.dex,
  "no two mons in the pack share a dex number")

T.eq(ray.spriteFront, ray.spriteBack, "Rayquaza reuses its front art for the back")
T.check(ray.spriteFront:sub(-15) == "/rayquaza_m.png", "sprite path came from the id")
T.check(mew.spriteFront:sub(-13) == "/mewthree.png", "and for Mewthree")
T.check(coal.spriteFront:sub(-14) == "/coalossal.png", "and for Coalossal")

for _, pair in ipairs({ { "RAYQUAZA_M", ray }, { "MEWTHREE", mew },
                        { "COALOSSAL", coal } }) do
  T.eq(pair[2].trueColor, true, pair[1] .. " keeps its own colors")
  T.eq(pair[2].battleScaleFront, 1, pair[1] .. " front scale defaulted to 1")
  T.eq(pair[2].battleScaleBack, 1, pair[1] .. " back scale defaulted to 1")
  T.eq(#pair[2].evolutions, 0, pair[1] .. " has no evolutions")
end
T.eq(ray.frontSize, 4, "frontSize defaults to 4")
T.eq(coal.frontSize, 7, "and an explicit frontSize still wins")

T.eq(#ray.tmhm, 55, "Rayquaza learns every TM and HM")
T.eq(#mew.tmhm, 55, "so does Mewthree")
T.eq(#coal.tmhm, 29, "Coalossal keeps its own shorter list")
T.check(ray.tmhm ~= mew.tmhm,
  "the two full TM lists are separate tables, not one shared table")
for _, pair in ipairs({ { "RAYQUAZA_M", ray }, { "MEWTHREE", mew },
                        { "COALOSSAL", coal } }) do
  for _, id in ipairs(pair[2].tmhm) do
    T.check(Data.moves[id] ~= nil, pair[1] .. " TM id " .. id .. " exists")
  end
end

for _, pair in ipairs({ { "RAYQUAZA_M", ray }, { "MEWTHREE", mew },
                        { "COALOSSAL", coal } }) do
  T.check(#pair[2].level1Moves <= 4, pair[1] .. " has at most four level-1 moves")
  for _, id in ipairs(pair[2].level1Moves) do
    T.check(Data.moves[id] ~= nil, pair[1] .. " level-1 move " .. id .. " exists")
  end
  for _, row in ipairs(pair[2].learnset) do
    T.check(Data.moves[row.move] ~= nil,
      pair[1] .. " learnset move " .. row.move .. " exists")
  end
end

T.eq(coal.ability, "STEAM_ENGINE", "the ability field rides through the schema")
T.eq(coal.baseStats.special, 90, "Coalossal special is 90")
T.eq(ray.baseStats.attack, 180, "Rayquaza attack is 180")
T.eq(mew.baseStats.speed, 130, "Mewthree speed is 130")

for _, id in ipairs({ "DRAGON_ASCENT", "DRAGON_DANCE", "TWISTER", "AIR_SLASH",
                      "FLAME_CHARGE", "SMACK_DOWN", "TAR_SHOT", "RAPID_SPIN",
                      "ROCK_POLISH", "ANCIENT_POWER", "STEALTH_ROCK",
                      "ROCK_BLAST", "STONE_EDGE" }) do
  T.check(Data.moves[id] ~= nil, id .. " merged")
end

T.eq(TypeChart.category(Data.moves.FLAME_CHARGE.type), "special",
  "Flame Charge is SPECIAL in gen 1 (physical in gen 9)")
T.eq(TypeChart.category(Data.moves.ANCIENT_POWER.type), "physical",
  "Ancient Power is PHYSICAL in gen 1 (special in gen 9)")
T.eq(Data.moves.STONE_EDGE.highCrit, true, "Stone Edge is high-crit")
T.eq(Data.moves.ANCIENT_POWER.name, "ANCIENTPOWER", "no space, so it fits the menu")

T.check(Data.type_chart.types.TAR ~= nil, "the hidden TAR type merged")
local rhydon = Data.pokemon.RHYDON
local plain = TypeChart.effectiveness("FIRE", rhydon.types)
local tarred = {}
for i, t in ipairs(rhydon.types) do tarred[i] = t end
tarred[#tarred + 1] = "TAR"
T.eq(TypeChart.effectiveness("FIRE", tarred), plain * 2,
  "tar doubles FIRE (" .. plain .. " -> " .. plain * 2 .. ")")
T.eq(TypeChart.effectiveness("WATER", tarred),
  TypeChart.effectiveness("WATER", rhydon.types), "tar changes nothing else")

local effect = Data.move_effects.TAR_SHOT_EFFECT
local function battler(name, types, hp)
  return { name = name, isPlayer = true, stages = {},
           def = { types = types }, curTypes = types,
           mon = { hp = hp or 200, stats = { hp = hp or 200 } } }
end
local victim = battler("RHYDON", rhydon.types)
effect.run({
  target = victim, user = battler("COALOSSAL", coal.types),
  changeStage = function(w, s, d)
    w.stages[s] = (w.stages[s] or 0) + d
    return { "stat" }
  end,
})
T.eq(victim.curTypes[3], "TAR", "TAR_SHOT_EFFECT appends the type")
T.eq(#rhydon.types, 2, "the SPECIES type table was not mutated")
T.eq(victim.stages.speed, -1, "and speed dropped a stage")

local function rocks(types, maxhp)
  return math.max(1, math.floor(maxhp * TypeChart.effectiveness("ROCK", types) / 80))
end
T.eq(rocks(Data.pokemon.CHARIZARD.types, 200), 100, "Charizard loses half its HP")
T.eq(rocks(Data.pokemon.ZAPDOS.types, 200), 50, "Zapdos loses a quarter")
T.eq(rocks(Data.pokemon.SNORLAX.types, 200), 25, "a neutral target loses 1/8")
T.eq(rocks(Data.pokemon.MACHAMP.types, 200), 12, "Machamp resists it")
T.eq(rocks(coal.types, 200), 50, "Coalossal itself takes 2x from rocks")
T.eq(rocks(ray.types, 200), 100, "Mega Rayquaza takes 2x as a Flying type")

local function fakeBattle()
  local b = { said = {}, hits = {} }
  b.rng = function() return 0 end
  b.sayNext = function(self, t) table.insert(self.said, t) end
  b.applyDamage = function(self, w, d) w.mon.hp = w.mon.hp - d; return d end
  b.onFaint = function() end
  return b
end

local function hit(target, moveId, moveType, user)
  local battle = fakeBattle()
  Runtime.emit("battle.damage_dealt", {
    battle = battle, move = { id = moveId, type = moveType },
    user = user or battler("FOE", { "NORMAL" }), target = target, damage = 40,
  })
  return battle
end

local function coalBattler()
  local b = battler("COALOSSAL", coal.types, 300)
  b.def.ability = "STEAM_ENGINE"
  return b
end

local water = coalBattler()
local log = hit(water, "SURF", "WATER")
T.eq(water.stages.speed, 6, "a WATER hit gives the full +6")
T.check(log.said[1]:find("STEAM ENGINE", 1, true), "the announcement prints first")
T.check(log.said[2]:find("greatly rose", 1, true), "then the stat line")

local fire = coalBattler()
hit(fire, "FIRE_BLAST", "FIRE")
T.eq(fire.stages.speed, 6, "a FIRE hit triggers it too")

local quake = coalBattler()
hit(quake, "EARTHQUAKE", "GROUND")
T.eq(quake.stages.speed, nil, "a GROUND hit does not")

local maxed = coalBattler()
maxed.stages.speed = 6
local quiet = hit(maxed, "SURF", "WATER")
T.eq(#quiet.said, 0, "at +6 it stays silent instead of saying nothing happened")
T.eq(maxed.stages.speed, 6, "and speed is unchanged")

local golem = battler("GOLEM", Data.pokemon.GOLEM.types, 200)
hit(golem, "SURF", "WATER")
T.eq(golem.stages.speed, nil, "a mon without the ability gets nothing")

local corpse = battler("FOE", { "NORMAL" }, 0)
for _, case in ipairs({ { "FLAME_CHARGE", "FIRE" }, { "RAPID_SPIN", "NORMAL" } }) do
  local user = coalBattler()
  Runtime.emit("battle.damage_dealt", {
    battle = fakeBattle(), move = { id = case[1], type = case[2] },
    user = user, target = corpse, damage = 40,
  })
  T.eq(user.stages.speed, 1, case[1] .. " boosts through a knockout")
end

local ap = coalBattler()
Runtime.emit("battle.damage_dealt", {
  battle = fakeBattle(), move = { id = "ANCIENT_POWER", type = "ROCK" },
  user = ap, target = corpse, damage = 40,
})
T.eq(ap.stages.attack, 1, "Ancient Power raises attack")
T.eq(ap.stages.defense, 1, "and defense")
T.eq(ap.stages.special, 1, "and special")
T.eq(ap.stages.speed, 1, "and speed")

local unlucky = coalBattler()
local high = fakeBattle()
high.rng = function() return 200 end
Runtime.emit("battle.damage_dealt", {
  battle = high, move = { id = "ANCIENT_POWER", type = "ROCK" },
  user = unlucky, target = corpse, damage = 40,
})
T.eq(unlucky.stages.attack, nil, "and it respects the 10% roll")

local ascent = battler("RAYQUAZA M", ray.types, 300)
local drop = fakeBattle()
Runtime.emit("battle.damage_dealt", {
  battle = drop, move = { id = "DRAGON_ASCENT", type = "FLYING" },
  user = ascent, target = corpse, damage = 40,
})
T.eq(ascent.stages.defense, -1, "Dragon Ascent drops defense through a knockout")
T.eq(ascent.stages.special, -1, "and special")

local clean = battler("RAYQUAZA M", ray.types, 300)
Runtime.emit("battle.damage_dealt", {
  battle = fakeBattle(), move = { id = "AIR_SLASH", type = "FLYING" },
  user = clean, target = corpse, damage = 40,
})
T.eq(clean.stages.defense, nil, "another Flying move does not")

local dance = Data.move_effects.DRAGON_DANCE_EFFECT
local dancer = battler("RAYQUAZA M", ray.types, 300)
dance.run({
  user = dancer,
  changeStage = function(w, s, d)
    w.stages[s] = (w.stages[s] or 0) + d
    return { s .. " rose!" }
  end,
})
T.eq(dancer.stages.speed, 1, "Dragon Dance raises the user's own speed")
T.eq(dancer.stages.attack, 1, "and attack")

local zapdos = battler("ZAPDOS", Data.pokemon.ZAPDOS.types, 200)
zapdos.invulnerable, zapdos.charging = true, { id = "FLY" }
Data.move_effects.SMACK_DOWN_EFFECT.afterDamage({ target = zapdos, say = function() end })
T.eq(zapdos.invulnerable, nil, "knocked out of Fly")
T.eq(zapdos.charging, nil, "the charge is cancelled")
T.eq(zapdos.landed, true, "and it is grounded")

local function vanillaDamage(ctx)
  local m = TypeChart.effectiveness(ctx.move.type, ctx.target.curTypes)
  if m == 0 then return 0, { typeMult = 0 } end
  return math.floor(100 * m / 10), { typeMult = m }
end
local function swing(target, moveType)
  return Runtime.call("battle.damage", vanillaDamage,
    { move = { type = moveType }, target = target })
end

T.eq(swing(zapdos, "GROUND"), 100, "Earthquake now lands on the grounded Zapdos")
T.eq(zapdos.curTypes[2], "FLYING", "curTypes was restored after the hook")
T.eq(swing(zapdos, "ROCK"), 200, "Rock still gets its 2x on the Flying type")

local articuno = battler("ARTICUNO", Data.pokemon.ARTICUNO.types, 200)
T.eq(swing(articuno, "GROUND"), 0, "an un-smacked Flying type is still immune")

run.release()
T.finish("glm_pokepack")
