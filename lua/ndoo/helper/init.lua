local pickers = require("ndoo.helper.pickers")

local M = {}

function M.get_current_git_commit_hash()
  local commit_hash = vim.fn.systemlist("git rev-parse HEAD")[1]
  if commit_hash == "" then
    return nil
  end
  return commit_hash
end

function M.get_current_git_branch()
  local branch = vim.fn.systemlist("git branch --show-current")[1]
  if branch == "" then
    return nil
  end
  return branch
end

function get_git_remote_names()
  local remotes = {}
  local remote_names = vim.fn.systemlist("git remote")
  for _, remote_name in ipairs(remote_names) do
    table.insert(remotes, remote_name)
  end
  return remotes
end

function M.show_remote_names_picker(cb_func)
  local git_remotes = get_git_remote_names()
  if #git_remotes == 1 then
    cb_func(git_remotes[1])
    return
  end
  pickers.generic_table_picker({
    prompt_title = "Pick a remote",
    dropdown = true,
    results = git_remotes,
    cb_func = cb_func,
  })
end

function M.open_url_in_browser(url)
  if vim.fn.has("mac") == 1 then
    vim.fn.system('open "' .. url .. '"')
  elseif vim.fn.has("unix") == 1 then
    vim.fn.system('xdg-open "' .. url .. '"')
  elseif vim.fn.has("win32") == 1 then
    vim.fn.system('start "' .. url .. '"')
  else
    print("Unsupported system")
  end
end

return M
