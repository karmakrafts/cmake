include(IncludeGuard)
include_guard_start(KSTD_CORE)

set(KSTD_CORE_VERSION master)
set(KSTD_CORE_FETCHED OFF)

macro(target_include_kstd_core target)
    if (NOT KSTD_CORE_FETCHED)
        FetchContent_Declare(
                kstd-core
                GIT_REPOSITORY https://github.com/karmakrafts/kstd-core.git
                GIT_TAG "${KSTD_CORE_VERSION}"
        )
        FetchContent_MakeAvailable(kstd-core)
        set(KSTD_CORE_FETCHED ON)
    endif ()

    target_include_directories(${target} PUBLIC "${CMAKE_CURRENT_BINARY_DIR}/_deps/kstd-core-src/include")
endmacro()

include_guard_end(KSTD_CORE)