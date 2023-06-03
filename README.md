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

Opens up the Github Web-IDE with the current line pre-selected (on the current branch).

![open normal mode](examples/images/open_normal_mode.gif)

Can be used from visual mode when passing `{ v = true }`
(`require('githubutils').open({ v = true })`) which will then pre-select
the visually selected lines (on the current branch).

![open visual mode](examples/images/open_visual_mode.gif)

**NOTE:** additionally `commit = true` can be passed which will open the current commit,
rather than the current branch.

### `require('githubutils').repo()`

Opens up the [base Github page](https://github.com/mistweaverco/githubutils.nvim)
of the current git repository you're in.

![repo](examples/images/repo.gif)

### `require('githubutils').commit()`

Prompts you for a commit hash and opens up the Github web-view of
[this commit](https://github.com/mistweaverco/githubutils.nvim/commit/c6050edc96ebdcdf50878e88b3b2f899bb2fccb4).

![commit](examples/images/commit.gif)

If you leave the prompt empty and press enter,
the Github [web-view of all commits](https://github.com/mistweaverco/githubutils.nvim/commits/main)
for the current branch will be opened.

![commit blank](examples/images/commit_blank.gif)

### `require('githubutils').pulls()`

Lists all open pull-requests.
Takes you to the web-view of the pull-request selected.

![pulls](examples/images/pulls.gif)

### `require('githubutils').issues()`

Lists all open issues.
Takes you to the web-view of the issue selected.

![issues](examples/images/issues.gif)

### `require('githubutils').actions()`

Takes you to the web-view of the actions.

![actions](examples/images/actions.gif)

### `require('githubutils').labels()`

Lists all labels.
Takes you to the web-view of the label selected.

![labels](examples/images/labels.gif)

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
        O = { "<Cmd>lua require('githubutils').open({ commit = true })<CR>", "Open commit" },
        r = { "<Cmd>lua require('githubutils').repo()<CR>", "Repo" },
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
        O = { "<Cmd>lua require('githubutils').open({ v = true, commit = true })<CR>", "Open commit" },
      },
  },
}, { prefix = "<leader>", mode = "v" })
```

