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

set(AC_APPLE_UNIVERSAL_BUILD FALSE)
set(ASSUME_RAM 128)

include(CheckCSourceCompiles)
include(CheckIncludeFiles)
include(CheckFunctionExists)
include(CheckSymbolExists)
include(CheckStructHasMember)
include(CheckTypeSize)
include(TestBigEndian)

#set(gt_expression_test_code  "+ * ngettext (\"\", \"\", 0)")
set(gt_expression_test_code  "")

if(CMAKE_GENERATOR_TOOLSET MATCHES "*xp")
    add_definitions(-D_WIN32_WINNT=0x0501)
endif()

check_c_source_compiles("
    #include <libintl.h>
    extern int _nl_msg_cat_cntr;
    extern int *_nl_domain_bindings;
    int main ()
    {
        bindtextdomain (\"\", \"\");
        return * gettext (\"\")${gt_expression_test_code} + _nl_msg_cat_cntr + *_nl_domain_bindings;
    }
    " ENABLE_NLS)
#option ( ENABLE_NLS "Translation of program messages to the user's native language is requested" OFF)     
  
check_include_files("sys/types.h" HAVE_SYS_TYPES_H)

# FreeBSD  sys/types.h + sha256.h      libmd    SHA256_CTX     SHA256_Init
# NetBSD   sys/types.h + sha2.h                 SHA256_CTX     SHA256_Init
# OpenBSD  sys/types.h + sha2.h                 SHA2_CTX       SHA256Init
# Solaris  sys/types.h + sha2.h        libmd    SHA256_CTX     SHA256Init
# MINIX 3  sys/types.h + minix/sha2.h  libutil  SHA256_CTX     SHA256_Init
# Darwin   CommonCrypto/CommonDigest.h          CC_SHA256_CTX  CC_SHA256_Init

check_include_files("CommonCrypto/CommonDigest.h" HAVE_COMMONCRYPTO_COMMONDIGEST_H)

if(HAVE_COMMONCRYPTO_COMMONDIGEST_H)
    set(HAVE_CC_SHA256_CTX TRUE)
    set(HAVE_CC_SHA256_INIT TRUE)
endif()

check_include_files("sha256.h" HAVE_SHA256_H)

if(HAVE_SHA256_H)
    set(HAVE_SHA256_CTX TRUE)
    set(HAVE_SHA256_INIT TRUE)
endif()

check_include_files("sha2.h" HAVE_SHA2_H)

if(HAVE_SHA2_H)
    check_function_exists("SHA256_Init" HAVE_SHA256_INIT)
    if(HAVE_SHA256_INIT)
        set(HAVE_SHA256_CTX TRUE)
    else()
        check_function_exists("SHA256Init" HAVE_SHA256INIT)
        if(HAVE_SHA256INIT)
            set(HAVE_SHA2_CTX TRUE)
        endif()
    endif()
endif()

check_include_files("minix/sha2.h" HAVE_MINIX_SHA2_H)

if(HAVE_MINIX_SHA2_H)
    set(HAVE_SHA256_CTX TRUE)
    set(HAVE_SHA256_INIT TRUE)
endif()

if(HAVE_COMMONCRYPTO_COMMONDIGEST_H OR HAVE_SHA256_H OR HAVE_SHA2_H OR HAVE_MINIX_SHA2_H)
    set(HAVE_CC_SHA256_CTX TRUE)  
endif()

check_c_source_compiles("
    #ifdef HAVE_SYS_TYPES_H
    # include <sys/types.h>
    #endif
    #ifdef HAVE_COMMONCRYPTO_COMMONDIGEST_H
    # include <CommonCrypto/CommonDigest.h>
    #endif
    #ifdef HAVE_SHA256_H
    # include <sha256.h>
    #endif
    #ifdef HAVE_SHA2_H
    # include <sha2.h>
    #endif
    #ifdef HAVE_MINIX_SHA2_H
    # include <minix/sha2.h>
    #endif
    #ifdef __cplusplus
    extern \"C\"
    #endif
    char SHA256_Init ();
    int main ()
    {
        return SHA256_Init ();
    }" HAVE_SHA256_INIT)
    
    check_c_source_compiles("
    #ifdef HAVE_SYS_TYPES_H
    # include <sys/types.h>
    #endif
    #ifdef HAVE_COMMONCRYPTO_COMMONDIGEST_H
    # include <CommonCrypto/CommonDigest.h>
    #endif
    #ifdef HAVE_SHA256_H
    # include <sha256.h>
    #endif
    #ifdef HAVE_SHA2_H
    # include <sha2.h>
    #endif
    #ifdef HAVE_MINIX_SHA2_H
    # include <minix/sha2.h>
    #endif
    #ifdef __cplusplus
    extern \"C\"
    #endif
    char SHA256Init ();
    int main ()
    {
        return SHA256Init ();
    }" HAVE_SHA256INIT)
    
if(NOT HAVE_CC_SHA256_INIT AND NOT HAVE_SHA256_INIT AND NOT HAVE_SHA256INIT)    
    set(USE_INTERNAL_SHA256 TRUE)
endif()    
    
check_c_source_compiles("
    #include <CoreFoundation/CFLocale.h>
    int main () {
        CFLocaleCopyCurrent();
        return 0;
    }" HAVE_CFLOCALECOPYCURRENT)
    
option(HAVE_CHECK_CRC32 "Enable CRC32 integrity check to build" ON)
option(HAVE_CHECK_CRC64 "Enable CRC64 integrity check to build" ON)
option(HAVE_CHECK_SHA256 "Enable SHA256 integrity check to build" ON)

check_function_exists("clock_gettime" HAVE_CLOCK_GETTIME)
check_function_exists("dcgettext" HAVE_DCGETTEXT)
check_symbol_exists("CLOCK_MONOTONIC" "time.h" HAVE_DECL_CLOCK_MONOTONIC)    
check_symbol_exists("program_invocation_name" "errno.h" HAVE_DECL_PROGRAM_INVOCATION_NAME)

option(HAVE_FILTER_ARM "Enable arm filter to build" ON)
option(HAVE_FILTER_ARMTHUMB "Enable armthumb filter to build" ON)
option(HAVE_FILTER_DELTA "Enable delta filter to build" ON)
option(HAVE_FILTER_IA64 "Enable ia64 filter to build" ON)
option(HAVE_FILTER_LZMA1 "Enable lzma1 filter to build" ON)
option(HAVE_FILTER_LZMA2 "Enable lzma2 filter to build" ON)
option(HAVE_FILTER_SPARC "Enable sparc filter to build" ON)
option(HAVE_FILTER_POWERPC "Enable powerpc filter to build" ON)
option(HAVE_FILTER_X86 "Enable x86 filter to build" ON)

if(HAVE_FILTER_LZMA1 OR HAVE_FILTER_LZMA2)
    set(HAVE_FILTER_LZ ON)
endif()

if(HAVE_FILTER_ARM OR HAVE_FILTER_ARMTHUMB OR HAVE_FILTER_IA64 OR HAVE_FILTER_SPARC OR HAVE_FILTER_POWERPC OR HAVE_FILTER_X86)
    set(HAVE_FILTER_SIMPLE ON)
endif()

option(HAVE_DECODER_ARM "Enable arm decoder to build" ON)
option(HAVE_DECODER_ARMTHUMB "Enable armthumb decoder to build" ON)
option(HAVE_DECODER_DELTA "Enable delta decoder to build" ON)
option(HAVE_DECODER_IA64 "Enable ia64 decoder to build" ON)
option(HAVE_DECODER_LZMA1 "Enable lzma1 decoder to build" ON)
option(HAVE_DECODER_LZMA2 "Enable lzma2 decoder to build" ON)
option(HAVE_DECODER_SPARC "Enable sparc decoder to build" ON)
option(HAVE_DECODER_POWERPC "Enable powerpc decoder to build" ON)
option(HAVE_DECODER_X86 "Enable x86 decoder to build" ON)

if(HAVE_DECODER_LZMA1 OR HAVE_DECODER_LZMA2)
    set(HAVE_DECODER_LZ ON)
endif()

if(HAVE_DECODER_ARM OR HAVE_DECODER_ARMTHUMB OR HAVE_DECODER_IA64 OR HAVE_DECODER_SPARC OR HAVE_DECODER_POWERPC OR HAVE_DECODER_X86)
    set(HAVE_DECODER_SIMPLE ON)
endif()

check_include_files("dlfcn.h" HAVE_DLFCN_H)

option(HAVE_ENCODER_ARM "Enable arm encoder to build" ON)
option(HAVE_ENCODER_ARMTHUMB "Enable armthumb encoder to build" ON)
option(HAVE_ENCODER_DELTA "Enable delta encoder to build" ON)
option(HAVE_ENCODER_IA64 "Enable ia64 encoder to build" ON)
option(HAVE_ENCODER_LZMA1 "Enable lzma1 encoder to build" ON)
option(HAVE_ENCODER_LZMA2 "Enable lzma2 encoder to build" ON)
option(HAVE_ENCODER_SPARC "Enable sparc encoder to build" ON)
option(HAVE_ENCODER_POWERPC "Enable powerpc encoder to build" ON)
option(HAVE_ENCODER_X86 "Enable x86 encoder to build" ON)

if(HAVE_ENCODER_LZMA1 OR HAVE_ENCODER_LZMA2)
    set(HAVE_ENCODER_LZ ON)
endif()

if(HAVE_ENCODER_ARM OR HAVE_ENCODER_ARMTHUMB OR HAVE_ENCODER_IA64 OR HAVE_ENCODER_SPARC OR HAVE_ENCODER_POWERPC OR HAVE_ENCODER_X86)
    set(HAVE_ENCODER_SIMPLE ON)
endif()

check_include_files("fcntl.h" HAVE_FCNTL_H) 

check_function_exists("futimens" HAVE_FUTIMENS)
check_function_exists("futimes" HAVE_FUTIMES)
check_function_exists("futimesat" HAVE_FUTIMESAT)

check_include_files("getopt.h" HAVE_GETOPT_H) 

check_function_exists("getopt_long" HAVE_GETOPT_LONG)
check_function_exists("gettext" HAVE_GETTEXT)

check_include_files("immintrin.h" HAVE_IMMINTRIN_H) 
check_include_files("inttypes.h" HAVE_INTTYPES_H) 
check_include_files("limits.h" HAVE_LIMITS_H) 

check_c_source_compiles("
    #include <CoreFoundation/CFPreferences.h>
    int main ()
    {
        CFPreferencesCopyAppValue(NULL, NULL);
        return 0;
    }" HAVE_CFPREFERENCESCOPYAPPVALUE)
    
check_c_source_compiles("
    #include <wchar.h>
    int main () {
        wchar_t wc;
        char const s[] = \"\";
        size_t n = 1;
        mbstate_t state;
	    return ! (sizeof state && (mbrtowc) (&wc, s, n, &state));
    }
    " HAVE_MBRTOWC)
  
check_include_files("memory.h" HAVE_MEMORY_H)

#hc3,hc4,bt2,bt3,bt4
option(HAVE_MF_BT2 "Enable bt2 match finder" ON)
option(HAVE_MF_BT3 "Enable bt3 match finder" ON)
option(HAVE_MF_BT4 "Enable bt4 match finder" ON)
option(HAVE_MF_HC3 "Enable hc3 match finder" ON)
option(HAVE_MF_HC4 "Enable hc4 match finder" ON)

check_symbol_exists("optreset" "getopt.h" HAVE_OPTRESET)

check_function_exists("posix_fadvise" HAVE_POSIX_FADVISE)
check_function_exists("pthread_condattr_setclock" HAVE_PTHREAD_CONDATTR_SETCLOCK)

check_c_source_compiles("
    #include <pthread.h>
    int main () {
        int i = PTHREAD_PRIO_INHERIT;
        return 0;
    }" HAVE_PTHREAD_PRIO_INHERIT)
    
option(HAVE_SMALL "Check if small size is preferred over speed" OFF)
option(ENABLE_THREADS "Enable threading support" ON)
# default is on but no code to build assembler crc32_x86.S via libtool  
option(ENABLE_ASSEMBLER "Enable assembler optimizations" OFF)
    
check_include_files(stdbool.h HAVE_STDBOOL_H)
if(NOT HAVE_STDBOOL_H)
  check_type_size(_Bool _BOOL)
endif()    
   
check_include_files("stdint.h" HAVE_STDINT_H)
check_include_files("stdlib.h" HAVE_STDLIB_H)
check_include_files("strings.h" HAVE_STRINGS_H)
check_include_files("string.h" HAVE_STRING_H)

check_struct_has_member("struct stat" st_atimensec "sys/stat.h" HAVE_STRUCT_STAT_ST_ATIMENSEC)
check_struct_has_member("struct stat" st_atimespec.tv_nsec "sys/stat.h" HAVE_STRUCT_STAT_ST_ATIMESPEC_TV_NSEC)
check_struct_has_member("struct stat" st_atim.st__tim.tv_nsec "sys/stat.h" HAVE_STRUCT_STAT_ST_ATIM_ST__TIM_TV_NSEC)
check_struct_has_member("struct stat" st_atim.tv_nsec "sys/stat.h" HAVE_STRUCT_STAT_ST_ATIM_TV_NSEC)
check_struct_has_member("struct stat" st_uatime "sys/stat.h" HAVE_STRUCT_STAT_ST_UATIME   )

check_include_files("sys/byteorder.h" HAVE_SYS_BYTEORDER_H)
check_include_files("sys/endian.h" HAVE_SYS_ENDIAN_H)
check_include_files("sys/param.h" HAVE_SYS_PARAM_H)
check_include_files("sys/stat.h" HAVE_SYS_STAT_H)
check_include_files("sys/time.h" HAVE_SYS_TIME_H)    
check_include_files("sys/types.h" HAVE_SYS_TYPES_H)   
check_include_files("sys/time.h" HAVE_SYS_TIME_H)
    
check_type_size(uintptr_t UINTPTR_T)
if(NOT HAVE_UINTPTR_T)
  if("${CMAKE_SIZEOF_VOID_P}" EQUAL 8)
    set(uintptr_t "uint64_t")
  else()
    set(uintptr_t "uint32_t")
  endif()
endif()    
   
check_include_files("unistd.h" HAVE_UNISTD_H)
    
check_function_exists("utime" HAVE_UTIME)    
check_function_exists("utimes" HAVE_UTIMES)
    
check_c_source_compiles("
    extern __attribute__((__visibility__(\"hidden\"))) int hiddenvar;
    extern __attribute__((__visibility__(\"default\"))) int exportedvar;
    extern __attribute__((__visibility__(\"hidden\"))) int hiddenfunc (void);
    extern __attribute__((__visibility__(\"default\"))) int exportedfunc (void);
    void dummyfunc (void) {}
    int main (){
      return 0;
    }    
    " HAVE_VISIBILITY)
    
check_function_exists("wcwidth" HAVE_WCWIDTH)   
  
check_symbol_exists("_mm_movemask_epi8" "immintrin.h" HAVE__MM_MOVEMASK_EPI8)    
   
if(UNIX)    
    set(MYTHREAD_POSIX TRUE)  
    add_definitions(-DMYTHREAD_POSIX) 
else( ) # WIN32 true if windows (32 and 64 bit)

    ## Check for Version ##
    if( ${CMAKE_SYSTEM_VERSION} VERSION_GREATER 6.0 ) # Windows Vista and newer
        set(MYTHREAD_VISTA TRUE)
        add_definitions(-DMYTHREAD_VISTA) 
    else() # Some other Windows
        set(MYTHREAD_WIN95 TRUE)
        add_definitions(-DMYTHREAD_WIN95) 
    endif()

endif()    
    
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(NDEBUG TRUE)
endif()   

check_type_size(size_t SIZEOF_SIZE_T)    

check_include_file("ctype.h" HAVE_CTYPE_H)

if (HAVE_CTYPE_H AND HAVE_STDLIB_H)
    set(STDC_HEADERS 1)
endif ()


check_c_source_compiles (
  "#include<byteswap.h>\nint main(void){bswap_16(0);return 0;}"
  HAVE_BSWAP_16)
check_c_source_compiles (
  "#include<byteswap.h>\nint main(void){bswap_32(0);return 0;}"
  HAVE_BSWAP_32)
check_c_source_compiles (
  "#include<byteswap.h>\nint main(void){bswap_64(0);return 0;}"
  HAVE_BSWAP_64)

test_big_endian(WORDS_BIGENDIAN)

check_type_size(int16_t INT16_T)
check_type_size(int32_t INT32_T)
check_type_size(int64_t INT64_T)
check_type_size(intmax_t INTMAX_T)
check_type_size(uint8_t UINT8_T)
check_type_size(uint16_t UINT16_T)
check_type_size(uint32_t UINT32_T)
check_type_size(uint64_t UINT64_T)
check_type_size(uintmax_t UINTMAX_T)

check_type_size("short" SIZE_OF_SHORT)
check_type_size("int" SIZE_OF_INT)
check_type_size("long" SIZE_OF_LONG)
check_type_size("long long" SIZE_OF_LONG_LONG)

check_type_size("unsigned short" SIZE_OF_UNSIGNED_SHORT)
check_type_size("unsigned" SIZE_OF_UNSIGNED)
check_type_size("unsigned long" SIZE_OF_UNSIGNED_LONG)
check_type_size("unsigned long long" SIZE_OF_UNSIGNED_LONG_LONG)
check_type_size("size_t" SIZE_OF_SIZE_T)

check_type_size("__int64" __INT64)
check_type_size("unsigned __int64" UNSIGNED___INT64)

set(PACKAGE ${PROJECT_NAME})
set(PACKAGE_NAME "lib${PACKAGE}")
set(PACKAGE_VERSION ${VERSION})
set(PACKAGE_STRING "${PACKAGE_NAME} ${PACKAGE_VERSION}")
set(PACKAGE_URL "http://tukaani.org/xz/")

configure_file(${CMAKE_MODULE_PATH}/config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h IMMEDIATE @ONLY)
add_definitions(-DHAVE_CONFIG_H) 

