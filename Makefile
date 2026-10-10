NVIM ?= nvim
export PATH := /opt/homebrew/opt/ruby/bin:/opt/homebrew/opt/openjdk@21/bin:/usr/local/opt/ruby/bin:/usr/local/opt/openjdk@21/bin:$(PATH)

.PHONY: help setup prereqs plugins tools parsers check

help:
	@printf '%s\n' 'make setup    Install Neovim plugins, LSPs, and parsers' 'make check    Check prerequisites and installed Neovim tools' 'make plugins  Install missing lazy.nvim plugins' 'make tools    Install missing Mason LSPs and stylua' 'make parsers  Install missing Tree-sitter parsers'

setup: plugins tools parsers check

prereqs:
	@for cmd in $(NVIM) git rg fd node npm go ruby java make cc; do command -v "$$cmd" >/dev/null || { printf 'Missing: %s\n' "$$cmd"; exit 1; }; done
	@$(NVIM) --headless --clean '+lua assert(vim.fn.has("nvim-0.11") == 1, "Neovim 0.11+ is required")' +qa
	@ruby -e 'abort "Ruby 3.2+ is required for ruby-lsp" if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3.2")'
	@java -version 2>&1 | ruby -ne 'if /version "(\d+)/; abort "Java 21+ is required for jdtls" if $$1.to_i < 21; found = true; end; END { abort "Could not determine Java version" unless found }'

plugins: prereqs
	$(NVIM) --headless '+lua require("config.setup").run("plugins")'

tools: prereqs
	$(NVIM) --headless '+lua require("config.setup").run("tools")'

parsers: prereqs
	$(NVIM) --headless '+lua require("config.setup").run("parsers")'

check: prereqs
	$(NVIM) --headless '+lua require("config.setup").run("check")'
