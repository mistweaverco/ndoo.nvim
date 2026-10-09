local pickers = require("ndoo.helper.pickers")

local M = {}

-- ---------------------------------------------------------------------------
-- Host / URL helpers
-- ---------------------------------------------------------------------------

local function extract_scheme_and_host(url)
  if url == nil then
    return nil, nil
  end
  local scheme, host = url:match("^(https?)://([^/]+)")
  if scheme and host then
    return scheme, host
  end
  host = url:match("^[%w_%.%-]+@([^:/]+)") or url:match("^ssh://[^@]*@([^:/]+)")
  return "https", host
end

local function extract_host(url)
  local _, host = extract_scheme_and_host(url)
  return host
end

M.extract_scheme_and_host = extract_scheme_and_host
M.extract_host = extract_host

function M.get_gitea_remote_url(remote)
  if remote == nil then
    remote = "origin"
  end
  local url = vim.fn.systemlist("git remote get-url " .. remote)[1]
  if url == nil or url == "" then
    return nil
  end
  return url
end

function M.get_gitea_repo_protocol(remote)
  local url = M.get_gitea_remote_url(remote)
  if url == nil then
    return nil
  end
  if url:match("^git@") or url:match("^ssh://") then
    return "ssh"
  end
  if url:match("^https?://") then
    return "https"
  end
  return nil
end

function M.get_gitea_repo_name(remote)
  local url = M.get_gitea_remote_url(remote)
  if url == nil then
    return nil
  end
  local name = url:match("^.+/(.+)$")
  if name == nil then
    return nil
  end
  return name:gsub("%.git$", "")
end

function M.get_gitea_repo_owner(remote)
  local url = M.get_gitea_remote_url(remote)
  if url == nil then
    return nil
  end
  local proto = M.get_gitea_repo_protocol(remote)
  if proto == "ssh" then
    return url:match("[:/]([^/]+)/[^/]+$")
  elseif proto == "https" then
    return url:match("^.+/(.+)/.+$")
  end
  return nil
end

local function repo_web_base()
  local scheme, host = extract_scheme_and_host(M.get_gitea_remote_url())
  if host == nil then
    return nil
  end
  local owner = M.get_gitea_repo_owner()
  local name = M.get_gitea_repo_name()
  if owner == nil or name == nil then
    return nil
  end
  return scheme .. "://" .. host .. "/" .. owner .. "/" .. name
end

-- ---------------------------------------------------------------------------
-- Backend detection and unified command layer
-- ---------------------------------------------------------------------------

-- Detected once on first use: "tea", "fj", or false.
local backend = nil

local function detect_backend()
  if backend ~= nil then
    return backend
  end
  -- Prefer tea: it works with both Gitea and Forgejo and supports
  -- --output json. The fj branch below is a placeholder for when
  -- forgejo-contrib/fj implements structured output (currently an open
  -- feature request). Until then, if only fj is installed, its commands
  -- will fail at parse time with "unrecognized subcommand" or similar.
  if vim.fn.executable("tea") == 1 then
    backend = "tea"
  elseif vim.fn.executable("fj") == 1 then
    backend = "fj"
  else
    backend = false
  end
  return backend
end

-- Run the backend CLI and decode JSON. Returns nil on failure, {} on empty.
local function cli_json(cmd)
  local out = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Command failed: " .. cmd .. "\n" .. out, vim.log.levels.ERROR)
    return nil
  end

  -- tea sometimes prints human-readable status ("No workflow runs found")
  -- with exit 0. Anything that doesn't start with [ or { is not JSON —
  -- treat it as an empty result rather than an error.
  local trimmed = out:gsub("^%s+", ""):gsub("%s+$", "")
  if trimmed == "" or not (trimmed:sub(1, 1) == "[" or trimmed:sub(1, 1) == "{") then
    return {}
  end

  local ok, decoded = pcall(vim.fn.json_decode, trimmed)
  if not ok or decoded == nil then
    vim.notify("Command returned invalid JSON: " .. cmd .. "\n" .. out, vim.log.levels.ERROR)
    return nil
  end
  return decoded
end

-- Fetch a list, normalizing field names so pickers don't care which CLI ran.
local function fetch(kind)
  local be = detect_backend()
  if be == false then
    vim.notify("Neither 'fj' nor 'tea' found in PATH", vim.log.levels.ERROR)
    return nil
  end

  local cmd, number_key
  if kind == "pulls" then
    cmd = be == "fj" and "fj pr list --json" or "tea pulls list --state open --output json"
    number_key = be == "fj" and "number" or "index"
  elseif kind == "issues" then
    cmd = be == "fj" and "fj issue list --json" or "tea issues list --state open --output json"
    number_key = be == "fj" and "number" or "index"
  elseif kind == "labels" then
    cmd = be == "fj" and "fj repo label list --json" or "tea labels list --output json"
  elseif kind == "pipelines" then
    cmd = be == "fj" and "fj actions --json" or "tea actions runs list --output json"
  else
    return nil
  end

  local data = cli_json(cmd)
  if data == nil then
    return nil
  end

  -- Normalize: expose a `number` field for pulls/issues regardless of backend.
  if number_key and number_key ~= "number" then
    for _, item in ipairs(data) do
      item.number = item[number_key]
    end
  end

  return data
end

-- ---------------------------------------------------------------------------
-- Labels
-- ---------------------------------------------------------------------------

function M.show_gitea_labels_picker(cb_func)
  local labels = fetch("labels")
  if labels == nil then
    return
  end
  if #labels == 0 then
    vim.notify("No labels found", vim.log.levels.INFO)
    return
  end

  local base = repo_web_base()
  if base == nil then
    vim.notify("Could not derive Gitea repo URL from remote", vim.log.levels.ERROR)
    return
  end

  for _, label in ipairs(labels) do
    label.url = base .. "/labels?q=" .. vim.fn.escape(label.name, " ")
  end

  pickers.generic_table_picker({
    prompt_title = "Pick a label",
    results = labels,
    entry_maker_value_key = "url",
    entry_maker_display_key = "name",
    entry_maker_ordinal_key = "name",
    cb_func = cb_func,
  })
end

-- ---------------------------------------------------------------------------
-- Pull requests
-- ---------------------------------------------------------------------------

function M.show_gitea_pull_picker(cb_func)
  local pulls = fetch("pulls")
  if pulls == nil then
    return
  end
  if #pulls == 0 then
    vim.notify("No open pull requests found", vim.log.levels.INFO)
    return
  end
  pickers.generic_table_picker({
    prompt_title = "Pick a pull",
    results = pulls,
    entry_maker_value_key = "number",
    entry_maker_display_key = "title",
    entry_maker_ordinal_key = "title",
    cb_func = cb_func,
  })
end

-- ---------------------------------------------------------------------------
-- Issues
-- ---------------------------------------------------------------------------

function M.show_gitea_issues_picker(cb_func)
  local issues = fetch("issues")
  if issues == nil then
    return
  end
  if #issues == 0 then
    vim.notify("No open issues found", vim.log.levels.INFO)
    return
  end
  pickers.generic_table_picker({
    prompt_title = "Pick an issue",
    results = issues,
    entry_maker_value_key = "number",
    entry_maker_display_key = "title",
    entry_maker_ordinal_key = "title",
    cb_func = cb_func,
  })
end

-- ---------------------------------------------------------------------------
-- Pipelines (Gitea Actions / Forgejo Actions)
-- ---------------------------------------------------------------------------

function M.show_gitea_pipelines_picker(cb_func)
  local runs = fetch("pipelines")
  if runs == nil then
    return
  end
  if #runs == 0 then
    vim.notify("No workflow runs found", vim.log.levels.INFO)
    return
  end
  pickers.generic_table_picker({
    prompt_title = "Pick a workflow run",
    results = runs,
    entry_maker_value_key = "id",
    entry_maker_display_key = "display_title",
    entry_maker_ordinal_key = "display_title",
    cb_func = cb_func,
  })
end

return M
