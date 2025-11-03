-- local opts = { noremap=true, silent=true }
-- vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
-- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
-- vim.keymap.set('n', '<space>c', vim.lsp.buf.code_action, bufopts)
--
-- -- Use an on_attach function to only map the following keys
-- -- after the language server attaches to the current buffer
-- local on_attach = function(client, bufnr)
--   -- Enable completion triggered by <c-x><c-o>
--   vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
--
--   -- Mappings.
--   -- See `:help vim.lsp.*` for documentation on any of the below functions
--   local bufopts = { noremap=true, silent=true, buffer=bufnr }
--   vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
--   vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
--   vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
--   vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
--   vim.keymap.set('n', '<C-w>', vim.lsp.buf.signature_help, bufopts)
--   vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
--   vim.keymap.set('n', '<space>r', vim.lsp.buf.rename, bufopts)
--   vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
--   end

local servers = {
  {'bashls'},
  {'nixd'},
}

vim.api.nvim_create_augroup("AutoFormat", {})
vim.api.nvim_create_autocmd("BufWritePost", {
    group = "AutoFormat",
    pattern = "*.nix",
    callback = function()
        vim.cmd("silent !nixpkgs-fmt %")
        vim.cmd("edit")
    end,
})

for _, server in pairs(servers) do
  local lsp = require 'lspconfig'
  local util = require 'lspconfig.util'
  local config = lsp[server[1]]

  -- Only setup a language server if we have the binary available!
  -- if (util.has_bins(config.document_config.default_config.cmd[1])) then
  if vim.fn.executable(config.document_config.default_config.cmd[1]) == 1 then
    local setup_config = {
      on_attach = on_attach,
      flags = {
        -- This will be the default in neovim 0.7+
        debounce_text_changes = 150,
      }
    }

    -- Add custom config if available
    for k, v in pairs(server) do
      if type(k) ~= 'number' then
        setup_config[k] = v
      end
    end

    config.setup(setup_config)
  end
end
