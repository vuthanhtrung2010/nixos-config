local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- function to get current time
local function current_time()
  return os.date("%d/%m/%Y %H:%M:%S")
end

ls.add_snippets("cpp", {
  s("cp", {
    t({
      "//Make KM great again",
      "//Vengeance",
      "#include <iostream>",
      "",
      "using namespace std;",
      "",
      "using ll = long long;",
      "using ui = unsigned int;",
      "using ull = unsigned long long;",
      "using ld = long double;",
      "",
      "signed main() {",
      "    cin.tie(nullptr)->sync_with_stdio(false);",
      "    ",
      "}",
      "",
      "// Author: devtrung",
      "// Created: ",
    }),
    f(current_time, {}), -- 🔥 dynamic time here
    t({ "" }),
    i(1),
  }),
})
