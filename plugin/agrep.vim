let s:term = ''
let s:count = 0

fu! agrep#InputHandler(job, msg)
    let l:matches = matchlist(a:msg, '\(.*\):\(\d*\):\s*\(.*\)')
    if len(l:matches) > 0
        call setloclist(0, [{'filename': l:matches[1], 'lnum': l:matches[2], 'text': l:matches[3]}], 'a')
        if s:count == 0
            :lop 6
        else
            :lbo
        endif
        let s:count += 1
    endif
endf

fu! agrep#CloseHandler(ch)
    if s:count == 0
        echo 'No matches for "' . s:term . '".'
    else
        echo 'Displaying ' . s:count . ' matches for "' . s:term . '".'
    endif
endf

fu! AGrep(term)
    :silent let l:gitroot = system('git rev-parse --show-toplevel')
    if v:shell_error == 0
        let l:grepcommand = 'git grep -n "' . a:term . '"'
    else
        let l:grepcommand = 'grep -rn "' . a:term . '" *'
    endif
    let s:count = 0
    call setloclist(0, [], 'r')
    echo 'Searching for ' . a:term . '...'
    let s:term = a:term
    call job_start(l:grepcommand, {'callback': 'agrep#InputHandler', 'close_cb': 'agrep#CloseHandler'})
endf

nnoremap <F3> :lne<CR>
nnoremap <S-F3> :lp<CR>
:com! -nargs=1 AG call AGrep(<f-args>)


