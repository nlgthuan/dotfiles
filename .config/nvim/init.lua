vim.g.mapleader = ' '
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.colorcolumn = "80"
vim.opt.signcolumn = "yes"
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.swapfile = false
vim.opt.winborder = "rounded"

vim.opt.complete = '.,w,b,o'
vim.opt.completeopt = 'menuone,noselect,fuzzy,noinsert'
vim.opt.autocomplete = true

vim.diagnostic.config({ virtual_text = true })


vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = "Copy to clipboard" })
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>gl', vim.diagnostic.open_float, { desc = 'Open diagnostic float' })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set('n', '<C-c>', '<cmd>nohlsearch<CR>')
-- By default, C-c doesn't trigger InsertLeave, which is needed for refreshing
-- diagnostic and other stuff
vim.keymap.set('i', '<C-c>', '<ESC>')

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.lsp.enable({ "lua_ls", "ts_ls", "oxlint", "pyright", "gopls", "postgres_lsp", "texlab", "jdtls", "hls", "clangd" })

-- [[ Plugins ]]
vim.pack.add({
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/chomosuke/typst-preview.nvim',
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  {
    src = "https://github.com/kylechui/nvim-surround",
    version = vim.version.range("4.x"),
  },
})

vim.cmd("colorscheme catppuccin-mocha")

require('typst-preview').setup()

require("oil").setup({
  view_options = {
    show_hidden = true,
  },
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })


local conform = require("conform")
conform.setup({
  notify_on_error = true,
  formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'isort', 'black' },
    ['_'] = { 'insert_final_newline' },
  },
  default_format_opts = {
    lsp_format = "fallback",
  },
})
vim.keymap.set('n', '<leader>f', function()
    conform.format()
    vim.cmd('write')
  end,
  { desc = '[F]ormat buffer' }
)

vim.api.nvim_create_autocmd('FileType', {
  callback = function() pcall(vim.treesitter.start) end,
})

require("gitsigns").setup({
  current_line_blame = true,
})

require('telescope').setup {
  defaults = {
    mappings = {
      i = { ['<c-q>'] = 'smart_send_to_qflist' },
    },
  },
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>sc', function()
  builtin.find_files { cwd = vim.fn.stdpath("config") }
end, { desc = 'Telescope find config' })
vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set("n", "<leader>gr", builtin.lsp_references)
vim.keymap.set("n", "gd", builtin.lsp_definitions)
vim.keymap.set("n", "gI", builtin.lsp_implementations)
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>sm', builtin.marks, { desc = '[S]earch [M]arks' })

-- Disable autocomplete on non normal buffer like telescope
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.bo.buftype == 'nofile' then
      vim.opt.autocomplete = false
      return
    end
    vim.opt.autocomplete = true
  end,
})


local mvn_test = require("mvn_test")
vim.keymap.set('n', '<leader>rt', mvn_test.run_java_test_in_tmux)
