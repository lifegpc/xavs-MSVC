cmake_minimum_required(VERSION 3.11)

set(XAVS_VERSION_MAJOR 55)
set(XAVS_VERSION ${XAVS_VERSION_MAJOR})

project(xavs VERSION ${XAVS_VERSION})

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

option(BUILD_SHARED_LIBS "Build shared library." ON)
option(BUILD_STATIC_LIBS "Build static library." ON)
option(BUILD_TOOL "Build tool" ON)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

if (MSVC)
    find_package(pthread REQUIRED)
    include_directories(${pthread_INCLUDE_DIRS})
endif()

set(LIB_OBJS encoder/analyse.h encoder/analyse.c encoder/cavlc.c encoder/encoder.c
encoder/eval.c encoder/lookahead.c encoder/macroblock.h encoder/macroblock.c encoder/me.h
encoder/me.c encoder/ratecontrol.h encoder/ratecontrol.c encoder/set.h encoder/set.c
common/common.c common/cpu.c common/csp.c common/dct.c common/frame.c common/macroblock.c
common/mc.c common/mdate.c common/pixel.c common/predict.c common/quant.c common/set.c
common/bs.h common/common.h common/cpu.h common/csp.h common/dct.h common/frame.h
common/macroblock.h common/mc.h common/osdep.h common/pixel.h common/predict.h
common/quant.h common/set.h common/vlc.h)

set(PUBLIC_HEADERS xavs.h)

if (MSVC)
    list(APPEND LIB_OBJS extras/getopt.c extras/getopt.h)
    configure_file(dll.rc.in dll.rc)
    set(DLL_RC_FILE ${CMAKE_CURRENT_BINARY_DIR}/dll.rc)
    if (BUILD_TOOL)
        configure_file(exe.rc.in exe.rc)
        set(EXE_RC_FILE ${CMAKE_CURRENT_BINARY_DIR}/exe.rc)
    endif()
endif()

if (BUILD_SHARED_LIBS)
    add_library(libxavs SHARED ${LIB_OBJS} ${DLL_RC_FILE})
    set_target_properties(libxavs PROPERTIES OUTPUT_NAME xavs)
    if(MSVC)
        target_link_options(libxavs PRIVATE "/DEF:${CMAKE_CURRENT_SOURCE_DIR}/libxavs.def")
    endif()
    list(APPEND TARGETS libxavs)
    if (MSVC)
        target_link_libraries(libxavs pthread::pthread)
    endif()
endif()
if (BUILD_STATIC_LIBS)
    add_library(libxavs-static STATIC ${LIB_OBJS})
    if (NOT MSVC OR (MSVC AND NOT BUILD_SHARED_LIBS))
        set_target_properties(libxavs-static PROPERTIES OUTPUT_NAME xavs)
    else()
        set_target_properties(libxavs-static PROPERTIES OUTPUT_NAME xavs-static)
    endif()
    list(APPEND TARGETS libxavs-static)
    if (MSVC)
        target_link_libraries(libxavs-static pthread::pthread)
    endif()
endif()

if (NOT CMAKE_INSTALL_LIBDIR)
    set(CMAKE_INSTALL_LIBDIR lib)
endif()
if (NOT CMAKE_INSTALL_INCLUDEDIR)
    set(CMAKE_INSTALL_INCLUDEDIR include)
endif()
if (NOT CMAKE_INSTALL_BINDIR)
    set(CMAKE_INSTALL_BINDIR bin)
endif()

install(TARGETS ${TARGETS}
LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

install(FILES ${PUBLIC_HEADERS} TYPE INCLUDE)

if (BUILD_TOOL)
    set(EXE_OBJS matroska.h matroska.c muxers.h muxers.c xavs.h xavs.c)
    if (MSVC)
        list(APPEND EXE_OBJS extras/getopt.c extras/getopt.h)
    endif()
    if (BUILD_SHARED_LIBS)
        set(LINK_TARGET libxavs)
    else()
        set(LINK_TARGET libxavs-static)
    endif()
    add_executable(xavs ${EXE_OBJS} ${EXE_RC_FILE})
    target_include_directories(xavs PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/extras)
    target_link_libraries(xavs ${LINK_TARGET})
    install(TARGETS xavs)
endif()
