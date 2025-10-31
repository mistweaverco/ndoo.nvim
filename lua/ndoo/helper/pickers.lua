local table_helpers = require("ndoo.helper.table")

local M = {}

M.generic_list_picker = function(opts, cb_func)
  opts = opts or {}
  opts.title = opts.title or "Pick an item"
  local theme_config = {}
  if pcall(require, "telescope.pickers") then
    local telescope_pickers = require("telescope.pickers")
    local telescope_finders = require("telescope.finders")
    local telescope_conf = require("telescope.config").values
    local telescope_actions = require("telescope.actions")
    local telescope_action_state = require("telescope.actions.state")
    local telescope_themes = require("telescope.themes")
    local telescope_theme_dropdown = telescope_themes.get_dropdown({})
    if opts.dropdown == true then
      theme_config = telescope_theme_dropdown
    end
    telescope_pickers
      .new(theme_config, {
        prompt_title = opts.title,
        finder = telescope_finders.new_table({
          results = opts.results,
        }),
        sorter = telescope_conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, _)
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
      })
      :find()
    return
  end
  if pcall(require, "fzf-lua") then
    local fzf = require("fzf-lua")
    fzf.fzf_exec(opts.results, {
      prompt = opts.title .. "> ",
      actions = {
        ["default"] = function(selected)
          if selected[1] == nil then
            cb_func(nil)
          else
            cb_func(selected[1])
          end
        end,
      },
    })
    return
  end
  vim.notify("No picker available (telescope or fzf-lua)", vim.log.levels.WARN)
end

M.generic_table_picker = function(opts)
  opts = opts or {}
  if pcall(require, "telescope.pickers") == true then
    local telescope_pickers = require("telescope.pickers")
    local telescope_finders = require("telescope.finders")
    local telescope_conf = require("telescope.config").values
    local telescope_actions = require("telescope.actions")
    local telescope_action_state = require("telescope.actions.state")
    local telescope_previewers = require("telescope.previewers")
    local telescope_utils = require("telescope.previewers.utils")
    local telescope_themes = require("telescope.themes")
    local telescope_theme_dropdown = telescope_themes.get_dropdown({})
    local theme_config = {}
    if opts.dropdown == true then
      theme_config = telescope_theme_dropdown
    end

    local previewer = nil

    if opts.preview == true then
      opts.preview_ft = opts.preview_ft or "markdown"

      previewer = telescope_previewers.new_buffer_previewer({
        title = opts.previewer_title or "Preview",
        define_preview = function(self, entry, _)
          local contents = vim.split(entry.previewer_value, "\r?\n")
          vim.print(vim.inspect(contents))
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, contents)
          telescope_utils.highlighter(self.state.bufnr, opts.preview_ft)
        end,
      })
    end

    local picker_config = {
      prompt_title = opts.prompt_title,
      finder = telescope_finders.new_table({
        results = opts.results,
        entry_maker = function(entry)
          -- Handle string entries
          if type(entry) == "string" then
            return {
              value = entry,
              display = entry,
              ordinal = entry,
              previewer_value = entry,
            }
          end

          -- Handle object entries
          if opts.previewer_value_key == nil then
            opts.previewer_value_key = opts.entry_maker_value_key
          end
          return {
            value = entry[opts.entry_maker_value_key],
            display = entry[opts.entry_maker_display_key],
            ordinal = entry[opts.entry_maker_ordinal_key],
            previewer_value = entry[opts.previewer_value_key],
          }
        end,
      }),
      sorter = telescope_conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, _)
        telescope_actions.select_default:replace(function()
          telescope_actions.close(prompt_bufnr)
          local selection = telescope_action_state.get_selected_entry()
          if selection == nil then
            opts.cb_func(nil)
          else
            opts.cb_func(selection.value)
          end
        end)
        return true
      end,
      previewer = previewer,
    }
    telescope_pickers.new(theme_config, picker_config):find()
    return
  end
  if pcall(require, "fzf-lua") == true then
    local fzf = require("fzf-lua")
    local fzf_results = {}
    local fzf_result_values = {}

    for _, entry in ipairs(opts.results) do
      if type(entry) == "string" then
        table.insert(fzf_results, entry)
      else
        local k = table_helpers.deep_get(entry, opts.entry_maker_display_key)
        local v = table_helpers.deep_get(entry, opts.entry_maker_value_key)
        if k ~= nil and v ~= nil then
          table.insert(fzf_results, k)
          fzf_result_values[k] = v
        end
      end
    end
    fzf.fzf_exec(fzf_results, {
      fzf_opts = {
        ["--no-multi"] = true,
        ["--preview-window"] = "up:1",
      },
      actions = {
        ["default"] = function(selected)
          vim.print(vim.inspect(selected))
          if selected[1] == nil then
            opts.cb_func(nil)
            return
          end
          vim.print(vim.inspect(fzf_result_values[selected[1]]))
          opts.cb_func(fzf_result_values[selected[1]])
        end,
      },
    })
    return
  end
  vim.notify("No picker available (telescope or fzf-lua)", vim.log.levels.WARN)
end

return M
