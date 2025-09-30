cmake_minimum_required(VERSION 3.22)

project("App Project")

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

## name of target binary, component and runtime dependency set
set(TARGET_NAME "app")
set(COMPONENT_NAME "${TARGET_NAME}")
set(RUNTIME_DEP_SET_NAME "${TARGET_NAME}_runtime_deps")

## header files
file(GLOB_RECURSE INC_FILES "include/*.h")

## source files
file(GLOB_RECURSE SRC_FILES "src/*.cpp")

## setup Qt
find_package(Qt6 REQUIRED COMPONENTS Core)
qt_standard_project_setup()

## add source and header files to this project's executable
qt_add_executable("${TARGET_NAME}" ${SRC_FILES} ${INC_FILES})

## on windows, don't open the console window for release builds
if(CMAKE_SYSTEM_NAME STREQUAL "Windows" AND CMAKE_BUILD_TYPE STREQUAL "Release")
	## when using WIN32_EXECUTABLE ON, the linker expects a WinMain entry point, so
	## we have to set /ENTRY manually to use the default main entry point instead
	set_target_properties("${TARGET_NAME}" PROPERTIES WIN32_EXECUTABLE ON)
	target_link_options("${TARGET_NAME}" PRIVATE "/ENTRY:mainCRTStartup")
endif()

## add include directories
target_include_directories("${TARGET_NAME}" PRIVATE "include")

## add libraries
# via vcpkg
#find_package(<lib> CONFIG REQUIRED)
#target_link_libraries("${TARGET_NAME}" PRIVATE <lib>)
#
# manually
#add_library(<lib> SHARED IMPORTED)
#set_target_properties(<lib> PROPERTIES
#	IMPORTED_IMPLIB <path to .lib/.a>
#	IMPORTED_LOCATION <path to .dll/.so>
#	INTERFACE_INCLUDE_DIRECTORIES <path to include>
#)
#target_link_libraries("${TARGET_FILE}" PRIVATE <lib>)
#add_custom_command(TARGET "${TARGET_FILE}" POST_BUILD
#	COMMAND ${CMAKE_COMMAND} -E copy_if_different
#	"$<TARGET_FILE:<lib>>" "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
#	VERBATIM
#)
#install(IMPORTED_RUNTIME_ARTIFACTS <lib>
#	RUNTIME_DEPENDENCY_SET "${RUNTIME_DEP_SET_NAME}"
#	RUNTIME DESTINATION "${RUNTIME_INSTALL_DIRECTORY}"
#	LIBRARY DESTINATION "${LIBRARY_INSTALL_DIRECTORY}"
#	COMPONENT "${COMPONENT_NAME}"
#)

# Qt6
find_package(Qt6 REQUIRED COMPONENTS Widgets)
target_link_libraries("${TARGET_NAME}" PRIVATE Qt6::Widgets)

# copy Qt platform plugins etc. to the build directory
util_add_post_build_qt_deploy("${TARGET_NAME}")

## make assets available in the build directory via symlink
#util_add_post_build_create_symlink("${TARGET_NAME}"
#	"${CMAKE_CURRENT_SOURCE_DIR}/resources"
#	"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/resources"
#)

## install executable, shared and static libraries
install(TARGETS "${TARGET_NAME}"
	RUNTIME_DEPENDENCY_SET "${RUNTIME_DEP_SET_NAME}"
	RUNTIME DESTINATION "${RUNTIME_INSTALL_DIRECTORY}"
	LIBRARY DESTINATION "${LIBRARY_INSTALL_DIRECTORY}"
	ARCHIVE DESTINATION "${ARCHIVE_INSTALL_DIRECTORY}"
	COMPONENT "${COMPONENT_NAME}"
)
install(RUNTIME_DEPENDENCY_SET "${RUNTIME_DEP_SET_NAME}"
	DESTINATION "${LIBRARY_INSTALL_DIRECTORY}"
	COMPONENT "${COMPONENT_NAME}"
	PRE_EXCLUDE_REGEXES ${GLOBAL_DEP_PRE_EXCLUDE_REGEXES}
	POST_EXCLUDE_REGEXES ${GLOBAL_DEP_POST_EXCLUDE_REGEXES}
)

## install Qt platform plugins etc.
util_install_qt_dependencies("${TARGET_NAME}")

## install assets
#install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/resources" DESTINATION "${RUNTIME_INSTALL_DIRECTORY}")
