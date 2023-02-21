{ lib, config, pkgs, ... }:
with lib;
let cfg = config.modules.nvim;
    withLang = lang: builtins.elem lang config.language-support;
in
{
  options.modules.nvim = {
    enable = mkOption {
      default = true;
      example = true;
      description = "Whether to enable neovim.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables.EDITOR = "nvim";

    home.packages = [
      pkgs.rust-analyzer
      pkgs.gcc
    ];

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;

      extraPackages = with pkgs; [
        yaml-language-server
        rnix-lsp nil # TODO move this to own optionals
      ] ++ optionals (withLang "bash") [
        nodePackages.bash-language-server
      ] ++ optionals (withLang "c") [
        gnumake
	ccls
      ] ++ optionals (withLang "nix") [
        rnix-lsp
	nil
      ] ++ optionals (withLang "python") (with python3Packages; [
        pyright
	python-lsp-server
	flake8
	pycodestyle
	autopep8
      ]) ++ optionals (withLang "rust") [
        rust-analyzer
      ];

      plugins = with pkgs.vimPlugins; [
	# Fancy plugins
	{
	  plugin = tokyonight-nvim;
	  type = "lua";
	  config = ''
	    vim.o.background = "dark"

	    require('tokyonight').setup({
	      dim_inactive = true,
	      comments = { italic = true },
	    });

	    vim.o.colorscheme = "tokyonight"
	  '';
	}
        {
	  plugin = (nvim-treesitter.withPlugins (plugins: with plugins; [
            dockerfile
	    git_rebase
	    help
	    meson
	    regex
	    sql
	    html
	    markdown
	    markdown_inline
	    json
	    json5
	    toml
	    yaml
	  ] ++ optionals (withLang "bash") [ bash ]
	    ++ optionals (withLang "c") [ c ]
	    ++ optionals (withLang "nix") [ nix ]
	    ++ optionals (withLang "python") [ python ]
	    ++ optionals (withLang "rust") [ rust ]
	  ));
	  type = "lua";
	  config = ''
            require'nvim-treesitter.configs'.setup {
              highlight = {
                enable = true,
	      };
	    }
	  '';
	}

	{
	  plugin = markdown-preview-nvim;
	  config = ''
	    let g:mkpd_auto_start = 1
	    let g:mkpd_auto_close = 1
	    let g:mkpd_echo_preview_url = 1
	    let g:mkpd_preview_options = {
	      \ 'mkit': {},
	      \ 'katex': {},
	      \ 'uml': {},
	      \ 'maid': {},
	      \ 'disable_sync_scroll': 0,
	      \ 'sync_scroll_type': 'relative',
	      \ 'hide_yaml_meta': 1,
	      \ 'sequence_diagrams': {},
	      \ 'flowchart_diagrams': {},
	      \ 'content_editable': v:false,
	      \ 'disable_filename': 0,
	      \ 'toc': {}
	      \ }

	      let g:mkdp_theme = 'light'
	  '';
	}

	{
          plugin = nvim-lspconfig;
	  type = "lua";
	  config = ''
            local lspconfig = require('lspconfig')
	    local lsp_defaults = lspconfig.util.default_config

	    lsp_defaults.capabilities = vim.tbl_deep_extend(
              'force',
	      lsp_defaults.capabilities,
	      require('cmp_nvim_lsp').default_capabilities()
	    )

	    local opts = { noremap = true, silent = true, }

            vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
            vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

            local on_attach = function(_client, bufnr)
	      vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
	      local bufopts = { noremap = true, silent = true, buffer = buffer, }

	      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
	      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
	      vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
	      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
	      vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
	      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
	      vim.keymap.set('n', '<space>r', vim.lsp.buf.rename, bufopts)
	      vim.keymap.set('n', '<space>a', vim.lsp.buf.code_action, bufopts)
	      vim.keymap.set('n', '<space>f', function()
	        vim.lsp.buf.format { async = true }
	      end, bufopts)
	    end

	    lspconfig.yamlls.setup { on_attach = on_attach }
	  '' + optionalString (withLang "bash") ''
            lspconfig.bashls.setup { on_attach = on_attach }
	  '' + optionalString (withLang "c") ''
            lspconfig.ccls.setup { on_attach = on_attach }
          '' + optionalString (withLang "nix") ''
            lspconfig.rnix.setup { on_attach = on_attach }
	  '' + optionalString (withLang "python") ''
	    lspconfig.pylsp.setup {
              on_attach = on_attach,
            }
	    lspconfig.pyright.setup {
              on_attach = on_attach
	    }

	  '' + optionalString (withLang "rust") ''
            lspconfig.rust_analyzer.setup { on_attach = on_attach }
	  '';
	}
	{
          plugin = lsp_signature-nvim;
	  type = "lua";
	  config = ''
	    require'lsp_signature'.setup {
              hint_prefix = "",
	      hint_scheme = "LSPVirtual",
	      floating_window = false,
	    }
	  '';
	}

	{
	  plugin = vimsence;
	  config = ''
	  let g:vimsence_small_text = 'NeoVim'
          let g:vimsence_small_image = 'neovim'
	  '';
	}
	{
	  plugin = which-key-nvim;
	  type = "lua";
	  config = ''
	    require("which-key").setup({
	      plugins = {
	        marks = true, -- shows a list of your marks on ' and `
	        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
	        spelling = {
	          enabled = false, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
	          suggestions = 20, -- how many suggestions should be shown in the list?
		},
		-- the presets plugin, adds help for a bunch of default keybindings in Neovim
		-- No actual key bindings are created
		presets = {
		  operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
		  motions = true, -- adds help for motions
		  text_objects = true, -- help for text objects triggered after entering an operator
		  windows = true, -- default bindings on <c-w>
		  nav = true, -- misc bindings to work with windows
		  z = true, -- bindings for folds, spelling and others prefixed with z
		  g = true, -- bindings for prefixed with g
		},
	      },
	      -- add operators that will trigger motion and text object completion
	      -- to enable all native operators, set the preset / operators plugin above
	      operators = { gc = "Comments" },
	      key_labels = {
		-- override the label used to display some keys. It doesn't effect WK in any other way.
		-- For example:
		-- ["<space>"] = "SPC",
		-- ["<cr>"] = "RET",
		-- ["<tab>"] = "TAB",
	      },
	      icons = {
		breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
		separator = "➜", -- symbol used between a key and it's label
		group = "+", -- symbol prepended to a group
	      },
	      popup_mappings = {
		scroll_down = '<c-d>', -- binding to scroll down inside the popup
	        scroll_up = '<c-u>', -- binding to scroll up inside the popup
	      },
	      window = {
		border = "none", -- none, single, double, shadow
		position = "bottom", -- bottom, top
	        margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
	        padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
	        winblend = 0
	      },
	      layout = {
		height = { min = 4, max = 25 }, -- min and max height of the columns
	        width = { min = 20, max = 50 }, -- min and max width of the columns
	        spacing = 3, -- spacing between columns
	        align = "left", -- align columns left, center or right
	      },
	      ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
	      hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ "}, -- hide mapping boilerplate
	      show_help = true, -- show help message on the command line when the popup is visible
	      show_keys = true, -- show the currently pressed key and its label as a message in the command line
	      triggers = "auto", -- automatically setup triggers
	      -- triggers = {"<leader>"} -- or specify a list manually
	      triggers_blacklist = {
	        -- list of mode / prefixes that should never be hooked by WhichKey
	        -- this is mostly relevant for key maps that start with a native binding
		-- most people should not need to change this
	        i = { "j", "k" },
	        v = { "j", "k" },
	      },
	      -- disable the WhichKey popup for certain buf types and file types.
	      -- Disabled by deafult for Telescope
	      disable = {
	        buftypes = {},
	        filetypes = { "TelescopePrompt" },
	      },
	    })
	  '';
	}

	cmp-nvim-lsp
	luasnip
	cmp_luasnip
	friendly-snippets
	{
	  plugin = crates-nvim;
	  type = "lua";
	  config = ''
	    require('crates').setup()
	  '';
	}
	{
          plugin = nvim-cmp;
	  type = "lua";
	  config = ''
	    require('luasnip.loaders.from_vscode').lazy_load()

	    -- vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
	    local cmp = require('cmp')
	    local luasnip = require('luasnip')
	    local check_backspace = function()
	      local col = vim.fn.col(".") - 1
	      return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
	    end

	    cmp.setup {
	      view = {
		entries = "custom",
	      },
	      snippet = {
                expand = function(args)
		  luasnip.lsp_expand(args.body)
		end
	      },
	      mapping = cmp.mapping.preset.insert({
		['<Down>'] = cmp.mapping(cmp.mapping.select_next_item({
		  behavior = cmp.SelectBehavior.Select
		}), {'i', 's'}),
		['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item({
		  behavior = cmp.SelectBehavior.Select
		}), {'i', 's'}),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
	      }),
	      sources = cmp.config.sources({
                { name = 'path' },
		{ name = 'nvim_lsp' },
		{ name = 'crates' },
	      }, {
                { name = 'luasnip' },
		{ name = 'buffer' },
	      }),
	      matching = {
                disallow_fuzzy_matching = true,
		disallow_partial_matching = true,
		disallow_prefix_matching = true,
	      },
	    }
	  '';
	}

        # Ugly vim9 plugins
	vim-eunuch
	vim-lastplace
	vim-nix
	vim-repeat
	vim-sleuth
	tcomment_vim
	{
          plugin = vim-better-whitespace;
	  config = ''
            let g:show_spaces_that_precede_tabs = 1
	  '';
	}
	{
	  plugin = vim-gitgutter;
	  config = ''
	    :set signcolumn=yes
	  '';
	}

        # TODO configure plugins here
      ];

      extraLuaConfig = ''
	vim.g.mapleader = ','

	vim.o.clipboard = 'unnamedplus'

	vim.o.noswapfile = true

	vim.o.wildignore = '*.o,*.obj,*.bin,*.git,*/__pycache__/*,/build/**,*.pyc'
	vim.o.wildignorecase = true

	vim.o.tabstop = 2
	vim.o.softtabstop = 2
	vim.o.shiftwidth = 2
	vim.o.expandtab = true

	vim.o.number = true
	vim.o.relativenumber = true

	vim.o.colorcolumn = 80

	vim.o.undofile = true
      '';
    };
  };
}
