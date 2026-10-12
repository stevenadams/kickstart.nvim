-- Invoked by the Makefile in headless Neovim. Use the same lists as the editor.
local languages = require 'config.languages'

local function plugins()
  require('lazy').install { wait = true, show = false, lockfile = true }
  local missing = {}
  for name, plugin in pairs(require('lazy.core.config').plugins) do
    if not plugin._.installed and not plugin._.disabled then
      missing[#missing + 1] = name
    end
  end
  assert(#missing == 0, 'Missing plugins: ' .. table.concat(missing, ', '))
  print 'Plugins installed.'
end

local function packages()
  local mapping = require('mason-lspconfig').get_mappings().lspconfig_to_package
  local names = vim.deepcopy(languages.tools)
  for server in pairs(languages.servers) do
    assert(mapping[server], 'No Mason package mapped for ' .. server)
    names[#names + 1] = mapping[server]
  end
  table.sort(names)
  return names
end

local function tools()
  local registry = require 'mason-registry'
  local refreshed
  registry.refresh(function(success)
    refreshed = success
  end)
  assert(vim.wait(60000, function()
    return refreshed ~= nil
  end, 100) and refreshed, 'Mason registry refresh failed')

  local pending, failed = 0, {}
  for _, name in ipairs(packages()) do
    local pkg = registry.get_package(name)
    if not pkg:is_installed() then
      pending = pending + 1
      pkg:install({}, function(success, err)
        if not success then
          failed[#failed + 1] = name .. ': ' .. tostring(err)
        end
        pending = pending - 1
      end)
    end
  end
  assert(
    vim.wait(300000, function()
      return pending == 0
    end, 100),
    'Timed out installing Mason packages'
  )
  assert(#failed == 0, table.concat(failed, '\n'))
  print 'Mason tools installed.'
end

local function parsers()
  local treesitter = require 'nvim-treesitter'
  assert(treesitter.install(languages.parsers):wait(300000), 'Tree-sitter parser installation failed or timed out')
  print 'Tree-sitter parsers installed.'
end

local function check()
  local missing = {}
  for name, plugin in pairs(require('lazy.core.config').plugins) do
    if not plugin._.installed and not plugin._.disabled then
      missing[#missing + 1] = 'plugin: ' .. name
    end
  end

  local registry = require 'mason-registry'
  for _, name in ipairs(packages()) do
    if not registry.is_installed(name) then
      missing[#missing + 1] = 'Mason: ' .. name
    end
  end

  local installed = {}
  for _, name in ipairs(require('nvim-treesitter').get_installed 'parsers') do
    installed[name] = true
  end
  for _, name in ipairs(languages.parsers) do
    if not installed[name] then
      missing[#missing + 1] = 'parser: ' .. name
    end
  end

  table.sort(missing)
  assert(#missing == 0, 'Missing Neovim dependencies:\n' .. table.concat(missing, '\n'))
  print 'All configured Neovim plugins, Mason tools, and parsers are installed.'
end

local actions = { plugins = plugins, tools = tools, parsers = parsers, check = check }

return {
  run = function(action)
    local ok, err = pcall(function()
      assert(actions[action], 'Unknown setup action: ' .. tostring(action))()
    end)
    if not ok then
      vim.api.nvim_err_writeln(tostring(err))
      vim.cmd 'cquit 1'
    else
      vim.cmd 'qa'
    end
  end,
}
