local HELPER = require("ndoo.helper")
local GITHUB = require("ndoo.github")

function get_base_repo_url(remote)
  local repo_owner = HELPER.get_github_repo_owner(remote)
  local repo_name = HELPER.get_github_repo_name(remote)
  if (repo_owner == nil or repo_name == nil) then
    print("not a github repo")
    return nil
  end
  return GITHUB.base_url .. repo_owner .. "/" .. repo_name
end

function open_slug(slug)
  local base_url = get_base_repo_url()
  if (base_url == nil) then
    return
  end
  HELPER.open_url_in_browser(base_url .. "/" .. slug)
end

function show_remote_names_picker_and_open_slug(slug)
  if (slug == nil) then
    slug = ""
  end
  HELPER.show_remote_names_picker(function(remote)
    if (remote == nil) then
      print("no remote selected")
      return
    end
    local base_url = get_base_repo_url(remote)
    if (base_url == nil) then
      return
    end
    HELPER.open_url_in_browser(base_url .. "/" .. slug)
  end)
end

function open_from_visual_selection(commit)
  local line_start = vim.fn.getpos("v")[2]
  local line_end = vim.api.nvim_win_get_cursor(0)[1]
  local filename = vim.fn.expand("%")
  if commit == nil then
    local branch = HELPER.get_current_git_branch()
    show_remote_names_picker_and_open_slug("blob/" .. branch .. "/" .. filename .. "?plain=1#L" .. line_start .. "-L" .. line_end)
  else
    local commit_hash = HELPER.get_current_git_commit_hash()
    show_remote_names_picker_and_open_slug("blob/" .. commit_hash .. "/" .. filename .. "?plain=1#L" .. line_start .. "-L" .. line_end)
  end
end

function open_from_normal_mode(commit)
  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  local filename = vim.fn.expand("%")
  if commit == nil then
    local branch = HELPER.get_current_git_branch()
    show_remote_names_picker_and_open_slug("blob/" .. branch .. "/" .. filename .. "?plain=1#L" .. line_number)
  else
    local commit_hash = HELPER.get_current_git_commit_hash()
    show_remote_names_picker_and_open_slug("blob/" .. commit_hash .. "/" .. filename .. "?plain=1#L" .. line_number)
  end
end

function prompt_user_for_commit_hash_and_open_github()
  local commit_hash = vim.fn.input("Commit hash: ")
  if (commit_hash == nil or commit_hash == "") then
    local branch = HELPER.get_current_git_branch()
    show_remote_names_picker_and_open_slug("commits/" .. branch)
  else
    show_remote_names_picker_and_open_slug("commit/" .. commit_hash)
  end
end

local M = {}

function M.setup()
  -- just a dummy function,
  -- in case we want to add some setup later
end

function M.open(opts)
  opts = opts or {}
  if opts.v then
    open_from_visual_selection(opts.commit)
  else
    open_from_normal_mode(opts.commit)
  end
end

function M.repo()
  show_remote_names_picker_and_open_slug()
end

function M.pulls()
  HELPER.show_github_pull_picker(function(pull_number)
    if (pull_number == nil) then
      print("no pull selected")
      return
    end
    open_slug("pull/" .. pull_number)
  end)
end

function M.issues()
  HELPER.show_github_issues_picker(function(issue_number)
    if (issue_number == nil) then
      print("no issue selected")
      return
    end
    open_slug("issues/" .. issue_number)
  end)
end

function M.labels()
  HELPER.show_github_labels_picker(function(label_url)
    if (label_url == nil) then
      print("no label selected")
      return
    end
    HELPER.open_url_in_browser(label_url)
  end)
end

function M.actions()
  show_remote_names_picker_and_open_slug("actions")
end

function M.commit()
  prompt_user_for_commit_hash_and_open_github()
end

return M

