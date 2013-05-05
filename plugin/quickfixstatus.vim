" Vim global plugin for showing quickfix (and location list and
" Syntastic lists) in the status line.
"
" Maintainer: Danny O'Brien <danny@spesh.com>
" License: Vim license
"
if exists("g:loaded_quickfixstatus") || &cp
      finish
endif

let g:loaded_quickfixstatus = 101
let s:keepcpo           = &cpo
set cpo&vim

let s:qfstatus_displaying = 0

function! s:Cache_Quickfix()
    let b:qfstatus_list = {}
    if exists("b:syntastic_loclist")
        let sy = b:syntastic_loclist
    else
        let sy = []
    endif
    for allfixes in extend(extend(getqflist(), getloclist(0)), sy)
        let err = allfixes['text']
        let err = substitute(err,'\n',' ','g')
        let b:qfstatus_list[allfixes['lnum']] = err
    endfor
    call s:Show_Quickfix_In_Status()
endfunction

function! s:Show_Quickfix_In_Status()
    if !exists("b:qfstatus_list")
        return
    endif
    let ln = line('.')
    if !has_key(b:qfstatus_list, ln)
        if s:qfstatus_displaying
          echo
          let s:qfstatus_displaying = 0
        endif
        return
    else
        let len = &columns - 12
        " echo | redraw!
        echo strpart(b:qfstatus_list[ln], 0, len)
        let s:qfstatus_displaying = 1
    endif
endfunction

function! s:Enable()
    augroup quickfixstatus
        au!
        au QuickFixCmdPost * call s:Cache_Quickfix()
        au CursorMoved,CursorMovedI * call s:Show_Quickfix_In_Status()
    augroup END
    call s:Cache_Quickfix()
endfunction

function! s:Disable()
    au! quickfixstatus
endfunction

command! -nargs=0 QuickfixStatusEnable call s:Enable()
command! -nargs=0 QuickfixStatusDisable call s:Disable()

call s:Enable()

let &cpo= s:keepcpo
unlet s:keepcpo
