# Autochdir.nvim
Smart directory switching on root directories delimited by flag files

## How Works?
Autochdir will try to find the root directory of a project from the current directory to the top level directory in the file system (/). This lookup is performed on every BufEnter event.\
The root directories are defined by flags files/directories that are usually in projects (like: README.md or .git)

## Settings
```lua
require('autochdir').setup {
    -- Useful for not accidentally jumping to other projects and staying in the first project found
    keep_dir = false

    -- Define flags by file extension (default: {})
    flags = {
        -- This is not set by default
        -- ['rs'] = {'Cargo.toml'},
        -- ['c'] = {'Makefile', 'CMake'}
    }
    -- Define generic flags for all files
    generic_flags = {'README.md', '.git'}

    -- Autochair will first find flags from 'flags' and then from 'generic flags'
}
```

### About keep_dir
If this option is true, it may be useful to take in mind for your workflow, where you only have one chance to get into a root project before Autochdir stops working for at least the current tab. __This force you to put just one project by tab__

## Commands
* __AutochdirCd__: change directory of then current tab to the near flag found in the directory tree
* __AutochdirCd!__: Same behavior of AutochdirCd, but if the current directory is a root directory, force to drill one more time in the directory tree
