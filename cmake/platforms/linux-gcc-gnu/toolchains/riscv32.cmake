if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
	set(CMAKE_SYSTEM_NAME "Linux")
endif()

set(CMAKE_SYSTEM_PROCESSOR "riscv32")
set(CMAKE_C_COMPILER "riscv32-linux-gnu-gcc")
set(CMAKE_CXX_COMPILER "riscv32-linux-gnu-g++")
