local telescope_pickers = require "telescope.pickers"
local telescope_finders = require "telescope.finders"
local telescope_conf = require("telescope.config").values
local telescope_actions = require "telescope.actions"
local telescope_action_state = require "telescope.actions.state"
local telescope_previewers = require "telescope.previewers"
local telescope_utils = require('telescope.previewers.utils')

local M = {}

M.generic_table_picker = function(opts)
  telescope_pickers.new({}, {
    prompt_title = opts.prompt_title,
    finder = telescope_finders.new_table {
      results = opts.results,
      entry_maker = function(entry)
        return {
          value = entry[opts.entry_maker_value_key],
          display = entry[opts.entry_maker_display_key],
          ordinal = entry[opts.entry_maker_ordinal_key],
          previewer_value = entry[opts.previewer_value_key],
        }
      end,
    },
    sorter = telescope_conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
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
    previewer = telescope_previewers.new_buffer_previewer {
      title = opts.previewer_title or "Preview",
      define_preview = function (self, entry, status)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(entry.previewer_value, "\r\n"))
        telescope_utils.highlighter(self.state.bufnr, 'markdown')
      end
    }
  }):find()
end

return M

