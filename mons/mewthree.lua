-- Adds Mewthree (#153), a fusion of Mewtwo and Mew. It learns every TM and HM
-- in the game.
return function(mod, shared)

  mod.content.palettes:register("MTHREEMON", {
    { 255, 255, 255 },
    { 255, 123, 255 },
    { 57, 90, 214 },
    { 0, 0, 0 },
  })

  shared.species(mod, {
    id = "MEWTHREE", name = "MEWTHREE", dex = 153,
    types = { "PSYCHIC_TYPE" },
    baseStats = { hp = 100, attack = 105, defense = 100,
                  speed = 130, special = 154 },
    catchRate = 3, baseExp = 255,
    growthRate = "MEDIUM_SLOW",
    level1Moves = { "PSYCHIC_M", "CONFUSION", "TRANSFORM", "SWIFT" },
    learnset = {
      { level = 63, move = "BARRIER" },
      { level = 66, move = "PSYCHIC_M" },
      { level = 70, move = "RECOVER" },
      { level = 75, move = "MIST" },
      { level = 81, move = "AMNESIA" },
    },
    tmhm = shared.ALL_TMHM,
    palette = "MTHREEMON",
    dexEntry = {
      kind = "FUSION", heightFt = 5, heightIn = 3, weight = 187.4,
      text = "MEW and MEWTWO were\nmade one. Its power\nanswers to no one.",
    },
  })
end
