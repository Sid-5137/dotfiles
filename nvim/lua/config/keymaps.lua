local map = vim.keymap.set

-- File tree
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })

-- Telescope
map("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", ":Telescope live_grep<CR>",  { desc = "Live grep" })
map("n", "<leader>fb", ":Telescope buffers<CR>",    { desc = "Buffers" })
map("n", "<leader>fh", ":Telescope help_tags<CR>",  { desc = "Help tags" })

-- Terminal mode exit (Esc to go back to normal mode from terminal)
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Python env switcher
map("n", "<leader>pv", ":VenvSelect<CR>",        { desc = "Select Python venv" })
map("n", "<leader>pc", ":VenvSelectCached<CR>",  { desc = "Use cached venv" })

-- Git
map("n", "<leader>gg", ":LazyGit<CR>", { desc = "LazyGit" })

-- Window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")

-- Diagnostics (0.11 jump API)
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end,  { desc = "Next diagnostic" })
map("n", "<leader>df", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- LSP keymaps: buffer-local, attached when any server connects
vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP keymaps on attach",
  callback = function(ev)
    local o = function(desc) return { buffer = ev.buf, desc = desc } end
    map("n", "gd", vim.lsp.buf.definition,     o("Go to definition"))
    map("n", "gD", vim.lsp.buf.declaration,    o("Go to declaration"))
    map("n", "gi", vim.lsp.buf.implementation, o("Go to implementation"))
    map("n", "gr", vim.lsp.buf.references,     o("References"))
    map("n", "K",  vim.lsp.buf.hover,          o("Hover"))
    map("n", "<leader>rn", vim.lsp.buf.rename, o("Rename symbol"))
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, o("Code action"))
    map("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, o("Format buffer"))

    -- Toggle inlay hints (0.10+)
    if vim.lsp.inlay_hint then
      map("n", "<leader>ch", function()
        local b = ev.buf
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = b }), { bufnr = b })
      end, o("Toggle inlay hints"))
    end
  end,
})

-- Rust-specific keymaps (rustaceanvim's enhanced commands), only in rust buffers
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(ev)
    local o = function(desc) return { buffer = ev.buf, desc = desc } end
    map("n", "K",          function() vim.cmd.RustLsp({ "hover", "actions" }) end, o("Rust hover actions"))
    map("n", "<leader>ca", function() vim.cmd.RustLsp("codeAction") end,           o("Rust code action"))
    map("n", "<leader>rr", function() vim.cmd.RustLsp("runnables") end,            o("Rust runnables"))
    map("n", "<leader>rd", function() vim.cmd.RustLsp("debuggables") end,          o("Rust debuggables"))
    map("n", "<leader>rm", function() vim.cmd.RustLsp("expandMacro") end,          o("Expand macro"))
    map("n", "<leader>rc", function() vim.cmd.RustLsp("openCargo") end,            o("Open Cargo.toml"))
  end,
})
