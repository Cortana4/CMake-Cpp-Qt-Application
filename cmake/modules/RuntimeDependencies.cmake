if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
	set(RUNTIME_DEP_PRE_EXCLUDE_REGEXES
		"^api-ms-.*\\.dll$"
		"^ext-ms-.*\\.dll$"
		"^kernel32\\.dll$"
		"^msvcrt\\.dll$"
		"^ucrtbase\\.dll$"
		"^ucrtbased\\.dll$"
	)

	set(RUNTIME_DEP_POST_EXCLUDE_REGEXES
		".*[\\\\/]([Ww]indows|[Ss]ystem32)[\\\\/].*"
	)

	option(APP_LOCAL_MSVC_RUNTIME "" ON)
	if(NOT APP_LOCAL_MSVC_RUNTIME)
		list(APPEND RUNTIME_DEP_PRE_EXCLUDE_REGEXES
			"^msvcp140.*\\.dll$"
			"^vcruntime140.*\\.dll$"
		)
	endif()

elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
	set(RUNTIME_DEP_PRE_EXCLUDE_REGEXES
		"^libc\\.so(\\..*)*$"
		"^libm\\.so(\\..*)*$"
		"^libgcc_s\\.so(\\..*)*$"
		"^libstdc\\+\\+\\.so(\\..*)*$"
		"^ld-linux.*\\.so(\\..*)*$"
	)

	set(RUNTIME_DEP_POST_EXCLUDE_REGEXES
		"^/(lib|lib64|usr/lib|usr/lib64)/.*"
	)
endif()

## When cross compiling, CMake does not include the toolchain directory
## when looking for runtime dependencies. However, the toolchain itself
## knows which directories must be included. CMake derives that information
## via CMAKE_<LANG>_IMPLICIT_LINK_DIRECTORIES. Unfortunately, this cache
## variable only holds the search directories for static libraries. To get
## the shared library directories, we have to replace "/lib" with "/bin".

## iterate over the implicit link directories for all enabled languages
get_property(enabled_languages GLOBAL PROPERTY ENABLED_LANGUAGES)
foreach(lang IN LISTS enabled_languages)
	foreach(dir IN LISTS CMAKE_${lang}_IMPLICIT_LINK_DIRECTORIES)
		## check if directory ends with "lib"
		cmake_path(GET dir FILENAME directory_name)
		if(directory_name STREQUAL "lib")
			## replace "lib" with "bin"
			cmake_path(GET dir PARENT_PATH parent_directory)
			set(bin_dir "${parent_directory}/bin")

			## only append existing directories
			if(IS_DIRECTORY "${bin_dir}")
				list(APPEND RUNTIME_DEP_DIRECTORIES "${bin_dir}")
			endif()
		endif()
	endforeach()
endforeach()

list(REMOVE_DUPLICATES RUNTIME_DEP_DIRECTORIES)
