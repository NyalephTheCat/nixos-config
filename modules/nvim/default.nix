{ lib, config, pkgs, ... }:
with lib;
let
    cfg = config.modules.nvim;
    # Source my theme
    jabuti-nvim = pkgs.vimUtils.buildVimPlugin {
        name = "jabuti-nvim";
        src = pkgs.fetchFromGitHub {
            owner = "jabuti-theme";
            repo = "jabuti-nvim";
            rev = "17f1b94cbf1871a89cdc264e4a8a2b3b4f7c76d2";
            sha256 = "sha256-iPjwx/rTd98LUPK1MUfqKXZhQ5NmKx/rN8RX1PIuDFA=";
        };
    };
in {
    options.modules.nvim = { enable = mkEnableOption "nvim"; };
    config = mkIf cfg.enable {

      home.file.".config/nvim/settings.lua".source = ./init.lua;
      home.wraplings = {
        view = "nvim -R";
        vimagit = "nvim +MagitOnly";
      };
      home.sessionVariables.EDITOR = "nvim";
        
        programs.neovim = {
          enable = true;
          defaultEditor = true;
          vimAlias = true;
          viAlias = true;

          withRuby = false;
          withNodeJs = true;

          extraPackages = with pkgs; [
            yaml-language-server
            # TODO add more packages here
          ] ++ lib.optionals (withLang "bash") [
            nodePackages.bash-language-server
          ] ++ lib.optionals (withLang "c") [
            gnumake # FOR :make
            ccls
          ] ++ lib.optionals (withLang "haskell") [
            haskell-language-server
          ] ++ lib.optionals (withLang "nix") [
            rnix-lsp
            nil
          ] ++ lib.optionals (withLang "python") (with python3Packages; [
            # TODO switch to pyright alone or at least make flake8 quieter
            pyright
            python-lsp-server
            flake8
            pycodestyle
            autopep8
          ]) ++ lib.optionals (withLang "rust") [
            rust-analyzer
          ];

          plugins = with pkgs.vimPlugins; [
            # Fancy plugins: treesitter
            # playground # :TSHighlightCaptureUnerCursor,
                         # :help treesitter-highlight-groups
            {
              plugins = (nvim-treesitter.withPlugins (plugins: with plugins;
              [ dockerfile git_rebase help meson
                regex sql
                html markdown markdown_inline
                json json5 toml yaml
              ]
              ++ lib.optionals (withLang "bash") [ bash ]
              ++ lib.optionals (withLang "c") [ c ]
              ++ lib.optionals (withLang "haskell") [ haskell ]
              ++ lib.optionals (withLang "nix") [ nix ]
              ++ lib.optionals (withLang "python") [ python ]
              ++ lib.optionals (withLang "rust") [ rust ]
              ));
              type = "lua"
              config = ''
                require'nvim-treesitter.configs'.setup {
                  highlight = {
                    enable = true,
                    -- additional_vim_regex_highlighting = false,
                  };
                }
                -- vim.api.nvim_set_hl(0, "@none", { link = "Normal" })
              '';
            }

            # Fancy plugins: LSP
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

                local opts = { noremap = true, silent = true }
                vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
                vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
                vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
                vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
                local on_attach = function(_client, bufnr)
                   vim.api.nvim_buf_set_option(bufnr, 'omnifunc',
                                              'v:lua.vim.lsp.omnifunc')
                   local bufopts = { noremap = true, silent = true, buffer = bufnr }
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
                 lspconfig.yamlls.setup{on_attach=on_attach}
               '' + lib.optionalString (withLang "bash") ''
                 lspconfig.bashls.setup{on_attach=on_attach}
               '' + lib.optionalString (withLang "c") ''
                 lspconfig.ccls.setup{on_attach=on_attach}
               '' + lib.optionalString (withLang "haskell") ''
                 lspconfig.hls.setup{on_attach=on_attach}
               '' + lib.optionalString (withLang "nix") ''
                 lspconfig.rnix.setup{on_attach=on_attach}
               '' + lib.optionalString (withLang "python") ''
                 lspconfig.pylsp.setup{
                   on_attach = on_attach,
                   settings = {
                     pylsp = {
                       plugins = {
                         flake8 = {
                           enabled = true,
                           -- pyright overlap
                           ignore = {'F811', 'F401', 'F821', 'F841'},
                         },
                         pycodestyle = {
                           enabled=true,
                         },
                       },
                     },
                   },
                 }
                 lspconfig.pyright.setup{
                   on_attach = on_attach,
                     settings = {
                       python = {
                         analysis = {
                           typeCheckingMode = 'basic',
                           diagnosticSeverityOverrides = {
                             reportConstantRedefinition = 'warning',
                             reportDuplicateImport = 'warning',
                             reportMissingSuperCall = 'warning',
                             reportUnnecessaryCast = 'warning',
                             reportUnnecessaryComparison = 'warning',
                             reportUnnecessaryContains = 'warning',
                             reportCallInDefaultInitializer = 'info',
                             reportFunctionMemberAccess = 'info',
                             reportImportCycles = 'info',
                             reportMatchNotExhaustive = 'info',
                             reportShadowedImports = 'info',
                             reportUninitializedInstanceVariable = 'info',
                             reportUnnecessaryIsInstance = 'info',
                             reportUnusedClass = 'info',
                             reportUnusedFunction = 'info',
                             reportUnusedImport = 'info',
                             reportUnusedVariable = 'info',
                           },
                         },
                       },
                     },
                   }
                '' + lib.optionalString (withLang "rust") ''
                  lspconfig.rust_analyzer.setup{on_attach=on_attach}
                '';
              }
              {
                plugin = lsp_signature.nvim;
                type = "lua";
                config = ''
                  require'lsp_signature'.setup{
                    hint_prefix = "",
                    hint_scheme = "LSPVirtual",
                    floating_window = false,
                  }
                '';
              }

              # Fancy plugins: autocompletion and snippets
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

                  cmp.setup(
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
                      disallow_fizzy_matching = true,
                      disallow_partial_matching = true,
                      disallow_prefix_matching = true,
                    },
                    mapping = {
                      ['<C-Space>'] = cmp.mapping.confirm({ select = false }),
                      ['<C-Tab>'] = cmp.mapping.complete_common_string(),
                      ['<Tab>'] = cmp.mapping(function(fallback))
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
                  )
                '';
              }

              # Less fancy plugins to update to nvim
              vim-eunuch # Helper for UNIX :SudoWrite :Rename, ...
              vim-lastplace # Remember last position
              vim-nix # Syntax files and indentation
              vim-repeat # Better repetition
              vim-sleuth # Guess indentation
              tcomment_vim # <gc> comment action
              vi-undofile-warn # undofile enable + warning on overundoing
              {
                plugin = vim-better-whitespace;
                config = ''
                  let g:show_spaces_that_precede_tabs = 1
                '';
              }
              {
                plugin = vim-sneak; # Faster motion bount to <s>
                config = ''
                  let g:sneak#target_labels = "tnaowyfu'x,c,rise" " Combos start with last
                '';
              }
              vim-gitgutter
              {
                plugin = vim-indent-guides;
                config = ''
                  let g:indent_guides_enable_on_vim_startup = 1
                '';
              }
              {
                # TODO: use own theme,
                # fix nested highlighting problems with hard overrides
                plugin = vim-boring;  # non-clownish color theme
                config = ''
                  set termguicolors
                  colorscheme boring
                  set colorcolumn=80
                  hi ColorColumn guifg=#ddbbbb guibg=#0a0a0a
                  set wildoptions=pum
                  set pumblend=20
                  set winblend=20
                  hi Pmenu guifg=#aaaaaa
                '';
              }
              {
                plugin = vimagit;  # my preferred git interface for committing
                config = ''
                  let g:magit_auto_close = 1
                '';
              }
            ];
            extraConfig = ''
              set shell=/bin/sh
              set laststatus=1 " Display statusline if there are at least two windows
              set suffixes+=.pdf " Don't offer to open pdfs
              set scrolloff=10
              set diffopt+=algorithm:patience
              set updatetime=500
              set title noruler noshowmode
              function! NiceMode()
                let mode_map = {
                  \  'n': ''', 'i': '[INS]', 'R': '[RPL]', 
                  \  'v': '[VIS]', 'V': '[VIL]', "\<C-v>": '[S-B]',
                  \  't': '[TRM]'
                  \ }
                return get(mode_map, mode(), '[???]')
              endfunction
              let &titlestring = "vi > %y %t%H%R > %P/%LL %-13.(%l:%c%V %{NiceMode()})%"
              set titlelen=200
            ''
        };
    };
}
