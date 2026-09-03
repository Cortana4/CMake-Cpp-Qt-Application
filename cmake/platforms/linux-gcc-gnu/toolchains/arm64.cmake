if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
	set(CMAKE_SYSTEM_NAME "Linux")
endif()

set(CMAKE_SYSTEM_PROCESSOR "aarch64")
set(CMAKE_C_COMPILER "aarch64-linux-gnu-gcc")
set(CMAKE_CXX_COMPILER "aarch64-linux-gnu-g++")
