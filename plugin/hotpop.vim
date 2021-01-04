let g:hotpopMappings = {}
let g:hotpopChapters = []
function! Hotmap(map_mode, map_special, key_sequence, command, help_chapter, help_description)

  if !has_key(g:hotpopMappings, a:help_chapter)
    let g:hotpopMappings[a:help_chapter]=[]
    call add(g:hotpopChapters, a:help_chapter)
  endif

  call add(g:hotpopMappings[a:help_chapter], [a:map_mode, a:map_special, a:key_sequence, a:help_description])

  execute a:map_mode . ' ' . a:map_special . ' ' a:key_sequence. ' ' . a:command
endfunction

function! s:popup_filter(winid, key)
    if a:key ==# "k"
        call win_execute(a:winid, "normal! \<c-y>")
        return v:true
    elseif a:key ==# "j"
        call win_execute(a:winid, "normal! \<c-e>")
        return v:true
    elseif a:key ==# 'q'
        return popup_filter_menu(a:winid, 'x')
    endif
    return v:false
endfunction

function! Hotpop()
  let rows = []

  call add(rows, "scroll with j and k and close with 'q'")
  call add(rows, '')

  for chapter in g:hotpopChapters
    call add(rows, '' . toupper(chapter))
    call add(rows, repeat('-', len(chapter)))

   for mapping in g:hotpopMappings[chapter]
      call add(rows, mapping[2] . repeat(' ', 20 - len(mapping[2])) . mapping[3])
    endfor
    call add(rows, '')

  endfor

  let winid = popup_create(rows, #{ title: ' My Mappings ', padding: [1,2,1,2], border: [], filter: function('s:popup_filter'), close: 'click' })
endfunction

