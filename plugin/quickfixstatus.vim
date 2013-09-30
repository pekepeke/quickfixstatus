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

let g:qfstatus_trim_message = get(g:, 'qfstatus_trim_message', 1)
" echo repeat("a", &columns - 12)
let g:qfstatus_trim_len = get(g:, 'qfstatus_trim_len', 12)
let g:qfstatus_tab_char = get(g:, 'qfstatus_tab_char', '  ')
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
        if g:qfstatus_trim_message
            let len = &cmdheight * &columns - g:qfstatus_trim_len
            echo strpart(substitute(b:qfstatus_list[ln], "\t", g:qfstatus_tab_char, "g"), 0, len)
        else
            echo b:qfstatus_list[ln]
        endif
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
