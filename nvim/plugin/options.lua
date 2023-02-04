vim.g.loaded_matchparen = 1

local opt = vim.opt

-- Ignore compiled files
opt.wildignore = "__pycache__"
opt.wildignore:append { "*.o", "*~", "*.pyc", "*.pycache*" }
opt.wildignore:append "Cargo.lock"

-- Cool floating window popup menu for completion on command line
opt.pumblend = 17
opt.wildmode = "longest:full"
opt.wildoptions = "pum"

opt.showmode = false
opt.showcmd = true
opt.cmdheight = 1
opt.incsearch = true
opt.showmatch = true
opt.relativenumber = true
opt.number = true
opt.ignorecase = true
opt.smartcase = true
opt.hidden = true
opt.equalalways = false
opt.splitright = true
opt.splitbelow = true
opt.updatetime = 1000
opt.hlsearch = true
opt.scrolloff = 10

-- Cursorline highlight control
--  Only have it on the active buffer
opt.cursorline = true
local group = vim.api.nvim_create_augroup("CursorLineControl", { clear = true })
local set_cursorline = function(event, value, pattern)
	vim.api.nvim_create_autocmd(event, {
		group = group,
		pattern = pattern,
		callbal = function()
			vim.opt_local.cursorline = value
		end,
	})
end
set_cursorline("WinLeave", false)
set_cursorline("WinEnter", true),
set_cursorline("FileType", false, "TelescopePrompt")

-- Tabs
opt.autoindent = true
opt.cindent = true
opt.wrap = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true

opt.breakindent = true
opt.showbreak = string.rep(" ", 3)
opt.linebreak = true

opt.foldmethod = "marker"
opt.foldlevel = 0
opt.modelines = 1

opt.belloff = "all" -- Shut up nvim

opt.clipboard = "unnamedplus"

opt.inccommand = "split"
opt.swapfile = false -- Livin' on the edge
opt.shada = { "!", "'1000", "<50", "s10", "h" }

opt.mouse = "a"

opt.formatoptions = opt.formatoptions
  - "a" -- Auto formatting is BAD.
  - "t" -- Don't auto format my code. I got linters for that.
  + "c" -- In general, I like it when comments respect textwidth
  + "q" -- Allow formatting comments w/ gq
  - "o" -- O and o, don't continue comments
  + "r" -- But do continue when pressing enter.
  + "n" -- Indent past the formatlistpat, not underneath it.
  + "j" -- Auto-remove comments if possible.
  - "2" -- I'm not in gradeschool anymore

opt.joinspaces = false
opt.fillchars = { eob = "~", tab = "→ ", space = "·", nbsp = "␣", trail = "•", eol = "¶" }

opt.diffopt = { "internal", "filter", "closeoff", "hiddenoff", "algorithm:minimal" }

opt.undofile = true
opt.signcolumn = "yes"
