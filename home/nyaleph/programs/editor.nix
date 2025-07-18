{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    extraPackages = with pkgs; [
      # Language servers
      lua-language-server
      nil # Nix LSP
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      rust-analyzer
      gopls
      pyright
      
      # Formatters
      nixpkgs-fmt
      rustfmt
      gofumpt
      black
      prettierd
      
      # Tools
      ripgrep
      fd
      tree-sitter
      gcc
    ];
    
    plugins = with pkgs.vimPlugins; [
      # Theme
      catppuccin-nvim
      
      # Core plugins
      nvim-treesitter.withAllGrammars
      plenary-nvim
      
      # LSP
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp_luasnip
      luasnip
      friendly-snippets
      
      # UI enhancements
      telescope-nvim
      telescope-fzf-native-nvim
      which-key-nvim
      nvim-tree-lua
      lualine-nvim
      bufferline-nvim
      indent-blankline-nvim
      gitsigns-nvim
      
      # Editing
      nvim-autopairs
      comment-nvim
      nvim-surround
      
      # Languages
      vim-nix
    ];
    
    extraLuaConfig = ''
      -- Basic settings
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.mouse = 'a'
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.hlsearch = false
      vim.opt.wrap = false
      vim.opt.breakindent = true
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true
      vim.opt.termguicolors = true
      vim.opt.signcolumn = 'yes'
      vim.opt.updatetime = 250
      vim.opt.timeoutlen = 300
      vim.opt.completeopt = 'menuone,noselect'
      vim.opt.undofile = true
      vim.opt.clipboard = 'unnamedplus'
      
      -- Set leader
      vim.g.mapleader = ' '
      vim.g.maplocalleader = ' '
      
      -- Theme
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
      })
      vim.cmd.colorscheme "catppuccin"
      
      -- Telescope
      require('telescope').setup({
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
        },
      })
      
      -- Telescope keymaps
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
      
      -- Treesitter
      require('nvim-treesitter.configs').setup({
        highlight = { enable = true },
        indent = { enable = true },
      })
      
      -- LSP
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      -- LSP servers
      lspconfig.lua_ls.setup({ capabilities = capabilities })
      lspconfig.nil_ls.setup({ capabilities = capabilities })
      lspconfig.tsserver.setup({ capabilities = capabilities })
      lspconfig.rust_analyzer.setup({ capabilities = capabilities })
      lspconfig.gopls.setup({ capabilities = capabilities })
      lspconfig.pyright.setup({ capabilities = capabilities })
      
      -- LSP keymaps
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, opts)
        end,
      })
      
      -- Completion
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
        })
      })
      
      -- File tree
      require("nvim-tree").setup()
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'File explorer' })
      
      -- Status line
      require('lualine').setup({
        options = {
          theme = 'catppuccin'
        }
      })
      
      -- Bufferline
      require("bufferline").setup({})
      
      -- Autopairs
      require('nvim-autopairs').setup({})
      
      -- Comment
      require('Comment').setup()
      
      -- Gitsigns
      require('gitsigns').setup()
      
      -- Which-key
      require('which-key').setup()
      
      -- Additional keymaps
      vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save' })
      vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'Quit' })
      vim.keymap.set('n', '<leader>h', ':noh<CR>', { desc = 'Clear highlights' })
    '';
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      # Theme
      catppuccin.catppuccin-vsc
      
      # Languages
      jnoortheen.nix-ide
      rust-lang.rust-analyzer
      golang.go
      ms-python.python
      ms-python.vscode-pylance
      ms-vscode.cpptools
      
      # Tools
      eamodio.gitlens
      ms-vscode-remote.remote-ssh
      ms-azuretools.vscode-docker
      github.copilot
      
      # Formatters
      esbenp.prettier-vscode
      
      # General
      vscodevim.vim
      yzhang.markdown-all-in-one
    ];
    
    userSettings = {
      "workbench.colorTheme" = "Catppuccin Mocha";
      "editor.fontFamily" = "'JetBrainsMono Nerd Font', monospace";
      "editor.fontSize" = 14;
      "editor.fontLigatures" = true;
      "editor.formatOnSave" = true;
      "editor.minimap.enabled" = false;
      "editor.rulers" = [ 80 120 ];
      "editor.renderWhitespace" = "trailing";
      "editor.suggestSelection" = "first";
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      
      "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
      "terminal.integrated.fontSize" = 14;
      
      "vim.useSystemClipboard" = true;
      "vim.hlsearch" = true;
      "vim.insertModeKeyBindings" = [
        {
          "before" = ["j" "j"];
          "after" = ["<Esc>"];
        }
      ];
      
      "git.autofetch" = true;
      "git.confirmSync" = false;
      
      "files.autoSave" = "afterDelay";
      "files.autoSaveDelay" = 1000;
      "files.trimTrailingWhitespace" = true;
      
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
      };
    };
  };
}
