GithubUtils.nvim
================

🐙 GithubUtils.nvim - simple utils for working with Github inside Neovim.

## Requirements

- [Neovim](https://github.com/neovim/neovim) (tested with 0.9.0)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [git](https://git-scm.com/)
- [Github CLI](https://cli.github.com/)

## Installation

Via [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
require('lazy').setup({
  -- Github Integration
  { 'mistweaverco/githubutils.nvim', dependencies = 'nvim-telescope/telescope.nvim' },
})
```

## Public methods

### `require('githubutils').open()`

Opens up the Github Web-IDE with the current line pre-selected.

Can be used from visual mode when passing `{ v = true}`
(`require('githubutils').open({ v = true })`) which will then pre-select
the visually selected lines.


### `require('githubutils').repo()`

Opens up the [base Github page](https://github.com/mistweaverco/githubutils.nvim)
of the current git repository you're in.

### `require('githubutils').commit()`

Prompts you for a commit hash and opens up the Github web-view of
[this commit](https://github.com/mistweaverco/githubutils.nvim).

If you leave the prompt empty and press enter,
The Github web-view of all commit for the current branch will be opened.

### `require('githubutils').pulls()`

Lists all open pull-requests.
Takes you to the web-view of the pull-request selected.

### `require('githubutils').issues()`

Lists all open issues.
Takes you to the web-view of the issue selected.

### `require('githubutils').actions()`

Takes you to the web-view of the actions.

### `require('githubutils').labels()`

Lists all labels.
Takes you to the web-view of the label selected.

## Configuration

With [which-key.nvim](https://github.com/folke/which-key.nvim):

```lua
-- Mappings for normal mode
wk.register({
  g = {
    name = "Goto",
      h = {
        name = "Github Utils",
        o = { "<Cmd>lua require('githubutils').open()<CR>", "Open" },
        O = { "<Cmd>lua require('githubutils').repo()<CR>", "Repo" },
        c = { "<Cmd>lua require('githubutils').commit()<CR>", "Commit" },
        p = { "<Cmd>lua require('githubutils').pulls()<CR>", "Pulls" },
        i = { "<Cmd>lua require('githubutils').issues()<CR>", "Issues" },
        a = { "<Cmd>lua require('githubutils').actions()<CR>", "Actions" },
        l = { "<Cmd>lua require('githubutils').labels()<CR>", "Actions" },
      },
  },
}, { prefix = "<leader>" })

-- Mappings for visual mode
wk.register({
  g = {
    name = "Goto",
      h = {
        name = "Github Utils",
        o = { "<Cmd>lua require('githubutils').open({ v = true })<CR>", "Open" },
      },
  },
}, { prefix = "<leader>", mode = "v" })
```

