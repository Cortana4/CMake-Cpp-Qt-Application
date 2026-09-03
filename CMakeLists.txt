cmake_minimum_required(VERSION 3.22)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

project("Qt Template Project" LANGUAGES C CXX)

include(ProjectLayout)
include(RuntimeDependencies)
include(RuntimeLibraryLinkage)
include(DeploymentTools)

option(BUILD_SHARED_LIBS "build dynamic project libraries" OFF)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_config_to_install_prefix()

add_subdirectory("App")
