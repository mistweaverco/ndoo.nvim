GithubUtils.nvim
================

🐙 GithubUtils.nvim - simple utils for working with Github inside Neovim.

## Requirements

- [Neovim](https://github.com/neovim/neovim) (tested with 0.9.0)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

## Installation

Via [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
require('lazy').setup({
  -- Github Integration
  { 'mistweaverco/githubutils', dependencies = 'nvim-telescope/telescope.nvim' },
})
```

## Configuration

With [whichkey.nvim](https://github.com/folke/which-key.nvim):

```lua
wk.register({
  g = {
    name = "Goto",
      h = {
        name = "Github Utils",
        o = { "<Cmd>lua require('githubutils').open()<CR>", "Open" },
        O = { "<Cmd>lua require('githubutils').open_remote()<CR>", "Open remote" },
        r = { "<Cmd>lua require('githubutils').repo()<CR>", "Repo" },
        p = { "<Cmd>lua require('githubutils').pulls()<CR>", "Pulls" },
        i = { "<Cmd>lua require('githubutils').issues()<CR>", "Issues" },
        a = { "<Cmd>lua require('githubutils').actions()<CR>", "Actions" },
      },
  },
}, { prefix = "<leader>" })
```

