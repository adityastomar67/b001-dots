return {
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			ensure_installed = { "bashls", "lua_ls", "cssls", "pylsp" },
			auto_install = true,
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			-- preserve your capabilities provider
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- shared on_attach to set buffer-local mappings
			local function on_attach(_, bufnr)
				local opts = { buffer = bufnr, noremap = true, silent = true }
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Declaration" }))
				vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Definitions" }))
				vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "References" }))
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
			end

			-- helper to configure and start a server using the new API
			local function setup_and_start(server_name, config_tbl)
				config_tbl = config_tbl or {}
				-- ensure common fields
				config_tbl.capabilities = config_tbl.capabilities or capabilities
				config_tbl.on_attach = config_tbl.on_attach or on_attach

				-- assign the server config to vim.lsp.config
				vim.lsp.config[server_name] = config_tbl

				-- start the server (this will create a client if not running)
				-- wrap in pcall to avoid hard errors during startup
				pcall(function()
					vim.lsp.start(vim.lsp.config[server_name])
				end)
			end

			-- Basic per-server configuration (customize settings as needed)
			-- bashls
			setup_and_start("bashls")

			-- cssls
			setup_and_start("cssls")

			-- lua_ls: keep the common Lua settings (adjust as desired)
			setup_and_start("lua_ls", {
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = { library = vim.api.nvim_get_runtime_file("", true) },
						telemetry = { enable = false },
					},
				},
			})

			-- pylsp
			setup_and_start("pylsp")
		end,
	},
}