{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;
    withRuby = false;
    withPython3 = false;
    plugins = with pkgs.vimPlugins; [
      lsp-format-nvim
      nerdtree-git-plugin
      plenary-nvim # lua lib
      tcomment_vim # hotkey: gc
      vim-devicons
      vim-repeat
      vim-sleuth # automatic indentation size detection
      vim-unimpaired
      nvim-cmp
      vim-airline-themes
      vim-gh-line
      {
        plugin = vim-airline;
        type = "viml";
        config = ''
          let g:airline_theme = 'deus'
          let g:airline_powerline_fonts = 1
        '';
      }
      {
        plugin = nvim-surround;
        type = "lua";
        config = ''
          require("nvim-surround").setup()
        '';
      }
      {
        plugin = telescope-nvim;
        type = "viml";
        config = ''
          lua << EOF
          require('telescope').setup{
            defaults = {
              prompt_prefix = "🔍",
              mappings = {
                i = {
                  ["<Esc>"] = require('telescope.actions').close,
                }
              },
              layout_config = {
                width = .99,
                height = .99
              },
            },
          }
          EOF

          nnoremap <C-l> <cmd>Telescope git_files<cr>
          nnoremap <C-g> <cmd>Telescope live_grep<cr>
          nnoremap <C-n> <cmd>Telescope grep_string<cr>
          nnoremap <C-p> <cmd>Telescope resume<cr>
        '';
      }
      {
        plugin = vim-nerdtree-syntax-highlight;
        type = "viml";
        config = ''
          let s:blue = "689FB6"
          let s:lightPurple = "834F79"

          let g:NERDTreeExtensionHighlightColor = {}
          let g:NERDTreeExtensionHighlightColor['nix'] = s:blue
          let g:NERDTreeExtensionHighlightColor['hs'] = s:lightPurple

          let g:WebDevIconsDisableDefaultFolderSymbolColorFromNERDTreeDir = 1
          let g:WebDevIconsDisableDefaultFileSymbolColorFromNERDTreeFile = 1
        '';
      }
      {
        plugin = nerdtree;
        type = "viml";
        config = ''
          autocmd StdinReadPre * let s:std_in=1
          autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

          let g:NERDTreeDirArrows = 1
          let g:NERDTreeMinimalUI = 1
          let g:NERDTreeMouseMode = 2

          noremap <C-t> :NERDTreeToggleVCS<CR>
          noremap <C-f> :NERDTreeFind<CR>;
        '';
      }
      # {
      #   plugin = nvim-lspconfig;
      #   config = ''
      #     :luafile ${./lsp.lua}
      #   '';
      # }
      {
        plugin = vim-better-whitespace;
        type = "viml";
        config = ''
          let g:better_whitespace_enabled = 1
          let g:strip_whitespace_on_save = 1
          let g:strip_whitespace_confirm = 0
          let g:strip_whitelines_at_eof = 1
          let g:show_spaces_that_precede_tabs = 1
          let g:better_whitespace_filetypes_blacklist = ['diff', 'git', 'gitcommit', 'unite', 'qf', 'help', 'fugitive']
        '';
      }
      {
        plugin = none-ls-nvim;
        type = "lua";
        config = ''
          local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
          local null_ls = require("null-ls")

          null_ls.setup({
            sources = {
              null_ls.builtins.code_actions.statix,
              null_ls.builtins.diagnostics.statix,
              null_ls.builtins.diagnostics.deadnix,
            },
            -- you can reuse a shared lspconfig on_attach callback here
            on_attach = function(client, bufnr)
                if client:supports_method("textDocument/formatting") then
                    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        group = augroup,
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({ async = false })
                        end,
                    })
                end
            end,
          })
        '';
      }
    ];
    extraConfig = ''
      source ${./sweet-theme.vim}
    ''
    + builtins.readFile ./vimrc.vim;
  };

  home.packages = with pkgs; [
    bash-language-server
    ripgrep
    # required for copy to clipboard
    xclip
    nil
    haskellPackages.cabal-fmt
    statix
    deadnix
    nixd
  ];
}
