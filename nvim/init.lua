-- My configuration files
-- A config for neovim

-- Inspired by TJ DeVries' config: https://github.com/tjdevries

-- Setup globals I expect to be available
require "nya.globals"

-- It's best to set those early in the config, so it it set for any keymaps
vim.g.mapleader = ","
vim.g.maplocalleader = " "

-- Disable all the builtins I don't use
-- require "nya.disable_builtins"

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"--single-branch",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	}
end

require("lazy").setup("custom.plugins", {
	ui = {
		icons = {
			cmd = "⌘",
      			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			source = "📄",
			start = "🚀",
			task = "📌",
		}
	}
})
