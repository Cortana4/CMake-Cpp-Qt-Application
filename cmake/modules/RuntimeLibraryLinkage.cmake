if (MSVC)
	if(RUNTIME_LIBRARY_LINKAGE STREQUAL "dynamic")
		set(CMAKE_MSVC_RUNTIME_LIBRARY
			"MultiThreaded$<$<CONFIG:Debug>:Debug>DLL"
		)

	elseif(RUNTIME_LIBRARY_LINKAGE STREQUAL "static")
		set(CMAKE_MSVC_RUNTIME_LIBRARY
			"MultiThreaded$<$<CONFIG:Debug>:Debug>"
		)
	endif()

elseif(MINGW AND RUNTIME_LIBRARY_LINKAGE STREQUAL "static")
	add_link_options("-static")
endif()
