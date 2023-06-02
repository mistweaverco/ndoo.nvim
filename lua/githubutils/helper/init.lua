local telescope_pickers = require "telescope.pickers"
local telescope_finders = require "telescope.finders"
local telescope_conf = require("telescope.config").values
local telescope_actions = require "telescope.actions"
local telescope_action_state = require "telescope.actions.state"
local telescope_themes = require("telescope.themes")
local telescope_theme_dropdown = telescope_themes.get_dropdown{}
local json = require("githubutils.helper.json")
local pickers = require("githubutils.helper.pickers")

local M = {}

function M.show_github_labels_picker(cb_func)
  local jsonstr = vim.fn.system("gh label list --json name,description,url -L 30")
  local pulls = json.parse(jsonstr)

  pickers.generic_table_picker({
    prompt_title = "Pick a label",
    results = pulls,
    entry_maker_value_key = "url",
    entry_maker_display_key = "name",
    entry_maker_ordinal_key = "name",
    previewer_value_key = "description",
    cb_func = cb_func,
  })
end

function M.show_github_pull_picker(cb_func)
  local jsonstr = vim.fn.system("gh pr list --json number,title,body,updatedAt -L 2000")
  local pulls = json.parse(jsonstr)

  pickers.generic_table_picker({
    prompt_title = "Pick a pull",
    results = pulls,
    entry_maker_value_key = "number",
    entry_maker_display_key = "title",
    entry_maker_ordinal_key = "title",
    previewer_value_key = "body",
    cb_func = cb_func,
  })
end

function M.show_github_issues_picker(cb_func)
  local jsonstr = vim.fn.system("gh issue list --json number,title,body,updatedAt -L 2000")
  local issues = json.parse(jsonstr)

  pickers.generic_table_picker({
    prompt_title = "Pick an issue",
    results = issues,
    entry_maker_value_key = "number",
    entry_maker_display_key = "title",
    entry_maker_ordinal_key = "title",
    previewer_value_key = "body",
    cb_func = cb_func,
  })
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
  telescope_pickers.new(telescope_theme_dropdown, {
    prompt_title = "Pick a remote",
    finder = telescope_finders.new_table {
      results = git_remotes,
    },
    sorter = telescope_conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      telescope_actions.select_default:replace(function()
        telescope_actions.close(prompt_bufnr)
        local selection = telescope_action_state.get_selected_entry()
        if selection == nil then
          cb_func(nil)
        else
          cb_func(selection[1])
        end
      end)
      return true
    end,
  }):find()
end

function M.open_url_in_browser(url)
  if vim.fn.has("mac") == 1 then
    vim.fn.system("open " .. url)
  elseif vim.fn.has("unix") == 1 then
    vim.fn.system("xdg-open " .. url)
  elseif vim.fn.has("win32") == 1 then
    vim.fn.system("start " .. url)
  else
    print("Unsupported system")
  end
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
