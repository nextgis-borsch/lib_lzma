################################################################################
# Project:  Lib LZMA
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nexgis.com
################################################################################
# Copyright (C) 2015-2018, NextGIS <info@nextgis.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
################################################################################

cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

project(lzma)

# some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

if(OSX_FRAMEWORK AND (BUILD_SHARED_LIBS OR BUILD_STATIC_LIBS))
  message(FATAL_ERROR "Only OSX_FRAMEWORK key or any or both BUILD_SHARED_LIBS
                       and BUILD_STATIC_LIBS keys are permitted")
endif()

if(OSX_FRAMEWORK)
    set(INSTALL_BIN_DIR "bin" CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR "Library/Frameworks" CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR ${INSTALL_LIB_DIR}/lib${PROJECT_NAME}.framework/Headers CACHE INTERNAL "Installation directory for headers" FORCE)
    set(SKIP_INSTALL_HEADERS ON)
    set(SKIP_INSTALL_EXECUTABLES OFF)
    set(SKIP_INSTALL_FILES ON)
    set(SKIP_INSTALL_EXPORT ON)
    set(CMAKE_MACOSX_RPATH ON)
    set(INSTALL_CMAKECONF_DIR ${INSTALL_LIB_DIR}/lib${PROJECT_NAME}.framework/Resources/CMake CACHE INTERNAL "Installation directory for cmake config files" FORCE)
else()
    include(GNUInstallDirs)

    set(INSTALL_BIN_DIR ${CMAKE_INSTALL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR ${CMAKE_INSTALL_INCLUDEDIR} CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_CMAKECONF_DIR ${CMAKE_INSTALL_DATADIR}/lib${PROJECT_NAME}/CMake CACHE INTERNAL "Installation directory for cmake config files" FORCE)
endif()

include(util)
check_version(LZMA_MAJOR_VERSION LZMA_MINOR_VERSION LZMA_REV_VERSION)
set(VERSION ${LZMA_MAJOR_VERSION}.${LZMA_MINOR_VERSION}.${LZMA_REV_VERSION})

if(OSX_FRAMEWORK)
    set(FRAMEWORK_VERSION "${LZMA_MAJOR_VERSION}")
endif()

include(FindAnyProject)
find_anyproject(ICONV)

if(ICONV_FOUND)
    set(HAVE_ICONV TRUE)
endif()

if(MSVC)
    if(CMAKE_C_COMPILER_VERSION VERSION_LESS "18.0.31101.0")
        message(FATAL_ERROR "The compiled version is less than VC 2013 SP 4")
    endif()

    add_definitions (-D_CRT_NONSTDC_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NON_CONFORMING_SWPRINTFS -D_CRT_SECURE_NO_DEPRECATE)
endif()

include(configure)

configure_file(${CMAKE_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake IMMEDIATE @ONLY)

include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/common )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/liblzma )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/liblzma/api )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/liblzma/check )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/liblzma/common )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/liblzma/delta )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/liblzma/lz )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/liblzma/lzma )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/liblzma/rangecoder )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/liblzma/simple )
include_directories ( ${CMAKE_CURRENT_BINARY_DIR} )

set(PUBLIC_HDRS
    liblzma/api/lzma.h
)

set(PUBLIC_LZMA_HDRS
    liblzma/api/lzma/base.h
    liblzma/api/lzma/bcj.h
    liblzma/api/lzma/block.h
    liblzma/api/lzma/check.h
    liblzma/api/lzma/container.h
    liblzma/api/lzma/delta.h
    liblzma/api/lzma/filter.h
    liblzma/api/lzma/hardware.h
    liblzma/api/lzma/index.h
    liblzma/api/lzma/index_hash.h
    liblzma/api/lzma/lzma12.h
    liblzma/api/lzma/stream_flags.h
    liblzma/api/lzma/version.h
    liblzma/api/lzma/vli.h
)

set(PRIVATE_HDRS
    ${CMAKE_CURRENT_BINARY_DIR}/config.h
    common/sysdefs.h
	liblzma/common/block_buffer_encoder.h
	liblzma/common/block_encoder.h
	liblzma/common/filter_encoder.h
	liblzma/common/index_encoder.h
	liblzma/common/alone_decoder.h
	liblzma/common/block_decoder.h
	liblzma/common/filter_decoder.h
	liblzma/common/stream_decoder.h
    common/tuklib_physmem.h
    liblzma/check/check.h
)

set(SRCS
    liblzma/common/alone_encoder.c
    liblzma/common/block_buffer_encoder.c
    liblzma/common/block_encoder.c
    liblzma/common/block_header_encoder.c
    liblzma/common/easy_buffer_encoder.c
    liblzma/common/easy_encoder.c
    liblzma/common/easy_encoder_memusage.c
    liblzma/common/filter_buffer_encoder.c
    liblzma/common/filter_encoder.c
    liblzma/common/filter_flags_encoder.c
    liblzma/common/index_encoder.c
    liblzma/common/stream_buffer_encoder.c
    liblzma/common/stream_encoder.c
    liblzma/common/stream_flags_encoder.c
    liblzma/common/vli_encoder.c
    liblzma/common/alone_decoder.c
    liblzma/common/auto_decoder.c
    liblzma/common/block_buffer_decoder.c
    liblzma/common/block_decoder.c
    liblzma/common/block_header_decoder.c
    liblzma/common/easy_decoder_memusage.c
    liblzma/common/filter_buffer_decoder.c
    liblzma/common/filter_decoder.c
    liblzma/common/filter_flags_decoder.c
    liblzma/common/index_decoder.c
    liblzma/common/index_hash.c
    liblzma/common/index.c
    liblzma/common/stream_buffer_decoder.c
    liblzma/common/stream_decoder.c
    liblzma/common/stream_flags_decoder.c
    liblzma/common/vli_decoder.c
    liblzma/common/common.c
    liblzma/common/block_util.c
    liblzma/common/easy_preset.c
    liblzma/common/filter_common.c
    liblzma/common/hardware_physmem.c
    liblzma/common/stream_flags_common.c
    liblzma/common/vli_size.c
    common/tuklib_physmem.c
    liblzma/check/check.c
)

if(ENABLE_THREADS)
    set(SRCS ${SRCS}
        common/tuklib_cpucores.c
        liblzma/common/outqueue.c
        liblzma/common/hardware_cputhreads.c
        liblzma/common/stream_encoder_mt.c
    )
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
    	liblzma/common/outqueue.h
    )
endif()

if(HAVE_CHECK_CRC32)
    if(HAVE_SMALL)
        set(SRCS ${SRCS}
            liblzma/check/crc32_small.c
        )
    else()
        set(SRCS ${SRCS}
            liblzma/check/crc32_table.c
        )
        set(PRIVATE_HDRS ${PRIVATE_HDRS}
        	liblzma/check/crc32_table_le.h
        	liblzma/check/crc32_table_be.h
        )
        if(ENABLE_ASSEMBLER)
            set(SRCS ${SRCS}
                liblzma/check/crc32_x86.S
            )
        else()
            set(SRCS ${SRCS}
                liblzma/check/crc32_fast.c
            )
        endif()
    endif()
endif()


if(HAVE_CHECK_CRC64)
    if(HAVE_SMALL)
        set(SRCS ${SRCS}
            liblzma/check/crc64_small.c
        )
    else()
        set(SRCS ${SRCS}
            liblzma/check/crc64_table.c
        )
        set(PRIVATE_HDRS ${PRIVATE_HDRS}
        	liblzma/check/crc64_table_le.h
        	liblzma/check/crc64_table_be.h
        )
        if(ENABLE_ASSEMBLER)
            set(SRCS ${SRCS}
                liblzma/check/crc64_x86.S
            )
        else()
            set(SRCS ${SRCS}
                liblzma/check/crc64_fast.c
            )
        endif()
    endif()
endif()

if(HAVE_CHECK_SHA256 AND USE_INTERNAL_SHA256)
    set(SRCS ${SRCS}
        liblzma/check/sha256.c
    )
endif()

if(HAVE_FILTER_LZ AND HAVE_ENCODER_LZ)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        liblzma/lz/lz_encoder.h
        liblzma/lz/lz_encoder_hash.h
        liblzma/lz/lz_encoder_hash_table.h
    )
    set(SRCS ${SRCS}
        liblzma/lz/lz_encoder.c
        liblzma/lz/lz_encoder_mf.c
    )
endif()

if(HAVE_FILTER_LZ AND HAVE_DECODER_LZ)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        liblzma/lz/lz_decoder.h
    )
    set(SRCS ${SRCS}
        liblzma/lz/lz_decoder.c
    )
endif()

if(HAVE_FILTER_LZMA1)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        liblzma/lzma/lzma_common.h
    )
    set(SRCS ${SRCS}
        # lzma/fastpos_tablegen.c add to EXTRA_DIST
        liblzma/rangecoder/price_tablegen.c
    )
endif()

if(HAVE_FILTER_LZMA1)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        liblzma/rangecoder/range_common.h
    )
endif()

if(HAVE_ENCODER_LZMA1 AND HAVE_FILTER_LZMA1)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        liblzma/lzma/fastpos.h
        liblzma/lzma/lzma_encoder.h
        liblzma/lzma/lzma_encoder_private.h
        liblzma/rangecoder/range_encoder.h
        liblzma/rangecoder/price.h
    )
    set(SRCS ${SRCS}
        liblzma/lzma/lzma_encoder.c
        liblzma/lzma/lzma_encoder_presets.c
        liblzma/lzma/lzma_encoder_optimum_fast.c
        liblzma/lzma/lzma_encoder_optimum_normal.c
        liblzma/lzma/fastpos_table.c
        liblzma/rangecoder/price_table.c
    )
endif()

if(HAVE_DECODER_LZMA1 AND HAVE_FILTER_LZMA1)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        liblzma/lzma/lzma_decoder.h
        liblzma/rangecoder/range_decoder.h
    )
    set(SRCS ${SRCS}
        liblzma/lzma/lzma_decoder.c
    )
endif()

if(HAVE_ENCODER_LZMA2 AND HAVE_FILTER_LZMA2)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        liblzma/lzma/lzma2_encoder.h
    )
    set(SRCS ${SRCS}
        liblzma/lzma/lzma2_encoder.c
    )
endif()

if(HAVE_DECODER_LZMA2 AND HAVE_FILTER_LZMA2)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        liblzma/lzma/lzma2_decoder.h
    )
    set(SRCS ${SRCS}
        liblzma/lzma/lzma2_decoder.c
    )
endif()

if(HAVE_FILTER_DELTA)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        liblzma/delta/delta_common.h
        liblzma/delta/delta_private.h
    )
    set(SRCS ${SRCS}
        liblzma/delta/delta_common.c
    )
endif()

if(HAVE_ENCODER_DELTA AND HAVE_FILTER_DELTA)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        liblzma/delta/delta_encoder.h
    )
    set(SRCS ${SRCS}
        liblzma/delta/delta_encoder.c
    )
endif()

if(HAVE_DECODER_DELTA AND HAVE_FILTER_DELTA)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        liblzma/delta/delta_decoder.h
    )
    set(SRCS ${SRCS}
        liblzma/delta/delta_decoder.c
    )
endif()

if(HAVE_FILTER_SIMPLE)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        liblzma/simple/simple_coder.h
        liblzma/simple/simple_private.h
    )
    set(SRCS ${SRCS}
        liblzma/simple/simple_coder.c
    )
endif()

if(HAVE_ENCODER_SIMPLE AND HAVE_FILTER_SIMPLE)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        liblzma/simple/simple_encoder.h
    )
    set(SRCS ${SRCS}
        liblzma/simple/simple_encoder.c
    )
endif()

if(HAVE_DECODER_SIMPLE AND HAVE_FILTER_SIMPLE)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        liblzma/simple/simple_decoder.h
    )
    set(SRCS ${SRCS}
        liblzma/simple/simple_decoder.c
    )
endif()

if(HAVE_FILTER_SIMPLE AND HAVE_FILTER_X86)
    set(SRCS ${SRCS}
        liblzma/simple/x86.c
    )
endif()

if(HAVE_FILTER_SIMPLE AND HAVE_FILTER_POWERPC)
    set(SRCS ${SRCS}
        liblzma/simple/powerpc.c
    )
endif()

if(HAVE_FILTER_SIMPLE AND HAVE_FILTER_IA64)
    set(SRCS ${SRCS}
        liblzma/simple/ia64.c
    )
endif()

if(HAVE_FILTER_SIMPLE AND HAVE_FILTER_ARM)
    set(SRCS ${SRCS}
        liblzma/simple/arm.c
    )
endif()

if(HAVE_FILTER_SIMPLE AND HAVE_FILTER_ARMTHUMB)
    set(SRCS ${SRCS}
        liblzma/simple/armthumb.c
    )
endif()

if(HAVE_FILTER_SIMPLE AND HAVE_FILTER_SPARC)
    set(SRCS ${SRCS}
        liblzma/simple/sparc.c
    )
endif()

if(WIN32)
    set(SRCS ${SRCS} liblzma/liblzma_w32res.rc)
    add_definitions(-D_WIN32 -D_WINDOWS -D_USRDLL)
    if(BUILD_SHARED_LIBS)
        add_definitions(-DHAVE_VISIBILITY -DDLL_EXPORT)
    else()
        add_definitions(-DLZMA_API_STATIC)
    endif()
endif()

report_version(${PROJECT_NAME} ${VERSION})

set(LIB_NAME lib${PROJECT_NAME})
if(BUILD_SHARED_LIBS)
    add_library(${LIB_NAME} SHARED ${SRCS} ${PUBLIC_HDRS} ${PRIVATE_HDRS} ${PUBLIC_LZMA_HDRS})
    set_target_properties(${LIB_NAME} PROPERTIES DEFINE_SYMBOL LZMA_DLL
        VERSION ${VERSION}
        SOVERSION 1
    )
elseif(OSX_FRAMEWORK)
    add_library(${LIB_NAME} SHARED ${SRCS} ${PUBLIC_HDRS} ${PRIVATE_HDRS} ${PUBLIC_LZMA_HDRS})
    set_property(SOURCE ${PUBLIC_LZMA_HDRS}
        PROPERTY MACOSX_PACKAGE_LOCATION "Headers/lzma"
    )
    set_target_properties(${LIB_NAME} PROPERTIES
      FRAMEWORK TRUE
      FRAMEWORK_VERSION ${FRAMEWORK_VERSION}
      MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION}
      MACOSX_FRAMEWORK_BUNDLE_VERSION ${VERSION}
      MACOSX_FRAMEWORK_IDENTIFIER org.liblzma.liblzma
      XCODE_ATTRIBUTE_INSTALL_PATH "@rpath"
      PUBLIC_HEADER "${PUBLIC_HDRS}")

else()
    add_library(${LIB_NAME} STATIC ${SRCS} ${PUBLIC_HDRS} ${PRIVATE_HDRS} ${PUBLIC_LZMA_HDRS})
endif()

target_link_extlibraries(${LIB_NAME})

if(UNIX)
    # On unix-like platforms the library is almost always called lib${PROJECT_NAME}
    if(NOT APPLE AND BUILD_SHARED_LIBS)
        set_target_properties(${LIB_NAME} PROPERTIES OUTPUT_NAME ${PROJECT_NAME})
        set_target_properties(${LIB_NAME} PROPERTIES LINK_FLAGS "-Wl,--version-script,\"${CMAKE_CURRENT_SOURCE_DIR}/liblzma.map\"")
    endif()
endif()

# Executables ------------------------------------------------------------------
option(BUILD_APPS "Build lzmainfo, xzdec, xz console utillities" OFF)
if(BUILD_APPS)
    set(lzmainfo_SRC
        lzmainfo/lzmainfo.c
        common/tuklib_progname.c
    	common/tuklib_exit.c
    )
    if(WIN32)
        set(lzmainfo_SRC ${lzmainfo_SRC}
            lzmainfo/lzmainfo_w32res.rc
        )
    endif()
    add_executable(lzmainfo ${lzmainfo_SRC})
    target_link_libraries(lzmainfo ${LIB_NAME})
    if(OSX_FRAMEWORK)
        set_target_properties(lzmainfo PROPERTIES INSTALL_RPATH "@executable_path/../../Library/Frameworks")
    endif()

    set(xzdec_SRC
        xzdec/xzdec.c
        common/tuklib_progname.c
    	common/tuklib_exit.c
    )
    if(WIN32)
        set(xzdec_SRC ${xzdec_SRC}
            xzdec/lzmadec_w32res.rc
        )
    endif()
    add_executable(xzdec ${xzdec_SRC})
    target_link_libraries(xzdec ${LIB_NAME})
    if(OSX_FRAMEWORK)
        set_target_properties(xzdec PROPERTIES INSTALL_RPATH "@executable_path/../../Library/Frameworks")
    endif()

    set(xz_SRC
        xz/args.c
        xz/coder.c
        xz/file_io.c
        xz/hardware.c
        xz/main.c
        xz/message.c
        xz/mytime.c
        xz/options.c
        xz/signals.c
        xz/suffix.c
        xz/util.c
        common/tuklib_open_stdxxx.c
        common/tuklib_progname.c
        common/tuklib_exit.c
        common/tuklib_mbstr_width.c
        common/tuklib_mbstr_fw.c
        xz/list.c
    )
    if(WIN32)
        set(xz_SRC ${xz_SRC}
            xz/xz_w32res.rc
        )
    endif()
    add_executable(xz ${xz_SRC})
    target_link_libraries(xz ${LIB_NAME})
    if(OSX_FRAMEWORK)
        set_target_properties(xz PROPERTIES INSTALL_RPATH "@executable_path/../../Library/Frameworks")
    endif()

    if(NOT SKIP_INSTALL_EXECUTABLES AND NOT SKIP_INSTALL_ALL )
        install(TARGETS xz xzdec lzmainfo
            RUNTIME DESTINATION ${INSTALL_BIN_DIR}
        )
    endif()
endif()

string(TOUPPER ${PACKAGE_NAME} PACKAGE_UPPER_NAME)

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL )
    install(TARGETS ${LIB_NAME}
        EXPORT ${PACKAGE_UPPER_NAME}Targets
        RUNTIME DESTINATION ${INSTALL_BIN_DIR}
        LIBRARY DESTINATION ${INSTALL_LIB_DIR}
        ARCHIVE DESTINATION ${INSTALL_LIB_DIR}
        INCLUDES DESTINATION ${INSTALL_INC_DIR}
        FRAMEWORK DESTINATION ${INSTALL_LIB_DIR}
    )
endif()
if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL )
    install(FILES ${PUBLIC_HDRS} DESTINATION "${INSTALL_INC_DIR}")
    install(FILES ${PUBLIC_LZMA_HDRS} DESTINATION "${INSTALL_INC_DIR}/lzma")
endif()

# Testing ======================================================================
enable_testing()
if(BUILD_TESTING)
    set(TESTS
        bcj_test
        create_compress_files
        test_bcj_exact_size
        test_block_header
        test_check
        test_filter_flags
        test_index
        test_stream_flags
    )

    macro(LZMA_TEST name)
        add_executable(${name} tests/${name}.c)
        target_link_libraries(${name} ${LIB_NAME})
        add_test(${name} ${name})
    endmacro()

    foreach(TEST ${TESTS})
        lzma_test(${TEST})
    endforeach()
endif()

add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)


# Export package ===============================================================

# Add path to includes to build-tree export
target_include_directories(${LIB_NAME} INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/liblzma/api>
)

# Add all targets to the build-tree export set
export(TARGETS ${LIB_NAME}
    FILE ${PROJECT_BINARY_DIR}/${PACKAGE_UPPER_NAME}Targets.cmake)

if(REGISTER_PACKAGE)
    # Export the package for use from the build-tree
    # (this registers the build-tree with a global CMake-registry)
    export(PACKAGE ${PACKAGE_UPPER_NAME})
endif()

# Create the <Package>Config.cmake file
configure_file(cmake/PackageConfig.cmake.in
    ${PROJECT_BINARY_DIR}/${PACKAGE_UPPER_NAME}Config.cmake @ONLY)

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL)
    # Install the <Package>Config.cmake
    install(FILES
      ${PROJECT_BINARY_DIR}/${PACKAGE_UPPER_NAME}Config.cmake
      DESTINATION ${INSTALL_CMAKECONF_DIR} COMPONENT dev)

    # Install the export set for use with the install-tree
    install(EXPORT ${PACKAGE_UPPER_NAME}Targets DESTINATION ${INSTALL_CMAKECONF_DIR} COMPONENT dev)
endif()

# Archiving ====================================================================

set(CPACK_PACKAGE_NAME "${PACKAGE_NAME}")
set(CPACK_PACKAGE_VENDOR "${PACKAGE_VENDOR}")
set(CPACK_PACKAGE_VERSION "${VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PACKAGE_NAME} Installation")
set(CPACK_PACKAGE_RELOCATABLE TRUE)
set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
set(CPACK_GENERATOR "ZIP")
set(CPACK_MONOLITHIC_INSTALL ON)
set(CPACK_STRIP_FILES TRUE)

# Get cpack zip archive name
get_cpack_filename(${VERSION} PROJECT_CPACK_FILENAME)
set(CPACK_PACKAGE_FILE_NAME ${PROJECT_CPACK_FILENAME})

include(CPack)
