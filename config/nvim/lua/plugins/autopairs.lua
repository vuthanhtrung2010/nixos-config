local ok_npairs, npairs = pcall(require, "nvim-autopairs")
if not ok_npairs then
  return
end

local Rule = require("nvim-autopairs.rule")
local cond = require("nvim-autopairs.conds")

npairs.setup({
  check_ts = false,
  enable_check_bracket_line = true,
  fast_wrap = {},
})

-- Typst, Markdown, and TeX math equation auto-pairing ($ and $$)
npairs.add_rules({
  -- 1. Auto-pair $ into $$
  Rule("$", "$", { "typst", "markdown", "tex", "plaintex" })
    :with_pair(cond.not_after_regex("[%w_%$]"))
    :with_move(function(opts)
      return opts.char == "$"
    end),

  -- 2. Expand spaces symmetrically inside $$: typing space in $$ produces $  $ with cursor centered
  Rule(" ", " ", { "typst", "markdown", "tex", "plaintex" })
    :with_pair(function(opts)
      local pair = opts.line:sub(opts.col - 1, opts.col)
      return pair == "$$"
    end)
    :with_del(function(opts)
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local context = opts.line:sub(col - 1, col + 2)
      return context == "$  $"
    end),

  -- 3. Skip over closing $ when space is already inside
  Rule("$ ", " $", { "typst", "markdown", "tex", "plaintex" })
    :with_pair(function()
      return false
    end)
    :with_move(function(opts)
      return opts.prev_char:match("%$$") ~= nil
    end)
    :use_key("$"),
})

-- Automatically insert parentheses when confirming functions in nvim-cmp
local ok_cmp, cmp = pcall(require, "cmp")
if ok_cmp then
  local ok_cmp_autopairs, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
  if ok_cmp_autopairs then
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end
end
