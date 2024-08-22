if (exists('g:loaded_hotpop') && g:loaded_hotpop) || &cp
   "finish
endif

let g:loaded_hotpop = 1

function! hotpop#init()
let g:hotpopMappings = {}
let g:hotpopChapters = []
endfunction

function! HotpopMap(map_mode, map_special, key_sequence, command, help_chapter, help_description)

  if !has_key(g:hotpopMappings, a:help_chapter)
    let g:hotpopMappings[a:help_chapter]=[]
    call add(g:hotpopChapters, a:help_chapter)
  endif

  call add(g:hotpopMappings[a:help_chapter], [a:map_mode, a:map_special, a:key_sequence, a:help_description])

  "WHEN EMPTY DONT MAP, JUST SHOW IN HELP
  if a:command == ''
  else
    execute a:map_mode . ' ' . a:map_special . ' ' a:key_sequence. ' ' . a:command
  endif

endfunction

function! hotpop#popup_create(what, options) abort
    if has('popupwin')
        return popup_create(a:what, a:options)
    elseif has('nvim')
        return s:floatwin(s:to_list(a:what), s:options(#{}, a:options))
    endif
endfunction

function s:to_list(what) abort
    if type(a:what) == v:t_number
        return getbufline(a:what, 1, '$')
    elseif type(a:what) == v:t_list
        return copy(a:what)
    else
        return [a:what]
    endif
endfunction

function s:floatwin(lines, opts) abort
    " extra vertical and horizontal space for menu box
    let l:extraV = a:opts.border[0] + a:opts.padding[0] +
        \ a:opts.padding[2] + a:opts.border[2]
    let l:extraH = a:opts.border[3] + a:opts.padding[3] +
        \ a:opts.padding[1] + a:opts.border[1]

    " calc height and width
    let l:height = max([len(a:lines), a:opts.minheight, 1])
    let l:height = min([l:height, a:opts.maxheight, &lines - &cmdheight - l:extraV])
    let l:height += l:extraV
    let l:width = max(extend(map(a:lines[:], 'strwidth(v:val)'), [a:opts.minwidth,
        \ strwidth(a:opts.title) - a:opts.padding[3] - a:opts.padding[1]]))
    let l:width = min([l:width, a:opts.maxwidth, &columns - l:extraH])
    let l:width += l:extraH

    " floatwin config
    let l:config = {'anchor': get({'topright': 'NE', 'botleft': 'SW', 'botright': 'SE'},
        \ a:opts.pos, 'NW'), 'height': l:height, 'width': l:width, 'relative': 'editor',
        \ 'focusable': v:false, 'style': 'minimal'}
    let l:config.row = a:opts.line ? a:opts.line - 1 : s:centered(l:height,
        \ &lines - &cmdheight, l:config.anchor[0] is# 'S')
    let l:config.col = a:opts.col ? a:opts.col - 1 : s:centered(l:width, &columns,
        \ l:config.anchor[1] is# 'E')

    " show menu box
    let a:opts.box = s:get_buffer('popup_box', v:true)
    call s:set_lines(a:opts.box, s:draw_box(l:config.height, l:config.width, a:opts))
    call nvim_open_win(a:opts.box, v:false, l:config)
    call s:set_winopts(bufwinid(a:opts.box), {'winhighlight': a:opts.highlight})

    " shift menu items inside the box
    let l:config.focusable = v:true
    let [l:config.height, l:config.width] -= [l:extraV, l:extraH]
    let [l:config.row, l:config.col] += s:shift_inside(l:config.anchor, a:opts)

    " show menu items
    let l:items = s:get_buffer('popup_options', a:opts)
    call s:set_lines(l:items, a:lines)
    let l:id = nvim_open_win(l:items, v:true, l:config)
    mapclear <buffer>
    autocmd! BufLeave <buffer> call s:bufleave(str2nr(expand('<abuf>')))
    call s:set_winopts(l:id, {'cursorline': a:opts.cursorline, 'scrolloff': 0,
        \ 'sidescrolloff': 0, 'winhighlight': a:opts.highlight, 'wrap': a:opts.wrap})
    call s:set_keymaps(l:id, a:opts.filtermode, a:opts.filter)
    if a:opts.firstline
        call nvim_win_set_cursor(l:id, [a:opts.firstline, 0])
    endif
    if a:opts.time
        call timer_start(a:opts.time, {-> win_getid() == l:id && popup#close(l:id)})
    endif

    return l:id
endfunction



function! s:popup_filter(winid, key)
  echo a:key
    if a:key ==# "k"
        call win_execute(a:winid, "normal! \<c-y>")
        return v:true
    elseif a:key ==# "j"
        call win_execute(a:winid, "normal! \<c-e>")
        return v:true
    elseif a:key ==# ""
        call win_execute(a:winid, "normal! \<c-b>")
        return v:true
    elseif a:key ==# ""
        call win_execute(a:winid, "normal! \<c-f>")
        return v:true
    elseif a:key ==# ''
        return popup_filter_menu(a:winid, 'x')
    elseif a:key ==# 'q'
        return popup_filter_menu(a:winid, 'x')
    endif
    return v:false
endfunction

function! HotpopShow()
  let rows = []

  call add(rows, "                                               Scroll lines: <j> and <k>")
  call add(rows, "                                               Scroll pages: <C-f> and <C-b>")
  call add(rows, "                                               Close:        <q> or <Esc>")

  for chapter in g:hotpopChapters
    call add(rows, '' . toupper(chapter))
    call add(rows, repeat('-', len(chapter)))

   for mapping in g:hotpopMappings[chapter]
      call add(rows, mapping[2] . repeat(' ', 20 - len(mapping[2])) . mapping[3])
    endfor
    call add(rows, '')

  endfor

  let winid = hotpop#popup_create(rows, #{ title: ' My Mappings ', minwidth: 70, maxheight: 30, padding: [1,2,1,2], border: [], filter: function('s:popup_filter'), filtermode: 'n', mapping: 0, close: 'click' })

endfunction

