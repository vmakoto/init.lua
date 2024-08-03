-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        {
            "rose-pine/neovim",
            name = "rose-pine",
            config = function()
                require('rose-pine').setup({
                    disable_background = true,
                })

                vim.cmd("colorscheme rose-pine")
                color = color or "rose-pine"
                vim.cmd.colorscheme(color)

            end
        },
        {
            'nvim-telescope/telescope.nvim', tag = '0.1.8',
            -- or                              , branch = '0.1.x',
            dependencies = { 'nvim-lua/plenary.nvim' },
            config = function()
                require('telescope').setup({})

                local builtin = require('telescope.builtin')
                vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
                vim.keymap.set('n', '<C-p>', builtin.git_files, {})
                vim.keymap.set('n', '<leader>pws', function()
                    local word = vim.fn.expand("<cword>")
                    builtin.grep_string({ search = word })
                end)
                vim.keymap.set('n', '<leader>pWs', function()
                    local word = vim.fn.expand("<cWORD>")
                    builtin.grep_string({ search = word })
                end)
                vim.keymap.set('n', '<leader>ps', function()
                    builtin.grep_string({ search = vim.fn.input("Grep > ") })
                end)
                vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
            end
        },
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function()
                require("nvim-treesitter.configs").setup({

                    ensure_installed = {
                        "vimdoc", "javascript", "typescript", "c", "lua", "rust",
                        "jsdoc", "bash", "elixir", "eex", "heex", "go", "gomod", "gosum",
                        "gowork"
                    },

                    sync_install = false,

                    auto_install = true,

                    indent = {
                        enable = true
                    },

                    highlight = {
                        enable = true,

                        additional_vim_regex_highlighting = { "markdown" },
                    },
                })

                local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
                treesitter_parser_config.templ = {
                    install_info = {
                        url = "https://github.com/vrischmann/tree-sitter-templ.git",
                        files = {"src/parser.c", "src/scanner.c"},
                        branch = "master",
                    },
                }

                vim.treesitter.language.register("templ", "templ")
            end
        },
        {
            "neovim/nvim-lspconfig",
            dependencies = {
                "williamboman/mason.nvim",
                "williamboman/mason-lspconfig.nvim",
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-cmdline",
                "hrsh7th/nvim-cmp",
                "L3MON4D3/LuaSnip",
                "saadparwaiz1/cmp_luasnip",
                "j-hui/fidget.nvim",
            },

            config = function()
                local cmp = require('cmp')
                local cmp_lsp = require("cmp_nvim_lsp")
                vim.api.nvim_create_autocmd('LspAttach', {
                    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
                    callback = function(event)
                        local map = function(keys, func, desc)
                            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                        end

                        local opts = {buffer = event.buf, remap = false}

                        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')


                        map("gd", function() vim.lsp.buf.definition() end, '')
                        map("K", function() vim.lsp.buf.hover() end, '')
                        map("<leader>vws", function() vim.lsp.buf.workspace_symbol() end, '')
                        map("<leader>vd", function() vim.diagnostic.open_float() end, '')
                        map("[d", function() vim.diagnostic.goto_next() end, '')
                        map("]d", function() vim.diagnostic.goto_prev() end, '')
                        map("<leader>vca", function() vim.lsp.buf.code_action() end, '')
                        map("<leader>vrr", function() vim.lsp.buf.references() end, '')
                        map("<leader>vrn", function() vim.lsp.buf.rename() end, '')
                        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
                    end,
                })

                local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                cmp_lsp.default_capabilities())

                require("fidget").setup({})
                require("mason").setup()
                require("mason-lspconfig").setup({
                    ensure_installed = {
                        "lua_ls",
                        "rust_analyzer",
                        "elixirls",
                        "tsserver"
                    },
                    handlers = {
                        function(server_name) -- default handler (optional)
                            require("lspconfig")[server_name].setup {
                                capabilities = capabilities
                            }
                        end,

                        zls = function()
                            local lspconfig = require("lspconfig")
                            lspconfig.zls.setup({
                                root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
                                settings = {
                                    zls = {
                                        enable_inlay_hints = true,
                                        enable_snippets = true,
                                        warn_style = true,
                                    },
                                },
                            })
                            vim.g.zig_fmt_parse_errors = 0
                            vim.g.zig_fmt_autosave = 0

                        end,
                        ["lua_ls"] = function()
                            local lspconfig = require("lspconfig")
                            lspconfig.lua_ls.setup {
                                capabilities = capabilities,
                                settings = {
                                    Lua = {
                                        runtime = { version = "Lua 5.1" },
                                        diagnostics = {
                                            globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                                        }
                                    }
                                }
                            }
                        end,
                    }
                })

                local cmp_select = { behavior = cmp.SelectBehavior.Select }

                cmp.setup({
                    snippet = {
                        expand = function(args)
                            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                        end,
                    },
                    mapping = cmp.mapping.preset.insert({
                        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                        ["<C-Space>"] = cmp.mapping.complete(),
                    }),
                    sources = cmp.config.sources({
                        { name = 'nvim_lsp' },
                        { name = 'luasnip' }, -- For luasnip users.
                    }, {
                        { name = 'buffer' },
                    })
                })

                vim.diagnostic.config({
                    -- update_in_insert = true,
                    float = {
                        focusable = false,
                        style = "minimal",
                        border = "rounded",
                        source = "always",
                        header = "",
                        prefix = "",
                    },
                })
            end
        }
    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "habamax" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
})
