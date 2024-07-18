cmake_minimum_required(VERSION 3.8)

## enable hot reload for MSVC compilers if supported.
if(POLICY CMP0141)
	cmake_policy(SET CMP0141 NEW)
	set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT
		"$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>"
	)
endif()

project("Qt Template Project")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

## target binary file
set(TARGET_FILE
	"Cpp-Qt-Application"
)

## header files
set(INC_FILES
	"include/mainWindow.h"
)

## source files
set(SRC_FILES
	"src/main.cpp"
	"src/mainWindow.cpp"
)

## add source and header files to this project's executable
add_executable(${TARGET_FILE} ${SRC_FILES} ${INC_FILES})

## add include directories
target_include_directories(${TARGET_FILE} PRIVATE "include")

## add libraries
# Qt5
find_package(Qt5 REQUIRED COMPONENTS Widgets)
target_link_libraries(${TARGET_FILE} PRIVATE Qt5::Widgets)

## do not open console window
set_target_properties(${TARGET_FILE} PROPERTIES WIN32_EXECUTABLE ON)

## copy resource files to build directory
#add_custom_target(copy_resources ALL
#	COMMAND ${CMAKE_COMMAND} -E remove_directory
#	${CMAKE_CURRENT_BINARY_DIR}/resources
#
#	COMMAND ${CMAKE_COMMAND} -E copy_directory
#	${CMAKE_CURRENT_SOURCE_DIR}/resources
#	${CMAKE_CURRENT_BINARY_DIR}/resources
#)
#add_dependencies(${TARGET_FILE} copy_resources)

## copy dynamic library and resource files from build to install directory
install(TARGETS ${TARGET_FILE} DESTINATION ${CMAKE_INSTALL_PREFIX})
#install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/resources DESTINATION ${CMAKE_INSTALL_PREFIX})
