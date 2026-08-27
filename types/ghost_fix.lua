-- The Gen 1 Ghost bug, fixed.
--
-- The ROM's own chart lists GHOST vs PSYCHIC as NO_EFFECT, so the two Ghost
-- lines in the game cannot touch the type they were clearly meant to beat.
-- This is the single row that puts it right.
--
-- It sits in its own file, apart from the new types, so that switching those
-- off does not quietly put the bug back. One row, one toggle.
return function(mod)

  local chart = mod.content.type_chart
  local ID = "GHOST>PSYCHIC_TYPE"

  -- The vanilla row is already registered by the engine, so this has to be
  -- an override. Overriding keeps the row in its original chart position;
  -- only the multiplier changes.
  if chart:get(ID) ~= nil then
    chart:override(ID, { multiplier = 20 })
  else
    chart:register(ID, { multiplier = 20 })
  end
end
