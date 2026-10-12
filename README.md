# Neovim configuration

This started from [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) and is now organized into small Lua modules.

- `init.lua` sets the leader keys and loads the configuration in order.
- `lua/config/options.lua`, `keymaps.lua`, and `autocmds.lua` contain editor defaults.
- `lua/config/lazy.lua` bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) and imports `lua/plugins/*.lua`.
- `lua/config/languages.lua` is the shared list of LSP servers, formatter/linter tools, and Tree-sitter parsers used by Neovim and the Makefile.
- `lua/plugins/` contains plugin specs grouped by purpose. Add a plugin by returning a spec from a file there (or adding it to an existing file).
- `lazy-lock.json` pins plugin versions and is versioned with the config. Use `:Lazy` to inspect plugins and `:Lazy update` to update them.

## Setup

On a Mac, the separate `local-setup` repository prepares the machine, installs Homebrew packages, clones this repository into `~/.config/nvim`, and runs `make setup` here. To install this config alone, clone it to `~/.config/nvim` and run `make setup` after installing the prerequisites.

`make setup` installs missing lazy.nvim plugins, Mason language servers/formatter, and Tree-sitter parsers, then checks the result. `make check` is read-only; `make help` lists individual targets. Run `make setup` again after adding servers or parsers to `lua/config/languages.lua`.

`Makefile` and `lua/config/toolchain.lua` put Homebrew's Ruby and OpenJDK 21 ahead of the macOS system versions for Mason and Neovim. Neovim requires version 0.11+; Ruby LSP needs Ruby 3.2+, and Java/Kotlin servers need a JDK (JDTLS needs Java 21+).

Mason installs `gopls` for Go, `ts_ls` for JavaScript/TypeScript, `pyright` for Python, `ruby_lsp` for Ruby, `jdtls` for Java, `kotlin_language_server` for Kotlin, and `lua_ls` for Lua. Tree-sitter installs parsers asynchronously during normal startup; `make parsers` waits for installation and reports errors.

Conform formats Lua with StyLua, Go with gofmt, and Python with Ruff. JavaScript/TypeScript, JSON, HTML, CSS, and Markdown use Prettier when a project has a local Prettier binary or configuration; Ruby uses RuboCop when a project has `.rubocop.yml`. Commands prefer project-local binaries where available and otherwise use Mason's tools. Formatting falls back to the LSP if no formatter is available. Save-time formatting is capped at 750 ms; Ruby formatting is manual (`<leader>f`) to avoid blocking saves in large projects. `nvim-lint` runs asynchronously on filetype detection and save: Ruff for Python and ShellCheck for shell scripts; ESLint only in projects with an ESLint config and local binary, and RuboCop only with `.rubocop.yml`.

Set `vim.g.have_nerd_font = true` in `init.lua` if your terminal uses a Nerd Font. The Markdown preview plugin needs Node.js/npm; CodeCompanion's inline adapter needs Ollama and the `qwen2.5-coder:7b` model.
