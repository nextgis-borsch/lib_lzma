################################################################################
# Project:  Lib LZMA
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nexgis.com
################################################################################
# Copyright (C) 2015, NextGIS <info@nextgis.com>
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

cmake_minimum_required(VERSION 2.8.10 FATAL_ERROR)

project(lzma C)

# some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin" CACHE INTERNAL "Installation directory for executables" FORCE)
set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib" CACHE INTERNAL "Installation directory for libraries" FORCE)
set(INSTALL_INC_DIR "${CMAKE_INSTALL_PREFIX}/include" CACHE INTERNAL "Installation directory for headers" FORCE)

include(util)
set(LZMA_MAJOR_VERSION -1)
set(LZMA_MINOR_VERSION -1)
set(LZMA_REV_VERSION -1)
check_version(LZMA_MAJOR_VERSION LZMA_MINOR_VERSION LZMA_REV_VERSION)
set(VERSION ${LZMA_MAJOR_VERSION}.${LZMA_MINOR_VERSION}.${LZMA_REV_VERSION})

include(find_anyproject)
find_anyproject(ICONV)

if(ICONV_FOUND)
    set(HAVE_ICONV TRUE)
endif()

if(MSVC)
    if(CMAKE_C_COMPILER_VERSION VERSION_LESS "18.0.40629.0")
        message(FATAL_ERROR "The compiled version is less than VC 2013 SP 5")
    endif()
    
    add_definitions (-D_CRT_NONSTDC_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NON_CONFORMING_SWPRINTFS -D_CRT_SECURE_NO_DEPRECATE)
endif()

include(configure)

configure_file(${CMAKE_MODULE_PATH}/cmake_uninstall.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake IMMEDIATE @ONLY)

include_directories ( ${CMAKE_CURRENT_SOURCE_DIR} )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/api )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/check )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/common )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/delta )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/lz )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/lzma )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/rangecoder )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/simple )
include_directories ( ${CMAKE_CURRENT_BINARY_DIR} )

set(PUBLIC_HDRS
    api/lzma.h
)

set(PUBLIC_LZMA_HDRS
    api/lzma/base.h
    api/lzma/bcj.h
    api/lzma/block.h
    api/lzma/check.h
    api/lzma/container.h
    api/lzma/delta.h
    api/lzma/filter.h
    api/lzma/hardware.h
    api/lzma/index.h
    api/lzma/index_hash.h
    api/lzma/lzma12.h
    api/lzma/stream_flags.h
    api/lzma/version.h
    api/lzma/vli.h
)

set(PRIVATE_HDRS
    ${CMAKE_CURRENT_BINARY_DIR}/config.h
    sysdefs.h
	common/block_buffer_encoder.h
	common/block_encoder.h
	common/filter_encoder.h
	common/index_encoder.h
	common/alone_decoder.h
	common/block_decoder.h
	common/filter_decoder.h
	common/stream_decoder.h
    common/tuklib_physmem.h
    check/check.h
)

set(SRCS
    common/alone_encoder.c
    common/block_buffer_encoder.c
    common/block_encoder.c
    common/block_header_encoder.c
    common/easy_buffer_encoder.c
    common/easy_encoder.c
    common/easy_encoder_memusage.c
    common/filter_buffer_encoder.c
    common/filter_encoder.c
    common/filter_flags_encoder.c
    common/index_encoder.c
    common/stream_buffer_encoder.c
    common/stream_encoder.c
    common/stream_flags_encoder.c
    common/vli_encoder.c
    common/alone_decoder.c
    common/auto_decoder.c
    common/block_buffer_decoder.c
    common/block_decoder.c
    common/block_header_decoder.c
    common/easy_decoder_memusage.c
    common/filter_buffer_decoder.c
    common/filter_decoder.c
    common/filter_flags_decoder.c
    common/index_decoder.c
    common/index_hash.c
    common/index.c
    common/stream_buffer_decoder.c
    common/stream_decoder.c
    common/stream_flags_decoder.c
    common/vli_decoder.c
    common/common.c
    common/block_util.c
    common/easy_preset.c
    common/filter_common.c
    common/hardware_physmem.c
    common/stream_flags_common.c
    common/vli_size.c
    common/tuklib_physmem.c
    check/check.c
)

if(ENABLE_THREADS)
    set(SRCS ${SRCS}
        tuklib_cpucores.c
        common/outqueue.c
        common/hardware_cputhreads.c
        common/stream_encoder_mt.c
    )
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
    	common/outqueue.h
    )    
endif()

if(HAVE_CHECK_CRC32)
    if(HAVE_SMALL)
        set(SRCS ${SRCS}
            check/crc32_small.c
        )
    else()
        set(SRCS ${SRCS}
            check/crc32_table.c
        )
        set(PRIVATE_HDRS ${PRIVATE_HDRS}
        	check/crc32_table_le.h
        	check/crc32_table_be.h
        )
        if(ENABLE_ASSEMBLER)
            set(SRCS ${SRCS}
                check/crc32_x86.S
            )
        else()
            set(SRCS ${SRCS}
                check/crc32_fast.c
            )
        endif() 
    endif()
endif()


if(HAVE_CHECK_CRC64)
    if(HAVE_SMALL)
        set(SRCS ${SRCS}
            check/crc64_small.c
        )
    else()
        set(SRCS ${SRCS}
            check/crc64_table.c
        )
        set(PRIVATE_HDRS ${PRIVATE_HDRS}
        	check/crc64_table_le.h
        	check/crc64_table_be.h
        )
        if(ENABLE_ASSEMBLER)
            set(SRCS ${SRCS}
                check/crc64_x86.S
            )
        else()
            set(SRCS ${SRCS}
                check/crc64_fast.c
            )
        endif() 
    endif()
endif()

if(HAVE_CHECK_SHA256 AND USE_INTERNAL_SHA256)
    set(SRCS ${SRCS}
        check/sha256.c
    )
endif()

if(HAVE_FILTER_LZ AND HAVE_ENCODER_LZ)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        lz/lz_encoder.h
        lz/lz_encoder_hash.h
        lz/lz_encoder_hash_table.h
    )
    set(SRCS ${SRCS}
        lz/lz_encoder.c
        lz/lz_encoder_mf.c
    )
endif()

if(HAVE_FILTER_LZ AND HAVE_DECODER_LZ)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        lz/lz_decoder.h
    )
    set(SRCS ${SRCS}
        lz/lz_decoder.c
    )
endif()

if(HAVE_FILTER_LZMA1)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        lzma/lzma_common.h
    )
    set(SRCS ${SRCS}
        # lzma/fastpos_tablegen.c add to EXTRA_DIST
        rangecoder/price_tablegen.c
    )
endif()

if(HAVE_FILTER_LZMA1)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        rangecoder/range_common.h
    )
endif()

if(HAVE_ENCODER_LZMA1 AND HAVE_FILTER_LZMA1)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        lzma/fastpos.h
        lzma/lzma_encoder.h
        lzma/lzma_encoder_private.h
        rangecoder/range_encoder.h
        rangecoder/price.h
    )
    set(SRCS ${SRCS}
        lzma/lzma_encoder.c
        lzma/lzma_encoder_presets.c
        lzma/lzma_encoder_optimum_fast.c
        lzma/lzma_encoder_optimum_normal.c
        lzma/fastpos_table.c
        rangecoder/price_table.c
    )
endif()

if(HAVE_DECODER_LZMA1 AND HAVE_FILTER_LZMA1)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        lzma/lzma_decoder.h
        rangecoder/range_decoder.h
    )
    set(SRCS ${SRCS}
        lzma/lzma_decoder.c
    )
endif()

if(HAVE_ENCODER_LZMA2 AND HAVE_FILTER_LZMA2)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        lzma/lzma2_encoder.h
    )
    set(SRCS ${SRCS}
        lzma/lzma2_encoder.c
    )
endif()

if(HAVE_DECODER_LZMA2 AND HAVE_FILTER_LZMA2)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        lzma/lzma2_decoder.h
    )
    set(SRCS ${SRCS}
        lzma/lzma2_decoder.c
    )
endif()

if(HAVE_FILTER_DELTA)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        delta/delta_common.h
        delta/delta_private.h
    )    
    set(SRCS ${SRCS} 
        delta/delta_common.c
    )
endif()

if(HAVE_ENCODER_DELTA AND HAVE_FILTER_DELTA)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        delta/delta_encoder.h
    )    
    set(SRCS ${SRCS} 
        delta/delta_encoder.c
    ) 
endif()

if(HAVE_DECODER_DELTA AND HAVE_FILTER_DELTA)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        delta/delta_decoder.h
    ) 
    set(SRCS ${SRCS} 
        delta/delta_decoder.c
    )
endif()

if(HAVE_FILTER_SIMPLE)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        simple/simple_coder.h
        simple/simple_private.h
    )    
    set(SRCS ${SRCS} 
        simple/simple_coder.c
    )
endif()

if(HAVE_ENCODER_SIMPLE AND HAVE_FILTER_SIMPLE)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        simple/simple_encoder.h
    )    
    set(SRCS ${SRCS} 
        simple/simple_encoder.c
    ) 
endif()

if(HAVE_DECODER_SIMPLE AND HAVE_FILTER_SIMPLE)
    set(PRIVATE_HDRS ${PRIVATE_HDRS}
        simple/simple_decoder.h
    ) 
    set(SRCS ${SRCS} 
        simple/simple_decoder.c
    )
endif()

if(HAVE_FILTER_SIMPLE AND HAVE_FILTER_X86)
    set(SRCS ${SRCS} 
        simple/x86.c
    )
endif()

if(HAVE_FILTER_SIMPLE AND HAVE_FILTER_POWERPC)
    set(SRCS ${SRCS} 
        simple/powerpc.c
    )
endif()

if(HAVE_FILTER_SIMPLE AND HAVE_FILTER_IA64)
    set(SRCS ${SRCS} 
        simple/ia64.c
    )
endif()

if(HAVE_FILTER_SIMPLE AND HAVE_FILTER_ARM)
    set(SRCS ${SRCS} 
        simple/arm.c
    )
endif()

if(HAVE_FILTER_SIMPLE AND HAVE_FILTER_ARMTHUMB)
    set(SRCS ${SRCS} 
        simple/armthumb.c
    )
endif()

if(HAVE_FILTER_SIMPLE AND HAVE_FILTER_SPARC)
    set(SRCS ${SRCS} 
        simple/sparc.c
    )
endif()

if(WIN32 AND BUILD_SHARED_LIBS)
  set(SRCS ${SRCS} liblzma_w32res.rc)
  add_definitions(-DDLL_EXPORT -D_WINDOWS -D_USRDLL -DLIBLZMADLL_EXPORTS)
endif()

report_version(${PROJECT_NAME} ${VERSION})    

if(BUILD_SHARED_LIBS)
    set(LIB_NAME ${PROJECT_NAME})
    add_library(${LIB_NAME} SHARED ${SRCS} ${PUBLIC_HDRS} ${PRIVATE_HDRS} ${PUBLIC_LZMA_HDRS})
    set_target_properties(${LIB_NAME} PROPERTIES DEFINE_SYMBOL LZMA_DLL)
    set_target_properties(${LIB_NAME} PROPERTIES SOVERSION 1)
else()    
    set(LIB_NAME ${PROJECT_NAME}static)
    add_library(${LIB_NAME} STATIC ${SRCS} ${PUBLIC_HDRS} ${PRIVATE_HDRS} ${PUBLIC_LZMA_HDRS})
    set_target_properties(${LIB_NAME} PROPERTIES SOVERSION 1)
endif()   

target_link_extlibraries(${LIB_NAME}) 

export(TARGETS ${LIB_NAME} FILE ${LIB_NAME}-exports.cmake)
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

if(NOT CYGWIN)
    set_target_properties(${LIB_NAME} PROPERTIES VERSION ${VERSION})
endif()

if(UNIX)
    # On unix-like platforms the library is almost always called lib${PROJECT_NAME}
    set_target_properties(${LIB_NAME} PROPERTIES OUTPUT_NAME ${PROJECT_NAME})
    if(NOT APPLE AND BUILD_SHARED_LIBS)
        set_target_properties(${LIB_NAME} PROPERTIES LINK_FLAGS "-Wl,--version-script,\"${CMAKE_CURRENT_SOURCE_DIR}/liblzma.map\"")
    endif()
endif()

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL )
    install(TARGETS ${LIB_NAME} 
        RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
        ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
        LIBRARY DESTINATION "${INSTALL_LIB_DIR}" )
endif()
if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL )
    install(FILES ${PUBLIC_HDRS} DESTINATION "${INSTALL_INC_DIR}")
    install(FILES ${PUBLIC_LZMA_HDRS} DESTINATION "${INSTALL_INC_DIR}/lzma")
endif()

