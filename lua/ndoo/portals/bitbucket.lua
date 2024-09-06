local CONFIG = require("ndoo.config")
local pickers = require("ndoo.helper.pickers")
local USERNAME = nil
local APP_PASSWORD = nil
local REPO_OWNER = nil
local REPO_NAME = nil
-- Path to the config file
local config_path = vim.fn.expand("~/.config/ndoo/config.json")


-- Function to check if a file exists
local function file_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  else
    return false
  end
end

-- Check if the config file exists
if file_exists(config_path) then
  local JSON_CONFIG = CONFIG.get_config_json()
  USERNAME = JSON_CONFIG.bitbucket_username
  APP_PASSWORD = JSON_CONFIG.bitbucket_app_password
end

-- Encode credentials if they exist
local BASE64_CREDS = nil
if USERNAME and APP_PASSWORD then
  BASE64_CREDS = vim.base64.encode(USERNAME .. ":" .. APP_PASSWORD)
end

local M = {}

M.base_url = "https://bitbucket.org/"
M.API_BASE_URL = "https://api.bitbucket.org/2.0/repositories/"

local function get_data(slug)
  if REPO_OWNER == nil then
    REPO_OWNER = M.get_bitbucket_repo_owner()
  end
  if REPO_NAME == nil then
    REPO_NAME = M.get_bitbucket_repo_name()
  end
  local curl_cmd = "curl -s -X GET -H 'Authorization: Basic "
    .. BASE64_CREDS
    .. "' "
    .. M.API_BASE_URL
    .. REPO_OWNER
    .. "/"
    .. REPO_NAME
    .. "/"
    .. slug
  local jsonstr = vim.fn.system(curl_cmd)
  local data = vim.fn.json_decode(jsonstr)
  return data
end

function M.show_bitbucket_labels_picker(cb_func)
  vim.notify("Bitbucket does not support labels", vim.log.levels.ERROR)
end

function M.show_bitbucket_pull_picker(cb_func)
  local pulls = get_data("pullrequests")
  if pulls.error ~= nil then
    vim.notify(pulls.error.message, vim.log.levels.ERROR)
    return
  end
  pickers.generic_table_picker({
    prompt_title = "Pick a pull",
    results = pulls.values,
    entry_maker_value_key = "links.html.href",
    entry_maker_display_key = "title",
    entry_maker_ordinal_key = "title",
    preview = true,
    previewer_value_key = "description",
    cb_func = cb_func,
  })
end

function M.show_bitbucket_issues_picker(cb_func)
  local issues = get_data("issues")
  if issues.error ~= nil then
    vim.notify(issues.error.message, vim.log.levels.ERROR)
    return
  end
  pickers.generic_table_picker({
    prompt_title = "Pick an issue",
    results = issues.values,
    entry_maker_value_key = "links.html.href",
    entry_maker_display_key = "title",
    entry_maker_ordinal_key = "title",
    preview = true,
    previewer_value_key = "content.raw",
    cb_func = cb_func,
  })
end

function M.get_bitbucket_remote_url(remote)
  if remote == nil then
    remote = "origin"
  end
  local url = vim.fn.systemlist("git remote get-url " .. remote)[1]
  if url == "" then
    return nil
  end
  return url
end

function M.get_bitbucket_repo_protocol()
  local url = M.get_bitbucket_remote_url()
  if url:match("^git@") then
    return "ssh"
  end
  if url:match("^https://") then
    return "https"
  end
  return nil
end

function M.get_bitbucket_repo_name(remote)
  local url = M.get_bitbucket_remote_url(remote)
  if url == nil then
    return nil
  end
  local repo_name = url:match("^.+/(.+)$")
  if repo_name == nil then
    return nil
  end
  repo_name = repo_name:gsub("%.git$", "")
  return repo_name
end

function M.get_bitbucket_repo_owner(remote)
  local url = M.get_bitbucket_remote_url(remote)
  if url == nil then
    return nil
  end
  local repo_owner = nil
  local repo_protocol = M.get_bitbucket_repo_protocol(remote)
  if repo_protocol == "ssh" then
    repo_owner = url:match("^.+:(.+)/.+$")
  end
  if repo_protocol == "https" then
    repo_owner = url:match("^.+/(.+)/.+$")
  end
  return repo_owner
end

return M
