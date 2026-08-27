-- FAIRY, STEEL and DARK, converted from a Gen 1 type_matchups.asm.
--
-- Only the rows that involve the three new types are here. Every vanilla row
-- is already in the chart the engine builds from the ROM, so repeating them
-- would be a duplicate registration, and duplicates are a hard load error.
--
-- Steel is on the modern (Gen 6+) chart: it does NOT resist Ghost or Dark
-- the way it did in Gens 2 through 5, which is what keeps it from running
-- away with the game.
--
-- Multipliers are the engine's x10 scale, the same one the ROM uses:
-- 20 = super effective, 5 = not very effective, 0 = no effect.
return function(mod)

  local chart = mod.content.type_chart

  -- The engine registers every vanilla type and every vanilla matchup before
  -- a single mod runs, so a row that already exists has to say override --
  -- plain register collides and takes the whole pack down with it. Asking
  -- first means this file does not care which rows the dataset already had,
  -- which also makes it safe on a Gold boot, where DARK and STEEL are native.
  local function put(id, value)
    if chart:get(id) ~= nil then
      chart:override(id, value)
    else
      chart:register(id, value)
    end
  end

  -- Gen 1 splits physical from special by TYPE, not per move, so every type
  -- has to pick a side. Steel goes physical, Dark and Fairy special -- where
  -- Gen 2 put the two of these that it had.
  put("STEEL", { name = "STEEL", category = "physical" })
  put("DARK",  { name = "DARK",  category = "special" })
  put("FAIRY", { name = "FAIRY", category = "special" })

  local SUPER, WEAK, NONE = 20, 5, 0

  -- Kept in the asm's own order so the chart reads the same in both files.
  -- Order is not cosmetic here: the engine applies matching rows one at a
  -- time in chart order, flooring after each, exactly like the ROM.
  local ROWS = {
    -- STEEL attacking
    { "STEEL>ICE",           SUPER },
    { "STEEL>ROCK",          SUPER },
    { "STEEL>FAIRY",         SUPER },
    { "STEEL>FIRE",          WEAK },
    { "STEEL>WATER",         WEAK },
    { "STEEL>ELECTRIC",      WEAK },
    { "STEEL>STEEL",         WEAK },
    -- STEEL defending
    { "NORMAL>STEEL",        WEAK },
    { "GRASS>STEEL",         WEAK },
    { "ICE>STEEL",           WEAK },
    { "FLYING>STEEL",        WEAK },
    { "PSYCHIC_TYPE>STEEL",  WEAK },
    { "BUG>STEEL",           WEAK },
    { "ROCK>STEEL",          WEAK },
    { "DRAGON>STEEL",        WEAK },
    { "FAIRY>STEEL",         WEAK },
    { "POISON>STEEL",        NONE },
    { "FIRE>STEEL",          SUPER },
    { "FIGHTING>STEEL",      SUPER },
    { "GROUND>STEEL",        SUPER },
    -- DARK attacking
    { "DARK>PSYCHIC_TYPE",   SUPER },
    { "DARK>GHOST",          SUPER },
    { "DARK>FIGHTING",       WEAK },
    { "DARK>DARK",           WEAK },
    { "DARK>FAIRY",          WEAK },
    -- DARK defending
    { "FIGHTING>DARK",       SUPER },
    { "BUG>DARK",            SUPER },
    { "FAIRY>DARK",          SUPER },
    { "GHOST>DARK",          WEAK },
    { "PSYCHIC_TYPE>DARK",   NONE },
    -- FAIRY attacking
    { "FAIRY>FIGHTING",      SUPER },
    { "FAIRY>DRAGON",        SUPER },
    { "FAIRY>FIRE",          WEAK },
    { "FAIRY>POISON",        WEAK },
    -- FAIRY defending
    { "POISON>FAIRY",        SUPER },
    { "DRAGON>FAIRY",        NONE },
    { "BUG>FAIRY",           WEAK },
    { "FIGHTING>FAIRY",      WEAK },
  }

  for _, row in ipairs(ROWS) do
    put(row[1], { multiplier = row[2] })
  end
end
