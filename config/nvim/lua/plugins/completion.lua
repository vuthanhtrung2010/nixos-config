local ok_cmp, cmp = pcall(require, "cmp")
local ok_luasnip, luasnip = pcall(require, "luasnip")

if not ok_cmp then
  return
end

local sources = {}
if pcall(require, "cmp_luasnip") then
  table.insert(sources, { name = "luasnip" })
end
if pcall(require, "cmp_buffer") then
  table.insert(sources, { name = "buffer" })
end
if pcall(require, "cmp_path") then
  table.insert(sources, { name = "path" })
end

cmp.setup({
  snippet = {
    expand = function(args)
      if ok_luasnip then
        luasnip.lsp_expand(args.body)
      end
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif ok_luasnip and luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif ok_luasnip and luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources(sources),
})
