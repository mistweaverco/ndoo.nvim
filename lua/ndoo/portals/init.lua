local M = {}

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


return M
