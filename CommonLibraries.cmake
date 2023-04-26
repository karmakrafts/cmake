include(IncludeGuard)
include_guard_start(COMMON_LIBS)

include(FetchContent)
include(Platform)
set(CL_DEPS_DIR "${CMAKE_CURRENT_BINARY_DIR}/_deps")

# CMake Scripts
set(CL_SCRIPTS_VERSION 23.04)
set(CL_SCRIPTS_FETCHED OFF)

macro(include_scripts)
    if (NOT CL_SCRIPTS_FETCHED)
        FetchContent_Declare(
                cmake_scripts
                GIT_REPOSITORY https://github.com/StableCoder/cmake-scripts.git
                GIT_TAG ${KSTD_SCRIPTS_VERSION})
        FetchContent_Populate(cmake_scripts)

        set(CMAKE_MODULE_PATH "${CL_DEPS_DIR}/cmake_scripts-src;")
        set(ENABLE_ALL_WARNINGS ON)

        include(compiler-options)

        if (NOT COMPILER_MSVC)
            if(${BUILD_DEBUG})
                set(USE_SANITIZER Thread,Undefined)
            else()
                set(USE_SANITIZER "")
            endif()

            include(sanitizers)
        endif ()

        set(CL_SCRIPTS_FETCHED ON)
    endif ()
endmacro()

# GoogleTest
set(CL_GTEST_VERSION 1.13.0)
set(CL_GTEST_FETCHED OFF)

macro(target_include_gtest target)
    if (NOT CL_GTEST_FETCHED)
        FetchContent_Declare(
                googletest
                GIT_REPOSITORY https://github.com/google/googletest.git
                GIT_TAG "v${CL_GTEST_VERSION}")
        set(gtest_force_shared_crt OFF CACHE BOOL "" FORCE)
        FetchContent_MakeAvailable(googletest)

        enable_testing(TRUE)
        include(GoogleTest)
        set(CL_GTEST_FETCHED ON)
    endif ()

    gtest_discover_tests(${target})
    target_link_libraries(${target} gtest_main)
endmacro()

# {fmt}
set(CL_FMT_VERSION 9.1.0)
set(CL_FMT_FETCHED OFF)

macro(target_include_fmt target)
    if (NOT CL_FMT_FETCHED)
        FetchContent_Declare(
                fmt
                GIT_REPOSITORY https://github.com/fmtlib/fmt.git
                GIT_TAG ${CL_FMT_VERSION}
        )
        FetchContent_MakeAvailable(fmt)
        set(CL_FMT_FETCHED ON)
    endif ()

    target_compile_definitions(${target} PUBLIC FMT_HEADER_ONLY)
    target_include_directories(${target} PUBLIC ${CL_DEPS_DIR}/fmt-src/include)
endmacro()

# parallel_hashmap
set(CL_PHMAP_VERSION 1.3.11)
set(CL_PHMAP_FETCHED OFF)

macro(target_include_phmap target)
    if (NOT CL_PHMAP_FETCHED)
        FetchContent_Declare(
                phmap
                GIT_REPOSITORY https://github.com/greg7mdp/parallel-hashmap.git
                GIT_TAG "v${CL_PHMAP_VERSION}"
        )
        FetchContent_MakeAvailable(phmap)
        set(CL_PHMAP_FETCHED ON)
    endif ()

    target_compile_definitions(${target} PUBLIC _SILENCE_CXX23_ALIGNED_STORAGE_DEPRECATION_WARNING)
    target_include_directories(${target} PUBLIC ${CL_DEPS_DIR}/phmap-src)
endmacro()

# SDL (Just macros since we use Find-scripts)
macro(target_include_sdl target)
    set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake;")
    find_package(SDL2 REQUIRED)
    target_include_directories(${target} PUBLIC ${SDL2_INCLUDE_DIR})
    target_link_libraries(${target} ${SDL2_LIBRARIES})
endmacro()

macro(target_include_sdl_image target)
    set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake;")
    find_package(SDL2_image REQUIRED)
    target_include_directories(${target} PUBLIC ${SDL2_IMAGE_INCLUDE_DIR})
    target_link_libraries(${target} ${SDL2_IMAGE_LIBRARIES})
endmacro()

macro(target_include_sdl_mixer target)
    set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake;")
    find_package(SDL2_mixer REQUIRED)
    target_include_directories(${target} PUBLIC ${SDL2_MIXER_INCLUDE_DIR})
    target_link_libraries(${target} ${SDL2_MIXER_LIBRARIES})
endmacro()

macro(target_include_sdl_ttf target)
    set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake;")
    find_package(SDL2_ttf REQUIRED)
    target_include_directories(${target} PUBLIC ${SDL2_TTF_INCLUDE_DIR})
    target_link_libraries(${target} ${SDL2_TTF_LIBRARIES})
endmacro()

macro(target_include_sdl_net target)
    set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake;")
    find_package(SDL2_net REQUIRED)
    target_include_directories(${target} PUBLIC ${SDL2_NET_INCLUDE_DIR})
    target_link_libraries(${target} ${SDL2_NET_LIBRARIES})
endmacro()

include_guard_end(COMMON_LIBS)