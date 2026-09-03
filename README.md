## Overview

This is a universal C++ CMake template project with arbitrary compiler and
architecture support. Many compilers and architectures are supported out of
the box and missing ones can easily be added by providing the necessary
toolchains, triplets and presets. Even cross compilation is supported. The
project relies on the vcpkg package manager, so that third party libraries can
easily be used in the project. To get started, you only need a compiler, CMake,
Ninja and of course vcpkg installed on your machine. For cross compilation,
you also need the libraries and headers of the target system. All dependencies
that are needed to run the executable are automatically copied to the
installation folder during the CMake install target. By having a self-contained
install folder, you get a portable executable, that can easily be shared and
run across systems.


## Getting Started

- First make sure that all tools (compiler, CMake, Ninja, vcpkg) are on your
  PATH and that the VCPKG_ROOT environment variable is set. Then clone the
  repository:

  `git clone https://github.com/Cortana4/CMake-Cpp-Console-Application.git`

- Rename the cloned folder, cd into it and delete the .git folder.

- Start fresh by initializing a new repository:

  `git init`<br>
  `git branch -M main`<br>
  `git remote add origin <URL>`<br>
  `git add --all`<br>
  `git commit -m "initial commit"`<br>
  `git push -u origin main`

- Now you can list all available presets for yor machine by running the
  following command in the root of your repository:

  `cmake --list-presets=all .`

- Choose a configure preset and configure the cache:

  `cmake --preset=<preset>`

- build and install:

  `cmake --build <build directory> --config=<Debug|Release|RelWithDebInfo>`<br>
  `cmake --install <build directory> --config=<Debug|Release|RelWithDebInfo>`

#### Windows Example

`cmake --preset=windows-msvc-x64-dynamic`<br>
`cmake --build build/windows-msvc-x64-dynamic --config=Release`<br>
`cmake --install build/windows-msvc-x64-dynamic --config=Release`<br>

#### Linux Example

`cmake --preset=linux-gcc-gnu-x64-static`<br>
`cmake --build build/linux-gcc-gnu-x64-static --config=Release`<br>
`cmake --install build/linux-gcc-gnu-x64-static --config=Release`<br>

## XWin
[XWin](https://github.com/Jake-Shadle/xwin) is a useful tool when cross
compiling for Windows. It can download headers and libraries needed for
compiling and linking programs targeting Windows. To use it, simply run
the following command and set the XWIN_ROOT environment variable.

```bash
xwin \
  --accept-license \
  --arch x86,x86_64,aarch64 \
  splat \
  --include-debug-libs \
  --include-debug-symbols \
  --output /opt/xwin
```

## Troubleshoot

- The path to your repository must not contain whitespaces or special chars.

#### Windows specific

- The path to your repository must be as short as possible.
- Update PowerShell to latest version (especially if pkgconf fails to build).

#### Linux specific

- Check logs if packages from system package manager must be installed.
