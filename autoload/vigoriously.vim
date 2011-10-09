" Vim library file
" Description:	VimL Function (snippet) generator.
" Maintainer:	Barry Arthur <%Email%>
" 		Israel Chauca <israelchauca@gmail.com>
" Version:	0.3
" Last Change:	09 Oct 2011
" License:	Vim License (see :help license)
" Location:	autoload/vigoriously.vim

if exists("g:loaded_lib_vigoriously")
      \ || v:version < 700 || &compatible
  finish
endif
let g:loaded_lib_vigoriously = 1

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

let s:p = Vimpeg({'skip_white': 1})

call s:p.e('"', {'id': 'comment'})
call s:p.e('\w\+', {'id': 'value'})
call s:p.e('\w\+', {'id': 'ident'})
call s:p.and(['ident', s:p.maybe_one(s:p.and([s:p.e(':'), 'value']))], {'id': 'arg', 'on_match': 'vigoriously#Arg'})

" change this to allow argumentless functions
call s:p.and(['arg', s:p.maybe_many(s:p.and([s:p.e(','), 'arg']))], {'id': 'arglist', 'on_match': 'vigoriously#ArgList'})
call s:p.and([s:p.e('('), 'arglist', s:p.e(')')], {'id': 'args', 'on_match': 'vigoriously#Args'})

call s:p.e('.*', {'id': 'fbody'})

let vigoriously#parser = s:p.and(['comment', 'ident', 'args', s:p.e('->'), 'fbody'], {'id': 'fdecl', 'on_match': 'vigoriously#FDecl'})

" callbacks on successful match of element (grammar provider library side)

func! vigoriously#Arg(elems)
  "echo "vigoriously#Arg: " . string(a:elems)
  let assignment = {}
  let assignment[a:elems[0]] = '__vigor_manarg'
  if len(a:elems[1]) > 0
    let assignment[a:elems[0]] = a:elems[1][0][1]
  endif
  return assignment
endfunc

func! vigoriously#ArgList(elems)
  "echo "vigoriously#ArgList: " . string(a:elems)
  let arglist = a:elems[0]
  call map(map(a:elems[1], 'v:val[1]'), 'extend(arglist, v:val)')
  return arglist
endfunc

func! vigoriously#Args(elems)
  "echo "vigoriously#Args: " . string(a:elems)
  return a:elems[1]
endfunc

func! vigoriously#FDecl(elems)
  "echo "vigoriously#FDecl: " . string(a:elems)
  let name = a:elems[1]
  let args = a:elems[2]
  let body = a:elems[4]
  let fhead = "function! " . name . " ("
  let fargs = []
  let unbounds = 0
  let lets = '  " vigoriously {{{' . "\n"
  let cnt = 0
  for arg in items(args)
    if arg[1] != '__vigor_manarg'
      let unbounds = 1
    else
      call add(fargs, arg[0])
    endif
    let cnt += 1
  endfor

  let varargs = filter(items(copy(args)), 'v:val[1] != "__vigor_manarg"')
  call map(args, 'v:val =~ "manarg" ? "a:".v:key : v:val')
  let lets .= "  let __vigor_args = " . string(map(varargs, 'v:val[0]')) . "\n"
  let lets .= "  let __vigor_argvals = " . string(args) . "\n"

  let lets .= "  let i = 0" . "\n"
  let lets .= "  while i < a:0" . "\n"
  let lets .= "    let __vigor_argvals[__vigor_args[i]] = a:000[i]" . "\n"
  let lets .= "    let i += 1" . "\n"
  let lets .= "  endwhile" . "\n"
  let lets .= "  for i in keys(__vigor_argvals)" . "\n"
  let lets .= "    exe 'let ' . i . ' = ' . __vigor_argvals[i]" . "\n"
  let lets .= "  endfor" . "\n"
  let lets .= "  unlet i" . ' "}}}' . "\n"
  let lets .= "\n  "

  if unbounds
    call add(fargs, '...')
  endif

  return fhead . join(fargs, ',') . ")\n" . lets . body . "\nendfunction"
endfunc

" Restore settings
let &cpo = s:save_cpo
unlet s:save_cpo

" vim: et sw=2

