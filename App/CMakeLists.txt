cmake_minimum_required(VERSION 3.22)

project("App Project")

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

## target binary file
set(TARGET_FILE "app")

## header files
file(GLOB_RECURSE INC_FILES "include/*.h")

## source files
file(GLOB_RECURSE SRC_FILES "src/*.cpp")

## setup Qt
find_package(Qt6 REQUIRED COMPONENTS Core)
qt_standard_project_setup()

## add source and header files to this project's executable
qt_add_executable("${TARGET_FILE}" ${SRC_FILES} ${INC_FILES})

## add include directories
target_include_directories("${TARGET_FILE}" PRIVATE "include")

## add libraries
# Qt6
find_package(Qt6 REQUIRED COMPONENTS Widgets)
target_link_libraries("${TARGET_FILE}" PRIVATE Qt6::Widgets)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
	## on windows, don't open the console window for release builds
	if(CMAKE_BUILD_TYPE STREQUAL "Release")
		set_target_properties("${TARGET_FILE}" PROPERTIES WIN32_EXECUTABLE ON)

		## when using WIN32_EXECUTABLE ON, the linker expects a WinMain entry point, so
		## we have to set /ENTRY manually to use the default main entry point instead
		target_link_options("${TARGET_FILE}" PRIVATE "/ENTRY:mainCRTStartup")
	endif()
endif()

util_add_post_build_qt_deploy("${TARGET_FILE}")

## make files needed at runtime available in the build directory via symlink
#util_add_post_build_create_symlink("${TARGET_FILE}"
#	"${CMAKE_CURRENT_SOURCE_DIR}/resources"
#	"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/resources"
#)

## install exetutable, shared and static libraries
install(TARGETS "${TARGET_FILE}" RUNTIME DESTINATION "${RUNTIME_INSTALL_DIRECTORY}")
install(TARGETS "${TARGET_FILE}" LIBRARY DESTINATION "${LIBRARY_INSTALL_DIRECTORY}")
install(TARGETS "${TARGET_FILE}" ARCHIVE DESTINATION "${ARCHIVE_INSTALL_DIRECTORY}")

## install Qt platform plugins etc.
util_install_qt_dependencies("${TARGET_FILE}")

## install resources folder
#install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/resources" DESTINATION "${RUNTIME_INSTALL_DIRECTORY}")
