local languages = require('config.languages').parsers
local configured = vim.iter(languages):fold({}, function(acc, lang)
  acc[lang] = true
  return acc
end)

return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local treesitter = require 'nvim-treesitter'
    -- Headless setup commands install parsers explicitly and wait for completion.
    if #vim.api.nvim_list_uis() > 0 then
      treesitter.install(languages)
    end
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter-features', { clear = true }),
      callback = function(event)
        local ft = vim.bo[event.buf].filetype
        local lang = vim.treesitter.language.get_lang(ft) or ft
        if not configured[lang] or not vim.treesitter.language.add(lang) then
          return
        end
        vim.treesitter.start(event.buf, lang)
        if ft ~= 'ruby' then
          vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
