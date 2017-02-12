let s:term = ''
let s:count = 0
let s:jump = 0

fu! agrep#InputHandler(job, msg)
    let l:matches = matchlist(a:msg, '\(.*\):\(\d*\):\s*\(.*\)')
    if len(l:matches) > 0
        call setloclist(0, [{'filename': l:matches[1], 'lnum': l:matches[2], 'text': l:matches[3]}], 'a')
        if s:count < 6 && s:count > 0
            execute('lop ' . (s:count + 1))
        endif
        lbo
        let s:count += 1
    endif
endf

fu! agrep#CloseHandler(ch)
    if s:count == 0
        echo 'No matches for ' . s:term . '.'
    elseif s:count == 1
        if s:jump
            silent ll
            echo 'Displaying only match for ' . s:term . '.'
        else
            lopen 1
        endif
    else
        if s:count < 6
            execute('lop ' . s:count)
        endif
        echo 'Displaying ' . s:count . ' matches for ' . s:term . '.'
    endif
endf

fu! AGrep(term)
    :silent let l:gitroot = system('git rev-parse --show-toplevel')
    if v:shell_error == 0
        let l:grepcommand = 'git grep -n ' . a:term
    else
        let l:grepcommand = 'grep -rn ' . a:term . ' *'
    endif
    let s:count = 0
    call setloclist(0, [], 'r')
    let s:term = a:term
    call job_start(l:grepcommand, {'callback': 'agrep#InputHandler', 'close_cb': 'agrep#CloseHandler'})
endf

fu! AGrepFree(term, jump)
    let s:jump = a:jump
    echo 'Searching for ' . a:term . '...'
    call AGrep(a:term)
endf

fu! AGrepGetDefine(name, jump)
    let s:jump = a:jump
    echo 'Searching for ' . a:name . '...'
    let l:define = '^\s*#define\s\+' . a:name
    let l:struct = '^\s*}\s*' . a:name . ';\s*$'
    let l:variable = '^\s*\([a-zA-Z_][a-zA-Z0-9_]*\s\+\)\+\([a-zA-Z\*_][a-zA-Z0-9\*_]*\s\+\)*' . a:name . '\s*\(=.*\)\=;$'
    let l:function = '^\s*\([a-zA-Z_][a-zA-Z0-9_]*\s\+\)\+\([a-zA-Z\*_][a-zA-Z0-9\*_]*\s\+\)*' . a:name . '\s*([^;]\+$'
    let l:func_ptr = '^\s*typedef\s\+\([a-zA-Z\*_][a-zA-Z0-9\*_]*\s\+\)\+(\*\s*' . a:name . '\s*)\s*([^;]\+$'
    let l:all_dict = [l:define, l:struct, l:variable, l:function, l:func_ptr]
    let l:all = '\(' . join(l:all_dict, '\|') . '\)'
    call AGrep('"' . l:all . '"')
endf

nnoremap <F3> :lne<CR>
nnoremap <S-F3> :lp<CR>
:com! -nargs=1 AG call AGrepFree(<f-args>, 1)
set switchbuf=usetab,newtab

