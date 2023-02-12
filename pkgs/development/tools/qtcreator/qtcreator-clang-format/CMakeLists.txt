cmake_minimum_required(VERSION 3.13.4)

project(qtcreator-clang-format)

include(GNUInstallDirs)

find_package(Clang REQUIRED)

# note: target name cannot be "clang-format"
# because "find_package(Clang" creates the imported target "clang-format"
# and cmake cannot rename targets
# see also: Project-level namespaces
# https://gitlab.kitware.com/cmake/cmake/-/issues/22687
add_executable(qtcreator-clang-format
  ClangFormat.cpp
  )

# set output file name
set_target_properties(qtcreator-clang-format
  PROPERTIES
  OUTPUT_NAME clang-format
)

set(CLANG_FORMAT_LIB_DEPS
  clangBasic
  clangFormat
  clangRewrite
  clangToolingCore
  )

target_link_libraries(qtcreator-clang-format
  PRIVATE
  ${CLANG_FORMAT_LIB_DEPS}
  )

install(TARGETS qtcreator-clang-format
  DESTINATION ${CMAKE_INSTALL_BINDIR}
)
