require "nvchad.autocmds"

--local autocmd = vim.api.nvim_create_autocmd
--
--autocmd({ "BufWinEnter" }, {
--  pattern = "*",
--  callback = function()
--    -- Only run if the file actually has lines to fold
--    if vim.fn.line("$") > 1 then
--      -- zM sets foldlevel to 0; zR sets it exactly to the file's max depth
--      vim.cmd("normal! zMzr")
--    end
--  end,
--})
