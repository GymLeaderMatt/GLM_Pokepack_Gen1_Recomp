-- Adds Farchamp (#197), a Fighting/Normal fusion of Farfetch'd and Machamp.
return function(mod, shared)

  shared.species(mod, {
    id = "FARCHAMP", name = "FARCHAMP", dex = 197,
    types = { "FIGHTING", "NORMAL" },
    baseStats = { hp = 90, attack = 130, defense = 55,
                  speed = 60, special = 62 },
    catchRate = 3, baseExp = 255,
    growthRate = "MEDIUM_SLOW",
    level1Moves = { "LOW_KICK", "KARATE_CHOP", "LEER", "PECK" },
    learnset = {
      { level = 15, move = "FURY_ATTACK" },
      { level = 20, move = "LOW_KICK" },
      { level = 23, move = "SWORDS_DANCE" },
      { level = 31, move = "AGILITY" },
      { level = 39, move = "SLASH" },
      { level = 52, move = "SUBMISSION" },
    },
    tmhm = {
      "MEGA_PUNCH", "RAZOR_WIND", "SWORDS_DANCE", "WHIRLWIND", "MEGA_KICK",
      "TOXIC", "BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "HYPER_BEAM",
      "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "RAGE", "EARTHQUAKE",
      "FISSURE", "DIG", "MIMIC", "DOUBLE_TEAM", "REFLECT", "BIDE",
      "METRONOME", "FIRE_BLAST", "SWIFT", "SKULL_BASH", "REST",
      "ROCK_SLIDE", "SUBSTITUTE", "CUT", "FLY", "STRENGTH",
    },
    frontSize = 7,
    palette = "BROWNMON",
    dexEntry = {
      kind = "SUPERPOWER", heightFt = 4, heightIn = 11, weight = 112.5,
      text = "It swings its leek\nlike a blade using\nall four mighty arms.",
    },
  })
end
