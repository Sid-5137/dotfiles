require("lazy").setup({

	-- Colorscheme: base16, driven by Noctalia's generated palette
	{
		"RRethy/base16-nvim",
		lazy = false,
		priority = 1000,
		config = function()
			-- Noctalia renders lua/matugen-template.lua -> lua/matugen.lua with the
			-- live palette. Load it if present; otherwise fall back to an on-brand
			-- base16 scheme so Neovim always has colors (e.g. before the first render).
			local ok = pcall(function() require("matugen").setup() end)
			if not ok then
				require("base16-colorscheme").setup({
					base00 = "#141314", base01 = "#1e1d20", base02 = "#47464c", base03 = "#919096",
					base04 = "#c7c5ce", base05 = "#e5e1e3", base06 = "#e5e1e3", base07 = "#ffffff",
					base08 = "#ffb4ab", base09 = "#dabfce", base0A = "#c7c5ce", base0B = "#c5c5d8",
					base0C = "#c7c5ce", base0D = "#dabfce", base0E = "#c5c5d8", base0F = "#ffb4ab",
				})
			end
		end,
	},

	-- File tree
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup()
		end,
	},

	-- Fuzzy finder
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup()
		end,
	},

	-- Syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local ok, ts = pcall(require, "nvim-treesitter.configs")
			if not ok then
				vim.notify("nvim-treesitter not built yet; run :Lazy build nvim-treesitter, then restart", vim.log.levels.WARN)
				return
			end
			ts.setup({
				ensure_installed = { "python", "lua", "bash", "rust", "toml", "json", "markdown", "vimdoc" },
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	-- Statusline (theme follows the active colorscheme)
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup({ options = { theme = "auto" } })
		end,
	},

	-- LSP installer
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},

	-- Bridges mason with lspconfig (python only; rust is handled by rustaceanvim)
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "basedpyright" },
				automatic_installation = true,
			})
		end,
	},

	-- LSP configs
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- Feed nvim-cmp's completion capabilities to every server
			local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
			if ok then
				vim.lsp.config("*", { capabilities = cmp_lsp.default_capabilities() })
			end
			vim.lsp.config("basedpyright", {})
			vim.lsp.enable("basedpyright")
		end,
	},

	-- Rust: rustaceanvim wires up rust-analyzer, clippy, runnables, macros, etc.
	{
		"mrcjkb/rustaceanvim",
		lazy = false, -- it lazy-loads itself on rust files; don't set ft/opts
		init = function()
			vim.g.rustaceanvim = {
				server = {
					default_settings = {
						["rust-analyzer"] = {
							cargo = { allFeatures = true },
							checkOnSave = true,
							check = { command = "clippy" },
							procMacro = { enable = true },
							inlayHints = {
								lifetimeElisionHints = { enable = "always" },
							},
						},
					},
				},
			}
		end,
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				},
			})
		end,
	},

	-- Git signs in the gutter
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				current_line_blame = true,
				current_line_blame_opts = {
					delay = 300,
				},
			})
		end,
	},

	-- Lazygit TUI
	{
		"kdheepak/lazygit.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- Which-key with group labels
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			local wk = require("which-key")
			wk.setup({ preset = "helix" })
			wk.add({
				{ "<leader>f", group = "Find" },
				{ "<leader>p", group = "Python" },
				{ "<leader>g", group = "Git" },
				{ "<leader>c", group = "Code/LSP" },
				{ "<leader>d", group = "Diagnostics" },
				{ "<leader>r", group = "Rust/Rename" },
			})
		end,
	},

	-- Floating terminal
	{
		"akinsho/toggleterm.nvim",
		config = function()
			require("toggleterm").setup({
				size = 15,
				open_mapping = [[<C-\>]], -- Ctrl+\ to toggle
				direction = "float",
				float_opts = {
					border = "curved",
				},
				shade_terminals = true,
			})
		end,
	},

	-- Auto-detect Python virtualenvs
	{
		"linux-cultist/venv-selector.nvim",
		dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
		config = function()
			require("venv-selector").setup({
				anaconda_base_path = vim.fn.expand("~/miniconda3"), -- adjust if using miniconda/mambaforge
				anaconda_envs_path = vim.fn.expand("~/miniconda3/envs"),
			})
		end,
	},

	-- Auto pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup()
		end,
	},

	-- Format on save: ruff (python) + rustfmt (rust)
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					python = { "ruff_format" },
					rust = { "rustfmt" },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_format = "fallback",
				},
			})
		end,
	},
})
