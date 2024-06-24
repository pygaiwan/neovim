return {
    "neovim/nvim-lspconfig",
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'VonHeikemen/lsp-zero.nvim',
        'neovim/nvim-lspconfig',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/nvim-cmp',
        'L3MON4D3/LuaSnip',
    },

    config = function()
        local lsp = require('lsp-zero')

        lsp.extend_lspconfig()
        lsp.preset('recommended')

        local cmp = require('cmp')
        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        local cmp_mappings = lsp.defaults.cmp_mappings({
            ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
            ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
            ['<C-space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true })
        })

        lsp.set_preferences({
            sign_icons = {}
        })

        require('mason').setup({
            PATH = "append"
        })
        require('mason-lspconfig').setup({
            ensure_installed = { 'lua_ls', 'ruff', 'pylsp' },
            handlers = {
                function(server_name)
                    if server_name == 'ruff' then
                        local ruff_config_path = vim.loop.os_homedir() .. '/.config/ruff/ruff.toml'
                        local project_ruff_config = vim.loop.cwd() .. '/ruff.toml'
                        local f = io.open(project_ruff_config, 'r')
                        if f ~= nil then
                            io.close(f)
                            ruff_config_path = project_ruff_config
                        end
                        require('lspconfig').ruff_lsp.setup({
                            init_options = {
                                settings = {
                                    format = {
                                        args = { "--config=" .. ruff_config_path }
                                    },
                                    lint = {
                                        args = { "--config=" .. ruff_config_path }
                                    }
                                }
                            }
                        })
                    elseif server_name == 'pylsp' then
                        require('lspconfig').pylsp.setup({
                            settings = {
                                pylsp = {
                                    plugins = {
                                        flake8 = { enabled = false },
                                        yapf = { enabled = false },
                                        flakes = { enabled = false },
                                        pylint = { enabled = false },
                                        pycodestyle = { enabled = false },
                                        pydocstyle = { enabled = false },
                                        mccabe = { enabled = false },
                                        autopep8 = { enabled = false },

                                    }
                                }
                            }
                        })
                    elseif server_name == 'lua_ls' then
                        require('lspconfig').lua_ls.setup({
                            settings = {
                                Lua = {
                                    diagnostics = {
                                        globals = { 'vim', 'describe', 'it' },
                                    },
                                    workspace = { library = vim.api.nvim_get_runtime_file("", true), },
                                    telemetry = { enable = false, },
                                }
                            }
                        })
                    else
                        require('lspconfig')[server_name].setup({})
                    end
                end,
            }
        })

        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(event
            )
                local map = function(key, func, desc)
                    vim.keymap.set("n", key, func, { buffer = event.buf, desc = "LSP: " .. desc })
                end

                map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
                map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
                map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
                map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
                map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
                map(
                    "<leader>ws",
                    require("telescope.builtin").lsp_dynamic_workspace_symbols,
                    "[W]orkspace [S]ymbols"
                )
                map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
                map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
                map("K", vim.lsp.buf.hover, "Hover Documentation")
                map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
            end,
        })
    end
}
