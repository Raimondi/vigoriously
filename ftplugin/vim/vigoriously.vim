" Vim filetype plugin file
" Description:	VimL Function (snippet) generator.
" Language:	VimL
" Maintainer:	%Maintainer% <%Email%>
" Version:	0.3
" Last Change:	02 Oct 2011
" License:	Vim License (see :help license)
" Location:	ftplugin/vim/vigoriously.vim

" Load only when it can perform its magic.
if v:version < 700 || &compatible
  finish
endif

" Be nice with user's custom mappings
if !hasmapto('<Plug>Vigoriously')
  map <unique> <buffer> <Leader>v <Plug>Vigoriously
endif

" Play nice when changing filetype.
let s:undo_ftplugin = 'sil! unmap <buffer> <Leader>v'
if exists('b:undo_ftplugin') && b:undo_ftplugin !~ '<Plug>Vigoriously'
  if b:undo_ftplugin =~ '^\s*$'
    let b:undo_ftplugin = s:undo_ftplugin
  else
    let b:undo_ftplugin = s:undo_ftplugin.'|'.b:undo_ftplugin
  endif
elseif !exists('b:undo_ftplugin')
  let b:undo_ftplugin = s:undo_ftplugin
endif

" Do not load everything twice
if exists('b:loaded_vigoriously')
  finish
endif
let b:loaded_vigoriously = 1

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

func! s:vigoriously() range
  let res = g:vigoriously#parser.match(getline('.'))
  if res['is_matched']
    call append(".", split(res['value'], '\n'))
  else
    echo res['errmsg']
  endif
endfunc

nnoremap <Plug>Vigoriously :call <SID>vigoriously()<CR>

" Restore settings
let &cpo = s:save_cpo
unlet s:save_cpo

" vim: et sw=2

