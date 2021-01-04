# HOTPOP vim mapping and cheatsheet plugin

When using this plugin to add custom mappings it add's them to a cheatsheet.

* Show cheatsheet in floating popup-window
* No redundant documentation

# Usage

```
call hotpop#init() "run this before other calls

"              MODE    <SPECIALS>   KEYSEQ          COMMAND                   SHEET-PARAGRAPH                  SHEET HELP_TEXT
call HotpopMap('nmap', '',          '<leader>?',    ':call HotpopShow()<CR>', 'Hotmap',                  'Open this popup...')
call HotpopMap('map',  '',          '<leader>d',  ':set background=dark<cr>', "Colors",           "Change to dark background")
call HotpopMap('map',  '',          '<leader>l', ':set background=light<cr>', "Colors",          "Change to light background")
call HotpopMap('map',  '',          '<leader>b',              ':Buffers<cr>', 'FZF',                  'FZF with open buffers')
call HotpopMap('map',  '',          '<leader>f',                ':Files<cr>', 'FZF',    'FZF with files in current directory')
```
