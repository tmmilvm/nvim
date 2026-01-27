vim.g.mapleader = " "
vim.g.maplocalleader = " "

--
-- Setup specific settings
--
local vertical_ruler = "80"
local ts_grammars = {
    "bash", "c", "csv", "diff", "json", "lua", "make", "markdown",
    "markdown-inline", "matlab", "printf", "python", "rust", "toml", "yaml",
    "xml"
}
local lsp_servers = { "pyright", "clangd", "rust_analyzer" }

--
-- Options
--

-- Basic
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true

-- Visual setting
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "0"
vim.opt.showmatch = true
vim.opt.matchtime = 2
vim.opt.cmdheight = 1
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.showmode = true
vim.opt.pumheight = 10
vim.opt.pumborder = "rounded"
vim.opt.winborder = "rounded"
vim.opt.pumblend = 0
vim.opt.winblend = 0
vim.opt.conceallevel = 0
vim.opt.concealcursor = ""
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 300
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- File handling
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 0
vim.opt.autoread = true
vim.opt.autowrite = false

-- Create undo directory if it doesn't exist
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end

-- Behavior settings
vim.opt.hidden = true
vim.opt.errorbells = false
vim.opt.backspace = "indent,eol,start"
vim.opt.autochdir = false
vim.opt.path:append("**")
vim.opt.selection = "exclusive"
vim.opt.mouse = "a"
vim.opt.clipboard:append("unnamedplus")
vim.opt.modifiable = true
vim.opt.encoding = "UTF-8"

-- Split behavior
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Command-line completion
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc" })
vim.opt.inccommand = "split"

-- Better diff options
vim.opt.diffopt:append("linematch:60")

-- Performance improvements
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

--
-- Key mappings
--

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })

-- Splitting & resizing
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Option toggling
vim.keymap.set("n", "<leader>ow", ":set wrap!<CR>", { desc = "Toggle word wrap" })
vim.keymap.set("n", "<leader>oh", ":nohlsearch<CR>", { desc = "Clear search highlights" })
function toggle_colorcolumn()
    if vim.wo.colorcolumn ~= "0" then
        vim.wo.colorcolumn = "0"
    else
        vim.wo.colorcolumn = vertical_ruler
    end
end
vim.keymap.set("n", "<leader>oc", ":lua toggle_colorcolumn()<CR>", { desc = "Toggle color column" })

-- netrw
vim.keymap.set("n", "<leader>e", ":Explore<CR>", { desc = "Open file explorer" })

--
-- Autocommands
--

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("tommi-highlight-yank", {}),
    desc = "Highlight when yanking text",
    callback = function() vim.hl.on_yank() end,
})

--
-- Plugins
--

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

-- Install and set up plugins
require("lazy").setup({
    {
        "nyoom-engineering/oxocarbon.nvim",
        config = function()
            vim.cmd("colorscheme oxocarbon")
        end
    },
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
        },
    },
    {
        "nvim-telescope/telescope.nvim",
        event = "VimEnter",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
                cond = function() return vim.fn.executable("make") == 1 end,
            },
            "nvim-telescope/telescope-ui-select.nvim",
        },
        config = function()
            require("telescope").setup {
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({ winblend = 10 }),
                    },
                },
            }

            pcall(require("telescope").load_extension, "fzf")
            pcall(require("telescope").load_extension, "ui-select")

            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "Find from git files" })
            vim.keymap.set("n", "<leader>pf", builtin.find_files, { desc = "Find from files" })
            vim.keymap.set("n", "<leader>pg", builtin.live_grep, { desc = "Grep" })
            vim.keymap.set("n", "<leader>ph", builtin.help_tags, { desc = "Search help" })
            vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "Find from buffers" })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").install(ts_grammars)
        end,
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("tommi-lsp-attach", { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        mode = mode or "n"
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end
                    map("grn", vim.lsp.buf.rename, "Rename")
                    map("gra", vim.lsp.buf.code_action, "Goto code action", { "n", "x" })
                    map("grr", require("telescope.builtin").lsp_references, "Goto references")
                    map("gri", require("telescope.builtin").lsp_implementations, "Goto implementation")
                    map("grd", require("telescope.builtin").lsp_definitions, "Goto definition")
                    map("grD", vim.lsp.buf.declaration, "Goto declaration")
                    map("grt", require("telescope.builtin").lsp_type_definitions, "Goto type definiton")
                    map("gO", require("telescope.builtin").lsp_document_symbols, "Open document symbols")
                    map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open workspace symbols")

                    -- Set up highlighting for references of the word under the
                    -- cursor when the cursor holds there for a while
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
                        local hl_augroup = vim.api.nvim_create_augroup("tommi-lsp-highlight", { clear = false })
                        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                            buffer = event.buf,
                            group = hl_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })
                        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                            buffer = event.buf,
                            group = hl_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })
                        vim.api.nvim_create_autocmd("LspDetach", {
                            group = vim.api.nvim_create_augroup("tommi-lsp-detach", { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds { group = "tommi-lsp-highlight", buffer = event2.buf }
                            end,
                        })
                    end
                end,
            })

            -- Diagnostic config
            vim.diagnostic.config {
                severity_sort = true,
                float = { border = "rounded", source = "if_many" },
                underline = { severity = vim.diagnostic.severity.ERROR },
            }

            for _, lsp_server in ipairs(lsp_servers) do
                vim.lsp.enable(lsp_server)
            end
        end,
    },
    {
        "folke/trouble.nvim",
        opts = {},
        cmd = "Trouble",
        keys = {
            {
                "<leader>da",
                ":Trouble diagnostics toggle<CR>",
                desc = "Toggle diagnostics (all)",
            },
            {
                "<leader>db",
                ":Trouble diagnostics toggle filter.buf=0<CR>",
                desc = "Toggle diagnostics (buffer)",
            },
            {
                "<leader>dl",
                ":Trouble loclist toggle<CR>",
                desc = "Toggle location list",
            },
            {
                "<leader>dq",
                ":Trouble qflist toggle<CR>",
                desc = "Toggle quickfix list",
            },
        },
    },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup()

            vim.keymap.set("n", "<leader>hl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Show harpoon list" })
            vim.keymap.set("n", "<leader>ha", function() harpoon:list():replace_at(1) end, { desc = "Replace harpoon list item 1" })
            vim.keymap.set("n", "<leader>hs", function() harpoon:list():replace_at(2) end, { desc = "Replace harpoon list item 2" })
            vim.keymap.set("n", "<leader>hd", function() harpoon:list():replace_at(3) end, { desc = "Replace harpoon list item 3" })
            vim.keymap.set("n", "<leader>hf", function() harpoon:list():replace_at(4) end, { desc = "Replace harpoon list item 4" })

            local harpoon_select = function(idx)
                harpoon:list():select(idx)
                if vim.bo.buftype == "terminal" then
                    vim.cmd(":startinsert")
                end
            end
            vim.keymap.set({"n", "t"}, "<A-a>", function() harpoon_select(1) end, { desc = "Select harpoon list item 1" })
            vim.keymap.set({"n", "t"}, "<A-s>", function() harpoon_select(2) end, { desc = "Select harpoon list item 2" })
            vim.keymap.set({"n", "t"}, "<A-d>", function() harpoon_select(3) end, { desc = "Select harpoon list item 3" })
            vim.keymap.set({"n", "t"}, "<A-f>", function() harpoon_select(4) end, { desc = "Select harpoon list item 4" })

            vim.api.nvim_create_autocmd("ExitPre", {
                group = vim.api.nvim_create_augroup("tommi-clear-harpoon-list", {}),
                desc = "Clear harpoon list before exiting",
                callback = function() harpoon:list():clear() end,
            })
        end,
    },
})

