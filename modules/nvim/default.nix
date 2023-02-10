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

	cmp-nvim-lsp
	luasnip
	cmp_luasnip
	friendly-snippets
	{
          plugin = nvim-cmp;
	  type = "lua";
	  config = ''
	    require('luasnip.loaders.from_vscode').lazy_load()

	    vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
	    local cmp = require('cmp')
	    local luasnip = require('luasnip')
	    local check_backspace = function()
	      local col = vim.fn.col(".") - 1
	      return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
	    end

	    cmp.setup {
              completion = { autocomplete = false },
	      snippet = {
                expand = function(args)
		  luasnip.lsp_expand(args.body)
		end
	      },
	      sources = cmp.config.sources({
                { name = 'path' },
		{ name = 'nvim_lsp' },
	      }, {
                { name = 'luasnip' },
		{ name = 'buffer' },
	      }),
	      matching = {
                disallow_fuzzy_matching = true,
		disallow_partial_matching = true,
		disallow_prefix_matching = true,
	      },
	      mapping = {
                ['<C-Space>'] = cmp.mapping.confirm({ select = false }),
		['<C-Tab>'] = cmp.mapping.complete_common_string(),
		['<Tab>'] = cmp.mapping(function(fallback)
		  if cmp.visible() then
		    if not cmp.complete_common_string() then
		      cmp.select_next_item(select_opts)
		    end
		  elseif check_backspace() then
		    fallback()
		  elseif luasnip.expandable() then
		    luasnip.expand()
		  elseif luasnip.expand_or_locally_jumpable() then
		    luasnip.expand_or_jump()
		  else
		    cmp.complete()
		  end
		end, {'i', 's'}),
		['<S-Tab>'] = cmp.mapping(function(fallback)
		  if cmp.visible() then
		    cmp.select_prev_item(select_opts)
		  elseif luasnip.locally_jumpable(-1) then
		    luasnip.jump(-1)
		  else
		    fallback()
		  end
		end, {'i', 's'}),
	      }
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
            autocmd BufWritePost * GitGutter
	    let g:gitgutter_highlight_liners = 1
	    :set signcolumn=yes
	    autocmd VimEnter,Colorscheme * :hi GitGutterAddLine guibg=#002200
	    autocmd VimEnter,Colorscheme * :hi GitGutterChangeLine guibg=#222200
	    autocmd VimEnter,Colorscheme * :hi GitGutterDeleteLine guibg=#220000
	    autocmd VimEnter,Colorscheme * :hi GitGutterChangeDeleteLine guibg=#220022
	    nnoremap <silent> gl :GitGutterLineHighlightsToggle<CR>:IndentGuidesToggle<CR>
	  '';
	}
	{
          plugin = vim-indent-guides;
	  config = ''
	    let g:indent_guides_enable_on_vim_startup = 1
	    let g:indent_guides_auto_colors = 0
	    autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd guibg=#000000
	    autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#0e0e0e
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

	vim.o.undofile = true
      '';
    };
  };
}
