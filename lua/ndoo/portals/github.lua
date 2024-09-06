local M = {}
local pickers = require("ndoo.helper.pickers")

M.base_url = "https://github.com/"

function M.show_github_labels_picker(cb_func)
  local jsonstr = vim.fn.system("gh label list --json name,description,url -L 30")
  local pulls = vim.fn.json_decode(jsonstr)

  pickers.generic_table_picker({
    prompt_title = "Pick a label",
    dropdown = true,
    results = pulls,
    entry_maker_value_key = "url",
    entry_maker_display_key = "name",
    entry_maker_ordinal_key = "name",
    cb_func = cb_func,
  })
end

function M.show_github_pull_picker(cb_func)
  local jsonstr = vim.fn.system("gh pr list --json number,title,body,updatedAt -L 2000")
  local pulls = vim.fn.json_decode(jsonstr)

  pickers.generic_table_picker({
    prompt_title = "Pick a pull",
    results = pulls,
    entry_maker_value_key = "number",
    entry_maker_display_key = "title",
    entry_maker_ordinal_key = "title",
    preview = true,
    previewer_value_key = "body",
    cb_func = cb_func,
  })
end

function M.show_github_issues_picker(cb_func)
  local jsonstr = vim.fn.system("gh issue list --json number,title,body,updatedAt -L 2000")
  local issues = vim.fn.json_decode(jsonstr)

  pickers.generic_table_picker({
    prompt_title = "Pick an issue",
    results = issues,
    entry_maker_value_key = "number",
    entry_maker_display_key = "title",
    entry_maker_ordinal_key = "title",
    preview = true,
    previewer_value_key = "body",
    cb_func = cb_func,
  })
end

function M.get_github_remote_url(remote)
  if remote == nil then
    remote = "origin"
  end
  local url = vim.fn.systemlist("git remote get-url " .. remote)[1]
  if url == "" then
    return nil
  end
  return url
end

function M.get_github_repo_protocol()
  local url = M.get_github_remote_url()
  if url:match("^git@") then
    return "ssh"
  end
  if url:match("^https://") then
    return "https"
  end
  return nil
end

function M.get_github_repo_name(remote)
  local url = M.get_github_remote_url(remote)
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

function M.get_github_repo_owner(remote)
  local url = M.get_github_remote_url(remote)
  if url == nil then
    return nil
  end
  local repo_owner = nil
  local repo_protocol = M.get_github_repo_protocol(remote)
  if repo_protocol == "ssh" then
    repo_owner = url:match("^.+:(.+)/.+$")
  end
  if repo_protocol == "https" then
    repo_owner = url:match("^.+/(.+)/.+$")
  end
  return repo_owner
end

return M
