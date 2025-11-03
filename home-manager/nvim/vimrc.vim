" Remove ALL autocommands for the current group so that they are not loaded multiple times
autocmd!

" if directory does not exist yet, create it
augroup Mkdir
  autocmd BufWritePre * call mkdir(expand("<afile>:p:h"), "p")
augroup END

" Core.
set fileencodings=ucs-bom,utf-8,gb18030,latin1
set foldmethod=marker
set lazyredraw
set mouse=a
set scrolloff=5
set undofile
" No undo for tmp files
autocmd BufWritePre /tmp/*,/var/tmp/*,/dev/shm/* setlocal noundofile nobackup
set shiftwidth=4
set softtabstop=-1 " Follows shiftwidth
set shiftround
set expandtab
set ttimeoutlen=1
set number
set relativenumber
set cursorline
set hlsearch
" have extra space before the line numbers for annotations
set signcolumn=yes
set list
set listchars=tab:-->,extends:>,precedes:<
set colorcolumn=80
set ignorecase
set smartcase
set noswapfile
set history=500

" Highlight on yank.
autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=200}

" Move lines.
nnoremap <C-Down> :move+<CR>
nnoremap <C-Up> :move-2<CR>
nnoremap gb :ls<CR>:b<Space>

" copy to clipboard
vmap <C-c> "+yi
vmap <C-x> "+c
vmap <C-v> c<ESC>"+p
imap <C-v> <C-r><C-o>+

" replace text in visual mode with ctrl + r
vnoremap <C-r> "hy:%s/<C-r>h/<C-r>h/g<left><left><left>

" cabal-fmt copied from:
" https://github.com/sdiehl/vim-cabalfmt/blob/master/ftplugin/cabal/cabalfmt-haskell.vim
if !exists("g:cabalfmt_command")
  let g:cabalfmt_command = "cabal-fmt"
endif

function! s:OverwriteBuffer(output)
  if &modifiable
    let l:curw=winsaveview()
    try | silent undojoin | catch | endtry
    let splitted = split(a:output, '\n')
    if line('$') > len(splitted)
      execute len(splitted) .',$delete'
    endif
    call setline(1, splitted)
    call winrestview(l:curw)
  else
    echom "Cannot write to non-modifiable buffer"
  endif
endfunction

function! s:CabalHaskell()
  if executable(g:cabalfmt_command)
    call s:RunCabal()
  elseif !exists("s:exec_warned")
    let s:exec_warned = 1
    echom "cabalfmt executable not found"
  endif
endfunction

function! s:CabalSave()
  call s:CabalHaskell()
  if exists("bufname")
    write
  endif
endfunction

function! s:RunCabal()
  if exists("bufname")
    let output = system(g:cabalfmt_command . " " . bufname("%"))
  else
    let stdin=join(getline(1, '$'), "\n")
    let output = system(g:cabalfmt_command, stdin)
  endif
  if v:shell_error != 0
    echom output
  else
    call s:OverwriteBuffer(output)
    if exists("bufname")
      write
    endif
  endif
endfunction

augroup cabalfmt-haskell
  autocmd!
  autocmd BufWritePost *.cabal call s:CabalSave()
augroup END
