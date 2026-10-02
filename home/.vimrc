" 跨平台系统检测
let s:is_windows = has('win32') || has('win64') || has('win32unix') || exists('$WINDIR') || exists('$COMSPEC')
let s:is_mac     = has('mac')
let s:is_linux   = !s:is_windows && !s:is_mac

" 增强默认配置
runtime! defaults.vim
let g:skip_defaults_vim = 1
highlight CocFloating ctermbg=240
set mouse=a
set ai
set showmatch
set vb
set laststatus=2
set showmode
set wildmode=list:longest,longest:full

" 状态栏
set statusline=%f
set statusline+=%h
set statusline+=%m
set statusline+=%r
set statusline+=\ [%{&ff}]
set statusline+=\ (%{strftime('%c',getftime(expand('%:p')))})
set statusline+=%=
set statusline+=%l,%c%V
set statusline+=\ %P
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}


"终端颜色
if has('termguicolors') && &term =~ 'xterm-256color\|alacritty\|kitty'
    set termguicolors
endif

" 编码设置
set encoding=UTF-8
set langmenu=zh_CN.UTF-8
language message zh_CN.UTF-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
set fileencoding=utf-8
set number
set vb t_vb=
au GuiEnter * set t_vb=
set tabstop=4
set softtabstop=4
set shiftwidth=4
set textwidth=79
set expandtab
set autoindent
set fileformat=unix
set fillchars=eob:\  " 最左侧不要～
set signcolumn=auto

" 剪贴板
if !empty($SSH_CONNECTION)
    set clipboard=
    augroup OSCYank
        autocmd!
        autocmd TextYankPost * if v:event.operator ==# 'y' | execute 'OSCYankReg "' | endif
    augroup END
    vnoremap cp <Plug>OSCYankVisual
else
    if has('clipboard')
        if s:is_windows || s:is_mac
            set clipboard=unnamed      " Windows/macOS 使用 * 寄存器
        else
            set clipboard=unnamedplus  " Linux 使用 + 寄存器
        endif
    endif
endif

" 插件管理
call plug#begin()
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'easymotion/vim-easymotion'
Plug 'Yggdroot/indentLine'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'preservim/nerdcommenter'
Plug 'chriszarate/yazi.vim'
Plug 'kien/rainbow_parentheses.vim'
Plug 'terryma/vim-expand-region'
Plug 'tpope/vim-surround'
Plug 'liuchengxu/vim-which-key'
Plug 'junegunn/vim-easy-align'

if !empty($SSH_CONNECTION)
    Plug 'ojroques/vim-oscyank', {'branch': 'main'}
elseif !s:is_windows
    Plug 'christoomey/vim-system-copy'
endif
call plug#end()

let g:airline_theme='onedark'

" Yazi 文件管理器
if s:is_windows
    let g:yazi_command = 'yazi.exe'
else
    let g:yazi_command = 'yazi'
endif
const g:yazi_exec_on_open = 'tabnew'

nnoremap <silent> - :Yazi<cr>
nnoremap <silent> _ :YaziWorkingDirectory<cr>
" nnoremap <silent> <C-v> :vsplit <bar> :Yazi<cr>

" 查看快捷键
let g:which_key_map = {}
let g:which_key_map.f = {
      \ 'name' : '+file',
      \ 'f' : [':Files', 'find file'],
      \ 'r' : [':NERDTreeToggle', 'file tree'],
      \ }
call which_key#register('<leader>', "g:which_key_map")
nnoremap <silent> <leader> :WhichKey '<leader>'<CR>


if empty($SSH_CONNECTION)
    let g:system_copy_silent = 1
endif

" 编译/运行/调试函数
" 检测 Python 命令
let s:python_cmd = ''
if executable('python3')
    let s:python_cmd = 'python3'
elseif executable('python')
    let s:python_cmd = 'python'
endif

func! CompileGcc()
    exec "w"
    let compilecmd="!gcc "
    let compileflag="-o %< "
    if s:is_windows
        let compileflag = "-o %<.exe "   " Windows 下生成 .exe 后缀
    endif
    if search("mpi\.h") != 0
        let compilecmd = "!mpicc "
    endif
    if search("glut\.h") != 0
        let compileflag .= " -lglut -lGLU -lGL "
    endif
    if search("cv\.h") != 0
        let compileflag .= " -lcv -lhighgui -lcvaux "
    endif
    if search("omp\.h") != 0
        let compileflag .= " -fopenmp "
    endif
    if search("math\.h") != 0
        let compileflag .= " -lm "
    endif
    exec compilecmd." % ".compileflag
endfunc

func! CompileGpp()
    exec "w"
    let compilecmd="!g++ -std=c++23 -fmodules-ts "
    let compileflag="-o %< "
    if s:is_windows
        let compileflag = "-o %<.exe "
    endif
    if search("mpi\.h") != 0
        let compilecmd = "!mpic++ "
    endif
    if search("glut\.h") != 0
        let compileflag .= " -lglut -lGLU -lGL "
    endif
    if search("cv\.h") != 0
        let compileflag .= " -lcv -lhighgui -lcvaux "
    endif
    if search("omp\.h") != 0
        let compileflag .= " -fopenmp "
    endif
    if search("math\.h") != 0
        let compileflag .= " -lm "
    endif
    exec compilecmd." % ".compileflag
endfunc

func! RunPython()
    if empty(s:python_cmd)
        echo "Python not found! Please install Python or set s:python_cmd manually."
        return
    endif
    exec "!" . s:python_cmd . " %"
endfunc

func! RunJS()
    if !executable('node')
        echo "nodejs not found! Please install nodejs."
        return
    endif
    exec "!node %"
endfunc

func! CompileJava()
    exec "!javac %"
endfunc

func! CompileCode()
    exec "w"
    if &filetype == "cpp"
        call CompileGpp()
    elseif &filetype == "c"
        call CompileGcc()
    elseif &filetype == "python"
        call RunPython()
    elseif &filetype == "java"
        call CompileJava()
    elseif &filetype =~ 'javascript\|typescript'
        call RunJS()
    endif
endfunc

func! RunResult()
    exec "w"
    if search("mpi\.h") != 0
        " MPI 运行，平台无关路径处理
        if s:is_windows
            exec "!mpirun -np 4 " . (executable("%<.exe") ? "%<.exe" : "%<")
        else
            exec "!mpirun -np 4 ./%<"
        endif
    elseif &filetype == "cpp" || &filetype == "c"
        if s:is_windows
            " 优先尝试 .exe，若无则使用无后缀文件
            exec "!" . (executable("%<.exe") ? "%<.exe" : "%<")
        else
            exec "!./%<"
        endif
    elseif &filetype == "python"
        call RunPython()
    elseif &filetype == "java"
        exec "!java %:t:r"
    endif
endfunc

func! Rungdb()
    if &filetype == "cpp"
        exec "w"
        if s:is_windows
            exec "!g++ -std=c++23 % -fmodules-ts -g -o %<.exe"
            exec "!gdb %<.exe"
        else
            exec "!g++ -std=c++23 % -fmodules-ts -g -o %<"
            exec "!gdb %<"
        endif
    elseif &filetype == "c"
        exec "w"
        if s:is_windows
            exec "!gcc % -g -o %<.exe"
            exec "!gdb %<.exe"
        else
            exec "!gcc % -g -o %<"
            exec "!gdb %<"
        endif
    elseif &filetype == "java"
        exec "w"
        exec "!javac %"
        exec "!jdb %<"
    elseif &filetype == "python"
        exec "w"
        if empty(s:python_cmd)
            echo "Python not found!"
            return
        endif
        exec "!" . s:python_cmd . " -m pdb %"
    endif
endfunc

" 快捷键映射 
map <F5> :call CompileCode()<CR>
imap <F5> <ESC>:call CompileCode()<CR>
vmap <F5> <ESC>:call CompileCode()<CR>
map <F6> :call RunResult()<CR>
map <F9> :call Rungdb()<CR>
vmap <A-c> cp
vmap v <Plug>(expand_region_expand)
vmap V <Plug>(expand_region_shrink)
map <C-n> :tabnew<CR>
map . :tabnext<CR>
map , :tabprevious<CR>
nnoremap <C-q> :q!<CR>
nnoremap <C-f> :Files<CR>
nnoremap <C-s> :w <CR>
inoremap <C-s> <ESC> :w<CR>i
nnoremap <F3> :NERDTreeToggle<CR>
nnoremap <F4> :NERDTreeMirror<CR>
nmap ss <Plug>(easymotion-s2)
inoremap <C-z> <ESC>:u <CR>i
inoremap <C-r> <ESC><C-r>i
nnoremap <silent> <C-l> zz
inoremap <C-l> <ESC> zzi
" Tab 缩进与Shift Tab 反缩进
vnoremap > >gv
vnoremap < <gv
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
nnoremap <Tab> >>
nnoremap <S-Tab> <<

" CoC 补全配置
set nobackup
set nowritebackup
set updatetime=300
set signcolumn=yes

" 使用 <Tab> 触发补全并导航
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" 回车确认补全
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" <c-space> 手动触发补全
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" 文本对齐
    " \a=        对齐等号表达
    " \a:        对齐冒号表达式(json/map等)
    "
    " # 默认左对齐
    " \a<space>  首个空格对齐
    " \a2<space> 第二个空格对齐
    " \a-<space> 倒数第一个空格对齐
    " \a-2<space> 倒数第二个空格对齐
    " \a*<space> 所有空格依次对齐
    "
    " # 右对齐
    " \a<Enter>*<space>

vmap <Leader>a <Plug>(EasyAlign)
nmap <Leader>a <Plug>(EasyAlign)
if !exists('g:easy_align_delimiters')
  let g:easy_align_delimiters    = {}
endif
let g:easy_align_delimiters['#'] = { 'pattern': '#', 'ignore_groups': ['String'] }

" 诊断导航
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" 代码导航
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" 显示文档
nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" 高亮符号
autocmd CursorHold * silent call CocActionAsync('highlight')

" 重命名符号
nmap <neader>rn <Plug>(coc-rename)

" 格式化选中区域
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" 代码操作
xmap <leader>c  <Plug>(coc-codeaction-selected)
nmap <leader>c  <Plug>(coc-codeaction-selected)
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
nmap <leader>as  <Plug>(coc-codeaction-source)
nmap <leader>qf  <Plug>(coc-fix-current)
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <leader>cl  <Plug>(coc-codelens-action)

" 文本对象
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" 滚动浮窗
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-,> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-,>"
  nnoremap <silent><nowait><expr> <C-.> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-.>"
  inoremap <silent><nowait><expr> <C-,> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-.> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-,> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-,>"
  vnoremap <silent><nowait><expr> <C-.> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-.>"
endif

" 范围选择
nmap <silent> <C-b> <Plug>(coc-range-select)
xmap <silent> <C-b> <Plug>(coc-range-select)

" 命令
command! -nargs=0 Format :call CocActionAsync('format')
command! -nargs=? Fold :call     CocAction('fold', <f-args>)
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" CocList 映射
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
inoremap <silent><expr> <c-space> coc#refresh()

" 光标形状
if has("autocmd") && !has("gui_running") && !s:is_windows && ($TERM =~ 'xterm\|rxvt\|screen\|tmux\|alacritty\|kitty')
  au VimEnter,InsertLeave * silent execute '!echo -ne "\e[2 q"' | redraw!
  au InsertEnter,InsertChange *
        \ if v:insertmode == 'i' |
        \   silent execute '!echo -ne "\e[6 q"' | redraw! |
        \ elseif v:insertmode == 'r' |
        \   silent execute '!echo -ne "\e[4 q"' | redraw! |
        \ endif
  au VimLeave * silent execute '!echo -ne "\e[ q"' | redraw!
endif

" 禁用 'c' 键
noremap c <Nop>
noremap C <Nop>
vnoremap c <Nop>
vnoremap C <Nop>

" NERD Commenter 设置 
let g:NERDCreateDefaultMappings = 1
let g:NERDSpaceDelims = 1
let g:NERDDefaultAlign = 'left'
let g:NERDCustomDelimiters = {
    \ 'php': { 'left': '/*','right': '*/' },
    \ 'html': { 'left': '<!--','right': '-->' },
    \ 'py': { 'left': '#' },
    \ 'sh': { 'left': '#' }
    \ }
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1

" 自动命令
if has("autocmd")
    autocmd BufReadPre COMMIT_EDITMSG,MERGE_MSG,git-rebase-todo setlocal fileencoding=utf-8
    autocmd BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$")
      \           && &filetype !~# 'commit\|gitrebase'
      \           && expand("%") !~ "ADD_EDIT.patch"
      \           && expand("%") !~ "addp-hunk-edit.diff" |
      \   exe "normal! g`\"" |
      \ endif
    autocmd BufNewFile,BufRead *.patch set filetype=diff
    autocmd Filetype diff
      \ highlight WhiteSpaceEOL ctermbg=red |
      \ match WhiteSpaceEOL /\(^+.*\)\@<=\s\+$/
endif

" 前面设置被覆盖了
set signcolumn=auto
