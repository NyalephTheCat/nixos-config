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
        
        home.packages = with pkgs; [
            rnix-lsp nixfmt # Nix
            sumneko-lua-language-server stylua # Lua
        ];

        programs.neovim = {
          enable = true;
          defaultEditor = true;
          vimAlias = true;
          viAlias = true;
            plugins = with pkgs.vimPlugins; [ 
                vim-nix
                plenary-nvim
                {
                    plugin = zk-nvim;
                    config = "lua require('zk').setup()";
                }
                {
                    plugin = jabuti-nvim;
                    config = "colorscheme jabuti";
                }
                {
                    plugin = impatient-nvim;
                    config = "lua require('impatient')";
                }
                {
                    plugin = lualine-nvim;
                    config = "lua require('lualine').setup()";
                }
                {
                    plugin = telescope-nvim;
                    config = "lua require('telescope').setup()";
                }
                {
                    plugin = indent-blankline-nvim;
                    config = "lua require('indent_blankline').setup()";
                }
                {
                    plugin = nvim-lspconfig;
                    config = ''
                        lua << EOF
                        local opts = { noremap = true, silent = true }
                        vim.keymaps.set('n', '<space>e', vim.diagnostics.open_float, opts)
                        vim.keymaps.set('n', '[d', vim.diagnostics.goto_prev, opts)
                        vim.keymaps.set('n', ']d', vim.diagnostics.goto_next, opts)
                        vim.keymaps.set('n', '<space>q', vim.diagnostics.setloclist, opts)

                        -- Uses an on_attach function to only map the following keys
                        --  after the language server attaches to the current buffer
                        local on_attach = function(client, bufnr)
                          -- Enable completion triggered by <c-x><c-o>
                          vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

                          -- Mappings
                          --  See `:help vim.lsp.*` for documentation on any of the below functions
                          local bufopts = { noremap = true, silent = true, buffer = bufnr }
                          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
                          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
                          vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
                          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
                          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
                          vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
                          vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
                          vim.keymap.set('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, bufopts)
                          vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
                          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
                          vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
                          vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
                          vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
                        end

                        require('lspconfig').rust_analyzer.setup{ on_attach = on_attach }
                        require('lspconfig').sumneko_lua.setup{ on_attach = on_attach }
                        require('lspconfig').rnix.setup{ on_attach = on_attach }
                        require('lspconfig').zk.setup{ on_attach = on_attach }
                        EOF
                    '';
                }
                {
                    plugin = nvim-treesitter;
                    config = ''
                    lua << EOF
                      require('nvim-treesitter.configs').setup {
                        highlight = {
                            enable = true,
                            additional_vim_regex_highlighting = false,
                        },
                    }
                    EOF
                    '';
                  }
                  {
                    plugin = vim-fugitive;
                  }
            ];

            extraConfig = ''
                luafile ~/.config/nvim/settings.lua
            '';
        };
    };
}
