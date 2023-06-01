local Helper = require("githubutils.helper")
local Github = require("githubutils.github")

function get_base_repo_url(remote)
  local repo_owner = Helper.get_github_repo_owner(remote)
  local repo_name = Helper.get_github_repo_name(remote)
  if (repo_owner == nil or repo_name == nil) then
    print("not a github repo")
    return nil
  end
  return Github.base_url .. repo_owner .. "/" .. repo_name
end

function show_remote_names_picker_and_open_slug(slug)
  if (slug == nil) then
    slug = ""
  end
  Helper.show_remote_names_picker(function(remote)
    if (remote == nil) then
      print("no remote selected")
      return
    end
    local base_url = get_base_repo_url(remote)
    if (base_url == nil) then
      return
    end
    Helper.open_url_in_browser(base_url .. "/" .. slug)
  end)
end

local M = {}

function M.setup()
  -- just a dummy function,
  -- in case we want to add some setup later
end

function M.open()
  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  local filename = vim.fn.expand("%")
  local branch = Helper.get_current_git_branch()
  show_remote_names_picker_and_open_slug("blob/" .. branch .. "/" .. filename .. "?plain=1#L" .. line_number)
  print(vim.inspect(filename))
end

function M.repo()
  show_remote_names_picker_and_open_slug()
end

function M.pulls()
  show_remote_names_picker_and_open_slug("pulls")
end

function M.issues()
  show_remote_names_picker_and_open_slug("issues")
end

function M.actions()
  show_remote_names_picker_and_open_slug("actions")
end

return M

