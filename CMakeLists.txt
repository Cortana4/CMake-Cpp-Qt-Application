cmake_minimum_required(VERSION 3.22)

project("Qt Template Project")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

## target binary file
set(TARGET_FILE "Cpp-Qt-Application")

## header files
file(GLOB_RECURSE INC_FILES "include/*.h")

## source files
file(GLOB_RECURSE SRC_FILES "src/*.cpp")

## set build directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${RUNTIME_SUBDIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${LIBRARY_SUBDIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${ARCHIVE_SUBDIR}")

## set install directories
set(RUNTIME_INSTALL_DIRECTORY "${CMAKE_INSTALL_PREFIX}/${RUNTIME_SUBDIR}")
set(LIBRARY_INSTALL_DIRECTORY "${CMAKE_INSTALL_PREFIX}/${LIBRARY_SUBDIR}")
set(ARCHIVE_INSTALL_DIRECTORY "${CMAKE_INSTALL_PREFIX}/${ARCHIVE_SUBDIR}")

## setup Qt
find_package(Qt6 REQUIRED COMPONENTS Core)
qt_standard_project_setup()

## add source and header files to this project's executable
qt_add_executable(${TARGET_FILE} ${SRC_FILES} ${INC_FILES})

## add include directories
target_include_directories(${TARGET_FILE} PRIVATE "include")

## add libraries
# Qt6
find_package(Qt6 REQUIRED COMPONENTS Widgets)
target_link_libraries(${TARGET_FILE} PRIVATE Qt6::Widgets)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
	## on windows, don't open the console window for release builds
	if(CMAKE_BUILD_TYPE STREQUAL "Release")
		set_target_properties(${TARGET_FILE} PROPERTIES WIN32_EXECUTABLE ON)

		## when using WIN32_EXECUTABLE ON, the linker expects a WinMain entry point, so
		## we have to set /ENTRY manually to use the default main entry point instead
		target_link_options(${TARGET_FILE} PRIVATE "/ENTRY:mainCRTStartup")
	endif()

	if(BUILD_SHARED_LIBS)
		## on windows, vcpkg does copy dependent .dll files to the build directory,
		## but that does not include Qt platform plugins etc., so we have to run
		## windeployqt after build in order to run the program from the build directory
		add_custom_command(TARGET ${TARGET_FILE} POST_BUILD
			COMMAND Qt6::windeployqt
			ARGS $<TARGET_FILE:${TARGET_FILE}>
		)

		## same applies to the install directory, so we have to generate a script that
		## copies the files for us
		qt_generate_deploy_script(
			TARGET ${TARGET_FILE}
			OUTPUT_SCRIPT DEPLOY_SCRIPT
			CONTENT "
set(QT_DEPLOY_PREFIX \"${CMAKE_INSTALL_PREFIX}/bin\")
set(QT_DEPLOY_BIN_DIR \".\")
set(QT_DEPLOY_PLUGINS_DIR \".\")

qt_deploy_runtime_dependencies(
	EXECUTABLE \"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/$<TARGET_FILE_NAME:${TARGET_FILE}>\"
)")
	endif()

elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
	if(BUILD_SHARED_LIBS)
		## on linux, vcpkg sets the RPATH/RUNPATH, meaning that all dependent .so
		## files are found in the vcpkg_installed directory, so no copy operation
		## is needed

		## however, in order to have a self contained install directory, we still
		## need to copy the files with a generated script
		qt_generate_deploy_script(
			TARGET ${TARGET_FILE}
			OUTPUT_SCRIPT DEPLOY_SCRIPT
			CONTENT "
set(QT_DEPLOY_PREFIX \"${CMAKE_INSTALL_PREFIX}\")
set(QT_DEPLOY_BIN_DIR \"bin\")
set(QT_DEPLOY_LIB_DIR \"lib\")
set(QT_DEPLOY_PLUGINS_DIR \"plugins\")
set(__QT_DEPLOY_MUST_ADJUST_PLUGINS_RPATH \"ON\")

if(\"${CMAKE_BUILD_TYPE}\" STREQUAL \"Debug\")
	set(__QT_DEPLOY_QT_INSTALL_PLUGINS \"debug/Qt6/plugins\")
endif()

qt_deploy_runtime_dependencies(
	EXECUTABLE \"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/$<TARGET_FILE_NAME:${TARGET_FILE}>\"
	GENERATE_QT_CONF
)")
	endif()
endif()

## install exetutable, shared and static libraries
install(TARGETS ${TARGET_FILE} RUNTIME DESTINATION ${RUNTIME_INSTALL_DIRECTORY})
install(TARGETS ${TARGET_FILE} LIBRARY DESTINATION ${LIBRARY_INSTALL_DIRECTORY})
install(TARGETS ${TARGET_FILE} ARCHIVE DESTINATION ${ARCHIVE_INSTALL_DIRECTORY})

## install Qt platform plugins etc.
if(BUILD_SHARED_LIBS)
	install(SCRIPT ${DEPLOY_SCRIPT})
endif()

## install resources folder
install(DIRECTORY resources DESTINATION ${RUNTIME_INSTALL_DIRECTORY})
