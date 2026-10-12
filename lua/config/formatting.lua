local M = {}

local prettier_config = {
  '.prettierrc',
  '.prettierrc.json',
  '.prettierrc.yml',
  '.prettierrc.yaml',
  '.prettierrc.json5',
  '.prettierrc.toml',
  '.prettierrc.js',
  '.prettierrc.cjs',
  '.prettierrc.mjs',
  'prettier.config.js',
  'prettier.config.cjs',
  'prettier.config.mjs',
}

local function project_has_prettier(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == '' then
    return false
  end
  local root = vim.fs.root(file, prettier_config)
  if root then
    return true
  end
  local package_root = vim.fs.root(file, 'package.json')
  if not package_root then
    return false
  end
  local path = vim.fs.joinpath(package_root, 'package.json')
  local read_ok, lines = pcall(vim.fn.readfile, path)
  if not read_ok then
    return false
  end
  local ok, data = pcall(vim.json.decode, table.concat(lines, '\n'))
  return ok and type(data) == 'table' and data.prettier ~= nil
end

M.prettier = function(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr)
  local root = file ~= '' and vim.fs.root(file, 'package.json')
  local local_prettier = root and vim.fs.joinpath(root, 'node_modules/.bin/prettier')
  if local_prettier and vim.fn.executable(local_prettier) == 1 then
    return { 'prettier' }
  end
  if project_has_prettier(bufnr) then
    return { 'prettier' }
  end
  return {}
end

M.rubocop = function(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file ~= '' and vim.fs.root(file, '.rubocop.yml') then
    return { 'rubocop' }
  end
  return {}
end

M.opts = {
  notify_on_error = false,
  default_format_opts = { lsp_format = 'fallback' },
  format_on_save = function(bufnr)
    -- RuboCop can take a while to start in large projects; keep it on <leader>f.
    if vim.bo[bufnr].filetype == 'ruby' then
      return nil
    end
    local disabled = { c = true, cpp = true }
    return { timeout_ms = 750, lsp_format = disabled[vim.bo[bufnr].filetype] and 'never' or 'fallback' }
  end,
  formatters_by_ft = {
    lua = { 'stylua' },
    go = { 'gofmt' },
    python = { 'ruff_format' },
    ruby = M.rubocop,
    javascript = M.prettier,
    javascriptreact = M.prettier,
    typescript = M.prettier,
    typescriptreact = M.prettier,
    json = M.prettier,
    css = M.prettier,
    html = M.prettier,
    markdown = M.prettier,
  },
}

return M
