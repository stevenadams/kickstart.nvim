-- GUI and terminal Neovim should both find Homebrew's Ruby and Java, not macOS's system versions.
local prefixes = { '/opt/homebrew', '/usr/local' }
local brew = vim.fn.exepath 'brew'
if brew ~= '' then
  table.insert(prefixes, 1, vim.fn.fnamemodify(brew, ':h:h'))
end
for _, prefix in ipairs(prefixes) do
  for _, bin in ipairs { 'opt/ruby/bin', 'opt/openjdk@21/bin' } do
    local path = prefix .. '/' .. bin
    if vim.uv.fs_stat(path) then
      vim.env.PATH = path .. ':' .. vim.env.PATH
    end
  end
end
