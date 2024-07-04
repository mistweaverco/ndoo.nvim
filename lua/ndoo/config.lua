local M = {}
local DEFAULT_CONFIG = {}
local UV = vim.loop

local function get_os_path_separator()
  if vim.fn.has("win32") == 1 then
    return "\\"
  else
    return "/"
  end
end

M.PS = get_os_path_separator()

M.get_config = function()
  return config
end

M.set_config = function(config)
  config = config or {}
  config = vim.tbl_deep_extend("force", DEFAULT_CONFIG, config)
end

M.get_config_dir = function()
  local config_dir = vim.fn.stdpath("config")
  return config_dir:match("(.*)" .. M.PS .. ".*") .. M.PS .. "ndoo"
end

M.get_config_json = function()
  local config_dir = M.get_config_dir()
  local config_file = config_dir .. M.PS .. "config.json"
  local config = {}
  if vim.fn.filereadable(config_file) == 1 then
    local file = io.open(config_file, "r")
    local content = file:read("*a")
    config = vim.fn.json_decode(content)
    file:close()
  end
  return config
end

return M
