local M = {}

local CONFIG = require("ndoo.config")

local function get_git_remote_url(remote)
  if remote == nil then
    remote = "origin"
  end
  local url = vim.fn.systemlist("git remote get-url " .. remote)[1]
  if url == "" then
    return nil
  end
  return url
end

M.is_bitbucket = function()
  local remote_url = get_git_remote_url()
  if remote_url == nil then
    return false
  end
  return remote_url:match("bitbucket.org") ~= nil
end

M.is_gitlab = function()
  local remote_url = get_git_remote_url()
  if remote_url == nil then
    return false
  end
  return remote_url:match("gitlab.com") ~= nil
end

M.is_github = function()
  local remote_url = get_git_remote_url()
  if remote_url == nil then
    return false
  end
  return remote_url:match("github.com") ~= nil
end

M.is_gitea = function()
  local remote_url = get_git_remote_url()
  if remote_url == nil then
    return false
  end

  -- Extract host from ssh (git@host:owner/repo, ssh://git@host/owner/repo)
  -- or https (https://host/owner/repo) remotes.
  local host = remote_url:match("^[%w_%.%-]+@([^:/]+)")
    or remote_url:match("^ssh://[^@]+@([^:/]+)")
    or remote_url:match("^https?://([^:/]+)")

  if host == nil then
    return false
  end
  host = host:lower()

  -- 1) Well-known public instances.
  if host == "codeberg.org" or host == "gitea.com" or host == "forgejo.org" then
    return true
  end

  -- 2) Hostname heuristic: git.* is almost always a self-hosted forge.
  if host:match("^git%.") then
    return true
  end

  -- 3) Explicit enterprise hosts from config.json.
  local json = CONFIG.get_config_json() or {}
  for _, entry in ipairs(json.gitea_hosts or {}) do
    entry = entry:lower()
    if host == entry or host:match("%." .. vim.pesc(entry) .. "$") then
      return true
    end
  end

  return false
end

return M
