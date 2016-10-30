
fu! agrep#InputHandler(job, msg)
    let l:matches = matchlist(a:msg, '\(.*\):\(\d*\):\s*\(.*\)')
    if len(l:matches) > 0
        call setloclist(0, [{'filename': l:matches[1], 'lnum': l:matches[2], 'text': l:matches[3]}], 'a')
        :lbo
    endif
endf

fu! agrep#CloseHandler(ch)
    let l:length = len(getloclist(0))
    if l:length == 0
        :lclose
        echo 'No matches'
    else
        echo 'Displaying ' . l:length . ' matches'
    endif
endf

fu! AGrep(term)
    :silent let l:gitroot = system('git rev-parse --show-toplevel')
    if v:shell_error == 0
        let l:grepcommand = 'git grep -n "' . a:term . '"'
    else
        let l:grepcommand = 'grep -rn "' . a:term . '" *'
    endif
    call setloclist(0, [], 'r')
    :lop 5
    echo 'Searching for ' . a:term . '...'
    call job_start(l:grepcommand, {'callback': 'agrep#InputHandler', 'close_cb': 'agrep#CloseHandler'})
endf

nnoremap <F3> :lne<CR>
nnoremap <S-F3> :lp<CR>
:com! -nargs=1 AG call AGrep(<f-args>)


