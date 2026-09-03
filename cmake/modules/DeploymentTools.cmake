include_guard(GLOBAL)

function(add_post_build_symlink TARGET_NAME SRC_DIR DST_DIR)
	cmake_path(GET DST_DIR PARENT_PATH dst_parent_dir)

	## the built-in cmake command "create_symlink" needs privileges on windows,
	## so we create a junction using native tools instead
	if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
		cmake_path(NATIVE_PATH SRC_DIR src_native_dir)
		cmake_path(NATIVE_PATH DST_DIR dst_native_dir)

		add_custom_command(TARGET "${TARGET_NAME}" POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E make_directory "${dst_parent_dir}"
			COMMAND ${CMAKE_COMMAND} -E rm -rf "${DST_DIR}"
			COMMAND cmd /c mklink /j "${dst_native_dir}" "${src_native_dir}"
			VERBATIM
		)
	## on linux we use the built-in create_symlink command
	else()
		add_custom_command(TARGET "${TARGET_NAME}" POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E make_directory "${dst_parent_dir}"
			COMMAND ${CMAKE_COMMAND} -E rm -rf "${DST_DIR}"
			COMMAND ${CMAKE_COMMAND} -E create_symlink "${SRC_DIR}" "${DST_DIR}"
			VERBATIM
		)
	endif()
endfunction()

function(add_post_build_qt_deployment TARGET_NAME)
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

function(install_qt_dependencies TARGET_NAME)
	## Neither cmake nor vcpkg handle the copy of the Qt platform plugins etc. on
	## install. In order to have a self contained install directory, we need to
	## copy these files with a generated script. The generated script fails, when
	## the parent path does not exist. The parent paths are created when RUNTIME,
	## LIBRARY and ARCHIVE install targets run. So make sure these run first.
	
	if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
		qt_generate_deploy_script(
			TARGET "${TARGET_NAME}"
			OUTPUT_SCRIPT DEPLOY_SCRIPT
			CONTENT "
set(QT_DEPLOY_BIN_DIR \"bin\")
set(QT_DEPLOY_LIB_DIR \"lib\")
set(QT_DEPLOY_PLUGINS_DIR \"bin\")
set(QT_DEPLOY_QML_DIR \"bin/qml\")
set(QT_DEPLOY_TRANSLATIONS_DIR \"bin/translations\")

qt_deploy_runtime_dependencies(
	EXECUTABLE \"$<TARGET_FILE:${TARGET_NAME}>\"
	DEPLOY_TOOL_OPTIONS
		$<$<CONFIG:Debug>:--qtpaths>
		$<$<CONFIG:Debug>:${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools/Qt6/bin/qtpaths.debug.bat>
)")

	elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
		qt_generate_deploy_script(
			TARGET "${TARGET_NAME}"
			OUTPUT_SCRIPT DEPLOY_SCRIPT
			CONTENT "
set(QT_DEPLOY_BIN_DIR \"bin\")
set(QT_DEPLOY_LIB_DIR \"lib\")
set(QT_DEPLOY_PLUGINS_DIR \"Qt6/plugins\")
set(QT_DEPLOY_QML_DIR \"Qt6/qml\")
set(QT_DEPLOY_TRANSLATIONS_DIR \"Qt6/translations\")

qt_deploy_runtime_dependencies(
	EXECUTABLE \"$<TARGET_FILE:${TARGET_NAME}>\"
	GENERATE_QT_CONF
)")
	endif()
	
	## install Qt platform plugins etc. with the generated script
	install(SCRIPT "${DEPLOY_SCRIPT}")
endfunction()

function(add_config_to_install_prefix)
	## Make the configured cmake install prefix config aware, but don't add
	## the config when overwritten with the --prefix option.
	set(configured_install_prefix "${CMAKE_INSTALL_PREFIX}")
	install(CODE "
if(CMAKE_INSTALL_PREFIX STREQUAL \"${configured_install_prefix}\")
	set(CMAKE_INSTALL_PREFIX
		\"\${CMAKE_INSTALL_PREFIX}/\${CMAKE_INSTALL_CONFIG_NAME}\"
	)
endif()
")
endfunction()
