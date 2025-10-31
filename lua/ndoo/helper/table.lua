local M = {}
--[[
  Function: deep_get(t, path)

  Recursively accesses a value within a nested Lua table 't' using a
  dot-separated string 'path' (e.g., "user.profile.name").

  Args:
    t (table): The starting Lua table.
    path (string): The dot-separated string path to the desired value.

  Returns:
    any: The value found at the specified path, or nil if the path is
         invalid, an intermediate key is missing, or an attempt is made to
         traverse a non-table value.
--]]
M.deep_get = function(t, path)
  -- 1. Split the path string by the dot character.
  -- This uses string.gmatch to find all sequences of characters that are NOT a dot.
  local keys = {}
  for key in string.gmatch(path, "[^%.]+") do
    table.insert(keys, key)
  end

  local current_value = t

  -- 2. Iterate through the keys to traverse the table structure.
  for i, key in ipairs(keys) do
    -- Check if we are trying to access a field on a non-table value.
    -- This covers the case: table.string.next_key
    if i > 1 and type(current_value) ~= "table" then
      -- We cannot go deeper because the current value is not a table.
      return nil
    end

    -- Try to get the next value.
    local next_value = current_value[key]

    if next_value == nil then
      -- If the next key is nil, stop immediately and return nil.
      return nil
    end

    -- Update the current value for the next iteration.
    current_value = next_value
  end

  -- 3. If the loop completes, current_value holds the final result.
  return current_value
end

return M
