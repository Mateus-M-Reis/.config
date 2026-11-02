-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local options = {
  base46 = {
    theme = "flexoki-light",
    -- hl_override = {
    -- 	Comment = { italic = true },
    -- 	["@comment"] = { italic = true },
    -- },
    theme_toggle = { "ayu_dark", "flexoki-light" },
    transparency = true,
  },

  -- nvdash = { load_on_startup = true },

  ui = {
    tabufline = {
      lazyload = false,
      order = { "buffers", "tabs", "btns" },
    },
  },
}

local status, chadrc = pcall(require, "chadrc")
return vim.tbl_deep_extend("force", options, status and chadrc or {})
