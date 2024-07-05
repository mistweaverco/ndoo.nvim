local CONFIG = require("ndoo.config")
local JSON_CONFIG = CONFIG.get_config_json()
local HELPER = require("ndoo.helper")
local PORTALS = require("ndoo.portals")
local GITHUB = require("ndoo.portals.github")
local GITLAB = require("ndoo.portals.gitlab")
local BITBUCKET = require("ndoo.portals.bitbucket")

function get_base_repo_url(remote)
  local repo_owner = ""
  local repo_name = ""
  if PORTALS.is_github() then
    repo_owner = GITHUB.get_github_repo_owner(remote)
    repo_name = GITHUB.get_github_repo_name(remote)
    if (repo_owner ~= nil or repo_name ~= nil) then
      return GITHUB.base_url .. repo_owner .. "/" .. repo_name
    end
  elseif PORTALS.is_gitlab() then
    repo_owner = GITLAB.get_gitlab_repo_owner(remote)
    repo_name = GITLAB.get_gitlab_repo_name(remote)
    if (repo_owner ~= nil or repo_name ~= nil) then
      return GITLAB.base_url .. repo_owner .. "/" .. repo_name
    end
  elseif PORTALS.is_bitbucket() then
    repo_owner = BITBUCKET.get_bitbucket_repo_owner(remote)
    repo_name = BITBUCKET.get_bitbucket_repo_name(remote)
    if (repo_owner ~= nil or repo_name ~= nil) then
      return BITBUCKET.base_url .. repo_owner .. "/" .. repo_name
    end
  end
  vim.notify("No supported portal detected", vim.log.levels.ERROR)
  return nil
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
    if PORTALS.is_github() then
      show_remote_names_picker_and_open_slug("blob/" .. branch .. "/" .. filename .. "?plain=1#L" .. line_start .. "-L" .. line_end)
    elseif PORTALS.is_gitlab() then
      show_remote_names_picker_and_open_slug("blob/" .. branch .. "/" .. filename .. "#L" .. line_start .. "-" .. line_end)
    elseif PORTALS.is_bitbucket() then
      show_remote_names_picker_and_open_slug("src/" .. branch .. "/" .. filename .. "#lines-" .. line_start .. ":" .. line_end)
    end
  else
    local commit_hash = HELPER.get_current_git_commit_hash()
    if PORTALS.is_github() then
      show_remote_names_picker_and_open_slug("blob/" .. commit_hash .. "/" .. filename .. "?plain=1#L" .. line_start .. "-L" .. line_end)
    elseif PORTALS.is_gitlab() then
      show_remote_names_picker_and_open_slug("blob/" .. commit_hash .. "/" .. filename .. "#L" .. line_start .. "-" .. line_end)
    elseif PORTALS.is_bitbucket() then
      show_remote_names_picker_and_open_slug("src/" .. commit_hash .. "/" .. filename .. "#lines-" .. line_start .. ":" .. line_end)
    end
  end
end

function open_from_normal_mode(commit)
  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  local filename = vim.fn.expand("%")
  if commit == nil then
    local branch = HELPER.get_current_git_branch()
    if PORTALS.is_github() then
      show_remote_names_picker_and_open_slug("blob/" .. branch .. "/" .. filename .. "?plain=1#L" .. line_number)
    elseif PORTALS.is_gitlab() then
      show_remote_names_picker_and_open_slug("blob/" .. branch .. "/" .. filename .. "#L" .. line_number)
    elseif PORTALS.is_bitbucket() then
      show_remote_names_picker_and_open_slug("src/" .. branch .. "/" .. filename .. "#lines-" .. line_number)
    end
  else
    local commit_hash = HELPER.get_current_git_commit_hash()
    if PORTALS.is_github() then
      show_remote_names_picker_and_open_slug("blob/" .. commit_hash .. "/" .. filename .. "?plain=1#L" .. line_number)
    elseif PORTALS.is_gitlab() then
      show_remote_names_picker_and_open_slug("blob/" .. commit_hash .. "/" .. filename .. "#L" .. line_number)
    elseif PORTALS.is_bitbucket() then
      show_remote_names_picker_and_open_slug("src/" .. commit_hash .. "/" .. filename .. "#lines-" .. line_number)
    end
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
  if PORTALS.is_github() then
    GITHUB.show_github_pull_picker(function(pull_number)
      if (pull_number == nil) then
        print("no pull selected")
        return
      end
      open_slug("pull/" .. pull_number)
    end)
  elseif PORTALS.is_gitlab() then
    GITLAB.show_gitlab_pull_picker(function(pull_number)
      if (pull_number == nil) then
        print("no pull selected")
        return
      end
      open_slug("merge_requests/" .. pull_number)
    end)
  elseif PORTALS.is_bitbucket() then
    BITBUCKET.show_bitbucket_pull_picker(function(pull_number)
      if (pull_number == nil) then
        print("no pull selected")
        return
      end
      open_slug("pull-requests/" .. pull_number)
    end)
  end

end

function M.issues()
  if PORTALS.is_github() then
    GITHUB.show_github_issues_picker(function(issue_number)
      if (issue_number == nil) then
        print("no issue selected")
        return
      end
      open_slug("issues/" .. issue_number)
    end)
  elseif PORTALS.is_gitlab() then
    GITLAB.show_gitlab_issues_picker(function(issue_number)
      if (issue_number == nil) then
        print("no issue selected")
        return
      end
      open_slug("issues/" .. issue_number)
    end)
  elseif PORTALS.is_bitbucket() then
    if JSON_CONFIG.bitbucket_use_jira_issues ~= nil then
      open_slug("jira")
      return
    end
    BITBUCKET.show_bitbucket_issues_picker(function(issue_number)
      if (issue_number == nil) then
        print("no issue selected")
        return
      end
      open_slug("issues/" .. issue_number)
    end)
  end
end

function M.labels()
  if PORTALS.is_github() then
    GITHUB.show_github_labels_picker(function(label_url)
      if (label_url == nil) then
        print("no label selected")
        return
      end
      HELPER.open_url_in_browser(label_url)
    end)
  elseif PORTALS.is_gitlab() then
    GITLAB.show_gitlab_labels_picker(function(label_url)
      if (label_url == nil) then
        print("no label selected")
        return
      end
      HELPER.open_url_in_browser(label_url)
    end)
  elseif PORTALS.is_bitbucket() then
    BITBUCKET.show_bitbucket_labels_picker(function(label_url)
      if (label_url == nil) then
        print("no label selected")
        return
      end
      HELPER.open_url_in_browser(label_url)
    end)
  end
end

function M.pipelines()
  if PORTALS.is_github() then
    show_remote_names_picker_and_open_slug("actions")
  elseif PORTALS.is_gitlab() then
    show_remote_names_picker_and_open_slug("pipelines")
  elseif PORTALS.is_bitbucket() then
    show_remote_names_picker_and_open_slug("pipelines")
  end
end

function M.commit()
  prompt_user_for_commit_hash_and_open_github()
end

return M

