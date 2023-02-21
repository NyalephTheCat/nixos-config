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
	neovim-sensible
	{
	  plugin = gruvbox-nvim;
	  type = "lua";
	  config = ''
	  vim.o.background = "dark"
	  vim.cmd([[colorscheme gruvbox]])
	  '';
	}
        {
          plugin = which-key-nvim;
          type = "lua";
          config = ''
          require("which-key")
          '';
        }
        vim-fugitive
        {
          plugin = neo-tree-nvim;
          type = "lua";
          config = ''
          require("neo-tree").setup {
            close_if_last_window = true,
            window = {
              width = 20,
            }
          }
          '';
        }
        vim-airline-themes
        {
          plugin = vim-airline;
          config = ''
            let g:airline_theme="base16_gruvbox_dark_hard"
            let g:airline#extensions#tabline#enabled = 1
            let g:airline#extensions#buffer_nr_show = 1
            let g:airline#powerline_fonts = 1
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
              }
            }
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


        {
          plugin = which-key-nvim;
          type = "lua";
          config = ''
            require("which-key").setup {
              layout = {
                height = { min = 4, max = 10 }
              }
            }
          '';
        }

        {
          plugin = markdown-preview-nvim;
          config = ''
            let g:mkpd_auto_start = 1
            let g:mkpd_auto_close = 1
          '';
        }
        {
          plugin = tex-conceal-vim;
          config = ''
            set conceallevel=2
          '';
        }

        {
	  plugin = vimsence;
	  config = ''
	  let g:vimsence_small_text = 'NeoVim'
          let g:vimsence_small_image = 'neovim'
	  '';
	}

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
