vim.g.mapleader = " "

vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.signcolumn = "yes"
vim.o.winborder = "rounded"


vim.pack.add({
	{ src = "https://github.com/folke/tokyonight.nvim" },
	{ src = 'https://github.com/neovim/nvim-lspconfig' },
	{ src = 'https://github.com/mason-org/mason.nvim' },
	{ src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
	{ src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/nvim-mini/mini.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/ibhagwan/fzf-lua" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/saghen/blink.cmp" },
	{ src = "https://github.com/mfussenegger/nvim-lint" },
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/akinsho/toggleterm.nvim" },
	{ src = "https://github.com/mrcjkb/rustaceanvim" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/folke/trouble.nvim" },
	{ src = 'https://github.com/nvim-tree/nvim-web-devicons' },
	{ src = 'https://github.com/nvim-lualine/lualine.nvim' },

})


require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		"lua_ls",
		"clangd",
		"python-lsp-server",
		"rust-analyzer",
	},
})

require("luasnip.loaders.from_vscode").lazy_load()

local lint = require("lint")
lint.linters_by_ft = {
	lua = { "luac" },
	c = { "cpplint" },
	cpp = { "cpplint" },
	python = { "ruff", "pylint" },
	rust = { "clippy" },
}

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT"
			},
			diagnostics = {
				global = { "vim", "require" }
			}
		}
	}

})

require("nvim-treesitter").install({ "rust", "c", "cpp", "python", "vue", "go" })
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "rust", "c", "cpp", "python", "vue", "go" },
	callback = function()
		vim.treesitter.start()
	end,
})

require("trouble").setup()

require("toggleterm").setup({
	open_mapping = [[<c-\>]],
	direction = "float"
})

require("oil").setup({
	columns = {
		"permissions",
		"icon"
	},
	view_options = {
		show_hidden = true }
})

local wk = require("which-key")
wk.setup({
	preset = "modern"
})
wk.add({
	{ "<leader>ff", "<CMD>FzfLua files<CR>",     desc = "Find files" },
	{ "<leader>/",  "<CMD>FzfLua live_grep<CR>", desc = "Grep files" },
})
wk.add({
	{ "<leader>c",  group = "Code" },
	{ "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action",     mode = { "n", "v" } },
	{ "<leader>cr", vim.lsp.buf.rename,      desc = "Rename Symbol" },
	{ "gd",         vim.lsp.buf.definition,  desc = "Go to Definition" },
	{ "gr",         vim.lsp.buf.references,  desc = "Show References" },
	{ "K",          vim.lsp.buf.hover,       desc = "Hover Docs" },
})

require("gitsigns").setup({
	signs = {
		add = { text = '+' },
		change = { text = '~' },
		delete = { text = '_' },
		topdelete = { text = '-' },
		changedelete = { text = '~' }
	}
})

require("mini.pick").setup()
require("mini.pairs").setup()
require("mini.surround").setup()
-- require("mini.statusline").setup()

require("lualine").setup()

local function pack_clean()
	local active_plugins = {}
	local unused_plugins = {}

	for _, plugin in ipairs(vim.pack.get()) do
		active_plugins[plugin.spec.name] = plugin.active
	end

	for _, plugin in ipairs(vim.pack.get()) do
		if not active_plugins[plugin.spec.name] then
			table.insert(unused_plugins, plugin.spec.name)
		end
	end

	if #unused_plugins == 0 then
		print("No unused plugins.")
		return
	end

	local choice = vim.fn.confirm("Remove unused plugins?", "&Yes\n&No", 2)
	if choice == 1 then
		vim.pack.del(unused_plugins)
	end
end

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	callback = function()
		require("lint").try_lint()
	end,
})

require("blink.cmp").setup({
	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = { force_version = "v*", download = true }
	},
	signature = { enabled = true },
	completion = {
		documentation = { auto_show = true },
		menu = { auto_show = true },
		list = {
			selection = { preselect = true, auto_insert = false },
		},
	},
	keymap = {
		["<CR>"] = { "accept", "fallback" },
		["<Tab>"] = { "select_next", "fallback" },
		["<S-Tab>"] = { "select_prev", "fallback" },
	},
})


vim.cmd.colorscheme("tokyonight-night")

vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>pc", pack_clean)
vim.keymap.set("n", "<leader>e", ":Oil<CR>")

vim.keymap.set("n", "<leader>t", ":Pick files<CR>")
vim.keymap.set("n", "<leader>h", ":Pick help<CR>")
vim.keymap.set("n", "<leader>g", ":Pick grep_live<CR>")
vim.keymap.set("n", "<leader>b", ":Pick buffers<CR>")

vim.keymap.set("n", "<leader>q", ":Trouble diagnostics toggle<CR>")

vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y<CR>')
vim.keymap.set({ "n", "v", "x" }, "<leader>d", '"+d<CR>')
