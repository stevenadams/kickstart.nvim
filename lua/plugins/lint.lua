return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    local lint = require 'lint'
    lint.linters_by_ft = {
      python = { 'ruff' },
      sh = { 'shellcheck' },
      bash = { 'shellcheck' },
    }

    local function run()
      local ft = vim.bo.filetype
      if ft == 'oil' or vim.api.nvim_buf_get_name(0) == '' then
        return
      end
      if ft == 'javascript' or ft == 'javascriptreact' or ft == 'typescript' or ft == 'typescriptreact' then
        local file = vim.api.nvim_buf_get_name(0)
        local root = file ~= ''
          and vim.fs.root(
            file,
            { 'eslint.config.js', 'eslint.config.mjs', 'eslint.config.cjs', '.eslintrc', '.eslintrc.json', '.eslintrc.js', '.eslintrc.cjs' }
          )
        if root and vim.fn.executable(vim.fs.joinpath(root, 'node_modules/.bin/eslint')) == 1 then
          lint.try_lint('eslint', { cwd = root })
        end
      elseif ft == 'ruby' then
        local file = vim.api.nvim_buf_get_name(0)
        local root = file ~= '' and vim.fs.root(file, '.rubocop.yml')
        if root then
          lint.try_lint('rubocop', { cwd = root })
        end
      else
        if lint.linters_by_ft[ft] then
          lint.try_lint()
        end
      end
    end

    vim.api.nvim_create_autocmd({ 'FileType', 'BufWritePost' }, {
      group = vim.api.nvim_create_augroup('local-lint', { clear = true }),
      callback = run,
    })
  end,
}
