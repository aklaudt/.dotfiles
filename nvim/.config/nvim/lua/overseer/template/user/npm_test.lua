return {
  name = "npm test",
  builder = function()
    return {
      cmd = { "npm run test" },
      components = {
        "on_result_diagnostics",
        "default",
      },
    }
  end,
  condition = {
    filetype = { "ts", "tsx" },
  },
}

