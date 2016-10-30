# vim-agrep
Asynchronous grep plugin for vim, using location list

vim-agrep uses git grep if in a git repository. Otherwise, it'll do a recursive search from the current working directory. 
It'll also automatically open the location list if there are multiple results.

## Usage

Can both be called with `AGrep(<term>)`, and as a normal command `:AG <term>`. 

