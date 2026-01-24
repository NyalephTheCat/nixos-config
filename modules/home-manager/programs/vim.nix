{ config, pkgs, lib, ... }:

{
  # Vim configuration with good defaults
  programs.vim = {
    enable = true;
    defaultEditor = false; # Set to true if you want vim as default editor
    
    # All vim settings and key mappings in extraConfig
    extraConfig = ''
      " Basic settings
      " Line numbers
      set number
      set relativenumber
      
      " Syntax highlighting
      syntax on
      
      " Search settings
      set incsearch      " Incremental search
      set hlsearch       " Highlight search results
      set ignorecase     " Case insensitive search
      set smartcase      " Case sensitive if uppercase in search
      
      " Indentation
      set autoindent
      set smartindent
      set tabstop=2      " Tab width
      set shiftwidth=2   " Indent width
      set expandtab      " Use spaces instead of tabs
      
      " Visual settings
      set showmatch      " Show matching brackets
      set showmode       " Show current mode
      set showcmd        " Show partial commands
      set ruler          " Show cursor position
      
      " Behavior
      set mouse=a        " Enable mouse support
      set backspace=indent,eol,start " Backspace behavior
      set wrap           " Wrap long lines
      set linebreak      " Break at word boundaries
      
      " File handling
      set nobackup       " Don't create backup files
      set nowritebackup
      set noswapfile     " Don't create swap files
      set undofile       " Persistent undo
      
      " Encoding
      set encoding=utf-8
      set fileencoding=utf-8
      
      " Performance
      set lazyredraw     " Don't redraw during macros
      set ttyfast        " Fast terminal connection
      
      " Key mappings
      " Better navigation
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l
      
      " Clear search highlighting with Esc
      nnoremap <Esc> :noh<CR><Esc>
      
      " Better indenting
      vnoremap < <gv
      vnoremap > >gv
      
      " Move between buffers
      nnoremap <leader>bn :bnext<CR>
      nnoremap <leader>bp :bprev<CR>
      nnoremap <leader>bd :bdelete<CR>
      
      " Quick save and quit
      nnoremap <leader>w :w<CR>
      nnoremap <leader>q :q<CR>
      nnoremap <leader>wq :wq<CR>
      
      " Set leader key to space
      let mapleader = " "
      
      " File type specific settings
      autocmd FileType python setlocal tabstop=4 shiftwidth=4
      autocmd FileType javascript setlocal tabstop=2 shiftwidth=2
      autocmd FileType json setlocal tabstop=2 shiftwidth=2
      autocmd FileType yaml setlocal tabstop=2 shiftwidth=2
      autocmd FileType nix setlocal tabstop=2 shiftwidth=2
      
      " Auto-remove trailing whitespace
      autocmd BufWritePre * :%s/\s\+$//e
      
      " Enable true color support
      if exists('+termguicolors')
        set termguicolors
      endif
    '';
    
    # Plugins (optional - can be extended)
    plugins = with pkgs.vimPlugins; [
      # Add popular plugins here if desired
      vim-nix
      vim-polyglot
      vim-airline
      vim-fugitive
    ];
  };
}

