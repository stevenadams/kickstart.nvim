return {
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    priority = 1000,
    config = function()
      require('rose-pine').setup { variant = 'main', dark_variant = 'main', extend_background_behind_borders = true }
      vim.cmd.colorscheme 'rose-pine'
    end,
  },
  {
    'mawkler/modicator.nvim',
    dependencies = { 'rose-pine/neovim' },
    init = function()
      vim.opt.termguicolors = true
    end,
    opts = { show_warnings = true },
  },
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
      local wk = require 'which-key'
      wk.setup()
      wk.add {
        { '<leader>c', group = '[C]ode' },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      }
    end,
  },
}
