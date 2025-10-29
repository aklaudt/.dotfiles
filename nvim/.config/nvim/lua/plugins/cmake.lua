-- CMake UX inside Neovim: :CMakeGenerate / :CMakeBuild / :CMakeOpenBuild
return {
  "Civitasv/cmake-tools.nvim",
  ft = { "c", "cpp", "cmake" },
  opts = {
    cmake_regenerate_on_save = true,
    cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" },
    cmake_build_directory = "build",
  },
}

