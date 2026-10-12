local servers = require('config.languages').servers

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end
        local builtin = require 'telescope.builtin'
        map('gd', builtin.lsp_definitions, 'Goto definition')
        map('gr', builtin.lsp_references, 'Goto references')
        map('gI', builtin.lsp_implementations, 'Goto implementation')
        map('<leader>D', builtin.lsp_type_definitions, 'Type definition')
        map('<leader>ds', builtin.lsp_document_symbols, 'Document symbols')
        map('<leader>ws', builtin.lsp_dynamic_workspace_symbols, 'Workspace symbols')
        map('<leader>rn', vim.lsp.buf.rename, 'Rename')
        map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
        map('K', vim.lsp.buf.hover, 'Hover documentation')
        map('gD', vim.lsp.buf.declaration, 'Goto declaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          local group = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = group,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = group,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd('LspDetach', {
            buffer = event.buf,
            group = group,
            callback = function(detach)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = group, buffer = detach.buf }
            end,
          })
        end
        if client and client.server_capabilities.inlayHintProvider then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }, { bufnr = event.buf })
          end, 'Toggle inlay hints')
        end
      end,
    })

    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    for name, config in pairs(servers) do
      vim.lsp.config(name, vim.tbl_deep_extend('force', { capabilities = capabilities }, config))
    end

    require('mason').setup()
    require('mason-tool-installer').setup { ensure_installed = require('config.languages').tools, run_on_start = #vim.api.nvim_list_uis() > 0 }
    require('mason-lspconfig').setup { ensure_installed = vim.tbl_keys(servers), automatic_enable = false }
    vim.lsp.enable(vim.tbl_keys(servers))
  end,
}
