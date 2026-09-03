if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
	set(CMAKE_SYSTEM_NAME "Linux")
endif()

set(CMAKE_SYSTEM_PROCESSOR "arm")
set(CMAKE_C_COMPILER "arm-linux-gnu-gcc")
set(CMAKE_CXX_COMPILER "arm-linux-gnu-g++")
