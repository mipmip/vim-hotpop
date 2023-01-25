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

  let winid = popup_create(rows, #{ title: ' My Mappings ', minwidth: 70, maxheight: 30, padding: [1,2,1,2], border: [], filter: function('s:popup_filter'), filtermode: 'n', mapping: 0, close: 'click' })

endfunction

