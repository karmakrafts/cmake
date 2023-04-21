include(IncludeGuard)
include_guard_start(PLATFORM)

if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(COMPILER_CLANG TRUE)
    add_compile_definitions(COMPILER_CLANG)
    message(STATUS "Detected Clang compiler")
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set(COMPILER_GCC TRUE)
    add_compile_definitions(COMPILER_GCC)
    message(STATUS "Detected GCC compiler")
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(COMPILER_MSVC TRUE)
    add_compile_definitions(COMPILER_MSVC)
    message(STATUS "Detected MSVC compiler")
endif ()

if (CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(CPU_64_BIT TRUE)
    add_compile_definitions(CPU_64_BIT)
else ()
    set(CPU_64_BIT FALSE)
    add_compile_definitions(CPU_32_BIT)
endif ()

if (${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm64|ARM64|aarch64|AArch64")
    set(CPU_ARCH "arm64")
    set(CPU_ARM TRUE)
    set(CPU_ARM64 TRUE)
    message(STATUS "Detected ARM64 based processor")
elseif (${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm|ARM")
    set(CPU_ARCH "arm")
    set(CPU_ARM TRUE)
    message(STATUS "Detected ARM based processor")
elseif (${CMAKE_SYSTEM_PROCESSOR} MATCHES "ppc|powerpc|PPC|PowerPC")
    set(CPU_ARCH "ppc")
    set(CPU_PPC TRUE)
    message(STATUS "Detected PowerPC based processor")
elseif (${CMAKE_SYSTEM_PROCESSOR} MATCHES "x86_64|x64|amd64|AMD64")
    set(CPU_ARCH "x64")
    set(CPU_X86 TRUE)
    set(CPU_X86_64 TRUE)
    message(STATUS "Detected x86_64 based processor")
elseif (${CMAKE_SYSTEM_PROCESSOR} MATCHES "x86|i386|i486|i586|i686")
    set(CPU_ARCH "x86")
    set(CPU_X86 TRUE)
    message(STATUS "Detected x86 based processor")
else ()
    message(FATAL_ERROR "Unsupported processor architecture: ${CMAKE_SYSTEM_PROCESSOR}")
endif ()

if (WIN32)
    set(PLATFORM "Windows")
    set(PLATFORM_WINDOWS TRUE)
    set(PLATFORM_SLIB_EXT "lib")
    set(PLATFORM_DLIB_EXT "dll")
    set(PLATFORM_LIB_PREFIX "")
    add_compile_definitions(PLATFORM_WINDOWS)
    message(STATUS "Detected Windows operating system")
elseif (APPLE)
    set(PLATFORM "MacOS")
    set(PLATFORM_MACOS TRUE)
    set(PLATFORM_UNIX TRUE)
    set(PLATFORM_SLIB_EXT "a")
    set(PLATFORM_DLIB_EXT "dylib")
    set(PLATFORM_LIB_PREFIX "lib")
    add_compile_definitions(PLATFORM_APPLE)
    add_compile_definitions(PLATFORM_UNIX)

    message(STATUS "Detected Mac operating system")
elseif (UNIX)
    if (UNIX AND NOT APPLE)
        set(PLATFORM "Linux")
        set(PLATFORM_LINUX TRUE)
        add_compile_definitions(PLATFORM_LINUX)
        add_compile_definitions(PLATFORM_UNIX)
    else ()
        set(PLATFORM "Unix")
        add_compile_definitions(PLATFORM_UNIX)
    endif ()

    find_program(MOLD_EXECUTABLE "mold")

    if(MOLD_EXECUTABLE)
        message(STATUS "Detected mold linker, substituting")

        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fuse-ld=mold")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fuse-ld=mold")

        if(NOT DEFINED NUM_LINK_THREADS) # So we can pass this in via CLI
			cmake_host_system_information(RESULT NUM_LINK_THREADS QUERY NUMBER_OF_LOGICAL_CORES)
		endif()

        message(STATUS "Using ${NUM_LINK_THREADS} threads for linking")
        add_link_options("LINKER:--threads,--thread-count=${NUM_LINK_THREADS}")
    endif()

    set(PLATFORM_UNIX TRUE)
    set(PLATFORM_SLIB_EXT "a")
    set(PLATFORM_DLIB_EXT "so")
    set(PLATFORM_LIB_PREFIX "lib")
    message(STATUS "Detected Unixoid operating system")
else ()
    message(FATAL_ERROR "Unsupported target platform '${CMAKE_SYSTEM_NAME}'")
endif ()

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(BUILD_TYPE "debug")
    set(BUILD_DEBUG ON)
    add_compile_definitions(BUILD_DEBUG)

    if(PLATFORM_LINUX AND COMPILER_GCC)
        # Enable safe STL, disable inlining and optimizations
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -O0 -fno-inline -D_GLIBCXX_DEBUG_BACKTRACE")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O0 -fno-inline -D_GLIBCXX_DEBUG_BACKTRACE")
    endif()

    if(PLATFORM_WINDOWS AND COMPILER_MSVC)
        add_compile_definitions(_ITERATOR_DEBUG_LEVEL=1) # Enable checked iterators
    endif()
else ()
    set(BUILD_RELEASE ON)
    set(BUILD_TYPE "release")
endif ()

string(TOLOWER ${PLATFORM} LC_PLATFORM)
set(PLATFORM_PAIR "${LC_PLATFORM}-${CPU_ARCH}")
message(STATUS "Determined platform pair '${PLATFORM_PAIR}'")

include_guard_end(PLATFORM)
