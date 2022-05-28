let s:default_table = {
      \ 'a': 0, 's': 1, 'd': 2, 'f': 3, 'g': 4,
      \ 'h': 5, 'j': 6, 'k': 7, 'l': 8, ';': 9,
      \ 'q': 10, 'w': 11, 'e': 12, 'r': 13, 't': 14,
      \ 'y': 15, 'u': 16, 'i': 17, 'o': 18, 'p': 19,
      \ '1': 20, '2': 21, '3': 22, '4': 23, '5': 24,
      \ '6': 25, '7': 26, '8': 27, '9': 28, '0': 29,
      \ }

function qselect#start(...)
  if !exists('*sign_define')
    call s:print_error(
          \ 'requires Vim 8.1.0614+ or neovim 0.4.0+.')
    return
  endif

  let options = {
        \ 'callback': v:null,
        \ 'reversed': v:false,
        \ 'table': s:default_table,
        \ }
  call extend(options, get(a:000, 0, {}))

  let table = s:get_quick_move_table(options)

  let save_signcolumn = &l:signcolumn
  setlocal signcolumn=yes

  echo 'Input quick match key: '
  call s:redraw_table(table, v:true)

  redraw

  let char = ''
  while char == ''
    let char = nr2char(s:getchar())
  endwhile

  call s:redraw_table(table, v:false)

  redraw

  let &l:signcolumn = save_signcolumn

  if !has_key(table, char)
    return
  endif

  call cursor(table[char], 0)

  if options.callback != v:null
    call call(options.callback, [])
  endif
endfunction

function s:get_quick_move_table(options)
  let table = {}
  let base = line('.')

  for [key, number] in items(a:options.table)
    let pos = a:options.reversed ? base - number : number + base
    if pos > 0
      let table[key] = pos
    endif
  endfor

  return table
endfunction

function s:redraw_table(table, is_define)
  let bufnr = bufnr('%')

  for [key, number] in items(a:table)
    let signid = 2000 + number
    let name = 'qselect_' + number
    if a:is_define
      call sign_define(name, {'text': key, 'texthl': 'Special'})
      call sign_place(signid, '', name, bufnr, {'lnum': number})
    else
      call sign_unplace('', {'id': signid, 'buffer': bufnr})
      call sign_undefine(name)
    endif
  endfor
endfunction

function! s:getchar(...) abort
  try
    return call('getchar', a:000)
  catch /^Vim:Interrupt/
    return 3
  catch
    return 0
  endtry
endfunction

function! s:print_error(string, ...) abort
  let name = a:0 ? a:1 : 'qselect'
  echohl Error
  echomsg printf('[%s] %s', name,
        \ type(a:string) ==# v:t_string ? a:string : string(a:string))
  echohl None
endfunction
