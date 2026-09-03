set(CMAKE_SYSTEM_NAME "Generic")
set(CMAKE_SYSTEM_PROCESSOR "riscv32")
set(CMAKE_C_COMPILER "riscv-none-elf-gcc.exe")
set(CMAKE_CXX_COMPILER "riscv-none-elf-g++.exe")
set(CMAKE_ASM_COMPILER "riscv-none-elf-as.exe")

set(CMAKE_C_FLAGS_INIT "-march=rv32imf_zicsr_zifencei -mabi=ilp32")
set(CMAKE_CXX_FLAGS_INIT "-march=rv32imf_zicsr_zifencei -mabi=ilp32")
