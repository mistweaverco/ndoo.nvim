local telescope_pickers = require "telescope.pickers"
local telescope_finders = require "telescope.finders"
local telescope_conf = require("telescope.config").values
local telescope_actions = require "telescope.actions"
local telescope_action_state = require "telescope.actions.state"

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
          ordinal = entry[opts.entry_maker_ordinal_key]
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
  }):find()
end

return M

