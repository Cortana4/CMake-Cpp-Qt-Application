if(DEFINED ENV{XWIN_ROOT} AND NOT "$ENV{XWIN_ROOT}" STREQUAL "")
	set(XWIN_ROOT "$ENV{XWIN_ROOT}")
else()
	set(XWIN_ROOT "/opt/xwin")
	message(WARNING "XWIN_ROOT not defined, using default value '${XWIN_ROOT}'")
endif()

if(NOT DEFINED XWIN_ARCH)
	message(FATAL_ERROR "XWIN_ARCH not defined")
endif()

set(APP_LOCAL_MSVC_RUNTIME OFF)

set(xwin_compiler_flags_list
	"-imsvc${XWIN_ROOT}/crt/include"
	"-imsvc${XWIN_ROOT}/sdk/include/cppwinrt"
	"-imsvc${XWIN_ROOT}/sdk/include/shared"
	"-imsvc${XWIN_ROOT}/sdk/include/ucrt"
	"-imsvc${XWIN_ROOT}/sdk/include/um"
	"-imsvc${XWIN_ROOT}/sdk/include/winrt"
)

set(xwin_linker_flags_list
	"/libpath:${XWIN_ROOT}/crt/lib/${XWIN_ARCH}"
	"/libpath:${XWIN_ROOT}/sdk/lib/ucrt/${XWIN_ARCH}"
	"/libpath:${XWIN_ROOT}/sdk/lib/um/${XWIN_ARCH}"
)

list(JOIN xwin_compiler_flags_list " " XWIN_COMPILER_FLAGS)
list(JOIN xwin_linker_flags_list " " XWIN_LINKER_FLAGS)
