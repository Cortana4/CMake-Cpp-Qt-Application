include_guard(GLOBAL)

function(util_add_post_build_create_symlink TARGET_NAME SRC_DIR DST_DIR)
	cmake_path(GET DST_DIR PARENT_PATH DST_PARENT_DIR)

	## the built-in cmake command "create_symlink" needs privileges on windows,
	## so we create a junction using native tools instead
	if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
		cmake_path(NATIVE_PATH SRC_DIR SRC_NATIVE_DIR)
		cmake_path(NATIVE_PATH DST_DIR DST_NATIVE_DIR)

		add_custom_command(TARGET "${TARGET_NAME}" POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E make_directory "${DST_PARENT_DIR}"
			COMMAND ${CMAKE_COMMAND} -E rm -rf "${DST_DIR}"
			COMMAND cmd /c mklink /j "${DST_NATIVE_DIR}" "${SRC_NATIVE_DIR}"
			VERBATIM
		)
	## on linux we use the built-in create_symlink command
	else()
		add_custom_command(TARGET "${TARGET_NAME}" POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E make_directory "${DST_PARENT_DIR}"
			COMMAND ${CMAKE_COMMAND} -E rm -rf "${DST_DIR}"
			COMMAND ${CMAKE_COMMAND} -E create_symlink "${SRC_DIR}" "${DST_DIR}"
			VERBATIM
		)
	endif()
endfunction()

function(util_add_post_build_qt_deploy TARGET_NAME)
	## on windows, vcpkg does copy dependent .dll files to the build directory,
	## but that does not include Qt platform plugins etc., so we have to run
	## windeployqt after build in order to run the program from the build directory
	if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
		add_custom_command(TARGET "${TARGET_NAME}" POST_BUILD
			COMMAND Qt6::windeployqt
			ARGS "$<TARGET_FILE:${TARGET_NAME}>"
		)
	endif()
	
	## on linux, vcpkg sets the RPATH/RUNPATH, meaning that all dependent .so
	## files are found in the vcpkg_installed directory, so no copy operation
	## is needed
endfunction()

function(util_install_qt_dependencies TARGET_NAME)
	if(NOT BUILD_SHARED_LIBS)
		return()
	endif()
	
	## neither cmake nor vcpkg handle the copy of the Qt platform plugins etc. on
	## install. In order to have a self contained install directory, we need to
	## copy these files with a generated script. The generated script fails, when
	## the parent path does not exist. The parent paths are created when RUNTIME,
	## LIBRARY and ARCHIVE install targets run. So make sure these run first.
	
	if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
		qt_generate_deploy_script(
			TARGET "${TARGET_NAME}"
			OUTPUT_SCRIPT DEPLOY_SCRIPT
			CONTENT "
set(QT_DEPLOY_PREFIX \"${CMAKE_INSTALL_PREFIX}/bin\")
set(QT_DEPLOY_BIN_DIR \".\")
set(QT_DEPLOY_PLUGINS_DIR \".\")

qt_deploy_runtime_dependencies(
	EXECUTABLE \"$<TARGET_FILE:${TARGET_NAME}>\"
)")

	elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
		qt_generate_deploy_script(
			TARGET "${TARGET_NAME}"
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
	EXECUTABLE \"$<TARGET_FILE:${TARGET_NAME}>\"
	GENERATE_QT_CONF
)")

	endif()
	
	## install Qt platform plugins etc. with the generated script
	install(SCRIPT "${DEPLOY_SCRIPT}")
endfunction()
