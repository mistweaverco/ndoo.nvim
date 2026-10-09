local CONFIG = require("ndoo.config")
local JSON_CONFIG = CONFIG.get_config_json()
local HELPER = require("ndoo.helper")
local PORTALS = require("ndoo.portals")
local GITHUB = require("ndoo.portals.github")
local GITLAB = require("ndoo.portals.gitlab")
local BITBUCKET = require("ndoo.portals.bitbucket")
local GITEA = require("ndoo.portals.gitea")

local function get_base_repo_url(remote)
  local owner, name, base

  if PORTALS.is_github() then
    owner, name, base = GITHUB.get_github_repo_owner(remote), GITHUB.get_github_repo_name(remote), GITHUB.base_url
  elseif PORTALS.is_gitlab() then
    owner, name, base = GITLAB.get_gitlab_repo_owner(remote), GITLAB.get_gitlab_repo_name(remote), GITLAB.base_url
  elseif PORTALS.is_bitbucket() then
    owner, name, base =
      BITBUCKET.get_bitbucket_repo_owner(remote), BITBUCKET.get_bitbucket_repo_name(remote), BITBUCKET.base_url
  elseif PORTALS.is_gitea() then
    local scheme, host = GITEA.extract_scheme_and_host(GITEA.get_gitea_remote_url(remote))
    if scheme and host then
      base = scheme .. "://" .. host .. "/"
      owner, name = GITEA.get_gitea_repo_owner(remote), GITEA.get_gitea_repo_name(remote)
    end
  end

  if owner and name and base then
    return base .. owner .. "/" .. name
  end

  vim.notify("No supported portal detected", vim.log.levels.ERROR)
  return nil
end

local function open_slug(slug)
  local base_url = get_base_repo_url()
  if base_url == nil then
    return
  end
  HELPER.open_url_in_browser(base_url .. "/" .. slug)
end

local function show_remote_names_picker_and_open_slug(slug)
  if slug == nil then
    slug = ""
  end
  HELPER.show_remote_names_picker(function(remote)
    if remote == nil then
      print("no remote selected")
      return
    end
    local base_url = get_base_repo_url(remote)
    if base_url == nil then
      return
    end
    HELPER.open_url_in_browser(base_url .. "/" .. slug)
  end)
end

local function open_from_visual_selection(commit)
  local line_start = vim.fn.getpos("v")[2]
  local line_end = vim.api.nvim_win_get_cursor(0)[1]
  local filename = vim.fn.expand("%")
  local ref = commit and HELPER.get_current_git_commit_hash() or HELPER.get_current_git_branch()

  local slug
  if PORTALS.is_github() then
    slug = "blob/" .. ref .. "/" .. filename .. "?plain=1#L" .. line_start .. "-L" .. line_end
  elseif PORTALS.is_gitlab() then
    slug = "blob/" .. ref .. "/" .. filename .. "#L" .. line_start .. "-" .. line_end
  elseif PORTALS.is_bitbucket() then
    slug = "src/" .. ref .. "/" .. filename .. "#lines-" .. line_start .. ":" .. line_end
  elseif PORTALS.is_gitea() then
    local kind = commit and "commit/" or "branch/"
    slug = "src/" .. kind .. ref .. "/" .. filename .. "#L" .. line_start .. "-L" .. line_end
  else
    return
  end

  show_remote_names_picker_and_open_slug(slug)
end

local function open_from_normal_mode(commit)
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local filename = vim.fn.expand("%")
  local ref = commit and HELPER.get_current_git_commit_hash() or HELPER.get_current_git_branch()

  local slug
  if PORTALS.is_github() then
    slug = "blob/" .. ref .. "/" .. filename .. "?plain=1#L" .. line
  elseif PORTALS.is_gitlab() then
    slug = "blob/" .. ref .. "/" .. filename .. "#L" .. line
  elseif PORTALS.is_bitbucket() then
    slug = "src/" .. ref .. "/" .. filename .. "#lines-" .. line
  elseif PORTALS.is_gitea() then
    local kind = commit and "commit/" or "branch/"
    slug = "src/" .. kind .. ref .. "/" .. filename .. "#L" .. line
  else
    return
  end

  show_remote_names_picker_and_open_slug(slug)
end

local function prompt_user_for_commit_hash()
  local commit_hash = vim.fn.input("Commit hash: ")
  local branch = nil
  if commit_hash == nil or commit_hash == "" then
    branch = HELPER.get_current_git_branch()
  end

  local path
  if PORTALS.is_github() then
    path = branch and ("commits/" .. branch) or ("commit/" .. commit_hash)
  elseif PORTALS.is_gitlab() then
    path = branch and ("-/commits/" .. branch) or ("-/commit/" .. commit_hash)
  elseif PORTALS.is_bitbucket() then
    path = branch and ("commits/" .. branch) or ("commits/" .. commit_hash)
  elseif PORTALS.is_gitea() then
    path = branch and ("commits/branch/" .. branch) or ("commit/" .. commit_hash)
  else
    return
  end

  show_remote_names_picker_and_open_slug(path)
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
  local function open(prefix)
    return function(n)
      if n == nil then
        print("no pull selected")
        return
      end
      open_slug(prefix .. n)
    end
  end

  if PORTALS.is_github() then
    GITHUB.show_github_pull_picker(open("pull/"))
  elseif PORTALS.is_gitlab() then
    GITLAB.show_gitlab_pull_picker(open("merge_requests/"))
  elseif PORTALS.is_bitbucket() then
    BITBUCKET.show_bitbucket_pull_picker(function(url)
      if url == nil then
        print("no pull selected")
        return
      end
      HELPER.open_url_in_browser(url)
    end)
  elseif PORTALS.is_gitea() then
    GITEA.show_gitea_pull_picker(open("pulls/"))
  end
end

function M.issues()
  local function open_issue(issue_number)
    if issue_number == nil then
      print("no issue selected")
      return
    end
    open_slug("issues/" .. issue_number)
  end

  if PORTALS.is_github() then
    GITHUB.show_github_issues_picker(open_issue)
  elseif PORTALS.is_gitlab() then
    GITLAB.show_gitlab_issues_picker(open_issue)
  elseif PORTALS.is_bitbucket() then
    if JSON_CONFIG.bitbucket_use_jira_issues ~= nil then
      open_slug("jira")
      return
    end
    BITBUCKET.show_bitbucket_issues_picker(open_issue)
  elseif PORTALS.is_gitea() then
    GITEA.show_gitea_issues_picker(open_issue)
  end
end

function M.labels()
  local function open(label_url)
    if label_url == nil then
      print("no label selected")
      return
    end
    HELPER.open_url_in_browser(label_url)
  end

  if PORTALS.is_github() then
    GITHUB.show_github_labels_picker(open)
  elseif PORTALS.is_gitlab() then
    GITLAB.show_gitlab_labels_picker(open)
  elseif PORTALS.is_bitbucket() then
    BITBUCKET.show_bitbucket_labels_picker(open)
  elseif PORTALS.is_gitea() then
    GITEA.show_gitea_labels_picker(open)
  end
end

function M.pipelines()
  if PORTALS.is_github() then
    show_remote_names_picker_and_open_slug("actions")
  elseif PORTALS.is_gitlab() or PORTALS.is_bitbucket() then
    show_remote_names_picker_and_open_slug("pipelines")
  elseif PORTALS.is_gitea() then
    GITEA.show_gitea_pipelines_picker(function(run_id)
      if run_id == nil then
        print("no run selected")
        return
      end
      show_remote_names_picker_and_open_slug("actions/runs/" .. run_id)
    end)
  end
end

function M.commit()
  prompt_user_for_commit_hash()
end

return M
