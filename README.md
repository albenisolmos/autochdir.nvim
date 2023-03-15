# Autochdir.nvim
Smart directory switching on root directories delimited by flag files

## Settings
```lua
require('autochdir').setup {
    flags = {
        ['*.rs'] = 'Cargo.toml',
        ['*.c\|*.cpp'] = ['Makefile', 'CMake']
        [''] = 'README.md' -- rest of files that no match the previous flags
    }
}
```

## Behavior
* On each BufEnter event try to find a root dir
    - Check if the files is in the same root dir to avoid unnecessary operations
* If there's no root dir just cd to the current dir of the file
* Sometimes, projects have inside more projects so should have a function to drill through root dir hierarchy

## TODO
* impl: find_root_dir() -> root_dir: Find the root dir project
    - check file extension
    - use his flags to drill through the current dir
        - case 1: it's found a flag, cd in that dir
        - case 1: it's not found flag, cd in the dir of the current file (cd expand('%:h'))
* impl: setup.keep_root_dir: This option will force to stay in the first root dir we enter a least is in diferent tag
