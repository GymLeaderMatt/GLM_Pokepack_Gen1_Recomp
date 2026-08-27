-- Bits every Pokemon in the pack can reuse: the full TM and HM list, a helper
-- for naming a battler in a message, and one function that registers a new
-- species along with its picture, menu icon and cry.
local Shared = {}

Shared.ALL_TMHM = {
  "MEGA_PUNCH", "RAZOR_WIND", "SWORDS_DANCE", "WHIRLWIND", "MEGA_KICK",
  "TOXIC", "HORN_DRILL", "BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE",
  "BUBBLEBEAM", "WATER_GUN", "ICE_BEAM", "BLIZZARD", "HYPER_BEAM",
  "PAY_DAY", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "RAGE",
  "MEGA_DRAIN", "SOLARBEAM", "DRAGON_RAGE", "THUNDERBOLT", "THUNDER",
  "EARTHQUAKE", "FISSURE", "DIG", "PSYCHIC_M", "TELEPORT",
  "MIMIC", "DOUBLE_TEAM", "REFLECT", "BIDE", "METRONOME",
  "SELFDESTRUCT", "EGG_BOMB", "FIRE_BLAST", "SWIFT", "SKULL_BASH",
  "SOFTBOILED", "DREAM_EATER", "SKY_ATTACK", "REST", "THUNDER_WAVE",
  "PSYWAVE", "EXPLOSION", "ROCK_SLIDE", "TRI_ATTACK", "SUBSTITUTE",
  "CUT", "FLY", "SURF", "STRENGTH", "FLASH",
}

function Shared.who(b)
  return b.isPlayer and b.name or ("Enemy " .. b.name)
end

function Shared.species(mod, def)
  -- A mon is only as loadable as its typing. If it names a type that is not
  -- in the chart -- almost always because the types layer that adds it was
  -- switched off -- skip the whole species and say why, rather than
  -- registering something whose type nothing can resolve.
  for _, t in ipairs(def.types or {}) do
    if mod.content.type_chart:get(t) == nil then
      mod.log:warn("%s needs the %s type, which is not loaded -- skipped",
        def.id, t)
      return nil
    end
  end

  local icon = def.icon or "MON"
  local cry = def.cry or "PIDGEY"
  def.icon, def.cry = nil, nil

  local slug = def.id:lower()
  def.spriteFront = def.spriteFront
    or (mod.path .. "/assets/sprites/" .. slug .. ".png")
  def.spriteBack = def.spriteBack or def.spriteFront

  if def.frontSize == nil then def.frontSize = 4 end
  if def.trueColor == nil then def.trueColor = true end
  if def.battleScaleFront == nil then def.battleScaleFront = 1 end
  if def.battleScaleBack == nil then def.battleScaleBack = 1 end
  if def.evolutions == nil then def.evolutions = {} end

  if def.tmhm then
    local list = {}
    for i, id in ipairs(def.tmhm) do list[i] = id end
    def.tmhm = list
  end

  mod.content.pokemon:register(def.id, def)
  mod.content.icons:register(def.id, icon)
  mod.content.cries:register(def.id, { base = cry })
  return def
end

return Shared
