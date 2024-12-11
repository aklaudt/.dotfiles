return {
  name = "cmake build",
  builder = function()
    return {
      cmd = { "cmake --build ." },
      components = {
        "on_result_diagnostics",
        "default",
      },
    }
  end,
  condition = {
    filetype = { "cpp", "h" },
  },
}
