local function read_file(path)
  local file = io.open(path, 'r')
  if not file then
    return ''
  end
  local content = file:read '*a'
  file:close()
  return content
end

return {
  'olimorris/codecompanion.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter', 'Davidyz/VectorCode' },
  config = function()
    require('codecompanion').setup {
      interactions = {
        chat = {
          adapter = 'anthropic',
          opts = {
            system_prompt = function()
              local global = read_file(vim.fn.expand '~/.claude/CLAUDE.md')
              local project = read_file(vim.fn.getcwd() .. '/CLAUDE.md')
              local parts = vim.tbl_filter(function(text)
                return text ~= ''
              end, { global, project })
              return #parts > 0 and table.concat(parts, '\n\n---\n\n') or 'You are a helpful coding assistant.'
            end,
          },
        },
        inline = { adapter = 'ollama' },
      },
      adapters = {
        http = {
          ollama = function()
            return require('codecompanion.adapters').extend('ollama', { schema = { model = { default = 'qwen2.5-coder:7b' } } })
          end,
        },
      },
      extensions = { vectorcode = { opts = { tool_group = { enabled = true } } } },
    }
  end,
  keys = {
    { '<leader>cc', '<cmd>CodeCompanionChat Toggle<cr>', desc = 'CodeCompanion chat' },
    { '<leader>ci', '<cmd>CodeCompanion<cr>', mode = { 'n', 'v' }, desc = 'CodeCompanion inline' },
    { '<leader>cp', '<cmd>CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'CodeCompanion actions' },
  },
}
