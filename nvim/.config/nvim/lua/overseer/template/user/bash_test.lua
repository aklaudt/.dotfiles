return {
  name = "bash test",
  builder = function()
    return {
      cmd = { "./scripts/run_tests.sh" },
      components = {
        "on_result_diagnostics",
        "default",
      },
    }
  end
}

