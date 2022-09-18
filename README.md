# just.nvim

A [just](https://github.com/casey/just) command runner plugin for [neovim](https://github.com/neovim/neovim).

## Getting started
### Packer
```
use("BeatScherrer/just.nvim")
```

set up the plugin:
```
require("just").setup()
```

### Telescope extension
This plugin comes with a telescope extension. This allows to pick the recipe in a telescope picker and run them directly.

Register the extension in telescope:
```
require("telescope").load_extension("just")
```

## Run recipes
To run a recipe the user command `Just` is available that wraps the actual command and handles output.

Example:
```
:Just some-task
```

If an error occurrs in the passed recipe the quickfix is automatically opened.


#TODO:
- [ ] Add config to not open the quickfix on error
- [ ] Improve the error messages in the just project

